SELECT id, sitelinks.site, sitelinks.title, sitelinks.encoded
FROM js(
(
  SELECT JSON_EXTRACT_SCALAR(item, '$.sitelinks.enwiki.title') title, item
  FROM [fh-bigquery:wikidata.latest_raw] 
  WHERE JSON_EXTRACT_SCALAR(item, '$.claims.P31[0].mainsnak.datavalue.value.numeric-id')='146' #cats
  AND LENGTH(item)>10
),
title, item,
"[{name: 'id', type:'string'},
  {name: 'sitelinks', type:'record', mode:'repeated', fields: [{name: 'site', type: 'string'},{name: 'title', type: 'string'},{name: 'encoded', type: 'string'}]}
  ]",
  "function(r, emit) {

  function wikiEncode(x) {
    return x ? encodeURI(x.split(' ').join('_')) : null;
  }

  var obj = JSON.parse(r.item.slice(0, -1));
    
  sitelinks =[];
  for(var i in obj.sitelinks) {
    sitelinks.push({'site':obj.sitelinks[i].site, 'title':obj.sitelinks[i].title, 'encoded':wikiEncode(obj.sitelinks[i].title)}) 
  }  
  emit({
    id: obj.id,
    sitelinks: sitelinks
    });  
  }")
WHERE sitelinks.site IN ('jawiki', 'arwiki')
