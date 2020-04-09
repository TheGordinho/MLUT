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
	#define fLUT_TextureName "Instant Photo MLUT.png"
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

namespace MLUT_MultiLUT_Instant_Photo
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Acatia 01\0 Acatia 01_S\0 Acatia 02\0 Acatia 02_S\0 Acatia 03\0 Acatia 03_S\0 Acatia 04\0 Acatia 04_S\0 Acatia 05\0 Acatia 05_S\0 Acatia 06\0 Acatia 06_S\0 Acatia 07\0 Acatia 07_S\0 Acatia 08\0 Acatia 08_S\0 Acatia 09\0 Acatia 09_S\0 Acatia 10\0 Acatia 10_S\0 Elvia 01\0 Elvia 01_S\0 Elvia 02\0 Elvia 02_S\0 Elvia 03\0 Elvia 03_S\0 Elvia 04\0 Elvia 04_S\0 Elvia 05\0 Elvia 05_S\0 Elvia 06\0 Elvia 06_S\0 Elvia 07\0 Elvia 07_S\0 Elvia 08\0 Elvia 08_S\0 Elvia 09\0 Elvia 09_S\0 Elvia 10\0 Elvia 10_S\0 Lalia 01\0 Lalia 01_S\0 Lalia 02\0 Lalia 02_S\0 Lalia 03\0 Lalia 03_S\0 Lalia 04\0 Lalia 04_S\0 Lalia 05\0 Lalia 05_S\0 Lalia 06\0 Lalia 06_S\0 Lalia 07\0 Lalia 07_S\0 Lalia 08\0 Lalia 08_S\0 Lalia 09\0 Lalia 09_S\0 Lalia 10\0 Lalia 10_S\0 Nuria 01\0 Nuria 01_S\0 Nuria 02\0 Nuria 02_S\0 Nuria 03\0 Nuria 03_S\0 Nuria 04\0 Nuria 04_S\0 Nuria 05\0 Nuria 05_S\0 Nuria 06\0 Nuria 06_S\0 Nuria 07\0 Nuria 07_S\0 Nuria 08\0 Nuria 08_S\0 Nuria 09\0 Nuria 09_S\0 Nuria 10\0 Nuria 10_S\0 Vallia 01\0 Vallia 01_S\0 Vallia 02\0 Vallia 02_S\0 Vallia 03\0 Vallia 03_S\0 Vallia 04\0 Vallia 04_S\0 Vallia 05\0 Vallia 05_S\0 Vallia 06\0 Vallia 06_S\0 Vallia 07\0 Vallia 07_S\0 Vallia 08\0 Vallia 08_S\0 Vallia 09\0 Vallia 09_S\0 Vallia 10\0 Vallia 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Instant_Photo < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Instant_Photo; };

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

    technique Instant_Photo_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}