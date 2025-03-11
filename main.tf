resource "aws_vpc" "tt_vpc" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }

}

resource "aws_subnet" "tt_vpc_public_subnet" {
  vpc_id                  = aws_vpc.tt_vpc.id
  cidr_block              = "10.20.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "dev-public"
  }
}

resource "aws_internet_gateway" "tt_vpc_IGW" {
  vpc_id = aws_vpc.tt_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "tt_public_route" {
  vpc_id = aws_vpc.tt_vpc.id

  tags = {
    Name = "dev_public_rt"
  }

}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.tt_public_route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.tt_vpc_IGW.id

}

resource "aws_route_table_association" "tt_public_associate" {
  subnet_id      = aws_subnet.tt_vpc_public_subnet.id
  route_table_id = aws_route_table.tt_public_route.id
}

resource "aws_security_group" "tt_SG" {
  name        = "dev_sg"
  description = "dev security SG"
  vpc_id      = aws_vpc.tt_vpc.id

}
resource "aws_vpc_security_group_ingress_rule" "tt_SG_ingress" {
  security_group_id = aws_security_group.tt_SG.id

  cidr_ipv4 = "68.194.79.238/32"
  # from_port   = 0
  ip_protocol = "-1"
  # to_port     = 0
}

resource "aws_vpc_security_group_egress_rule" "tt_SG_egress" {
  security_group_id = aws_security_group.tt_SG.id

  cidr_ipv4 = "0.0.0.0/0"
  # from_port   = 0
  ip_protocol = "-1"
  # to_port     = 0
}

resource "aws_key_pair" "tt_key" {
  key_name   = "tt_key"
  public_key = file("E:/Terraform/.ssh/ttkey.pub")

}

resource "aws_instance" "dev_node" {
  instance_type = "t2.micro"
  ami = data.aws_ami.server_ami.id
  key_name = aws_key_pair.tt_key.id
  vpc_security_group_ids = [aws_security_group.tt_SG.id]
  subnet_id = aws_subnet.tt_vpc_public_subnet.id
  user_data = file("userdata.tpl")

    root_block_device {
     volume_size = 10
    }
    
    tags = {
    Name = "dev_node"
      }

   

  }

