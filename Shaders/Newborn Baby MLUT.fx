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
	#define fLUT_TextureName "Newborn Baby MLUT.png"
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

namespace MLUT_MultiLUT_Newborn_Baby
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Baby Blue and Pink 01\0 Baby Blue and Pink 01_S\0 Baby Blue and Pink 02\0 Baby Blue and Pink 02_S\0 Baby Blue and Pink 03\0 Baby Blue and Pink 03_S\0 Baby Blue and Pink 04\0 Baby Blue and Pink 04_S\0 Baby Blue and Pink 05\0 Baby Blue and Pink 05_S\0 Baby Blue and Pink 06\0 Baby Blue and Pink 06_S\0 Baby Blue and Pink 07\0 Baby Blue and Pink 07_S\0 Baby Blue and Pink 08\0 Baby Blue and Pink 08_S\0 Baby Blue and Pink 09\0 Baby Blue and Pink 09_S\0 Baby Blue and Pink 10\0 Baby Blue and Pink 10_S\0 Clean Tones 01\0 Clean Tones 01_S\0 Clean Tones 02\0 Clean Tones 02_S\0 Clean Tones 03\0 Clean Tones 03_S\0 Clean Tones 04\0 Clean Tones 04_S\0 Clean Tones 05\0 Clean Tones 05_S\0 Clean Tones 06\0 Clean Tones 06_S\0 Clean Tones 07\0 Clean Tones 07_S\0 Clean Tones 08\0 Clean Tones 08_S\0 Clean Tones 09\0 Clean Tones 09_S\0 Clean Tones 10\0 Clean Tones 10_S\0 Cream 01\0 Cream 01_S\0 Cream 02\0 Cream 02_S\0 Cream 03\0 Cream 03_S\0 Cream 04\0 Cream 04_S\0 Cream 05\0 Cream 05_S\0 Cream 06\0 Cream 06_S\0 Cream 07\0 Cream 07_S\0 Cream 08\0 Cream 08_S\0 Cream 09\0 Cream 09_S\0 Cream 10\0 Cream 10_S\0 Film Soft 01\0 Film Soft 01_S\0 Film Soft 02\0 Film Soft 02_S\0 Film Soft 03\0 Film Soft 03_S\0 Film Soft 04\0 Film Soft 04_S\0 Film Soft 05\0 Film Soft 05_S\0 Film Soft 06\0 Film Soft 06_S\0 Film Soft 07\0 Film Soft 07_S\0 Film Soft 08\0 Film Soft 08_S\0 Film Soft 09\0 Film Soft 09_S\0 Film Soft 10\0 Film Soft 10_S\0 Lifestyle 01\0 Lifestyle 01_S\0 Lifestyle 02\0 Lifestyle 02_S\0 Lifestyle 03\0 Lifestyle 03_S\0 Lifestyle 04\0 Lifestyle 04_S\0 Lifestyle 05\0 Lifestyle 05_S\0 Lifestyle 06\0 Lifestyle 06_S\0 Lifestyle 07\0 Lifestyle 07_S\0 Lifestyle 08\0 Lifestyle 08_S\0 Lifestyle 09\0 Lifestyle 09_S\0 Lifestyle 10\0 Lifestyle 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Newborn_Baby < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Newborn_Baby; };

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

    technique Newborn_Baby_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}