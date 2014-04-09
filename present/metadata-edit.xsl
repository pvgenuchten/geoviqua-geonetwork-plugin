<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl ="http://www.w3.org/1999/XSL/Transform"
  xmlns:gvq="http://www.geoviqua.org/QualityInformationModel/4.0"
  xmlns:gmd="http://www.isotc211.org/2005/gmd"
  xmlns:gts="http://www.isotc211.org/2005/gts"
  xmlns:gco="http://www.isotc211.org/2005/gco"
  xmlns:gmx="http://www.isotc211.org/2005/gmx"
  xmlns:srv="http://www.isotc211.org/2005/srv"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:gml="http://www.opengis.net/gml"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:geonet="http://www.fao.org/geonetwork"
  xmlns:exslt="http://exslt.org/common"
  exclude-result-prefixes="gmx xsi gmd gco gml gts srv xlink exslt geonet">

  <xsl:import href="metadata-view.xsl"/>
  <xsl:import href="metadata-utils.xsl"/>

  <!-- Use this mode on the root element to add hidden fields to the editor -->
  <xsl:template mode="schema-hidden-fields" match="gvq:GVQ_Metadata|*[@gco:isoType='gmd:MD_Metadata']" priority="2">
    <!-- The GetCapabilities URL -->
    <xsl:variable name="capabilitiesUrl">
      <xsl:call-template name="getServiceURL">
        <xsl:with-param name="metadata" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <input type="hidden" id="serviceUrl" value="{$capabilitiesUrl}"/>
    
  </xsl:template>


  <!-- ===================================================================== -->
  <!-- apply the geoviqua profile -->
  <!-- ===================================================================== -->
  
  <!-- main template - the way into processing iso19139.geoviqua -->
  <xsl:template match="metadata-iso19139.geoviqua" name="metadata-iso19139.geoviqua">
    <xsl:param name="schema"/>
    <xsl:param name="edit" select="false()"/>
    <xsl:param name="embedded"/>
    
    <!-- process in profile mode first -->
    <xsl:variable name="geoviquaElements">
      <xsl:apply-templates mode="iso19139.geoviqua" select="." >
      <xsl:with-param name="schema" select="$schema"/>
        <xsl:with-param name="edit"   select="$edit"/>
        <xsl:with-param name="embedded" select="$embedded" />
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:choose>
      <!-- if we got a match in profile mode then show it -->
      <xsl:when test="count($geoviquaElements/*)>0">
        <xsl:copy-of select="$geoviquaElements"/>
      </xsl:when>
      <!-- otherwise process in base iso19139 mode -->
      <xsl:otherwise>
          <xsl:apply-templates mode="iso19139" select="." >
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit"   select="$edit"/>
            <xsl:with-param name="embedded" select="$embedded" />
          </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- ===================================================================== -->
  <!-- these elements should be boxed -->
  <!-- ===================================================================== -->

  <xsl:template mode="iso19139.geoviqua" match="gmd:identificationInfo|gmd:distributionInfo|gmd:descriptiveKeywords|gmd:thesaurusName|
              *[name(..)='gmd:resourceConstraints']|gmd:spatialRepresentationInfo|gmd:pointOfContact|
              gvq:dataQualityInfo|gmd:contentInfo|gmd:distributionFormat|
              gmd:referenceSystemInfo|gmd:spatialResolution|gmd:offLine|gmd:projection|gmd:ellipsoid|gmd:extent[name(..)!='gmd:EX_TemporalExtent']|gmd:attributes|gmd:verticalCRS|
              gmd:geographicBox|gmd:EX_TemporalExtent|gmd:MD_Distributor|
              srv:containsOperations|srv:SV_CoupledResource|
              gmd:metadataConstraints">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    
    <xsl:apply-templates mode="complexElement" select=".">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
    </xsl:apply-templates>
  </xsl:template>
  
  
  <xsl:template name="file-or-logo-upload-geoviqua">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:param name="ref"/>
    <xsl:param name="value"/>
    <xsl:param name="src"/>
    <xsl:param name="action"/>
    <xsl:param name="delButton" select="normalize-space($value)!=''"/>
    <xsl:param name="setButton" select="normalize-space($value)!=''"/>
    <xsl:param name="visible" select="not($setButton)"/>
    <xsl:param name="setButtonLabel" select="/root/gui/strings/insertFileMode"/>
    <xsl:param name="label" select="/root/gui/strings/file"/>
    
    
    <xsl:apply-templates mode="complexElement" select=".">
      <xsl:with-param name="schema"   select="$schema"/>
      <xsl:with-param name="edit"     select="$edit"/>
      <xsl:with-param name="content">
        
        <xsl:choose>
          <xsl:when test="$edit">
            <xsl:variable name="id" select="generate-id(.)"/>
            <xsl:variable name="isXLinked" select="count(ancestor-or-self::node()[@xlink:href]) > 0" />
            
            <div id="{$id}"/>
            
            <xsl:call-template name="simpleElementGui">
              <xsl:with-param name="schema" select="$schema"/>
              <xsl:with-param name="edit" select="$edit"/>
              <xsl:with-param name="title" select="$label"/>
              <xsl:with-param name="text">
                <xsl:if test="$visible">
                  <input id="_{$ref}_src" class="md" type="text" name="_{$ref}_src" value="{$src}" size="40">
                    <xsl:if test="$isXLinked"><xsl:attribute name="disabled">disabled</xsl:attribute></xsl:if>
                  </input>
                </xsl:if>
                <button class="content" onclick="{$action}" type="button">
                  <xsl:value-of select="$setButtonLabel"/>
                </button>
              </xsl:with-param>
              <xsl:with-param name="id" select="concat('db_',$ref)"/>
              <xsl:with-param name="visible" select="$setButton"/>
            </xsl:call-template>
            
            <xsl:if test="$delButton">
              <xsl:apply-templates mode="iso19139FileRemove" select="gmx:FileName">
                <xsl:with-param name="access" select="'public'"/>
                <xsl:with-param name="id" select="$id"/>
                <xsl:with-param name="geo" select="false()"/>
              </xsl:apply-templates>
            </xsl:if>
            
            <xsl:call-template name="simpleElementGui">
              <xsl:with-param name="schema" select="$schema"/>
              <xsl:with-param name="edit" select="$edit"/>
              <xsl:with-param name="title">
                <xsl:call-template name="getTitle">
                  <xsl:with-param name="name"   select="name(.)"/>
                  <xsl:with-param name="schema" select="$schema"/>
                </xsl:call-template>
              </xsl:with-param>
              <xsl:with-param name="text">
                <input id="_{$ref}" class="md" type="text" name="_{$ref}" value="{$value}" size="40" >
                  <xsl:if test="$isXLinked"><xsl:attribute name="disabled">disabled</xsl:attribute></xsl:if>
                </input>
              </xsl:with-param>
              <xsl:with-param name="id" select="concat('di_',$ref)"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <!-- in view mode, if a label is provided display a simple element for this label 
              with the link variable (could be an image or a hyperlink)-->
            <xsl:variable name="link">
              <xsl:choose>
                <xsl:when test="gvq:is-image(gmx:FileName/@src)">
                  <div class="logo-wrap"><img src="{gmx:FileName/@src}"/></div>
                </xsl:when>
                <xsl:otherwise>
                  <a href="{gmx:FileName/@src}"><xsl:value-of select="gmx:FileName"/></a>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            
            <xsl:if test="$label">
              <xsl:call-template name="simpleElementGui">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit" select="$edit"/>
                <xsl:with-param name="title" select="$label"/>
                <xsl:with-param name="text">
                  <xsl:copy-of select="$link"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:if>
            
            <xsl:call-template name="simpleElementGui">
              <xsl:with-param name="schema" select="$schema"/>
              <xsl:with-param name="edit" select="$edit"/>
              <xsl:with-param name="title">
                <xsl:call-template name="getTitle">
                  <xsl:with-param name="name"   select="name(.)"/>
                  <xsl:with-param name="schema" select="$schema"/>
                </xsl:call-template>
              </xsl:with-param>
              <xsl:with-param name="text">
                <xsl:choose>
                  <xsl:when test="$label">
                    <xsl:value-of select="gmx:FileName"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:copy-of select="$link"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  
  
  <!-- ============================================================================= -->

  <xsl:template mode="iso19139GetAttributeText" match="@*">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    
    <xsl:variable name="name"     select="local-name(..)"/>
    <xsl:variable name="qname"    select="name(..)"/>
    <xsl:variable name="value"    select="../@codeListValue"/>
    
    <xsl:choose>
      <xsl:when test="$qname='gmd:LanguageCode'">
        <xsl:apply-templates mode="iso19139" select="..">
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <!--
          Get codelist from profil first and use use default one if not
          available.
        -->
        <xsl:variable name="codelistProfil">
          <xsl:choose>
            <xsl:when test="starts-with($schema,'iso19139.')">
              <xsl:copy-of
                select="/root/gui/schemas/*[name(.)=$schema]/codelists/codelist[@name = $qname]/*" />
            </xsl:when>
            <xsl:otherwise />
          </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="codelistCore">
          <xsl:choose>
            <xsl:when test="normalize-space($codelistProfil)!=''">
              <xsl:copy-of select="$codelistProfil" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of
                select="/root/gui/schemas/*[name(.)='iso19139']/codelists/codelist[@name = $qname]/*" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="codelist" select="exslt:node-set($codelistCore)" />
        <xsl:variable name="isXLinked" select="count(ancestor-or-self::node()[@xlink:href]) > 0" />

        <xsl:choose>
          <xsl:when test="$edit=true()">
            <!-- codelist in edit mode -->
            <select class="md" name="_{../geonet:element/@ref}_{name(.)}" id="_{../geonet:element/@ref}_{name(.)}" size="1">
              <!-- Check element is mandatory or not -->
              <xsl:if test="../../geonet:element/@min='1' and $edit">
                <xsl:attribute name="onchange">validateNonEmpty(this);</xsl:attribute>
              </xsl:if>
              <xsl:if test="$isXLinked">
                <xsl:attribute name="disabled">disabled</xsl:attribute>
              </xsl:if>
              <option name=""/>
              <xsl:for-each select="$codelist/entry[not(@hideInEditMode)]">
                <xsl:sort select="label"/>
                <option>
                  <xsl:if test="code=$value">
                    <xsl:attribute name="selected"/>
                  </xsl:if>
                  <xsl:attribute name="value"><xsl:value-of select="code"/></xsl:attribute>
                  <xsl:attribute name="title"><xsl:value-of select="description"/></xsl:attribute>
                  <xsl:value-of select="label"/>
                </option>
              </xsl:for-each>
            </select>
          </xsl:when>
          <xsl:otherwise>
            <!-- codelist in view mode -->
            <xsl:if test="normalize-space($value)!=''">
              <xsl:variable name="label" select="$codelist/entry[code = $value]/label"/>
              <xsl:choose>
                <xsl:when test="normalize-space($label)!=''">
                  <b><xsl:value-of select="$label"/></b>
                  <xsl:value-of select="concat(': ',$codelist/entry[code = $value]/description)"/>
                </xsl:when>
                <xsl:otherwise>
                  <b><xsl:value-of select="$value"/></b>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <!--
    <xsl:call-template name="getAttributeText">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
    </xsl:call-template>
    -->
  </xsl:template>
  
  

  <xsl:template mode="iso19139" match="//gvq:GVQ_Metadata/gmd:characterSet|//*[@gco:isoType='gmd:MD_Metadata']/gmd:characterSet" priority="2">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    
    <xsl:call-template name="iso19139Codelist">
      <xsl:with-param name="schema"  select="$schema"/>
      <xsl:with-param name="edit"    select="false()"/>
    </xsl:call-template>
  </xsl:template>
  
  
  <!-- ============================================================================= -->
  <!-- descriptiveKeywords -->
  <!-- ============================================================================= -->
  <xsl:template mode="iso19139" match="gmd:descriptiveKeywords">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    
    <xsl:choose>
      <xsl:when test="$edit=true()">
    
        <xsl:variable name="content">
          <xsl:for-each select="gmd:MD_Keywords">
            <!-- FIXME : layout should move to metadata.xsl -->
            <col>
                      <xsl:apply-templates mode="elementEP" select="gmd:keyword|geonet:child[string(@name)='keyword']">
                        <xsl:with-param name="schema" select="$schema"/>
                        <xsl:with-param name="edit"   select="$edit"/>
                      </xsl:apply-templates>
                      <xsl:apply-templates mode="elementEP" select="gmd:type|geonet:child[string(@name)='type']">
                        <xsl:with-param name="schema" select="$schema"/>
                        <xsl:with-param name="edit"   select="$edit"/>
                      </xsl:apply-templates>
            </col>
            <col>                    
                      <xsl:apply-templates mode="elementEP" select="gmd:thesaurusName|geonet:child[string(@name)='thesaurusName']">
                        <xsl:with-param name="schema" select="$schema"/>
                        <xsl:with-param name="edit"   select="$edit"/>
                      </xsl:apply-templates>
            </col>
          </xsl:for-each>
        </xsl:variable>
        
        <xsl:apply-templates mode="complexElement" select=".">
          <xsl:with-param name="schema"  select="$schema"/>
          <xsl:with-param name="edit"    select="$edit"/>
          <xsl:with-param name="content">
            <xsl:call-template name="columnElementGui">
              <xsl:with-param name="cols" select="$content"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="simpleElement" select=".">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="title">
            <xsl:call-template name="getTitle">
              <xsl:with-param name="name" select="name(.)"/>
              <xsl:with-param name="schema" select="$schema"/>
            </xsl:call-template>
            <xsl:if test="gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString">
              (<xsl:value-of
                select="gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString"/>)
            </xsl:if>
          </xsl:with-param>
          <xsl:with-param name="text">
            <xsl:variable name="value">
              <xsl:for-each select="gmd:MD_Keywords/gmd:keyword">
                <xsl:if test="position() &gt; 1"><xsl:text>, </xsl:text></xsl:if>

								<xsl:choose>
									<xsl:when test="gmx:Anchor">
										<a href="{gmx:Anchor/@xlink:href}"><xsl:value-of select="if (gmx:Anchor/text()) then gmx:Anchor/text() else gmx:Anchor/@xlink:href"/></a>
									</xsl:when>
									<xsl:otherwise>

                <xsl:call-template name="translatedString">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="langId">
                        <xsl:call-template name="getLangId">
                              <xsl:with-param name="langGui" select="/root/gui/language"/>
                              <xsl:with-param name="md" select="ancestor-or-self::*[name(.)='gvq:GVQ_Metadata' or @gco:isoType='gmd:MD_Metadata']" />
                          </xsl:call-template>
                    </xsl:with-param>
                  </xsl:call-template>

										</xsl:otherwise>
									</xsl:choose>

              </xsl:for-each>
              <xsl:if test="gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue!=''">
                <xsl:text> (</xsl:text>
                <xsl:value-of select="gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue"/>
                <xsl:text>)</xsl:text>
              </xsl:if>
              <xsl:text>.</xsl:text>
            </xsl:variable>
            <xsl:copy-of select="$value"/>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  

  <!-- ==================================================================== -->
  <!-- Metadata -->
  <!-- ==================================================================== -->

  <xsl:template mode="iso19139.geoviqua" match="gvq:GVQ_Metadata|*[@gco:isoType='gmd:MD_Metadata']">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:param name="embedded"/>

    <xsl:variable name="dataset" select="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='dataset' or normalize-space(gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue)=''"/>
    
    
    <xsl:choose>
    
      <!-- metadata tab -->
      <xsl:when test="$currTab='metadata'">
        <xsl:call-template name="iso19139.geoviquaMetadata">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
          <xsl:with-param name="flat"   select="false"/>
        </xsl:call-template>
      </xsl:when>

      <!-- identification tab -->
      <xsl:when test="$currTab='identification'">
        <xsl:apply-templates mode="elementEP" select="gmd:identificationInfo|geonet:child[string(@name)='identificationInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- maintenance tab -->
      <xsl:when test="$currTab='maintenance'">
        <xsl:apply-templates mode="elementEP" select="gmd:metadataMaintenance|geonet:child[string(@name)='metadataMaintenance']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- constraints tab -->
      <xsl:when test="$currTab='constraints'">
        <xsl:apply-templates mode="elementEP" select="gmd:metadataConstraints|geonet:child[string(@name)='metadataConstraints']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- spatial tab -->
      <xsl:when test="$currTab='spatial'">
        <xsl:apply-templates mode="elementEP" select="gmd:spatialRepresentationInfo|geonet:child[string(@name)='spatialRepresentationInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- refSys tab -->
      <xsl:when test="$currTab='refSys'">
        <xsl:apply-templates mode="elementEP" select="gmd:referenceSystemInfo|geonet:child[string(@name)='referenceSystemInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- distribution tab -->
      <xsl:when test="$currTab='distribution'">
        <xsl:apply-templates mode="elementEP" select="gmd:distributionInfo|geonet:child[string(@name)='distributionInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- embedded distribution tab -->
      <xsl:when test="$currTab='distribution2'">
        <xsl:apply-templates mode="elementEP" select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>
      
      <!-- dataQuality tab -->
      <xsl:when test="$currTab='dataQuality'">
        <xsl:apply-templates mode="elementEP" select="gvq:dataQualityInfo|geonet:child[string(@name)='dataQualityInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- appSchInfo tab -->
      <xsl:when test="$currTab='appSchInfo'">
        <xsl:apply-templates mode="elementEP" select="gmd:applicationSchemaInfo|geonet:child[string(@name)='applicationSchemaInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- porCatInfo tab -->
      <xsl:when test="$currTab='porCatInfo'">
        <xsl:apply-templates mode="elementEP" select="gmd:portrayalCatalogueInfo|geonet:child[string(@name)='portrayalCatalogueInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- contentInfo tab -->
      <xsl:when test="$currTab='contentInfo'">
      <xsl:apply-templates mode="elementEP" select="gmd:contentInfo|geonet:child[string(@name)='contentInfo']">
        <xsl:with-param name="schema" select="$schema"/>
        <xsl:with-param name="edit"   select="$edit"/>
      </xsl:apply-templates>
      </xsl:when>
      
      <!-- extensionInfo tab -->
      <xsl:when test="$currTab='extensionInfo'">
      <xsl:apply-templates mode="elementEP" select="gmd:metadataExtensionInfo|geonet:child[string(@name)='metadataExtensionInfo']">
        <xsl:with-param name="schema" select="$schema"/>
        <xsl:with-param name="edit"   select="$edit"/>
      </xsl:apply-templates>
      </xsl:when>

      <!-- ISOMinimum tab -->
      <xsl:when test="$currTab='ISOMinimum'">
        <xsl:call-template name="isotabs.geoviqua">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
          <xsl:with-param name="dataset" select="$dataset"/>
          <xsl:with-param name="core" select="false()"/>
        </xsl:call-template>
      </xsl:when>

      <!-- ISOCore tab -->
      <xsl:when test="$currTab='ISOCore'">
        <xsl:call-template name="isotabs.geoviqua">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
          <xsl:with-param name="dataset" select="$dataset"/>
          <xsl:with-param name="core" select="true()"/>
        </xsl:call-template>
      </xsl:when>
      
      <!-- ISOAll tab -->
      <xsl:when test="$currTab='ISOAll'">
        <xsl:call-template name="iso19139.geoviquaComplete">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:call-template>
      </xsl:when>
      
      <!-- INSPIRE tab -->
      <xsl:when test="$currTab='inspire'">
        <xsl:call-template name="inspiretabs.geoviqua">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
          <xsl:with-param name="dataset" select="$dataset"/>          
        </xsl:call-template>
      </xsl:when>
      
      
      <!-- default -->
      <xsl:otherwise>
        <xsl:call-template name="iso19139.geoviquaSimple">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
          <xsl:with-param name="flat"   select="/root/gui/config/metadata-tab/*[name(.)=$currTab]/@flat"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ============================================================================= -->

  <xsl:template name="isotabs.geoviqua">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:param name="dataset"/>
    <xsl:param name="core"/>

    <!-- dataset or resource info in its own box -->
  
    <xsl:for-each select="gmd:identificationInfo/gvq:GVQ_DataIdentification|
            gmd:identificationInfo/srv:SV_ServiceIdentification|
            gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']|
            gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']">
      <xsl:call-template name="complexElementGuiWrapper">
        <xsl:with-param name="title">
        <xsl:choose>
          <xsl:when test="$dataset=true()">
            <xsl:value-of select="/root/gui/schemas/iso19139/labels/element[@name='gvq:GVQ_DataIdentification']/label"/>
          </xsl:when>
          <xsl:when test="local-name(.)='SV_ServiceIdentification' or @gco:isoType='srv:SV_ServiceIdentification'">
            <xsl:value-of select="/root/gui/schemas/iso19139/labels/element[@name='srv:SV_ServiceIdentification']/label"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'Resource Identification'"/><!-- FIXME i18n-->
          </xsl:otherwise>
        </xsl:choose>
        </xsl:with-param>
        <xsl:with-param name="content">
    
        <xsl:apply-templates mode="elementEP" select="gmd:citation/gmd:CI_Citation/gmd:title|gmd:citation/gmd:CI_Citation/geonet:child[string(@name)='title']
          |gmd:citation/gmd:CI_Citation/gmd:date|gmd:citation/gmd:CI_Citation/geonet:child[string(@name)='date']
          |gmd:abstract|geonet:child[string(@name)='abstract']
          |gmd:pointOfContact|geonet:child[string(@name)='pointOfContact']
          |gmd:descriptiveKeywords|geonet:child[string(@name)='descriptiveKeywords']
          ">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>

        
        <xsl:if test="$core and $dataset">
          <xsl:apply-templates mode="elementEP" select="gmd:spatialRepresentationType|geonet:child[string(@name)='spatialRepresentationType']
            |gmd:spatialResolution|geonet:child[string(@name)='spatialResolution']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit"   select="$edit"/>
          </xsl:apply-templates>
        </xsl:if>

        <xsl:apply-templates mode="elementEP" select="gmd:language|geonet:child[string(@name)='language']
          |gmd:characterSet|geonet:child[string(@name)='characterSet']
          |gmd:topicCategory|geonet:child[string(@name)='topicCategory']
          ">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>


        <xsl:if test="$dataset">
          <xsl:for-each select="gmd:extent/gmd:EX_Extent">
            <xsl:call-template name="complexElementGuiWrapper">
              <xsl:with-param name="title" select="/root/gui/schemas/iso19139/labels/element[@name='gmd:EX_Extent']/label"/>
              <xsl:with-param name="content">
                <xsl:apply-templates mode="elementEP" select="*">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="edit"   select="$edit"/>
                </xsl:apply-templates>
              </xsl:with-param>
              <xsl:with-param name="schema" select="$schema"/>
              <xsl:with-param name="edit"   select="$edit"/>
              <xsl:with-param name="realname"   select="'gmd:EX_Extent'"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:if>

        </xsl:with-param>
        <xsl:with-param name="schema" select="$schema"/>
        <xsl:with-param name="edit"   select="$edit"/>
        <xsl:with-param name="realname"   select="name(.)"/>
      </xsl:call-template>
    </xsl:for-each>

    <xsl:if test="$core and $dataset">

    <!-- scope and lineage in their own box -->
    
      <xsl:call-template name="complexElementGuiWrapper">
        <xsl:with-param name="title" select="/root/gui/schemas/iso19139/labels/element[@name='gmd:LI_Lineage']/label"/>
        <xsl:with-param name="id" select="generate-id(/root/gui/schemas/iso19139/labels/element[@name='gmd:LI_Lineage']/label)"/>
        <xsl:with-param name="content">

          <xsl:for-each select="gvq:dataQualityInfo/gvq:GVQ_DataQuality">
            <xsl:apply-templates mode="elementEP" select="gmd19157:scope|geonet:child[string(@name)='scope']
              |gmd19157:lineage|geonet:child[string(@name)='lineage']">
              <xsl:with-param name="schema" select="$schema"/>
              <xsl:with-param name="edit"   select="$edit"/>
            </xsl:apply-templates>
          </xsl:for-each>

        </xsl:with-param>
        <xsl:with-param name="schema" select="$schema"/>
        <xsl:with-param name="group" select="/root/gui/strings/dataQualityTab"/>
        <xsl:with-param name="edit" select="$edit"/>
        <xsl:with-param name="realname"   select="'gvq:DataQualityInfo'"/>
      </xsl:call-template>

    <!-- referenceSystemInfo in its own box -->
    
      <xsl:call-template name="complexElementGuiWrapper">
        <xsl:with-param name="title" select="/root/gui/schemas/iso19139/labels/element[@name='gmd:referenceSystemInfo']/label"/>
        <xsl:with-param name="id" select="generate-id(/root/gui/schemas/iso19139/labels/element[@name='gmd:referenceSystemInfo']/label)"/>
        <xsl:with-param name="content">

        <xsl:for-each select="gmd:referenceSystemInfo/gmd:MD_ReferenceSystem">
          <xsl:apply-templates mode="elementEP" select="gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code
            |gmd:referenceSystemIdentifier/gmd:RS_Identifier/geonet:child[string(@name)='code']
            |gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:codeSpace
            |gmd:referenceSystemIdentifier/gmd:RS_Identifier/geonet:child[string(@name)='codeSpace']
            ">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit"   select="$edit"/>
          </xsl:apply-templates>
        </xsl:for-each>

        </xsl:with-param>
        <xsl:with-param name="schema" select="$schema"/>
        <xsl:with-param name="group" select="/root/gui/strings/refSysTab"/>
        <xsl:with-param name="edit" select="$edit"/>
        <xsl:with-param name="realname"   select="'gmd:referenceSystemInfo'"/>
      </xsl:call-template>

      <!-- distribution Format and onlineResource(s) in their own box -->

      <xsl:call-template name="complexElementGuiWrapper">
        <xsl:with-param name="title" select="/root/gui/schemas/iso19139/labels/element[@name='gmd:distributionInfo']/label"/>
        <xsl:with-param name="id" select="generate-id(/root/gui/schemas/iso19139/labels/element[@name='gmd:distributionInfo']/label)"/>
        <xsl:with-param name="content">

        <xsl:for-each select="gmd:distributionInfo">
          <xsl:apply-templates mode="elementEP" select="*/gmd:distributionFormat|*/geonet:child[string(@name)='distributionFormat']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit"   select="$edit"/>
          </xsl:apply-templates>

          <xsl:apply-templates mode="elementEP" select="*/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine|*/gmd:transferOptions/gmd:MD_DigitalTransferOptions/geonet:child[string(@name)='onLine']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit"   select="$edit"/>
          </xsl:apply-templates>
        </xsl:for-each>

        </xsl:with-param>
        <xsl:with-param name="schema" select="$schema"/>
        <xsl:with-param name="group" select="/root/gui/strings/distributionTab"/>
        <xsl:with-param name="edit" select="$edit"/>
        <xsl:with-param name="realname" select="gmd:distributionInfo"/>
      </xsl:call-template>
      
    </xsl:if>

    <!-- metadata info in its own box -->

    <xsl:call-template name="complexElementGuiWrapper">
      <xsl:with-param name="title" select="/root/gui/schemas/iso19139/labels/element[@name='gvq:GVQ_Metadata']/label"/>
      <xsl:with-param name="id" select="generate-id(/root/gui/schemas/iso19139/labels/element[@name='gvq:GVQ_Metadata']/label)"/>
      <xsl:with-param name="content">

      <xsl:apply-templates mode="elementEP" select="gmd:fileIdentifier|geonet:child[string(@name)='fileIdentifier']
        |gmd:language|geonet:child[string(@name)='language']
        |gmd:characterSet|geonet:child[string(@name)='characterSet']
        |gmd:parentIdentifier|geonet:child[string(@name)='parentIdentifier']
        |gmd:hierarchyLevel|geonet:child[string(@name)='hierarchyLevel']
        |gmd:hierarchyLevelName|geonet:child[string(@name)='hierarchyLevelName']
        ">
        <xsl:with-param name="schema" select="$schema"/>
        <xsl:with-param name="edit"   select="$edit"/>
      </xsl:apply-templates>
    
      <!-- metadata contact info in its own box -->

      <xsl:for-each select="gmd:contact">

        <xsl:call-template name="complexElementGuiWrapper">
          <xsl:with-param name="title" select="/root/gui/schemas/iso19139/labels/element[@name='gmd:contact']/label"/>
          <xsl:with-param name="content">

            <xsl:apply-templates mode="elementEP" select="*/gmd:individualName|*/geonet:child[string(@name)='individualName']
              |*/gmd:organisationName|*/geonet:child[string(@name)='organisationName']
              |*/gmd:positionName|*/geonet:child[string(@name)='positionName']
              |*/gmd:contactInfo|*/geonet:child[string(@name)='contactInfo']
              |*/gmd:role|*/geonet:child[string(@name)='role']">
              <xsl:with-param name="schema" select="$schema"/>
              <xsl:with-param name="edit"   select="$edit"/>
            </xsl:apply-templates>

          </xsl:with-param>
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="group" select="/root/gui/strings/metadata"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:call-template>
    
      </xsl:for-each>

      <!-- more metadata elements -->

      <xsl:apply-templates mode="elementEP" select="gmd:dateStamp|geonet:child[string(@name)='dateStamp']">
        <xsl:with-param name="schema" select="$schema"/>
        <xsl:with-param name="edit"   select="$edit"/>
      </xsl:apply-templates>
    
      <xsl:if test="$core and $dataset">
        <xsl:apply-templates mode="elementEP" select="gmd:metadataStandardName|geonet:child[string(@name)='metadataStandardName']
          |gmd:metadataStandardVersion|geonet:child[string(@name)='metadataStandardVersion']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:if>

      </xsl:with-param>
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="group" select="/root/gui/strings/metadataTab"/>
      <xsl:with-param name="edit" select="$edit"/>
    </xsl:call-template>
    
  </xsl:template>


  <!-- ================================================================== -->
  <!-- complete mode we just display everything - tab = complete          -->
  <!-- ================================================================== -->

  <xsl:template name="iso19139.geoviquaComplete">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>

    <xsl:apply-templates mode="elementEP" select="gmd:identificationInfo|geonet:child[string(@name)='identificationInfo']
      |gmd:spatialRepresentationInfo|geonet:child[string(@name)='spatialRepresentationInfo']
      |gmd:referenceSystemInfo|geonet:child[string(@name)='referenceSystemInfo']
      |gmd:contentInfo|geonet:child[string(@name)='contentInfo']
      |gmd:distributionInfo|geonet:child[string(@name)='distributionInfo']
      |gvq:dataQualityInfo|geonet:child[string(@name)='dataQualityInfo']
      |gmd:portrayalCatalogueInfo|geonet:child[string(@name)='portrayalCatalogueInfo']
      |gmd:metadataConstraints|geonet:child[string(@name)='metadataConstraints']
      |gmd:applicationSchemaInfo|geonet:child[string(@name)='applicationSchemaInfo']
      |gmd:metadataMaintenance|geonet:child[string(@name)='metadataMaintenance']">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
    </xsl:apply-templates>

    <xsl:call-template name="complexElementGuiWrapper">
      <xsl:with-param name="title" select="'Metadata Info'"/>
      <xsl:with-param name="content">

        <xsl:apply-templates mode="elementEP" select="gmd:fileIdentifier|geonet:child[string(@name)='fileIdentifier']
          |gmd:language|geonet:child[string(@name)='language']
          |gmd:characterSet|geonet:child[string(@name)='characterSet']
          |gmd:parentIdentifier|geonet:child[string(@name)='parentIdentifier']
          |gmd:hierarchyLevel|geonet:child[string(@name)='hierarchyLevel']
          |gmd:hierarchyLevelName|geonet:child[string(@name)='hierarchyLevelName']
          |gmd:dateStamp|geonet:child[string(@name)='dateStamp']
          |gmd:metadataStandardName|geonet:child[string(@name)='metadataStandardName']
          |gmd:metadataStandardVersion|geonet:child[string(@name)='metadataStandardVersion']
          |gmd:contact|geonet:child[string(@name)='contact']
          |gmd:dataSetURI|geonet:child[string(@name)='dataSetURI']
          |gmd:locale|geonet:child[string(@name)='locale']
          |gmd:series|geonet:child[string(@name)='series']
          |gmd:describes|geonet:child[string(@name)='describes']
          |gmd:propertyType|geonet:child[string(@name)='propertyType']
          |gmd:featureType|geonet:child[string(@name)='featureType']
          |gmd:featureAttribute|geonet:child[string(@name)='featureAttribute']
          ">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>

      </xsl:with-param>
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="group" select="/root/gui/strings/metadataTab"/>
      <xsl:with-param name="edit" select="$edit"/>
    </xsl:call-template>

<!-- metadata Extension Information - dead last because its boring and
     can clutter up the rest of the metadata record! -->

    <xsl:apply-templates mode="elementEP" select="gmd:metadataExtensionInfo|geonet:child[string(@name)='metadataExtensionInfo']">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
    </xsl:apply-templates>

  </xsl:template>
  
  
  <!-- ============================================================================= -->

  <xsl:template name="iso19139.geoviquaMetadata">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:param name="flat"/>
    
    <xsl:variable name="ref" select="concat('#_',geonet:element/@ref)"/>
    <xsl:variable name="validationLink">
      <xsl:call-template name="validationLink">
        <xsl:with-param name="ref" select="$ref"/>
      </xsl:call-template>      
    </xsl:variable>
    
    <xsl:call-template name="complexElementGui">
      <xsl:with-param name="title" select="/root/gui/strings/metadata"/>
      <xsl:with-param name="validationLink" select="$validationLink"/>

      <xsl:with-param name="helpLink">
        <xsl:call-template name="getHelpLink">
            <xsl:with-param name="name" select="name(.)"/>
            <xsl:with-param name="schema" select="$schema"/>
        </xsl:call-template>
      </xsl:with-param>
      
      <xsl:with-param name="edit" select="true()"/>
      <xsl:with-param name="content">
    
      <!-- if the parent is root then display fields not in tabs -->
        <xsl:choose>
          <xsl:when test="name(..)='root'">
          <xsl:apply-templates mode="elementEP" select="gmd:fileIdentifier|geonet:child[string(@name)='fileIdentifier']
            |gmd:language|geonet:child[string(@name)='language']
            |gmd:characterSet|geonet:child[string(@name)='characterSet']
            |gmd:parentIdentifier|geonet:child[string(@name)='parentIdentifier']
            |gmd:hierarchyLevel|geonet:child[string(@name)='hierarchyLevel']
            |gmd:hierarchyLevelName|geonet:child[string(@name)='hierarchyLevelName']
            |gmd:dateStamp|geonet:child[string(@name)='dateStamp']
            |gmd:metadataStandardName|geonet:child[string(@name)='metadataStandardName']
            |gmd:metadataStandardVersion|geonet:child[string(@name)='metadataStandardVersion']
            |gmd:contact|geonet:child[string(@name)='contact']
            |gmd:dataSetURI|geonet:child[string(@name)='dataSetURI']
            |gmd:locale|geonet:child[string(@name)='locale']
            |gmd:series|geonet:child[string(@name)='series']
            |gmd:describes|geonet:child[string(@name)='describes']
            |gmd:propertyType|geonet:child[string(@name)='propertyType']
            |gmd:featureType|geonet:child[string(@name)='featureType']
            |gmd:featureAttribute|geonet:child[string(@name)='featureAttribute']
            ">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit"   select="$edit"/>
            <xsl:with-param name="flat"   select="$flat"/>
          </xsl:apply-templates>
        </xsl:when>
        <!-- otherwise, display everything because we have embedded MD_Metadata -->
        <xsl:otherwise>
          <xsl:apply-templates mode="elementEP" select="*">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit"   select="$edit"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>

      </xsl:with-param>
      <xsl:with-param name="schema" select="$schema"/>
    </xsl:call-template>
    
  </xsl:template>
  
  <!-- ============================================================================= -->
  <!--
  simple mode; ISO order is:
  - gmd:fileIdentifier
  - gmd:language
  - gmd:characterSet
  - gmd:parentIdentifier
  - gmd:hierarchyLevel
  - gmd:hierarchyLevelName
  - gmd:contact
  - gmd:dateStamp
  - gmd:metadataStandardName
  - gmd:metadataStandardVersion
  + gmd:dataSetURI
  + gmd:locale
  - gmd:spatialRepresentationInfo
  - gmd:referenceSystemInfo
  - gmd:metadataExtensionInfo
  - gmd:identificationInfo
  - gmd:contentInfo
  - gmd:distributionInfo
  - gmd:dataQualityInfo
  - gmd:portrayalCatalogueInfo
  - gmd:metadataConstraints
  - gmd:applicationSchemaInfo
  - gmd:metadataMaintenance
  + gmd:series
  + gmd:describes
  + gmd:propertyType
  + gmd:featureType
  + gmd:featureAttribute
  -->
  <!-- ============================================================================= -->

  <xsl:template name="iso19139.geoviquaSimple">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:param name="flat"/>


    <xsl:apply-templates mode="elementEP" select="gmd:identificationInfo|geonet:child[string(@name)='identificationInfo']">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
      <xsl:with-param name="flat"   select="$flat"/>
    </xsl:apply-templates>
    
    <xsl:apply-templates mode="elementEP" select="gmd:distributionInfo|geonet:child[string(@name)='distributionInfo']">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
      <xsl:with-param name="flat"   select="$flat"/>
    </xsl:apply-templates>
    
    <xsl:apply-templates mode="elementEP" select="gmd:spatialRepresentationInfo|geonet:child[string(@name)='spatialRepresentationInfo']">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
      <xsl:with-param name="flat"   select="$flat"/>
    </xsl:apply-templates>
    
    <xsl:apply-templates mode="elementEP" select="gmd:referenceSystemInfo|geonet:child[string(@name)='referenceSystemInfo']">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
      <xsl:with-param name="flat"   select="$flat"/>
    </xsl:apply-templates>
    
    <xsl:apply-templates mode="elementEP" select="gmd:applicationSchemaInfo|geonet:child[string(@name)='applicationSchemaInfo']">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
      <xsl:with-param name="flat"   select="$flat"/>
    </xsl:apply-templates>
    
    <xsl:apply-templates mode="elementEP" select="gmd:portrayalCatalogueInfo|geonet:child[string(@name)='portrayalCatalogueInfo']">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
      <xsl:with-param name="flat"   select="$flat"/>
    </xsl:apply-templates>
    
    <xsl:apply-templates mode="elementEP" select="gvq:dataQualityInfo|geonet:child[string(@name)='dataQualityInfo']">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
      <xsl:with-param name="flat"   select="$flat"/>
    </xsl:apply-templates>
    
    <xsl:apply-templates mode="elementEP" select="gmd:metadataConstraints|geonet:child[string(@name)='metadataConstraints']">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
      <xsl:with-param name="flat"   select="$flat"/>
    </xsl:apply-templates>
    
    
    <xsl:call-template name="complexElementGui">
      <xsl:with-param name="title" select="/root/gui/strings/metadata"/>
      <xsl:with-param name="content">
        <xsl:call-template name="iso19139Metadata">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
          <xsl:with-param name="flat"   select="$flat"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="schema" select="$schema"/>
    </xsl:call-template>
    
    <xsl:apply-templates mode="elementEP" select="gmd:contentInfo|geonet:child[string(@name)='contentInfo']
      |gmd:metadataExtensionInfo|geonet:child[string(@name)='metadataExtensionInfo']">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
      <xsl:with-param name="flat"   select="$flat"/>
    </xsl:apply-templates>
    
  </xsl:template>
  

  <!-- ============================================================================= -->
  <!-- FIXME HTML should move to layout -->
  <xsl:template mode="iso19139.geoviqua" match="gmd:transferOptions">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>

    
    <xsl:if test="$edit=false()">
      <xsl:if test="count(gmd:MD_DigitalTransferOptions/gmd:onLine/updated19115:CI_OnlineResource/gmd:protocol/gco:CharacterString[contains(string(.),'download')])>1 and
                  //geonet:info/download='true'">
        <xsl:call-template name="complexElementGui">
          <xsl:with-param name="title" select="/root/gui/strings/downloadSummary"/>
          <xsl:with-param name="content">
            <tr>
              <td  align="center">
                <button class="content" onclick="javascript:runFileDownloadSummary('{//geonet:info/uuid}','{/root/gui/strings/downloadSummary}')" type="button">
                  <xsl:value-of select="/root/gui/strings/showFileDownloadSummary"/>  
                </button>
              </td>
            </tr>
          </xsl:with-param>
          <xsl:with-param name="helpLink">
            <xsl:call-template name="getHelpLink">
              <xsl:with-param name="name"   select="name(.)"/>
              <xsl:with-param name="schema" select="$schema"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="schema" select="$schema"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
    <xsl:apply-templates mode="complexElement" select=".">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
    </xsl:apply-templates>
  </xsl:template>
  

  <!-- ============================================================================= -->
  <!-- online resources -->
  <!-- ============================================================================= -->

  <xsl:template mode="iso19139.geoviqua" match="updated19115:CI_OnlineResource" priority="2">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    
    <xsl:variable name="langId">
      <xsl:call-template name="getLangId">
        <xsl:with-param name="langGui" select="/root/gui/language" />
        <xsl:with-param name="md"
          select="ancestor-or-self::*[name(.)='gvq:GVQ_Metadata' or @gco:isoType='gmd:MD_Metadata']" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="linkage" select="gmd:linkage/gmd:URL" />
    <xsl:variable name="name">
      <xsl:for-each select="gmd:name">
        <xsl:call-template name="localised">
          <xsl:with-param name="langId" select="$langId"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="description">
      <xsl:for-each select="gmd:description">
        <xsl:call-template name="localised">
          <xsl:with-param name="langId" select="$langId"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="$edit=true()">
        <xsl:apply-templates mode="iso19139EditOnlineRes" select=".">
          <xsl:with-param name="schema" select="$schema"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="string($linkage)!=''">
        <xsl:apply-templates mode="simpleElement" select=".">
          <xsl:with-param name="schema"  select="$schema"/>
          <xsl:with-param name="text">
            <a href="{$linkage}" target="_new">
              <xsl:choose>
                <xsl:when test="string($name)!=''">
                  <xsl:value-of select="$name"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$linkage"/>
                </xsl:otherwise>
              </xsl:choose>
            </a>
            <xsl:if test="string($description)!=''">
              <br/><xsl:value-of select="$description"/>
            </xsl:if>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- ============================================================================= -->

  <xsl:template mode="iso19139EditOnlineRes" match="*">
    <xsl:param name="schema"/>
  
    <xsl:variable name="id" select="generate-id(.)"/>
    <tr><td colspan="2"><div id="{$id}"/></td></tr>
    <xsl:apply-templates mode="complexElement" select=".">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="true()"/>
      <xsl:with-param name="content">
        
        <xsl:apply-templates mode="elementEP" select="gmd:linkage|geonet:child[string(@name)='linkage']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="true()"/>
        </xsl:apply-templates>
      
        <!-- use elementEP for geonet:child only -->
        <xsl:apply-templates mode="elementEP" select="geonet:child[string(@name)='protocol']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="true()"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="iso19139" select="gmd:protocol">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="true()"/>
        </xsl:apply-templates>
        
        <xsl:apply-templates mode="elementEP" select="updated19115:protocolRequest">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="true()"/>
        </xsl:apply-templates>
        
        <xsl:apply-templates mode="elementEP" select="gmd:applicationProfile|geonet:child[string(@name)='applicationProfile']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="true()"/>
        </xsl:apply-templates>
        
        <xsl:choose>
          <xsl:when test="matches(gmd:protocol[1]/gco:CharacterString,'^WWW:DOWNLOAD-.*-http--download.*') 
            and string(gmd:name/gco:CharacterString|gmd:name/gmx:MimeFileType)!=''">
            <xsl:apply-templates mode="iso19139FileRemove" select="gmd:name/gco:CharacterString|gmd:name/gmx:MimeFileType">
              <xsl:with-param name="access" select="'private'"/>
              <xsl:with-param name="id" select="$id"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:when test="string(gmd:protocol[1]/gco:CharacterString)='DB:POSTGIS' 
            and string(gmd:name/gco:CharacterString|gmd:name/gmx:MimeFileType)!=''">
            <xsl:apply-templates mode="iso19139GeoPublisher" select="gmd:name/gco:CharacterString">
            <xsl:with-param name="access" select="'db'"/>
            <xsl:with-param name="id" select="$id"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:when test="(string(gmd:protocol[1]/gco:CharacterString)='FILE:GEO'
            or string(gmd:protocol[1]/gco:CharacterString)='FILE:RASTER') 
            and string(gmd:linkage/gmd:URL)!=''">
            <xsl:apply-templates mode="iso19139GeoPublisher" select="gmd:name/gco:CharacterString">
              <xsl:with-param name="access" select="'fileOrUrl'"/>
              <xsl:with-param name="id" select="$id"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <!-- use elementEP for geonet:child only -->
            <xsl:apply-templates mode="elementEP" select="geonet:child[string(@name)='name']">
              <xsl:with-param name="schema" select="$schema"/>
              <xsl:with-param name="edit"   select="true()"/>
            </xsl:apply-templates>

            <xsl:apply-templates mode="iso19139" select="gmd:name">
              <xsl:with-param name="schema" select="$schema"/>
              <xsl:with-param name="edit"   select="true()"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:apply-templates mode="elementEP" select="gmd:description|geonet:child[string(@name)='description']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="true()"/>
        </xsl:apply-templates>
        
        <xsl:apply-templates mode="elementEP" select="gmd:function|geonet:child[string(@name)='function']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="true()"/>
        </xsl:apply-templates>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>
  
  <!-- ============================================================================= -->
  <!-- online resources: WMS get map -->
  <!-- ============================================================================= -->

  <xsl:template mode="iso19139.geoviqua" match="updated19115:CI_OnlineResource[starts-with(gmd:protocol/gco:CharacterString,'OGC:WMS-') and contains(gmd:protocol/gco:CharacterString,'-get-map') and gmd:name]" priority="2">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:variable name="metadata_id" select="//geonet:info/id" />
    <xsl:variable name="linkage" select="gmd:linkage/gmd:URL" />
    <xsl:variable name="name" select="normalize-space(gmd:name/gco:CharacterString|gmd:name/gmx:MimeFileType)" />
    <xsl:variable name="description" select="normalize-space(gmd:description/gco:CharacterString)" />
    
    <xsl:choose>
      <xsl:when test="$edit=true()">
        <xsl:apply-templates mode="iso19139EditOnlineRes" select=".">
          <xsl:with-param name="schema" select="$schema"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="string(//geonet:info/dynamic)='true' and string($name)!='' and string($linkage)!=''">
      <!-- Create a link for a WMS service that will open in the map viewer -->
        <xsl:apply-templates mode="simpleElement" select=".">
          <xsl:with-param name="schema"  select="$schema"/>
          <xsl:with-param name="title"  select="/root/gui/strings/interactiveMap"/>
          <xsl:with-param name="text">
            <a href="javascript:addWMSLayer([['{$name}','{$linkage}','{$name}','{$metadata_id}']])" title="{/root/strings/interactiveMap}">
                <xsl:choose>
                <xsl:when test="string($description)!=''">
                  <xsl:value-of select="$description"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$name"/>
                </xsl:otherwise>
              </xsl:choose>
            </a><br/>(OGC-WMS Server: <xsl:value-of select="$linkage"/> )
          </xsl:with-param>
        </xsl:apply-templates>
        <!-- Create a link for a WMS service that will open in Google Earth through the reflector -->
        <xsl:apply-templates mode="simpleElement" select=".">
          <xsl:with-param name="schema"  select="$schema"/>
          <xsl:with-param name="title"  select="/root/gui/strings/viewInGE"/>
          <xsl:with-param name="text">
            <a href="{/root/gui/locService}/google.kml?uuid={//geonet:info/uuid}&amp;layers={$name}" title="{/root/strings/interactiveMap}">
              <xsl:choose>
                <xsl:when test="string($description)!=''">
                  <xsl:value-of select="$description"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$name"/>
                </xsl:otherwise>
              </xsl:choose>
              &#160;
              <img src="{/root/gui/url}/images/google_earth_link.gif" height="20px" width="20px" alt="{/root/gui/strings/viewInGE}" title="{/root/gui/strings/viewInGE}" style="border: 0px solid;"/>
            </a>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- ============================================================================= -->
  <!-- online resources: WMS get capabilities -->
  <!-- ============================================================================= -->

  <xsl:template mode="iso19139.geoviqua" match="updated19115:CI_OnlineResource[starts-with(gmd:protocol/gco:CharacterString,'OGC:WMS-') and contains(gmd:protocol/gco:CharacterString,'-get-capabilities') and gmd:name]" priority="2">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:variable name="linkage" select="gmd:linkage/gmd:URL" />
    <xsl:variable name="name" select="normalize-space(gmd:name/gco:CharacterString|gmd:name/gmx:MimeFileType)" />
    <xsl:variable name="description" select="normalize-space(gmd:description/gco:CharacterString)" />
    
    <xsl:choose>
      <xsl:when test="$edit=true()">
        <xsl:apply-templates mode="iso19139EditOnlineRes" select=".">
          <xsl:with-param name="schema" select="$schema"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="string(//geonet:info/dynamic)='true' and string($linkage)!=''">
        <xsl:apply-templates mode="simpleElement" select=".">
          <xsl:with-param name="schema"  select="$schema"/>
          <xsl:with-param name="title"  select="/root/gui/strings/interactiveMap"/>
          <xsl:with-param name="text">
            <a href="javascript:runIM_selectService('{$linkage}',2,{//geonet:info/id})" title="{/root/strings/interactiveMap}">              
              <xsl:choose>
                <xsl:when test="string($description)!=''">
                  <xsl:value-of select="$description"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$name"/>
                </xsl:otherwise>
              </xsl:choose>
            </a>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- ============================================================================= -->
  <!-- online resources: download -->
  <!-- ============================================================================= -->

  <xsl:template mode="iso19139.geoviqua" match="updated19115:CI_OnlineResource[matches(gmd:protocol/gco:CharacterString,'^WWW:DOWNLOAD-.*-http--download.*') and gmd:name]" priority="2">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:variable name="download_check"><xsl:text>&amp;fname=&amp;access</xsl:text></xsl:variable>
    <xsl:variable name="linkage" select="gmd:linkage/gmd:URL" />
    <xsl:variable name="name" select="normalize-space(gmd:name/gco:CharacterString|gmd:name/gmx:MimeFileType)" />
    <xsl:variable name="description" select="normalize-space(gmd:description/gco:CharacterString)" />
    
    <xsl:choose>
      <xsl:when test="$edit=true()">
        <xsl:apply-templates mode="iso19139EditOnlineRes" select=".">
          <xsl:with-param name="schema" select="$schema"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="string(//geonet:info/download)='true' and string($linkage)!='' and not(contains($linkage,$download_check))">
        <xsl:apply-templates mode="simpleElement" select=".">
          <xsl:with-param name="schema"  select="$schema"/>
          <xsl:with-param name="title"  select="/root/gui/strings/downloadData"/>
          <xsl:with-param name="text">
            <xsl:variable name="title">
              <xsl:choose>
                <xsl:when test="string($description)!=''">
                  <xsl:value-of select="$description"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$name"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <a href="{$linkage}" title="{$title}" onclick="runFileDownload(this.href, this.title); return false;"><xsl:value-of select="$title"/></a>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- ============================================================================= -->
  <!-- protocol -->
  <!-- ============================================================================= -->

  <xsl:template mode="iso19139" match="gmd:protocol" priority="2">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    
    <xsl:choose>
      <xsl:when test="$edit=true()">
        <xsl:call-template name="simpleElementGui">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
          <xsl:with-param name="title">
            <xsl:call-template name="getTitle">
              <xsl:with-param name="name"   select="name(.)"/>
              <xsl:with-param name="schema" select="$schema"/>
            </xsl:call-template>
          </xsl:with-param>

          <xsl:with-param name="helpLink">
              <xsl:call-template name="getHelpLink">
                  <xsl:with-param name="name" select="name(.)"/>
                  <xsl:with-param name="schema" select="$schema"/>
              </xsl:call-template>
          </xsl:with-param>
                
          <xsl:with-param name="text">
            <xsl:variable name="value" select="string(gco:CharacterString)"/>
            <xsl:variable name="ref" select="gco:CharacterString/geonet:element/@ref"/>
            <xsl:variable name="isXLinked" select="count(ancestor-or-self::node()[@xlink:href]) > 0"/>
            <xsl:variable name="fref" select="../gmd:name/gco:CharacterString/geonet:element/@ref|../gmd:name/gmx:MimeFileType/geonet:element/@ref"/>
            <input type="hidden" id="_{$ref}" name="_{$ref}" value="{$value}"/>
            <select id="s_{$ref}" name="s_{$ref}" size="1" onchange="checkForFileUpload('{$fref}', '{$ref}');" class="md">
              <xsl:if test="$isXLinked"><xsl:attribute name="disabled">disabled</xsl:attribute></xsl:if>
              <xsl:if test="$value=''">
                <option value=""/>
              </xsl:if>
              <xsl:for-each select="/root/gui/strings/protocolChoice[@value]">
                <option>
                  <xsl:if test="string(@value)=$value">
                    <xsl:attribute name="selected"/>
                  </xsl:if>
                  <xsl:attribute name="value"><xsl:value-of select="string(@value)"/></xsl:attribute>
                  <xsl:value-of select="string(.)"/>
                </option>
              </xsl:for-each>
            </select>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="element" select=".">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="false()"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ===================================================================== -->
  <!-- name for onlineresource only -->
  <!-- ===================================================================== -->

  <xsl:template mode="iso19139.geoviqua" match="gmd:name[name(..)='updated19115:CI_OnlineResource']" priority="2">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>

    <xsl:choose>
      <xsl:when test="$edit=true()">
        <xsl:variable name="protocol" select="../gmd:protocol/gco:CharacterString"/>
        <xsl:variable name="protocolRequest" select="../updated19115:protocolRequest/gco:CharacterString"/>
        <xsl:variable name="pref" select="../gmd:protocol/gco:CharacterString/geonet:element/@ref"/>
        <xsl:variable name="ref" select="gco:CharacterString/geonet:element/@ref|gmx:MimeFileType/geonet:element/@ref"/>
        <xsl:variable name="value" select="gco:CharacterString|gmx:MimeFileType"/>
        <xsl:variable name="button" select="matches($protocol,'^WWW:DOWNLOAD-.*-http--download.*') and normalize-space($value)=''"/>

        <xsl:call-template name="simpleElementGui">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
          <xsl:with-param name="title" select="/root/gui/strings/file"/>
          <xsl:with-param name="text">
            <button class="content" onclick="Ext.getCmp('editorPanel').showFileUploadPanel({//geonet:info/id}, '{$ref}');" type="button">
              <xsl:value-of select="/root/gui/strings/insertFileMode"/>
            </button>
          </xsl:with-param>
          <xsl:with-param name="id" select="concat('db_',$ref)"/>
          <xsl:with-param name="visible" select="$button"/>
        </xsl:call-template>

        <xsl:call-template name="simpleElementGui">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
          <xsl:with-param name="title">
            <xsl:call-template name="getTitle">
              <xsl:with-param name="name"   select="name(.)"/>
              <xsl:with-param name="schema" select="$schema"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="text">
            <input id="_{$ref}" class="md" type="text" name="_{$ref}" value="{$value}" size="40" />
            </xsl:with-param>
          <xsl:with-param name="id" select="concat('di_',$ref)"/>
          <xsl:with-param name="visible" select="not($button)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="element" select=".">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="false()"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ============================================================================= -->

  <xsl:template name="iso19139.geoviquaGeoPublisherButton">
    <xsl:param name="access" select="'public'"/>
    
    <xsl:if test="/root/gui/config/editor-geopublisher">
      <xsl:variable name="bbox">
        <xsl:call-template name="iso19139-global-bbox"/>
      </xsl:variable>
      <xsl:variable name="layer">
        <xsl:choose>
          <xsl:when test="../../gmd:protocol/gco:CharacterString='DB:POSTGIS'">
            <xsl:value-of select="concat(../../gmd:linkage/gmd:URL, '#', .)"/>
          </xsl:when>
          <xsl:when test="../../gmd:protocol/gco:CharacterString='FILE:GEO'
            or ../../gmd:protocol/gco:CharacterString='FILE:RASTER'">
            <xsl:value-of select="../../gmd:linkage/gmd:URL"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:variable name="title">
        <xsl:apply-templates mode="escapeXMLEntities" select="/root/gvq:GVQ_Metadata/gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString">
          <xsl:with-param name="includingCRLF" select="true()"/>
        </xsl:apply-templates>
      </xsl:variable>
    
      <xsl:variable name="abstract">
        <xsl:apply-templates mode="escapeXMLEntities" select="/root/gmd:MD_Metadata/gmd:identificationInfo/*/gmd:abstract/gco:CharacterString"/>
      </xsl:variable>
    
      <button type="button" class="content repository" 
        onclick="javascript:Ext.getCmp('editorPanel').showGeoPublisherPanel('{/root/*/geonet:info/id}',
        '{/root/*/geonet:info/uuid}', 
        '{$title}',
        '{$abstract}',
        '{$layer}', 
        '{$access}', 'gmd:onLine', '{ancestor::gmd:MD_DigitalTransferOptions/geonet:element/@ref}', [{$bbox}]);" 
        alt="{/root/gui/strings/publishHelp}" 
        title="{/root/gui/strings/geopublisherHelp}"><xsl:value-of select="/root/gui/strings/geopublisher"/></button>
    </xsl:if>
  </xsl:template>
  
  
  <!-- ===================================================================== -->
  <!-- === iso19139 brief formatting === -->
  <!-- ===================================================================== -->
  <xsl:template mode="superBrief" match="gvq:GVQ_Metadata|*[@gco:isoType='gmd:MD_Metadata']" priority="2">
    <xsl:variable name="langId">
      <xsl:call-template name="getLangId">
        <xsl:with-param name="langGui" select="/root/gui/language"/>
        <xsl:with-param name="md" select="."/>
      </xsl:call-template>
    </xsl:variable>
    
    <id><xsl:value-of select="geonet:info/id"/></id>
    <uuid><xsl:value-of select="geonet:info/uuid"/></uuid>
    <title>
      <xsl:apply-templates mode="localised" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title">
        <xsl:with-param name="langId" select="$langId"/>
      </xsl:apply-templates>
    </title>
    <abstract>
      <xsl:apply-templates mode="localised" select="gmd:identificationInfo/*/gmd:abstract">
        <xsl:with-param name="langId" select="$langId"/>
      </xsl:apply-templates>
    </abstract>
  </xsl:template>    
  
  <xsl:template match="iso19139Brief">
    <metadata>
     <xsl:call-template name="iso19139-brief"/>
    </metadata>
  </xsl:template>


  
  <!-- In order to add profil specific tabs 
    add a template in this mode.
    
    To add some more tabs.
    <xsl:template mode="extraTab" match="iso19139.fraCompleteTab">
    <xsl:param name="tabLink"/>
    <xsl:param name="schema"/>
    <xsl:if test="$schema='iso19139.fra'">
    ...
    </xsl:if>
    </xsl:template>
  -->
  <xsl:template mode="extraTab" match="/"/>
  
  
  <!-- ============================================================================= -->
  <!-- iso19139 complete tab template  -->
  <!-- ============================================================================= -->

  <xsl:template name="iso19139.geoviquaCompleteTab">
    <xsl:param name="tabLink"/>
    <xsl:param name="schema"/>
    
    <!-- INSPIRE tab -->
    <xsl:if test="/root/gui/env/inspire/enable = 'true' and /root/gui/env/metadata/enableInspireView = 'true'">
      <xsl:call-template name="mainTab">
        <xsl:with-param name="title" select="/root/gui/strings/inspireTab"/>
        <xsl:with-param name="default">inspire</xsl:with-param>
        <xsl:with-param name="menu">
          <item label="inspireTab">inspire</item>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    
    <!-- To define profil specific tabs -->
    <xsl:apply-templates mode="extraTab" select="/">
      <xsl:with-param name="tabLink" select="$tabLink"/>
      <xsl:with-param name="schema" select="$schema"/>
    </xsl:apply-templates>
    
    <xsl:if test="/root/gui/env/metadata/enableIsoView = 'true'">
      <xsl:call-template name="mainTab">
        <xsl:with-param name="title" select="/root/gui/strings/byGroup"/>
        <xsl:with-param name="default">ISOCore</xsl:with-param>
        <xsl:with-param name="menu">
          <item label="isoMinimum">ISOMinimum</item>
          <item label="isoCore">ISOCore</item>
          <item label="isoAll">ISOAll</item>
        </xsl:with-param>
      </xsl:call-template>
     </xsl:if>
    
    
    
    <xsl:if test="/root/gui/config/metadata-tab/advanced">
      <xsl:call-template name="mainTab">
        <xsl:with-param name="title" select="/root/gui/strings/byPackage"/>
        <xsl:with-param name="default">identification</xsl:with-param>
        <xsl:with-param name="menu">
          <item label="metadata">metadata</item>
          <item label="identificationTab">identification</item>
          <item label="maintenanceTab">maintenance</item>
          <item label="constraintsTab">constraints</item>
          <item label="spatialTab">spatial</item>
          <item label="refSysTab">refSys</item>
          <item label="distributionTab">distribution</item>
          <item label="dataQualityTab">dataQuality</item>
          <item label="appSchInfoTab">appSchInfo</item>
          <item label="porCatInfoTab">porCatInfo</item>
          <item label="contentInfoTab">contentInfo</item>
          <item label="extensionInfoTab">extensionInfo</item>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>    
  </xsl:template>
  

  <!-- Display extra thumbnails (not managed by GeoNetwork).
    Thumbnails managed by GeoNetwork are displayed on header.
    If fileName does not start with http://, just display as
    simple elements.
  -->
  <xsl:template mode="iso19139" match="gmd:graphicOverview" priority="2">
    <xsl:param name="schema" />
    <xsl:param name="edit" />

    <!-- do not show empty elements in view mode -->
    <xsl:choose>
      <xsl:when test="$edit=true()">
        <xsl:apply-templates mode="element" select=".">
          <xsl:with-param name="schema" select="$schema" />
          <xsl:with-param name="edit" select="true()" />
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="simpleElement"
          select=".">
          <xsl:with-param name="schema" select="$schema" />
          <xsl:with-param name="text">&#160;
              
              
            <xsl:variable name="langId">
              <xsl:call-template name="getLangId">
                <xsl:with-param name="langGui" select="/root/gui/language" />
                <xsl:with-param name="md"
                  select="ancestor-or-self::*[name(.)='gvq:GVQ_Metadata' or @gco:isoType='gmd:MD_Metadata']" />
              </xsl:call-template>
            </xsl:variable>
            
            <xsl:variable name="imageTitle">
                <xsl:choose>
                    <xsl:when test="gmd:MD_BrowseGraphic/gmd:fileDescription/gco:CharacterString
                      and not(gmd:MD_BrowseGraphic/gmd:fileDescription/@gco:nilReason)">
                      <xsl:for-each select="gmd:MD_BrowseGraphic/gmd:fileDescription">
                        <xsl:call-template name="localised">
                          <xsl:with-param name="langId" select="$langId"/>
                        </xsl:call-template>
                      </xsl:for-each>
                    </xsl:when>
                  <xsl:otherwise>
                    <!-- Filename is not multilingual -->
                    <xsl:value-of select="gmd:MD_BrowseGraphic/gmd:fileName/gco:CharacterString"/>
                  </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
              
            <xsl:variable name="fileName" select="gmd:MD_BrowseGraphic/gmd:fileName/gco:CharacterString"/>
            <xsl:variable name="url" select="if (contains($fileName, '://')) 
                                                then $fileName 
                                                else geonet:get-thumbnail-url($fileName, //geonet:info, /root/gui/locService)"/>

            <div class="md-view">
              <a rel="lightbox-viewset" href="{$url}">
                <img class="logo" src="{$url}">
                  <xsl:attribute name="alt"><xsl:value-of select="$imageTitle"/></xsl:attribute>
                    <xsl:attribute name="title"><xsl:value-of select="$imageTitle"/></xsl:attribute>
                </img>
              </a>  
              <br/>
              <span class="thumbnail"><a href="{$url}" target="thumbnail-view"><xsl:value-of select="$imageTitle"/></a></span>
            </div>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>
  
  <!-- ===================================================================== -->
  <!-- Templates to retrieve thumbnails -->
  <xsl:template mode="get-thumbnail" match="gvq:GVQ_Metadata|*[@gco:isoType='gmd:MD_Metadata']">
    <xsl:apply-templates mode="get-thumbnail" select="gmd:identificationInfo/*/gmd:graphicOverview"/>
  </xsl:template>
  
  <xsl:template mode="get-thumbnail" match="gmd:graphicOverview">
    <xsl:variable name="fileName" select="gmd:MD_BrowseGraphic/gmd:fileName/gco:CharacterString"/>
    <xsl:variable name="desc" select="gmd:MD_BrowseGraphic/gmd:fileDescription/gco:CharacterString"/>
    <xsl:variable name="info" select="ancestor::*[name(.) = 'gvq:GVQ_Metadata' or @gco:isoType='gmd:MD_Metadata']/geonet:info"></xsl:variable>
    
    <thumbnail>
      <href><xsl:value-of select="geonet:get-thumbnail-url($fileName, $info, /root/gui/locService)"/></href>
      <desc><xsl:value-of select="$desc"/></desc>
      <mimetype><xsl:value-of select="gmd:MD_BrowseGraphic/gmd:fileType/gco:CharacterString"/></mimetype>
      <type><xsl:value-of select="if (geonet:contains-any-of($desc, ('thumbnail', 'large_thumbnail'))) then 'local' else ''"/></type>
    </thumbnail>
  </xsl:template>


  <!-- match everything else and do nothing - leave that to iso19139 mode -->
  <xsl:template mode="iso19139.geoviqua" match="*|@*"/> 

</xsl:stylesheet>
