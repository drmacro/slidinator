<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:df="http://dita2indesign.org/dita/functions"  
  xmlns:index-terms="http://dita4publishers.org/index-terms"
  xmlns:enum="http://dita4publishers.org/enumerables"
  xmlns:glossdata="http://dita4publishers.org/glossdata"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:sld="urn:ns:dita4publishers.org:doctypes:simpleslideset"
  xmlns:htmlutil="http://dita4publishers.org/functions/htmlutil"
  xmlns:local="http://local-functions"
  exclude-result-prefixes="xs xd df relpath index-terms htmlutil glossdata enum local"
  version="2.0">
  
  <!-- =============================
    
       Generate slides from topics
    ============================= -->
  
  <xsl:template match="*[df:class(., 'topic/topic')]">
    <xsl:if test="$debugBoolean">
      <xsl:message> + [DEBUG] topic/topic, default mode: Generating a slide...</xsl:message>
    </xsl:if>
    <sld:slide>
      <xsl:apply-templates select="*[df:class(., 'topic/title')]"/>
      <sld:slidebody>
        <xsl:apply-templates mode="slideBody" select="* except (*[df:class(., 'topic/title')])"/>
      </sld:slidebody>
<!--
                  *[df:class(., 'd4pSlide/d4pStudentNotes')], 
          *[df:class(., 'd4pSlide/d4pInstructorNotes')]

        -->
      
      <sld:slidenotes>
        <xsl:apply-templates mode="slideNotes" select="*"/>
      </sld:slidenotes>
    </sld:slide>    
    
  </xsl:template>
  
  <xsl:template mode="slideBody" match="*[df:class(., 'topic/abstract')]">
    <xsl:apply-templates mode="#current" select="*[df:class(., 'topic/shortdesc')]"/>
  </xsl:template>

  <xsl:template mode="slideBody" match="*[df:class(., 'topic/shortdesc')]">
    <xsl:call-template name="make-para"/>
  </xsl:template>

  <xsl:template  mode="slideBody" priority="10" 
    match="
    *[df:class(., 'd4pSlide/d4pStudentNotes')] | 
    *[df:class(., 'd4pSlide/d4pInstructorNotes')]">
    <!-- Suppress in slideBody mode -->
  </xsl:template>
  
  <xsl:template  mode="slideNotes" 
    match="
    *[df:class(., 'topic/title')] | 
    *[df:class(., 'topic/prolog')]">
    <!-- Suppress -->
  </xsl:template>
  
  <xsl:template  mode="slideNotes" 
    match="*[df:class(., 'topic/body')]">
    <xsl:apply-templates 
      select="*[df:class(., 'topic/section')]" 
      mode="#current"/>
  </xsl:template>
  
  <xsl:template  mode="slideNotes" priority="10" 
    match="
    *[df:class(., 'd4pSlide/d4pStudentNotes')] | 
    *[df:class(., 'd4pSlide/d4pInstructorNotes')]">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/section')]" mode="slideBody">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/section')]" mode="slideNotes">
    <!-- Suppress sections by default in slide notes mode -->
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/title')]">
    <sld:title>
      <sld:p style="Title"><xsl:apply-templates/></sld:p>
    </sld:title>    
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/ul')]" mode="#all">
    <sld:ul>
      <xsl:apply-templates/>
    </sld:ul>    
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/ol')]" mode="#all">
    <sld:ol>
      <xsl:apply-templates/>
    </sld:ol>    
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/li')]" mode="#all">
    <!-- FIXME: May need to handle mix of text and block children
                as for topic/p 
      -->
    <sld:li><xsl:apply-templates/></sld:li>    
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/p')]" name="make-para" mode="#all">
    <xsl:choose>
      <xsl:when test="df:hasBlockChildren(.)">
        <xsl:for-each-group select="node()" group-by="local:isBlock(.)">
          <xsl:choose>
            <xsl:when test="current-grouping-key() = true()">
              <xsl:apply-templates select="current-group()"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="normalize-space(string-join(current-group(), '')) != ''">
                <sld:p><xsl:apply-templates select="current-group()"/></sld:p>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each-group>
      </xsl:when>
      <xsl:otherwise>
        <sld:p><xsl:apply-templates/></sld:p>    
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/fig')]" mode="#all">
    <sld:div style="{local:getOutputClass(.)}"><xsl:apply-templates/></sld:div>  
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/pre')]" mode="#all">
    <sld:pre style="{local:getOutputClass(.)}"><xsl:apply-templates/></sld:pre>  
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/image')][@href != '']" mode="#all">
    <xsl:variable name="hrefValue" as="xs:string" select="@href"/>
    <xsl:variable name="imageUrl" as="xs:string"
      select="relpath:newFile(relpath:getParent(document-uri(root(.))), $hrefValue)"
    />
    <sld:image href="{relpath:getAbsolutePath($imageUrl)}">
      <xsl:apply-templates mode="#current"/>
    </sld:image> 
  </xsl:template>
  
  <xsl:template 
    match="*[df:class(., 'topic/keyword')] | 
    *[df:class(., 'topic/term')] | 
    *[df:class(., 'topic/ph')] 
           ">
    <sld:inline style="{name(.)}"><xsl:apply-templates/></sld:inline>
  </xsl:template>
  
  <xsl:function name="local:getOutputClass" as="xs:string">
    <!-- Return either an explicitly-specified outputclass or the local tagname -->
    <xsl:param name="context" as="element()"/>
    
    <xsl:sequence
      select="if ($context/@outputclass) then string($context/@outputclass) else name($context)"
    />
  </xsl:function>
  
  <xsl:function name="local:isBlock" as="xs:boolean">
    <xsl:param name="node" as="node()"/>
    <xsl:variable name="result" as="xs:boolean"
      select="if ($node/self::*) then df:isBlock($node) else false()"
    />
    <xsl:sequence select="$result"/>
  </xsl:function>
  
</xsl:stylesheet>