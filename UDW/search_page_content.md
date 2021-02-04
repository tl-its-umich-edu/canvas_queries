## Search for string occurance in course page

Use the following query in Canvas data to find courses where modules/pages contains the search string.

Replace the `SOME_STRING` with the search string value.

```
select c.canvas_id as course_id, c."name" as course_name, mid.title as module_name
from module_item_dim mid,  wiki_page_dim wpd, course_dim c
where
mid.wiki_page_id = wpd.id
and wpd.body like '%SOME_STRING%'
and c.id  = mid.course_id
order by c.canvas_id
```
