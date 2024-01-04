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
FROM udp-umich-prod.canvas.enrollments as en
JOIN udp-umich-prod.canvas.pseudonyms ps on en.value.user_id = ps.value.user_id
JOIN udp-umich-prod.canvas.courses co on en.value.course_id = co.key.id
JOIN udp-umich-prod.canvas.users us on en.value.user_id = us.key.id
WHERE en.value.course_id = <COURSE_ID>
    AND en.value.type = 'StudentEnrollment'
ORDER BY us.value.name DESC
;
```