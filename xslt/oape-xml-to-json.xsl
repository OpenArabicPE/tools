<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:oape="https://openarabicpe.github.io/ns"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xpath-default-namespace="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="#all"
    version="3.0">
    
    <!-- this stylesheet converts the custom XML used for statistical output of OpenArabicPE to JSON -->
    
    <xsl:template match="oape:array" mode="m_oap-to-json">
        <xsl:apply-templates select="oape:key" mode="m_oap-to-json"/>
        <xsl:text> [</xsl:text>
        <xsl:apply-templates select="node()[not(self::oape:key)]" mode="m_oap-to-json"/>
        <xsl:text>]</xsl:text>
        <xsl:if test="following-sibling::node()">
            <xsl:text>, </xsl:text>
        </xsl:if>
    </xsl:template>
    <xsl:template match="oape:object" mode="m_oap-to-json">
        <xsl:apply-templates select="oape:key" mode="m_oap-to-json"/>
        <xsl:text> {</xsl:text>
        <xsl:apply-templates select="node()[not(self::oape:key)]" mode="m_oap-to-json"/>
        <xsl:text>}</xsl:text>
        <xsl:if test="following-sibling::node()">
            <xsl:text>, </xsl:text>
        </xsl:if>
    </xsl:template>
    <xsl:template match="oape:item" mode="m_oap-to-json">
        <xsl:apply-templates mode="m_oap-to-json"/>
        <xsl:if test="following-sibling::node()">
            <xsl:text>, </xsl:text>
        </xsl:if>
    </xsl:template>
    <xsl:template match="oape:key" mode="m_oap-to-json">
        <xsl:text>"</xsl:text>
        <xsl:apply-templates mode="m_oap-to-json"/>
        <xsl:text>"</xsl:text>
        <xsl:text>: </xsl:text>
    </xsl:template>
    <xsl:template match="oape:value" mode="m_oap-to-json">
        <xsl:text>"</xsl:text>
        <xsl:apply-templates mode="m_oap-to-json"/>
        <xsl:text>"</xsl:text>
        <xsl:if test="following-sibling::node()">
            <xsl:text>, </xsl:text>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>