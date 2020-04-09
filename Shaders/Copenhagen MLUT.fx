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
	#define fLUT_TextureName "Copenhagen MLUT.png"
#endif
#ifndef fLUT_TileSizeXY
	#define fLUT_TileSizeXY 32
#endif
#ifndef fLUT_TileAmount
	#define fLUT_TileAmount 32
#endif
#ifndef fLUT_LutAmount
	#define fLUT_LutAmount 100
#endif
#include "ReShade.fxh"

namespace MLUT_MultiLUT_Copenhagen
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Chokolade 01\0 Chokolade 01_S\0 Chokolade 02\0 Chokolade 02_S\0 Chokolade 03\0 Chokolade 03_S\0 Chokolade 04\0 Chokolade 04_S\0 Chokolade 05\0 Chokolade 05_S\0 Chokolade 06\0 Chokolade 06_S\0 Chokolade 07\0 Chokolade 07_S\0 Chokolade 08\0 Chokolade 08_S\0 Chokolade 09\0 Chokolade 09_S\0 Chokolade 10\0 Chokolade 10_S\0 Hygge 01\0 Hygge 01_S\0 Hygge 02\0 Hygge 02_S\0 Hygge 03\0 Hygge 03_S\0 Hygge 04\0 Hygge 04_S\0 Hygge 05\0 Hygge 05_S\0 Hygge 06\0 Hygge 06_S\0 Hygge 07\0 Hygge 07_S\0 Hygge 08\0 Hygge 08_S\0 Hygge 09\0 Hygge 09_S\0 Hygge 10\0 Hygge 10_S\0 Nyboder 01\0 Nyboder 01_S\0 Nyboder 02\0 Nyboder 02_S\0 Nyboder 03\0 Nyboder 03_S\0 Nyboder 04\0 Nyboder 04_S\0 Nyboder 05\0 Nyboder 05_S\0 Nyboder 06\0 Nyboder 06_S\0 Nyboder 07\0 Nyboder 07_S\0 Nyboder 08\0 Nyboder 08_S\0 Nyboder 09\0 Nyboder 09_S\0 Nyboder 10\0 Nyboder 10_S\0 Nyhavn 01\0 Nyhavn 01_S\0 Nyhavn 02\0 Nyhavn 02_S\0 Nyhavn 03\0 Nyhavn 03_S\0 Nyhavn 04\0 Nyhavn 04_S\0 Nyhavn 05\0 Nyhavn 05_S\0 Nyhavn 06\0 Nyhavn 06_S\0 Nyhavn 07\0 Nyhavn 07_S\0 Nyhavn 08\0 Nyhavn 08_S\0 Nyhavn 09\0 Nyhavn 09_S\0 Nyhavn 10\0 Nyhavn 10_S\0 Winter 01\0 Winter 01_S\0 Winter 02\0 Winter 02_S\0 Winter 03\0 Winter 03_S\0 Winter 04\0 Winter 04_S\0 Winter 05\0 Winter 05_S\0 Winter 06\0 Winter 06_S\0 Winter 07\0 Winter 07_S\0 Winter 08\0 Winter 08_S\0 Winter 09\0 Winter 09_S\0 Winter 10\0 Winter 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Copenhagen < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Copenhagen; };

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

    technique Copenhagen_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}