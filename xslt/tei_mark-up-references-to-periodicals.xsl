<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs" version="3.0" xmlns="http://www.tei-c.org/ns/1.0" xmlns:oape="https://openarabicpe.github.io/ns" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:output encoding="UTF-8" indent="no" method="xml" omit-xml-declaration="no" version="1.0"/>
    <!-- this stylesheet wraps references to periodical titles that start with *jarīda* or *majalla* in a <bibl> and <title> tag  -->
    <!-- NOTE: as always, this doesn't work with mixed-content nodes, such as a <p> interspersed with milestone elements, such as <lb/> -->
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
    <xsl:template name="t_text-milestones">
        <xsl:param name="p_text"/>
        <xsl:param name="p_milestone" select="$p_text/following-sibling::node()[1][local-name() = ('pb', 'cb', 'lb')]"/>
        <xsl:variable name="v_string-length" select="string-length($p_text)"/>
        <!--<xsl:if test="$v_string-length gt 0">-->
        <row>
            <cell n="text">
                <xsl:copy-of select="$p_text"/>
            </cell>
            <cell n="index">
                <xsl:value-of select="$v_string-length"/>
            </cell>
            <cell n="milestone">
                <xsl:copy-of select="$p_milestone"/>
            </cell>
        </row>
        <xsl:message>
            <xsl:text>Found text of </xsl:text>
            <xsl:value-of select="$v_string-length"/>
            <xsl:text> chars</xsl:text>
            <xsl:if test="$p_milestone/name()">
                <xsl:text>, followed by element </xsl:text>
                <xsl:copy-of select="$p_milestone/name()"/>
            </xsl:if>
        </xsl:message>
        <!--</xsl:if>-->
    </xsl:template>
    <xsl:template match="text()[ancestor::tei:text][not(ancestor::tei:title | ancestor::tei:bibl)]">
        <xsl:copy-of select="oape:find-references-to-periodicals(.)"/>
    </xsl:template>
    <xsl:template match="*[text()][tei:pb | tei:cb | tei:lb]">
        <xsl:variable name="v_preprocessed">
            <table>
                <xsl:apply-templates mode="m_preprocess-milestones" select="."/>
            </table>
        </xsl:variable>
        <xsl:variable name="v_compiled-text">
            <xsl:value-of select="$v_preprocessed/descendant::tei:cell[@n = 'text']"/>
        </xsl:variable>
        <xsl:variable name="v_marked-up" select="oape:find-references-to-periodicals($v_compiled-text)"/>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="m_identity-transform"/>
            <xsl:copy-of select="$v_marked-up"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="node() | @*" mode="m_preprocess-milestones">
        <xsl:copy>
            <xsl:apply-templates mode="m_preprocess-milestones" select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="*[text()][tei:pb | tei:cb | tei:lb]" mode="m_preprocess-milestones">
        <xsl:variable name="v_current-name" select="name()"/>
        <xsl:call-template name="t_text-milestones">
            <xsl:with-param name="p_text">
                <xsl:apply-templates mode="m_identity-transform" select="node()[local-name() = ('pb', 'cb', 'lb')][1]/preceding-sibling::node()"/>
            </xsl:with-param>
            <xsl:with-param name="p_milestone" select="node()[local-name() = ('pb', 'cb', 'lb')][1]"/>
        </xsl:call-template>
        <!-- I have to continue with the rest of element - I store it into another variable 
            an encapsulate it with the element of the same name. Then it is processing
            in standard way. -->
        <xsl:variable name="v_remainder">
            <xsl:element name="{$v_current-name}">
                <xsl:copy-of select="node()[local-name() = ('pb', 'cb', 'lb')][1]/following-sibling::node()"/>
            </xsl:element>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$v_remainder/node()/node()[local-name() = ('pb', 'cb', 'lb')]">
                <xsl:apply-templates mode="m_preprocess-milestones" select="$v_remainder"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="t_text-milestones">
                    <xsl:with-param name="p_text" select="$v_remainder/node()/node()"/>
                    <xsl:with-param name="p_milestone" select="''"/>
                </xsl:call-template>
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
