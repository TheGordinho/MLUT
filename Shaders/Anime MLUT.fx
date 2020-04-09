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
	#define fLUT_TextureName "Anime MLUT.png"
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

namespace MLUT_MultiLUT_Anime
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Anime 01\0 Anime 01_S\0 Anime 02\0 Anime 02_S\0 Anime 03\0 Anime 03_S\0 Anime 04\0 Anime 04_S\0 Anime 05\0 Anime 05_S\0 Anime 06\0 Anime 06_S\0 Anime 07\0 Anime 07_S\0 Anime 08\0 Anime 08_S\0 Anime 09\0 Anime 09_S\0 Anime 10\0 Anime 10_S\0 Arcade 01\0 Arcade 01_S\0 Arcade 02\0 Arcade 02_S\0 Arcade 03\0 Arcade 03_S\0 Arcade 04\0 Arcade 04_S\0 Arcade 05\0 Arcade 05_S\0 Arcade 06\0 Arcade 06_S\0 Arcade 07\0 Arcade 07_S\0 Arcade 08\0 Arcade 08_S\0 Arcade 09\0 Arcade 09_S\0 Arcade 10\0 Arcade 10_S\0 Game 01\0 Game 01_S\0 Game 02\0 Game 02_S\0 Game 03\0 Game 03_S\0 Game 04\0 Game 04_S\0 Game 05\0 Game 05_S\0 Game 06\0 Game 06_S\0 Game 07\0 Game 07_S\0 Game 08\0 Game 08_S\0 Game 09\0 Game 09_S\0 Game 10\0 Game 10_S\0 Virtual 01\0 Virtual 01_S\0 Virtual 02\0 Virtual 02_S\0 Virtual 03\0 Virtual 03_S\0 Virtual 04\0 Virtual 04_S\0 Virtual 05\0 Virtual 05_S\0 Virtual 06\0 Virtual 06_S\0 Virtual 07\0 Virtual 07_S\0 Virtual 08\0 Virtual 08_S\0 Virtual 09\0 Virtual 09_S\0 Virtual 10\0 Virtual 10_S\0 Yolk 01\0 Yolk 01_S\0 Yolk 02\0 Yolk 02_S\0 Yolk 03\0 Yolk 03_S\0 Yolk 04\0 Yolk 04_S\0 Yolk 05\0 Yolk 05_S\0 Yolk 06\0 Yolk 06_S\0 Yolk 07\0 Yolk 07_S\0 Yolk 08\0 Yolk 08_S\0 Yolk 09\0 Yolk 09_S\0 Yolk 10\0 Yolk 10_S\0";
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

    texture texMultiLUT_MLUT_pdb80_Anime < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pdb80_Anime; };

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

    technique Anime_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}