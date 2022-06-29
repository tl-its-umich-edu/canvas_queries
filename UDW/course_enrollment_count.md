## Course Enrollment Count query

Use the following query to count of student enrollment for given term courses, order by course id and course name.

Replace the `<term_name>` with the name of specific acdemic term, e.g. 'Fall 2021', 'Winter 2022'

```
 select 
 cd2.canvas_id as course_id,
 cd2.name as course_name,
 count(distinct ud.id) as #_students
 from course_dim cd2, enrollment_term_dim etd, 
 account_dim ad, enrollment_dim ed, course_section_dim csd, role_dim rd, pseudonym_dim pd, user_dim ud 
 where 
 cd2.enrollment_term_id = etd.id 
 and cd2.id = ed.course_id 
 and cd2.account_id = ad.id
 and pd.workflow_state != 'deleted'
 and ed.course_section_id = csd.id
 and ed.role_id = rd.id
 and (ed.workflow_state = 'active' or ed.workflow_state = 'completed' or ed.workflow_state = 'invited')
 and rd.name = 'StudentEnrollment'
 and ed.user_id = pd.user_id 
 and pd.user_id = ud.id 
 and etd."name" = '<term_name>'
 and ud.sortable_name !='Student, Test'
group by cd2.canvas_id, cd2."name"
order by cd2.canvas_id, cd2."name"
```
