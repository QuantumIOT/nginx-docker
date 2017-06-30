FROM nginx:latest

RUN apt-get update \
	&& apt-get install --no-install-recommends --no-install-suggests -y curl jq

COPY docker-entrypoint.sh /
COPY ips_check.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
