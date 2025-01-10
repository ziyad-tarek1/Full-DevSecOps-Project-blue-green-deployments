# Generate an RSA private key
resource "tls_private_key" "rs4_4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create a key pair for SSH access
resource "aws_key_pair" "demo1_key" {
  key_name   = var.key_name
  public_key = tls_private_key.rs4_4096.public_key_openssh
}

# Save the private key locally
resource "local_file" "demo1_private_key" {
  content          = tls_private_key.rs4_4096.private_key_pem
  filename         = "./${var.key_name}.pem"
  file_permission  = "0400"
}

# Fetch the latest Amazon Linux 2 AMI
/*data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["amazon"]
}*/

data "aws_ami" "ubuntu-linux-1804" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# IAM Role for EC2 Instance
resource "aws_iam_role" "ec2_role" {
  name               = "${var.project_name}-eks-manager-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.project_name}-eks-manager-instance-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy_attachment" "eks_AdministratorAccess_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Security Group for EC2 Instance
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-eks-manager-sg"
  description = "Allow SSH access for EKS manager EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow custom port range"
    from_port   = 500
    to_port     = 11000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-eks-manager-sg"
  }
}

# EC2 Instance with Key Pair and Provisioners
resource "aws_instance" "demo1_ec2" {
  ami                  =   data.aws_ami.ubuntu-linux-1804.id   //"ami-0e2c8caa4b6378d8c"   //data.aws_ami.amazon_linux.id
  instance_type        = var.instance_type
  subnet_id            = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  key_name             = aws_key_pair.demo1_key.key_name

  # User Data for Instance Bootstrapping
  user_data = file(var.entry_point_script)

  # Connection for SSH Provisioning
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.rs4_4096.private_key_pem
  }

  # File Provisioner
  provisioner "file" {
    source      = var.provisioner_script
    destination = "/home/ubuntu/${basename(var.provisioner_script)}"
  }

  # Remote-Exec Provisioner
  provisioner "remote-exec" {
    script = var.provisioner_script
  }

  tags = {
    Name = "${var.project_name}_${var.instanceName}"
  }

  depends_on = [var.eks_dependency]
}

# Elastic IP for EC2 Instance
resource "aws_eip" "demo1_eip" {
  instance = aws_instance.demo1_ec2.id

  tags = {
    Name = "${var.project_name}-eks-manager-eip"
  }
}
