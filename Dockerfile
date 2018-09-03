# nginx running in alpine as an arbitrary user
# S2I image, works in OpenShift 3.9

FROM alpine:3.7

LABEL io.k8s.description="S2I image for nginx in alpine linux" \
      io.k8s.display-name="Nginx 1.14" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,html,nginx,alpine,s2i" \
      io.openshift.s2i.scripts-url="image:///usr/libexec/s2i"

# install nginx
RUN apk add --no-cache nginx

# Copy the S2I scripts to /usr/libexec/s2i which is the location set for scripts
# as io.openshift.s2i.scripts-url label
COPY ./s2i/bin/ /usr/libexec/s2i

# Copy customized config files
COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf

# support running as arbitrary user which belogs to the root group 
RUN mkdir -p /var/cache/nginx && \
    adduser -u 1001 -G root -h /var/lib/nginx -D -H -S -s/sbin/nologin 1001 && \
    chown -R 1001:root \
        /usr/sbin/nginx \
	/var/cache/nginx \
	/var/run \
	/var/log/nginx \
	/usr/libexec/s2i \
	/var/tmp \
	/var/lib/nginx && \
    chmod -R u+x \
	/usr/libexec/s2i  && \
    chmod -R g=u \
        /usr/sbin/nginx \
	/var/cache/nginx \
	/var/run \
	/var/log/nginx \
	/usr/libexec/s2i \
	/var/tmp \
	/var/lib/nginx

# RUN chgrp -R root /var/cache/nginx

# RUN addgroup nginx root

EXPOSE 8080

USER 1001

CMD [ "/usr/libexec/s2i/usage" ]
