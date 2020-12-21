#!/bin/bash

cat > index.html <<EOF
<h1>Hello, World</h1>
<h1>My Name is Karam, and i am learning terraform</h1>
<h1>hopefully it works this time and i can finisht the book</h1>
<h1>this is the new application provisioned in 2020</h1>
EOF
nohup busybox httpd -f -p ${server_port} &