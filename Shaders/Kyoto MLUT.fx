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
	#define fLUT_TextureName "Kyoto MLUT.png"
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

namespace MLUT_MultiLUT_Kyoto
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Ice Cream 01\0 Ice Cream 01_S\0 Ice Cream 02\0 Ice Cream 02_S\0 Ice Cream 03\0 Ice Cream 03_S\0 Ice Cream 04\0 Ice Cream 04_S\0 Ice Cream 05\0 Ice Cream 05_S\0 Ice Cream 06\0 Ice Cream 06_S\0 Ice Cream 07\0 Ice Cream 07_S\0 Ice Cream 08\0 Ice Cream 08_S\0 Ice Cream 09\0 Ice Cream 09_S\0 Ice Cream 10\0 Ice Cream 10_S\0 Jelly 01\0 Jelly 01_S\0 Jelly 02\0 Jelly 02_S\0 Jelly 03\0 Jelly 03_S\0 Jelly 04\0 Jelly 04_S\0 Jelly 05\0 Jelly 05_S\0 Jelly 06\0 Jelly 06_S\0 Jelly 07\0 Jelly 07_S\0 Jelly 08\0 Jelly 08_S\0 Jelly 09\0 Jelly 09_S\0 Jelly 10\0 Jelly 10_S\0 Rose 01\0 Rose 01_S\0 Rose 02\0 Rose 02_S\0 Rose 03\0 Rose 03_S\0 Rose 04\0 Rose 04_S\0 Rose 05\0 Rose 05_S\0 Rose 06\0 Rose 06_S\0 Rose 07\0 Rose 07_S\0 Rose 08\0 Rose 08_S\0 Rose 09\0 Rose 09_S\0 Rose 10\0 Rose 10_S\0 Smoothie 01\0 Smoothie 01_S\0 Smoothie 02\0 Smoothie 02_S\0 Smoothie 03\0 Smoothie 03_S\0 Smoothie 04\0 Smoothie 04_S\0 Smoothie 05\0 Smoothie 05_S\0 Smoothie 06\0 Smoothie 06_S\0 Smoothie 07\0 Smoothie 07_S\0 Smoothie 08\0 Smoothie 08_S\0 Smoothie 09\0 Smoothie 09_S\0 Smoothie 10\0 Smoothie 10_S\0 Valentines 01\0 Valentines 01_S\0 Valentines 02\0 Valentines 02_S\0 Valentines 03\0 Valentines 03_S\0 Valentines 04\0 Valentines 04_S\0 Valentines 05\0 Valentines 05_S\0 Valentines 06\0 Valentines 06_S\0 Valentines 07\0 Valentines 07_S\0 Valentines 08\0 Valentines 08_S\0 Valentines 09\0 Valentines 09_S\0 Valentines 10\0 Valentines 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Kyoto < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Kyoto; };

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

    technique Kyoto_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}