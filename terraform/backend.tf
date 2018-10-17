terraform {
  backend "s3" {
    bucket = "goldsquare-state"
    key    = "terraform/gs-infrastructure"
    region = "eu-west-1"
  }
}
