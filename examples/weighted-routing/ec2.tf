############################################
# Jumphosts
############################################

module "ec2_client" {
  source = "tfstack/jumphost/aws"

  name      = "${local.base_name_1}-ec2-client"
  subnet_id = module.vpc_1.private_subnet_ids[0]
  vpc_id    = module.vpc_1.vpc_id

  create_security_group  = false
  vpc_security_group_ids = [aws_security_group.ec2_client_sg.id]
  allowed_cidr_blocks    = ["${trimspace(data.http.my_public_ip.response_body)}/32"]
  assign_eip             = false

  user_data_extra = <<-EOT
    hostname ${local.base_name_1}-ec2-client
    yum install -y mtr nc
  EOT

  tags = local.tags_1
}

module "ec2_web_server_1" {
  source = "tfstack/ec2-server/aws"

  name      = "${local.base_name_2}-ec2-web-server-1"
  subnet_id = module.vpc_2.private_subnet_ids[0]
  vpc_id    = module.vpc_2.vpc_id

  create_security_group  = false
  vpc_security_group_ids = [aws_security_group.ec2_web_server_1_sg.id]

  instance_type    = "t3.micro"
  assign_public_ip = false
  enable_ssm       = true

  user_data = <<-EOT
#!/bin/bash
set -e
    hostname ${local.base_name_2}-ec2-web-server-1
    yum install -y mtr nc httpd
    echo "Hello from ${local.base_name_2}-ec2-web-server-1 in VPC2!" > /var/www/html/index.html
    systemctl enable httpd
    systemctl start httpd
EOT

  instance_tags = merge(local.tags_2, {
    Name = "${local.base_name_2}-ec2-web-server-1-sg"
  })
}

module "ec2_web_server_2" {
  source = "tfstack/ec2-server/aws"

  name      = "${local.base_name_2}-ec2-web-server-2"
  subnet_id = module.vpc_2.private_subnet_ids[1]
  vpc_id    = module.vpc_2.vpc_id

  create_security_group  = false
  vpc_security_group_ids = [aws_security_group.ec2_web_server_2_sg.id]

  instance_type    = "t3.micro"
  assign_public_ip = false
  enable_ssm       = true

  user_data = <<-EOT
#!/bin/bash
set -e
    hostname ${local.base_name_2}-ec2-web-server-2
    yum install -y mtr nc httpd
    echo "Hello from ${local.base_name_2}-ec2-web-server-2 in VPC2!" > /var/www/html/index.html
    systemctl enable httpd
    systemctl start httpd
EOT

  instance_tags = merge(local.tags_2, {
    Name = "${local.base_name_2}-ec2-web-server-2-sg"
  })
}

module "ec2_web_server_3" {
  source = "tfstack/ec2-server/aws"

  name      = "${local.base_name_2}-ec2-web-server-3"
  subnet_id = module.vpc_2.private_subnet_ids[1]
  vpc_id    = module.vpc_2.vpc_id

  create_security_group  = false
  vpc_security_group_ids = [aws_security_group.ec2_web_server_3_sg.id]

  instance_type    = "t3.micro"
  assign_public_ip = false
  enable_ssm       = true

  user_data = <<-EOT
#!/bin/bash
set -e
    hostname ${local.base_name_2}-ec2-web-server-3
    yum install -y mtr nc httpd
    echo "Hello from ${local.base_name_2}-ec2-web-server-3 in VPC2!" > /var/www/html/index.html
    # Configure Apache to run on port 8080
    sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf
    sed -i 's/:80/:8080/g' /etc/httpd/conf/httpd.conf
    systemctl enable httpd
    systemctl start httpd
EOT

  instance_tags = merge(local.tags_2, {
    Name = "${local.base_name_2}-ec2-web-server-3-sg"
  })
}

module "ec2_web_server_4" {
  source = "tfstack/ec2-server/aws"

  name      = "${local.base_name_2}-ec2-web-server-4"
  subnet_id = module.vpc_2.private_subnet_ids[2]
  vpc_id    = module.vpc_2.vpc_id

  create_security_group  = false
  vpc_security_group_ids = [aws_security_group.ec2_web_server_4_sg.id]

  instance_type    = "t3.micro"
  assign_public_ip = false
  enable_ssm       = true

  user_data = <<-EOT
#!/bin/bash
set -e
    hostname ${local.base_name_2}-ec2-web-server-4
    yum install -y mtr nc httpd
    echo "Hello from ${local.base_name_2}-ec2-web-server-4 in VPC2!" > /var/www/html/index.html
    # Configure Apache to run on port 8080
    sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf
    sed -i 's/:80/:8080/g' /etc/httpd/conf/httpd.conf
    systemctl enable httpd
    systemctl start httpd
EOT

  instance_tags = merge(local.tags_2, {
    Name = "${local.base_name_2}-ec2-web-server-4-sg"
  })
}

data "aws_ami" "amzn2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

resource "aws_instance" "ec2_web_server_5" {
  count = length(module.vpc_3.private_subnet_ids)

  ami           = data.aws_ami.amzn2023.id
  instance_type = "t3.micro"
  subnet_id     = module.vpc_3.private_subnet_ids[count.index]

  vpc_security_group_ids = [
    aws_security_group.ec2_web_server_5_sg.id
  ]

  user_data_base64 = base64encode(file("${path.module}/external/cloud-init.yaml"))

  tags = merge(local.tags_3, { Name = "${local.base_name_3}-web-${count.index}" })
}
