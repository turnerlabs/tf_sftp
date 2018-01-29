# this section stores the terraform state for the s3 bucket in the terraform state bucket we created in step 1.
terraform {
  backend "s3" {
    bucket = "" # the terraform state bucket has to be hand entered unfortunately
    key    = "ec2/sftp_server/terraform.tfstate"
    region = "us-east-1"
    encrypt = "true"
  }
}

# this is for an aws specific provider(not gcp or azure)
provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

# VPC for sftpserver
resource "aws_vpc" "vpc_sftpserver" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags {
    Name            = "vpc_sftpserver"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# Internet gateway for VPC
resource "aws_internet_gateway" "igw_sftpserver" {
  depends_on = ["aws_vpc.vpc_sftpserver"]
  
  vpc_id     = "${aws_vpc.vpc_sftpserver.id}"

  tags {
    Name            = "igw_sftpserver"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# VPC Subnet for us east1 a
resource "aws_subnet" "sn_sftpserver_useast1a" {
  depends_on        = ["aws_vpc.vpc_sftpserver"]
  
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  vpc_id            = "${aws_vpc.vpc_sftpserver.id}"

  tags {
    Name            = "sn_sftpserver_useast1a"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# VPC Subnet for us east1 b
resource "aws_subnet" "sn_sftpserver_useast1b" {
  depends_on        = ["aws_vpc.vpc_sftpserver"]
  
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  vpc_id            = "${aws_vpc.vpc_sftpserver.id}"

  tags {
    Name            = "sn_sftpserver_useast1b"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# VPC Subnet for us east1 c
resource "aws_subnet" "sn_sftpserver_useast1c" {
  depends_on        = ["aws_vpc.vpc_sftpserver"]
  
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1c"
  vpc_id            = "${aws_vpc.vpc_sftpserver.id}"

  tags {
    Name            = "sn_sftpserver_useast1c"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# Route to provide internet access
resource "aws_route" "rt_sftpserver" {
  depends_on              = ["aws_vpc.vpc_sftpserver", "aws_internet_gateway.igw_sftpserver"]
  
  route_table_id          = "${aws_vpc.vpc_sftpserver.main_route_table_id}"
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = "${aws_internet_gateway.igw_sftpserver.id}"
}

# Associate us-east-1a to the route table.  May need to add others as well
resource "aws_route_table_association" "rta_sftpserver" {
  depends_on      = ["aws_vpc.vpc_sftpserver", "aws_subnet.sn_sftpserver_useast1a"]
  
  subnet_id       = "${aws_subnet.sn_sftpserver_useast1a.id}"
  route_table_id  = "${aws_vpc.vpc_sftpserver.main_route_table_id}"
}

# Security group to allow access to ELB
resource "aws_security_group" "sg_elb_sftpserver" {
  depends_on  = ["aws_vpc.vpc_sftpserver"]

  name        = "sg_elb_sftpserver"
  description = "Security group for sftpserver elb access"
  vpc_id      = "${aws_vpc.vpc_sftpserver.id}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["157.166.0.0/16"]
    description     = "Turner"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name            = "sg_elb_sftpserver"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# Security group to allow access to Instance
resource "aws_security_group" "sg_instance_sftpserver" {
  depends_on  = ["aws_security_group.sg_elb_sftpserver", "aws_vpc.vpc_sftpserver"]

  name        = "sg_instance_sftpserver"
  description = "Security group for sftpserver instance access"
  vpc_id      = "${aws_vpc.vpc_sftpserver.id}"

  # SSH access from Turner
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["157.166.0.0/16"]
    description     = "Turner"
  }

  # Access from ELB
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.sg_elb_sftpserver.id}"]
    description     = "Turner"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
 
  tags {
    Name            = "sg_instance_sftpserver"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# ELB sitting in front of sftp instance(s)
resource "aws_elb" "elb_sftpserver" {
  depends_on          = ["aws_security_group.sg_elb_sftpserver"]

  name                = "elb-sftpserver"
  subnets             = ["${aws_subnet.sn_sftpserver_useast1a.id}", "${aws_subnet.sn_sftpserver_useast1b.id}", "${aws_subnet.sn_sftpserver_useast1c.id}"]
  security_groups     = ["${aws_security_group.sg_elb_sftpserver.id}"]

  listener {
    instance_port       = "22"
    instance_protocol   = "tcp"
    lb_port             = "22"
    lb_protocol         = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:22"
    interval            = 30
  }

  tags {
    Name                = "elb_sftpserver"
    application         = "${var.tag_application}"
    contact-email       = "${var.tag_contact_email}"
    customer            = "${var.tag_customer}"
    team                = "${var.tag_team}"
    environment         = "${var.tag_environment}"
  }
}

resource "aws_launch_configuration" "lc_sftpserver" {
  depends_on            = ["aws_security_group.sg_instance_sftpserver"]

  name                  = "lc_sftpserver"
  image_id              = "${var.image_id}"
  instance_type         = "${var.instance_type}"
  key_name              = "${var.key_name}"
  iam_instance_profile  = "${var.iam_instance_profile}"

  security_groups       = ["${aws_security_group.sg_instance_sftpserver.id}"]
}

resource "aws_autoscaling_group" "asg_sftpserver" {
  depends_on                = ["aws_launch_configuration.lc_sftpserver", "aws_elb.elb_sftpserver"]

  name                      = "asg_sftpserver"
  vpc_zone_identifier       = ["${aws_subnet.sn_sftpserver_useast1a.id}", "${aws_subnet.sn_sftpserver_useast1b.id}", "${aws_subnet.sn_sftpserver_useast1c.id}"]
  launch_configuration      = "${aws_launch_configuration.lc_sftpserver.id}"
  max_size                  = "2"
  min_size                  = "1"
  desired_capacity          = "1"
  health_check_grace_period = 300
  health_check_type         = "ELB"
  load_balancers            = ["${aws_elb.elb_sftpserver.id}"]
  termination_policies      = ["OldestInstance", "OldestLaunchConfiguration"]


  tag {
    key                 = "Name"
    value               = "sftpserver"
    propagate_at_launch = true
  }

  tag {
    key                 = "application"
    value               = "${var.tag_application}"
    propagate_at_launch = true
  }

  tag {
    key                 = "contact-email"
    value               = "${var.tag_contact_email}"
    propagate_at_launch = true
  }

  tag {
    key                 = "customer"
    value               = "${var.tag_customer}"
    propagate_at_launch = true
  }

  tag {
    key                 = "team"
    value               = "${var.tag_team}"
    propagate_at_launch = true
  }

  tag {
    key                 = "environment"
    value               = "${var.tag_environment}"
    propagate_at_launch = true
  }
}