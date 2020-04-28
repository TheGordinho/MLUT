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
	#define fLUT_TextureName "Triune Digital Fantasy MLUT.png"
#endif
#ifndef fLUT_TileSizeXY
	#define fLUT_TileSizeXY 33
#endif
#ifndef fLUT_TileAmount
	#define fLUT_TileAmount 33
#endif
#ifndef fLUT_LutAmount
	#define fLUT_LutAmount 45
#endif


#include "ReShade.fxh"

namespace MLUT_MultiLUT_Triune_Digital_Fantasy
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


	uniform int fLUT_LutSelector < 
		ui_type = "combo";
		ui_min= 0; ui_max=45;
		ui_items=" 300\0 A Monster Calls\0 Alice in Wonderland\0 Beauty and the Beast\0 Big Fish\0 Bridge to Terabithia\0 Charlie and the Chocolate Factory\0 Clash of the Titans\0 Conan the Barbarian\0 Excalibur\0 Game of Thrones (Castle Black)\0 Game of Thrones (Dothraki)\0 Game of Thrones (Dragon Stone)\0 Game of Thrones (Kings Landing)\0 Harry Potter\0 Highlander\0 Jumanji\0 Labyrinth\0 Ladyhawke\0 Life of Pi\0 Mary Poppins\0 Mr Magoriums Wonder Emporium\0 Pan's Labyrinth\0 Peter Pan\0 Pirates of the Caribbean\0 Sleepy Hollow\0 Solomon Kane\0 Stardust\0 Tale of Tales\0 The Chronicles of Narnia\0 The City of Lost Children\0 The Dark Crystal\0 The Hobbit\0 The Imaginarium of Doctor Parnassus\0 The Lord of the Rings\0 The Neverending Story\0 The Princess Bride\0 The Spiderwick Chronicles\0 The Witches of Eastwick\0 The Wizard of Oz\0 Time Bandits\0 Where the Wild Things Are\0 Willow\0 Willy Wonka\0 Zathura\0";
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

    texture texMultiLUT_MLUT_Triune_Digital_Fantasy < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_Triune_Digital_Fantasy; };

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

    technique Triune_Digital_Fantasy_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}