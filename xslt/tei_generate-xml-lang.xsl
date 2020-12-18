<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs xd html" version="2.0" xmlns="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet adds <tei:att>xml:lang</tei:att> to every node that lacks this attribute. The value is based on the ancestor.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output encoding="UTF-8" indent="no" method="xml" name="xml" omit-xml-declaration="no" version="1.0"/>
    <!-- identify the author of the change by means of a @xml:id -->
    <!--    <xsl:param name="p_id-editor" select="'pers_TG'"/>-->
    <xsl:include href="../../oxygen-project/OpenArabicPE_parameters.xsl"/>
    
    <!-- variable to test if something needs to be changed -->
    <xsl:variable name="v_changed">
        <xsl:choose>
            <xsl:when test="/descendant::*[. != ''][not(@xml:lang)][not(ancestor-or-self::tei:facsimile)]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- identity transform -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- generate @xml:lang -->
    <xsl:template match="*[not(@xml:lang)][. != ''][not(ancestor-or-self::tei:facsimile)]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <!-- add documentation of change -->
            <xsl:choose>
                <xsl:when test="not(@change)">
                    <xsl:attribute name="change" select="concat('#', $p_id-change)"/>
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
    
     <!-- document the changes -->
    <xsl:template match="tei:revisionDesc" priority="100">
        <!-- basic debugging -->
        <xsl:if test="$p_verbose = true()">
            <xsl:message>
                <xsl:text>change-id: </xsl:text>
                <xsl:value-of select="$p_id-change"/>
            </xsl:message>
        </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:if test="not(@xml:lang)">
                <xsl:attribute name="xml:lang" select="'en'"/>
            </xsl:if>
            <!-- suppress a new tei:change element if nothing was changed -->
            <xsl:if test="$v_changed = true()">
                <xsl:element name="change">
                    <xsl:attribute name="when" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
                    <xsl:attribute name="who" select="concat('#', $p_id-editor)"/>
                    <xsl:attribute name="xml:id" select="$p_id-change"/>
                    <xsl:attribute name="xml:lang" select="'en'"/>
                    <xsl:text>Added the @xml:lang attribute to all nodes that lacked this attribute. The value is based on the closest ancestor.</xsl:text>
                </xsl:element>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- document changes on changed elements by means of the @change attribute linking to the @xml:id of the <tei:change> element -->
    <xsl:template match="@change" mode="m_documentation">
        <xsl:attribute name="change">
            <xsl:value-of select="concat(., ' #', $p_id-change)"/>
        </xsl:attribute>
    </xsl:template>
</xsl:stylesheet>
