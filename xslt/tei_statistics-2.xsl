<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
    xmlns:oape="https://openarabicpe.github.io/ns" xmlns:tei="http://www.tei-c.org/ns/1.0"
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
    <xsl:param name="p_file-name-personography" select="'personography_OpenArabicPE.TEIP5.xml'"/>
    
    <!-- import functions -->
    <xsl:import href="../../tools/xslt/openarabicpe_functions.xsl"/>
    
    <!-- load the authority files -->
    <xsl:variable name="v_gazetteer"
        select="doc(concat($p_path-authority-files, $p_file-name-gazetteer))"/>
    <xsl:variable name="v_personography"
        select="doc(concat($p_path-authority-files, $p_file-name-personography))"/>
    <!-- variables for CSV output -->
    <xsl:variable name="v_new-line" select="'&#x0A;'"/>
    <xsl:variable name="v_seperator" select="';'"/>
    <xsl:variable name="v_id-file" select="if(tei:TEI/@xml:id) then(tei:TEI/@xml:id) else(substring-before(tokenize(base-uri(),'/')[last()],'.TEIP5'))"/>
    <xsl:template match="tei:TEI">
        <xsl:apply-templates select="descendant::tei:text"/>
    </xsl:template>
    <xsl:template match="tei:text">
        <!-- variables -->
        <!-- select the first edition as source -->
        <xsl:variable name="v_bibl-source"
            select="ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct[1]"/>
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
        <xsl:result-document format="text" href="../_output/statistics/{$v_id-file}-stats_tei-pages.csv">
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
        <xsl:result-document format="text" href="../_output/statistics/{$v_id-file}-stats_tei-articles.csv">
            <!-- csv head -->
            <xsl:text>article.id</xsl:text><xsl:value-of select="$v_seperator"/>
            <!-- information of journal issue -->
            <xsl:text>publication.title</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>date</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>volume</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>issue</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>publication.location.name</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>publication.location.coordinates</xsl:text><xsl:value-of select="$v_seperator"/>
            <!-- information on article -->
            <xsl:text>article.title</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>has.author</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>author.name</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>author.id.viaf</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>author.id.oape</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>author.birth</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>author.death</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>works.viaf.count</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>is.independent</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>byline.location.name</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>byline.location.coordinates</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>word.count</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>character.count</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>page.count</xsl:text>
            <xsl:value-of select="$v_new-line"/>
            <!-- one line for each article -->
            <xsl:for-each select="tei:body/descendant::tei:div[@type = 'article'][not(ancestor::tei:div[@type = 'bill'])]">
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
<!--                <xsl:apply-templates select="$v_publication-place" mode="m_location-name"/>-->
                <xsl:value-of select="oape:query-gazetteer($v_publication-place,$v_gazetteer,'name',$p_output-language)"/>
                <xsl:value-of select="$v_seperator"/>
<!--                <xsl:apply-templates select="$v_publication-place" mode="m_location-coordinates"/>-->
                <xsl:value-of select="oape:query-gazetteer($v_publication-place,$v_gazetteer,'location','')"/>
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
                    <xsl:value-of select="oape:query-personography(.,$v_personography,'name',$p_output-language)"/>
                    <xsl:if test="position() != last()">
                        <xsl:text>|</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:value-of select="$v_seperator"/>
                <!-- author id: VIAF -->
                <xsl:for-each select="tei:byline/descendant::tei:persName">
                    <xsl:value-of select="replace(@ref,'.*(viaf:\d+).*','$1')"/>
                    <xsl:if test="position() != last()">
                        <xsl:text>|</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:value-of select="$v_seperator"/>
                <!-- author id: OpenArabicPE (local authority file) -->
                <xsl:for-each select="tei:byline/descendant::tei:persName">
                    <xsl:value-of select="replace(@ref,'.*(oape:pers:\d+).*','$1')"/>
                </xsl:for-each>
                <xsl:value-of select="$v_seperator"/>
                <!-- birth -->
                <xsl:for-each select="tei:byline/descendant::tei:persName">
                    <xsl:value-of select="oape:query-personography(.,$v_personography,'birth','')"/>
                    <xsl:if test="position() != last()">
                        <xsl:text>|</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:value-of select="$v_seperator"/>
                <!-- death -->
                <xsl:for-each select="tei:byline/descendant::tei:persName">
                    <xsl:value-of select="oape:query-personography(.,$v_personography,'death','')"/>
                    <xsl:if test="position() != last()">
                        <xsl:text>|</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:value-of select="$v_seperator"/>
                <!-- number of works in VIAF -->
                <xsl:for-each select="tei:byline/descendant::tei:persName">
                    <xsl:value-of select="oape:query-personography(.,$v_personography,'countWorks','')"/>
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
                <!-- if there is more than one toponym, prioritize -->
                <xsl:if test="tei:byline/descendant::tei:placeName">
                <xsl:choose>
                    <xsl:when test="count(tei:byline/descendant::tei:placeName) &gt; 1">
                        <!--<xsl:message>
                            <xsl:value-of select="count(tei:byline/descendant::tei:placeName)"/>
                        </xsl:message>-->
                        <xsl:for-each select="tei:byline/descendant::tei:placeName">
                            <xsl:if test="oape:query-gazetteer(.,$v_gazetteer,'type','') = 'town'">
                                <xsl:value-of select="oape:query-gazetteer(.,$v_gazetteer,'name',$p_output-language)"/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="oape:query-gazetteer(tei:byline/descendant::tei:placeName,$v_gazetteer,'name',$p_output-language)"/>
                    </xsl:otherwise>
                </xsl:choose>
                </xsl:if>
                <!--<xsl:for-each select="tei:byline/descendant::tei:placeName">
                        <xsl:value-of select="oape:query-gazetteer(.,$v_gazetteer,'name',$p_output-language)"/>
                    <xsl:if test="position() != last()">
                        <xsl:text>|</xsl:text>
                    </xsl:if>
                </xsl:for-each>-->
                <xsl:value-of select="$v_seperator"/>
                <!-- 2. coordinates -->
                <xsl:if test="tei:byline/descendant::tei:placeName">
                    <xsl:choose>
                    <xsl:when test="count(tei:byline/descendant::tei:placeName) &gt; 1">
                        <xsl:for-each select="tei:byline/descendant::tei:placeName">
                            <xsl:if test="oape:query-gazetteer(.,$v_gazetteer,'type','') = 'town'">
                                <xsl:value-of select="oape:query-gazetteer(.,$v_gazetteer,'location','')"/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="oape:query-gazetteer(tei:byline/descendant::tei:placeName,$v_gazetteer,'location','')"/>
                    </xsl:otherwise>
                </xsl:choose>
                </xsl:if>
                <!--<xsl:for-each select="tei:byline/descendant::tei:placeName">
                    <xsl:value-of select="oape:query-gazetteer(.,$v_gazetteer,'location','')"/>
                    <xsl:if test="position() != last()">
                        <xsl:text>|</xsl:text>
                    </xsl:if>
                </xsl:for-each>-->
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
        <xsl:result-document format="text" href="../_output/statistics/{$v_id-file}-stats_tei-referenced-works.csv">
            <!-- csv head -->
            <xsl:text>bibl.id</xsl:text><xsl:value-of select="$v_seperator"/>
            <!-- information of journal issue -->
            <xsl:text>publication.title</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>date</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>volume</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>issue</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>publication.location.name</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>publication.location.coordinates</xsl:text><xsl:value-of select="$v_seperator"/>
            <!-- information on article -->
            <xsl:text>bibl.text</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>bibl.title.m.or.j</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>bibl.date</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>bibl.volume</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>bibl.issue</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>bibl.title.a</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>bibl.author.name</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>bibl.editor.name</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>bibl.location.name</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>bibl.location.coordinates</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>bibl.publisher</xsl:text>
            <!-- end of head -->
            <xsl:value-of select="$v_new-line"/>
            <!-- one line for each referced work: <bibl>, <title> -->
            <xsl:for-each select="tei:body/descendant::tei:bibl | tei:body/descendant::tei:biblStruct | tei:title[not(ancestor::tei:bibl | ancestor::tei:biblStruct)]">
                <!-- preprocess -->
                <xsl:variable name="v_plain-text">
                    <xsl:apply-templates select="." mode="m_plain-text"/>
                </xsl:variable>
                <!--  ID of referenced work -->
                <xsl:value-of select="concat($v_id-file, '-', @xml:id)"/>
                <!-- information on the source -->
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
<!--                <xsl:apply-templates select="$v_publication-place" mode="m_location-name"/>-->
                <xsl:value-of select="oape:query-gazetteer($v_publication-place,$v_gazetteer,'name',$p_output-language)"/>
                <xsl:value-of select="$v_seperator"/>
<!--                <xsl:apply-templates select="$v_publication-place" mode="m_location-coordinates"/>-->
                <xsl:value-of select="oape:query-gazetteer($v_publication-place,$v_gazetteer,'location','')"/>
                <xsl:value-of select="$v_seperator"/>
                <!-- information on the referenced work -->
                <xsl:value-of select="normalize-space($v_plain-text)"/><xsl:value-of select="$v_seperator"/>
                <!-- publication title -->
                <xsl:value-of select="descendant-or-self::tei:title[@level = ('m','j')]"/><xsl:value-of select="$v_seperator"/>
                <!-- publication date -->
                <xsl:value-of select="descendant::tei:date[@when][1]/@when"/><xsl:value-of select="$v_seperator"/>
                <!-- volume -->
                <xsl:value-of select="descendant::tei:biblScope[@unit='volume']/@from"/><xsl:value-of select="$v_seperator"/>
                <!-- issue -->
                 <xsl:value-of select="descendant::tei:biblScope[@unit='issue']/@from"/><xsl:value-of select="$v_seperator"/>
                <!-- article title -->
                <xsl:value-of select="descendant-or-self::tei:title[@level = 'a']"/><xsl:value-of select="$v_seperator"/>
                <!-- authors -->
                <xsl:for-each select="descendant::tei:author/tei:persName">
                    <xsl:value-of select="oape:query-personography(.,$v_personography,'name',$p_output-language)"/>
                    <xsl:if test="position() != last()">
                        <xsl:text>|</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:value-of select="$v_seperator"/>
                <!-- editors names -->
                <xsl:for-each select="descendant::tei:editor/child::node()[not(matches(.,'\s+'))]">
                    <xsl:value-of select="oape:query-personography(.,$v_personography,'name',$p_output-language)"/>
                    <xsl:if test="position() != last()">
                        <xsl:text>|</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:value-of select="$v_seperator"/>
                <!-- pubPlace -->
                <xsl:if test="descendant::tei:pubPlace/tei:placeName">
                    <xsl:choose>
                    <xsl:when test="count(descendant::tei:pubPlace/tei:placeName) &gt; 1">
                        <xsl:for-each select="descendant::tei:pubPlace/tei:placeName">
                            <xsl:if test="oape:query-gazetteer(.,$v_gazetteer,'type','') = 'town'">
                                <xsl:value-of select="oape:query-gazetteer(.,$v_gazetteer,'name',$p_output-language)"/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="oape:query-gazetteer(descendant::tei:pubPlace/tei:placeName,$v_gazetteer,'name',$p_output-language)"/>
                    </xsl:otherwise>
                </xsl:choose>
                </xsl:if>
                <xsl:value-of select="$v_seperator"/>
                <xsl:if test="descendant::tei:pubPlace/tei:placeName">
                    <xsl:choose>
                    <xsl:when test="count(descendant::tei:pubPlace/tei:placeName) &gt; 1">
                        <xsl:for-each select="descendant::tei:pubPlace/tei:placeName">
                            <xsl:if test="oape:query-gazetteer(.,$v_gazetteer,'type','') = 'town'">
                                <xsl:value-of select="oape:query-gazetteer(.,$v_gazetteer,'location','')"/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="oape:query-gazetteer(descendant::tei:pubPlace/tei:placeName,$v_gazetteer,'location','')"/>
                    </xsl:otherwise>
                </xsl:choose>
                </xsl:if>
                <xsl:value-of select="$v_seperator"/>
                <!-- publisher -->
                <xsl:for-each select="descendant::tei:publisher/child::node()[not(matches(.,'\s+'))]">
                    <xsl:value-of select="oape:query-personography(.,$v_personography,'name',$p_output-language)"/>
                    <xsl:if test="position() != last()">
                        <xsl:text>|</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <!-- end of entry -->
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
