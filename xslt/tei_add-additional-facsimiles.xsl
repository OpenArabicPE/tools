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
    version="3.0">
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet generates a <tei:facsimile/> node with a pre-defined number of <tei:surface/> children. All parameters can be set through the group of variables at the beginning of the stylesheet.</xd:p>
            <xd:p>The variable $vEapIssueId must be changed for every issue of Muqtabas</xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- TO DO: 
        1. the OCLC number must be retrieved from the input file
        2. EAP has switched to IIIF and therefore new URLs-->
    
    <xsl:output encoding="UTF-8" indent="no" method="xml" omit-xml-declaration="no" version="1.0"/>

    <!-- identify the author of the change by means of a @xml:id -->
    <!--    <xsl:param name="p_id-editor" select="'pers_TG'"/>-->
    <xsl:include href="../../oxygen-project/OpenArabicPE_parameters.xsl"/>
    
    <!-- params to toggle certain links -->
    <xsl:param name="p_file-local" select="true()"/>
    <xsl:param name="p_file-hathi" select="false()"/>
    <xsl:param name="p_file-eap" select="false()"/>
    <xsl:param name="p_file-sakhrit" select="false()"/>
    
    <xsl:param name="p_generate-pbs" select="false()"/>
    
    <!-- ID / date of issue in EAP: these are formatted as yyyymm and need to be set for each issue. the volumes commence with yyyy02 -->
<!--    <xsl:param name="pEapIssueId" select="'191202'"/>-->
    <!-- set-off between HathiTrust image numbers and the printed edition; default is 0 -->
    <xsl:param name="p_image-setoff_hathi" select="28" as="xs:integer"/>
    <!-- set-off between EAP image number and the printed edition; default is 0 -->
    <xsl:param name="p_image-setoff_eap" select="0" as="xs:integer"/>
    <!-- set-off between local image number and the printed edition; default is 0 -->
    <xsl:param name="p_image-setoff_local" select="0" as="xs:integer"/>
    
    <!-- volume in HathTrust collection: needs to be set -->
    <xsl:variable name="vHathiTrustId" select="'umn.319510029968616'"/> <!-- vol. 2 -->
    <!-- volume in EAP collection: needs to be set  -->
    <xsl:variable name="v_publication_eap" select="4" as="xs:integer"/>
    <xsl:param name="p_volume-setoff_eap" select="-1" as="xs:integer"/>
    <!-- EAP moved on to IIIF in late 2017 -->
    <xsl:variable name="v_iiif-scheme" select="'https://'"/>
    <xsl:variable name="v_iiif-server" select="'images.eap.bl.uk'"/>
    <xsl:variable name="v_iiif-prefix" select="'/EAP119'"/>
    
    <!-- variables based on the input file -->
    <!-- select the first edition by default -->
    <xsl:param name="p_edition-id" select="'edition_1'"/>
    <xsl:variable name="v_biblStructSource" select="//tei:sourceDesc/tei:biblStruct[@xml:id=$p_edition-id]"/>
    <!-- parameter to select the periodical, current values are 'haqaiq' or 'muqtabas' -->
    <xsl:param name="p_periodical"/>
    <xsl:variable name="v_oclc">
        <xsl:choose>
            <xsl:when test="lower-case($p_periodical) = 'haqaiq'">
                <xsl:text>644997575</xsl:text>
            </xsl:when>
            <xsl:when test="lower-case($p_periodical) = 'muqtabas'">
                <xsl:text>4770057679</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$v_biblStructSource/descendant::tei:idno[@type='OCLC'][1]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
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
                <xsl:value-of select="1"/>
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
    
    
    
    <!-- Path to local files -->
    <xsl:variable name="v_name-base" select="concat('oclc_',$v_oclc,'-v_',$v_volume)"/>
    <xsl:variable name="v_name-file">
        <xsl:choose>
            <xsl:when test="lower-case($p_periodical) = 'muqtabas'">
                <xsl:value-of select="concat(translate($vHathiTrustId,'.','-'),'-img_')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($v_name-base,'-img_')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!-- local path to folder containing the images of this issue -->
    <xsl:variable name="v_path-base" select="concat('../images/',$v_name-base,'/oib/')"/>
    <xsl:variable name="v_path-file" select="concat($v_path-base, $v_name-file)"/>

    <!-- prefix for the @xml:id of all facsimiles -->
    <xsl:variable name="v_id-facs" select="'facs_'"/>
    
  
    <!-- identity transform -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:surface">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <!-- add new facsimile for this page -->
            <!-- assume that the sequence of surface children of facsimile follow the sequence of pages. Figure out which page we are at-->
            <xsl:variable name="v_page" select="count(preceding-sibling::tei:surface) + $v_page-start"/>
            <xsl:variable name="v_graphic" select="count(tei:graphic) + 3"/>
            <xsl:element name="tei:graphic">
                <xsl:attribute name="xml:id" select="concat(@xml:id, '-g_', $v_graphic)"/>
                <xsl:attribute name="change" select="concat('#',$p_id-change)"></xsl:attribute>
                <xsl:if test="$p_file-local = true()">
                    <xsl:attribute name="url" select="concat($v_path-file,format-number($v_page + $p_image-setoff_local,'000'),'.tif')"/>
                    <xsl:attribute name="mimeType" select="'image/tiff'"/>
                </xsl:if>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    
    <!-- document the changes -->
    <xsl:template match="tei:revisionDesc">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="tei:change">
                <xsl:attribute name="when" select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>
                <xsl:attribute name="who" select="concat('#',$p_id-editor)"/>
                <xsl:attribute name="xml:id" select="$p_id-change"/>
                <xsl:attribute name="xml:lang" select="'en'"></xsl:attribute>
                <xsl:text>Added </xsl:text><tei:gi>graphic</tei:gi><xsl:text> for all pages linking to local facsimiles.</xsl:text>
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
                <!-- local TIFF copy -->
                <!--<xsl:element name="tei:graphic">
                    <xsl:attribute name="xml:id" select="concat($v_id-facs,$p_page-start,'-g_1')"/>
                    <!-\- when local files were downloaded from HathiTrust, the set-off should be similar -\->
                    <xsl:attribute name="url" select="concat($v_path-file,format-number($p_page-start + $p_image-setoff_hathi,'000'),'.tif')"/>
                    <xsl:attribute name="mimeType" select="'image/tiff'"/>
                </xsl:element>-->
                <!-- local JPEG copy -->
                <xsl:element name="tei:graphic">
                    <xsl:attribute name="xml:id" select="concat($v_id-facs,$p_page-start,'-g_2')"/>
                    <!-- when local files were downloaded from HathiTrust, the set-off should be similar -->
                    <xsl:attribute name="url" select="concat($v_path-file,format-number($p_page-start + $p_image-setoff_hathi,'000'),'.jpg')"/>
                    <xsl:attribute name="mimeType" select="'image/jpeg'"/>
                </xsl:element>
            </xsl:if>
            <!-- link to Hathi -->
            <xsl:if test="$p_file-hathi = true()">
            <xsl:element name="tei:graphic">
                <xsl:attribute name="xml:id" select="concat($v_id-facs,$p_page-start,'-g_3')"/>
                <xsl:attribute name="url" select="concat($vFileUrlHathi,$p_page-start + $p_image-setoff_hathi)"/>
                <xsl:attribute name="mimeType" select="'image/jpeg'"/>
            </xsl:element>
            </xsl:if>
            <!-- link to EAP119 -->
            <xsl:if test="$p_file-eap = true()">
            <xsl:element name="tei:graphic">
                <xsl:attribute name="xml:id" select="concat($v_id-facs,$p_page-start,'-g_4')"/>
<!--                <xsl:attribute name="url" select="concat($vFileUrlEap,'_',format-number($p_page-start + $p_image-setoff_eap,'000'),'_L.jpg')"/>-->
                <!-- new url pointing to IIIF manifest -->
                <xsl:attribute name="url" select="concat($v_iiif-scheme,$v_iiif-server,$v_iiif-prefix,'/EAP119_1_',$v_publication_eap,'_',$v_volume + $p_volume-setoff_eap,'/',$p_page-start + $p_image-setoff_eap,'.jp2')"/>
                <xsl:attribute name="mimeType" select="'image/jpeg'"/>
                <xsl:attribute name="type" select="'iiif'"/>
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
</xsl:stylesheet>