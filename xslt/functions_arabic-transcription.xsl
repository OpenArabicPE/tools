<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:oape="https://openarabicpe.github.io/ns" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <!-- the templates/ functions in this stylesheet aim at automatic re-translation from Arabic in Latin transcription to Arabic in Arabic script -->
    <!-- in order to work, this stylesheet needs to be loaded from functions_core.xsl -->
    <!-- the templates assume the IJMES system of transcription -->
    <xsl:variable name="v_string-transcribe-ijmes-from" select="'bptṯṯḥḫjǧǧdḏrzsšṣḍṭẓʿʻġfqḳḳklmnhâāāáûūūîīwy0123456789'"/>
    <xsl:variable name="v_string-transcribe-arabic-to" select="'بپتثثحخجججدذرزسشصضطظععغفقققكلمنهاااىوووييوي٠١٢٣٤٥٦٧٨٩'"/>
    <xsl:variable name="v_regex-hamza" select="'[ʾ|ʼ]'"/>
    <xsl:param name="p_debug" select="false()"/>
    <!--    TO DO:
        - الل- - XSLT typical mistake when there is wa-l-
    -->
    <!-- testing: -->
    <!-- <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="node()[@xml:lang = 'ar-Latn-x-ijmes'] | tei:persName | tei:name">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:copy-of select="oape:string-transliterate-ijmes-to-arabic(.)"/>
        </xsl:copy>
    </xsl:template>
    <!-\- identity transform -\->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>-->
    <xsl:function name="oape:string-transliterate-arabic_latin-to-arabic">
        <xsl:param as="xs:string" name="p_input"/>
        <xsl:message>
            <xsl:text># start</xsl:text>
        </xsl:message>
        <xsl:message>
            <xsl:text>$p_input: </xsl:text>
            <xsl:value-of select="$p_input"/>
        </xsl:message>
        <xsl:variable name="v_tokenized" select="oape:string-mark-up-tokens($p_input)"/>
        <xsl:message>
            <xsl:text>$v_tokenized: </xsl:text>
            <xsl:for-each select="$v_tokenized/self::element()">
                <xsl:value-of select="."/>
                <xsl:if test="position() != last()">
                    <xsl:text> | </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:message>
        <xsl:message>iterating through tokens</xsl:message>
        <xsl:for-each select="$v_tokenized/self::element()">
            <xsl:if test="$p_debug = true()">
                <xsl:message>
                    <xsl:text>token: </xsl:text>
                    <xsl:value-of select="."/>
                </xsl:message>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="self::tei:w">
                    <xsl:variable name="v_word">
                        <xsl:call-template name="f-1_string-arabic-article-gender">
                            <xsl:with-param name="p_input" select="."/>
                        </xsl:call-template>
                    </xsl:variable>
                    <!-- reassemble all words from right to left  -->
                    <xsl:if test="$v_word/descendant-or-self::tei:c[@xml:lang = 'ar']">
                        <xsl:message>
                            <xsl:text>input: </xsl:text>
                            <xsl:value-of select="."/>
                        </xsl:message>
                        <xsl:message>
                            <xsl:text>assembled output: </xsl:text>
                            <xsl:value-of select="$v_word"/>
                        </xsl:message>
                        <xsl:element name="tei:w">
                            <xsl:attribute name="xml:lang" select="'ar'"/>
                            <xsl:value-of select="$v_word"/>
                        </xsl:element>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    <xsl:template name="f-1_string-arabic-article-gender">
        <xsl:param as="xs:string" name="p_input"/>
        <xsl:if test="$p_debug = true()">
            <xsl:message>
                <xsl:text># f1: find articles</xsl:text>
            </xsl:message>
            <xsl:message>
                <xsl:text>$p_input: </xsl:text>
                <xsl:value-of select="$p_input"/>
            </xsl:message>
        </xsl:if>
        <xsl:analyze-string regex="^(.+)(-|')(.+?)$" select="lower-case($p_input)">
            <xsl:matching-substring>
                <xsl:variable name="v_string-prefix" select="regex-group(1)"/>
                <xsl:variable name="v_string-remainder" select="regex-group(3)"/>
                <xsl:choose>
                    <xsl:when test="matches($v_string-prefix, '(a|e)(l|d|ḍ|t|ṭ|z|ẓ|s|š|n)')">
                        <xsl:if test="$p_debug = true()">
                            <xsl:message>
                                <xsl:text>determined article "</xsl:text>
                                <xsl:value-of select="$v_string-prefix"/>
                                <xsl:text>"</xsl:text>
                            </xsl:message>
                        </xsl:if>
                        <xsl:element name="tei:c">
                            <xsl:attribute name="xml:lang" select="'ar'"/>
                            <xsl:text>ا</xsl:text>
                        </xsl:element>
                        <xsl:element name="tei:c">
                            <xsl:attribute name="xml:lang" select="'ar'"/>
                            <xsl:text>ل</xsl:text>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="$v_string-prefix = ('bi-al', 'bi-l')">
                        <xsl:if test="$p_debug = true()">
                            <xsl:message>
                                <xsl:text>preposition followed by determined article "</xsl:text>
                                <xsl:value-of select="$v_string-prefix"/>
                                <xsl:text>"</xsl:text>
                            </xsl:message>
                        </xsl:if>
                        <xsl:element name="tei:c">
                            <xsl:attribute name="xml:lang" select="'ar'"/>
                            <xsl:text>ب</xsl:text>
                        </xsl:element>
                        <xsl:element name="tei:c">
                            <xsl:attribute name="xml:lang" select="'ar'"/>
                            <xsl:text>ا</xsl:text>
                        </xsl:element>
                        <xsl:element name="tei:c">
                            <xsl:attribute name="xml:lang" select="'ar'"/>
                            <xsl:text>ل</xsl:text>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="$v_string-prefix = ('wa-al', 'wa-l')">
                        <xsl:if test="$p_debug = true()">
                            <xsl:message>
                                <xsl:text>preposition followed by determined article "</xsl:text>
                                <xsl:value-of select="$v_string-prefix"/>
                                <xsl:text>"</xsl:text>
                            </xsl:message>
                        </xsl:if>
                        <xsl:element name="tei:c">
                            <xsl:attribute name="xml:lang" select="'ar'"/>
                            <xsl:text>و</xsl:text>
                        </xsl:element>
                        <xsl:element name="tei:c">
                            <xsl:attribute name="xml:lang" select="'ar'"/>
                            <xsl:text>ا</xsl:text>
                        </xsl:element>
                        <xsl:element name="tei:c">
                            <xsl:attribute name="xml:lang" select="'ar'"/>
                            <xsl:text>ل</xsl:text>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="$v_string-prefix = ('li-al', 'li-l', 'lil', 'li-''l')">
                        <xsl:if test="$p_debug = true()">
                            <xsl:message>
                                <xsl:text>preposition followed by determined article "</xsl:text>
                                <xsl:value-of select="$v_string-prefix"/>
                                <xsl:text>"</xsl:text>
                            </xsl:message>
                        </xsl:if>
                        <xsl:element name="tei:c">
                            <xsl:attribute name="xml:lang" select="'ar'"/>
                            <xsl:text>ل</xsl:text>
                        </xsl:element>
                        <xsl:element name="tei:c">
                            <xsl:attribute name="xml:lang" select="'ar'"/>
                            <xsl:text>ل</xsl:text>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="$v_string-prefix = ('li', 'bi', 'wa')">
                        <xsl:if test="$p_debug = true()">
                            <xsl:message>
                                <xsl:text>preposition "</xsl:text>
                                <xsl:value-of select="regex-group(1)"/>
                                <xsl:text>"</xsl:text>
                            </xsl:message>
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when test="$v_string-prefix = 'bi'">
                                <xsl:element name="tei:c">
                                    <xsl:attribute name="xml:lang" select="'ar'"/>
                                    <xsl:text>ب</xsl:text>
                                </xsl:element>
                            </xsl:when>
                            <xsl:when test="$v_string-prefix = 'li'">
                                <xsl:element name="tei:c">
                                    <xsl:attribute name="xml:lang" select="'ar'"/>
                                    <xsl:text>ل</xsl:text>
                                </xsl:element>
                            </xsl:when>
                            <xsl:when test="$v_string-prefix = 'wa'">
                                <xsl:element name="tei:c">
                                    <xsl:attribute name="xml:lang" select="'ar'"/>
                                    <xsl:text>و</xsl:text>
                                </xsl:element>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <!-- otherwise not implemented -->
                    <xsl:otherwise>
                        <xsl:message error-code="2" terminate="no">
                            <xsl:text>The prefix "</xsl:text>
                            <xsl:value-of select="regex-group(1)"/>
                            <xsl:text>" has not been recognised</xsl:text>
                        </xsl:message>
                        <xsl:call-template name="f-2_string-arabic-split-radicals">
                            <xsl:with-param name="p_input" select="$v_string-prefix"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                <!-- Problem: if we loop the input through funcStringTranscribeIjmesToArabic, it is lost somewhere down the line -->
                <xsl:copy-of select="oape:string-transliterate-arabic_latin-to-arabic($v_string-remainder)"/>
                <!--<xsl:call-template name="f-1_string-arabic-article-gender">
                    <xsl:with-param name="p_input" select="regex-group(2)"/>
                </xsl:call-template>-->
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <!-- tāʾ marbūṭa should be dealt with here. I presume there is no word of two letters ending with it -->
                <xsl:analyze-string regex="^(\w+)īyah$|^(\w+)a[t|h]*$|^(\w+)[a|i|u]hā$|^(\w+)ā$" select=".">
                    <xsl:matching-substring>
                        <xsl:choose>
                            <xsl:when test="matches(., '^\w+īyah$')">
                                <xsl:if test="$p_debug = true()">
                                    <xsl:message>
                                        <xsl:text>word ends in yāʾ+tāʾ marbūṭa</xsl:text>
                                    </xsl:message>
                                </xsl:if>
                                <xsl:call-template name="f-2_string-arabic-split-radicals">
                                    <xsl:with-param name="p_input" select="regex-group(1)"/>
                                </xsl:call-template>
                                <xsl:element name="tei:c">
                                    <xsl:attribute name="xml:lang" select="'ar'"/>
                                    <xsl:text>ي</xsl:text>
                                </xsl:element>
                                <xsl:element name="tei:c">
                                    <xsl:attribute name="xml:lang" select="'ar'"/>
                                    <xsl:text>ة</xsl:text>
                                </xsl:element>
                            </xsl:when>
                            <xsl:when test="matches(., '^\w+a[t|h]*$')">
                                <xsl:if test="$p_debug = true()">
                                    <xsl:message>
                                        <xsl:text>word ends in tāʾ marbūṭa</xsl:text>
                                    </xsl:message>
                                </xsl:if>
                                <xsl:call-template name="f-2_string-arabic-split-radicals">
                                    <xsl:with-param name="p_input" select="regex-group(2)"/>
                                </xsl:call-template>
                                <xsl:element name="tei:c">
                                    <xsl:attribute name="xml:lang" select="'ar'"/>
                                    <xsl:text>ة</xsl:text>
                                </xsl:element>
                            </xsl:when>
                            <xsl:when test="matches(., '|^(\w+)[a|i|u]hā$')">
                                <xsl:if test="$p_debug = true()">
                                    <xsl:message>
                                        <xsl:text>word ends in female possessive</xsl:text>
                                    </xsl:message>
                                </xsl:if>
                                <xsl:call-template name="f-2_string-arabic-split-radicals">
                                    <xsl:with-param name="p_input" select="regex-group(3)"/>
                                </xsl:call-template>
                                <xsl:element name="tei:c">
                                    <xsl:attribute name="xml:lang" select="'ar'"/>
                                    <xsl:text>ه</xsl:text>
                                </xsl:element>
                                <xsl:element name="tei:c">
                                    <xsl:attribute name="xml:lang" select="'ar'"/>
                                    <xsl:text>ا</xsl:text>
                                </xsl:element>
                            </xsl:when>
                            <xsl:when test="matches(., '^\w+ā$')">
                                <xsl:if test="$p_debug = true()">
                                    <xsl:message>
                                        <xsl:text>word ends in alif makṣūra</xsl:text>
                                    </xsl:message>
                                </xsl:if>
                                <xsl:call-template name="f-2_string-arabic-split-radicals">
                                    <xsl:with-param name="p_input" select="regex-group(4)"/>
                                </xsl:call-template>
                                <xsl:element name="tei:c">
                                    <xsl:attribute name="xml:lang" select="'ar'"/>
                                    <xsl:text>ى</xsl:text>
                                </xsl:element>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:call-template name="f-2_string-arabic-split-radicals">
                            <xsl:with-param name="p_input" select="."/>
                        </xsl:call-template>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    <!-- this template takes individual words as input and splits them into syllables / radicals -->
    <xsl:template name="f-2_string-arabic-split-radicals">
        <xsl:param name="p_input"/>
        <xsl:if test="$p_debug = true()">
            <xsl:message>
                <xsl:text># f2: split into radicals</xsl:text>
            </xsl:message>
            <xsl:message>
                <xsl:text>$p_input: </xsl:text>
                <xsl:value-of select="$p_input"/>
            </xsl:message>
        </xsl:if>
        <!-- starting hamza -->
        <xsl:variable name="v_output">
            <xsl:choose>
                <xsl:when test="starts-with($p_input, 'i')">
                    <xsl:element name="tei:c">
                        <xsl:attribute name="xml:lang" select="'ar'"/>
                        <xsl:text>ا</xsl:text>
                    </xsl:element>
                    <xsl:call-template name="f-2_string-arabic-split-radicals">
                        <xsl:with-param name="p_input" select="substring($p_input, 2)"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="starts-with($p_input, 'a')">
                    <xsl:element name="tei:c">
                        <xsl:attribute name="xml:lang" select="'ar'"/>
                        <xsl:text>ا</xsl:text>
                    </xsl:element>
                    <xsl:call-template name="f-2_string-arabic-split-radicals">
                        <xsl:with-param name="p_input" select="substring($p_input, 2)"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="starts-with($p_input, 'u')">
                    <xsl:element name="tei:c">
                        <xsl:attribute name="xml:lang" select="'ar'"/>
                        <xsl:text>ا</xsl:text>
                    </xsl:element>
                    <xsl:call-template name="f-2_string-arabic-split-radicals">
                        <xsl:with-param name="p_input" select="substring($p_input, 2)"/>
                    </xsl:call-template>
                </xsl:when>
                <!-- hamza in the middle or at the end of a word -->
                <xsl:when test="matches($p_input, concat('^.+', $v_regex-hamza))">
                    <xsl:if test="$p_debug = true()">
                        <xsl:message>
                            <xsl:text>string contains hamza</xsl:text>
                        </xsl:message>
                    </xsl:if>
                    <xsl:analyze-string regex="{concat('(\w*)', $v_regex-hamza, '(\w*)')}" select="$p_input">
                        <xsl:matching-substring>
                            <xsl:variable name="v_string-preceding-length" select="string-length(regex-group(1))"/>
                            <xsl:variable name="v_string-preceding" select="regex-group(1)"/>
                            <xsl:variable name="v_string-preceding-end" select="substring($v_string-preceding, $v_string-preceding-length)"/>
                            <xsl:variable name="v_string-following" select="regex-group(2)"/>
                            <xsl:variable name="v_string-following-first-letter" select="substring($v_string-following, 1, 1)"/>
                            <xsl:variable name="v_string-following-remainder" select="substring($v_string-following, 2)"/>
                            <xsl:if test="$p_debug = true()">
                                <xsl:message>
                                    <xsl:text>hamza follows "</xsl:text>
                                    <xsl:value-of select="$v_string-preceding"/>
                                    <xsl:text>" and is followed by "</xsl:text>
                                    <xsl:value-of select="$v_string-following"/>
                                    <xsl:text>"</xsl:text>
                                </xsl:message>
                            </xsl:if>
                            <xsl:choose>
                                <!-- trailing hamza -->
                                <xsl:when test="$v_string-following = ''">
                                    <xsl:if test="$p_debug = true()">
                                        <xsl:message>
                                            <xsl:text>trailing hamza</xsl:text>
                                        </xsl:message>
                                    </xsl:if>
                                    <xsl:call-template name="f-2_string-arabic-split-radicals">
                                        <xsl:with-param name="p_input" select="$v_string-preceding"/>
                                    </xsl:call-template>
                                    <xsl:element name="tei:c">
                                        <xsl:attribute name="xml:lang" select="'ar'"/>
                                        <xsl:text>ء</xsl:text>
                                    </xsl:element>
                                </xsl:when>
                                <!-- hamza following a or ā -->
                                <xsl:when test="$v_string-preceding-end = 'a' or $v_string-preceding-end = 'ā'">
                                    <xsl:if test="$p_debug = true()">
                                        <xsl:message>
                                            <xsl:text>hamza follows a or ā</xsl:text>
                                        </xsl:message>
                                    </xsl:if>
                                    <xsl:call-template name="f-2_string-arabic-split-radicals">
                                        <xsl:with-param name="p_input" select="$v_string-preceding"/>
                                    </xsl:call-template>
                                    <xsl:choose>
                                        <xsl:when test="$v_string-following-first-letter = 'i'">
                                            <xsl:element name="tei:c">
                                                <xsl:attribute name="xml:lang" select="'ar'"/>
                                                <xsl:text>ئ</xsl:text>
                                            </xsl:element>
                                            <xsl:call-template name="f-2_string-arabic-split-radicals">
                                                <xsl:with-param name="p_input" select="$v_string-following-remainder"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:when test="$v_string-following-first-letter = 'ī'">
                                            <xsl:element name="tei:c">
                                                <xsl:attribute name="xml:lang" select="'ar'"/>
                                                <xsl:text>ئ</xsl:text>
                                            </xsl:element>
                                            <xsl:call-template name="f-2_string-arabic-split-radicals">
                                                <xsl:with-param name="p_input" select="$v_string-following"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:when test="$v_string-following-first-letter = 'u'">
                                            <xsl:element name="tei:c">
                                                <xsl:attribute name="xml:lang" select="'ar'"/>
                                                <xsl:text>ؤ</xsl:text>
                                            </xsl:element>
                                            <xsl:call-template name="f-2_string-arabic-split-radicals">
                                                <xsl:with-param name="p_input" select="$v_string-following-remainder"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:when test="$v_string-following-first-letter = 'ū'">
                                            <xsl:element name="tei:c">
                                                <xsl:attribute name="xml:lang" select="'ar'"/>
                                                <xsl:text>ؤ</xsl:text>
                                            </xsl:element>
                                            <xsl:call-template name="f-2_string-arabic-split-radicals">
                                                <xsl:with-param name="p_input" select="$v_string-following"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:when test="$v_string-following-first-letter = 'ā'">
                                            <xsl:element name="tei:c">
                                                <xsl:attribute name="xml:lang" select="'ar'"/>
                                                <xsl:text>ء</xsl:text>
                                            </xsl:element>
                                            <xsl:call-template name="f-2_string-arabic-split-radicals">
                                                <xsl:with-param name="p_input" select="$v_string-following"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:when>
                                <!-- hamza following i or ī -->
                                <xsl:when test="$v_string-preceding-end = 'i' or $v_string-preceding-end = 'ī'">
                                    <xsl:if test="$p_debug = true()">
                                        <xsl:message>
                                            <xsl:text>hamza follows i or ī</xsl:text>
                                        </xsl:message>
                                    </xsl:if>
                                    <xsl:call-template name="f-2_string-arabic-split-radicals">
                                        <xsl:with-param name="p_input" select="$v_string-preceding"/>
                                    </xsl:call-template>
                                    <xsl:choose>
                                        <xsl:when test="$v_string-following-first-letter = 'i' or $v_string-following-first-letter = 'a'">
                                            <xsl:if test="$p_debug = true()">
                                                <xsl:message>
                                                    <xsl:text>hamza is followed by i or a</xsl:text>
                                                </xsl:message>
                                            </xsl:if>
                                            <xsl:element name="tei:c">
                                                <xsl:attribute name="xml:lang" select="'ar'"/>
                                                <xsl:text>ئ</xsl:text>
                                            </xsl:element>
                                            <xsl:call-template name="f-2_string-arabic-split-radicals">
                                                <xsl:with-param name="p_input" select="$v_string-following-remainder"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:if test="$p_debug = true()">
                                                <xsl:message>
                                                    <xsl:text>hamza is followed by u or consonant</xsl:text>
                                                </xsl:message>
                                            </xsl:if>
                                            <xsl:element name="tei:c">
                                                <xsl:attribute name="xml:lang" select="'ar'"/>
                                                <xsl:text>ئ</xsl:text>
                                            </xsl:element>
                                            <xsl:call-template name="f-2_string-arabic-split-radicals">
                                                <xsl:with-param name="p_input" select="$v_string-following"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:when test="$v_string-preceding-end = 'u' or $v_string-preceding-end = 'ū'">
                                    <xsl:if test="$p_debug = true()">
                                        <xsl:message>
                                            <xsl:text>hamza follows u or ū</xsl:text>
                                        </xsl:message>
                                    </xsl:if>
                                    <xsl:call-template name="f-2_string-arabic-split-radicals">
                                        <xsl:with-param name="p_input" select="$v_string-preceding"/>
                                    </xsl:call-template>
                                    <xsl:element name="tei:c">
                                        <xsl:attribute name="xml:lang" select="'ar'"/>
                                        <xsl:text>ؤ</xsl:text>
                                    </xsl:element>
                                    <xsl:call-template name="f-2_string-arabic-split-radicals">
                                        <xsl:with-param name="p_input" select="$v_string-following"/>
                                    </xsl:call-template>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:when>
                <!-- check for numbers -->
                <xsl:when test="$p_input castable as xs:double">
                    <!--<xsl:message>
                    <xsl:value-of select="$p_input"/>
                    <xsl:text> is a number</xsl:text>
                </xsl:message>-->
                    <xsl:for-each select="$p_input">
                        <xsl:call-template name="f-4_string-arabic-transliterate-single-characters">
                            <xsl:with-param name="p_input" select="."/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <!-- split at short vowels -->
                    <xsl:for-each select="tokenize($p_input, '([aui])')">
                        <xsl:choose>
                            <!-- transliterate single consonants -->
                            <xsl:when test="string-length(.) = 1">
                                <xsl:call-template name="f-4_string-arabic-transliterate-single-characters">
                                    <xsl:with-param name="p_input" select="."/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- split strings at long vowels, single consonants are immediately transliterated -->
                                <xsl:analyze-string regex="(\w*)([āūī])(\w*)" select=".">
                                    <xsl:matching-substring>
                                        <!-- the string contanis long vowls -->
                                        <!--<xsl:message>
                                        <xsl:text>the string contains long vowels</xsl:text>
                                    </xsl:message>-->
                                        <xsl:choose>
                                            <xsl:when test="string-length(regex-group(1)) = 1">
                                                <xsl:call-template name="f-4_string-arabic-transliterate-single-characters">
                                                    <xsl:with-param name="p_input" select="regex-group(1)"/>
                                                </xsl:call-template>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:call-template name="f-2_string-arabic-split-radicals">
                                                    <xsl:with-param name="p_input" select="regex-group(1)"/>
                                                </xsl:call-template>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:call-template name="f-4_string-arabic-transliterate-single-characters">
                                            <xsl:with-param name="p_input" select="regex-group(2)"/>
                                        </xsl:call-template>
                                        <xsl:choose>
                                            <xsl:when test="string-length(regex-group(3)) = 1">
                                                <xsl:call-template name="f-4_string-arabic-transliterate-single-characters">
                                                    <xsl:with-param name="p_input" select="regex-group(3)"/>
                                                </xsl:call-template>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:call-template name="f-2_string-arabic-split-radicals">
                                                    <xsl:with-param name="p_input" select="regex-group(3)"/>
                                                </xsl:call-template>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:matching-substring>
                                    <xsl:non-matching-substring>
                                        <!-- the string does not contain long vowels -->
                                        <xsl:choose>
                                            <xsl:when test="string-length(.) = 2">
                                                <xsl:call-template name="f-3_string-arabic-transliterate-double-characters">
                                                    <xsl:with-param name="p_input" select="."/>
                                                </xsl:call-template>
                                            </xsl:when>
                                            <!-- how to deal with strings of more then 2 consonants? -->
                                            <!-- let us assume that a string of 4 consonants of the pattern abab stands for a single Arabic letter with a shadda -->
                                            <xsl:when test="string-length(.) = 4 and substring(., 1, 2) = substring(., 3, 2)">
                                                <xsl:call-template name="f-3_string-arabic-transliterate-double-characters">
                                                    <xsl:with-param name="p_input" select="substring(., 1, 2)"/>
                                                </xsl:call-template>
                                            </xsl:when>
                                            <xsl:when test="string-length(.) = 3">
                                                <!-- check if the first two letters fit a single letter: f-3_string-arabic-transliterate-double-characters returns a single tei:w node -->
                                                <xsl:variable name="vFirstTwoLetters">
                                                    <xsl:call-template name="f-3_string-arabic-transliterate-double-characters">
                                                        <xsl:with-param name="p_input" select="substring(., 1, 2)"/>
                                                    </xsl:call-template>
                                                </xsl:variable>
                                                <xsl:choose>
                                                    <xsl:when test="count($vFirstTwoLetters/tei:c) = 1">
                                                        <xsl:copy-of select="$vFirstTwoLetters/tei:c"/>
                                                        <xsl:call-template name="f-4_string-arabic-transliterate-single-characters">
                                                            <xsl:with-param name="p_input" select="substring(., 3, 1)"/>
                                                        </xsl:call-template>
                                                    </xsl:when>
                                                    <!-- otherwise it must be the other way around as there are no combinations of three Arabic consonants without a vowel -->
                                                    <xsl:otherwise>
                                                        <xsl:call-template name="f-4_string-arabic-transliterate-single-characters">
                                                            <xsl:with-param name="p_input" select="substring(., 1, 1)"/>
                                                        </xsl:call-template>
                                                        <xsl:call-template name="f-3_string-arabic-transliterate-double-characters">
                                                            <xsl:with-param name="p_input" select="substring(., 2, 2)"/>
                                                        </xsl:call-template>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:message error-code="1">
                                                    <xsl:text>The string "</xsl:text>
                                                    <xsl:value-of select="."/>
                                                    <xsl:text>" comprises more than 2 consonants</xsl:text>
                                                </xsl:message>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:non-matching-substring>
                                </xsl:analyze-string>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$p_debug = true()">
            <xsl:message>
                <xsl:text>output of splitting and transliteration: </xsl:text>
                <xsl:for-each select="$v_output/tei:c">
                    <xsl:value-of select="."/>
                    <xsl:if test="position() != last()">
                        <xsl:text> | </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:message>
        </xsl:if>
        <xsl:copy-of select="$v_output"/>
    </xsl:template>
    <xsl:template name="f-3_string-arabic-transliterate-double-characters">
        <xsl:param name="p_input"/>
        <xsl:if test="$p_debug = true()">
            <xsl:message>
                <xsl:text># f3: transliterate double characters</xsl:text>
            </xsl:message>
            <xsl:message>
                <xsl:text>$p_input: </xsl:text>
                <xsl:value-of select="$p_input"/>
            </xsl:message>
        </xsl:if>
        <xsl:variable name="v_output">
            <xsl:choose>
                <xsl:when test="$p_input = 'th'">
                    <xsl:element name="tei:c">
                        <xsl:attribute name="xml:lang" select="'ar'"/>
                        <xsl:text>ث</xsl:text>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="$p_input = 'dh'">
                    <xsl:element name="tei:c">
                        <xsl:attribute name="xml:lang" select="'ar'"/>
                        <xsl:text>ذ</xsl:text>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="$p_input = 'gh'">
                    <xsl:element name="tei:c">
                        <xsl:attribute name="xml:lang" select="'ar'"/>
                        <xsl:text>غ</xsl:text>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="$p_input = 'kh'">
                    <xsl:element name="tei:c">
                        <xsl:attribute name="xml:lang" select="'ar'"/>
                        <xsl:text>خ</xsl:text>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="$p_input = 'sh'">
                    <xsl:element name="tei:c">
                        <xsl:attribute name="xml:lang" select="'ar'"/>
                        <xsl:text>ش</xsl:text>
                    </xsl:element>
                </xsl:when>
                <!-- dealing with shadda -->
                <xsl:when test="substring($p_input, 1, 1) = substring($p_input, 2, 1)">
                    <xsl:call-template name="f-4_string-arabic-transliterate-single-characters">
                        <xsl:with-param name="p_input" select="substring($p_input, 1, 1)"/>
                    </xsl:call-template>
                </xsl:when>
                <!-- otherwise it is reasonable to assume that the string represents two single characters -->
                <xsl:otherwise>
                    <xsl:if test="$p_debug = true()">
                        <xsl:message>
                            <xsl:text>the input most likely contains two Arabic characters </xsl:text>
                        </xsl:message>
                    </xsl:if>
                    <xsl:call-template name="f-4_string-arabic-transliterate-single-characters">
                        <xsl:with-param name="p_input" select="substring($p_input, 1, 1)"/>
                    </xsl:call-template>
                    <xsl:call-template name="f-4_string-arabic-transliterate-single-characters">
                        <xsl:with-param name="p_input" select="substring($p_input, 2, 1)"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$p_debug = true()">
            <xsl:message>
                <xsl:text>$v_output: </xsl:text>
                <xsl:value-of select="$v_output"/>
            </xsl:message>
        </xsl:if>
        <xsl:copy-of select="$v_output"/>
    </xsl:template>
    <xsl:template name="f-4_string-arabic-transliterate-single-characters">
        <xsl:param name="p_input"/>
        <xsl:if test="$p_debug = true()">
            <xsl:message>
                <xsl:text># f4: transliterate single characters</xsl:text>
            </xsl:message>
            <xsl:message>
                <xsl:text>$p_input: </xsl:text>
                <xsl:value-of select="$p_input"/>
            </xsl:message>
        </xsl:if>
        <xsl:variable name="v_output">
            <xsl:choose>
                <xsl:when test="contains($v_string-transcribe-ijmes-from, $p_input)">
                    <xsl:element name="tei:c">
                        <xsl:attribute name="xml:lang" select="'ar'"/>
                        <xsl:value-of select="translate($p_input, $v_string-transcribe-ijmes-from, $v_string-transcribe-arabic-to)"/>
                    </xsl:element>
                </xsl:when>
                <!-- input is not part of the Arabic alphabet -->
                <xsl:otherwise>
                    <xsl:message error-code="3">
                        <xsl:text>the letter "</xsl:text>
                        <xsl:value-of select="$p_input"/>
                        <xsl:text>" is not part of the Arabic alphabet</xsl:text>
                        <xsl:element name="tei:c">
                            <xsl:attribute name="xml:lang" select="'und-Latn'"/>
                            <xsl:value-of select="$p_input"/>
                        </xsl:element>
                    </xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$p_debug = true()">
            <xsl:message>
                <xsl:text>$v_output: </xsl:text>
                <xsl:value-of select="$v_output"/>
            </xsl:message>
        </xsl:if>
        <xsl:copy-of select="$v_output"/>
    </xsl:template>
    <!-- input: string -->
    <!-- output: mixed content with TEI mark-up for words and punctuation marks -->
    <xsl:function name="oape:string-mark-up-tokens">
        <xsl:param as="xs:string" name="p_input"/>
        <xsl:message>
            <xsl:text># oape:string-mark-up-tokens</xsl:text>
        </xsl:message>
        <xsl:message>
            <xsl:text>$p_input: </xsl:text>
            <xsl:value-of select="$p_input"/>
        </xsl:message>
        <!-- periods and dashes are included in the word tokens, as they could mark abbreviations or the Arabic article "al-" -->
        <!-- ([\w]+[\.&apos;\-]*[\w]+[\.]*) -->
        <xsl:if test="$p_debug = true()">
            <xsl:message>
                <xsl:text>1. tokenizing along whitespace and punctuation marks</xsl:text>
            </xsl:message>
        </xsl:if>
        <xsl:analyze-string regex="([\w\.&apos;:\-]+)" select="$p_input">
            <!-- consider the first group to be a word -->
            <xsl:matching-substring>
                <xsl:variable name="v_regex-1" select="regex-group(1)"/>
                <xsl:if test="$p_debug = true()">
                    <xsl:message>
                        <xsl:text>2. tokenizing "</xsl:text>
                        <xsl:value-of select="$v_regex-1"/>
                        <xsl:text>" into words, punctuation marks, and whitespace</xsl:text>
                    </xsl:message>
                </xsl:if>
                <xsl:analyze-string regex="^(\w+)([\.&apos;:\-])(\w?)$" select="$v_regex-1">
                    <xsl:matching-substring>
                        <xsl:if test="$p_debug = true()">
                            <xsl:message>
                                <xsl:text>"</xsl:text>
                                <xsl:value-of select="regex-group(1)"/>
                                <xsl:text> | </xsl:text>
                                <xsl:value-of select="regex-group(2)"/>
                                <xsl:text> | </xsl:text>
                                <xsl:value-of select="regex-group(3)"/>
                                <xsl:text>"</xsl:text>
                            </xsl:message>
                        </xsl:if>
                        <xsl:element name="tei:w">
                            <xsl:value-of select="regex-group(1)"/>
                        </xsl:element>
                        <xsl:element name="tei:pc">
                            <xsl:value-of select="regex-group(2)"/>
                        </xsl:element>
                        <xsl:if test="regex-group(3) != ''">
                            <xsl:element name="tei:w">
                                <xsl:value-of select="regex-group(3)"/>
                            </xsl:element>
                        </xsl:if>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:element name="tei:w">
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <!-- consider the first group to be a punctuation mark -->
                <xsl:analyze-string regex="([,;\.–—\(\)&apos;:\[\]&lt;&gt;])" select=".">
                    <xsl:matching-substring>
                        <xsl:element name="tei:pc">
                            <xsl:value-of select="regex-group(1)"/>
                        </xsl:element>
                    </xsl:matching-substring>
                    <!-- the remnants should be whitespaces only -->
                    <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
</xsl:stylesheet>
