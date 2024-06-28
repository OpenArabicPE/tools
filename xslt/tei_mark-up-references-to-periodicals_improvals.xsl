<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0" xmlns="http://www.tei-c.org/ns/1.0" xmlns:oape="https://openarabicpe.github.io/ns" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <!-- this stylesheet queries an external authority files for every <title> and attempts to provide links via the @ref attribute -->
    <!-- The now unnecessary code to updated the master file needs to be removed -->
    <xsl:output encoding="UTF-8" exclude-result-prefixes="#all" indent="no" method="xml" omit-xml-declaration="no"/>
    
    <!-- identify the author of the change by means of a @xml:id -->
    <xsl:include href="../../oxygen-project/OpenArabicPE_parameters.xsl"/>
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()[ancestor::tei:body][not(ancestor::tei:bibl)]" priority="100">
        <xsl:choose>
            <!-- text followed by <title> -->
            <xsl:when test="following-sibling::node()[1][self::tei:title[@level = 'j']]">
                <xsl:variable name="v_title" select="following-sibling::node()[1][self::tei:title[@level = 'j']]"/>
                <xsl:if test="$p_verbose = true()">
                    <xsl:message>
                    <xsl:text>found text followed by </xsl:text>
                    <xsl:copy-of select="$v_title" copy-namespaces="no"/>
                    </xsl:message>
                </xsl:if>
                <xsl:analyze-string regex="(.*)((مجلة|جريدة)\s+\(*)$" select=".">
                    <xsl:matching-substring>
                        <xsl:if test="$p_verbose = true()">
                            <xsl:message>
                                <xsl:text>text ends with مجلة or جريدة</xsl:text>
                            </xsl:message>
                        </xsl:if>
                        <xsl:value-of select="regex-group(1)"/>
                        <xsl:element name="bibl">
                            <xsl:attribute name="type" select="'periodical'"/>
                            <!-- add @subtype based on $p_prefix -->
                            <xsl:attribute name="subtype">
                                <xsl:choose>
                                    <xsl:when test="matches(regex-group(3), 'جريدة')">
                                        <xsl:text>newspaper</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="matches(regex-group(3), 'مجلة')">
                                        <xsl:text>journal</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:attribute name="change" select="concat('#', $p_id-change)"/>
                            <xsl:value-of select="regex-group(2)"/>
                            <xsl:copy-of select="$v_title"/>
                        </xsl:element>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:title[ancestor::tei:body][@level = 'j'][not(ancestor::tei:bibl)][matches(preceding-sibling::text()[1], '(مجلة|جريدة)\s+\(*$')]">
<!--        <xsl:apply-templates select="node()"/>-->
    </xsl:template>
    <!-- generate documentation of change -->
    <xsl:template match="tei:revisionDesc">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="change">
                <xsl:attribute name="when" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
                <xsl:attribute name="who" select="concat('#', $p_id-editor)"/>
                <xsl:attribute name="xml:id" select="$p_id-change"/>
                <xsl:attribute name="xml:lang" select="'en'"/>
                <xsl:text>Automatically wrapped all </xsl:text><tag>title level="j"</tag><xsl:text> preceded by مجلة or جريدة in a </xsl:text><tag>bibl type="periodical"</tag>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
