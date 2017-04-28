<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:oap="https://openarabicpe.github.io/ns"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xpath-default-namespace="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xs xd"
    version="2.0">
    
    <!-- this stylesheet converts the custom XML used for statistical output of OpenArabicPE to CSV -->
    
    <!-- the new line variable is provided by Tei2Md-parameters -->
<!--    <xsl:variable name="v_new-line" select="'&#x0A;'"/>-->
    <xsl:variable name="v_seperator" select="';'"/>
    
    <xsl:template match="oap:array">
        <xsl:apply-templates mode="m_oap-to-csv"/>
    </xsl:template>
    <!-- each object should be converted into a single line -->
    <xsl:template match="oap:object" mode="m_oap-to-csv">
        <xsl:apply-templates select="oap:item[1]/oap:key" mode="m_oap-to-csv"/>
        <xsl:value-of select="$v_new-line"/>
        <xsl:apply-templates select="oap:item[1]/oap:value" mode="m_oap-to-csv"/>
        <xsl:if test="following-sibling::node()">
            <xsl:value-of select="$v_new-line"/>
        </xsl:if>
    </xsl:template>
    <!--<xsl:template match="oap:item" mode="m_oap-to-csv">
        <xsl:apply-templates mode="m_oap-to-csv"/>
        <xsl:if test="following-sibling::node()">
            <xsl:text>, </xsl:text>
        </xsl:if>
    </xsl:template>-->
    <xsl:template match="oap:key" mode="m_oap-to-csv">
        <xsl:apply-templates mode="m_oap-to-csv"/>
        <xsl:if test="parent::oap:item/following-sibling::oap:item[1]/oap:key">
            <xsl:value-of select="$v_seperator"/>
            <xsl:apply-templates select="parent::oap:item/following-sibling::oap:item[1]/oap:key" mode="m_oap-to-csv"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="oap:value" mode="m_oap-to-csv">
        <xsl:apply-templates mode="m_oap-to-csv"/>
        <xsl:if test="parent::oap:item/following-sibling::oap:item[1]/oap:value">
            <xsl:value-of select="$v_seperator"/>
            <xsl:apply-templates select="parent::oap:item/following-sibling::oap:item[1]/oap:value" mode="m_oap-to-csv"/>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>