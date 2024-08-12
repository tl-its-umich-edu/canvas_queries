# MyLA queries for admin, communications, & reporting

## Find courses with MyLA in the Navigation menu

*This query is used to identify courses that have added MyLA to course navigation. Note: MyLA external tool ID is 28861*

```
SELECT co.value.enrollment_term_id
  ,co.key.id
  ,co.value.name
  ,co.value.course_code
  ,co.value.workflow_state
  ,co.value.tab_configuration
FROM udp-umich-prod.canvas.courses co
WHERE co.value.enrollment_term_id = <TERM_ID>
  AND co.value.workflow_state = 'available'
  AND (co.value.tab_configuration like '%context_external_tool_28861"}%'
      OR co.value.tab_configuration like '%context_external_tool_28861","hidden":null,"%')
;
```

## Find teachers on courses with MyLA in the Navigation Menu

*This query is used to find the names and uniqnames of teachers on MyLA courses for communications. Note: MyLA external tool ID is 28861*

```
SELECT DISTINCT ps.value.unique_id
    ,us.value.name as teacher_name
    ,en.value.type as role_type
    ,ro.value.name as role_name
    ,co.key.id as course_id
FROM udp-umich-prod.canvas.enrollments en
JOIN udp-umich-prod.canvas.pseudonyms ps on en.value.user_id = ps.value.user_id
JOIN udp-umich-prod.canvas.users us on en.value.user_id = us.key.id
JOIN udp-umich-prod.canvas.roles ro on en.value.role_id = ro.key.id
JOIN udp-umich-prod.canvas.courses co on en.value.course_id = co.key.id
WHERE co.key.id in  (
    SELECT co.key.id
    FROM udp-umich-prod.canvas.courses co
    WHERE co.value.enrollment_term_id = <TERM_ID>
        AND co.value.workflow_state != 'deleted'
        AND (co.value.tab_configuration like '%context_external_tool_28861"}%'
         OR co.value.tab_configuration like '%context_external_tool_28861","hidden":null,"%')
    )
AND en.value.type = 'TeacherEnrollment'
AND en.value.workflow_state = 'active'
ORDER BY co.key.id
;
```

## Find student enrollment count on courses with MyLA in the Navigation Menu

*This query is used to find the enrollment count for MyLA courses. Note: this will not include courses with no enrollments.*

```
SELECT co.key.id, co.value.name, ro.value.name
FROM udp-umich-prod.canvas.enrollments en
JOIN udp-umich-prod.canvas.pseudonyms ps on en.value.user_id = ps.value.user_id
JOIN udp-umich-prod.canvas.users us on en.value.user_id = us.key.id
JOIN udp-umich-prod.canvas.roles ro on en.value.role_id = ro.key.id
JOIN udp-umich-prod.canvas.courses co on en.value.course_id = co.key.id
WHERE co.key.id in  (
    SELECT co.key.id
    FROM udp-umich-prod.canvas.courses co
    WHERE co.value.enrollment_term_id = 311
        AND co.value.workflow_state = 'available'
        AND (co.value.tab_configuration like '%context_external_tool_28861"}%'
         OR co.value.tab_configuration like '%context_external_tool_28861","hidden":null,"%')
    )
AND en.value.type = 'StudentEnrollment'
AND en.value.workflow_state = 'active'
GROUP BY co.key.id, co.value.name, ro.value.name
;
```

## Find students on courses with MyLA in the Navigation Menu

*This query is used to find the names and uniqnames of students on MyLA courses for communications. Note: MyLA external tool ID is 28861*

```
SELECT DISTINCT ps.value.unique_id
    ,us.value.name as student_name
    ,en.value.type as role_type
    ,ro.value.name as role_name
    ,co.key.id as course_id
FROM udp-umich-prod.canvas.enrollments en
JOIN udp-umich-prod.canvas.pseudonyms ps on en.value.user_id = ps.value.user_id
JOIN udp-umich-prod.canvas.users us on en.value.user_id = us.key.id
JOIN udp-umich-prod.canvas.roles ro on en.value.role_id = ro.key.id
JOIN udp-umich-prod.canvas.courses co on en.value.course_id = co.key.id
WHERE co.key.id in  (
    SELECT co.key.id
    FROM udp-umich-prod.canvas.courses co
    WHERE co.value.enrollment_term_id = <TERM_ID>
        AND co.value.workflow_state != 'deleted'
        AND (co.value.tab_configuration like '%context_external_tool_28861"}%'
         OR co.value.tab_configuration like '%context_external_tool_28861","hidden":null,"%')
    )
AND en.value.type = 'StudentEnrollment'
AND en.value.workflow_state = 'active'
ORDER BY co.key.id
;
```