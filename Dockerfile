
# nginx-alpine
# Here you can use whatever base image is relevant for your application.
FROM nginx:1.14.0-alpine

# Here you can specify the maintainer for the image that you're building
LABEL maintainer="Miquel Canals <miquel.canals@uib.cat>"

# Export an environment variable that provides information about the application version.
# Replace this with the version for your application.
ENV NGINX_VERSION=1.14.0

# Set the labels that are used for OpenShift to describe the builder image.
LABEL io.k8s.description="Nginx Webserver" \
    io.k8s.display-name="Nginx 1.14.0" \
    io.openshift.expose-services="8080:http" \
    io.openshift.tags="builder,webserver,html,nginx" \
    # this label tells s2i where to find its mandatory scripts
    # (run, assemble, save-artifacts)
    io.openshift.s2i.scripts-url="image:///usr/libexec/s2i"

## create user in group root
RUN  adduser -s /bin/sh -u 1001 -G root -H -S -D default

# Change the default port for nginx
# Required if you plan on running images as a non-root user).
RUN sed -i 's/listen\(.*\)80;/listen 8080;/' /etc/nginx/conf.d/default.conf
# RUN sed -i 's/80/8080/' /etc/nginx/nginx.conf
RUN sed -i 's/^user/#user/' /etc/nginx/nginx.conf

RUN apk add --no-cache bash

# Copy the S2I scripts to /usr/libexec/s2i since we set the label that way
COPY ./s2i/bin/ /usr/libexec/s2i

RUN chmod -R 775 \
  /var/cache/nginx \
  /var/run \
  /var/log/nginx \
  /usr/libexec/s2i \
  /usr/share/nginx/* \
  && chgrp -R root /var/cache/nginx

RUN chown -R 1001:0 \
  /var/cache/nginx \
  /var/run \
  /var/log/nginx \
  /usr/libexec/s2i \
  /etc/nginx \
  /usr/share/nginx/*


USER 1001

# Set the default port for applications built using this image
EXPOSE 8080

# Modify the usage script in your application dir to inform the user how to run
# this image.
# CMD ["/bin/bash"]
CMD ["/usr/libexec/s2i/usage"]
