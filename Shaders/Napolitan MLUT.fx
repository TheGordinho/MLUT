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
	#define fLUT_TextureName "Napolitan MLUT.png"
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

namespace MLUT_MultiLUT_Napolitan
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Bliss 01\0 Bliss 01_S\0 Bliss 02\0 Bliss 02_S\0 Bliss 03\0 Bliss 03_S\0 Bliss 04\0 Bliss 04_S\0 Bliss 05\0 Bliss 05_S\0 Bliss 06\0 Bliss 06_S\0 Bliss 07\0 Bliss 07_S\0 Bliss 08\0 Bliss 08_S\0 Bliss 09\0 Bliss 09_S\0 Bliss 10\0 Bliss 10_S\0 Chocolate 01\0 Chocolate 01_S\0 Chocolate 02\0 Chocolate 02_S\0 Chocolate 03\0 Chocolate 03_S\0 Chocolate 04\0 Chocolate 04_S\0 Chocolate 05\0 Chocolate 05_S\0 Chocolate 06\0 Chocolate 06_S\0 Chocolate 07\0 Chocolate 07_S\0 Chocolate 08\0 Chocolate 08_S\0 Chocolate 09\0 Chocolate 09_S\0 Chocolate 10\0 Chocolate 10_S\0 Pistachio 01\0 Pistachio 01_S\0 Pistachio 02\0 Pistachio 02_S\0 Pistachio 03\0 Pistachio 03_S\0 Pistachio 04\0 Pistachio 04_S\0 Pistachio 05\0 Pistachio 05_S\0 Pistachio 06\0 Pistachio 06_S\0 Pistachio 07\0 Pistachio 07_S\0 Pistachio 08\0 Pistachio 08_S\0 Pistachio 09\0 Pistachio 09_S\0 Pistachio 10\0 Pistachio 10_S\0 Sweetheart 01\0 Sweetheart 01_S\0 Sweetheart 02\0 Sweetheart 02_S\0 Sweetheart 03\0 Sweetheart 03_S\0 Sweetheart 04\0 Sweetheart 04_S\0 Sweetheart 05\0 Sweetheart 05_S\0 Sweetheart 06\0 Sweetheart 06_S\0 Sweetheart 07\0 Sweetheart 07_S\0 Sweetheart 08\0 Sweetheart 08_S\0 Sweetheart 09\0 Sweetheart 09_S\0 Sweetheart 10\0 Sweetheart 10_S\0 Treat 01\0 Treat 01_S\0 Treat 02\0 Treat 02_S\0 Treat 03\0 Treat 03_S\0 Treat 04\0 Treat 04_S\0 Treat 05\0 Treat 05_S\0 Treat 06\0 Treat 06_S\0 Treat 07\0 Treat 07_S\0 Treat 08\0 Treat 08_S\0 Treat 09\0 Treat 09_S\0 Treat 10\0 Treat 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Napolitan < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Napolitan; };

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

    technique Napolitan_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}