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
	#define fLUT_TextureName "Nude Tones MLUT.png"
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

namespace MLUT_MultiLUT_Nude_Tones
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=100;
		ui_items=" Azure 01\0 Azure 01_S\0 Azure 02\0 Azure 02_S\0 Azure 03\0 Azure 03_S\0 Azure 04\0 Azure 04_S\0 Azure 05\0 Azure 05_S\0 Azure 06\0 Azure 06_S\0 Azure 07\0 Azure 07_S\0 Azure 08\0 Azure 08_S\0 Azure 09\0 Azure 09_S\0 Azure 10\0 Azure 10_S\0 Bold Rouge 01\0 Bold Rouge 01_S\0 Bold Rouge 02\0 Bold Rouge 02_S\0 Bold Rouge 03\0 Bold Rouge 03_S\0 Bold Rouge 04\0 Bold Rouge 04_S\0 Bold Rouge 05\0 Bold Rouge 05_S\0 Bold Rouge 06\0 Bold Rouge 06_S\0 Bold Rouge 07\0 Bold Rouge 07_S\0 Bold Rouge 08\0 Bold Rouge 08_S\0 Bold Rouge 09\0 Bold Rouge 09_S\0 Bold Rouge 10\0 Bold Rouge 10_S\0 Dark Chocolate 01\0 Dark Chocolate 01_S\0 Dark Chocolate 02\0 Dark Chocolate 02_S\0 Dark Chocolate 03\0 Dark Chocolate 03_S\0 Dark Chocolate 04\0 Dark Chocolate 04_S\0 Dark Chocolate 05\0 Dark Chocolate 05_S\0 Dark Chocolate 06\0 Dark Chocolate 06_S\0 Dark Chocolate 07\0 Dark Chocolate 07_S\0 Dark Chocolate 08\0 Dark Chocolate 08_S\0 Dark Chocolate 09\0 Dark Chocolate 09_S\0 Dark Chocolate 10\0 Dark Chocolate 10_S\0 Elm Beige 01\0 Elm Beige 01_S\0 Elm Beige 02\0 Elm Beige 02_S\0 Elm Beige 03\0 Elm Beige 03_S\0 Elm Beige 04\0 Elm Beige 04_S\0 Elm Beige 05\0 Elm Beige 05_S\0 Elm Beige 06\0 Elm Beige 06_S\0 Elm Beige 07\0 Elm Beige 07_S\0 Elm Beige 08\0 Elm Beige 08_S\0 Elm Beige 09\0 Elm Beige 09_S\0 Elm Beige 10\0 Elm Beige 10_S\0 High Fashion 01\0 High Fashion 01_S\0 High Fashion 02\0 High Fashion 02_S\0 High Fashion 03\0 High Fashion 03_S\0 High Fashion 04\0 High Fashion 04_S\0 High Fashion 05\0 High Fashion 05_S\0 High Fashion 06\0 High Fashion 06_S\0 High Fashion 07\0 High Fashion 07_S\0 High Fashion 08\0 High Fashion 08_S\0 High Fashion 09\0 High Fashion 09_S\0 High Fashion 10\0 High Fashion 10_S\0";
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

    texture texMultiLUT_MLUT_Nude_Tones < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_Nude_Tones; };

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

    technique Nude_Tones_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}