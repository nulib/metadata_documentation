#!/usr/bin/env python
#this exports ALL published finding aids and prints an alert for those that have a missing EAD_ID or mismatched EAD_ID/Identifier values and for those that have a missing or incorrect EAD_Location value.

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

password = getpass.getpass("Input your netID PASSWORD : ")

# authenticates the session
auth = requests.post(baseURL+'/users/'+user+'/login?password='+password).json()
session = auth["session"]

if 'session' in auth:
	print ("Authenticated!")
headers = {'X-ArchivesSpace-Session':session}

# Gets the IDs of all repositories in ArchivesSpace
#repositoryIds = requests.get(baseURL+'/repositories?all_ids=true', headers=headers)
repositoryIds=['3','4','5','6','7','8','9']
#repositoryIds=['10']

#set EAD export options: number components and include DAOs
export_options = '?include_daos=true&numbered_cs=true&include_unpublished=false'

#Prompt for the output path.
outputpath = input("Please enter path for EAD files using double slashes: ")

for repo in repositoryIds:

	# Gets the IDs of all resources in the repository
	#resourceIds = requests.get(baseURL + '/repositories/'+repository+'/resources?all_ids=true', headers=headers)
	resourceIds = requests.get(baseURL+'/repositories/'+repo+'/resources?all_ids=true', headers=headers)	
	# Exports EAD for all resources whose IDs contain 'FA'
	for id in resourceIds.json():
		#resource = (requests.get(baseURL + '/repositories/'+repository+'/resources/' + str(id), headers=headers)).json()
		resource = requests.get(baseURL+'/repositories/'+repo+'/resources/' + str(id), headers=headers).json()
		resourceID = resource["id_0"]
		log = open("c:\\temp\exportsLog.txt", "a")		
		
		#Limit the export to published Resources.
		if resource["publish"]==True and resource["suppressed"]==False:
			#Alert me if a published finding aid has a missing or mismatched Identier/EAD ID
			if "ead_id" in resource:
				if resource["ead_id"]!=resource["id_0"]:
					print(baseURL+'/repositories/'+repo+'/resources/' + str(id)+" has mismatched Identifier/EADID", file=log)
			else:
				print(baseURL+'/repositories/'+repo+'/resources/' + str(id)+" has NO EADID value", file=log)
		
			#Alert me if a published finding aid has a missing or incorrect EAD_location.
			if "ead_location" in resource:
				if resource["ead_location"]!='https://findingaids.library.northwestern.edu/repositories/' + repo + '/resources/' + str(id):
					print(baseURL+'/repositories/'+repo+'/resources/' + str(id)+" has mismatched EAD_location (public URL)", file=log)
			else:
				print(baseURL+'/repositories/'+repo+'/resources/' + str(id)+" has NO EAD_location (public URL) value", file=log)
					
		
			#	if "FA" in resourceID:
			#ead = requests.get(baseURL + '/repositories/'+repository+'/resource_descriptions/'+str(id)+'.xml', headers=headers).text
			ead = requests.get(baseURL + '/repositories/'+repo+'/resource_descriptions/'+str(id)+'.xml'+export_options, headers=headers).text
			
			# Sets the location where the files should be saved
			#destination = 'location goes here'
			destination = outputpath
			
			#Note that I changed the output to include binary and to use the ArchivesSpace Resource ID instead of the local Identifier.
			#The Local identifiers for University Archives include slashes, which resulted in invalid filenames.
			#f = open(destination+resourceID+'.xml', 'w')
			f = open(destination + '\\'+str(id)+'.xml', 'wb')
			f.write(ead.encode('utf-16'))
			f.close
			print (resourceID + ' exported to ' + destination, file=log)