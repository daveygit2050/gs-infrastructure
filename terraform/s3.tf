resource "aws_s3_bucket" "gs-infrastructure-output" {
  bucket = "gs-infrastructure-output"

  lifecycle_rule {
    id      = "general"
    enabled = true

    expiration = {
      days = 7
    }
  }
}
