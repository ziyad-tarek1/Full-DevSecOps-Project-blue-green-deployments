# 🚀 End-to-End Kubernetes Three-Tier DevSecOps Project 🌐  
### A Full DevSecOps Lifecycle with Blue-Green Deployments and Automated Kubernetes Infrastructure

This project is a fully automated **DevSecOps pipeline** that demonstrates secure, scalable, and reliable application delivery using modern tools and practices. From infrastructure provisioning to blue-green deployments, it integrates CI/CD, security, and monitoring into a single cohesive workflow.  

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Setup and Installation](#setup-and-installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

This project implements an **end-to-end DevSecOps lifecycle** using cutting-edge technologies to achieve:  
- Secure and automated **infrastructure provisioning** on AWS.  
- Deployment of a three-tier application (Frontend, Backend, Database) on Kubernetes.  
- Zero-downtime **blue-green deployments** using ArgoCD Rollouts.  
- Continuous monitoring with Prometheus and Grafana.  

**Key Tools and Practices**:
- **GitHub Actions**: Automates infrastructure and application deployment.  
- **Terraform**: Provisions EKS, a bastion host, and Kubernetes add-ons using AWS and Helm providers.  
- **ArgoCD**: Monitors Git repositories to manage Kubernetes deployments.  
- **Blue-Green Deployment**: Ensures seamless updates with service-active and service-preview patterns.  

---

## Features

- **GitHub Actions CI/CD**:  
  - Uses **OpenID Connect** to securely deploy infrastructure and monitor updates.  
  - Triggers automated pipelines on every code push.  

- **Infrastructure Provisioning with Terraform**:  
  - Deploys an **EKS cluster** with two worker nodes.  
  - Sets up a **bastion host** to manage the cluster (includes Jenkins, Docker, Trivy, and SonarQube).  
  - Installs critical Kubernetes components like Prometheus, Grafana, Metrics Server, AWS ALB, ArgoCD, and Argo Rollouts using **Helm**.  

- **Blue-Green Deployment with ArgoCD Rollouts**:  
  - Enables seamless traffic switching between active and preview versions of the frontend application.  

- **Three-Tier Application Deployment**:  
  - Frontend: React.js  
  - Backend: Node.js  
  - Database: Stateful Kubernetes deployment with Persistent Volumes and Secrets.  

- **Security and Quality**:  
  - **Trivy**: Scans Docker images for vulnerabilities.  
  - **SonarQube**: Analyzes code quality during CI.  

---

## Architecture

![image alt](https://github.com/ziyad-tarek1/Full-DevSecOps-Project-blue-green-deployments/blob/bc3b1447451b47587bb0c7c4bc8f51607b63b0b5/finalllll.gif)

**Infrastructure Overview**:
1. **AWS Infrastructure**:
   - EKS Cluster with two worker nodes.  
   - Bastion host (jump server) configured with Jenkins, Trivy, Docker, and SonarQube.  

2. **Kubernetes Cluster**:
   - Automated deployment of monitoring tools (Prometheus, Grafana).  
   - Application services for Frontend, Backend, Database, and Ingress.  
   - Blue-Green deployment for the frontend using Argo Rollouts.  

3. **CI/CD Pipeline**:
   - GitHub Actions automates Terraform deployment.  
   - ArgoCD monitors the repository and syncs Kubernetes manifests.  

---

## Project Structure

```plaintext
.
├── application/
│   ├── backend/               # Node.js backend code
│   └── frontend/              # React.js frontend code
├── github-action/             # GitHub Actions workflows and policies
├── infrastructure/            # Terraform scripts for AWS infrastructure
│   ├── modules/               # Modular Terraform configuration
│   ├── production/            # Production environment variables and scripts
├── k8s/                       # Kubernetes manifests
│   ├── argocd/                # ArgoCD application definitions
│   ├── Backend/               # Backend deployment and service
│   ├── Database/              # Database deployment, secrets, and PVC
│   ├── Frontend/              # Frontend deployment and services
│   ├── Ingress/               # Ingress rules for routing
│   └── namespace.yaml         # Namespace configuration
├── RBAC/                      # Role-based access control for Jenkins-EKS authentication
├── Jenkinsfile                # Jenkins pipeline definition
└── README.md                  # Project documentation
```

## Setup and Installation
### Prerequisites
    AWS CLI: Install and configure with appropriate credentials.
    Terraform: Version 1.0 or higher.
    Docker: Installed and configured.
    Kubernetes: kubectl CLI installed.
    GitHub Actions: Repository secrets configured for Terraform.


## Usage
1- Trigger Pipeline:

    - Push changes to the GitHub repository to trigger GitHub Actions workflows for infrastructure automation and deployments.
2- View Jenkins and SonarQube:
- Access the bastion host to monitor Jenkins builds and SonarQube analysis.
3- Monitor Kubernetes Resources:
- Check the status of pods and services:
```bash
kubectl get all --all-namespace
```
4- Access the Application:
- Use the AWS ALB endpoint to access the deployed frontend and backend.
5- Monitor with Grafana:
- Access Grafana dashboards for real-time metrics and insights.

## Contributing
Contributions are welcome! Feel free to fork the repository, make changes, and submit a pull request. Ensure all contributions align with the project goals and adhere to best practices.

## License
This project is licensed under the MIT License. See LICENSE for detail
