/**
 * Required Variables
 */
variable "gitlab_token" {
  description = "(Required) Sets the access token for the technical user"
  type        = string
}

variable "gitlab_users" {
  description = "(Required) Sets an aray of users as active GitLab members"
  type        = list(object({
    email = string
    is_external = bool
    is_admin = bool
  }))
}