/// EKS IAM Role for Cluster
resource "aws_iam_role" "eks" {
  name               = "${var.project_name}-eks-cluster"
  assume_role_policy = file("${path.module}/policies/eks-policy.json")
}

resource "aws_iam_role_policy_attachment" "eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}

/// EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = var.eks_name
  role_arn = aws_iam_role.eks.arn
  version  = var.eks_version

  vpc_config {
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    subnet_ids              = var.private_subnets
  }

  access_config {
    authentication_mode                          = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks]
}

/// Worker IAM Role
resource "aws_iam_role" "worker" {
  name               = "${var.project_name}-eks-worker"
  assume_role_policy = file("${path.module}/policies/ec2-policy.json")
}

/// Autoscaler IAM Policy
resource "aws_iam_policy" "autoscaler" {
  name   = "${var.project_name}-autoscaler-policy"
  policy = file("${path.module}/policies/autoscaler-policy.json")
}

/// Attach Policies to Worker Role
resource "aws_iam_role_policy_attachment" "autoscaler" {
  policy_arn = aws_iam_policy.autoscaler.arn
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker.name
}

/// EKS Node Group
resource "aws_eks_node_group" "general" {
  cluster_name    = aws_eks_cluster.eks.name
  version         = var.eks_version
  node_group_name = "${var.eks_name}-general"

  subnet_ids      = var.public_subnets
  capacity_type   = "ON_DEMAND"
  instance_types  = var.instance_types

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "${var.eks_name}-general"
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  node_role_arn = aws_iam_role.worker.arn
}

/// EKS Add-On for Pod Identity Agent
resource "aws_eks_addon" "pod-addon" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = "v1.3.4-eksbuild.1"
}

////////////////////////////////////////////////////////////////////////////////

# Fetch the EKS cluster details
data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.eks.name
}

# Fetch the authentication token for the EKS cluster
data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks.name
}

# Configure the Helm provider to interact with the EKS cluster
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}


////////////////////

resource "helm_release" "metrics_server" {

name = "metrics-server"

repository = "https://kubernetes-sigs.github.io/metrics-server/"

chart = "metrics-server"

namespace = "kube-system"

version = "3.12.1"

values = [file("${path.module}/values/metrics-server.yaml")]

depends_on = [aws_eks_node_group.general]

}

/////////////////////

resource "aws_iam_role" "cluster_autoscaler" {
    name = "${aws_eks_cluster.eks.name}-autoscaler"

    //assume_role_policy = file("./policies/podrole-autoscaler.json")
    assume_role_policy = file("${path.module}/policies/podrole-autoscaler.json")

  
}




resource "aws_iam_policy" "cluster_autoscaler" {
  name = "${aws_eks_cluster.eks.name}-cluster-autoscaler"

 // policy = file("./policies/policy-autoscaler.json")
  policy = file("${path.module}/policies/policy-autoscaler.json")

}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
  role       = aws_iam_role.cluster_autoscaler.name
}

resource "aws_eks_pod_identity_association" "cluster_autoscaler" {
  cluster_name    = aws_eks_cluster.eks.name
  namespace       = "kube-system"
  service_account = "cluster-autoscaler"
  role_arn        = aws_iam_role.cluster_autoscaler.arn
}

resource "helm_release" "cluster_autoscaler" {
  name = "autoscaler"

  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.37.0"

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = aws_eks_cluster.eks.name
  }


  set {
    name  = "awsRegion"
    value = var.region   # MUST be updated to match your region 
  }

  depends_on = [helm_release.metrics_server]
}


///////////////////////////////////////

resource "aws_iam_role" "aws_lbc" {
    name = "${aws_eks_cluster.eks.name}-alb"
    assume_role_policy = file("${path.module}/policies/podrole-autoscaler.json")
  
}

resource "aws_iam_policy" "aws_lbc" {
  policy = file("${path.module}/policies/alb-policy.json")
  name   = "AWSLoadBalancerController"
}

resource "aws_iam_role_policy_attachment" "aws_lbc" {
  policy_arn = aws_iam_policy.aws_lbc.arn
  role       = aws_iam_role.aws_lbc.name
}

resource "aws_eks_pod_identity_association" "aws_lbc" {
  cluster_name    = aws_eks_cluster.eks.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.aws_lbc.arn
}


resource "helm_release" "aws_lbc" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.7.2"

    # Add timeout
  timeout = 300 # 5 minutes

  set {
    name  = "clusterName"
    value = aws_eks_cluster.eks.name
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }


  set {
    name  = "awsRegion"
    value = var.region   # MUST be updated to match your region 
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

    depends_on = [
    helm_release.cluster_autoscaler,
    aws_eks_pod_identity_association.aws_lbc,
    aws_eks_cluster.eks
  ]
}


/////////////////////////////////////

provider "time" {
  
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}



data "aws_eks_node_group" "general" {
    cluster_name = aws_eks_cluster.eks.name
    node_group_name = aws_eks_node_group.general.node_group_name
}

resource "time_sleep" "wait_for_kubernetes" {

    depends_on = [
        data.aws_eks_cluster.eks
    ]

    create_duration = "20s"
}

resource "kubernetes_namespace" "kube-namespace" {
  depends_on = [data.aws_eks_node_group.general, time_sleep.wait_for_kubernetes]
  metadata {
    
    name = "prometheus"
  }
}


resource "helm_release" "prometheus" {
  depends_on = [kubernetes_namespace.kube-namespace, time_sleep.wait_for_kubernetes]
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.kube-namespace.id
  create_namespace = true
  version    = "45.7.1"
  values = [
    file("${path.module}/values/promethousvalues.yaml")

  ]
  timeout = 2000
  

set {
    name  = "podSecurityPolicy.enabled"
    value = true
  }

  set {
    name  = "server.persistentVolume.enabled"
    value = false
  }

  set {
    name = "server\\.resources"
    value = yamlencode({
      limits = {
        cpu    = "200m"
        memory = "50Mi"
      }
      requests = {
        cpu    = "100m"
        memory = "30Mi"
      }
    })
  }
   /* set {
    name  = "grafana.service.type"
    value = "LoadBalancer"
  }*/
}

resource "helm_release" "argocd" {
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "5.46.0"
  create_namespace = true

  values = [
    file("${path.module}/values/argo3.yaml")
  ]
}




# Deploy Argo Rollouts Controller with Prometheus Scraping Enabled
resource "helm_release" "argocd_rollouts" {
  namespace        = "argo-rollouts"           # Namespace for Argo Rollouts
  create_namespace = true                      # Ensure namespace is created
  name             = "argo-rollouts"           # Helm release name
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-rollouts"           # Helm chart for Argo Rollouts
  version          = "2.22.0"                  # Chart version

  values = [
    <<EOF
controller:
  replicaCount: 1
  metrics:
    enabled: true
    service:
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8090"

dashboard:
  enabled: true
  service:
    type: LoadBalancer
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing

serviceAccount:
  create: true

rbac:
  create: true
EOF
  ]

  # Ensure dependencies are met
  depends_on = [
    data.aws_eks_cluster.eks,
    data.aws_eks_node_group.general,
    helm_release.prometheus # Ensure Prometheus is installed before deploying Argo Rollouts
  ]
}
