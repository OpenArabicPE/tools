<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    exclude-result-prefixes="xs xd oape" 
    version="3.0" 
    xmlns="http://www.tei-c.org/ns/1.0" 
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:xd="http://www.pnp-software.com/XSLTdoc" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:oape="https://openarabicpe.github.io/ns">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet generates the masthead of issues based on the information in the teiHeader</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output encoding="UTF-8" indent="no" method="xml" omit-xml-declaration="no"/>
    <xsl:include href="https://tillgrallert.github.io/xslt-calendar-conversion/functions/date-functions.xsl"/>
    <xsl:include href="../../oxygen-project/OpenArabicPE_parameters.xsl"/>
    
     <!-- set language of output -->
    <xsl:variable name="v_lang" select="'ar'"/>
    
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
                <xsl:text>Generated a new </xsl:text>
                <tei:gi xml:lang="en">front</tei:gi>
                <xsl:text>based on the </xsl:text>
                <tei:gi xml:lang="en">sourceDesc</tei:gi>
                <xsl:text>that matches the information found in the masthead of the actual issues.</xsl:text>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- document changes on changed elements by means of the @change attribute linking to the @xml:id of the <tei:change>element -->
    <xsl:template match="@change" mode="m_documentation">
        <xsl:attribute name="change">
            <xsl:value-of select="concat(.,' #',$p_id-change)"/>
        </xsl:attribute>
    </xsl:template>
    
   
    <!-- retrieve bibliographic information from the teiHeader -->
    <xsl:variable name="v_biblSource" select="tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct"/>
    <!-- move the first page break before the <front>-->
    <xsl:template match="tei:text">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <!-- move the first page beginning before the content -->
            <xsl:copy-of select="descendant::tei:pb[@ed='print'][1]"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:pb[@ed='print']">
        <!-- supress the first tei:pb in tei:text -->
        <xsl:if test="preceding::tei:pb[@ed='print']">
            <xsl:copy>
                <xsl:apply-templates select="@*"/>
                <!--<xsl:apply-templates mode="m_documentation" select="@change"/>-->
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    
    <!-- generate a new <front>-->
    <xsl:template match="tei:front">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <!-- add documentation of change -->
            <xsl:choose>
                <xsl:when test="not(@change)">
                    <xsl:attribute name="change" select="concat('#',$p_id-change)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates mode="m_documentation" select="@change"/>
                </xsl:otherwise>
            </xsl:choose>
            <!-- add a masthead -->
            <xsl:element name="tei:div">
                <xsl:attribute name="change" select="concat('#',$p_id-change)"/>
                <xsl:attribute name="type" select="'masthead'"/>
                <xsl:element name="tei:bibl">
                    <!-- issue information -->
                    <xsl:element name="tei:biblScope">
                        <xsl:attribute name="unit" select="'issue'"/>
                        <xsl:attribute name="from" select="$v_biblSource//tei:biblScope[@unit='issue']/@from"/>
                        <xsl:attribute name="to" select="$v_biblSource//tei:biblScope[@unit='issue']/@to"/>
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
                            <xsl:when test="$v_biblSource//tei:biblScope[@unit = 'issue']/@from = $v_biblSource//tei:biblScope[@unit = 'issue']/@to">
                                <xsl:value-of select="$v_biblSource//tei:biblScope[@unit = 'issue']/@from"/>
                            </xsl:when>
                            <!-- check for ranges -->
                            <xsl:when test="$v_biblSource//tei:biblScope[@unit = 'issue']/@from != $v_biblSource//tei:biblScope[@unit = 'issue']/@to">
                                <xsl:value-of select="$v_biblSource//tei:biblScope[@unit = 'issue']/@from"/>
                                <!-- probably an en-dash is the better option here -->
                                <xsl:text>/</xsl:text>
                                <xsl:value-of select="$v_biblSource//tei:biblScope[@unit = 'issue']/@to"/>
                            </xsl:when>
                            <!-- fallback: erroneous encoding of issue information with @n -->
                            <xsl:when test="$v_biblSource//tei:biblScope[@unit = 'issue']/@n">
                                <xsl:value-of select="$v_biblSource//tei:biblScope[@unit = 'issue']/@n"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:element>
                    <!-- volume information -->
                    <xsl:element name="tei:biblScope">
                        <xsl:attribute name="unit" select="'volume'"/>
                        <xsl:attribute name="from" select="$v_biblSource//tei:biblScope[@unit='volume']/@from"/>
                        <xsl:attribute name="to" select="$v_biblSource//tei:biblScope[@unit='volume']/@to"/>
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
                            <xsl:when test="$v_biblSource//tei:biblScope[@unit = 'volume']/@from = $v_biblSource//tei:biblScope[@unit = 'volume']/@to">
                                <xsl:value-of select="$v_biblSource//tei:biblScope[@unit = 'volume']/@from"/>
                            </xsl:when>
                            <!-- check for ranges -->
                            <xsl:when test="$v_biblSource//tei:biblScope[@unit = 'volume']/@from != $v_biblSource//tei:biblScope[@unit = 'volume']/@to">
                                <xsl:value-of select="$v_biblSource//tei:biblScope[@unit = 'volume']/@from"/>
                                <!-- probably an en-dash is the better option here -->
                                <xsl:text>/</xsl:text>
                                <xsl:value-of select="$v_biblSource//tei:biblScope[@unit = 'volume']/@to"/>
                            </xsl:when>
                            <!-- fallback: erroneous encoding of volume information with @n -->
                            <xsl:when test="$v_biblSource//tei:biblScope[@unit = 'volume']/@n">
                                <xsl:value-of select="$v_biblSource//tei:biblScope[@unit = 'volume']/@n"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:element>
                    <lb/>
                    <!-- main title -->
                    <xsl:apply-templates mode="m_copy" select="$v_biblSource//tei:title[@level='j'][@xml:lang='ar'][not(@type='sub')]"/>
                    <!--                    <xsl:copy-of select="$v_biblSource//tei:title[@level='j'][@xml:lang='ar'][not(@type='sub')]"/>-->
                    <!-- some periodicals, such as al-Ḥaqāʾiq provide the place of publication. This should be automatically toggled, for instance on the basis of the oclc number -->
                    <xsl:choose>
                        <!-- al-Ḥaqāʾiq -->
                        <xsl:when test="$v_biblSource//tei:idno[@type='OCLC'] = '644997575'">
                            <!-- here follows the date line -->
                            <lb/>
                            <xsl:apply-templates select="$v_biblSource//tei:monogr/tei:imprint/tei:pubPlace/tei:placeName[@xml:lang='ar'][1]"/>
                            <xsl:text>في </xsl:text>
                            <xsl:apply-templates mode="mBibl" select="$v_biblSource//tei:date[@calendar='#cal_islamic']"/>
                            <!--<xsl:text>و</xsl:text><xsl:apply-templates select="$v_biblSource//tei:date[@calendar='#cal_ottomanfiscal']" mode="mBibl"/><xsl:text>و</xsl:text><xsl:apply-templates select="$v_biblSource//tei:date[@calendar='#cal_gregorian']" mode="mBibl"/>-->
                        </xsl:when>
                        <!-- al-Muqtabas -->
                        <xsl:when test="$v_biblSource//tei:idno[@type='OCLC'] = '4770057679' and $v_biblSource//tei:biblScope[@unit='volume']/@from &lt; 6">
                            <!-- here follows the date line -->
                            <lb/>
                            <xsl:apply-templates mode="mBibl" select="$v_biblSource//tei:date[@calendar='#cal_islamic']"/>
                            <xsl:text> موافق </xsl:text>
                            <xsl:copy-of select="oape:date-format-iso-string-to-tei($v_biblSource//tei:date[@when][1]/@when,'#cal_julian', true(), false(), 'ar')"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:element>
            </xsl:element>
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
            <xsl:apply-templates mode="m_copy" select="@*"/>
            <xsl:attribute name="xml:lang" select="$v_lang"/>
            <xsl:if test="$p_verbose = true()">
                <xsl:message>
                    <xsl:text>Copied node </xsl:text><xsl:value-of select="@xml:id"/><xsl:text> and applied templates to its attributes.</xsl:text>
                </xsl:message>
            </xsl:if>
            <xsl:value-of select="oape:date-format-iso-string-to-tei($v_date, @calendar, true(), false(), 'ar')"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="node() | @*" mode="m_copy">
        <xsl:copy>
            <xsl:apply-templates mode="m_copy" select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="@xml:id" mode="m_copy"/>
    
</xsl:stylesheet>