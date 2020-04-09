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
	#define fLUT_TextureName "IWLTBAP Standart 1 MLUT.png"
#endif
#ifndef fLUT_TileSizeXY
	#define fLUT_TileSizeXY 33
#endif
#ifndef fLUT_TileAmount
	#define fLUT_TileAmount 33
#endif
#ifndef fLUT_LutAmount
	#define fLUT_LutAmount 104
#endif


#include "ReShade.fxh"

namespace MLUT_MultiLUT_IWLTBAP_Stanadart_1
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=16;
		ui_items="B-7000-STD\0B-7010-STD\0B-7020-STD\0B-7030-STD\0B-7040-STD\0C-6960-STD\0C-8010-STD\0C-8020-STD\0C-8070-STD\0C-8080-STD\0C-8100-STD\0C-8110-STD\0C-8120-STD\0C-8290-STD\0C-8300-STD\0C-8430-STD\0C-8460-STD\0C-8690-STD\0C-8750-STD\0C-8760-STD\0C-8920-STD\0C-8960-STD\0C-9020-STD\0C-9030-STD\0C-9100-STD\0C-9170-STD\0C-9350-STD\0C-9560-STD\0C-9730-STD\0C-9750-STD\0C-9760-STD\0C-9840-STD\0C-9850-STD\0F-6880-STD\0F-6890-STD\0F-6900-STD\0F-6930-STD\0F-6970-STD\0F-6980-STD\0F-6990-STD\0F-8000-STD\0F-8030-STD\0F-8060-STD\0F-8130-STD\0F-8140-STD\0F-8150-STD\0F-8160-STD\0F-8170-STD\0F-8180-STD\0F-8181-STD\0F-8190-STD\0F-8230-STD\0F-8240-STD\0F-8310-STD\0F-8320-STD\0F-8330-STD\0F-8340-STD\0F-8350-STD\0F-8410-STD\0F-8450-STD\0F-8500-STD\0F-8530-STD\0F-8540-STD\0F-8560-STD\0F-8610-STD\0F-8630-STD\0F-8640-STD\0F-8680-STD\0F-8700-STD\0F-8700-V2-STD\0F-8710-STD\0F-8720-STD\0F-8840-STD\0F-8860-STD\0F-8870-STD\0F-8900-STD\0F-8940-STD\0F-8990-STD\0F-9070-STD\0F-9080-STD\0F-9160-STD\0F-9180-STD\0F-9190-STD\0F-9230-STD\0F-9240-STD\0F-9300-STD\0F-9310-STD\0F-9340-STD\0F-9380-STD\0F-9420-STD\0F-9440-STD\0F-9490-STD\0F-9550-STD\0F-9590-STD\0F-9600-STD\0F-9650-STD\0F-9670-STD\0F-9680-STD\0F-9720-STD\0F-9790-STD\0F-9820-STD\0F-9860-STD\0F-9870-STD\0F-9880-STD\0";
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

    texture texMultiLUT_MLUT_pd80_IWLTBAP_Stanadart_1 < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_IWLTBAP_Stanadart_1; };

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

    technique IWLTBAP_Stanadart_1_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}