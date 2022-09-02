[
  {
    "name": "${project}-${group}-${env}",
    "image": "${app_image}",
    "cpu": 256,
    "memory": 512,
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/${project}-${group}-${env}",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "portMappings": [
      {
        "containerPort": ${app_port},
        "hostPort": ${app_port},
        "protocol": "tcp"
      }
    ],
    "essential": true
  }
]