<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs" 
    version="3.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:output encoding="UTF-8" indent="no" method="xml" omit-xml-declaration="no" version="1.0"/>

    <!-- this stylesheet tokenizes text() nodes and wraps tokenz (words) in `<w>` -->

    <!-- identify the author of the change by means of a @xml:id -->
    <xsl:include href="../../oxygen-project/OpenArabicPE_parameters.xsl"/>
    
    <!-- initialization of variables -->
    <xsl:param name="p_identify-language" select="false()"/>
    <xsl:variable name="v_alphabet-arabic" select="'اأإبتثحخجدذرزسشصضطظعغفقكلمنهوؤيئىةء٠١٢٣٤٥٦٧٨٩'"/>
    <xsl:variable name="v_alphabet-latin" select="'0123456789abcdefghijklmnopqrstuvwxyz'"/>
    <!-- identity transform -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text/descendant::text()[not(parent::tei:w | parent::tei:pc)]">
        <xsl:analyze-string select="." regex="((\w)+)|([^\w+|\s])">
            <xsl:matching-substring>
                <xsl:choose>
                    <!-- check punctuation character-->
                    <xsl:when test="matches(.,'[^\w+|\s]')">
                        <xsl:element name="pc">
                            <xsl:attribute name="change" select="concat('#', $p_id-change)"/>
                            <xsl:value-of select="regex-group(3)"/>
                        </xsl:element>
                    </xsl:when>
                    <!-- check arabic words -->
                    <xsl:when test="$p_identify-language = true() and matches(.,'\w+') and contains($v_alphabet-arabic, regex-group(2))">
                        <xsl:element name="w">
                            <xsl:attribute name="change" select="concat('#', $p_id-change)"/>
                            <xsl:attribute name="xml:lang" select="'ar'"/>
                           <xsl:value-of select="regex-group(1)"/>
                        </xsl:element>
                    </xsl:when>
                    <!-- check english words -->
                  <xsl:when test="$p_identify-language = true() and matches(.,'\w+') and contains($v_alphabet-latin, regex-group(2))">
                        <xsl:element name="w">
                            <xsl:attribute name="change" select="concat('#', $p_id-change)"/>
                            <xsl:attribute name="xml:lang" select="'en'"/>
                            <xsl:value-of select="regex-group(1)"/>
                        </xsl:element>
                    </xsl:when>
                    <!-- fall back option -->
                    <xsl:otherwise>
                        <xsl:element name="w">
                            <xsl:attribute name="change" select="concat('#', $p_id-change)"/>
                            <xsl:value-of select="regex-group(1)"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <!-- generate documentation of change -->
    <xsl:template match="tei:revisionDesc">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="change">
                <xsl:attribute name="when" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
                <xsl:attribute name="who" select="concat('#', $p_id-editor)"/>
                <xsl:attribute name="xml:lang" select="'en'"/>
                <xsl:text>Automatically tokenized all text() nodes and wrapped words and punctuation charatcers in </xsl:text><gi>w</gi><xsl:text> and </xsl:text><gi>pc</gi><xsl:text> respectively.</xsl:text>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
