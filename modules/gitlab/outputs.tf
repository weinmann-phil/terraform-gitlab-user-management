/**
 * Output GitLab Projects
 *
 * Echoes a list of GitLab projects
 */
output "gitlab_projects" {
  value = local.gitlab_var_project_paths
}