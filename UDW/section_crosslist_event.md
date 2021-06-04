## Search for section crosslist event

Use the following query in Canvas data to find out who/when did a section crosslisting 

Replace the `section_id` with the 6-digit Canvas section id; and `timestamp_year` in format of 'YYYY' for desired time range.

```
select r.course_id, r.url, pd.sis_user_id, pd.unique_name, , r.timestamp_year, r.timestamp_month, r.timestamp_day 
from requests r, user_dim ud, pseudonym_dim pd 
where 
r.http_method='POST'
and url like '%/sections/<section_id>/crosslist'
and r.timestamp_year = '<YYYY>'
and r.user_id = ud.id 
and ud.canvas_id = pd.canvas_id 
order by r."timestamp" desc
```
