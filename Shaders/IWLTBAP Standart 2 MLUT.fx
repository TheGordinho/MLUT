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
// LUTs created by IWLTBAP 
// Converted by TheGordinho 
// Thanks to kingeric1992 and Matsilagi for the tools
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#ifndef fLUT_TextureName
	#define fLUT_TextureName "IWLTBAP Standart 2 MLUT.png"
#endif
#ifndef fLUT_TileSizeXY
	#define fLUT_TileSizeXY 33
#endif
#ifndef fLUT_TileAmount
	#define fLUT_TileAmount 33
#endif
#ifndef fLUT_LutAmount
	#define fLUT_LutAmount 105
#endif


#include "ReShade.fxh"

namespace MLUT_MultiLUT_IWLTBAP_Stanadart_2
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items="H-8040-STD\0H-8440-STD\0H-8520-STD\0H-8600-STD\0H-8790-STD\0H-9000-STD\0H-9010-STD\0H-9060-STD\0H-9110-STD\0H-9120-STD\0H-9150-STD\0H-9210-STD\0H-9290-STD\0H-9470-STD\0H-9700-STD\0W-6920-STD\0W-6940-STD\0W-6950-STD\0W-8050-STD\0W-8200-STD\0W-8210-STD\0W-8250-STD\0W-8360-STD\0W-8370-STD\0W-8380-STD\0W-8390-STD\0W-8400-STD\0W-8420-STD\0W-8480-STD\0W-8510-STD\0W-8550-STD\0W-8570-STD\0W-8590-STD\0W-8620-STD\0W-8650-STD\0W-8660-STD\0W-8670-STD\0W-8730-STD\0W-8780-STD\0W-8800-STD\0W-8810-STD\0W-8830-STD\0W-8880-STD\0W-8910-STD\0W-8950-STD\0W-8970-STD\0W-9090-STD\0W-9130-STD\0W-9140-STD\0W-9200-STD\0W-9270-STD\0W-9280-STD\0W-9320-STD\0W-9410-STD\0W-9430-STD\0W-9480-STD\0W-9500-STD\0W-9520-STD\0W-9530-STD\0W-9540-STD\0W-9570-STD\0W-9630-STD\0W-9660-STD\0W-9690-STD\0W-9710-STD\0W-9740-STD\0W-9770-STD\0W-9830-STD\0X-6870-STD\0X-6910-STD\0X-8090-STD\0X-8220-STD\0X-8260-STD\0X-8270-STD\0X-8280-STD\0X-8470-STD\0X-8490-STD\0X-8580-STD\0X-8740-STD\0X-8770-STD\0X-8820-STD\0X-8850-STD\0X-8890-STD\0X-8930-STD\0X-8980-STD\0X-9040-STD\0X-9050-STD\0X-9220-STD\0X-9250-STD\0X-9260-STD\0X-9330-STD\0X-9360-STD\0X-9370-STD\0X-9390-STD\0X-9400-STD\0X-9450-STD\0X-9460-STD\0X-9510-STD\0X-9580-STD\0X-9610-STD\0X-9620-STD\0X-9640-STD\0X-9780-STD\0X-9800-STD\0X-9810-STD\0";
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

    texture texMultiLUT_MLUT_pd80_IWLTBAP_Stanadart_2 < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_IWLTBAP_Stanadart_2; };

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

    technique MultiLUT_MLUT_IWLTBAP_Stanadart_2
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}