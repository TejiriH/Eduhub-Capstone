resource "aws_db_subnet_group" "postgres" {
  name       = "${local.safe_name}-postgres-subnet-group"
  subnet_ids = var.storage_subnet_ids  # your storage private subnets

  tags = {
    Name = "${var.project_name}-postgres-subnet-group"
  }
}

resource "aws_security_group" "postgres" {
  name        = "${var.project_name}-postgres-sg"
  description = "Allow EKS nodes to connect to PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from EKS nodes only"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-postgres-sg"
  }
}

resource "aws_db_instance" "postgres" {
  identifier              = "${local.safe_name}-postgres"
  engine                  = "postgres"
  engine_version          = "15"  # latest 15.x as of 2025
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  max_allocated_storage   = 100
  storage_type            = "gp2"
  storage_encrypted       = true

  db_name  = "eduhub"  # initial database
  username = var.db_master_username
  password = var.db_master_password  

  vpc_security_group_ids = [aws_security_group.postgres.id]
  db_subnet_group_name   = aws_db_subnet_group.postgres.name

  multi_az               = false
  publicly_accessible    = false
  backup_retention_period = 7
  skip_final_snapshot    = true
  apply_immediately      = true

  tags = {
    Name = "${var.project_name}-postgres"
  }
}

# # Create the 4 required databases inside the instance
# resource "null_resource" "create_databases" {
#   depends_on = [aws_db_instance.postgres]

#   provisioner "local-exec" {
#     command = <<-EOT
#       export PGPASSWORD='${var.db_master_password}'
#       psql -h ${aws_db_instance.postgres.endpoint} \
#            -U ${var.db_master_username} \
#            -d eduhub \
#            -c "CREATE DATABASE auth_db;" \
#            -c "CREATE DATABASE catalog_db;" \
#            -c "CREATE DATABASE assignment_db;" \
#            -c "CREATE DATABASE notifications_db;"
#     EOT

#     environment = {
#       PGHOST = split(":", aws_db_instance.postgres.endpoint)[0]
#     }
#   }
# }

#########################
# 3B – ELASTICACHE REDIS
#########################

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.project_name}-redis-subnet-group"
  subnet_ids = var.storage_subnet_ids
}

resource "aws_security_group" "redis" {
  name        = "${var.project_name}-redis-sg"
  description = "Allow EKS nodes to connect to Redis"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Redis from EKS nodes only"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.eks_node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-redis-sg"
  }
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = replace("${local.safe_name}-redis", "/--+/g", "-")
  engine               = "redis"
  engine_version       = "7.1"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"

  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.redis.id]

  tags = {
    Name = "${var.project_name}-redis"
  }
}

#########################
# 3C – DYNAMODB (Optional but do it – looks pro)
#########################

resource "aws_dynamodb_table" "analytics" {
  name         = "eduhub-analytics"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"
  range_key    = "timestamp"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  tags = {
    Name = "eduhub-analytics"
  }
}