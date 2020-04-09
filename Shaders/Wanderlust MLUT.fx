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
	#define fLUT_TextureName "Wanderlust MLUT.png"
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

namespace MLUT_MultiLUT_Wanderlust
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Exploration 247 01\0 Exploration 247 01_S\0 Exploration 247 02\0 Exploration 247 02_S\0 Exploration 247 03\0 Exploration 247 03_S\0 Exploration 247 04\0 Exploration 247 04_S\0 Exploration 247 05\0 Exploration 247 05_S\0 Exploration 247 06\0 Exploration 247 06_S\0 Exploration 247 07\0 Exploration 247 07_S\0 Exploration 247 08\0 Exploration 247 08_S\0 Exploration 247 09\0 Exploration 247 09_S\0 Exploration 247 10\0 Exploration 247 10_S\0 Magical Minutes 01\0 Magical Minutes 01_S\0 Magical Minutes 02\0 Magical Minutes 02_S\0 Magical Minutes 03\0 Magical Minutes 03_S\0 Magical Minutes 04\0 Magical Minutes 04_S\0 Magical Minutes 05\0 Magical Minutes 05_S\0 Magical Minutes 06\0 Magical Minutes 06_S\0 Magical Minutes 07\0 Magical Minutes 07_S\0 Magical Minutes 08\0 Magical Minutes 08_S\0 Magical Minutes 09\0 Magical Minutes 09_S\0 Magical Minutes 10\0 Magical Minutes 10_S\0 Peaceful Positivity 01\0 Peaceful Positivity 01_S\0 Peaceful Positivity 02\0 Peaceful Positivity 02_S\0 Peaceful Positivity 03\0 Peaceful Positivity 03_S\0 Peaceful Positivity 04\0 Peaceful Positivity 04_S\0 Peaceful Positivity 05\0 Peaceful Positivity 05_S\0 Peaceful Positivity 06\0 Peaceful Positivity 06_S\0 Peaceful Positivity 07\0 Peaceful Positivity 07_S\0 Peaceful Positivity 08\0 Peaceful Positivity 08_S\0 Peaceful Positivity 09\0 Peaceful Positivity 09_S\0 Peaceful Positivity 10\0 Peaceful Positivity 10_S\0 The Little Things 01\0 The Little Things 01_S\0 The Little Things 02\0 The Little Things 02_S\0 The Little Things 03\0 The Little Things 03_S\0 The Little Things 04\0 The Little Things 04_S\0 The Little Things 05\0 The Little Things 05_S\0 The Little Things 06\0 The Little Things 06_S\0 The Little Things 07\0 The Little Things 07_S\0 The Little Things 08\0 The Little Things 08_S\0 The Little Things 09\0 The Little Things 09_S\0 The Little Things 10\0 The Little Things 10_S\0 Truest Self 01\0 Truest Self 01_S\0 Truest Self 02\0 Truest Self 02_S\0 Truest Self 03\0 Truest Self 03_S\0 Truest Self 04\0 Truest Self 04_S\0 Truest Self 05\0 Truest Self 05_S\0 Truest Self 06\0 Truest Self 06_S\0 Truest Self 07\0 Truest Self 07_S\0 Truest Self 08\0 Truest Self 08_S\0 Truest Self 09\0 Truest Self 09_S\0 Truest Self 10\0 Truest Self 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Wanderlust < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Wanderlust; };

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

    technique Wanderlust_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}