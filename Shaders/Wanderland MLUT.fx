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
	#define fLUT_TextureName "Wanderland MLUT.png"
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

namespace MLUT_MultiLUT_Wanderland
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Evavous 01\0 Evavous 01_S\0 Evavous 02\0 Evavous 02_S\0 Evavous 03\0 Evavous 03_S\0 Evavous 04\0 Evavous 04_S\0 Evavous 05\0 Evavous 05_S\0 Evavous 06\0 Evavous 06_S\0 Evavous 07\0 Evavous 07_S\0 Evavous 08\0 Evavous 08_S\0 Evavous 09\0 Evavous 09_S\0 Evavous 10\0 Evavous 10_S\0 get names.bat Kokava 01\0 Kokava 01_S\0 Kokava 02\0 Kokava 02_S\0 Kokava 03\0 Kokava 03_S\0 Kokava 04\0 Kokava 04_S\0 Kokava 05\0 Kokava 05_S\0 Kokava 06\0 Kokava 06_S\0 Kokava 07\0 Kokava 07_S\0 Kokava 08\0 Kokava 08_S\0 Kokava 09\0 Kokava 09_S\0 Kokava 10\0 Kokava 10_S\0 Lovmava 01\0 Lovmava 01_S\0 Lovmava 02\0 Lovmava 02_S\0 Lovmava 03\0 Lovmava 03_S\0 Lovmava 04\0 Lovmava 04_S\0 Lovmava 05\0 Lovmava 05_S\0 Lovmava 06\0 Lovmava 06_S\0 Lovmava 07\0 Lovmava 07_S\0 Lovmava 08\0 Lovmava 08_S\0 Lovmava 09\0 Lovmava 09_S\0 Lovmava 10\0 Lovmava 10_S\0 Olsontt 01\0 Olsontt 01_S\0 Olsontt 02\0 Olsontt 02_S\0 Olsontt 03\0 Olsontt 03_S\0 Olsontt 04\0 Olsontt 04_S\0 Olsontt 05\0 Olsontt 05_S\0 Olsontt 06\0 Olsontt 06_S\0 Olsontt 07\0 Olsontt 07_S\0 Olsontt 08\0 Olsontt 08_S\0 Olsontt 09\0 Olsontt 09_S\0 Olsontt 10\0 Olsontt 10_S\0 Talva 01\0 Talva 01_S\0 Talva 02\0 Talva 02_S\0 Talva 03\0 Talva 03_S\0 Talva 04\0 Talva 04_S\0 Talva 05\0 Talva 05_S\0 Talva 06\0 Talva 06_S\0 Talva 07\0 Talva 07_S\0 Talva 08\0 Talva 08_S\0 Talva 09\0 Talva 09_S\0 Talva 10\0 Talva 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Wanderland < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Wanderland; };

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

    technique Wanderland_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}