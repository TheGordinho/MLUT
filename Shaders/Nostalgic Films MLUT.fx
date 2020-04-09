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
	#define fLUT_TextureName "Nostalgic Films MLUT.png"
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

namespace MLUT_MultiLUT_Nostalgic_Films
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Airia 01\0 Airia 01_S\0 Airia 02\0 Airia 02_S\0 Airia 03\0 Airia 03_S\0 Airia 04\0 Airia 04_S\0 Airia 05\0 Airia 05_S\0 Airia 06\0 Airia 06_S\0 Airia 07\0 Airia 07_S\0 Airia 08\0 Airia 08_S\0 Airia 09\0 Airia 09_S\0 Airia 10\0 Airia 10_S\0 Azuria 01\0 Azuria 01_S\0 Azuria 02\0 Azuria 02_S\0 Azuria 03\0 Azuria 03_S\0 Azuria 04\0 Azuria 04_S\0 Azuria 05\0 Azuria 05_S\0 Azuria 06\0 Azuria 06_S\0 Azuria 07\0 Azuria 07_S\0 Azuria 08\0 Azuria 08_S\0 Azuria 09\0 Azuria 09_S\0 Azuria 10\0 Azuria 10_S\0 Chroma 01\0 Chroma 01_S\0 Chroma 02\0 Chroma 02_S\0 Chroma 03\0 Chroma 03_S\0 Chroma 04\0 Chroma 04_S\0 Chroma 05\0 Chroma 05_S\0 Chroma 06\0 Chroma 06_S\0 Chroma 07\0 Chroma 07_S\0 Chroma 08\0 Chroma 08_S\0 Chroma 09\0 Chroma 09_S\0 Chroma 10\0 Chroma 10_S\0 Prima 01\0 Prima 01_S\0 Prima 02\0 Prima 02_S\0 Prima 03\0 Prima 03_S\0 Prima 04\0 Prima 04_S\0 Prima 05\0 Prima 05_S\0 Prima 06\0 Prima 06_S\0 Prima 07\0 Prima 07_S\0 Prima 08\0 Prima 08_S\0 Prima 09\0 Prima 09_S\0 Prima 10\0 Prima 10_S\0 Vivia 01\0 Vivia 01_S\0 Vivia 02\0 Vivia 02_S\0 Vivia 03\0 Vivia 03_S\0 Vivia 04\0 Vivia 04_S\0 Vivia 05\0 Vivia 05_S\0 Vivia 06\0 Vivia 06_S\0 Vivia 07\0 Vivia 07_S\0 Vivia 08\0 Vivia 08_S\0 Vivia 09\0 Vivia 09_S\0 Vivia 10\0 Vivia 10_S\0";
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

    texture texMultiLUT_MLUT_pd80_Nostalgic_Films < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Nostalgic_Films; };

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

    technique Nostalgic_Films_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}