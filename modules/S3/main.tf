resource "aws_s3_bucket" "logs" {
  bucket = "${var.project}-${var.group}-${var.env}"

  tags = {
    Name        = "${var.project}-${var.group}-${var.env}"
    Environment = var.env
  }
}

resource "aws_s3_bucket_acl" "logs" {
  bucket = aws_s3_bucket.logs.id
  acl    = "private"
}