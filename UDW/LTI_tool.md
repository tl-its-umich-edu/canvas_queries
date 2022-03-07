## LTI tool installation query

Use the following query to find LTI tool installations (course and instructors) in Canvas instance.

Replace the `<LTI Tool Name>` with the name of a LTI tool.

```
 select 
 etd.canvas_id as term_id,
 etd."name" as term_name,
 ad.canvas_id as account_id,
 ad."name" as account_name,
 cd2.canvas_id as course_id, 
 cd2.name as course_name,
 cd2.workflow_state as course_workflow_status,
 csd."name" as section_name,
 pd.unique_name as teacher_uniqname,
 ud."name" as teacher_name
 from course_dim cd2, enrollment_term_dim etd, account_dim ad, enrollment_dim ed, course_section_dim csd, role_dim rd, pseudonym_dim pd, user_dim ud 
 where 
 cd2.enrollment_term_id = etd.id 
 and cd2.id = ed.course_id 
 and cd2.account_id = ad.id
 and pd.workflow_state != 'deleted'
 and ed.course_section_id = csd.id
 and ed.role_id = rd.id
 and (ed.workflow_state = 'active' or ed.workflow_state = 'completed' or ed.workflow_state = 'invited')
 and rd.name = 'TeacherEnrollment'
 and ed.user_id = pd.user_id 
 and pd.user_id = ud.id 
 and cd2.id in
 (
 	select course_id
 	from course_ui_navigation_item_fact
 	where course_ui_navigation_item_id
 	in
 	(
		 select id
		 from course_ui_navigation_item_dim cd
		 where id in
		 (
			 select course_ui_navigation_item_id
			 from course_ui_navigation_item_fact cunif
			 where external_tool_activation_id
			 in (
				 select id from external_tool_activation_dim etad
				 where 
				 lower(name) = '<LTI Tool Name>' 
				 -- use the following to match search string
				 -- lower(name) like '%search_string%' 
				 and workflow_state ='active' 
				 -- use the following to look for account-level LTI tools
				 -- and activation_target_type ='account' 
				 -- sometimes there are multiple LTI tools with same name; 
				 -- add url value as another filter field
				 -- and url = '<tool_launch_url>'
			 )
		 ) and visible = 'visible'
	 )
 )
order by etd.canvas_id desc, cd2.canvas_id ASC, ud."name" ASC 
```

## get list of courses (course name, course id, term) with the LTI tool installed
```
select name, canvas_id, enrollment_term_id 
from course_dim cd 
where cd.id in 
(
select course_id
 	from course_ui_navigation_item_fact
 	where course_ui_navigation_item_id
 	in
 	(
		 select id
		 from course_ui_navigation_item_dim cd
		 where id in
		 (
			 select course_ui_navigation_item_id
			 from course_ui_navigation_item_fact cunif
			 where external_tool_activation_id
			 in (
				 select id
				 from external_tool_activation_dim etad
				 where 
				 lower(name) = '<LTI Tool Name>' 
				 -- use the following to match search string
				 -- lower(name) like '%search_string%' 
				 and workflow_state ='active' 
				 -- use the following to look for account-level LTI tools
				 -- and activation_target_type ='account'
				 -- sometimes there are multiple LTI tools with same name; 
				 -- add url value as another filter field
				 and url = '<tool_launch_url>'
			 )
		 ) and visible = 'visible'
	 )
 )
 and (cd.enrollment_term_id = '<term_id>' or cd.enrollment_term_id ='<term_id>')
 order by cd.enrollment_term_id, name asc
```
