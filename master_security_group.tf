resource "aws_security_group" "master-cluster" {
  name        = "eks-master-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-master"
  }
}

resource "aws_security_group_rule" "master-cluster-ingress-workstation-https" {
  cidr_blocks       = var.allow_eks_cidr
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.master-cluster.id
  to_port           = 443
  type              = "ingress"
}
