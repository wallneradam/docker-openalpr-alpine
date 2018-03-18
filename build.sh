#!/bin/sh

docker build --rm -t wallneradam/openalpr-alpine:latest .
docker push wallneradam/openalpr-alpine:latest
