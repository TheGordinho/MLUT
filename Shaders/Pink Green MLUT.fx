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
	#define fLUT_TextureName "Pink Green MLUT.png"
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

namespace MLUT_MultiLUT_Pink_Green
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Blush 01\0 Blush 01_S\0 Blush 02\0 Blush 02_S\0 Blush 03\0 Blush 03_S\0 Blush 04\0 Blush 04_S\0 Blush 05\0 Blush 05_S\0 Blush 06\0 Blush 06_S\0 Blush 07\0 Blush 07_S\0 Blush 08\0 Blush 08_S\0 Blush 09\0 Blush 09_S\0 Blush 10\0 Blush 10_S\0 Bubble Gum 01\0 Bubble Gum 01_S\0 Bubble Gum 02\0 Bubble Gum 02_S\0 Bubble Gum 03\0 Bubble Gum 03_S\0 Bubble Gum 04\0 Bubble Gum 04_S\0 Bubble Gum 05\0 Bubble Gum 05_S\0 Bubble Gum 06\0 Bubble Gum 06_S\0 Bubble Gum 07\0 Bubble Gum 07_S\0 Bubble Gum 08\0 Bubble Gum 08_S\0 Bubble Gum 09\0 Bubble Gum 09_S\0 Bubble Gum 10\0 Bubble Gum 10_S\0 Flamingo 01\0 Flamingo 01_S\0 Flamingo 02\0 Flamingo 02_S\0 Flamingo 03\0 Flamingo 03_S\0 Flamingo 04\0 Flamingo 04_S\0 Flamingo 05\0 Flamingo 05_S\0 Flamingo 06\0 Flamingo 06_S\0 Flamingo 07\0 Flamingo 07_S\0 Flamingo 08\0 Flamingo 08_S\0 Flamingo 09\0 Flamingo 09_S\0 Flamingo 10\0 Flamingo 10_S\0 Love Letter 01\0 Love Letter 01_S\0 Love Letter 02\0 Love Letter 02_S\0 Love Letter 03\0 Love Letter 03_S\0 Love Letter 04\0 Love Letter 04_S\0 Love Letter 05\0 Love Letter 05_S\0 Love Letter 06\0 Love Letter 06_S\0 Love Letter 07\0 Love Letter 07_S\0 Love Letter 08\0 Love Letter 08_S\0 Love Letter 09\0 Love Letter 09_S\0 Love Letter 10\0 Love Letter 10_S\0 Strawberry 01\0 Strawberry 01_S\0 Strawberry 02\0 Strawberry 02_S\0 Strawberry 03\0 Strawberry 03_S\0 Strawberry 04\0 Strawberry 04_S\0 Strawberry 05\0 Strawberry 05_S\0 Strawberry 06\0 Strawberry 06_S\0 Strawberry 07\0 Strawberry 07_S\0 Strawberry 08\0 Strawberry 08_S\0 Strawberry 09\0 Strawberry 09_S\0 Strawberry 10\0 Strawberry 10_S\0";
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

    texture texMultiLUT_MLUT_pd80_Pink_Green < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Pink_Green; };

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

    technique Pink_Green_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}