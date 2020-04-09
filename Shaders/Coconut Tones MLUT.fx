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
	#define fLUT_TextureName "Coconut Tones MLUT.png"
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

namespace MLUT_MultiLUT_Coconut_Tones
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Birch 01\0 Birch 01_S\0 Birch 02\0 Birch 02_S\0 Birch 03\0 Birch 03_S\0 Birch 04\0 Birch 04_S\0 Birch 05\0 Birch 05_S\0 Birch 06\0 Birch 06_S\0 Birch 07\0 Birch 07_S\0 Birch 08\0 Birch 08_S\0 Birch 09\0 Birch 09_S\0 Birch 10\0 Birch 10_S\0 Brunette 01\0 Brunette 01_S\0 Brunette 02\0 Brunette 02_S\0 Brunette 03\0 Brunette 03_S\0 Brunette 04\0 Brunette 04_S\0 Brunette 05\0 Brunette 05_S\0 Brunette 06\0 Brunette 06_S\0 Brunette 07\0 Brunette 07_S\0 Brunette 08\0 Brunette 08_S\0 Brunette 09\0 Brunette 09_S\0 Brunette 10\0 Brunette 10_S\0 Chocolate 01\0 Chocolate 01_S\0 Chocolate 02\0 Chocolate 02_S\0 Chocolate 03\0 Chocolate 03_S\0 Chocolate 04\0 Chocolate 04_S\0 Chocolate 05\0 Chocolate 05_S\0 Chocolate 06\0 Chocolate 06_S\0 Chocolate 07\0 Chocolate 07_S\0 Chocolate 08\0 Chocolate 08_S\0 Chocolate 09\0 Chocolate 09_S\0 Chocolate 10\0 Chocolate 10_S\0 Coffee 01\0 Coffee 01_S\0 Coffee 02\0 Coffee 02_S\0 Coffee 03\0 Coffee 03_S\0 Coffee 04\0 Coffee 04_S\0 Coffee 05\0 Coffee 05_S\0 Coffee 06\0 Coffee 06_S\0 Coffee 07\0 Coffee 07_S\0 Coffee 08\0 Coffee 08_S\0 Coffee 09\0 Coffee 09_S\0 Coffee 10\0 Coffee 10_S\0 Tanned 01\0 Tanned 01_S\0 Tanned 02\0 Tanned 02_S\0 Tanned 03\0 Tanned 03_S\0 Tanned 04\0 Tanned 04_S\0 Tanned 05\0 Tanned 05_S\0 Tanned 06\0 Tanned 06_S\0 Tanned 07\0 Tanned 07_S\0 Tanned 08\0 Tanned 08_S\0 Tanned 09\0 Tanned 09_S\0 Tanned 10\0 Tanned 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Coconut_Tones < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Coconut_Tones; };

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

    technique Coconut_Tones_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}