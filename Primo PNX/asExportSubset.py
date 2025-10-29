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
