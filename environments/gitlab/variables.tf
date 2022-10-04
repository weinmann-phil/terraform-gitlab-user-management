/**
 * Required Variables
 */
variable "gitlab_token" {
  description = "(Required) Sets the access token for the technical user"
  type        = string
  sensitive   = true
}

variable "gitlab_public_host" {
  description = "(Required) Sets the public host DNS for your self-hosted GitLab"
  type        = string
  sensitive   = false
}

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
