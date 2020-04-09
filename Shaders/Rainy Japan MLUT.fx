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
	#define fLUT_TextureName "Rainy Japan MLUT.png"
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

namespace MLUT_MultiLUT_Rainy_Japan
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Akihabara 01\0 Akihabara 01_S\0 Akihabara 02\0 Akihabara 02_S\0 Akihabara 03\0 Akihabara 03_S\0 Akihabara 04\0 Akihabara 04_S\0 Akihabara 05\0 Akihabara 05_S\0 Akihabara 06\0 Akihabara 06_S\0 Akihabara 07\0 Akihabara 07_S\0 Akihabara 08\0 Akihabara 08_S\0 Akihabara 09\0 Akihabara 09_S\0 Akihabara 10\0 Akihabara 10_S\0 Asakusa 01\0 Asakusa 01_S\0 Asakusa 02\0 Asakusa 02_S\0 Asakusa 03\0 Asakusa 03_S\0 Asakusa 04\0 Asakusa 04_S\0 Asakusa 05\0 Asakusa 05_S\0 Asakusa 06\0 Asakusa 06_S\0 Asakusa 07\0 Asakusa 07_S\0 Asakusa 08\0 Asakusa 08_S\0 Asakusa 09\0 Asakusa 09_S\0 Asakusa 10\0 Asakusa 10_S\0 Ginza 01\0 Ginza 01_S\0 Ginza 02\0 Ginza 02_S\0 Ginza 03\0 Ginza 03_S\0 Ginza 04\0 Ginza 04_S\0 Ginza 05\0 Ginza 05_S\0 Ginza 06\0 Ginza 06_S\0 Ginza 07\0 Ginza 07_S\0 Ginza 08\0 Ginza 08_S\0 Ginza 09\0 Ginza 09_S\0 Ginza 10\0 Ginza 10_S\0 Harajuku 01\0 Harajuku 01_S\0 Harajuku 02\0 Harajuku 02_S\0 Harajuku 03\0 Harajuku 03_S\0 Harajuku 04\0 Harajuku 04_S\0 Harajuku 05\0 Harajuku 05_S\0 Harajuku 06\0 Harajuku 06_S\0 Harajuku 07\0 Harajuku 07_S\0 Harajuku 08\0 Harajuku 08_S\0 Harajuku 09\0 Harajuku 09_S\0 Harajuku 10\0 Harajuku 10_S\0 Shibuya 01\0 Shibuya 01_S\0 Shibuya 02\0 Shibuya 02_S\0 Shibuya 03\0 Shibuya 03_S\0 Shibuya 04\0 Shibuya 04_S\0 Shibuya 05\0 Shibuya 05_S\0 Shibuya 06\0 Shibuya 06_S\0 Shibuya 07\0 Shibuya 07_S\0 Shibuya 08\0 Shibuya 08_S\0 Shibuya 09\0 Shibuya 09_S\0 Shibuya 10\0 Shibuya 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Rainy_Japan < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Rainy_Japan; };

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

    technique Rainy_Japan_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}