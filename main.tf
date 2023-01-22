terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIA264EKVB4RHBA32HD"
  secret_key = "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"
}

resource "aws_instance" "jenkins" {
  ami           = "ami-0cca134ec43cf708f"
  instance_type = "t2.micro"
  key_name = "jenkins"
  vpc_security_group_ids = [aws_security_group.sg_grp.id]

provisioner "remote-exec" {
  inline = [
    "sudo yum update -y",
    "sudo amazon-linux-extras install java-openjdk11 -y",
    " sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
    "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key",
    "sudo yum install jenkins -y",
    "sudo systemctl start jenkins",
  ]
}

connection {
  type        = "ssh"
  host        = self.public_ip
  user        = "ec2-user"
  private_key = file("./jenkins.pem")
}
  tags = {
    Name = "Jenkins-Server"
  }
}

resource "aws_instance" "ansible" {
  ami           = "ami-0cca134ec43cf708f"
  instance_type = "t2.micro"
  key_name = "jenkins"
  vpc_security_group_ids = [aws_security_group.sg_grp.id]

provisioner "remote-exec" {
  inline = [
    "sudo yum update -y",
    "sudo amazon-linux-extras install ansible2 -y",
  ]
}

connection {
  type        = "ssh"
  host        = self.public_ip
  user        = "ec2-user"
  private_key = file("./jenkins.pem")
}
  tags = {
    Name  = "Ansible-Server"
  }

}

resource "aws_security_group" "sg_grp" {
    name        = "sg_grp"
    description = "Allow inbound traffic"

    ingress {
        from_port     = 22
        to_port       = 22
        protocol      = "tcp"
        cidr_blocks   =["0.0.0.0/0"]
    }

    ingress {
        from_port     = 0
        to_port       = 0
        protocol      = "-1"
        cidr_blocks   =["0.0.0.0/0"]
    }

    egress {
        from_port     = 0
        to_port       = 0
        protocol      = "-1"
        cidr_blocks   =["0.0.0.0/0"]
    }

tags = {
  name = "sg_grp"
}
  
}