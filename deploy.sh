#!/bin/sh
DIR=/data/nginx/blog   # 此处为你在vps上存放站点的绝对路径
rm -rf public/
hugo -b https://blog.seveniu.com && rsync -avz --delete public/ ali:${DIR}

exit 0
