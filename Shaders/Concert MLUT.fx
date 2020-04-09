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
	#define fLUT_TextureName "Concert MLUT.png"
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

namespace MLUT_MultiLUT_Concert
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Alive 01\0 Alive 01_S\0 Alive 02\0 Alive 02_S\0 Alive 03\0 Alive 03_S\0 Alive 04\0 Alive 04_S\0 Alive 05\0 Alive 05_S\0 Alive 06\0 Alive 06_S\0 Alive 07\0 Alive 07_S\0 Alive 08\0 Alive 08_S\0 Alive 09\0 Alive 09_S\0 Alive 10\0 Alive 10_S\0 Boom 01\0 Boom 01_S\0 Boom 02\0 Boom 02_S\0 Boom 03\0 Boom 03_S\0 Boom 04\0 Boom 04_S\0 Boom 05\0 Boom 05_S\0 Boom 06\0 Boom 06_S\0 Boom 07\0 Boom 07_S\0 Boom 08\0 Boom 08_S\0 Boom 09\0 Boom 09_S\0 Boom 10\0 Boom 10_S\0 Canuck 01\0 Canuck 01_S\0 Canuck 02\0 Canuck 02_S\0 Canuck 03\0 Canuck 03_S\0 Canuck 04\0 Canuck 04_S\0 Canuck 05\0 Canuck 05_S\0 Canuck 06\0 Canuck 06_S\0 Canuck 07\0 Canuck 07_S\0 Canuck 08\0 Canuck 08_S\0 Canuck 09\0 Canuck 09_S\0 Canuck 10\0 Canuck 10_S\0 Gravity 01\0 Gravity 01_S\0 Gravity 02\0 Gravity 02_S\0 Gravity 03\0 Gravity 03_S\0 Gravity 04\0 Gravity 04_S\0 Gravity 05\0 Gravity 05_S\0 Gravity 06\0 Gravity 06_S\0 Gravity 07\0 Gravity 07_S\0 Gravity 08\0 Gravity 08_S\0 Gravity 09\0 Gravity 09_S\0 Gravity 10\0 Gravity 10_S\0 Metal 01\0 Metal 01_S\0 Metal 02\0 Metal 02_S\0 Metal 03\0 Metal 03_S\0 Metal 04\0 Metal 04_S\0 Metal 05\0 Metal 05_S\0 Metal 06\0 Metal 06_S\0 Metal 07\0 Metal 07_S\0 Metal 08\0 Metal 08_S\0 Metal 09\0 Metal 09_S\0 Metal 10\0 Metal 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Concert < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Concert; };

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

    technique Concert_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}