<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:mods="http://www.loc.gov/mods/v3" xmlns:oap="https://openarape.github.io/ns"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xpath-default-namespace="http://www.loc.gov/mods/v3" exclude-result-prefixes="xs xd"
    version="2.0">

    <xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no" name="xml"/>
    <xsl:output method="text" indent="yes" encoding="UTF-8" omit-xml-declaration="yes" name="text"/>

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet produces a number of statistics such as word counts, character counts etc. Input are MODS XML files.</xd:p>
        </xd:desc>
    </xd:doc>

    <!-- include translator for JSON -->
    <xsl:include href="oap-xml-to-json.xsl"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="modsCollection">
        <xsl:variable name="v_id-file" select="replace(base-uri(), '.*(oclc_\d+).*', '$1')"/>
        <xsl:variable name="v_array-result">
            <oap:array>
                <xsl:for-each-group select="mods"
                    group-by="descendant::name[role/roleTerm[@authority = 'marcrelator'] = 'aut']">
                    <xsl:sort select="current-group()[1]/descendant::name[1]"/>
                    <!-- generate author names -->
                    <xsl:variable name="v_author">
                        <xsl:for-each select="current-group()[1]/descendant::name[1]/namePart[@type = 'given']">
                            <xsl:value-of select="."/>
                            <xsl:if test="not(position() = last())">
                                <xsl:text> </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="current-group()[1]/descendant::name[1]/namePart[@type = 'family']"/>
                    </xsl:variable>
                    <oap:object>
                        <oap:item>
                            <oap:key>name</oap:key>
                            <oap:value>
                                <xsl:value-of select="normalize-space($v_author)"/>
                            </oap:value>
                        </oap:item>
                        <!-- articles -->
                        <oap:array>
                            <oap:key>articles</oap:key>
                            <oap:object>
                                <oap:item>
                                    <oap:key>total</oap:key>
                                    <oap:value>
                                        <xsl:value-of select="number(count(current-group()))"/>
                                    </oap:value>
                                </oap:item>
                            </oap:object>
                            <!-- articles etc. per year -->
                            <xsl:for-each-group select="current-group()" group-by="substring((descendant::dateIssued[@encoding = 'w3cdtf']), 1, 4)">
                                <xsl:sort select="current-grouping-key()"/>
                                <!-- generate number of pages -->
                                <xsl:variable name="v_pages">
                                    <oap:object>
                                        <xsl:for-each select="current-group()/descendant-or-self::mods">
                                            <xsl:if test="descendant::extent[@unit='pages']/end!=''">
                                            <oap:item>
                                                <oap:key>pages</oap:key>
                                                <oap:value>
                                                    <xsl:value-of select="descendant::extent[@unit='pages']/end - descendant::extent[@unit='pages']/start +1"/>
                                                </oap:value>
                                            </oap:item>
                                            </xsl:if>
                                        </xsl:for-each>
                                    </oap:object>
                                </xsl:variable>
                                <xsl:variable name="v_urls">
                                    <oap:array>
                                        <oap:key>urls</oap:key>
                                        <xsl:for-each select="current-group()/descendant-or-self::mods">
                                            <oap:value><xsl:value-of select="descendant::location/url"/></oap:value>
                                        </xsl:for-each>
                                    </oap:array>
                                </xsl:variable>
                                <oap:object>
                                    <oap:item>
                                        <oap:key>year</oap:key>
                                        <oap:value>
                                            <xsl:value-of select="current-grouping-key()"/>
                                        </oap:value>
                                    </oap:item>
                                    <!-- articles per year -->
                                    <oap:item>
                                        <oap:key>articles</oap:key>
                                        <oap:value>
                                            <xsl:value-of select="number(count(current-group()))"/>
                                        </oap:value>
                                    </oap:item>
                                    <!-- pages per year -->
                                    <oap:item>
                                        <oap:key>pages</oap:key>
                                        <oap:value><xsl:value-of select="sum($v_pages/descendant::oap:value)"/>
<!--                                        <xsl:copy-of select="$v_pages"/>-->
                                        </oap:value>
                                    </oap:item>
                                    <!-- URLs to articles -->
                                    <xsl:copy-of select="$v_urls"></xsl:copy-of>
                                </oap:object>
                            </xsl:for-each-group>
                        </oap:array>
                    </oap:object>
                </xsl:for-each-group>
            </oap:array>
        </xsl:variable>
        <!-- JSON -->
        <xsl:result-document href="../statistics/{$v_id-file}-stats_mods.json" format="text">
            <xsl:text>[</xsl:text>
            <xsl:apply-templates
                select="$v_array-result/descendant::oap:object[oap:item/oap:key/text() = 'name']"
                mode="m_oap-to-json">
                <xsl:sort
                    select="descendant::oap:key[text() = 'total']/following-sibling::oap:value"
                    order="descending" data-type="number"/>
            </xsl:apply-templates>
            <xsl:text>]</xsl:text>
        </xsl:result-document>
        <!-- custom XML -->
        <xsl:result-document href="../statistics/{$v_id-file}-stats_mods.xml" format="xml">
            <!-- provide styling that looks like JSON -->
            <xsl:value-of
                select="'&lt;?xml-stylesheet type=&quot;text/css&quot; href=&quot;../css/statistics.css&quot;?>'"
                disable-output-escaping="yes"/>
            <xsl:copy-of select="$v_array-result"/>
        </xsl:result-document>
    </xsl:template>

</xsl:stylesheet>
