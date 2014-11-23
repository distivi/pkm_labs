#!/bin/bash

echo "run server with some secret on port: $1"

xterm -hold -e "ruby server.rb $1" &

echo "run multiple client to huck server's secret key"

xterm -hold -e "ruby client.rb $1 0000 0500" &
xterm -hold -e "ruby client.rb $1 0501 1000" &
xterm -hold -e "ruby client.rb $1 1001 1500" &



