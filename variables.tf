cat > variables.tf << 'EOF'
variable "aws_region" {
  default = "ap-south-1"   # change to your preferred AWS region
}

variable "ami_id" {
  default = "ami-XXXXXXXXXXXXXXXXX"   # replace with your own AMI ID
}

variable "instance_type" {
  default = "t3.micro"
}
