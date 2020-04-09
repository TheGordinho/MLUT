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
	#define fLUT_TextureName "Travel Filmmakers MLUT.png"
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

namespace MLUT_MultiLUT_Travel_Filmmakers
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Ascent 01\0 Ascent 01_S\0 Ascent 02\0 Ascent 02_S\0 Ascent 03\0 Ascent 03_S\0 Ascent 04\0 Ascent 04_S\0 Ascent 05\0 Ascent 05_S\0 Ascent 06\0 Ascent 06_S\0 Ascent 07\0 Ascent 07_S\0 Ascent 08\0 Ascent 08_S\0 Ascent 09\0 Ascent 09_S\0 Ascent 10\0 Ascent 10_S\0 Bali 01\0 Bali 01_S\0 Bali 02\0 Bali 02_S\0 Bali 03\0 Bali 03_S\0 Bali 04\0 Bali 04_S\0 Bali 05\0 Bali 05_S\0 Bali 06\0 Bali 06_S\0 Bali 07\0 Bali 07_S\0 Bali 08\0 Bali 08_S\0 Bali 09\0 Bali 09_S\0 Bali 10\0 Bali 10_S\0 Desire 01\0 Desire 01_S\0 Desire 02\0 Desire 02_S\0 Desire 03\0 Desire 03_S\0 Desire 04\0 Desire 04_S\0 Desire 05\0 Desire 05_S\0 Desire 06\0 Desire 06_S\0 Desire 07\0 Desire 07_S\0 Desire 08\0 Desire 08_S\0 Desire 09\0 Desire 09_S\0 Desire 10\0 Desire 10_S\0 Flame 01\0 Flame 01_S\0 Flame 02\0 Flame 02_S\0 Flame 03\0 Flame 03_S\0 Flame 04\0 Flame 04_S\0 Flame 05\0 Flame 05_S\0 Flame 06\0 Flame 06_S\0 Flame 07\0 Flame 07_S\0 Flame 08\0 Flame 08_S\0 Flame 09\0 Flame 09_S\0 Flame 10\0 Flame 10_S\0 Stay Gold 01\0 Stay Gold 01_S\0 Stay Gold 02\0 Stay Gold 02_S\0 Stay Gold 03\0 Stay Gold 03_S\0 Stay Gold 04\0 Stay Gold 04_S\0 Stay Gold 05\0 Stay Gold 05_S\0 Stay Gold 06\0 Stay Gold 06_S\0 Stay Gold 07\0 Stay Gold 07_S\0 Stay Gold 08\0 Stay Gold 08_S\0 Stay Gold 09\0 Stay Gold 09_S\0 Stay Gold 10\0 Stay Gold 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Travel_Filmmakers < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Travel_Filmmakers; };

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

    technique Travel_Filmmakers_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}