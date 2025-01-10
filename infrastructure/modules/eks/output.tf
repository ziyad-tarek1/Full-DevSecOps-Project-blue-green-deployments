output "eks_cluster_name" {
  description = "The name of the EKS cluster."
  value       = aws_eks_cluster.eks.name
}

output "eks_cluster_arn" {
  description = "The ARN of the EKS cluster."
  value       = aws_eks_cluster.eks.arn
}

output "worker_role_arn" {
  description = "The ARN of the worker IAM role."
  value       = aws_iam_role.worker.arn
}

output "node_group_name" {
  description = "The name of the EKS node group."
  value       = aws_eks_node_group.general.node_group_name
}

output "eks_node_group_dependency" {
  value = aws_eks_node_group.general
  
}

output "pod_identity_addon_status" {
  description = "The status of the EKS Pod Identity Add-On."
  value       = aws_eks_addon.pod-addon.id
}
