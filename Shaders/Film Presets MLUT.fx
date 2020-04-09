//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ReShade effect file
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Multi-LUT shader, using a texture atlas with multiple LUTs
// by Otis / Infuse Project.
// Based on Marty's LUT shader 1.0 for ReShade 3.0
// Copyright © 2008-2016 Marty McFly
//
// Edit by prod80 | 2020 | https://github.com/prod80/prod80-ReShade-Repository
// Removed blend modes (luma/chroma)
// Help identifying blending issues by kingeric1992
// Converted by TheGordinho 
// Thanks to kingeric1992 and Matsilagi for the tools
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#ifndef fLUT_TextureName
	#define fLUT_TextureName "Film Presets MLUT.png"
#endif
#ifndef fLUT_TileSizeXY
	#define fLUT_TileSizeXY 32
#endif
#ifndef fLUT_TileAmount
	#define fLUT_TileAmount 32
#endif
#ifndef fLUT_LutAmount
	#define fLUT_LutAmount 150
#endif

#include "ReShade.fxh"

namespace MLUT_MultiLUT_Film_Presets
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=150;
		ui_items=" Ada S\0 Ada\0 Alice S\0 Alice\0 Andrews S\0 Andrews\0 Buckingham S\0 Buckingham\0 Buckley S\0 Buckley\0 Bucknell S\0 Bucknell\0 Butin S\0 Butin\0 Cadigal S\0 Cadigal\0 Camden S\0 Camden\0 Carington S\0 Carington\0 Cary S\0 Cary\0 Chalmers S\0 Chalmers\0 Cobar S\0 Cobar\0 Cooper S\0 Cooper\0 Cowper S\0 Cowper\0 Crown S\0 Crown\0 Devine S\0 Devine\0 Dixson S\0 Dixson\0 Edward S\0 Edward\0 Elger S\0 Elger\0 Elizabeth S\0 Elizabeth\0 Esk S\0 Esk\0 Farr S\0 Farr\0 Fernbank S\0 Fernbank\0 Fisher S\0 Fisher\0 Forbes S\0 Forbes\0 Garners S\0 Garners\0 Gladstone S\0 Gladstone\0 Glebe S\0 Glebe\0 Goodlet S\0 Goodlet\0 Gorman S\0 Gorman\0 Gowrie S\0 Gowrie\0 Harris S\0 Harris\0 Hawken S\0 Hawken\0 Holdsworth S\0 Holdsworth\0 Hollis S\0 Hollis\0 Holt S\0 Holt\0 Hugh S\0 Hugh\0 Iverys S\0 Iverys\0 Jesmond S\0 Jesmond\0 Kings S\0 Kings\0 Kippax S\0 Kippax\0 Knight S\0 Knight\0 Lacey S\0 Lacey\0 Leopold S\0 Leopold\0 Malakoff S\0 Malakoff\0 Marian S\0 Marian\0 Melford S\0 Melford\0 Myra S\0 Myra\0 Newman S\0 Newman\0 Parkers S\0 Parkers\0 Peace S\0 Peace\0 Pembroke S\0 Pembroke\0 Pemell S\0 Pemell\0 Phillip S\0 Phillip\0 Pitt S\0 Pitt\0 Premier S\0 Premier\0 Randle S\0 Randle\0 Regent S\0 Regent\0 Renwick S\0 Renwick\0 Roslyn S\0 Roslyn\0 Sloane S\0 Sloane\0 Soudan S\0 Soudan\0 Station S\0 Station\0 Sussex S\0 Sussex\0 Third S\0 Third\0 Thomas S\0 Thomas\0 Thornley S\0 Thornley\0 Union S\0 Union\0 Victoria S\0 Victoria\0 Waterloo S\0 Waterloo\0 Wells S\0 Wells\0 Wentworth S\0 Wentworth\0 Western S\0 Western\0 Whitehorse S\0 Whitehorse\0"; 
		ui_label = "The LUT to use";
		
	> = 0;

    uniform float fLUT_Intensity <
        ui_type = "slider";
        ui_min = 0.00; ui_max = 1.00;
        ui_label = "LUT Intensity";
        ui_tooltip = "Intensity of LUT effect";
    > = 1.00;

    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    texture texMultiLUT_MLUT_pd80_Film_Presets < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Film_Presets; };

    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    void PS_MultiLUT_Apply( float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target0 )
    {
        color            = tex2D( ReShade::BackBuffer, texcoord.xy );
        float2 texelsize = rcp( fLUT_TileSizeXY );
        texelsize.x     /= fLUT_TileAmount;

        float3 lutcoord  = float3(( color.xy * fLUT_TileSizeXY - color.xy + 0.5f ) * texelsize.xy, color.z * fLUT_TileSizeXY - color.z );
        lutcoord.y      /= fLUT_LutAmount;
        lutcoord.y      += ( float( fLUT_LutSelector ) / fLUT_LutAmount );
        float lerpfact   = frac( lutcoord.z );
        lutcoord.x      += ( lutcoord.z - lerpfact ) * texelsize.y;

        float3 lutcolor  = lerp( tex2D( SamplerMultiLUT, lutcoord.xy ).xyz, tex2D( SamplerMultiLUT, float2( lutcoord.x + texelsize.y, lutcoord.y )).xyz, lerpfact );
        color.xyz        = lerp( color.xyz, lutcolor.xyz, fLUT_Intensity );
    }

    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    technique Film_Presets_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}