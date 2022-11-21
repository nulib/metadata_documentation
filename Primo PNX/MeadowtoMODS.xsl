<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:fn="http://www.w3.org/2005/xpath-functions" 
xmlns:xs="http://www.w3.org/2001/XMLSchema" 
xmlns:xlink="http://www.w3.org/1999/xlink" 
xmlns:ead="urn:isbn:1-931666-22-9" 
xmlns:mods="http://www.loc.gov/mods/v3"  
xmlns="http://www.loc.gov/mods/v3">

 
<!--This stylesheet transforms DONUT records into MODS. Based on a stylesheet developed by Karen Miller in 2014.-->
<!--This XSL creates one MODS file for each DONUT record.-->
<!--DONUT records are harvested as JSON and must be converted to XML before using this transformation.-->

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
		
		<titleInfo>
			<title>
				<xsl:value-of select="normalize-space(descriptiveMetadata/title)"/>			
			</title>
		</titleInfo>
		
		<xsl:for-each select="descriptiveMetadata/alternateTitle/alternateTitle">
			<xsl:if test=".!=''">
				<titleInfo>
					<xsl:attribute name="type">alternative</xsl:attribute>
					<title>
						<xsl:value-of select="normalize-space(.)"/>
					</title>
				</titleInfo>
			</xsl:if>
		</xsl:for-each>
		
		<xsl:for-each select="descriptiveMetadata/caption">
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
				
			<xsl:for-each select="descriptiveMetadata//creator/term/label | descriptiveMetadata//contributor/term/label">
				<xsl:call-template name="origination_name">
					<xsl:with-param name="valueURI">
						<xsl:choose>
							<xsl:when test="../term/id='null'"/>
							<xsl:otherwise><xsl:value-of select="../id"/></xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
					<xsl:with-param name="roleTerm">
						<xsl:value-of select="../../role/label"/>
					</xsl:with-param>
					<xsl:with-param name="roleCode">
						<xsl:value-of select="../../role/id"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
			
		</xsl:template>
	
	<!-- origination_name -->
	<xsl:template name="origination_name">
		<xsl:param name="valueURI"/>
		<xsl:param name="roleTerm"/>
		<xsl:param name="roleCode"/>
		<name>
			<xsl:if test="$valueURI !=''">
				<xsl:attribute name="valueURI"><xsl:value-of select="$valueURI"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="$roleTerm !=''"><role><roleTerm type="text"><xsl:value-of select="$roleTerm"/></roleTerm></role></xsl:if>
			<xsl:if test="$roleCode !=''"><role><roleTerm type="code"><xsl:value-of select="$roleCode"/></roleTerm></role></xsl:if>
			<namePart>	
				<xsl:value-of select="normalize-space(.)"/>
			</namePart>
			<displayForm><xsl:value-of select="normalize-space(.)"/></displayForm>
		</name>
	</xsl:template>
	
	
	<!--typeOfResource-->
	<xsl:template name="typeOfResource">
		<typeOfResource>still image</typeOfResource>
	</xsl:template>			
	
	
	<!--genre-->
	<xsl:template name="genre">
		<xsl:for-each select="descriptiveMetadata/genre//term/label">
			<genre>
				<xsl:attribute name="valueURI"><xsl:value-of select="..//id"/></xsl:attribute>
				<xsl:value-of select="."/>
			</genre>
		</xsl:for-each>
	</xsl:template>
		
		
	<!--OriginInfo-->
	<xsl:template name="originInfo">
		<xsl:if test="descriptiveMetadata/publisher/publisher or descriptiveMetadata/dateCreated/dateCreated">
			<originInfo>
				<xsl:for-each select="descriptiveMetadata/publisher/publisher">
					<publisher>
						<xsl:value-of select="normalize-space(.)"/>
					</publisher>
				</xsl:for-each>
				<xsl:for-each select="descriptiveMetadata/dateCreated/dateCreated">	
					<dateCreated>
						<xsl:value-of select="humanized"/>
					</dateCreated>
				</xsl:for-each>
			</originInfo>
		</xsl:if>
	</xsl:template>
	
	
	<!-- language -->
	<xsl:template name="language">
		<xsl:for-each select="descriptiveMetadata/language//term">
			<language>
				<languageTerm type="text">
					<xsl:attribute name="valueURI"><xsl:value-of select="id"/></xsl:attribute>
					<xsl:value-of select="label"/>
				</languageTerm>
				<languageTerm type="code" authority="iso639-2b">
					<xsl:attribute name="valueURI"><xsl:value-of select="id"/></xsl:attribute>
					<xsl:value-of select="substring-after(id,'http://id.loc.gov/vocabulary/languages/')"/>
				</languageTerm>
			</language>
		</xsl:for-each>
	</xsl:template>
	
	
	<!--physicalDescription-->
	<xsl:template name="physicalDescription">
		<physicalDescription>
			<internetMediaType>image</internetMediaType>
			<extent>	
				<xsl:for-each select="descriptiveMetadata/physicalDescriptionMaterial/physicalDescriptionMaterial">
					<xsl:if test="preceding-sibling::physicalDescriptionMaterial">
						<xsl:text>, </xsl:text>
					</xsl:if>
					<xsl:value-of select="."/>
				</xsl:for-each>
				<xsl:for-each select="descriptiveMetadata/physicalDescriptionSize/physicalDescriptionSize">
					<xsl:if test=".!='' and ../../physicalDescriptionMaterial/physicalDescriptionMaterial !=''">
						<xsl:text> ; </xsl:text>
					</xsl:if>
					<xsl:if test="preceding-sibling::physicalDescriptionSize">
						<xsl:text>, </xsl:text>
					</xsl:if>
					<xsl:value-of select="."/>
				</xsl:for-each>
			</extent>
		</physicalDescription>
	</xsl:template>
	
	
	<!-- abstract -->
	<xsl:template name="abstract">
		<xsl:for-each select="descriptiveMetadata/description/description | descriptiveMetadata/abstract/abstract">
			<xsl:if test=".!=''">
				<abstract>
					<xsl:value-of select="normalize-space(.)"/>
				</abstract>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	
	<!--tableOfContents-->
	<xsl:template name="tableOfContents">
		<xsl:for-each select="descriptiveMetadata/tableOfContents/tableOfContents">
			<xsl:if test=".!=''">
				<tableOfContents>
					<xsl:value-of select="normalize-space(.)"/>
				</tableOfContents>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	
	<!--note-->
	<xsl:template name="note">
		<xsl:for-each select="descriptiveMetadata/notes/note">
			<xsl:if test=".!=''">
				<note>
					<xsl:value-of select="normalize-space(.)"/>
				</note>
			</xsl:if>
		</xsl:for-each>
		
		<xsl:for-each select="descriptiveMetadata/scopeAndContents/scopeAndContent">
			<xsl:if test=".!=''">
				<note displayLabel="Scope and Contents">
					<xsl:value-of select="normalize-space(.)"/>
				</note>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	
	<!--AccessCondition-->
	<xsl:template name="accessCondition">
		<xsl:for-each select="descriptiveMetadata/rightsStatement">
			<xsl:if test=".!=''">
				<accessCondition type="rights">
					<xsl:attribute name="xlink:href"><xsl:value-of select="id"/> </xsl:attribute>
					<xsl:value-of select="normalize-space(label)"/>
				</accessCondition>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="descriptiveMetadata/termsOfUse">
			<xsl:if test=".!=''">
				<accessCondition type="useAndReproduction">
					<xsl:value-of select="normalize-space(.)"/>
				</accessCondition>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	
	<!--subjects-->
	<xsl:template name="subjects">
	
		<xsl:for-each select="descriptiveMetadata/subject">
			<xsl:choose>
				<xsl:when test="role/id='TOPICAL'">
					<subject>
						<xsl:if test="term/id != 'null'"><xsl:attribute name="valueURI"><xsl:value-of select="term/id"/></xsl:attribute></xsl:if>
						<topic>
							<xsl:value-of select="term/label"/>
						</topic>
					</subject>
				</xsl:when>
				<xsl:when test="role/id='TEMPORAL'">
					<subject>
						<xsl:if test="term/id != 'null'"><xsl:attribute name="valueURI"><xsl:value-of select="term/id"/></xsl:attribute></xsl:if>
						<temporal>
							<xsl:value-of select="term/label"/>
						</temporal>
					</subject>
				</xsl:when>
				<xsl:when test="role/id='GEOGRAPHICAL'">
					<subject>
						<xsl:if test="term/id != 'null'"><xsl:attribute name="valueURI"><xsl:value-of select="term/id"/></xsl:attribute></xsl:if>
						<geographic>
							<xsl:value-of select="term/label"/>
						</geographic>
					</subject>
				</xsl:when>
				<xsl:otherwise>
					<subject>
						<topic>
							<xsl:value-of select="term/label"/>
						</topic>
					</subject>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
		
		<xsl:for-each select="descriptiveMetadata/stylePeriod/stylePeriod">
			<subject>
				<xsl:if test="term/id != 'null'"><xsl:attribute name="valueURI"><xsl:value-of select="term/id"/></xsl:attribute></xsl:if>
				<topic>
					<xsl:value-of select="term/label"/>
				</topic>
			</subject>
		</xsl:for-each>
	
	</xsl:template>
	
	
	<!--identifers and URLs-->
	<xsl:template name="identifier">
		
		<xsl:for-each select="descriptiveMetadata/identifier/identifier">
			<identifier type="local">
				<xsl:value-of select="normalize-space(.)"/>
			</identifier>
		</xsl:for-each>
		
		<identifier displayLabel="PID" type="local"><xsl:value-of select="id"/></identifier>
		
		<location>
			<url displayLabel="Digitized Image" access="object in context">
				<xsl:text>https://dc.library.northwestern.edu/items/</xsl:text>
				<xsl:value-of select="id"/>
			</url>
			<url displayLabel="Thumbnail" note="thumbnail">
				<xsl:value-of select="representativeFileSet/url"/>			
				<xsl:text>/square/100,100/0/default.jpg</xsl:text>
			</url>
		</location>
		
	</xsl:template>
	
	
	<!--recordInfo-->
	<xsl:template name="recordInfo">
		<recordInfo>
			<recordOrigin>Glaze</recordOrigin><!--NUL specific repository name-->
			<recordContentSource authority="marcorg">IEN</recordContentSource><!--NUL specific MARC code-->
			<recordCreationDate encoding="marc"><xsl:value-of select="createDate"/><xsl:value-of select="create-date"/></recordCreationDate>
			<recordChangeDate encoding="iso8601"><xsl:value-of select="format-dateTime(current-dateTime(),'[Y0001][M01][D01][H01][m01][s01]')"/>.0</recordChangeDate>
			<recordIdentifier source="IEN">
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
				<xsl:value-of select="administrativeMetadata/libraryUnit/label"/>
			</physicalLocation>
			<shelfLocator>
				<xsl:value-of select="descriptiveMetadata/identifier/identifier[1]"/>
			</shelfLocator>
		</location>
	</xsl:template>
	
	
	<!--collection, series, related URL, related material, source-->
	<xsl:template name="relatedItem">
		
		<xsl:for-each select="collection/title">
			<relatedItem type="host" displayLabel="Collection">
				<titleInfo><title>					
					<xsl:value-of select="normalize-space(.)"/>
					<xsl:text> </xsl:text>
				</title></titleInfo>
				<identifier displayLabel="Collection PID" type="local"><xsl:value-of select="../id"/></identifier>
			</relatedItem>				
		</xsl:for-each>
				
		<xsl:for-each select="descriptiveMetadata/series/series">
			<relatedItem type="series">
				<titleInfo><title>
					<xsl:value-of select="normalize-space(.)"/>
				</title></titleInfo>
			</relatedItem>
		</xsl:for-each>
				
		<xsl:for-each select="descriptiveMetadata/relatedUrl/relatedUrl/url">
				<relatedItem otherType="Related URL">
					<location><url>
						<xsl:value-of select="normalize-space(.)"/>
					</url></location>
				</relatedItem>
		</xsl:for-each>
		
		<xsl:for-each select="descriptiveMetadata/relatedMaterial/relatedMaterial">
				<relatedItem otherType="Related Material">
					<title><titleInfo>
						<xsl:value-of select="normalize-space(.)"/>
					</titleInfo></title>
				</relatedItem>
		</xsl:for-each>
		
		<xsl:for-each select="descriptiveMetadata/source/source">
			<relatedItem type='original' displayLabel='Source'>
				<titleInfo><title>
					<xsl:value-of select="normalize-space(.)"/>
				</title></titleInfo>
			</relatedItem>
		</xsl:for-each>
		
	</xsl:template>
	
		
	<xsl:template name="allElse">
		<note type="for indexing only">
			<xsl:for-each select="descriptiveMetadata/descendant-or-self::text()">
				<xsl:value-of select="normalize-space(.)"/><xsl:text>  </xsl:text>
			</xsl:for-each>
		</note>
	</xsl:template>	
	
</xsl:stylesheet>
