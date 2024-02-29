resource "random_integer" "random_suffix" {
  min = 1000
  max = 9999
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "default" {
  for_each = toset(data.aws_subnets.default.ids)
  id       = each.value
}

output "aws_vpc_id" {
  value = data.aws_vpc.default.id
}

# data "aws_security_groups" "test" {

#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.default.id]
#   }
# }


data "template_file" "user_data" {
  template = file("../scripts/user-data.sh")
}


data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/*20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

variable "branch_name" {
  type    = string
  default = "production"
}

# locals {
#   parsed_security_groups = split(" ", var.vpc_security_group_ids)
# }

resource "aws_security_group" "new_security_group" {
  name        = "new-security-group-${random_integer.random_suffix.result}"
  description = "Security group with rules open for ports 22, 80, 443, and 8080"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "mern-instance" {
  # count         = 1
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"

  subnet_id = [for s in data.aws_subnet.default : s.id][0]
  # vpc_security_group_ids = data.aws_security_groups.test.ids
  vpc_security_group_ids = [aws_security_group.new_security_group.id]


  tags = {
    Name    = "mern-instance-${var.branch_name}"
    Project = "devops"
  }

  user_data = data.template_file.user_data.rendered
  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --region us-east-1 --instance-id ${self.id}"
  }
}

output "public_ip1" {
  value = aws_instance.mern-instance.public_ip
}
# output "public_ip2" {
#   value = aws_instance.mern-instance[1].public_ip
# }

output "private_ip1" {
  value = aws_instance.mern-instance.private_ip
}

# output "private_ip2" {
#   value = aws_instance.mern-instance[1].private_ip
# }


# output "aws_security_group" {
#   value = data.aws_security_groups.test.ids
# }

output "subnet_cidr_blocks" {
  value = [for s in data.aws_subnet.default : s.id]
}
