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
	#define fLUT_TextureName "Bleak MLUT.png"
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

namespace MLUT_MultiLUT_Bleak
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    
	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Hawk 01\0 Hawk 01_S\0 Hawk 02\0 Hawk 02_S\0 Hawk 03\0 Hawk 03_S\0 Hawk 04\0 Hawk 04_S\0 Hawk 05\0 Hawk 05_S\0 Hawk 06\0 Hawk 06_S\0 Hawk 07\0 Hawk 07_S\0 Hawk 08\0 Hawk 08_S\0 Hawk 09\0 Hawk 09_S\0 Hawk 10\0 Hawk 10_S\0 Pear 01\0 Pear 01_S\0 Pear 02\0 Pear 02_S\0 Pear 03\0 Pear 03_S\0 Pear 04\0 Pear 04_S\0 Pear 05\0 Pear 05_S\0 Pear 06\0 Pear 06_S\0 Pear 07\0 Pear 07_S\0 Pear 08\0 Pear 08_S\0 Pear 09\0 Pear 09_S\0 Pear 10\0 Pear 10_S\0 Shoji 01\0 Shoji 01_S\0 Shoji 02\0 Shoji 02_S\0 Shoji 03\0 Shoji 03_S\0 Shoji 04\0 Shoji 04_S\0 Shoji 05\0 Shoji 05_S\0 Shoji 06\0 Shoji 06_S\0 Shoji 07\0 Shoji 07_S\0 Shoji 08\0 Shoji 08_S\0 Shoji 09\0 Shoji 09_S\0 Shoji 10\0 Shoji 10_S\0 Spire 01\0 Spire 01_S\0 Spire 02\0 Spire 02_S\0 Spire 03\0 Spire 03_S\0 Spire 04\0 Spire 04_S\0 Spire 05\0 Spire 05_S\0 Spire 06\0 Spire 06_S\0 Spire 07\0 Spire 07_S\0 Spire 08\0 Spire 08_S\0 Spire 09\0 Spire 09_S\0 Spire 10\0 Spire 10_S\0 Trellick 01\0 Trellick 01_S\0 Trellick 02\0 Trellick 02_S\0 Trellick 03\0 Trellick 03_S\0 Trellick 04\0 Trellick 04_S\0 Trellick 05\0 Trellick 05_S\0 Trellick 06\0 Trellick 06_S\0 Trellick 07\0 Trellick 07_S\0 Trellick 08\0 Trellick 08_S\0 Trellick 09\0 Trellick 09_S\0 Trellick 10\0 Trellick 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Bleak < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Bleak; };

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

    technique Bleak_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}