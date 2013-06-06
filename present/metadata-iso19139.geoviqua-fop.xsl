<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:gml="http://www.opengis.net/gml" xmlns:fra="http://www.cnig.gouv.fr/2005/fra"
  xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:gts="http://www.isotc211.org/2005/gts"
  xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:geonet="http://www.fao.org/geonetwork"
  xmlns:date="http://exslt.org/dates-and-times" xmlns:exslt="http://exslt.org/common"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

  <!-- Redirect to iso19139 default layout first then GeoViQua specific stuff -->
  <xsl:template name="metadata-fop-iso19139.geoviqua">
	<xsl:param name="schema"/>
    
    <xsl:call-template name="metadata-fop-iso19139">
      <xsl:with-param name="schema" select="'iso19139'"/>
    </xsl:call-template>

    <xsl:variable name="geoBbox">
      <xsl:apply-templates mode="elementFop"
        select="./gmd:identificationInfo/*/gmd:extent/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox |
              ./gmd:identificationInfo/*/srv:extent/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox">
        <xsl:with-param name="schema" select="$schema"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:variable name="timeExtent">
      <xsl:apply-templates mode="elementFop"
        select="./gmd:identificationInfo/*/gmd:extent/*/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimeInstant/gml:timePosition">
        <xsl:with-param name="schema" select="$schema"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="extent">
      <xsl:call-template name="blockElementFop">
        <xsl:with-param name="block" select="$geoBbox"/>
        <xsl:with-param name="label">
          <xsl:value-of
            select="/root/gui/schemas/iso19139/labels/element[@name='gmd:EX_GeographicBoundingBox']/label"
          />
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="blockElementFop">
        <xsl:with-param name="block" select="$timeExtent"/>
        <xsl:with-param name="label">
          <xsl:value-of
            select="/root/gui/schemas/iso19139/labels/element[@name='gmd:temporalElement']/label"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="extent">
      <xsl:call-template name="blockElementFop">
        <xsl:with-param name="block" select="$extent"/>
        <xsl:with-param name="label">
          <xsl:value-of
            select="/root/gui/schemas/iso19139/labels/element[@name='gmd:EX_Extent']/label"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>

    <xsl:call-template name="blockElementFop">
      <xsl:with-param name="block"> 

        <xsl:copy-of select="$extent"/>
        
      </xsl:with-param>
      <xsl:with-param name="label">
        <xsl:value-of select="'GeoViQua Specific Information'"/>
      </xsl:with-param>
    </xsl:call-template>
	
  </xsl:template>

</xsl:stylesheet>
