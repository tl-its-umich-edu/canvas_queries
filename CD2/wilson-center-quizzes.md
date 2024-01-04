#Wilson Center Training course queries

##Get training quiz data for weekly report to Wilson Center

*This query pulls quiz submissions and scores for the 3 required training quizzes on the Wilson Center Training Canvas course. Change the date to run the report each week.*

SELECT ad.value.title as assignment_title
    ,ps.value.sis_user_id as UMID
    ,ps.value.unique_id as uniqname
    ,us.value.sortable_name as fullname
    ,su.value.graded_at as graded_date
    ,ad.value.points_possible
    ,su.value.published_grade
FROM udp-umich-prod.canvas.assignments as ad
    ,udp-umich-prod.canvas.submissions as su
    ,udp-umich-prod.canvas.pseudonyms as ps
    ,udp-umich-prod.canvas.users as us
WHERE su.value.assignment_id = ad.key.id
    AND su.value.user_id = ps.value.user_id
    AND su.value.user_id = us.key.id
    AND ad.value.context_id = 428325
    AND su.value.graded_at > TIMESTAMP('2023-12-20T00:00:00 UTC')
    AND ad.key.id in (1171099, 1171096, 1349408)
ORDER BY su.value.graded_at desc
;

##Get enrollment dates for students in Wilson Center course

*This query finds the dates that individual students enrolled in the course.*

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
WHERE en.value.course_id = 428325
    AND en.value.type = 'StudentEnrollment'
ORDER BY us.value.name DESC
;

