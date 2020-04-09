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
// Thanks to Fernando Souza from blackmagicdesign.com for converting the https://gmic.eu/color_presets/ to .cube 
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#ifndef fLUT_TextureName
	#define fLUT_TextureName "Instant Consumer MLUT.png"
#endif
#ifndef fLUT_TileSizeXY
	#define fLUT_TileSizeXY 64
#endif
#ifndef fLUT_TileAmount
	#define fLUT_TileAmount 64
#endif
#ifndef fLUT_LutAmount
	#define fLUT_LutAmount 54
#endif

#include "ReShade.fxh"

namespace MLUT_MultiLUT_Instant_Costumer
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items="polaroid_px-100uv+_cold\0polaroid_px-100uv+_cold_+++\0polaroid_px-100uv+_cold_++\0polaroid_px-100uv+_cold_+\0polaroid_px-100uv+_cold_--\0polaroid_px-100uv+_cold_-\0polaroid_px-100uv+_warm\0polaroid_px-100uv+_warm_+++\0polaroid_px-100uv+_warm_++\0polaroid_px-100uv+_warm_+\0polaroid_px-100uv+_warm_--\0polaroid_px-100uv+_warm_-\0polaroid_px-680\0polaroid_px-680_++\0polaroid_px-680_+\0polaroid_px-680_--\0polaroid_px-680_-\0polaroid_px-680_cold\0polaroid_px-680_cold_++\0polaroid_px-680_cold_++_alt\0polaroid_px-680_cold_+\0polaroid_px-680_cold_--\0polaroid_px-680_cold_-\0polaroid_px-680_warm\0polaroid_px-680_warm_++\0polaroid_px-680_warm_+\0polaroid_px-680_warm_--\0polaroid_px-680_warm_-\0polaroid_px-70\0polaroid_px-70_+++\0polaroid_px-70_++\0polaroid_px-70_+\0polaroid_px-70_--\0polaroid_px-70_-\0polaroid_px-70_cold\0polaroid_px-70_cold_++\0polaroid_px-70_cold_+\0polaroid_px-70_cold_--\0polaroid_px-70_cold_-\0polaroid_px-70_warm\0polaroid_px-70_warm_++\0polaroid_px-70_warm_+\0polaroid_px-70_warm_--\0polaroid_px-70_warm_-\0polaroid_time_zero_(expired)\0polaroid_time_zero_(expired)_++\0polaroid_time_zero_(expired)_+\0polaroid_time_zero_(expired)_---\0polaroid_time_zero_(expired)_--\0polaroid_time_zero_(expired)_-\0polaroid_time_zero_(expired)_cold\0polaroid_time_zero_(expired)_cold_---\0polaroid_time_zero_(expired)_cold_--\0polaroid_time_zero_(expired)_cold_-\0"; 
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

    texture texMultiLUT_MLUT_pd80_Instant_Costumer < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Instant_Costumer; };

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

    technique Instant_Costumer_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}