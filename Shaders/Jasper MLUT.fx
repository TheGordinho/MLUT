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
	#define fLUT_TextureName "Jasper MLUT.png"
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

namespace MLUT_MultiLUT_Jasper
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Athabasca 01\0 Athabasca 01_S\0 Athabasca 02\0 Athabasca 02_S\0 Athabasca 03\0 Athabasca 03_S\0 Athabasca 04\0 Athabasca 04_S\0 Athabasca 05\0 Athabasca 05_S\0 Athabasca 06\0 Athabasca 06_S\0 Athabasca 07\0 Athabasca 07_S\0 Athabasca 08\0 Athabasca 08_S\0 Athabasca 09\0 Athabasca 09_S\0 Athabasca 10\0 Athabasca 10_S\0 Geraldine 01\0 Geraldine 01_S\0 Geraldine 02\0 Geraldine 02_S\0 Geraldine 03\0 Geraldine 03_S\0 Geraldine 04\0 Geraldine 04_S\0 Geraldine 05\0 Geraldine 05_S\0 Geraldine 06\0 Geraldine 06_S\0 Geraldine 07\0 Geraldine 07_S\0 Geraldine 08\0 Geraldine 08_S\0 Geraldine 09\0 Geraldine 09_S\0 Geraldine 10\0 Geraldine 10_S\0 Maligne 01\0 Maligne 01_S\0 Maligne 02\0 Maligne 02_S\0 Maligne 03\0 Maligne 03_S\0 Maligne 04\0 Maligne 04_S\0 Maligne 05\0 Maligne 05_S\0 Maligne 06\0 Maligne 06_S\0 Maligne 07\0 Maligne 07_S\0 Maligne 08\0 Maligne 08_S\0 Maligne 09\0 Maligne 09_S\0 Maligne 10\0 Maligne 10_S\0 Miette 01\0 Miette 01_S\0 Miette 02\0 Miette 02_S\0 Miette 03\0 Miette 03_S\0 Miette 04\0 Miette 04_S\0 Miette 05\0 Miette 05_S\0 Miette 06\0 Miette 06_S\0 Miette 07\0 Miette 07_S\0 Miette 08\0 Miette 08_S\0 Miette 09\0 Miette 09_S\0 Miette 10\0 Miette 10_S\0 Pyramid 01\0 Pyramid 01_S\0 Pyramid 02\0 Pyramid 02_S\0 Pyramid 03\0 Pyramid 03_S\0 Pyramid 04\0 Pyramid 04_S\0 Pyramid 05\0 Pyramid 05_S\0 Pyramid 06\0 Pyramid 06_S\0 Pyramid 07\0 Pyramid 07_S\0 Pyramid 08\0 Pyramid 08_S\0 Pyramid 09\0 Pyramid 09_S\0 Pyramid 10\0 Pyramid 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Jasper < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Jasper; };

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

    technique Jasper_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}