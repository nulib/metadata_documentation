<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:fn="http://www.w3.org/2005/xpath-functions" 
xmlns:xs="http://www.w3.org/2001/XMLSchema" 
xmlns:xlink="http://www.w3.org/1999/xlink" 
xmlns:ead="urn:isbn:1-931666-22-9" 
xmlns:mods="http://www.loc.gov/mods/v3"  
xmlns="http://www.loc.gov/mods/v3" 
 >
 
<!--This stylesheet transforms EAD records into MODS 3.5. Based on a stylesheet developed by Bill Parod, updated by Karen Miller in 2012 and 2014.-->
<!--Updated by Karen Miller in March 2017 to accommodate EAD exported from ArchivesSpace instead of from Archon-->
<!--This XSL creates one MODS file for each EAD record.-->
<!--ArchivesSpace is not exporting a URL; this has to be manually added to either the EAD, MODS or PNX-->
<!--Note that ArchivesSpace does not export the <bioghist> associated with an Agent record. This was exported from Archon, so this is a loss of information in the full text search capability of the PNX-->

<!--For use outside NUL, update the template named recordInfo to put in your institution's MARC code or something like it-->

<!--The eadid@URL value must be manually added to the EAD on export as of March 2017-->
    
<xsl:output method="xml" indent="yes" omit-xml-declaration="no"  media-type="text/xml" encoding="utf-8"/>
<xsl:strip-space elements="*"/>
<xsl:variable name="collection_name">Northwestern University Library Archival and Manuscript Collections</xsl:variable>

<xsl:template match="*">
	<mods xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/mods/v3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-7.xsd">

		<xsl:call-template name="titleInfo"/>
		<xsl:call-template name="name"/>
		<xsl:call-template name="typeOfResource"/>
		<xsl:call-template name="genre"/>			
		<xsl:call-template name="originInfo"/>
		<xsl:call-template name="language"/>
		<xsl:call-template name="physicalDescription"/>
		<xsl:call-template name="abstract"/>		
		<xsl:call-template name="tableOfContents"/>
		<xsl:call-template name="note"/>
		<xsl:call-template name="accessCondition"/>
		<xsl:call-template name="subjects"/>
		<xsl:call-template name="identifier"/>
		<xsl:call-template name="location"/>
		<xsl:call-template name="recordInfo"/>
		<xsl:call-template name="allElse"/>
		
		<relatedItem  type="host">
			<titleInfo><title><xsl:value-of select="$collection_name"/></title></titleInfo>
		</relatedItem>

	</mods>
</xsl:template>

<!--If the finding aid is not published, then it should produce no EAD-->
<xsl:template match="ead:ead[ead:archdesc/@audience='internal']">
	<titleInfo><title>This finding aid is not public.</title></titleInfo>
</xsl:template> 	
			
<!--titleInfo section-->
<xsl:template name="titleInfo">
	<titleInfo>
		<title>
			<!--select the titleproper that does not have @type='filing' and only select the text in it, not the subordinate <num> element-->
			<xsl:choose><!--This choose condition was put in place for finding aids that have <emph> elements in the title, but it does not work for finding aids that have a <num> value that appears in the title, which applies to nearly all Music finding aids!-->
				<xsl:when test="ead:eadheader/ead:filedesc/ead:titlestmt/ead:titleproper[not(@type='filing')]/ead:num">
					<!--xsl:value-of select="normalize-space(substring-before(normalize-space(ead:eadheader/ead:filedesc/ead:titlestmt/ead:titleproper[not(@type='filing')]), ead:eadheader/ead:filedesc/ead:titlestmt/ead:titleproper[not(@type='filing')]/ead:num))"/-->			
					<xsl:value-of select="normalize-space(ead:eadheader/ead:filedesc/ead:titlestmt/ead:titleproper[not(@type='filing')]/text())"/>			
					<!--xsl:value-of select="normalize-space(ead:eadheader/ead:filedesc/ead:titlestmt/ead:titleproper[not(@type='filing')])"/-->								
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(ead:eadheader/ead:filedesc/ead:titlestmt/ead:titleproper[not(@type='filing')]/text())"/>			
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="ead:archdesc/ead:did/ead:unittitle/ead:unitdate">
				<xsl:text>, </xsl:text>
				<xsl:choose>
					<xsl:when test="ead:archdesc/ead:did/ead:unittitle/ead:unitdate[@type='inclusive']">
						<xsl:value-of select="ead:archdesc/ead:did/ead:unittitle/ead:unitdate[@type='inclusive'][1]"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="ead:archdesc/ead:did/ead:unittitle/ead:unitdate[1]"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<!--this code is here to catch a unitdate which appears outside of the unittitle, as it does for the Galter GV Black finding aid.-->
			<xsl:if test="ead:archdesc/ead:did/ead:unitdate">
				<xsl:text>, </xsl:text>
				<xsl:choose>
					<xsl:when test="ead:archdesc/ead:did/ead:unitdate[@type='inclusive']">
						<xsl:value-of select="ead:archdesc/ead:did/ead:unitdate[@type='inclusive'][1]"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="ead:archdesc/ead:did/ead:unitdate[1]"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</title>
	</titleInfo>
	<titleInfo>
		<xsl:attribute name="otherType">filing</xsl:attribute>
		<title>
			<xsl:value-of select="normalize-space(ead:eadheader/ead:filedesc/ead:titlestmt/ead:titleproper[@type='filing'])"/>
		</title>
	</titleInfo>
</xsl:template>


<!--name section-->
<xsl:template name="name">
	<xsl:if test="ead:archdesc/ead:did/ead:origination[ead:persname|ead:corpname|ead:famname|ead:name]">

		<xsl:for-each select="ead:archdesc/ead:did/ead:origination/ead:persname">
			<xsl:call-template name="origination_name">
				<xsl:with-param name="type">personal</xsl:with-param>
				<xsl:with-param name="role"><xsl:value-of select="../@label"/></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>

		<xsl:for-each select="ead:archdesc/ead:did/ead:origination/ead:corpname">
			<xsl:call-template name="origination_name">
				<xsl:with-param name="type">corporate</xsl:with-param>
				<xsl:with-param name="role"><xsl:value-of select="../@label"/></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	
		<xsl:for-each select="ead:archdesc/ead:did/ead:origination/ead:famname">
			<xsl:call-template name="origination_name">
				<xsl:with-param name="type">family</xsl:with-param>
				<xsl:with-param name="role"><xsl:value-of select="../@label"/></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	
		<xsl:for-each select="ead:archdesc/ead:did/ead:origination/ead:name">
			<xsl:call-template name="origination_name">
				<xsl:with-param name="role"><xsl:value-of select="../@label"/></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	
	</xsl:if>
</xsl:template>

<!-- origination_name -->
<xsl:template name="origination_name">
	<xsl:param name="role"/>
	<xsl:param name="type"/>
	<name type="{$type}">
	<xsl:if test="@source"><xsl:attribute name="authority"><xsl:value-of select="@source"/></xsl:attribute></xsl:if>
	<xsl:choose>
		<xsl:when test="$role!=''"><role><roleTerm type="text"><xsl:value-of select="$role"/></roleTerm></role></xsl:when>
		<xsl:when test="@role"><role><roleTerm type="text"><xsl:value-of select="@role"/></roleTerm></role></xsl:when>
	</xsl:choose>	
	<namePart>
		<xsl:choose>
			<xsl:when test="@normal"><xsl:value-of select="@normal"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="normalize-space(.)"/></xsl:otherwise>
		</xsl:choose>
	</namePart>
		<displayForm><xsl:value-of select="normalize-space(.)"/></displayForm>
	</name>
</xsl:template>

<!--typeOfResource-->
<xsl:template name="typeOfResource">
	<typeOfResource manuscript="yes" collection="yes">mixed material</typeOfResource>
</xsl:template>			

<!--genre-->
<xsl:template name="genre">
	<genre authority="marcgt">finding aid</genre>
</xsl:template>
	
<!--OriginInfo-->
<xsl:template name="originInfo">
	
	<originInfo>

		<publisher>
			<xsl:choose>
				<xsl:when test="ead:eadheader/ead:filedesc/ead:publicationstmt/ead:publisher">
					<xsl:value-of select="normalize-space(ead:eadheader/ead:filedesc/ead:publicationstmt/ead:publisher)"/>
				</xsl:when>
				<xsl:when test="ead:frontmatter/ead:titlepage/ead:publisher">
					<xsl:value-of select="ead:frontmatter/ead:titlepage/ead:publisher"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Northwestern University Library</xsl:text><!--NUL specific publisher text-->
				</xsl:otherwise>
			</xsl:choose>
		</publisher>
		
		<xsl:if test="ead:archdesc/ead:did/ead:unittitle/ead:unitdate">	
			<xsl:choose>
				<xsl:when test="ead:archdesc/ead:did/ead:unittitle/ead:unitdate[@type='inclusive']">
					<dateCreated><xsl:value-of select="ead:archdesc/ead:did/ead:unittitle/ead:unitdate[@type='inclusive']"/></dateCreated>
				</xsl:when>
				<xsl:otherwise>
					<dateCreated><xsl:value-of select="ead:archdesc/ead:did/ead:unittitle/ead:unitdate[1]"/></dateCreated>
				</xsl:otherwise>
			</xsl:choose>		
			<xsl:choose>
				<xsl:when test="ead:archdesc/ead:did/ead:unittitle/ead:unitdate[@normal]">
					<dateCreated encoding="marc" point="start"><xsl:value-of select="substring-before(ead:archdesc/ead:did/ead:unittitle/ead:unitdate/@normal,'/')"/></dateCreated>
					<dateCreated encoding="marc" point="end"><xsl:value-of select="substring-after(ead:archdesc/ead:did/ead:unittitle/ead:unitdate/@normal,'/')"/></dateCreated>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
		 <!--this code is here to catch a unitdate which appears outside of the unittitle, as it does for the Galter GV Black finding aid.-->
		<xsl:if test="ead:archdesc/ead:did/ead:unitdate">	
			<xsl:choose>
				<xsl:when test="ead:archdesc/ead:did/ead:unitdate[@type='inclusive']">
					<dateCreated><xsl:value-of select="ead:archdesc/ead:did/ead:unitdate[@type='inclusive']"/></dateCreated>
				</xsl:when>
				<xsl:otherwise>
					<dateCreated><xsl:value-of select="ead:archdesc/ead:did/ead:unitdate[1]"/></dateCreated>
				</xsl:otherwise>
			</xsl:choose>		
			<xsl:choose>
				<xsl:when test="ead:archdesc/ead:did/ead:unitdate[@normal]">
					<dateCreated encoding="marc" point="start"><xsl:value-of select="substring-before(ead:archdesc/ead:did/ead:unitdate[1]/@normal,'/')"/></dateCreated>
					<dateCreated encoding="marc" point="end"><xsl:value-of select="substring-after(ead:archdesc/ead:did/ead:unitdate[1]/@normal,'/')"/></dateCreated>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
		
		<issuance>monographic</issuance>
	
	</originInfo>

</xsl:template>

<!-- language -->
<xsl:template name="language">
	<xsl:for-each select="ead:archdesc/ead:did/ead:langmaterial/ead:language">
		<language>
			<languageTerm type="text"><xsl:value-of select="normalize-space(.)"/></languageTerm>
			<languageTerm type="code" authority="iso639-2b"><xsl:value-of select="@langcode"/></languageTerm>
		</language>
	</xsl:for-each>
</xsl:template>

<!--physicalDescription-->
<xsl:template name="physicalDescription">
	<physicalDescription>
		<form authority="marcform">print</form>
		<internetMediaType>text/xml</internetMediaType>
		<digitalOrigin>born digital</digitalOrigin>
		<extent>
			<xsl:for-each select="ead:archdesc/ead:did/ead:physdesc/ead:extent">
				<xsl:choose>
					<xsl:when test="preceding-sibling::ead:extent">
							<xsl:text> (</xsl:text>
							<xsl:value-of select="."/>
							<xsl:text>)</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="."/>
					</xsl:otherwise>
					</xsl:choose>
			</xsl:for-each>
			
			
		</extent>
		<xsl:for-each select="ead:archdesc/ead:did/ead:physdesc/ead:dimensions">
			<note>
				<xsl:attribute name="displayLabel">
					<xsl:choose>
						<xsl:when test="@label">
							<xsl:value-of select="@label"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>Dimensions</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			<xsl:value-of select="."/>
			</note>
		</xsl:for-each>
		<xsl:for-each select="ead:archdesc/ead:did/ead:physdesc/ead:physfacet">
			<note>
				<xsl:attribute name="displayLabel">
					<xsl:choose>
						<xsl:when test="@label">
							<xsl:value-of select="@label"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>Physical Details</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			<xsl:value-of select="."/>
			</note>
		</xsl:for-each>
	</physicalDescription>
</xsl:template>

<!-- abstract -->
<xsl:template name="abstract">
	<abstract><xsl:if test="ead:archdesc/ead:did/ead:abstract/@label"><xsl:attribute name="displayLabel"><xsl:value-of select="ead:archdesc/ead:did/ead:abstract/@label"/></xsl:attribute></xsl:if>
		<xsl:value-of select="ead:archdesc/ead:did/ead:abstract"/>
	</abstract>
</xsl:template>

<!--tableOfContents-->
<xsl:template name="tableOfContents">
	<xsl:if test="ead:archdesc/ead:arrangement">
		<tableOfContents><xsl:attribute name="displayLabel"><xsl:value-of select="ead:archdesc/ead:arrangement/ead:head"/></xsl:attribute>
			<xsl:for-each select="ead:archdesc/ead:arrangement/ead:p">
				<xsl:value-of select="normalize-space(.)"/>
			</xsl:for-each>
		</tableOfContents>
	</xsl:if>
</xsl:template>

<!--note-->
<xsl:template name="note">
	<xsl:for-each select="ead:archdesc/ead:did/ead:note/ead:p">
		<note><xsl:attribute name="displayLabel"><xsl:value-of select="../@label"/></xsl:attribute><xsl:value-of select="normalize-space(.)"></xsl:value-of></note>
	</xsl:for-each>
	<xsl:if test="//ead:bioghist[ead:head]">
		<note><xsl:attribute name="displayLabel"><xsl:value-of select="//ead:bioghist[ead:head]/ead:head"/></xsl:attribute><xsl:value-of select="//ead:bioghist[ead:head]/ead:p"/></note>
	</xsl:if>
	<xsl:if test="ead:archdesc/ead:scopecontent">
		<note><xsl:attribute name="displayLabel"><xsl:value-of select="ead:archdesc/ead:scopecontent/ead:head"/></xsl:attribute><xsl:value-of select="ead:archdesc/ead:scopecontent/ead:p"/></note>
	</xsl:if>
	
	<xsl:for-each select="ead:archdesc[ead:acqinfo|ead:custodhist|ead:processinfo|ead:accruals|ead:appraisal|ead:altformavail|ead:prefercite]">
	<!--xsl:for-each select="ead:archdesc/ead:descgrp[ead:acqinfo|ead:custodhist|ead:processinfo|ead:accruals|ead:appraisal|ead:altformavail|ead:prefercite]"-->	
		<xsl:for-each select="ead:acqinfo">
			<xsl:call-template name="note_type">
				<xsl:with-param name="notetype">acquisition</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>

		<xsl:for-each select="ead:custodhist">
			<xsl:call-template name="note_type">
				<xsl:with-param name="notetype">ownership</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	
		<xsl:for-each select="ead:accruals">
			<xsl:call-template name="note_type">
				<xsl:with-param name="notetype">accruals</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	
		<xsl:for-each select="ead:processinfo">
			<xsl:call-template name="note_type">
				<xsl:with-param name="notetype">action</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	
		<xsl:for-each select="ead:appraisal">
			<xsl:call-template name="note_type">
				<xsl:with-param name="notetype">action</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>	
	
		<xsl:for-each select="ead:altformavail">
			<xsl:call-template name="note_type">
				<xsl:with-param name="notetype">additional physical form</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>	

		<xsl:for-each select="ead:prefercite">
			<xsl:call-template name="note_type">
				<xsl:with-param name="notetype">preferred citation</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>	

	</xsl:for-each>
</xsl:template>

<!-- note_type -->
<xsl:template name="note_type">
	<xsl:param name="notetype"/>
	<note type="{$notetype}">
		<xsl:if test="ead:head">
			<xsl:attribute name="displayLabel"><xsl:value-of select="ead:head"/></xsl:attribute>
		</xsl:if>	
		<xsl:for-each select="ead:p">
				<xsl:value-of select="normalize-space(.)"/>
		</xsl:for-each>
	</note>
</xsl:template>

<!--AccessCondition-->
<xsl:template name="accessCondition">
	<xsl:for-each select="ead:archdesc/ead:userestrict">
		<accessCondition type="useAndReproduction">
			<xsl:if test="ead:head"><xsl:attribute name="displayLabel"><xsl:value-of select="ead:head"/></xsl:attribute></xsl:if>
			<xsl:for-each select="ead:p">
				<xsl:value-of select="normalize-space(.)"/>
			</xsl:for-each>
		</accessCondition>
	</xsl:for-each>
	<xsl:for-each select="ead:archdesc/ead:accessrestrict">
		<accessCondition type="restrictionOnAccess">
			<xsl:if test="ead:head"><xsl:attribute name="displayLabel"><xsl:value-of select="ead:head"/></xsl:attribute></xsl:if>
			<xsl:for-each select="ead:p">
				<xsl:value-of select="normalize-space(.)"/>
			</xsl:for-each>
		</accessCondition>
	</xsl:for-each>
</xsl:template>




<!--subjects--><!--Note that this only uses subject headings from the collection description (the <archdesc>); subject headings for components are not included.-->
<xsl:template name="subjects">

	<!--xsl:for-each select="//ead:controlaccess//ead:persname"--><!--Use this commented out code to include all subject headings, including those at the component levels.-->
	<xsl:for-each select="ead:archdesc/ead:controlaccess//ead:persname">
		<subject>
			<xsl:if test="@source"><xsl:attribute name="authority"><xsl:value-of select="@source"/></xsl:attribute></xsl:if>
			<xsl:if test="@id"><xsl:attribute name="ID"><xsl:value-of select="@id"/></xsl:attribute></xsl:if>
			<name type="personal">
				<namePart><xsl:value-of select="normalize-space(.)"/></namePart>
				<displayForm><xsl:value-of select="normalize-space(.)"/></displayForm>
			</name>
		</subject>
	</xsl:for-each>

	<!--xsl:for-each select="//ead:controlaccess//ead:famname"--><!--Use this commented out code to include all subject headings, including those at the component levels.-->
	<xsl:for-each select="ead:archdesc/ead:controlaccess//ead:famname">
		<subject>
			<xsl:if test="@source"><xsl:attribute name="authority"><xsl:value-of select="@source"/></xsl:attribute></xsl:if>
			<xsl:if test="@id"><xsl:attribute name="ID"><xsl:value-of select="@id"/></xsl:attribute></xsl:if>
			<name type="family">
				<namePart><xsl:value-of select="normalize-space(.)"/></namePart>
				<displayForm><xsl:value-of select="normalize-space(.)"/></displayForm>
			</name>
		</subject>
	</xsl:for-each>

	<!--xsl:for-each select="//ead:controlaccess//ead:corpname"--><!--Use this commented out code to include all subject headings, including those at the component levels.-->
	<xsl:for-each select="ead:archdesc/ead:controlaccess//ead:corpname">
		<subject>
			<xsl:if test="@source"><xsl:attribute name="authority"><xsl:value-of select="@source"/></xsl:attribute></xsl:if>
			<xsl:if test="@id"><xsl:attribute name="ID"><xsl:value-of select="@id"/></xsl:attribute></xsl:if>
			<name type="corporate">
				<namePart><xsl:value-of select="normalize-space(.)"/></namePart>
				<displayForm><xsl:value-of select="normalize-space(.)"/></displayForm>
			</name>
		</subject>
	</xsl:for-each>

	<!--xsl:for-each select="//ead:controlaccess//ead:title"--><!--Use this commented out code to include all subject headings, including those at the component levels.-->
	<xsl:for-each select="ead:archdesc/ead:controlaccess//ead:title">
		<subject>
			<xsl:if test="@source"><xsl:attribute name="authority"><xsl:value-of select="@source"/></xsl:attribute></xsl:if>
			<xsl:if test="@id"><xsl:attribute name="ID"><xsl:value-of select="@id"/></xsl:attribute></xsl:if>
				<titleInfo><title><xsl:value-of select="normalize-space(.)"/></title></titleInfo>
		</subject>
	</xsl:for-each>

	<!--xsl:for-each select="//ead:controlaccess//ead:subject[.!='N/A']"--><!--Use this commented out code to include all subject headings, including those at the component levels.-->
	<xsl:for-each select="ead:archdesc/ead:controlaccess//ead:subject[.!='N/A']">
		<subject>
			<xsl:if test="@source"><xsl:attribute name="authority"><xsl:value-of select="@source"/></xsl:attribute></xsl:if>
			<xsl:if test="@id"><xsl:attribute name="ID"><xsl:value-of select="@id"/></xsl:attribute></xsl:if>
			<topic>
				<xsl:value-of select="."/>
			</topic>
		</subject>
	</xsl:for-each>

	<!--xsl:for-each select="//ead:controlaccess//ead:geogname[.!='N/A']"--><!--Use this commented out code to include all subject headings, including those at the component levels.-->
	<xsl:for-each select="ead:archdesc/ead:controlaccess//ead:geogname[.!='N/A']">
		<subject>
			<xsl:if test="@source"><xsl:attribute name="authority"><xsl:value-of select="@source"/></xsl:attribute></xsl:if>
			<xsl:if test="@id"><xsl:attribute name="ID"><xsl:value-of select="@id"/></xsl:attribute></xsl:if>
			<geographic>
				<xsl:value-of select="."/>
			</geographic>
		</subject>
	</xsl:for-each>	

	<!--xsl:for-each select="//ead:controlaccess//ead:genreform"--><!--Use this commented out code to include all subject headings, including those at the component levels.-->
	<xsl:for-each select="ead:archdesc/ead:controlaccess//ead:genreform">
		<subject>
			<xsl:if test="@source"><xsl:attribute name="authority"><xsl:value-of select="@source"/></xsl:attribute></xsl:if>
			<xsl:if test="@id"><xsl:attribute name="ID"><xsl:value-of select="@id"/></xsl:attribute></xsl:if>
			<genre>
				<xsl:value-of select="."/>
			</genre>
		</subject>
	</xsl:for-each>	
	
	<!--xsl:for-each select="//ead:controlaccess//ead:name"--><!--Use this commented out code to include all subject headings, including those at the component levels.-->
	<xsl:for-each select="//ead:controlaccess//ead:name">
		<subject>
			<xsl:if test="@source"><xsl:attribute name="authority"><xsl:value-of select="@source"/></xsl:attribute></xsl:if>
			<xsl:if test="@id"><xsl:attribute name="ID"><xsl:value-of select="@id"/></xsl:attribute></xsl:if>
			<name>
				<namePart><xsl:value-of select="."/></namePart>
				<displayForm><xsl:value-of select="."/></displayForm>
			</name>
		</subject>
	</xsl:for-each>
	
</xsl:template>
 
 	<!--identifer-->
<xsl:template name="identifier">
	<xsl:if test="ead:archdesc/ead:did/ead:unitid">
		<identifier type="local" displayLabel="ID">
			<xsl:value-of select="ead:archdesc/ead:did/ead:repository/ead:corpname"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="ead:archdesc/ead:did/ead:unitid"/>
		</identifier>
	</xsl:if>
	<identifier displayLabel="PID" type="local"><xsl:value-of select="ead:eadheader/ead:eadid"/></identifier>
	<location>
		<url displayLabel="Online Finding Aid" access="object in context">
		<xsl:value-of select="ead:eadheader/ead:eadid/@url"/></url>
	</location>
</xsl:template>

<!--recordInfo-->
<xsl:template name="recordInfo">
	<recordInfo>
		<recordOrigin>ArchivesSpace</recordOrigin><!--NUL specific repository name-->
		<recordContentSource authority="marcorg">IEN</recordContentSource><!--NUL specific MARC code-->
		<recordCreationDate encoding="marc"><xsl:value-of select="ead:eadheader/ead:profiledesc/ead:creation/ead:date"/></recordCreationDate>
		<recordChangeDate encoding="iso8601"><xsl:value-of select="format-dateTime(current-dateTime(),'[Y0001][M01][D01][H01][m01][s01]')"/>.0</recordChangeDate>
		<recordIdentifier source="IEN"><!--NUL specific MARC code-->
			<xsl:choose>
				<xsl:when test="ead:eadheader/ead:eadid/@identifier">
					<xsl:value-of select="ead:eadheader/ead:eadid/@identifier"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="ead:eadheader/ead:eadid"/>
				</xsl:otherwise>
			</xsl:choose>
		</recordIdentifier>
		<languageOfCataloging><languageTerm authority="iso639-2b" type="code"><xsl:value-of select="ead:eadheader/ead:profiledesc/ead:langusage"></xsl:value-of></languageTerm></languageOfCataloging>
		<recordInfoNote>item</recordInfoNote>
	</recordInfo>
</xsl:template>

<!--location-->
<xsl:template name="location">
	<location>
		<physicalLocation>
			<xsl:value-of select="ead:archdesc/ead:did/ead:repository/ead:corpname"/>
		</physicalLocation>
		<shelfLocator>
			<xsl:value-of select="ead:archdesc/ead:did/ead:unitid"/>
		</shelfLocator>
	</location>
</xsl:template>

<!--This works, but not quite. It pulls in the internal elements as well as the rest; clearly the "when" test is failing and the internal elements end up in the note for indexing.-->
<xsl:template name="allElse">
	<xsl:choose>
		<xsl:when test="@audience='internal'"><!--//*[@audience='internal'] selects ALL of the elements. *[@audience='internal'] selects none of them--><!--N.B.: THIS CODE DOES NOT WORK!-->
			<note type="excluded"><xsl:value-of select="//ead:*[@audience='internal']/descendant-or-self::text()"/></note>
		</xsl:when>
		<xsl:otherwise>
			<note type="for indexing only">
				<xsl:for-each select="descendant-or-self::text()">
					<xsl:value-of select="."/><xsl:text>  </xsl:text>
				</xsl:for-each>
			</note>
			<!--xsl:value-of select="descendant-or-self::text()"/>-->
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>	

</xsl:stylesheet>