#!/bin/sh

echo "Starting cron service"
service cron start

echo "Starting openresty"
/usr/bin/openresty -g 'daemon off;'

exec "$@"
