# Discussions Queries

*This query is used to find discussions in courses by subaccount and term for selected terms.*

```
SELECT dt.value.type as content_type
    ,dt.value.discussion_type as discussion_type
    ,dt.value.title as discussion_title
    ,dt.value.assignment_id as assignment_id
    ,dt.value.is_section_specific as section_specific
    ,dt.value.context_id as course_id
    ,co.value.name as course_name
    ,co.value.account_id as subaccount_id
    ,ac.value.name as subaccount_name
    ,co.value.enrollment_term_id as term_id
    ,et.value.name as term
FROM udp-umich-prod.canvas.discussion_topics dt
    JOIN udp-umich-prod.canvas.courses co on dt.value.context_id = co.key.id
    JOIN udp-umich-prod.canvas.accounts ac on co.value.account_id = ac.key.id
    JOIN udp-umich-prod.canvas.enrollment_terms et on co.value.enrollment_term_id = et.key.id
WHERE dt.value.workflow_state !='deleted'
    AND dt.value.context_type = 'Course'
    AND co.value.workflow_state !='deleted'
    AND et.key.id in (<LIST OF TERMS>)
;
```

*This query is used to find discussions in courses by subaccount and term for selected terms along with teachers for those courses.*

```
SELECT dt.value.type as content_type
    ,dt.value.discussion_type as discussion_type
    ,dt.value.title as discussion_title
    ,dt.value.assignment_id as assignment_id
    ,dt.value.is_section_specific as section_specific
    ,dt.value.context_id as course_id
    ,co.value.name as course_name
    ,co.value.account_id as subaccount_id
    ,ac.value.name as subaccount_name
    ,co.value.enrollment_term_id as term_id
    ,et.value.name as term
FROM udp-umich-prod.canvas.discussion_topics dt
    JOIN udp-umich-prod.canvas.courses co on dt.value.context_id = co.key.id
    JOIN udp-umich-prod.canvas.accounts ac on co.value.account_id = ac.key.id
    JOIN udp-umich-prod.canvas.enrollment_terms et on co.value.enrollment_term_id = et.key.id
WHERE dt.value.workflow_state !='deleted'
    AND dt.value.context_type = 'Course'
    AND co.value.workflow_state !='deleted'
    AND et.key.id in (<LIST OF TERMS>)
;
```