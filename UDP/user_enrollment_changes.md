## user course enrollment status history

A query to find out who made changes to the given user's enrollment status in a given course:

```
select
JSON_EXTRACT_SCALAR(actor.extensions, '$[\'com.instructure.canvas\'][user_login]') as actor_uniqname,
CAST(REGEXP_EXTRACT(membership.id, r'.:(.)') AS INT64) AS enrollment_user_id,
JSON_EXTRACT_SCALAR(group.extensions, '$[\'com.instructure.canvas\'][entity_id]') as enrollment_course_id,
action as enrollment_action,
JSON_EXTRACT_SCALAR(object.extensions, '$[\'com.instructure.canvas\'][workflow_state]') as enrollment_workflow_status,
event_time
from event_store.expanded
where event_time > '<from_date, e.g. 2021-05-01>'
and type = 'Event'
and CAST(REGEXP_EXTRACT(membership.id, r'.:(.)') AS INT64) is not null
and JSON_EXTRACT_SCALAR(object.extensions, '$[\'com.instructure.canvas\'][user_name]') = '<user full name, e.g. Joe Doe>'
and JSON_EXTRACT_SCALAR(group.extensions, '$[\'com.instructure.canvas\'][entity_id]') = '< canvas course id, e.g. 17700000000xxxxxx'
order by event_time desc
```
