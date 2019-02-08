<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
    xmlns:oape="https://openarabicpe.github.io/ns" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:output encoding="UTF-8" indent="yes" method="xml" name="xml" omit-xml-declaration="no"/>
    <xsl:output encoding="UTF-8" indent="yes" method="text" name="text" omit-xml-declaration="yes"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet converts biblStruct nodes to rows of a CSV file. It also adds some information from authority files.</xd:p>
        </xd:desc>
    </xd:doc>
    <!-- select preference for output language -->
    <xsl:param name="p_output-language" select="'ar'"/>
    <!-- locate authority files -->
    <xsl:param name="p_path-authority-files" select="'../../authority-files/data/tei/'"/>
    <xsl:param name="p_file-name-gazetteer" select="'gazetteer_levant-phd.TEIP5.xml'"/>
    <xsl:param name="p_file-name-personography" select="'personography_OpenArabicPE.TEIP5.xml'"/>
    <!-- toggle debugging messages -->
    <xsl:include href="../../oxygen-project/OpenArabicPE_parameters.xsl"/>
    <!-- import functions -->
    <xsl:import href="../../tools/xslt/openarabicpe_functions.xsl"/>
    
    <!-- load the authority files -->
    <xsl:variable name="v_gazetteer"
        select="doc(concat($p_path-authority-files, $p_file-name-gazetteer))"/>
    <xsl:variable name="v_personography"
        select="doc(concat($p_path-authority-files, $p_file-name-personography))"/>
    <!-- variables for CSV output -->
    <xsl:variable name="v_new-line" select="'&quot;&#x0A;'"/>
    <xsl:variable name="v_seperator" select="'&quot;,&quot;'"/>
    <xsl:variable name="v_id-file" select="if(tei:TEI/@xml:id) then(tei:TEI/@xml:id) else(substring-before(tokenize(base-uri(),'/')[last()],'.TEIP5'))"/>
    <xsl:template match="tei:TEI">
        <xsl:apply-templates select="descendant::tei:text"/>
    </xsl:template>
    <xsl:template match="tei:text">
         <!-- stats per biblStruct-->
        <xsl:result-document format="text" href="../metadata/{$v_id-file}-bibl.csv">
            <!-- csv head -->
            <xsl:text>"article.id</xsl:text><xsl:value-of select="$v_seperator"/>
            <!-- information of journal issue -->
            <xsl:text>publication.title</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>publication.id.sakhrit</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>publication.id.oclc</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>date</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>volume</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>issue</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>publication.location.name</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>publication.location.coordinates</xsl:text><xsl:value-of select="$v_seperator"/>
            <!-- information on article -->
            <xsl:text>article.title</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>has.author</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>author.name</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>author.name.normalized</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>author.id.viaf</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>author.id.oape</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>author.birth</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>author.death</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>works.viaf.count</xsl:text><!--<xsl:value-of select="$v_seperator"/>
            <xsl:text>is.independent</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>byline.location.name</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>byline.location.coordinates</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>word.count</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>character.count</xsl:text><xsl:value-of select="$v_seperator"/>
            <xsl:text>page.count</xsl:text>-->
            <xsl:value-of select="$v_new-line"/>
            <!-- one line for each article/ biblStruct -->
            <xsl:apply-templates select="tei:body/descendant::tei:biblStruct" mode="m_tei-to-csv"/>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="tei:biblStruct" mode="m_tei-to-csv">
                <xsl:text>"</xsl:text>
                <!-- article ID -->
                <xsl:value-of select="if(@xml:id) then(concat($v_id-file, '-', @xml:id)) else(@corresp)"/>
                <xsl:value-of select="$v_seperator"/>
                <!-- publication title -->
                <xsl:value-of select="tei:monogr/tei:title[@level=('m','j')][1]"/>
                <xsl:value-of select="$v_seperator"/>
                <!-- publication ID: sakhrit -->
                <xsl:value-of select="tei:monogr/tei:idno[@type='jid']"/>
                <xsl:value-of select="$v_seperator"/>
                <!-- publication ID: OCLC -->
                <xsl:value-of select="tei:monogr/tei:idno[@type='OCLC']"/>
                <xsl:value-of select="$v_seperator"/>
                <!-- date -->
                <xsl:value-of select="tei:monogr/tei:imprint/tei:date/@when"/>
                <xsl:value-of select="$v_seperator"/>
                <!-- volume -->
                <xsl:value-of select="tei:monogr/tei:biblScope[@unit='volume']/@from"/>
                <xsl:value-of select="$v_seperator"/>
                <!-- issue -->
                <xsl:value-of select="tei:monogr/tei:biblScope[@unit='issue']/@from"/>
                <xsl:value-of select="$v_seperator"/>
                <!-- publication place -->
                <xsl:if test="tei:monogr/tei:imprint/tei:pubPlace">
                    <xsl:value-of select="oape:query-gazetteer(tei:monogr/tei:imprint/tei:pubPlace[1]/tei:placeName[1],$v_gazetteer,'name',$p_output-language)"/>
                </xsl:if>
                <xsl:value-of select="$v_seperator"/>
                <xsl:if test="tei:monogr/tei:imprint/tei:pubPlace">
                    <xsl:value-of select="oape:query-gazetteer(tei:monogr/tei:imprint/tei:pubPlace[1]/tei:placeName[1],$v_gazetteer,'location','')"/>
                </xsl:if>
                <xsl:value-of select="$v_seperator"/>
                <!-- article title -->
                <xsl:value-of select="tei:analytic/tei:title[@level='a']"/>
                <xsl:value-of select="$v_seperator"/>
                <!-- has author? -->
                <xsl:choose>
                    <xsl:when test="tei:analytic/tei:author">
                        <xsl:text>T</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>F</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="$v_seperator"/>
                <!-- author names -->
                <xsl:for-each select="tei:analytic/tei:author/tei:persName">
                    <xsl:apply-templates select="." mode="m_plain-text"/>
                    <xsl:if test="position() != last()">
                        <xsl:text>|</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:value-of select="$v_seperator"/>
                <!-- normalized -->
                <xsl:for-each select="tei:analytic/tei:author/tei:persName">
                    <xsl:value-of select="oape:query-personography(.,$v_personography,'name',$p_output-language)"/>
                    <xsl:if test="position() != last()">
                        <xsl:text>|</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:value-of select="$v_seperator"/>
                <!-- author id: VIAF -->
                <xsl:for-each select="tei:analytic/tei:author/tei:persName">
                    <xsl:value-of select="oape:query-personography(.,$v_personography,'viaf','')"/>
                    <xsl:if test="position() != last()">
                        <xsl:text>|</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:value-of select="$v_seperator"/>
                <!-- author id: OpenArabicPE (local authority file) -->
                <xsl:for-each select="tei:analytic/tei:author/tei:persName">
                    <xsl:value-of select="oape:query-personography(.,$v_personography,'oape','')"/>
                    <xsl:if test="position() != last()">
                        <xsl:text>|</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:value-of select="$v_seperator"/>
                <!-- birth -->
                <xsl:for-each select="tei:analytic/tei:author/tei:persName">
                    <xsl:value-of select="oape:query-personography(.,$v_personography,'birth','')"/>
                    <xsl:if test="position() != last()">
                        <xsl:text>|</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:value-of select="$v_seperator"/>
                <!-- death -->
                <xsl:for-each select="tei:analytic/tei:author/tei:persName">
                    <xsl:value-of select="oape:query-personography(.,$v_personography,'death','')"/>
                    <xsl:if test="position() != last()">
                        <xsl:text>|</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:value-of select="$v_seperator"/>
                <!-- number of works in VIAF -->
                <xsl:for-each select="tei:analytic/tei:author/tei:persName">
                    <xsl:value-of select="oape:query-personography(.,$v_personography,'countWorks','')"/>
                    <xsl:if test="position() != last()">
                        <xsl:text>|</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <!-- end of line -->
                <xsl:value-of select="$v_new-line"/>
            </xsl:template>
    
    <!-- count words -->
    <xsl:template name="t_count-words">
        <!-- $p_input accepts xml nodes as input -->
        <xsl:param name="p_input"/>
        <xsl:value-of select="number(count(tokenize(string($p_input), '\W+')))"/>
    </xsl:template>
    <!-- count characters: output is a number -->
    <xsl:template name="t_count-characters">
        <!-- $p_input accepts xml nodes as input -->
        <xsl:param name="p_input"/>
        <!--<xsl:variable name="v_plain-text">
            <xsl:apply-templates select="$p_input" mode="mPlainText"/>
        </xsl:variable>-->
        <xsl:value-of select="number(string-length(replace(string($p_input), '\W', '')))"/>
    </xsl:template>
    <!-- plain text mode -->
    <!-- plain text -->
    <xsl:template match="text()" mode="m_plain-text">
        <!-- in many instances adding whitespace before and after a text() node makes a lot of sense -->
        <xsl:text> </xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:text> </xsl:text>
    </xsl:template>
    <!-- replace page breaks with tokens that can be used for string split -->
    <xsl:template match="tei:pb[@ed = 'print']" mode="m_plain-text">
        <xsl:text>$pb</xsl:text>
        <xsl:value-of select="@n"/>
        <xsl:text>$</xsl:text>
    </xsl:template>
    <!-- editorial interventions -->
    <!-- remove all interventions from shamela.ws -->
    <xsl:template match="node()[@resp = '#org_MS']" mode="m_plain-text"/>
    <!-- editorial corrections with choice: original mistakes are encoded as <sic> or <orig>, corrections as <corr> -->
    <xsl:template match="tei:choice" mode="m_plain-text">
        <xsl:apply-templates mode="m_plain-text" select="node()[not(self::tei:corr)]"/>
    </xsl:template>
</xsl:stylesheet>
