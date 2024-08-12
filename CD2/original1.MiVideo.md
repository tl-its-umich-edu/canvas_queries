# MiVideo Queries

*Use this query to find pages that have MiVideo content embedded for courss in a specified term and subaccount.  Use the option to for wp.value.body like '%resource_link_lookup_uuid%' for LTI 1.3 video embeds and use wp.value.body like '%aakaf.mivideo.it.umich.edu%' for LTI 1.1 video embeds*



```
SELECT co.value.enrollment_term_id as term_id
  ,et.value.name as term_name
  ,co.value.account_id as subaccount
  ,ac.value.name as subaccount_name
  ,co.key.id as course_id
  ,co.value.name as course_name
  ,co.value.workflow_state as course_status
  ,wp.value.title as page_title
  ,wp.value.body as page_body
  ,wp.value.url as page_url
FROM udp-umich-prod.canvas.courses co
JOIN udp-umich-prod.canvas.wiki_pages wp on wp.value.context_id = co.key.id
JOIN udp-umich-prod.canvas.lti_resource_links rl on rl.value.context_id = co.key.id
JOIN udp-umich-prod.canvas.enrollment_terms et on et.key.id = co.value.enrollment_term_id
JOIN udp-umich-prod.canvas.accounts ac on ac.key.id = co.value.account_id
WHERE co.value.enrollment_term_id = <TERM_ID>
  AND co.value.account_id = <ACCOUNT_ID>
  AND co.value.workflow_state !='deleted'
  AND wp.value.workflow_state != 'deleted'
  AND wp.value.context_type = 'Course'
--  AND wp.value.body like '%resource_link_lookup_uuid%'
--  AND wp.value.body like '%aakaf.mivideo.it.umich.edu%'
;
```

*Use this query to find pages that have MiVideo content embedded in specified courses. Use the option to for wp.value.body like '%resource_link_lookup_uuid%' for LTI 1.3 video embeds and use wp.value.body like '%aakaf.mivideo.it.umich.edu%' for LTI 1.1 video embeds*


```
SELECT co.value.enrollment_term_id as term_id
  ,et.value.name as term_name
  ,co.value.account_id as subaccount
  ,ac.value.name as subaccount_name
  ,co.key.id as course_id
  ,co.value.name as course_name
  ,co.value.workflow_state as course_status
  ,wp.value.title as page_title
  ,wp.value.body as page_body
  ,wp.value.url as page_url
FROM udp-umich-prod.canvas.courses co
JOIN udp-umich-prod.canvas.wiki_pages wp on wp.value.context_id = co.key.id
JOIN udp-umich-prod.canvas.enrollment_terms et on et.key.id = co.value.enrollment_term_id
JOIN udp-umich-prod.canvas.accounts ac on ac.key.id = co.value.account_id
WHERE co.key.id in <(list of course_id)>
  AND co.value.workflow_state !='deleted'
  AND wp.value.workflow_state != 'deleted'
  AND wp.value.context_type = 'Course'
--  AND wp.value.body like '%resource_link_lookup_uuid%'
--  AND wp.value.body like '%aakaf.mivideo.it.umich.edu%'
;
```

*Use this query to find pages that have MiVideo content embedded in Canvas pages. Use enrollment terms to limit the amount of data returned* 

```
SELECT DISTINCT et.value.name as term
  ,c.key.id as course_id
  ,wp.key.id as wiki_page_id
  ,wp.value.title as wiki_page_title
  ,wp.value.workflow_state as wiki_page_workflow_state
  ,wp.value.url as wiki_page_url
  ,wp.value.body as wiki_page_body
FROM udp-umich-prod.canvas.wiki_pages wp
JOIN udp-umich-prod.canvas.courses c on wp.value.context_id = c.key.id
JOIN udp-umich-prod.canvas.enrollment_terms et on c.value.enrollment_term_id = et.key.id
WHERE wp.value.body LIKE '%aakaf.mivideo.it.umich.edu%browseandembed%playerSkin%2F%'
  AND wp.value.context_type = 'Course'
  AND c.value.enrollment_term_id in (311,312)
  AND wp.value.workflow_state !='deleted'
  AND c.value.workflow_state !='deleted'
  and wp.value.updated_at > TIMESTAMP('2023-02-15T00:00:00 UTC') 
;

```
*Use this query to find the player types for MiVideo content embedded on Canvas pages. Limit the terms and last updated date.*
```
SELECT DISTINCT et.value.name as term
  ,c.key.id as course_id
  ,wp.key.id as wiki_page_id
  ,wp.value.title as wiki_page_title
  ,wp.value.workflow_state as wiki_page_workflow_state
  ,wp.value.url as wiki_page_url
  ,wp.value.body as wiki_page_body
FROM udp-umich-prod.canvas.wiki_pages wp
JOIN udp-umich-prod.canvas.courses c on wp.value.context_id = c.key.id
JOIN udp-umich-prod.canvas.enrollment_terms et on c.value.enrollment_term_id = et.key.id
WHERE wp.value.body LIKE '%aakaf.mivideo.it.umich.edu%browseandembed%playerSkin%2F%'
  AND wp.value.context_type = 'Course'
  AND c.value.enrollment_term_id in (311,312)
  AND wp.value.workflow_state !='deleted'
  AND c.value.workflow_state !='deleted'
  --and wp.value.updated_at > TIMESTAMP('2023-02-15T00:00:00 UTC') 
  ;

```
*Use this query to find thumbnail embeds for MiVideo content embeded on Canvas pages.*
```
SELECT et.value.name as term
  ,wp.value.context_id as course_id
  ,wp.key.id as page_id
  ,wp.value.workflow_state as page_workflow_state
  ,wp.value.title as page_title
FROM udp-umich-prod.canvas.wiki_pages wp
JOIN udp-umich-prod.canvas.courses c on wp.value.context_id = c.key.id
JOIN udp-umich-prod.canvas.enrollment_terms et on c.value.enrollment_term_id = et.key.id
WHERE wp.value.body LIKE '%aakaf.mivideo.it.umich.edu%browseandembed%playerSkin%thumbEmbed%'
  AND wp.value.context_type = 'Course'
  AND c.value.enrollment_term_id in (313, 314, 315)
  AND wp.value.workflow_state !='deleted'
  AND c.value.workflow_state !='deleted'
  ORDER BY term, course_id 
;

```