variable "aws_region" {
  default     = "us-east-1"
  description = "AWS region"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}
variable "public_subnet_cidrs" {
  description = "CIDR for public subnet"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b"]
}

variable "cluster_name" {
  default = "my-eks-cluster"
}

variable "key_name" {
  description = "The name of the KeyPair for SSH access to the EKS nodes"
  default = "DEVOPS"
}

variable "private_subnet_cidr" {
  description = "CIDR for private subnet"
  default     = "10.0.2.0/24"
}
variable "ami_id" {
  description = "AMI for ec2"
  type = string
  default = "ami-0c94855ba95c574c8" # Замініть на актуальний AMI ID для вашого регіону
}

variable "instance_type" {
  description = "EC2 type"
  default     = "t3.micro"
}


