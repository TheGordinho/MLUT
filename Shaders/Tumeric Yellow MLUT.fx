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
	#define fLUT_TextureName "Tumeric Yellow MLUT.png"
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

namespace MLUT_MultiLUT_Tumeric_Yellow
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=100;
		ui_items=" Curcumin 01\0 Curcumin 01_S\0 Curcumin 02\0 Curcumin 02_S\0 Curcumin 03\0 Curcumin 03_S\0 Curcumin 04\0 Curcumin 04_S\0 Curcumin 05\0 Curcumin 05_S\0 Curcumin 06\0 Curcumin 06_S\0 Curcumin 07\0 Curcumin 07_S\0 Curcumin 08\0 Curcumin 08_S\0 Curcumin 09\0 Curcumin 09_S\0 Curcumin 10\0 Curcumin 10_S\0 Ginger 01\0 Ginger 01_S\0 Ginger 02\0 Ginger 02_S\0 Ginger 03\0 Ginger 03_S\0 Ginger 04\0 Ginger 04_S\0 Ginger 05\0 Ginger 05_S\0 Ginger 06\0 Ginger 06_S\0 Ginger 07\0 Ginger 07_S\0 Ginger 08\0 Ginger 08_S\0 Ginger 09\0 Ginger 09_S\0 Ginger 10\0 Ginger 10_S\0 Lemon 01\0 Lemon 01_S\0 Lemon 02\0 Lemon 02_S\0 Lemon 03\0 Lemon 03_S\0 Lemon 04\0 Lemon 04_S\0 Lemon 05\0 Lemon 05_S\0 Lemon 06\0 Lemon 06_S\0 Lemon 07\0 Lemon 07_S\0 Lemon 08\0 Lemon 08_S\0 Lemon 09\0 Lemon 09_S\0 Lemon 10\0 Lemon 10_S\0 Milk 01\0 Milk 01_S\0 Milk 02\0 Milk 02_S\0 Milk 03\0 Milk 03_S\0 Milk 04\0 Milk 04_S\0 Milk 05\0 Milk 05_S\0 Milk 06\0 Milk 06_S\0 Milk 07\0 Milk 07_S\0 Milk 08\0 Milk 08_S\0 Milk 09\0 Milk 09_S\0 Milk 10\0 Milk 10_S\0 Root 01\0 Root 01_S\0 Root 02\0 Root 02_S\0 Root 03\0 Root 03_S\0 Root 04\0 Root 04_S\0 Root 05\0 Root 05_S\0 Root 06\0 Root 06_S\0 Root 07\0 Root 07_S\0 Root 08\0 Root 08_S\0 Root 09\0 Root 09_S\0 Root 10\0 Root 10_S\0";
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

    texture texMultiLUT_MLUT_Tumeric_Yellow < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_Tumeric_Yellow; };

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

    technique Tumeric_Yellow_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}