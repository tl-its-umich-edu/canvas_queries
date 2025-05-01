# Course name to Subaccount info

*This query was used to find relevant subaccount and department information based on Perusall's usage data*

Searching by course name is not the most reliable way to find this information as opposed to Course Id, since the search may involve duplicate courses or renamed courses across terms. If the course name is the only information given, this is how to search CD2 for a subaccount and parent account names. This search is strict to the exact names given, but could be modified to be less strict (without using filtering + aggregation)

Note that the identifiers that we are joining on (`course_id`, `account_id`) is not necessarily an exact match since we are aggregating by course name, meaning there could be multiple `course_id`'s per course name.

## Create temp table with course names

First use your given course name data to create an id - name relationship (such that you respect duplicates). This step could be skipped and you can remove temp_id if you only care about unique course names.

```
CREATE TEMPORARY TABLE TempCourses (
    id INT,
    course_name STRING
);

INSERT INTO TempCourses (id, course_name)
VALUES
(1,"course name 1 2025"),
(2,"course name 2 2025"),
(3,"course name 3 2025"),
(4,"course name 4 2025"),
...
```
To create this list, you can use a csv table to fill in the id numbers by using "Smart Fill" in google sheets. 

After creating the google sheet list of ids and course names, you can paste the google sheets entries into the Query window, then use multi-line editing to format the data holding down the shortcut "Shift"-"Option" and using the cursor to select every line.

Alternatively, you could try to import the google sheets into bigquery by selecting "Create Table" when right-clicking an appropriate dataset (such as "test" in udp-umich-prod). There may be other ways to import custom data, such as using a different project and importing via external connection. You may need to consult Unizin for confirmation of best practices.

## Find subaccount info

In the same query window where you import the temp table data (labeled as `TempCourses`), you can use this query to group by course Name & temporary id to get the resulting info from CD2
```
CREATE TEMPORARY TABLE Results (
    temp_id INT,
    temp_course_name STRING,
    canvas_course_id INT,
    course_sis_id STRING,
    canvas_account_name STRING,
    canvas_parent_account_name STRING,
    #udp_org_name STRING,
    #udp_parent_org_name STRING
);

INSERT INTO Results 
SELECT 
  TC.id as temp_id, 
  TC.course_name as temp_course_name, 
  MIN(CC.key.id) as canvas_course_id,  
  MIN(CC.value.sis_source_id) as course_sis_id, 
  MIN(AC.value.name) as canvas_account_name, 
  MIN(parent_AC.value.name) as canvas_parent_account_name
FROM TempCourses TC
LEFT JOIN `udp-umich-prod.canvas.courses` CC ON TC.course_name = CC.value.name 
LEFT JOIN `udp-umich-prod.canvas.accounts` AC ON CC.value.account_id = AC.key.id
LEFT JOIN `udp-umich-prod.canvas.accounts` parent_AC ON AC.value.parent_account_id = parent_AC.key.id
GROUP BY TC.id, TC.course_name
;
```

If you want get an exact replica of the course name list given with the added data fields, sort by id such that the order is retained. You can then import the result from this query as a CSV/google sheet:
```
Select *
from Results
ORDER BY Results.temp_id ASC
```
