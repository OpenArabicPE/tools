<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs" version="2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:oape="https://openarabicpe.github.io/ns" xmlns:tei="http://www.tei-c.org/ns/1.0">
    <!-- source; http://www.jenitennison.com/2007/05/03/levenshtein-distance-in-xslt-2-0.html -->
    
    <!-- test the function -->
    <!--<xsl:template match="/">
        <xsl:copy-of select="oape:LevenshteinDistanceA(descendant::tei:title[2], descendant::tei:title[3])"/>
    </xsl:template>-->
    
    <xsl:function as="xs:integer" name="oape:LevenshteinDistanceA">
        <xsl:param as="xs:string" name="string1"/>
        <xsl:param as="xs:string" name="string2"/>
        <xsl:sequence select="
                oape:LevenshteinDistanceB(string-to-codepoints($string1), string-to-codepoints($string2), 1, 1, for $p in (0 to string-length($string1))
                return
                    $p, 1)"/>
    </xsl:function>
    <xsl:function as="xs:integer" name="oape:LevenshteinDistanceB">
        <xsl:param as="xs:integer+" name="chars1"/>
        <xsl:param as="xs:integer+" name="chars2"/>
        <xsl:param as="xs:integer" name="i1"/>
        <xsl:param as="xs:integer" name="i2"/>
        <xsl:param as="xs:integer+" name="lastRow"/>
        <xsl:param as="xs:integer+" name="thisRow"/>
        <xsl:choose>
            <xsl:when test="$i1 > count($chars1)">
                <xsl:choose>
                    <xsl:when test="$i2 = count($chars2)">
                        <xsl:sequence select="$thisRow[last()]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="oape:LevenshteinDistanceB($chars1, $chars2, 1, $i2 + 1, $thisRow, ($i2 + 1))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable as="xs:integer" name="char1" select="$chars1[$i1]"/>
                <xsl:variable as="xs:integer" name="char2" select="$chars2[$i2]"/>
                <xsl:variable as="xs:integer" name="deletion" select="$lastRow[$i1 + 1] + 1"/>
                <xsl:variable as="xs:integer" name="insertion" select="$thisRow[last()] + 1"/>
                <xsl:variable as="xs:integer" name="substitution" select="
                        $lastRow[$i1] + (if ($char1 eq $char2) then
                            0
                        else
                            1)"/>
                <xsl:variable name="cost" select="min(($deletion, $insertion, $substitution))"/>
                <xsl:sequence select="oape:LevenshteinDistanceB($chars1, $chars2, $i1 + 1, $i2, $lastRow, ($thisRow, $cost))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
