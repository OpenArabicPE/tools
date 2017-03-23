<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:html="http://www.w3.org/1999/xhtml" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc" xmlns:opf="http://www.idpf.org/2007/opf" xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:bgn="http://bibliograph.net/" xmlns:genont="http://www.w3.org/2006/gen/ont#" xmlns:pto="http://www.productontology.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:re="http://oclcsrw.google.code/redirect" xmlns:schema="http://schema.org/" xmlns:umbel="http://umbel.org/umbel#"
    xmlns:xi="http://www.w3.org/2001/XInclude" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs xd xi dc opf html" version="2.0">
    
    <!-- this stylesheet  tries to query external authority files if they are linked through the @ref attribute -->
    <xsl:output method="xml" encoding="UTF-8" indent="yes" exclude-result-prefixes="#all"/>
    
   
    
    <!-- query VIAF -->
    <xsl:template name="t_query-viaf-rdf">
        <xsl:param name="p_viaf-id"/>
        <xsl:variable name="v_viaf-rdf" select="doc(concat('https://viaf.org/viaf/',$p_viaf-id,'/rdf.xml'))"/>
        <xsl:apply-templates select="$v_viaf-rdf//rdf:RDF/rdf:Description/schema:birthDate"/>
        <xsl:apply-templates select="$v_viaf-rdf//rdf:RDF/rdf:Description/schema:deathDate"/>
    </xsl:template>
    
    <xsl:template match="schema:birthDate">
        <xsl:element name="tei:birth">
            <xsl:element name="tei:date">
                <xsl:attribute name="when" select="."/>
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="schema:deathDate">
        <xsl:element name="tei:death">
            <xsl:element name="tei:date">
                <xsl:attribute name="when" select="."/>
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    
</xsl:stylesheet>