# MiVideo Queries

*This query is an attempt to find pages that have MiVideo content embedded for courss in a specified term and subaccount.  Use the option to for wp.value.body like '%resource_link_lookup_uuid%' for LTI 1.3 video embeds and use wp.value.body like '%aakaf.mivideo.it.umich.edu%' for LTI 1.1 video embeds*



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
WHERE co.value.enrollment_term_id = 312
  AND co.value.account_id = 52
  AND co.value.workflow_state !='deleted'
  AND wp.value.workflow_state != 'deleted'
  AND wp.value.context_type = 'Course'
--  AND wp.value.body like '%resource_link_lookup_uuid%'
--  AND wp.value.body like '%aakaf.mivideo.it.umich.edu%'
;
```