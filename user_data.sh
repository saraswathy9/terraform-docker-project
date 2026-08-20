#!/bin/bash
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker

mkdir -p /home/ec2-user/app
cd /home/ec2-user/app

cat > index.html << 'HTMLEOF'
<!DOCTYPE html>
<html>
<head><title>Terraform + Docker + httpd</title></head>
<body style="font-family: sans-serif; text-align:center; margin-top: 100px;">
  <h1>Deployed with Terraform + Docker (Apache httpd)</h1>
</body>
</html>
HTMLEOF

cat > Dockerfile << 'DOCKEREOF'
FROM httpd:alpine
COPY index.html /usr/local/apache2/htdocs/index.html
DOCKEREOF

docker build -t my-web-app .
docker run -d -p 80:80 --restart always my-web-app
