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
	#define fLUT_TextureName "Painting Tones MLUT.png"
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

namespace MLUT_MultiLUT_Painting_Tones
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=100;
		ui_items=" Mona Lisa 01\0 Mona Lisa 01_S\0 Mona Lisa 02\0 Mona Lisa 02_S\0 Mona Lisa 03\0 Mona Lisa 03_S\0 Mona Lisa 04\0 Mona Lisa 04_S\0 Mona Lisa 05\0 Mona Lisa 05_S\0 Mona Lisa 06\0 Mona Lisa 06_S\0 Mona Lisa 07\0 Mona Lisa 07_S\0 Mona Lisa 08\0 Mona Lisa 08_S\0 Mona Lisa 09\0 Mona Lisa 09_S\0 Mona Lisa 10\0 Mona Lisa 10_S\0 Night Watch 01\0 Night Watch 01_S\0 Night Watch 02\0 Night Watch 02_S\0 Night Watch 03\0 Night Watch 03_S\0 Night Watch 04\0 Night Watch 04_S\0 Night Watch 05\0 Night Watch 05_S\0 Night Watch 06\0 Night Watch 06_S\0 Night Watch 07\0 Night Watch 07_S\0 Night Watch 08\0 Night Watch 08_S\0 Night Watch 09\0 Night Watch 09_S\0 Night Watch 10\0 Night Watch 10_S\0 Nighthawks 01\0 Nighthawks 01_S\0 Nighthawks 02\0 Nighthawks 02_S\0 Nighthawks 03\0 Nighthawks 03_S\0 Nighthawks 04\0 Nighthawks 04_S\0 Nighthawks 05\0 Nighthawks 05_S\0 Nighthawks 06\0 Nighthawks 06_S\0 Nighthawks 07\0 Nighthawks 07_S\0 Nighthawks 08\0 Nighthawks 08_S\0 Nighthawks 09\0 Nighthawks 09_S\0 Nighthawks 10\0 Nighthawks 10_S\0 Persistence of Memory 01\0 Persistence of Memory 01_S\0 Persistence of Memory 02\0 Persistence of Memory 02_S\0 Persistence of Memory 03\0 Persistence of Memory 03_S\0 Persistence of Memory 04\0 Persistence of Memory 04_S\0 Persistence of Memory 05\0 Persistence of Memory 05_S\0 Persistence of Memory 06\0 Persistence of Memory 06_S\0 Persistence of Memory 07\0 Persistence of Memory 07_S\0 Persistence of Memory 08\0 Persistence of Memory 08_S\0 Persistence of Memory 09\0 Persistence of Memory 09_S\0 Persistence of Memory 10\0 Persistence of Memory 10_S\0 Starry Night 01\0 Starry Night 01_S\0 Starry Night 02\0 Starry Night 02_S\0 Starry Night 03\0 Starry Night 03_S\0 Starry Night 04\0 Starry Night 04_S\0 Starry Night 05\0 Starry Night 05_S\0 Starry Night 06\0 Starry Night 06_S\0 Starry Night 07\0 Starry Night 07_S\0 Starry Night 08\0 Starry Night 08_S\0 Starry Night 09\0 Starry Night 09_S\0 Starry Night 10\0 Starry Night 10_S\0";
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

    texture texMultiLUT_MLUT_Painting_Tones < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_Painting_Tones; };

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

    technique Painting_Tones_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}