resource "aws_security_group" "sg_8080" {
  vpc_id = var.vpc_id

  name        = "terraform-learn-move-sg"
  description = "Security Group managed by Terraform"

  ingress {
    from_port   = "8080"
    to_port     = "8080"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
