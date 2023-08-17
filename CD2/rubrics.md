## get course rubrics

```
SELECT ra.value.association_type, 
ra.value.rubric_id, 
r.value.data, 
r.value.title, 
r.value.context_type, 
r.value.points_possible, 
r.value.workflow_state
FROM 
`udp-umich-sit.cd2_2023_06_16.rubric_associations` as ra, 
`udp-umich-sit.cd2_2023_06_16.rubrics` as r
where ra.value.context_type = 'Course'
--and ra.value.title like '%ASSIGNMENT TITLE%'
and ra.value.context_id =<COURSE_ID>
and ra.value.workflow_state='active'
and ra.value.rubric_id = r.key.id
order by r.value.title
```

## get student submissions and rubrics scores. Show only student id
```
SELECT r_assessment.value.user_id as submitter_id, 
r_assessment.value.assessor_id as grader_id,
s.key.id as submission_id,
r_assessment.value.assessment_type,
r_assessment.value.score,
r_assessment.value.rubric_id,
a.value.context_id as canvas_course_id,
a.key.id as assignment_id,
a.value.title as assignment_title,
s.value.workflow_state as submission_workflow_state,
a.value.workflow_state as assignment_workflow_state,
r_assessment.value.artifact_attempt,
r_assessment.value.data
from `udp-umich-sit.cd2_2023_06_16.rubric_assessments` r_assessment,
(
SELECT key.id as association_id, value.title
--, value.association_id as association_id, value.association_type
FROM `udp-umich-sit.cd2_2023_06_16.rubric_associations` 
where value.context_type = 'Course'
and value.title like '%ASSIGNMENT TITLE%'
and value.context_id =<COURSE_ID>
and value.workflow_state='active'
order by title) r_association,
`udp-umich-sit.cd2_2023_06_16.submissions` s
,`udp-umich-sit.cd2_2023_06_16.assignments` a
where r_assessment.value.rubric_association_id = 
r_association.association_id
and r_assessment.value.artifact_type='Submission'
and r_assessment.value.artifact_id = s.key.id
and s.value.assignment_id = a.key.id
and a.value.workflow_state='published'
order by r_assessment.value.rubric_id, r_assessment.value.user_id
```

## get student submissions and rubrics scores. Show both student id and student name
```
SELECT r_assessment.value.user_id as submitter_id, 
u.value.name as submitter_name,
r_assessment.value.assessor_id as grader_id,
s.key.id as submission_id,
r_assessment.value.assessment_type,
r_assessment.value.score,
r_assessment.value.rubric_id,
a.value.context_id as canvas_course_id,
a.key.id as assignment_id,
a.value.title as assignment_title,
s.value.workflow_state as submission_workflow_state,
a.value.workflow_state as assignment_workflow_state,
r_assessment.value.artifact_attempt,
r_assessment.value.data
from `udp-umich-sit.cd2_2023_06_16.rubric_assessments` r_assessment,
(
SELECT key.id as association_id, value.title
--, value.association_id as association_id, value.association_type
FROM `udp-umich-sit.cd2_2023_06_16.rubric_associations` 
where value.context_type = 'Course'
--and value.title like '%ASSIGNMENT TITLE%'
and value.context_id =<COURSE_ID>
and value.workflow_state='active'
order by title) r_association,
`udp-umich-sit.cd2_2023_06_16.submissions` s
,`udp-umich-sit.cd2_2023_06_16.assignments` a,
`udp-umich-sit.cd2_2023_06_16.users` u
where r_assessment.value.rubric_association_id = r_association.association_id
and r_assessment.value.artifact_type='Submission'
and r_assessment.value.artifact_id = s.key.id
and s.value.assignment_id = a.key.id
and a.value.workflow_state='published'
and r_assessment.value.user_id = u.key.id
order by r_assessment.value.rubric_id, r_assessment.value.user_id
```
