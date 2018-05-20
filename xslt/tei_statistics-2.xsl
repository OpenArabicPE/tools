<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs" version="3.0"
    xmlns:oap="https://openarabicpe.github.io/ns" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:output encoding="UTF-8" indent="yes" method="xml" name="xml" omit-xml-declaration="no"/>
    <xsl:output encoding="UTF-8" indent="yes" method="text" name="text" omit-xml-declaration="yes"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet produces a number of statistics such as word counts, character counts etc. Input are TEI XML files. Output are CSV files.</xd:p>
        </xd:desc>
    </xd:doc>
    <!-- select preference for output language -->
    <xsl:param name="p_output-language" select="'ar-Latn-x-ijmes'"/>
    <!-- locate authority files -->
    <xsl:param name="p_path-authority-files" select="'../../authority-files/data/tei/'"/>
    <xsl:param name="p_file-name-gazetteer" select="'gazetteer_levant-phd.TEIP5.xml'"/>
    <xsl:param name="p_file-name-personography" select="'entities_master.TEIP5.xml'"/>
    <xsl:variable name="v_gazetteer"
        select="doc(concat($p_path-authority-files, $p_file-name-gazetteer))"/>
    <xsl:variable name="v_personography"
        select="doc(concat($p_path-authority-files, $p_file-name-personography))"/>
    <!-- variables for CSV output -->
    <xsl:variable name="v_new-line" select="'&#x0A;'"/>
    <xsl:variable name="v_seperator" select="';'"/>
    <xsl:variable name="v_id-file" select="tei:TEI/@xml:id"/>
    <xsl:template match="tei:TEI">
        <xsl:apply-templates select="descendant::tei:text"/>
    </xsl:template>
    <xsl:template match="tei:text">
        <!-- variables -->
        <xsl:variable name="v_bibl-source"
            select="ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct"/>
        <xsl:variable name="v_title-publication"
            select="$v_bibl-source/tei:monogr/title[@xml:lang = 'ar-Latn-x-ijmes'][not(@type = 'sub')][1]"/>
        <xsl:variable name="v_date"
            select="$v_bibl-source/tei:monogr/tei:imprint/tei:date[@when][1]/@when"/>
        <xsl:variable name="v_volume">
            <xsl:choose>
                <!-- check for correct encoding of volume information -->
                <xsl:when
                    test="$v_bibl-source//tei:biblScope[@unit = 'volume']/@from = $v_bibl-source//tei:biblScope[@unit = 'volume']/@to">
                    <xsl:value-of select="$v_bibl-source//tei:biblScope[@unit = 'volume']/@from"/>
                </xsl:when>
                <!-- check for ranges -->
                <xsl:when
                    test="$v_bibl-source//tei:biblScope[@unit = 'volume']/@from != $v_bibl-source//tei:biblScope[@unit = 'volume']/@to">
                    <xsl:value-of select="$v_bibl-source//tei:biblScope[@unit = 'volume']/@from"/>
                    <!-- probably an en-dash is the better option here -->
                    <xsl:text>/</xsl:text>
                    <xsl:value-of select="$v_bibl-source//tei:biblScope[@unit = 'volume']/@to"/>
                </xsl:when>
                <!-- fallback: erroneous encoding of volume information with @n -->
                <xsl:when test="$v_bibl-source//tei:biblScope[@unit = 'volume']/@n">
                    <xsl:value-of select="$v_bibl-source//tei:biblScope[@unit = 'volume']/@n"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="v_issue">
            <xsl:choose>
                <!-- check for correct encoding of issue information -->
                <xsl:when
                    test="$v_bibl-source//tei:biblScope[@unit = 'issue']/@from = $v_bibl-source//tei:biblScope[@unit = 'issue']/@to">
                    <xsl:value-of select="$v_bibl-source//tei:biblScope[@unit = 'issue']/@from"/>
                </xsl:when>
                <!-- check for ranges -->
                <xsl:when
                    test="$v_bibl-source//tei:biblScope[@unit = 'issue']/@from != $v_bibl-source//tei:biblScope[@unit = 'issue']/@to">
                    <xsl:value-of select="$v_bibl-source//tei:biblScope[@unit = 'issue']/@from"/>
                    <!-- probably an en-dash is the better option here -->
                    <xsl:text>/</xsl:text>
                    <xsl:value-of select="$v_bibl-source//tei:biblScope[@unit = 'issue']/@to"/>
                </xsl:when>
                <!-- fallback: erroneous encoding of issue information with @n -->
                <xsl:when test="$v_bibl-source//tei:biblScope[@unit = 'issue']/@n">
                    <xsl:value-of select="$v_bibl-source//tei:biblScope[@unit = 'issue']/@n"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="v_publication-place" select="$v_bibl-source/tei:monogr/tei:imprint/tei:pubPlace[1]/tei:placeName[1]"/>
        <!-- stats per page -->
        <xsl:result-document format="text"
            href="../_output/statistics/{ancestor::tei:TEI/@xml:id}-stats_tei-pages.csv">
            <!-- requires preprocessing -->
            <xsl:variable name="v_plain-text">
                <xsl:apply-templates mode="m_plain-text"/>
            </xsl:variable>
            <!-- csv head -->
            <xsl:text>publication.title</xsl:text>
            <xsl:value-of select="$v_seperator"/>
            <xsl:text>date</xsl:text>
            <xsl:value-of select="$v_seperator"/>
            <xsl:text>volume</xsl:text>
            <xsl:value-of select="$v_seperator"/>
            <xsl:text>issue</xsl:text>
            <xsl:value-of select="$v_seperator"/>
            <xsl:text>page</xsl:text>
            <xsl:value-of select="$v_seperator"/>
            <xsl:text>word.count</xsl:text>
            <xsl:value-of select="$v_seperator"/>
            <xsl:text>character.count</xsl:text>
            <xsl:value-of select="$v_new-line"/>
            <!-- one line for each page -->
            <xsl:for-each select="tokenize(normalize-space($v_plain-text), '\$pb')">
                <xsl:variable name="v_page" select="substring-before(., '$')"/>
                <xsl:variable name="v_text" select="substring-after(., '$')"/>
                <xsl:if test="$v_page != ''">
                    <!-- title -->
                    <xsl:value-of select="$v_title-publication"/>
                    <xsl:value-of select="$v_seperator"/>
                    <!-- date -->
                    <xsl:value-of select="$v_date"/>
                    <xsl:value-of select="$v_seperator"/>
                    <!-- volume -->
                    <xsl:value-of select="$v_volume"/>
                    <xsl:value-of select="$v_seperator"/>
                    <!-- issue -->
                    <xsl:value-of select="$v_issue"/>
                    <xsl:value-of select="$v_seperator"/>
                    <!-- page information -->
                    <xsl:value-of select="$v_page"/>
                    <xsl:value-of select="$v_seperator"/>
                    <!-- number of words -->
                    <xsl:call-template name="t_count-words">
                        <xsl:with-param name="p_input" select="$v_text"/>
                    </xsl:call-template>
                    <xsl:value-of select="$v_seperator"/>
                    <!-- number of characters -->
                    <xsl:call-template name="t_count-characters">
                        <xsl:with-param name="p_input" select="$v_text"/>
                    </xsl:call-template>
                    <!-- end of line -->
                    <xsl:value-of select="$v_new-line"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:result-document>
        <!-- stats per article -->
        <xsl:result-document format="text"
            href="../_output/statistics/{ancestor::tei:TEI/@xml:id}-stats_tei-articles.csv">
            <!-- csv head -->
            <xsl:text>article.id</xsl:text>
            <xsl:value-of select="$v_seperator"/>
            <!-- information of journal issue -->
            <xsl:text>publication.title</xsl:text>
            <xsl:value-of select="$v_seperator"/>
            <xsl:text>date</xsl:text>
            <xsl:value-of select="$v_seperator"/>
            <xsl:text>volume</xsl:text>
            <xsl:value-of select="$v_seperator"/>
            <xsl:text>issue</xsl:text>
            <xsl:value-of select="$v_seperator"/>
            <xsl:text>publication.location.name</xsl:text>
            <xsl:value-of select="$v_seperator"/>
            <xsl:text>publication.location.coordinates</xsl:text>
            <xsl:value-of select="$v_seperator"/>
            <!-- information on article -->
            <xsl:text>article.title</xsl:text>
            <xsl:value-of select="$v_seperator"/>
            <xsl:text>has.author</xsl:text>
            <xsl:value-of select="$v_seperator"/>
            <xsl:text>author</xsl:text>
            <xsl:value-of select="$v_seperator"/>
            <xsl:text>author.birth</xsl:text>
            <xsl:value-of select="$v_seperator"/>
            <xsl:text>author.death</xsl:text>
            <xsl:value-of select="$v_seperator"/>
            <xsl:text>is.independent</xsl:text>
            <xsl:value-of select="$v_seperator"/>
            <xsl:text>byline.location.name</xsl:text>
            <xsl:value-of select="$v_seperator"/>
            <xsl:text>byline.location.coordinates</xsl:text>
            <xsl:value-of select="$v_seperator"/>
            <xsl:text>word.count</xsl:text>
            <xsl:value-of select="$v_seperator"/>
            <xsl:text>character.count</xsl:text>
            <xsl:value-of select="$v_seperator"/>
            <xsl:text>page.count</xsl:text>
            <xsl:value-of select="$v_new-line"/>
            <!-- one line for each article -->
            <xsl:for-each
                select="descendant::tei:div[@type = 'article'][not(ancestor::tei:div[@type = 'bill'])]">
                <!-- preprocess -->
                <xsl:variable name="v_plain-text">
                    <xsl:apply-templates mode="m_plain-text"/>
                </xsl:variable>
                <!-- article ID -->
                <xsl:value-of select="concat($v_id-file, '-', @xml:id)"/>
                <xsl:value-of select="$v_seperator"/>
                <!-- publication title -->
                <xsl:value-of select="$v_title-publication"/>
                <xsl:value-of select="$v_seperator"/>
                <!-- date -->
                <xsl:value-of select="$v_date"/>
                <xsl:value-of select="$v_seperator"/>
                <!-- volume -->
                <xsl:value-of select="$v_volume"/>
                <xsl:value-of select="$v_seperator"/>
                <!-- issue -->
                <xsl:value-of select="$v_issue"/>
                <xsl:value-of select="$v_seperator"/>
                <!-- publication place -->
                <xsl:apply-templates select="$v_publication-place" mode="m_location-name"/>
                <xsl:value-of select="$v_seperator"/>
                <xsl:apply-templates select="$v_publication-place" mode="m_location-coordinates"/>
                <xsl:value-of select="$v_seperator"/>
                <!-- article title -->
                <xsl:if test="@type = 'article' and ancestor::tei:div[@type = 'section']">
                    <xsl:variable name="v_plain">
                        <xsl:apply-templates mode="m_plain-text"
                            select="ancestor::tei:div[@type = 'section']/tei:head"/>
                    </xsl:variable>
                    <xsl:value-of select="normalize-space($v_plain)"/>
                    <xsl:text>: </xsl:text>
                </xsl:if>
                <xsl:variable name="v_plain">
                    <xsl:apply-templates mode="m_plain-text" select="tei:head"/>
                </xsl:variable>
                <xsl:value-of select="normalize-space($v_plain)"/>
                <xsl:value-of select="$v_seperator"/>
                <!-- has author? -->
                <xsl:choose>
                    <xsl:when test="tei:byline[descendant::tei:persName]">
                        <xsl:text>y</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>n</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="$v_seperator"/>
                <!-- author names -->
                <xsl:for-each select="tei:byline/descendant::tei:persName">
                    <xsl:choose>
                        <xsl:when test="@ref">
                            <xsl:value-of select="@ref"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="v_plain">
                                <xsl:apply-templates mode="m_plain-text" select="."/>
                            </xsl:variable>
                            <xsl:value-of select="normalize-space($v_plain)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="position() != last()">
                        <xsl:text>|</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:value-of select="$v_seperator"/>
                <!-- birth -->
                <xsl:for-each select="tei:byline/descendant::tei:persName">
                    <xsl:apply-templates mode="m_birth-date" select="."/>
                    <xsl:if test="position() != last()">
                        <xsl:text>|</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:value-of select="$v_seperator"/>
                <!-- death -->
                <xsl:for-each select="tei:byline/descendant::tei:persName">
                    <xsl:apply-templates mode="m_death-date" select="."/>
                    <xsl:if test="position() != last()">
                        <xsl:text>|</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:value-of select="$v_seperator"/>
                <!-- is independent or part of a section? -->
                <xsl:choose>
                    <xsl:when test="ancestor::tei:div[@type = 'section']">
                        <xsl:text>n</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>y</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="$v_seperator"/>
                <!-- location information -->
                <!-- 1. name: use normalized toponyms from authority file -->
                <xsl:for-each select="tei:byline/descendant::tei:placeName">
                    <xsl:apply-templates mode="m_location-name" select="."/>
                    <xsl:if test="position() != last()">
                        <xsl:text>|</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:value-of select="$v_seperator"/>
                <!-- 2. coordinates -->
                <xsl:for-each select="tei:byline/descendant::tei:placeName">
                    <xsl:apply-templates mode="m_location-coordinates" select="."/>
                    <xsl:if test="position() != last()">
                        <xsl:text>|</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:value-of select="$v_seperator"/>
                <!-- number of words -->
                <xsl:call-template name="t_count-words">
                    <xsl:with-param name="p_input" select="$v_plain-text"/>
                </xsl:call-template>
                <xsl:value-of select="$v_seperator"/>
                <!-- number of characters -->
                <xsl:call-template name="t_count-characters">
                    <xsl:with-param name="p_input" select="$v_plain-text"/>
                </xsl:call-template>
                <xsl:value-of select="$v_seperator"/>
                <!-- number of pages -->
                <xsl:value-of select="count(descendant::tei:pb[@ed = 'print']) + 1"/>
                <!-- end of line -->
                <xsl:value-of select="$v_new-line"/>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>
    <!-- count words -->
    <xsl:template name="t_count-words">
        <!-- $p_input accepts xml nodes as input -->
        <xsl:param name="p_input"/>
        <xsl:value-of select="number(count(tokenize(string($p_input), '\W+')))"/>
    </xsl:template>
    <!-- count characters: output is a number -->
    <xsl:template name="t_count-characters">
        <!-- $p_input accepts xml nodes as input -->
        <xsl:param name="p_input"/>
        <!--<xsl:variable name="v_plain-text">
            <xsl:apply-templates select="$p_input" mode="mPlainText"/>
        </xsl:variable>-->
        <xsl:value-of select="number(string-length(replace(string($p_input), '\W', '')))"/>
    </xsl:template>
    <xsl:template match="tei:placeName" mode="m_location-name">
        <xsl:choose>
            <!-- test for @ref pointing to GeoNames -->
            <xsl:when test="starts-with(@ref, 'geon:')">
                <xsl:variable name="v_geonames-id" select="replace(@ref, 'geon:(\d+)', '$1')"/>
                <!-- select entry from the gazetteer with the same geonames ID -->
                <xsl:variable name="v_place"
                    select="$v_gazetteer/descendant::tei:place[tei:idno[@type = 'geon'] = $v_geonames-id][1]"/>
                <xsl:choose>
                    <xsl:when test="$v_place//tei:placeName[@xml:lang = $p_output-language]">
                        <xsl:value-of
                            select="normalize-space($v_place//tei:placeName[@xml:lang = $p_output-language][1])"
                        />
                    </xsl:when>
                    <!-- fallback to english -->
                    <xsl:when test="$v_place/tei:placeName[@xml:lang = 'en']">
                        <xsl:value-of
                            select="normalize-space($v_place/tei:placeName[@xml:lang = 'en'][1])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space($v_place/tei:placeName[1])"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- 1. toponym as found in the byline -->
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:placeName" mode="m_location-coordinates">
        <xsl:choose>
            <!-- test for @ref pointing to GeoNames -->
            <xsl:when test="starts-with(@ref, 'geon:')">
                <xsl:variable name="v_geonames-id" select="replace(@ref, 'geon:(\d+)', '$1')"/>
                <!-- select entry from the gazetteer with the same geonames ID -->
                <xsl:variable name="v_place"
                    select="$v_gazetteer/descendant::tei:place[tei:idno[@type = 'geon'] = $v_geonames-id][1]"/>
                <xsl:value-of select="$v_place/tei:location/tei:geo"/>
            </xsl:when>
            <!-- otherwise: no location data -->
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:persName" mode="m_birth-date">
        <xsl:choose>
            <!-- test for @ref pointing to VIAF -->
            <xsl:when test="starts-with(@ref, 'viaf:')">
                <xsl:variable name="v_viaf-id" select="replace(@ref, 'viaf:(\d+)', '$1')"/>
                <!-- select entry from the gazetteer with the same geonames ID -->
                <xsl:variable name="v_person"
                    select="$v_personography/descendant::tei:person[tei:idno[@type = 'viaf'] = $v_viaf-id][1]"/>
                <xsl:value-of select="$v_person/tei:birth/@when"/>
            </xsl:when>
            <!-- otherwise: no data -->
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:persName" mode="m_death-date">
        <xsl:choose>
            <!-- test for @ref pointing to VIAF -->
            <xsl:when test="starts-with(@ref, 'viaf:')">
                <xsl:variable name="v_viaf-id" select="replace(@ref, 'viaf:(\d+)', '$1')"/>
                <!-- select entry from the gazetteer with the same geonames ID -->
                <xsl:variable name="v_person"
                    select="$v_personography/descendant::tei:person[tei:idno[@type = 'viaf'] = $v_viaf-id][1]"/>
                <xsl:value-of select="$v_person/tei:death/@when"/>
            </xsl:when>
            <!-- otherwise: no data -->
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    <!-- plain text mode -->
    <!-- plain text -->
    <xsl:template match="text()" mode="m_plain-text">
        <!-- in many instances adding whitespace before and after a text() node makes a lot of sense -->
        <xsl:text> </xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:text> </xsl:text>
    </xsl:template>
    <!-- replace page breaks with tokens that can be used for string split -->
    <xsl:template match="tei:pb[@ed = 'print']" mode="m_plain-text">
        <xsl:text>$pb</xsl:text>
        <xsl:value-of select="@n"/>
        <xsl:text>$</xsl:text>
    </xsl:template>
    <!-- editorial interventions -->
    <!-- remove all interventions from shamela.ws -->
    <xsl:template match="node()[@resp = '#org_MS']" mode="m_plain-text"/>
    <!-- editorial corrections with choice: original mistakes are encoded as <sic> or <orig>, corrections as <corr> -->
    <xsl:template match="tei:choice" mode="m_plain-text">
        <xsl:apply-templates mode="m_plain-text" select="node()[not(self::tei:corr)]"/>
    </xsl:template>
</xsl:stylesheet>
