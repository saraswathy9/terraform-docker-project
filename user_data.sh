#!/bin/bash
# This script runs automatically the first time the server starts.
# It installs Docker, builds a website image, and runs it.

# Update the server and install Docker
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker

# Make a folder for our website files
mkdir -p /home/ec2-user/app
cd /home/ec2-user/app

# Create the website page
cat > index.html << 'HTMLEOF'
<!DOCTYPE html>
<html>
<head><title>Terraform + Docker + httpd</title></head>
<body style="font-family: sans-serif; text-align:center; margin-top: 100px;">
  <h1>Deployed with Terraform + Docker (Apache httpd)</h1>
</body>
</html>
HTMLEOF

# Create the Dockerfile (instructions for building the container image)
cat > Dockerfile << 'DOCKEREOF'
FROM httpd:alpine
COPY index.html /usr/local/apache2/htdocs/index.html
DOCKEREOF

# Build the image and run it as a container on port 80
docker build -t my-web-app .
docker run -d -p 80:80 --restart always my-web-app
