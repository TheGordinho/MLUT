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
	#define fLUT_TextureName "California Vibe MLUT.png"
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

namespace MLUT_MultiLUT_California_Vibe
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Los Angeles 01\0 Los Angeles 01_S\0 Los Angeles 02\0 Los Angeles 02_S\0 Los Angeles 03\0 Los Angeles 03_S\0 Los Angeles 04\0 Los Angeles 04_S\0 Los Angeles 05\0 Los Angeles 05_S\0 Los Angeles 06\0 Los Angeles 06_S\0 Los Angeles 07\0 Los Angeles 07_S\0 Los Angeles 08\0 Los Angeles 08_S\0 Los Angeles 09\0 Los Angeles 09_S\0 Los Angeles 10\0 Los Angeles 10_S\0 San Diego 01\0 San Diego 01_S\0 San Diego 02\0 San Diego 02_S\0 San Diego 03\0 San Diego 03_S\0 San Diego 04\0 San Diego 04_S\0 San Diego 05\0 San Diego 05_S\0 San Diego 06\0 San Diego 06_S\0 San Diego 07\0 San Diego 07_S\0 San Diego 08\0 San Diego 08_S\0 San Diego 09\0 San Diego 09_S\0 San Diego 10\0 San Diego 10_S\0 San Francisco 01\0 San Francisco 01_S\0 San Francisco 02\0 San Francisco 02_S\0 San Francisco 03\0 San Francisco 03_S\0 San Francisco 04\0 San Francisco 04_S\0 San Francisco 05\0 San Francisco 05_S\0 San Francisco 06\0 San Francisco 06_S\0 San Francisco 07\0 San Francisco 07_S\0 San Francisco 08\0 San Francisco 08_S\0 San Francisco 09\0 San Francisco 09_S\0 San Francisco 10\0 San Francisco 10_S\0 Santa Barbara 01\0 Santa Barbara 01_S\0 Santa Barbara 02\0 Santa Barbara 02_S\0 Santa Barbara 03\0 Santa Barbara 03_S\0 Santa Barbara 04\0 Santa Barbara 04_S\0 Santa Barbara 05\0 Santa Barbara 05_S\0 Santa Barbara 06\0 Santa Barbara 06_S\0 Santa Barbara 07\0 Santa Barbara 07_S\0 Santa Barbara 08\0 Santa Barbara 08_S\0 Santa Barbara 09\0 Santa Barbara 09_S\0 Santa Barbara 10\0 Santa Barbara 10_S\0 Santa Monica 01\0 Santa Monica 01_S\0 Santa Monica 02\0 Santa Monica 02_S\0 Santa Monica 03\0 Santa Monica 03_S\0 Santa Monica 04\0 Santa Monica 04_S\0 Santa Monica 05\0 Santa Monica 05_S\0 Santa Monica 06\0 Santa Monica 06_S\0 Santa Monica 07\0 Santa Monica 07_S\0 Santa Monica 08\0 Santa Monica 08_S\0 Santa Monica 09\0 Santa Monica 09_S\0 Santa Monica 10\0 Santa Monica 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_California_Vibe < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_California_Vibe; };

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

    technique California_Vibe
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}