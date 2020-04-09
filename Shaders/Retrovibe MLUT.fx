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
	#define fLUT_TextureName "Retrovibe LUT.png"
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

namespace MLUT_MultiLUT_Retrovibe
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Christina 01\0 Christina 01_S\0 Christina 02\0 Christina 02_S\0 Christina 03\0 Christina 03_S\0 Christina 04\0 Christina 04_S\0 Christina 05\0 Christina 05_S\0 Christina 06\0 Christina 06_S\0 Christina 07\0 Christina 07_S\0 Christina 08\0 Christina 08_S\0 Christina 09\0 Christina 09_S\0 Christina 10\0 Christina 10_S\0 Hillside 01\0 Hillside 01_S\0 Hillside 02\0 Hillside 02_S\0 Hillside 03\0 Hillside 03_S\0 Hillside 04\0 Hillside 04_S\0 Hillside 05\0 Hillside 05_S\0 Hillside 06\0 Hillside 06_S\0 Hillside 07\0 Hillside 07_S\0 Hillside 08\0 Hillside 08_S\0 Hillside 09\0 Hillside 09_S\0 Hillside 10\0 Hillside 10_S\0 Musing 01\0 Musing 01_S\0 Musing 02\0 Musing 02_S\0 Musing 03\0 Musing 03_S\0 Musing 04\0 Musing 04_S\0 Musing 05\0 Musing 05_S\0 Musing 06\0 Musing 06_S\0 Musing 07\0 Musing 07_S\0 Musing 08\0 Musing 08_S\0 Musing 09\0 Musing 09_S\0 Musing 10\0 Musing 10_S\0 Rouge 01\0 Rouge 01_S\0 Rouge 02\0 Rouge 02_S\0 Rouge 03\0 Rouge 03_S\0 Rouge 04\0 Rouge 04_S\0 Rouge 05\0 Rouge 05_S\0 Rouge 06\0 Rouge 06_S\0 Rouge 07\0 Rouge 07_S\0 Rouge 08\0 Rouge 08_S\0 Rouge 09\0 Rouge 09_S\0 Rouge 10\0 Rouge 10_S\0 Woods 01\0 Woods 01_S\0 Woods 02\0 Woods 02_S\0 Woods 03\0 Woods 03_S\0 Woods 04\0 Woods 04_S\0 Woods 05\0 Woods 05_S\0 Woods 06\0 Woods 06_S\0 Woods 07\0 Woods 07_S\0 Woods 08\0 Woods 08_S\0 Woods 09\0 Woods 09_S\0 Woods 10\0 Woods 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Retrovibe < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Retrovibe; };

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

    technique Retrovibe_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}