#!/bin/sh
DIR=/data/nginx/blog   # 此处为你在vps上存放站点的绝对路径
rm -rf public/
hugo && rsync -avz --delete public/ ali:${DIR}

exit 0