<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
    xpath-default-namespace="http://www.sitemaps.org/schemas/sitemap/0.9"
    exclude-result-prefixes="xs tei"
    version="3.0">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    
    <!-- this stylesheet generates a sitemap.xml to submit to Google for searching the TEI XML files in an edition -->
    
    
    <!-- establish the URL of the data folder -->
    <xsl:param name="p_url-repository" select="replace(base-uri(),'file:(.+?)[/].[^/]+\.xml', '$1')"/>
    <xsl:variable name="v_url-tei-files" select="concat($p_url-repository,'?select=*.TEIP5.xml')"/>
<!--    <xsl:variable name="v_url-tei-files" select="'/BachUni/BachBibliothek/GitHub/OpenArabicPE/journal_al-zuhur/tei?select=*.TEIP5.xml'"/>-->
    
    <xsl:template match="/">
        <!-- generate the sitemap -->
        <urlset 
                xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" 
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
                xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">           <!-- include all URLs for TEI XML files -->
            <xsl:apply-templates select="collection($v_url-tei-files)/descendant::tei:TEI" mode="m_tei-to-sitemap"/>
        </urlset>
    </xsl:template>
    
        <xsl:template match="tei:TEI" mode="m_tei-to-sitemap">
            <xsl:variable name="v_url" select="tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='url'][1]"/>
            <url>
                <loc>
                <xsl:analyze-string select="$v_url" regex="^.+github.com/(.+)/(.+)/blob/master/(.+\.xml)$">
                    <xsl:matching-substring>
                        <xsl:value-of select="concat('https://', regex-group(1), '.github.io/', regex-group(2), '/', regex-group(3))"/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="$v_url"/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </loc>
            <lastmod>
                <xsl:value-of select="tei:teiHeader/tei:revisionDesc/tei:change[1]/@when"/>
            </lastmod>
            <!-- static priority -->
            <priority>1</priority>
            </url>
        </xsl:template>
</xsl:stylesheet>