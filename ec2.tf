# key pair (login)
resource aws_key_pair my_key {
  key_name = "terra-key-ansible"
  public_key = file("terra-key-ansible.pub")
}

# VPC & Security Group
resource aws_default_vpc default {
  
}



resource aws_security_group my_security_group {
    name = "automate-sg"
    description = "this will add a TF generated Security group"
    vpc_id = aws_default_vpc.default.id

    # inbound rules
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "SSH Open"
    } 

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP Open"
    }

    # outbound rules
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "All access open outbound"
    }

    tags = {
      Name = "automate-sg"
    }
   
}

# ec2 instance
resource "aws_instance" "my_instance" {
    for_each = tomap({
      shrikant-micro-Master = "ami-0df368112825f8d8f" # Ubuntu
      shrikant-micro-2 = "ami-0df368112825f8d8f" # Ubuntu
      shrikant-micro-3 = "ami-09de149defa704528" # Redhat
      shrikant-micro-4 = "ami-08f9a9c699d2ab3f9" # amazon
    })

    depends_on = [ aws_security_group.my_security_group, aws_key_pair.my_key ]

    key_name = aws_key_pair.my_key.key_name
    security_groups = [aws_security_group.my_security_group.name]
    instance_type = "t2.micro"
    ami = each.value # ubuntu

    root_block_device {
      volume_size = 10
      volume_type = "gp3"
    }

    tags = {
      Name = each.key
    }


}

