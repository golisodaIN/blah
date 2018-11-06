# Find the top 4-step path between 2 Wikipedia pages
# @felipehoffa

SELECT a.a, a.bridge.b, a.c, b.bridge.b b_b, b.c b_c, a.bridge.prob*b.bridge.prob prob
FROM `fh-bigquery.wikipedia_vt.clicstream_c_comb_clust_a` a
JOIN `fh-bigquery.wikipedia_vt.clicstream_c_comb_clust_c` b
ON a.c=b.a
WHERE a.a='List_of_Presidents_of_the_United_States'
AND b.c='Lady_Gaga'
AND a.bridge.b!=b.bridge.b
AND a.a!=b.bridge.b
AND a.bridge.b!=b.c
ORDER BY prob DESC
LIMIT 30
