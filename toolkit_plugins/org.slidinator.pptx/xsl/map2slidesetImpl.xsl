<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:df="http://dita2indesign.org/dita/functions"  
  xmlns:index-terms="http://dita4publishers.org/index-terms"
  xmlns:enum="http://dita4publishers.org/enumerables"
  xmlns:glossdata="http://dita4publishers.org/glossdata"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:html2="http://dita4publishers.org/html2"
  xmlns:sld="urn:ns:dita4publishers.org:doctypes:simpleslideset"
  xmlns:mapdriven="http://dita4publishers.org/mapdriven"
  exclude-result-prefixes="xs xd df relpath html2 enum index-terms mapdriven"
  version="2.0">
  
  <!-- =============================================================
    
       DITA Map to SlideSet Transformation
       
       Copyright (c) 2013, 2014 W. Eliot Kimber
       
       Licensed under Common Public License v1.0 or the Apache Software Foundation License v2.0.
       The intent of this license is for this material to be licensed in a way that is
       consistent with and compatible with the license of the DITA Open Toolkit.
       
       ============================================================== -->

  <xsl:import href="plugin:org.dita.base:xsl/common/dita-utilities.xsl"/>
  <xsl:import href="plugin:org.dita.base:xsl/common/output-message.xsl"/>
  
  <xsl:import href="plugin:org.dita-community.common.xslt:xsl/dita-support-lib.xsl"/>
  <xsl:import href="plugin:org.dita-community.common.xslt:/xsl/relpath_util.xsl"/>
  <xsl:import href="plugin:org.dita4publishers.common.html:xsl/html-generation-utils.xsl"/>
  
  <xsl:import href="plugin:org.dita4publishers.common.xslt:xsl/graphicMap2AntCopyScript.xsl"/>
  <xsl:import href="plugin:org.dita4publishers.common.xslt:xsl/map2graphicMapImpl.xsl"/>
  <xsl:import href="plugin:org.dita4publishers.common.mapdriven:xsl/dataCollection.xsl"/>  

  <xsl:include href="map2slidesetMap.xsl"/>
  <xsl:include href="map2slidesetTopic.xsl"/>
  
  <!-- The outdir param is used primarily for the generation of graphic-copying
       Ant script generated in map2graphicMap.xsl
    -->
  <xsl:param name="outdir" select="'./slideset'"/>
  <!-- NOTE: Case of OUTEXT parameter matches case used in base HTML
    transformation type.
  -->
  <xsl:param name="OUTEXT" select="'.xml'"/>
  <xsl:param name="tempdir" select="'./temp'"/>
  <xsl:param name="CSSPATH" select="''"/>
  <xsl:param name="DITAEXT" select="'.dita'"/>
  <xsl:param name="FILTERFILE" select="''"/> <!-- From dita2htmlImpl.xsl -->
  
  <xsl:param name="topicsOutputDir" select="'topics'" as="xs:string"/> <!-- Required by HTML generation utils -->
  <xsl:param name="rawPlatformString" select="'unknown'" as="xs:string"/><!-- As provided by Ant -->
  <xsl:param name="imagesOutputDir" select="'images'" as="xs:string"/>

  <xsl:param name="generateGlossary" as="xs:string" select="'no'"/>
  <xsl:variable name="generateGlossaryBoolean" 
    select="matches($generateGlossary, 'yes|true|on|1', 'i')"
    as="xs:boolean"
  />
  
  <xsl:param name="generateIndex" as="xs:string" select="'no'"/>
  <xsl:variable name="generateIndexBoolean" 
    select="matches($generateIndex, 'yes|true|on|1', 'i')"
    as="xs:boolean"
  />
  
  <!-- used by the OT-provided output-message named template. -->
  <xsl:variable name="msgprefix">DOTX</xsl:variable>
  
  <!-- NOTE: This parameter is required by the map2graphicMap.xsl, which we include,
             but is not used directly by the main Simple Slide Set generation
             logic.
                           
    -->
  <xsl:param name="imagesOutputPath" as="xs:string" 
    select="relpath:newFile($outdir, 'images')"
  />
  
  <xsl:output method="xml" name="indented-xml"
    indent="yes"
  />
  
  <xsl:preserve-space elements="lines codeblock"/>
  
  <!-- These variables are copied from dita2htmlImpl.xsl: -->
  <xsl:variable name="FILTERFILEURL">
    <xsl:choose>
      <xsl:when test="not($FILTERFILE)"/> <!-- If no filterfile leave empty -->
      <xsl:when test="starts-with($FILTERFILE,'file:')">
        <xsl:value-of select="$FILTERFILE"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="starts-with($FILTERFILE,'/')">
            <xsl:text>file://</xsl:text><xsl:value-of select="$FILTERFILE"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>file:/</xsl:text><xsl:value-of select="$FILTERFILE"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="FILTERDOC" select="document($FILTERFILEURL,/)"/>
  
  <xsl:variable name="platform" as="xs:string"
    select="
    if (starts-with($rawPlatformString, 'Win') or 
    starts-with($rawPlatformString, 'Win'))
    then 'windows'
    else 'nx'
    "
  />
  
  
  <xsl:template match="/">
    <xsl:message> + [DEBUG] Root template: Starting...</xsl:message>
    <xsl:apply-templates select="." mode="report-parameters"/>
    
    <xsl:message>
 ==============================
 + [DEBUG] Input map=
<xsl:sequence select="."/>
    
    </xsl:message>
    
    <xsl:variable name="rootMapDocUrl" select="string(base-uri(.))" as="xs:string"/>
    <xsl:message> + [DEBUG] rootmapDocUrl="<xsl:value-of select="$rootMapDocUrl"/>"</xsl:message>
    <xsl:message> + [DEBUG] Root template: Applying templates...</xsl:message>
    <xsl:apply-templates>
      <xsl:with-param name="rootMapDocUrl" select="$rootMapDocUrl" as="xs:string" tunnel="yes"/>
    </xsl:apply-templates>
    <xsl:message> + [DEBUG] Root template: Done applying templates.</xsl:message>
 </xsl:template>   
    
 <xsl:template match="/*[df:class(., 'map/map')]">   
    <xsl:message> + [DEBUG] default mode: map/map</xsl:message>

   <xsl:message> + [DEBUG] collecting data:</xsl:message>
   <xsl:variable name="collected-data" as="element()">
<!--     <xsl:call-template name="mapdriven:collect-data"/>      -->
     <mapdriven:collected-data/>
   </xsl:variable>
   
   <xsl:if test="true() or $debugBoolean">
     <xsl:variable name="collectedDataFileUrl" as="xs:string" 
       select="relpath:newFile(relpath:getParent(base-uri(.)), 'collected-data.xml')"
     />
     <xsl:message> + [DEBUG] Writing file <xsl:sequence select="$collectedDataFileUrl"/>...</xsl:message>
     <xsl:result-document href="{$collectedDataFileUrl}"
       format="indented-xml"
       >
       <xsl:sequence select="$collected-data"/>
     </xsl:result-document>
   </xsl:if>
   
   <xsl:message> + [DEBUG] default: map/map: applying templates in mode generate-slides...</xsl:message>
   <xsl:message> + [DEBUG]    $collected-data=<xsl:sequence select="$collected-data"/></xsl:message>
   <xsl:apply-templates select="." mode="generate-slides">
     <xsl:with-param name="collected-data" as="element()" tunnel="yes"
       select="$collected-data"
     />
   </xsl:apply-templates>
   <xsl:message> + [DEBUG] default: map/map: applying templates in mode generate-slides...</xsl:message>
   
  </xsl:template>
   
  <xsl:template name="report-parameters" match="*" mode="report-parameters">
    <xsl:message> 
      ==========================================
      Plugin version: ^version^ - build ^buildnumber^ at ^timestamp^
      
      Parameters:
      
      + debug           = "<xsl:sequence select="$debug"/>"
      + outdir           = "<xsl:sequence select="$outdir"/>"
      + OUTEXT           = "<xsl:sequence select="$OUTEXT"/>"
      + tempdir          = "<xsl:sequence select="$tempdir"/>"
      + CSSPATH          = "<xsl:sequence select="$CSSPATH"/>"
      + DITAEXT          = "<xsl:sequence select="$DITAEXT"/>"
      + FILTERFILE       = "<xsl:sequence select="$FILTERFILE"/>"
      + topicsOutputDir  = "<xsl:sequence select="$topicsOutputDir"/>"
      + rawPlatformString= "<xsl:sequence select="$rawPlatformString"/>"
      + imagesOutputDir  = "<xsl:sequence select="$imagesOutputDir"/>"
      + generateGlossary = "<xsl:sequence select="$generateGlossary"/>"
      + generateIndex    = "<xsl:sequence select="$generateIndex"/>"
       
      Global Variables:
      
      + debugBoolean     = "<xsl:sequence select="$debugBoolean"/>"
      
      ==========================================
    </xsl:message>
  </xsl:template>
  
  
</xsl:stylesheet>
