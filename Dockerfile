# Use an official apache image
FROM  amazonlinux:latest

# Update and install necessary packages
RUN yum update -y && \
    yum install -y httpd git

# Change directory
RUN cd /var/www/html

# Clone the repository and copy its contents to the web server root
RUN git clone https://github.com/chagak/honey-static-webapp.git /tmp/honey-static-webapp/*
RUN cp -r /tmp/honey-static-webapp/* /var/www/html/
RUN rm -rf honey-static-webapp/
RUN systemctl enable httpd
RUN systemctl start httpd

# Expose port 80
EXPOSE 80

# Set the default application that will start when the container start
ENTRYPOINT ["/usr/sbin/httpd", "-D", "FOREGROUND"]
#COPY build /usr/share/nginx/html