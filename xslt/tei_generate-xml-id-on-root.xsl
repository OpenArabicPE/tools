<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs xd"
    version="3.0">
    
    <xsl:output encoding="UTF-8" indent="no" method="xml" name="xml" omit-xml-declaration="no" version="1.0"/>
    <xsl:param name="p_consecutive-file-names" select="true()"/>
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:TEI">
        <xsl:variable name="v_bibl-source" select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct"/>
        <xsl:variable name="v_volume" select="$v_bibl-source/tei:monogr/tei:biblScope[@unit='volume']/@from"/>
        <xsl:variable name="v_issue" select="$v_bibl-source/tei:monogr/tei:biblScope[@unit='issue']/@from"/>
        <xsl:variable name="v_oclc" select="concat('oclc_',$v_bibl-source/tei:monogr/tei:idno[@type='OCLC'][1])"/>
        <xsl:variable name="v_file-name" select="number(replace(base-uri(),'.+-i_(\d+).+$','$1'))"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="$p_consecutive-file-names = false()">
                    <xsl:attribute name="xml:id" select="concat($v_oclc,'-v_', $v_volume, '-i_', $v_issue)"/>
                </xsl:when>
                <xsl:when test="$p_consecutive-file-names = true()">
                    <xsl:attribute name="xml:id" select="concat($v_oclc,'-i_', $v_file-name)"/>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>