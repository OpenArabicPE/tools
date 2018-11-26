<xsl:stylesheet exclude-result-prefixes="xs xd html" version="3.0"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet generates a <tei:att>xml:id</tei:att> for every node based on its name, position in the document and generate-id(). The position is used to provide leverage against the slight chance that generate-id() generates an ID already present in the document. An <tei:att>xml:id</tei:att> wil thus look like "div_1.d1e1786"</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output encoding="UTF-8" indent="no" method="xml" name="xml" omit-xml-declaration="no"
        version="1.0"/>
    <!-- identify the author of the change by means of a @xml:id -->
    <!--    <xsl:param name="p_id-editor" select="'pers_TG'"/>-->
    <xsl:include href="../../oxygen-project/OpenArabicPE_parameters.xsl"/>
    
    <!-- this param defines a threshold under which no tei:num/@value will be wrapped in tei:date -->
    <xsl:param name="p_treshold" select="100"/>
    
    <!-- identity transform -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- generate documentation of change -->
    <xsl:template match="tei:revisionDesc" priority="100">
        <!-- basic debugging -->
        <xsl:if test="$p_verbose = true()">
            <xsl:message>
                <xsl:text>change-id: </xsl:text>
                <xsl:value-of select="$p_id-change"/>
            </xsl:message>
        </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="change">
                <xsl:attribute name="when"
                    select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
                <xsl:attribute name="who" select="concat('#', $p_id-editor)"/>
                <xsl:attribute name="xml:id" select="$p_id-change"/>
                <xsl:attribute name="xml:lang" select="'en'"/>
                <xsl:text>Automatically wrapped all occurrences of "sana" and "ʿām" followed by a </xsl:text><tei:gi xml:lang="en">num</tei:gi><xsl:text> node in </xsl:text><tei:gi xml:lang="en">date</tei:gi><xsl:text>.</xsl:text>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- document changes on changed elements by means of the @change attribute linking to the @xml:id of the <tei:change> element -->
    <xsl:template match="@change" mode="m_documentation">
        <xsl:attribute name="change">
            <xsl:value-of select="concat(., ' #', $p_id-change)"/>
        </xsl:attribute>
    </xsl:template>
    
    <!-- apply to all text() followed by a <num> -->
    <xsl:template match="text()[not(ancestor::tei:date)][ following-sibling::node()[1][self::tei:num/@value &gt;= $p_treshold]][matches(.,'(سنة|عام)\s*$')]">
        <xsl:if test="$p_verbose = true()">
            <xsl:message>
            <xsl:text>Found text followed by a num</xsl:text>
        </xsl:message>
        </xsl:if>
        <xsl:variable name="v_num" select="following-sibling::node()[1][self::tei:num]"/>
        <xsl:variable name="v_year-iso" select="format-number($v_num/@value,'0000')"/>
        <!-- find all text  -->
        <xsl:analyze-string select="." regex="(سنة|عام)\s*$">
            <xsl:matching-substring>
                <xsl:if test="$p_verbose = true()">
                <xsl:message>
            <xsl:text>Found indicator of date</xsl:text>
        </xsl:message>
                </xsl:if>
                <xsl:element name="tei:date">
                    <!-- try to establish if the text provides clues to identify the calendar -->
                    <xsl:choose>
                        <!-- the date is Hijrī if we find a trailing 'هـ'  -->
                        <xsl:when test="$v_num/following-sibling::node()[1][matches(.,'^\s*هـ')]">
                            <xsl:attribute name="calendar" select="'#cal_islamic'"/>
                            <xsl:attribute name="datingMethod" select="'#cal_islamic'"/>
                            <xsl:attribute name="when-custom" select="$v_year-iso"/>
                        </xsl:when>
                        <!-- the date is Gregorian if we find a trailing 'م'  -->
                        <xsl:when test="$v_num/following-sibling::node()[1][matches(.,'^\s*م\s')]">
                            <xsl:attribute name="calendar" select="'#cal_gregorian'"/>
                            <xsl:attribute name="when" select="$v_year-iso"/>
                        </xsl:when>
                        <!-- since we deal with mostly Islamicate Arabic material, we also assume that all dates before 1500 to be hijrī -->
                        <xsl:when test="$v_num/@value &lt;= 1499">
                            <xsl:attribute name="calendar" select="'#cal_islamic'"/>
                            <xsl:attribute name="datingMethod" select="'#cal_islamic'"/>
                            <xsl:attribute name="when-custom" select="$v_year-iso"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="when" select="$v_year-iso"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:attribute name="type" select="'auto-markup'"/>
                    <xsl:attribute name="change" select="concat('#',$p_id-change)"/>
                    <xsl:value-of select="regex-group(1)"/><xsl:text> </xsl:text>
                    <xsl:copy-of select="$v_num"/>
                </xsl:element>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <!-- remove <num> that have been wrapped in <date> -->
        <xsl:template match="tei:num[@value &gt;= $p_treshold][not(ancestor::tei:date)][preceding-sibling::text()[1][matches(.,'(سنة|عام)\s*$')]]">
        <xsl:if test="$p_verbose = true()">
            <xsl:message>
            <xsl:text>Found a num following an indicator of a date.</xsl:text>
        </xsl:message>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
