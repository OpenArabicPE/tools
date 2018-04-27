<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:html="http://www.w3.org/1999/xhtml" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc" xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs xd html" version="2.0">

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet takes TEI XML as input, looks for <tei:gi>pb</tei:gi> that are not of <tei:att>ed</tei:att>="shamela",
                adds <tei:att>ed</tei:att>="print" to them, computes the current position of the <tei:gi>pb</tei:gi> and adds the first page
                number to this value to establish the page number of the current <tei:gi>pb</tei:gi>, which is then written to the
                    <tei:att>n</tei:att> attribute, i.e. <tei:tag>pb/</tei:tag> is converted to <tei:tag>pb ed="print"
                n="435"</tei:tag>.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output encoding="UTF-8" indent="yes" method="xml" name="xml" omit-xml-declaration="no" version="1.0"/>

    <!-- identify the author of the change by means of a @xml:id -->
<!--    <xsl:param name="p_id-editor" select="'pers_TG'"/>-->
    <xsl:include href="../../oxygen-project/OpenArabicPE_parameters.xsl"/>
    <!--<xsl:variable name="vFirstPage" select="if(//tei:pb[not(@ed='shamela')][1]/@n) then(//tei:pb[not(@ed='shamela')][1]/@n) else(tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct//tei:biblScope[@unit='page']/@from)"/>-->
    
    <xsl:variable name="v_sourceDesc" select="tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc"/>

<!-- reproduce everything as is -->
    <xsl:template match="@* |node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- generate documentation of change -->
    <xsl:template match="tei:revisionDesc" priority="100">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="change">
                <xsl:attribute name="when" select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>
                <xsl:attribute name="who" select="concat('#',$p_id-editor)"/>
                <xsl:attribute name="xml:id" select="$p_id-change"/>
                <xsl:text>Added automated page numbers as </xsl:text><xsl:element name="att">n</xsl:element><xsl:text>s and </xsl:text><xsl:element name="att">ed</xsl:element><xsl:text>="print" for every</xsl:text><xsl:element name="gi">pb</xsl:element><xsl:text> that was not of </xsl:text><xsl:element name="att">ed</xsl:element><xsl:text>="shamela".</xsl:text>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- document changes on changed elements by means of the @change attribute linking to the @xml:id of the <tei:change> element -->
    <xsl:template match="tei:pb/@change">
        <xsl:attribute name="change">
                    <xsl:value-of select="concat(.,' #',$p_id-change)"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="tei:pb[not(@ed = 'shamela')]" name="t_1">
        <xsl:if test="$p_verbose = true()">
            <xsl:message><xsl:text>t_1: Found page break other than shamela</xsl:text></xsl:message>
        </xsl:if>
<!--        <xsl:variable name="v_page-first" select="if(ancestor::tei:text/descendant::tei:pb[not(@ed='shamela')][@n!=''][1]/@n) then(ancestor::tei:text/descendant::tei:pb[not(@ed='shamela')][@n!=''][1]/@n) else(ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct//tei:biblScope[@unit='page']/@from)"/>-->
        <xsl:variable name="v_page-first" select="$v_sourceDesc/tei:biblStruct//tei:biblScope[@unit='page']/@from"/>
        <xsl:copy>
            <!-- add documentation of change -->
                    <xsl:if test="not(@change)">
                        <xsl:attribute name="change" select="concat('#',$p_id-change)"/>
                    </xsl:if>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="ed">
                <xsl:text>print</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="n">
                <xsl:value-of select="count(preceding::tei:pb[not(@ed = 'shamela')]) + $v_page-first"/>
            </xsl:attribute>
            <!--<xsl:choose>
                <xsl:when test="not(@n)">
                    <xsl:attribute name="n">
                        <xsl:value-of select="count(preceding::tei:pb[not(@ed = 'shamela')]) + $v_page-first"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@n"/>
                </xsl:otherwise>
            </xsl:choose>-->
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
