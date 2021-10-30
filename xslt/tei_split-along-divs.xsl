<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns="http://www.tei-c.org/ns/1.0" xmlns:oape="https://openarabicpe.github.io/ns" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output encoding="UTF-8" indent="yes" method="xml" name="xml-split" omit-xml-declaration="no" />
    <!-- this stylesheet divides a TEI XML file into smaller files along the <div> children of  <body> and links them together by means of XPointers-->
    <!--<xsl:include href="functions.xsl"/>-->
    <xsl:import href="../../authority-files/xslt/functions.xsl"/>
    <xsl:import href="../../convert_tei-to-bibliographic-data/xslt/convert_tei-to-biblstruct_functions.xsl"/>
    <xsl:param name="p_base-url" select="replace(base-uri(), '(^.+/)[^/]+$', '$1')"/>
    <xsl:param name="p_target-folder" select="'_output/split/'"/>
     <xsl:variable name="p_target-folder-for-divs" select="'divs/'"/>
    <xsl:variable name="v_file-name-base" select="substring-after(base-uri(), $p_base-url)"/>
    
    <!-- TO DO:
       
    -->
    
    <!-- idendity transform -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="/">
        <xsl:result-document href="{concat($p_base-url, $p_target-folder, $v_file-name-base)}">
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
        <xsl:variable name="v_position" select="count(preceding::tei:div) + 1"/>
        <xsl:variable name="v_id-self" select="$v_bibl/tei:analytic/tei:idno[@type = 'BibTeX'][1]"/>
        <xsl:variable name="v_file-name" select="concat($v_id-self, '.TEIP5.xml')"/>
        <xsl:variable name="v_path-to-file_absolute" select="concat($p_base-url, $p_target-folder, $p_target-folder-for-divs,  $v_file-name)"/>
        <xsl:variable name="v_path-to-file_relative" select="concat($p_target-folder-for-divs,  $v_file-name)"/>
        <xsl:result-document format="xml-split" href="{$v_path-to-file_absolute}">
            <!-- copy the linked schema files and stylesheets -->
            <xsl:apply-templates select="/processing-instruction()"/>
            <TEI>
                <xsl:attribute name="xml:id" select="$v_id-self"/>
                <xsl:attribute name="next" select="concat(oape:bibliography-tei-div-to-biblstruct(following::tei:div[@type = 'item'][1])/tei:analytic/tei:idno[@type = 'BibTeX'][1],'.TEIP5.xml')"/>
                <xsl:attribute name="prev" select="concat(oape:bibliography-tei-div-to-biblstruct(preceding::tei:div[@type = 'item'][1])/tei:analytic/tei:idno[@type = 'BibTeX'][1],'.TEIP5.xml')"/>
                <!-- replicate the teiHeader of the source file -->
                <!--                <xsl:apply-templates select="ancestor::tei:TEI/tei:teiHeader"/>-->
                <teiHeader>
                    <fileDesc>
                        <xsl:variable name="v_fileDesc" select="ancestor::tei:TEI/tei:teiHeader/tei:fileDesc"/>
                        <titleStmt>
                                <xsl:apply-templates select="$v_bibl/tei:analytic/tei:title" mode="m_no-ids"/>
                            <xsl:apply-templates select="$v_bibl/tei:analytic/tei:author" mode="m_no-ids"/>
                            <xsl:apply-templates select="$v_bibl/tei:monogr/tei:editor" mode="m_no-ids"/>
                            
                            <!-- copy author etc. from the source file -->
<!--                             <xsl:apply-templates mode="m_identity-transform" select="$v_fileDesc/tei:titleStmt/tei:author | $v_fileDesc/tei:titleStmt/tei:respStmt"/>-->
                            <xsl:apply-templates mode="m_identity-transform" select="$v_fileDesc/tei:titleStmt/tei:respStmt"/>
                        </titleStmt>
                        <publicationStmt>
                            <authority>
                                <xsl:apply-templates select="$p_editor//tei:persName" mode="m_no-ids"/>
                            </authority>
                                <xsl:apply-templates select="$v_fileDesc/tei:publicationStmt/tei:pubPlace" mode="m_no-ids"/>
                                <date when="{ year-from-date(current-date())}"><xsl:value-of select="year-from-date(current-date())"/></date>
                                <xsl:apply-templates select="$v_fileDesc/tei:publicationStmt/tei:availability" mode="m_no-ids"/>
                                <!-- this needs a new URL -->
                                <xsl:apply-templates select="$v_fileDesc/tei:publicationStmt/tei:idno" mode="m_no-ids"/>
                        </publicationStmt>
                        <sourceDesc>
                            <xsl:apply-templates select="$v_bibl" mode="m_split-file"/>
                        </sourceDesc>
                    </fileDesc>
                    <!-- encoding desc etc. -->
                    <revisionDesc>
                        <change when="{format-date(current-date(), '[Y0001]-[M01]-[D01]')}" who="{concat('#', $p_id-editor)}" xml:id="{$p_id-change}" xml:lang="en">Created this file through spliting <xsl:value-of select="$v_file-name"/> along the constituent <gi>div</gi>s.</change>
                        <xsl:apply-templates mode="m_identity-transform" select="ancestor::tei:TEI/tei:teiHeader/tei:revisionDesc/node()"/>
                    </revisionDesc>
                </teiHeader>
                <!-- facsimiles -->
                <facsimile>
                    <xsl:apply-templates mode="m_identity-transform" select="ancestor::tei:TEI/tei:facsimile/@*"/>
                    <!-- copy all surface nodes linked in this div -->
                    <xsl:apply-templates mode="m_corresponding-surface" select="preceding::tei:pb[@facs][1]"/>
                    <xsl:apply-templates mode="m_corresponding-surface" select="descendant::tei:pb[@facs]"/>
                    <xsl:apply-templates mode="m_corresponding-surface" select="following::tei:pb[@facs][1]"/>
                </facsimile>
                <!-- content of the file -->
                <text xml:lang="ar">
                    <body>
                        <!-- last preceding page break -->
                         <xsl:apply-templates mode="m_identity-transform" select="preceding::tei:pb[@ed = 'print'][1]"/>
                        <xsl:apply-templates mode="m_identity-transform" select="preceding::tei:pb[@ed = 'shamela'][1]"/>
                        <xsl:if test="preceding::tei:pb[@ed = 'print'][1]/following-sibling::node()[not(matches(.,'^\s+$'))]">
                            <!--<xsl:message>
                                <xsl:value-of select="$v_id-self"/>
                                <xsl:text> starts in the middle of a page.</xsl:text>
                            </xsl:message>-->
                            <gap reason="sampling" resp="#xslt"/>
                        </xsl:if>
                        <!-- copy of the div -->
                        <xsl:copy>
                            <xsl:apply-templates mode="m_identity-transform" select="@* | node()"/>
                        </xsl:copy>
                    </body>
                </text>
            </TEI>
        </xsl:result-document>
        <!-- XPointer -->
        <xi:include href="{$v_path-to-file_relative}" parse="xml" xpointer="{@xml:id}"/>
    </xsl:template>
    <xsl:template match="tei:pb[@facs]" mode="m_corresponding-surface">
        <xsl:variable name="v_id" select="substring-after(@facs, '#')"/>
        <xsl:copy-of select="ancestor::tei:TEI/tei:facsimile/tei:surface[@xml:id = $v_id]"/>
    </xsl:template>
    <!-- generate correct URLs in sourceDesc -->
    <xsl:template match="node() | @*" mode="m_split-file">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="m_split-file"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:analytic/tei:idno[@type = 'url']" mode="m_split-file">
        <xsl:copy>
            <xsl:apply-templates select="@* " mode="m_split-file"/>
            <xsl:value-of select="concat(substring-before(., $v_id-file), $p_target-folder, $p_target-folder-for-divs, following-sibling::tei:idno[@type = 'BibTeX'], '.TEIP5.xml')"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:revisionDesc">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="m_identity-transform"/>
            <change when="{format-date(current-date(), '[Y0001]-[M01]-[D01]')}" who="{concat('#', $p_id-editor)}" xml:id="{$p_id-change}" xml:lang="en">Created this file through spliting <xsl:value-of select="$v_id-file"/> into the constituent <gi>div</gi>s and linking the newly created files via <gi>xi:include</gi>s.</change>
            <xsl:apply-templates select="node()" mode="m_identity-transform"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
