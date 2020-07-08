<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:html="http://www.w3.org/1999/xhtml" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:page="http://schema.primaresearch.org/PAGE/gts/pagecontent/2013-07-15"
    xmlns:oape="https://openarabicpe.github.io/ns"
    exclude-result-prefixes="xs xd html"
    version="3.0">
    <xsl:output encoding="UTF-8" indent="no" method="xml" name="xml" omit-xml-declaration="no" version="1.0"/>
    
    
    <!-- identity transform -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[ancestor::page:TextEquiv]" priority="10">
        <xsl:value-of select="oape:transpose-digits(oape:transpose-digits(.,'urdu', 'arabic'), 'western', 'arabic')"/>
    </xsl:template>
    
    <xsl:function name="oape:transpose-digits">
        <xsl:param name="p_input"/>
        <xsl:param name="p_from"/>
        <xsl:param name="p_to"/>
        <xsl:variable name="v_digits-arabic" select="'٠١٢٣٤٥٦٧٨٩'"/>
        <xsl:variable name="v_digits-persian" select="'٠١٢٣۴۵۶٧٨٩'"/>
        <xsl:variable name="v_digits-urdu" select="'۰۱۲۳۴۵۶۷۸۹'"/>
        <xsl:variable name="v_digits-western" select="'0123456789'"/>
        <xsl:variable name="v_from">
            <xsl:choose>
                <xsl:when test="$p_from = 'arabic'">
                    <xsl:value-of select="$v_digits-arabic"/>
                </xsl:when>
                <xsl:when test="$p_from = 'persian'">
                    <xsl:value-of select="$v_digits-persian"/>
                </xsl:when>
                <xsl:when test="$p_from = 'urdu'">
                    <xsl:value-of select="$v_digits-urdu"/>
                </xsl:when>
                <xsl:when test="$p_from = 'western'">
                    <xsl:value-of select="$v_digits-western"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes">
                        <xsl:text>Value for $p_from not available</xsl:text>
                    </xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="v_to">
            <xsl:choose>
                <xsl:when test="$p_to = 'arabic'">
                    <xsl:value-of select="$v_digits-arabic"/>
                </xsl:when>
                <xsl:when test="$p_to = 'persian'">
                    <xsl:value-of select="$v_digits-persian"/>
                </xsl:when>
                <xsl:when test="$p_to = 'urdu'">
                    <xsl:value-of select="$v_digits-urdu"/>
                </xsl:when>
                <xsl:when test="$p_to = 'western'">
                    <xsl:value-of select="$v_digits-western"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes">
                        <xsl:text>Value for $p_to not available</xsl:text>
                    </xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="translate($p_input, $v_from, $v_to)"/>
    </xsl:function>
</xsl:stylesheet>