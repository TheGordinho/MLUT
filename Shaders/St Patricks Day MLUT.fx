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
	#define fLUT_TextureName "St Patricks Day MLUT.png"
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

namespace MLUT_MultiLUT_St_Patricks_Day
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Dublin 01\0 Dublin 01_S\0 Dublin 02\0 Dublin 02_S\0 Dublin 03\0 Dublin 03_S\0 Dublin 04\0 Dublin 04_S\0 Dublin 05\0 Dublin 05_S\0 Dublin 06\0 Dublin 06_S\0 Dublin 07\0 Dublin 07_S\0 Dublin 08\0 Dublin 08_S\0 Dublin 09\0 Dublin 09_S\0 Dublin 10\0 Dublin 10_S\0 Four Leaf Clover 01\0 Four Leaf Clover 01_S\0 Four Leaf Clover 02\0 Four Leaf Clover 02_S\0 Four Leaf Clover 03\0 Four Leaf Clover 03_S\0 Four Leaf Clover 04\0 Four Leaf Clover 04_S\0 Four Leaf Clover 05\0 Four Leaf Clover 05_S\0 Four Leaf Clover 06\0 Four Leaf Clover 06_S\0 Four Leaf Clover 07\0 Four Leaf Clover 07_S\0 Four Leaf Clover 08\0 Four Leaf Clover 08_S\0 Four Leaf Clover 09\0 Four Leaf Clover 09_S\0 Four Leaf Clover 10\0 Four Leaf Clover 10_S\0 Irish 01\0 Irish 01_S\0 Irish 02\0 Irish 02_S\0 Irish 03\0 Irish 03_S\0 Irish 04\0 Irish 04_S\0 Irish 05\0 Irish 05_S\0 Irish 06\0 Irish 06_S\0 Irish 07\0 Irish 07_S\0 Irish 08\0 Irish 08_S\0 Irish 09\0 Irish 09_S\0 Irish 10\0 Irish 10_S\0 Leprechaun 01\0 Leprechaun 01_S\0 Leprechaun 02\0 Leprechaun 02_S\0 Leprechaun 03\0 Leprechaun 03_S\0 Leprechaun 04\0 Leprechaun 04_S\0 Leprechaun 05\0 Leprechaun 05_S\0 Leprechaun 06\0 Leprechaun 06_S\0 Leprechaun 07\0 Leprechaun 07_S\0 Leprechaun 08\0 Leprechaun 08_S\0 Leprechaun 09\0 Leprechaun 09_S\0 Leprechaun 10\0 Leprechaun 10_S\0 Victorian 01\0 Victorian 01_S\0 Victorian 02\0 Victorian 02_S\0 Victorian 03\0 Victorian 03_S\0 Victorian 04\0 Victorian 04_S\0 Victorian 05\0 Victorian 05_S\0 Victorian 06\0 Victorian 06_S\0 Victorian 07\0 Victorian 07_S\0 Victorian 08\0 Victorian 08_S\0 Victorian 09\0 Victorian 09_S\0 Victorian 10\0 Victorian 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_St_Patricks_Day < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_St_Patricks_Day; };

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

    technique St_Patricks_Day_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}