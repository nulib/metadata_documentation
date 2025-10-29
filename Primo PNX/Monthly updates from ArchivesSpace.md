Monthly updates of PrimoDC from ArchivesSpace
October 29, 2025


This process involves exporting EAD files from ArchivesSpace in XML format, converting them to MODS and then to PNX. A separate PNX file is created for each EAD and these are concatenated together with an XML wrapper element using a DOS .bat file. Finally, the combined PNX files are edited to meet the formatting requirements of Primo VE.
Requirements:
•	SQL engine (such as Excel or MySQL Workbench)
•	ODBC connection to ArchivesSpace
•	ArchivesSpace API
•	XSLT parser engine (such as XMLSpy or Oxygen; MarcEdit may be used for transformations)

All files used in this process reside on GitHub at https://github.com/nulib/metadata_documentation/tree/main/Primo%20PNX


1.	Generate a CSV file identifying new or modified ArchivesSpace Resource records. You will need to have ODBC access (read only is fine) to the ArchivesSpace production server. 

i.	Open the SQL file identifyModifiedRecords.sql (See Appendix A for the SQL).
ii.	Change date in the SET command that precedes the SELECT command to the first day of the previous month.
iii.	Run the code and export it to .csv format.
iv.	Check the CSV file to make sure it’s complete and well-formed. The file should include the numeric code for the repository in the first column and the numeric identifier of the resource in the second column with the first row containing headers.

Alternately, skip this step to export all published resources using asExport.py in step 2.


2.	Use the ArchivesSpace API to export EAD files for the Resource records identified in step 1. You will need to have access to the API port and will need to know the name and location of the CSV file exported in step 1.

i.	Open the Anaconda prompt via the Windows Start menu and change into the directory where you have the script asExportSubset.py stored.
ii.	Run the Python script asExportSubset.py by typing this at the command line:
python asExportSubset.py
iii.	Alternately, you can export all published resources using asExport.py instead of asExportSubset.py.
iv.	See Appendix B for the Python script.


3.	Create a PrimoDC file for each of the exported EAD records. You will need access to the two XSLT programs that create MODS from EAD and PrimoDC from MODs: EADtoMODS.xsl and MODStoPrimoDC.xsl. 

i.	Use an XML editor such as XMLSpy or Oxygen to do a bulk transformation of all of the newly exported EAD files into MODS using EADtoMODS.xsl. Then transform the MODS files into PrimoDC using MODStoPrimoDC.xsl. MARCEdit can be used to do this using the XML transformation tools but cannot be used to edit the XML or XSLT files.
ii.	See Appendix C for the location of the two XSLT files.


4.	Combine all of the PrimoDC files into one large file for ingest into Primo using the DOS batch file combinePNX.bat. This file should reside in the same directory as the PrimoVE files. You should also have the files header.txt and footer.txt in this directory. The contents of all three files are in appendix D.

i.	Edit (do not use the Open option) the file combinePNX.bat using NotePad++ or another plain text editor. Change the directory and filename each month. Save the file and close it.
ii.	Run combinePNX.bat by double-clicking on it a Windows Explorer window or by typing the filename at a DOS command in the directory where it resides.


5.	Once the file is generated, you’ll need to open it in an editor to replace extraneous tags and move namespace declarations in order to meet the expectations of Primo’s ingest function.

i.	Use the Find/Replace function to remove the XML declaration:

a.	Copy the XML declaration (<?xml version="1.0" encoding="us-ascii"?>)
b.	Replace <?xml version="1.0" encoding="us-ascii"?> with ‘’
c.	Paste the XML declaration back into the top line of the file so that it only occurs once in the file.
ii.	Use the Find/Replace function to move the namespace declarations from the root element open and closing tags into the oai_dc tags:

a.	Copy the record open tag: 

<record xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://www.dublincore.org/schemas/xmls/qdc/dcterms.xsd" xmlns:discovery="http://purl.org/dc/elements/1.1/" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

and replace it with

<record>

b.	Copy the oai_dc:dc open tag: 

<oai_dc:dc xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">

and replace it with

<oai_dc:dc xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://www.dublincore.org/schemas/xmls/qdc/dcterms.xsd" xmlns:discovery="http://purl.org/dc/elements/1.1/" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">


iii.	Save the file. Note that this creates an XML file that does not validate, but should be well-formed. 

6.	Copy the file to a place that it can be accessed and notify the person who will upload it into Primo (currently, put it in G:\collaboration\Karenm\PNX and notify Geoff Morse).
 
Appendix A : SQL to retrieve new and modified Resources (including modifications and additions to archival objects)

This file can be downloaded here: 

https://github.com/nulib/metadata_documentation/blob/main/Primo%20PNX/identifyModifiedRecords.sql


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



 
Appendix B : Python script using the ArchivesSpace API to export EAD for resources identified in Step 1.

This file can be downloaded here: 

https://github.com/nulib/metadata_documentation/blob/main/Primo%20PNX/asExportSubset.py

#!/usr/bin/env python
#this exports only published finding aids specified in a csv file. CSV file should have a column for the repository ID and a column for the resourceID.
#Prints an alert for those that have a missing EAD_ID or mismatched EAD_ID/Identifier values and for those that have a missing or incorrect EAD_Location value.
#Exports from the NUL production server; does not prompt for a server.

import csv
import requests
import json
import pprint
import traceback
import getpass

# the base URL of your ArchivesSpace installation
#baseURL = 'https://northwestern-test-api.as.atlas-sys.com/'
#baseURL = 'http://archival-d.library.northwestern.edu:8089'
baseURL = 'https://as-api.library.northwestern.edu/'

user=input("Input your netID: ")

password = getpass.getpass("Input your netID PASSWORD: ")

# authenticates the session
auth = requests.post(baseURL+'/users/'+user+'/login?password='+password).json()
session = auth["session"]

if 'session' in auth:
    print ("Authenticated!")
headers = {'X-ArchivesSpace-Session':session}

#set EAD export options: number components and include DAOs
export_options = '?include_daos=true&numbered_cs=true&include_unpublished=false'

def export_ead(baseURL, headers, row, outputpath, logpath):
	#this is the first column of the spreadsheet
    repo = row[0]
	#this is the second column of the spreadsheet
    ID = row[1]

    try:
        resource = requests.get(baseURL+'/repositories/'+repo+'/resources/' + str(ID), headers=headers).json()
        resourceID = resource["id_0"]
		#Limit the export to published Resources.
        log = open(logpath, "a")

        if resource["publish"]==True and resource["suppressed"]==False:
			#Alert me if a published finding aid has a missing or mismatched Identier/EAD ID
            if "ead_id" in resource:
                if resource["ead_id"]!=resource["id_0"]:
                    print(baseURL+'/re, file=logpositories/'+repo+'/resources/' + str(ID)+" has mismatched Identifier/EADID", file=log)
            else:
                print(baseURL+'/repositories/'+repo+'/resources/' + str(ID)+" has NO EADID value", file=log)

			#Alert me if a published finding aid has a missing or incorrect EAD_location.
            if "ead_location" in resource:
                if resource["ead_location"]!='https://findingaids.library.northwestern.edu/repositories/' + repo + '/resources/' + str(ID):
                    print(baseURL+'/repositories/'+repo+'/resources/' + str(ID)+" has mismatched EAD_location (public URL)", file=log)
            else:
                print(baseURL+'/repositories/'+repo+'/resources/' + str(ID)+" has NO EAD_location (public URL) value", file=log)


            ead = requests.get(baseURL + '/repositories/'+repo+'/resource_descriptions/'+str(ID)+'.xml'+export_options, headers=headers).text
			
			# Sets the location where the files should be saved
			#destination = 'location goes here'
            destination = outputpath
			
			#The Local identifiers for University Archives include slashes, which resulted in invalid filenames.
            f = open(destination+'\\'+str(ID)+'.xml', 'wb')
            f.write(ead.encode('utf-16'))
            f.close
            print(resourceID + ' exported to ' + destination, file=log)

	# this blanket except statement is not what you'd want to do if you were distributing this program, but
	# works for this example since you will want to see what your errors are in order to fix them
    except Exception:
        print(traceback.format_exc())

def main():
	#api_url, headers = as_login.login()
    csvpath = input('Please enter path to CSV file: ')
    outputpath = input('Please enter path for EAD files: ')
    logpath = "c:\\temp\\exportsLog.txt"	
    print()
    #The location of the log is set above in ex
    print('Look for the log file at ', logpath)
    print()
    with open(csvpath, 'r', encoding='utf-8') as csvfile:
        csvreader = csv.reader(csvfile)
		#skips the header row
        next(csvreader, None)
        for row in csvreader:
            export_ead(baseURL, headers, row, outputpath, logpath)

main() 
Appendix C : Location of XSLT files

EADtoMODS.xsl can be downloaded here:

https://github.com/nulib/metadata_documentation/blob/master/Primo%20PNX/EADtoMODS.xsl

MODStoPrimoDC.xsl can be downloaded here:

https://github.com/nulib/metadata_documentation/tree/master/Primo%20PNX/MODStoPrimoDC.xsl


 
Appendix D : DOS batch file to combine all of the PrimoDC files into one
Save the code below with a .bat extension in the directory with the PrimoDC files. Change the text in red to reflect your directory and filenames.
OR issue this command at the command line, changing the filenames marked in red: 
type header.txt >>findingAids.xml
for %%f in (September2021_complete\*.pnx) do (type %%f >>findingAids.xml)
type footer.txt >>findingAids.xml
rename findingAids.xml findingAids20210901.xml
where header.txt is a file containing the line: 
<ListRecords>
and footer.txt is a file containing the line: 
</ListRecords>

