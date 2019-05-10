<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs" version="3.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output encoding="UTF-8" indent="no" method="xml" omit-xml-declaration="no" version="1.0"/>
    <!-- identify the author of the change by means of a @xml:id -->
    <!--    <xsl:param name="p_id-editor" select="'pers_TG'"/>-->
    <xsl:include href="../../oxygen-project/OpenArabicPE_parameters.xsl"/>
    <xsl:param name="p_string-length" select="30"/>
    <!-- reproduce everything as is -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template
        match="tei:div[@type = 'section'][not(ancestor::tei:div[@type = ('article', 'item')])]">
        <xsl:if test="$p_verbose = true()">
            <xsl:message>
                <xsl:text>Found a section div</xsl:text>
            </xsl:message>
        </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <!-- code for Lughat al-ʿArab -->
                <xsl:when test="tei:p[tei:hi[@style = 'color:red;']]">
                    <xsl:if test="$p_verbose = true()">
                        <xsl:message>
                            <xsl:text>Found p children that begin with a hi</xsl:text>
                        </xsl:message>
                    </xsl:if>
                    <!-- reproduce head of the section -->
                    <xsl:apply-templates select="tei:head"/>
                    <xsl:for-each-group group-starting-with=".[tei:hi[@style = 'color:red;']]"
                        select="node()">
                        <xsl:if test="$p_verbose = true()">
                            <xsl:message>
                                <xsl:text>Create a new div</xsl:text>
                            </xsl:message>
                        </xsl:if>
                        <xsl:element name="tei:div">
                            <xsl:attribute name="type" select="'item'"/>
                            <xsl:attribute name="change" select="concat('#', $p_id-change)"/>
                            <!-- head -->
                            <xsl:apply-templates select="current-group()/descendant-or-self::tei:p[tei:hi[@style = 'color:red;']]" mode="m_convert-p-to-head"/>
                            <!-- content of div: supress duplicate output of the first p child -->
                            <xsl:apply-templates select="current-group()[not(descendant-or-self::tei:p[tei:hi[@style = 'color:red;']])]"/>
                        </xsl:element>
                    </xsl:for-each-group>
                </xsl:when>
                <xsl:when
                    test="tei:p[string-length(replace(., '\W', '')) &lt;= $p_string-length][1][preceding-sibling::tei:head]">
                    <xsl:if test="$p_verbose = true()">
                        <xsl:message>
                            <xsl:text>Found short p immediately after the head</xsl:text>
                        </xsl:message>
                    </xsl:if>
                    <xsl:apply-templates select="tei:head"/>
                    <!-- assume that the first paragraph is also a short one -->
                    <xsl:apply-templates mode="m_group-divs"
                        select="tei:p[string-length(replace(., '\W', '')) &lt;= $p_string-length][1]"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:p" mode="m_convert-p-to-head">
        <xsl:element name="tei:head">
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="change" select="concat(@change, ' #', $p_id-change)"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:p[string-length(replace(., '\W', '')) &lt;= $p_string-length]"
        mode="m_group-divs">
        <!--<xsl:message>
            <xsl:value-of select="."/>
        </xsl:message>-->
        <xsl:element name="tei:div">
            <xsl:attribute name="type" select="'item'"/>
            <xsl:attribute name="subtype" select="'article'"/>
            <xsl:attribute name="change" select="concat('#', $p_id-change)"/>
            <xsl:element name="tei:head">
                <xsl:attribute name="change" select="concat('#', $p_id-change)"/>
                <xsl:apply-templates/>
            </xsl:element>
            <!-- following paragraphs until the next the next short paragraph. In case there is no following short paragraph everything should be reproduced -->
            <!--            <xsl:apply-templates select="following-sibling::node()[. &lt;&lt; current()/following-sibling::tei:p[string-length( replace(.,'\W','')) &lt;= $p_string-length][1]]"/>-->
            <xsl:apply-templates
                select="
                    if (following-sibling::tei:p[string-length(replace(., '\W', '')) &lt;= $p_string-length][1]) then
                        (following-sibling::node()[. &lt;&lt; current()/following-sibling::tei:p[string-length(replace(., '\W', '')) &lt;= $p_string-length][1]])
                    else
                        (following-sibling::node())"
            />
        </xsl:element>
        <!-- go to the next article -->
        <xsl:apply-templates mode="m_group-divs"
            select="following-sibling::tei:p[string-length(replace(., '\W', '')) &lt;= $p_string-length][1]"
        />
    </xsl:template>
    <!-- generate documentation of change -->
    <xsl:template match="tei:revisionDesc">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="tei:change">
                <xsl:attribute name="when"
                    select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
                <xsl:attribute name="who" select="concat('#', $p_id-editor)"/>
                <xsl:attribute name="xml:lang" select="'en'"/>
                <xsl:attribute name="xml:id" select="$p_id-change"/>
                <xsl:text>Automatically split all </xsl:text>
                <tei:tag>div type="section"</tei:tag>
                <xsl:text> into subsections of </xsl:text>
                <tei:tag>div type="article"</tei:tag>
                <xsl:text>, using paragraphs with a length of </xsl:text>
                <xsl:value-of select="$p_string-length"/>
                <xsl:text> or less as indicator of a heading.</xsl:text>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
