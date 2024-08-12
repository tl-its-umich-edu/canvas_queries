## Generate log of deleted events for a Canvas course

A query to find out who made delete changes in a given course:

```
select 
course_offering.canvas_id as course_id,
event_time,
actor.id as actor_id,
actor.type as actor_type,
object.type,
object.name,
JSON_EXTRACT_SCALAR(object.extensions, '$[\'com.instructure.canvas\'][folder_id]') as object_folder_id,
JSON_EXTRACT_SCALAR(object.extensions, '$[\'com.instructure.canvas\'][entity_id]') as object_entity_id,
ed_app.id,
JSON_EXTRACT_SCALAR(extensions_json, '$[\'com.instructure.canvas\'][job_tag]') as job_id,
JSON_EXTRACT_SCALAR(extensions_json, '$[\'com.instructure.canvas\'][job_tag]') as job_tag,
from `udp-umich-prod.event_store.expanded`
where
action="Deleted"
and course_offering.canvas_id = '<course_canvas_id>'
and event_time >= 'YYYY-MM-DD'
order by 
course_offering.canvas_id,
event_time desc
```
