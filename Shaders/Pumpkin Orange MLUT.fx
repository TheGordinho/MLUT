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
	#define fLUT_TextureName "Pumpkin Orange MLUT.png"
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

namespace MLUT_MultiLUT_Pumpkin_Orange
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Alyx 01\0 Alyx 01_S\0 Alyx 02\0 Alyx 02_S\0 Alyx 03\0 Alyx 03_S\0 Alyx 04\0 Alyx 04_S\0 Alyx 05\0 Alyx 05_S\0 Alyx 06\0 Alyx 06_S\0 Alyx 07\0 Alyx 07_S\0 Alyx 08\0 Alyx 08_S\0 Alyx 09\0 Alyx 09_S\0 Alyx 10\0 Alyx 10_S\0 Jack 01\0 Jack 01_S\0 Jack 02\0 Jack 02_S\0 Jack 03\0 Jack 03_S\0 Jack 04\0 Jack 04_S\0 Jack 05\0 Jack 05_S\0 Jack 06\0 Jack 06_S\0 Jack 07\0 Jack 07_S\0 Jack 08\0 Jack 08_S\0 Jack 09\0 Jack 09_S\0 Jack 10\0 Jack 10_S\0 Kurt 01\0 Kurt 01_S\0 Kurt 02\0 Kurt 02_S\0 Kurt 03\0 Kurt 03_S\0 Kurt 04\0 Kurt 04_S\0 Kurt 05\0 Kurt 05_S\0 Kurt 06\0 Kurt 06_S\0 Kurt 07\0 Kurt 07_S\0 Kurt 08\0 Kurt 08_S\0 Kurt 09\0 Kurt 09_S\0 Kurt 10\0 Kurt 10_S\0 Liam 01\0 Liam 01_S\0 Liam 02\0 Liam 02_S\0 Liam 03\0 Liam 03_S\0 Liam 04\0 Liam 04_S\0 Liam 05\0 Liam 05_S\0 Liam 06\0 Liam 06_S\0 Liam 07\0 Liam 07_S\0 Liam 08\0 Liam 08_S\0 Liam 09\0 Liam 09_S\0 Liam 10\0 Liam 10_S\0 Nate 01\0 Nate 01_S\0 Nate 02\0 Nate 02_S\0 Nate 03\0 Nate 03_S\0 Nate 04\0 Nate 04_S\0 Nate 05\0 Nate 05_S\0 Nate 06\0 Nate 06_S\0 Nate 07\0 Nate 07_S\0 Nate 08\0 Nate 08_S\0 Nate 09\0 Nate 09_S\0 Nate 10\0 Nate 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Pumpkin_Orange < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Pumpkin_Orange; };

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

    technique Pumpkin_Orange_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}