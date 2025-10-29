/*The report generates a list of ArchivesSpace Resource records (including their components) that have been modified since the date set in the first line of code below*/
/*BEFORE RUNNING THIS SCRIPT, CHANGE THE VALUE OF @sinceDate BELOW */
/*Export the file as type Excel spreadsheet (*.xml) */
/*Then, from Excel, open the xml file and save as ArchivesSpaceReports_ModifiedResources_[MONTHYEAR].xlsx to G:\Collaboration\ACMS-ET\Monthly ArchivesSpace Reports from the Result Grid below*/

SET @sinceDate='2025-10-01'/*Change the date here*/;
SELECT 
    T10.repo_code AS `repository`,
    T0.id AS `resourceID`,
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(T0.identifier,'","','-'),'[',''),']',''),'null',''),'"',''),',','')  AS `EAD_ID`,
    T0.title AS `resourceTitle`
FROM
    archivesspace.resource T0
       JOIN
    archivesspace.repository T10 ON T0.repo_id = T10.id
WHERE
    ((T0.user_mtime >= @sinceDate
        OR T0.system_mtime >= @sinceDate)
        AND (T0.Suppressed = 0 AND T0.Publish = 1));
