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
	#define fLUT_TextureName "Desolated Cinematic MLUT.png"
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

namespace MLUT_MultiLUT_Desolated_Cinematic
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=100;
		ui_items=" Battlefield 01\0 Battlefield 01_S\0 Battlefield 02\0 Battlefield 02_S\0 Battlefield 03\0 Battlefield 03_S\0 Battlefield 04\0 Battlefield 04_S\0 Battlefield 05\0 Battlefield 05_S\0 Battlefield 06\0 Battlefield 06_S\0 Battlefield 07\0 Battlefield 07_S\0 Battlefield 08\0 Battlefield 08_S\0 Battlefield 09\0 Battlefield 09_S\0 Battlefield 10\0 Battlefield 10_S\0 Island 01\0 Island 01_S\0 Island 02\0 Island 02_S\0 Island 03\0 Island 03_S\0 Island 04\0 Island 04_S\0 Island 05\0 Island 05_S\0 Island 06\0 Island 06_S\0 Island 07\0 Island 07_S\0 Island 08\0 Island 08_S\0 Island 09\0 Island 09_S\0 Island 10\0 Island 10_S\0 Poppy Field 01\0 Poppy Field 01_S\0 Poppy Field 02\0 Poppy Field 02_S\0 Poppy Field 03\0 Poppy Field 03_S\0 Poppy Field 04\0 Poppy Field 04_S\0 Poppy Field 05\0 Poppy Field 05_S\0 Poppy Field 06\0 Poppy Field 06_S\0 Poppy Field 07\0 Poppy Field 07_S\0 Poppy Field 08\0 Poppy Field 08_S\0 Poppy Field 09\0 Poppy Field 09_S\0 Poppy Field 10\0 Poppy Field 10_S\0 Prison 01\0 Prison 01_S\0 Prison 02\0 Prison 02_S\0 Prison 03\0 Prison 03_S\0 Prison 04\0 Prison 04_S\0 Prison 05\0 Prison 05_S\0 Prison 06\0 Prison 06_S\0 Prison 07\0 Prison 07_S\0 Prison 08\0 Prison 08_S\0 Prison 09\0 Prison 09_S\0 Prison 10\0 Prison 10_S\0 Storm 01\0 Storm 01_S\0 Storm 02\0 Storm 02_S\0 Storm 03\0 Storm 03_S\0 Storm 04\0 Storm 04_S\0 Storm 05\0 Storm 05_S\0 Storm 06\0 Storm 06_S\0 Storm 07\0 Storm 07_S\0 Storm 08\0 Storm 08_S\0 Storm 09\0 Storm 09_S\0 Storm 10\0 Storm 10_S\0";
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

    texture texMultiLUT_MLUT_Desolated_Cinematic < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_Desolated_Cinematic; };

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

    technique Desolated_Cinematic_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}