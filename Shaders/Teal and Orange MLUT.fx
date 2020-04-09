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
	#define fLUT_TextureName "Teal and Orange MLUT.png"
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

namespace MLUT_MultiLUT_Teal_and_Orange
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Orange Blue 01\0 Orange Blue 01_S\0 Orange Blue 02\0 Orange Blue 02_S\0 Orange Blue 03\0 Orange Blue 03_S\0 Orange Blue 04\0 Orange Blue 04_S\0 Orange Blue 05\0 Orange Blue 05_S\0 Orange Blue 06\0 Orange Blue 06_S\0 Orange Blue 07\0 Orange Blue 07_S\0 Orange Blue 08\0 Orange Blue 08_S\0 Orange Blue 09\0 Orange Blue 09_S\0 Orange Blue 10\0 Orange Blue 10_S\0 Orange Slate 01\0 Orange Slate 01_S\0 Orange Slate 02\0 Orange Slate 02_S\0 Orange Slate 03\0 Orange Slate 03_S\0 Orange Slate 04\0 Orange Slate 04_S\0 Orange Slate 05\0 Orange Slate 05_S\0 Orange Slate 06\0 Orange Slate 06_S\0 Orange Slate 07\0 Orange Slate 07_S\0 Orange Slate 08\0 Orange Slate 08_S\0 Orange Slate 09\0 Orange Slate 09_S\0 Orange Slate 10\0 Orange Slate 10_S\0 Orange Teal 01\0 Orange Teal 01_S\0 Orange Teal 02\0 Orange Teal 02_S\0 Orange Teal 03\0 Orange Teal 03_S\0 Orange Teal 04\0 Orange Teal 04_S\0 Orange Teal 05\0 Orange Teal 05_S\0 Orange Teal 06\0 Orange Teal 06_S\0 Orange Teal 07\0 Orange Teal 07_S\0 Orange Teal 08\0 Orange Teal 08_S\0 Orange Teal 09\0 Orange Teal 09_S\0 Orange Teal 10\0 Orange Teal 10_S\0 Red Blue 01\0 Red Blue 01_S\0 Red Blue 02\0 Red Blue 02_S\0 Red Blue 03\0 Red Blue 03_S\0 Red Blue 04\0 Red Blue 04_S\0 Red Blue 05\0 Red Blue 05_S\0 Red Blue 06\0 Red Blue 06_S\0 Red Blue 07\0 Red Blue 07_S\0 Red Blue 08\0 Red Blue 08_S\0 Red Blue 09\0 Red Blue 09_S\0 Red Blue 10\0 Red Blue 10_S\0 Red Teal 01\0 Red Teal 01_S\0 Red Teal 02\0 Red Teal 02_S\0 Red Teal 03\0 Red Teal 03_S\0 Red Teal 04\0 Red Teal 04_S\0 Red Teal 05\0 Red Teal 05_S\0 Red Teal 06\0 Red Teal 06_S\0 Red Teal 07\0 Red Teal 07_S\0 Red Teal 08\0 Red Teal 08_S\0 Red Teal 09\0 Red Teal 09_S\0 Red Teal 10\0 Red Teal 10_S\0";
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

    texture texMultiLUT_MLUT_pd80_Teal_and_Orange < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Teal_and_Orange; };

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

    technique Teal_and_Orange_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}