<xsl:stylesheet 
    xmlns:html="http://www.w3.org/1999/xhtml" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs xd html xi"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    version="3.0">
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet generates <tei:gi>publicationStmt</tei:gi></xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output encoding="UTF-8" indent="yes" method="xml" omit-xml-declaration="no" version="1.0" />
    
    <!-- identify the author of the change by means of a @xml:id -->
    <xsl:include href="../../oxygen-project/OpenArabicPE_parameters.xsl"/>
    <xsl:param name="p_github-user" select="'openarabicpe'"/>
    <xsl:param name="p_github-repository" select="'newspaper_hadiqat-al-akhbar'"/>
    <xsl:param name="p_path-local" select="'tei'"/>
    <xsl:param name="p_replace-existing" select="true()"/>
    <xsl:variable name="v_file-name" select="tokenize(base-uri(),'/')[last()]"/>
    <xsl:variable name="v_today" select="year-from-date(current-date())"/>

    
    <!-- identity transform -->
    <xsl:template match="@* |node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:publicationStmt">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="$p_replace-existing = true()">
                    <xsl:attribute name="change" select="concat(@change, ' #', $p_id-change)"/>
            <xsl:attribute name="xml:lang" select="'en'"/>
            <xsl:element name="authority">
                <xsl:copy-of select="$p_editor/descendant::tei:persName"/>
            </xsl:element>
            <xsl:element name="pubPlace">
                <xsl:element name="placeName">
                    <xsl:text>Beirut</xsl:text>
                </xsl:element>
            </xsl:element>
            <xsl:element name="date">
                <xsl:attribute name="when" select="$v_today"/>
                <xsl:value-of select="$v_today"/>
            </xsl:element>
            <xsl:element name="availability">
                <xsl:attribute name="status" select="'restricted'"/>
                <xsl:element name="licence">
                    <xsl:attribute name="target" select="'http://creativecommons.org/licenses/by-sa/4.0/'"/>
                    <xsl:text>Distributed under a Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0) license</xsl:text>
                </xsl:element>
            </xsl:element>
            <xsl:element name="idno">
                <xsl:attribute name="type" select="'url'"/>
                <xsl:value-of select="concat('https://github.com/',$p_github-user,'/',$p_github-repository,'/blob/master/',$p_path-local,'/',$v_file-name)"/>
            </xsl:element>
            <xsl:element name="idno">
                <xsl:attribute name="type" select="'url'"/>
                <xsl:value-of select="concat('https://',$p_github-user,'.github.io/',$p_github-repository,'/',$p_path-local,'/',$v_file-name)"/>
            </xsl:element>
                </xsl:when>
                <!-- fallback -->
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <!-- generate documentation of change -->
    <xsl:template match="tei:revisionDesc">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="change">
                <xsl:attribute name="when" select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>
                <xsl:attribute name="who" select="concat('#',$p_id-editor)"/>
                <xsl:attribute name="xml:id" select="$p_id-change"/>
                <xsl:attribute name="xml:lang" select="'en'"/>
                <xsl:text>Added </xsl:text><tei:gi>publicationStmt</tei:gi><xsl:text>.</xsl:text>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
