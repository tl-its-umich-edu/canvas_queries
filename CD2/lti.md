## LTI tool usage report

This query finds courses where the given LTI tool (given tool name) is enabled in the course navigation. The query also returns the instructor name and email lists.

```
SELECT 
  co.value.name as course_name
  ,co.key.id as Course_ID
  ,co.value.sis_source_id as SIS_course_ID
  ,acc.key.id as account_id
  ,acc.value.name as account_name
  ,et.key.id as term_id
  ,et.value.name as term_name
  , mart_co.instructor_display
  , mart_co.instructor_email_address_display
FROM 
  udp-umich-prod.canvas.courses co, 
  (
    select concat('context_external_tool_', cet.key.id) as external_tool_id
    from udp-umich-prod.canvas.context_external_tools cet
    where 
    lower(cet.value.name) = '<LTI tool name in lower case>'
    -- lower(name) like '%search_string%' 
    -- workflow_state values: public, anonymous, deleted, name_only, email_only, disabled
    and cet.value.workflow_state ='public'
    ) lti,
  udp-umich-prod.canvas.enrollment_terms as et,
  udp-umich-prod.canvas.accounts as acc,
  `udp-umich-prod.mart_helper.context__course_offering__enrollment` as mart_co
WHERE 
  co.value.workflow_state = 'available'
  AND co.value.enrollment_term_id = et.key.id
  AND co.value.account_id = acc.key.id
  AND (co.value.tab_configuration like concat(concat('%', lti.external_tool_id), '","hidden":null,"%')
  OR co.value.tab_configuration like concat(concat('%', lti.external_tool_id), '"}%'))
  AND co.key.id = cast(mart_co.lms_course_offering_id as INT64)
ORDER BY co.value.enrollment_term_id DESC, co.value.name DESC;
```

This query finds courses within given term where the given LTI tool (given tool id) is enabled in the course navigation. The query also returns the instructor name and email lists.
```
SELECT 
  co.value.name as course_name
  ,co.key.id as Course_ID
  ,co.value.sis_source_id as SIS_course_ID
  ,acc.key.id as account_id
  ,acc.value.name as account_name
  ,et.key.id as term_id
  ,et.value.name as term_name
  , mart_co.instructor_display
  , mart_co.instructor_email_address_display
FROM 
  udp-umich-prod.canvas.courses co, 
  (
    select concat('context_external_tool_', cet.key.id) as external_tool_id
    from udp-umich-prod.canvas.context_external_tools cet
    where 
    cet.key.id= <canvas_tool_id>
    and cet.value.workflow_state ='public'
    ) lti,
  udp-umich-prod.canvas.enrollment_terms as et,
  udp-umich-prod.canvas.accounts as acc,
  `udp-umich-prod.mart_helper.context__course_offering__enrollment` as mart_co
WHERE 
  co.value.workflow_state = 'available'
  AND co.value.enrollment_term_id = et.key.id
  AND co.value.account_id = acc.key.id
  AND (co.value.tab_configuration like concat(concat('%', lti.external_tool_id), '","hidden":null,"%')
  OR co.value.tab_configuration like concat(concat('%', lti.external_tool_id), '"}%'))
  AND co.key.id = cast(mart_co.lms_course_offering_id as INT64)
  AND et.value.name='Winter 2025'
ORDER BY co.value.enrollment_term_id DESC, co.value.name DESC;
```

This query finds users given roles inside given term Canvas courses with a LTI tool enabled
```
SELECT DISTINCT co.key.id as course_canvas_id
    ,co.value.name as course_name
    ,ps.value.unique_id as uniqname
    ,us.value.sortable_name as sortable_name
    ,en.value.user_id as user_canvas_id
FROM udp-umich-prod.canvas.enrollments en
JOIN udp-umich-prod.canvas.pseudonyms ps on en.value.user_id = ps.value.user_id
JOIN udp-umich-prod.canvas.users us on en.value.user_id = us.key.id
JOIN udp-umich-prod.canvas.courses co on en.value.course_id = co.key.id
JOIN udp-umich-prod.canvas.enrollment_terms t on co.value.enrollment_term_id = t.key.id
JOIN  (
    select concat('context_external_tool_', cet.key.id) as external_tool_id
    from udp-umich-prod.canvas.context_external_tools cet
    where 
    cet.key.id= <lti_tool_id>
    and cet.value.workflow_state ='public'
    ) lti   on (co.value.tab_configuration like concat(concat('%', lti.external_tool_id), '","hidden":null,"%')
  OR co.value.tab_configuration like concat(concat('%', lti.external_tool_id), '"}%'))
WHERE t.value.name = '<term_id>'
    AND en.value.role_id = <role_id>
    AND co.value.workflow_state = 'available'
    AND en.value.workflow_state = 'active'
ORDER BY co.value.name, us.value.sortable_name
;
```
