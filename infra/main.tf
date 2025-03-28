# ---------------------------------------------------------------------------------------------------------------------
# PROVIDERS & VARIABLES
# ---------------------------------------------------------------------------------------------------------------------
provider "aws" {
  region = "ca-central-1"
}

variable "ecomiq_namespace" {
  default = "ecomiq"
}

variable "backend_image" {
  default = "727646477053.dkr.ecr.ca-central-1.amazonaws.com/ecomiq-backend:latest"
}

variable "frontend_image" {
  default = "727646477053.dkr.ecr.ca-central-1.amazonaws.com/ecomiq-frontend:latest"
}

variable "acm_certificate_arn" {
  default = "arn:aws:acm:ca-central-1:727646477053:certificate/f6533daa-c0e7-4eab-93f2-ab7b56ae7d9b"
}

# ---------------------------------------------------------------------------------------------------------------------
# NETWORKING - VPC, SUBNETS, ROUTES, GATEWAYS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "${var.ecomiq_namespace}-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "${var.ecomiq_namespace}-igw" }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id
  tags = { Name = "${var.ecomiq_namespace}-nat" }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ca-central-1a"
  map_public_ip_on_launch = true
  tags = { Name = "${var.ecomiq_namespace}-public-a" }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ca-central-1b"
  map_public_ip_on_launch = true
  tags = { Name = "${var.ecomiq_namespace}-public-b" }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ca-central-1a"
  tags = { Name = "${var.ecomiq_namespace}-private-a" }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ca-central-1b"
  tags = { Name = "${var.ecomiq_namespace}-private-b" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "${var.ecomiq_namespace}-public-rt" }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = { Name = "${var.ecomiq_namespace}-private-rt" }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUPS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "ecs" {
  name        = "${var.ecomiq_namespace}-ecs-sg"
  description = "Allow inbound HTTP and HTTPS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.ecomiq_namespace}-sg" }
}

# ---------------------------------------------------------------------------------------------------------------------
# ECS CLUSTER AND IAM ROLES
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_ecs_cluster" "ecomiq" {
  name = "${var.ecomiq_namespace}-cluster"
}

data "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"
}

# ---------------------------------------------------------------------------------------------------------------------
# ALB + TARGET GROUPS + HTTPS LISTENER
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_lb" "ecomiq" {
  name               = "${var.ecomiq_namespace}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  security_groups    = [aws_security_group.ecs.id]
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "frontend" {
  name        = "frontend-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id
}

resource "aws_lb_target_group" "backend" {
  name        = "backend-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/up"
    port                = "3000"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.ecomiq.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404 Not Found"
      status_code  = "404"
    }
  }
}

# Rule for frontend.ecomiqstore.com → frontend target group (port 80)
resource "aws_lb_listener_rule" "frontend" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  condition {
    host_header {
      values = ["frontend.ecomiqstore.com"]
    }
  }
}

# Rule for backend.ecomiqstore.com → backend target group (port 3000)
resource "aws_lb_listener_rule" "backend" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    host_header {
      values = ["backend.ecomiqstore.com"]
    }
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# ECS TASK DEFINITIONS & SERVICES
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.ecomiq_namespace}-frontend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution.arn
  container_definitions    = jsonencode([
    {
      name      = "frontend"
      image     = var.frontend_image
      essential = true
      portMappings = [{ containerPort = 80, protocol = "tcp" }]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/ecs/${var.ecomiq_namespace}-frontend",
          awslogs-region        = "ca-central-1",
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.ecomiq_namespace}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "3072"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution.arn
  task_role_arn            = data.aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = var.backend_ecr_url
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "RAILS_MASTER_KEY"
          value = "e95ecaf6037b6116172b666d376a18bb"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.ecomiq_namespace}-backend"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "frontend" {
  name            = "${var.ecomiq_namespace}-frontend"
  cluster         = aws_ecs_cluster.ecomiq.id
  task_definition = aws_ecs_task_definition.frontend.arn
  launch_type     = "FARGATE"
  desired_count   = 2

  network_configuration {
    subnets         = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = 80
  }
}

resource "aws_ecs_service" "backend" {
  name            = "${var.ecomiq_namespace}-backend"
  cluster         = aws_ecs_cluster.ecomiq.id
  task_definition = aws_ecs_task_definition.backend.arn
  launch_type     = "FARGATE"
  desired_count   = 2

  network_configuration {
    subnets         = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "backend"
    container_port   = 3000
  }
}
