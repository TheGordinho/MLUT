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
	#define fLUT_TextureName "Traditional Wedding MLUT.png"
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

namespace MLUT_MultiLUT_Traditional_Wedding
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Airy 01\0 Airy 01_S\0 Airy 02\0 Airy 02_S\0 Airy 03\0 Airy 03_S\0 Airy 04\0 Airy 04_S\0 Airy 05\0 Airy 05_S\0 Airy 06\0 Airy 06_S\0 Airy 07\0 Airy 07_S\0 Airy 08\0 Airy 08_S\0 Airy 09\0 Airy 09_S\0 Airy 10\0 Airy 10_S\0 Bohemian 01\0 Bohemian 01_S\0 Bohemian 02\0 Bohemian 02_S\0 Bohemian 03\0 Bohemian 03_S\0 Bohemian 04\0 Bohemian 04_S\0 Bohemian 05\0 Bohemian 05_S\0 Bohemian 06\0 Bohemian 06_S\0 Bohemian 07\0 Bohemian 07_S\0 Bohemian 08\0 Bohemian 08_S\0 Bohemian 09\0 Bohemian 09_S\0 Bohemian 10\0 Bohemian 10_S\0 Chocolate 01\0 Chocolate 01_S\0 Chocolate 02\0 Chocolate 02_S\0 Chocolate 03\0 Chocolate 03_S\0 Chocolate 04\0 Chocolate 04_S\0 Chocolate 05\0 Chocolate 05_S\0 Chocolate 06\0 Chocolate 06_S\0 Chocolate 07\0 Chocolate 07_S\0 Chocolate 08\0 Chocolate 08_S\0 Chocolate 09\0 Chocolate 09_S\0 Chocolate 10\0 Chocolate 10_S\0 Film 01\0 Film 01_S\0 Film 02\0 Film 02_S\0 Film 03\0 Film 03_S\0 Film 04\0 Film 04_S\0 Film 05\0 Film 05_S\0 Film 06\0 Film 06_S\0 Film 07\0 Film 07_S\0 Film 08\0 Film 08_S\0 Film 09\0 Film 09_S\0 Film 10\0 Film 10_S\0 Urban 01\0 Urban 01_S\0 Urban 02\0 Urban 02_S\0 Urban 03\0 Urban 03_S\0 Urban 04\0 Urban 04_S\0 Urban 05\0 Urban 05_S\0 Urban 06\0 Urban 06_S\0 Urban 07\0 Urban 07_S\0 Urban 08\0 Urban 08_S\0 Urban 09\0 Urban 09_S\0 Urban 10\0 Urban 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Traditional_Wedding < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Traditional_Wedding; };

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

    technique Traditional_Wedding_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}