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
	#define fLUT_TextureName "Yellow Teal MLUT.png"
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

namespace MLUT_MultiLUT_Yellow_Teal
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=100;
		ui_items=" Highlighter 01\0 Highlighter 01_S\0 Highlighter 02\0 Highlighter 02_S\0 Highlighter 03\0 Highlighter 03_S\0 Highlighter 04\0 Highlighter 04_S\0 Highlighter 05\0 Highlighter 05_S\0 Highlighter 06\0 Highlighter 06_S\0 Highlighter 07\0 Highlighter 07_S\0 Highlighter 08\0 Highlighter 08_S\0 Highlighter 09\0 Highlighter 09_S\0 Highlighter 10\0 Highlighter 10_S\0 Lemonology 01\0 Lemonology 01_S\0 Lemonology 02\0 Lemonology 02_S\0 Lemonology 03\0 Lemonology 03_S\0 Lemonology 04\0 Lemonology 04_S\0 Lemonology 05\0 Lemonology 05_S\0 Lemonology 06\0 Lemonology 06_S\0 Lemonology 07\0 Lemonology 07_S\0 Lemonology 08\0 Lemonology 08_S\0 Lemonology 09\0 Lemonology 09_S\0 Lemonology 10\0 Lemonology 10_S\0 Marigold 01\0 Marigold 01_S\0 Marigold 02\0 Marigold 02_S\0 Marigold 03\0 Marigold 03_S\0 Marigold 04\0 Marigold 04_S\0 Marigold 05\0 Marigold 05_S\0 Marigold 06\0 Marigold 06_S\0 Marigold 07\0 Marigold 07_S\0 Marigold 08\0 Marigold 08_S\0 Marigold 09\0 Marigold 09_S\0 Marigold 10\0 Marigold 10_S\0 Spring 01\0 Spring 01_S\0 Spring 02\0 Spring 02_S\0 Spring 03\0 Spring 03_S\0 Spring 04\0 Spring 04_S\0 Spring 05\0 Spring 05_S\0 Spring 06\0 Spring 06_S\0 Spring 07\0 Spring 07_S\0 Spring 08\0 Spring 08_S\0 Spring 09\0 Spring 09_S\0 Spring 10\0 Spring 10_S\0 Tulip 01\0 Tulip 01_S\0 Tulip 02\0 Tulip 02_S\0 Tulip 03\0 Tulip 03_S\0 Tulip 04\0 Tulip 04_S\0 Tulip 05\0 Tulip 05_S\0 Tulip 06\0 Tulip 06_S\0 Tulip 07\0 Tulip 07_S\0 Tulip 08\0 Tulip 08_S\0 Tulip 09\0 Tulip 09_S\0 Tulip 10\0 Tulip 10_S\0";
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

    texture texMultiLUT_MLUT_Yellow_Teal < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_Yellow_Teal; };

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

    technique Yellow_Teal_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}