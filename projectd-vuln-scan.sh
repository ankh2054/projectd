#!/bin/bash

# Run against a URL wax.json is automatically added.
## ./wax-hypersion-scan.sh https://waxsweden.org
#curl https://validate.eosnation.io/wax/reports/endpoints.json | jq -c '.report.api_http[]|{name:values[0]["name"],api:values[1]}'

## Colours setup 
RED='\033[1;31m'
NC='\033[0m' # No Color


# Obtain the public nodes from JSON file.
ENDPOINTS=$(curl -s $1"/wax.json"  | jq -c '.nodes | .[] | select(.node_type == "seed" | "full" | "api" ) | .p2p_endpoint, .api_endpoint, .ssl_endpoint | select(length > 0)'
) 

# Place each endpoint onto a new line |  strip http and https | remove duplicates   > endpoints.txt
echo "$ENDPOINTS" | gsed 's/^"//; s/"$//; s~^https\?://~~; s/:[0-9]\+$//' |  sort -u > endpoints.txt

echo -e "${RED}These are thepoints to be scanned"
cat endpoints.txt
echo -e "${NC}"

# Apply list to projectd clean up then if hyperion do this
cat endpoints.txt | naabu -silent -ports-file naabu/ports.txt -exclude-ports 53 | httprobe | nuclei -t panels/rabbitmq-dashboard.yaml --json 

