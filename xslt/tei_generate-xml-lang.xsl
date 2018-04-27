<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:html="http://www.w3.org/1999/xhtml" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs xd html"
    version="2.0">
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet adds <tei:att>xml:lang</tei:att> to every node that lacks this attribute. The value is based on the ancestor.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output encoding="UTF-8" indent="no" method="xml" name="xml" omit-xml-declaration="no" version="1.0"/>
    
    <!-- identify the author of the change by means of a @xml:id -->
<!--    <xsl:param name="p_id-editor" select="'pers_TG'"/>-->
    <xsl:include href="../../oxygen-project/OpenArabicPE_parameters.xsl"/>
    
<!--    <!-\- generate a new file -\->
    <xsl:template match="/">
        <!-\-<xsl:result-document href="{substring-before(base-uri(),'.TEIP5.xml')}_lang-codes.TEIP5.xml">-\->
            <xsl:copy>
                <xsl:apply-templates select="node()"/>
            </xsl:copy>
        <!-\-</xsl:result-document>-\->
    </xsl:template>-->

    <!-- reproduce everything -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- document the changes -->
    <xsl:template match="tei:revisionDesc" priority="100">
        <!-- basic debugging -->
        <xsl:if test="$p_verbose = true()">
            <xsl:message><xsl:text>change-id: </xsl:text><xsl:value-of select="$p_id-change"/></xsl:message>
        </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="tei:change">
                <xsl:attribute name="when" select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>
                <xsl:attribute name="who" select="concat('#',$p_id-editor)"/>
                <xsl:attribute name="change" select="$p_id-change"/>
                <xsl:attribute name="xml:lang" select="'en'"/>
                <xsl:text>Added the </xsl:text><tei:att xml:lang="en">xml:lang</tei:att><xsl:text> attribute to all nodes that lacked this attribute. The value is based on the closest ancestor.</xsl:text>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- document changes on changed elements by means of the @change attribute linking to the @xml:id of the <tei:change> element -->
    <xsl:template match="@change" mode="m_documentation">
        <xsl:attribute name="change">
                    <xsl:value-of select="concat(.,' #',$p_id-change)"/>
        </xsl:attribute>
    </xsl:template>
    
    <!-- generate @xml:lang -->
    <xsl:template match="*[not(@xml:lang)][.!=''][not(ancestor-or-self::tei:facsimile)]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <!-- add documentation of change -->
            <xsl:choose>
                <xsl:when test="not(@change)">
                    <xsl:attribute name="change" select="concat('#',$p_id-change)"/>
                </xsl:when>
                <xsl:otherwise>
                     <xsl:apply-templates mode="m_documentation" select="@change"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:attribute name="xml:lang">
                <xsl:value-of select="ancestor::node()[@xml:lang != ''][1]/@xml:lang"/>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>