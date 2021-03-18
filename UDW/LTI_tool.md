## LTI tool installation query

Use the following query to find LTI tool installations in Canvas instance.

Replace the `<LTI Tool Name>` with the name of a LTI tool.

```
 select 
 etd."name" , 
 cd2.canvas_id as course_id, 
 cd2.name as course_name, 
 cd2.code as course_code, 
 cd2.publicly_visible, 
 cd2.workflow_state
 from course_dim cd2, enrollment_term_dim etd 
 where 
 cd2.enrollment_term_id = etd.id 
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
				 where name = '<LTI TOOL NAME>' and workflow_state ='active' and activation_target_type ='account'
			 )
		 ) and visible = 'visible'
	 )
 )
order by etd."name" desc
```
