## queries used to create student success report for Athletic department

- the materialized view for courses in certain term 
```
DROP MATERIALIZED view v1_student_current_term_course;
create materialized view v1_student_current_term_course as
 select
	co2.lms_ext_id as "Canvas_Course_ID",
	co.le_code as canvas_course_title,
	co.course_offering_id as course_offering_id,
	cs.section_number as "Section",
	co.available_credits as Credits,
    pat.gpa_credits_units_hours,
	cg2.gpa_cumulative_excluding_course_grade as cumulative_gpa,
	-- regexp_replace(co.syllabus_content,'\s*(<[^>]+>|<script.+?<\/script>|<style.+?<\/style>)\s*','','gi') as syllabus, 
	--regexp_replace(co.syllabus_content, '\s*(<[^>]+>|<script.+?<\/script>|<style.+?<\/style>)\s*','','gi') as syllabus,
	cg.le_current_score as "Current_Grade", 
	cg.le_final_score as "Final_Grade",
    REPLACE (lower(pe.email_address), '@umich.edu', '') as Uniqname,
    pe.person_id as person_id,
    pat.cen_academic_level, 
    am.academic_program_id, 
    am.description as academic_major,
    pat.athletic_participant_sport, 
	ap.description as academic_program,
	ap.educational_level
from 
entity.person_email pe, 
entity.course_section_enrollment cse,
entity.course_section cs,
entity.course_offering co,
entity.academic_term at2,
entity.course_grade cg,
keymap.course_offering co2,
entity.course_grade cg2,
entity.person__academic_term pat, 
entity.person__academic_major__academic_term pamat,
entity.academic_major am,
entity.academic_program ap
where 
pe.person_id = cse.person_id
and cse.role_status = 'Enrolled'
and cse."role" = 'Student'
and cs.course_section_id = cse.course_section_id
and co.course_offering_id = cs.course_offering_id
and co.academic_term_id = at2.academic_term_id 
and cg.course_section_id = cs.course_section_id
and cg.person_id = cse.person_id
and co.le_status = 'available'
and co2.id = co.course_offering_id
and cg2.course_section_id = cs.course_section_id 
and cg2.person_id = pe.person_id
and pat.academic_term_id = at2.academic_term_id
and at2.academic_term_id = pamat.academic_term_id
and pe.person_id = pat.person_id 
and pat.person_id = pamat.person_id 
and pamat.academic_major_id = am.academic_major_id
and am.academic_program_id = ap.academic_program_id
-- get current term data
and current_timestamp < at2.term_end_date
and current_timestamp > at2.term_begin_date 
order by pe.person_id 
with data
```

- the materialized view for student assignment averages, used to enhance the the performance of following view 'student_current_term_course_activities'
```
DROP MATERIALIZED view v2_student_current_term_course_assignment_avg;
create materialized view v2_student_current_term_course_assignment_avg
as
select 
la.course_offering_id, 
lar.learner_activity_id, 
(avg(lar.published_score) FILTER (WHERE lar.gradebook_status = 'true' and lar.grading_status = 'graded') ::NUMERIC(10,2) ) as avg_assignment_score
from
v1_student_current_term_course vsctc 
left join entity.learner_activity la on vsctc.course_offering_id = la.course_offering_id 
left join entity.learner_activity_result lar on la.learner_activity_id = lar.learner_activity_id 
left join entity.annotation a on a.learner_activity_result_id = lar.learner_activity_result_id
group by la.course_offering_id, lar.learner_activity_id
with data
```

- the materialized view for student learning activities in course
```
DROP MATERIALIZED view v3_student_current_term_course_activities;
create materialized view v3_student_current_term_course_activities 
as
select lar.person_id,  
la.course_offering_id, 
la.learner_activity_id,
la.title as assignment_title,
TO_CHAR(la.due_date :: DATE, 'YYYY-MM-DD hh:mm:ss TZ') as assignment_due_date,
CASE
   WHEN lar.gradebook_status = 'true' and lar.grading_status = 'graded' THEN lar.published_score
   ELSE null
END assignment_score,
la.points_possible as max_assignment_score,
CASE
   WHEN lar.gradebook_status = 'true' and lar.grading_status = 'graded' THEN lar.published_grade
   ELSE null
END assignment_grade,
course_assignment_avg.avg_assignment_score,
CASE
   WHEN a.is_hidden is false THEN a.body_value
   ELSE ''
END assignment_comment
from
	v1_student_current_term_course vsctc 
	left join v2_student_current_term_course_assignment_avg course_assignment_avg on vsctc.course_offering_id = course_assignment_avg.course_offering_id 
	left join entity.learner_activity la on course_assignment_avg.learner_activity_id = la.learner_activity_id 
	left join entity.learner_activity_result lar on vsctc.person_id = lar.person_id and la.learner_activity_id  = lar.learner_activity_id 
	left join entity.annotation a on lar.learner_activity_result_id  = a.learner_activity_result_id 
with data
```

## view refresh queries for the daily cron job
```
REFRESH MATERIALIZED view v1_student_current_term_course;
REFRESH MATERIALIZED view v2_student_current_term_course_assignment_avg;
REFRESH MATERIALIZED view v3_student_current_term_course_activities;
```
