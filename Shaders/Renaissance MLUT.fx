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
	#define fLUT_TextureName "Renaissance MLUT.png"
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

namespace MLUT_MultiLUT_Renaissance
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=100;
		ui_items=" Baroque 01\0 Baroque 01_S\0 Baroque 02\0 Baroque 02_S\0 Baroque 03\0 Baroque 03_S\0 Baroque 04\0 Baroque 04_S\0 Baroque 05\0 Baroque 05_S\0 Baroque 06\0 Baroque 06_S\0 Baroque 07\0 Baroque 07_S\0 Baroque 08\0 Baroque 08_S\0 Baroque 09\0 Baroque 09_S\0 Baroque 10\0 Baroque 10_S\0 Italy 01\0 Italy 01_S\0 Italy 02\0 Italy 02_S\0 Italy 03\0 Italy 03_S\0 Italy 04\0 Italy 04_S\0 Italy 05\0 Italy 05_S\0 Italy 06\0 Italy 06_S\0 Italy 07\0 Italy 07_S\0 Italy 08\0 Italy 08_S\0 Italy 09\0 Italy 09_S\0 Italy 10\0 Italy 10_S\0 Literature 01\0 Literature 01_S\0 Literature 02\0 Literature 02_S\0 Literature 03\0 Literature 03_S\0 Literature 04\0 Literature 04_S\0 Literature 05\0 Literature 05_S\0 Literature 06\0 Literature 06_S\0 Literature 07\0 Literature 07_S\0 Literature 08\0 Literature 08_S\0 Literature 09\0 Literature 09_S\0 Literature 10\0 Literature 10_S\0 Michelangelo 01\0 Michelangelo 01_S\0 Michelangelo 02\0 Michelangelo 02_S\0 Michelangelo 03\0 Michelangelo 03_S\0 Michelangelo 04\0 Michelangelo 04_S\0 Michelangelo 05\0 Michelangelo 05_S\0 Michelangelo 06\0 Michelangelo 06_S\0 Michelangelo 07\0 Michelangelo 07_S\0 Michelangelo 08\0 Michelangelo 08_S\0 Michelangelo 09\0 Michelangelo 09_S\0 Michelangelo 10\0 Michelangelo 10_S\0 Prodigal 01\0 Prodigal 01_S\0 Prodigal 02\0 Prodigal 02_S\0 Prodigal 03\0 Prodigal 03_S\0 Prodigal 04\0 Prodigal 04_S\0 Prodigal 05\0 Prodigal 05_S\0 Prodigal 06\0 Prodigal 06_S\0 Prodigal 07\0 Prodigal 07_S\0 Prodigal 08\0 Prodigal 08_S\0 Prodigal 09\0 Prodigal 09_S\0 Prodigal 10\0 Prodigal 10_S\0";
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

    texture texMultiLUT_MLUT_Renaissance < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_Renaissance; };

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

    technique Renaissance_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}