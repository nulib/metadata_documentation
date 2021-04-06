<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="mods" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:discovery="https://dc.library.northwestern.edu/"
xmlns:dcterms="http://www.dublincore.org/schemas/xmls/qdc/dcterms.xsd"
xmlns:dc="http://www.dublincore.org/schemas/xmls/qdc/dcterms.xsd">

<!-- This stylesheet transforms MODS version 3.5 records Dublin Core that is customized for use in Primo VE.
This stylesheet has been developed for use with the Northwestern University Library archival and manuscript collections MODS records
 (derived from their original source records in EAD), the Northwestern University Digital Collections, and Northwestern University's
Arch institutional repository. It is copied from the MODS to DC crosswalk at http://www.loc.gov/standards/mods/MODS3-22simpleDC.xsl.
Edited by Karen Miller to meet the needs of NUL.	-->
<!--March 2021, created from code that creates Primo PNX-->

<!--@encoding below needs to be us-ascii to deal with diacritics-->
	<xsl:output method="xml" indent="yes" omit-xml-declaration="no" encoding="us-ascii" media-type="text/xml"/>	
	<xsl:strip-space elements="*"/>
	
	<xsl:template match="/">
		<pnx>
			<xsl:for-each select="//mods:mods">
		
				<xsl:variable name="collection_name">
					<xsl:value-of select="mods:relatedItem[@type='host']/mods:titleInfo/mods:title"/>
				</xsl:variable>			

				<record>
			
					<xsl:apply-templates mode="display"/><!--some of the elements get used twice and this allows nodes to get matched more than one-->
					<xsl:apply-templates/>

					<xsl:if test="mods:recordInfo/mods:recordOrigin='Archon' or mods:recordInfo/mods:recordOrigin='ArchivesSpace' ">
						<discovery:local28>01NWU_EAD</discovery:local28>
					</xsl:if>
					<xsl:if test="mods:recordInfo/mods:recordOrigin='Glaze'">
						<discovery:local28>01NWU_GLAZE</discovery:local28>
					</xsl:if>
					<xsl:if test="mods:recordInfo/mods:recordOrigin='Arch'">
						<discovery:local28>01NWU_ARCH</discovery:local28>
					</xsl:if>
					<discovery:local28>Northwestern University Library (Evanston, Ill.)</discovery:local28>
					<discovery:local28>
						<xsl:value-of select="$collection_name"/>
					</discovery:local28>
					
				</record>
			</xsl:for-each>
		</pnx>
	</xsl:template>

	<xsl:template match="mods:modsCollection"/>

	<!--Creator, Contributor-->
	<xsl:template match="mods:name[1]" mode="display">
		
		<!--Creators-->
		<xsl:for-each select="../mods:name[mods:role/mods:roleTerm[@type='text']='Creator' or mods:role/mods:roleTerm[@type='text']='creator' or mods:role/mods:roleTerm[@type='code']='cre']">
			<dc:creator>
				<xsl:call-template name="name"/>
			</dc:creator>
		</xsl:for-each>
			
		<!--Contributors-->	
		<xsl:for-each select="../mods:name[not(mods:role/mods:roleTerm[@type='text']='Creator' or mods:role/mods:roleTerm[@type='text']='creator' or mods:role/mods:roleTerm[@type='code']='cre')]">
			<dcterms:contributor>
				<xsl:call-template name="name"/>
			</dcterms:contributor>
		</xsl:for-each>
		
	</xsl:template>
		
	<!--For searching purposes, replace ampersands in names with "and"-->
	<xsl:template match="mods:name" mode="search">
		<discovery:local28>
			<xsl:call-template name="name"/>
		</discovery:local28>
		<xsl:if test="contains(mods:namePart, '&amp;')">
			<discovery:local28>
				<xsl:value-of select="replace(mods:namePart, '&amp;', 'and')"/>
			</discovery:local28>
		</xsl:if>
		<xsl:if test="contains(mods:namePart, ' and ')">
			<discovery:local28>
				<xsl:value-of select="replace(mods:namePart, ' and ', ' &amp; ')"/>
			</discovery:local28>
		</xsl:if>
	</xsl:template>
	
	<!--Title-->
	<xsl:template match="mods:titleInfo[1]">
		<dcterms:title>
			<xsl:call-template name="title"/>
			<xsl:if test="../mods:note[@type='statement of responsibility']">
				<xsl:text> / </xsl:text>
				<xsl:value-of select="../mods:note[@type='statement of responsibility']"/>
			</xsl:if>
		</dcterms:title>
	
		<!--Replace "and" or "&" to facilitate discovery-->
		<xsl:if test="contains(mods:title, '&amp;')">
			<discovery:local24>
				<xsl:value-of select="replace(mods:title, '&amp;', 'and')"/>
			</discovery:local24>
		</xsl:if>
		
		<xsl:if test="contains(mods:title, ' and ')">
			<discovery:local24>
				<xsl:value-of select="replace(mods:title, ' and ', ' &amp; ')"/>
			</discovery:local24>
		</xsl:if>
		
	</xsl:template>
	
	<!--Series -->
	<xsl:template match="mods:relatedItem[not(@type='host') and not(@otherType='Related URL')]" mode="display">
		<xsl:for-each select=".">
			<discovery:local22>
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
			</discovery:local22>
		</xsl:for-each>
	</xsl:template>

	<!--Edition, Publisher, Creationdate for Display-->
	<xsl:template match="mods:originInfo" mode="display">
	
		<xsl:if test="mods:edition">
			<discovery:local28>
				<xsl:value-of select="mods:edition"/>
			</discovery:local28>
		</xsl:if>
		
		<xsl:for-each select="mods:publisher">
			<dc:publisher>
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
			</dc:publisher>
		</xsl:for-each>
		
		<xsl:choose>
			<xsl:when test="../mods:genre='finding aid'"/>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="mods:dateIssued[not(@encoding='marc')]">
						<dcterms:date>
							<xsl:value-of select="mods:dateIssued[not(@encoding='marc')]"/>
						</dcterms:date>
					</xsl:when>
					<xsl:when test="mods:dateCreated[not(@encoding='marc')]">
						<dcterms:date>
							<xsl:value-of select="mods:dateCreated[not(@encoding='marc')]"/>
						</dcterms:date>
					</xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!--Publisher (more)-->
	<xsl:template match="mods:note[@type='thesis']" mode="display">
		<dc:publisher>
			<xsl:value-of select="normalize-space(.)"/>
		</dc:publisher>
	</xsl:template>
	
	<!--Language-->
	<xsl:template match="mods:language">	
		<dc:language>
			<xsl:choose>
				<xsl:when test="mods:languageTerm[@type='code'] != ''">
					<xsl:value-of select="mods:languageTerm[@type='code']"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="mods:languageTerm"/>
					<xsl:if test="following-sibling::mods:language"> ; </xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</dc:language>	
	</xsl:template>	
	
	<!--Format-->
	<xsl:template match="mods:physicalDescription">
		<xsl:choose>
			<!--If there is a missing extent in the EAD, the MODS physicalDescription/extent element will be "NaN". Just skip pnx:format if that's the case.-->
			<xsl:when test="mods:extent != 'NaN ' and mods:extent != ''">
				<dc:format>
					<xsl:for-each select="mods:extent">
						<xsl:if test="preceding-sibling::mods:extent">
							<xsl:text>, </xsl:text>
						</xsl:if>
						<xsl:value-of select="normalize-space(.)"/>
					</xsl:for-each>
				</dc:format>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="mods:note[@type]">
					<dc:format>
					<xsl:value-of select="mods:note[@type!='leaf']"/>
					</dc:format>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!--Summary (User defined field local 1)-->
	<xsl:template match="mods:abstract" mode="display">
		<xsl:if test="string-length(.)>0">
			<discovery:local1>
				<xsl:value-of select="normalize-space(.)"/>
			</discovery:local1>
		</xsl:if>
	</xsl:template>
		
	<!--Table of Contents (User defined field local47)-->
	<xsl:template match="mods:tableOfContents" mode="display">
		<xsl:if test="string-length(.)>0">
			<discovery:local47>
				<xsl:value-of select="normalize-space(.)"/>
			</discovery:local47>
		</xsl:if>
	</xsl:template>

	<!--Subject-->
	<!--Dump MODS elements geographicGode and cartographics-->
	<xsl:template match="mods:geographicCode"/>
	<xsl:template match="mods:cartographics"/>

	<!--Subjects go into separate elements for the Search section-->
	<xsl:template match="mods:subject[mods:topic | mods:geographic | mods:temporal | mods:titleInfo | mods:name | mods:occupation | mods:hierarchicalGeographic | mods:genre]">
		<dc:subject>
			<xsl:apply-templates select="mods:*" mode="subject"/>
		</dc:subject>
	</xsl:template>

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

	<!--Full text search note-->
	<!--Splits discovery:local28 into small chunks for Primo VE-->
	<xsl:template match="mods:note[@type='for indexing only']">
		<xsl:variable name="line-length" select="4000"/>
		<xsl:variable name="i">
			<xsl:value-of select="(string-length(normalize-space(.)) idiv $line-length)"></xsl:value-of>
		</xsl:variable>
		<xsl:variable name="string" select="normalize-space(.)"/>
		
			<xsl:choose>
				<xsl:when test="$i=0">
					<discovery:local28>
						<xsl:value-of select="$string"></xsl:value-of>
					</discovery:local28>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="0 to $i">
						<xsl:variable name="start" select="(.*$line-length)+1"/>
																												
						<discovery:local28>
							<xsl:value-of select="substring($string, $start, $line-length)"/>
						</discovery:local28>
						<!--this is a kludgy way to get a split word into the text search field. It does not solve the problem of quoted string searching-->
						<xsl:if test="not(ends-with(substring($string, $start, $line-length), ' ')) and not(substring($string, ((.+1)*$line-length)+1) eq ' ') and not(.=$i)">
							<discovery:local28>
								<xsl:value-of select="tokenize(substring($string, $start, $line-length), '\s+')[last()]"></xsl:value-of>
								<xsl:value-of select="substring-before(substring($string, ((.+1)*$line-length)+1, $line-length), ' ')"/>
							</discovery:local28>
						</xsl:if>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
				
	</xsl:template>
	
	<!--Description-->
	<!--This pulls in miscellaneous notes. It's specifically here to display Keywords from Arch records-->
	<xsl:template match="mods:note[not(@type='statement of responsibility') and not(@type='for indexing only')]" mode="display">
		<xsl:if test="../mods:relatedItem[@type='host']/mods:titleInfo/mods:title!='Northwestern University Library Archival and Manuscript Collections'">
			<discovery:local50>
				<xsl:value-of select="normalize-space(.)"/>
			</discovery:local50>
		</xsl:if>
	</xsl:template>
	
	<!--isPartOf--><!--Primo sees the semi-colon as a separator, so replace it in the collection name with a comma-->
	<xsl:template match="mods:relatedItem[@type='host']" mode="display">
		<dcterms:ispartof>
			<xsl:value-of select="replace(mods:titleInfo/mods:title, ';', ',')"/>
		</dcterms:ispartof>
	</xsl:template>
	
	<!--Resource Type-->
	<xsl:template match="mods:typeOfResource">
		<xsl:variable name="resourceType">
			<xsl:choose>
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
			<xsl:choose>
				<xsl:when test="../mods:genre='finding aid'">
					<xsl:text>finding_aid</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test=".='book'">
						<xsl:text>books</xsl:text>
					</xsl:if>
					<xsl:if test=".='cartographic'">
						<xsl:text>maps</xsl:text>
					</xsl:if>
					<xsl:if test=".='dissertation'">
						<xsl:text>dissertations</xsl:text>
					</xsl:if>
					<xsl:if test=".='article'">
						<xsl:text>articles</xsl:text>
					</xsl:if>
					<xsl:if test=".='mixed material'">
						<xsl:text>others</xsl:text>
					</xsl:if>
					<xsl:if test=".='notated music'">
						<xsl:text>scores</xsl:text>
					</xsl:if>
					<xsl:if test="starts-with(.,'sound recording')">
						<xsl:text>audios</xsl:text>
					</xsl:if>
					<xsl:if test=".='still image'">
						<xsl:text>images</xsl:text>
					</xsl:if>
					<xsl:if test=".='moving image'">
						<xsl:text>videos</xsl:text>
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
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<discovery:resourceType>
			<xsl:value-of select="$resourceType"/>
		</discovery:resourceType>
	</xsl:template>

	<!--Rights-->
	<xsl:template match="mods:accessCondition" mode="display">
		<dcterms:rights>
			<xsl:if test="attribute(displayLabel)">
				<xsl:value-of select="attribute(displayLabel)"/>
				<xsl:text>: </xsl:text>
			</xsl:if>
			<xsl:value-of select="normalize-space(.)"/>
		</dcterms:rights>
	</xsl:template>
	
	<!--Unique Record Identifier-->
	<xsl:template match="mods:recordInfo">
		<dc:identifier>
			<xsl:value-of select="normalize-space(mods:recordIdentifier[@source='IEN'])"/>
		</dc:identifier>
	</xsl:template>
	
	<!--Public Identifier-->
	<xsl:template match="mods:identifier[@displayLabel='ID']">
		<discovery:local46>
			<xsl:value-of select="."/>
		</discovery:local46>
	</xsl:template>
	
	<!--Repository + Call Number-->
	<xsl:template match="mods:location">
		<xsl:if test="mods:physicalLocation | mods:shelfLocator | mods:holdingExternal">
			<discovery:local45>
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
			</discovery:local45>
		</xsl:if>
	</xsl:template>
	
<!--Links section-->
	<xsl:template match="mods:location[mods:url/@access='object in context']">
		
		<dcterms:source>
			<xsl:value-of select="mods:url[@access='object in context']"/>
		</dcterms:source>
			
		<xsl:if test="mods:url[@note='thumbnail']">
			<dcterms:educationalLevel>
				<xsl:value-of select="mods:url[@note='thumbnail']"/>
			</dcterms:educationalLevel>		
		</xsl:if>
						
	</xsl:template>
	
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


</xsl:stylesheet>
