## assignment update events

A query for course assignment update events: 
```
select 
course_offering.canvas_id as course_id,
event_time,
actor.id as actor_id,
JSON_EXTRACT_SCALAR(actor.extensions, '$[\'com.instructure.canvas\'][user_login]') as actor_uniqname,
actor.type as actor_type,
object.type as object_type,
object.name as object_name,
object.id as object_id,
JSON_EXTRACT_SCALAR(object.extensions, '$[\'com.instructure.canvas\'][entity_id]') as object_entity_id,
ed_app.id as ed_app_id,
JSON_EXTRACT_SCALAR(extensions_json, '$[\'com.instructure.canvas\'][job_tag]') as job_id,
JSON_EXTRACT_SCALAR(extensions_json, '$[\'com.instructure.canvas\'][job_tag]') as job_tag,
from `udp-umich-prod.event_store.expanded`
where
action="Modified"
and course_offering.canvas_id = 'COURSE_ID'
and object.id like 'urn:instructure:canvas:assignment%ASSIGNMENT_ID'
and object.type='AssignableDigitalResource'
and event_time >= '2024-12-01'
order by event_time
```
