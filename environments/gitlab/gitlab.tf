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
  gitlab_var_active_user_array = (var.gitlab_users == null) ? [] : var.gitlab_users
  gitlab_var_active_user = [ for user in var.gitlab_users :
    {
      user = title(join(" ", split(".", split("@", user["email"])[0])))
      username = split("@", user["email"])[0]
      email = user["email"]
      is_admin = (user["is_external"] == true) ? false : user["is_admin"]
      is_external = user["is_external"]
      project_limit = (user["is_external"] == true) ? 10 : 10000
      can_create_group = (user["is_external"] == true) ? false : true
    }
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
  token = var.gitlab_token
  base_url = "http://localhost"
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