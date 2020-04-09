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
// Converted by Thegordinho and Matsilagi
// Thanks to kingeric1992 and Matsilagi for the tools
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#ifndef fLUT_TextureName
	#define fLUT_TextureName "Winter Snowscape MLUT.png"
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

namespace MLUT_MultiLUT_Winter_Snowscape
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items="Blizzard01\0Blizzard01_S\0Blizzard02\0Blizzard02_S\0Blizzard03\0Blizzard03_S\0Blizzard04\0Blizzard04_S\0Blizzard05\0Blizzard05_S\0Blizzard06\0Blizzard06_S\0Blizzard07\0Blizzard07_S\0Blizzard08\0Blizzard08_S\0Blizzard09\0Blizzard09_S\0Blizzard10\0Blizzard10_S\0Brambling01\0Brambling01_S\0Brambling02\0Brambling02_S\0Brambling03\0Brambling03_S\0Brambling04\0Brambling04_S\0Brambling05\0Brambling05_S\0Brambling06\0Brambling06_S\0Brambling07\0Brambling07_S\0Brambling08\0Brambling08_S\0Brambling09\0Brambling09_S\0Brambling10\0Brambling10_S\0Crisp01\0Crisp01_S\0Crisp02\0Crisp02_S\0Crisp03\0Crisp03_S\0Crisp04\0Crisp04_S\0Crisp05\0Crisp05_S\0Crisp06\0Crisp06_S\0Crisp07\0Crisp07_S\0Crisp08\0Crisp08_S\0Crisp09\0Crisp09_S\0Crisp10\0Crisp10_S\0Hyacinth01\0Hyacinth01_S\0Hyacinth02\0Hyacinth02_S\0Hyacinth03\0Hyacinth03_S\0Hyacinth04\0Hyacinth04_S\0Hyacinth05\0Hyacinth05_S\0Hyacinth06\0Hyacinth06_S\0Hyacinth07\0Hyacinth07_S\0Hyacinth08\0Hyacinth08_S\0Hyacinth09\0Hyacinth09_S\0Hyacinth10\0Hyacinth10_S\0PureSnow01\0PureSnow01_S\0PureSnow02\0PureSnow02_S\0PureSnow03\0PureSnow03_S\0PureSnow04\0PureSnow04_S\0PureSnow05\0PureSnow05_S\0PureSnow06\0PureSnow06_S\0PureSnow07\0PureSnow07_S\0PureSnow08\0PureSnow08_S\0PureSnow09\0PureSnow09_S\0PureSnow10\0PureSnow10_S\0";
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

    texture texMultiLUT_MLUT_pd80_Winter_Snowscape < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Winter_Snowscape; };

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

    technique Winter_Snowscape_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}