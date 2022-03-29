<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs" version="3.0" 
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:oape="https://openarabicpe.github.io/ns"
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:output encoding="UTF-8" indent="no" method="xml" omit-xml-declaration="no"/>
    
     <xsl:include href="../../oxygen-project/OpenArabicPE_parameters.xsl"/>
    
    <xsl:param name="p_hathitrust-correction-factor" as="xs:integer" select="0"/>
    
    <!-- identity transform -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:graphic[matches(@url, 'babel.hathitrust.org')]">
        <xsl:variable name="v_xml-id-parent" select="parent::tei:surface/@xml:id"/>
        <xsl:variable name="v_corresponding-pb-n" select="ancestor::tei:TEI/descendant::tei:pb[@facs = concat('#', $v_xml-id-parent)]/@n"/>
        <xsl:variable name="v_hathitrust-base-url"  select="replace(@url,'(^.+;seq=)(\d+)', '$1')"/>
        <xsl:variable name="v_hathitrust-seq"  select="number(replace(@url,'(^.+;seq=)(\d+)', '$2'))"/>
        <xsl:variable name="v_hathitrust-correction-factor">
            <!--<xsl:choose>
                <!-\- these are the correction factors for al-Muqtabas 8 as of 2020-07-27 -\->
                 <xsl:when test="$v_corresponding-pb-n &gt;= 876">
                    <xsl:value-of select="4"/>
                </xsl:when>
                <!-\-<xsl:when test="$v_corresponding-pb-n &gt;= 718">
                    <xsl:value-of select="4"/>
                </xsl:when>
                <xsl:when test="$v_corresponding-pb-n &gt;= 404">
                    <xsl:value-of select="2"/>
                </xsl:when>-\->
                <xsl:otherwise>
                    <xsl:value-of select="$p_hathitrust-correction-factor"/>
                </xsl:otherwise>
            </xsl:choose>-->
            <xsl:value-of select="$p_hathitrust-correction-factor"/>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <!-- document changes -->
            <xsl:attribute name="change">
                <xsl:choose>
                    <xsl:when test="@change">
                        <xsl:value-of select="concat(@change, ' #', $p_id-change)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat(' #', $p_id-change)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <!-- fix URL -->
            <xsl:attribute name="url" select="concat($v_hathitrust-base-url, $v_hathitrust-seq + $v_hathitrust-correction-factor)"/>
            <xsl:apply-templates/>
        </xsl:copy>
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
                <xsl:text>Fixed URLs pointing to facsimiles at Hathitrust that had been subject to link rot due to changes at their side.</xsl:text>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>