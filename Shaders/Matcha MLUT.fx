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
	#define fLUT_TextureName "Matcha MLUT.png"
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

namespace MLUT_MultiLUT_Matcha
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Imamiya 01\0 Imamiya 01_S\0 Imamiya 02\0 Imamiya 02_S\0 Imamiya 03\0 Imamiya 03_S\0 Imamiya 04\0 Imamiya 04_S\0 Imamiya 05\0 Imamiya 05_S\0 Imamiya 06\0 Imamiya 06_S\0 Imamiya 07\0 Imamiya 07_S\0 Imamiya 08\0 Imamiya 08_S\0 Imamiya 09\0 Imamiya 09_S\0 Imamiya 10\0 Imamiya 10_S\0 Nishio 01\0 Nishio 01_S\0 Nishio 02\0 Nishio 02_S\0 Nishio 03\0 Nishio 03_S\0 Nishio 04\0 Nishio 04_S\0 Nishio 05\0 Nishio 05_S\0 Nishio 06\0 Nishio 06_S\0 Nishio 07\0 Nishio 07_S\0 Nishio 08\0 Nishio 08_S\0 Nishio 09\0 Nishio 09_S\0 Nishio 10\0 Nishio 10_S\0 Uji 01\0 Uji 01_S\0 Uji 02\0 Uji 02_S\0 Uji 03\0 Uji 03_S\0 Uji 04\0 Uji 04_S\0 Uji 05\0 Uji 05_S\0 Uji 06\0 Uji 06_S\0 Uji 07\0 Uji 07_S\0 Uji 08\0 Uji 08_S\0 Uji 09\0 Uji 09_S\0 Uji 10\0 Uji 10_S\0 Wazuka 01\0 Wazuka 01_S\0 Wazuka 02\0 Wazuka 02_S\0 Wazuka 03\0 Wazuka 03_S\0 Wazuka 04\0 Wazuka 04_S\0 Wazuka 05\0 Wazuka 05_S\0 Wazuka 06\0 Wazuka 06_S\0 Wazuka 07\0 Wazuka 07_S\0 Wazuka 08\0 Wazuka 08_S\0 Wazuka 09\0 Wazuka 09_S\0 Wazuka 10\0 Wazuka 10_S\0 Yame 01\0 Yame 01_S\0 Yame 02\0 Yame 02_S\0 Yame 03\0 Yame 03_S\0 Yame 04\0 Yame 04_S\0 Yame 05\0 Yame 05_S\0 Yame 06\0 Yame 06_S\0 Yame 07\0 Yame 07_S\0 Yame 08\0 Yame 08_S\0 Yame 09\0 Yame 09_S\0 Yame 10\0 Yame 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Matcha < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Matcha; };

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

    technique Matcha_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}