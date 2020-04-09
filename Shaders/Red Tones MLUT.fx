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
	#define fLUT_TextureName "Red Tones MLUT.png"
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

namespace MLUT_MultiLUT_Red_Tones
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Dawn 01\0 Dawn 01_S\0 Dawn 02\0 Dawn 02_S\0 Dawn 03\0 Dawn 03_S\0 Dawn 04\0 Dawn 04_S\0 Dawn 05\0 Dawn 05_S\0 Dawn 06\0 Dawn 06_S\0 Dawn 07\0 Dawn 07_S\0 Dawn 08\0 Dawn 08_S\0 Dawn 09\0 Dawn 09_S\0 Dawn 10\0 Dawn 10_S\0 Lady 01\0 Lady 01_S\0 Lady 02\0 Lady 02_S\0 Lady 03\0 Lady 03_S\0 Lady 04\0 Lady 04_S\0 Lady 05\0 Lady 05_S\0 Lady 06\0 Lady 06_S\0 Lady 07\0 Lady 07_S\0 Lady 08\0 Lady 08_S\0 Lady 09\0 Lady 09_S\0 Lady 10\0 Lady 10_S\0 lgetnames.bat list.txt LutMate.bat LutMate.exe Radiant 01\0 Radiant 01_S\0 Radiant 02\0 Radiant 02_S\0 Radiant 03\0 Radiant 03_S\0 Radiant 04\0 Radiant 04_S\0 Radiant 05\0 Radiant 05_S\0 Radiant 06\0 Radiant 06_S\0 Radiant 07\0 Radiant 07_S\0 Radiant 08\0 Radiant 08_S\0 Radiant 09\0 Radiant 09_S\0 Radiant 10\0 Radiant 10_S\0 Sage 01\0 Sage 01_S\0 Sage 02\0 Sage 02_S\0 Sage 03\0 Sage 03_S\0 Sage 04\0 Sage 04_S\0 Sage 05\0 Sage 05_S\0 Sage 06\0 Sage 06_S\0 Sage 07\0 Sage 07_S\0 Sage 08\0 Sage 08_S\0 Sage 09\0 Sage 09_S\0 Sage 10\0 Sage 10_S\0 Wine 01\0 Wine 01_S\0 Wine 02\0 Wine 02_S\0 Wine 03\0 Wine 03_S\0 Wine 04\0 Wine 04_S\0 Wine 05\0 Wine 05_S\0 Wine 06\0 Wine 06_S\0 Wine 07\0 Wine 07_S\0 Wine 08\0 Wine 08_S\0 Wine 09\0 Wine 09_S\0 Wine 10\0 Wine 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Red_Tones < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Red_Tones; };

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

    technique Red_Tones_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}