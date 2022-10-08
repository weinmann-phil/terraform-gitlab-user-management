###############################################################################
# GitLab Module for User Management
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
  gitlab_var_project_paths = data.gitlab_projects.glab.projects[*].path_with_namespace
  gitlab_var_existing_users = [ for user in data.gitlab_users.glab.users :
    {
      user              = user.name
      username          = user.username
      email             = user.email
      is_admin          = user.is_admin
      is_external       = user.external
      project_limit     = user.projects_limit
      can_create_group  = user.can_create_group
      membership        = toset(flatten([ for project in local.gitlab_project_membership :
        [ for member in project.members :
            (member.member == user.username) ? {
              project = project.project
              access_level = member.access_level
            } : {}
        ]
      ]))
    }
  ]
  gitlab_project_membership = [ for project in data.gitlab_project_membership.glab : 
    {
      project = project.full_path
      members = [ for member in project.members : 
        {
          member = member.username
          access_level = member.access_level
        }
      ]
    }
  ]
}

/**
 * GitLab Users Data Source
 *
 * Gets existing user data
 * For more information about this method, please refer to the following site:
 * https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/data-sources/users
 *
 * @param active    (Optional) Sets the filter for active users
 * @param order_by  (Optional) Sets the parameter by which the output is ordered. 
 *   Accepted Values are `id`, `name`, `username`, `created_at`, or `updated_at`.
 */
data "gitlab_users" "glab" {
  active = true
  order_by = "name"
}

/**
 * GitLab Project Membership Data Source
 *
 * Gets membership data from existing projects
 */
data "gitlab_project_membership" "glab" {
  for_each = toset(local.gitlab_var_project_paths)
  full_path = each.key
}

/**
 * Local File
 *
 * Export the list of users with all project assignments
 *
 * @param content   (Required) Sets the content of the file
 * @param filename  (Required) Sets the path for the export
 */
resource "local_file" "gitlab_users" {
  content  = jsonencode(local.gitlab_var_existing_users)
  filename = "${path.module}/../../environments/gitlab/export.json"
}

/**
 * GitLab User
 *
 * Manages the user based on a list of map entries
 * For more information about this method, please refer to the following site:
 * https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/user
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
 * Gets data and metadata from any existing GitLab projects.
 * For more information about this method, please refer to the following site:
 * https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/data-sources/projects
 *
 * @param order_by          (Optional) 
 * @param include_subgroups (Optional) 
 * @param archived          (Optional) 
 * @param simple            (Optional) 
 */
data "gitlab_projects" "glab" {
  order_by          = "name"
  include_subgroups = true
  archived          = false
  simple            = true
}

/**
 * GitLab Specific Project Data Source
 *
 * Gets data and metadata from existing GitLab projects
 * For more information about this method, please refer to the following site:
 * https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/data-sources/project
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
 * In this case, the relationship is strictly that of one user to many projects. 
 * For more information about this method, please refer to the following site:
 * https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_membership
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