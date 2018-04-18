<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:oap="https://openarabicpe.github.io/ns"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="text" indent="no" encoding="UTF-8" name="text"/>
    <xsl:output method="xml" indent="yes" encoding="UTF-8" name="xml"/>
    
    <!-- this stylesheet takes a MODS XML file as input, counts publications per location and tries to georeference them through GeoNames or a local authority file. The output is a geoJSON file -->
    
    <!-- include XSLT to query GeoNames.org -->
    <xsl:include href="../../authority-files/xslt/query-geonames.xsl"/>
    <!-- include XSLT to transfrom TEI to geoJSON -->
    <xsl:include href="../../tools/xslt/convert_tei-to-geojson.xsl"/>
    
    
    <xsl:param name="p_verbose" select="false()"/>
    
    <!-- plan: 
        1. retrieve information from GeoNames or local authority file 
        2. transform results to TEI 
        3. transform resulting TEI to geoJSON
    -->
    
    <xsl:template match="/">
        <xsl:result-document  href="../_output/{tokenize( document-uri(),'/')[last()]}.geojson" format="text">
            <xsl:copy-of select="$v_geojson-opener"/>
            <xsl:for-each-group select="descendant::mods:mods" group-by="mods:originInfo/mods:place/mods:placeTerm[1]">
                <xsl:sort select="count(current-group())" data-type="number" order="descending"/>
                <xsl:variable name="v_toponym" select="current-grouping-key()"/>
                <xsl:variable name="v_count" select="count(current-group())"/>
                <xsl:variable name="v_output-tei">
                    <tei:place>
                        <tei:placeName><xsl:value-of select="$v_toponym"/></tei:placeName>
                        <xsl:call-template name="t_query-geonames">
                            <xsl:with-param name="p_input" select="$v_toponym"/>
                            <xsl:with-param name="p_output-mode" select="'tei'"/>
                        </xsl:call-template>
                    </tei:place>
                </xsl:variable>
                <!--<xsl:variable name="v_output-csv">
            <xsl:value-of select="current-grouping-key()"/>
            <xsl:text>,</xsl:text>
            <xsl:value-of select="count(current-group())"/>
            <xsl:text>,</xsl:text>
            <xsl:call-template name="t_query-geonames">
                <xsl:with-param name="p_input" select="current-grouping-key()"/>
                <xsl:with-param name="p_output-mode" select="'csv'"/>
                <xsl:with-param name="p_csv-separator" select="','"/>
            </xsl:call-template>
            <xsl:text>;</xsl:text>
            </xsl:variable>-->
                <!-- output -->
                <xsl:call-template name="t_boilerplate-geojson">
                    <xsl:with-param name="p_input" select="$v_output-tei/descendant-or-self::tei:place"/>
                    <xsl:with-param name="p_properties">
                        <xsl:text>"publications": </xsl:text><xsl:value-of select="$v_count"/>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:if test="not(last())">
                    <xsl:text>,</xsl:text>
                </xsl:if>
            </xsl:for-each-group>
            <xsl:copy-of select="$v_geojson-closer"/>
        </xsl:result-document>
    </xsl:template>
    
    
    
</xsl:stylesheet>