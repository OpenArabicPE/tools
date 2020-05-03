<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs" 
    version="3.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:output encoding="UTF-8" indent="no" method="xml" omit-xml-declaration="no" version="1.0"/>

    <!-- this stylesheet wraps references to periodical titles that start with *jarīda* or *majalla* in a <bibl> and <title> tag  -->

    <!-- identify the author of the change by means of a @xml:id -->
    <xsl:include href="../../oxygen-project/OpenArabicPE_parameters.xsl"/>
    <!-- reproduce everything as is -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()[not(ancestor::tei:title)]">
        <xsl:analyze-string regex="(\W|و|^)((مجلة|جريدة)\s+\(*)(ال\w+)(\)*)|(\W|و|^)((مجلة|جريدة)\s+\()(.+?)(\))" select=".">
            <xsl:matching-substring>
                <xsl:choose>
                    <xsl:when test="matches(., '((\W|و|^)(مجلة|جريدة)\s+\(*)(ال\w+)(\)*)')">
                        <xsl:value-of select="regex-group(1)"/>
                        <xsl:call-template name="t_add-bibl">
                            <xsl:with-param name="p_prefix" select="regex-group(2)"/>
                            <xsl:with-param name="p_title" select="regex-group(4)"/>
                            <xsl:with-param name="p_suffix" select="regex-group(5)"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="matches(., '((\W|و|^)(مجلة|جريدة)\s+\()(.+?)(\))')">
                        <xsl:value-of select="regex-group(7)"/>
                        <xsl:call-template name="t_add-bibl">
                            <xsl:with-param name="p_prefix" select="regex-group(7)"/>
                            <xsl:with-param name="p_title" select="regex-group(9)"/>
                            <xsl:with-param name="p_suffix" select="regex-group(10)"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template name="t_add-bibl">
        <xsl:param name="p_prefix"/>
        <xsl:param name="p_title"/>
        <xsl:param name="p_suffix"/>
        <!-- wrap everything in a bibl -->
        <xsl:element name="bibl">
            <xsl:attribute name="type" select="'periodical'"/>
            <!-- add @subtype based on $p_prefix -->
            <xsl:attribute name="subtype">
                <xsl:choose>
                    <xsl:when test="matches($p_prefix,'جريدة')">
                        <xsl:text>newspaper</xsl:text>                        
                    </xsl:when>
                    <xsl:when test="matches($p_prefix,'مجلة')">
                        <xsl:text>journal</xsl:text>                        
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="change" select="concat('#', $p_id-change)"/>
            <xsl:value-of select="$p_prefix"/>
            <!-- title -->
            <xsl:element name="title">
                <xsl:attribute name="level" select="'j'"/>
                <xsl:attribute name="change" select="concat('#', $p_id-change)"/>
                <xsl:value-of select="$p_title"/>
            </xsl:element>
            <xsl:value-of select="$p_suffix"/>
        </xsl:element>
    </xsl:template>
    <!-- generate documentation of change -->
    <xsl:template match="tei:revisionDesc">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="tei:change">
                <xsl:attribute name="when" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
                <xsl:attribute name="who" select="concat('#', $p_id-editor)"/>
                <xsl:attribute name="xml:lang" select="'en'"/>
                <xsl:text>Automatically marked up references to periodicals with </xsl:text><tag>bibl type="periodical"</tag><xsl:text> and </xsl:text><tag>title level="j"</tag><xsl:text>.</xsl:text>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
