**Metadata Records into HathiTrust**

General HathiTrust metadata submission guide  [https://goo.gl/FCbQBS](https://goo.gl/FCbQBS)

**Step 1: Create an itemized set of physical items (NUL uses barcodes)**

- Create a spreadsheet with the header: Barcode -- format the column as text so that numeric strings do not convert to Scientific Notation.
- Upload record set into ALMA: Admin &gt; Manage Sets &gt; Add set &gt; itemized
- Set content type = Physical items
- Upload file, then Save
- To see an error file: Administration &gt; Manage Jobs &gt; Monitor Jobs
- Confirm count of set members matches count on spreadsheet of barcodes. Actions &gt; Members

**Step 2: Export from ALMA using a publishing profile (need correct ALMA permissions to do this)**

- ALMA menu &gt; Resources &gt; Publishing Profile &gt; Add Profile
- Profile Details
- Select set name
- Publishing Mode: Full
- FTP – [your local ftp server]
- Physical format: Binary // number of records in file: one
- Data Enrichment
- Add holding information &gt; checked
  - `852 $b $c $h $i`
- Add items information &gt; checked
  - Include item information &gt; `955 $b (barcode) $v (description) $d (permanent location) $e (call number)`
  - Run publishing profile &gt; Actions -&gt; Run

**Step 3: Check publishing report and download file**

- Use [FileZilla](https://filezilla-project.org/) to download your exported file
- [login to your local ftp server]
- drag the file over to My Documents
- Open with [MARCEdit](http://marcedit.reeset.net/) &gt; MARC Tools
- convert file to .mrk format (MARC Breaker function)

**Step 4: Fields to remove/add -- Note: this could also be done with a normalization rule**

- Open the .mrk file created in MARCEdit
- Remove 9XX fields other than the 955. (948, 949, 938, 994)
- Remove 035 $9, ONLY 035 with OCLC should remain – also no 019 or 035 $z
- **Required elements:** `LDR (000), 001, 008, 035 $a (OCoLC)  040 $c, 245, 300 $a`

**Step 5: Record checks using MARCEdit**

- Make sure the counts of `000/001/008/035/245/955` equal the same quantity (one bib per item record)
- Check MARCEdit MARC validation report
- Confirm that all records have only one OCLC number
- Validate headings – correct and establish headings as needed

**Step 6: Convert final file to XML**

- In MARCEditor, compile .mrk file into MARC - File menu &gt; Compile file into MARC. This will create .mrc file which is also UTF encoded. Close file.

- Use MARCEdit tools to convert final file to MARC21XML

- Click the MARC Tools Icon
- Supply input and Output file names and make sure to select MARC-&gt;MARC21XML.
- Execute

**Step 7: Uploading to Zephir**

- [HathiTrust gives you a naming convention]
- This naming convention also ensure sthat your files are not run through your configuration for any Google-scanned materials.

- Use [CoreFTP](http://www.coreftp.com/) to upload file
- Upload file to **ftps.cdlib.org/submissions**

**Step 8: Send notification email to CDL**

To: [cdl-zphr-l@ucop.edu](mailto:cdl-zphr-l@ucop.edu)

file name=&lt;file name&gt;

file size=&lt;file size in bytes&gt;

record count=&lt;number of records&gt;

notification email=&lt;email address to which you would like your run notification sent&gt;

**Step 9: look at error reports, etc.**

Run reports for contributor&#39;s files are posted to their FTPS space, in the subdirectory **ftps.cdlib.org/runreports**.

You are responsible for retrieving your own error files via FTPS from **ftps.cdlib.org/errfiles**. Error files will remain in the FTPS location for 60 days.

Error files will be provided as MARCXML files using the file naming convention: **original\_file\_name\_error.xml**

**Correcting your records and re-submitting them**

After correcting the errors, you may re-submit the records to **ftps.cdlib.org/submissions** , following the same guidelines you followed for initial record submission. **Important** : Because the loader script implements updates to records relying on a change in the date associated with each, it is critical that the filename used for the corrected records includes the date of re-submission and NOT the date included in the name of the file as initially submitted.
