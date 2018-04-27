<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:oap="https://openarabicpe.github.io/ns" xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="3.0">

    <xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no" name="xml"/>
    <xsl:output method="text" indent="yes" encoding="UTF-8" omit-xml-declaration="yes" name="text"/>

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet produces a number of statistics such as word counts, character counts etc. Input are TEI XML files. Output are CSV files.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:variable name="v_new-line" select="'&#x0A;'"/>
    <xsl:variable name="v_seperator" select="';'"/>

    <xsl:template match="tei:TEI">
        <xsl:apply-templates select="descendant::tei:text"/>
    </xsl:template>

    <xsl:template match="tei:text">
        <!-- variables -->
        <xsl:variable name="v_bibl-source" select="ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct"/>
        <xsl:variable name="v_title-publication" select="$v_bibl-source/tei:monogr/title[@xml:lang='ar-Latn-x-ijmes'][not(@type='sub')][1]"/>
        <xsl:variable name="v_date" select="$v_bibl-source/tei:monogr/tei:imprint/tei:date[@when][1]/@when"/>
        <xsl:variable name="v_volume">
            <xsl:choose>
                <!-- check for correct encoding of volume information -->
                <xsl:when test="$v_bibl-source//tei:biblScope[@unit = 'volume']/@from = $v_bibl-source//tei:biblScope[@unit = 'volume']/@to">
                    <xsl:value-of select="$v_bibl-source//tei:biblScope[@unit = 'volume']/@from"/>
                </xsl:when>
                <!-- check for ranges -->
                <xsl:when test="$v_bibl-source//tei:biblScope[@unit = 'volume']/@from != $v_bibl-source//tei:biblScope[@unit = 'volume']/@to">
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
                <xsl:when test="$v_bibl-source//tei:biblScope[@unit = 'issue']/@from = $v_bibl-source//tei:biblScope[@unit = 'issue']/@to">
                    <xsl:value-of select="$v_bibl-source//tei:biblScope[@unit = 'issue']/@from"/>
                </xsl:when>
                <!-- check for ranges -->
                <xsl:when test="$v_bibl-source//tei:biblScope[@unit = 'issue']/@from != $v_bibl-source//tei:biblScope[@unit = 'issue']/@to">
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
        <!-- stats per page -->
        <xsl:result-document href="../_output/statistics/{ancestor::tei:TEI/@xml:id}-stats_tei-pages.csv" format="text">
            <!-- requires preprocessing -->
            <xsl:variable name="v_plain-text">
                <xsl:apply-templates mode="m_plain-text"/>
            </xsl:variable>
            <!-- csv head -->
            <xsl:text>publication</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>date</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>volume</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>issue</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>page</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>word.count</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>character.count</xsl:text>
            <xsl:value-of select="$v_new-line"/>
            <!-- one line for each page -->
            <xsl:for-each select="tokenize(normalize-space($v_plain-text),'\$pb')">
                <xsl:variable name="v_page" select="substring-before(.,'$')"/>
                <xsl:variable name="v_text" select="substring-after(.,'$')"/>
                <xsl:if test="$v_page!=''">
                    <!-- title -->
                    <xsl:value-of select="$v_title-publication"/><xsl:value-of select="$v_seperator"/>
                    <!-- date -->
                    <xsl:value-of select="$v_date"/><xsl:value-of select="$v_seperator"/>
                    <!-- volume -->
                    <xsl:value-of select="$v_volume"/><xsl:value-of select="$v_seperator"/>
                    <!-- issue -->
                    <xsl:value-of select="$v_issue"/><xsl:value-of select="$v_seperator"/>
                    <!-- page information -->
                    <xsl:value-of select="$v_page"/><xsl:value-of select="$v_seperator"/>
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
        <xsl:result-document href="../_output/statistics/{ancestor::tei:TEI/@xml:id}-stats_tei-articles.csv" format="text">
            <!-- csv head -->
            <xsl:text>publication</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>date</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>volume</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>issue</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>article.id</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>article.title</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>has.author</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>author</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>is.independent</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>word.count</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>character.count</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>page.count</xsl:text>
            <xsl:value-of select="$v_new-line"/>
           <!-- one line for each article -->
            <xsl:for-each select="descendant::tei:div[@type = 'article'][not(ancestor::tei:div[@type = 'bill'])]">
                <!-- preprocess -->
                <xsl:variable name="v_plain-text">
                    <xsl:apply-templates mode="m_plain-text"/>
                </xsl:variable>
                <!-- title -->
                <xsl:value-of select="$v_title-publication"/><xsl:value-of select="$v_seperator"/>
                <!-- date -->
                <xsl:value-of select="$v_date"/><xsl:value-of select="$v_seperator"/>
                <!-- volume -->
                <xsl:value-of select="$v_volume"/><xsl:value-of select="$v_seperator"/>
                <!-- issue -->
                <xsl:value-of select="$v_issue"/><xsl:value-of select="$v_seperator"/>
                <!-- article ID -->
                <xsl:value-of select="@xml:id"/><xsl:value-of select="$v_seperator"/>
                <!-- article title -->
                    <xsl:if test="@type = 'article' and ancestor::tei:div[@type = 'section']">
                        <xsl:variable name="v_plain">
                            <xsl:apply-templates select="ancestor::tei:div[@type = 'section']/tei:head" mode="m_plain-text"/>
                        </xsl:variable>
                        <xsl:value-of select="normalize-space($v_plain)"/>
                        <xsl:text>: </xsl:text>
                    </xsl:if>
                    <xsl:variable name="v_plain">
                        <xsl:apply-templates select="tei:head" mode="m_plain-text"/>
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
                                    <xsl:apply-templates select="." mode="m_plain-text"/>
                                </xsl:variable>
                                <xsl:value-of select="normalize-space($v_plain)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="position()!=last()">
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
                <xsl:value-of select="count(descendant::tei:pb[@ed='print'])+1"/>
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
    
    <!-- plain text mode -->
    <!-- plain text -->
    <xsl:template match="text()" mode="m_plain-text">
        <!-- in many instances adding whitespace before and after a text() node makes a lot of sense -->
        <xsl:text> </xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:text> </xsl:text>
    </xsl:template>
    <!-- replace page breaks with tokens that can be used for string split -->
    <xsl:template match="tei:pb[@ed='print']" mode="m_plain-text">
        <xsl:text>$pb</xsl:text><xsl:value-of select="@n"/><xsl:text>$</xsl:text>
    </xsl:template>
    <!-- editorial interventions -->
    <!-- remove all interventions from shamela.ws -->
    <xsl:template match="node()[@resp='#org_MS']" mode="m_plain-text"/>
    <!-- editorial corrections with choice: original mistakes are encoded as <sic> or <orig>, corrections as <corr> -->
    <xsl:template match="tei:choice" mode="m_plain-text">
        <xsl:apply-templates select="node()[not(self::tei:corr)]" mode="m_plain-text"/>
    </xsl:template>
    
</xsl:stylesheet>
