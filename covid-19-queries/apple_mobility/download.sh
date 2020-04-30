x=$(curl -s https://covid19-static.cdn-apple.com/covid19-mobility-data/current/v2/index.json)
url=$( echo https://covid19-static.cdn-apple.com`jq -n "$x" |jq -r '.basePath'``jq -n "$x"|jq -r '.regions."en-us".csvPath'
`)
curl -s $url -o /tmp/latestAppleCovidData.csv
bq load --autodetect --replace fh-bigquery:temp.latestAppleCovidData /tmp/latestAppleCovidData.csv
