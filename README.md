# canvas_queries

Common queries for Canvas data

## Creating Scheduled Queries
1. Go to BiqQuery Console for [scheduled queries](https://console.cloud.google.com/bigquery/scheduled-queries?project=udp-umich-prod) and click on `+ Create scheduled query in editor`
2. Enter your query in the Editor and click `SCHEDULE` button
3. Add following in the pop-up window
   1. Details and schedule: `datamart_name__table_name_you_want_to_give`. For example: `athletic_department_views__v1_student_current_term_course`
   2. Schedule option: `days` and at `18:00`. Don't need to do anything for `Start now` and `End never` elements.
   3. Destination for Query result: 
      1. Check the checkbox `Set a destination table for query results`
      2. Choose the data set name `athletic_department_views`
      3. Give a table name for example: `v1_student_current_term_course`
4. Destination table write preferance: `Overwrite table`

## Updating a Scheduled queries
1. Do as in Step - 1 in the Create scheduled queries section above and click Edit and modify your query and than select `Schedule -> Update scheduled Query`(if you are owner of the queries, BQ configuration changed so this is possible now)
2. if you are not owner of the scheduled queries - it's may be always Delete and create a new table. (This needs to be tested)

## On demand refresh Datamart tables
1. Go to the scheduled queiries console as described above and chose a table to do a refresh
2. Click on the `SCHEDULE BACKFILL` button choose option `Run one time transfer` and clike `ok`. This will start the process.
3. all 3 tables take about 5 min to run.

## Athletic student google sheet roster
Athletic dept provides all the student enrolled to their program in current term via a google sheet. We have an additional step 
in making this data available to Tableau dashboard as table called `student_athletic_export_csv`. We created this table since Tableau
has some issues connecting to google sheets.
Every term this table (student_athletic_export) need to updated with latest data. This table resides in the context store with user account provisioned for the project
Steps to update the table
1. create a CSV File from the current term student roster
2. Open the SQL editor from you SQL client and run `delete from student_athlete_export_csv ` to delete all the rows
3. Right click on the `student_athletic_export_csv` table import CSV (from step 1)
4. Verify it has latest info.

## VSCode extension for SQL format
1. VS Code support the BigQuery syntax, optional install will be SQL (BigQuery)
    1. View > Extensions
    2. Search for SQL (BigQuery)
