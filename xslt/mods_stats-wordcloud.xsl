<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:oap="https://openarabicpe.github.io/ns"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:srw="http://www.loc.gov/zing/srw/"
    xmlns:viaf="http://viaf.org/viaf/terms#"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output method="html" encoding="UTF-8" indent="yes"/>
    
    <xsl:param name="p_base-font-size" select="3"/>
    
    <!-- this stylesheet generates a simple wordcloud using  HTML and inline CSS
        - input: custom xml with author statistics based on the MODS files (output from mods_statistics.xsl )
        - output: HTML
    -->
    <xsl:param name="p_master-entities" select="doc('../../authority-files/tei/entities_master.TEIP5.xml')"/>
    
    <xsl:param name="p_year-start" select="1875"/>
    <xsl:param name="p_year-stop" select="1908"/>
       
    <!-- run stylesheet on root  -->
    <xsl:template match="/">
        <html>
            <xsl:copy-of select="$v_html-head"/>
            <body>
        <div>
            <h1>authors and numbers of articles:</h1>
            <h2><xsl:value-of select="$p_year-start"/> until <xsl:value-of select="$p_year-stop"/></h2>
            <xsl:apply-templates/>
        </div>
            </body>
        </html>
    </xsl:template>
    
    <!-- deal with individual authors -->
    <xsl:template match="oap:object[descendant::oap:key='name']">
        <xsl:variable name="v_number">
            <xsl:choose>
                <!-- if data is missing from the source, select the total number of articles  -->
                <xsl:when test="oap:array[oap:key='articles']/oap:object/oap:item[oap:key='year']/oap:value=''">
                    <xsl:value-of select="oap:array[oap:key='articles']/oap:object/oap:item[oap:key='total']/oap:value"/>
                </xsl:when>
                <!-- otherwise the source should contain data for the time span  -->
                <xsl:otherwise>
                    <xsl:value-of select="sum(oap:array[oap:key='articles']/oap:object[$p_year-start &lt;= oap:item[oap:key='year']/oap:value][oap:item[oap:key='year']/oap:value &lt;= $p_year-stop]/oap:item[oap:key='articles']/oap:value)"/>
                </xsl:otherwise>
            </xsl:choose>
            <!--<xsl:value-of select="sum(oap:array[oap:key='articles']/oap:object[$p_year-start &lt;= oap:item[oap:key='year']/oap:value][oap:item[oap:key='year']/oap:value &lt;= $p_year-stop]/oap:item[oap:key='articles']/oap:value)"/>-->
        </xsl:variable>
        <!-- check if the author published anything during the time span -->
        <xsl:if test="$v_number &gt; 0">
            <!-- calculate the size as a percentage of the maximum number of articles in a given period -->
            <xsl:variable name="v_percentage" select="$v_number * 100 div $v_number-max"/>
            <xsl:variable name="v_decile" select="floor($v_percentage div 10)"/>
            <xsl:variable name="v_id-viaf" select="oap:item[oap:key='viaf']/oap:value"/>
            <xsl:variable name="v_name" select="oap:item[oap:key='name']/oap:value"/>
            <xsl:variable name="v_date-birth">
                <xsl:if test="$v_id-viaf!=''">
                    <xsl:value-of select="$p_master-entities//tei:person[tei:idno[@type='viaf']=$v_id-viaf]/tei:birth/@when"/>
                </xsl:if>
            </xsl:variable>
            <xsl:variable name="v_date-death">
                <xsl:if test="$v_id-viaf!=''">
                    <xsl:value-of select="$p_master-entities//tei:person[tei:idno[@type='viaf']=$v_id-viaf]/tei:death/@when"/>
                </xsl:if>
            </xsl:variable>
            <!-- query viaf for titles -->
            <xsl:variable name="v_viaf-srw" select="doc(concat('https://viaf.org/viaf/search?query=local.viafID+any+&quot;',$v_id-viaf,'&quot;&amp;httpAccept=application/xml'))"/>
            <xsl:variable name="v_viaf-record" select="$v_viaf-srw/descendant-or-self::srw:searchRetrieveResponse/srw:records/srw:record[srw:recordData[@xsi:type='ns1:stringOrXmlFragment']/viaf:VIAFCluster[.//viaf:viafID=$v_id-viaf]]"/>
            
            <xsl:variable name="v_works" select="$v_viaf-record/descendant-or-self::viaf:titles"/>
            <xsl:variable name="v_works-number" select="count($v_works/descendant-or-self::viaf:work)"/>
            <!-- result -->
<!--            <span class="c_item" style="font-size: {$v_number * $p_base-font-size + 10}px; color: #F9{$v_number * $p_base-font-size * 41}7;">-->
                <span class="c_item c_decile-{$v_decile}">
                    <!-- add an icon-like span -->
                    <span class="c_icon circle c_decile-{$v_decile}"/>
                <xsl:choose>
                    <xsl:when test="$v_id-viaf!=''">
                        <a class="c_name" href="https://viaf.org/viaf/{$v_id-viaf}" target="_blank">
                            <span class="c_name"><xsl:value-of select="$v_name"/></span>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <span class="c_name"><xsl:value-of select="$v_name"/></span>
                    </xsl:otherwise>
                </xsl:choose>
                <!-- values -->
                <!-- life dates -->
                <xsl:if test="$v_date-birth!='' or $v_date-death!=''">
                    <span class="c_dates c_viaf">
                        <xsl:if test="$v_date-birth!=''">
                            <span class="c_birth"><xsl:value-of select="tokenize($v_date-birth,'-')[1]"/></span>
                        </xsl:if>
                        <xsl:if test="$v_date-death!=''">
                            <span class="c_death"><xsl:value-of select="tokenize($v_date-death,'-')[1]"/></span>
                        </xsl:if>
                    </span>
                </xsl:if>
                <!--<xsl:if test="$v_works!=''">
                <span class="c_number-works c_viaf"><xsl:value-of select="$v_works-number"/></span>
            </xsl:if>-->
                <!-- number of articles -->
                <span class="c_number"><xsl:value-of select="$v_number"/></span>
            </span>
        </xsl:if>
    </xsl:template>
    
    <!-- variable storing the HTML head -->
    <xsl:variable name="v_html-head">
        <head>
            <title></title>
            <meta charset="utf-8"></meta>
            <style type="text/css">
                body {
                font-family: Helvetica;
                font-weight: lighter;
                padding: 1em;
                /* max-width: 90%; */
                }
                div {
                display: block;
                }
                span {
                display: inline-block;
                /*float: right;*/
                }
                .c_item {
                display: block;
                float: right;
                padding-left: 10px;
                padding-right: 10px; 
                }
                /* deciles */
                .c_decile-0 {
                font-size: 16px;
                color: #1B8500;
                }
                .c_decile-1 {
                font-size: 19px;
                color: #88C816; /* better colour? */
                }
                .c_decile-2 {
                font-size: 21px;
                color: #00AAB7;
                }
                .c_decile-3 {
                font-size: 24px;
                color: #0143DB;
                }
                .c_decile-4 {
                font-size: 27px;
                color: #6E42F7;
                }
                .c_decile-5 {
                font-size: 30px;
                color: #8435D9;
                }
                .c_decile-6 {
                font-size: 33px;
                color: #CC3FFF;
                }
                .c_decile-7 {
                font-size: 36px;
                color: #FF2F8F;
                }
                .c_decile-8 {
                font-size: 39px;
                color: #FF7A80;
                }
                .c_decile-9 {
                font-size: 42px;
                color: #F7240C;
                }
                .c_decile-10 {
                font-size: 45px;
                color: #A9172B;
                }
                /* other information */
                .c_name, .c_number, .c_dates {
                float: right;
                }
                
                .c_number:before{
                content: ": ";
                float: right;
                }
                .c_viaf {
                font-size: 60%;
                font-weight: lighter;
                vertical-align: middle;
                }
                .c_dates:before{
                content: "("
                }
                .c_dates:after{
                content: ")"
                }
                .c_birth:before{
                content: "b."
                }
                .c_death {
                display: none;
                }
                a {
                text-decoration: none;
                color: inherit;
                }
                /* icons */
                .c_icon {
                margin: 1px;
                padding-right: 0px;
                display: block;
                float: left;
                clear: none;
                }
                /* shapes */
                .sphere {
                border-radius: 50%;
                text-align: center;
                vertical-align: middle;
                font-size: 500%;
                position: relative;
                box-shadow: inset -5px -5px 50px #000, 5px 5px 10px black, inset 0px 0px 5px black;
                display: inline-block;
                /*float:right;*/
                }
                .sphere::after {
                background-color: rgba(255, 255, 255, 0.3);
                content: '';
                height: 45%;
                width: 12%;
                position: absolute;
                top: 4%;
                left: 15%;
                border-radius: 50%;
                transform: rotate(40deg);
                }
                
                .circle {
                border-radius: 50%;
                position: relative;
                display: inline-block;
                text-align: center;
                vertical-align: middle;
                box-shadow: inset -5px -5px 30px #000 /*, 5px 5px 10px black/*, inset 0px 0px 5px black*/;
                }
                /* sizes and colors*/
                .c_decile-0.c_icon {
                width: 20px;
                height: 20px;
                background-color: #1B8500;
                }
                .c_decile-1.c_icon  {
                width: 30px;
                height: 30px;
                background-color: #88C816; /* better colour? */
                }
                .c_decile-2.c_icon {
                width: 40px;
                height: 40px;
                background-color: #00AAB7;
                }
                .c_decile-3.c_icon {
                width: 50px;
                height: 50px;
                background-color: #0143DB;
                }
                .c_decile-4.c_icon {
                width: 60px;
                height: 60px;
                background-color: #6E42F7;
                }
                .c_decile-5.c_icon {
                width: 70px;
                height: 70px;
                background-color: #8435D9;
                }
                .c_decile-6.c_icon {
                width: 80px;
                height: 80px;
                background-color: #CC3FFF;
                }
                .c_decile-7.c_icon {
                width: 90px;
                height: 90px;
                background-color: #FF2F8F;
                }
                .c_decile-8.c_icon {
                width: 100px;
                height: 100px;
                background-color: #FF7A80;
                }
                .c_decile-9.c_icon {
                width: 110px;
                height: 110px;
                background-color: #F7240C;
                }
                .c_decile-10.c_icon {
                width: 120px;
                height: 120px;
                background-color: #A9172B;
                }
                .c_icon /*, .c_name, .c_number, .c_viaf */ {
                display: none;
                }
            </style>
        </head>
    </xsl:variable>
    
    <!-- calculate the maximum number of articles per author during the time span -->
    <xsl:variable name="v_number-max">
        <xsl:variable name="v_numbers-all">
            <xsl:apply-templates select="/descendant::oap:object[descendant::oap:key='name']" mode="m_number"/>
        </xsl:variable>
        <xsl:value-of select="max($v_numbers-all/descendant::oap:value)"/>
    </xsl:variable>
    <xsl:template match="oap:object[descendant::oap:key='name']" mode="m_number">
        <xsl:variable name="v_number">
            <xsl:choose>
                <!-- if data is missing from the source, select the total number of articles  -->
                <xsl:when test="oap:array[oap:key='articles']/oap:object/oap:item[oap:key='year']/oap:value=''">
                    <xsl:value-of select="oap:array[oap:key='articles']/oap:object/oap:item[oap:key='total']/oap:value"/>
                </xsl:when>
                <!-- otherwise the source should contain data for the time span  -->
                <xsl:otherwise>
                    <xsl:value-of select="sum(oap:array[oap:key='articles']/oap:object[$p_year-start &lt;= oap:item[oap:key='year']/oap:value][oap:item[oap:key='year']/oap:value &lt;= $p_year-stop]/oap:item[oap:key='articles']/oap:value)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$v_number &gt; 0">
            <oap:item>
                <oap:key>articles</oap:key>
                <oap:value><xsl:value-of select="$v_number"/></oap:value>
            </oap:item>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>