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
	#define fLUT_TextureName "Cyberpunk Neon MLUT.png"
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

namespace MLUT_MultiLUT_Cyberpunk_Neon
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

uniform int fLUT_LutSelector < 
	ui_type = "combo";
	ui_min= 0; ui_max=16;
	ui_items=" 2077 01\0 2077 01_S\0 2077 02\0 2077 02_S\0 2077 03\0 2077 03_S\0 2077 04\0 2077 04_S\0 2077 05\0 2077 05_S\0 2077 06\0 2077 06_S\0 2077 07\0 2077 07_S\0 2077 08\0 2077 08_S\0 2077 09\0 2077 09_S\0 2077 10\0 2077 10_S\0 Aesthetics 01\0 Aesthetics 01_S\0 Aesthetics 02\0 Aesthetics 02_S\0 Aesthetics 03\0 Aesthetics 03_S\0 Aesthetics 04\0 Aesthetics 04_S\0 Aesthetics 05\0 Aesthetics 05_S\0 Aesthetics 06\0 Aesthetics 06_S\0 Aesthetics 07\0 Aesthetics 07_S\0 Aesthetics 08\0 Aesthetics 08_S\0 Aesthetics 09\0 Aesthetics 09_S\0 Aesthetics 10\0 Aesthetics 10_S\0 Colorways 01\0 Colorways 01_S\0 Colorways 02\0 Colorways 02_S\0 Colorways 03\0 Colorways 03_S\0 Colorways 04\0 Colorways 04_S\0 Colorways 05\0 Colorways 05_S\0 Colorways 06\0 Colorways 06_S\0 Colorways 07\0 Colorways 07_S\0 Colorways 08\0 Colorways 08_S\0 Colorways 09\0 Colorways 09_S\0 Colorways 10\0 Colorways 10_S\0 Fury 01\0 Fury 01_S\0 Fury 02\0 Fury 02_S\0 Fury 03\0 Fury 03_S\0 Fury 04\0 Fury 04_S\0 Fury 05\0 Fury 05_S\0 Fury 06\0 Fury 06_S\0 Fury 07\0 Fury 07_S\0 Fury 08\0 Fury 08_S\0 Fury 09\0 Fury 09_S\0 Fury 10\0 Fury 10_S\0 Futuristic 01\0 Futuristic 01_S\0 Futuristic 02\0 Futuristic 02_S\0 Futuristic 03\0 Futuristic 03_S\0 Futuristic 04\0 Futuristic 04_S\0 Futuristic 05\0 Futuristic 05_S\0 Futuristic 06\0 Futuristic 06_S\0 Futuristic 07\0 Futuristic 07_S\0 Futuristic 08\0 Futuristic 08_S\0 Futuristic 09\0 Futuristic 09_S\0 Futuristic 10\0 Futuristic 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Cyberpunk_Neon < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Cyberpunk_Neon; };

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

    technique Cyberpunk_Neon_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}