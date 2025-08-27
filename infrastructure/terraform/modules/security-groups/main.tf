# Security Groups Module
resource "aws_security_group" "eks_cluster" {
  name_prefix = "${var.name_prefix}-eks-cluster"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-eks-cluster-sg"
  })
}

resource "aws_security_group" "eks_nodes" {
  name_prefix = "${var.name_prefix}-eks-nodes"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-eks-nodes-sg"
  })
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.name_prefix}-rds"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-rds-sg"
  })
}