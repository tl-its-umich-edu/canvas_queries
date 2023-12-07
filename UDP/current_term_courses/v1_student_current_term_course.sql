WITH
 term_info AS (
 SELECT
   academic_term_id,
   name AS term_name
 FROM
   `udp-umich-prod.context_store_entity.academic_term` at2
 WHERE
   DATE(current_timestamp) < DATE_ADD(at2.term_end_date, INTERVAL 2 WEEK)
   AND DATE(current_timestamp) > at2.term_begin_date ),
 courses AS (
 SELECT
   co.course_offering_id,
   co.le_code AS canvas_course_title,
   co.available_credits AS credits,
   co.academic_term_id,
   term_name
 FROM
   `udp-umich-prod.context_store_entity.course_offering` co
 JOIN
   term_info at2
 ON
   co.academic_term_id = at2.academic_term_id
 WHERE
   co.le_status = 'available'),
 sections AS (
 SELECT
   cs.course_section_id,
   cs2.lms_ext_id AS canvas_section_id,
   cs.le_current_course_offering_id AS course_offering_id,
   co4.lms_ext_id AS canvas_course_id,
   cs.le_name AS section_name,
   cs.section_number AS section
 FROM
   `udp-umich-prod.context_store_entity.course_section` cs
 JOIN
   `udp-umich-prod.context_store_keymap.course_section` cs2
 ON
   cs.course_section_id = cs2.id
 JOIN
   `udp-umich-prod.context_store_keymap.course_offering` co4
 ON
   co4.id = cs.le_current_course_offering_id
   AND cs.status='active'),
 courses_sections_of_current_term AS (
 SELECT
   c.canvas_course_title,
   c.term_name,
   s.*,
   c.academic_term_id,
   c.credits
 FROM
   courses c
 JOIN
   sections s
 ON
   c.course_offering_id=s.course_offering_id
),
courses_enrollment AS (
SELECT 
  csct.*,
  cse.person_id, 
  p.name AS person_name, 
  case when p.first_name is null then REGEXP_EXTRACT(p.name, r'^\w+(?:-\w+)?') else p.first_name
  end first_name,
  case when p.last_name is null then REGEXP_EXTRACT(p.name, r'\w+(?:-\w+)?$') else p.last_name
  end last_name,
  REPLACE (LOWER(pe.email_address), '@umich.edu', '') AS uniqname 
FROM 
  courses_sections_of_current_term csct 
JOIN 
  `udp-umich-prod.context_store_entity.course_section_enrollment` cse on cse.course_section_id = csct.course_section_id
JOIN 
  `udp-umich-prod.context_store_entity.person` p on cse.person_id = p.person_id
JOIN 
  `udp-umich-prod.context_store_entity.person_email` pe on pe.person_id = p.person_id
WHERE 
  cse.role = 'Student'
  AND cse.role_status = 'Enrolled' 
  AND cse.enrollment_status = 'Active' 
),
course_grades AS (
 SELECT
   ce.*,
   cg.le_current_score AS current_grade,
   cg.le_final_score AS final_grade,
   cg.gpa_cumulative_excluding_course_grade AS cumulative_gpa
 FROM
   `udp-umich-prod.context_store_entity.course_grade` cg
 JOIN
   courses_enrollment ce
 ON
   ce.course_section_id = cg.course_section_id
   AND ce.person_id = cg.person_id),
 aca_prog_major AS (
 SELECT
   am.academic_program_id,
   am.description AS academic_major,
   ap.description AS academic_program,
   ap.educational_level,
   am.academic_major_id
 FROM
   `udp-umich-prod.context_store_entity.academic_major` am
 JOIN
   `udp-umich-prod.context_store_entity.academic_program` ap
 ON
   ap.academic_program_id = am.academic_program_id),
 average_course_grade as (
  select 
    canvas_course_id, 
    round(AVG(current_grade),2) as avg_course_grade 
  from (
    select 
      distinct uniqname, 
      canvas_course_id,
      current_grade 
    from course_grades
    ) as course_unique_student_avg_grade 
    group by canvas_course_id
    ),
 courses_grade_average as (
  select 
    cg.*, 
    acg.avg_course_grade  
  from 
    average_course_grade acg 
  join 
    course_grades cg 
  on 
    cg.canvas_course_id  = acg.canvas_course_id),
 person_term_major_academic AS (
 SELECT
   pamat.academic_major_id,
   pat.athletic_participant_sport,
   pat.cen_academic_level,
   pat.gpa_credits_units_hours,
   pamat.person_id,
   pat.academic_term_id
 FROM
   `udp-umich-prod.context_store_entity.person__academic_term` pat
 JOIN
   `udp-umich-prod.context_store_entity.person__academic_major__academic_term` pamat
 ON
   pamat.person_id = pat .person_id
   AND pat.academic_term_id = pamat.academic_term_id
   AND pat.eot_academic_load LIKE '%Time'),
 person_full_academic_term_major AS (
 SELECT
   *
 FROM
   aca_prog_major a
 JOIN
   person_term_major_academic b
 ON
   a.academic_major_id = b.academic_major_id ),
 courses_enrollment_major AS (
 SELECT
   a.*,
   b.academic_major,
   b.academic_program,
   b.educational_level,
   b.athletic_participant_sport,
   b.cen_academic_level,
   b.gpa_credits_units_hours
 FROM
   courses_grade_average a
 JOIN
   person_full_academic_term_major b
 ON
   a.person_id = b.person_id
   AND a.academic_term_id = b.academic_term_id)
SELECT
 canvas_course_id,
 canvas_course_title,
 course_offering_id,
 section,
 section_name,
 credits,
 gpa_credits_units_hours,
 cumulative_gpa,
 current_grade,
 final_grade,
 avg_course_grade,
 uniqname,
 person_name,
 first_name,
 last_name,
 person_id,
 cen_academic_level,
 academic_major,
 academic_program,
 athletic_participant_sport,
 educational_level,
 term_name,
 course_section_id,
 canvas_section_id
FROM
 courses_enrollment_major