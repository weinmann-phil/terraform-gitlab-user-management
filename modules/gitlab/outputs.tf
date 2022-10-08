/**
 * Output GitLab Projects
 *
 * Echoes a list of GitLab projects
 */
output "gitlab_projects" {
  value = local.gitlab_var_project_paths
}

/**
 * Output GitLab Users
 *
 * Echoes a list of GitLab users
 */
output "gitlab_users" {
  value = local.gitlab_var_existing_users
}

/**
 * Output Project Membership
 *
 * Echoes all projects and their members
 */
output "gitlab_project_membership" {
  value = local.gitlab_project_membership
}