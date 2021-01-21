<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="mods" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- This stylesheet transforms MODS version 3.5 records and collections of records to PNX.
This stylesheet has been developed for use with the Northwestern University Library archival and manuscript collections MODS records
 (derived from their original source records in EAD), the Image Repository collection of Transportation Library photographs, and the
Winterton Collection of East African Photographs.
It is copied from the MODS to DC crosswalk at http://www.loc.gov/standards/mods/MODS3-22simpleDC.xsl.
Edited by Karen Miller to meet the needs of NUL.	-->
<!--updated Aug. 5, 2020 to accommodate multiple Extent sub-records-->

<!--20170505: changed @encoding below from UTF-8 to us-ascii to deal with diacritics-->
	<xsl:output method="xml" indent="yes" omit-xml-declaration="no" encoding="us-ascii" media-type="text/xml"/>	
	<xsl:strip-space elements="*"/>
	<!--xsl:variable name="collection_name" select="mods:mods/mods:relatedItem[@type='host']/mods:titleInfo/mods:title"/-->

	
	<xsl:template match="/">
		<pnx>
		<xsl:for-each select="//mods:mods">
		
			<xsl:variable name="collection_name">
				<xsl:value-of select="mods:relatedItem[@type='host']/mods:titleInfo/mods:title"/>
			</xsl:variable>			

			<record>
			
			<xsl:if test="not(contains($collection_name, 'Cordwell'))"><!--Remove this and the corresponding closing tag once the Cordwell collection is gone!-->
			
				<control>
					<xsl:apply-templates mode="control"/>
					<sourceformat>MODS</sourceformat>
				</control>
				<display>
					<xsl:apply-templates mode="display"/>
				</display>
				<links>
					<xsl:apply-templates mode="links"/>
				</links>
				<search>
					<xsl:apply-templates mode="search"/>

						<xsl:if test="mods:recordInfo/mods:recordOrigin='Archon' or mods:recordInfo/mods:recordOrigin='ArchivesSpace' ">
							<searchscope>01NWU_EAD</searchscope>
							<scope>01NWU_EAD</scope>
						</xsl:if>
						<xsl:if test="contains($collection_name,'Winterton')">
							<searchscope>01NWU_WTON</searchscope>
							<scope>01NWU_WTON</scope>
						</xsl:if>
						<xsl:if test="contains($collection_name,'Transportation')">
							<searchscope>01NWU_TRANS</searchscope>
							<scope>01NWU_TRANS</scope>
						</xsl:if>
						<xsl:if test="mods:recordInfo/mods:recordOrigin='Digital Image Library'">
							<searchscope>01NWU_VRA</searchscope>
							<scope>01NWU_VRA</scope>
							<description>Images Repository public collections</description>
						</xsl:if>
						<xsl:if test="mods:recordInfo/mods:recordOrigin='Glaze'">
							<searchscope>01NWU_GLAZE</searchscope>
							<scope>01NWU_GLAZE</scope>
							<description>Images Repository public collections</description>
						</xsl:if>
						<xsl:if test="mods:recordInfo/mods:recordOrigin='Arch'">
							<searchscope>01NWU_ARCH</searchscope>
							<scope>01NWU_ARCH</scope>
							<description>Arch institutional repository service for Northwestern University</description>
						</xsl:if>
						<searchscope>01NWU</searchscope>
						<scope>01NWU</scope>

					<addtitle>
						<xsl:value-of select="$collection_name"/>
					</addtitle>
					<addttle>Northwestern University Library (Evanston, Ill.)</addttle>
				</search>
					<sort>
					<xsl:apply-templates mode="sort"/>
				</sort>
				<facets>
					<xsl:apply-templates mode="facets"/>
					<!--<collection>Main &amp; Deering Libraries (Evanston)</collection>-->
					<toplevel>available</toplevel>
					<xsl:choose>
						<xsl:when test="contains($collection_name,'Winterton')">
							<toplevel>online_resources</toplevel>
						</xsl:when>
						<xsl:when test="mods:physicalDescription/mods:internetMediaType!='text/xml'">
							<toplevel>online_resources</toplevel>
						</xsl:when>
					</xsl:choose>
				</facets>
				<delivery>
					<institution>01NWU</institution>
					<delcategory>Online Resource</delcategory>
					<xsl:apply-templates mode="delivery"/>
				</delivery>
				<ranking>
					<xsl:apply-templates mode="ranking"/>
				</ranking>
				<dedup>
					<xsl:apply-templates mode="dedup"/>
				</dedup>
</xsl:if>				
				
			</record>
		</xsl:for-each>
		</pnx>		
	</xsl:template>


<xsl:template match="mods:modsCollection"/>
		
		
	<xsl:template match="mods:mods">
			<xsl:param name="collection_name">
				<xsl:value-of select="mods:relatedItem[@type='host']/mods:titleInfo/mods:title"/>
			</xsl:param>		
	</xsl:template>	

	
	
<!--Control section -->
	<xsl:template match="mods:recordInfo" mode="control">
		<xsl:if test="mods:recordIdentifier">
			<sourcerecordid>
				<xsl:value-of select="mods:recordIdentifier"/>
			</sourcerecordid>
			<recordid>
				<xsl:value-of select="mods:recordIdentifier"/>
			</recordid>
		</xsl:if>	
		<sourceid>
			<xsl:call-template name="sourceid"/>
		</sourceid>
		<sourcesystem>
			<xsl:call-template name="sourcesystem"/>
		</sourcesystem>
		<!-- Removing Jan. 20, 2021 as we're not using this. It can be added back later if needed-->
		<!--
		<colldiscovery>
			<xsl:choose>
				<xsl:when test="mods:recordInfoNote='collection'">
					<xsl:text>$$Tcollection</xsl:text>
					<xsl:text>$$D</xsl:text>
					<xsl:value-of select="mods:recordIdentifier[@source='IEN']"/>
				</xsl:when>
				<xsl:when test="mods:recordInfoNote='item'">
					<xsl:text>$$Titem</xsl:text>		
					<xsl:text>$$D</xsl:text>
					<xsl:value-of select="../mods:relatedItem[@type='host']/mods:identifier[@displayLabel='PID']"/>		
				</xsl:when>
			</xsl:choose>
			<xsl:text>$$I01NWU</xsl:text>
		</colldiscovery>
-->

	</xsl:template>


	
<!--Control section from Winterton MODS-->
	<xsl:template match="mods:identifier" mode="control">
		<xsl:choose>
			<xsl:when test="@type='local' and @displayLabel='Object ID'">
				<sourcerecordid>
					<xsl:value-of select="."/>
				</sourcerecordid>
				<recordid>01NWU_WTON<xsl:value-of select="."/></recordid>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!--Common elements for multiple modes (sections)-->

	<!--Type-->
	<xsl:template match="mods:typeOfResource" mode="display">
		<type>
			<xsl:choose>
				<xsl:when test="../mods:genre='finding aid'">
					<xsl:text>finding aid</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="type"/>
				</xsl:otherwise>
			</xsl:choose>
		</type>
	</xsl:template>

	<!--Source-->
	<xsl:template match="mods:identifier[@displayLabel='ID']" mode="display">
		<source>
			<xsl:value-of select="."/>
		</source>
	</xsl:template>
	
	<xsl:template match="mods:typeOfResource" mode="search">
		<rsrctype>
			<xsl:call-template name="type"/>
		</rsrctype>
	</xsl:template>

<!--Title-->
	<!--For Display, we can only have one title, so take the first. Note that this makes the (big) assumption that the first <mods:titleInfo> is the preferred title.-->
	<!--For Display, we want to include the 245$c, but not for the other sections.-->
	<xsl:template match="mods:titleInfo[1]" mode="display">
		<title>
			<xsl:call-template name="title"/>
			<xsl:if test="../mods:note[@type='statement of responsibility']">
				<xsl:text> / </xsl:text>
				<xsl:value-of select="../mods:note[@type='statement of responsibility']"/>
			</xsl:if>
		</title>
	</xsl:template>
	<xsl:template match="mods:titleInfo" mode="display">
		<xsl:if test="not(@otherType='filing')">
			<lds24>
				<xsl:call-template name="title"/>
				<xsl:if test="../mods:note[@type='statement of responsibility']">
					<xsl:text> / </xsl:text>
					<xsl:value-of select="../mods:note[@type='statement of responsibility']"/>
				</xsl:if>
			</lds24>
		</xsl:if>
	</xsl:template>
	
	<!--For Search, all but the 245 ought to go into <alttitle> and 245 goes into the Title element. Note that this makes the (big) assumption that the first <mods:titleInfo> is the preferred title.-->
	<xsl:template match="mods:titleInfo[1]" mode="search">
		<title>
			<xsl:call-template name="title"/>
		</title>
	</xsl:template>
	<xsl:template match="mods:titleInfo" mode="search">
		<alttitle>
			<xsl:call-template name="title"/>
		</alttitle>
		<xsl:if test="ends-with(mods:title, 'Records of')"><!--Also search for "[filing title name] papers"-->
			<alttitle>
				<xsl:value-of select="substring-before(mods:title, ', Records of')"/><xsl:text> papers</xsl:text>
			</alttitle>
			<alttitle>
				<xsl:value-of select="replace(mods:title, '&amp;', 'and')"/>
			</alttitle>
		</xsl:if>
	</xsl:template>
	
<!--For Sort, sort by the 245-->
	<xsl:template mode="sort" match="mods:titleInfo[@type='alternative'] | mods:titleInfo[@type='abbreviated'] | mods:titleInfo[@type='translated'] | mods:titleInfo[@type='uniform']"/>
	
	<xsl:template match="mods:titleInfo" mode="sort">
		<xsl:choose>
			<xsl:when test="@otherType='filing'">
				<title>
					<xsl:call-template name="title"/>
				</title>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="count(../mods:titleInfo[@otherType='filing'])=0">
					<title>
						<xsl:call-template name="title"/>
					</title>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!--AddTitle. For Search, also sort by related titles; note that Voyager mapping only includes Series here.-->
	<xsl:template match="mods:relatedItem[mods:titleInfo/mods:title]" mode="search">
		<addtitle>
			<xsl:value-of select="mods:titleInfo/mods:title"/>
			<xsl:value-of select="mods:relatedItem[@type='series']/mods:titleInfo/mods:title"/>
		</addtitle>
	</xsl:template>

	<!--Creator, Contributor-->
<xsl:template match="mods:name[1]" mode="display">
	<xsl:if test="../mods:name[mods:role/mods:roleTerm[@type='text']='Creator' or mods:role/mods:roleTerm[@type='text']='creator' or mods:role/mods:roleTerm[@type='code']='cre']">
		<creator>
			<xsl:for-each select="../mods:name[mods:role/mods:roleTerm[@type='text']='Creator' or mods:role/mods:roleTerm[@type='text']='creator' or mods:role/mods:roleTerm[@type='code']='cre']">
				<xsl:if test="position() le 5">
					<!--Limit the number of creators listed in the display to 5-->
					<xsl:if test="preceding-sibling::mods:name[mods:role/mods:roleTerm[@type='text']='Creator' or mods:role/mods:roleTerm[@type='text']='creator' or mods:role/mods:roleTerm[@type='code']='cre']"> ; </xsl:if>
					<xsl:call-template name="name"/>
				</xsl:if>
				<xsl:if test="position() eq 6">
					<xsl:text> [and others]</xsl:text>
				</xsl:if>
			</xsl:for-each>
		</creator>
	</xsl:if>
	<xsl:if test="../mods:name[not(mods:role/mods:roleTerm[@type='text']='Creator' or mods:role/mods:roleTerm[@type='text']='creator' or mods:role/mods:roleTerm[@type='code']='cre')]">
		<contributor>
			<xsl:for-each select="../mods:name[not(mods:role/mods:roleTerm[@type='text']='Creator' or mods:role/mods:roleTerm[@type='text']='creator' or mods:role/mods:roleTerm[@type='code']='cre')]">
				<xsl:if test="position() le 5">
					<!--Limit the number of contributors listed in the display to 5-->
					<xsl:call-template name="name"/>
					<!--xsl:if test="following-sibling::mods:name"> ; </xsl:if-->
					<xsl:if test="following-sibling::mods:name[not(mods:role/mods:roleTerm[@type='text']='creator')]"> ; </xsl:if>					
				</xsl:if>
				<xsl:if test="position() eq 6">
					<xsl:text> [and others]</xsl:text>
				</xsl:if>
			</xsl:for-each>
		</contributor>
	</xsl:if>
</xsl:template>
		
	<!--For <search>, take both the 1xx and 7xx fields and the 245$c-->
	<xsl:template match="mods:name" mode="search">
		<creatorcontrib>
			<xsl:call-template name="name"/>
		</creatorcontrib>
		<xsl:if test="contains(mods:namePart, '&amp;')">
			<creatorcontrib>
				<xsl:value-of select="replace(mods:namePart, '&amp;', 'and')"/>
			</creatorcontrib>
		</xsl:if>
	</xsl:template>
	<xsl:template match="mods:note[@type='statement of responsibility']" mode="search">
		<creatorcontrib>
			<xsl:value-of select="normalize-space(.)"/>
		</creatorcontrib>
	</xsl:template>

	<!--Although it does not appear in the documentation, Sort uses an Author element. Why not call it Creator like the others? Who knows.-->
	<xsl:template match="mods:name" mode="sort">
		<xsl:choose>
			<xsl:when test="mods:role/mods:roleTerm[@type='text']='Creator' or mods:role/mods:roleTerm[@type='text']='creator' or mods:role/mods:roleTerm[@type='code']='cre' ">
				<author>
					<xsl:call-template name="name"/>
				</author>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!--For <facets>, take both the 1xx and 7xx fields. For personal names, take only the first letter of the first name.-->
	<xsl:template match="mods:name" mode="facets">
		<creatorcontrib>
			<xsl:choose>
				<!--xsl:when test="@type='personal'"-->
				<xsl:when test="@type='personal' and not(contains(mods:namePart,'unknown') or contains(mods:namePart,'Unknown'))">
					<xsl:choose>
						<xsl:when test="contains(mods:namePart, ',')">
							<xsl:value-of select="concat(substring-before(mods:namePart[1], ','), ',', substring(substring-after(mods:namePart[1], ','),1,2))"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="mods:namePart[1]"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="name"/>
				</xsl:otherwise>
			</xsl:choose>
		</creatorcontrib>
	</xsl:template>

	<!--Description ("any information that describes the content of the resource ...MARC 502, 505, 520 fields")-->
	<!--NUL Voyager mapping is as follows for the Display section: 502 to publisher, 505 to lds01, 520 to lds02 -->
	<!--The mapping below could easily be de-activated or expanded. This may be desirable for records that did not originate as MARC.-->
	<xsl:template match="mods:note[not(@type='statement of responsibility') and not(@type='for indexing only')]" mode="display">
		<!--xsl:if test="$collection_name!='Northwestern University Library Archival and Manuscript Collections'"-->
		<xsl:if test="../mods:relatedItem[@type='host']/mods:titleInfo/mods:title!='Northwestern University Library Archival and Manuscript Collections'">
			<description>
				<xsl:value-of select="normalize-space(.)"/>
			</description>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="mods:abstract" mode="search">
		<description>
			<xsl:value-of select="normalize-space(.)"/>
		</description>
	</xsl:template>
	
	
	<!--xsl:template match="mods:note[not(@type='statement of responsibility')]" mode="search">
		<lds06>
			<xsl:value-of select="."/>
		</lds06>
	</xsl:template-->
	
	<!--Changed 1. to split lds06 into smaller chunks for Primo VE and 2. to pull only from mods:note@type='for indexing only' /kdm Oct. 30, 2020-->
	<!--this works nicely with small files, but crashes with a stack overflow for larger ones-->
	<!--xsl:template match="mods:note[@type='for indexing only']" mode="search">
		<xsl:call-template name="wordwrap">
			<xsl:with-param name="string">
				<xsl:value-of select="normalize-space(.)"/>
			</xsl:with-param>
			<xsl:with-param name="start" select="1"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="wordwrap">
		<xsl:param name="string"/>
		<xsl:param name="start"/>
		<xsl:param name="line-length" select="37850"/>
    
		<xsl:variable name="line" select="normalize-space(substring-before($string, tokenize(substring($string, $start, $line-length), '\s+')[last()]))"/>
		<xsl:variable name="rest" select="normalize-space(substring($string, string-length($line)+1))"/>
		
		<xsl:if test="$line">
			<lds06>
			   <xsl:value-of select="$line"/>
			</lds06>
		</xsl:if>
    
    	<xsl:choose>
			<xsl:when test="string-length($rest) gt $line-length">
				<xsl:call-template name="wordwrap">
					<xsl:with-param name="string" select="$rest"/>
					<xsl:with-param name="start" select="string-length($line)+1"/>
				</xsl:call-template>
			 </xsl:when>
			 <xsl:when test="string-length($rest) lt $line-length and string-length($rest) gt 0">
				<lds06>
					<xsl:value-of select="$rest"/>
				</lds06>
			 </xsl:when>		   
		</xsl:choose>
    </xsl:template-->

<!--Changed 1. to split lds06 into smaller chunks for Primo VE and 2. to pull only from mods:note@type='for indexing only' /kdm Oct. 30, 2020-->
	<xsl:template match="mods:note[@type='for indexing only']" mode="search">
		<xsl:variable name="line-length" select="37850"/>
		<xsl:variable name="i">
			<xsl:value-of select="(string-length(normalize-space(.)) idiv $line-length)"></xsl:value-of>
		</xsl:variable>
		<xsl:variable name="string" select="normalize-space(.)"/>
		
			<xsl:choose>
				<xsl:when test="$i=0">
					<lds06>
						<xsl:value-of select="$string"></xsl:value-of>
					</lds06>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="0 to $i">
						<xsl:variable name="start" select="(.*$line-length)+1"/>
																												
						<lds06>
							<xsl:value-of select="substring($string, $start, $line-length)"/>
						</lds06>
						<!--this is a kludgy way to get a split word into the text search field. It does not solve the problem of quoted string searching-->
						<xsl:if test="not(ends-with(substring($string, $start, $line-length), ' ')) and not(substring($string, ((.+1)*$line-length)+1) eq ' ') and not(.=$i)">
							<lds06>
								<xsl:value-of select="tokenize(substring($string, $start, $line-length), '\s+')[last()]"></xsl:value-of>
								<xsl:value-of select="substring-before(substring($string, ((.+1)*$line-length)+1, $line-length), ' ')"/>
							</lds06>
						</xsl:if>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
				
	</xsl:template>

	
	<!--Edition, Publisher, Creationdate for Display-->
	<xsl:template match="mods:originInfo" mode="display">
		<xsl:if test="mods:edition">
			<edition>
				<xsl:value-of select="mods:edition"/>
			</edition>
		</xsl:if>
		<xsl:for-each select="mods:publisher">
			<publisher>
				<!--Note that a place of publication is only included in the PNX when mods:placeTerm@type='text'-->
				<xsl:for-each select="mods:place/mods:placeTerm[@type='text']">
					<xsl:choose>
						<xsl:when test="ends-with(., ':')">
							<xsl:value-of select="."/>
							<xsl:text> </xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="."/>
							<xsl:text> : </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
				<xsl:choose>
					<!--Override the publisher for University Archives & Charles Deering McCormick Library of Special Collections-->
					<xsl:when test="contains(., 'Charles Deering McCormick Library of Special Collections') or contains(., 'Northwestern University Archives')">
						<xsl:text>McCormick Library of Special Collections and University Archives</xsl:text>
					</xsl:when>
					<xsl:when test="ends-with(.,',')">
						<xsl:value-of select="substring-before(., ',')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="normalize-space(.)"/>
					</xsl:otherwise>
				</xsl:choose>
				
			</publisher>
		</xsl:for-each>
		
		<xsl:choose>
			<xsl:when test="../mods:genre='finding aid'"/>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="mods:dateIssued[not(@encoding='marc')]">
						<creationdate>
							<xsl:value-of select="mods:dateIssued[not(@encoding='marc')]"/>
						</creationdate>
					</xsl:when>
					<xsl:when test="mods:dateCreated[not(@encoding='marc')]">
						<creationdate>
							<xsl:value-of select="mods:dateCreated[not(@encoding='marc')]"/>
						</creationdate>
					</xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
<!--Publisher (more)-->
	<!--This matches the NUL Voyager mapping-->
	<xsl:template match="mods:note[@type='thesis']" mode="display">
		<publisher>
			<xsl:value-of select="normalize-space(.)"/>
		</publisher>
	</xsl:template>

	<!--Creation date-->
	<xsl:template match="mods:originInfo" mode="search">
		<xsl:call-template name="creationdate"/>
		<xsl:if test="mods:publisher">
			<general>
				<xsl:value-of select="mods:publisher"/>
			</general>
		</xsl:if>
	</xsl:template>
	<xsl:template match="mods:originInfo" mode="facets">
		<xsl:call-template name="creationdate"/>
	</xsl:template>
	<xsl:template match="mods:originInfo" mode="sort">
		<xsl:call-template name="creationdate">
			<!--append 13 to the end of the date because sorting includes records with yyyymm-->
			<xsl:with-param name="appendtext">13</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
<!--Format-->
	<xsl:template match="mods:physicalDescription" mode="display">
		<xsl:choose>
<!--If there is a missing extent in the EAD, the MODS physicalDescription/extent element will be "NaN". Just skip pnx:format if that's the case.-->
			<xsl:when test="mods:extent != 'NaN ' and mods:extent != ''">
				<format>
					<xsl:for-each select="mods:extent">
						<xsl:if test="preceding-sibling::mods:extent">
							<xsl:text>, </xsl:text>
						</xsl:if>
						<xsl:value-of select="normalize-space(.)"/>
					</xsl:for-each>
				</format>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="mods:note[@type]">
					<format>
					<xsl:value-of select="mods:note[@type!='leaf']"/>
					</format>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
<!--Identifier-->
	<xsl:template match="mods:identifier" mode="display">
		<xsl:variable name="type" select="translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
		<xsl:choose>
			<xsl:when test="contains ('isbn issn', $type)">
				<identifier>
					<xsl:value-of select="$type"/>: <xsl:value-of select="."/>
				</identifier>
			</xsl:when>
			<!--This is specific to Winterton-->
			<xsl:otherwise>
				<xsl:if test="@displayLabel='Object ID'">
					<identifier>
						<xsl:value-of select="@displayLabel"/>: <xsl:value-of select="."/>
					</identifier>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

<!--Language-->
	<!--xsl:template match="mods:language[1]" mode="display"-->
	<xsl:template match="mods:language[1]" mode="display">	
		<!--language>
			<xsl:for-each select="../mods:language[mods:languageTerm[@type='code'] != '']">
				<xsl:value-of select="mods:languageTerm[@type='code']"/>
				<xsl:if test="following-sibling::mods:language[mods:languageTerm]"> ; </xsl:if>
			</xsl:for-each>
			<xsl:if test="not(../mods:language[mods:languageTerm[@type='code']])">
				<xsl:for-each select="../mods:language/mods:languageTerm">
				<xsl:if test="following-sibling::mods:language"> ; </xsl:if>
			</xsl:for-each>
			
			</xsl:if>
		</language-->
		
		<language>
			<xsl:for-each select="../mods:language">
				<xsl:choose>
					<xsl:when test="mods:languageTerm[@type='code'] != ''">
						<xsl:value-of select="mods:languageTerm[@type='code']"/>
						<xsl:if test="following-sibling::mods:language[mods:languageTerm]"> ; </xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="mods:languageTerm"/>
						<xsl:if test="following-sibling::mods:language"> ; </xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</language>
	</xsl:template>	
	
	<!--Record multiple languages in separate elements for the facets section-->
	<xsl:template match="mods:language" mode="facets">
		<xsl:for-each select="mods:languageTerm[@type='code']">
			<language>
				<xsl:value-of select="normalize-space(.)"/>
			</language>
		</xsl:for-each>
	</xsl:template>

	<!--Subject-->
	<!--Dump MODS elements geographicGode and cartographics-->
	<!--xsl:template match="mods:subject[mods:geographicCode]"/-->
	<xsl:template match="mods:geographicCode" mode="subject"/>
	<xsl:template match="mods:cartographics" mode="subject"/>

	<!--here is where the subjects are munged together-->
	<xsl:template match="mods:*" mode="subject">
		<xsl:if test="preceding-sibling::mods:*">--</xsl:if>
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>
	<xsl:template match="mods:name" mode="subject">
		<xsl:if test="preceding-sibling::mods:*">--</xsl:if>
		<xsl:call-template name="name"/>
	</xsl:template>
	<xsl:template match="mods:titleInfo" mode="subject">
		<xsl:if test="preceding-sibling::mods:*">--</xsl:if>
		<xsl:call-template name="title"/>
	</xsl:template>
	<xsl:template match="mods:hierarchicalGeographic" mode="subject">
		<xsl:for-each select="mods:*">
			<xsl:value-of select="normalize-space(.)"/>
			<xsl:if test="following-sibling::mods:*">--</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
<!--Subjects are put into one element in the Display section-->
	<xsl:template match="mods:subject[1]" mode="display">
		<subject>
			<!--This is here to accommodate records that came from VRA Core that have
	display field with more accurately subdivided subjects headings than those in the subject fields-->
			<xsl:choose>
				<xsl:when test="@displayLabel='display'">
					<xsl:value-of select="descendant-or-self::text()"/>
				</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="../mods:subject[not(mods:geographicCode | mods:cartographics | ancestor::mods:relatedItem)]">
					<xsl:apply-templates select="mods:*" mode="subject"/>
					<xsl:if test="following-sibling::mods:subject[not(mods:cartographics | mods:geographicCode)]"> ; </xsl:if>
				</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</subject>
	</xsl:template>

	<!--Subjects go into separate elements for the Search section-->
	<xsl:template match="mods:subject[mods:topic | mods:geographic | mods:temporal | mods:titleInfo | mods:name | mods:occupation | mods:hierarchicalGeographic | mods:genre]" mode="search">
		<subject>
			<xsl:apply-templates select="mods:*" mode="subject"/>
		</subject>
	</xsl:template>

	<!--Subjects go into separate elements for facets section and, for some odd reason, are now Topics.-->
	<!--here is where the Facet topics are munged together; similar to the Subjects, but separates out Genre-->
	<!--Topic-->
	<xsl:template match="mods:subject[mods:topic | mods:geographic | mods:temporal | mods:titleInfo | mods:name | mods:occupation | mods:hierarchicalGeographic]" mode="facets" priority="1">
		<xsl:if test="not(@displayLabel='display')">
			<topic>
				<xsl:apply-templates select="mods:*" mode="subject"/>
			</topic>
		</xsl:if>
	</xsl:template>
	
<!--Genre-->
<!--Note that <mods:genre> by itself doesn't end up anywhere in the PNX. It's only included if it's a child of <subject>-->
<!--This might be an issue with VRA Core, which does generate a <mods:genre> element outside of <subject>, but not sure where it should go in the PNX.-->
	<xsl:template match="mods:subject/mods:genre | mods:genre" mode="facets">
		<genre>
			<!--xsl:value-of select="normalize-space(mods:genre[1])"/--> <!--I'm not sure why I was selecting only the first genre. Maybe this will come back to bite me later, but I need the simpler one for the finding aids.-->
			<xsl:value-of select="normalize-space(.)"/>
		</genre>
	</xsl:template>
	
<!--Relation-->
	<xsl:template match="mods:*" mode="series">
		<xsl:for-each select="mods:titleInfo/mods:*">
			<xsl:if test="normalize-space(.)!= ''">
				<xsl:value-of select="normalize-space(.)"/>
				<xsl:text> </xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:if test="following-sibling::mods:relatedItem[@type='series']">; </xsl:if>
	</xsl:template>

	<xsl:template match="mods:relatedItem[@type='series'][1]" mode="display" >
		<relation>
			<xsl:text>series </xsl:text>
			<xsl:apply-templates select="//mods:relatedItem[@type='series']" mode="series"/>
		</relation>
	</xsl:template>
	
	<xsl:template match="mods:relatedItem[@type='constituent']" mode="display" >
		<relation>
			<xsl:text>includes </xsl:text>
			<xsl:for-each select="mods:titleInfo/mods:*">
				<xsl:if test="normalize-space(.)!= ''">
					<xsl:value-of select="normalize-space(.)"/>
						<xsl:if test="position() != last()">
							<xsl:text> ; </xsl:text>
						</xsl:if>
				</xsl:if>
			</xsl:for-each>
		</relation>
	</xsl:template>	
		
	<xsl:template match="mods:relatedItem[@type and not(@type='series') and not(@type='constituent') and not(@type='host')]" mode="display">
		<relation>
			<xsl:choose>
				<xsl:when test="@type='preceding'">
					<xsl:text>preceding: </xsl:text>
				</xsl:when>
				<xsl:when test="@type='succeeding'">
					<xsl:text>succeeding: </xsl:text>
				</xsl:when>
				<xsl:when test="@type='original'">
					<xsl:text>original: </xsl:text>
				</xsl:when>
				<xsl:when test="@type='otherVersion'">
					<xsl:text>other version: </xsl:text>
				</xsl:when>
				<xsl:when test="@type='otherFormat'">
					<xsl:text>other format: </xsl:text>
				</xsl:when>
				<xsl:when test="@type='isReferencedBy'">
					<xsl:text>is referenced by: </xsl:text>
				</xsl:when>
				<xsl:when test="@type='references'">
					<xsl:text>references: </xsl:text>
				</xsl:when>
				<xsl:when test="@type='reviewOf'">
					<xsl:text>review of: </xsl:text>
				</xsl:when>
			</xsl:choose>
			<xsl:for-each select="mods:titleInfo/mods:* | mods:identifier">
				<xsl:text> </xsl:text>
					<xsl:value-of select="normalize-space(.)"/>
			</xsl:for-each>
		</relation>
	</xsl:template>
	
<!--isPartOf--><!--Added a test to see if there are multiple Collection names, since this element displays all on one line in Primo/kdm Oct. 30, 2020-->
<!--Removed the test to add a preceding comma if there are multiple Collection names, as Primo VE is displaying them on two lines in detailed results and separates them with a semi-colon in the brief results-->
	<xsl:template match="mods:relatedItem[@type='host']" mode="display">
		<ispartof>
			<!--xsl:for-each select="mods:titleInfo/mods:* | mods:name/mods:namePart">
				<xsl:if test="normalize-space(.)!= ''">
					<xsl:value-of select="normalize-space(.)"/>
					<xsl:text> </xsl:text>
				</xsl:if>
			</xsl:for-each-->
			<!--xsl:value-of select="$collection_name"/-->
			<!--xsl:value-of select="mods:titleInfo/mods:title"/--><!--20190827: changed this to replace semi-colons with commas, since semi-colons tell the display to split the field-->		<!--xsl:if test="preceding-sibling::mods:relatedItem[@type='host']/mods:titleInfo/mods:title">, </xsl:if-->
				<xsl:value-of select="replace(mods:titleInfo/mods:title, ';', ',')"/>
		</ispartof>
	</xsl:template>
	
<!--Relation (Series, Related URL-->
	<xsl:template match="mods:relatedItem[not(@type='host') and not(@otherType='Related URL')]" mode="display">
		<xsl:for-each select=".">
			<relation>
				<xsl:choose>
					<xsl:when test="@type='series'">
						<xsl:value-of select="normalize-space(mods:titleInfo/mods:title)"/>
					</xsl:when>
					<xsl:when test="@type='otherFormat'">
						<xsl:value-of select="normalize-space(mods:location/mods:url)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="descendant-or-self::text()"/>
					</xsl:otherwise>
				</xsl:choose>
			</relation>
		</xsl:for-each>
	</xsl:template>

<!--Rights-->
	<xsl:template match="mods:accessCondition" mode="display">
		<rights>
			<xsl:if test="attribute(displayLabel)">
				<xsl:value-of select="attribute(displayLabel)"/>
				<xsl:text>: </xsl:text>
			</xsl:if>
			<xsl:value-of select="normalize-space(.)"/>
		</rights>
	</xsl:template>

<!--AvailLibrary-->
	<xsl:template match="mods:location" mode="display">
		<xsl:if test="mods:physicalLocation | mods:shelfLocator | mods:holdingExternal">
			<lds18>
				<xsl:choose>
					<xsl:when test="contains(mods:physicalLocation,'Galter')">
						<xsl:text>Galter Health Sciences Library (Chicago)</xsl:text>
						<xsl:text>Galter Health Sciences Library: Special Collections</xsl:text>
					</xsl:when>
					<xsl:when test="contains(mods:physicalLocation,'Pritzker')">
						<xsl:text>Law Library (Chicago)</xsl:text>
						<xsl:text>Law Library: X,MSS (Rare Book Room)</xsl:text>
					</xsl:when>
					<xsl:when test="contains(mods:physicalLocation,'Transportation')">
						<xsl:text>Main Library </xsl:text>
						<xsl:text>TRANSPORTATION Library</xsl:text>
					</xsl:when>
					<xsl:when test="contains(mods:physicalLocation, 'African')">
						<xsl:text>Main Library </xsl:text>
						<xsl:text>AFRICANA (Archives)</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Deering Library </xsl:text>
						<xsl:choose>
							<xsl:when test="contains(mods:physicalLocation, 'Archives')">
								<xsl:text>UNIVERSITY ARCHIVES</xsl:text>
							</xsl:when>
							<xsl:when test="contains(mods:physicalLocation, 'Special')">
								<xsl:text>SPECIAL COLLECTIONS (Deering library)</xsl:text>
							</xsl:when>
							<xsl:when test="contains(mods:physicalLocation, 'Music')">
								<xsl:text>MUSIC Library (Rare) (Non-circulating)</xsl:text>
							</xsl:when>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text> </xsl:text>
				<xsl:value-of select="mods:shelfLocator"/>
			</lds18>
		</xsl:if>
	</xsl:template>
	
<!--Table of Contents (User defined field lds01)-->
	<xsl:template match="mods:tableOfContents" mode="display">
		<xsl:if test="string-length(.)>0">
			<lds01>
				<xsl:value-of select="normalize-space(.)"/>
			</lds01>
		</xsl:if>
	</xsl:template>
	
<!--Summary (User defined field lds02)-->
	<xsl:template match="mods:abstract" mode="display">
		<xsl:if test="string-length(.)>0">
			<lds02>
				<xsl:value-of select="normalize-space(.)"/>
			</lds02>
		</xsl:if>
	</xsl:template>

<!--Links section-->
	<xsl:template match="mods:location[mods:url/@access='object in context']" mode="links">
		<linktorsrc>
			<xsl:value-of select="mods:url[@access='object in context']"/><xsl:text>Link to </xsl:text>
			<xsl:choose>
				<xsl:when test="mods:url[@access='object in context']/@displayLabel">
					<xsl:value-of select="mods:url[@access='object in context']/@displayLabel"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text> source </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text> in </xsl:text>				
			 <!--xsl:value-of select="$collection_name"/-->
			 <xsl:value-of select="../mods:relatedItem[@type='host'][@otherType='sourceSystem']/mods:titleInfo/mods:title"/>				 
			<xsl:text>01NWU</xsl:text>
		</linktorsrc>
			
			<!--Added 20190828 to accommodate Glaze related_url element-->
		<xsl:if test="../mods:relatedItem[@otherType='Related URL']/mods:location/mods:url">
			<additionallinks>
				<xsl:value-of select="../mods:relatedItem[@otherType='Related URL']/mods:location/mods:url"/><xsl:text>Link to related URL</xsl:text>
				<xsl:text>01NWU</xsl:text>
			</additionallinks>
		</xsl:if>
			
			<xsl:if test="mods:url[@note='thumbnail']">
				<thumbnail>
					<xsl:value-of select="mods:url[@note='thumbnail']"/>
				</thumbnail>			
			</xsl:if>
						
	</xsl:template>
	
	

<!--Search section-->
<!--ISBN-->
	<xsl:template match="mods:identifier[@type='isbn']" mode="search">
		<isbn>
			<xsl:value-of select="."/>
		</isbn>
	</xsl:template>
	
<!--ISSN-->
	<xsl:template match="mods:identifier[@type='issn']" mode="search">
		<issn>
			<xsl:value-of select="."/>
		</issn>
	</xsl:template>

<!--FullText. This will be used for finding aids; make sure to dump entirety of finding aid into a mods:note[@type='fulltext']!-->
	<xsl:template match="mods:note[@type='fulltext']" mode="search">
		<fulltext>
			<xsl:value-of select="normalize-space(.)"/>
		</fulltext>
	</xsl:template>
	
<!--TOC-->
	<xsl:template match="mods:tableOfContents" mode="search">
		<toc>
			<xsl:value-of select="normalize-space(.)"/>
		</toc>
	</xsl:template>

<!--Record Identifiers-->
	<xsl:template match="mods:identifier" mode="search">
		<recordid>
			<xsl:value-of select="."/>
		</recordid>
	</xsl:template>
		
<!--General; note that this matches the NUL Voyager mapping-->
	<xsl:template match="mods:note[@type='thesis'] | mods:note[@type='original version'] | mods:note[@type='venue'] | mods:note[@type='creation/production credits']" mode="search">
		<general>
			<xsl:value-of select="normalize-space(.)"/>
		</general>
	</xsl:template>
	<xsl:template match="mods:targetAudience" mode="search">
		<general>
			<xsl:value-of select="normalize-space(.)"/>
		</general>
	</xsl:template>
	
<!--User-defined element lsr01. This matches the Voyager mapping, although that mapping also puts the call number into <availlibrary>-->
	<xsl:template match="mods:classification" mode="search">
		<lsr01>
			<xsl:value-of select="."/>
		</lsr01>
	</xsl:template>
	
	<xsl:template match="mods:recordInfo" mode="search">
		<xsl:if test="mods:recordInfoNote='item'">
			<cdparentid>
				<xsl:value-of select="../mods:relatedItem[@type='host']/mods:identifier[@displayLabel='PID']"/>
			</cdparentid>
		</xsl:if>
	</xsl:template>
	
<!--Facets section-->
<!--Rsrctype and Prefilter-->
<!--Note that this is similar to but not exactly the same as Type element in other sections-->
	<xsl:template match="mods:typeOfResource" mode="facets">
		<xsl:variable name="resourceType">
			<xsl:choose><!--Removing the test for collection-->
				<!--xsl:when test="@collection='yes'">
					<xsl:text>other</xsl:text>
				</xsl:when-->
				<xsl:when test=".='text'">
					<xsl:choose>
						<xsl:when test="../mods:originInfo/mods:issuance='monographic'">
							<xsl:text>books</xsl:text>
						</xsl:when>
						<xsl:when test=" ../mods:genre='periodical'">
							<xsl:text>journals</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>text_resources</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
			<xsl:if test=".='book'">
				<xsl:text>books</xsl:text>
			</xsl:if>
			<xsl:if test=".='cartographic'">
				<xsl:text>maps</xsl:text>
			</xsl:if>
			<xsl:if test=".='dissertation'">
				<xsl:text>dissertation</xsl:text>
			</xsl:if>
			<xsl:if test=".='article'">
				<xsl:text>article</xsl:text>
			</xsl:if>			
			<xsl:if test=".='mixed material'">
				<xsl:text>others</xsl:text>
			</xsl:if>
			<xsl:if test=".='notated music'">
				<xsl:text>scores</xsl:text>
			</xsl:if>
			<xsl:if test="starts-with(.,'sound recording')">
				<xsl:text>audio</xsl:text>
			</xsl:if>
			<xsl:if test=".='still image'">
				<xsl:text>images</xsl:text>
			</xsl:if>
			<xsl:if test=".='moving image'">
				<xsl:text>video</xsl:text>
			</xsl:if>
			<xsl:if test=".='three dimensional object'">
				<xsl:text>others</xsl:text>
			</xsl:if>
			<xsl:if test=". ='software, multimedia'">
				<xsl:text>other</xsl:text>
			</xsl:if>
			<xsl:if test=". ='other'">
				<xsl:text>other</xsl:text>
			</xsl:if>
		</xsl:variable>
		<rsrctype>
			<xsl:value-of select="$resourceType"/>
		</rsrctype>
		<prefilter>
			<xsl:value-of select="$resourceType"/>
		</prefilter>
	</xsl:template>
	
<!--Collection-->
	<!--Note that the MODS extension element is not currently being used; I've added this for future use.-->
	<!--Also note that there are two collection elements hard coded into the top of the stylesheet based on current mappings from Voyager records.-->
	<xsl:template match="mods:extension" mode="facets">
		<lfc05>
			<xsl:value-of select="mods:collection"/>
		</lfc05>
	</xsl:template>

	<xsl:template match="mods:relatedItem[@type='host']" mode="facets">
		<xsl:for-each select="mods:titleInfo/mods:title">
			<lfc05>
				<xsl:value-of select="."/>
			</lfc05>
		</xsl:for-each>
	</xsl:template>
	
	
	
<!--Library-->
		<xsl:template match="mods:location[mods:physicalLocation]" mode="facets">
			<library>
				<xsl:choose>
					<xsl:when test="contains(mods:physicalLocation,'Galter')">
						<xsl:text>HSL</xsl:text>
					</xsl:when>
					<xsl:when test="contains(mods:physicalLocation,'Pritzker')">
						<xsl:text>LAW</xsl:text>
					</xsl:when>
					<xsl:when test="contains(mods:physicalLocation, 'African')">
						<xsl:text>MAIN</xsl:text>
					</xsl:when>
					<xsl:when test="contains(mods:physicalLocation, 'Transportation')">
						<xsl:text>MAIN</xsl:text>
					</xsl:when>	
					<xsl:when test="contains(mods:physicalLocation, 'Government')">
						<xsl:text>MAIN</xsl:text>
					</xsl:when>
					<xsl:when test="contains(mods:physicalLocation, 'Archives')">
						<xsl:text>DEER</xsl:text>
					</xsl:when>
					<xsl:when test="contains(mods:physicalLocation, 'Special')">
						<xsl:text>DEER</xsl:text>
					</xsl:when>
					<xsl:when test="contains(mods:physicalLocation, 'Music')">
						<xsl:text>DEER</xsl:text>
					</xsl:when>
				</xsl:choose>
			</library>
			<lfc05>
				<xsl:choose>
					<xsl:when test="contains(mods:physicalLocation,'Galter')">
						<xsl:text>Galter Health Sciences Library</xsl:text>
					</xsl:when>
					<xsl:when test="contains(mods:physicalLocation,'Pritzker')">
						<xsl:text>Law Library</xsl:text>
					</xsl:when>
					<xsl:when test="contains(mods:physicalLocation, 'African')">
						<xsl:text>Africana Library</xsl:text>
					</xsl:when>
					<xsl:when test="contains(mods:physicalLocation, 'Transportation')">
						<xsl:text>Transportation Library</xsl:text>
					</xsl:when>	
					<xsl:when test="contains(mods:physicalLocation, 'Government')">
						<xsl:text>Government &amp; Geographic Information Collection</xsl:text>
					</xsl:when>	
					<xsl:when test="contains(mods:physicalLocation, 'Archives')">
						<xsl:text>Archives</xsl:text>
					</xsl:when>
					<xsl:when test="contains(mods:physicalLocation, 'Special')">
						<xsl:text>Special Collections</xsl:text>
					</xsl:when>
					<xsl:when test="contains(mods:physicalLocation, 'Music')">
						<xsl:text>Music Library</xsl:text>
					</xsl:when>
				</xsl:choose>
			</lfc05>
	</xsl:template>
	
<!--Delivery section-->
	<!--Delcategory. This could be hard-coded as "Online Resources", but I think it's best to assume some might not be. This might need some work in the future.-->
	<!--xsl:template match="mods:physicalDescription" mode="delivery">
		<xsl:if test="mods:form">
			<delcategory>Online Resource</delcategory>
				<xsl:choose>
					<xsl:when test="starts-with(mods:form[@authority='marcform'], 'print')">Physical Item</xsl:when>
					<xsl:when test="starts-with(mods:form[@authority='marcform'], 'electronic')">Online Resource</xsl:when>
					<xsl:when test="starts-with(mods:form[@authority='gmd'], 'electronic')">Online Resource</xsl:when>
				</xsl:choose>
		</xsl:if>
		<xsl:if test="../mods:recordInfo/mods:recordOrigin='Glaze' or ../mods:recordInfo/mods:recordOrigin='Arch'">
			<delcategory>Online Resource</delcategory>
		</xsl:if>
	</xsl:template-->
	
<!--Dedup section-->
	<xsl:template match="mods:recordInfo" mode="dedup">
		<xsl:if test="mods:recordOrigin='Glaze' or mods:recordOrigin='Arch'">
			<t>99</t>
		</xsl:if>
	</xsl:template>
	
<!--Ranking section-->
	<!--xsl:template match="mods:language[mods:languageTerm]" mode="ranking">
		<xsl:choose>
			<xsl:when test="mods:languageTerm[@type='code']='eng'">25</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:template-->

	<!-- suppress all else:-->
	<xsl:template match="*" mode="#all"/>
	
	<!--Named templates-->
	<xsl:template name="title">
		<xsl:variable name="Title">
			<xsl:choose>
				<xsl:when test="ends-with(mods:nonSort,' ')">
					<xsl:value-of select="mods:nonSort"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="mods:nonSort">
						<xsl:value-of select="mods:nonSort"/>
						<xsl:text> </xsl:text>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="ends-with(mods:title,':')">
					<xsl:value-of select="substring-before(mods:title, ':')"/>
				</xsl:when>
				<xsl:when test="ends-with(normalize-space(mods:title),'/')">
					<xsl:value-of select="normalize-space(substring-before(mods:title, '/'))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="mods:title"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="ends-with(mods:subTitle,'/')">
					<xsl:text>: </xsl:text>
					<xsl:value-of select="normalize-space(substring-before(mods:subTitle, '/'))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="mods:subTitle">
						<xsl:text> : </xsl:text>
						<xsl:value-of select="mods:subTitle"/>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="mods:partNumber">
				<xsl:text>. </xsl:text>
				<xsl:value-of select="mods:partNumber"/>
			</xsl:if>
			<xsl:if test="mods:partName">
				<xsl:text>. </xsl:text>
				<xsl:value-of select="mods:partName"/>
			</xsl:if>
		</xsl:variable>
		<xsl:value-of select="$Title"/>
	</xsl:template>

<xsl:template name="name">
	<xsl:variable name="name">
		<xsl:choose>
			<xsl:when test="mods:displayForm">
				<xsl:value-of select="mods:displayForm"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="mods:namePart[not(@type)]">
					<xsl:value-of select="normalize-space(.)"/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
				<xsl:value-of select="mods:namePart[@type='family']"/>
				<xsl:if test="mods:namePart[@type='given']">
					<xsl:if test="not(substring(mods:namePart,string-length(mods:namePart))=',')">
						<xsl:text>, </xsl:text>
					</xsl:if>
					<xsl:value-of select="mods:namePart[@type='given']"/>
				</xsl:if>
				<xsl:if test="mods:namePart[@type='date']">
					<xsl:if test="ends-with(modsnamePart,',')">
						<xsl:text>, </xsl:text>
					</xsl:if>
					<xsl:value-of select="mods:namePart[@type='date']"/>
					<xsl:text/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="ends-with(normalize-space($name), ',')">
			<xsl:value-of select="substring(normalize-space($name),1,string-length(normalize-space($name))-1)"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="normalize-space($name)"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

	<xsl:template name="type">
		<xsl:variable name="Type">
			<xsl:choose>
				<!--I've taken out the test for collection because it wasn't resulting in a resource type that made sense.-->
				<!--xsl:when test="@collection='yes'">
					<xsl:text>other</xsl:text>
				</xsl:when-->
				<xsl:when test=".='text'">
					<xsl:choose>
						<xsl:when test="../mods:originInfo/mods:issuance='monographic'">
							<xsl:text>book</xsl:text>
						</xsl:when>
						<xsl:when test=" ../mods:genre='periodical'">
							<xsl:text>journal</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>text_resource</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
			<xsl:if test=".='book'">
				<xsl:text>book</xsl:text>
			</xsl:if>
			<xsl:if test=".='cartographic'">
				<xsl:text>map</xsl:text>
			</xsl:if>
			<xsl:if test=".='dissertation'">
				<xsl:text>dissertation</xsl:text>
			</xsl:if>
			<xsl:if test=".='article'">
				<xsl:text>article</xsl:text>
			</xsl:if>			
			<xsl:if test=".='mixed material'">
				<xsl:text>mixed</xsl:text>
			</xsl:if>
			<xsl:if test=".='notated music'">
				<xsl:text>score</xsl:text>
			</xsl:if>
			<xsl:if test="starts-with(.,'sound recording')">
				<xsl:text>audio</xsl:text>
			</xsl:if>
			<xsl:if test=".='still image'">
				<xsl:text>image</xsl:text>
			</xsl:if>
			<xsl:if test=".='moving image'">
				<xsl:text>video</xsl:text>
			</xsl:if>
			<xsl:if test=".='three dimensional object'">
				<xsl:text>other</xsl:text>
			</xsl:if>
			<xsl:if test=". ='software, multimedia'">
				<xsl:text>other</xsl:text>
			</xsl:if>
			<xsl:if test=". ='other'">
				<xsl:text>other</xsl:text>
			</xsl:if>
		</xsl:variable>
		<xsl:value-of select="$Type"/>
	</xsl:template>

<xsl:template name="creationdate">
		<xsl:param name="appendtext"/>
		<xsl:if test="mods:dateIssued | mods:dateCreated">
			<creationdate>
			
			<xsl:choose>
				<xsl:when test="mods:dateIssued">
					<xsl:choose>
						<xsl:when test="mods:dateIssued[@encoding='marc']">
							<xsl:choose>
								<xsl:when test="mods:dateIssued[@point='start']">
									<xsl:value-of select="mods:dateIssued[@point='start']"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="mods:dateIssued[@encoding='marc']"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="mods:dateIssued"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="mods:dateCreated">
					<xsl:choose>
						<xsl:when test="mods:dateCreated[@encoding='marc']">
							<xsl:choose>
								<xsl:when test="mods:dateCreated[@point='start']">
									<xsl:value-of select="mods:dateCreated[@point='start']"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="mods:dateCreated[@encoding='marc']"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="mods:dateCreated"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
			<xsl:value-of select="$appendtext"/>
			</creationdate>
		</xsl:if>
	</xsl:template>

	<xsl:template name="sourceid">
		<!--xsl:value-of select="$collection_name"/-->
		<xsl:value-of select="../mods:relatedItem[@type='host']/mods:titleInfo/mods:title"/>		
	</xsl:template>
	
	<xsl:template name="sourcesystem">
		<xsl:choose>
			<xsl:when test="mods:recordOrigin">
				<xsl:value-of select="mods:recordOrigin"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Fedora</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>
