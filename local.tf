locals {
    # Standard tag components
  # base_name = "${var.bu}-${var.program}-${var.app}-${var.env}"

  common_tags = {
    BusinessUnit = var.bu
    Program      = var.program
    Application  = var.app
    Environment  = var.env
    Team         = var.team
    Region       = var.region
    ManagedBy    = "Terraform"
  }

}


###################### EKS Cluster  ####################

locals {
  eks_name = "${var.bu}-${var.env}-${var.program}-${var.app}-eks-cluster"
}


###################### Node Group  ####################

locals {
  node_group_name = "${var.bu}-${var.env}-${var.program}-${var.app}-eks-node-group"
}


####################### Launch Template  ####################
locals {
  app_lt_name = "${var.bu}-${var.env}-${var.program}-${var.app}-eks-app-lt"
}

locals {
  db_lt_name = "${var.bu}-${var.env}-${var.program}-${var.app}-eks-app-lt"
}


#################### Security Groups ########################

locals {
  security_groups = {
    for i in range(length(var.sg_names)) :
    var.sg_names[i] => "${var.bu}-${var.env}-${var.program}-${var.app}-${var.sg_names[i]}-eks-node-sg"
  }

  security_group_config = {
    for sg_key, sg_value in var.security_groups_rule :
    sg_key => {
      name    = try(local.security_groups[sg_key], null)
      ingress = sg_value.ingress_rules
      egress  = sg_value.egress_rules
    }
  }
}

locals {
  flattened_ingress_rules = flatten([
    for sg_key, sg_value in local.security_group_config : [
      for rule in sg_value.ingress : [
        rule.source_sg_names != null && length(rule.source_sg_names) > 0 ? {
          sg_name   = sg_key
          rule_type = "sg"
          rule      = rule
          } : {
          sg_name   = sg_key
          rule_type = "cidr"
          rule      = rule
        }
      ]
    ]
  ])
}


locals {
  flattened_egress_rules = flatten([
    for sg_key, sg_value in local.security_group_config : [
      for rule in sg_value.egress : [
        length(try(rule.source_sg_names, [])) > 0 ? {
          sg_name   = sg_key
          rule_type = "sg"
          rule      = rule
          } : {
          sg_name   = sg_key
          rule_type = "cidr"
          rule      = rule
        }
      ]
    ]
  ])
}

locals {
  known_source_sgs = {
    eks-cluster = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
  }
}

locals {
  app_lt_sg = [
    aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id,
    aws_security_group.sg[var.sg_names[0]].id
  ]
}
locals {
  db_lt_sg = [
    aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id,
    aws_security_group.sg[var.sg_names[1]].id
  ]
}


locals {
  eks_sg_rules = {
    for name, sg in aws_security_group.sg : name => [
      for rule in var.eks_sg_rule : {
        from_port    = rule.from_port
        to_port      = rule.to_port
        protocol     = rule.protocol
        source_sg_id = sg.id
      }
    ]
  }
}

locals {
  eks_sg_rules_flat = flatten([
    for sg_name, rules in local.eks_sg_rules : [
      for idx, rule in rules : {
        key          = "${sg_name}-${idx}"
        from_port    = rule.from_port
        to_port      = rule.to_port
        protocol     = rule.protocol
        source_sg_id = rule.source_sg_id
      }
    ]
  ])
}

