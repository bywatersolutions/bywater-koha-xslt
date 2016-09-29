<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: MARC21slim2DC.xsl,v 1.1 2003/01/06 08:20:27 adam Exp $ -->
<!-- Edited: Bug 1807 [ENH] XSLT enhancements sponsored by bywater solutions 2015/01/19 WS wsalesky@gmail.com  -->
<!DOCTYPE stylesheet [<!ENTITY nbsp "&#160;" >]>
<xsl:stylesheet version="1.0"
  xmlns:marc="http://www.loc.gov/MARC21/slim"
  xmlns:items="http://www.koha-community.org/items"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:str="http://exslt.org/strings"
  exclude-result-prefixes="marc items">
    <xsl:import href="MARC21slimUtils.xsl"/>
    <xsl:output method = "html" indent="yes" omit-xml-declaration = "yes" encoding="UTF-8"/>

    <xsl:template match="/">
            <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="marc:record">

        <!-- Option: Display Alternate Graphic Representation (MARC 880)  -->
        <xsl:variable name="display880" select="boolean(marc:datafield[@tag=880])"/>

        <xsl:variable name="UseControlNumber" select="marc:sysprefs/marc:syspref[@name='UseControlNumber']"/>
        <xsl:variable name="DisplayOPACiconsXSLT" select="marc:sysprefs/marc:syspref[@name='DisplayOPACiconsXSLT']"/>
        <xsl:variable name="OPACURLOpenInNewWindow" select="marc:sysprefs/marc:syspref[@name='OPACURLOpenInNewWindow']"/>
        <xsl:variable name="URLLinkText" select="marc:sysprefs/marc:syspref[@name='URLLinkText']"/>

        <xsl:variable name="SubjectModifier"><xsl:if test="marc:sysprefs/marc:syspref[@name='TraceCompleteSubfields']='1'">,complete-subfield</xsl:if></xsl:variable>
        <xsl:variable name="UseAuthoritiesForTracings" select="marc:sysprefs/marc:syspref[@name='UseAuthoritiesForTracings']"/>
        <xsl:variable name="TraceSubjectSubdivisions" select="marc:sysprefs/marc:syspref[@name='TraceSubjectSubdivisions']"/>
        <xsl:variable name="Show856uAsImage" select="marc:sysprefs/marc:syspref[@name='OPACDisplay856uAsImage']"/>
        <xsl:variable name="OPACTrackClicks" select="marc:sysprefs/marc:syspref[@name='TrackClicks']"/>
        <xsl:variable name="theme" select="marc:sysprefs/marc:syspref[@name='opacthemes']"/>
        <xsl:variable name="biblionumber" select="marc:datafield[@tag=999]/marc:subfield[@code='c']"/>
        <xsl:variable name="TracingQuotesLeft">
            <xsl:choose>
              <xsl:when test="marc:sysprefs/marc:syspref[@name='UseICU']='1'">{</xsl:when>
              <xsl:otherwise>"</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="TracingQuotesRight">
          <xsl:choose>
            <xsl:when test="marc:sysprefs/marc:syspref[@name='UseICU']='1'">}</xsl:when>
            <xsl:otherwise>"</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="leader" select="marc:leader"/>
        <xsl:variable name="leader6" select="substring($leader,7,1)"/>
        <xsl:variable name="leader7" select="substring($leader,8,1)"/>
        <xsl:variable name="leader19" select="substring($leader,20,1)"/>
        <xsl:variable name="controlField008" select="marc:controlfield[@tag=008]"/>
        <xsl:variable name="materialTypeCode">
            <xsl:choose>
                <xsl:when test="$leader19='a'">ST</xsl:when>
                <xsl:when test="$leader6='a'">
                    <xsl:choose>
                        <xsl:when test="$leader7='c' or $leader7='d' or $leader7='m'">BK</xsl:when>
                        <xsl:when test="$leader7='i' or $leader7='s'">SE</xsl:when>
                        <xsl:when test="$leader7='a' or $leader7='b'">AR</xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$leader6='t'">BK</xsl:when>
                <xsl:when test="$leader6='o' or $leader6='p'">MX</xsl:when>
                <xsl:when test="$leader6='m'">CF</xsl:when>
                <xsl:when test="$leader6='e' or $leader6='f'">MP</xsl:when>
                <xsl:when test="$leader6='g' or $leader6='k' or $leader6='r'">VM</xsl:when>
                <xsl:when test="$leader6='i' or $leader6='j'">MU</xsl:when>
                <xsl:when test="$leader6='c' or $leader6='d'">PR</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="materialTypeLabel">
            <xsl:choose>
                <xsl:when test="$leader19='a'">Set</xsl:when>
                <xsl:when test="$leader6='a'">
                    <xsl:choose>
                        <xsl:when test="$leader7='c' or $leader7='d' or $leader7='m'">Book</xsl:when>
                        <xsl:when test="$leader7='i' or $leader7='s'">
                            <xsl:choose>
                                <xsl:when test="substring($controlField008,22,1)!='m'">Continuing resource</xsl:when>
                                <xsl:otherwise>Series</xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="$leader7='a' or $leader7='b'">Article</xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$leader6='t'">Book</xsl:when>
				<xsl:when test="$leader6='o'">Kit</xsl:when>
                <xsl:when test="$leader6='p'">Mixed materials</xsl:when>
                <xsl:when test="$leader6='m'">Computer file</xsl:when>
                <xsl:when test="$leader6='e' or $leader6='f'">Map</xsl:when>
                <xsl:when test="$leader6='g' or $leader6='k' or $leader6='r'">Visual material</xsl:when>
                <xsl:when test="$leader6='j'">Music</xsl:when>
                <xsl:when test="$leader6='i'">Sound</xsl:when>
                <xsl:when test="$leader6='c' or $leader6='d'">Score</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- #27193 used by 008/007 display, see Material type, Format and Type of continuing resource -->
        <xsl:variable name="typeOf008">
            <xsl:choose>
                <xsl:when test="$leader19='a'">ST</xsl:when>
                <xsl:when test="$leader6='a'">
                    <xsl:choose>
                        <xsl:when test="$leader7='a' or $leader7='c' or $leader7='d' or $leader7='m'">BK</xsl:when>
                        <xsl:when test="$leader7='b' or $leader7='i' or $leader7='s'">CR</xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$leader6='t'">BK</xsl:when>
                <xsl:when test="$leader6='o' or $leader6='p'">MX</xsl:when>
                <xsl:when test="$leader6='m'">CF</xsl:when>
                <xsl:when test="$leader6='e' or $leader6='f'">MP</xsl:when>
                <xsl:when test="$leader6='g' or $leader6='k' or $leader6='r'">VM</xsl:when>
                <xsl:when test="$leader6='i' or $leader6='j'">MU</xsl:when>
                <xsl:when test="$leader6='c' or $leader6='d'">PR</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="controlField008-23" select="substring($controlField008,24,1)"/>
        <xsl:variable name="controlField008-21" select="substring($controlField008,22,1)"/>
        <xsl:variable name="controlField008-22" select="substring($controlField008,23,1)"/>
        <xsl:variable name="controlField008-24" select="substring($controlField008,25,4)"/>
        <xsl:variable name="controlField008-26" select="substring($controlField008,27,1)"/>
        <xsl:variable name="controlField008-29" select="substring($controlField008,30,1)"/>
        <xsl:variable name="controlField008-34" select="substring($controlField008,35,1)"/>
        <xsl:variable name="controlField008-33" select="substring($controlField008,34,1)"/>
        <xsl:variable name="controlField008-30-31" select="substring($controlField008,31,2)"/>

        <xsl:variable name="physicalDescription">
            <xsl:if test="$typeOf008='CF' and marc:controlfield[@tag=007][substring(.,12,1)='a']">
                reformatted digital
            </xsl:if>
            <xsl:if test="$typeOf008='CF' and marc:controlfield[@tag=007][substring(.,12,1)='b']">
                digitized microfilm
            </xsl:if>
            <xsl:if test="$typeOf008='CF' and marc:controlfield[@tag=007][substring(.,12,1)='d']">
                digitized other analog
            </xsl:if>

            <xsl:variable name="check008-23">
                <xsl:if test="$typeOf008='BK' or $typeOf008='MU' or $typeOf008='CR' or $typeOf008='MX'">
                    <xsl:value-of select="true()"></xsl:value-of>
                </xsl:if>
            </xsl:variable>
            <xsl:variable name="check008-29">
                <xsl:if test="$typeOf008='MP' or $typeOf008='VM'">
                    <xsl:value-of select="true()"></xsl:value-of>
                </xsl:if>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="($check008-23 and $controlField008-23='f') or ($check008-29 and $controlField008-29='f')">
                    braille
                </xsl:when>
                <xsl:when test="($controlField008-23=' ' and ($leader6='c' or $leader6='d')) or (($typeOf008='BK' or $typeOf008='CR') and ($controlField008-23=' ' or $controlField008='r'))">
                    print
                </xsl:when>
                <xsl:when test="$leader6 = 'm' or ($check008-23 and $controlField008-23='s') or ($check008-29 and $controlField008-29='s')">
                    electronic
                </xsl:when>
                <xsl:when test="($check008-23 and $controlField008-23='b') or ($check008-29 and $controlField008-29='b')">
                    microfiche
                </xsl:when>
                <xsl:when test="($check008-23 and $controlField008-23='a') or ($check008-29 and $controlField008-29='a')">
                    microfilm
                </xsl:when>
            </xsl:choose>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='b']">
                chip cartridge
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='c']">
                <img src="/opac-tmpl/lib/famfamfam/silk/cd.png" alt="computer optical disc cartridge" title="computer optical disc cartridge" class="format"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='j']">
                magnetic disc
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='m']">
                magneto-optical disc
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='o']">
                <img src="/opac-tmpl/lib/famfamfam/silk/cd.png" alt="optical disc" title="optical disc" class="format"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='r']">
		available online
                <img src="/opac-tmpl/lib/famfamfam/silk/drive_web.png" alt="remote" title="remote" class="format"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='a']">
                tape cartridge
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='f']">
                tape cassette
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='h']">
                tape reel
            </xsl:if>

            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='d'][substring(text(),2,1)='a']">
                <img src="/opac-tmpl/lib/famfamfam/silk/world.png" alt="celestial globe" title="celestial globe" class="format"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='d'][substring(text(),2,1)='e']">
                <img src="/opac-tmpl/lib/famfamfam/silk/world.png" alt="earth moon globe" title="earth moon globe" class="format"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='d'][substring(text(),2,1)='b']">
                <img src="/opac-tmpl/lib/famfamfam/silk/world.png" alt="planetary or lunar globe" title="planetary or lunar globe" class="format"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='d'][substring(text(),2,1)='c']">
                <img src="/opac-tmpl/lib/famfamfam/silk/world.png" alt="terrestrial globe" title="terrestrial globe" class="format"/>
            </xsl:if>

            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='o'][substring(text(),2,1)='o']">
                kit
            </xsl:if>

            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='d']">
                atlas
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='g']">
                diagram
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='j']">
                map
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='q']">
                model
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='k']">
                profile
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='r']">
                remote-sensing image
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='s']">
                section
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='y']">
                view
            </xsl:if>

            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='a']">
                aperture card
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='e']">
                microfiche
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='f']">
                microfiche cassette
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='b']">
                microfilm cartridge
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='c']">
                microfilm cassette
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='d']">
                microfilm reel
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='g']">
                microopaque
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='m'][substring(text(),2,1)='c']">
                film cartridge
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='m'][substring(text(),2,1)='f']">
                film cassette
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='m'][substring(text(),2,1)='r']">
                film reel
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='n']">
                <img src="/opac-tmpl/lib/famfamfam/silk/chart_curve.png" alt="chart" title="chart" class="format"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='c']">
                collage
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='d']">
                 <img src="/opac-tmpl/lib/famfamfam/silk/pencil.png" alt="drawing" title="drawing" class="format"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='o']">
                <img src="/opac-tmpl/lib/famfamfam/silk/note.png" alt="flash card" title="flash card" class="format"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='e']">
                <img src="/opac-tmpl/lib/famfamfam/silk/paintbrush.png" alt="painting" title="painting" class="format"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='f']">
                photomechanical print
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='g']">
                photonegative
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='h']">
                photoprint
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='i']">
                <img src="/opac-tmpl/lib/famfamfam/silk/picture.png" alt="picture" title="picture" class="format"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='j']">
                print
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='l']">
                technical drawing
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='q'][substring(text(),2,1)='q']">
                <img src="/opac-tmpl/lib/famfamfam/silk/script.png" alt="notated music" title="notated music" class="format"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='g'][substring(text(),2,1)='d']">
                filmslip
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='g'][substring(text(),2,1)='c']">
                filmstrip cartridge
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='g'][substring(text(),2,1)='o']">
                filmstrip roll
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='g'][substring(text(),2,1)='f']">
                other filmstrip type
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='g'][substring(text(),2,1)='s']">
                <img src="/opac-tmpl/lib/famfamfam/silk/pictures.png" alt="slide" title="slide" class="format"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='g'][substring(text(),2,1)='t']">
                transparency
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='r'][substring(text(),2,1)='r']">
                remote-sensing image
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='e']">
                cylinder
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='q']">
                roll
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='g']">
                sound cartridge
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='s']">
                sound cassette
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='d']">
                <img src="/opac-tmpl/lib/famfamfam/silk/cd.png" alt="sound disc" title="sound disc" class="format"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='t']">
                sound-tape reel
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='i']">
                sound-track film
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='w']">
                wire recording
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='f'][substring(text(),2,1)='c']">
                combination
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='f'][substring(text(),2,1)='b']">
                braille
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='f'][substring(text(),2,1)='a']">
                moon
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='f'][substring(text(),2,1)='d']">
                tactile, with no writing system
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='t'][substring(text(),2,1)='c']">
                braille
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='t'][substring(text(),2,1)='b']">
                <img src="/opac-tmpl/lib/famfamfam/silk/magnifier.png" alt="large print" title="large print" class="format"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='t'][substring(text(),2,1)='a']">
                regular print
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='t'][substring(text(),2,1)='d']">
                text in looseleaf binder
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='v'][substring(text(),2,1)='c']">
                videocartridge
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='v'][substring(text(),2,1)='f']">
                videocassette
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='v'][substring(text(),2,1)='d']">
                <img src="/opac-tmpl/lib/famfamfam/silk/dvd.png" alt="videodisc" title="videodisc" class="format"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='v'][substring(text(),2,1)='r']">
                videoreel
            </xsl:if>
        </xsl:variable>


        <!-- Schema.org type -->
        <xsl:variable name="schemaOrgType">
            <xsl:choose>
                <xsl:when test="$materialTypeLabel='Book'">Book</xsl:when>
                <xsl:when test="$materialTypeLabel='Map'">Map</xsl:when>
                <xsl:when test="$materialTypeLabel='Music'">MusicAlbum</xsl:when>
                <xsl:otherwise>CreativeWork</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Wrapper div for our schema.org object -->
        <xsl:element name="div">
            <xsl:attribute name="class">record</xsl:attribute>
            <xsl:attribute name="vocab">http://schema.org/</xsl:attribute>
            <xsl:attribute name="typeof"><xsl:value-of select='$schemaOrgType' /> Product</xsl:attribute>
            <xsl:attribute name="resource">#record</xsl:attribute>

        <!-- Title Statement -->
        <!-- Alternate Graphic Representation (MARC 880) -->
        <xsl:if test="$display880">
            <h1 class="title" property="alternateName">
                <xsl:call-template name="m880Select">
                    <!-- #27193 Add 240 -->
                    <xsl:with-param name="basetags">245,240</xsl:with-param>
                    <xsl:with-param name="codes">abhfgknps</xsl:with-param>
                </xsl:call-template>
            </h1>
        </xsl:if>

            <!--Bug 13381 -->
            <!-- #27193 Add 240 -->
            <xsl:choose>
                <xsl:when test="marc:datafield[@tag=245]">
                    <h1 class="title" property="name">
                        <xsl:for-each select="marc:datafield[@tag=245]">
                            <xsl:call-template name="subfieldSelect">
                                <xsl:with-param name="codes">a</xsl:with-param>
                            </xsl:call-template>
                            <xsl:text> </xsl:text>
                            <!-- 13381 add additional subfields-->
                            <xsl:for-each select="marc:subfield[contains('bchknps', @code)]">
                                <xsl:choose>
                                    <xsl:when test="@code='h'">
                                        <!--  13381 Span class around subfield h so it can be suppressed via css -->
                                        <span class="title_medium"><xsl:apply-templates/> </span>
                                    </xsl:when>
                                    <xsl:when test="@code='c'">
                                        <!--  13381 Span class around subfield c so it can be suppressed via css -->
                                        <span class="title_resp_stmt"><xsl:apply-templates/> </span>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates/>
                                        <xsl:text> </xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:for-each>
                    </h1>
                </xsl:when>
                <xsl:when test="marc:datafield[@tag=240]">
                    <h1 class="title" property="name">
                        <xsl:for-each select="marc:datafield[@tag=240]">
                            <xsl:call-template name="subfieldSelect">
                                <xsl:with-param name="codes">a</xsl:with-param>
                            </xsl:call-template>
                            <xsl:text> </xsl:text>
                            <!-- 13381 add additional subfields-->
                            <xsl:for-each select="marc:subfield[contains('bchknps', @code)]">
                                <xsl:choose>
                                    <xsl:when test="@code='h'">
                                        <!--  13381 Span class around subfield h so it can be suppressed via css -->
                                        <span class="title_medium"><xsl:apply-templates/> </span>
                                    </xsl:when>
                                    <xsl:when test="@code='c'">
                                        <!--  13381 Span class around subfield c so it can be suppressed via css -->
                                        <span class="title_resp_stmt"><xsl:apply-templates/> </span>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates/>
                                        <xsl:text> </xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:for-each>
                    </h1>
                </xsl:when>
            </xsl:choose>


        <!-- Author Statement: Alternate Graphic Representation (MARC 880) -->
        <xsl:if test="$display880">
            <h5 class="author">
                <xsl:call-template name="m880Select">
                    <xsl:with-param name="basetags">100,110,111,700,710,711</xsl:with-param>
                    <xsl:with-param name="codes">abc</xsl:with-param>
                    <xsl:with-param name="index">au</xsl:with-param>
                    <!-- do not use label 'by ' here, it would be repeated for every occurrence of 100,110,111,700,710,711 -->
                </xsl:call-template>
            </h5>
        </xsl:if>

        <!--#13382 Added Author Statement to separate Authors and Contributors -->
        <xsl:call-template name="showAuthor">
            <xsl:with-param name="authorfield" select="marc:datafield[(@tag=100 or @tag=110 or @tag=111)]"/>
            <xsl:with-param name="UseAuthoritiesForTracings" select="$UseAuthoritiesForTracings"/>
            <xsl:with-param name="materialTypeLabel" select="$materialTypeLabel"/>
            <xsl:with-param name="theme" select="$theme"/>
        </xsl:call-template>

        <xsl:call-template name="showAuthor">
            <!-- #13382 suppress 700$i and 7xx/@ind2=2 -->
            <xsl:with-param name="authorfield" select="marc:datafield[(@tag=700 or @tag=710 or @tag=711) and not(@ind2=2) and not(marc:subfield[@code='i'])]"/>
            <xsl:with-param name="UseAuthoritiesForTracings" select="$UseAuthoritiesForTracings"/>
            <xsl:with-param name="materialTypeLabel" select="$materialTypeLabel"/>
            <xsl:with-param name="theme" select="$theme"/>
        </xsl:call-template>
        
        <!-- #27193 Add 007/008 -->
        <xsl:if test="$DisplayOPACiconsXSLT!='0'">
            <span class="results_summary type">
                <xsl:if test="$materialTypeCode!=''">
                    <span class="results_material_type"><span class="label">Material type: </span>
                        <xsl:element name="img"><xsl:attribute name="src">/opac-tmpl/lib/famfamfam/<xsl:value-of select="$materialTypeCode"/>.png</xsl:attribute><xsl:attribute name="alt">materialTypeLabel</xsl:attribute><xsl:attribute name="class">materialtype</xsl:attribute></xsl:element>
                        <xsl:value-of select="$materialTypeLabel"/>
                    </span>
                </xsl:if>
                <xsl:if test="string-length(normalize-space($physicalDescription))">
                    <span class="results_format">
                        <span class="label">; Format: </span><xsl:copy-of select="$physicalDescription"></xsl:copy-of>
                    </span>
                </xsl:if>
                <xsl:if test="$controlField008-21 or $controlField008-22 or $controlField008-24 or $controlField008-26 or $controlField008-29 or $controlField008-34 or $controlField008-33 or $controlField008-30-31 or $controlField008-33">   
                    <xsl:if test="$typeOf008='CR'">
                        <span class="results_typeofcontinuing">
                        <xsl:if test="$controlField008-21 and $controlField008-21 !='|' and $controlField008-21 !=' '">
                        <span class="label">; Type of continuing resource: </span>
                        </xsl:if>
                            <xsl:choose>
                                <xsl:when test="$controlField008-21='d'">
                                     <img src="/opac-tmpl/lib/famfamfam/silk/database.png" alt="database" title="database" class="format"/>
                                </xsl:when>
                                <xsl:when test="$controlField008-21='l'">
                                    loose-leaf
                                </xsl:when>
                                <xsl:when test="$controlField008-21='m'">
                                    series
                                </xsl:when>
                                <xsl:when test="$controlField008-21='n'">
                                    newspaper
                                </xsl:when>
                                <xsl:when test="$controlField008-21='p'">
                                    periodical
                                </xsl:when>
                                <xsl:when test="$controlField008-21='w'">
                                     <img src="/opac-tmpl/lib/famfamfam/silk/world_link.png" alt="web site" title="web site" class="format"/>
                                </xsl:when>
                            </xsl:choose>
                        </span>
                    </xsl:if>
                    <xsl:if test="$typeOf008='BK' or $typeOf008='CR'">
                        <xsl:if test="contains($controlField008-24,'abcdefghijklmnopqrstvwxyz')">
                            <span class="results_natureofcontents">
                            <span class="label">; Nature of contents: </span>
                                <xsl:choose>
                                    <xsl:when test="contains($controlField008-24,'a')">
                                        abstract or summary
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'b')">
                    			bibliography
                                         <img src="/opac-tmpl/lib/famfamfam/silk/text_list_bullets.png" alt="bibliography" title="bibliography" class="natureofcontents"/>
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'c')">
                                        catalog
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'d')">
                                        dictionary
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'e')">
                                        encyclopedia
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'f')">
                                        handbook
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'g')">
                                        legal article
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'i')">
                                        index
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'k')">
                                        discography
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'l')">
                                        legislation
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'m')">
                                        theses
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'n')">
                                        survey of literature
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'o')">
                                        review
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'p')">
                                        programmed text
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'q')">
                                        filmography
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'r')">
                                        directory
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'s')">
                                        statistics
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'t')">
                                         <img src="/opac-tmpl/lib/famfamfam/silk/report.png" alt="technical report" title="technical report" class="natureofcontents"/>
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'v')">
                                        legal case and case notes
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'w')">
                                        law report or digest
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'z')">
                                        treaty
                                    </xsl:when>
                                </xsl:choose>
                                <xsl:choose>
                                    <xsl:when test="$controlField008-29='1'">
                                        conference publication
                                    </xsl:when>
                                </xsl:choose>
                            </span>
                        </xsl:if>    
                    </xsl:if>
                    <xsl:if test="$typeOf008='CF'">
                        <span class="results_typeofcomp">
                            <xsl:if test="$controlField008-26='a' or $controlField008-26='e' or $controlField008-26='f' or $controlField008-26='g'">
                            <span class="label">; Type of computer file: </span>
                            </xsl:if>
                            <xsl:choose>
                                <xsl:when test="$controlField008-26='a'">
                                    numeric data
                                </xsl:when>
                                <xsl:when test="$controlField008-26='e'">
                                     <img src="/opac-tmpl/lib/famfamfam/silk/database.png" alt="database" title="database" class="format"/>
                                </xsl:when>
                                <xsl:when test="$controlField008-26='f'">
                                     <img src="/opac-tmpl/lib/famfamfam/silk/font.png" alt="font" title="font" class="format"/>
                                </xsl:when>
                                <xsl:when test="$controlField008-26='g'">
                                     <img src="/opac-tmpl/lib/famfamfam/silk/controller.png" alt="game" title="game" class="format"/>
                                </xsl:when>
                            </xsl:choose>
                        </span>
                    </xsl:if>
                    <xsl:if test="$typeOf008='BK'">
                        <span class="results_contents_literary">
                            <xsl:if test="(substring($controlField008,25,1)='j') or (substring($controlField008,25,1)='1') or ($controlField008-34='a' or $controlField008-34='b' or $controlField008-34='c' or $controlField008-34='d')">
                            <span class="label">; Nature of contents: </span>
                            </xsl:if>
                            <xsl:if test="substring($controlField008,25,1)='j'">
                                patent
                            </xsl:if>
                            <xsl:if test="substring($controlField008,31,1)='1'">
                                festschrift
                            </xsl:if>
                            <xsl:if test="$controlField008-34='a' or $controlField008-34='b' or $controlField008-34='c' or $controlField008-34='d'">
                                 <img src="/opac-tmpl/lib/famfamfam/silk/user.png" alt="biography" title="biography" class="natureofcontents"/>
                            </xsl:if>
                
                            <xsl:if test="$controlField008-33 and $controlField008-33!='|' and $controlField008-33!='u' and $controlField008-33!=' '">
                            <span class="label">; Literary form: </span>
                            </xsl:if>
                            <xsl:choose>
                                <xsl:when test="$controlField008-33='0'">
                                    not fiction
                                </xsl:when>
                                <xsl:when test="$controlField008-33='1'">
                                    fiction
                                </xsl:when>
                                <xsl:when test="$controlField008-33='e'">
                                    essay
                                </xsl:when>
                                <xsl:when test="$controlField008-33='d'">
                                    drama
                                </xsl:when>
                                <xsl:when test="$controlField008-33='c'">
                                    comic strip
                                </xsl:when>
                                <xsl:when test="$controlField008-33='l'">
                                    fiction
                                </xsl:when>
                                <xsl:when test="$controlField008-33='h'">
                                    humor, satire
                                </xsl:when>
                                <xsl:when test="$controlField008-33='i'">
                                    letter
                                </xsl:when>
                                <xsl:when test="$controlField008-33='f'">
                                    novel
                                </xsl:when>
                                <xsl:when test="$controlField008-33='j'">
                                    short story
                                </xsl:when>
                                <xsl:when test="$controlField008-33='s'">
                                    speech
                                </xsl:when>
                            </xsl:choose>
                        </span>
                    </xsl:if>
                    <xsl:if test="$typeOf008='MU' and $controlField008-30-31 and $controlField008-30-31!='||' and $controlField008-30-31!='  '">
                        <span class="results_literaryform">
                            <span class="label">; Literary form: </span> <!-- Literary text for sound recordings -->
                            <xsl:if test="contains($controlField008-30-31,'b')">
                                biography
                            </xsl:if>
                            <xsl:if test="contains($controlField008-30-31,'c')">
                                conference publication
                            </xsl:if>
                            <xsl:if test="contains($controlField008-30-31,'d')">
                                drama
                            </xsl:if>
                            <xsl:if test="contains($controlField008-30-31,'e')">
                                essay
                            </xsl:if>
                            <xsl:if test="contains($controlField008-30-31,'f')">
                                fiction
                            </xsl:if>
                            <xsl:if test="contains($controlField008-30-31,'o')">
                                folktale
                            </xsl:if>
                            <xsl:if test="contains($controlField008-30-31,'h')">
                                history
                            </xsl:if>
                            <xsl:if test="contains($controlField008-30-31,'k')">
                                humor, satire
                            </xsl:if>
                            <xsl:if test="contains($controlField008-30-31,'m')">
                                memoir
                            </xsl:if>
                            <xsl:if test="contains($controlField008-30-31,'p')">
                                poetry
                            </xsl:if>
                            <xsl:if test="contains($controlField008-30-31,'r')">
                                rehearsal
                            </xsl:if>
                            <xsl:if test="contains($controlField008-30-31,'g')">
                                reporting
                            </xsl:if>
                            <xsl:if test="contains($controlField008-30-31,'s')">
                                sound
                            </xsl:if>
                            <xsl:if test="contains($controlField008-30-31,'l')">
                                speech
                            </xsl:if>
                        </span>
                    </xsl:if>
                    <xsl:if test="$typeOf008='VM'">
                        <span class="results_typeofvisual">
                            <span class="label">; Type of visual material: </span>
                            <xsl:choose>
                                <xsl:when test="$controlField008-33='a'">
                                    art original
                                </xsl:when>
                                <xsl:when test="$controlField008-33='b'">
                                    kit
                                </xsl:when>
                                <xsl:when test="$controlField008-33='c'">
                                    art reproduction
                                </xsl:when>
                                <xsl:when test="$controlField008-33='d'">
                                    diorama
                                </xsl:when>
                                <xsl:when test="$controlField008-33='f'">
                                    filmstrip
                                </xsl:when>
                                <xsl:when test="$controlField008-33='g'">
                                    legal article
                                </xsl:when>
                                <xsl:when test="$controlField008-33='i'">
                                    picture
                                </xsl:when>
                                <xsl:when test="$controlField008-33='k'">
                                    graphic
                                </xsl:when>
                                <xsl:when test="$controlField008-33='l'">
                                    technical drawing
                                </xsl:when>
                                <xsl:when test="$controlField008-33='m'">
                                    motion picture
                                </xsl:when>
                                <xsl:when test="$controlField008-33='n'">
                                    chart
                                </xsl:when>
                                <xsl:when test="$controlField008-33='o'">
                                    flash card
                                </xsl:when>
                                <xsl:when test="$controlField008-33='p'">
                                    microscope slide
                                </xsl:when>
                                <xsl:when test="$controlField008-33='q' or marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='q']">
                                    model
                                </xsl:when>
                                <xsl:when test="$controlField008-33='r'">
                                    realia
                                </xsl:when>
                                <xsl:when test="$controlField008-33='s'">
                                    slide
                                </xsl:when>
                                <xsl:when test="$controlField008-33='t'">
                                    transparency
                                </xsl:when>
                                <xsl:when test="$controlField008-33='v'">
                                    videorecording
                                </xsl:when>
                                <xsl:when test="$controlField008-33='w'">
                                    toy
                                </xsl:when>
                            </xsl:choose>
                         </span>
                    </xsl:if>
                    
                </xsl:if>
        
                <xsl:if test="($typeOf008='BK' or $typeOf008='CF' or $typeOf008='MU' or $typeOf008='VM') and ($controlField008-22='a' or $controlField008-22='b' or $controlField008-22='c' or $controlField008-22='d' or $controlField008-22='e' or $controlField008-22='g' or $controlField008-22='j' or $controlField008-22='f')">
                    <span class="results_audience">
                    <span class="label">; Audience: </span>
                    <xsl:choose>
                        <xsl:when test="$controlField008-22='a'">
                         Preschool;
                        </xsl:when>
                        <xsl:when test="$controlField008-22='b'">
                         Primary;
                        </xsl:when>
                        <xsl:when test="$controlField008-22='c'">
                         Pre-adolescent;
                        </xsl:when>
                        <xsl:when test="$controlField008-22='d'">
                         Adolescent;
                        </xsl:when>
                        <xsl:when test="$controlField008-22='e'">
                         Adult;
                        </xsl:when>
                        <xsl:when test="$controlField008-22='g'">
                         General;
                        </xsl:when>
                        <xsl:when test="$controlField008-22='j'">
                         Juvenile;
                        </xsl:when>
                        <xsl:when test="$controlField008-22='f'">
                         Specialized;
                        </xsl:when>
                    </xsl:choose>
                    </span>
                </xsl:if>
                <xsl:text> </xsl:text> <!-- added blank space to fix font display problem, see Bug 3671 -->
        	</span>
        </xsl:if>

        <!--Series: Alternate Graphic Representation (MARC 880) -->
        <xsl:if test="$display880">
            <xsl:call-template name="m880Select">
                <xsl:with-param name="basetags">440,490</xsl:with-param>
                <xsl:with-param name="codes">av</xsl:with-param>
                <xsl:with-param name="class">results_summary series</xsl:with-param>
                <xsl:with-param name="label">Series: </xsl:with-param>
                <xsl:with-param name="index">se</xsl:with-param>
            </xsl:call-template>
        </xsl:if>

        <!-- Series -->
        <xsl:if test="marc:datafield[@tag=440 or @tag=490]">
        <span class="results_summary series"><span class="label">Series: </span>
        <!-- 440 -->
        <xsl:for-each select="marc:datafield[@tag=440]">
            <a><xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=se,phr:"<xsl:value-of select="marc:subfield[@code='a']"/>"</xsl:attribute>
            <xsl:call-template name="chopPunctuation">
                            <xsl:with-param name="chopString">
                                <xsl:call-template name="subfieldSelect">
                                    <xsl:with-param name="codes">av</xsl:with-param>
                                </xsl:call-template>
                            </xsl:with-param>
                        </xsl:call-template>
            </a>
            <xsl:call-template name="part"/>
            <xsl:choose><xsl:when test="position()=last()"><xsl:text>. </xsl:text></xsl:when><xsl:otherwise><xsl:text> ; </xsl:text></xsl:otherwise></xsl:choose>
        </xsl:for-each>

        <!-- 490 Series not traced, Ind1 = 0 -->
        <xsl:for-each select="marc:datafield[@tag=490][@ind1!=1]">
            <a><xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=se,phr:"<xsl:value-of select="marc:subfield[@code='a']"/>"</xsl:attribute>
                        <xsl:call-template name="chopPunctuation">
                            <xsl:with-param name="chopString">
                                <xsl:call-template name="subfieldSelect">
                                    <xsl:with-param name="codes">av</xsl:with-param>
                                </xsl:call-template>
                            </xsl:with-param>
                        </xsl:call-template>
            </a>
                    <xsl:call-template name="part"/>
        <xsl:choose><xsl:when test="position()=last()"><xsl:text>.</xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
        </xsl:for-each>
        <!-- 490 Series traced, Ind1 = 1 -->
        <xsl:if test="marc:datafield[@tag=490][@ind1=1]">
            <xsl:for-each select="marc:datafield[@tag=800 or @tag=810 or @tag=811 or @tag=830]">
                <xsl:choose>
                    <xsl:when test="$UseControlNumber = '1' and marc:subfield[@code='w']">
                        <a href="/cgi-bin/koha/opac-search.pl?q=rcn:{marc:subfield[@code='w']}">
                            <xsl:call-template name="chopPunctuation">
                                <xsl:with-param name="chopString">
                                    <xsl:call-template name="subfieldSelect">
                                        <xsl:with-param name="codes">a_t</xsl:with-param>
                                    </xsl:call-template>
                                </xsl:with-param>
                            </xsl:call-template>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <a><xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=se,phr:"<xsl:value-of select="marc:subfield[@code='a']"/>"</xsl:attribute>
                            <xsl:call-template name="chopPunctuation">
                                <xsl:with-param name="chopString">
                                    <xsl:call-template name="subfieldSelect">
                                        <xsl:with-param name="codes">a_t</xsl:with-param>
                                    </xsl:call-template>
                                </xsl:with-param>
                            </xsl:call-template>
                        </a>
                        <xsl:call-template name="part"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>: </xsl:text>
                <xsl:value-of  select="marc:subfield[@code='v']" />
            <xsl:choose><xsl:when test="position()=last()"><xsl:text></xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
            </xsl:for-each>
        </xsl:if>
        </span>
        </xsl:if>

        <!-- Analytics -->
        <xsl:if test="$leader7='s'">
        <span class="results_summary analytics"><span class="label">Analytics: </span>
            <a>
            <xsl:choose>
            <xsl:when test="$UseControlNumber = '1' and marc:controlfield[@tag=001]">
                <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=rcn:<xsl:value-of select="marc:controlfield[@tag=001]"/>+and+(bib-level:a+or+bib-level:b)</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=Host-item:<xsl:value-of select="translate(marc:datafield[@tag=245]/marc:subfield[@code='a'], '/', '')"/></xsl:attribute>
            </xsl:otherwise>
            </xsl:choose>
            <xsl:text>Show analytics</xsl:text>
            </a>
        </span>
        </xsl:if>

        <!-- Volumes of sets and traced series -->
        <xsl:if test="$materialTypeCode='ST' or substring($controlField008,22,1)='m'">
        <span class="results_summary volumes"><span class="label">Volumes: </span>
            <a>
            <xsl:choose>
            <xsl:when test="$UseControlNumber = '1' and marc:controlfield[@tag=001]">
                <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=rcn:<xsl:value-of select="marc:controlfield[@tag=001]"/>+not+(bib-level:a+or+bib-level:b)</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=ti,phr:<xsl:value-of select="translate(marc:datafield[@tag=245]/marc:subfield[@code='a'], '/', '')"/></xsl:attribute>
            </xsl:otherwise>
            </xsl:choose>
            <xsl:text>Show volumes</xsl:text>
            </a>
        </span>
        </xsl:if>

        <!-- Set -->
        <xsl:if test="$leader19='c'">
        <span class="results_summary set"><span class="label">Set: </span>
        <xsl:for-each select="marc:datafield[@tag=773]">
            <a>
            <xsl:choose>
            <xsl:when test="$UseControlNumber = '1' and marc:subfield[@code='w']">
                <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=Control-number:<xsl:call-template name="extractControlNumber"><xsl:with-param name="subfieldW" select="marc:subfield[@code='w']"/></xsl:call-template></xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=ti,phr:<xsl:value-of select="translate(//marc:datafield[@tag=245]/marc:subfield[@code='a'], '.', '')"/></xsl:attribute>
            </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="translate(//marc:datafield[@tag=245]/marc:subfield[@code='a'], '.', '')" />
            </a>
            <xsl:choose>
                <xsl:when test="position()=last()"></xsl:when>
                <xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        </span>
        </xsl:if>

        <!-- Publisher Statement: Alternate Graphic Representation (MARC 880) -->
        <xsl:if test="$display880">
            <xsl:call-template name="m880Select">
                <xsl:with-param name="basetags">260</xsl:with-param>
                <xsl:with-param name="codes">abcg</xsl:with-param>
                <xsl:with-param name="class">results_summary publisher</xsl:with-param>
                <xsl:with-param name="label">Publisher: </xsl:with-param>
            </xsl:call-template>
        </xsl:if>

        <!-- Publisher info and RDA related info from tags 260, 264 -->
        <xsl:choose>
            <xsl:when test="marc:datafield[@tag=264]">
                <xsl:call-template name="showRDAtag264"/>
            </xsl:when>
            <xsl:when test="marc:datafield[@tag=260]">
             <span class="results_summary publisher"><span class="label">Publisher: </span>
                 <xsl:for-each select="marc:datafield[@tag=260]">
                     <span property="publisher" typeof="Organization">
                     <xsl:if test="marc:subfield[@code='a']">
                         <span property="location">
                         <xsl:call-template name="subfieldSelect">
                             <xsl:with-param name="codes">a</xsl:with-param>
                         </xsl:call-template>
                         </span>
                     </xsl:if>
                     <xsl:text> </xsl:text>
                     <xsl:if test="marc:subfield[@code='b']">
                     <span property="name"><a href="/cgi-bin/koha/opac-search.pl?q=pb:{marc:subfield[@code='b']}">
                         <xsl:call-template name="subfieldSelect">
                             <xsl:with-param name="codes">b</xsl:with-param>
                         </xsl:call-template>
                     </a></span>
                     </xsl:if>
                     </span>
                     <xsl:text> </xsl:text>
                     <xsl:if test="marc:subfield[@code='c' or @code='g']">
                     <span property="datePublished">
                         <xsl:call-template name="chopPunctuation">
                           <xsl:with-param name="chopString">
                             <xsl:call-template name="subfieldSelect">
                                 <xsl:with-param name="codes">cg</xsl:with-param>
                             </xsl:call-template>
                            </xsl:with-param>
                        </xsl:call-template>
                     </span>
                     </xsl:if>
                     <xsl:choose><xsl:when test="position()=last()"><xsl:text></xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
                 </xsl:for-each>
             </span>
            </xsl:when>
        </xsl:choose>

        <!-- Edition Statement: Alternate Graphic Representation (MARC 880) -->
        <xsl:if test="$display880">
            <xsl:call-template name="m880Select">
                <xsl:with-param name="basetags">250</xsl:with-param>
                <xsl:with-param name="codes">ab</xsl:with-param>
                <xsl:with-param name="class">results_summary edition</xsl:with-param>
                <xsl:with-param name="label">Edition: </xsl:with-param>
            </xsl:call-template>
        </xsl:if>

        <xsl:if test="marc:datafield[@tag=250]">
        <span class="results_summary edition"><span class="label">Edition: </span>
            <xsl:for-each select="marc:datafield[@tag=250]">
                <span property="bookEdition">
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">ab</xsl:with-param>
                    </xsl:call-template>
                   </xsl:with-param>
               </xsl:call-template>
                </span>
                    <xsl:choose><xsl:when test="position()=last()"><xsl:text>.</xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
            </xsl:for-each>
        </span>
        </xsl:if>

        <!-- Description: Alternate Graphic Representation (MARC 880) -->
        <xsl:if test="$display880">
            <xsl:call-template name="m880Select">
                <xsl:with-param name="basetags">300</xsl:with-param>
                <xsl:with-param name="codes">abceg</xsl:with-param>
                <xsl:with-param name="class">results_summary description</xsl:with-param>
                <xsl:with-param name="label">Description: </xsl:with-param>
            </xsl:call-template>
        </xsl:if>

        <xsl:if test="marc:datafield[@tag=300]">
        <span class="results_summary description"><span class="label">Description: </span>
            <xsl:for-each select="marc:datafield[@tag=300]">
                <span property="description">
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">abceg</xsl:with-param>
                    </xsl:call-template>
                   </xsl:with-param>
               </xsl:call-template>
                </span>
                    <xsl:choose><xsl:when test="position()=last()"><xsl:text>.</xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
            </xsl:for-each>
        </span>
       </xsl:if>


            <!-- Content Type -->
            <xsl:if test="marc:datafield[@tag=336] or marc:datafield[@tag=337] or marc:datafield[@tag=338]">
                <span class="results_summary" id="content_type">
                    <xsl:if test="marc:datafield[@tag=336]">
                        <span class="label">Content type: </span>
                        <xsl:for-each select="marc:datafield[@tag=336]">
                            <xsl:call-template name="subfieldSelect">
                                <xsl:with-param name="codes">a</xsl:with-param>
                                <xsl:with-param name="delimeter">, </xsl:with-param>
                            </xsl:call-template>
                            <xsl:if test="position() != last()"><span class="separator"><xsl:text> | </xsl:text></span></xsl:if>
                        </xsl:for-each>
                    </xsl:if>
                    <xsl:text> </xsl:text>
                    <!-- Media Type -->
                    <xsl:if test="marc:datafield[@tag=337]">
                        <span class="label">Media type: </span>
                        <xsl:for-each select="marc:datafield[@tag=337]">
                            <xsl:call-template name="subfieldSelect">
                                <xsl:with-param name="codes">a</xsl:with-param>
                                <xsl:with-param name="delimeter">, </xsl:with-param>
                            </xsl:call-template>
                            <xsl:if test="position() != last()"><span class="separator"><xsl:text> | </xsl:text></span></xsl:if>
                        </xsl:for-each>
                    </xsl:if>
                    <xsl:text> </xsl:text>
                    <!-- Media Type -->
                    <xsl:if test="marc:datafield[@tag=338]">
                        <span class="label">Carrier type: </span>
                        <xsl:for-each select="marc:datafield[@tag=338]">
                            <xsl:call-template name="subfieldSelect">
                                <xsl:with-param name="codes">a</xsl:with-param>
                                <xsl:with-param name="delimeter">, </xsl:with-param>
                            </xsl:call-template>
                            <xsl:if test="position() != last()"><span class="separator"><xsl:text> | </xsl:text></span></xsl:if>
                        </xsl:for-each>
                    </xsl:if>
                </span>
            </xsl:if>



        <xsl:if test="marc:datafield[@tag=020]/marc:subfield[@code='a']">
          <span class="results_summary isbn"><span class="label">ISBN: </span>
            <xsl:for-each select="marc:datafield[@tag=020]/marc:subfield[@code='a']">
              <span property="isbn">
                <xsl:value-of select="."/>
                <xsl:choose>
                  <xsl:when test="position()=last()">
                    <xsl:text>.</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>; </xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </span>
            </xsl:for-each>
          </span>
        </xsl:if>

        <!-- Build ISSN -->
        <xsl:if test="marc:datafield[@tag=022]/marc:subfield[@code='a']">
          <span class="results_summary issn"><span class="label">ISSN: </span>
            <xsl:for-each select="marc:datafield[@tag=022]/marc:subfield[@code='a']">
              <span property="issn">
                <xsl:value-of select="."/>
                <xsl:choose>
                  <xsl:when test="position()=last()">
                    <xsl:text>.</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>; </xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </span>
            </xsl:for-each>
          </span>
        </xsl:if>

        <xsl:if test="marc:datafield[@tag=013]">
            <span class="results_summary patent_info">
                <span class="label">Patent information: </span>
                <xsl:for-each select="marc:datafield[@tag=013]">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">acdef</xsl:with-param>
                        <xsl:with-param name="delimeter">, </xsl:with-param>
                    </xsl:call-template>
                <xsl:choose><xsl:when test="position()=last()"><xsl:text></xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
                </xsl:for-each>
            </span>
        </xsl:if>

        <xsl:if test="marc:datafield[@tag=088]">
            <span class="results_summary report_number">
                <span class="label">Report number: </span>
                <xsl:for-each select="marc:datafield[@tag=088]">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">a</xsl:with-param>
                    </xsl:call-template>
                <xsl:choose><xsl:when test="position()=last()"><xsl:text></xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
                </xsl:for-each>
            </span>
        </xsl:if>

        <!-- Other Title  Statement: Alternate Graphic Representation (MARC 880) -->
        <xsl:if test="$display880">
            <xsl:call-template name="m880Select">
                <xsl:with-param name="basetags">246</xsl:with-param>
                <xsl:with-param name="codes">abhfgnp</xsl:with-param>
                <xsl:with-param name="class">results_summary other_title</xsl:with-param>
                <xsl:with-param name="label">Other title: </xsl:with-param>
            </xsl:call-template>
        </xsl:if>

            <xsl:if test="marc:datafield[@tag=246]">
                <span class="results_summary other_title"><span class="label">Other title: </span>
                    <xsl:for-each select="marc:datafield[@tag=246]">
                        <span property="alternateName">
                            <xsl:call-template name="chopPunctuation">
                                <xsl:with-param name="chopString">
                                    <xsl:call-template name="subfieldSelect">
                                        <xsl:with-param name="codes">abhfgnp</xsl:with-param>
                                    </xsl:call-template>
                                </xsl:with-param>
                            </xsl:call-template>
                            <xsl:if test="@ind1=1 and not(marc:subfield[@code='i'])">
                                <xsl:choose>
                                    <xsl:when test="@ind2=0"> [Portion of title]</xsl:when>
                                    <xsl:when test="@ind2=1"> [Parallel title]</xsl:when>
                                    <xsl:when test="@ind2=2"> [Distinctive title]</xsl:when>
                                    <xsl:when test="@ind2=3"> [Other title]</xsl:when>
                                    <xsl:when test="@ind2=4"> [Cover title]</xsl:when>
                                    <xsl:when test="@ind2=5"> [Added title page title]</xsl:when>
                                    <xsl:when test="@ind2=6"> [Caption title]</xsl:when>
                                    <xsl:when test="@ind2=7"> [Running title]</xsl:when>
                                    <xsl:when test="@ind2=8"> [Spine title]</xsl:when>
                                </xsl:choose>
                            </xsl:if>
                            <xsl:if test="marc:subfield[@code='i']">
                                <xsl:value-of select="concat(' [',marc:subfield[@code='i'],']')"/>
                            </xsl:if>
                        </span>
                        <!-- #13386 added separator | -->
                        <xsl:choose><xsl:when test="position()=last()"><xsl:text>.</xsl:text></xsl:when><xsl:otherwise><span class="separator"><xsl:text> | </xsl:text></span></xsl:otherwise></xsl:choose>
                    </xsl:for-each>
                </span>
            </xsl:if>


        <xsl:if test="marc:datafield[@tag=242]">
        <span class="results_summary translated_title"><span class="label">Title translated: </span>
            <xsl:for-each select="marc:datafield[@tag=242]">
                <span property="alternateName">
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">abchnp</xsl:with-param>
                    </xsl:call-template>
                   </xsl:with-param>
               </xsl:call-template>
                </span>
                    <xsl:choose><xsl:when test="position()=last()"><xsl:text>.</xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
            </xsl:for-each>
        </span>
       </xsl:if>

        <!-- Uniform Title  Statement: Alternate Graphic Representation (MARC 880) -->
        <xsl:if test="$display880">
            <span property="alternateName">
            <xsl:call-template name="m880Select">
                <xsl:with-param name="basetags">130,240</xsl:with-param>
                <xsl:with-param name="codes">adfklmor</xsl:with-param>
                <xsl:with-param name="class">results_summary uniform_title</xsl:with-param>
                <xsl:with-param name="label">Uniform titles: </xsl:with-param>
            </xsl:call-template>
            </span>
        </xsl:if>

            <xsl:if test="marc:datafield[@tag=130]|marc:datafield[@tag=240]|marc:datafield[@tag=730][@ind2!=2]">
                <span class="results_summary uniform_titles"><span class="label">Uniform titles: </span>
                    <xsl:for-each select="marc:datafield[@tag=130]|marc:datafield[@tag=240]|marc:datafield[@tag=730][@ind2!=2]">
                        <span property="alternateName">
                            <xsl:for-each select="marc:subfield">
                                <xsl:if test="contains('adfghklmnoprst',@code)">
                                    <xsl:value-of select="text()"/>
                                    <xsl:text> </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </span>
                        <xsl:if test="position() != last()">
                            <span class="separator"><xsl:text> | </xsl:text></span>
                        </xsl:if>
                    </xsl:for-each>
                </span>
            </xsl:if>


            <!-- #13382 Added Related works 700$i -->
            <xsl:if test="marc:datafield[@tag=700][marc:subfield[@code='i']] or marc:datafield[@tag=710][marc:subfield[@code='i']] or marc:datafield[@tag=711][marc:subfield[@code='i']]">
                <span class="results_summary related_works"><span class="label">Related works: </span>
                    <xsl:for-each select="marc:datafield[@tag=700][marc:subfield[@code='i']] | marc:datafield[@tag=710][marc:subfield[@code='i']] | marc:datafield[@tag=711][marc:subfield[@code='i']]">
                        <xsl:variable name="str">
                            <xsl:call-template name="subfieldSelect">
                                <xsl:with-param name="codes">abcdfghiklmnporstux</xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:call-template name="chopPunctuation">
                            <xsl:with-param name="chopString">
                                <xsl:value-of select="$str"/>
                            </xsl:with-param>
                        </xsl:call-template>
                        <!-- add relator code too between brackets-->
                        <xsl:if test="marc:subfield[@code='4' or @code='e']">
                            <span class="relatorcode">
                                <xsl:text> [</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="marc:subfield[@code='e']">
                                        <xsl:for-each select="marc:subfield[@code='e']">
                                            <xsl:value-of select="."/>
                                            <xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
                                        </xsl:for-each>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:for-each select="marc:subfield[@code='4']">
                                            <xsl:value-of select="."/>
                                            <xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
                                        </xsl:for-each>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text>]</xsl:text>
                            </span>
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when test="position()=last()"><xsl:text>.</xsl:text></xsl:when><xsl:otherwise><span class="separator"><xsl:text> | </xsl:text></span></xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </span>
            </xsl:if>

            <!-- #13382 Added Contained Works 7xx@ind2=2 -->
            <xsl:if test="marc:datafield[@tag=700][@ind2=2 and not(marc:subfield[@code='i'])] or marc:datafield[@tag=710][@ind2=2 and not(marc:subfield[@code='i'])] or marc:datafield[@tag=711][@ind2=2 and not(marc:subfield[@code='i'])]">
                <span class="results_summary contained_works"><span class="label">Contained works: </span>
                    <xsl:for-each select="marc:datafield[@tag=700][@ind2=2][not(marc:subfield[@code='i'])] | marc:datafield[@tag=710][@ind2=2][not(marc:subfield[@code='i'])] | marc:datafield[@tag=711][@ind2=2][not(marc:subfield[@code='i'])]">
                        <xsl:variable name="str">
                            <xsl:call-template name="subfieldSelect">
                                <xsl:with-param name="codes">abcdfghiklmnporstux</xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:call-template name="chopPunctuation">
                            <xsl:with-param name="chopString">
                                <xsl:value-of select="$str"/>
                            </xsl:with-param>
                        </xsl:call-template>
                        <!-- add relator code too between brackets-->
                        <xsl:if test="marc:subfield[@code='4' or @code='e']">
                            <span class="relatorcode">
                                <xsl:text> [</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="marc:subfield[@code='e']">
                                        <xsl:for-each select="marc:subfield[@code='e']">
                                            <xsl:value-of select="."/>
                                            <xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
                                        </xsl:for-each>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:for-each select="marc:subfield[@code='4']">
                                            <xsl:value-of select="."/>
                                            <xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
                                        </xsl:for-each>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text>]</xsl:text>
                            </span>
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when test="position()=last()"><xsl:text>.</xsl:text></xsl:when><xsl:otherwise><span class="separator"><xsl:text> | </xsl:text></span></xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </span>
            </xsl:if>

            <xsl:if test="marc:datafield[substring(@tag, 1, 1) = '6' and not(@tag=655)]">
            <span class="results_summary subjects"><span class="label">Subject(s): </span>
                <xsl:for-each select="marc:datafield[substring(@tag, 1, 1) = '6'][not(@tag=655)]">
            <span property="keywords">
            <a>
            <xsl:choose>
            <xsl:when test="marc:subfield[@code=9] and $UseAuthoritiesForTracings='1'">
                <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=an:<xsl:value-of select="marc:subfield[@code=9]"/></xsl:attribute>
            </xsl:when>
            <!-- #1807 Strip unwanted parenthesis from subjects for searching -->
            <xsl:when test="$TraceSubjectSubdivisions='1'">
                <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=<xsl:call-template name="subfieldSelectSubject">
                        <xsl:with-param name="codes">abcdfgklmnopqrstvxyz</xsl:with-param>
                        <xsl:with-param name="delimeter"> AND </xsl:with-param>
                        <xsl:with-param name="prefix">(su<xsl:value-of select="$SubjectModifier"/>:<xsl:value-of select="$TracingQuotesLeft"/></xsl:with-param>
                        <xsl:with-param name="suffix"><xsl:value-of select="$TracingQuotesRight"/>)</xsl:with-param>
                    </xsl:call-template>
                </xsl:attribute>
            </xsl:when>
                <!-- #1807 Strip unwanted parenthesis from subjects for searching -->
            <xsl:otherwise>
                <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=su<xsl:value-of select="$SubjectModifier"/>:<xsl:value-of select="$TracingQuotesLeft"/><xsl:value-of select="translate(marc:subfield[@code='a'],'()','')"/><xsl:value-of select="$TracingQuotesRight"/></xsl:attribute>
            </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">abcdfgklmnopqrstvxyz</xsl:with-param>
                        <xsl:with-param name="subdivCodes">vxyz</xsl:with-param>
                        <xsl:with-param name="subdivDelimiter">-- </xsl:with-param>
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:call-template>
            </a>
            </span>
            <xsl:if test="marc:subfield[@code=9]">
                <a class='authlink'>
                    <xsl:attribute name="href">/cgi-bin/koha/opac-authoritiesdetail.pl?authid=<xsl:value-of select="marc:subfield[@code=9]"/></xsl:attribute>
                    <xsl:element name="img">
                        <xsl:attribute name="src">/opac-tmpl/<xsl:value-of select="$theme"/>/images/filefind.png</xsl:attribute>
                        <xsl:attribute name="style">vertical-align:middle</xsl:attribute>
                        <xsl:attribute name="height">15</xsl:attribute>
                        <xsl:attribute name="width">15</xsl:attribute>
                    </xsl:element>
                </a>
            </xsl:if>
            <xsl:choose>
            <xsl:when test="position()=last()"></xsl:when>
            <xsl:otherwise> | </xsl:otherwise>
            </xsl:choose>

            </xsl:for-each>
            </span>
        </xsl:if>

            <!-- Genre/Form -->
            <xsl:if test="marc:datafield[@tag=655]">
                <span class="results_summary genre"><span class="label">Genre/Form: </span>
                    <xsl:for-each select="marc:datafield[@tag=655]">
                        <a>
                            <xsl:choose>
                                <xsl:when test="marc:subfield[@code=9] and $UseAuthoritiesForTracings='1'">
                                    <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=an:<xsl:value-of select="marc:subfield[@code=9]"/></xsl:attribute>
                                </xsl:when>
                                <xsl:when test="$TraceSubjectSubdivisions='1'">
                                    <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=<xsl:call-template name="subfieldSelectSubject">
                                        <xsl:with-param name="codes">avxyz</xsl:with-param>
                                        <xsl:with-param name="delimeter"> AND </xsl:with-param>
                                        <xsl:with-param name="prefix">(su<xsl:value-of select="$SubjectModifier"/>:<xsl:value-of select="$TracingQuotesLeft"/></xsl:with-param>
                                        <xsl:with-param name="suffix"><xsl:value-of select="$TracingQuotesRight"/>)</xsl:with-param>
                                    </xsl:call-template>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=su<xsl:value-of select="$SubjectModifier"/>:<xsl:value-of select="$TracingQuotesLeft"/><xsl:value-of select="marc:subfield[@code='a']"/><xsl:value-of select="$TracingQuotesRight"/></xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                        <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">avxyz</xsl:with-param>
                            <xsl:with-param name="subdivCodes">vxyz</xsl:with-param>
                            <xsl:with-param name="subdivDelimiter">-- </xsl:with-param>
                        </xsl:call-template>
                        </a>
                        <xsl:if test="position()!=last()"><span class="separator"> | </span></xsl:if>
                    </xsl:for-each>
                </span>
            </xsl:if>

<!-- DDC classification -->
    <xsl:if test="marc:datafield[@tag=082]">
        <span class="results_summary ddc">
            <span class="label">DDC classification: </span>
            <xsl:for-each select="marc:datafield[@tag=082]">
                <xsl:call-template name="subfieldSelect">
                    <xsl:with-param name="codes">a</xsl:with-param>
                    <xsl:with-param name="delimeter"><xsl:text> | </xsl:text></xsl:with-param>
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="position()=last()"><xsl:text>  </xsl:text></xsl:when>
                    <xsl:otherwise> | </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </span>
    </xsl:if>


<!-- Image processing code added here, takes precedence over text links including y3z text   -->
        <xsl:if test="marc:datafield[@tag=856]">
        <span class="results_summary online_resources"><span class="label">Online resources: </span>
        <xsl:for-each select="marc:datafield[@tag=856]">
            <xsl:variable name="SubqText"><xsl:value-of select="marc:subfield[@code='q']"/></xsl:variable>
	    <a property="url">
	    <xsl:choose>
	      <xsl:when test="$OPACTrackClicks='track'">
            <xsl:attribute name="href">/cgi-bin/koha/tracklinks.pl?uri=<xsl:value-of select="str:encode-uri(marc:subfield[@code='u'], true())"/>&amp;biblionumber=<xsl:value-of select="$biblionumber"/></xsl:attribute>
	      </xsl:when>
	      <xsl:when test="$OPACTrackClicks='anonymous'">
            <xsl:attribute name="href">/cgi-bin/koha/tracklinks.pl?uri=<xsl:value-of select="str:encode-uri(marc:subfield[@code='u'], true())"/>&amp;biblionumber=<xsl:value-of select="$biblionumber"/></xsl:attribute>
	      </xsl:when>
	      <xsl:otherwise>
                <xsl:attribute name="href"><xsl:value-of select="marc:subfield[@code='u']"/></xsl:attribute>
	      </xsl:otherwise>
	    </xsl:choose>
            <xsl:if test="$OPACURLOpenInNewWindow='1'">
                <xsl:attribute name="target">_blank</xsl:attribute>
            </xsl:if>
            <xsl:choose>
            <xsl:when test="($Show856uAsImage='Details' or $Show856uAsImage='Both') and (substring($SubqText,1,6)='image/' or $SubqText='img' or $SubqText='bmp' or $SubqText='cod' or $SubqText='gif' or $SubqText='ief' or $SubqText='jpe' or $SubqText='jpeg' or $SubqText='jpg' or $SubqText='jfif' or $SubqText='png' or $SubqText='svg' or $SubqText='tif' or $SubqText='tiff' or $SubqText='ras' or $SubqText='cmx' or $SubqText='ico' or $SubqText='pnm' or $SubqText='pbm' or $SubqText='pgm' or $SubqText='ppm' or $SubqText='rgb' or $SubqText='xbm' or $SubqText='xpm' or $SubqText='xwd')">
                <xsl:element name="img"><xsl:attribute name="src"><xsl:value-of select="marc:subfield[@code='u']"/></xsl:attribute><xsl:attribute name="alt"><xsl:value-of select="marc:subfield[@code='y']"/></xsl:attribute><xsl:attribute name="style">height:100px</xsl:attribute></xsl:element><xsl:text></xsl:text>
            </xsl:when>
            <xsl:when test="marc:subfield[@code='y' or @code='3' or @code='z']">
                <xsl:call-template name="subfieldSelect">
                    <xsl:with-param name="codes">y3z</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$URLLinkText!=''">
                <xsl:value-of select="$URLLinkText"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Click here to access online</xsl:text>
            </xsl:otherwise>
            </xsl:choose>
            </a>
            <xsl:choose>
            <xsl:when test="position()=last()"><xsl:text>  </xsl:text></xsl:when>
            <xsl:otherwise> | </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        </span>
        </xsl:if>

        <!-- 530 -->
        <xsl:if test="marc:datafield[@tag=530]">
        <xsl:for-each select="marc:datafield[@tag=530]">
        <span class="results_summary additionalforms">
            <xsl:call-template name="subfieldSelect">
                <xsl:with-param name="codes">abcd</xsl:with-param>
            </xsl:call-template>
            <xsl:for-each select="marc:subfield[@code='u']">
                <a><xsl:attribute name="href"><xsl:value-of select="text()"/></xsl:attribute>
                <xsl:if test="$OPACURLOpenInNewWindow='1'">
                    <xsl:attribute name="target">_blank</xsl:attribute>
                </xsl:if>
                <xsl:value-of select="text()"/>
                </a>
            </xsl:for-each>
        </span>
        </xsl:for-each>
        </xsl:if>

        <!-- 505 -->
        <xsl:if test="marc:datafield[@tag=505]">
        <div class="results_summary contents">
        <xsl:for-each select="marc:datafield[@tag=505]">
        <xsl:if test="position()=1">
            <xsl:choose>
            <xsl:when test="@ind1=1">
                <span class="label">Incomplete contents:</span>
            </xsl:when>
            <xsl:when test="@ind1=2">
                <span class="label">Partial contents:</span>
            </xsl:when>
            <xsl:otherwise>
                <span class="label">Contents:</span>
            </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <div class='contentblock' property='description'>
        <xsl:choose>
        <xsl:when test="@ind2=0">
            <xsl:call-template name="subfieldSelectSpan">
                <xsl:with-param name="codes">tru</xsl:with-param>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="subfieldSelectSpan">
                <xsl:with-param name="codes">atru</xsl:with-param>
            </xsl:call-template>
        </xsl:otherwise>
        </xsl:choose>
        </div>
        </xsl:for-each>
        </div>
        </xsl:if>

        <!-- 583 -->
        <xsl:if test="marc:datafield[@tag=583]">
        <xsl:for-each select="marc:datafield[@tag=583]">
            <xsl:if test="@ind1=1 or @ind1=' '">
            <span class="results_summary actionnote">
                <xsl:choose>
                <xsl:when test="marc:subfield[@code='z']">
                    <xsl:value-of select="marc:subfield[@code='z']"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">abcdefgijklnou</xsl:with-param>
                    </xsl:call-template>
                </xsl:otherwise>
                </xsl:choose>
            </span>
            </xsl:if>
        </xsl:for-each>
        </xsl:if>

        <!-- 508 -->
            <xsl:if test="marc:datafield[@tag=508]">
                <div class="results_summary prod_credits">
                    <span class="label">Production Credits: </span>
                    <xsl:for-each select="marc:datafield[@tag=508]">
                        <xsl:call-template name="subfieldSelectSpan">
                            <xsl:with-param name="codes">a</xsl:with-param>
                        </xsl:call-template>
                        <xsl:if test="position()!=last()"><span class="separator"><xsl:text> | </xsl:text></span></xsl:if>
                    </xsl:for-each>
                </div>
            </xsl:if>

        <!-- 586 -->
        <xsl:if test="marc:datafield[@tag=586]">
            <span class="results_summary awardsnote">
                <xsl:if test="marc:datafield[@tag=586]/@ind1=' '">
                    <span class="label">Awards: </span>
                </xsl:if>
                <xsl:for-each select="marc:datafield[@tag=586]">
                    <xsl:value-of select="marc:subfield[@code='a']"/>
                    <xsl:if test="position()!=last()"><span class="separator"><xsl:text> | </xsl:text></span></xsl:if>
                </xsl:for-each>
            </span>
        </xsl:if>

        <!-- 773 -->
        <xsl:if test="marc:datafield[@tag=773]">
        <xsl:for-each select="marc:datafield[@tag=773]">
        <xsl:if test="@ind1 !=1">
        <span class="results_summary in"><span class="label">
        <xsl:choose>
        <xsl:when test="@ind2=' '">
            In:
        </xsl:when>
        <xsl:when test="@ind2=8">
            <xsl:if test="marc:subfield[@code='i']">
                <xsl:value-of select="marc:subfield[@code='i']"/>
            </xsl:if>
        </xsl:when>
        </xsl:choose>
        </span>
                <xsl:variable name="f773">
                    <xsl:call-template name="chopPunctuation"><xsl:with-param name="chopString"><xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">a_t</xsl:with-param>
                    </xsl:call-template></xsl:with-param></xsl:call-template>
                </xsl:variable>
            <xsl:choose>
                <xsl:when test="$UseControlNumber = '1' and marc:subfield[@code='w']">
                    <a><xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=Control-number:<xsl:call-template name="extractControlNumber"><xsl:with-param name="subfieldW" select="marc:subfield[@code='w']"/></xsl:call-template></xsl:attribute>
                        <xsl:value-of select="translate($f773, '()', '')"/>
                    </a>
                    <xsl:if test="marc:subfield[@code='g']"><xsl:text> </xsl:text><xsl:value-of select="marc:subfield[@code='g']"/></xsl:if>
                </xsl:when>
                <xsl:when test="marc:subfield[@code='0']">
                    <a><xsl:attribute name="href">/cgi-bin/koha/opac-detail.pl?biblionumber=<xsl:value-of select="marc:subfield[@code='0']"/></xsl:attribute>
                        <xsl:value-of select="$f773"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <a><xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=ti,phr:<xsl:value-of select="translate($f773, '()', '')"/></xsl:attribute>
                        <xsl:value-of select="$f773"/>
                    </a>
                    <xsl:if test="marc:subfield[@code='g']"><xsl:text> </xsl:text><xsl:value-of select="marc:subfield[@code='g']"/></xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </span>

        <xsl:if test="marc:subfield[@code='n']">
            <span class="results_summary"><xsl:value-of select="marc:subfield[@code='n']"/></span>
        </xsl:if>

        </xsl:if>
        </xsl:for-each>
        </xsl:if>

        <xsl:for-each select="marc:datafield[@tag=511]">
            <span class="results_summary perf_note">
                <span class="label">
                    <xsl:if test="@ind1=1"><xsl:text>Cast: </xsl:text></xsl:if>
                </span>
                <xsl:call-template name="subfieldSelect">
                    <xsl:with-param name="codes">a</xsl:with-param>
                </xsl:call-template>
            </span>
        </xsl:for-each>

        <xsl:if test="marc:datafield[@tag=502]">
            <span class="results_summary diss_note">
                <span class="label">Dissertation note: </span>
                <xsl:for-each select="marc:datafield[@tag=502]">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">abcdgo</xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:choose><xsl:when test="position()=last()"><xsl:text></xsl:text></xsl:when><xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise></xsl:choose>
            </span>
        </xsl:if>

        <xsl:for-each select="marc:datafield[@tag=520]">
        <span class="results_summary summary"><span class="label">
        <xsl:choose>
          <xsl:when test="@ind1=0"><xsl:text>Subject: </xsl:text></xsl:when>
          <xsl:when test="@ind1=1"><xsl:text>Review: </xsl:text></xsl:when>
          <xsl:when test="@ind1=2"><xsl:text>Scope and content: </xsl:text></xsl:when>
          <xsl:when test="@ind1=3"><xsl:text>Abstract: </xsl:text></xsl:when>
          <xsl:when test="@ind1=4"><xsl:text>Content advice: </xsl:text></xsl:when>
          <xsl:otherwise><xsl:text>Summary: </xsl:text></xsl:otherwise>
        </xsl:choose>
        </span>
        <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">abcu</xsl:with-param>
        </xsl:call-template>
        </span>
        </xsl:for-each>

        <!-- 866 textual holdings -->
        <xsl:if test="marc:datafield[@tag=866]">
            <!-- #27193 changed label -->
            <span class="results_summary holdings_note"><span class="label">Print holdings: </span>
                <xsl:for-each select="marc:datafield[@tag=866]">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">az</xsl:with-param>
                    </xsl:call-template>
                    <xsl:choose><xsl:when test="position()=last()"><xsl:text></xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
                </xsl:for-each>
            </span>
        </xsl:if>

        <!--  775 Other Edition  -->
        <xsl:if test="marc:datafield[@tag=775]">
        <span class="results_summary other_editions"><span class="label">Other editions: </span>
        <xsl:for-each select="marc:datafield[@tag=775]">
            <xsl:variable name="f775">
                <xsl:call-template name="chopPunctuation"><xsl:with-param name="chopString"><xsl:call-template name="subfieldSelect">
                <xsl:with-param name="codes">a_t</xsl:with-param>
                </xsl:call-template></xsl:with-param></xsl:call-template>
            </xsl:variable>
            <xsl:if test="marc:subfield[@code='i']">
                <xsl:call-template name="subfieldSelect">
                    <xsl:with-param name="codes">i</xsl:with-param>
                </xsl:call-template>
                <xsl:text>: </xsl:text>
            </xsl:if>
            <a>
            <xsl:choose>
            <xsl:when test="$UseControlNumber = '1' and marc:subfield[@code='w']">
                <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=Control-number:<xsl:call-template name="extractControlNumber"><xsl:with-param name="subfieldW" select="marc:subfield[@code='w']"/></xsl:call-template></xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=ti,phr:<xsl:value-of select="translate($f775, '()', '')"/></xsl:attribute>
            </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="subfieldSelect">
                <xsl:with-param name="codes">a_t</xsl:with-param>
            </xsl:call-template>
            </a>
            <xsl:choose>
                <xsl:when test="position()=last()"></xsl:when>
                <xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        </span>
        </xsl:if>

        <!-- 780 -->
        <xsl:if test="marc:datafield[@tag=780]">
        <xsl:for-each select="marc:datafield[@tag=780]">
        <xsl:if test="@ind1=0">
        <span class="results_summary preceeding_entry">
        <xsl:choose>
        <xsl:when test="@ind2=0">
            <span class="label">Continues:</span>
        </xsl:when>
        <xsl:when test="@ind2=1">
            <span class="label">Continues in part:</span>
        </xsl:when>
        <xsl:when test="@ind2=2">
            <span class="label">Supersedes:</span>
        </xsl:when>
        <xsl:when test="@ind2=3">
            <span class="label">Supersedes in part:</span>
        </xsl:when>
        <xsl:when test="@ind2=4">
            <span class="label">Formed by the union: ... and: ...</span>
        </xsl:when>
        <xsl:when test="@ind2=5">
            <span class="label">Absorbed:</span>
        </xsl:when>
        <xsl:when test="@ind2=6">
            <span class="label">Absorbed in part:</span>
        </xsl:when>
        <xsl:when test="@ind2=7">
            <span class="label">Separated from:</span>
        </xsl:when>
        </xsl:choose>
        <xsl:text> </xsl:text>
                <xsl:variable name="f780">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">a_t</xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>
            <xsl:choose>
                <xsl:when test="$UseControlNumber = '1' and marc:subfield[@code='w']">
                    <a><xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=Control-number:<xsl:call-template name="extractControlNumber"><xsl:with-param name="subfieldW" select="marc:subfield[@code='w']"/></xsl:call-template></xsl:attribute>
                        <xsl:value-of select="translate($f780, '()', '')"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <a><xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=ti,phr:<xsl:value-of select="translate($f780, '()', '')"/></xsl:attribute>
                        <xsl:value-of select="translate($f780, '()', '')"/>
                    </a>
                </xsl:otherwise>
            </xsl:choose>
        </span>

        <xsl:if test="marc:subfield[@code='n']">
            <span class="results_summary"><xsl:value-of select="marc:subfield[@code='n']"/></span>
        </xsl:if>

        </xsl:if>
        </xsl:for-each>
        </xsl:if>

        <!-- 785 -->
        <xsl:if test="marc:datafield[@tag=785]">
        <xsl:for-each select="marc:datafield[@tag=785]">
        <xsl:if test="@ind1=0">
        <span class="results_summary succeeding_entry">
        <xsl:choose>
        <xsl:when test="@ind2=0">
            <span class="label">Continued by:</span>
        </xsl:when>
        <xsl:when test="@ind2=1">
            <span class="label">Continued in part by:</span>
        </xsl:when>
        <xsl:when test="@ind2=2">
            <span class="label">Superseded by:</span>
        </xsl:when>
        <xsl:when test="@ind2=3">
            <span class="label">Superseded in part by:</span>
        </xsl:when>
        <xsl:when test="@ind2=4">
            <span class="label">Absorbed by:</span>
        </xsl:when>
        <xsl:when test="@ind2=5">
            <span class="label">Absorbed in part by:</span>
        </xsl:when>
        <xsl:when test="@ind2=6">
            <span class="label">Split into .. and ...:</span>
        </xsl:when>
        <xsl:when test="@ind2=7">
            <span class="label">Merged with ... to form ...</span>
        </xsl:when>
        <xsl:when test="@ind2=8">
            <span class="label">Changed back to:</span>
        </xsl:when>
        </xsl:choose>
        <xsl:text> </xsl:text>
                   <xsl:variable name="f785">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">a_t</xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>

            <xsl:choose>
                <xsl:when test="$UseControlNumber = '1' and marc:subfield[@code='w']">
                    <a><xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=Control-number:<xsl:call-template name="extractControlNumber"><xsl:with-param name="subfieldW" select="marc:subfield[@code='w']"/></xsl:call-template></xsl:attribute>
                        <xsl:value-of select="translate($f785, '()', '')"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <a><xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=ti,phr:<xsl:value-of select="translate($f785, '()', '')"/></xsl:attribute>
                        <xsl:value-of select="translate($f785, '()', '')"/>
                    </a>
                </xsl:otherwise>
            </xsl:choose>

        </span>

        <xsl:if test="marc:subfield[@code='n']">
            <span class="results_summary"><xsl:value-of select="marc:subfield[@code='n']"/></span>
        </xsl:if>

        </xsl:if>
        </xsl:for-each>
        </xsl:if>

    </xsl:element>
    </xsl:template>

    <xsl:template name="showAuthor">
        <xsl:param name="authorfield" />
        <xsl:param name="UseAuthoritiesForTracings" />
        <xsl:param name="materialTypeLabel" />
        <xsl:param name="theme" />
        <xsl:if test="count($authorfield)&gt;0">
        <h5 class="author">
            <xsl:for-each select="$authorfield">
                <xsl:choose>
                    <xsl:when test="position()&gt;1"/>
                    <!-- #13383 -->
                    <xsl:when test="@tag&lt;700">By: </xsl:when>
                    <!--#13382 Changed Additional author to contributor -->
                    <xsl:otherwise>Contributor(s): </xsl:otherwise>
                </xsl:choose>
            <xsl:choose>
                <xsl:when test="not(@tag=111) or @tag=700 or @tag=710 or @tag=711"/>
                <xsl:when test="marc:subfield[@code='n']">
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">n</xsl:with-param>
                    </xsl:call-template>
                    <xsl:text> </xsl:text>
                </xsl:when>
            </xsl:choose>
            <a>
                <xsl:choose>
                    <xsl:when test="marc:subfield[@code=9] and $UseAuthoritiesForTracings='1'">
                        <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=an:"<xsl:value-of select="marc:subfield[@code=9]"/>"</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=au:"<xsl:value-of select="marc:subfield[@code='a']"/>"</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <span resource="#record"><span>
                    <xsl:choose>
                        <xsl:when test="substring(@tag, 1, 1)='1'">
                            <xsl:choose>
                                <xsl:when test="$materialTypeLabel='Music'"><xsl:attribute name="property">byArtist</xsl:attribute></xsl:when>
                                <xsl:otherwise><xsl:attribute name="property">author</xsl:attribute></xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise><xsl:attribute name="property">contributor</xsl:attribute></xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring(@tag, 2, 1)='0'">
                            <xsl:choose>
                                <xsl:when test="$materialTypeLabel='Music'"><xsl:attribute name="typeof">MusicGroup</xsl:attribute></xsl:when>
                                <xsl:otherwise><xsl:attribute name="typeof">Person</xsl:attribute></xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise><xsl:attribute name="typeof">Organization</xsl:attribute></xsl:otherwise>
                    </xsl:choose>
                <span property="name">
                <xsl:choose>
                    <xsl:when test="@tag=100 or @tag=110 or @tag=111">
                        <!-- #13383 -->
                        <xsl:call-template name="chopPunctuation">
                            <xsl:with-param name="chopString">
                                <xsl:call-template name="subfieldSelect">
                                    <xsl:with-param name="codes">
                                        <xsl:choose>
                                            <!-- #13383 include subfield e for field 111  -->
                                            <xsl:when test="@tag=111">abceqt</xsl:when>
                                            <xsl:otherwise>abcjqt</xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:with-param>
                            <xsl:with-param name="punctuation">
                                <xsl:text>:,;/ </xsl:text>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <!-- #13382 excludes 700$i and ind2=2, displayed as Related Works -->
                    <!--#13382 Added all relevant subfields 4, e, and d are handled separately -->
                    <xsl:when test="@tag=700 or @tag=710 or @tag=711">
                        <xsl:variable name="str">
                            <xsl:call-template name="subfieldSelect">
                                <xsl:with-param name="codes">abcfghiklmnoprstux</xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:call-template name="chopPunctuation">
                            <xsl:with-param name="chopString">
                                <xsl:value-of select="$str"/>
                            </xsl:with-param>
                            <xsl:with-param name="punctuation">
                                <xsl:text>:,;/. </xsl:text>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
                </span></span></span>
                <xsl:if test="marc:subfield[@code='d']">
                    <span class="authordates">
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="marc:subfield[@code='d']"/>
                    </span>
                </xsl:if>
                <!-- #13383 include relator code j for field 111 -->
                <xsl:if test="marc:subfield[@code='4' or @code='e'][not(parent::*[@tag=111])] or (self::*[@tag=111] and marc:subfield[@code='4' or @code='j'][. != ''])">
                    <span class="relatorcode">
                        <xsl:text> [</xsl:text>
                        <xsl:choose>
                            <xsl:when test="@tag=111">
                                <xsl:choose>
                                    <!-- Prefer j over 4 -->
                                    <xsl:when test="marc:subfield[@code='j']">
                                        <xsl:for-each select="marc:subfield[@code='j']">
                                            <xsl:value-of select="."/>
                                            <xsl:if test="position() != last()">, </xsl:if>
                                        </xsl:for-each>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:for-each select="marc:subfield[@code=4]">
                                            <xsl:value-of select="."/>
                                            <xsl:if test="position() != last()">, </xsl:if>
                                        </xsl:for-each>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <!-- Prefer e over 4 -->
                            <xsl:when test="marc:subfield[@code='e']">
                                <xsl:for-each select="marc:subfield[@code='e']">
                                    <xsl:value-of select="."/>
                                    <xsl:if test="position() != last()">, </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:for-each select="marc:subfield[@code=4]">
                                    <xsl:value-of select="."/>
                                    <xsl:if test="position() != last()">, </xsl:if>
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>]</xsl:text>
                    </span>
                </xsl:if>
            </a>
            <xsl:if test="marc:subfield[@code=9]">
                <a class='authlink'>
                    <xsl:attribute name="href">/cgi-bin/koha/opac-authoritiesdetail.pl?authid=<xsl:value-of select="marc:subfield[@code=9]"/></xsl:attribute>
                    <xsl:element name="img">
                        <xsl:attribute name="src">/opac-tmpl/<xsl:value-of select="$theme"/>/images/filefind.png</xsl:attribute>
                        <xsl:attribute name="style">vertical-align:middle</xsl:attribute>
                        <xsl:attribute name="height">15</xsl:attribute>
                        <xsl:attribute name="width">15</xsl:attribute>
                    </xsl:element>
                </a>
            </xsl:if>
                <xsl:choose>
                    <xsl:when test="position()=last()"><xsl:text>.</xsl:text></xsl:when><xsl:otherwise><span class="separator"><xsl:text> | </xsl:text></span></xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </h5>
        </xsl:if>
    </xsl:template>

    <xsl:template name="nameABCQ">
            <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">abcq</xsl:with-param>
                    </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="punctuation">
                    <xsl:text>:,;/ </xsl:text>
                </xsl:with-param>
            </xsl:call-template>
    </xsl:template>

    <xsl:template name="nameABCDN">
            <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">abcdn</xsl:with-param>
                    </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="punctuation">
                    <xsl:text>:,;/ </xsl:text>
                </xsl:with-param>
            </xsl:call-template>
    </xsl:template>

    <xsl:template name="nameACDEQ">
            <xsl:call-template name="subfieldSelect">
                <xsl:with-param name="codes">acdeq</xsl:with-param>
            </xsl:call-template>
    </xsl:template>

    <xsl:template name="part">
        <xsl:variable name="partNumber">
            <xsl:call-template name="specialSubfieldSelect">
                <xsl:with-param name="axis">n</xsl:with-param>
                <xsl:with-param name="anyCodes">n</xsl:with-param>
                <xsl:with-param name="afterCodes">fghkdlmor</xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="partName">
            <xsl:call-template name="specialSubfieldSelect">
                <xsl:with-param name="axis">p</xsl:with-param>
                <xsl:with-param name="anyCodes">p</xsl:with-param>
                <xsl:with-param name="afterCodes">fghkdlmor</xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:if test="string-length(normalize-space($partNumber))">
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString" select="$partNumber"/>
                </xsl:call-template>
        </xsl:if>
        <xsl:if test="string-length(normalize-space($partName))">
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString" select="$partName"/>
                </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="specialSubfieldSelect">
        <xsl:param name="anyCodes"/>
        <xsl:param name="axis"/>
        <xsl:param name="beforeCodes"/>
        <xsl:param name="afterCodes"/>
        <xsl:variable name="str">
            <xsl:for-each select="marc:subfield">
                <xsl:if test="contains($anyCodes, @code)      or (contains($beforeCodes,@code) and following-sibling::marc:subfield[@code=$axis])      or (contains($afterCodes,@code) and preceding-sibling::marc:subfield[@code=$axis])">
                    <xsl:value-of select="text()"/>
                    <xsl:text> </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="substring($str,1,string-length($str)-1)"/>
    </xsl:template>

    <!-- #1807 Strip unwanted parenthesis from subjects for searching -->
    <xsl:template name="subfieldSelectSubject">
        <xsl:param name="codes"/>
        <xsl:param name="delimeter"><xsl:text> </xsl:text></xsl:param>
        <xsl:param name="subdivCodes"/>
        <xsl:param name="subdivDelimiter"/>
        <xsl:param name="prefix"/>
        <xsl:param name="suffix"/>
        <xsl:variable name="str">
            <xsl:for-each select="marc:subfield">
                <xsl:if test="contains($codes, @code)">
                    <xsl:if test="contains($subdivCodes, @code)">
                        <xsl:value-of select="$subdivDelimiter"/>
                    </xsl:if>
                    <xsl:value-of select="$prefix"/><xsl:value-of select="translate(text(),'()','')"/><xsl:value-of select="$suffix"/><xsl:value-of select="$delimeter"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="substring($str,1,string-length($str)-string-length($delimeter))"/>
    </xsl:template>
</xsl:stylesheet>
