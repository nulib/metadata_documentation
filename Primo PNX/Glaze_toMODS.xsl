<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:fn="http://www.w3.org/2005/xpath-functions" 
xmlns:xs="http://www.w3.org/2001/XMLSchema" 
xmlns:xlink="http://www.w3.org/1999/xlink" 
xmlns:ead="urn:isbn:1-931666-22-9" 
xmlns:mods="http://www.loc.gov/mods/v3"  
xmlns="http://www.loc.gov/mods/v3">
	
	<!--Deprecated as of April 2021-->

 
<!--This stylesheet transforms Glaze records into MODS. Based on a stylesheet developed by Karen Miller in 2014.-->
<!--This XSL creates one MODS file for each Glaze record.-->
<!--Glaze records are harvested as JSON and must be converted to XML before using this transformation.-->

<!--For use outside NUL, update the template named recordInfo to put in your institution's MARC code or something like it-->
<!--Also search on 01NWU for other changes to local coding-->

<xsl:output method="xml" indent="yes" omit-xml-declaration="no"  media-type="text/xml" encoding="utf-8"/>
<xsl:strip-space elements="*"/>


	<xsl:template match="JSON">
		<modsCollection xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/mods/v3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-7.xsd">
			<xsl:apply-templates/>
		</modsCollection>
	</xsl:template>
	
	<xsl:template match="//_source">
		
		<mods>
			
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
		<xsl:call-template name="relatedItem"/>
		<xsl:call-template name="allElse"/>
		
		<relatedItem type="host" otherType="sourceSystem">	
			<titleInfo><title>
				<xsl:text>Digital Collections Images Repository</xsl:text>
			</title></titleInfo>
		</relatedItem>
			
		</mods>
	
	</xsl:template>

	
<!--Housekeeping. This clears out unneeded information at the top of a file of multiple records-->
<xsl:template match="_scroll_id | _scroll-id | _index | _type | _id | _version | found | took | timed_out | timed-out | terminated_early | terminated-early | _shards | hits/total | hits/max_score | hits/hits/_index | hits/hits/_type | hits/hits/_id | hits/hits/_score | sort"/>


<!--titleInfo section-->
<xsl:template name="titleInfo">
	<xsl:if test="title/primary">
		<titleInfo>
			<title>
				<xsl:value-of select="normalize-space(title/primary)"/>			
			</title>
		</titleInfo>
	</xsl:if>
	<xsl:choose>
		<xsl:when test="title/alternate[@type='array']"><!--this is weird because the JSON converts to XML inconsistently. In K's XML, it's just title/primary and title/alternative, but in E's, it's title/primary@type='array'/primary and title/alternative@ty[e='array'/alternative-->
			<xsl:for-each select="title/alternate[@type='array']/alternate">
				<xsl:if test=".!=''">
					<titleInfo>
						<xsl:attribute name="type">alternative</xsl:attribute>
						<title>
							<xsl:value-of select="normalize-space(.)"/>
						</title>
					</titleInfo>
				</xsl:if>
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<xsl:for-each select="title/alternate">
				<xsl:if test=".!=''">
					<titleInfo>
						<xsl:attribute name="type">alternative</xsl:attribute>
						<title>
							<xsl:value-of select="normalize-space(.)"/>
						</title>
					</titleInfo>
				</xsl:if>
			</xsl:for-each>
		</xsl:otherwise>
	</xsl:choose>
	
	<xsl:for-each select="caption">
		<xsl:if test=".!=''">
			<titleInfo>
				<xsl:attribute name="type">alternative</xsl:attribute>
					<title>
						<xsl:value-of select="normalize-space(.)"/>
					</title>
			</titleInfo>
		</xsl:if>
	</xsl:for-each>
		
</xsl:template>


<!--name section-->
<xsl:template name="name">
	<!--Note that the metadata that comes out of Glaze for contributor has the <role> value stuck to the end of it. Might want to remove it later.-->
			
		<xsl:for-each select="creator//label | contributor//label">
			<xsl:call-template name="origination_name">
				<xsl:with-param name="valueURI">
					<xsl:choose>
						<xsl:when test="../uri='null'"/>
						<xsl:otherwise><xsl:value-of select="../uri"/></xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
				<xsl:with-param name="role">
					<xsl:choose>
						<xsl:when test="starts-with(../role, 'nul_') ">
							<xsl:value-of select="substring-after(../role, 'nul_')"/>
						</xsl:when>
						<xsl:otherwise><xsl:value-of select="../role"/></xsl:otherwise>
					</xsl:choose></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		
	</xsl:template>

<!-- origination_name -->
<xsl:template name="origination_name">
	<xsl:param name="valueURI"/>
	<xsl:param name="role"/>
	<name>
		<xsl:if test="$valueURI !=''">
			<xsl:attribute name="valueURI"><xsl:value-of select="$valueURI"/></xsl:attribute>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="$role !=''"><role><roleTerm type="text"><xsl:value-of select="$role"/></roleTerm></role></xsl:when>
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
	<typeOfResource>
		<xsl:choose>
			<xsl:when test="contains(lower-case(resource_type), 'text')">text</xsl:when>
			<xsl:when test="contains(lower-case(resource_type), 'map')">cartographic</xsl:when>
			<xsl:when test="contains(lower-case(resource_type), 'image')">still image</xsl:when>
			<xsl:when test="contains(lower-case(resource-type), 'text')">text</xsl:when>
			<xsl:when test="contains(lower-case(resource-type), 'map')">cartographic</xsl:when>
			<xsl:when test="contains(lower-case(resource-type), 'image')">still image</xsl:when>
			<xsl:otherwise>still image material</xsl:otherwise>
		</xsl:choose>	
	</typeOfResource>
</xsl:template>			


<!--genre-->
<xsl:template name="genre">
	<xsl:for-each select="genre//label">
		<genre>
			<xsl:attribute name="valueURI"><xsl:value-of select="..//uri"/></xsl:attribute>
			<xsl:value-of select="."/>
		</genre>
	</xsl:for-each>
</xsl:template>
	
	
<!--OriginInfo-->
<xsl:template name="originInfo">
	<xsl:if test="publisher or date">
		<originInfo>
			<xsl:if test="publisher">
				<publisher>
					<xsl:value-of select="normalize-space(publisher)"/>
				</publisher>
			</xsl:if>
			<xsl:if test="date">	
				<dateCreated>
					<xsl:value-of select="date"/>
				</dateCreated>
			</xsl:if>
		</originInfo>
	</xsl:if>
</xsl:template>


<!-- language -->
<xsl:template name="language">
	<xsl:for-each select="language//label">
		<language>
			<languageTerm type="text">
				<xsl:attribute name="valueURI"><xsl:value-of select="..//uri"/></xsl:attribute>
				<xsl:value-of select="."/>
			</languageTerm>
			<languageTerm type="code" authority="iso639-2b">
				<xsl:attribute name="valueURI"><xsl:value-of select="..//uri"/></xsl:attribute>
				<xsl:value-of select="substring-after(..//uri,'http://id.loc.gov/vocabulary/languages/')"/>
			</languageTerm>
		</language>
	</xsl:for-each>
</xsl:template>


<!--physicalDescription-->
<xsl:template name="physicalDescription">
	<physicalDescription>
		<internetMediaType>image</internetMediaType>
		<extent>	
			<xsl:for-each select="physical_description/material | physical-description/material ">
				<xsl:if test="preceding-sibling::physical_description/material | preceding-sibling::physical-description/material">
					<xsl:text>, </xsl:text>
				</xsl:if>
				<xsl:value-of select="."/>
			</xsl:for-each>
			<xsl:for-each select="physical_description/size | physical-description/size">
				<xsl:if test=".!='' and preceding-sibling::material !=''">
					<xsl:text> ; </xsl:text>
				</xsl:if>
				<xsl:if test="preceding-sibling::physical_description/size | preceding-sibling::physical-description/size">
					<xsl:text>, </xsl:text>
				</xsl:if>
				<xsl:value-of select="."/>
			</xsl:for-each>
		</extent>
	</physicalDescription>
</xsl:template>


<!-- abstract -->
<xsl:template name="abstract">
	<xsl:for-each select="description | abstract">
		<xsl:if test=".!=''">
			<abstract>
				<xsl:value-of select="normalize-space(.)"/>
			</abstract>
		</xsl:if>
	</xsl:for-each>
</xsl:template>


<!--tableOfContents-->
<xsl:template name="tableOfContents">
	<xsl:for-each select="table_of_contents | table-of-contents">
		<xsl:if test=".!=''">
			<tableOfContents>
				<xsl:value-of select="normalize-space(.)"/>
			</tableOfContents>
		</xsl:if>
	</xsl:for-each>
</xsl:template>


<!--note-->
<xsl:template name="note">
	<xsl:for-each select="notes">
		<xsl:if test=".!=''">
			<note>
				<xsl:value-of select="normalize-space(.)"/>
			</note>
		</xsl:if>
	</xsl:for-each>
	
	<xsl:for-each select="scope_and_contents | scope-and-contents">
		<xsl:if test=".!=''">
			<note displayLabel="Scope and Contents">
				<xsl:value-of select="normalize-space(.)"/>
			</note>
		</xsl:if>
	</xsl:for-each>
</xsl:template>


<!--AccessCondition-->
<xsl:template name="accessCondition">
	<xsl:for-each select="rights_statement | rights-statement">
		<xsl:if test=".!=''">
			<accessCondition type="rights">
				<xsl:attribute name="xlink:href"><xsl:value-of select="uri"/> </xsl:attribute>
				<xsl:value-of select="normalize-space(label)"/>
			</accessCondition>
		</xsl:if>
	</xsl:for-each>
	<xsl:for-each select="nul_use_statement | nul-use-statement">
		<xsl:if test=".!=''">
			<accessCondition type="rights">
				<xsl:value-of select="normalize-space(.)"/>
			</accessCondition>
		</xsl:if>
	</xsl:for-each>
</xsl:template>


<!--subjects-->
<xsl:template name="subjects">

	<xsl:for-each select="subject//label">
		<xsl:choose>
			<xsl:when test="../role='topical'">
				<subject>
					<xsl:if test="../uri != 'null'"><xsl:attribute name="valueURI"><xsl:value-of select="../uri"/></xsl:attribute></xsl:if>
					<topic>
						<xsl:value-of select="."/>
					</topic>
				</subject>
			</xsl:when>
			<xsl:when test="../role='temporal'">
				<subject>
					<xsl:if test="../uri != 'null'"><xsl:attribute name="valueURI"><xsl:value-of select="../uri"/></xsl:attribute></xsl:if>
					<temporal>
						<xsl:value-of select="."/>
					</temporal>
				</subject>
			</xsl:when>
			<xsl:when test="../role='geographical'">
				<subject>
					<xsl:if test="../uri != 'null'"><xsl:attribute name="valueURI"><xsl:value-of select="../uri"/></xsl:attribute></xsl:if>
					<geographic>
						<xsl:value-of select="."/>
					</geographic>
				</subject>
			</xsl:when>
			<xsl:otherwise>
				<subject>
					<topic>
						<xsl:value-of select="."/>
					</topic>
				</subject>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>
	
	<xsl:for-each select="style_period//label | style-period//label">
		<subject>
			<xsl:if test="../uri != 'null'"><xsl:attribute name="valueURI"><xsl:value-of select="../uri"/></xsl:attribute></xsl:if>
			<topic>
				<xsl:value-of select="."/>
			</topic>
		</subject>
	</xsl:for-each>

</xsl:template>


<!--identifer-->
<xsl:template name="identifier">
	<xsl:if test="admin_set/title | admin-set/title">
		<identifier type="local" displayLabel="ID">
			<xsl:for-each select="admin_set/title | admin-set/title">
				<xsl:value-of select="normalize-space(.)"/>
			</xsl:for-each>
			<xsl:text> </xsl:text>
			<xsl:choose>
				<xsl:when test="identifier[@type='array']">
					<xsl:for-each select="identifier[@type='array']/identifier">
						<xsl:value-of select="normalize-space(.)"/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="identifier">
						<xsl:value-of select="normalize-space(.)"/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>			
		</identifier>
	</xsl:if>
	<identifier displayLabel="PID" type="local"><xsl:value-of select="../_id"/></identifier>
	<location>
		<url displayLabel="Digitized Image" access="object in context">
			<xsl:text>https://dc.library.northwestern.edu/items/</xsl:text><!--01NWU:Change this to use a local URL-->
			<xsl:value-of select="../_id"/>
		</url>
		<url displayLabel="Thumbnail" note="thumbnail">
			<xsl:value-of select="representative_file_url"/>
			<xsl:value-of select="representative-file-url"/>			
			<xsl:text>/square/100,100/0/default.jpg</xsl:text>
		</url>
	</location>
	
	<xsl:if test="call_number != 'null' and call_number != ''">
		<identifier displayLabel="Call Number" type="call number">
			<xsl:value-of select="normalize-space(call_number)"/>
		</identifier>
	</xsl:if>
	
	<xsl:if test="call-number != 'null' and call-number != ''">
		<identifier displayLabel="Call Number" type="call number">
			<xsl:value-of select="normalize-space(call-number)"/>
		</identifier>
	</xsl:if>
	
</xsl:template>

<!--recordInfo-->
<xsl:template name="recordInfo">
	<recordInfo>
		<recordOrigin>Glaze</recordOrigin><!--NUL specific repository name-->
		<recordContentSource authority="marcorg">IEN</recordContentSource><!--NUL specific MARC code-->
		<recordCreationDate encoding="marc"><xsl:value-of select="create_date"/><xsl:value-of select="create-date"/></recordCreationDate>
		<recordChangeDate encoding="iso8601"><xsl:value-of select="format-dateTime(current-dateTime(),'[Y0001][M01][D01][H01][m01][s01]')"/>.0</recordChangeDate>
		<recordIdentifier source="IEN"><!--NUL specific MARC code-->
			<xsl:value-of select="../_id"/>
		</recordIdentifier>
		<languageOfCataloging><languageTerm authority="iso639-2b" type="code">eng</languageTerm></languageOfCataloging>
		<recordInfoNote>item</recordInfoNote>
	</recordInfo>
</xsl:template>

<!--location-->
<xsl:template name="location">
	<location>
		<physicalLocation>
			<xsl:value-of select="admin_set/title"/>
			<xsl:value-of select="admin-set/title"/>
		</physicalLocation>
		<shelfLocator>
			<xsl:choose>
				<xsl:when test="identifier[@type='array']">
					<xsl:for-each select="identifier[@type='array']/identifier">
						<xsl:value-of select="normalize-space(.)"/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="identifier">
						<xsl:value-of select="normalize-space(.)"/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</shelfLocator>
	</location>
</xsl:template>

<!--series and host-->
<xsl:template name="relatedItem">

			<xsl:choose>
				<xsl:when test="collection[@type='array']">
					<xsl:for-each select="collection[@type='array']/collection/title"><xsl:if test=".!='Railroad Menu Highlights'"><!--01NUW:Local use only-->
						<relatedItem type="host">
							<titleInfo><title>					
								<xsl:value-of select="normalize-space(.)"/>
								<xsl:text> </xsl:text>
							</title></titleInfo>
							<identifier displayLabel="PID" type="local"><xsl:value-of select="../id"/></identifier>
						</relatedItem></xsl:if>					
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="collection/title"><xsl:if test=".!='Railroad Menu Highlights'"><!--01NUW:Local use only-->
						<relatedItem type="host">
							<titleInfo><title>					
								<xsl:value-of select="normalize-space(.)"/>
								<xsl:text> </xsl:text>
							</title></titleInfo>
							<identifier displayLabel="PID" type="local"><xsl:value-of select="../id"/></identifier>
						</relatedItem></xsl:if>					
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>

	
	<xsl:if test="series !=''">
		<relatedItem type='series'>
			<titleInfo><title>
				<xsl:value-of select="normalize-space(series)"/>
			</title></titleInfo>
		</relatedItem>
	</xsl:if>
	
	<!--Removed 20190827; this was getting mapped to a clickable PNX Display element, but it didn't work. Putting it into another Display element would make it visible, but not clickable-->
	<!--20190828: putting this into a place where it can go to a PNX link element-->
	<xsl:if test="related_url | related-url">
		<xsl:if test="related_url !=''">
			<relatedItem otherType="Related URL">
				<location><url>
					<xsl:value-of select="normalize-space(related_url)"/>
				</url></location>
			</relatedItem>
		</xsl:if>
		<xsl:if test="related-url !=''">
			<relatedItem otherType="Related URL">
				<location><url>
					<xsl:value-of select="normalize-space(related-url)"/>
				</url></location>
			</relatedItem>
		</xsl:if>
	</xsl:if>
	
	<xsl:if test="related_material | related-material">
		<xsl:if test="related_material !=''">
			<relatedItem>
				<titleInfo><title>
					<xsl:value-of select="normalize-space(related_material)"/>
				</title></titleInfo>
			</relatedItem>
		</xsl:if>
		<xsl:if test="related-material !=''">
			<relatedItem>
				<titleInfo><title>
					<xsl:value-of select="normalize-space(related-material)"/>
				</title></titleInfo>
			</relatedItem>
		</xsl:if>
	</xsl:if>	
	
	
	
	<xsl:if test="source !=''">
		<relatedItem type='original' displayLabel='Source'>
			<titleInfo><title>
				<xsl:value-of select="normalize-space(source)"/>
			</title></titleInfo>
		</relatedItem>
	</xsl:if>
	
	
</xsl:template>

<!--This works, but not quite. It pulls in the internal elements as well as the rest; clearly the "when" test is failing and the internal elements end up in the note for indexing.-->
<xsl:template name="allElse">
	<note type="for indexing only">
		<xsl:for-each select="descendant-or-self::text()">
			<xsl:value-of select="normalize-space(.)"/><xsl:text>  </xsl:text>
		</xsl:for-each>
	</note>
</xsl:template>	

</xsl:stylesheet>
