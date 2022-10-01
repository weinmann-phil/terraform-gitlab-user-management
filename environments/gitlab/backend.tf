terraform {
  backend "local" {
    path = "~/.terraform/states/gitlab.tfstate"
  }
}