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
	#define fLUT_TextureName "Desaturated City MLUT.png"
#endif
#ifndef fLUT_TileSizeXY
	#define fLUT_TileSizeXY 32
#endif
#ifndef fLUT_TileAmount
	#define fLUT_TileAmount 32
#endif
#ifndef fLUT_LutAmount
	#define fLUT_LutAmount 99
#endif

#include "ReShade.fxh"

namespace MLUT_MultiLUT_Desaturated_City
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items="Arrival 01\0Arrival 01_S\0Arrival 02\0Arrival 02_s\0Arrival 03\0Arrival 03_s\0Arrival 04\0Arrival 04_S\0Arrival 05\0Arrival 05_S\0Arrival 06\0Arrival 06_S\0Arrival 07\0Arrival 07_S\0Arrival 08\0Arrival 08_S\0Arrival 09\0Arrival 09_S\0Arrival 10\0Arrival 10_S\0Flame 01\0Flame 01_S\0Flame 02\0Flame 02_S\0Flame 03\0Flame 03_S\0Flame 04\0Flame 04_S\0Flame 05\0Flame 05_S\0Flame 06\0Flame 06_S\0Flame 07\0Flame 07_S\0Flame 08\0Flame 08_S\0Flame 09\0Flame 09_S\0Flame 10\0Flame 10_S\0Gold 01\0Gold 01_S\0Gold 02\0Gold 02_S\0Gold 03\0Gold 03_S\0Gold 04\0Gold 05\0Gold 05_S\0Gold 06\0Gold 06_S\0Gold 07\0Gold 07_S\0Gold 08\0Gold 08_S\0Gold 09\0Gold 09_S\0Gold 10\0Gold 10_S\0Nocturne 01\0Nocturne 01_S\0Nocturne 02\0Nocturne 02_S\0Nocturne 03\0Nocturne 03_S\0Nocturne 04\0Nocturne 04_S\0Nocturne 05\0Nocturne 05_S\0Nocturne 06\0Nocturne 06_S\0Nocturne 07\0Nocturne 07_S\0Nocturne 08\0Nocturne 08_S\0Nocturne 09\0Nocturne 09_S\0Nocturne 10\0Nocturne 10_S\0Turbowave 01\0Turbowave 01_S\0Turbowave 02\0Turbowave 02_S\0Turbowave 03\0Turbowave 03_S\0Turbowave 04\0Turbowave 04_S\0Turbowave 05\0Turbowave 05_S\0Turbowave 06\0Turbowave 06_S\0Turbowave 07\0Turbowave 07_S\0Turbowave 08\0Turbowave 08_S\0Turbowave 09\0Turbowave 09_S\0Turbowave 10\0Turbowave 10_S";
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

    texture texMultiLUT_MLUT_pd80_Desaturated_City < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Desaturated_City; };

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

    technique Desaturated_City_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}