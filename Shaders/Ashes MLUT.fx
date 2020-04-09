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
	#define fLUT_TextureName "Ashes MLUT.png"
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

namespace MLUT_MultiLUT_Ashes
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items=" Dillon 01\0 Dillon 01_S\0 Dillon 02\0 Dillon 02_S\0 Dillon 03\0 Dillon 03_S\0 Dillon 04\0 Dillon 04_S\0 Dillon 05\0 Dillon 05_S\0 Dillon 06\0 Dillon 06_S\0 Dillon 07\0 Dillon 07_S\0 Dillon 08\0 Dillon 08_S\0 Dillon 09\0 Dillon 09_S\0 Dillon 10\0 Dillon 10_S\0 Mankato 01\0 Mankato 01_S\0 Mankato 02\0 Mankato 02_S\0 Mankato 03\0 Mankato 03_S\0 Mankato 04\0 Mankato 04_S\0 Mankato 05\0 Mankato 05_S\0 Mankato 06\0 Mankato 06_S\0 Mankato 07\0 Mankato 07_S\0 Mankato 08\0 Mankato 08_S\0 Mankato 09\0 Mankato 09_S\0 Mankato 10\0 Mankato 10_S\0 Mesa 01\0 Mesa 01_S\0 Mesa 02\0 Mesa 02_S\0 Mesa 03\0 Mesa 03_S\0 Mesa 04\0 Mesa 04_S\0 Mesa 05\0 Mesa 05_S\0 Mesa 06\0 Mesa 06_S\0 Mesa 07\0 Mesa 07_S\0 Mesa 08\0 Mesa 08_S\0 Mesa 09\0 Mesa 09_S\0 Mesa 10\0 Mesa 10_S\0 Pecos 01\0 Pecos 01_S\0 Pecos 02\0 Pecos 02_S\0 Pecos 03\0 Pecos 03_S\0 Pecos 04\0 Pecos 04_S\0 Pecos 05\0 Pecos 05_S\0 Pecos 06\0 Pecos 06_S\0 Pecos 07\0 Pecos 07_S\0 Pecos 08\0 Pecos 08_S\0 Pecos 09\0 Pecos 09_S\0 Pecos 10\0 Pecos 10_S\0 Westerly 01\0 Westerly 01_S\0 Westerly 02\0 Westerly 02_S\0 Westerly 03\0 Westerly 03_S\0 Westerly 04\0 Westerly 04_S\0 Westerly 05\0 Westerly 05_S\0 Westerly 06\0 Westerly 06_S\0 Westerly 07\0 Westerly 07_S\0 Westerly 08\0 Westerly 08_S\0 Westerly 09\0 Westerly 09_S\0 Westerly 10\0 Westerly 10_S\0"; 
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

    texture texMultiLUT_MLUT_pd80_Ashes < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_Ashes; };

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

    technique Ashes_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}