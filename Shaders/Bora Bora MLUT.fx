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
	#define fLUT_TextureName "Bora Bora LUT.png"
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

namespace MLUT_MultiLUT_Bora_Bora
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Beach Bliss 01\0 Beach Bliss 01_S\0 Beach Bliss 02\0 Beach Bliss 02_S\0 Beach Bliss 03\0 Beach Bliss 03_S\0 Beach Bliss 04\0 Beach Bliss 04_S\0 Beach Bliss 05\0 Beach Bliss 05_S\0 Beach Bliss 06\0 Beach Bliss 06_S\0 Beach Bliss 07\0 Beach Bliss 07_S\0 Beach Bliss 08\0 Beach Bliss 08_S\0 Beach Bliss 09\0 Beach Bliss 09_S\0 Beach Bliss 10\0 Beach Bliss 10_S\0 Bungalow 01\0 Bungalow 01_S\0 Bungalow 02\0 Bungalow 02_S\0 Bungalow 03\0 Bungalow 03_S\0 Bungalow 04\0 Bungalow 04_S\0 Bungalow 05\0 Bungalow 05_S\0 Bungalow 06\0 Bungalow 06_S\0 Bungalow 07\0 Bungalow 07_S\0 Bungalow 08\0 Bungalow 08_S\0 Bungalow 09\0 Bungalow 09_S\0 Bungalow 10\0 Bungalow 10_S\0 Pearl Beach 01\0 Pearl Beach 01_S\0 Pearl Beach 02\0 Pearl Beach 02_S\0 Pearl Beach 03\0 Pearl Beach 03_S\0 Pearl Beach 04\0 Pearl Beach 04_S\0 Pearl Beach 05\0 Pearl Beach 05_S\0 Pearl Beach 06\0 Pearl Beach 06_S\0 Pearl Beach 07\0 Pearl Beach 07_S\0 Pearl Beach 08\0 Pearl Beach 08_S\0 Pearl Beach 09\0 Pearl Beach 09_S\0 Pearl Beach 10\0 Pearl Beach 10_S\0 Perfect Honeymoon 01\0 Perfect Honeymoon 01_S\0 Perfect Honeymoon 02\0 Perfect Honeymoon 02_S\0 Perfect Honeymoon 03\0 Perfect Honeymoon 03_S\0 Perfect Honeymoon 04\0 Perfect Honeymoon 04_S\0 Perfect Honeymoon 05\0 Perfect Honeymoon 05_S\0 Perfect Honeymoon 06\0 Perfect Honeymoon 06_S\0 Perfect Honeymoon 07\0 Perfect Honeymoon 07_S\0 Perfect Honeymoon 08\0 Perfect Honeymoon 08_S\0 Perfect Honeymoon 09\0 Perfect Honeymoon 09_S\0 Perfect Honeymoon 10\0 Perfect Honeymoon 10_S\0 Tahiti 01\0 Tahiti 01_S\0 Tahiti 02\0 Tahiti 02_S\0 Tahiti 03\0 Tahiti 03_S\0 Tahiti 04\0 Tahiti 04_S\0 Tahiti 05\0 Tahiti 05_S\0 Tahiti 06\0 Tahiti 06_S\0 Tahiti 07\0 Tahiti 07_S\0 Tahiti 08\0 Tahiti 08_S\0 Tahiti 09\0 Tahiti 09_S\0 Tahiti 10\0 Tahiti 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Bora_Bora < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Bora_Bora; };

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

    technique Bora_Bora_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}