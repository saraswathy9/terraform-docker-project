cat > variables.tf << 'EOF'
variable "aws_region" {
  default = "ap-south-1"
}

variable "ami_id" {
  default = "ami-0ac7b260cf76d8865"
}

variable "instance_type" {
  default = "t3.micro"
}
EOF
# This file holds the values used in main.tf, so you can change
# things in one place.

variable "aws_region" {
  default = "ap-south-1"   # change to your preferred AWS region
}

variable "ami_id" {
  # Amazon Linux 2023 AMI ID â€” this is region-specific and changes
  # over time. Look up the current one yourself:
  # AWS Console â†’ EC2 â†’ AMI Catalog â†’ search "Amazon Linux 2023"
  # (make sure the region matches var.aws_region above)
  default = "ami-XXXXXXXXXXXXXXXXX"   # replace with your own AMI ID
}

variable "instance_type" {
  default = "t3.micro"   # free-tier eligible server size
}
