CREATE TEMP FUNCTION parse(item STRING)
RETURNS STRUCT <
  id STRING
  ,en_label STRING
  ,en_wiki STRING
  ,en_description STRING
  ,ja_label STRING
  ,ja_wiki STRING
  ,ja_description STRING
  ,es_label STRING
  ,es_wiki STRING
  ,es_description STRING
  ,fr_label STRING
  ,fr_wiki STRING
  ,fr_description STRING  
  ,de_label STRING
  ,de_wiki STRING
  ,de_description STRING
  ,type STRING
  ,sitelinks ARRAY<STRUCT<site STRING, title STRING, encoded STRING>>
  ,descriptions ARRAY<STRUCT<language STRING, value STRING>>
  ,labels ARRAY<STRUCT<language STRING, value STRING>>
  ,aliases ARRAY<STRUCT<language STRING, value STRING>>
  ,instance_of ARRAY<STRUCT<numeric_id INT64>>
  ,gender ARRAY<STRUCT<numeric_id INT64>>
  ,date_of_birth ARRAY<STRUCT<time STRING>>
  ,date_of_death ARRAY<STRUCT<time STRING>>
  ,country_of_citizenship ARRAY<STRUCT<numeric_id INT64>>
  ,country ARRAY<STRUCT<numeric_id INT64>>
  ,occupation ARRAY<STRUCT<numeric_id INT64>>
  ,instrument ARRAY<STRUCT<numeric_id INT64>>
  ,genre ARRAY<STRUCT<numeric_id INT64>>
  ,industry ARRAY<STRUCT<numeric_id INT64>>
  ,subclass_of ARRAY<STRUCT<numeric_id INT64>>
  ,coordinate_location ARRAY<STRUCT<latitude FLOAT64, longitude FLOAT64, altitude FLOAT64>>
  ,iso_3166_alpha3 ARRAY<STRUCT<value STRING>> 
>

LANGUAGE js AS """

  function wikiEncode(x) {
//    return x ? encodeURI(x.split(' ').join('_')) : null;
    return x ? (x.split(' ').join('_')) : null;
  }
  
  var obj = JSON.parse(item.slice(0, -1));

  sitelinks =[];
  for(var i in obj.sitelinks) {
    sitelinks.push({'site':obj.sitelinks[i].site, 'title':obj.sitelinks[i].title, 'encoded':wikiEncode(obj.sitelinks[i].title)}) 
  }  
  descriptions =[];
  for(var i in obj.descriptions) {
    descriptions.push({'language':obj.descriptions[i].language, 'value':obj.descriptions[i].value}) 
  }
  labels =[];
  for(var i in obj.labels) {
    labels.push({'language':obj.labels[i].language, 'value':obj.labels[i].value}) 
  }
  aliases =[];
  for(var i in obj.aliases) {
    for(var j in obj.aliases[i]) {
      aliases.push({'language':obj.aliases[i][j].language, 'value':obj.aliases[i][j].value}) 
    }
  }
  
  function snaks(obj, pnumber, name) {
    var snaks = []
    for(var i in obj.claims[pnumber]) {
      if (!obj.claims[pnumber][i].mainsnak.datavalue) continue;
      var claim = {}
      claim[name]=obj.claims[pnumber][i].mainsnak.datavalue.value[name.split('_').join('-')]
      snaks.push(claim) 
    }
    return snaks
  }
  function snaksValue(obj, pnumber, name) {
    var snaks = []
    for(var i in obj.claims[pnumber]) {
      if (!obj.claims[pnumber][i].mainsnak.datavalue) continue;
      var claim = {}
      claim[name]=obj.claims[pnumber][i].mainsnak.datavalue.value
      snaks.push(claim) 
    }
    return snaks
  }
  function snaksLoc(obj, pnumber) {
    var snaks = []
    for(var i in obj.claims[pnumber]) {
      if (!obj.claims[pnumber][i].mainsnak.datavalue) continue;
      var claim = {}
      claim['altitude']=obj.claims[pnumber][i].mainsnak.datavalue.value['altitude']
      claim['longitude']=obj.claims[pnumber][i].mainsnak.datavalue.value['longitude']
      claim['latitude']=obj.claims[pnumber][i].mainsnak.datavalue.value['latitude']
      snaks.push(claim) 
    }
    return snaks
  }
  
  instance_of=snaks(obj, 'P31', 'numeric_id');
  gender=snaks(obj, 'P21', 'numeric_id');
  date_of_birth=snaks(obj, 'P569', 'time');
  date_of_death=snaks(obj, 'P569', 'time');
  place_of_birth=snaks(obj, 'P19', 'numeric_id');
  country_of_citizenship=snaks(obj, 'P27', 'numeric_id');
  country=snaks(obj, 'P17', 'numeric_id');
  occupation=snaks(obj, 'P106', 'numeric_id');
  instrument=snaks(obj, 'P1303', 'numeric_id');
  genre=snaks(obj, 'P136', 'numeric_id');
  industry=snaks(obj, 'P452', 'numeric_id');
  subclass_of=snaks(obj, 'P279', 'numeric_id');
  coordinate_location=snaksLoc(obj, 'P625');
  iso_3166_alpha3=snaksValue(obj, 'P298', 'value');

  return {
    id: obj.id,
    en_wiki: obj.sitelinks.enwiki ? wikiEncode(obj.sitelinks.enwiki.title) : null,
    en_label: obj.labels.en ? obj.labels.en.value : null,
    en_description: obj.descriptions.en ? obj.descriptions.en.value : null,
    ja_wiki: obj.sitelinks.jawiki ? wikiEncode(obj.sitelinks.jawiki.title) : null,
    ja_label: obj.labels.ja ? obj.labels.ja.value : null,
    ja_description: obj.descriptions.ja ? obj.descriptions.ja.value : null,
    es_wiki: obj.sitelinks.eswiki ? wikiEncode(obj.sitelinks.eswiki.title) : null,
    es_label: obj.labels.es ? obj.labels.es.value : null,
    es_description: obj.descriptions.es ? obj.descriptions.es.value : null,
    de_wiki: obj.sitelinks.dewiki ? wikiEncode(obj.sitelinks.dewiki.title) : null,
    de_label: obj.labels.de ? obj.labels.de.value : null,
    de_description: obj.descriptions.de ? obj.descriptions.de.value : null,
    
    labels: labels, 
    descriptions: descriptions,
    sitelinks: sitelinks,
    aliases: aliases,
    instance_of: instance_of,
    gender: gender,
    date_of_birth: date_of_birth,
    date_of_death: date_of_death,
    place_of_birth: place_of_birth,
    country_of_citizenship: country_of_citizenship,
    country: country,
    occupation: occupation,
    instrument: instrument,
    genre: genre,
    industry: industry,
    subclass_of: subclass_of,
    coordinate_location: coordinate_location,
    iso_3166_alpha3: iso_3166_alpha3,
  }

""";

CREATE TABLE `temp.wikidata_parsed2`
AS

SELECT parse(item).*, item
FROM `fh-bigquery.temp.wikidata_partial` 
WHERE LENGTH(item)>10
AND (
  JSON_EXTRACT_SCALAR(item, '$.sitelinks.enwiki.title') IS NOT NULL
  OR
  JSON_EXTRACT_SCALAR(item, '$.sitelinks.jawiki.title') IS NOT NULL
  OR
  JSON_EXTRACT_SCALAR(item, '$.sitelinks.eswiki.title') IS NOT NULL
)
