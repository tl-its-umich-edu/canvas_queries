WITH
 lar AS (
 SELECT
   lar.learner_activity_id,
   lar.learner_activity_result_id,
   lar.published_score
 FROM
   `udp-umich-prod.context_store_entity.learner_activity_result` AS lar
 WHERE
   lar.gradebook_status = 'true'
   AND lar.grading_status = 'graded' )
SELECT
 la.course_offering_id,
 la.learner_activity_id,
 ROUND(AVG(lar.published_score),2) AS avg_assignment_score
FROM
 `udp-umich-prod.athletic_department_views`.v1_student_current_term_course vsctc
LEFT JOIN
 `udp-umich-prod.context_store_entity.learner_activity` la
ON
 vsctc.course_offering_id = la.course_offering_id
LEFT JOIN
 lar AS lar
ON
 la.learner_activity_id = lar.learner_activity_id
WHERE
 la.status = 'published'
GROUP BY
 la.course_offering_id,
 la.learner_activity_id