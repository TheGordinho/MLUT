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
	#define fLUT_TextureName "Epic Iceland MLUT.png"
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

namespace MLUT_MultiLUT_Epic_Iceland
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Aurora 01\0 Aurora 01_S\0 Aurora 02\0 Aurora 02_S\0 Aurora 03\0 Aurora 03_S\0 Aurora 04\0 Aurora 04_S\0 Aurora 05\0 Aurora 05_S\0 Aurora 06\0 Aurora 06_S\0 Aurora 07\0 Aurora 07_S\0 Aurora 08\0 Aurora 08_S\0 Aurora 09\0 Aurora 09_S\0 Aurora 10\0 Aurora 10_S\0 Blue Lagoon 01\0 Blue Lagoon 01_S\0 Blue Lagoon 02\0 Blue Lagoon 02_S\0 Blue Lagoon 03\0 Blue Lagoon 03_S\0 Blue Lagoon 04\0 Blue Lagoon 04_S\0 Blue Lagoon 05\0 Blue Lagoon 05_S\0 Blue Lagoon 06\0 Blue Lagoon 06_S\0 Blue Lagoon 07\0 Blue Lagoon 07_S\0 Blue Lagoon 08\0 Blue Lagoon 08_S\0 Blue Lagoon 09\0 Blue Lagoon 09_S\0 Blue Lagoon 10\0 Blue Lagoon 10_S\0 Seljalandsfoss 01\0 Seljalandsfoss 01_S\0 Seljalandsfoss 02\0 Seljalandsfoss 02_S\0 Seljalandsfoss 03\0 Seljalandsfoss 03_S\0 Seljalandsfoss 04\0 Seljalandsfoss 04_S\0 Seljalandsfoss 05\0 Seljalandsfoss 05_S\0 Seljalandsfoss 06\0 Seljalandsfoss 06_S\0 Seljalandsfoss 07\0 Seljalandsfoss 07_S\0 Seljalandsfoss 08\0 Seljalandsfoss 08_S\0 Seljalandsfoss 09\0 Seljalandsfoss 09_S\0 Seljalandsfoss 10\0 Seljalandsfoss 10_S\0 Sunrise 01\0 Sunrise 01_S\0 Sunrise 02\0 Sunrise 02_S\0 Sunrise 03\0 Sunrise 03_S\0 Sunrise 04\0 Sunrise 04_S\0 Sunrise 05\0 Sunrise 05_S\0 Sunrise 06\0 Sunrise 06_S\0 Sunrise 07\0 Sunrise 07_S\0 Sunrise 08\0 Sunrise 08_S\0 Sunrise 09\0 Sunrise 09_S\0 Sunrise 10\0 Sunrise 10_S\0 Vestrahorn 01\0 Vestrahorn 01_S\0 Vestrahorn 02\0 Vestrahorn 02_S\0 Vestrahorn 03\0 Vestrahorn 03_S\0 Vestrahorn 04\0 Vestrahorn 04_S\0 Vestrahorn 05\0 Vestrahorn 05_S\0 Vestrahorn 06\0 Vestrahorn 06_S\0 Vestrahorn 07\0 Vestrahorn 07_S\0 Vestrahorn 08\0 Vestrahorn 08_S\0 Vestrahorn 09\0 Vestrahorn 09_S\0 Vestrahorn 10\0 Vestrahorn 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Epic_Iceland < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Epic_Iceland; };

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

    technique Epic_Iceland_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}