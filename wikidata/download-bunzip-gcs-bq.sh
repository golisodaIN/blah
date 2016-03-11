#! /bin/bash
apt-get update
apt-get install -y wget lbzip2

wget https://dumps.wikimedia.org/wikidatawiki/entities/latest-all.json.bz2; date;\
lbunzip2 latest-all.json.bz2; date;\
gsutil -o GSUtil:parallel_composite_upload_threshold=150M cp latest-all.json gs://fh-bigquery/wikidata/; date;\
bq load --field_delimiter="tab" --max_bad_records 1 --replace wikidata.latest_raw gs://fh-bigquery/wikidata/latest-all.json item; date


# Download: 4.1 GB, 2 MB/s, 35 minutes
# lbunzip2: 65 GB, 7 minutes (16 cpus)
# gsutil cp: 65 GB, 3 minutes (4 cpus)
# bq: 3 minutes ingest
