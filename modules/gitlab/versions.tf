terraform {
  required_version = ">= 1.3.0"
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = ">= 3.18.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.2.3"
    }
  }
}