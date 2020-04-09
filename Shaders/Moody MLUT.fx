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
	#define fLUT_TextureName "Moody MLUT.png"
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

namespace MLUT_MultiLUT_Moody
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Autumn 01\0 Autumn 01_S\0 Autumn 02\0 Autumn 02_S\0 Autumn 03\0 Autumn 03_S\0 Autumn 04\0 Autumn 04_S\0 Autumn 05\0 Autumn 05_S\0 Autumn 06\0 Autumn 06_S\0 Autumn 07\0 Autumn 07_S\0 Autumn 08\0 Autumn 08_S\0 Autumn 09\0 Autumn 09_S\0 Autumn 10\0 Autumn 10_S\0 Foggy Morning 01\0 Foggy Morning 01_S\0 Foggy Morning 02\0 Foggy Morning 02_S\0 Foggy Morning 03\0 Foggy Morning 03_S\0 Foggy Morning 04\0 Foggy Morning 04_S\0 Foggy Morning 05\0 Foggy Morning 05_S\0 Foggy Morning 06\0 Foggy Morning 06_S\0 Foggy Morning 07\0 Foggy Morning 07_S\0 Foggy Morning 08\0 Foggy Morning 08_S\0 Foggy Morning 09\0 Foggy Morning 09_S\0 Foggy Morning 10\0 Foggy Morning 10_S\0 Honey 01\0 Honey 01_S\0 Honey 02\0 Honey 02_S\0 Honey 03\0 Honey 03_S\0 Honey 04\0 Honey 04_S\0 Honey 05\0 Honey 05_S\0 Honey 06\0 Honey 06_S\0 Honey 07\0 Honey 07_S\0 Honey 08\0 Honey 08_S\0 Honey 09\0 Honey 09_S\0 Honey 10\0 Honey 10_S\0 Midnight Dark 01\0 Midnight Dark 01_S\0 Midnight Dark 02\0 Midnight Dark 02_S\0 Midnight Dark 03\0 Midnight Dark 03_S\0 Midnight Dark 04\0 Midnight Dark 04_S\0 Midnight Dark 05\0 Midnight Dark 05_S\0 Midnight Dark 06\0 Midnight Dark 06_S\0 Midnight Dark 07\0 Midnight Dark 07_S\0 Midnight Dark 08\0 Midnight Dark 08_S\0 Midnight Dark 09\0 Midnight Dark 09_S\0 Midnight Dark 10\0 Midnight Dark 10_S\0 Warm Daylight 01\0 Warm Daylight 01_S\0 Warm Daylight 02\0 Warm Daylight 02_S\0 Warm Daylight 03\0 Warm Daylight 03_S\0 Warm Daylight 04\0 Warm Daylight 04_S\0 Warm Daylight 05\0 Warm Daylight 05_S\0 Warm Daylight 06\0 Warm Daylight 06_S\0 Warm Daylight 07\0 Warm Daylight 07_S\0 Warm Daylight 08\0 Warm Daylight 08_S\0 Warm Daylight 09\0 Warm Daylight 09_S\0 Warm Daylight 10\0 Warm Daylight 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Moody < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Moody; };

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

    technique Moody_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}