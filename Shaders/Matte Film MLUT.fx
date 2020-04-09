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
	#define fLUT_TextureName "Matte Film MLUT.png"
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

namespace MLUT_MultiLUT_Matte_Film
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Airy 01\0 Airy 01_S\0 Airy 02\0 Airy 02_S\0 Airy 03\0 Airy 03_S\0 Airy 04\0 Airy 04_S\0 Airy 05\0 Airy 05_S\0 Airy 06\0 Airy 06_S\0 Airy 07\0 Airy 07_S\0 Airy 08\0 Airy 08_S\0 Airy 09\0 Airy 09_S\0 Airy 10\0 Airy 10_S\0 Influencer 01\0 Influencer 01_S\0 Influencer 02\0 Influencer 02_S\0 Influencer 03\0 Influencer 03_S\0 Influencer 04\0 Influencer 04_S\0 Influencer 05\0 Influencer 05_S\0 Influencer 06\0 Influencer 06_S\0 Influencer 07\0 Influencer 07_S\0 Influencer 08\0 Influencer 08_S\0 Influencer 09\0 Influencer 09_S\0 Influencer 10\0 Influencer 10_S\0 K Chrome 01\0 K Chrome 01_S\0 K Chrome 02\0 K Chrome 02_S\0 K Chrome 03\0 K Chrome 03_S\0 K Chrome 04\0 K Chrome 04_S\0 K Chrome 05\0 K Chrome 05_S\0 K Chrome 06\0 K Chrome 06_S\0 K Chrome 07\0 K Chrome 07_S\0 K Chrome 08\0 K Chrome 08_S\0 K Chrome 09\0 K Chrome 09_S\0 K Chrome 10\0 K Chrome 10_S\0 Tungsten 01\0 Tungsten 01_S\0 Tungsten 02\0 Tungsten 02_S\0 Tungsten 03\0 Tungsten 03_S\0 Tungsten 04\0 Tungsten 04_S\0 Tungsten 05\0 Tungsten 05_S\0 Tungsten 06\0 Tungsten 06_S\0 Tungsten 07\0 Tungsten 07_S\0 Tungsten 08\0 Tungsten 08_S\0 Tungsten 09\0 Tungsten 09_S\0 Tungsten 10\0 Tungsten 10_S\0 XProc 01\0 XProc 01_S\0 XProc 02\0 XProc 02_S\0 XProc 03\0 XProc 03_S\0 XProc 04\0 XProc 04_S\0 XProc 05\0 XProc 05_S\0 XProc 06\0 XProc 06_S\0 XProc 07\0 XProc 07_S\0 XProc 08\0 XProc 08_S\0 XProc 09\0 XProc 09_S\0 XProc 10\0 XProc 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Matte_Film < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Matte_Film; };

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

    technique Matte_Film_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}