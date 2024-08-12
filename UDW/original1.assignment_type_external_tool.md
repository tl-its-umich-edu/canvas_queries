## assignment submission type with external tool

Use the following query to find Canvas courses with at least one assignment using certain LTI tool as "external tool" of submission type. Replace the `<LTI Tool Name>` with the name of a LTI tool.

```
select canvas_id as course_id, name as course_name
from course_dim where id IN
(
	select distinct course_id
	from assignment_fact
	where external_tool_id
	in (
		select id from external_tool_activation_dim etad
		where name = '<LTI Tool Name>' and workflow_state ='active' and activation_target_type ='account'
	)
)
```
