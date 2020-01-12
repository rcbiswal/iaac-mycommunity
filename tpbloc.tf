## Terraform project. This project uses remote state to store the details of resources terraform has
## created. All state should be stored in a remote backend (s3) to allow collaboration across users
## More details on Terraform state can be found here: https://www.terraform.io/docs/state/index.html
## More details on Terraform remote state here: https://www.terraform.io/docs/state/remote.html

## IMPORTANT: The remote state configuration in this template requires Terraform v0.11.1.

terraform {
  required_version = "= 0.11.1"
}

## Providers ##

provider "aws" {
  region  = "${var.region}"
  version = "2.31"
}