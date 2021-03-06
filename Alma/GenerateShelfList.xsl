<?xml version="1.0" encoding="UTF-16"?>
<!--This creates a &#9;delimited flat file with one row per holding records with location code starting 'with the value of $location-->
<!--Change the value of the $location below to look at different holdings.-->
<!--Includes MMSID, Title, 300, and holding information.-->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fn="http://www.w3.org/2005/xpath-functions" 
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:mix="http://www.loc.gov/mix/" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

<xsl:output method="text" indent="no"/>

<xsl:variable name="location">mrare</xsl:variable>

	<xsl:template match="collection">
<!--write out headings for the csv-->		
<!--Each of the headings below corresponds to a named template which populates the column under the heading with the EXCEPTION
 of Location, Call Number, Note, and Holding Summary, which are all included in the Holding template.-->
<!--If you add or remove a named template, be sure to adjust the CSV file headings immediately below to match.-->
	
		<xsl:text>MMS ID</xsl:text>
		<xsl:text> &#9;</xsl:text>
		<xsl:text>Holding ID</xsl:text>
		<xsl:text> &#9;</xsl:text>
		<xsl:text>Title</xsl:text>
		<xsl:text> &#9;</xsl:text>
		<xsl:text>Physical Description</xsl:text>
		<xsl:text> &#9;</xsl:text>	
		<xsl:if test="contains($location,'mstx')">
			<xsl:text>Largest dimension (in cm)</xsl:text>
			<xsl:text> &#9;</xsl:text>	
		</xsl:if>
		<xsl:text>Location</xsl:text>
		<xsl:text> &#9;</xsl:text>
		<xsl:if test="contains($location,'nspec')">
			<xsl:text>Derived Location</xsl:text>
			<xsl:text> &#9;</xsl:text>	
		</xsl:if>
		<xsl:text>Call Number</xsl:text>
		<xsl:text> &#9;</xsl:text>
		<xsl:text>Note</xsl:text>
		<xsl:text> &#9;</xsl:text>
		<xsl:text>Holding Summary</xsl:text>
		<xsl:text> &#9;</xsl:text>
		<xsl:if test="contains($location,'nspec')">
			<xsl:text>Is this a serial?</xsl:text>
			<xsl:text> &#9;</xsl:text>
		</xsl:if>
		<xsl:if test="contains($location,'nspec')">
			<xsl:text>Is this an MVSET?</xsl:text>
			<xsl:text> &#9;</xsl:text>
		</xsl:if>
				<xsl:if test="contains($location,'nspec')">
			<xsl:text>Is this a billing record?</xsl:text>
			<xsl:text> &#9;</xsl:text>
		</xsl:if>
		<xsl:apply-templates/>
				
	</xsl:template>


	<xsl:template match="record">
		
		<xsl:for-each select="datafield[@tag='852']/subfield[@code='c']"> <!--creates an output row for each Holding, not for each Bib record-->
			<!--xsl:if test=".=$location"--><!--Use this code to pull the exact location instead of one that starts with a location code.-->
			<xsl:if test="starts-with(.,$location)"><!--Only looks at Holding records in $location; we don't care about other locations-->
				<xsl:call-template name="MMSID"/>
				<xsl:call-template name="HoldingID"/>
				<xsl:call-template name="Title"/>
				<xsl:call-template name="PhysDesc"/>
				<xsl:if test="contains($location,'mstx')">
					<xsl:call-template name="LargestDimension"/>
				</xsl:if>
				<xsl:call-template name="Holding">
					<xsl:with-param name="whichHolding">
						<xsl:value-of select="../subfield[@code='8']"/>
					</xsl:with-param>
				</xsl:call-template>	
				<xsl:call-template name="Serial"/>
				<xsl:call-template name="MVSet"/>
				<xsl:call-template name="BillingRecord"/>				
			</xsl:if>			
		</xsl:for-each>			
			
	</xsl:template>

	
	<xsl:template name="MMSID">
		<xsl:text>&#xa;</xsl:text>
		<xsl:value-of select="../../controlfield[@tag='001']"/>		
		<xsl:text> &#9;</xsl:text>
	</xsl:template>
	
	<xsl:template name="HoldingID">
		<xsl:value-of select="../subfield[@code='8']"/>	
		<xsl:text> &#9;</xsl:text>
	</xsl:template>

	<xsl:template name="Title">
		<xsl:value-of select="../../datafield[@tag='245']"/>		
		<xsl:text> &#9;</xsl:text>
	</xsl:template>
	
	<xsl:template name="PhysDesc">
		<xsl:choose>
			<xsl:when test="../../datafield[@tag='300']">
				<xsl:if test="../../datafield[@tag='300']/subfield[@code='a']">
					<xsl:value-of select="../../datafield[@tag='300']/subfield[@code='a']"/>		
					<xsl:text> </xsl:text>
				</xsl:if>	
				<xsl:if test="../../datafield[@tag='300']/subfield[@code='b']">
					<xsl:value-of select="../../datafield[@tag='300']/subfield[@code='b']"/>		
					<xsl:text> </xsl:text>
				</xsl:if>	
				<xsl:if test="../../datafield[@tag='300']/subfield[@code='c']">
					<xsl:value-of select="../../datafield[@tag='300']/subfield[@code='c']"/>		
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>No physical description</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text> &#9;</xsl:text>
	</xsl:template>

	<xsl:template name="LargestDimension">
		<xsl:choose><!--FIX THIS FIRST ONE-->
<!--			<xsl:when test="contains(../../datafield[@tag='300']/subfield[@code='c'],'-') and contains(../../datafield[@tag='300']/subfield[@code='c'],'x')">
				<xsl:value-of select="substring-before(substring-after(substring-after(../../datafield[@tag='300']/subfield[@code='x'],'x'),'-'),'cm')"/>
			</xsl:when>		-->
			<xsl:when test="../../datafield[@tag='300']/subfield[@code='c']">
				<xsl:choose>
					<xsl:when test="contains(../../datafield[@tag='300']/subfield[@code='c'],'-')">
						<xsl:value-of select="substring-after(substring-before(../../datafield[@tag='300']/subfield[@code='c'],'cm'),'-')"/>
					</xsl:when>
					<xsl:when test="contains(../../datafield[@tag='300']/subfield[@code='c'],'x')">
						<xsl:value-of select="substring-after(substring-before(../../datafield[@tag='300']/subfield[@code='c'],'cm'),'x')"/>
					</xsl:when>
					<xsl:when test="contains(../../datafield[@tag='300']/subfield[@code='c'],'X')">
						<xsl:value-of select="substring-after(substring-before(../../datafield[@tag='300']/subfield[@code='c'],'cm'),'X')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="substring-before(../../datafield[@tag='300']/subfield[@code='c'],'cm')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>None</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text> &#9;</xsl:text>
				
	</xsl:template>
	
	<xsl:template name="Holding">	<!--This code corresponds to the Location heading. Note that it encompasses the entirety of the Holding template.-->
		<xsl:param name="whichHolding"/>

			<xsl:value-of select="."/>		<!--This code corresponds to the Call Number heading-->
			<xsl:text> &#9;</xsl:text>
			
			<xsl:if test="contains($location,'nspec')">	<!--This code corresponds to the Derived Location heading-->
			<!--If there is an embedded size designation OR if there is a size in $k, then we amend the location code in the Derived Location-->
				<xsl:choose>
					<xsl:when test="contains(../subfield[@code='h'],' L ')
						or contains(../subfield[@code='h'],' l ') or contains(../subfield[@code='h'],' Large ') or contains(../subfield[@code='h'],' large ')
						or contains(../subfield[@code='h'],' L1 ') or contains(../subfield[@code='h'],' L2 ') 
						or ../subfield[@code='k']='L' or ../subfield[@code='k']='l' or contains(../subfield[@code='k'],'Large') 
						or contains(../subfield[@code='k'],'large') or contains(../subfield[@code='k'],'L1') or contains(../subfield[@code='k'],'L2')">
							<xsl:text>nspec,lg</xsl:text>
					</xsl:when>
					<xsl:when test="contains(../subfield[@code='h'],' F ')
						or contains(../subfield[@code='h'],' f ') or contains(../subfield[@code='h'],' Folio ') or contains(../subfield[@code='h'],' folio ')
						or contains(../subfield[@code='k'],'F') or contains(../subfield[@code='k'],'f') or contains(../subfield[@code='k'],'Folio') 
						or contains(../subfield[@code='k'],'folio')">
							<xsl:text>nspec,fol</xsl:text>
					</xsl:when>
					<xsl:when test="contains(../subfield[@code='h'],' Pam ') or contains(../subfield[@code='h'],' pam ')
						or contains(../subfield[@code='h'],' Pamphlet ') or contains(../subfield[@code='h'],' Pamphlets ')
						or contains(../subfield[@code='h'],' pamphlets ')">
							<xsl:text>nspec,pam</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="../subfield[@code='c']"/>
					</xsl:otherwise>
				</xsl:choose>
				 <xsl:text> &#9;</xsl:text>
			</xsl:if>
			
		<xsl:if test="../subfield[@code='h']"> <!--This code corresponds to the Call Number heading-->
			<xsl:value-of select="../subfield[@code='h']"/>		
			<xsl:text> </xsl:text>
			<xsl:value-of select="../subfield[@code='i']"/>		
			<xsl:text> </xsl:text>
			<xsl:value-of select="../subfield[@code='t']"/>		
		</xsl:if>
		<xsl:text> &#9;</xsl:text>
		
		<xsl:if test="../subfield[@code='k']"> <!--This code corresponds to the Note heading-->
			<xsl:value-of select="../subfield[@code='k']"/>		
		</xsl:if>
		<xsl:text> &#9;</xsl:text>		
	
		<!--This code corresponds to the Holding Summary heading-->
		<xsl:for-each select="../../datafield[@tag='866']">
		
			<xsl:variable name="thatsAll"> <!--check to see if the 866 is affliated with the preceding 852 or the next one-->
				<xsl:choose>
					<xsl:when test="preceding-sibling::datafield[@tag='852'][1]/subfield[@code='8'] != $whichHolding">
						<xsl:text>yes</xsl:text> <!--A value of yes here means to stop recording 866s - they're part of the next holding-->
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>no</xsl:text>
					</xsl:otherwise>		
				</xsl:choose>
			</xsl:variable>
											
			<xsl:if test="$thatsAll='no'" >
				<xsl:value-of select="subfield[@code='a']"/>
				<xsl:text> ; </xsl:text> <!--come back to this and fix this so that the semi-colon doesn't appear after the last 866 in the set. Harder than it looks.-->
			</xsl:if>
						
			</xsl:for-each>

		<xsl:text> &#9;</xsl:text>

	</xsl:template>
	
	<xsl:template name="Serial">
		<xsl:choose>
			<xsl:when test="substring(../../leader,8,1)='s' or contains(../subfield[@code='h'],' Serial ') or contains(../subfield[@code='h'],' serial ')">
				<xsl:text>y</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>n</xsl:text>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:text> &#9;</xsl:text>
		
	</xsl:template>
		
	<xsl:template name="MVSet">
		<xsl:choose>
			<xsl:when test="../../datafield[@tag='866']">
				<xsl:text>y</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>n</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		
		<xsl:text> &#9;</xsl:text>
		
	</xsl:template>

	<xsl:template name="BillingRecord">
		<xsl:choose>
			<xsl:when test="starts-with(../../datafield[@tag='245'],'[Billin')">
				<xsl:text>y</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>n</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		
		<xsl:text> &#9;</xsl:text>	</xsl:template>

</xsl:stylesheet>