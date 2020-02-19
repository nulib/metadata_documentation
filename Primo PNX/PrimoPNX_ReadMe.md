# Primo PNX Read Me
February 18, 2020


This directory includes XSLT to create PNX from MODS 3.5, as well as to create MODS from various other formats.

Formats crosswalked to MODS include:

1. EAD, specifically EAD 2002 exported from ArchivesSpace v2.4.1. This code has not been tested with EAD3. Also of note:

   - ArchivesSpace is not exporting a URL; this has to be manually added to either the EAD, MODS or PNX

   - ArchivesSpace does not export the <bioghist> associated with an Agent record.

   - In `EADtoMODS.xsl`, update the template named recordInfo with your local information to put in your institution's MARC code or something like it.

   - In `MODStoPNX.xsl`, search on "01NWU" to find information that is hard coded into the PNX and change it to suit local Primo settings.

2. Propriety XML derived from JSON harvested from NUL's Arch Institutional Repository. Files from this system are labeled `Arch`.

   - XML generated from JSON that included arrays resulted in different nesting levels depending on how the conversion was done, therefore some XSLT transformations look to multiple layers to get the data.

   - In `Arch_toMODS.xsl`, update the template named recordInfo with your local information to put in your institution's MARC code or something like it.

   - In `MODStoPNX.xsl`, search on "01NWU" to find information that is hard coded into the PNX and change it to suit local Primo settings.


3. Propriety XML derived from JSON harvested from NUL's Digital Repository. Files from this system are labeled `Glaze`.

   - XML generated from JSON that included arrays resulted in different nesting levels depending on how the conversion was done, therefore some XSLT transformations look to multiple layers to get the data.

   - In `Glaze_toMODS.xsl`, update the template named recordInfo with your local information to put in your institution's MARC code or something like it.

   - In `MODStoPNX.xsl`, search on "01NWU" to find information that is hard coded into the PNX and change it to suit local Primo settings.
