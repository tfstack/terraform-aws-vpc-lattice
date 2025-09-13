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
    yum install -y mtr nc jq
  EOT

  tags = local.tags_1
}
