#############
### ROLES ###
#############

# ECS task execution role data
data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS execution role
resource "aws_iam_role" "ecs_execution_role" {
  name               = "${var.project}-${var.group}-ecs-tasks-execution-role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

# ECS execution role policy attachment
resource "aws_iam_role_policy_attachment" "ecs_execution_role" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS task role
resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.project}-${var.group}-ecs-tasks-role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}
# ECS task role policy attachment
resource "aws_iam_role_policy_attachment" "ecs_task_role_s3" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_secretmanager" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}


################
### Security ###
################

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project}-${var.group}-ecs-tasks-security-group-${var.env}"
  description = "allow inbound access"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = var.app_port
    to_port         = var.app_port
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "lb" {
  name        = "${var.project}-${var.group}-load-balancer-security-group-${var.env}"
  description = "controls access to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

###################
### ECS Cluster ###
###################

resource "aws_ecs_cluster" "app" {
  name = "${var.project}-${var.group}-cluster-${var.env}"
}

data "template_file" "app" {
  template = file("${path.module}/templates/container_def.json.tpl")

  vars = {
    app_image       = var.ecr_app_url
    app_port        = var.app_port
    fargate_cpu     = var.fargate_cpu
    fargate_memory  = var.fargate_memory
    aws_region      = var.aws_region
    project         = var.project
    group           = var.group
    env             = var.env
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project}-${var.group}-${var.env}"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.app.rendered

  tags = {
    env = var.env
  }
}

resource "aws_ecs_service" "main" {
  name                   = "${var.project}-${var.group}-service-${var.env}"
  cluster                = aws_ecs_cluster.app.id
  task_definition        = aws_ecs_task_definition.app.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = var.subnets
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.id
    container_name   = "${var.project}-${var.group}-${var.env}"
    container_port   = var.app_port
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_role_secretmanager]

  tags = {
    env = var.env
  }
}


##################
### CloudWatch ###
##################

resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = "/ecs/${var.project}-${var.group}-${var.env}"
  retention_in_days = 30

  tags = {
    Name  = "${var.project}-${var.group}-log-group-${var.env}"
    Group = var.group
  }
}

resource "aws_cloudwatch_log_stream" "app_log_stream" {
  name           = "${var.project}-${var.group}-log-stream-${var.env}"
  log_group_name = aws_cloudwatch_log_group.app_log_group.name
}


#####################
### Load Balancer ###
#####################

resource "aws_alb" "main" {
  name            = "${var.project}-${var.group}-lb-${var.env}"
  subnets         = var.subnets
  security_groups = [aws_security_group.lb.id]
}

resource "aws_lb_target_group" "main" {
  name        = "${var.project}-${var.group}-tg-${var.env}"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "200"
    protocol            = "HTTP"
    matcher             = "200-499"
    timeout             = "50"
    path                = "/"
    unhealthy_threshold = "3"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "app" {
  load_balancer_arn = aws_alb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.main.id
    type = "forward"
  }
}

