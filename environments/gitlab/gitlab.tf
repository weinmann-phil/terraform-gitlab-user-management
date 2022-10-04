###############################################################################
# GitLab User Management with Terraform
# 
# This module provides a tool with which to manage users within a local 
# instance of GitLab. 
# The tool is intended as a backend automation solution for recruiters within a
# tech company. 
#
# Version: v0.0.1
#

/**
 * Local Variables
 *
 * Sets constants or conditional variables for this area and further logic on input values
 */
locals {
  gitlab_var_active_user = [ for user in var.gitlab_users :
    {
      user = title(join(" ", split(".", split("@", user["email"])[0])))
      username = split("@", user["email"])[0]
      email = user["email"]
      is_admin = (user["is_external"] == true) ? false : user["is_admin"]
      is_external = user["is_external"]
      project_limit = (user["is_external"] == true) ? 10 : 10000
      can_create_group = (user["is_external"] == true) ? false : true
      membership = [ for project in user["membership"] : {
        project = project.project
        access_level = lookup(project, "access_level", user.is_external == true ? "reporter" : user.is_admin == true ? "maintainer" : "developer")
      }]
    }
  ]
  gitlab_var_project_memberships = distinct(flatten([ for user in local.gitlab_var_active_user : [
      for project in user.membership : {
        user = user.user
        project = project.project
        access_level = project.access_level
      }
    ]
  ]))
  gitlab_var_project_paths = [
    "test-group/project01",
    "test-group/project02",
    "test-group/project03",
  ]
}

/**
 * Provider Configuration
 *
 * Configures the provider to enable specific provider methods 
 * Please refer to the official documentation for further information:
 * https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs
 *
 * @param token    (Required) Sets the access token for the technical user
 * @param base_url (Required) Sets the URL of the self-hosted GitLab instance
 */
provider "gitlab" {
  token    = var.gitlab_token
  base_url = var.gitlab_public_host
}

/**
 * GitLab User
 *
 * Manages the user based on a list of map entries
 *
 * @param name             (Required) Sets the name of the GitLab user
 * @param username         (Required) Sets the username for the GitLab user
 * @param email            (Required) Sets the email for the GitLab user
 * @param password         (Optional) Sets the password for the user
 * @param is_admin         (Optional) Sets the user as GitLab administrator
 * @param project_limit    (Optional) Sets the number of project the user can fork
 * @param can_create_group (Optional) Sets the right to create groups in GitLab
 * @param is_external      (Optional) Sets the user as external
 * @param reset_password   (Optional) Sets the user to reset their password upon first login
 */
resource "gitlab_user" "glab" {
  for_each = {for user in local.gitlab_var_active_user : user.user => user}
  name             = each.value.user
  username         = each.value.username
  email            = each.value.email
  is_admin         = each.value.is_admin
  projects_limit   = each.value.project_limit
  can_create_group = each.value.can_create_group
  is_external      = each.value.is_external
  reset_password   = true
}

/**
 * GitLab Projects Data Source
 *
 * Gets data and metadata from existing GitLab projects
 *
 * @param path_with_namespace (Required) Sets the fully qualified path to the repo
 */
data "gitlab_project" "glab_project_id" {
  for_each = toset(local.gitlab_var_project_paths)
  path_with_namespace = each.key
}

/**
 * GitLab Project Membership
 *
 * Manages memberships with respect to the user. 
 * In this case, the relationship is strictly that of one user to many projects
 *
 * @param access_level  (Required) Sets the access level for the member. 
 *   Valid values are: no one, minimal, guest, reporter, developer, maintainer, owner, master
 * @param project_id    (Required) Sets the ID of the project
 * @param user_id       (Required) Sets the ID of the user
 * @param expires_at    (Optional) Sets the expiration date of the project membership
 */
resource "gitlab_project_membership" "glab" {
  for_each = {for member in local.gitlab_var_project_memberships : "${member.user}.${member.project}.${member.access_level}" => member}
  access_level = each.value.access_level
  project_id = data.gitlab_project.glab_project_id[each.value.project].id
  user_id = gitlab_user.glab[each.value.user].id
}