<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs" version="3.0" xmlns="http://www.tei-c.org/ns/1.0" xmlns:oape="https://openarabicpe.github.io/ns" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:output encoding="UTF-8" indent="no" method="xml" omit-xml-declaration="no" version="1.0"/>
    <!-- this stylesheet wraps references to periodical titles that start with *jarīda* or *majalla* in a <bibl> and <title> tag  -->
    <!-- NOTE: as always, this doesn't work with mixed-content nodes, such as a <p> interspersed with milestone elements, such as <lb/> -->
    <!-- process
        1. find mixed-content nodes with milestones in them
        2. check if they also contain other child nodes
        3. if so split them along the non-milestone children
        4. pre-process the resulting mixed-content nodes
    -->
    <!-- Problems:
       - titles that do not start with "al-" are not caught
   -->
    <xsl:include href="../../authority-files/xslt/functions.xsl"/>
    <!-- reproduce everything as is -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()[ancestor::tei:text][not(ancestor::tei:title | ancestor::tei:bibl)]">
        <xsl:copy-of select="oape:find-references-to-periodicals(.)"/>
    </xsl:template>
    <xsl:template match="tei:seg[@type = 'mixedContent'][ancestor::tei:text]">
        <xsl:variable name="v_compiled">
            <xsl:apply-templates select="node()" mode="m_compile"/>
        </xsl:variable>
        <xsl:copy-of select="oape:find-references-to-periodicals($v_compiled)"/>
    </xsl:template>
    
    <xsl:template match="node()" mode="m_compile">
        <xsl:choose>
            <xsl:when test="not(child::text())">
                <xsl:text> </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="text()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- generate documentation of change -->
    <xsl:template match="tei:revisionDesc">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="tei:change">
                <xsl:attribute name="when" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
                <xsl:attribute name="who" select="concat('#', $p_id-editor)"/>
                <xsl:attribute name="xml:lang" select="'en'"/>
                <xsl:text>Automatically marked up references to periodicals with </xsl:text>
                <tag>bibl type="periodical"</tag>
                <xsl:text> and </xsl:text>
                <tag>title level="j"</tag>
                <xsl:text>.</xsl:text>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
