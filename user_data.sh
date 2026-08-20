#!/bin/bash
# user_data.sh
# EC2 runs this automatically ONE TIME when the instance first boots.
# Every line here is a plain shell command — no programming language.

# Update all installed packages to the latest version
yum update -y

# Install Docker from Amazon Linux's package repository
yum install -y docker

# Start the Docker service now...
systemctl start docker
# ...and make sure it also starts automatically on every future reboot
systemctl enable docker

# Create a folder to hold our website files
mkdir -p /home/ec2-user/app

# Write the website's HTML file.
# The "<< 'EOF' ... EOF" syntax is a heredoc — everything between the
# two EOF markers is written into the file exactly as-is.
cat > /home/ec2-user/app/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Terraform + Docker Project</title></head>
<body style="font-family: sans-serif; text-align:center; margin-top: 100px;">
  <h1>Deployed with Terraform + Docker on AWS EC2</h1>
  <p>This entire server was provisioned automatically — no manual setup.</p>
</body>
</html>
EOF

# Write the Dockerfile that defines our container image.
# FROM httpd:alpine = start from a tiny, official Apache HTTP Server image.
# COPY puts our index.html where httpd serves files from by default.
cat > /home/ec2-user/app/Dockerfile << 'EOF'
FROM httpd:alpine
COPY index.html /usr/local/apache2/htdocs/index.html
EOF

# Move into the app folder so the next commands run against these files
cd /home/ec2-user/app

# Build a Docker image from the Dockerfile above, and name it "my-web-app"
docker build -t my-web-app .

# Run the image as a container:
#   -d              run in the background (detached)
#   -p 80:80        map port 80 on the server to port 80 inside the container
#   --restart always   auto-restart the container if it crashes or the server reboots
docker run -d -p 80:80 --restart always my-web-app

