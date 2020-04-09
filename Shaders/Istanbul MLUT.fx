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
	#define fLUT_TextureName "Istanbul MLUT.png"
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

namespace MLUT_MultiLUT_Istanbul
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Bazaar 01\0 Bazaar 01_S\0 Bazaar 02\0 Bazaar 02_S\0 Bazaar 03\0 Bazaar 03_S\0 Bazaar 04\0 Bazaar 04_S\0 Bazaar 05\0 Bazaar 05_S\0 Bazaar 06\0 Bazaar 06_S\0 Bazaar 07\0 Bazaar 07_S\0 Bazaar 08\0 Bazaar 08_S\0 Bazaar 09\0 Bazaar 09_S\0 Bazaar 10\0 Bazaar 10_S\0 Belgrad 01\0 Belgrad 01_S\0 Belgrad 02\0 Belgrad 02_S\0 Belgrad 03\0 Belgrad 03_S\0 Belgrad 04\0 Belgrad 04_S\0 Belgrad 05\0 Belgrad 05_S\0 Belgrad 06\0 Belgrad 06_S\0 Belgrad 07\0 Belgrad 07_S\0 Belgrad 08\0 Belgrad 08_S\0 Belgrad 09\0 Belgrad 09_S\0 Belgrad 10\0 Belgrad 10_S\0 Galata 01\0 Galata 01_S\0 Galata 02\0 Galata 02_S\0 Galata 03\0 Galata 03_S\0 Galata 04\0 Galata 04_S\0 Galata 05\0 Galata 05_S\0 Galata 06\0 Galata 06_S\0 Galata 07\0 Galata 07_S\0 Galata 08\0 Galata 08_S\0 Galata 09\0 Galata 09_S\0 Galata 10\0 Galata 10_S\0 Simit 01\0 Simit 01_S\0 Simit 02\0 Simit 02_S\0 Simit 03\0 Simit 03_S\0 Simit 04\0 Simit 04_S\0 Simit 05\0 Simit 05_S\0 Simit 06\0 Simit 06_S\0 Simit 07\0 Simit 07_S\0 Simit 08\0 Simit 08_S\0 Simit 09\0 Simit 09_S\0 Simit 10\0 Simit 10_S\0 Taksim 01\0 Taksim 01_S\0 Taksim 02\0 Taksim 02_S\0 Taksim 03\0 Taksim 03_S\0 Taksim 04\0 Taksim 04_S\0 Taksim 05\0 Taksim 05_S\0 Taksim 06\0 Taksim 06_S\0 Taksim 07\0 Taksim 07_S\0 Taksim 08\0 Taksim 08_S\0 Taksim 09\0 Taksim 09_S\0 Taksim 10\0 Taksim 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Istanbul < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Istanbul; };

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

    technique Istanbul_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}