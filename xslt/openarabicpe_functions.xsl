<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs" version="3.0"
    xmlns:oape="https://openarabicpe.github.io/ns" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    
    <xsl:include href="../../authority-files/xslt/query-viaf.xsl"/>
    
    <!-- functions -->
    <xsl:function name="oape:query-gazetteer">
        <xsl:param name="placeName"/>
        <!-- $p_gazetteer expects a path to a file -->
        <xsl:param name="gazetteer"/>
        <!-- values for $p_mode are 'location', 'name', 'type' -->
        <xsl:param name="mode"/>
        <!-- select a target language for toponyms -->
        <xsl:param name="output-language"/>
        <xsl:choose>
            <!-- test for @ref pointing to GeoNames -->
            <xsl:when test="starts-with($placeName/@ref, 'geon:')">
                <xsl:variable name="v_geonames-id"
                    select="replace($placeName/@ref, 'geon:(\d+)', '$1')"/>
                <!-- select entry from the gazetteer with the same geonames ID -->
                <xsl:variable name="v_place"
                    select="$gazetteer/descendant::tei:place[tei:idno[@type = 'geon'] = $v_geonames-id][1]"/>
                <xsl:choose>
                    <!-- return location -->
                    <xsl:when test="$mode = 'location'">
                        <xsl:value-of select="$v_place/tei:location/tei:geo"/>
                    </xsl:when>
                    <!-- return toponym in selected language -->
                    <xsl:when test="$mode = 'name'">
                        <xsl:choose>
                            <xsl:when test="$v_place/tei:placeName[@xml:lang = $output-language]">
                                <xsl:value-of
                                    select="normalize-space($v_place/tei:placeName[@xml:lang = $output-language][1])"
                                />
                            </xsl:when>
                            <!-- fallback to english -->
                            <xsl:when test="$v_place/tei:placeName[@xml:lang = 'en']">
                                <xsl:value-of
                                    select="normalize-space($v_place/tei:placeName[@xml:lang = 'en'][1])"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space($v_place/tei:placeName[1])"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <!-- return type -->
                    <xsl:when test="$mode = 'type'">
                        <xsl:value-of select="$v_place/@type"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <!-- return original input toponym if nothing else is fond -->
            <xsl:when test="$mode = 'name'">
                <xsl:value-of select="normalize-space($placeName)"/>
            </xsl:when>
            <!-- otherwise: no location data -->
            <xsl:otherwise>
                <xsl:message>
                    <xsl:text>no location data found for </xsl:text><xsl:value-of select="normalize-space($placeName)"/>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="oape:query-personography">
        <xsl:param name="persName"/>
        <xsl:param name="personography"/>
        <!-- values are 'birth', 'death', 'name', 'wiki', 'countWorks' -->
        <xsl:param name="mode"/>
        <xsl:param name="output-language"/>
        <!-- establish IDs -->
        <xsl:variable name="v_viaf-id" select="replace($persName/@ref,'.*viaf:(\d+).*','$1')"/>
        <xsl:variable name="v_oape-id" select="replace($persName/@ref,'.*oape:pers:(\d+).*','$1')"/>
        <!-- load data from authority file -->
        <xsl:variable name="v_person">
            <xsl:choose>
                <xsl:when test="$v_oape-id!=''">
                    <xsl:copy-of select="$personography/descendant::tei:person[tei:idno[@type = 'oape'] = $v_oape-id][1]"/>
                </xsl:when>
                <xsl:when test="$v_viaf-id!=''">
                    <xsl:copy-of select="$personography/descendant::tei:person[tei:idno[@type = 'viaf'] = $v_viaf-id][1]"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <!-- test for @ref pointing to VIAF -->
            <xsl:when test="$v_person!=''">
                <xsl:choose>
                    <xsl:when test="$mode = 'birth'">
                        <xsl:value-of select="$v_person/descendant-or-self::tei:person/tei:birth/@when"/>
                    </xsl:when>
                    <xsl:when test="$mode = 'death'">
                        <xsl:value-of select="$v_person/descendant-or-self::tei:person/tei:death/@when"/>
                    </xsl:when>
                    <xsl:when test="$mode = 'name'">
                        <xsl:choose>
                            <!-- preference for names without titles etc. -->
                            <xsl:when test="$v_person/descendant-or-self::tei:person/tei:persName[not(tei:addName)][@xml:lang = $output-language]">
                                <xsl:value-of select="$v_person/descendant-or-self::tei:person/tei:persName[not(tei:addName)][@xml:lang = $output-language][1]"/>
                            </xsl:when>
                            <!-- fallback to first full name in selected output language-->
                            <xsl:when test="$v_person/descendant-or-self::tei:person/tei:persName[not(@type = 'flattened')][@xml:lang = $output-language]">
                                <xsl:value-of select="$v_person/descendant-or-self::tei:person/tei:persName[not(@type = 'flattened')][@xml:lang = $output-language][1]"/>
                            </xsl:when>
                            <!-- fallback to first full name in English -->
                            <xsl:when test="$v_person/descendant-or-self::tei:person/tei:persName[not(@type = 'flattened')][@xml:lang = 'en']">
                                <xsl:value-of select="$v_person/descendant-or-self::tei:person/tei:persName[not(@type = 'flattened')][@xml:lang = 'en'][1]"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space($v_person/descendant-or-self::tei:person/tei:persName[not(@type = 'flattened')][1])"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <!-- return number of works in viaf -->
                    <xsl:when test="$mode = 'countWorks' and $v_viaf-id!=''">
                        <xsl:variable name="v_person-viaf">
                    <xsl:call-template name="t_query-viaf-sru">
                        <xsl:with-param name="p_input-type" select="'id'"/>
                        <xsl:with-param name="p_search-term" select="$v_viaf-id"/>
                        <xsl:with-param name="p_include-bibliograpy-in-output" select="true()"/>
                        <xsl:with-param name="p_output-mode" select="'tei'"/>
                    </xsl:call-template>
                </xsl:variable>
                         <xsl:value-of select="count($v_person-viaf/descendant::tei:listBibl/tei:bibl)"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <!-- return original input name if nothing else is fond -->
            <xsl:when test="$mode = 'name'">
                <xsl:value-of select="normalize-space($persName)"/>
            </xsl:when>
            <!-- otherwise: no data -->
            <xsl:otherwise>
                <xsl:message>
                    <xsl:text>no authority data found for </xsl:text><xsl:value-of select="$persName"/>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
