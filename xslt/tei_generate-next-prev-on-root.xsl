<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs xd" version="2.0" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:output encoding="UTF-8" indent="no" method="xml" name="xml" omit-xml-declaration="no"
        version="1.0"/>
    <xsl:param name="p_consecutive-file-names" select="true()"/>
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:TEI">
        <xsl:variable name="v_bibl-source"
            select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct"/>
        <xsl:variable name="v_volume"
            select="$v_bibl-source/tei:monogr/tei:biblScope[@unit = 'volume']/@from"/>
        <xsl:variable name="v_issue"
            select="$v_bibl-source/tei:monogr/tei:biblScope[@unit = 'issue']/@from"/>
        <xsl:variable name="v_oclc"
            select="concat('oclc_', $v_bibl-source/tei:monogr/tei:idno[@type = 'OCLC'][1])"/>
        <xsl:variable name="v_file-name" select="number(replace(base-uri(),'.+-i_(\d+).+$','$1'))"/>
        <xsl:variable name="v_file-extension" select="'.TEIP5.xml'"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="$p_consecutive-file-names = false()">
                    <xsl:attribute name="next">
                        <xsl:choose>
                            <xsl:when test="$v_issue = 12">
                                <xsl:value-of
                                    select="concat($v_oclc, '-v_', $v_volume + 1, '-i_1', $v_file-extension)"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="concat($v_oclc, '-v_', $v_volume, '-i_', $v_issue + 1, $v_file-extension)"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="$v_volume = 1 and $v_issue = 1"/>
                        <xsl:when test="$v_issue = 1">
                            <xsl:attribute name="prev"
                                select="concat($v_oclc, '-v_', $v_volume - 1, '-i_', $v_issue - 1, $v_file-extension)"
                            />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="prev"
                                select="concat($v_oclc, '-v_', $v_volume, '-i_', $v_issue - 1, $v_file-extension)"
                            />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$p_consecutive-file-names = true()">
                    <xsl:attribute name="next"
                        select="concat($v_oclc, '-i_', $v_file-name + 1, $v_file-extension)"/>
                    <xsl:attribute name="prev"
                        select="concat($v_oclc, '-i_', $v_file-name - 1, $v_file-extension)"
                    />
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
