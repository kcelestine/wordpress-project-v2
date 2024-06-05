resource "aws_vpc" "wp_vpc" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "wp_vpc"
  }
}

resource "aws_subnet" "wp_public" {
 vpc_id = "${aws_vpc.wp_vpc.id}"
 cidr_block = "192.168.0.0/24"
 availability_zone = "us-east-1a"
 map_public_ip_on_launch = "true"
 
 tags = {
  Name = "wp_public_subnet"
 } 
}
resource "aws_subnet" "wp_private" {
 vpc_id = "${aws_vpc.wp_vpc.id}"
 cidr_block = "192.168.1.0/24"
 availability_zone = "us-east-1b"
 
 tags = {
  Name = "wp_private_subnet"
 }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.wp_vpc.id

  tags = {
    Name = "gw"
  }
}

resource "aws_route_table" "wp_rt" {
 vpc_id = "${aws_vpc.wp_vpc.id}"
 
 route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
 }
 
 tags = {
  Name = "wp rt"
 }
}

resource "aws_route_table_association" "a" {
 subnet_id = "${aws_subnet.wp_public.id}"
 route_table_id = "${aws_route_table.wp_rt.id}"
}


resource "aws_security_group" "wp_sg" {
  name = "WP SG"
  vpc_id = aws_vpc.wp_vpc.id

  ingress {
  description = "SSH"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 }
 
 ingress { 
  description = "HTTP"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 }
 
 ingress {
  description = "TCP"
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 }
 
 egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
 }
 
 tags = {
  Name = "wordpress"
 }
}


resource "aws_instance" "wordpress" {
 ami = "ami-00beae93a2d981137"
 instance_type = "t2.micro"
 key_name = "wp"
 vpc_security_group_ids = [ "${aws_security_group.wp_sg.id}" ]
 subnet_id = "${aws_subnet.wp_public.id}"
 user_data = "bootstrap.sh"
 tags = {
  Name = "wordpress"
 }
}


resource "aws_instance" "mysql" {
 ami = "ami-00beae93a2d981137"
 instance_type = "t2.micro"
 key_name = "wp"
 vpc_security_group_ids = [ "${aws_security_group.wp_sg.id}" ]
 subnet_id = "${aws_subnet.wp_public.id}"
  
 tags = {
  Name = "MySQL"
 }
}



/*
 Create VPC: vpc-0969e05515190e0d2 
 Enable DNS hostnames
 Enable DNS resolution
 Verifying VPC creation: vpc-0969e05515190e0d2 
 Create subnet: subnet-02064d4c27d225418 
 Create internet gateway: igw-025a5ad3f892cff18 
 Attach internet gateway to the VPC
 Create route table: rtb-003476855b78dd663 
 Create route
 Associate route table
 Verifying route table creation
*/