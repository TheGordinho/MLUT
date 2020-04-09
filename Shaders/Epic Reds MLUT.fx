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
	#define fLUT_TextureName "Epic Reds MLUT.png"
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

namespace MLUT_MultiLUT_Epic_Reds
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items="Aero 01\0Aero 01_S\0Aero 02\0Aero 02_S\0Aero 03\0Aero 03_S\0Aero 04\0Aero 04_S\0Aero 05\0Aero 05_S\0Aero 06\0Aero 06_S\0Aero 07\0Aero 07_S\0Aero 08\0Aero 08_S\0Aero 09\0Aero 09_S\0Aero 10\0Aero 10_S\0Crimson 01\0Crimson 01_S\0Crimson 02\0Crimson 02_S\0Crimson 03\0Crimson 03_S\0Crimson 04\0Crimson 04_S\0Crimson 05\0Crimson 05_S\0Crimson 06\0Crimson 06_S\0Crimson 07\0Crimson 07_S\0Crimson 08\0Crimson 08_S\0Crimson 09\0Crimson 09_S\0Crimson 10\0Crimson 10_S\0Mint 01\0Mint 01_S\0Mint 02\0Mint 02_S\0Mint 03\0Mint 03_S\0Mint 04\0Mint 04_S\0Mint 05\0Mint 05_S\0Mint 06\0Mint 06_S\0Mint 07\0Mint 07_S\0Mint 08\0Mint 08_S\0Mint 09\0Mint 09_S\0Mint 10\0Mint 10_S\0Sakura 01\0Sakura 01_S\0Sakura 02\0Sakura 02_S\0Sakura 03\0Sakura 03_S\0Sakura 04\0Sakura 04_S\0Sakura 05\0Sakura 05_S\0Sakura 06\0Sakura 06_S\0Sakura 07\0Sakura 07_S\0Sakura 08\0Sakura 08_S\0Sakura 09\0Sakura 09_S\0Sakura 10\0Sakura 10_S\0Scarlet 01\0Scarlet 01_S\0Scarlet 02\0Scarlet 02_S\0Scarlet 03\0Scarlet 03_S\0Scarlet 04\0Scarlet 04_S\0Scarlet 05\0Scarlet 05_S\0Scarlet 06\0Scarlet 06_S\0Scarlet 07\0Scarlet 07_S\0Scarlet 08\0Scarlet 08_S\0Scarlet 09\0Scarlet 09_S\0Scarlet 10\0Scarlet 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Epic_Reds < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Epic_Reds; };

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

    technique Epic_Reds_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}