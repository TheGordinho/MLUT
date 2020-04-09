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
// Originally created by napoleonofthestump https://www.nexusmods.com/skyrim/mods/92833
// Converted to reshade by TheGordinho
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#ifndef fLUT_TextureName
	#define fLUT_TextureName "RevoLUTion MLUT.png"
#endif
#ifndef fLUT_TileSizeXY
	#define fLUT_TileSizeXY 16
#endif
#ifndef fLUT_TileAmount
	#define fLUT_TileAmount 16
#endif
#ifndef fLUT_LutAmount
	#define fLUT_LutAmount 126
#endif


#include "ReShade.fxh"

namespace MLUT_MultiLUT_RevoLUTion
{
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

uniform int fLUT_LutSelector < 
	ui_type = "combo";
	ui_min= 0; ui_max=16;
	ui_items="Default\0blucon\0Boreal\0Cecropia\0Celeste\0Chordate\0Cicada\0cinematic_1_lut\0cinematic_2_lut\0cinematic_legacy_lut\0Cleanbean\0Coldbrew\0Deckard\0EyeOn_lut_00\0EyeOn_lut_105\0EyeOn_lut_120\0EyeOn_lut_135\0EyeOn_lut_15\0EyeOn_lut_150\0EyeOn_lut_165\0EyeOn_lut_180\0EyeOn_lut_195\0EyeOn_lut_210\0EyeOn_lut_225\0EyeOn_lut_240\0EyeOn_lut_255\0EyeOn_lut_270\0EyeOn_lut_285\0EyeOn_lut_30\0EyeOn_lut_300\0EyeOn_lut_315\0EyeOn_lut_330\0EyeOn_lut_345\0EyeOn_lut_45\0EyeOn_lut_60\0EyeOn_lut_75\0EyeOn_lut_90\0Grandad\0Guillemot\0Habrok\0Homestead\0ImpulZ_Rec709_Fuji_Pro_400_FC\0ImpulZ_Rec709_Fuji_Superior_200_FC\0ImpulZ_Rec709_FujiColor_200_FC\0ImpulZ_Rec709_Kodak_Ektar_100_FC\0ImpulZ_Rec709_Kodak_Elite_Chrome_200_FC\0ImpulZ_Rec709_Kodak_Elite_Color_200_FC\0ImpulZ_Rec709_Kodak_Gold_Gen6_200_FC\0ImpulZ_Rec709_Kodak_Ultramax_400_FC\0ImpulZ_Rec709_Kodak_Vis3_200T_5213_NEG_FC\0ImpulZ_Rec709_Kodak_Vis3_250D_5207_NEG_FC\0ImpulZ_Rec709_Kodak_Vis3_500T_5219_C41_FC\0ImpulZ_Rec709_Kodak_Vis3_500T_5219_NEG_FC\0ImpulZ_Rec709_Kodak_Vis3_50D_5203_DP_FC\0ImpulZ_Rec709_Kodak_Vis3_50D_5203_NEG_FC\0ImpulZ_Rec709_Lomo_Color_Implosion_21_FC\0ImpulZ_Rec709_LPP_Tetrachrome_400_FC\0jedi_knight2_lut\0Koji_Arri_LogC_to_Rec709_2383\0Koji_Blackmagic_BMDFilm_to_Rec709_2383\0Koji_Blackmagic_BMDFilmV2_to_Rec709_2383\0Koji_Blackmagic_BMPC4KFilm_to_Rec709_2383\0Koji_Blackmagic_Rec709_to_Rec709_2383\0Koji_Canon_Cseries_CLog_to_Rec709_2383\0Koji_Canon_Cseries_Rec709_to_Rec709_2383\0Koji_Canon_DSLR_Rec709_to_Rec709_2383\0Koji_Generic_Cineon_to_Cineon_2383\0Koji_Generic_Cineon_to_P3_2383\0Koji_Generic_Rec709_to_Rec709_2383\0Koji_Panasonic_GHseries_Rec709_to_Rec709_2383\0Koji_RED_Rec709_to_Rec709_2383\0Koji_RED_REDlogFilm_to_Rec709_2383\0Koji_RED_REDlogFilm_to_REDlogFilm_2383\0Koji_Sony_Rec709_to_Rec709_2383_cube\0Koji_Sony_SLog3Sgamut3Cine_to_Cine709_2383\0Koji_Sony_SLog3Sgamut3Cine_to_LC709TypeA_2383\0Koji_Sony_SLog3Sgamut3Cine_to_LC709_2383\0Koji_Sony_SLog3Sgamut3Cine_to_SLog2709_2383\0Limestone\0\0Marble\0Megaloceros\0Mercury\0Mudpuppy\0Neumann_Cave_Dwellers\0Neumann_Cinema\0Neumann_HoboCop\0Neumann_Man_of_Teal\0Neumann_Monsters_and_Robots\0Neumann_Post-Ap\0Neumann_The_Great_War\0Neumann_The_Halfling\0Neumann_The_Wes_Look\0Neumann_Vintage_Vibrance\0November\0OSIRIS_DELTA\0OSIRIS_DK79\0OSIRIS_JUGO\0OSIRIS_KDX\0OSIRIS_M31\0OSIRIS_PRISMO\0OSIRIS_Vision_4\0OSIRIS_Vision_6\0OSIRIS_Vision_X\0Parchment\0Peachy_Keen\0Petrichor\0Polypore\0ravage\0rich\0Samhain\0Sassafra\0Steppe\0Taiga\0Tlilxochitl\0torchlight2_lut\0Vamp\0XIX_Chrysotype\0XIX_Ferrotype\0XIX_Half-plate_Tintype\0XIX_Oil_Print\0XIX_Platinum_Palladium_Print\0XIX_Resinotype\0XIX_Silver_Gelatin_Dry\0XIX_Tintype_Classic\0XIX_Ziatype\0Zebra\0";
	ui_label = "The LUT to use";
	ui_tooltip = "The LUT to use for color transformation. 'Default' doesn't do any color transformation.";
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

    texture texMultiLUT_MLUT_pd80_RevoLUTion < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY * fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
    sampler	SamplerMultiLUT { Texture = texMultiLUT_MLUT_pd80_RevoLUTion; };

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

    technique RevoLUTion_MLUT
    {
        pass MultiLUT_Apply
        {
            VertexShader = PostProcessVS;
            PixelShader  = PS_MultiLUT_Apply;
        }
    }
}