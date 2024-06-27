<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs" version="3.0" xmlns="http://www.tei-c.org/ns/1.0" xmlns:oape="https://openarabicpe.github.io/ns" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:output encoding="UTF-8" indent="no" method="xml" omit-xml-declaration="no" version="1.0"/>
    <!-- this stylesheet wraps references to periodical titles that start with *jarīda* or *majalla* in a <bibl> and <title> tag  -->
    <!-- NOTE: as always, this doesn't work with mixed-content nodes, such as a <p> interspersed with milestone elements, such as <lb/> -->
    <xsl:include href="../../authority-files/xslt/functions.xsl"/>
    <!-- reproduce everything as is -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- 
        1. find mixed-content nodes with milestones in them
    -->
    <xsl:template match="node()[child::text()[not(matches(., '^\s*$'))] and child::element()[not(child::text())]]">
        <xsl:message>
            <xsl:text>mixed-content node with milestones</xsl:text>
        </xsl:message>
        <!-- reproduce the element -->
        <xsl:copy>
            <!-- reproduce the attributes -->
            <xsl:apply-templates mode="m_identity-transform" select="@*"/>
            <!-- 
        2. check if they also contain other child nodes
    -->
            <xsl:apply-templates mode="m_milestones-only" select="."/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="node()[child::text()[not(matches(., '^\s*$'))] and child::element()[not(child::text())]]" mode="m_milestones-only">
        <xsl:message>
            <xsl:text>preprocessed mixed-content node with milestones</xsl:text>
        </xsl:message>
        <!-- 
        2. check if they also contain other child nodes
    -->
        <xsl:choose>
            <xsl:when test="child::element()/text()[not(matches(., '^\s*$'))]">
                <xsl:message>
                    <xsl:text>contains non-milestone child nodes</xsl:text>
                </xsl:message>
                <!-- 3. if so split them along the non-milestone children -->
                <xsl:variable name="v_current-name" select="name()"/>
                <xsl:for-each-group group-ending-with="self::element()[text()[not(matches(., '^\s*$'))]]" select="child::node()">
                    <xsl:message>
                        <xsl:text>group starting with non-milestone element</xsl:text>
                    </xsl:message>
                    <!-- construct a new node -->
                    <xsl:variable name="v_group">
                        <xsl:element name="{$v_current-name}">
                            <xsl:copy-of select="current-group()[position() != last()]"/>
                        </xsl:element>
                    </xsl:variable>
                    <xsl:apply-templates mode="m_milestones-only" select="$v_group"/>
                    <xsl:apply-templates select="current-group()[last()]"/>
                </xsl:for-each-group>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>
                    <xsl:text>contains only milestone child nodes</xsl:text>
                </xsl:message>
                <!-- 4. pre-process the resulting mixed-content nodes -->
                <xsl:copy-of select="oape:milestones-to-table(.)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- simple wrapper function. Output is a simple TEI table with three columns -->
    <xsl:function name="oape:milestones-to-table">
        <xsl:param name="p_node"/>
        <xsl:choose>
            <xsl:when test="$p_node[text()] and $p_node[child::element()[not(child::text())]]">
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
        <xsl:param name="p_milestone"/>
        <xsl:variable name="v_text">
            <xsl:copy-of select="$p_text/descendant-or-self::text()"/>
        </xsl:variable>
        <!-- some way of providing the position of the milestone -->
        <!-- could also be: string-length($p_text) -->
        <xsl:variable name="v_position-milestone" select="count(tokenize($v_text, '[\W]+'))"/>
        <!--<xsl:if test="$v_string-length gt 0">-->
        <row>
            <cell n="text">
                <xsl:copy-of select="$p_text"/>
            </cell>
            <cell n="index">
<!--                <xsl:if test="exists($p_milestone)">-->
                    <xsl:value-of select="$v_position-milestone"/>
                <!--</xsl:if>-->
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
    <xsl:template match="node()[text()][child::element()[not(child::text())]]" mode="m_preprocess-milestones">
        <xsl:variable name="v_current-name" select="name()"/>
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
    </xsl:template>
</xsl:stylesheet>
