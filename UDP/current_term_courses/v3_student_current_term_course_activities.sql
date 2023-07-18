SELECT
 lar.person_id,
 la.course_offering_id,
 la.learner_activity_id,
 la.title AS assignment_title,
 CAST(DATETIME(TIMESTAMP(la.due_date), 'America/New_York') AS STRING FORMAT 'YYYY-MM-DD HH24:MI:SS') AS assignment_due_date,
 CASE
   WHEN lar.gradebook_status = 'true' AND lar.grading_status = 'graded' THEN lar.published_score
 ELSE
 NULL
END
 assignment_score,
 la.points_possible AS max_assignment_score,
 CASE
   WHEN lar.gradebook_status = 'true' AND lar.grading_status = 'graded' THEN lar.published_grade
 ELSE
 NULL
END
 assignment_grade,
 course_assignment_avg.avg_assignment_score,
 CASE
   WHEN a.is_hidden IS FALSE THEN a.body_value
 ELSE
 ''
END
 assignment_comment
FROM
 `udp-umich-prod.athletic_department_views`.v1_student_current_term_course vsctc
LEFT JOIN
 `udp-umich-prod.athletic_department_views`.v2_student_current_term_course_assignment_avg course_assignment_avg
ON
 vsctc.course_offering_id = course_assignment_avg.course_offering_id
LEFT JOIN
 `udp-umich-prod.context_store_entity.learner_activity` la
ON
 course_assignment_avg.learner_activity_id = la.learner_activity_id
LEFT JOIN
 `udp-umich-prod.context_store_entity.learner_activity_result` lar
ON
 vsctc.person_id = lar.person_id
 AND la.learner_activity_id = lar.learner_activity_id
LEFT JOIN
 `udp-umich-prod.context_store_entity.annotation` a
ON
 lar.learner_activity_result_id = a.learner_activity_result_id
WHERE
 la.status = 'published'