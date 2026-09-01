# https://verdaccio.org/docs/docker#adding-plugins-with-local-plugins-a-dockerfile
FROM verdaccio/verdaccio:6

COPY config/config.yaml /verdaccio/conf/config.yaml
