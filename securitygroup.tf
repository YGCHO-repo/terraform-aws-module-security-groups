resource "null_resource" "validate_account" {
  count = var.current_id == var.account_id ? 0 : "Please check that you are using the AWS account - module_v2"
}

#220628 - region에 대한 비교 구문 추가
#변상기M 모듈과 달리 versioning 및 module_name에는 무관하므로 해당 부분에 대한 것을 삭제
#대신해서 current_region 및 사용 region에 대한 부분을 새롭게 추가
resource "null_resource" "validate_region" {
  count = var.current_region == var.region ? 0 : "Please check that you are setting the region - module_v2"
}

#220628 - SG 작성 코드 추가
#의존성 체크에 validate_account 외 신규 생성한 validate_region 추가
resource "aws_security_group" "this" {
  name   = format("%s-%s-security-groups", var.prefix, var.name)
  vpc_id = var.vpc_id

  depends_on = [
    null_resource.validate_account,
    null_resource.validate_region
  ]

  tags = merge(var.tags, tomap({ Name = format("%s-%s-security-group", var.prefix, var.name) }))
}

###########################################################################################
# 220628 - 신규 구축 : ingress/egress traffic을 따로 작성
# 기존 source 유형(IPv4/self/SG)으로 나뉘던 것에서 ingress/egress로 추가로 배리에이션을 나눈다
#
# 1-1. source - cidr / ingress
# 1-2. source - cidr / egress
#
# 2-1. source - self / ingress
# 2-2. source - self / egress 
# 
# 3-1. source - SG   / ingress
# 3-2. source - SG   / egress
###########################################################################################

###########################################################################################
# 1-1. source - cidr / ingress
###########################################################################################
resource "aws_security_group_rule" "cidr_ingress" {
  security_group_id = aws_security_group.this.id
  for_each          = { for i in local.cidr_2_rules_ingress : i.name => i }
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  cidr_blocks       = each.value.cidr_blocks
  ipv6_cidr_blocks  = each.value.ipv6_cidr_blocks
  protocol          = each.value.protocol
  prefix_list_ids   = each.value.prefix_list_ids
  description       = each.value.description


  depends_on = [
    aws_security_group.this
  ]

  lifecycle {
    create_before_destroy = true
  }
}

###########################################################################################
# 1-2. source - cidr / egress
###########################################################################################
resource "aws_security_group_rule" "cidr_egress" {
  security_group_id = aws_security_group.this.id
  for_each          = { for i in local.cidr_2_rules_egress : i.name => i }
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  ipv6_cidr_blocks  = each.value.ipv6_cidr_blocks
  prefix_list_ids   = each.value.prefix_list_ids
  description       = each.value.description

  depends_on = [
    aws_security_group.this
  ]

  lifecycle {
    create_before_destroy = true
  }
}

###########################################################################################
# 2-1. source - self / ingress
###########################################################################################

resource "aws_security_group_rule" "self_ingress" {
  security_group_id = aws_security_group.this.id
  for_each          = { for i in local.self_2_rules_ingress : i.name => i }
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  prefix_list_ids   = each.value.prefix_list_ids
  description       = each.value.description
  self              = each.value.self

  depends_on = [
    aws_security_group.this
  ]

  lifecycle {
    create_before_destroy = true
  }
}

###########################################################################################
# 2-2. source - self / egress
###########################################################################################

resource "aws_security_group_rule" "self_egress" {
  security_group_id = aws_security_group.this.id
  for_each          = { for i in local.self_2_rules_egress : i.name => i }
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  prefix_list_ids   = each.value.prefix_list_ids
  description       = each.value.description
  self              = each.value.self

  depends_on = [
    aws_security_group.this
  ]

  lifecycle {
    create_before_destroy = true
  }
}

###########################################################################################
# 3-1. source - SG   / ingress
###########################################################################################
resource "aws_security_group_rule" "security_group_id_ingress" {
  security_group_id        = aws_security_group.this.id
  for_each                 = { for i in local.sg_2_rules_ingress : i.name => i }
  type                     = each.value.type
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  source_security_group_id = each.value.source_security_group_id
  prefix_list_ids          = each.value.prefix_list_ids
  description              = each.value.description

  depends_on = [
    aws_security_group.this
  ]

  lifecycle {
    create_before_destroy = true
  }
}

###########################################################################################
# 3-2. source - SG   / egress
###########################################################################################
resource "aws_security_group_rule" "security_group_id_egress" {
  security_group_id        = aws_security_group.this.id
  for_each                 = { for i in local.sg_2_rules_egress : i.name => i }
  type                     = each.value.type
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  source_security_group_id = each.value.source_security_group_id
  prefix_list_ids          = each.value.prefix_list_ids
  description              = each.value.description

  depends_on = [
    aws_security_group.this
  ]

  lifecycle {
    create_before_destroy = true
  }
}