# Use the official Amazon Linux image as the base image
FROM amazonlinux:latest

# Install necessary packages including Apache, Git, Docker, and AWS CLI
RUN yum update -y && \
    yum install -y \
    httpd \
    git \
    curl \
    unzip \
    sudo \
    docker \
    aws-cli

# Install Docker (optional, in case the default version is not sufficient)
RUN curl -fsSL https://get.docker.com | sh

# Install AWS CLI v2 (this is to ensure you have the latest version of AWS CLI)
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    sudo ./aws/install && \
    rm -rf awscliv2.zip

# Set working directory
WORKDIR /var/www/html

# Clone the repository and copy its contents to the web server root
RUN git clone https://github.com/chagak/honey-static-webapp.git /tmp/honey-static-webapp && \
    cp -r /tmp/honey-static-webapp/* /var/www/html/ && \
    rm -rf /tmp/honey-static-webapp

# Expose port 80 to allow access to the web server
EXPOSE 80

# Start Apache in the foreground
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
