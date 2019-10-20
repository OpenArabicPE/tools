<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs" version="2.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output encoding="UTF-8" indent="no" method="xml" omit-xml-declaration="no" version="1.0"/>
    <!-- identify the author of the change by means of a @xml:id -->
    <!--    <xsl:param name="p_id-editor" select="'pers_TG'"/>-->
    <xsl:include href="../../oxygen-project/OpenArabicPE_parameters.xsl"/>
    <xsl:param name="p_string-length" select="50"/>
    <!-- reproduce everything as is -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()[not(ancestor::tei:title)]">
        <xsl:analyze-string
            regex="((\W|و|^)(مجلة|جريدة)\s+\(*)(ال\w+)(\)*)|((\W|و|^)(مجلة|جريدة)\s+\()(.+?)(\))"
            select=".">
            <xsl:matching-substring>
                <xsl:choose>
                    <xsl:when test="matches(., '((\W|و|^)(مجلة|جريدة)\s+\(*)(ال\w+)(\)*)')">
                        <xsl:value-of select="regex-group(1)"/>
                        <xsl:element name="tei:title">
                            <xsl:attribute name="level" select="'j'"/>
                            <xsl:attribute name="change" select="concat('#', $p_id-change)"/>
                            <xsl:value-of select="regex-group(4)"/>
                        </xsl:element>
                        <xsl:value-of select="regex-group(5)"/>
                    </xsl:when>
                    <xsl:when test="matches(., '((\W|و|^)(مجلة|جريدة)\s+\()(.+?)(\))')">
                        <xsl:value-of select="regex-group(6)"/>
                        <xsl:element name="tei:title">
                            <xsl:attribute name="level" select="'j'"/>
                            <xsl:attribute name="change" select="concat('#', $p_id-change)"/>
                            <xsl:value-of select="regex-group(9)"/>
                        </xsl:element>
                        <xsl:value-of select="regex-group(10)"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    <!-- generate documentation of change -->
    <xsl:template match="tei:revisionDesc">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="tei:change">
                <xsl:attribute name="when"
                    select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
                <xsl:attribute name="who" select="concat('#', $p_id-editor)"/>
                <xsl:attribute name="xml:lang" select="'en'"/>
                <xsl:text>Automatically marked up references to periodicals with </xsl:text>
                <tei:tag>title level="j"</tei:tag>
                <xsl:text>.</xsl:text>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
