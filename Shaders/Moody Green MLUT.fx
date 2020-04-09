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
	#define fLUT_TextureName "Moody Green MLUT.png"
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

namespace MLUT_MultiLUT_Moody_Green
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Dark Woods 01\0 Dark Woods 01_S\0 Dark Woods 02\0 Dark Woods 02_S\0 Dark Woods 03\0 Dark Woods 03_S\0 Dark Woods 04\0 Dark Woods 04_S\0 Dark Woods 05\0 Dark Woods 05_S\0 Dark Woods 06\0 Dark Woods 06_S\0 Dark Woods 07\0 Dark Woods 07_S\0 Dark Woods 08\0 Dark Woods 08_S\0 Dark Woods 09\0 Dark Woods 09_S\0 Dark Woods 10\0 Dark Woods 10_S\0 Forest 01\0 Forest 01_S\0 Forest 02\0 Forest 02_S\0 Forest 03\0 Forest 03_S\0 Forest 04\0 Forest 04_S\0 Forest 05\0 Forest 05_S\0 Forest 06\0 Forest 06_S\0 Forest 07\0 Forest 07_S\0 Forest 08\0 Forest 08_S\0 Forest 09\0 Forest 09_S\0 Forest 10\0 Forest 10_S\0 Jade 01\0 Jade 01_S\0 Jade 02\0 Jade 02_S\0 Jade 03\0 Jade 03_S\0 Jade 04\0 Jade 04_S\0 Jade 05\0 Jade 05_S\0 Jade 06\0 Jade 06_S\0 Jade 07\0 Jade 07_S\0 Jade 08\0 Jade 08_S\0 Jade 09\0 Jade 09_S\0 Jade 10\0 Jade 10_S\0 Monstera 01\0 Monstera 01_S\0 Monstera 02\0 Monstera 02_S\0 Monstera 03\0 Monstera 03_S\0 Monstera 04\0 Monstera 04_S\0 Monstera 05\0 Monstera 05_S\0 Monstera 06\0 Monstera 06_S\0 Monstera 07\0 Monstera 07_S\0 Monstera 08\0 Monstera 08_S\0 Monstera 09\0 Monstera 09_S\0 Monstera 10\0 Monstera 10_S\0 Surreal 01\0 Surreal 01_S\0 Surreal 02\0 Surreal 02_S\0 Surreal 03\0 Surreal 03_S\0 Surreal 04\0 Surreal 04_S\0 Surreal 05\0 Surreal 05_S\0 Surreal 06\0 Surreal 06_S\0 Surreal 07\0 Surreal 07_S\0 Surreal 08\0 Surreal 08_S\0 Surreal 09\0 Surreal 09_S\0 Surreal 10\0 Surreal 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Moody_Green < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Moody_Green; };

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

    technique Moody_Green_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}