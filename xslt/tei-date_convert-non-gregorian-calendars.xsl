<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns="http://www.tei-c.org/ns/1.0" xmlns:oape="https://openarabicpe.github.io/ns" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:output encoding="UTF-8" indent="no" method="xml" omit-xml-declaration="no" version="1.0"/>
    <xsl:include href="../../../xslt-calendar-conversion/functions/date-functions.xsl"/>
    <!-- this stylesheet goes through a TEI file and looks for all <tei:date> elements that have @when-custom but no @when attribute -->
    <!-- identify the author of the change by means of a @xml:id -->
    <xsl:include href="../../oxygen-project/OpenArabicPE_parameters.xsl"/>
    <!-- select whether to update existing conversions -->
    <xsl:param name="p_update-existing-dates" select="false()"/>
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- convert dates date include information on single days -->
    <xsl:template match="tei:date[string-length(@when-custom) = 10]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="not(@when) or $p_update-existing-dates = true()">
                    <!-- add documentation of change -->
                    <xsl:choose>
                        <xsl:when test="not(@change)">
                            <xsl:attribute name="change" select="concat('#', $p_id-change)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates mode="m_documentation" select="@change"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:attribute name="when">
                        <xsl:value-of select="oape:date-convert-calendars(@when-custom, @datingMethod, '#cal_gregorian')"/>
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <!-- convert hijri years only -->
    <xsl:template match="tei:date[string-length(@when-custom) = 4][@datingMethod = '#cal_islamic'][not(@when)][not(@notBefore)]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <!-- add documentation of change -->
            <xsl:choose>
                <xsl:when test="not(@change)">
                    <xsl:attribute name="change" select="concat('#', $p_id-change)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates mode="m_documentation" select="@change"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:variable name="v_date-h-1" select="concat(@when-custom, '-01-01')"/>
            <xsl:variable name="v_date-g-1" select="oape:date-convert-calendars($v_date-h-1, '#cal_islamic', '#cal_gregorian')"/>
            <xsl:variable name="v_date-h-2" select="concat(@when-custom, '-12-29')"/>
            <xsl:variable name="v_date-g-2" select="oape:date-convert-calendars($v_date-h-2, '#cal_islamic', '#cal_gregorian')"/>
            <!-- test if the Hijrī year spans more than one Gregorian year (this is not the case for 1295, 1329  -->
            <xsl:choose>
                <xsl:when test="substring($v_date-g-1, 1, 4) = substring($v_date-g-2, 1, 4)">
                    <xsl:attribute name="when" select="substring($v_date-g-1, 1, 4)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="notBefore" select="$v_date-g-1"/>
                    <xsl:attribute name="notAfter" select="$v_date-g-2"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <!-- document changes -->
    <xsl:template match="tei:revisionDesc">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="change">
                <xsl:attribute name="when" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
                <xsl:attribute name="who" select="concat('#', $p_id-editor)"/>
                <xsl:attribute name="xml:id" select="$p_id-change"/>
                <xsl:attribute name="xml:lang" select="'en'"/>
                <xsl:text>Automatically added computed Gregorian dates to the </xsl:text>
                <xsl:element name="att">when</xsl:element>
                <xsl:text> attributes of all non-Gregorian </xsl:text>
                <xsl:element name="gi">date</xsl:element>
                <xsl:text> elements.</xsl:text>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- document changes on changed elements by means of the @change attribute linking to the @xml:id of the <tei:change> element -->
    <xsl:template match="@change" mode="m_documentation">
        <xsl:attribute name="change">
            <xsl:value-of select="concat(., ' #', $p_id-change)"/>
        </xsl:attribute>
    </xsl:template>
</xsl:stylesheet>
