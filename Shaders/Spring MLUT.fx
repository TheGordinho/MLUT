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
	#define fLUT_TextureName "Spring MLUT.png"
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

namespace MLUT_MultiLUT_Spring
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Cherry 01\0 Cherry 01_S\0 Cherry 02\0 Cherry 02_S\0 Cherry 03\0 Cherry 03_S\0 Cherry 04\0 Cherry 04_S\0 Cherry 05\0 Cherry 05_S\0 Cherry 06\0 Cherry 06_S\0 Cherry 07\0 Cherry 07_S\0 Cherry 08\0 Cherry 08_S\0 Cherry 09\0 Cherry 09_S\0 Cherry 10\0 Cherry 10_S\0 Easter 01\0 Easter 01_S\0 Easter 02\0 Easter 02_S\0 Easter 03\0 Easter 03_S\0 Easter 04\0 Easter 04_S\0 Easter 05\0 Easter 05_S\0 Easter 06\0 Easter 06_S\0 Easter 07\0 Easter 07_S\0 Easter 08\0 Easter 08_S\0 Easter 09\0 Easter 09_S\0 Easter 10\0 Easter 10_S\0 March 01\0 March 01_S\0 March 02\0 March 02_S\0 March 03\0 March 03_S\0 March 04\0 March 04_S\0 March 05\0 March 05_S\0 March 06\0 March 06_S\0 March 07\0 March 07_S\0 March 08\0 March 08_S\0 March 09\0 March 09_S\0 March 10\0 March 10_S\0 Sakura 01\0 Sakura 01_S\0 Sakura 02\0 Sakura 02_S\0 Sakura 03\0 Sakura 03_S\0 Sakura 04\0 Sakura 04_S\0 Sakura 05\0 Sakura 05_S\0 Sakura 06\0 Sakura 06_S\0 Sakura 07\0 Sakura 07_S\0 Sakura 08\0 Sakura 08_S\0 Sakura 09\0 Sakura 09_S\0 Sakura 10\0 Sakura 10_S\0 Season 01\0 Season 01_S\0 Season 02\0 Season 02_S\0 Season 03\0 Season 03_S\0 Season 04\0 Season 04_S\0 Season 05\0 Season 05_S\0 Season 06\0 Season 06_S\0 Season 07\0 Season 07_S\0 Season 08\0 Season 08_S\0 Season 09\0 Season 09_S\0 Season 10\0 Season 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Spring < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Spring; };

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

    technique Spring_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}