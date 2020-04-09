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
	#define fLUT_TextureName "Illuminate MLUT.png"
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

namespace MLUT_MultiLUT_Illuminate
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Cyberpunk 01\0 Cyberpunk 01_S\0 Cyberpunk 02\0 Cyberpunk 02_S\0 Cyberpunk 03\0 Cyberpunk 03_S\0 Cyberpunk 04\0 Cyberpunk 04_S\0 Cyberpunk 05\0 Cyberpunk 05_S\0 Cyberpunk 06\0 Cyberpunk 06_S\0 Cyberpunk 07\0 Cyberpunk 07_S\0 Cyberpunk 08\0 Cyberpunk 08_S\0 Cyberpunk 09\0 Cyberpunk 09_S\0 Cyberpunk 10\0 Cyberpunk 10_S\0 Journey 01\0 Journey 01_S\0 Journey 02\0 Journey 02_S\0 Journey 03\0 Journey 03_S\0 Journey 04\0 Journey 04_S\0 Journey 05\0 Journey 05_S\0 Journey 06\0 Journey 06_S\0 Journey 07\0 Journey 07_S\0 Journey 08\0 Journey 08_S\0 Journey 09\0 Journey 09_S\0 Journey 10\0 Journey 10_S\0 Rosey Mint 01\0 Rosey Mint 01_S\0 Rosey Mint 02\0 Rosey Mint 02_S\0 Rosey Mint 03\0 Rosey Mint 03_S\0 Rosey Mint 04\0 Rosey Mint 04_S\0 Rosey Mint 05\0 Rosey Mint 05_S\0 Rosey Mint 06\0 Rosey Mint 06_S\0 Rosey Mint 07\0 Rosey Mint 07_S\0 Rosey Mint 08\0 Rosey Mint 08_S\0 Rosey Mint 09\0 Rosey Mint 09_S\0 Rosey Mint 10\0 Rosey Mint 10_S\0 Stock 01\0 Stock 01_S\0 Stock 02\0 Stock 02_S\0 Stock 03\0 Stock 03_S\0 Stock 04\0 Stock 04_S\0 Stock 05\0 Stock 05_S\0 Stock 06\0 Stock 06_S\0 Stock 07\0 Stock 07_S\0 Stock 08\0 Stock 08_S\0 Stock 09\0 Stock 09_S\0 Stock 10\0 Stock 10_S\0 Urbanized 01\0 Urbanized 01_S\0 Urbanized 02\0 Urbanized 02_S\0 Urbanized 03\0 Urbanized 03_S\0 Urbanized 04\0 Urbanized 04_S\0 Urbanized 05\0 Urbanized 05_S\0 Urbanized 06\0 Urbanized 06_S\0 Urbanized 07\0 Urbanized 07_S\0 Urbanized 08\0 Urbanized 08_S\0 Urbanized 09\0 Urbanized 09_S\0 Urbanized 10\0 Urbanized 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Illuminate < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Illuminate; };

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

    technique Illuminate_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}