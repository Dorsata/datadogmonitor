# Dockerfile
FROM quay.io/aptible/ubuntu:14.04

ADD . /app
WORKDIR /app

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
  && apt-get install -y apt-transport-https \
  && rm -rf /var/lib/apt/lists/*

RUN sh -c "echo 'deb https://apt.datadoghq.com/ stable main' > /etc/apt/sources.list.d/datadog.list"
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C7A7DA52

RUN apt-get update && apt-get -y install --allow-unauthenticated datadog-agent

# ADD app /app

RUN set -a && . /app/.aptible.env && echo "init_config:\ninstances:\n  - host : $DBHOST\n    port : $DBPORT\n    username : $DBUSERNAME\n    password : $DBPASSWORD\n    ssl : True" > /etc/dd-agent/conf.d/postgres.yaml

# ADD postgres.yaml /etc/dd-agent/conf.d/

RUN set -a && . /app/.aptible.env && sh -c "sed 's/api_key:.*/api_key: $DATADOGAPIKEY/' /etc/dd-agent/datadog.conf.example > /etc/dd-agent/datadog.conf"
RUN sh -c "sed -i 's/# apm_enabled: false/apm_enabled: true/' /etc/dd-agent/datadog.conf"
RUN sh -c "sed -i 's/# bind_host: localhost/bind_host: 0.0.0.0/' /etc/dd-agent/datadog.conf"

EXPOSE 8126 8125
