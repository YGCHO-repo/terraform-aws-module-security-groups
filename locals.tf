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
#
# designate에서 받아온 값을 기반으로 local에서 위의 기준에 따라 처리
# 기존 대비 총 6개의 리소스 가공이 이루어짐
###########################################################################################

###########################################################################################
# 1-1. source - cidr / ingress
###########################################################################################
locals {
  cidr_2_rules_ingress = flatten([
    for key, value in var.rules : {
      name             = key
      type             = value.type
      from_port        = value.from_port
      to_port          = value.to_port
      protocol         = value.protocol
      cidr_blocks      = value.cidr_blocks
      ipv6_cidr_blocks = value.ipv6_cidr_blocks
      prefix_list_ids  = value.prefix_list_ids
      description      = value.description  
    }
    if (( 0 < length(value.cidr_blocks)  || 0 < length(value.ipv6_cidr_blocks) || 0 < length(value.prefix_list_ids)) && false == value.self && "ingress" == value.type )
  ])
}

###########################################################################################
# 1-2. source - cidr / egress
###########################################################################################
locals {
  cidr_2_rules_egress = flatten([
    for key, value in var.rules : {
      name             = key
      type             = value.type
      from_port        = value.from_port
      to_port          = value.to_port
      protocol         = value.protocol
      cidr_blocks      = value.cidr_blocks
      ipv6_cidr_blocks = value.ipv6_cidr_blocks
      prefix_list_ids  = value.prefix_list_ids
      description      = value.description  
    }
    if (( 0 < length(value.cidr_blocks)  || 0 < length(value.ipv6_cidr_blocks) || 0 < length(value.prefix_list_ids)) && false == value.self && "egress" == value.type )
  ])
}

###########################################################################################
# 2-1. source - self / ingress
###########################################################################################
locals {
   self_2_rules_ingress = flatten([
    for key, value in var.rules : {
      name             = key
      type             = value.type
      from_port        = value.from_port
      to_port          = value.to_port
      protocol         = value.protocol
      prefix_list_ids  = value.prefix_list_ids
      description      = value.description
      self             = value.self  
    } 
    if ( true == value.self && "ingress" == value.type )
   ])
}

###########################################################################################
# 2-2. source - self / egress
###########################################################################################
locals {
   self_2_rules_egress = flatten([
    for key, value in var.rules : {
      name             = key
      type             = value.type
      from_port        = value.from_port
      to_port          = value.to_port
      protocol         = value.protocol
      prefix_list_ids  = value.prefix_list_ids
      description      = value.description  
      self             = value.self 
    } 
    if ( true == value.self && "egress" == value.type )
   ])
}

###########################################################################################
# 3-1. source - SG   / ingress
###########################################################################################
locals {
    sg_2_rules_ingress = flatten([
    for key, value in var.rules : {
        name                     = key
        type                     = value.type
        from_port                = value.from_port
        to_port                  = value.to_port
        protocol                 = value.protocol
        source_security_group_id = value.source_security_group_id
        prefix_list_ids          = value.prefix_list_ids
        description              = value.description
    }
    if ( "" != value.source_security_group_id  && false == value.self && "ingress" == value.type )
    ]) 
}

###########################################################################################
# 3-2. source - SG   / egress
###########################################################################################
locals {
    sg_2_rules_egress = flatten([
    for key, value in var.rules : {
        name                     = key
        type                     = value.type
        from_port                = value.from_port
        to_port                  = value.to_port
        protocol                 = value.protocol
        source_security_group_id = value.source_security_group_id
        prefix_list_ids          = value.prefix_list_ids
        description              = value.description
    }
    if ( "" != value.source_security_group_id  && false == value.self && "egress" == value.type )
    ]) 
}