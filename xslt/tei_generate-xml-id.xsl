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
            <xd:p>This stylesheet generates a <tei:att>xml:id</tei:att> for every node based on its name, position in the document and generate-id(). The position is used to provide leverage against the slight chance that generate-id() generates an ID already present in the document. An <tei:att>xml:id</tei:att> wil thus look like "div_1.d1e1786"</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output encoding="UTF-8" indent="no" method="xml" name="xml" omit-xml-declaration="no" version="1.0"/>
    
    <!-- identify the author of the change by means of a @xml:id -->
<!--    <xsl:param name="p_id-editor" select="'pers_TG'"/>-->
    <xsl:include href="../../oxygen-project/OpenArabicPE_parameters.xsl"/>
   
    
    <!-- reproduce everything as is -->
    <xsl:template match="@* |node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- generate documentation of change -->
    <xsl:template match="tei:revisionDesc" priority="100">
        <!-- basic debugging -->
        <xsl:if test="$p_verbose = true()">
            <xsl:message><xsl:text>change-id: </xsl:text><xsl:value-of select="$p_id-change"/></xsl:message>
        </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="change">
                <xsl:attribute name="when" select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>
                <xsl:attribute name="who" select="concat('#',$p_id-editor)"/>
                <xsl:attribute name="change" select="$p_id-change"/>
                <xsl:text>Added automated </xsl:text>
                <xsl:element name="att">xml:id</xsl:element>
                <xsl:text>s for every element that is a descendant of </xsl:text>
                <xsl:element name="gi">tei:text</xsl:element>
                <xsl:text>and had no existing </xsl:text>
                <xsl:element name="att">xml:id</xsl:element>
                <xsl:text>following the pattern "name()_generate-id()"</xsl:text>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- document changes on changed elements by means of the @change attribute linking to the @xml:id of the <tei:change> element -->
    <xsl:template match="@change">
        <xsl:attribute name="change">
                    <xsl:value-of select="concat(.,' #',$p_id-change)"/>
        </xsl:attribute>
    </xsl:template>
    
     <!-- generate an @xml:id for the selected element -->
    <xsl:template match="tei:TEI//node()">
        <xsl:variable name="vName" select="if(starts-with(name(),'tei:')) then(substring-after(name(),'tei:')) else(name())"/>
        <xsl:copy>
            <xsl:choose>
                <!-- if an xml:id is already present, it should never (!) be changed -->
                <xsl:when test="@xml:id">
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- add documentation of change -->
                    <xsl:if test="not(@change)">
                        <xsl:attribute name="change" select="concat('#',$p_id-change)"/>
                    </xsl:if>
                    <xsl:apply-templates select="@* "/>
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="concat($vName,'_',count(preceding::node()[name()=$vName])+1,'.',generate-id())"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="node()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
