<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0" xmlns="http://www.tei-c.org/ns/1.0" xmlns:oape="https://openarabicpe.github.io/ns" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <!-- this stylesheet tries to remove automatically generated mark-up -->
    <xsl:output encoding="UTF-8" exclude-result-prefixes="#all" indent="no" method="xml" omit-xml-declaration="no"/>
    <!-- identify the author of the change by means of a @xml:id -->
    <!--    <xsl:include href="../../oxygen-project/OpenArabicPE_parameters.xsl"/>-->
    <xsl:include href="../../authority-files/xslt/functions.xsl"/>
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="node()[@change][not(self::tei:div)][not(self::tei:idno)]">
        <!-- look-up the first referenced change -->
        <xsl:variable name="v_change-id" select="substring-after(tokenize(@change, '\s+')[1], '#')"/>
        <xsl:variable name="v_change" select="/tei:TEI/tei:teiHeader/tei:revisionDesc/tei:change[@xml:id = $v_change-id][1]"/>
        <xsl:variable name="v_change-is-automatic">
            <xsl:choose>
                <!-- based on the @type attribute -->
                <xsl:when test="@type = 'auto-markup'">
                    <xsl:value-of select="true()"/>
                </xsl:when>
                <!-- based on the text of the <change> element -->
                <xsl:when test="matches($v_change, '^automatic', 'i')">
                    <xsl:value-of select="true()"/>
                </xsl:when>
                <xsl:when test="matches($v_change, '^Marked up dates by automatically', 'i')">
                    <xsl:value-of select="true()"/>
                </xsl:when>
                <xsl:when test="matches($v_change, '^Wrapped all numerals in ', 'i')">
                    <xsl:value-of select="true()"/>
                </xsl:when>
                <!-- some of the automatic mark-up of periodical titles did not include an @xml:id on the change -->
                <xsl:when test="self::tei:title and $v_change = ''">
                    <xsl:value-of select="true()"/>
                </xsl:when>
                <!-- bassed on the @resp attribute -->
                <xsl:otherwise>
                    <xsl:value-of select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <!-- temporarily add titles -->
            <xsl:when test="self::tei:title[@level = 'j'][not(ancestor::tei:bibl | ancestor::tei:persName)][matches(preceding-sibling::node()[1], '(مجلة|جريدة)\s+$')]">
                <xsl:apply-templates select="node()"/>
            </xsl:when>
            <xsl:when test="$v_change-is-automatic = false()">
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="$v_change-is-automatic = true() and self::tei:num">
                <xsl:value-of select="oape:remove-scientific-notation(.)"/>
            </xsl:when>
            <xsl:when test="$v_change-is-automatic = true()">
                <xsl:apply-templates select="node()"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!-- Converts numbers in Scientific Notation e.g. 6.15595432E8 to decimal -->
    <xsl:function name="oape:remove-scientific-notation">
        <xsl:param name="p_num"/>
        <xsl:variable name="v_value">
            <xsl:choose>
                <xsl:when test="matches($p_num/@value, '^\-?[\d\.,]*[Ee][+\-]*\d*$')">
                    <xsl:message>
                        <xsl:text>found scientific notation: </xsl:text>
                        <xsl:value-of select="$p_num/@value"/>
                        <xsl:text> = </xsl:text>
                        <xsl:value-of select="format-number(number($p_num/@value), '#0.#############')"/>
                    </xsl:message>
                    <xsl:value-of select="format-number(number($p_num/@value), '#0.#############')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$p_num/@value"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:copy select="$p_num">
            <xsl:apply-templates select="$p_num/@*"/>
            <xsl:attribute name="value" select="$v_value"/>
            <xsl:choose>
                <xsl:when test="$p_num/@xml:lang = 'ar'">
                    <xsl:value-of select="translate($v_value, $v_string-transcribe-ijmes, $v_string-transcribe-arabic)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="$p_num/node()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:function>
</xsl:stylesheet>
