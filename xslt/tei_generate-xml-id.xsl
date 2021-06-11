<xsl:stylesheet exclude-result-prefixes="xs xd html" version="3.0" xmlns="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet generates a <tei:att>xml:id</tei:att> for every node based on its name, position in the document and generate-id(). The position is used to provide leverage against the slight chance that generate-id() generates an ID already present in the document. An <tei:att>xml:id</tei:att> wil thus look like "div_1.d1e1786"</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output encoding="UTF-8" indent="no" method="xml" name="xml" omit-xml-declaration="no" version="1.0"/>
    <!-- identify the author of the change by means of a @xml:id -->
    <!--    <xsl:param name="p_id-editor" select="'pers_TG'"/>-->
    <xsl:include href="../../oxygen-project/OpenArabicPE_parameters.xsl"/>
    <!-- variable to test if something needs to be changed -->
    <xsl:variable name="v_changed">
        <xsl:choose>
            <xsl:when test="/descendant::*[not(@xml:id)]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!-- identity transform -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- generate an @xml:id for the selected element -->
    <xsl:template match="*[not(@xml:id)]">
        <xsl:variable name="v_name" select="local-name()"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <!-- add documentation of change -->
            <xsl:choose>
                <xsl:when test="not(@change)">
                    <xsl:attribute name="change" select="concat('#', $p_id-change)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates mode="m_documentation" select="@change"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:attribute name="xml:id">
                <xsl:value-of select="concat($v_name, '_', count(preceding::node()[name() = $v_name]) + 1, '.', generate-id())"/>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- generate documentation of change -->
    <xsl:template match="tei:revisionDesc" priority="100">
        <!-- basic debugging -->
        <xsl:if test="$p_verbose = true()">
            <xsl:message>
                <xsl:text>change-id: </xsl:text>
                <xsl:value-of select="$p_id-change"/>
            </xsl:message>
        </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:if test="not(@xml:id)">
                <!-- add documentation of change -->
                    <xsl:choose>
                        <xsl:when test="not(@change)">
                            <xsl:attribute name="change" select="concat('#', $p_id-change)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates mode="m_documentation" select="@change"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="concat(local-name(), '_1.', generate-id())"/>
                    </xsl:attribute>
            </xsl:if>
            <!-- suppress a new tei:change element if nothing was changed -->
            <xsl:if test="$v_changed = true()">
                <xsl:element name="change">
                    <xsl:attribute name="when" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
                    <xsl:attribute name="who" select="concat('#', $p_id-editor)"/>
                    <xsl:attribute name="xml:id" select="$p_id-change"/>
                    <xsl:attribute name="xml:lang" select="'en'"/>
                    <xsl:text>Added automated @xml:id to every element had no existing @xml:id, following the pattern "name()_generate-id()".</xsl:text>
                </xsl:element>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- document changes on changed elements by means of the @change attribute linking to the @xml:id of the <tei:change> element -->
    <xsl:template match="@change" mode="m_documentation">
        <xsl:attribute name="change">
            <xsl:value-of select="concat(., ' #', $p_id-change)"/>
        </xsl:attribute>
    </xsl:template>
</xsl:stylesheet>
