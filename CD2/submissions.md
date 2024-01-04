# Assignment Submissions Queries

## Get specific assignment submission grades and grade dates for students in a course

*This query pulls assignment (quiz) submissions and scores for the specified assignments in a specified course for a specified time frame*

```
SELECT ad.value.title as assignment_title
    ,ps.value.sis_user_id as UMID
    ,ps.value.unique_id as uniqname
    ,us.value.sortable_name as fullname
    ,su.value.graded_at as graded_date
    ,ad.value.points_possible
    ,su.value.published_grade
FROM udp-umich-prod.canvas.assignments as ad
    ,udp-umich-prod.canvas.submissions as su
    ,udp-umich-prod.canvas.pseudonyms as ps
    ,udp-umich-prod.canvas.users as us
WHERE su.value.assignment_id = ad.key.id
    AND su.value.user_id = ps.value.user_id
    AND su.value.user_id = us.key.id
    AND ad.value.context_id = <COURSE_ID>
    AND su.value.graded_at > TIMESTAMP(<'YYYY-MM-DDT00:00:00 UTC'>)
    AND ad.key.id in (<[list of assignment IDs]>)
ORDER BY su.value.graded_at desc
;
```



