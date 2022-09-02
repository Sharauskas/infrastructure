##############################################################
#### Nginx ####

resource "aws_ecr_repository" "repo" {
  name                 = "${var.project}-${var.group}-ecr-${var.env}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}

resource "aws_ecr_lifecycle_policy" "repo" {
  repository = aws_ecr_repository.repo.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last ${var.image_count} images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": ${var.image_count}
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}


