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
    
    <!-- this stylesheet converts the custom XML used for statistical output of OpenArabicPE to CSV -->
    
    <!-- the new line variable is provided by Tei2Md-parameters -->
<!--    <xsl:variable name="v_new-line" select="'&#x0A;'"/>-->
    <xsl:variable name="v_seperator" select="';'"/>
    
    <xsl:template match="oape:array">
        <xsl:apply-templates mode="m_oap-to-csv"/>
    </xsl:template>
    <!-- each object should be converted into a single line -->
    <xsl:template match="oape:object" mode="m_oap-to-csv">
        <xsl:apply-templates select="oape:item[1]/oape:key" mode="m_oap-to-csv"/>
        <xsl:value-of select="$v_new-line"/>
        <xsl:apply-templates select="oape:item[1]/oape:value" mode="m_oap-to-csv"/>
        <xsl:if test="following-sibling::node()">
            <xsl:value-of select="$v_new-line"/>
        </xsl:if>
    </xsl:template>
    <!--<xsl:template match="oape:item" mode="m_oap-to-csv">
        <xsl:apply-templates mode="m_oap-to-csv"/>
        <xsl:if test="following-sibling::node()">
            <xsl:text>, </xsl:text>
        </xsl:if>
    </xsl:template>-->
    <xsl:template match="oape:key" mode="m_oap-to-csv">
        <xsl:apply-templates mode="m_oap-to-csv"/>
        <xsl:if test="parent::oape:item/following-sibling::oape:item[1]/oape:key">
            <xsl:value-of select="$v_seperator"/>
            <xsl:apply-templates select="parent::oape:item/following-sibling::oape:item[1]/oape:key" mode="m_oap-to-csv"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="oape:value" mode="m_oap-to-csv">
        <xsl:apply-templates mode="m_oap-to-csv"/>
        <xsl:if test="parent::oape:item/following-sibling::oape:item[1]/oape:value">
            <xsl:value-of select="$v_seperator"/>
            <xsl:apply-templates select="parent::oape:item/following-sibling::oape:item[1]/oape:value" mode="m_oap-to-csv"/>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>