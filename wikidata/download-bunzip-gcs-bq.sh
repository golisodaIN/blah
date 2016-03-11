wget https://dumps.wikimedia.org/wikidatawiki/entities/latest-all.json.bz2; \
lbunzip2 latest-all.json.bz2; \
gsutil -o GSUtil:parallel_composite_upload_threshold=150M cp latest-all.json gs://bqpipeline/wikidata/; \
bq load --field_delimiter="tab" --max_bad_records 1 --replace imports.wikidata_csv gs://bqpipeline/wikidata/latest-all.json item

