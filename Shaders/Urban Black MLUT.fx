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
	#define fLUT_TextureName "Urban Black MLUT.png"
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

namespace MLUT_MultiLUT_Urban_Black
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=100;
		ui_items=" Flaming 01\0 Flaming 01_S\0 Flaming 02\0 Flaming 02_S\0 Flaming 03\0 Flaming 03_S\0 Flaming 04\0 Flaming 04_S\0 Flaming 05\0 Flaming 05_S\0 Flaming 06\0 Flaming 06_S\0 Flaming 07\0 Flaming 07_S\0 Flaming 08\0 Flaming 08_S\0 Flaming 09\0 Flaming 09_S\0 Flaming 10\0 Flaming 10_S\0 Indigo 01\0 Indigo 01_S\0 Indigo 02\0 Indigo 02_S\0 Indigo 03\0 Indigo 03_S\0 Indigo 04\0 Indigo 04_S\0 Indigo 05\0 Indigo 05_S\0 Indigo 06\0 Indigo 06_S\0 Indigo 07\0 Indigo 07_S\0 Indigo 08\0 Indigo 08_S\0 Indigo 09\0 Indigo 09_S\0 Indigo 10\0 Indigo 10_S\0 Lemon 01\0 Lemon 01_S\0 Lemon 02\0 Lemon 02_S\0 Lemon 03\0 Lemon 03_S\0 Lemon 04\0 Lemon 04_S\0 Lemon 05\0 Lemon 05_S\0 Lemon 06\0 Lemon 06_S\0 Lemon 07\0 Lemon 07_S\0 Lemon 08\0 Lemon 08_S\0 Lemon 09\0 Lemon 09_S\0 Lemon 10\0 Lemon 10_S\0 Minty 01\0 Minty 01_S\0 Minty 02\0 Minty 02_S\0 Minty 03\0 Minty 03_S\0 Minty 04\0 Minty 04_S\0 Minty 05\0 Minty 05_S\0 Minty 06\0 Minty 06_S\0 Minty 07\0 Minty 07_S\0 Minty 08\0 Minty 08_S\0 Minty 09\0 Minty 09_S\0 Minty 10\0 Minty 10_S\0 Supreme 01\0 Supreme 01_S\0 Supreme 02\0 Supreme 02_S\0 Supreme 03\0 Supreme 03_S\0 Supreme 04\0 Supreme 04_S\0 Supreme 05\0 Supreme 05_S\0 Supreme 06\0 Supreme 06_S\0 Supreme 07\0 Supreme 07_S\0 Supreme 08\0 Supreme 08_S\0 Supreme 09\0 Supreme 09_S\0 Supreme 10\0 Supreme 10_S\0";
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

    texture texMultiLUT_MLUT_Urban_Black < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_Urban_Black; };

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

    technique Urban_Black_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}