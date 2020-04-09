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
	#define fLUT_TextureName "Cotton Candy MLUT.png"
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

namespace MLUT_MultiLUT_Cotton_Candy
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Cherry 01\0 Cherry 01_S\0 Cherry 02\0 Cherry 02_S\0 Cherry 03\0 Cherry 03_S\0 Cherry 04\0 Cherry 04_S\0 Cherry 05\0 Cherry 05_S\0 Cherry 06\0 Cherry 06_S\0 Cherry 07\0 Cherry 07_S\0 Cherry 08\0 Cherry 08_S\0 Cherry 09\0 Cherry 09_S\0 Cherry 10\0 Cherry 10_S\0 Lemon Lime 01\0 Lemon Lime 01_S\0 Lemon Lime 02\0 Lemon Lime 02_S\0 Lemon Lime 03\0 Lemon Lime 03_S\0 Lemon Lime 04\0 Lemon Lime 04_S\0 Lemon Lime 05\0 Lemon Lime 05_S\0 Lemon Lime 06\0 Lemon Lime 06_S\0 Lemon Lime 07\0 Lemon Lime 07_S\0 Lemon Lime 08\0 Lemon Lime 08_S\0 Lemon Lime 09\0 Lemon Lime 09_S\0 Lemon Lime 10\0 Lemon Lime 10_S\0 Maple 01\0 Maple 01_S\0 Maple 02\0 Maple 02_S\0 Maple 03\0 Maple 03_S\0 Maple 04\0 Maple 04_S\0 Maple 05\0 Maple 05_S\0 Maple 06\0 Maple 06_S\0 Maple 07\0 Maple 07_S\0 Maple 08\0 Maple 08_S\0 Maple 09\0 Maple 09_S\0 Maple 10\0 Maple 10_S\0 Pineapple 01\0 Pineapple 01_S\0 Pineapple 02\0 Pineapple 02_S\0 Pineapple 03\0 Pineapple 03_S\0 Pineapple 04\0 Pineapple 04_S\0 Pineapple 05\0 Pineapple 05_S\0 Pineapple 06\0 Pineapple 06_S\0 Pineapple 07\0 Pineapple 07_S\0 Pineapple 08\0 Pineapple 08_S\0 Pineapple 09\0 Pineapple 09_S\0 Pineapple 10\0 Pineapple 10_S\0 Tangerine 01\0 Tangerine 01_S\0 Tangerine 02\0 Tangerine 02_S\0 Tangerine 03\0 Tangerine 03_S\0 Tangerine 04\0 Tangerine 04_S\0 Tangerine 05\0 Tangerine 05_S\0 Tangerine 06\0 Tangerine 06_S\0 Tangerine 07\0 Tangerine 07_S\0 Tangerine 08\0 Tangerine 08_S\0 Tangerine 09\0 Tangerine 09_S\0 Tangerine 10\0 Tangerine 10_S\0";
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

    texture texMultiLUT_MLUT_pd80_Cotton_Candy < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Cotton_Candy; };

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

    technique Cotton_Candy_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}