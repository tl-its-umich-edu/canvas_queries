## queries used to create student success report for Athletic department

- the materialized view for courses in certain term 
```
DROP MATERIALIZED view v1_student_current_term_course;
create materialized view v1_student_current_term_course as
with
term_info as (select academic_term_id , name as term_name from entity.academic_term at2 where  current_timestamp < at2.term_end_date  
and current_timestamp > at2.term_begin_date ),
courses as 
(select co.course_offering_id, co.le_code as canvas_course_title, co.available_credits as credits, co.academic_term_id, term_name
from entity.course_offering co join term_info at2 on co.academic_term_id = at2.academic_term_id where co.le_status = 'available'),

sections as 
(select cs.course_section_id , cs2.lms_ext_id as canvas_section_id, cs.le_current_course_offering_id as course_offering_id, co4.lms_ext_id as "Canvas_Course_ID", cs.le_name as section_name, cs.section_number as "Section"
from entity.course_section cs join keymap.course_section cs2 on cs.course_section_id = cs2.id join keymap.course_offering co4 on co4.id = cs.le_current_course_offering_id and cs.status='active'),
courses_sections_of_current_term as (select c.canvas_course_title, c.term_name, s.*, c.academic_term_id, c.credits from courses c join sections s on c.course_offering_id=s.course_offering_id),

enrollment as 
(select cse.course_section_id, cse.person_id, REPLACE (lower(pe.email_address), '@umich.edu', '') as uniqname, p."name" as person_name from entity.course_section_enrollment cse join entity.person_email pe 
on pe.person_id = cse.person_id join entity.person p on p.person_id = cse.person_id where cse."role"='Student' and cse.role_status = 'Enrolled' and cse.enrollment_status = 'Active'),
courses_enrollment as (select cst.*, e.person_id, e.uniqname, e.person_name from courses_sections_of_current_term cst join enrollment e on e.course_section_id = cst.course_section_id),
course_grades as (select ce.*, cg.le_current_score as "Current_Grade", cg.le_final_score as "Final_Grade", cg.gpa_cumulative_excluding_course_grade as cumulative_gpa from entity.course_grade cg join courses_enrollment ce on ce.course_section_id = cg.course_section_id and ce.person_id = cg.person_id),

average_course_grade as (select "Canvas_Course_ID", round(AVG("Current_Grade"),2) as avg_course_grade from (select distinct uniqname, "Canvas_Course_ID", "Current_Grade" from course_grades) as course_unique_student_avg_grade group by "Canvas_Course_ID"),
courses_grade_average as (select cg.*, acg.avg_course_grade  from average_course_grade acg join course_grades cg on cg."Canvas_Course_ID"  = acg."Canvas_Course_ID"),

aca_prog_major as (select am.academic_program_id, am.description as academic_major, ap.description as academic_program, ap.educational_level, am.academic_major_id 
from entity.academic_major am join entity.academic_program ap on ap.academic_program_id = am.academic_program_id),
person_term_major_academic as (select pamat.academic_major_id, pat.athletic_participant_sport, pat.cen_academic_level , pat.gpa_credits_units_hours, pamat.person_id, pat.academic_term_id  
from entity.person__academic_term pat join entity.person__academic_major__academic_term pamat 
on pamat.person_id = pat .person_id and pat.academic_term_id = pamat.academic_term_id and pat.eot_academic_load like '%Time'),

person_full_academic_term_major as (select * from aca_prog_major a join person_term_major_academic b on a.academic_major_id = b.academic_major_id ),

courses_enrollment_major as (select a.*, b.academic_major, b.academic_program,b.educational_level, b.athletic_participant_sport, b.cen_academic_level, b.gpa_credits_units_hours  
from courses_grade_average a join person_full_academic_term_major b on a.person_id = b.person_id and a.academic_term_id = b.academic_term_id)

select "Canvas_Course_ID", canvas_course_title, course_offering_id, "Section", section_name, credits, gpa_credits_units_hours, cumulative_gpa, 
"Current_Grade", "Final_Grade", avg_course_grade,  Uniqname, person_name, person_id, cen_academic_level, academic_major, academic_program,  athletic_participant_sport
, educational_level, term_name, course_section_id, canvas_section_id from courses_enrollment_major 
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
where la.status = 'published'
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
TO_CHAR(la.due_date at time zone 'UTC' at time zone 'EST', 'YYYY-MM-DD HH24:MI:SS')  as assignment_due_date,
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
where la.status = 'published'
with data
```

## view refresh queries for the daily cron job
```
REFRESH MATERIALIZED view v1_student_current_term_course;
REFRESH MATERIALIZED view v2_student_current_term_course_assignment_avg;
REFRESH MATERIALIZED view v3_student_current_term_course_activities;
```

## Auto-Refreshed Materialized Views
Details are here: https://resources.unizin.org/display/UDP/UDP+Context+store

## Athletic student google sheet roster
Athletic dept provides all the student enrolled to their program in current term via a google sheet. We have an additional step 
in making this data available to Tableau dashboard as table called `student_athletic_export`. We created this table since Tableau
has some issues connecting to google sheets.
Every term this table (student_athletic_export) need to updated with latest data. This table resides in the context store with user account provisioned for the project
Steps to update the table
1. create a CSV File from the current term student roster
2. Open the SQL editor from you SQL client and run `delete from student_athlete_export ` to delete all the rows
3. Right click on the `student_athletic_export` table import CSV (from step 1)
4. Verify it has latest info.
