resource "aws_security_group" "this" {
  name = "novasphere-${var.resource_name}"
  description = coalesce(
    var.security_group_description,
    "Regles du serveur ${var.name}"
  )

  ingress {
    description = var.ssh_description
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  dynamic "ingress" {
    for_each = toset(var.open_ports)

    content {
      description = ingress.value == 80 ? "HTTP public" : "Port public ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.this.id]

  tags = merge(var.tags, {
    Name = "novasphere-${var.resource_name}"
    Role = var.name
  })
}
