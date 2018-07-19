# nginx-alpine
This is the S2I nginx-alpine image:
To use it, install S2I: https://github.com/openshift/source-to-image

---------------------------------------------------------------
Build image in Docker:
	docker build -t nginx-alpine-s2i

Test application:
All files under the test directory will be in your test web

	s2i build test/ nginx-alpine-s2i nginx-test

Execute the test web application in docker:

	docker run -d -p 8080:8080 nginx-test

navigate to your web browsing at http://localhost:8080

---------------------------------------------------------------
Build in openshift:
	oc new-build --name nginx-alpine --strategy=docker \
	--code  https://github.com/mcn015/nginx-alpine

Build from the local directory:
	oc start-build nginx-alpine --from-dir=.

Create application in openshift:
	oc new-app nginx-alpine~https://github.com/mcn015/nginx-alpine \
	--context-dir test/ \
	--name nginx-test

NOTE: In Alpine linux there is no bash (ash shell only),
 note the "#bin/sh" line in the s2i/bin/ files
