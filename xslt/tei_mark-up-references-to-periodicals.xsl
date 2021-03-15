<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs" version="3.0" xmlns="http://www.tei-c.org/ns/1.0" xmlns:oape="https://openarabicpe.github.io/ns" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:output encoding="UTF-8" indent="no" method="xml" omit-xml-declaration="no" version="1.0"/>
    <!-- this stylesheet wraps references to periodical titles that start with *jarīda* or *majalla* in a <bibl> and <title> tag  -->
    <!-- NOTE: as always, this doesn't work with mixed-content nodes, such as a <p> interspersed with milestone elements, such as <lb/> -->
    <!-- identify the author of the change by means of a @xml:id -->
    <!--    <xsl:include href="../../oxygen-project/OpenArabicPE_parameters.xsl"/>-->
    <xsl:include href="../../authority-files/xslt/functions.xsl"/>
    <!-- reproduce everything as is -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()[not(ancestor::tei:title)]">
        <!-- find the token identifying a periodical and followed by a likely title -->
        <xsl:variable name="v_regex-1" select="'(\W|و|ل|^)((مجلة|جريدة)\s+)((ال\w+\s*)+?)(\s*ال\w+ية*)'"/>
        <xsl:variable name="v_regex-2" select="'(\W|و|ل|^)((مجلة|جريدة)\s+\()(.+?)(\)\s*(ال\w+ية)*)'"/>
        <xsl:analyze-string regex="{concat($v_regex-1, '|', $v_regex-2)}" select=".">
            <xsl:matching-substring>
                <xsl:choose>
                    <!-- sequence matters -->
                    <xsl:when test="matches(., $v_regex-2)">
                        <xsl:value-of select="regex-group(7)"/>
                        <xsl:call-template name="t_add-bibl">
                            <xsl:with-param name="p_prefix" select="regex-group(8)"/>
                            <xsl:with-param name="p_title" select="regex-group(10)"/>
                            <xsl:with-param name="p_suffix" select="regex-group(11)"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="matches(., $v_regex-1)">
                        <xsl:value-of select="regex-group(1)"/>
                        <xsl:call-template name="t_add-bibl">
                            <xsl:with-param name="p_prefix" select="regex-group(2)"/>
                            <xsl:with-param name="p_title" select="normalize-space(regex-group(4))"/>
                            <xsl:with-param name="p_suffix" select="regex-group(6)"/>
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
        <!-- test if the suffix string contains a toponym -->
        <xsl:variable name="v_place-ref">
            <xsl:choose>
                <xsl:when test="matches($p_suffix, '\sال\w+ية$')">
                    <xsl:variable name="v_entity">
                        <xsl:element name="placeName">
                            <xsl:value-of select="replace($p_suffix, '^.*ال(\w+)ية$', '$1')"/>
                        </xsl:element>
                    </xsl:variable>
                    <xsl:value-of select="oape:query-gazetteer($v_entity/descendant-or-self::tei:placeName, $v_gazetteer, $p_local-authority, 'tei-ref', '')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'NA'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$p_verbose = true()">
            <xsl:message>
                <xsl:text>Found reference to a periodical with </xsl:text>
                <xsl:text>title: </xsl:text>
                <xsl:value-of select="$p_title"/>
                <xsl:text>, suffix: </xsl:text>
                <xsl:value-of select="$p_suffix"/>
                <xsl:text>, toponym: </xsl:text>
                <xsl:value-of select="$v_place-ref"/>
            </xsl:message>
        </xsl:if>
        <!-- wrap everything in a bibl -->
        <xsl:element name="bibl">
            <xsl:attribute name="resp" select="'xslt'"/>
            <xsl:attribute name="type" select="'periodical'"/>
            <!-- add @subtype based on $p_prefix -->
            <xsl:attribute name="subtype">
                <xsl:choose>
                    <xsl:when test="matches($p_prefix, 'جريدة')">
                        <xsl:text>newspaper</xsl:text>
                    </xsl:when>
                    <xsl:when test="matches($p_prefix, 'مجلة')">
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
                <!-- this will remove toponyms from the title. They need to be added after the title -->
                <xsl:value-of select="$p_title"/>
            </xsl:element>
            <xsl:value-of select="$p_suffix"/>
            <!-- empty content with attributes to provide machine-readable data -->
            <xsl:if test="$v_place-ref != 'NA'">
                <xsl:element name="pubPlace">
                    <xsl:attribute name="resp" select="'xslt'"/>
                    <xsl:element name="placeName">
                        <xsl:attribute name="ref" select="$v_place-ref"/>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
        </xsl:element>
        <!-- add trailing whitespace -->
        <xsl:text> </xsl:text>
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
