terraform {
  backend "s3" {
    key            = "terraform/state.tfstate"
    encrypt        = true
  }
}
