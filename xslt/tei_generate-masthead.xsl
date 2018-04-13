<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="xs xd"
    version="2.0">
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet generates the masthead of issues based on the information in the teiHeader</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="xml" omit-xml-declaration="no" indent="no" encoding="UTF-8"/>

<!--    <xsl:include href="https://rawgit.com/tillgrallert/xslt-calendar-conversion/master/date-function.xsl"/>-->
    <xsl:include href="../../../xslt-functions/functions_core.xsl"/>
    
    <!-- identify the author of the change by means of a @xml:id -->
<!--    <xsl:param name="p_id-editor" select="'pers_TG'"/>-->
    <xsl:include href="../../oxygen-project/OpenArabicPE_parameters.xsl"/>
    
    <!-- param to toggle debugging mode -->
    <xsl:param name="p_debug" select="true()"/>
    
    <!-- identity transform -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- generate documentation of change -->
    <xsl:template match="tei:revisionDesc" priority="100">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="change">
                <xsl:attribute name="when" select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>
                <xsl:attribute name="who" select="concat('#',$p_id-editor)"/>
                <xsl:attribute name="xml:id" select="$p_id-change"/>
                <xsl:attribute name="xml:lang" select="'en'"/>
                <xsl:text>Generated a new </xsl:text><tei:gi xml:lang="en">front</tei:gi><xsl:text> based on the </xsl:text><tei:gi xml:lang="en">sourceDesc</tei:gi><xsl:text> that matches the information found in the masthead of the actual issues.</xsl:text>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- document changes on changed elements by means of the @change attribute linking to the @xml:id of the <tei:change> element -->
    <xsl:template match="@change" mode="m_documentation">
        <xsl:attribute name="change">
                    <xsl:value-of select="concat(.,' #',$p_id-change)"/>
        </xsl:attribute>
    </xsl:template>
    
    <!-- set language -->
    <xsl:variable name="v_lang" select="'ar'"/>
    <!-- retrieve bibliographic information from the teiHeader -->
    <xsl:variable name="vBiblSource" select="tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct"/>
    <!-- move the first page break before the <front> -->
    <xsl:template match="tei:text">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:copy-of select="descendant::tei:pb[@ed='print'][1]"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:pb[@ed='print']">
        <!-- supress the first tei:pb in tei:text -->
            <xsl:if test="preceding::tei:pb[@ed='print']">
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:apply-templates select="@change" mode="m_documentation"/>
                </xsl:copy>
            </xsl:if> 
    </xsl:template>

    <!-- generate a new <front> -->
    <xsl:template match="tei:front">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <!-- add documentation of change -->
            <xsl:choose>
                <xsl:when test="not(@change)">
                        <xsl:attribute name="change" select="concat('#',$p_id-change)"/>
                    </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@change" mode="m_documentation"/>
                </xsl:otherwise>
            </xsl:choose>
            <div type="masthead" change="{concat('#',$p_id-change)}">
                <bibl>
                    <xsl:element name="tei:biblScope">
                        <xsl:attribute name="unit" select="'issue'"/>
                        <xsl:attribute name="from" select="$vBiblSource//tei:biblScope[@unit='issue']/@from"/>
                        <xsl:attribute name="to" select="$vBiblSource//tei:biblScope[@unit='issue']/@to"/>
                        <xsl:choose>
                            <xsl:when test="$v_lang = 'ar'">
                                <xsl:text>الجزء </xsl:text>
                            </xsl:when>
                            <xsl:when test="$v_lang = 'en'">
                                <xsl:text>issue </xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>issue </xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                            <xsl:choose>
                                <!-- check for correct encoding of issue information -->
                                <xsl:when test="$vBiblSource//tei:biblScope[@unit = 'issue']/@from = $vBiblSource//tei:biblScope[@unit = 'issue']/@to">
                                    <xsl:value-of select="$vBiblSource//tei:biblScope[@unit = 'issue']/@from"/>
                                </xsl:when>
                                <!-- check for ranges -->
                                <xsl:when test="$vBiblSource//tei:biblScope[@unit = 'issue']/@from != $vBiblSource//tei:biblScope[@unit = 'issue']/@to">
                                    <xsl:value-of select="$vBiblSource//tei:biblScope[@unit = 'issue']/@from"/>
                                    <!-- probably an en-dash is the better option here -->
                                    <xsl:text>/</xsl:text>
                                    <xsl:value-of select="$vBiblSource//tei:biblScope[@unit = 'issue']/@to"/>
                                </xsl:when>
                                <!-- fallback: erroneous encoding of issue information with @n -->
                                <xsl:when test="$vBiblSource//tei:biblScope[@unit = 'issue']/@n">
                                    <xsl:value-of select="$vBiblSource//tei:biblScope[@unit = 'issue']/@n"/>
                                </xsl:when>
                            </xsl:choose>
                    </xsl:element>
                    <xsl:element name="tei:biblScope">
                        <xsl:attribute name="unit" select="'volume'"/>
                        <xsl:attribute name="from" select="$vBiblSource//tei:biblScope[@unit='volume']/@from"/>
                        <xsl:attribute name="to" select="$vBiblSource//tei:biblScope[@unit='volume']/@to"/>
                        <xsl:choose>
                            <xsl:when test="$v_lang = 'ar'">
                                <xsl:text>المجلد </xsl:text>
                            </xsl:when>
                            <xsl:when test="$v_lang = 'en'">
                                <xsl:text>volume </xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>volume </xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:choose>
                            <!-- check for correct encoding of volume information -->
                            <xsl:when test="$vBiblSource//tei:biblScope[@unit = 'volume']/@from = $vBiblSource//tei:biblScope[@unit = 'volume']/@to">
                                <xsl:value-of select="$vBiblSource//tei:biblScope[@unit = 'volume']/@from"/>
                            </xsl:when>
                            <!-- check for ranges -->
                            <xsl:when test="$vBiblSource//tei:biblScope[@unit = 'volume']/@from != $vBiblSource//tei:biblScope[@unit = 'volume']/@to">
                                <xsl:value-of select="$vBiblSource//tei:biblScope[@unit = 'volume']/@from"/>
                                <!-- probably an en-dash is the better option here -->
                                <xsl:text>/</xsl:text>
                                <xsl:value-of select="$vBiblSource//tei:biblScope[@unit = 'volume']/@to"/>
                            </xsl:when>
                            <!-- fallback: erroneous encoding of volume information with @n -->
                            <xsl:when test="$vBiblSource//tei:biblScope[@unit = 'volume']/@n">
                                <xsl:value-of select="$vBiblSource//tei:biblScope[@unit = 'volume']/@n"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:element>
                    <lb/>
                    <xsl:copy-of select="$vBiblSource//tei:title[@level='j'][@xml:lang='ar'][not(@type='sub')]"/>
                    <!-- here follows the date line -->
                    <lb/>
                    <!-- some periodicals, such as al-Ḥaqāʾiq provide the place of publication -->
                    <xsl:apply-templates select="$vBiblSource//tei:monogr/tei:imprint/tei:pubPlace/tei:placeName[@xml:lang='ar'][1]"/>
                    <xsl:text> في </xsl:text>
                    <xsl:apply-templates select="$vBiblSource//tei:date[@calendar='#cal_islamic']" mode="mBibl"/>
                    <xsl:apply-templates select="$vBiblSource//tei:date[@calendar='#cal_ottomanfiscal']" mode="mBibl"/>
                    <xsl:apply-templates select="$vBiblSource//tei:date[@calendar='#cal_julian']" mode="mBibl"/>
                    <xsl:apply-templates select="$vBiblSource//tei:date[@calendar='#cal_gregorian']" mode="mBibl"/>
                </bibl>
            </div>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tei:imprint/tei:date" mode="mBibl">
        <xsl:variable name="v_date">
            <xsl:choose>
                                <xsl:when test="@calendar = '#cal_gregorian'">
                                    <xsl:value-of select="@when"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@when-custom"/>
                                </xsl:otherwise>
                            </xsl:choose>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="xml:lang" select="'ar'"/>
            <xsl:value-of select="translate(format-number(number(tokenize($v_date, '-')[3]),'#'),$vStringTranscribeFromIjmes,$vStringTranscribeToArabic)"/>
            <xsl:text> </xsl:text>
            <xsl:call-template name="funcDateMonthNameNumber">
                        <xsl:with-param name="pDate" select="$v_date"/>
                        <xsl:with-param name="p_lang" select="$v_lang"/>
                        <xsl:with-param name="p_calendar" select="@calendar"/>
                        <xsl:with-param name="pMode" select="'name'"/>
                    </xsl:call-template>
             <xsl:text> سنة </xsl:text>
            <xsl:value-of select="translate(tokenize($v_date, '-')[1],$vStringTranscribeFromIjmes,$vStringTranscribeToArabic)"/>
        </xsl:copy>
        <xsl:if test="following-sibling::tei:date">
            <xsl:text> و </xsl:text>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>