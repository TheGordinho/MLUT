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
	#define fLUT_TextureName "Black And Yellow MLUT.png"
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

namespace MLUT_MultiLUT_Black_And_Yellow
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Black and Yellow 01\0 Black and Yellow 01_S\0 Black and Yellow 02\0 Black and Yellow 02_S\0 Black and Yellow 03\0 Black and Yellow 03_S\0 Black and Yellow 04\0 Black and Yellow 04_S\0 Black and Yellow 05\0 Black and Yellow 05_S\0 Black and Yellow 06\0 Black and Yellow 06_S\0 Black and Yellow 07\0 Black and Yellow 07_S\0 Black and Yellow 08\0 Black and Yellow 08_S\0 Black and Yellow 09\0 Black and Yellow 09_S\0 Black and Yellow 10\0 Black and Yellow 10_S\0 Gold and Teal 01\0 Gold and Teal 01_S\0 Gold and Teal 02\0 Gold and Teal 02_S\0 Gold and Teal 03\0 Gold and Teal 03_S\0 Gold and Teal 04\0 Gold and Teal 04_S\0 Gold and Teal 05\0 Gold and Teal 05_S\0 Gold and Teal 06\0 Gold and Teal 06_S\0 Gold and Teal 07\0 Gold and Teal 07_S\0 Gold and Teal 08\0 Gold and Teal 08_S\0 Gold and Teal 09\0 Gold and Teal 09_S\0 Gold and Teal 10\0 Gold and Teal 10_S\0 Inferno 01\0 Inferno 01_S\0 Inferno 02\0 Inferno 02_S\0 Inferno 03\0 Inferno 03_S\0 Inferno 04\0 Inferno 04_S\0 Inferno 05\0 Inferno 05_S\0 Inferno 06\0 Inferno 06_S\0 Inferno 07\0 Inferno 07_S\0 Inferno 08\0 Inferno 08_S\0 Inferno 09\0 Inferno 09_S\0 Inferno 10\0 Inferno 10_S\0 list.txt Moody 01\0 Moody 01_S\0 Moody 02\0 Moody 02_S\0 Moody 03\0 Moody 03_S\0 Moody 04\0 Moody 04_S\0 Moody 05\0 Moody 05_S\0 Moody 06\0 Moody 06_S\0 Moody 07\0 Moody 07_S\0 Moody 08\0 Moody 08_S\0 Moody 09\0 Moody 09_S\0 Moody 10\0 Moody 10_S\0 Navy 01\0 Navy 01_S\0 Navy 02\0 Navy 02_S\0 Navy 03\0 Navy 03_S\0 Navy 04\0 Navy 04_S\0 Navy 05\0 Navy 05_S\0 Navy 06\0 Navy 06_S\0 Navy 07\0 Navy 07_S\0 Navy 08\0 Navy 08_S\0 Navy 09\0 Navy 09_S\0 Navy 10\0 Navy 10_S\0";
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

    texture texMultiLUT_MLUT_pd80_Black_And_Yellow < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Black_And_Yellow; };

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

    technique Black_And_Yellow_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}