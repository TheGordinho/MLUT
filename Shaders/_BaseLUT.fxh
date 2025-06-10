#pragma once

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ReShade effect file
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Multi-LUT shader, using a texture atlas with multiple LUTs
// by Otis / Infuse Project. (https://github.com/FransBouma)
// Based on Marty's LUT shader 1.0 for ReShade 3.0 (https://github.com/martymcmodding)
// Thanks to kingeric1992 and Matsilagi for the tools (https://github.com/kingeric1992) (https://github.com/Matsilagi)
// Thanks to luluco250 for refactoring the code (https://github.com/luluco250)
// BlueSkyDefender for tweaking the shader every once in a while (https://github.com/BlueSkyDefender) 
// Thanks to etra0 (https://github.com/etra0) for helping speed up the creation process
// Converted and Modified by TheGordinho (https://github.com/TheGordinho)
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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

namespace fLUT_Name
{

uniform int fLUT_LutSelector<
    __UNIFORM_COMBO_INT1
    ui_label = "Main LUT";
    ui_items = fLUT_LutList;
> = 0;

uniform float GlobalControl <
    __UNIFORM_SLIDER_FLOAT1
    ui_min = 0.00; ui_max = 1.00;
    ui_label = "LUT intensity";
    ui_tooltip = "Controls how much of the LUT is applied.";
> = 1.00;

uniform float fLUT_AmountChroma <
    __UNIFORM_SLIDER_FLOAT1
    ui_min = 0.00; ui_max = 1.00;
    ui_label = "LUT Chroma Amount";
    ui_tooltip = "Intensity of color/chroma change of the LUT.";
> = 1.00;

uniform float fLUT_AmountLuma <
    __UNIFORM_SLIDER_FLOAT1
    ui_min = 0.00; ui_max = 1.00;
    ui_label = "LUT luma amount";
    ui_tooltip = "Intensity of luma change of the LUT.";
> = 1.00;

uniform bool bLUT_UseDepth <
    ui_label = "LUT Depth Distance";
    ui_tooltip = "Allows LUT to change colors based on the distance.";
> = false;

uniform float fLUT_FocusDistance <
    __UNIFORM_SLIDER_FLOAT1
    ui_min = 0.0; ui_max = 1.0;
    ui_label = "LUT Focus Distance";
    ui_tooltip = "Sets the focus distance where LUT is fully applied.";
> = 0.5;

uniform float2 fLUT_Fade <
    __UNIFORM_SLIDER_FLOAT1
    ui_min = 0.0; ui_max = 1.0;
    ui_label = "LUT Fade";
    ui_tooltip = "Distance where the LUT starts to fade in.";
> = float2(0.2, 0.2);

uniform float2 BlendPower <
    __UNIFORM_SLIDER_FLOAT1
    ui_min = 0.01; ui_max = 5.0;
    ui_label = "LUT Blend Power";
    ui_tooltip = "Controls the sharpness of the edges.";
> = float2(1, 1);

texture MultiLutTex <source = fLUT_TextureName;>
{
    Width = fLUT_TileSizeXY * fLUT_TileAmount;
    Height = fLUT_TileSizeXY * fLUT_LutAmount;
};

sampler MultiLUT
{
    Texture = MultiLutTex;
};

float Dot(float3 D) { return dot(D, float3(0.2125, 0.7154, 0.0721)); }

float4 MainPS(float4 pos : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
    float4 color = tex2D(ReShade::BackBuffer, uv);
    float depth = ReShade::GetLinearizedDepth(uv);
    color.a = Dot(color.rgb);

    float2 lut_ps = rcp(fLUT_TileSizeXY);
    lut_ps.x /= fLUT_TileAmount;

    float3 lut_uv = float3(
    (color.rg * fLUT_TileSizeXY - color.rg + 0.5) * lut_ps,
    color.b * fLUT_TileSizeXY - color.b);

    lut_uv.y /= fLUT_LutAmount;
    lut_uv.y += float(fLUT_LutSelector) / fLUT_LutAmount;

    float lerpfact = frac(lut_uv.z);
    lut_uv.x += (lut_uv.z - lerpfact) * lut_ps.y;

    float4 lutcolor = lerp(
        tex2D(MultiLUT, lut_uv.xy),
        tex2D(MultiLUT, float2(lut_uv.x + lut_ps.y, lut_uv.y)),
        lerpfact);

    lutcolor.a = Dot(lutcolor.rgb);
    float3 storecolor = color.rgb;

    color.rgb = lerp(lutcolor.rgb, color.rgb, 1 - fLUT_AmountChroma);
    color.rgb -= Dot(color.rgb);
    color.rgb += lerp(lutcolor.a, color.a, 1 - fLUT_AmountLuma);
    color.rgb = lerp(color.rgb, storecolor, 1 - GlobalControl);

    if (bLUT_UseDepth)
    {
        float nearStart = saturate(fLUT_FocusDistance - fLUT_Fade.x);
        float farEnd    = saturate(fLUT_FocusDistance + fLUT_Fade.y);

        float blendNear = smoothstep(nearStart, fLUT_FocusDistance, depth);
        float blendFar  = 1.0 - smoothstep(fLUT_FocusDistance, farEnd, depth);

        blendNear = pow(blendNear, BlendPower.x);
        blendFar = pow(blendFar, BlendPower.y);

        float blendDepth = saturate(blendNear * blendFar);

        color.rgb = lerp(storecolor.rgb, color.rgb, blendDepth);
    }

    return color;
}

technique fLUT_Name
{
    pass MultiLUT_Apply
    {
        VertexShader = PostProcessVS;
        PixelShader = MainPS;
    }
}

}
