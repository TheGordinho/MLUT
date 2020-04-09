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
	#define fLUT_TextureName "Bohemian MLUT.png"
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

namespace MLUT_MultiLUT_Bohemian
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Hippie Style 01\0 Hippie Style 01_S\0 Hippie Style 02\0 Hippie Style 02_S\0 Hippie Style 03\0 Hippie Style 03_S\0 Hippie Style 04\0 Hippie Style 04_S\0 Hippie Style 05\0 Hippie Style 05_S\0 Hippie Style 06\0 Hippie Style 06_S\0 Hippie Style 07\0 Hippie Style 07_S\0 Hippie Style 08\0 Hippie Style 08_S\0 Hippie Style 09\0 Hippie Style 09_S\0 Hippie Style 10\0 Hippie Style 10_S\0 Moody Soft 01\0 Moody Soft 01_S\0 Moody Soft 02\0 Moody Soft 02_S\0 Moody Soft 03\0 Moody Soft 03_S\0 Moody Soft 04\0 Moody Soft 04_S\0 Moody Soft 05\0 Moody Soft 05_S\0 Moody Soft 06\0 Moody Soft 06_S\0 Moody Soft 07\0 Moody Soft 07_S\0 Moody Soft 08\0 Moody Soft 08_S\0 Moody Soft 09\0 Moody Soft 09_S\0 Moody Soft 10\0 Moody Soft 10_S\0 Pastel Chic 01\0 Pastel Chic 01_S\0 Pastel Chic 02\0 Pastel Chic 02_S\0 Pastel Chic 03\0 Pastel Chic 03_S\0 Pastel Chic 04\0 Pastel Chic 04_S\0 Pastel Chic 05\0 Pastel Chic 05_S\0 Pastel Chic 06\0 Pastel Chic 06_S\0 Pastel Chic 07\0 Pastel Chic 07_S\0 Pastel Chic 08\0 Pastel Chic 08_S\0 Pastel Chic 09\0 Pastel Chic 09_S\0 Pastel Chic 10\0 Pastel Chic 10_S\0 Simple Boho 01\0 Simple Boho 01_S\0 Simple Boho 02\0 Simple Boho 02_S\0 Simple Boho 03\0 Simple Boho 03_S\0 Simple Boho 04\0 Simple Boho 04_S\0 Simple Boho 05\0 Simple Boho 05_S\0 Simple Boho 06\0 Simple Boho 06_S\0 Simple Boho 07\0 Simple Boho 07_S\0 Simple Boho 08\0 Simple Boho 08_S\0 Simple Boho 09\0 Simple Boho 09_S\0 Simple Boho 10\0 Simple Boho 10_S\0 Summer Vibe 01\0 Summer Vibe 01_S\0 Summer Vibe 02\0 Summer Vibe 02_S\0 Summer Vibe 03\0 Summer Vibe 03_S\0 Summer Vibe 04\0 Summer Vibe 04_S\0 Summer Vibe 05\0 Summer Vibe 05_S\0 Summer Vibe 06\0 Summer Vibe 06_S\0 Summer Vibe 07\0 Summer Vibe 07_S\0 Summer Vibe 08\0 Summer Vibe 08_S\0 Summer Vibe 09\0 Summer Vibe 09_S\0 Summer Vibe 10\0 Summer Vibe 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Bohemian < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Bohemian; };

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

    technique Bohemian_LUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}