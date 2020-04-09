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
	#define fLUT_TextureName "Iridescent Pastel MLUT.png"
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

namespace MLUT_MultiLUT_Iridescent_Pastel
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Anchor 01\0 Anchor 01_S\0 Anchor 02\0 Anchor 02_S\0 Anchor 03\0 Anchor 03_S\0 Anchor 04\0 Anchor 04_S\0 Anchor 05\0 Anchor 05_S\0 Anchor 06\0 Anchor 06_S\0 Anchor 07\0 Anchor 07_S\0 Anchor 08\0 Anchor 08_S\0 Anchor 09\0 Anchor 09_S\0 Anchor 10\0 Anchor 10_S\0 Apricot 01\0 Apricot 01_S\0 Apricot 02\0 Apricot 02_S\0 Apricot 03\0 Apricot 03_S\0 Apricot 04\0 Apricot 04_S\0 Apricot 05\0 Apricot 05_S\0 Apricot 06\0 Apricot 06_S\0 Apricot 07\0 Apricot 07_S\0 Apricot 08\0 Apricot 08_S\0 Apricot 09\0 Apricot 09_S\0 Apricot 10\0 Apricot 10_S\0 Electric 01\0 Electric 01_S\0 Electric 02\0 Electric 02_S\0 Electric 03\0 Electric 03_S\0 Electric 04\0 Electric 04_S\0 Electric 05\0 Electric 05_S\0 Electric 06\0 Electric 06_S\0 Electric 07\0 Electric 07_S\0 Electric 08\0 Electric 08_S\0 Electric 09\0 Electric 09_S\0 Electric 10\0 Electric 10_S\0 Plum 01\0 Plum 01_S\0 Plum 02\0 Plum 02_S\0 Plum 03\0 Plum 03_S\0 Plum 04\0 Plum 04_S\0 Plum 05\0 Plum 05_S\0 Plum 06\0 Plum 06_S\0 Plum 07\0 Plum 07_S\0 Plum 08\0 Plum 08_S\0 Plum 09\0 Plum 09_S\0 Plum 10\0 Plum 10_S\0 Russet 01\0 Russet 01_S\0 Russet 02\0 Russet 02_S\0 Russet 03\0 Russet 03_S\0 Russet 04\0 Russet 04_S\0 Russet 05\0 Russet 05_S\0 Russet 06\0 Russet 06_S\0 Russet 07\0 Russet 07_S\0 Russet 08\0 Russet 08_S\0 Russet 09\0 Russet 09_S\0 Russet 10\0 Russet 10_S\0";
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

    texture texMultiLUT_MLUT_pd80_Iridescent_Pastel < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Iridescent_Pastel; };

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

    technique Iridescent_Pastel_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}