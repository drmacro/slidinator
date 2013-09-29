<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:sld="urn:ns:slidinator.org:doctypes:simpleslideset"
  
  xmlns:dita2html="http://dita-ot.sourceforge.net/ns/200801/dita2html"  
  xmlns:df="http://dita2indesign.org/dita/functions"
  xmlns:enum="http://dita4publishers.org/enumerables"
  exclude-result-prefixes="xs xd relpath dita2html df enum sld"
  xmlns="http://www.w3.org/1999/xhtml"  
  version="2.0">
  
  <!-- Common HTML processing for Slideset to HTML transforms. Base templates are here. Individual HTML outputs should only override transforms here as needed.
  -->
  

  <!-- This is an override of the same template from dita2htmlmpl.xsl. It 
       uses xtrf rather than $OUTPUTDIR to provide the location of the
       graphic as authored, not as output.
    -->
  
  
  <xsl:template match="sld:title" mode="generate-html-title">
    <!-- sld:title allows for block and inline elements but HTML title element is text only. Since the only element that should be put through this mode is sld:title and we do not suppress text nodes in this mode, the end-result should be a concatenation of all of the descendant text nodes of the slideset title -->
    <!-- FIXME: Need to be more intelligent with this? -->
    <xsl:apply-templates mode="#current" />
  </xsl:template>
  
  <xsl:template match="sld:styles" mode="generate-style-definitions">
    <!-- FIXME: In slideset-01.xml, slideStyle, charStyle, and objectStyle do not have properties that are CSS compliant. How to handle that? -->
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="text()" mode="generate-style-definitions" />

  <xsl:template match="sld:paraStyle" mode="generate-style-definitions">
    <!-- assume that every property is an acceptable css property -->
    <xsl:text>
      </xsl:text><xsl:value-of select="concat('.',@name,' {')"/>
    <xsl:for-each select="sld:property">
      <xsl:text>
      </xsl:text><xsl:value-of select="concat(@name,': ',@value,';')"/>
    </xsl:for-each>
    <xsl:text>
      </xsl:text><xsl:value-of select="'}'"/>
  </xsl:template>
  
  <xsl:template match="sld:slides" mode="generate-html-slides"> 
    <!-- Pass through... there may be specific implementations that we want to do something for --> 
    <xsl:apply-templates mode="#current" />
  </xsl:template>
  
  <xsl:template match="sld:slide[1]" mode="generate-html-slides">
    <!-- Process first slide, assuming it is the cover slide -->
    <div class="slide cover"> 
      <!-- FIXME: Implement a common attributes analog similar to one used in pdf2? -->
      <xsl:apply-templates select="sld:title" mode="generate-html-slide-title"/>
      <xsl:apply-templates select="sld:slidebody" mode="generate-html-slide-body"/>
      <xsl:apply-templates select="sld:slidenotes" mode="generate-html-slide-notes"/>
      
    </div> 
  </xsl:template>
  
  <xsl:template match="sld:slide[position() ne 1]" mode="generate-html-slides">
    <!-- Process slides -->
    <!-- FIXME: Implement a common attributes analog similar to one used in pdf2? -->
    <div class="slide"> 
      <xsl:apply-templates select="sld:title" mode="generate-html-slide-title"/>
      <xsl:apply-templates select="sld:slidebody" mode="generate-html-slide-body"/>
      <xsl:apply-templates select="sld:slidenotes" mode="generate-html-slide-notes"/>
      
    </div> 
  </xsl:template>
  
  <xsl:template match="sld:title" mode="generate-html-slide-title">
    <!-- Pass through because sld:title is element only... there may be specific implementations that we want to do something for --> 
    <xsl:apply-templates mode="#current" />
  </xsl:template>
  
  <xsl:template match="sld:p[1]" mode="generate-html-slide-title">
    <!-- Assume the first sld:p child in the sld:title for sld:slide is the title -->
    <h1>
      <xsl:apply-templates select="@style" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </h1>
  </xsl:template>
  
  <xsl:template match="sld:p" mode="generate-html-slide-body generate-html-slide-notes">
    <p>
      <xsl:apply-templates select="@style" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </p>
  </xsl:template>
  
  <xsl:template match="*[self::sld:inline or self::sld:textrun]" mode="generate-html-slide-title generate-html-slide-body generate-html-slide-notes">
    <!-- sld:inline or sld:textrun shouldn't need different effects depending on if it occurs in title, body, or notes -->
    <xsl:variable name="localName" select="local-name()"/>
    <xsl:choose>
      <xsl:when test="@style='i'">
        <em class="{$localName} i">
          <xsl:apply-templates mode="#current"/>
        </em>
      </xsl:when>
      
      <xsl:when test="@style='b'">
        <strong class="{$localName} b">
          <xsl:apply-templates mode="#current"/>
        </strong>
      </xsl:when>
      
      <xsl:when test="@style='u'">
        <!-- <u> is deprecated in HTML 4 and has different meaning in HTML 5 so use a span -->
        <span class="{$localName} u">
          <xsl:apply-templates mode="#current"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <span class="{$localName} {@style}">
          <xsl:apply-templates mode="#current"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="sld:ul" mode="generate-html-slide-body generate-html-slide-notes">
    <ul>
      <xsl:apply-templates select="@style" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </ul>
  </xsl:template>
  
  <xsl:template match="sld:ol" mode="generate-html-slide-body generate-html-slide-notes">
    <ol>
      <xsl:apply-templates select="@style" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </ol>
  </xsl:template>
  
  <xsl:template match="sld:li" mode="generate-html-slide-body generate-html-slide-notes">
    <li>
      <xsl:apply-templates select="@style" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </li>
  </xsl:template>
  
  <xsl:template match="sld:div" mode="generate-html-slide-body generate-html-slide-notes">
    <div>
      <xsl:apply-templates select="@style" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="sld:image" mode="generate-html-slide-body generate-html-slide-notes">
    <img class="image {@style}" src="{@href}"/>
  </xsl:template>
  
  <xsl:template match="sld:slidenotes" mode="generate-html-slide-notes">
    <!-- Capability to handle slide notes will vary based on system being used (e.g., does not appear that Slidy can handle it; so for now we just output them in a hidden div with an id of slidenotes -->
    <div style="display:none;" id="slidenotes">
      <xsl:apply-templates mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="@style" mode="generate-html-slide-body generate-html-slide-title generate-html-slide-notes">
    <!-- Assume @style on elems in slidesetbody are meant to be @class attribs -->
    <xsl:attribute name="class" select="."/>
  </xsl:template>
  
  <xsl:template mode="slide-fixup" match="*" priority="5">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*,node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="slide-fixup" match="@*|node()">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="@class" mode="slide-fixup" priority="5">
    <xsl:attribute name="class" select="normalize-space()"/> 
  </xsl:template>
  
  <xsl:template mode="slide-custom-fixup" match="*" priority="5">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*,node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="slide-custom-fixup" match="@*|node()">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template name="defaultSlidinator2HTMLCSS">
    <link rel="stylesheet" type="text/css" media="screen, projection, print" 
      href="resources/styles/base-slideset.css" />
  </xsl:template>
</xsl:stylesheet>