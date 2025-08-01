# Submitting metadata records for locally digitized material to HathiTrust

[General HathiTrust metadata submission guide](https://goo.gl/FCbQBS)

## Step 1: Create an itemized set of physical items (NUL uses barcodes)

> **Requirements for export:** All bib records must be `unsuppressed` otherwise neither the bib nor item data will export

- Create a spreadsheet with the header: `Barcode`
  - Format the column as `text` so that numeric strings do not convert to `Scientific Notation.`
  - Alma accepts `.txt`, `.csv`, `.xls`, `.xlsx` files when adding members to a set from a file
- Create a record set in ALMA:
  - `Admin` &gt; `Manage Sets` &gt; `Add Set` &gt; `Itemized`
  - Set content type = `Physical items`
  - Upload your spreadsheet of barcodes, then `Save`
- To see an error file: `Administration` &gt; `Manage Jobs` &gt; `Monitor Jobs`
- Confirm count of set members matches count on spreadsheet of barcodes. `Actions` &gt; `Members`

## Step 2: Export MARC file from ALMA using a publishing profile

> Will need correct ALMA permissions to do this

- ALMA menu &gt; `Resources` &gt; `Publishing Profile`
- Use the profile `Hathi Trust for DC workflow (one record per barcode)`
- Open the Action menu on the right and select `Edit`
- Change the selected set to `your itemized set`
- Run the publishing profile> `Actions` &gt; `Run`

### Profile Details Tab Settings

- Publishing Mode: `Full`
- FTP: `Ex Libris Secure FTP Server`
- Include all records each time file is published: `checked`
- Physical format: `Binary`
- Number of records in file: `One File`
- File name prefix: `your preference`

### Data Enrichment Tab Settings

- Add holding information &gt; `checked`
  - `852 $b $c $h $i`
- Add items information &gt; `checked`
  - `955 $b (barcode) $v (description) $d (permanent location) $e (call number)`

## Step 3: Check publishing report and download file

- Use [FileZilla](https://filezilla-project.org/) to download your exported file
  - Log in to the `Ex Libris SFTP Service`
  - Navigate to the `production` folder
  - Rename the file by adding the `.mrc` extension
  - Drag the file over to `your preferred location`
- Open the `.mrc` file with [MARCEdit](http://marcedit.reeset.net/) &gt; `MARC Tools`
  - Use the `MARC Breaker` function to convert it to `.mrk` format

## Step 4: Edit records to conform to HathiTrust requirements

> **Note:** this step could _probably_ also be done with a normalization rule

- Open the `.mrk` file created in MARCEdit Editor
- Download and import the task file `Hathi_trust_tasks.task`
- Run the task list `Tools` &gt; `Assigned Tasks` &gt; `Currently available tasks` &gt; `Hathi ingest prep combined`
  - Remove all `9XX` fields other than the `955`
  - Remove all `035 $a` fields except one `035 $a (OCoLC)`
  - Remove all `019` or `035 $z`

## Step 5: Record quality control using MARCEdit

### Required elements for HathiTrust Submission

If any of these fields are missing, the record will be rejected - Add these if necessary, either in Alma then start over with step 2 to re-export, or edit directly in MARCEdit and correct in Alma afterward.
  - `LDR (000)`
  - `001`
  - `008`
  - `035 $a (OCoLC)`
  - `040 $c`
  - `245`
  - `300 $a`
  - `955` 

#### In MARCEdit:

- Use MARCEdit's `Field Count` function to verify that the count of `000/001/008/035/245/955` matches the number of bib records in the file, i.e. each record should have one and only one of these
- Run the MARCEdit `MARC validation` report
- `Validate headings` – Correct and establish authorized access points as needed but avoid getting bogged down with fixing unvalidated headings. Consider batch updating if need be.

> **Bound withs**: Hathi requires “each describe a single item using a single 955 field with that item's description (one bibliographic record per item; multi-volume works should have the same record repeated for each volume)”, which suggests you can repeat the same item info on more than one bib record for a bound with.

## Step 6: Convert final file to XML

- In MARCEdit, compile the `.mrk` file into MARC
  - `File`  &gt; `Compile file into MARC`. This will create `.mrc` file which is also `UTF-8` encoded. Close file.
- Use `MARC Tools` to convert the `.mrc` file to `MARC21XML`
    - Supply `Input` and `Output` file names and make sure to select `MARC` &gt; `MARC21XML`&gt; `Execute`

## Step 7: Upload to Zephir using CoreFTP

Rename the file to conform exactly to the naming convention that HathiTrust has established for NUL. This ensures that these tiles are processed as locally digitized material and not as Google-scanned items

- `nwu_nwu-loc_YYYYMMDD_northwestern.xml`

> **Note:** Google-scanned materials have a different file naming convention  

HathiTrust requires the use of [CoreFTP](http://www.coreftp.com/) to upload the file
- Once connected the server in CoreFTP, upload the file to **ftps.cdlib.org/submissions**

## Step 8: Send notification email to CDL

*To:* [cdl-zphr-l@ucop.edu](mailto:cdl-zphr-l@ucop.edu)  

*Subject:* Local digitization workflow submission from Northwestern University YYYYMMDD  

[Body of message]

- File name=&lt;file name&gt;
- File size=&lt;file size in bytes&gt;
- Record count=&lt;number of records in file&gt;
- Notification email=&lt;email address to which you would like your run notification sent&gt;

## Step 9: Check reports and resolve errors

- A day or two after submission, run reports for contributor&#39;s files are posted in the CDL FTP subdirectory **ftps.cdlib.org/runreports**.
- You are responsible for retrieving your own error files via FTPS from **ftps.cdlib.org/errfiles**. Error files will remain in the FTPS location for 60 days.
  - Error files will be provided as MARCXML files using the file naming convention: **original\_file\_name\_error.xml**

### Correcting your records and re-submitting them

After correcting the errors, you may re-submit the records to **ftps.cdlib.org/submissions**, following the same guidelines you followed for initial record submission.

> **Important** : Because the loader script relies on a change in the date associated with records to implement updates, it is critical that the filename used for the corrected records includes the date of resubmission and NOT the date when it was originally sent.
