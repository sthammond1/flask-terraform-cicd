terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

############################
# Default VPC & Subnets
############################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

############################
# Reuse AWS ECS Service Role
############################
data "aws_iam_role" "ecs_execution" {
  name = "AWSServiceRoleForECS"
}

############################
# ECS Cluster
############################
resource "aws_ecs_cluster" "this" {
  name = "flask-cluster"
}

############################
# ECS Task Definition
############################
resource "aws_ecs_task_definition" "this" {
  family                   = "flask-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  execution_role_arn = data.aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([
    {
      name      = "flask"
      image     = var.docker_image
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
    }
  ])
}

############################
# ECS Service
############################
resource "aws_ecs_service" "this" {
  name            = "flask-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    assign_public_ip = true
    security_groups  = []
  }
}
