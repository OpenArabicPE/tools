<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs" version="2.0" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    
    <!-- this stylesheet extracts all elements from a TEI XML file and groups them into a <tagsDecl> element  -->
    <xsl:output indent="yes" method="xml" omit-xml-declaration="no" encoding="UTF-8"/>
    
    <!-- copy everything -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:teiHeader">
       <xsl:copy>
           <xsl:apply-templates select="@* "/>
           <xsl:apply-templates select="child::tei:fileDesc"/>
           <xsl:choose>
               <xsl:when test="not(child::tei:encodingDesc)">
                   <xsl:element name="encodingDesc">
                       <xsl:call-template name="t_tagsDecl"/>
                   </xsl:element>
               </xsl:when>
               <xsl:otherwise>
                   <xsl:apply-templates select="child::tei:encodingDesc"/>
               </xsl:otherwise>
           </xsl:choose>
           <xsl:apply-templates select="child::tei:revisionDesc"/>
       </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:encodingDesc">
        <xsl:copy>
                <xsl:apply-templates select="@* | node()"/>
            <xsl:if test="not(child::tei:tagsDecl)">
                <xsl:call-template name="t_tagsDecl"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <!-- generating the documentation of all used tags in a <tagsDecl> -->
    <xsl:template name="t_tagsDecl">
        <xsl:element name="tagsDecl">
            <xsl:element name="namespace">
                <xsl:attribute name="name" select="'http://www.tei-c.org/ns/1.0'"/>
                <!-- note that namespace prefixes are part of name() -->
                <xsl:for-each-group select="/descendant::tei:*" group-by="if(matches(name(),'.+:.+$')) then(substring-after(name(),':')) else(name())">
                    <xsl:sort order="ascending" select="name()"/>
                    <xsl:element name="tagUsage">
                        <xsl:attribute name="gi" select="current-grouping-key()"/>
                        <xsl:attribute name="occurs" select="count(current-group())"/>
                    </xsl:element>
                </xsl:for-each-group>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- generate documentation of change -->
    <xsl:template match="tei:revisionDesc">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="change">
                <xsl:attribute name="when" select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>
                <xsl:attribute name="xml:lang" select="'en'"/>
                <xsl:text>Added an automatically generated </xsl:text>
                <xsl:element name="gi"><xsl:value-of select="'tagsDecl'"/></xsl:element>
                <xsl:text>listing all TEI tags used in this file. The frequency of each tag is recoreded by means of an </xsl:text>
                <xsl:element name="att">occurs</xsl:element>
                <xsl:text> attribute.</xsl:text>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
