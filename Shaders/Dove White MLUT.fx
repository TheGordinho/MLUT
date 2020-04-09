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
	#define fLUT_TextureName "Dove White MLUT.png"
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

namespace MLUT_MultiLUT_Dove_White
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Bright Whites 01\0 Bright Whites 01_S\0 Bright Whites 02\0 Bright Whites 02_S\0 Bright Whites 03\0 Bright Whites 03_S\0 Bright Whites 04\0 Bright Whites 04_S\0 Bright Whites 05\0 Bright Whites 05_S\0 Bright Whites 06\0 Bright Whites 06_S\0 Bright Whites 07\0 Bright Whites 07_S\0 Bright Whites 08\0 Bright Whites 08_S\0 Bright Whites 09\0 Bright Whites 09_S\0 Bright Whites 10\0 Bright Whites 10_S\0 Foodie Clean 01\0 Foodie Clean 01_S\0 Foodie Clean 02\0 Foodie Clean 02_S\0 Foodie Clean 03\0 Foodie Clean 03_S\0 Foodie Clean 04\0 Foodie Clean 04_S\0 Foodie Clean 05\0 Foodie Clean 05_S\0 Foodie Clean 06\0 Foodie Clean 06_S\0 Foodie Clean 07\0 Foodie Clean 07_S\0 Foodie Clean 08\0 Foodie Clean 08_S\0 Foodie Clean 09\0 Foodie Clean 09_S\0 Foodie Clean 10\0 Foodie Clean 10_S\0 Gray Blogger 01\0 Gray Blogger 01_S\0 Gray Blogger 02\0 Gray Blogger 02_S\0 Gray Blogger 03\0 Gray Blogger 03_S\0 Gray Blogger 04\0 Gray Blogger 04_S\0 Gray Blogger 05\0 Gray Blogger 05_S\0 Gray Blogger 06\0 Gray Blogger 06_S\0 Gray Blogger 07\0 Gray Blogger 07_S\0 Gray Blogger 08\0 Gray Blogger 08_S\0 Gray Blogger 09\0 Gray Blogger 09_S\0 Gray Blogger 10\0 Gray Blogger 10_S\0 Minimal 01\0 Minimal 01_S\0 Minimal 02\0 Minimal 02_S\0 Minimal 03\0 Minimal 03_S\0 Minimal 04\0 Minimal 04_S\0 Minimal 05\0 Minimal 05_S\0 Minimal 06\0 Minimal 06_S\0 Minimal 07\0 Minimal 07_S\0 Minimal 08\0 Minimal 08_S\0 Minimal 09\0 Minimal 09_S\0 Minimal 10\0 Minimal 10_S\0 Peachy Light 01\0 Peachy Light 01_S\0 Peachy Light 02\0 Peachy Light 02_S\0 Peachy Light 03\0 Peachy Light 03_S\0 Peachy Light 04\0 Peachy Light 04_S\0 Peachy Light 05\0 Peachy Light 05_S\0 Peachy Light 06\0 Peachy Light 06_S\0 Peachy Light 07\0 Peachy Light 07_S\0 Peachy Light 08\0 Peachy Light 08_S\0 Peachy Light 09\0 Peachy Light 09_S\0 Peachy Light 10\0 Peachy Light 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Dove_White < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Dove_White; };

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

    technique Dove_White_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}