provider "aws"{
    region = "ap-south-1"

}


# Key Pair
resource "aws_key_pair" "my_key" {
  key_name   = "terra-key-ec2"
  public_key = file("terra-key-ec2.pub")
}

# Default VPC
resource "aws_default_vpc" "my_vpc" {}

# Security Group
resource "aws_security_group" "my_sg" {
  name        = "terraform-sg"
  description = "Terraform generated Security Group"
  vpc_id      = aws_default_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"   #this proctol will allow all type of traffic
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

# EC2 Instance
resource "aws_instance" "webserver" {
  ami                        =  var.ec2_ami_id
  instance_type               = var.ec2_instance_type
  key_name                    = aws_key_pair.my_key.key_name #this method is string interpolation means dynamically assigning inserting variable
  vpc_security_group_ids      = [aws_security_group.my_sg.id]  #the group ids wil be in list structure

  root_block_device {
    volume_size = var.ec2_root_storage_size
    volume_type = "gp3"
  }

  tags = {
    Name = "Terraform server"  #we have assigned a name to the instance
  }
}
