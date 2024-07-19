<xsl:stylesheet exclude-result-prefixes="xs xd html oape" version="3.0" xmlns="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:oape="https://openarabicpe.github.io/ns"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xd="http://www.pnp-software.com/XSLTdoc" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <!-- this stylesheets tries to find and mark-up dates -->
    <xsl:output encoding="UTF-8" indent="no" method="xml" name="xml" omit-xml-declaration="no" version="1.0"/>
    <!-- include dating functions -->
<!--    <xsl:include href="https://tillgrallert.github.io/xslt-calendar-conversion/functions/date-functions.xsl"/>-->
        <xsl:include href="/Users/Shared/BachUni/BachBibliothek/GitHub/xslt-calendar-conversion/functions/date-functions.xsl"/>
    <!-- identify the author of the change by means of a @xml:id -->
    <xsl:include href="../../oxygen-project/OpenArabicPE_parameters.xsl"/>
    <!-- this param defines a threshold under which no tei:num/@value will be wrapped in tei:date -->
    <xsl:param name="p_treshold" select="100"/>
    <!-- identity transform -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- debugging -->
    <xsl:template match="/">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <!-- generate documentation of change -->
    <xsl:template match="tei:revisionDesc" priority="100">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <tei:change when="{format-date(current-date(), '[Y0001]-[M01]-[D01]')}" who="{concat('#', $p_id-editor)}" xml:id="{$p_id-change}" xml:lang="en"
                >Automatically marked up dates by wrapping all <tei:list> <tei:item>occurrences of "سنة" and "عام" followed by a <tei:gi>num</tei:gi> node </tei:item>
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
    <xsl:template match="tei:text//text()[not(ancestor::tei:date | ancestor::tei:num)]" priority="10">
        <xsl:copy-of select="oape:find-dates(., $p_id-change)"/>
    </xsl:template>
    <xsl:template match="tei:text//text()[not(ancestor::tei:date | ancestor::tei:num)]" priority="0">
        <xsl:variable name="v_preceding-sibling" select="preceding-sibling::node()[1]"/>
        <xsl:variable name="v_preceding-sibling-is-num" select="
                if ($v_preceding-sibling[self::tei:num]) then
                    (true())
                else
                    (false())"/>
        <xsl:variable name="v_following-sibling" select="following-sibling::node()[1]"/>
        <xsl:variable name="v_following-sibling-is-num" select="
                if ($v_following-sibling[self::tei:num]) then
                    (true())
                else
                    (false())"/>
        <xsl:if test="$p_verbose = true()">
            <xsl:message>
                <xsl:text>Checking text node for dates.</xsl:text>
            </xsl:message>
        </xsl:if>
        <xsl:analyze-string regex="'(\d{{3,4}})(\s*(هـ|هجري|م[\W]|ملادي|للمسيح))'" select=".">
            <xsl:matching-substring>
                <!-- it is necessary to translate Arabic numerals -->
                <xsl:variable name="v_year" select="translate(regex-group(1), $v_string-digits-ar, $v_string-digits-latn)"/>
                <xsl:variable name="v_year-iso" select="format-number(number($v_year), '0000')"/>
                <xsl:if test="$p_verbose = true()">
                    <xsl:message>
                        <xsl:text>Found a date string: </xsl:text>
                        <xsl:value-of select="$v_year-iso"/>
                    </xsl:message>
                </xsl:if>
                <xsl:element name="tei:date">
                    <xsl:attribute name="resp" select="'#xslt'"/>
                    <!-- establish the calendar -->
                    <xsl:choose>
                        <!-- the date is Hijrī if we find a trailing 'هـ'  -->
                        <xsl:when test="regex-group(3) = ('هـ', 'هجري')">
                            <xsl:attribute name="calendar" select="'#cal_islamic'"/>
                            <xsl:attribute name="datingMethod" select="'#cal_islamic'"/>
                            <xsl:attribute name="when-custom" select="$v_year-iso"/>
                        </xsl:when>
                        <!-- the date is Gregorian if we find a trailing 'م'  -->
                        <xsl:when test="regex-group(3) = ('م', 'ملادي', 'للمسيح')">
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
                <xsl:if test="$p_verbose = true()">
                    <xsl:message>
                        <xsl:text>No dates found</xsl:text>
                    </xsl:message>
                </xsl:if>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    <xsl:template match="tei:num[not(ancestor::tei:date)][preceding-sibling::text()[1][matches(., '(سنة|عام)\s*$')]]" priority="1">
        <!--        <xsl:if test="$p_verbose = true()">-->
        <xsl:message>
            <xsl:text>Found a *num* node (</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>) following an indicator of a date.</xsl:text>
        </xsl:message>
        <!--</xsl:if>-->
        <!-- add date node -->
        <xsl:variable name="v_year-iso" select="format-number(@value, '0000')"/>
        <xsl:element name="tei:date">
            <!-- try to establish if the text provides clues to identify the calendar -->
            <xsl:choose>
                <!-- since we deal with mostly Islamicate Arabic material, we assume that all dates before 1500 to be hijrī -->
                <xsl:when test="number($v_year-iso) &lt;= 1499">
                    <xsl:attribute name="calendar" select="'#cal_islamic'"/>
                    <xsl:attribute name="datingMethod" select="'#cal_islamic'"/>
                    <xsl:attribute name="when-custom" select="$v_year-iso"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="calendar" select="'#cal_gregorian'"/>
                    <xsl:attribute name="when" select="$v_year-iso"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:attribute name="change" select="concat('#', $p_id-change)"/>
            <xsl:attribute name="resp" select="'#xslt'"/>
            <xsl:copy-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:num[not(ancestor::tei:date)][following-sibling::text()[1][matches(., '^\s*(هـ|هجري|م|ملادي|للمسيح)\W')]]" priority="2">
        <!--        <xsl:if test="$p_verbose = true()">-->
        <xsl:message>
            <xsl:text>Found a *num* node (</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>) preceding an indicator of a date.</xsl:text>
        </xsl:message>
        <!--</xsl:if>-->
        <!-- add date node -->
        <xsl:variable name="v_year-iso" select="format-number(@value, '0000')"/>
        <xsl:element name="tei:date">
            <!-- establish the calendar -->
            <xsl:analyze-string regex="^\s*(هـ|هجري|م|ملادي|للمسيح)\W" select="following-sibling::text()[1]">
                <xsl:matching-substring>
                    <xsl:choose>
                        <!-- the date is Hijrī if we find a trailing 'هـ'  -->
                        <xsl:when test="regex-group(1) = ('هـ', 'هجري')">
                            <xsl:attribute name="calendar" select="'#cal_islamic'"/>
                            <xsl:attribute name="datingMethod" select="'#cal_islamic'"/>
                            <xsl:attribute name="when-custom" select="$v_year-iso"/>
                        </xsl:when>
                        <!-- the date is Gregorian if we find a trailing 'م'  -->
                        <xsl:when test="regex-group(1) = ('م', 'ملادي', 'للمسيح')">
                            <xsl:attribute name="calendar" select="'#cal_gregorian'"/>
                            <xsl:attribute name="when" select="$v_year-iso"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:matching-substring>
            </xsl:analyze-string>
            <xsl:attribute name="change" select="concat('#', $p_id-change)"/>
            <xsl:attribute name="resp" select="'#xslt'"/>
            <xsl:copy-of select="."/>
        </xsl:element>
    </xsl:template>
    <!-- add machine-readable data to existing date-nodes -->
    <xsl:template match="tei:date">
        <xsl:variable name="v_lang">
            <xsl:choose>
                <xsl:when test="@xml:lang">
                    <xsl:value-of select="@xml:lang"/>
                </xsl:when>
                <xsl:when test="ancestor::node()/@xml:lang">
                    <xsl:value-of select="ancestor::node()[@xml:lang][1]/@xml:lang"/>
                </xsl:when>
                <!-- default to English -->
                <xsl:otherwise>
                    <xsl:value-of select="'en'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$p_debug = true()">
            <xsl:message>
                <xsl:value-of select="$v_lang"/>
            </xsl:message>
        </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <!-- if calendar is Gregorian and @when is supplied, nothing should be done -->
                <xsl:when test="@calendar = '#cal_gregorian' and @when != ''"/>
                <!-- if @when-custom,  @when etc. are supplied, nothing should be done -->
                <xsl:when test="@when-custom, @when, @from, @to"/>
                <xsl:when test="@notAfter, @notBefore"/>
                <xsl:otherwise>
                    <xsl:variable name="v_calendar">
                        <xsl:choose>
                            <xsl:when test="@calendar">
                                <xsl:value-of select="@calendar"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'#cal_gregorian'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <!-- assume that unmarked calendars default to gregorian -->
                    <xsl:variable name="v_date-normalised" select="oape:date-normalise-input(., $v_lang, $v_calendar)"/>
                    <!-- check if the input can be normalised to ISO format -->
                    <xsl:choose>
                        <xsl:when test="matches($v_date-normalised, '^\d{4}-\d{2}-\d{2}$|^\d{4}$')">
                            <!-- convert normalised input to gregorian -->
                            <xsl:variable name="v_date-gregorian">
                                <xsl:choose>
                                    <xsl:when test="matches($v_date-normalised, '^\d{4}-\d{2}-\d{2}$')">
                                        <xsl:copy-of select="oape:date-convert-calendars($v_date-normalised, $v_calendar, '#cal_gregorian')"/>
                                    </xsl:when>
                                    <xsl:when test="matches($v_date-normalised, '^\d{4}$')">
                                        <xsl:copy-of select="oape:date-convert-years-between-calendars($v_date-normalised, $v_calendar, '#cal_gregorian')"/>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:if test="not(@when-custom) and not($v_calendar = '#cal_gregorian')">
                                <xsl:attribute name="when-custom" select="$v_date-normalised"/>
                                <xsl:attribute name="datingMethod" select="$v_calendar"/>
                            </xsl:if>
                            <xsl:if test="matches($v_date-gregorian, '^\d{4}-\d{2}-\d{2}$|^\d{4}$')">
                                <xsl:attribute name="when" select="$v_date-gregorian"/>
                            </xsl:if>
                            <!-- make sure that documentation is only toggled after actual changes -->
                            <xsl:if test="(not(@when-custom = $v_date-normalised) or not(@when = $v_date-gregorian))">
                                <xsl:choose>
                                    <xsl:when test="@change">
                                        <xsl:apply-templates mode="m_documentation" select="@change"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="change" select="concat('#', $p_id-change)"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:if>
                        </xsl:when>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
