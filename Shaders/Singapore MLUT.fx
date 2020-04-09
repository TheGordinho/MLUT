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
	#define fLUT_TextureName "Singapore MLUT.png"
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

namespace MLUT_MultiLUT_Singapore
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Fort Canning 01\0 Fort Canning 01_S\0 Fort Canning 02\0 Fort Canning 02_S\0 Fort Canning 03\0 Fort Canning 03_S\0 Fort Canning 04\0 Fort Canning 04_S\0 Fort Canning 05\0 Fort Canning 05_S\0 Fort Canning 06\0 Fort Canning 06_S\0 Fort Canning 07\0 Fort Canning 07_S\0 Fort Canning 08\0 Fort Canning 08_S\0 Fort Canning 09\0 Fort Canning 09_S\0 Fort Canning 10\0 Fort Canning 10_S\0 Marina Bay 01\0 Marina Bay 01_S\0 Marina Bay 02\0 Marina Bay 02_S\0 Marina Bay 03\0 Marina Bay 03_S\0 Marina Bay 04\0 Marina Bay 04_S\0 Marina Bay 05\0 Marina Bay 05_S\0 Marina Bay 06\0 Marina Bay 06_S\0 Marina Bay 07\0 Marina Bay 07_S\0 Marina Bay 08\0 Marina Bay 08_S\0 Marina Bay 09\0 Marina Bay 09_S\0 Marina Bay 10\0 Marina Bay 10_S\0 Rainforest 01\0 Rainforest 01_S\0 Rainforest 02\0 Rainforest 02_S\0 Rainforest 03\0 Rainforest 03_S\0 Rainforest 04\0 Rainforest 04_S\0 Rainforest 05\0 Rainforest 05_S\0 Rainforest 06\0 Rainforest 06_S\0 Rainforest 07\0 Rainforest 07_S\0 Rainforest 08\0 Rainforest 08_S\0 Rainforest 09\0 Rainforest 09_S\0 Rainforest 10\0 Rainforest 10_S\0 Sentosa 01\0 Sentosa 01_S\0 Sentosa 02\0 Sentosa 02_S\0 Sentosa 03\0 Sentosa 03_S\0 Sentosa 04\0 Sentosa 04_S\0 Sentosa 05\0 Sentosa 05_S\0 Sentosa 06\0 Sentosa 06_S\0 Sentosa 07\0 Sentosa 07_S\0 Sentosa 08\0 Sentosa 08_S\0 Sentosa 09\0 Sentosa 09_S\0 Sentosa 10\0 Sentosa 10_S\0 Supertrees 01\0 Supertrees 01_S\0 Supertrees 02\0 Supertrees 02_S\0 Supertrees 03\0 Supertrees 03_S\0 Supertrees 04\0 Supertrees 04_S\0 Supertrees 05\0 Supertrees 05_S\0 Supertrees 06\0 Supertrees 06_S\0 Supertrees 07\0 Supertrees 07_S\0 Supertrees 08\0 Supertrees 08_S\0 Supertrees 09\0 Supertrees 09_S\0 Supertrees 10\0 Supertrees 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Singapore < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Singapore; };

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

    technique Singapore_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}