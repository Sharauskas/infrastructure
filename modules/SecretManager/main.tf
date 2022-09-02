resource "aws_secretsmanager_secret" "app" {
  name = "${var.project}-${var.group}-secret-${var.env}"
}

