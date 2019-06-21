<xsl:stylesheet exclude-result-prefixes="xs xd html" version="3.0"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:oape="https://openarabicpe.github.io/ns"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet generates a <tei:att>xml:id</tei:att> for every node based on its name, position in the document and generate-id(). The position is used to provide leverage against the slight chance that generate-id() generates an ID already present in the document. An <tei:att>xml:id</tei:att> wil thus look like "div_1.d1e1786"</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output encoding="UTF-8" indent="no" method="xml" name="xml" omit-xml-declaration="no"
        version="1.0"/>
    <!-- include dating functions -->
    <!--    <xsl:include href="https://tillgrallert.github.io/xslt-calendar-conversion/functions/date-functions.xsl"/>-->
    <xsl:include href="/BachUni/BachBibliothek/GitHub/xslt-calendar-conversion/date-function.xsl"/>
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
            <tei:change when="{format-date(current-date(), '[Y0001]-[M01]-[D01]')}"
                who="{concat('#', $p_id-editor)}" xml:id="{$p_id-change}" xml:lang="en"
                >Marked up dates by automatically wrapping all <tei:list>
                <tei:item>occurrences of "سنة" and "عام" followed by a <tei:gi>num</tei:gi> node </tei:item>
                <tei:item><tei:gi>num</tei:gi> nodes followed by either "هـ" or "م" as indicators of calendars</tei:item>
                <tei:item>\d{3,4} followed by either "هـ" or "م" as indicators of calendars.</tei:item>
                </tei:list> in a <tei:gi>date</tei:gi> with the appropriate <tei:att>calendar</tei:att> and <tei:att>datingMethod</tei:att> attributes</tei:change>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- document changes on changed elements by means of the @change attribute linking to the @xml:id of the <tei:change> element -->
    <xsl:template match="@change" mode="m_documentation">
        <xsl:attribute name="change">
            <xsl:value-of select="concat(., ' #', $p_id-change)"/>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="tei:text//text()[not(ancestor::tei:date)]">
        <xsl:variable name="v_preceding-sibling" select="preceding-sibling::node()[1]"/>
        <xsl:variable name="v_preceding-sibling-is-num"
            select="
                if ($v_preceding-sibling[self::tei:num]) then
                    (true())
                else
                    (false())"/>
        <xsl:variable name="v_following-sibling" select="following-sibling::node()[1]"/>
        <xsl:variable name="v_following-sibling-is-num"
            select="
                if ($v_following-sibling[self::tei:num]) then
                    (true())
                else
                    (false())"/>
        <xsl:if test="$p_verbose = true()">
            <xsl:message>
                <xsl:text>Checking text node for dates.</xsl:text>
            </xsl:message>
        </xsl:if>
        <xsl:analyze-string regex="(\d{{3,4}})(\s*(هـ|م))" select=".">
            <xsl:matching-substring>
                <xsl:variable name="v_year-iso"
                    select="format-number(number(regex-group(1)), '0000')"/>
                <xsl:if test="$p_verbose = true()">
                    <xsl:message>
                        <xsl:text>Found a date string: </xsl:text>
                        <xsl:value-of select="$v_year-iso"/>
                    </xsl:message>
                </xsl:if>
                <xsl:element name="tei:date">
                    <!-- establish the calendar -->
                    <xsl:choose>
                        <!-- the date is Hijrī if we find a trailing 'هـ'  -->
                        <xsl:when test="regex-group(3) = 'هـ'">
                            <xsl:attribute name="calendar" select="'#cal_islamic'"/>
                            <xsl:attribute name="datingMethod" select="'#cal_islamic'"/>
                            <xsl:attribute name="when-custom" select="$v_year-iso"/>
                        </xsl:when>
                        <!-- the date is Gregorian if we find a trailing 'م'  -->
                        <xsl:when test="regex-group(3) = 'م'">
                            <xsl:attribute name="calendar" select="'#cal_gregorian'"/>
                            <xsl:attribute name="when" select="$v_year-iso"/>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="change" select="concat('#', $p_id-change)"/>
                    <xsl:value-of select="regex-group(1)"/>
                </xsl:element>
                <xsl:value-of select="regex-group(2)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:choose>
                    <!-- check if preceding node is a <num> -->
                    <xsl:when test="$v_preceding-sibling-is-num = true()">
                        <xsl:if test="$p_verbose = true()">
                            <xsl:message>
                                <xsl:text>The preceding sibling is a &lt;num/> node of value </xsl:text>
                                <xsl:value-of select="$v_preceding-sibling/@value"/>
                            </xsl:message>
                        </xsl:if>
                        <!-- check if there are indicators of dates and calendars -->
                        <xsl:analyze-string regex="^\s*(هـ|م)\W" select=".">
                            <xsl:matching-substring>
                                <xsl:variable name="v_year-iso"
                                    select="format-number($v_preceding-sibling/@value, '0000')"/>
                                <xsl:element name="tei:date">
                                    <!-- establish the calendar -->
                                    <xsl:choose>
                                        <!-- the date is Hijrī if we find a trailing 'هـ'  -->
                                        <xsl:when test="regex-group(1) = 'هـ'">
                                            <xsl:attribute name="calendar" select="'#cal_islamic'"/>
                                            <xsl:attribute name="datingMethod"
                                                select="'#cal_islamic'"/>
                                            <xsl:attribute name="when-custom" select="$v_year-iso"/>
                                        </xsl:when>
                                        <!-- the date is Gregorian if we find a trailing 'م'  -->
                                        <xsl:when test="regex-group(1) = 'م'">
                                            <xsl:attribute name="calendar" select="'#cal_gregorian'"/>
                                            <xsl:attribute name="when" select="$v_year-iso"/>
                                        </xsl:when>
                                    </xsl:choose>
                                    <xsl:attribute name="change" select="concat('#', $p_id-change)"/>
                                    <xsl:copy-of select="$v_preceding-sibling"/>
                                </xsl:element>
                                <xsl:value-of select="."/>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:value-of select="."/>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:when>
                    <!-- check if following node is a <num> -->
                    <xsl:when test="$v_following-sibling-is-num = true()">
                        <xsl:if test="$p_verbose = true()">
                            <xsl:message>
                                <xsl:text>The following sibling is a &lt;num/> node of value </xsl:text>
                                <xsl:value-of select="$v_following-sibling/@value"/>
                            </xsl:message>
                        </xsl:if>
                        <xsl:analyze-string regex="(سنة|عام)\s*$" select=".">
                            <xsl:matching-substring>
                                <xsl:if test="$p_verbose = true()">
                                    <xsl:message>
                                        <xsl:text>Found indicator of date</xsl:text>
                                    </xsl:message>
                                </xsl:if>
                                <xsl:variable name="v_year-iso"
                                    select="format-number($v_following-sibling/@value, '0000')"/>
                                <!-- replicate content -->
                                <xsl:value-of select="."/>
                                <!-- add date node -->
                                <xsl:element name="tei:date">
                                    <!-- try to establish if the text provides clues to identify the calendar -->
                                    <xsl:choose>
                                        <!-- since we deal with mostly Islamicate Arabic material, we assume that all dates before 1500 to be hijrī -->
                                        <xsl:when test="number($v_year-iso)  &lt;= 1499">
                                            <xsl:attribute name="calendar" select="'#cal_islamic'"/>
                                            <xsl:attribute name="datingMethod"
                                                select="'#cal_islamic'"/>
                                            <xsl:attribute name="when-custom" select="$v_year-iso"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:attribute name="when" select="$v_year-iso"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:attribute name="change" select="concat('#', $p_id-change)"/>
                                    <xsl:copy-of select="$v_following-sibling"/>
                                </xsl:element>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:value-of select="."/>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="$p_verbose = true()">
                            <xsl:message>
                                <xsl:text>No dates found</xsl:text>
                            </xsl:message>
                        </xsl:if>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
<!--     remove <num>s that have been wrapped in <date> -->
    <xsl:template
        match="tei:num[not(ancestor::tei:date)][preceding-sibling::text()[1][matches(., '(سنة|عام)\s*$')]] | tei:num[not(ancestor::tei:date)][following-sibling::text()[1][matches(., '^\s*(هـ|م)\W')]]">
        <xsl:if test="$p_verbose = true()">
            <xsl:message>
                <xsl:text>Found a num following an indicator of a date.</xsl:text>
            </xsl:message>
        </xsl:if>
    </xsl:template>
    
    <!-- add machine-readable data to existing date-nodes -->
    <xsl:template match="tei:date[@calendar][not(@when-custom)][not(@calendar='#cal_gregorian')]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:variable name="v_date-normalised" select="oape:date-normalise-input(.,@xml:lang,@calendar)"/>
                <xsl:if test="matches($v_date-normalised, '\d{4}-\d{2}-\d{2}')">
                    <xsl:attribute name="when-custom" select="$v_date-normalised"/>
                    <xsl:attribute name="datingMethod" select="@calendar"/>
                    <xsl:attribute name="when" select="oape:date-convert-calendars($v_date-normalised, @calendar, '#cal_gregorian')"/>
                    <xsl:choose>
                        <xsl:when test="@change">
                            <xsl:apply-templates select="@change" mode="m_documentation"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="change" select="concat('#',$p_id-change)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
