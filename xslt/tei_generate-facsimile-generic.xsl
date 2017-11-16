<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:html="http://www.w3.org/1999/xhtml" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs xd html"
    version="2.0">
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet generates a <tei:facsimile/> node with a pre-defined number of <tei:surface/> children. All parameters can be set through the group of variables at the beginning of the stylesheet.</xd:p>
            <xd:p>The variable $vEapIssueId must be changed for every issue of Muqtabas</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output encoding="UTF-8" indent="yes" method="xml" omit-xml-declaration="no" version="1.0"/>

    <!-- identify the author of the change by means of a @xml:id -->
    <xsl:param name="p_id-editor" select="'pers_TG'"/>
    
    <!-- params to toggle certain links -->
    <xsl:param name="p_file-local" select="true()"/>
    
    
    <!-- variables based on the input file -->
    <xsl:variable name="v_biblStructSource" select="//tei:sourceDesc/tei:biblStruct"/>
    <!-- first page of the issue -->
    <xsl:variable name="v_page-start" as="xs:integer">
        <xsl:choose>
            <xsl:when test="$v_biblStructSource//tei:biblScope[@unit='page']/@from">
                <xsl:value-of select="$v_biblStructSource//tei:biblScope[@unit='page']/@from"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="7"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!-- total number of pages in this issue -->
    <xsl:variable name="v_pages" as="xs:integer">
        <xsl:choose>
            <xsl:when test="$v_biblStructSource//tei:biblScope[@unit='page']/@from and $v_biblStructSource//tei:biblScope[@unit='page']/@to">
                <xsl:value-of select="$v_biblStructSource//tei:biblScope[@unit='page']/@to - $v_biblStructSource//tei:biblScope[@unit='page']/@from + 1"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="85"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="v_path-file" select="'../images/index/Thamarat al_Founoun-Index-'"/>
    <xsl:variable name="v_id-facs" select="'facs_'"/>
    
    <!-- generate the facsimile and reproduce the file -->
    <xsl:template match="tei:TEI">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="child::tei:teiHeader"/>
            <xsl:element name="tei:facsimile">
                <xsl:attribute name="xml:id" select="'facs'"/>
                <xsl:call-template name="t_generate-facsimile">
                    <xsl:with-param name="p_page-start" select="number($v_page-start)"/>
                    <xsl:with-param name="p_page-stop" select="number($v_page-start + $v_pages -1)"/>
                </xsl:call-template>
            </xsl:element>
            <xsl:apply-templates select="child::tei:text"/>
        </xsl:copy>
        <!-- reporting and debugging -->
    </xsl:template>
   
   <xsl:template match="tei:text">
       <xsl:copy>
           <xsl:apply-templates select="@*"/>
           <!-- generate a pb linking to the first facsimile -->
           <xsl:call-template name="t_generate-pb">
               <xsl:with-param name="p_page-start" select="number($v_page-start)"/>
               <xsl:with-param name="p_page-stop" select="number($v_page-start)"/>
           </xsl:call-template>
           <xsl:apply-templates select="tei:front"/>
           <xsl:apply-templates select="tei:body"/>
           <xsl:choose>
               <xsl:when test="tei:back">
                   <xsl:apply-templates select="tei:back"/>
               </xsl:when>
               <xsl:otherwise>
                   <xsl:variable name="v_back">
                       <xsl:element name="tei:back"/>
                   </xsl:variable>
                   <xsl:apply-templates select="$v_back/descendant-or-self::tei:back"/>
               </xsl:otherwise>
           </xsl:choose>
       </xsl:copy>
   </xsl:template>
    
    <xsl:template match="tei:back">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:element name="div">
                <xsl:call-template name="t_generate-pb">
                    <xsl:with-param name="p_page-start" select="number($v_page-start +1)"/>
                    <xsl:with-param name="p_page-stop" select="number($v_page-start + $v_pages -1)"/>
                </xsl:call-template>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <!-- copy everything -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- document the changes -->
    <xsl:template match="tei:revisionDesc">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="tei:change">
                <xsl:attribute name="when" select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>
                <xsl:attribute name="who" select="$p_id-editor"/>
                <xsl:text>Added </xsl:text><tei:gi>graphic</tei:gi><xsl:text> for </xsl:text>
                <xsl:value-of select="$v_pages"/>
                <xsl:text> pages with references to digital images.</xsl:text><!--<xsl:text> at HathiTrust and EAP.</xsl:text>-->
                <!--<xsl:text>Created </xsl:text><tei:gi>facsimile</tei:gi><xsl:text> for </xsl:text>
                <xsl:value-of select="$vNumberPages"/>
                <xsl:text> pages with references to a local copy of .tif and .jpeg as well as to the online resource for each page.</xsl:text>-->
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- generate the facsimile -->
    <xsl:template name="t_generate-facsimile">
        <xsl:param name="p_page-start" select="1"/>
        <xsl:param name="p_page-stop" select="20"/>
        <xsl:element name="tei:surface">
            <xsl:attribute name="xml:id" select="concat($v_id-facs,$p_page-start)"/>
            <xsl:if test="$p_file-local = true()">
                <xsl:element name="tei:graphic">
                    <xsl:attribute name="xml:id" select="concat($v_id-facs,$p_page-start,'-g_2')"/>
                    <xsl:attribute name="url" select="concat($v_path-file,format-number($p_page-start,'000'),'.jpg')"/>
                    <xsl:attribute name="mimeType" select="'image/jpeg'"/>
                </xsl:element>
            </xsl:if>
        </xsl:element>
        <xsl:if test="$p_page-start lt $p_page-stop">
            <xsl:call-template name="t_generate-facsimile">
                <xsl:with-param name="p_page-start" select="$p_page-start +1"/>
                <xsl:with-param name="p_page-stop" select="$p_page-stop"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="t_generate-pb">
        <xsl:param name="p_page-start"/>
        <xsl:param name="p_page-stop"/>
            <xsl:element name="tei:pb">
                <xsl:attribute name="ed" select="'print'"/>
                <xsl:attribute name="n" select="$p_page-start"/>
                <xsl:attribute name="facs" select="concat('#',$v_id-facs,$p_page-start)"/>
            </xsl:element>
        <xsl:if test="$p_page-start lt $p_page-stop">
            <xsl:call-template name="t_generate-pb">
                <xsl:with-param name="p_page-start" select="$p_page-start +1"/>
                <xsl:with-param name="p_page-stop" select="$p_page-stop"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>