# LinkedIn Learning videos can be embedded in wiki pages, or used as 'External Tool' submission type for assignment.

## 1. Find course wiki pages with Linkedin Learning URLs:

```
select 
et.value.name as term_name,
co.key.id as course_id,
co.value.name as course_name,
wp.value.title as wiki_page_title,
wp.value.url as wiki_page_url,
wp.value.wiki_id as wiki_page
from 
`udp-umich-prod.canvas.wiki_pages` as wp,
`udp-umich-prod.canvas.courses` co,
`udp-umich-prod.canvas.enrollment_terms` et
where 
wp.value.body like '%https://www.linkedin.com/learning/%'
and wp.value.workflow_state = 'active'
and wp.value.context_id = co.key.id
and co.value.enrollment_term_id = et.key.id
order by et.key.id desc, co.value.name asc;
```

## 2. Find course assignments use Linkedin Learning as 'External Tool' submission type:
```
select 
terms.value.name as term_name,
co.key.id as course_id,
et.value.context_id as assignment_id,
assg.value.title as assignment_title,
et.value.content_type as content_type,
cet.value.name as external_tool_name,
et.value.context_id as assignment_id
from
`udp-umich-prod.canvas.content_tags` et
,`udp-umich-prod.canvas.assignments` as assg,
`udp-umich-prod.canvas.context_external_tools` as cet,
`udp-umich-prod.canvas.courses` co,
`udp-umich-prod.canvas.enrollment_terms` terms
where
et.value.context_type = 'Assignment'
AND et.value.workflow_state = 'active'
AND et.value.content_id IS NOT NULL 
and et.value.context_id = assg.key.id
and cet.key.id = et.value.content_id
and cet.value.name = 'Linkedin Learning'
and co.key.id = assg.value.context_id
and co.value.enrollment_term_id = terms.key.id
order by terms.key.id desc, co.value.name asc;
```