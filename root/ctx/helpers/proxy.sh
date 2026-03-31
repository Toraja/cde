#!/bin/bash

vars=(http_proxy https_proxy no_proxy)
for var in ${vars[@]}; do
  val=$(eval echo \$$var)
  if [[ -n "$val" ]]; then
    echo $var=$val >> /etc/environment
    echo ${var^^}=$val >> /etc/environment
  fi
done
