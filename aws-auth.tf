resource "kubernetes_config_map" "aws_auth" {
  count = var.add_additional_iam_roles == true ? 1 : 0
  depends_on = [null_resource.wait_for_cluster]

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles    = yamlencode(distinct(concat(var.map_additional_iam_roles)))
  }
}
