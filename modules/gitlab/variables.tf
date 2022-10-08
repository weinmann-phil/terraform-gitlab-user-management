/**
 * Required Variables
 */
variable "gitlab_users" {
  description = "(Required) Sets an aray of users as active GitLab members"
  type        = list(object({
    email       = string
    is_external = bool
    is_admin    = bool
    membership  = list(map(any))
  }))
  sensitive   = false
}
