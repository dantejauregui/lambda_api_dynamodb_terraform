terraform {
  backend "s3" {
    # "Key" in this terraform block will only work when you do terraform-apply from your local machine. If run using pipelines, it will be overwritting anyway for its own Key "dev.state" or "prod.state" depending:
    key     = "terraform/dev.tfstate"
    encrypt = true
  }
}
