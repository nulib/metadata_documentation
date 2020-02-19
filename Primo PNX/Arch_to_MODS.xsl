<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:fn="http://www.w3.org/2005/xpath-functions" 
xmlns:xs="http://www.w3.org/2001/XMLSchema" 
xmlns:xlink="http://www.w3.org/1999/xlink" 
xmlns:ead="urn:isbn:1-931666-22-9" 
xmlns:mods="http://www.loc.gov/mods/v3"  
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
xmlns:gn="http://sws.geonames.org"
xmlns="http://www.loc.gov/mods/v3">
 
<!--N.B. The call to retrieve values of URIs for geognames that appear in the subjects template DOES NOT WORK, so it is commented out.--> 
 
 
<!--This stylesheet transforms Arch records into MODS. Based on a stylesheet developed by Karen Miller in 2019 to transform DONUT records.-->
<!--This XSL creates one MODS file for each Arch record.-->
<!--Arch records are harvested as JSON and must be converted to XML before using this transformation.-->

<!--Search on 01NWU for changes to local coding-->

<xsl:output method="xml" indent="yes" omit-xml-declaration="no"  media-type="text/xml" encoding="utf-8"/>
<xsl:strip-space elements="*"/>


	<xsl:template match="/">
		<modsCollection xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/mods/v3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-7.xsd">
			<xsl:apply-templates/>
		</modsCollection>
	</xsl:template>
	
	<xsl:template match="JSON">
		
		<mods>
			
			<xsl:call-template name="titleInfo"/>
			<xsl:call-template name="name"/>
			<xsl:call-template name="typeOfResource"/>
			<xsl:call-template name="originInfo"/>
			<xsl:call-template name="language"/>
			<xsl:call-template name="abstract"/>		
			<xsl:call-template name="note"/>
			<xsl:call-template name="accessCondition"/>
			<xsl:call-template name="subjects"/>
			<xsl:call-template name="identifier"/>
			<xsl:call-template name="recordInfo"/>
			<xsl:call-template name="relatedItem"/>
			<xsl:call-template name="allElse"/>
		
			<relatedItem type="host" otherType="sourceSystem">	
				<!--titleInfo><title><xsl:value-of select="member_of_collections/title[1]"/></title></titleInfo-->
				<!--identifier displayLabel="PID" type="local"><xsl:value-of select="member_of_collections/id"/></identifier-->
				<titleInfo><title>
					<xsl:text>Arch Institutional Repository</xsl:text></title></titleInfo>
			</relatedItem>
		
			<xsl:for-each select="member-of-collections/member-of-collection">
				<relatedItem type="host">
				<identifier displayLabel="PID" type="local"><xsl:value-of select="id"/></identifier>
					<titleInfo><title>	
						<xsl:value-of select="title[1]/title"/>
					</title></titleInfo>
				</relatedItem>
			</xsl:for-each>
		
		</mods>
	
	</xsl:template>
	

	
<!--Housekeeping. This clears out unneeded information at the top of a file of multiple records--><!--Come back to this! It will likely be different with Arch records-->
<xsl:template match="_scroll_id | _scroll-id | _index | _type | _id | _version | found | took | timed_out | timed-out | terminated_early | terminated-early | _shards | hits/total | hits/max_score | hits/hits/_index | hits/hits/_type | hits/hits/_id | hits/hits/_score | sort"/>



<!--titleInfo section-->
<xsl:template name="titleInfo">

	<xsl:choose>
		<xsl:when test="title[1]">
			<titleInfo>
				<title>
					<xsl:value-of select="normalize-space(title[1])"/>			
				</title>
			</titleInfo>
		</xsl:when>
		<xsl:otherwise>
			<xsl:for-each select="title">
		<titleInfo>
			<xsl:attribute name="type">alternative</xsl:attribute>
			<title>
				<xsl:value-of select="normalize-space(title)"/>
			</title>
		</titleInfo>
	</xsl:for-each>
	</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!--name section-->
<xsl:template name="name">
	<!--xsl:for-each select="creator | contributor"-->
	<xsl:for-each select="creator/creator | contributor/contributor">	
		<xsl:if test=". !=''">
			<name>
				<namePart>
					<xsl:value-of select="normalize-space(.)"/>
				</namePart>
					<role>
						<xsl:choose>
							<xsl:when test="name(.)='creator'">
								<roleTerm>Creator</roleTerm>
							</xsl:when>
							<xsl:otherwise>
								<roleTerm>Contributor</roleTerm>
							</xsl:otherwise>
						</xsl:choose>
				</role>			
			</name>
		</xsl:if>
	</xsl:for-each>
</xsl:template>


<!--typeOfResource-->
<xsl:template name="typeOfResource">
	<xsl:for-each select="resource_type | resource-type">
		<typeOfResource>
			<xsl:choose>
				<xsl:when test="contains(lower-case(.), 'book')">book</xsl:when>
				<xsl:when test="contains(lower-case(.), 'audio')">audio</xsl:when>
				<xsl:when test="contains(lower-case(.), 'conference proceeding')">text</xsl:when>
				<xsl:when test="contains(lower-case(.), 'data')">other</xsl:when>																
				<xsl:when test="contains(lower-case(.), 'dissertation')">dissertation</xsl:when>						
				<xsl:when test="contains(lower-case(.), 'article')">article</xsl:when>
				<xsl:when test="contains(lower-case(.), 'masters thesis')">text</xsl:when>									
				<xsl:when test="contains(lower-case(.), 'poster')">still image</xsl:when>			
				<xsl:when test="contains(lower-case(.), 'presentation')">other</xsl:when>						
				<xsl:when test="contains(lower-case(.), 'project')">other</xsl:when>									
				<xsl:when test="contains(lower-case(.), 'report')">text</xsl:when>											
				<xsl:when test="contains(lower-case(.), 'research paper')">text</xsl:when>										
				<xsl:when test="contains(lower-case(.), 'map')">cartographic</xsl:when>
				<xsl:when test="contains(lower-case(.), 'image')">still image</xsl:when>
				<xsl:when test="contains(lower-case(.), 'software')">other</xsl:when>							
				<xsl:when test="contains(lower-case(.), 'video')">moving image</xsl:when>
				<xsl:when test="contains(lower-case(resource-type), 'book')">book</xsl:when>
				<xsl:when test="contains(lower-case(resource-type), 'audio')">audio</xsl:when>
				<xsl:when test="contains(lower-case(resource-type), 'conference proceeding')">text</xsl:when>
				<xsl:when test="contains(lower-case(resource-type), 'data')">other</xsl:when>																
				<xsl:when test="contains(lower-case(resource-type), 'dissertation')">dissertation</xsl:when>						
				<xsl:when test="contains(lower-case(resource-type), 'article')">article</xsl:when>
				<xsl:when test="contains(lower-case(resource-type), 'masters thesis')">text</xsl:when>									
				<xsl:when test="contains(lower-case(resource-type), 'poster')">still image</xsl:when>			
				<xsl:when test="contains(lower-case(resource-type), 'presentation')">other</xsl:when>						
				<xsl:when test="contains(lower-case(resource-type), 'project')">other</xsl:when>									
				<xsl:when test="contains(lower-case(resource-type), 'report')">text</xsl:when>											
				<xsl:when test="contains(lower-case(resource-type), 'research paper')">text</xsl:when>										
				<xsl:when test="contains(lower-case(resource-type), 'map')">cartographic</xsl:when>
				<xsl:when test="contains(lower-case(resource-type), 'image')">still image</xsl:when>
				<xsl:when test="contains(lower-case(resource-type), 'software')">other</xsl:when>							
				<xsl:when test="contains(lower-case(resource-type), 'video')">moving image</xsl:when>										
				<xsl:otherwise>mixed material</xsl:otherwise>
			</xsl:choose>	
		</typeOfResource>
	</xsl:for-each>
</xsl:template>

	
<!--OriginInfo-->
<xsl:template name="originInfo">
	<xsl:if test="(publisher !='') or (date_created !='') or (date-created !='')">
		<originInfo>
			<!--xsl:for-each select="publisher"-->
			<xsl:for-each select="member-of-collections/member-of-collection/publisher">
				<xsl:if test=".!=''">
					<publisher>
						<xsl:value-of select="normalize-space(.)"/>
					</publisher>
				</xsl:if>
			</xsl:for-each>
			<xsl:for-each select="publisher/publisher">
				<xsl:if test=".!='' and .!= member-of-collections/member-of-collection/publisher"><!--this is here to prevent duplicate publishers from showing up-->
					<publisher>
						<xsl:value-of select="normalize-space(.)"/>
					</publisher>
				</xsl:if>
			</xsl:for-each>
			<xsl:if test="date_created !=''">	
				<dateCreated>
					<xsl:value-of select="date_created"/>
				</dateCreated>
			</xsl:if>
			<!--xsl:if test="date-created"-->	
			<xsl:if test="date-created !=''">				
				<dateCreated>
					<xsl:value-of select="date-created/date-created"/>
				</dateCreated>
			</xsl:if>
		</originInfo>
	</xsl:if>
</xsl:template>


<!-- language -->
<xsl:template name="language">
	<!--xsl:for-each select="language"-->
	<xsl:for-each select="language/language">	
		<language>
			<languageTerm type="text">
				<xsl:value-of select="."/>
			</languageTerm>
		</language>
	</xsl:for-each>
</xsl:template>


<!-- abstract -->
<xsl:template name="abstract">
	<xsl:for-each select="description">
		<xsl:if test=".!=''">
			<abstract>
				<xsl:value-of select="normalize-space(.)"/>
			</abstract>
		</xsl:if>
	</xsl:for-each>
</xsl:template>


<!-- note -->
<xsl:template name="note">
	<xsl:if test="keyword !=''">
		<note>
			<xsl:choose>
				<xsl:when test="count(keyword/keyword) = 1">
					<xsl:text>Keyword: </xsl:text>				
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Keywords: </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:for-each select="keyword/keyword">
				<xsl:value-of select="normalize-space(.)"/>
				<xsl:if test="following-sibling::keyword">, </xsl:if>
			</xsl:for-each>
		</note>
	</xsl:if>

</xsl:template>



<!--AccessCondition-->
<xsl:template name="accessCondition">
	<xsl:for-each select="rights_statement | rights-statement">
		<xsl:if test="contains(normalize-space(.), 'rightsstatements.org')">
			<accessCondition type="rights">
				<!--xsl:value-of select="normalize-space(.)"/-->
				<xsl:choose>
					<xsl:when test="contains(normalize-space(.), 'UND/1.0/')">
						<xsl:text>Copyright Undetermined</xsl:text>
					</xsl:when>
					<xsl:when test="contains(normalize-space(.), 'InC/1.0/')">
						<xsl:text>In Copyright</xsl:text>
					</xsl:when>
					<xsl:when test="contains(normalize-space(.), 'InC-OW-EU/1.0/')">
						<xsl:text>In Copyright - EU Orphan Work</xsl:text>
					</xsl:when>
					<xsl:when test="contains(normalize-space(.), 'InC-EDU/1.0/')">
						<xsl:text>In Copyright - Educational Use Permitted</xsl:text>
					</xsl:when>
					<xsl:when test="contains(normalize-space(.), 'InC-NC/1.0/')">
						<xsl:text>In Copyright - Non-Commercial Use Permitted</xsl:text>
					</xsl:when>
					<xsl:when test="contains(normalize-space(.), 'InC-RUU/1.0/')">
						<xsl:text>In Copyright - Rights-holder(s) Unlocatable or Unidentifiable</xsl:text>
					</xsl:when>
					<xsl:when test="contains(normalize-space(.), 'NoC-CR/1.0/')">
						<xsl:text>No Copyright - Contractual Restrictions</xsl:text>
					</xsl:when>
					<xsl:when test="contains(normalize-space(.), 'NoC-NC/1.0/')">
						<xsl:text>No Copyright - Non-Commercial Use Only</xsl:text>
					</xsl:when>
					<xsl:when test="contains(normalize-space(.), 'NoC-OKLR/1.0/')">
						<xsl:text>No Copyright - Other Known Legal Restrictions</xsl:text>
					</xsl:when>
					<xsl:when test="contains(normalize-space(.), 'NoC-US/1.0/')">
						<xsl:text>No Copyright - United States</xsl:text>
					</xsl:when>
					<xsl:when test="contains(normalize-space(.), 'CNE/1.0/')">
						<xsl:text>Copyright Not Evaluated</xsl:text>
					</xsl:when>
					<xsl:when test="contains(normalize-space(.), 'NKC/1.0/')">
						<xsl:text>No Known Copyright</xsl:text>
					</xsl:when>
				</xsl:choose>
			</accessCondition>
		</xsl:if>
	</xsl:for-each>
	<xsl:for-each select="license">
		<xsl:if test="contains(normalize-space(.), 'creativecommons.org/licenses/')">
			<accessCondition type="license">
				<xsl:choose>
					<xsl:when test="contains(normalize-space(.), 'creativecommons.org/licenses/by-nc-sa')">
						<xsl:text>Attribution-NonCommercial-ShareAlike International (CC BY-NC-SA)</xsl:text>
					</xsl:when>
					<xsl:when test="contains(normalize-space(.), 'creativecommons.org/licenses/by-nd')">
						<xsl:text>Attribution-NoDerivatives International (CC BY-ND)</xsl:text>
					</xsl:when>
					<xsl:when test="contains(normalize-space(.), 'creativecommons.org/licenses/by-sa')">
						<xsl:text>Attribution-ShareAlike International (CC BY-SA)</xsl:text>
					</xsl:when>
					<xsl:when test="contains(normalize-space(.), 'creativecommons.org/licenses/by')">
						<xsl:text>Attribution International (CC BY)</xsl:text>
					</xsl:when>
					<xsl:when test="contains(normalize-space(.), 'creativecommons.org/licenses/by-nc-nd')">
						<xsl:text>Attribution-NonCommercial-NoDerivatives International (CC BY-NC-ND)</xsl:text>
					</xsl:when>
					<xsl:when test="contains(normalize-space(.), 'creativecommons.org/licenses/by-nc')">
						<xsl:text>Attribution-NonCommercial International (CC BY-NC)</xsl:text>
					</xsl:when>		
					<xsl:when test="contains(normalize-space(.), 'creativecommons.org/publicdomain/zero')">
						<xsl:text>CC0 Universal (CC0) Public Domain Dedication (No Copyright)</xsl:text>
					</xsl:when>
					<xsl:when test="contains(normalize-space(.), 'creativecommons.org/publicdomain/mark')">
						<xsl:text>Public Domain Mark (No Copyright)</xsl:text>
					</xsl:when>	
					<xsl:when test="contains(normalize-space(.), 'www.europeana.eu/portal/rights/rr-r.html')">
						<xsl:text>Rights Reserved - Restricted Access</xsl:text>
					</xsl:when>	
				</xsl:choose>
			</accessCondition>
		</xsl:if>
	</xsl:for-each>
</xsl:template>


<!--subjects-->
<xsl:template name="subjects">

	<xsl:for-each select="subject/subject">
		<xsl:if test=".!=''">
			<subject>
				<topic>
					<xsl:value-of select="normalize-space(.)"/>
				</topic>
			</subject>
		</xsl:if>
	</xsl:for-each>

<!--COME BACK TO THIS eventually-->
	<xsl:for-each select="based_near">
		<xsl:if test="not(id)">
			<subject>
				<geographic>
					<xsl:value-of select="."/>
				</geographic>
			</subject>
		</xsl:if>
		
		<!--xsl:if test="id">
			<xsl:value-of select="document(concat(id, 'about.rdf'))/rdf:RDF/gn:Feature/gn:name/text()"/>
		</xsl:if-->
	</xsl:for-each>


</xsl:template>


<!--identifer-->
<xsl:template name="identifier">
	<!--xsl:for-each select="identifier"-->
	<xsl:for-each select="identifier/identifier">	
		<xsl:if test=".!=''">
			<identifier type="local" displayLabel="ID">
				<xsl:value-of select="normalize-space(.)"/>
			</identifier>
		</xsl:if>
	</xsl:for-each>
	<identifier displayLabel="PID" type="local"><xsl:value-of select="id"/></identifier>
	<location>
		<url displayLabel="Digital Content" access="object in context">
			<xsl:text>https://arch.library.northwestern.edu/concern/generic_works/</xsl:text><!--01NWU:Change this to use a local URL-->
			<xsl:value-of select="id"/>
		</url>
		<url displayLabel="Thumbnail" note="thumbnail">
			<xsl:text>https://arch.library.northwestern.edu/downloads/</xsl:text><!--01NWU:Change this to use a local URL-->		
			<xsl:value-of select="thumbnail-id"/>
			<xsl:text>?file=thumbnail</xsl:text>
		</url>
	</location>
</xsl:template>



<xsl:template name="relatedItem">
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
</xsl:template>	
	


<!--recordInfo-->
<xsl:template name="recordInfo">
	<recordInfo>
		<recordOrigin>Arch</recordOrigin><!--NUL specific repository name-->
		<recordContentSource authority="marcorg">IEN</recordContentSource><!--NUL specific MARC code-->
		<recordCreationDate encoding="marc"><xsl:value-of select="create_date"/></recordCreationDate>
		<recordChangeDate encoding="iso8601"><xsl:value-of select="format-dateTime(current-dateTime(),'[Y0001][M01][D01][H01][m01][s01]')"/>.0</recordChangeDate>
		<recordIdentifier source="IEN"><!--NUL specific MARC code-->
			<xsl:value-of select="id"/>
		</recordIdentifier>
		<languageOfCataloging><languageTerm authority="iso639-2b" type="code">eng</languageTerm></languageOfCataloging>
		<recordInfoNote>item</recordInfoNote>
	</recordInfo>
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