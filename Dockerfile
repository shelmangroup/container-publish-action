FROM quay.io/buildah/stable:v1.14.3
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]