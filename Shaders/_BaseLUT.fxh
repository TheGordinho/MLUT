#pragma once

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ReShade effect file
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Multi-LUT shader, using a texture atlas with multiple LUTs
// by Otis / Infuse Project.
// Based on Marty's LUT shader 1.0 for ReShade 3.0
// Copyright © 2008-2016 Marty McFly
// Converted and Modified by TheGordinho
// Thanks to kingeric1992 and Matsilagi for the tools
// Refactored by luluco250
// 
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//#region Preprocessor

#include "ReShade.fxh"
#include "ReShadeUI.fxh"

#if !defined(fLUT_Name)
    #error "LUT name not defined"
#endif

#if !defined(fLUT_LutList)
	#error "LUT list not defined"
#endif

#if !defined(fLUT_TextureName)
    #error "LUT texture name not defined"
#endif

#if !defined(fLUT_TileSizeXY)
    #error "LUT tile size not defined"
#endif

#if !defined(fLUT_TileAmount)
    #error "LUT tile amount not defined"
#endif

#if !defined(fLUT_LutAmount)
    #error "LUT amount not defined"
#endif

//#endregion

namespace fLUT_Name
{

//#region Uniforms

uniform int fLUT_LutSelector
<
	__UNIFORM_COMBO_INT1

	ui_label = "The LUT to use";
	ui_items = fLUT_LutList;
> = 0;

uniform float fLUT_AmountChroma <
	__UNIFORM_SLIDER_FLOAT1
	//ui_type = "drag";
	ui_min = 0.00; ui_max = 1.00;
	ui_label = "LUT chroma amount";
	ui_tooltip = "Intensity of color/chroma change of the LUT.";
> = 1.00;

uniform float fLUT_AmountLuma <
	__UNIFORM_SLIDER_FLOAT1
	//ui_type = "drag";
	ui_min = 0.00; ui_max = 1.00;
	ui_label = "LUT luma amount";
	ui_tooltip = "Intensity of luma change of the LUT.";

> = 1.00;

//#endregion

//#region Textures

texture MultiLutTex <source = fLUT_TextureName;>
{
	Width = fLUT_TileSizeXY * fLUT_TileAmount;
	Height = fLUT_TileSizeXY * fLUT_LutAmount;
};

sampler MultiLUT
{
	Texture = MultiLutTex;
};

//#endregion

//#region Shaders

float4 MainPS(
	float4 pos : SV_POSITION,
	float2 uv : TEXCOORD) : SV_TARGET
{
	float4 color = tex2D(ReShade::BackBuffer, uv);

	float2 lut_ps = rcp(fLUT_TileSizeXY);
	lut_ps.x /= fLUT_TileAmount;

	float3 lut_uv = float3(
		(color.rg * fLUT_TileSizeXY - color.rg + 0.5) * lut_ps,
		color.b * fLUT_TileSizeXY - color.b);

	lut_uv.y /= fLUT_LutAmount;
	lut_uv.y += float(fLUT_LutSelector) / fLUT_LutAmount;

	float lerpfact = frac(lut_uv.z);
	lut_uv.x += (lut_uv.z - lerpfact) * lut_ps.y;

	float3 lutcolor = (float3)lerp(
		(float3)tex2D(MultiLUT, lut_uv.xy).xyz,
		(float3)tex2D(
			MultiLUT,
			float2(lut_uv.x + lut_ps.y, lut_uv.y)).xyz,
		lerpfact);


	color.xyz = lerp(saturate(normalize(color.xyz)), saturate(normalize(lutcolor.xyz)), fLUT_AmountChroma)* 
	            lerp(length(color.xyz),    length(lutcolor.xyz),    fLUT_AmountLuma);

	
	return color;
}

//#endregion

//#region Technique

technique fLUT_Name
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = MainPS;
	}
}

//#endregion

}
