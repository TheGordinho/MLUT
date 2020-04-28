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
	#define fLUT_TextureName "Food Lightroom MLUT.png"
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

namespace MLUT_MultiLUT_Food_Lightroom
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=100;
		ui_items=" Breakfast 01\0 Breakfast 01_S\0 Breakfast 02\0 Breakfast 02_S\0 Breakfast 03\0 Breakfast 03_S\0 Breakfast 04\0 Breakfast 04_S\0 Breakfast 05\0 Breakfast 05_S\0 Breakfast 06\0 Breakfast 06_S\0 Breakfast 07\0 Breakfast 07_S\0 Breakfast 08\0 Breakfast 08_S\0 Breakfast 09\0 Breakfast 09_S\0 Breakfast 10\0 Breakfast 10_S\0 Hearty 01\0 Hearty 01_S\0 Hearty 02\0 Hearty 02_S\0 Hearty 03\0 Hearty 03_S\0 Hearty 04\0 Hearty 04_S\0 Hearty 05\0 Hearty 05_S\0 Hearty 06\0 Hearty 06_S\0 Hearty 07\0 Hearty 07_S\0 Hearty 08\0 Hearty 08_S\0 Hearty 09\0 Hearty 09_S\0 Hearty 10\0 Hearty 10_S\0 Rustic Bread 01\0 Rustic Bread 01_S\0 Rustic Bread 02\0 Rustic Bread 02_S\0 Rustic Bread 03\0 Rustic Bread 03_S\0 Rustic Bread 04\0 Rustic Bread 04_S\0 Rustic Bread 05\0 Rustic Bread 05_S\0 Rustic Bread 06\0 Rustic Bread 06_S\0 Rustic Bread 07\0 Rustic Bread 07_S\0 Rustic Bread 08\0 Rustic Bread 08_S\0 Rustic Bread 09\0 Rustic Bread 09_S\0 Rustic Bread 10\0 Rustic Bread 10_S\0 Superfood 01\0 Superfood 01_S\0 Superfood 02\0 Superfood 02_S\0 Superfood 03\0 Superfood 03_S\0 Superfood 04\0 Superfood 04_S\0 Superfood 05\0 Superfood 05_S\0 Superfood 06\0 Superfood 06_S\0 Superfood 07\0 Superfood 07_S\0 Superfood 08\0 Superfood 08_S\0 Superfood 09\0 Superfood 09_S\0 Superfood 10\0 Superfood 10_S\0 Tomato Basil 01\0 Tomato Basil 01_S\0 Tomato Basil 02\0 Tomato Basil 02_S\0 Tomato Basil 03\0 Tomato Basil 03_S\0 Tomato Basil 04\0 Tomato Basil 04_S\0 Tomato Basil 05\0 Tomato Basil 05_S\0 Tomato Basil 06\0 Tomato Basil 06_S\0 Tomato Basil 07\0 Tomato Basil 07_S\0 Tomato Basil 08\0 Tomato Basil 08_S\0 Tomato Basil 09\0 Tomato Basil 09_S\0 Tomato Basil 10\0 Tomato Basil 10_S\0";
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

    texture texMultiLUT_MLUT_Food_Lightroom < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_Food_Lightroom; };

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

    technique Food_Lightroom_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}