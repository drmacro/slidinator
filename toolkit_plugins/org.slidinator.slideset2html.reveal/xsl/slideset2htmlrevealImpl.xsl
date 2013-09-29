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
  xmlns:sld="urn:ns:slidinator.org:doctypes:simpleslideset"
  xmlns:mapdriven="http://dita4publishers.org/mapdriven"
  exclude-result-prefixes="xs xd df relpath html2 enum index-terms mapdriven sld glossdata"
  version="2.0">
  
  <!-- =============================================================
    
       SlideSet to HTML Reveal Transformation
       
       Copyright (c) 2013 DITA For Publishers
       
       Licensed under Common Public License v1.0 or the Apache Software Foundation License v2.0.
       The intent of this license is for this material to be licensed in a way that is
       consistent with and compatible with the license of the DITA Open Toolkit.
       
       ============================================================== -->

  <xsl:import href="../../../xsl/common/dita-utilities.xsl"/>
  <xsl:import href="../../../xsl/common/output-message.xsl"/>
  
  <xsl:import href="../../net.sourceforge.dita4publishers.common.xslt/xsl/lib/dita-support-lib.xsl"/>
  <xsl:import href="../../net.sourceforge.dita4publishers.common.xslt/xsl/lib/relpath_util.xsl"/>
  <xsl:import href="../../net.sourceforge.dita4publishers.common.xslt/xsl/lib/html-generation-utils.xsl"/>
  
  <xsl:import href="../../net.sourceforge.dita4publishers.common.xslt/xsl/graphicMap2AntCopyScript.xsl"/>
  <xsl:import href="../../net.sourceforge.dita4publishers.common.xslt/xsl/map2graphicMapImpl.xsl"/>
  <!--<xsl:import href="../../net.sourceforge.dita4publishers.common.mapdriven/xsl/dataCollection.xsl"/>  
-->
  <xsl:import href="../../org.slidinator.slideset2html.common/xsl/commonHtml.xsl"/>

  <xsl:param name="outdir" select="'./reveal'"/>
  <!-- NOTE: Case of OUTEXT parameter matches case used in base HTML
    transformation type.
  -->
  <xsl:param name="OUTEXT" select="'.html'"/>
  <xsl:param name="tempdir" select="'./temp'"/>
  <xsl:param name="CSSPATH" select="''"/>
  
  <xsl:param name="FILTERFILE" select="''"/> <!-- From dita2htmlImpl.xsl -->
  
  <xsl:param name="topicsOutputDir" select="'topics'" as="xs:string"/> <!-- Required by HTML generation utils -->
  <xsl:param name="rawPlatformString" select="'unknown'" as="xs:string"/><!-- As provided by Ant -->
  <xsl:param name="imagesOutputDir" select="'images'" as="xs:string"/>

<!-- Any of this needed? -->
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
  
  <xsl:output method="xml" name="indented-xml"
    indent="yes"
  />
  
  <xsl:preserve-space elements="lines codeblock"/>
  
  <xsl:variable name="imagesOutputPath">
    <xsl:choose>
      <xsl:when test="$imagesOutputDir != ''">
        <xsl:sequence select="concat($outdir, 
          if (ends-with($outdir, '/')) then '' else '/', 
          $imagesOutputDir)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$outdir"/>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:variable>  
  
  

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
  
  <xsl:output name="slide-html"
    method="xhtml"
    encoding="UTF-8"
    indent="yes" 
    
  /> 
  <xsl:template match="/">
    <xsl:message> + [DEBUG] Root template: Starting...</xsl:message>
    <xsl:apply-templates select="." mode="report-parameters"/>
    
    <xsl:variable name="rootMapDocUrl" select="string(base-uri(.))" as="xs:string"/>
    <xsl:message> + [DEBUG] rootmapDocUrl="<xsl:value-of select="$rootMapDocUrl"/>"</xsl:message>
    <xsl:message> + [DEBUG] Root template: Applying templates...</xsl:message>
    <xsl:apply-templates>
      <xsl:with-param name="rootMapDocUrl" select="$rootMapDocUrl" as="xs:string" tunnel="yes"/>
    </xsl:apply-templates>
    <xsl:message> + [DEBUG] Root template: Done applying templates.</xsl:message>
 </xsl:template>   
    
  <xsl:template match="sld:simpleslideset">   
    <xsl:message> + [DEBUG] default mode: map/map</xsl:message>

   <xsl:message> + [DEBUG] collecting data:</xsl:message>
   <!--
     Is there a slideset analog to what collected-data gets for a DITA Map that we should accommodate?
     <xsl:variable name="collected-data" as="element()">
<!-\-     <xsl:call-template name="mapdriven:collect-data"/>      -\->
     <mapdriven:collected-data/>
   </xsl:variable>
   
   <xsl:if test="true() or $debugBoolean">
     <xsl:message> + [DEBUG] Writing file <xsl:sequence select="relpath:newFile($outdir, 'collected-data.xml')"/>...</xsl:message>
     <xsl:result-document href="{relpath:newFile($outdir, 'collected-data.xml')}"
       format="indented-xml"
       >
       <xsl:sequence select="$collected-data"/>
     </xsl:result-document>
   </xsl:if>-->
   
    <xsl:message> + [DEBUG] default: sld:simpleslideset: applying templates ...</xsl:message>

<!--

    -->
    <xsl:variable name="slideHTML">
      <!-- Capture everything in a variable so that it is easy for users to manipulate the HTML before it gets written -->
      <html lang="en" xml:lang="en"> <!--FIXME: lang needs to be specified by lang of calling XML file -->
        <head> 
          <title><xsl:apply-templates select="sld:prolog/sld:title" mode="generate-html-title"/></title> 
          <meta name="copyright" 
            content="Copyright &#169; 2005 your copyright notice" /> <!-- FIXME -->
          <!-- FIXME: need a way to allow for this feature of Slidy (which keeps track of how much time is left in a presentation:
            <meta name="duration" content="5" />
            So what do we need added to simpleslideset or does it already allow for it? 
            -->
          <link rel="stylesheet" type="text/css" media="screen, projection, print" href="resources/css/reveal.css"></link>
          
          <xsl:call-template name="defaultSlidinator2HTMLCSS" />
          
          <!-- FIXME: The slidy js and css files should be in a local folder, be copied, etc. -->
          <style type="text/css">
            <!-- Need to allow for custom CSS rules ... will be generated from the sld:styles element --> 
            <xsl:apply-templates select="sld:styles" mode="generate-style-definitions"/>
          </style> 
        </head>
        <body>
          <div class="reveal">
            <div class="slides">
              
          <xsl:apply-templates select="sld:slides" mode="generate-html-slides"/>
            </div>
          </div>
          
          <script src="resources/lib/js/head.min.js"></script>
          <script src="resources/js/reveal.min.js"></script>
          
          <script>
            
            Reveal.initialize();
            
          </script>
          
        </body>
      </html>
    </xsl:variable>
    
    
    <xsl:variable name="slideHTMLFixedUp">
      <xsl:apply-templates select="$slideHTML" mode="slide-fixup"/> <!-- slide-fixup is for built-in fixups; users who want to do their own fixup should use mode slide-custom-fixup -->
    </xsl:variable>
    
    <xsl:result-document href="{relpath:newFile($outdir, 'reveal.html')}" format="slide-html">
      <xsl:apply-templates select="$slideHTMLFixedUp" mode="slide-custom-fixup"/> <!-- provides users the opportunity to do their own processing; if not taken advantage of, then everything is just copied -->
    </xsl:result-document>
    
    
    
   <!--<xsl:apply-templates select="." mode="generate-slides">
     <xsl:with-param name="collected-data" as="element()" tunnel="yes"
       select="$collected-data"
     />
   </xsl:apply-templates>-->
    <xsl:message> + [DEBUG] default: sld:simpleslideset: applying templates ...</xsl:message>
   
  </xsl:template>
   
   
  <xsl:template match="sld:slide[1]" mode="generate-html-slides">
    <!-- Process first slide, assuming it is the cover slide -->
    <section class="slide cover"> 
      <!-- FIXME: Implement a common attributes analog similar to one used in pdf2? -->
      <xsl:apply-templates select="sld:title" mode="generate-html-slide-title"/>
      <xsl:apply-templates select="sld:slidebody" mode="generate-html-slide-body"/>
      <xsl:apply-templates select="sld:slidenotes" mode="generate-html-slide-notes"/>
      
    </section> 
  </xsl:template>
  
  <xsl:template match="sld:slide[position() ne 1]" mode="generate-html-slides">
    <!-- Process slides -->
    <!-- FIXME: Implement a common attributes analog similar to one used in pdf2? -->
    <section class="slide"> 
      <xsl:apply-templates select="sld:title" mode="generate-html-slide-title"/>
      <xsl:apply-templates select="sld:slidebody" mode="generate-html-slide-body"/>
      <xsl:apply-templates select="sld:slidenotes" mode="generate-html-slide-notes"/>
      
    </section> 
  </xsl:template>
  
   
   <xsl:template match="text()"/> <!-- suppress text nodes in default mode -->
   
  <!--FIXME: Slidy has class="incremenetal" feature for slidebody descendant elements... how can we support from slideset? -->
   
  <!--FIXME: Slidy has  class='outline' for ul/ol ... -->
  
   
   
  <xsl:template name="report-parameters" match="*" mode="report-parameters">
    <xsl:message> 
      ==========================================
      Plugin version: ^version^ - build ^buildnumber^ at ^timestamp^
      
      Parameters:
      
      + debug           = "<xsl:sequence select="$debug"/>"
      
      Global Variables:
      
      + debugBoolean     = "<xsl:sequence select="$debugBoolean"/>"
      
      ==========================================
    </xsl:message>
  </xsl:template>
  
  
</xsl:stylesheet>
