<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:mods="http://www.loc.gov/mods/v3" xmlns:oape="https://openarabicpe.github.io/ns"
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
    <xsl:include href="oape-xml-to-json.xsl"/>
    
    <!-- this defines the master files for entities; default is '../../authority-files/tei/entities_master.TEIP5.xml'; other options include ../../digital-mawaqif/tei/entities_master.TEIP5.xml -->
    <xsl:param name="p_file-entities-master" select="doc('../../authority-files/tei/entities_master.TEIP5.xml')"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="modsCollection">
        <xsl:variable name="v_id-file" select="replace(base-uri(), '.*(oclc_\d+)(-i_\d+)?.*', '$1$2')"/>
        <xsl:variable name="v_array-result">
            <oape:array>
                <!-- group by author: check if viaf references are available -->
                <xsl:for-each-group select="mods"
                    group-by="if(descendant::name[role/roleTerm[@authority = 'marcrelator'] = 'aut']/@authority='viaf') then(descendant::name[role/roleTerm[@authority = 'marcrelator'] = 'aut']/@valueURI) else(descendant::name[role/roleTerm[@authority = 'marcrelator'] = 'aut'])">
                    <xsl:sort select="current-group()[1]/descendant::name[1]"/>
                    <!-- VIAF ID of authors: if present this is the current-grouping-key(). this can be used for querying $p_file-entities-master for additional information -->
                    <xsl:variable name="v_id-viaf" select="substring-after(current-grouping-key(),'https://viaf.org/viaf/')"/>
                    <xsl:variable name="v_person-author"  select="$p_file-entities-master//tei:person[tei:idno[@type='VIAF']=$v_id-viaf]"/>
                    
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
                    <oape:object>
                        <oape:item>
                            <oape:key>name</oape:key>
                            <oape:value>
                                <xsl:value-of select="normalize-space($v_author)"/>
                            </oape:value>
                        </oape:item>
                        <oape:item>
                            <oape:key>viaf</oape:key>
                            <oape:value>
                                <xsl:value-of select="normalize-space($v_id-viaf)"/>
                            </oape:value>
                        </oape:item>
                        <!-- articles -->
                        <oape:array>
                            <oape:key>articles</oape:key>
                            <oape:object>
                                <oape:item>
                                    <oape:key>total</oape:key>
                                    <oape:value>
                                        <xsl:value-of select="number(count(current-group()))"/>
                                    </oape:value>
                                </oape:item>
                            </oape:object>
                            <!-- articles etc. per year -->
                            <xsl:for-each-group select="current-group()" group-by="substring((descendant::dateIssued[@encoding = 'w3cdtf']), 1, 4)">
                                <xsl:sort select="current-grouping-key()"/>
                                <!-- generate number of pages -->
                                <xsl:variable name="v_pages">
                                    <oape:object>
                                        <xsl:for-each select="current-group()/descendant-or-self::mods">
                                            <xsl:if test="descendant::extent[@unit='pages']/end!=''">
                                            <oape:item>
                                                <oape:key>pages</oape:key>
                                                <oape:value>
                                                    <xsl:value-of select="descendant::extent[@unit='pages']/end - descendant::extent[@unit='pages']/start +1"/>
                                                </oape:value>
                                            </oape:item>
                                            </xsl:if>
                                        </xsl:for-each>
                                    </oape:object>
                                </xsl:variable>
                                <xsl:variable name="v_urls">
                                    <oape:array>
                                        <oape:key>urls</oape:key>
                                        <xsl:for-each select="current-group()/descendant-or-self::mods">
                                            <oape:value><xsl:value-of select="descendant::location/url"/></oape:value>
                                        </xsl:for-each>
                                    </oape:array>
                                </xsl:variable>
                                <!-- age of author at publication -->
                                <xsl:variable name="v_age-author">
                                    <xsl:choose>
                                        <xsl:when test="number($v_person-author//tei:death[1]/@when) - number(current-grouping-key()) &lt; 0">
                                            <xsl:text>dead</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="$v_person-author//tei:birth[1]/@when">
                                            <xsl:value-of select=" number(current-grouping-key())- number(substring($v_person-author//tei:birth[1]/@when,1,4))"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>unknown</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <oape:object>
                                    <oape:item>
                                        <oape:key>year</oape:key>
                                        <oape:value>
                                            <xsl:value-of select="current-grouping-key()"/>
                                        </oape:value>
                                    </oape:item>
                                    <!-- age at publication -->
                                    <oape:item>
                                        <oape:key>age</oape:key>
                                        <oape:value>
                                            <xsl:value-of select="$v_age-author"/>
                                        </oape:value>
                                    </oape:item>
                                    <!-- articles per year -->
                                    <oape:item>
                                        <oape:key>articles</oape:key>
                                        <oape:value>
                                            <xsl:value-of select="number(count(current-group()))"/>
                                        </oape:value>
                                    </oape:item>
                                    <!-- pages per year -->
                                    <oape:item>
                                        <oape:key>pages</oape:key>
                                        <oape:value><xsl:value-of select="sum($v_pages/descendant::oape:value)"/>
<!--                                        <xsl:copy-of select="$v_pages"/>-->
                                        </oape:value>
                                    </oape:item>
                                    <!-- URLs to articles -->
                                    <xsl:copy-of select="$v_urls"></xsl:copy-of>
                                </oape:object>
                            </xsl:for-each-group>
                        </oape:array>
                    </oape:object>
                </xsl:for-each-group>
            </oape:array>
        </xsl:variable>
        <!-- JSON -->
        <xsl:result-document href="../statistics/{$v_id-file}-stats_mods.json" format="text">
            <xsl:text>[</xsl:text>
            <xsl:apply-templates
                select="$v_array-result/descendant::oape:object[oape:item/oape:key/text() = 'name']"
                mode="m_oap-to-json">
                <xsl:sort
                    select="descendant::oape:key[text() = 'total']/following-sibling::oape:value"
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
