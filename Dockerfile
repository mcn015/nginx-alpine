# nginx running in alpine as an arbitrary user
FROM nginx:1.14.0-alpine

LABEL io.k8s.description="S2I image for nginx in alpine linux" \
      io.k8s.display-name="Nginx 1.14" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,html,nginx,alpine,s2i" \
      io.openshift.s2i.scripts-url="image:///usr/libexec/s2i"

# RUN apk add --no-cache bash

# Copy the S2I scripts to /usr/libexec/s2i which is the location set for scripts
# as io.openshift.s2i.scripts-url label
COPY ./s2i/bin/ /usr/libexec/s2i

# support running as arbitrary user which belogs to the root group
RUN chmod -R g+rwx \
	/var/cache/nginx \
	/var/run \
	/var/log/nginx \
	/usr/libexec/s2i \
	/usr/share/nginx/html/
RUN chgrp -R root /var/cache/nginx

# users are not allowed to listen on priviliged ports, use 8080
RUN sed -i.bak 's/listen\(.*\)80;/listen 8080;/' /etc/nginx/conf.d/default.conf

# comment user directive as master process is run as user in OpenShift anyhow
RUN sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf

RUN addgroup nginx root

EXPOSE 8080

USER nginx

CMD [ "/usr/libexec/s2i/usage" ]
