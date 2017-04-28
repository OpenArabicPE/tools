<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:oap="https://openarabicpe.github.io/ns" xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0">

    <xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no" name="xml"/>
    <xsl:output method="text" indent="yes" encoding="UTF-8" omit-xml-declaration="yes" name="text"/>

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet produces a number of statistics such as word counts, character counts etc. Input are TEI XML files.</xd:p>
        </xd:desc>
    </xd:doc>

    <!-- include plain text functions -->
    <xsl:include href="https://rawgit.com/OpenArabicPE/convert_tei-to-markdown/master/xslt/Tei2Md-functions.xsl"/>

    <!-- include translator for JSON -->
    <xsl:include href="oap-xml-to-json.xsl"/>
    <!-- include translator for CSV -->
    <xsl:include href="oap-xml-to-csv.xsl"/>

    <xsl:template match="tei:TEI">
        <xsl:apply-templates select="descendant::tei:text"/>
    </xsl:template>

    <xsl:template match="tei:text">
        <!-- variables -->
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
            <oap:array>
                <xsl:for-each
                    select="$v_articles-independent/descendant-or-self::tei:div[@type = 'article']">
                    <xsl:variable name="v_plain-text">
                        <xsl:apply-templates select="." mode="mPlainText"/>
                    </xsl:variable>
                    <oap:item>
                        <oap:key>number of characters</oap:key>
                        <oap:value>
                            <xsl:value-of
                                select="number(string-length(replace($v_plain-text, '\W', '')))"/>
                        </oap:value>
                    </oap:item>
                </xsl:for-each>
            </oap:array>
        </xsl:variable>
        <xsl:variable name="v_count-characters-articles-in-sections">
            <oap:array>
                <xsl:for-each
                    select="$v_articles-in-sections/descendant-or-self::tei:div[@type = 'article']">
                    <xsl:variable name="v_plain-text">
                        <xsl:apply-templates select="." mode="mPlainText"/>
                    </xsl:variable>
                    <oap:item>
                        <oap:key>number of characters</oap:key>
                        <oap:value>
                            <xsl:value-of
                                select="number(string-length(replace($v_plain-text, '\W', '')))"/>
                        </oap:value>
                    </oap:item>
                </xsl:for-each>
            </oap:array>
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
            <oap:array>
                <xsl:for-each
                    select="$v_articles-independent/descendant-or-self::tei:div[@type = 'article']">
                    <oap:item>
                        <oap:key>number of words</oap:key>
                        <oap:value>
                            <xsl:call-template name="t_count-words">
                                <xsl:with-param name="p_input" select="."/>
                            </xsl:call-template>
                        </oap:value>
                    </oap:item>
                </xsl:for-each>
            </oap:array>
        </xsl:variable>
        <xsl:variable name="v_count-words-articles-in-sections">
            <oap:array>
                <xsl:for-each
                    select="$v_articles-in-sections/descendant-or-self::tei:div[@type = 'article']">
                    <oap:item>
                        <oap:key>number of words</oap:key>
                        <oap:value>
                            <xsl:call-template name="t_count-words">
                                <xsl:with-param name="p_input" select="."/>
                            </xsl:call-template>
                        </oap:value>
                    </oap:item>
                </xsl:for-each>
            </oap:array>
        </xsl:variable>
        <xsl:variable name="v_url-mods"
            select="concat('../metadata/', ancestor::tei:TEI/@xml:id, '.MODS.xml')"/>
        <!-- output -->
        <xsl:variable name="v_array-result">
            <oap:array xml:id="{@xml:id}-stats">
                <oap:object>
                    <oap:item>
                        <oap:key>MODS</oap:key>
                        <oap:value>
                            <xsl:value-of select="$v_url-mods"/>
                        </oap:value>
                    </oap:item>
                    <oap:item>
                        <oap:key>number of pages</oap:key>
                        <oap:value>
                            <xsl:value-of select="$v_count-pages-all"/>
                        </oap:value>
                    </oap:item>
                    <oap:item>
                        <oap:key>number of words</oap:key>
                        <oap:value>
                            <xsl:value-of select="$v_count-words-all"/>
                        </oap:value>
                    </oap:item>
                    <oap:item>
                        <oap:key>number of articles</oap:key>
                        <oap:value>
                            <xsl:value-of select="$v_count-articles-all"/>
                        </oap:value>
                    </oap:item>
                    <oap:item>
                        <oap:key>words per article</oap:key>
                        <oap:value>
                            <xsl:value-of select="$v_count-words-all div $v_count-articles-all"/>
                        </oap:value>
                    </oap:item>
                    <oap:item>
                        <oap:key>number of independent articles</oap:key>
                        <oap:value>
                            <xsl:value-of select="$v_count-articles-independent"/>
                        </oap:value>
                    </oap:item>
                    <oap:item>
                        <oap:key>words per independent article</oap:key>
                        <oap:value>
                            <xsl:value-of
                                select="sum($v_count-words-articles-independent/descendant::oap:value) div $v_count-articles-independent"
                            />
                        </oap:value>
                    </oap:item>
                    <oap:item>
                        <oap:key>characters per independent article</oap:key>
                        <oap:value>
                            <xsl:value-of
                                select="sum($v_count-characters-articles-independent/descendant::oap:value) div $v_count-articles-independent"
                            />
                        </oap:value>
                    </oap:item>
                    <oap:item>
                        <oap:key>number of independent articles with author information</oap:key>
                        <oap:value>
                            <xsl:value-of select="$v_count-articles-independent-authors"/>
                        </oap:value>
                    </oap:item>
                    <oap:item>
                        <oap:key>number of articles in sections</oap:key>
                        <oap:value>
                            <xsl:value-of select="$v_count-articles-in-sections"/>
                        </oap:value>
                    </oap:item>
                    <oap:item>
                        <oap:key>words per article in sections</oap:key>
                        <oap:value>
                            <xsl:value-of
                                select="sum($v_count-words-articles-in-sections/descendant::oap:value) div $v_count-articles-in-sections"
                            />
                        </oap:value>
                    </oap:item>
                    <oap:item>
                        <oap:key>characters per article in sections</oap:key>
                        <oap:value>
                            <xsl:value-of
                                select="sum($v_count-characters-articles-in-sections/descendant::oap:value) div $v_count-articles-in-sections"
                            />
                        </oap:value>
                    </oap:item>
                </oap:object>
            </oap:array>
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

    <!-- count characters -->

</xsl:stylesheet>
