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
	#define fLUT_TextureName "Hyperbeast MLUT.png"
#endif
#ifndef fLUT_TileSizeXY
	#define fLUT_TileSizeXY 32	
#endif
#ifndef fLUT_TileAmount
	#define fLUT_TileAmount 32
#endif
#ifndef fLUT_LutAmount
	#define fLUT_LutAmount 120
#endif

#include "ReShade.fxh"

namespace MLUT_MultiLUT_Hyperbeast
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=120;
		ui_items=" CYPK01\0 CYPK01_S\0 CYPK02\0 CYPK02_S\0 CYPK03\0 CYPK03_S\0 CYPK04\0 CYPK04_S\0 CYPK05\0 CYPK05_S\0 CYPK06\0 CYPK06_S\0 CYPK07\0 CYPK07_S\0 CYPK08\0 CYPK08_S\0 CYPK09\0 CYPK09_S\0 CYPK10\0 CYPK10_S\0 FILM01\0 FILM01_S\0 FILM02\0 FILM02_S\0 FILM03\0 FILM03_S\0 FILM04\0 FILM04_S\0 FILM05\0 FILM05_S\0 FILM06\0 FILM06_S\0 FILM07\0 FILM07_S\0 FILM08\0 FILM08_S\0 FILM09\0 FILM09_S\0 FILM10\0 FILM10_S\0 FLM01\0 FLM01_S\0 FLM02\0 FLM02_S\0 FLM03\0 FLM03_S\0 FLM04\0 FLM04_S\0 FLM05\0 FLM05_S\0 FLM06\0 FLM06_S\0 FLM07\0 FLM07_S\0 FLM08\0 FLM08_S\0 FLM09\0 FLM09_S\0 FLM10\0 FLM10_S\0 OT01\0 OT01_S\0 OT02\0 OT02_S\0 OT03\0 OT03_S\0 OT04\0 OT04_S\0 OT05\0 OT05_S\0 OT06\0 OT06_S\0 OT07\0 OT07_S\0 OT08\0 OT08_S\0 OT09\0 OT09_S\0 OT10\0 OT10_S\0 SPR01\0 SPR01_S\0 SPR02\0 SPR02_S\0 SPR03\0 SPR03_S\0 SPR04\0 SPR04_S\0 SPR05\0 SPR05_S\0 SPR06\0 SPR06_S\0 SPR07\0 SPR07_S\0 SPR08\0 SPR08_S\0 SPR09\0 SPR09_S\0 SPR10\0 SPR10_S\0 TEK01\0 TEK01_S\0 TEK02\0 TEK02_S\0 TEK03\0 TEK03_S\0 TEK04\0 TEK04_S\0 TEK05\0 TEK05_S\0 TEK06\0 TEK06_S\0 TEK07\0 TEK07_S\0 TEK08\0 TEK08_S\0 TEK09\0 TEK09_S\0 TEK10\0 TEK10_S\0";
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

    texture texMultiLUT_MLUT_pd80_Hyperbeast < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Hyperbeast; };

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

    technique Hyperbeast_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}