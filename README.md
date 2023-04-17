# canvas_queries

Common queries for Canvas data

## Current Term Courses Info
1. We fetch current term courses information, student assignment, grades and background information from UDP. All the SQL quries associated from that are in `current_term_courses`
2. Athletic dept is the main user of this view, which are Materialized views.
3. MatViews are created on the BigQuery Context store and refreshed 1PM EST

## Auto-Refreshed Materialized Views
Details are here: https://resources.unizin.org/display/UDP/UDP+Context+store

## Athletic student google sheet roster
Athletic dept provides all the student enrolled to their program in current term via a google sheet. We have an additional step 
in making this data available to Tableau dashboard as table called `student_athletic_export`. We created this table since Tableau
has some issues connecting to google sheets.
Every term this table (student_athletic_export) need to updated with latest data. This table resides in the context store with user account provisioned for the project
Steps to update the table
1. create a CSV File from the current term student roster
2. Open the SQL editor from you SQL client and run `delete from student_athlete_export ` to delete all the rows
3. Right click on the `student_athletic_export` table import CSV (from step 1)
4. Verify it has latest info.

## VSCode extension for SQL format
1. VS Code support the BigQuery syntax, optional install will be SQL (BigQuery)
    1. View > Extensions
    2. Search for SQL (BigQuery)
