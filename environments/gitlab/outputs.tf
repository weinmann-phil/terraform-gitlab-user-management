/**
 * GitLab Users
 *
 * Echoes all the users and their configurations
 */
output "gitlab_user_array" {
  value = local.gitlab_var_active_user[*].user
}
