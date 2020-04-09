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
// Converted by TheGordinho https://www.youtube.com/watch?v=EwTZ2xpQwpA
// Thanks to kingeric1992 and Matsilagi for the tools
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#ifndef fLUT_TextureName
	#define fLUT_TextureName "Chocolate Tones LUT.png"
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

namespace MLUT_MultiLUT_Chocolate_Tones
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Cappuccino 01\0 Cappuccino 01_S\0 Cappuccino 02\0 Cappuccino 02_S\0 Cappuccino 03\0 Cappuccino 03_S\0 Cappuccino 04\0 Cappuccino 04_S\0 Cappuccino 05\0 Cappuccino 05_S\0 Cappuccino 06\0 Cappuccino 06_S\0 Cappuccino 07\0 Cappuccino 07_S\0 Cappuccino 08\0 Cappuccino 08_S\0 Cappuccino 09\0 Cappuccino 09_S\0 Cappuccino 10\0 Cappuccino 10_S\0 Caramel 01\0 Caramel 01_S\0 Caramel 02\0 Caramel 02_S\0 Caramel 03\0 Caramel 03_S\0 Caramel 04\0 Caramel 04_S\0 Caramel 05\0 Caramel 05_S\0 Caramel 06\0 Caramel 06_S\0 Caramel 07\0 Caramel 07_S\0 Caramel 08\0 Caramel 08_S\0 Caramel 09\0 Caramel 09_S\0 Caramel 10\0 Caramel 10_S\0 Coffee 01\0 Coffee 01_S\0 Coffee 02\0 Coffee 02_S\0 Coffee 03\0 Coffee 03_S\0 Coffee 04\0 Coffee 04_S\0 Coffee 05\0 Coffee 05_S\0 Coffee 06\0 Coffee 06_S\0 Coffee 07\0 Coffee 07_S\0 Coffee 08\0 Coffee 08_S\0 Coffee 09\0 Coffee 09_S\0 Coffee 10\0 Coffee 10_S\0 Mocha 01\0 Mocha 01_S\0 Mocha 02\0 Mocha 02_S\0 Mocha 03\0 Mocha 03_S\0 Mocha 04\0 Mocha 04_S\0 Mocha 05\0 Mocha 05_S\0 Mocha 06\0 Mocha 06_S\0 Mocha 07\0 Mocha 07_S\0 Mocha 08\0 Mocha 08_S\0 Mocha 09\0 Mocha 09_S\0 Mocha 10\0 Mocha 10_S\0 Peanut 01\0 Peanut 01_S\0 Peanut 02\0 Peanut 02_S\0 Peanut 03\0 Peanut 03_S\0 Peanut 04\0 Peanut 04_S\0 Peanut 05\0 Peanut 05_S\0 Peanut 06\0 Peanut 06_S\0 Peanut 07\0 Peanut 07_S\0 Peanut 08\0 Peanut 08_S\0 Peanut 09\0 Peanut 09_S\0 Peanut 10\0 Peanut 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Chocolate_Tones < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Chocolate_Tones; };

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

    technique Chocolate_Tones_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}