# Find a peer review submitted by user id

* this query will find all peer reviews submitted by given user id

```
select 
ro.value.context_id as course_id,
ro.value.context_type as context_type,
ro.value.association_id as assignment_id,
ro.value.association_type as assignment_type,
a.value.title as assignment_title,
ro.value.rubric_id as rubric_id,
ra.value.user_id,
u.value.sortable_name,
ra.value.assessor_id,
ra.value.rubric_association_id,
ra.value.assessment_type,
ra.value.rubric_id,
ra.value.artifact_type,
--ra.value.artifact_id,
ra.value.created_at,
ra.value.updated_at,
ra.value.data
from `udp-umich-prod`.canvas.rubric_assessments ra, 
`udp-umich-prod`.canvas.rubric_associations ro,
`udp-umich-prod`.canvas.assignments a,
`udp-umich-prod`.canvas.users u
where  ra.value.assessor_id = <canvas_user_id>
and ra.value.rubric_association_id = ro.key.id
and a.key.id = ro.value.association_id
and u.key.id = ra.value.user_id
order by a.value.title, ra.value.rubric_id
```
