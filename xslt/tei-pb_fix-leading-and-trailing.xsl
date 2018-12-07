<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="3.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <!-- this stylesheet fixes the problem of page breaks wrongly located at the beginning of the first or the end of the last child node. In these cases pb should move up in the hiearchy -->
    
    <!-- identify the author of the change by means of a @xml:id -->
    <xsl:include href="../../oxygen-project/OpenArabicPE_parameters.xsl"/>
    
    <!-- identity transform -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node()[ancestor::tei:text]">
        <xsl:choose>
        <!-- check for leading pb -->
            <xsl:when test="child::node()[1] = tei:pb">
                <xsl:message>
                    <xsl:value-of select="@xml:id"/>
                    <xsl:text> has a leading pb (</xsl:text>
                    <xsl:value-of select="tei:pb[1]/@xml:id"/>
                    <xsl:text>)</xsl:text>
                </xsl:message>
                <xsl:apply-templates select="tei:pb[1]" mode="m_documentation"/>
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:apply-templates select="node()[not(self::tei:pb[1])]"/>
                </xsl:copy>
            </xsl:when>
        <!-- check for trailing pb -->
            <xsl:when test="child::node()[last()] = tei:pb">
                <xsl:message>
                    <xsl:value-of select="@xml:id"/>
                    <xsl:text> has a trailing pb (</xsl:text>
                    <xsl:value-of select="tei:pb[last()]/@xml:id"/>
                    <xsl:text>)</xsl:text>
                </xsl:message>
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                     <xsl:apply-templates select="node()[not(self::tei:pb[last()])]"/>
                </xsl:copy>
                <xsl:apply-templates select="tei:pb[last()]" mode="m_documentation"/>
            </xsl:when>
            <xsl:when test="normalize-space(child::node()[last()][preceding-sibling::node()[1]/name() = 'pb']) = ' '">
                <xsl:message>
                    <xsl:value-of select="@xml:id"/>
                    <xsl:text> has a trailing pb (</xsl:text>
                    <xsl:value-of select="tei:pb[last()]/@xml:id"/>
                    <xsl:text>)</xsl:text>
                </xsl:message>
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                     <xsl:apply-templates select="node()[not(self::tei:pb[last()])]"/>
                </xsl:copy>
                <xsl:apply-templates select="tei:pb[last()]" mode="m_documentation"/>
            </xsl:when>
            <!-- fallback:nothing changes -->
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- document changes on changed elements by means of the @change attribute linking to the @xml:id of the <tei:change> element -->
    <xsl:template match="node()" mode="m_documentation">
         <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <!-- add documentation of change -->
            <xsl:choose>
                <xsl:when test="not(@change)">
                    <xsl:attribute name="change" select="concat('#',$p_id-change)"/>
                </xsl:when>
                <xsl:otherwise>
                     <xsl:attribute name="change" select="concat(.,' #',$p_id-change)"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- generate documentation of change -->
    <xsl:template match="tei:revisionDesc" priority="100">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="tei:change">
                <xsl:attribute name="when"
                    select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
                <xsl:attribute name="who" select="concat('#', $p_id-editor)"/>
                <xsl:attribute name="xml:id" select="$p_id-change"/>
                <xsl:attribute name="xml:lang" select="'en'"></xsl:attribute>
                <xsl:text>Moved leading and trailing </xsl:text><tei:gi>pb</tei:gi><xsl:text>s up the hierarchy.</xsl:text>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>