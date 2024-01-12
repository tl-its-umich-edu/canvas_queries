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

## Get enrolled courses and course instructors

*This query finds course courses with active enrollment for given students, and also returns instructor name and email list.

```
select courses.*
, mart_co.instructor_display
, mart_co.instructor_email_address_display
from
(
SELECT
    co.value.name as course_name
    ,en.value.type as enrollment_type
    ,en.value.workflow_state as enrollment_status
    ,co.key.id as Course_ID
    ,co.value.sis_source_id as SIS_course_ID
    ,acc.key.id as account_id
    ,acc.value.name as account_name
    ,et.key.id as term_id
    ,et.value.name as term_name
FROM udp-umich-prod.canvas.enrollments as en
JOIN udp-umich-prod.canvas.pseudonyms ps on en.value.user_id = ps.value.user_id
JOIN udp-umich-prod.canvas.courses co on en.value.course_id = co.key.id
JOIN udp-umich-prod.canvas.users us on en.value.user_id = us.key.id
JOIN udp-umich-prod.canvas.enrollment_terms as et on co.value.enrollment_term_id = et.key.id
JOIN udp-umich-prod.canvas.accounts as acc on co.value.account_id = acc.key.id
WHERE
en.value.type != 'StudentEnrollment'
and ps.value.unique_id='<student_login_id>'
and en.value.workflow_state != 'deleted'
) as courses,
`udp-umich-prod.mart_helper.context__course_offering__enrollment` as mart_co
where courses.Course_ID = cast(mart_co.lms_course_offering_id as INT64)
ORDER BY courses.term_id DESC, courses.course_name DESC;
```