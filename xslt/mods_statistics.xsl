<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:oap="https://openarape.github.io/ns"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xpath-default-namespace="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xs xd"
    version="2.0">
    
    <xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no" name="xml"/>
    <xsl:output method="text" indent="yes" encoding="UTF-8" omit-xml-declaration="yes" name="text"/>
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet produces a number of statistics such as word counts, character counts etc. Input are TEI XML files.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- include translator for JSON -->
    <xsl:include href="oap-xml-to-json.xsl"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="modsCollection">
        <xsl:variable name="v_array-result">
            <oap:array>
                <xsl:for-each-group select="mods" group-by="descendant::name[role/roleTerm[@authority='marcrelator']='aut']">
                    <xsl:sort select="current-group()[1]/descendant::name[1]"/>
                    <!-- generate author names -->
                    <xsl:variable name="v_author">
                        <xsl:for-each select="current-group()[1]/descendant::name[1]/namePart[@type='given']">
                            <xsl:value-of select="."/>
                            <xsl:if test="not(position()=last())">
                                <xsl:text> </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="current-group()[1]/descendant::name[1]/namePart[@type='family']"/>
                    </xsl:variable>
                    <oap:object>
                        <oap:item>
                            <oap:key>name</oap:key>
                            <oap:value>
                                <xsl:value-of select="normalize-space($v_author)"/>
                            </oap:value>
                        </oap:item>
                        <!-- articles per year -->
                        <oap:array>
                            <oap:key>articles</oap:key>
                            <oap:object>
                                <oap:item>
                                    <oap:key>total</oap:key>
                                    <oap:value><xsl:value-of select="number(count(current-group()))"/></oap:value>
                                </oap:item>
                            </oap:object>
                                
                            <xsl:for-each-group select="current-group()" group-by="year-from-date(descendant::dateIssued[@encoding='w3cdtf'])">
       <oap:object>                         
                                    <oap:item><oap:key>year</oap:key>
                                        <oap:value><xsl:value-of select="current-grouping-key()"/></oap:value></oap:item>
                                    <oap:item><oap:key>number of articles</oap:key>
                                        <oap:value><xsl:value-of select="number(count(current-group()))"/></oap:value></oap:item>
       </oap:object>
                            </xsl:for-each-group>
                        </oap:array>
                    </oap:object>
                </xsl:for-each-group>
            </oap:array>
        </xsl:variable>
        <!-- JSON -->
        <xsl:result-document href="../statistics/{descendant-or-self::modsCollection/@ID}-stats.json" format="text">
            <xsl:apply-templates select="$v_array-result" mode="m_oap-to-json">
            </xsl:apply-templates>
        </xsl:result-document>
        <!-- custom XML -->
        <xsl:result-document href="../statistics/{descendant-or-self::modsCollection/@ID}-stats.xml" format="xml">
        <!-- provide styling that looks like JSON -->
        <xsl:value-of select="'&lt;?xml-stylesheet type=&quot;text/css&quot; href=&quot;../css/statistics.css&quot;?&gt;'" disable-output-escaping="yes"/>
            <xsl:copy-of select="$v_array-result"/>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="oap:array" mode="m_oap-to-json">
        <xsl:apply-templates select="oap:key" mode="m_oap-to-json"/>
        <xsl:text> [</xsl:text>
        <xsl:apply-templates select="node()[not(self::oap:key)]" mode="m_oap-to-json"/>
        <xsl:text>]</xsl:text>
        <xsl:if test="following-sibling::node()">
            <xsl:text>, </xsl:text>
        </xsl:if>
    </xsl:template>
    <xsl:template match="oap:object" mode="m_oap-to-json">
        <xsl:apply-templates select="oap:key" mode="m_oap-to-json"/>
        <xsl:text> {</xsl:text>
        <xsl:apply-templates select="node()[not(self::oap:key)]" mode="m_oap-to-json"/>
        <xsl:text>}</xsl:text>
        <xsl:if test="following-sibling::node()">
            <xsl:text>, </xsl:text>
        </xsl:if>
    </xsl:template>
    <xsl:template match="oap:item" mode="m_oap-to-json">
        <xsl:choose>
            <xsl:when test="@key">
                <xsl:text>"</xsl:text>
                <xsl:apply-templates select="@key" mode="m_oap-to-json"/>
                <xsl:text>": "</xsl:text>
                <xsl:apply-templates mode="m_oap-to-json"/>
                <xsl:text>"</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="m_oap-to-json"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="following-sibling::node()">
            <xsl:text>, </xsl:text>
        </xsl:if>
    </xsl:template>
    <xsl:template match="oap:key" mode="m_oap-to-json">
        <xsl:text>"</xsl:text>
        <xsl:apply-templates mode="m_oap-to-json"/>
        <xsl:text>": </xsl:text>
    </xsl:template>
    <xsl:template match="oap:value" mode="m_oap-to-json">
        <xsl:text>"</xsl:text>
        <xsl:apply-templates mode="m_oap-to-json"/>
        <xsl:text>"</xsl:text>
    </xsl:template>
    
</xsl:stylesheet>