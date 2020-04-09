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
	#define fLUT_TextureName "Breezy Coral MLUT.png"
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

namespace MLUT_MultiLUT_Breezy_Coral
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	 uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Fluffy 01\0 Fluffy 01_S\0 Fluffy 02\0 Fluffy 02_S\0 Fluffy 03\0 Fluffy 03_S\0 Fluffy 04\0 Fluffy 04_S\0 Fluffy 05\0 Fluffy 05_S\0 Fluffy 06\0 Fluffy 06_S\0 Fluffy 07\0 Fluffy 07_S\0 Fluffy 08\0 Fluffy 08_S\0 Fluffy 09\0 Fluffy 09_S\0 Fluffy 10\0 Fluffy 10_S\0 Notebook 01\0 Notebook 01_S\0 Notebook 02\0 Notebook 02_S\0 Notebook 03\0 Notebook 03_S\0 Notebook 04\0 Notebook 04_S\0 Notebook 05\0 Notebook 05_S\0 Notebook 06\0 Notebook 06_S\0 Notebook 07\0 Notebook 07_S\0 Notebook 08\0 Notebook 08_S\0 Notebook 09\0 Notebook 09_S\0 Notebook 10\0 Notebook 10_S\0 Roses 01\0 Roses 01_S\0 Roses 02\0 Roses 02_S\0 Roses 03\0 Roses 03_S\0 Roses 04\0 Roses 04_S\0 Roses 05\0 Roses 05_S\0 Roses 06\0 Roses 06_S\0 Roses 07\0 Roses 07_S\0 Roses 08\0 Roses 08_S\0 Roses 09\0 Roses 09_S\0 Roses 10\0 Roses 10_S\0 Sugar 01\0 Sugar 01_S\0 Sugar 02\0 Sugar 02_S\0 Sugar 03\0 Sugar 03_S\0 Sugar 04\0 Sugar 04_S\0 Sugar 05\0 Sugar 05_S\0 Sugar 06\0 Sugar 06_S\0 Sugar 07\0 Sugar 07_S\0 Sugar 08\0 Sugar 08_S\0 Sugar 09\0 Sugar 09_S\0 Sugar 10\0 Sugar 10_S\0 Watercolor 01\0 Watercolor 01_S\0 Watercolor 02\0 Watercolor 02_S\0 Watercolor 03\0 Watercolor 03_S\0 Watercolor 04\0 Watercolor 04_S\0 Watercolor 05\0 Watercolor 05_S\0 Watercolor 06\0 Watercolor 06_S\0 Watercolor 07\0 Watercolor 07_S\0 Watercolor 08\0 Watercolor 08_S\0 Watercolor 09\0 Watercolor 09_S\0 Watercolor 10\0 Watercolor 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Breezy_Coral < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Breezy_Coral; };

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

    technique Breezy_Coral_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}