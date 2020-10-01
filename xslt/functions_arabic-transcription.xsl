<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"  
    xmlns:oape="https://openarabicpe.github.io/ns"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    
    <!-- the templates/ functions in this stylesheet aim at automatic re-translation from Arabic in Latin transcription to Arabic in Arabic script -->
    <!-- in order to work, this stylesheet needs to be loaded from functions_core.xsl -->
    
    <!-- the templates assume the IJMES system of transcription -->
    
    <!-- Issues:
        1. sequences of more than one Latin consonant: i.e. kht in ikhtlāf or dhdh in kadhdhāb
         -->
    
    <xsl:variable name="v_string-transcribe-ijmes-from" select="'btḥḫjdrzsṣḍṭẓʿfqklmnhāūīwy0123456789'"/>
    <xsl:variable name="v_string-transcribe-arabic-to" select="'بتحخجدرزسصضطظعفقكلمنهاويوي٠١٢٣٤٥٦٧٨٩'"/>
    
    <xsl:function name="oape:string-transliterate-ijmes-to-arabic">
        <xsl:param name="pInput" as="xs:string"/>
        <!--<xsl:message>
            <xsl:value-of select="$pInput"/>
        </xsl:message>-->
        <xsl:variable name="vTokens">
            <xsl:call-template name="funcStringTokenize">
                <xsl:with-param name="pInput" select="$pInput"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:for-each select="$vTokens/child::node()">
            <xsl:choose>
                <xsl:when test="self::tei:w">
                    <xsl:variable name="vWord">
                        <xsl:call-template name="funcStringArabicArticleGender">
                            <xsl:with-param name="pInput" select="."/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:choose>
                        <!-- reassemble all words from right to left  -->
                        <xsl:when test="$vWord//tei:c[@xml:lang='ar']">
                            <xsl:message>
                                <xsl:text>Assemble word: </xsl:text>
                                <xsl:value-of select="$vWord"/>
                            </xsl:message>
                            <xsl:element name="tei:w">
                                <xsl:attribute name="xml:lang" select="'ar'"/>
                                <!--<xsl:for-each select="$vWord//tei:c">
                        <xsl:sort order="ascending" select="position()"/>
                        <xsl:value-of select="."/>
                    </xsl:for-each>-->
                                <xsl:value-of select="$vWord"/>
                            </xsl:element>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:template name="funcStringArabicArticleGender">
        <xsl:param name="pInput"/>
        <xsl:analyze-string regex="(\w+)\-(\w+)" select="lower-case($pInput)">
            <xsl:matching-substring>
                <xsl:message>
                    <xsl:text>determined article</xsl:text>
                </xsl:message>
                <xsl:choose>
                    <xsl:when test="regex-group(1)='al' or 'el' or 'ad' or 'ed'">
                        <xsl:element name="tei:c">
                            <xsl:attribute name="xml:lang" select="'ar'"/>
                            <xsl:text>ا</xsl:text>
                        </xsl:element>
                        <xsl:element name="tei:c">
                            <xsl:attribute name="xml:lang" select="'ar'"/>
                            <xsl:text>ل</xsl:text>
                        </xsl:element>
                    </xsl:when>
                    <!-- otherwise not implemented -->
                    <xsl:otherwise></xsl:otherwise>
                </xsl:choose>
                <xsl:message>
                    <xsl:text>followed by </xsl:text>
                    <xsl:value-of select="regex-group(2)"/>
                </xsl:message>
                <!-- Problem: if we loop the input through funcStringTranscribeIjmesToArabic, it is lost somewhere down the line -->
                <xsl:call-template name="funcStringArabicArticleGender">
                    <xsl:with-param name="pInput" select="regex-group(2)"/>
                </xsl:call-template>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <!-- tāʾ marbūṭa should be dealt with here. I presume there is no word of two letters ending with it -->
                <xsl:analyze-string select="." regex="\w\w+at*$">
                    <xsl:matching-substring>
                        <xsl:message>
                            <xsl:text>word ends in tāʾ marbūṭa</xsl:text>
                        </xsl:message>
                        <xsl:call-template name="funcStringArabicSplitRadicals">
                            <xsl:with-param name="pInput" select="substring(.,1,string-length(.)-1)"/>
                        </xsl:call-template>
                        <xsl:element name="tei:c">
                            <xsl:attribute name="xml:lang" select="'ar'"/>
                            <xsl:text>ة</xsl:text>
                        </xsl:element>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:call-template name="funcStringArabicSplitRadicals">
                            <xsl:with-param name="pInput" select="."/>
                        </xsl:call-template>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <!-- this template takes individual words as input and splits them into syllables / radicals -->
    <xsl:template name="funcStringArabicSplitRadicals">
        <xsl:param name="pInput"/>
        <xsl:message>
            <xsl:text>Input funcStringArabicSplitRadicals: </xsl:text>
            <xsl:value-of select="$pInput"/>
        </xsl:message>
        <!-- starting hamza -->
        <xsl:choose>
            <xsl:when test="starts-with($pInput,'i')">
                <xsl:element name="tei:c">
                    <xsl:attribute name="xml:lang" select="'ar'"/>
                    <xsl:text>ا</xsl:text>
                </xsl:element>
                <xsl:call-template name="funcStringArabicSplitRadicals">
                    <xsl:with-param name="pInput" select="substring($pInput,2)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="starts-with($pInput,'a')">
                <xsl:element name="tei:c">
                    <xsl:attribute name="xml:lang" select="'ar'"/>
                    <xsl:text>ا</xsl:text>
                </xsl:element>
                <xsl:call-template name="funcStringArabicSplitRadicals">
                    <xsl:with-param name="pInput" select="substring($pInput,2)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="starts-with($pInput,'u')">
                <xsl:element name="tei:c">
                    <xsl:attribute name="xml:lang" select="'ar'"/>
                    <xsl:text>ا</xsl:text>
                </xsl:element>
                <xsl:call-template name="funcStringArabicSplitRadicals">
                    <xsl:with-param name="pInput" select="substring($pInput,2)"/>
                </xsl:call-template>
            </xsl:when>
            <!-- hamza in the middle or at the end of a word -->
            <xsl:when test="contains($pInput,'ʾ')">
                <xsl:message>
                    <xsl:text>string contains hamza</xsl:text>
                </xsl:message>
                <xsl:analyze-string select="$pInput" regex="(\w*)ʾ(\w*)">
                    <xsl:matching-substring>
                        <xsl:variable name="vPrecedingStringLength" select="string-length(regex-group(1))"/>
                        <xsl:variable name="vPrecedingString" select="regex-group(1)"/>
                        <xsl:variable name="vPrecedingStringEnd" select="substring($vPrecedingString,$vPrecedingStringLength)"/>
                        <xsl:variable name="vFollowingString" select="regex-group(2)"/>
                        <xsl:variable name="vFollowingStringBeginning" select="substring($vFollowingString,1,1)"/>
                        <xsl:variable name="vFollowingStringRemainder" select="substring($vFollowingString,2)"/>
                        <xsl:message>
                            <xsl:text>hamza follows </xsl:text>
                            <xsl:value-of select="$vPrecedingString"/>
                            <xsl:text> and is followed by </xsl:text>
                            <xsl:value-of select="$vFollowingString"/>
                        </xsl:message>
                        <xsl:choose>
                            <!-- trailing hamza -->
                            <xsl:when test="regex-group(2)=''">
                                <xsl:message>
                                    <xsl:text>trailing hamza</xsl:text>
                                </xsl:message>
                                <xsl:call-template name="funcStringArabicSplitRadicals">
                                    <xsl:with-param name="pInput" select="$vPrecedingString"/>
                                </xsl:call-template>
                                <xsl:element name="tei:c">
                                    <xsl:attribute name="xml:lang" select="'ar'"/>
                                    <xsl:text>ء</xsl:text>
                                </xsl:element>
                            </xsl:when>
                            <!-- hamza following a or ā -->
                            <xsl:when test="$vPrecedingStringEnd = 'a' or $vPrecedingStringEnd = 'ā'">
                                <xsl:message>
                                    <xsl:text>hamza follows a or ā</xsl:text>
                                </xsl:message>
                                <xsl:call-template name="funcStringArabicSplitRadicals">
                                    <xsl:with-param name="pInput" select="$vPrecedingString"/>
                                </xsl:call-template>
                                
                                <xsl:choose>
                                    <xsl:when test="$vFollowingStringBeginning = 'i'">
                                        <xsl:element name="tei:c">
                                    <xsl:attribute name="xml:lang" select="'ar'"/>
                                    <xsl:text>ئ</xsl:text>
                                </xsl:element>
                                        <xsl:call-template name="funcStringArabicSplitRadicals">
                                            <xsl:with-param name="pInput" select="$vFollowingStringRemainder"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:when test="$vFollowingStringBeginning = 'ī'">
                                        <xsl:element name="tei:c">
                                            <xsl:attribute name="xml:lang" select="'ar'"/>
                                            <xsl:text>ئ</xsl:text>
                                        </xsl:element>
                                        <xsl:call-template name="funcStringArabicSplitRadicals">
                                            <xsl:with-param name="pInput" select="$vFollowingString"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:when test="$vFollowingStringBeginning = 'u'">
                                        <xsl:element name="tei:c">
                                            <xsl:attribute name="xml:lang" select="'ar'"/>
                                            <xsl:text>ؤ</xsl:text>
                                        </xsl:element>
                                        <xsl:call-template name="funcStringArabicSplitRadicals">
                                            <xsl:with-param name="pInput" select="$vFollowingStringRemainder"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:when test="$vFollowingStringBeginning = 'ū'">
                                        <xsl:element name="tei:c">
                                            <xsl:attribute name="xml:lang" select="'ar'"/>
                                            <xsl:text>ؤ</xsl:text>
                                        </xsl:element>
                                        <xsl:call-template name="funcStringArabicSplitRadicals">
                                            <xsl:with-param name="pInput" select="$vFollowingString"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:when>
                            <!-- hamza following i or ī -->
                            <xsl:when test="$vPrecedingStringEnd = 'i' or $vPrecedingStringEnd = 'ī'">
                                <xsl:message>
                                    <xsl:text>hamza follows i or ī</xsl:text>
                                </xsl:message>
                                <xsl:call-template name="funcStringArabicSplitRadicals">
                                    <xsl:with-param name="pInput" select="$vPrecedingString"/>
                                </xsl:call-template>
                                
                                <xsl:choose>
                                    <xsl:when test="$vFollowingStringBeginning = 'i' or $vFollowingStringBeginning = 'a'">
                                        <xsl:message>
                                            <xsl:text>hamza is followed by i or a</xsl:text>
                                        </xsl:message>
                                        <xsl:element name="tei:c">
                                            <xsl:attribute name="xml:lang" select="'ar'"/>
                                            <xsl:text>ئ</xsl:text>
                                        </xsl:element>
                                        <xsl:call-template name="funcStringArabicSplitRadicals">
                                            <xsl:with-param name="pInput" select="$vFollowingStringRemainder"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:message>
                                            <xsl:text>hamza is followed by u or consonant</xsl:text>
                                        </xsl:message>
                                        <xsl:element name="tei:c">
                                            <xsl:attribute name="xml:lang" select="'ar'"/>
                                            <xsl:text>ئ</xsl:text>
                                        </xsl:element>
                                        <xsl:call-template name="funcStringArabicSplitRadicals">
                                            <xsl:with-param name="pInput" select="$vFollowingString"/>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="$vPrecedingStringEnd = 'u' or $vPrecedingStringEnd = 'ū'">
                                <xsl:message>
                                    <xsl:text>hamza follows u or ū</xsl:text>
                                </xsl:message>
                                <xsl:call-template name="funcStringArabicSplitRadicals">
                                    <xsl:with-param name="pInput" select="$vPrecedingString"/>
                                </xsl:call-template>
                                    <xsl:element name="tei:c">
                                        <xsl:attribute name="xml:lang" select="'ar'"/>
                                        <xsl:text>ؤ</xsl:text>
                                    </xsl:element>
                                    <xsl:call-template name="funcStringArabicSplitRadicals">
                                        <xsl:with-param name="pInput" select="$vFollowingString"/>
                                    </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <!-- check for numbers -->
            <xsl:when test="$pInput castable as xs:double">
                <!--<xsl:message>
                    <xsl:value-of select="$pInput"/>
                    <xsl:text> is a number</xsl:text>
                </xsl:message>-->
                <xsl:for-each select="$pInput">
                    <xsl:call-template name="funcStringArabicTransliterateSingleCharacters">
                        <xsl:with-param name="pInput" select="."/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <!-- split at short vowels -->
                <xsl:for-each select="tokenize($pInput,'([aui])')">
                    <xsl:choose>
                        <!-- transliterate single consonants -->
                        <xsl:when test="string-length(.)=1">
                            <xsl:call-template name="funcStringArabicTransliterateSingleCharacters">
                                <xsl:with-param name="pInput" select="."/>
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
                                        <xsl:when test="string-length(regex-group(1))=1">
                                            <xsl:call-template
                                                name="funcStringArabicTransliterateSingleCharacters">
                                                <xsl:with-param name="pInput"
                                                    select="regex-group(1)"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="funcStringArabicSplitRadicals">
                                                <xsl:with-param name="pInput"
                                                    select="regex-group(1)"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:call-template
                                        name="funcStringArabicTransliterateSingleCharacters">
                                        <xsl:with-param name="pInput" select="regex-group(2)"/>
                                    </xsl:call-template>
                                    <xsl:choose>
                                        <xsl:when test="string-length(regex-group(3))=1">
                                            <xsl:call-template
                                                name="funcStringArabicTransliterateSingleCharacters">
                                                <xsl:with-param name="pInput"
                                                    select="regex-group(3)"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="funcStringArabicSplitRadicals">
                                                <xsl:with-param name="pInput"
                                                    select="regex-group(3)"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:matching-substring>
                                <xsl:non-matching-substring>
                                    <!-- the string does not contain long vowels -->
                                    <xsl:choose>
                                        <xsl:when test="string-length(.)=2">
                                            <xsl:call-template
                                                name="funcStringArabicTransliterateDoubleCharacters">
                                                <xsl:with-param name="pInput" select="."/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <!-- how to deal with strings of more then 2 consonants? -->
                                        <!-- let us assume that a string of 4 consonants of the pattern abab stands for a single Arabic letter with a shadda -->
                                        <xsl:when test="string-length(.)=4 and substring(.,1,2) = substring(.,3,2)">
                                            <xsl:call-template
                                                name="funcStringArabicTransliterateDoubleCharacters">
                                                <xsl:with-param name="pInput" select="substring(.,1,2)"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:when test="string-length(.)=3">
                                            <!-- check if the first two letters fit a single letter: funcStringArabicTransliterateDoubleCharacters returns a single tei:w node -->
                                            <xsl:variable name="vFirstTwoLetters">
                                                <xsl:call-template name="funcStringArabicTransliterateDoubleCharacters">
                                                    <xsl:with-param name="pInput" select="substring(.,1,2)"/>
                                                </xsl:call-template>
                                            </xsl:variable>
                                            <xsl:choose>
                                                <xsl:when test="count($vFirstTwoLetters/tei:c)=1">
                                                    <xsl:copy-of select="$vFirstTwoLetters/tei:c"/>
                                                    <xsl:call-template name="funcStringArabicTransliterateSingleCharacters">
                                                        <xsl:with-param name="pInput" select="substring(.,3,1)"/>
                                                    </xsl:call-template>
                                                </xsl:when>
                                                <!-- otherwise it must be the other way around as there are no combinations of three Arabic consonants without a vowel -->
                                                <xsl:otherwise>
                                                    <xsl:call-template name="funcStringArabicTransliterateSingleCharacters">
                                                        <xsl:with-param name="pInput" select="substring(.,1,1)"/>
                                                    </xsl:call-template>
                                                    <xsl:call-template name="funcStringArabicTransliterateDoubleCharacters">
                                                        <xsl:with-param name="pInput" select="substring(.,2,2)"/>
                                                    </xsl:call-template>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:message>
                                                <xsl:text>The string </xsl:text>
                                                <xsl:value-of select="."/>
                                                <xsl:text> comprises more than 2 consonants</xsl:text>
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
    </xsl:template>
    <xsl:template name="funcStringArabicTransliterateDoubleCharacters">
        <xsl:param name="pInput"/>
        <xsl:message>
            <xsl:text>Input funcStringArabicTransliterateDoubleCharacters: </xsl:text>
            <xsl:value-of select="$pInput"/>
        </xsl:message>
        <xsl:choose>
            <xsl:when test="$pInput='th'">
                <xsl:element name="tei:c">
                    <xsl:attribute name="xml:lang" select="'ar'"/>
                    <xsl:text>ث</xsl:text>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$pInput='dh'">
                <xsl:element name="tei:c">
                    <xsl:attribute name="xml:lang" select="'ar'"/>
                    <xsl:text>ذ</xsl:text>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$pInput='gh'">
                <xsl:element name="tei:c">
                    <xsl:attribute name="xml:lang" select="'ar'"/>
                    <xsl:text>غ</xsl:text>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$pInput='kh'">
                <xsl:element name="tei:c">
                    <xsl:attribute name="xml:lang" select="'ar'"/>
                    <xsl:text>خ</xsl:text>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$pInput='sh'">
                <xsl:element name="tei:c">
                    <xsl:attribute name="xml:lang" select="'ar'"/>
                    <xsl:text>ش</xsl:text>
                </xsl:element>
            </xsl:when>
            <!-- dealing with shadda -->
            <xsl:when test="substring($pInput,1,1) = substring($pInput,2,1)">
                <xsl:call-template name="funcStringArabicTransliterateSingleCharacters">
                    <xsl:with-param name="pInput" select="substring($pInput,1,1)"/>
                </xsl:call-template>
            </xsl:when>
            <!-- otherwise it is reasonable to assume that the string represents two single characters -->
            <xsl:otherwise>
                <xsl:call-template name="funcStringArabicTransliterateSingleCharacters">
                    <xsl:with-param name="pInput" select="substring($pInput,1,1)"/>
                </xsl:call-template>
                <xsl:call-template name="funcStringArabicTransliterateSingleCharacters">
                    <xsl:with-param name="pInput" select="substring($pInput,2,1)"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="funcStringArabicTransliterateSingleCharacters">
        <xsl:param name="pInput"/>
        <xsl:message>
            <xsl:text>Input funcStringArabicTransliterateSingleCharacters: </xsl:text>
            <xsl:value-of select="$pInput"/>
        </xsl:message>
        <xsl:element name="tei:c">
            <xsl:attribute name="xml:lang" select="'ar'"/>
            <xsl:value-of
                select="translate($pInput,$v_string-transcribe-ijmes-from,$v_string-transcribe-arabic-to)"/>
        </xsl:element>
    </xsl:template>
    
     <xsl:template name="funcStringTokenize">
        <xsl:param name="pInput"/>
        <!-- periods and dashes are included in the word tokens, as they could mark abbreviations or the Arabic article "al-" -->
        <!-- ([\w]+[\.&apos;\-]*[\w]+[\.]*) -->
        <xsl:analyze-string regex="([\w\.&apos;:\-]+)" select="$pInput">
            <!-- consider the first group to be a word -->
            <xsl:matching-substring>
                <xsl:analyze-string regex="(.+)([&apos;:\-])(\w?)$" select="regex-group(1)">
                    <xsl:matching-substring>
                        <xsl:element name="tei:w">
                            <xsl:value-of select="regex-group(1)"/>
                        </xsl:element>
                        <xsl:element name="tei:pc">
                            <xsl:value-of select="regex-group(2)"/>
                        </xsl:element>
                        <xsl:if test="regex-group(3)!=''">
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
    </xsl:template>
   
</xsl:stylesheet>