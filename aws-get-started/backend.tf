terraform {
  backend "remote" {
    organization = "russomi"

    workspaces {
      name = "Example-Workspace"
    }
  }
}
