# Use the official Amazon Linux 2 image
FROM amazonlinux:2

# Install necessary packages including Apache, Git, Docker, and AWS CLI dependencies
RUN yum update -y && \
    yum install -y \
    httpd \
    git \
    curl \
    unzip \
    sudo \
    && yum install -y docker

# Enable Docker service (optional, if needed to run Docker within the container)
RUN sudo systemctl enable docker

# Change directory to the Apache web root
RUN cd /var/www/html

# Clone the repository and copy its contents to the web server root
RUN git clone https://github.com/chagak/honey-static-webapp.git /tmp/honey-static-webapp/* \
    && cp -r /tmp/honey-static-webapp/* /var/www/html/ \
    && rm -rf /tmp/honey-static-webapp/

# Expose port 80
EXPOSE 80

# Set the default application that will start when the container starts
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]

