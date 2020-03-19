## basics_for_hathi
	- adds 003 IEN
	- adds 040 $cINU if no $c exists
	- changes 590 to 500
	- deletes 852, 856

## 035_Voyager_Step1
	deletes (NU or TR) from end of 035$a 
	
## 035 Voyager Step2 
	removes -nuwdb from 035
	changes 035 $a(IEN) to $z(IEN)Voyager
	removes 035 $z [containing: set by OCLC ; Added by OCLC; added by program)

## Indicator corrections 
	common indicator corrections

## Remove extra fields
	removes 9XX
	removes 850, 852, 866
	removes 019
	removes 035 $z(OCoLC) ; Added by OCLC
  
  
check marc using rules file
validate record structure

count 035$a - should only be on per record

check for missing 955
  
