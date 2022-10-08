###############################################################################
# GitLab User Management with Terraform main file
# 
# This sets the provider information and calls upon the module. 
#
# Version: v0.0.2
#

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
 * GitLab Module
 *
 * This module transforms the given data and updates all users and their 
 * respective project assignments.
 *
 * @param source       (Required) Sets the source data of the module
 * @param gitlab_users (Required) Sets the list of users and their assigned projects
 */
module "gitlab" {
  source = "../../modules/gitlab"
  gitlab_users = var.gitlab_users
}