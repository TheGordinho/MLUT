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
	#define fLUT_TextureName "Papaya Orange MLUT.png"
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

namespace MLUT_MultiLUT_Papaya_Orange
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=100;
		ui_items=" Hawaii Bright 01\0 Hawaii Bright 01_S\0 Hawaii Bright 02\0 Hawaii Bright 02_S\0 Hawaii Bright 03\0 Hawaii Bright 03_S\0 Hawaii Bright 04\0 Hawaii Bright 04_S\0 Hawaii Bright 05\0 Hawaii Bright 05_S\0 Hawaii Bright 06\0 Hawaii Bright 06_S\0 Hawaii Bright 07\0 Hawaii Bright 07_S\0 Hawaii Bright 08\0 Hawaii Bright 08_S\0 Hawaii Bright 09\0 Hawaii Bright 09_S\0 Hawaii Bright 10\0 Hawaii Bright 10_S\0 Pandan Papaya 01\0 Pandan Papaya 01_S\0 Pandan Papaya 02\0 Pandan Papaya 02_S\0 Pandan Papaya 03\0 Pandan Papaya 03_S\0 Pandan Papaya 04\0 Pandan Papaya 04_S\0 Pandan Papaya 05\0 Pandan Papaya 05_S\0 Pandan Papaya 06\0 Pandan Papaya 06_S\0 Pandan Papaya 07\0 Pandan Papaya 07_S\0 Pandan Papaya 08\0 Pandan Papaya 08_S\0 Pandan Papaya 09\0 Pandan Papaya 09_S\0 Pandan Papaya 10\0 Pandan Papaya 10_S\0 Papaya Whip 01\0 Papaya Whip 01_S\0 Papaya Whip 02\0 Papaya Whip 02_S\0 Papaya Whip 03\0 Papaya Whip 03_S\0 Papaya Whip 04\0 Papaya Whip 04_S\0 Papaya Whip 05\0 Papaya Whip 05_S\0 Papaya Whip 06\0 Papaya Whip 06_S\0 Papaya Whip 07\0 Papaya Whip 07_S\0 Papaya Whip 08\0 Papaya Whip 08_S\0 Papaya Whip 09\0 Papaya Whip 09_S\0 Papaya Whip 10\0 Papaya Whip 10_S\0 PapaYay 01\0 PapaYay 01_S\0 PapaYay 02\0 PapaYay 02_S\0 PapaYay 03\0 PapaYay 03_S\0 PapaYay 04\0 PapaYay 04_S\0 PapaYay 05\0 PapaYay 05_S\0 PapaYay 06\0 PapaYay 06_S\0 PapaYay 07\0 PapaYay 07_S\0 PapaYay 08\0 PapaYay 08_S\0 PapaYay 09\0 PapaYay 09_S\0 PapaYay 10\0 PapaYay 10_S\0 Tropic Orange 01\0 Tropic Orange 01_S\0 Tropic Orange 02\0 Tropic Orange 02_S\0 Tropic Orange 03\0 Tropic Orange 03_S\0 Tropic Orange 04\0 Tropic Orange 04_S\0 Tropic Orange 05\0 Tropic Orange 05_S\0 Tropic Orange 06\0 Tropic Orange 06_S\0 Tropic Orange 07\0 Tropic Orange 07_S\0 Tropic Orange 08\0 Tropic Orange 08_S\0 Tropic Orange 09\0 Tropic Orange 09_S\0 Tropic Orange 10\0 Tropic Orange 10_S\0";
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

    texture texMultiLUT_MLUT_Papaya_Orange < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_Papaya_Orange; };

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

    technique Papaya_Orange_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}