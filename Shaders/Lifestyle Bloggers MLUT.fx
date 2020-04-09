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
	#define fLUT_TextureName "Lifestyle Bloggers MLUT.png"
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

namespace MLUT_MultiLUT_Lifestyle_Bloggers
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Airy 01\0 Airy 01_S\0 Airy 02\0 Airy 02_S\0 Airy 03\0 Airy 03_S\0 Airy 04\0 Airy 04_S\0 Airy 05\0 Airy 05_S\0 Airy 06\0 Airy 06_S\0 Airy 07\0 Airy 07_S\0 Airy 08\0 Airy 08_S\0 Airy 09\0 Airy 09_S\0 Airy 10\0 Airy 10_S\0 Clean 01\0 Clean 01_S\0 Clean 02\0 Clean 02_S\0 Clean 03\0 Clean 03_S\0 Clean 04\0 Clean 04_S\0 Clean 05\0 Clean 05_S\0 Clean 06\0 Clean 06_S\0 Clean 07\0 Clean 07_S\0 Clean 08\0 Clean 08_S\0 Clean 09\0 Clean 09_S\0 Clean 10\0 Clean 10_S\0 Gold 01\0 Gold 01_S\0 Gold 02\0 Gold 02_S\0 Gold 03\0 Gold 03_S\0 Gold 04\0 Gold 04_S\0 Gold 05\0 Gold 05_S\0 Gold 06\0 Gold 06_S\0 Gold 07\0 Gold 07_S\0 Gold 08\0 Gold 08_S\0 Gold 09\0 Gold 09_S\0 Gold 10\0 Gold 10_S\0 Insta 01\0 Insta 01_S\0 Insta 02\0 Insta 02_S\0 Insta 03\0 Insta 03_S\0 Insta 04\0 Insta 04_S\0 Insta 05\0 Insta 05_S\0 Insta 06\0 Insta 06_S\0 Insta 07\0 Insta 07_S\0 Insta 08\0 Insta 08_S\0 Insta 09\0 Insta 09_S\0 Insta 10\0 Insta 10_S\0 Summer 01\0 Summer 01_S\0 Summer 02\0 Summer 02_S\0 Summer 03\0 Summer 03_S\0 Summer 04\0 Summer 04_S\0 Summer 05\0 Summer 05_S\0 Summer 06\0 Summer 06_S\0 Summer 07\0 Summer 07_S\0 Summer 08\0 Summer 08_S\0 Summer 09\0 Summer 09_S\0 Summer 10\0 Summer 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Lifestyle_Bloggers < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Lifestyle_Bloggers; };

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

    technique Lifestyle_Bloggers_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}