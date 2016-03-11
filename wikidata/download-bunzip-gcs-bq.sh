wget https://dumps.wikimedia.org/wikidatawiki/entities/latest-all.json.bz2; \
lbunzip2 latest-all.json.bz2; \
gsutil -o GSUtil:parallel_composite_upload_threshold=150M cp latest-all.json gs://fh-bigquery/wikidata/; \
bq load --field_delimiter="tab" --max_bad_records 1 --replace wikidata.latest_raw gs://fh-bigquery/wikidata/latest-all.json item

