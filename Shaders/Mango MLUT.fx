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
	#define fLUT_TextureName "Mango MLUT.png"
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

namespace MLUT_MultiLUT_Mango
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Alphonso 01\0 Alphonso 01_S\0 Alphonso 02\0 Alphonso 02_S\0 Alphonso 03\0 Alphonso 03_S\0 Alphonso 04\0 Alphonso 04_S\0 Alphonso 05\0 Alphonso 05_S\0 Alphonso 06\0 Alphonso 06_S\0 Alphonso 07\0 Alphonso 07_S\0 Alphonso 08\0 Alphonso 08_S\0 Alphonso 09\0 Alphonso 09_S\0 Alphonso 10\0 Alphonso 10_S\0 Green 01\0 Green 01_S\0 Green 02\0 Green 02_S\0 Green 03\0 Green 03_S\0 Green 04\0 Green 04_S\0 Green 05\0 Green 05_S\0 Green 06\0 Green 06_S\0 Green 07\0 Green 07_S\0 Green 08\0 Green 08_S\0 Green 09\0 Green 09_S\0 Green 10\0 Green 10_S\0 Haden 01\0 Haden 01_S\0 Haden 02\0 Haden 02_S\0 Haden 03\0 Haden 03_S\0 Haden 04\0 Haden 04_S\0 Haden 05\0 Haden 05_S\0 Haden 06\0 Haden 06_S\0 Haden 07\0 Haden 07_S\0 Haden 08\0 Haden 08_S\0 Haden 09\0 Haden 09_S\0 Haden 10\0 Haden 10_S\0 Kent 01\0 Kent 01_S\0 Kent 02\0 Kent 02_S\0 Kent 03\0 Kent 03_S\0 Kent 04\0 Kent 04_S\0 Kent 05\0 Kent 05_S\0 Kent 06\0 Kent 06_S\0 Kent 07\0 Kent 07_S\0 Kent 08\0 Kent 08_S\0 Kent 09\0 Kent 09_S\0 Kent 10\0 Kent 10_S\0 Vallenato 01\0 Vallenato 01_S\0 Vallenato 02\0 Vallenato 02_S\0 Vallenato 03\0 Vallenato 03_S\0 Vallenato 04\0 Vallenato 04_S\0 Vallenato 05\0 Vallenato 05_S\0 Vallenato 06\0 Vallenato 06_S\0 Vallenato 07\0 Vallenato 07_S\0 Vallenato 08\0 Vallenato 08_S\0 Vallenato 09\0 Vallenato 09_S\0 Vallenato 10\0 Vallenato 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Mango < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Mango; };

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

    technique Mango_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}