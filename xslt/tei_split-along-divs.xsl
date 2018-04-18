<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xi="http://www.w3.org/2001/XInclude">
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>
    
    <!-- this stylesheet divides a TEI XML file into smaller files along the <div> children of  <body> and links them together by means of XPointers-->
    
    <xsl:variable name="v_file-name-base">
        <xsl:value-of select="substring-before(base-uri(),'.TEIP5')"/>
    </xsl:variable>
    
    <!-- idendity transform -->
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/">
        <xsl:result-document href="{$v_file-name-base}-xpointer.TEIP5.xml">
            <xsl:copy>
                <xsl:apply-templates/>
            </xsl:copy>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="tei:body/tei:div">
        <!-- create a new file and an XPointer -->
        <xsl:variable name="v_position" select="count(preceding-sibling::tei:div)+1"/>
        <xsl:variable name="v_id-self" select="concat('div_',$v_position)"/>
        <xsl:variable name="v_file-name" select="concat($v_file-name-base,'-',$v_id-self,'.TEIP5.xml')"/>
        <xsl:result-document href="{$v_file-name}">
            <TEI>
                <xsl:attribute name="xml:id" select="concat($v_file-name-base,'-',$v_id-self)"/>
                <xsl:attribute name="next" select="concat($v_file-name-base,'-div_',$v_position + 1)"/>
                <xsl:attribute name="prev" select="concat($v_file-name-base,'-div_',$v_position - 1)"/>
                <!-- replicate the teiHeader of the source file -->
                <xsl:apply-templates select="ancestor::tei:TEI/tei:teiHeader"/>
                <text>
                    <body>
                        <xsl:copy>
                            <xsl:apply-templates select="@*"/>
                            <xsl:attribute name="type" select="'section'"/>
                            <xsl:apply-templates select="node()"/>
                        </xsl:copy>
                    </body>
                </text>
            </TEI>
        </xsl:result-document>
        <!-- XPointer -->
        <xi:include href="{$v_file-name}" xpointer="{$v_id-self}" parse="xml"/>
    </xsl:template>

</xsl:stylesheet>
