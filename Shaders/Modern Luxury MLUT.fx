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
	#define fLUT_TextureName "Modern Luxury MLUT.png"
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

namespace MLUT_MultiLUT_Modern_Luxury
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Deco 01\0 Deco 01_S\0 Deco 02\0 Deco 02_S\0 Deco 03\0 Deco 03_S\0 Deco 04\0 Deco 04_S\0 Deco 05\0 Deco 05_S\0 Deco 06\0 Deco 06_S\0 Deco 07\0 Deco 07_S\0 Deco 08\0 Deco 08_S\0 Deco 09\0 Deco 09_S\0 Deco 10\0 Deco 10_S\0 Hierarchy 01\0 Hierarchy 01_S\0 Hierarchy 02\0 Hierarchy 02_S\0 Hierarchy 03\0 Hierarchy 03_S\0 Hierarchy 04\0 Hierarchy 04_S\0 Hierarchy 05\0 Hierarchy 05_S\0 Hierarchy 06\0 Hierarchy 06_S\0 Hierarchy 07\0 Hierarchy 07_S\0 Hierarchy 08\0 Hierarchy 08_S\0 Hierarchy 09\0 Hierarchy 09_S\0 Hierarchy 10\0 Hierarchy 10_S\0 Nouveau 01\0 Nouveau 01_S\0 Nouveau 02\0 Nouveau 02_S\0 Nouveau 03\0 Nouveau 03_S\0 Nouveau 04\0 Nouveau 04_S\0 Nouveau 05\0 Nouveau 05_S\0 Nouveau 06\0 Nouveau 06_S\0 Nouveau 07\0 Nouveau 07_S\0 Nouveau 08\0 Nouveau 08_S\0 Nouveau 09\0 Nouveau 09_S\0 Nouveau 10\0 Nouveau 10_S\0 Redefine 01\0 Redefine 01_S\0 Redefine 02\0 Redefine 02_S\0 Redefine 03\0 Redefine 03_S\0 Redefine 04\0 Redefine 04_S\0 Redefine 05\0 Redefine 05_S\0 Redefine 06\0 Redefine 06_S\0 Redefine 07\0 Redefine 07_S\0 Redefine 08\0 Redefine 08_S\0 Redefine 09\0 Redefine 09_S\0 Redefine 10\0 Redefine 10_S\0 Shine 01\0 Shine 01_S\0 Shine 02\0 Shine 02_S\0 Shine 03\0 Shine 03_S\0 Shine 04\0 Shine 04_S\0 Shine 05\0 Shine 05_S\0 Shine 06\0 Shine 06_S\0 Shine 07\0 Shine 07_S\0 Shine 08\0 Shine 08_S\0 Shine 09\0 Shine 09_S\0 Shine 10\0 Shine 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Modern_Luxury < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Modern_Luxury; };

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

    technique Modern_Luxury_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}