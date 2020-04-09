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
	#define fLUT_TextureName "Peachy Peach MLUT.png"
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

namespace MLUT_MultiLUT_Peachy_Peach
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Blush 01\0 Blush 01_S\0 Blush 02\0 Blush 02_S\0 Blush 03\0 Blush 03_S\0 Blush 04\0 Blush 04_S\0 Blush 05\0 Blush 05_S\0 Blush 06\0 Blush 06_S\0 Blush 07\0 Blush 07_S\0 Blush 08\0 Blush 08_S\0 Blush 09\0 Blush 09_S\0 Blush 10\0 Blush 10_S\0 Copper 01\0 Copper 01_S\0 Copper 02\0 Copper 02_S\0 Copper 03\0 Copper 03_S\0 Copper 04\0 Copper 04_S\0 Copper 05\0 Copper 05_S\0 Copper 06\0 Copper 06_S\0 Copper 07\0 Copper 07_S\0 Copper 08\0 Copper 08_S\0 Copper 09\0 Copper 09_S\0 Copper 10\0 Copper 10_S\0 Coral 01\0 Coral 01_S\0 Coral 02\0 Coral 02_S\0 Coral 03\0 Coral 03_S\0 Coral 04\0 Coral 04_S\0 Coral 05\0 Coral 05_S\0 Coral 06\0 Coral 06_S\0 Coral 07\0 Coral 07_S\0 Coral 08\0 Coral 08_S\0 Coral 09\0 Coral 09_S\0 Coral 10\0 Coral 10_S\0 Emberglow 01\0 Emberglow 01_S\0 Emberglow 02\0 Emberglow 02_S\0 Emberglow 03\0 Emberglow 03_S\0 Emberglow 04\0 Emberglow 04_S\0 Emberglow 05\0 Emberglow 05_S\0 Emberglow 06\0 Emberglow 06_S\0 Emberglow 07\0 Emberglow 07_S\0 Emberglow 08\0 Emberglow 08_S\0 Emberglow 09\0 Emberglow 09_S\0 Emberglow 10\0 Emberglow 10_S\0 Sunset 01\0 Sunset 01_S\0 Sunset 02\0 Sunset 02_S\0 Sunset 03\0 Sunset 03_S\0 Sunset 04\0 Sunset 04_S\0 Sunset 05\0 Sunset 05_S\0 Sunset 06\0 Sunset 06_S\0 Sunset 07\0 Sunset 07_S\0 Sunset 08\0 Sunset 08_S\0 Sunset 09\0 Sunset 09_S\0 Sunset 10\0 Sunset 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Peachy_Peach < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Peachy_Peach; };

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

    technique Peachy_Peach_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}