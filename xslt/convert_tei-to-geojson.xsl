<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="3.0">
    
    <xsl:output method="text" indent="no" encoding="UTF-8" name="text"/>
    
    <xsl:param name="p_lang" select="'ar'"/>
    <xsl:variable name="v_geojson-opener">
        <xsl:text>{"type": "FeatureCollection","features": [</xsl:text>
    </xsl:variable>
    <xsl:variable name="v_geojson-closer">
        <xsl:text>]}</xsl:text>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:result-document href="test_geojson-{ format-date(current-date(),'[Y0001]-[M01]-[D01]')}.geojson" format="text">
            <xsl:value-of select="$v_geojson-opener"/>
            <xsl:apply-templates select="descendant::tei:place"/>
            <xsl:value-of select="$v_geojson-closer"/>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="tei:place" name="t_boilerplate-geojson">
        <xsl:param name="p_input" select="."/>
        <xsl:param name="p_lang" select="$p_lang"/>
        <!-- the following can be derived from the input parameter -->
        <xsl:param name="p_lat" select="tokenize($p_input/tei:location/tei:geo,',')[1]"/>
        <xsl:param name="p_lng" select="tokenize($p_input/tei:location/tei:geo,',')[2]"/>
        <xsl:param name="p_toponym">
            <xsl:choose>
                <xsl:when test="$p_input/tei:placeName[@xml:lang=$p_lang]">
                    <xsl:copy-of select="$p_input/tei:placeName[@xml:lang=$p_lang][1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$p_input/tei:placeName[1]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:param>
        <xsl:param name="p_id-geonames" select="$p_input/tei:idno[@type='geon'][1]"/>
        <!-- $p_properties takes correctly formatted JSON as input -->
        <xsl:param name="p_properties">
            <xsl:text>"publications": 47</xsl:text>
        </xsl:param>
        <!-- generate the output -->
        <xsl:if test="$p_lat!='' and $p_lng!=''">
            <xsl:text>{"type": "Feature", "geometry": {"type": "Point","coordinates": [</xsl:text><xsl:value-of select="$p_lng"/><xsl:text>, </xsl:text><xsl:value-of select="$p_lat"/><xsl:text>]},"properties": {"name": "</xsl:text><xsl:value-of select="normalize-space($p_toponym)"/><xsl:text>"</xsl:text>
            <xsl:if test="$p_id-geonames!=''">
                <xsl:text>,"geonId": </xsl:text><xsl:value-of select="$p_id-geonames"/>
            </xsl:if>
            <xsl:if test="$p_properties!=''">
                <xsl:text>,</xsl:text><xsl:value-of select="$p_properties"/>
            </xsl:if>
            <xsl:text>}}</xsl:text>
            <!-- add comma for following  -->
            <xsl:if test="following::tei:place">
                <xsl:text>,</xsl:text>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>