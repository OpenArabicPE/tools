<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:oape="https://openarabicpe.github.io/ns">
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="no" name="xml-split"/>
    
    <!-- this stylesheet divides a TEI XML file into smaller files along the <div> children of  <body> and links them together by means of XPointers-->
    
    <!--<xsl:include href="functions.xsl"/>-->
<!--    <xsl:include href="../../authority-files/xslt/functions.xsl"/>-->
    <xsl:include href="../../convert_tei-to-bibliographic-data/xslt/convert_tei-to-biblstruct_functions.xsl"/>
    <xsl:param name="p_base-url" select="replace(base-uri(),'(^.+)/[^/]+$', '$1')"/>
    <xsl:param name="p_target-folder" select="concat($p_base-url,'/_output/split')"/>
    <xsl:variable name="v_file-name-base"  select="substring-after(base-uri(), $p_base-url)"/>
    
    <!-- idendity transform -->
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/">
        <xsl:result-document href="{$p_target-folder}/{$v_file-name-base}">
            <xsl:copy>
                <xsl:apply-templates/>
            </xsl:copy>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="tei:body//tei:div[@type = 'item']">
        <!-- bibliographic information for this div -->
        <xsl:variable name="v_bibl" select="oape:bibliography-tei-div-to-biblstruct(.)"/>
        <!-- create a new file and an XPointer -->
        <!-- the file name can be pulled from the BibTeX key for this div in $v_bibl -->
        <xsl:variable name="v_position" select="count(preceding::tei:div)+1"/>
        <xsl:variable name="v_id-self" select="concat('div_',$v_position)"/>
        <xsl:variable name="v_file-name" select="concat($v_file-name-base,'-',$v_id-self,'.TEIP5.xml')"/>
        <xsl:variable name="v_target-folder" select="concat($p_target-folder,'/parts')"/>
        <xsl:result-document href="{$v_target-folder}/{$v_file-name}" format="xml-split">
            <TEI>
                <xsl:attribute name="xml:id" select="concat($v_file-name-base,'-',$v_id-self)"/>
                <xsl:attribute name="next" select="concat($v_file-name-base,'-div_',$v_position + 1)"/>
                <xsl:attribute name="prev" select="concat($v_file-name-base,'-div_',$v_position - 1)"/>
                <!-- replicate the teiHeader of the source file -->
<!--                <xsl:apply-templates select="ancestor::tei:TEI/tei:teiHeader"/>-->
                <teiHeader>
                    <sourceDesc>
                        <xsl:copy-of select="$v_bibl"/>
                    </sourceDesc>
                </teiHeader>
                <text>
                    <body>
                        <xsl:copy>
                            <xsl:apply-templates select="@*"/>
                           <!-- replicate content -->
<!--                            <xsl:apply-templates select="node()"/>-->
                        </xsl:copy>
                    </body>
                </text>
            </TEI>
        </xsl:result-document>
        <!-- XPointer -->
        <xi:include href="{$v_file-name}" xpointer="{$v_id-self}" parse="xml"/>
    </xsl:template>

</xsl:stylesheet>
