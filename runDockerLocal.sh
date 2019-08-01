#!/bin/bash

docker build --rm -t iipimage:latest . && docker run --rm -p 80:80 --name iipimage --sig-proxy=false iipimage:latest
