# Enrollments Queries

## Get enrollment dates for students in a specified course

*This query finds the dates enrollments were created and updated as well as enrollment status for students in the course.*

```
SELECT us.value.name as student_name
    ,ps.value.sis_user_id as SIS_user_id
    ,ps.value.unique_id as uniqname
    ,co.value.name as course_name
    ,co.key.id as Course_ID
    ,co.value.sis_source_id as SIS_course_ID
    ,en.value.workflow_state as enrollment_state
    ,en.value.created_at as enrollment_create_date
    ,en.value.updated_at as enrollment_update_date
    ,en.value.completed_at as enrollment_completion_cate
FROM udp-umich-prod.canvas.enrollments en
JOIN udp-umich-prod.canvas.pseudonyms ps on en.value.user_id = ps.value.user_id
JOIN udp-umich-prod.canvas.courses co on en.value.course_id = co.key.id
JOIN udp-umich-prod.canvas.users us on en.value.user_id = us.key.id
WHERE en.value.course_id = <COURSE_ID>
    AND en.value.type = 'StudentEnrollment'
ORDER BY us.value.name DESC
;
```

## Get uniqname and Canvas ID for students enrolled in a list of Canvas courses

*This query is used to get student enrollments in a given list of courses.*

```
SELECT DISTINCT co.key.id as course_id
    ,co.value.name as course_name
    ,ps.value.unique_id as uniqname
    ,en.value.user_id as Canvas_id
FROM udp-umich-prod.canvas.enrollments en
JOIN udp-umich-prod.canvas.pseudonyms ps on en.value.user_id = ps.value.user_id
JOIN udp-umich-prod.canvas.courses co on en.value.course_id = co.key.id
WHERE co.key.id in (<LIST OF COURSE_ID>)
    AND en.value.type = 'StudentEnrollment'
    AND en.value.workflow_state = 'active'
ORDER BY co.value.name
;
```

*This query is a variation of the above query; use this query if there are students who have no uniqname and don't exist in pseudonym_dim.*
```
SELECT DISTINCT us.key.id as canvas_user_id
    ,us.value.name
    ,us.value.sortable_name as sortable_name
    ,co.value.name as course_name
    ,co.key.id as course_id
    ,en.value.workflow_state as enrollment_status
FROM udp-umich-prod.canvas.enrollments en
JOIN udp-umich-prod.canvas.courses co on en.value.course_id = co.key.id
JOIN udp-umich-prod.canvas.users us on en.value.user_id = us.key.id
WHERE co.key.id in (<LIST OF COURSE_ID>)
    AND en.value.type = 'StudentEnrollment'
    AND en.value.workflow_state = 'active'
;
```

## Get list of students with their sections enrolled in a single Canvas course

*This query is used to get student enrollments with section information.*

```
SELECT DISTINCT ps.value.unique_id as uniqname
    ,ps.value.sis_user_id
    ,us.key.id as canvas_user_id
    ,co.value.name as course_name
    ,co.key.id as course_id
    ,cs.key.id as course_section_id
    ,cs.value.name as section_name
    ,en.value.workflow_state as status
FROM udp-umich-prod.canvas.enrollments en
JOIN udp-umich-prod.canvas.pseudonyms ps on en.value.user_id = ps.value.user_id
JOIN udp-umich-prod.canvas.courses co on en.value.course_id = co.key.id
JOIN udp-umich-prod.canvas.users us on ps.value.user_id = us.key.id
JOIN udp-umich-prod.canvas.course_sections cs on cs.value.course_id = co.key.id
WHERE en.value.course_id = <COURSE_ID>
    AND en.value.type = 'StudentEnrollment'
    AND en.value.workflow_state = 'active'
;
    