<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:html="http://www.w3.org/1999/xhtml" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs xd html"
    version="2.0">
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet generates a <tei:facsimile/> node with a pre-defined number of <tei:surface/> children. All parameters can be set through the group of variables at the beginning of the stylesheet.</xd:p>
            <xd:p>The variable $vEapIssueId must be changed for every issue of Muqtabas</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output encoding="UTF-8" indent="yes" method="xml" omit-xml-declaration="no" version="1.0"/>

    <!-- identify the author of the change by means of a @xml:id -->
<!--    <xsl:param name="p_id-editor" select="'pers_TG'"/>-->
    <xsl:include href="../../oxygen-project/OpenArabicPE_parameters.xsl"/>
    
    <xsl:variable name="v_iiif-scheme" select="'http://'"/>
    <xsl:variable name="v_iiif-server" select="'images.eap.bl.uk'"/>
    <xsl:variable name="v_iiif-prefix" select="'/EAP119'"/>
    
    
    <!-- copy everything -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- replace links to EAP imagery with IIIF manifestos -->
    <xsl:template match="tei:graphic[starts-with(@url,'http://eap.')]">
        <xsl:copy>
            <xsl:apply-templates select="@*[not(name()='url')]"/>
                <xsl:analyze-string select="@url" regex="(EAP119_\d+_\d+_\d+)-.+_(\d+)_L.jpg">
                    <xsl:matching-substring>
                        <xsl:attribute name="url">
                        <xsl:value-of select="concat($v_iiif-scheme,$v_iiif-server,$v_iiif-prefix,'/',regex-group(1),'/',format-number(number(regex-group(2)),'#'),'.jp2')"/>
                        </xsl:attribute>
                        <xsl:attribute name="type" select="'iiif'"/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:attribute name="url">
                            <xsl:value-of select="."/>
                        </xsl:attribute>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
        </xsl:copy>
    </xsl:template>
    
    
    <!-- document the changes -->
    <xsl:template match="tei:revisionDesc">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="tei:change">
                <xsl:attribute name="when" select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>
                <xsl:attribute name="who" select="concat('#',$p_id-editor)"/>
                <xsl:text>Added </xsl:text><tei:gi>graphic</tei:gi><xsl:text> of </xsl:text><tei:att>type</tei:att><xsl:text>="iiif" that links to the IIIF manifestos provided by EAP and deleted the original links to EAP images as these are not working anymore.</xsl:text>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>