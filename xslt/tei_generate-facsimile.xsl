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
    <xsl:param name="p_file-hathi" select="true()"/>
    <xsl:param name="p_file-eap" select="false()"/>
    <xsl:param name="p_file-sakhrit" select="false()"/>
    
    <!-- ID / date of issue in EAP: these are formatted as yyyymm and need to be set for each issue. the volumes commence with yyyy02 -->
    <xsl:param name="pEapIssueId" select="'191202'"/>
    <!-- set-off between the EAP, which takes the printed page number as image number and Hathi, which doesn't; default is 0 -->
    <xsl:param name="pImgStartHathiDifference" select="4" as="xs:integer"/>
    <!-- set-off between EAP image number and the printed edition; default is 0 -->
    <xsl:param name="p_image-setoff_eap" select="0" as="xs:integer"/>
    <!-- volume in HathTrust collection: needs to be set -->
    <xsl:variable name="vHathiTrustId" select="'njp.32101007615691'"/>
    <!-- volume in EAP collection: needs to be set  -->
    <xsl:variable name="vEapVolumeId" select="'6'"/>
    
    <!-- variables based on the input file -->
    <xsl:variable name="v_biblStructSource" select="//tei:sourceDesc/tei:biblStruct"/>
    <xsl:variable name="v_volume">
        <xsl:choose>
            <!-- check for correct encoding of volume information -->
            <xsl:when test="$v_biblStructSource//tei:biblScope[@unit = 'volume']/@from = $v_biblStructSource//tei:biblScope[@unit = 'volume']/@to">
                <xsl:value-of select="$v_biblStructSource//tei:biblScope[@unit = 'volume']/@from"/>
            </xsl:when>
            <!-- check for ranges -->
            <xsl:when test="$v_biblStructSource//tei:biblScope[@unit = 'volume']/@from != $v_biblStructSource//tei:biblScope[@unit = 'volume']/@to">
                <xsl:value-of select="$v_biblStructSource//tei:biblScope[@unit = 'volume']/@from"/>
                <!-- probably an en-dash is the better option here -->
                <xsl:text>/</xsl:text>
                <xsl:value-of select="$v_biblStructSource//tei:biblScope[@unit = 'volume']/@to"/>
            </xsl:when>
            <!-- fallback: erroneous encoding of volume information with @n -->
            <xsl:when test="$v_biblStructSource//tei:biblScope[@unit = 'volume']/@n">
                <xsl:value-of select="$v_biblStructSource//tei:biblScope[@unit = 'volume']/@n"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="v_issue">
        <xsl:choose>
            <!-- check for correct encoding of issue information -->
            <xsl:when test="$v_biblStructSource//tei:biblScope[@unit = 'issue']/@from = $v_biblStructSource//tei:biblScope[@unit = 'issue']/@to">
                <xsl:value-of select="$v_biblStructSource//tei:biblScope[@unit = 'issue']/@from"/>
            </xsl:when>
            <!-- check for ranges -->
            <xsl:when test="$v_biblStructSource//tei:biblScope[@unit = 'issue']/@from != $v_biblStructSource//tei:biblScope[@unit = 'issue']/@to">
                <xsl:value-of select="$v_biblStructSource//tei:biblScope[@unit = 'issue']/@from"/>
                <!-- probably an en-dash is the better option here -->
                <xsl:text>/</xsl:text>
                <xsl:value-of select="$v_biblStructSource//tei:biblScope[@unit = 'issue']/@to"/>
            </xsl:when>
            <!-- fallback: erroneous encoding of issue information with @n -->
            <xsl:when test="$v_biblStructSource//tei:biblScope[@unit = 'issue']/@n">
                <xsl:value-of select="$v_biblStructSource//tei:biblScope[@unit = 'issue']/@n"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
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
    
    <!-- URL to Hathi, this is always the same -->
    <xsl:variable name="vFileUrlHathi" select="concat('https://babel.hathitrust.org/cgi/imgsrv/image?id=',$vHathiTrustId,';seq=')"/>
    
    <!-- URL to archive.sakhrit -->
    <xsl:variable name="v_url-sakhrit-base" select="'http://archive.sakhrit.co/MagazinePages/Magazine_JPG/'"/>
    <xsl:variable name="v_journal-title-sakhrit" select="'AL_moqtabs'"/>
    <xsl:param name="p_year-sakhrit" select="'1906'"/>
    <xsl:variable name="v_url-sakhrit" select="concat($v_url-sakhrit-base,$v_journal-title-sakhrit,'/',$v_journal-title-sakhrit,'_',$p_year-sakhrit,'/Issue_',$v_issue,'/')"/>    
    
    <!-- URL to EAP, always the same for the same periodical. In this case al-Muqtabas -->
    <xsl:variable name="vFileUrlEap" select="concat('http://eap.bl.uk/EAPDigitalItems/EAP119/EAP119_1_4_',$vEapVolumeId,'-EAP119_muq',$pEapIssueId)"/>
    
    <!-- Path to local files -->
    <xsl:variable name="v_name-file" select="concat(translate($vHathiTrustId,'.','-'),'-img_')"/>
    <!-- local path to folder containing the images of this issue -->
    <xsl:variable name="v_path-base" select="concat('../images/oclc_4770057679-v_',$v_volume,'/')"/>
    <xsl:variable name="v_path-file" select="concat($v_path-base, $v_name-file)"/>

    
    <xsl:variable name="v_id-facs" select="'facs_'"/>
    
    <!-- count number of first-level divs in the file -->
    <xsl:variable name="v_count-divs" select="number(count(tei:TEI/tei:text/tei:body/tei:div))"/>
    <xsl:variable name="v_count-pb-per-div" select="round($v_pages div $v_count-divs)"/>
    
    
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
        <xsl:message>
            <xsl:text>There are </xsl:text><xsl:value-of select="$v_pages"/><xsl:text> pages in this file and on average </xsl:text><xsl:value-of select="$v_count-pb-per-div"/><xsl:text> per div.</xsl:text>
        </xsl:message>
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
    
    <!-- add an approximate number of <pb>s after each <div> to ease the job for potential editors  -->
    <!--<xsl:template match="tei:body/tei:div">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
        <xsl:call-template name="t_generate-pb">
            <xsl:with-param name="p_page-start" select="count(preceding-sibling::tei:div) * $v_count-pb-per-div + $v_page-start"/>
            <xsl:with-param name="p_page-stop" select="count(preceding-sibling::tei:div) * $v_count-pb-per-div + $v_count-pb-per-div + $v_page-start"/>
        </xsl:call-template>
    </xsl:template>-->
    
    <!-- copy everything -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    
    
    <!-- document the changes -->
    <xsl:template match="tei:revisionDesc">
        <xsl:copy>
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
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- generate the facsimile -->
    <xsl:template name="t_generate-facsimile">
        <xsl:param name="p_page-start" select="1"/>
        <xsl:param name="p_page-stop" select="20"/>
        <xsl:variable name="vStartHathi" select="$p_page-start + $pImgStartHathiDifference"/>
        <xsl:element name="tei:surface">
            <xsl:attribute name="xml:id" select="concat($v_id-facs,$p_page-start)"/>
            <xsl:if test="$p_file-local = true()">
                <!--<xsl:element name="tei:graphic">
                    <xsl:attribute name="xml:id" select="concat($v_id-facs,$p_page-start,'-g_1')"/>
                    <xsl:attribute name="url" select="concat($v_path-file,format-number($vStartHathi,'000'),'.tif')"/>
                    <xsl:attribute name="mimeType" select="'image/tiff'"/>
                </xsl:element>-->
                <xsl:element name="tei:graphic">
                    <xsl:attribute name="xml:id" select="concat($v_id-facs,$p_page-start,'-g_2')"/>
                    <xsl:attribute name="url" select="concat($v_path-file,format-number($vStartHathi,'000'),'.jpg')"/>
                    <xsl:attribute name="mimeType" select="'image/jpeg'"/>
                </xsl:element>
            </xsl:if>
            <!-- link to Hathi -->
            <xsl:if test="$p_file-hathi = true()">
            <xsl:element name="tei:graphic">
                <xsl:attribute name="xml:id" select="concat($v_id-facs,$p_page-start,'-g_3')"/>
                <xsl:attribute name="url" select="concat($vFileUrlHathi,$vStartHathi)"/>
                <xsl:attribute name="mimeType" select="'image/jpeg'"/>
            </xsl:element>
            </xsl:if>
            <!-- link to EAP119 -->
            <xsl:if test="$p_file-eap = true()">
            <xsl:element name="tei:graphic">
                <xsl:attribute name="xml:id" select="concat($v_id-facs,$p_page-start,'-g_4')"/>
                <xsl:attribute name="url" select="concat($vFileUrlEap,'_',format-number($p_page-start + $p_image-setoff_eap,'000'),'_L.jpg')"/>
                <xsl:attribute name="mimeType" select="'image/jpeg'"/>
            </xsl:element>
            </xsl:if>
            <!-- link to archive.sakhrit -->
            <xsl:if test="$p_file-sakhrit = true()">
                <xsl:element name="tei:graphic">
                    <xsl:attribute name="xml:id" select="concat($v_id-facs,$p_page-start,'-g_5')"/>
                    <xsl:attribute name="url" select="concat($v_url-sakhrit,format-number($p_page-start,'000'),'.jpg')"/>
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