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
	#define fLUT_TextureName "Hustle MLUT.png"
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

namespace MLUT_MultiLUT_Hustle
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" 0 Luck 01\0 0 Luck 01_S\0 0 Luck 02\0 0 Luck 02_S\0 0 Luck 03\0 0 Luck 03_S\0 0 Luck 04\0 0 Luck 04_S\0 0 Luck 05\0 0 Luck 05_S\0 0 Luck 06\0 0 Luck 06_S\0 0 Luck 07\0 0 Luck 07_S\0 0 Luck 08\0 0 Luck 08_S\0 0 Luck 09\0 0 Luck 09_S\0 0 Luck 10\0 0 Luck 10_S\0 Afraid of Nothing 01\0 Afraid of Nothing 01_S\0 Afraid of Nothing 02\0 Afraid of Nothing 02_S\0 Afraid of Nothing 03\0 Afraid of Nothing 03_S\0 Afraid of Nothing 04\0 Afraid of Nothing 04_S\0 Afraid of Nothing 05\0 Afraid of Nothing 05_S\0 Afraid of Nothing 06\0 Afraid of Nothing 06_S\0 Afraid of Nothing 07\0 Afraid of Nothing 07_S\0 Afraid of Nothing 08\0 Afraid of Nothing 08_S\0 Afraid of Nothing 09\0 Afraid of Nothing 09_S\0 Afraid of Nothing 10\0 Afraid of Nothing 10_S\0 Hustle Hard 01\0 Hustle Hard 01_S\0 Hustle Hard 02\0 Hustle Hard 02_S\0 Hustle Hard 03\0 Hustle Hard 03_S\0 Hustle Hard 04\0 Hustle Hard 04_S\0 Hustle Hard 05\0 Hustle Hard 05_S\0 Hustle Hard 06\0 Hustle Hard 06_S\0 Hustle Hard 07\0 Hustle Hard 07_S\0 Hustle Hard 08\0 Hustle Hard 08_S\0 Hustle Hard 09\0 Hustle Hard 09_S\0 Hustle Hard 10\0 Hustle Hard 10_S\0 Stay Humble 01\0 Stay Humble 01_S\0 Stay Humble 02\0 Stay Humble 02_S\0 Stay Humble 03\0 Stay Humble 03_S\0 Stay Humble 04\0 Stay Humble 04_S\0 Stay Humble 05\0 Stay Humble 05_S\0 Stay Humble 06\0 Stay Humble 06_S\0 Stay Humble 07\0 Stay Humble 07_S\0 Stay Humble 08\0 Stay Humble 08_S\0 Stay Humble 09\0 Stay Humble 09_S\0 Stay Humble 10\0 Stay Humble 10_S\0 Wake Up 01\0 Wake Up 01_S\0 Wake Up 02\0 Wake Up 02_S\0 Wake Up 03\0 Wake Up 03_S\0 Wake Up 04\0 Wake Up 04_S\0 Wake Up 05\0 Wake Up 05_S\0 Wake Up 06\0 Wake Up 06_S\0 Wake Up 07\0 Wake Up 07_S\0 Wake Up 08\0 Wake Up 08_S\0 Wake Up 09\0 Wake Up 09_S\0 Wake Up 10\0 Wake Up 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Hustle < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Hustle; };

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

    technique Hustle_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}