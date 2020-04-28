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
	#define fLUT_TextureName "Sakura Lights MLUT.png"
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

namespace MLUT_MultiLUT_Sakura_Lights
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=100;
		ui_items=" Blossom Beauty 01\0 Blossom Beauty 01_S\0 Blossom Beauty 02\0 Blossom Beauty 02_S\0 Blossom Beauty 03\0 Blossom Beauty 03_S\0 Blossom Beauty 04\0 Blossom Beauty 04_S\0 Blossom Beauty 05\0 Blossom Beauty 05_S\0 Blossom Beauty 06\0 Blossom Beauty 06_S\0 Blossom Beauty 07\0 Blossom Beauty 07_S\0 Blossom Beauty 08\0 Blossom Beauty 08_S\0 Blossom Beauty 09\0 Blossom Beauty 09_S\0 Blossom Beauty 10\0 Blossom Beauty 10_S\0 Blush 01\0 Blush 01_S\0 Blush 02\0 Blush 02_S\0 Blush 03\0 Blush 03_S\0 Blush 04\0 Blush 04_S\0 Blush 05\0 Blush 05_S\0 Blush 06\0 Blush 06_S\0 Blush 07\0 Blush 07_S\0 Blush 08\0 Blush 08_S\0 Blush 09\0 Blush 09_S\0 Blush 10\0 Blush 10_S\0 Kimono Pink 01\0 Kimono Pink 01_S\0 Kimono Pink 02\0 Kimono Pink 02_S\0 Kimono Pink 03\0 Kimono Pink 03_S\0 Kimono Pink 04\0 Kimono Pink 04_S\0 Kimono Pink 05\0 Kimono Pink 05_S\0 Kimono Pink 06\0 Kimono Pink 06_S\0 Kimono Pink 07\0 Kimono Pink 07_S\0 Kimono Pink 08\0 Kimono Pink 08_S\0 Kimono Pink 09\0 Kimono Pink 09_S\0 Kimono Pink 10\0 Kimono Pink 10_S\0 Light Shimmer 01\0 Light Shimmer 01_S\0 Light Shimmer 02\0 Light Shimmer 02_S\0 Light Shimmer 03\0 Light Shimmer 03_S\0 Light Shimmer 04\0 Light Shimmer 04_S\0 Light Shimmer 05\0 Light Shimmer 05_S\0 Light Shimmer 06\0 Light Shimmer 06_S\0 Light Shimmer 07\0 Light Shimmer 07_S\0 Light Shimmer 08\0 Light Shimmer 08_S\0 Light Shimmer 09\0 Light Shimmer 09_S\0 Light Shimmer 10\0 Light Shimmer 10_S\0 Pink Plaid 01\0 Pink Plaid 01_S\0 Pink Plaid 02\0 Pink Plaid 02_S\0 Pink Plaid 03\0 Pink Plaid 03_S\0 Pink Plaid 04\0 Pink Plaid 04_S\0 Pink Plaid 05\0 Pink Plaid 05_S\0 Pink Plaid 06\0 Pink Plaid 06_S\0 Pink Plaid 07\0 Pink Plaid 07_S\0 Pink Plaid 08\0 Pink Plaid 08_S\0 Pink Plaid 09\0 Pink Plaid 09_S\0 Pink Plaid 10\0 Pink Plaid 10_S\0";
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

    texture texMultiLUT_MLUT_Sakura_Lights < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_Sakura_Lights; };

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

    technique Sakura_Lights_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}