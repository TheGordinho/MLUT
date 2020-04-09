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
	#define fLUT_TextureName "Top Wedding MLUT.png"
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

namespace MLUT_MultiLUT_Top_Wedding
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Beach 01\0 Beach 01_S\0 Beach 02\0 Beach 02_S\0 Beach 03\0 Beach 03_S\0 Beach 04\0 Beach 04_S\0 Beach 05\0 Beach 05_S\0 Beach 06\0 Beach 06_S\0 Beach 07\0 Beach 07_S\0 Beach 08\0 Beach 08_S\0 Beach 09\0 Beach 09_S\0 Beach 10\0 Beach 10_S\0 Editorial 01\0 Editorial 01_S\0 Editorial 02\0 Editorial 02_S\0 Editorial 03\0 Editorial 03_S\0 Editorial 04\0 Editorial 04_S\0 Editorial 05\0 Editorial 05_S\0 Editorial 06\0 Editorial 06_S\0 Editorial 07\0 Editorial 07_S\0 Editorial 08\0 Editorial 08_S\0 Editorial 09\0 Editorial 09_S\0 Editorial 10\0 Editorial 10_S\0 Film Light 01\0 Film Light 01_S\0 Film Light 02\0 Film Light 02_S\0 Film Light 03\0 Film Light 03_S\0 Film Light 04\0 Film Light 04_S\0 Film Light 05\0 Film Light 05_S\0 Film Light 06\0 Film Light 06_S\0 Film Light 07\0 Film Light 07_S\0 Film Light 08\0 Film Light 08_S\0 Film Light 09\0 Film Light 09_S\0 Film Light 10\0 Film Light 10_S\0 Morning Park 01\0 Morning Park 01_S\0 Morning Park 02\0 Morning Park 02_S\0 Morning Park 03\0 Morning Park 03_S\0 Morning Park 04\0 Morning Park 04_S\0 Morning Park 05\0 Morning Park 05_S\0 Morning Park 06\0 Morning Park 06_S\0 Morning Park 07\0 Morning Park 07_S\0 Morning Park 08\0 Morning Park 08_S\0 Morning Park 09\0 Morning Park 09_S\0 Morning Park 10\0 Morning Park 10_S\0 Noir 01\0 Noir 01_S\0 Noir 02\0 Noir 02_S\0 Noir 03\0 Noir 03_S\0 Noir 04\0 Noir 04_S\0 Noir 05\0 Noir 05_S\0 Noir 06\0 Noir 06_S\0 Noir 07\0 Noir 07_S\0 Noir 08\0 Noir 08_S\0 Noir 09\0 Noir 09_S\0 Noir 10\0 Noir 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Top_Wedding < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Top_Wedding; };

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

    technique Top_Wedding_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}