## asset access history based on course and/or asset name

A query to find out the course file access history 

```
SELECT 'canvas' AS resource_type, 
REGEXP_EXTRACT(object.id, r'.*:(.*)') AS resource_id, 
CAST(REGEXP_EXTRACT(membership.id, r'.*:(.*)') AS INT64) AS user_id, 
JSON_EXTRACT_SCALAR(actor.extensions, '$[\'com.instructure.canvas\'][user_login]') as user_login_name, 
CAST(REGEXP_EXTRACT(`group`.id, r'.*:(.*)') AS INT64) AS course_id, 
COALESCE( 
JSON_EXTRACT_SCALAR(object.extensions, '$[\'com.instructure.canvas\'][asset_name]'), 
JSON_EXTRACT_SCALAR(object.extensions, '$[\'com.instructure.canvas\'][filename]'), 
object.name, 
'attachment' 
) as name, 
datetime(EVENT_TIME) as access_time 
FROM event_store.expanded 
where 
JSON_EXTRACT_SCALAR(ed_app.json, '$.id') IN UNNEST(['http://m.canvas.umich.edu/' , 'http://umich.instructure.com/' ]) 
and type = 'NavigationEvent' 
and STARTS_WITH(object.id, 'urn:instructure:canvas:attachment') 
and action = 'NavigatedTo' 
and membership.id is not null 
and REGEXP_EXTRACT(`group`.id, r'.*:(.*)') ='17700000000<course_id>'
and REGEXP_EXTRACT(membership.id, r'.*:(.*)') = '17700000000<user_id>'
and COALESCE( 
JSON_EXTRACT_SCALAR(object.extensions, '$[\'com.instructure.canvas\'][asset_name]'), 
JSON_EXTRACT_SCALAR(object.extensions, '$[\'com.instructure.canvas\'][filename]'), 
object.name, 
'attachment' 
) = '<file_name>'
and event_time > '<start_date>'
order by user_id, event_time desc
```
