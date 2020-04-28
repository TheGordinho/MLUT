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
	#define fLUT_TextureName "Bold Corporate MLUT.png"
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

namespace MLUT_MultiLUT_Bold_Corporate
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=100;
		ui_items=" Colbalt Business 01\0 Colbalt Business 01_S\0 Colbalt Business 02\0 Colbalt Business 02_S\0 Colbalt Business 03\0 Colbalt Business 03_S\0 Colbalt Business 04\0 Colbalt Business 04_S\0 Colbalt Business 05\0 Colbalt Business 05_S\0 Colbalt Business 06\0 Colbalt Business 06_S\0 Colbalt Business 07\0 Colbalt Business 07_S\0 Colbalt Business 08\0 Colbalt Business 08_S\0 Colbalt Business 09\0 Colbalt Business 09_S\0 Colbalt Business 10\0 Colbalt Business 10_S\0 Creative Agency 01\0 Creative Agency 01_S\0 Creative Agency 02\0 Creative Agency 02_S\0 Creative Agency 03\0 Creative Agency 03_S\0 Creative Agency 04\0 Creative Agency 04_S\0 Creative Agency 05\0 Creative Agency 05_S\0 Creative Agency 06\0 Creative Agency 06_S\0 Creative Agency 07\0 Creative Agency 07_S\0 Creative Agency 08\0 Creative Agency 08_S\0 Creative Agency 09\0 Creative Agency 09_S\0 Creative Agency 10\0 Creative Agency 10_S\0 Greenergy 01\0 Greenergy 01_S\0 Greenergy 02\0 Greenergy 02_S\0 Greenergy 03\0 Greenergy 03_S\0 Greenergy 04\0 Greenergy 04_S\0 Greenergy 05\0 Greenergy 05_S\0 Greenergy 06\0 Greenergy 06_S\0 Greenergy 07\0 Greenergy 07_S\0 Greenergy 08\0 Greenergy 08_S\0 Greenergy 09\0 Greenergy 09_S\0 Greenergy 10\0 Greenergy 10_S\0 Market Red 01\0 Market Red 01_S\0 Market Red 02\0 Market Red 02_S\0 Market Red 03\0 Market Red 03_S\0 Market Red 04\0 Market Red 04_S\0 Market Red 05\0 Market Red 05_S\0 Market Red 06\0 Market Red 06_S\0 Market Red 07\0 Market Red 07_S\0 Market Red 08\0 Market Red 08_S\0 Market Red 09\0 Market Red 09_S\0 Market Red 10\0 Market Red 10_S\0 White Collar 01\0 White Collar 01_S\0 White Collar 02\0 White Collar 02_S\0 White Collar 03\0 White Collar 03_S\0 White Collar 04\0 White Collar 04_S\0 White Collar 05\0 White Collar 05_S\0 White Collar 06\0 White Collar 06_S\0 White Collar 07\0 White Collar 07_S\0 White Collar 08\0 White Collar 08_S\0 White Collar 09\0 White Collar 09_S\0 White Collar 10\0 White Collar 10_S\0";
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

    texture texMultiLUT_MLUT_Bold_Corporate < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_Bold_Corporate; };

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

    technique Bold_Corporate_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}