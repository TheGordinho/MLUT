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
	#define fLUT_TextureName "Sea Salt MLUT.png"
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

namespace MLUT_MultiLUT_Sea_Salt
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

uniform int fLUT_LutSelector < 
	ui_type = "combo";
	ui_min= 0; ui_max=16;
	ui_items=" Beach 01\0 Beach 01_S\0 Beach 02\0 Beach 02_S\0 Beach 03\0 Beach 03_S\0 Beach 04\0 Beach 04_S\0 Beach 05\0 Beach 05_S\0 Beach 06\0 Beach 06_S\0 Beach 07\0 Beach 07_S\0 Beach 08\0 Beach 08_S\0 Beach 09\0 Beach 09_S\0 Beach 10\0 Beach 10_S\0 Blossoms 01\0 Blossoms 01_S\0 Blossoms 02\0 Blossoms 02_S\0 Blossoms 03\0 Blossoms 03_S\0 Blossoms 04\0 Blossoms 04_S\0 Blossoms 05\0 Blossoms 05_S\0 Blossoms 06\0 Blossoms 06_S\0 Blossoms 07\0 Blossoms 07_S\0 Blossoms 08\0 Blossoms 08_S\0 Blossoms 09\0 Blossoms 09_S\0 Blossoms 10\0 Blossoms 10_S\0 Breezy 01\0 Breezy 01_S\0 Breezy 02\0 Breezy 02_S\0 Breezy 03\0 Breezy 03_S\0 Breezy 04\0 Breezy 04_S\0 Breezy 05\0 Breezy 05_S\0 Breezy 06\0 Breezy 06_S\0 Breezy 07\0 Breezy 07_S\0 Breezy 08\0 Breezy 08_S\0 Breezy 09\0 Breezy 09_S\0 Breezy 10\0 Breezy 10_S\0 Solemn 01\0 Solemn 01_S\0 Solemn 02\0 Solemn 02_S\0 Solemn 03\0 Solemn 03_S\0 Solemn 04\0 Solemn 04_S\0 Solemn 05\0 Solemn 05_S\0 Solemn 06\0 Solemn 06_S\0 Solemn 07\0 Solemn 07_S\0 Solemn 08\0 Solemn 08_S\0 Solemn 09\0 Solemn 09_S\0 Solemn 10\0 Solemn 10_S\0 Turqoise 01\0 Turqoise 01_S\0 Turqoise 02\0 Turqoise 02_S\0 Turqoise 03\0 Turqoise 03_S\0 Turqoise 04\0 Turqoise 04_S\0 Turqoise 05\0 Turqoise 05_S\0 Turqoise 06\0 Turqoise 06_S\0 Turqoise 07\0 Turqoise 07_S\0 Turqoise 08\0 Turqoise 08_S\0 Turqoise 09\0 Turqoise 09_S\0 Turqoise 10\0 Turqoise 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Sea_Salt < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Sea_Salt; };

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

    technique Sea_Salt_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}