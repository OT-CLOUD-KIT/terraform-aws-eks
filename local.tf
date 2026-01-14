locals {
  common_tags = {
    BusinessUnit = var.bu
    Program      = var.program
    Application  = var.app
    Environment  = var.env
    Team         = var.team
    Region       = var.region
    ManagedBy    = "Terraform"
  }

  eks_name        = "${var.bu}-${var.env}-${var.program}-${var.app}-eks-cluster"
  node_group_name = "${var.bu}-${var.env}-${var.program}-${var.app}-eks-node-group"

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
