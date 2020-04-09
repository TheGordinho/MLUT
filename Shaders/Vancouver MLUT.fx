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
	#define fLUT_TextureName "Vancouver MLUT.png"
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

namespace MLUT_MultiLUT_Vancouver
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" East Van 01\0 East Van 01_S\0 East Van 02\0 East Van 02_S\0 East Van 03\0 East Van 03_S\0 East Van 04\0 East Van 04_S\0 East Van 05\0 East Van 05_S\0 East Van 06\0 East Van 06_S\0 East Van 07\0 East Van 07_S\0 East Van 08\0 East Van 08_S\0 East Van 09\0 East Van 09_S\0 East Van 10\0 East Van 10_S\0 Gastown 01\0 Gastown 01_S\0 Gastown 02\0 Gastown 02_S\0 Gastown 03\0 Gastown 03_S\0 Gastown 04\0 Gastown 04_S\0 Gastown 05\0 Gastown 05_S\0 Gastown 06\0 Gastown 06_S\0 Gastown 07\0 Gastown 07_S\0 Gastown 08\0 Gastown 08_S\0 Gastown 09\0 Gastown 09_S\0 Gastown 10\0 Gastown 10_S\0 Grouse 01\0 Grouse 01_S\0 Grouse 02\0 Grouse 02_S\0 Grouse 03\0 Grouse 03_S\0 Grouse 04\0 Grouse 04_S\0 Grouse 05\0 Grouse 05_S\0 Grouse 06\0 Grouse 06_S\0 Grouse 07\0 Grouse 07_S\0 Grouse 08\0 Grouse 08_S\0 Grouse 09\0 Grouse 09_S\0 Grouse 10\0 Grouse 10_S\0 Sea to Sky 01\0 Sea to Sky 01_S\0 Sea to Sky 02\0 Sea to Sky 02_S\0 Sea to Sky 03\0 Sea to Sky 03_S\0 Sea to Sky 04\0 Sea to Sky 04_S\0 Sea to Sky 05\0 Sea to Sky 05_S\0 Sea to Sky 06\0 Sea to Sky 06_S\0 Sea to Sky 07\0 Sea to Sky 07_S\0 Sea to Sky 08\0 Sea to Sky 08_S\0 Sea to Sky 09\0 Sea to Sky 09_S\0 Sea to Sky 10\0 Sea to Sky 10_S\0 Steveston 01\0 Steveston 01_S\0 Steveston 02\0 Steveston 02_S\0 Steveston 03\0 Steveston 03_S\0 Steveston 04\0 Steveston 04_S\0 Steveston 05\0 Steveston 05_S\0 Steveston 06\0 Steveston 06_S\0 Steveston 07\0 Steveston 07_S\0 Steveston 08\0 Steveston 08_S\0 Steveston 09\0 Steveston 09_S\0 Steveston 10\0 Steveston 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Vancouver < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Vancouver; };

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

    technique Vancouver_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}