provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.authentication.token
    load_config_file       =  false
    # config_path            = var.kubeconfig_name
  }
}

data "aws_eks_cluster_auth" "authentication" {
  name = var.cluster_name
}

  resource "helm_release" "cluster_autoscaler" {
  name  = "clusterautoscaler"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  depends_on = [aws_eks_cluster.eks_cluster]
 
  set {
    name  = "awsRegion"
    value = var.region
  }
  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }
}

  resource "helm_release" "metrics_server" {
  name       = "metricsserver"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "metrics-server"
  namespace  = "kube-system"
  depends_on = [aws_eks_cluster.eks_cluster]
}

  resource "helm_release" "k8s-spot-termination-handler" {
  name       = "verticalautoscaling"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "k8s-spot-termination-handler"
  namespace  = "kube-system"
  depends_on = [aws_eks_cluster.eks_cluster]

  set {
      name = "slackUrl"
      value = var.slackUrl
  }
  set {
      name = "clusterName"
      value = var.cluster_name
  }
}
