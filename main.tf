terraform {
  backend "s3" {
    bucket = "065148798076-cicd-bucket"
    key = "env/dev/terraform.tfstate"
    region = "ap-south-1"
    use_lockfile = true
    encrypt = true  
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "my_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = "linux_sever_16jul"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data              = file("nginx.sh")
  metadata_options {
    http_tokens = "required"
  }
  root_block_device {
    encrypted = true
  }
  tags = {
    Name : "web-Server"
  }
}

resource "aws_security_group" "web_sg" {
  name        = "nginx-sg"
  description = "Allow HTTP and restricted SSH"

  # 🌐 HTTP (public website ke liye open)
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-ec2-no-public-ingress-sgr
  }

  # 🔐 SSH (sirf tumhare IP se)
  ingress {
    description = "Allow SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = ["192.168.31.163/32"]
  }

  # 📤 Outbound (generally open rehta hai)
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-ec2-no-public-egress-sgr
  }
}
