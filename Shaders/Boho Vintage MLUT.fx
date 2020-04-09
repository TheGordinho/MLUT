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
	#define fLUT_TextureName "Boho Vintage MLUT.png"
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

namespace MLUT_MultiLUT_Boho_Vintage
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Beach 01\0 Beach 01_S\0 Beach 02\0 Beach 02_S\0 Beach 03\0 Beach 03_S\0 Beach 04\0 Beach 04_S\0 Beach 05\0 Beach 05_S\0 Beach 06\0 Beach 06_S\0 Beach 07\0 Beach 07_S\0 Beach 08\0 Beach 08_S\0 Beach 09\0 Beach 09_S\0 Beach 10\0 Beach 10_S\0 Caramel 01\0 Caramel 01_S\0 Caramel 02\0 Caramel 02_S\0 Caramel 03\0 Caramel 03_S\0 Caramel 04\0 Caramel 04_S\0 Caramel 05\0 Caramel 05_S\0 Caramel 06\0 Caramel 06_S\0 Caramel 07\0 Caramel 07_S\0 Caramel 08\0 Caramel 08_S\0 Caramel 09\0 Caramel 09_S\0 Caramel 10\0 Caramel 10_S\0 Chic 01\0 Chic 01_S\0 Chic 02\0 Chic 02_S\0 Chic 03\0 Chic 03_S\0 Chic 04\0 Chic 04_S\0 Chic 05\0 Chic 05_S\0 Chic 06\0 Chic 06_S\0 Chic 07\0 Chic 07_S\0 Chic 08\0 Chic 08_S\0 Chic 09\0 Chic 09_S\0 Chic 10\0 Chic 10_S\0 Feather 01\0 Feather 01_S\0 Feather 02\0 Feather 02_S\0 Feather 03\0 Feather 03_S\0 Feather 04\0 Feather 04_S\0 Feather 05\0 Feather 05_S\0 Feather 06\0 Feather 06_S\0 Feather 07\0 Feather 07_S\0 Feather 08\0 Feather 08_S\0 Feather 09\0 Feather 09_S\0 Feather 10\0 Feather 10_S\0 Romper 01\0 Romper 01_S\0 Romper 02\0 Romper 02_S\0 Romper 03\0 Romper 03_S\0 Romper 04\0 Romper 04_S\0 Romper 05\0 Romper 05_S\0 Romper 06\0 Romper 06_S\0 Romper 07\0 Romper 07_S\0 Romper 08\0 Romper 08_S\0 Romper 09\0 Romper 09_S\0 Romper 10\0 Romper 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Boho_Vintage < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Boho_Vintage; };

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

    technique Boho_Vintage_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}