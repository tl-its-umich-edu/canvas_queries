DROP MATERIALIZED view v2_student_current_term_course_assignment_avg;

create materialized view v2_student_current_term_course_assignment_avg as
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
 lar.learner_activity_id,
 ROUND(AVG(lar.published_score),2) AS avg_assignment_score
FROM
 umich_materialized_views.v1_student_current_term_course vsctc
LEFT JOIN
 `udp-umich-prod.context_store_entity.learner_activity` la
ON
 vsctc.course_offering_id = la.course_offering_id
LEFT JOIN
 lar AS lar
ON
 la.learner_activity_id = lar.learner_activity_id
LEFT JOIN
 `udp-umich-prod.context_store_entity.annotation` a
ON
 a.learner_activity_result_id = lar.learner_activity_result_id
WHERE
 la.status = 'published'
GROUP BY
 la.course_offering_id,
 lar.learner_activity_id
with data
