## list of courses uses Canvas's peer review assignment feature

```
select						
cd2."name" as course_name,
course_enrollments.num_students as #_students,
course_peer_assignment_count.peer_review_assignment_count as #_peer_review_assignments,			
concat('https://umich.instructure.com/courses/', cd2.canvas_id) as course_url,			
course_teachers.user_ids as teacher_uniqnames
from course_dim cd2,			
(			
	select			
	cd.id as course_id,			
	count(DISTINCT ed.user_id) as num_students			
	from course_dim cd, enrollment_dim ed, role_dim rd			
	where cd.id in			
	(			
		select ad.course_id			
		from assignment_dim ad			
		where ad.peer_reviews = true			
		and ad.workflow_state = 'published'			
		group by course_id			
	)			
	and ed.course_id = cd.id			
	and ed.role_id = rd.id			
	and rd.name='StudentEnrollment'			
	and (ed.workflow_state = 'active' or ed.workflow_state = 'complete')			
	and cd.enrollment_term_id = '17700000000000XXX'			
	group by cd."id"			
	order by count(DISTINCT ed.user_id) desc			
) course_enrollments,
(			
  select			
	cd.id as course_id,
	LISTAGG(pd.unique_name, ',') as user_ids			
	from course_dim cd, enrollment_dim ed, role_dim rd, pseudonym_dim pd 		
	where cd.id in			
	(			
		select ad.course_id			
		from assignment_dim ad			
		where ad.peer_reviews = true			
		and ad.workflow_state = 'published'			
		group by course_id			
	)			
	and ed.course_id = cd.id			
	and ed.role_id = rd.id			
	and rd.name='TeacherEnrollment'	
	and ed.user_id = pd.user_id 
	and (ed.workflow_state = 'active' or ed.workflow_state = 'complete')			
	and cd.enrollment_term_id = '17700000000000XXX'			
	group by cd."id"			
	order by count(DISTINCT ed.user_id) desc			
) course_teachers,
(			
select			
ad.course_id as course_id,			
count(*) as peer_review_assignment_count			
from assignment_dim ad			
where ad.peer_reviews = true			
and ad.workflow_state = 'published'			
group by course_id			
) course_peer_assignment_count			
where cd2.id = course_enrollments.course_id	
and cd2.id = course_teachers.course_id
and cd2.id = course_peer_assignment_count.course_id			
order by course_enrollments.num_students desc			
```
