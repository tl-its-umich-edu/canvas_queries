# Gradebook Queries

## Get current and final scores for students in a course.  
*Note that the query will return multiple rows for students when the student is enrolled in more than one section in the course.*
```
WITH enroll as
    (SELECT DISTINCT en.value.user_id as canvas_user_id
      ,en.key.id as enrollment_id
      ,en.value.course_id as course_id
      ,en.value.course_section_id as section_id
    FROM udp-umich-prod.canvas.enrollments en
    WHERE en.value.course_id = <COURSE_ID>
      AND en.value.type = 'StudentEnrollment'
      AND en.value.workflow_state = 'active')
  ,students as
    (SELECT ps.value.unique_id as uniqname
      ,e.*
      FROM udp-umich-prod.canvas.pseudonyms ps
      JOIN enroll e on e.canvas_user_id = ps.value.user_id
    )
SELECT st.course_id as Canvas_course_id
  ,st.uniqname
  ,sc.value.current_score
  ,sc.value.final_score
FROM udp-umich-prod.canvas.scores sc
JOIN students st on sc.value.enrollment_id = st.enrollment_id
WHERE value.course_score = true
;

```
