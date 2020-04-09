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
	#define fLUT_TextureName "Honney Yellow MLUT.png"
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

namespace MLUT_MultiLUT_Honney_Yellow
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Comb 01\0 Comb 01_S\0 Comb 02\0 Comb 02_S\0 Comb 03\0 Comb 03_S\0 Comb 04\0 Comb 04_S\0 Comb 05\0 Comb 05_S\0 Comb 06\0 Comb 06_S\0 Comb 07\0 Comb 07_S\0 Comb 08\0 Comb 08_S\0 Comb 09\0 Comb 09_S\0 Comb 10\0 Comb 10_S\0 Gold 01\0 Gold 01_S\0 Gold 02\0 Gold 02_S\0 Gold 03\0 Gold 03_S\0 Gold 04\0 Gold 04_S\0 Gold 05\0 Gold 05_S\0 Gold 06\0 Gold 06_S\0 Gold 07\0 Gold 07_S\0 Gold 08\0 Gold 08_S\0 Gold 09\0 Gold 09_S\0 Gold 10\0 Gold 10_S\0 Hive 01\0 Hive 01_S\0 Hive 02\0 Hive 02_S\0 Hive 03\0 Hive 03_S\0 Hive 04\0 Hive 04_S\0 Hive 05\0 Hive 05_S\0 Hive 06\0 Hive 06_S\0 Hive 07\0 Hive 07_S\0 Hive 08\0 Hive 08_S\0 Hive 09\0 Hive 09_S\0 Hive 10\0 Hive 10_S\0 Raw 01\0 Raw 01_S\0 Raw 02\0 Raw 02_S\0 Raw 03\0 Raw 03_S\0 Raw 04\0 Raw 04_S\0 Raw 05\0 Raw 05_S\0 Raw 06\0 Raw 06_S\0 Raw 07\0 Raw 07_S\0 Raw 08\0 Raw 08_S\0 Raw 09\0 Raw 09_S\0 Raw 10\0 Raw 10_S\0 Syrup 01\0 Syrup 01_S\0 Syrup 02\0 Syrup 02_S\0 Syrup 03\0 Syrup 03_S\0 Syrup 04\0 Syrup 04_S\0 Syrup 05\0 Syrup 05_S\0 Syrup 06\0 Syrup 06_S\0 Syrup 07\0 Syrup 07_S\0 Syrup 08\0 Syrup 08_S\0 Syrup 09\0 Syrup 09_S\0 Syrup 10\0 Syrup 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Honney_Yellow < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Honney_Yellow; };

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

    technique Honney_Yellow_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}