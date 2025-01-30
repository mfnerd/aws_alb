terraform {
  backend "s3" {
    bucket         = "tf4shepzilla"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
  }
}
