# README: Deploying Infrastructure to AWS with Terraform using GitHub Actions

## Important Notes for Forking This Repository

This repository is set up to deploy infrastructure to AWS using Terraform and GitHub Actions, leveraging the GitHub OpenID Connect (OIDC) provider for authentication.

### Workflow Overview

1. **JWT Request**: The GitHub Action requests a JSON Web Token (JWT) from the GitHub OIDC provider.
2. **Signed JWT Issuance**: The GitHub OIDC provider issues a signed JWT to the GitHub Action.
3. **Temporary Access Token Request**: The GitHub Action uses the signed JWT to request a temporary access token from the AWS IAM provider.
4. **JWT Verification**: The AWS IAM provider verifies the signed JWT with the OIDC provider and checks if the specified role can be assumed by the IAM role.
5. **Access Grant**: The IAM provider uses the temporary access token to grant the GitHub Action access to the AWS account.

### Steps to Set Up

#### 1. Configure GitHub Repository

- Get your GitHub username and repository name in the following format:     YOUR_GITHUB_USERNAME/YOUR_REPO_NAME


#### 2. Set Up AWS IAM

- Go to the AWS Management Console and navigate to IAM.
- Choose **Identity Providers** and select **Add Provider**.
- Select **OpenID Connect** as the provider type.

#### 3. Configure OpenID Connect Provider

- **Provider URL**:   https://token.action.githubusercontent.com
- **Audience**:       sts:amazonaws.com

- Click on **Get Thumbprint** and then **Add Provider**.

#### 4. Create an S3 Bucket

- Create an S3 bucket to store the Terraform state file.
- Ensure that encryption is activated for the bucket.

#### 5. Create IAM Role

- Create a new IAM role using the `role-trusted-entity.json` file provided in this repository.
- Adjust the role trust policy to match your AWS account.

#### 6. Create IAM Policies

- Create a policy that allows the role to access the S3 bucket where the Terraform state file will be stored. Use the `s3-bucket-state.json` file as a reference.
- Create a policy specific to your needs (e.g., `task-permissions.json`). Note: For testing purposes, administrative access was used in this repository. **Do not use administrative access in production environments.**
- Attach the created policies to the IAM role.

#### 7. Add Secrets to GitHub Actions

- Add the necessary secrets to your GitHub repository for the GitHub Actions workflow. This typically includes AWS credentials and any other sensitive information required for deployment.

### Conclusion

By following these steps, you will be able to set up your AWS infrastructure deployment using Terraform and GitHub Actions with OpenID Connect. Make sure to review and adjust permissions according to your security requirements.
