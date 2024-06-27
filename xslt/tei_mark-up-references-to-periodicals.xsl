<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs" version="3.0" xmlns="http://www.tei-c.org/ns/1.0" xmlns:oape="https://openarabicpe.github.io/ns" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:output encoding="UTF-8" indent="no" method="xml" omit-xml-declaration="no" version="1.0"/>
    <!-- this stylesheet wraps references to periodical titles that start with *jarīda* or *majalla* in a <bibl> and <title> tag  -->
    <!-- NOTE: as always, this doesn't work with mixed-content nodes, such as a <p> interspersed with milestone elements, such as <lb/> -->
    <!-- Problems:
       - titles that do not start with "al-" are not caught
   -->
    <xsl:include href="../../authority-files/xslt/functions.xsl"/>
    <!-- reproduce everything as is -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()[ancestor::tei:text][not(ancestor::tei:title | ancestor::tei:bibl)]">
        <xsl:copy-of select="oape:find-references-to-periodicals(.)"/>
    </xsl:template>
    <!-- dealing with milestones -->
    <xsl:template match="*[text()[not(matches(., '^\s*$'))]][tei:pb | tei:cb | tei:lb]">
        <xsl:variable name="v_preprocessed" select="oape:milestones-to-table(.)"/>
        <xsl:message>
            <xsl:text>$v_preprocessed: </xsl:text>
            <xsl:copy-of select="$v_preprocessed"/>
        </xsl:message>
        <xsl:variable name="v_compiled-text">
            <xsl:value-of select="$v_preprocessed/descendant::tei:cell[@n = 'text']"/>
        </xsl:variable>
        <xsl:message>
            <xsl:text>$v_compiled-text: </xsl:text>
            <xsl:copy-of select="$v_compiled-text"/>
        </xsl:message>
        <xsl:variable name="v_marked-up" select="oape:find-references-to-periodicals($v_compiled-text)"/>
        <xsl:message>
            <xsl:text>$v_marked-up: </xsl:text>
            <xsl:copy-of select="$v_marked-up"/>
        </xsl:message>
        <xsl:copy>
            <xsl:apply-templates mode="m_identity-transform" select="@*"/>
            <xsl:copy-of select="$v_marked-up"/>
        </xsl:copy>
        <!-- debugging -->
        <xsl:copy>
            <xsl:apply-templates mode="m_identity-transform" select="@*"/>
            <xsl:copy-of select="$v_preprocessed"/>
        </xsl:copy>
        <xsl:copy>
            <xsl:apply-templates mode="m_identity-transform" select="@*"/>
            <xsl:copy-of select="$v_compiled-text"/>
        </xsl:copy>
    </xsl:template>
    <!-- simple wrapper function. Output is a simple TEI table with three columns -->
    <xsl:function name="oape:milestones-to-table">
        <xsl:param name="p_node"/>
        <xsl:choose>
            <xsl:when test="$p_node[text()] and $p_node[tei:pb | tei:cb | tei:lb]">
                <table>
                    <xsl:apply-templates mode="m_preprocess-milestones" select="$p_node"/>
                </table>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'NA'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:template name="t_text-milestones">
        <xsl:param name="p_text"/>
        <xsl:param name="p_milestone" select="$p_text/following-sibling::node()[1][local-name() = ('pb', 'cb', 'lb')]"/>
        <xsl:variable name="v_text" select="$p_text/text()"/>
        <!-- some way of providing the position of the milestone -->
        <!-- could also be: string-length($p_text) -->
        <xsl:variable name="v_position-milestone" select="count(tokenize($v_text, '[\W]+'))"/>
        <!--<xsl:if test="$v_string-length gt 0">-->
        <row>
            <cell n="text">
                <xsl:copy-of select="$p_text"/>
            </cell>
            <cell n="index">
                <xsl:value-of select="$v_position-milestone"/>
            </cell>
            <cell n="milestone">
                <xsl:copy-of select="$p_milestone"/>
            </cell>
        </row>
        <!--</xsl:if>-->
    </xsl:template>
    <xsl:template match="node() | @*" mode="m_preprocess-milestones">
        <xsl:copy>
            <xsl:apply-templates mode="m_preprocess-milestones" select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()" mode="m_preprocess-milestones">
        <xsl:call-template name="t_text-milestones">
            <xsl:with-param name="p_text" select="."/>
            <xsl:with-param name="p_milestone" select="''"/>
        </xsl:call-template>
    </xsl:template>
    <!-- preprocess nodes with text and milestone children and nothing else! -->
    <xsl:template match="node()[text()][tei:pb | tei:cb | tei:lb]" mode="m_preprocess-milestones">
        <xsl:variable name="v_current-name" select="name()"/>
        <xsl:choose>
            <xsl:when test="element()[not(local-name() = ('pb', 'cb', 'lb'))]">
                <xsl:for-each-group group-starting-with="self::element()[not(local-name() = ('pb', 'cb', 'lb'))]" select="node()">
                    <xsl:variable name="v_current-group">
                        <xsl:element name="{$v_current-name}">
                            <xsl:copy-of select="current-group()[position() != 1]"/>
                        </xsl:element>
                    </xsl:variable>
                    <xsl:copy-of select="current-group()[position() = 1]"/>
                    <xsl:apply-templates mode="m_preprocess-milestones" select="$v_current-group/node()"/>
                    <!-- this indicates that this approach should be working -->
                    <xsl:message>
                        <xsl:copy-of select="$v_current-group/node()"/>
                    </xsl:message>
                </xsl:for-each-group>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="t_text-milestones">
                    <xsl:with-param name="p_text" select="node()[local-name() = ('pb', 'cb', 'lb')][1]/preceding-sibling::node()"/>
                    <xsl:with-param name="p_milestone" select="node()[local-name() = ('pb', 'cb', 'lb')][1]"/>
                </xsl:call-template>
                <!-- I have to continue with the rest of element - I store it into another variable 
            an encapsulate it with the element of the same name. Then it is processing
            in standard way. -->
                <xsl:variable name="v_remainder">
                    <xsl:element name="{$v_current-name}">
                        <xsl:copy-of select="node()[local-name() = ('pb', 'cb', 'lb')][1]/following-sibling::node()"/>
                    </xsl:element>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$v_remainder/node()/node()[local-name() = ('pb', 'cb', 'lb')]">
                        <xsl:apply-templates mode="m_preprocess-milestones" select="$v_remainder"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="t_text-milestones">
                            <xsl:with-param name="p_text" select="$v_remainder/node()/node()"/>
                            <xsl:with-param name="p_milestone" select="''"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- generate documentation of change -->
    <xsl:template match="tei:revisionDesc">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="tei:change">
                <xsl:attribute name="when" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
                <xsl:attribute name="who" select="concat('#', $p_id-editor)"/>
                <xsl:attribute name="xml:lang" select="'en'"/>
                <xsl:text>Automatically marked up references to periodicals with </xsl:text>
                <tag>bibl type="periodical"</tag>
                <xsl:text> and </xsl:text>
                <tag>title level="j"</tag>
                <xsl:text>.</xsl:text>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
