<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:oape="https://openarabicpe.github.io/ns" xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="3.0">

    <xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no" name="xml"/>
    <xsl:output method="text" indent="yes" encoding="UTF-8" omit-xml-declaration="yes" name="text"/>

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet produces a number of statistics such as word counts, character counts etc. Input are TEI XML files.</xd:p>
        </xd:desc>
    </xd:doc>

    <!-- include plain text functions -->
    <xsl:include href="../../convert_tei-to-markdown/xslt/Tei2Md-functions.xsl"/>
<!--    <xsl:include href="https://rawgit.com/OpenArabicPE/convert_tei-to-markdown/master/xslt/Tei2Md-functions.xsl"/>-->

    <!-- include translator for JSON -->
    <xsl:include href="oape-xml-to-json.xsl"/>
    <!-- include translator for CSV -->
    <xsl:include href="oape-xml-to-csv.xsl"/>

    <xsl:template match="tei:TEI">
        <xsl:apply-templates select="descendant::tei:text"/>
    </xsl:template>

    <xsl:template match="tei:text">
        <!-- variables -->
        <xsl:variable name="v_bibl-source" select="ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct"/>
        <xsl:variable name="v_date" select="$v_bibl-source/tei:monogr/tei:imprint/tei:date[1]/@when"/>
        <xsl:variable name="v_volume" select="$v_bibl-source/tei:monogr/tei:biblScope[@unit='volume']/@from"/>
        <xsl:variable name="v_issue" select="$v_bibl-source/tei:monogr/tei:biblScope[@unit='issue']/@from"/>
        <xsl:variable name="v_articles-independent"
            select="descendant::tei:div[@type = 'article'][not(ancestor::tei:div[@type = 'section'])]"/>
        <xsl:variable name="v_articles-independent-authors"
            select="descendant::tei:div[@type = 'article'][not(ancestor::tei:div[@type = 'section'])][tei:byline[descendant::tei:persName]]"/>
        <xsl:variable name="v_articles-in-sections"
            select="descendant::tei:div[@type = 'article'][ancestor::tei:div[@type = 'section']]"/>
        <xsl:variable name="v_count-articles-all"
            select="number(count(descendant::tei:div[@type = 'article']))"/>
        <xsl:variable name="v_count-articles-independent"
            select="number(count($v_articles-independent))"/>
        <xsl:variable name="v_count-articles-independent-authors"
            select="number(count($v_articles-independent-authors))"/>
        <xsl:variable name="v_count-articles-in-sections"
            select="number(count($v_articles-in-sections))"/>
        <xsl:variable name="v_count-characters-articles-independent">
            <oape:array>
                <xsl:for-each
                    select="$v_articles-independent/descendant-or-self::tei:div[@type = 'article']">
                    <oape:item>
                        <oape:key>number of characters</oape:key>
                        <oape:value>
                            <xsl:call-template name="t_count-characters">
                                <xsl:with-param name="p_input" select="."/>
                            </xsl:call-template>
                        </oape:value>
                    </oape:item>
                </xsl:for-each>
            </oape:array>
        </xsl:variable>
        <xsl:variable name="v_count-characters-articles-in-sections">
            <oape:array>
                <xsl:for-each
                    select="$v_articles-in-sections/descendant-or-self::tei:div[@type = 'article']">
                    <oape:item>
                        <oape:key>number of characters</oape:key>
                        <oape:value>
                            <xsl:call-template name="t_count-characters">
                                <xsl:with-param name="p_input" select="."/>
                            </xsl:call-template>
                        </oape:value>
                    </oape:item>
                </xsl:for-each>
            </oape:array>
        </xsl:variable>
        <xsl:variable name="v_count-pages-all">
            <xsl:value-of select="number(count(descendant::tei:pb[@ed = 'print']))"/>
        </xsl:variable>
        <xsl:variable name="v_count-words-all">
            <xsl:call-template name="t_count-words">
                <xsl:with-param name="p_input" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="v_count-words-articles-independent">
            <oape:array>
                <xsl:for-each
                    select="$v_articles-independent/descendant-or-self::tei:div[@type = 'article']">
                    <oape:item>
                        <oape:key>number of words</oape:key>
                        <oape:value>
                            <xsl:call-template name="t_count-words">
                                <xsl:with-param name="p_input" select="."/>
                            </xsl:call-template>
                        </oape:value>
                    </oape:item>
                </xsl:for-each>
            </oape:array>
        </xsl:variable>
        <xsl:variable name="v_count-words-articles-in-sections">
            <oape:array>
                <xsl:for-each
                    select="$v_articles-in-sections/descendant-or-self::tei:div[@type = 'article']">
                    <oape:item>
                        <oape:key>number of words</oape:key>
                        <oape:value>
                            <xsl:call-template name="t_count-words">
                                <xsl:with-param name="p_input" select="."/>
                            </xsl:call-template>
                        </oape:value>
                    </oape:item>
                </xsl:for-each>
            </oape:array>
        </xsl:variable>
        <xsl:variable name="v_url-mods"
            select="concat('../metadata/', ancestor::tei:TEI/@xml:id, '.MODS.xml')"/>
        <!-- output -->
        <xsl:variable name="v_array-result">
            <oape:array xml:id="{@xml:id}-stats">
                <oape:object>
                    <oape:item>
                        <oape:key>date</oape:key>
                        <oape:value><xsl:value-of select="$v_date"/></oape:value>
                    </oape:item>
                    <oape:item>
                        <oape:key>volume</oape:key>
                        <oape:value><xsl:value-of select="$v_volume"/></oape:value>
                    </oape:item>
                    <oape:item>
                        <oape:key>issue</oape:key>
                        <oape:value><xsl:value-of select="$v_issue"/></oape:value>
                    </oape:item>
                    <oape:item>
                        <oape:key>MODS</oape:key>
                        <oape:value>
                            <xsl:value-of select="$v_url-mods"/>
                        </oape:value>
                    </oape:item>
                    <oape:item>
                        <oape:key>number of pages</oape:key>
                        <oape:value>
                            <xsl:value-of select="$v_count-pages-all"/>
                        </oape:value>
                    </oape:item>
                    <oape:item>
                        <oape:key>number of words</oape:key>
                        <oape:value>
                            <xsl:value-of select="$v_count-words-all"/>
                        </oape:value>
                    </oape:item>
                    <oape:item>
                        <oape:key>number of articles</oape:key>
                        <oape:value>
                            <xsl:value-of select="$v_count-articles-all"/>
                        </oape:value>
                    </oape:item>
                    <oape:item>
                        <oape:key>words per article</oape:key>
                        <oape:value>
                            <xsl:value-of select="$v_count-words-all div $v_count-articles-all"/>
                        </oape:value>
                    </oape:item>
                    <oape:item>
                        <oape:key>number of independent articles</oape:key>
                        <oape:value>
                            <xsl:value-of select="$v_count-articles-independent"/>
                        </oape:value>
                    </oape:item>
                    <oape:item>
                        <oape:key>words per independent article</oape:key>
                        <oape:value>
                            <xsl:value-of
                                select="sum($v_count-words-articles-independent/descendant::oape:value) div $v_count-articles-independent"
                            />
                        </oape:value>
                    </oape:item>
                    <oape:item>
                        <oape:key>characters per independent article</oape:key>
                        <oape:value>
                            <xsl:value-of
                                select="sum($v_count-characters-articles-independent/descendant::oape:value) div $v_count-articles-independent"
                            />
                        </oape:value>
                    </oape:item>
                    <oape:item>
                        <oape:key>number of independent articles with author information</oape:key>
                        <oape:value>
                            <xsl:value-of select="$v_count-articles-independent-authors"/>
                        </oape:value>
                    </oape:item>
                    <oape:item>
                        <oape:key>number of articles in sections</oape:key>
                        <oape:value>
                            <xsl:value-of select="$v_count-articles-in-sections"/>
                        </oape:value>
                    </oape:item>
                    <oape:item>
                        <oape:key>words per article in sections</oape:key>
                        <oape:value>
                            <xsl:value-of
                                select="sum($v_count-words-articles-in-sections/descendant::oape:value) div $v_count-articles-in-sections"
                            />
                        </oape:value>
                    </oape:item>
                    <oape:item>
                        <oape:key>characters per article in sections</oape:key>
                        <oape:value>
                            <xsl:value-of
                                select="sum($v_count-characters-articles-in-sections/descendant::oape:value) div $v_count-articles-in-sections"
                            />
                        </oape:value>
                    </oape:item>
                </oape:object>
            </oape:array>
        </xsl:variable>
        <!-- JSON -->
        <xsl:result-document href="../statistics/{ancestor::tei:TEI/@xml:id}-stats_tei.json"
            format="text">
            <xsl:apply-templates select="$v_array-result" mode="m_oap-to-json"/>
        </xsl:result-document>
        <!-- custom XML -->
        <xsl:result-document href="../statistics/{ancestor::tei:TEI/@xml:id}-stats_tei.xml"
            format="xml">
            <!-- provide styling that looks like JSON -->
            <xsl:value-of
                select="'&lt;?xml-stylesheet type=&quot;text/css&quot; href=&quot;../css/statistics.css&quot;?>'"
                disable-output-escaping="yes"/>
            <xsl:copy-of select="$v_array-result"/>
        </xsl:result-document>
        <!-- CSV -->
        <xsl:result-document href="../statistics/{ancestor::tei:TEI/@xml:id}-stats_tei.csv" format="text">
            <xsl:apply-templates select="$v_array-result" mode="m_oap-to-csv"/>
        </xsl:result-document>
    </xsl:template>

    <!-- count words -->
    <xsl:template name="t_count-words">
        <xsl:param name="p_input"/>
        <xsl:value-of select="number(count(tokenize(string($p_input), '\W+')))"/>
    </xsl:template>

    <!-- count characters: output is a number -->
    <xsl:template name="t_count-characters">
        <!-- $p_input accepts xml nodes as input -->
        <xsl:param name="p_input"/>
        <xsl:variable name="v_plain-text">
            <xsl:apply-templates select="$p_input" mode="mPlainText"/>
        </xsl:variable>
        <xsl:value-of select="number(string-length(replace($v_plain-text, '\W', '')))"/>
    </xsl:template>

</xsl:stylesheet>
