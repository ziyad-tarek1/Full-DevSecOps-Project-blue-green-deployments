variable "project_name" {
  description = "The name of the project for tagging and resource naming."
  type        = string
}

variable "eks_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "eks_version" {
  description = "The version of the EKS cluster."
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for the EKS cluster."
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet IDs for the worker node group."
  type        = list(string)
}

variable "instance_types" {
  description = "List of instance types for the EKS node group."
  type        = list(string)
  default     = ["t2.medium"]
}

variable "desired_size" {
  description = "Desired size of the EKS node group."
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum size of the EKS node group."
  type        = number
  default     = 5
}

variable "min_size" {
  description = "Minimum size of the EKS node group."
  type        = number
  default     = 1
}


variable "region" {
  description = "AWS region for the EKS cluster."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the cluster networking."
  type        = string
}


variable "endpoint_private_access" {
  description = "Flag to enable endpoint private access"
  type        = bool
  default     = false
}

variable "endpoint_public_access" {
  description = "Flag to enable endpoint public access"
  type        = bool
  default     = true
}