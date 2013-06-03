%%
%%  wpc_yafaray.erl
%%
%%     YafaRay Plugin User Interface.
%%
%%  Copyright (c) 2003-2008 Raimo Niskanen
%%  Code Converted from Yafray to YafaRay by Bernard Oortman (Wings3d user oort)
%%  Meshlight Export Perfected with Assistance from Micheus
%%  See the file "license.terms" for information on usage and redistribution
%%  of this file, and for a DISCLAIMER OF ALL WARRANTIES.
%%
%%

-module(wpc_yafaray).
-export([init/0,menu/2,dialog/2,command/2]).

%% Debug exports
%% -export([now_diff_1/1]).

-include_lib("kernel/include/file.hrl").
-include("e3d.hrl").
-include("e3d_image.hrl").
-include("wings.hrl").

-import(lists, [reverse/1,reverse/2,sort/1,keydelete/3,
        foreach/2,foldl/3,foldr/3]).
-compile({no_auto_import,[max/2]}).

-define(TAG, yafaray).
-define(KEY(K), {?TAG,(K)}).
-define(TAG_RENDER, yafaray_render).

key(Key) -> {key,?KEY(Key)}.

-define(NONZERO, 1.0e-10).

%%% Default values
-define(DEF_DIALOGS, auto).
-define(DEF_RENDERER, "yafaray-xml").
-define(DEF_OPTIONS, "").
-define(DEF_THREADS_AUTO, true).
-define(DEF_THREADS_NUMBER, 1).
-define(DEF_SUBDIVISIONS, 0).
-define(DEF_KEEP_XML, false).
-define(DEF_SAVE_ALPHA, false).
-define(DEF_GAMMA, 1.0).
-define(DEF_EXPOSURE, 1.4).
-define(DEF_RENDER_FORMAT, tga).
-define(DEF_EXR_FLAG_COMPRESSION, compression_zip).

%% Shader
-define(DEF_SHADER_TYPE, shinydiffuse).
-define(DEF_TIR, false).
-define(DEF_GLASS_IR_DEPTH, 3).
-define(DEF_IOR, 1.4).
-define(DEF_MIN_REFLE, 0.0).
-define(DEF_OBJECT_TYPE, mesh).
-define(DEF_VOLUME_TYPE, uniformvolume).
-define(DEF_VOLUME_SIGMA_A, 0.4).
-define(DEF_VOLUME_SIGMA_S, 0.05).
-define(DEF_VOLUME_HEIGHT, 0.5).
-define(DEF_VOLUME_STEEPNESS, 0.2).
-define(DEF_VOLUME_ATTGRIDSCALE, 3).
-define(DEF_VOLUME_SHARPNESS, 2.0).
-define(DEF_VOLUME_COVER, 0.05).
-define(DEF_VOLUME_DENSITY, 1.0).
-define(DEF_VOLUME_MINMAX_X, 2.0).
-define(DEF_VOLUME_MINMAX_Y, 2.0).
-define(DEF_VOLUME_MINMAX_Z, 2.0).
-define(DEF_MESHLIGHT_POWER, 5.0).
-define(DEF_MESHLIGHT_SAMPLES, 16).
-define(DEF_MESHLIGHT_COLOR, {1.0,1.0,1.0}).
-define(DEF_MESHLIGHT_DOUBLE_SIDED, false).
-define(DEF_USE_HARDNESS, false).
-define(DEF_AUTOSMOOTH, true).
-define(DEF_AUTOSMOOTH_ANGLE, 60.0).
-define(DEF_SSS_ABSORPTION_COLOR, {0.649,0.706,0.655}).
-define(DEF_SCATTER_COLOR, {0.599,0.680,0.511}).
-define(DEF_SSS_SPECULAR_COLOR, {1.0,1.0,1.0}).
-define(DEF_ABSORPTION_DIST, 3.0).
-define(DEF_DISPERSION_POWER, 0.0).
-define(DEF_DISPERSION_SAMPLES, 10).
-define(DEF_DISPERSION_JITTER, false).
-define(DEF_FAKE_SHADOWS, false).
-define(DEF_TRANSPARENCY, 0.0).
-define(DEF_TRANSMIT_FILTER, 0.5).
-define(DEF_TRANSLUCENCY, 0.0).
-define(DEF_SSS_TRANSLUCENCY, 1.0).
-define(DEF_SIGMAS_FACTOR, 1.0).
-define(DEF_DIFFUSE_REFLECT, 0.2).
-define(DEF_SPECULAR_REFLECT, 0.0).
-define(DEF_GLOSSY_REFLECT, 0.01).
-define(DEF_EMIT, 0.0).
-define(DEF_EXPONENT, 25.0).
-define(DEF_ANISOTROPIC, false).
-define(DEF_ANISOTROPIC_U, 5.0).
-define(DEF_ANISOTROPIC_V, 1500.0).
-define(DEF_ROUGHNESS, 0.2).
-define(DEF_LIGHTMAT_POWER, 0.9).
-define(DEF_BLEND_MAT1, "New Material").
-define(DEF_BLEND_MAT2, "New Material 2").
-define(DEF_BLEND_VALUE, 0.5).
-define(DEF_OREN_NAYAR, false).
-define(DEF_OREN_NAYAR_SIGMA, 0.25).

%% Arealight
-define(DEF_AREALIGHT, false).
-define(DEF_AREALIGHT_SAMPLES, 50).
-define(DEF_AREALIGHT_PSAMPLES, 0).
-define(DEF_DUMMY, false).
-define(DEF_QMC_METHOD, 0).
-define(DEF_AREALIGHT_RADIUS, 1.0).

%% Render
-define(DEF_LIGHTING_METHOD, directlighting).
-define(DEF_PM_DIFFUSE_PHOTONS, 500000).
-define(DEF_PM_BOUNCES, 5).
-define(DEF_PM_SEARCH, 100).
-define(DEF_PM_DIFFUSE_RADIUS, 1.0).
-define(DEF_PM_CAUSTIC_PHOTONS, 500000).
-define(DEF_PM_CAUSTIC_RADIUS, 1.0).
-define(DEF_PM_CAUSTIC_MIX, 100).
-define(DEF_PM_USE_BACKGROUND, true).
-define(DEF_PM_USE_FG, true).
-define(DEF_PM_FG_BOUNCES, 3).
-define(DEF_PM_FG_SAMPLES, 100).
-define(DEF_PM_FG_SHOW_MAP, false).
-define(DEF_PT_DIFFUSE_PHOTONS, 500000).
-define(DEF_PT_BOUNCES, 5).
-define(DEF_PT_CAUSTIC_TYPE, path).
-define(DEF_PT_CAUSTIC_RADIUS, 1.0).
-define(DEF_PT_CAUSTIC_MIX, 100).
-define(DEF_PT_CAUSTIC_DEPTH, 10).
-define(DEF_PT_USE_BACKGROUND, true).
-define(DEF_PT_SAMPLES, 32).
-define(DEF_VOLINTEGR_TYPE, none).
-define(DEF_VOLINTEGR_ADAPTIVE, true).
-define(DEF_VOLINTEGR_OPTIMIZE, true).
-define(DEF_VOLINTEGR_STEPSIZE, 0.2).
-define(DEF_USE_SSS, false).
-define(DEF_SSS_PHOTONS, 1000).
-define(DEF_SSS_DEPTH, 15.0).
-define(DEF_SSS_SCALE, 2.0).
-define(DEF_SSS_SINGLESCATTER_SAMPLES, 32.0).
-define(DEF_USE_CAUSTICS, false).
-define(DEF_CAUSTIC_PHOTONS, 900000).
-define(DEF_CAUSTIC_DEPTH, 10).
-define(DEF_CAUSTIC_MIX, 200).
-define(DEF_CAUSTIC_RADIUS, 0.5).
-define(DEF_DO_AO, false).
-define(DEF_AO_DISTANCE, 5.0).
-define(DEF_AO_SAMPLES, 32.0).
-define(DEF_AO_COLOR, {1.0,1.0,1.0}).
-define(DEF_AA_PASSES, 3).
-define(DEF_AA_MINSAMPLES, 1).
-define(DEF_AA_PIXELWIDTH, 1.5).
-define(DEF_AA_THRESHOLD, 0.02).
-define(DEF_AA_JITTERFIRST, true).
-define(DEF_CLAMP_RGB, true).
-define(DEF_AA_FILTER_TYPE, box).
-define(DEF_TRANSPARENT_SHADOWS, false).
-define(DEF_BACKGROUND_TRANSP_REFRACT, true).
-define(DEF_SHADOW_DEPTH, 2).
-define(DEF_RAYDEPTH, 12).
-define(DEF_BIAS, 0.001).
-define(DEF_WIDTH, 200).
-define(DEF_HEIGHT, 200).
-define(DEF_LENS_TYPE, perspective).
-define(DEF_LENS_ORTHO_SCALE, 7.0).
-define(DEF_LENS_ANGULAR_CIRCULAR, true).
-define(DEF_LENS_ANGULAR_MIRRORED, false).
-define(DEF_LENS_ANGULAR_MAX_ANGLE, 90.0).
-define(DEF_LENS_ANGULAR_ANGLE, 90.0).
-define(DEF_APERTURE, 0.0).
-define(DEF_BOKEH_TYPE, triangle).
-define(DEF_BOKEH_BIAS, uniform).
-define(DEF_BOKEH_ROTATION, 0.0).
-define(DEF_DOF_DISTANCE, 7.0).

%% Light
-define(DEF_ATTN_POWER, 30.0).
-define(DEF_POINT_TYPE, pointlight).
-define(DEF_CAST_SHADOWS, true).
-define(DEF_USE_QMC, false).
-define(DEF_GLOW_INTENSITY, 0.0).
-define(DEF_GLOW_OFFSET, 0.0).
-define(DEF_GLOW_TYPE, 0).

%% Spotlight
-define(DEF_SPOT_TYPE, spotlight).
-define(DEF_CONE_ANGLE, 45.0).
-define(DEF_SPOT_EXPONENT, 2.0).
-define(DEF_BLEND, 0.5).
-define(DEF_SPOT_PHOTON_ONLY, false).
-define(DEF_SPOT_SOFT_SHADOWS, false).

%% IESlight
-define(DEF_SPOT_IES_FILENAME, "").
-define(DEF_SPOT_IES_SAMPLES, 16).

%% Photonlight
-define(DEF_MODE,caustic).
-define(DEF_PHOTONS,5000000).
-define(DEF_SEARCH,64).
-define(DEF_DEPTH,3).
-define(DEF_CAUS_DEPTH,4).
-define(DEF_DIRECT,false).
-define(DEF_MINDEPTH,1).
-define(DEF_FIXEDRADIUS,0.08).
-define(DEF_CLUSTER,0.01).

%% Softlight
-define(DEF_RES, 100).
-define(DEF_RADIUS, 1).

%% Sunlight
-define(DEF_POWER, 5.0).
-define(DEF_BACKGROUND, undefined).
-define(DEF_BACKGROUND_COLOR, {0.0,0.0,0.0}).
-define(DEF_CONSTANT_BACK_POWER, 1.0).
-define(DEF_HORIZON_COLOR, {1.0,1.0,1.0}).
-define(DEF_ZENITH_COLOR, {0.4,0.5,1.0}).
-define(DEF_GRADIENT_BACK_POWER, 1.0).
-define(DEF_TURBIDITY, 4.0).
-define(DEF_SUNSKY_VAR, 1.0).
-define(DEF_SUN_SAMPLES, 16).
-define(DEF_SUN_ANGLE, 0.5).
-define(DEF_SKY_BACKGROUND_LIGHT, false).
-define(DEF_SKY_BACKGROUND_POWER, 1.0).
-define(DEF_SKY_BACKGROUND_SAMPLES, 16).

%% Infinite Light
-define(DEF_INFINITE_TYPE, sunlight).
-define(DEF_INFINITE_TRUE, true).
-define(DEF_INFINITE_RADIUS, 1.0).

%% Hemilight and Pathlight
-define(DEF_AMBIENT_TYPE, hemilight).
-define(DEF_USE_MAXDISTANCE, false).
-define(DEF_MAXDISTANCE, 1.0).
-define(DEF_BACKGROUND_FILENAME, "").
-define(DEF_BACKGROUND_EXPOSURE_ADJUST, 1.0).
-define(DEF_BACKGROUND_MAPPING, probe).
-define(DEF_BACKGROUND_POWER, 5.0).
-define(DEF_BACKGROUND_PREFILTER, true).
-define(DEF_BACKGROUND_ENLIGHT, true).
-define(DEF_SAMPLES, 128).

%% Pathlight
-define(DEF_PATHLIGHT_MODE, undefined).
-define(DEF_CACHE, false).
-define(DEF_CACHE_SIZE, 0.01).
-define(DEF_ANGLE_THRESHOLD, 0.2).
-define(DEF_SHADOW_THRESHOLD, 0.3).
-define(DEF_GRADIENT, false).
-define(DEF_SHOW_SAMPLES, false).

%% Global Photonlight
-define(DEF_GLOBALPHOTONLIGHT_PHOTONS, 50000).
-define(DEF_GLOBALPHOTONLIGHT_RADIUS, 1.0).
-define(DEF_GLOBALPHOTONLIGHT_DEPTH, 2).
-define(DEF_GLOBALPHOTONLIGHT_SEARCH, 200).

%% Modulator
-define(DEF_MOD_ENABLED, true).
-define(DEF_MOD_MODE, mix).
-define(DEF_MOD_SIZE, 1.0).
-define(DEF_MOD_SIZE_X, 1.0).
-define(DEF_MOD_SIZE_Y, 1.0).
-define(DEF_MOD_SIZE_Z, 1.0).
-define(DEF_MOD_OPACITY, 1.0).
-define(DEF_MOD_DIFFUSE, 0.0).
-define(DEF_MOD_SPECULAR, 0.0).
-define(DEF_MOD_AMBIENT, 0.0).
-define(DEF_MOD_SHININESS, 0.0).
-define(DEF_MOD_NORMAL, 0.0).
-define(DEF_MOD_TYPE, image).
-define(DEF_MOD_FILENAME, "").
-define(DEF_MOD_COLOR1, {0.0,0.0,0.0}).
-define(DEF_MOD_COLOR2, {1.0,1.0,1.0}).
-define(DEF_MOD_DEPTH, 8).
-define(DEF_MOD_NOISEBASIS, blender).
-define(DEF_MOD_NOISESIZE, 1.75).
-define(DEF_MOD_HARD, true).
-define(DEF_MOD_TURBULENCE, 12.0).
-define(DEF_MOD_SHARPNESS, 15.0).
-define(DEF_MOD_WOODTYPE, rings).
-define(DEF_MOD_SHAPE, "sin").
-define(DEF_MOD_CELLTYPE, intensity).
-define(DEF_MOD_CELLSHAPE, actual).
-define(DEF_MOD_CELLSIZE, 4.0).
-define(DEF_MOD_INTENSITY, 1.0).
-define(DEF_MOD_CELL_WEIGHT1, 1.0).
-define(DEF_MOD_CELL_WEIGHT2, 0.0).
-define(DEF_MOD_CELL_WEIGHT3, 0.0).
-define(DEF_MOD_CELL_WEIGHT4, 0.0).
-define(DEF_MOD_MUSGRAVE_TYPE, multifractal).

-define(DEF_MOD_MUSGRAVE_NOISESIZE, 0.5).
-define(DEF_MOD_MUSGRAVE_INTENSITY, 2.0).
-define(DEF_MOD_MUSGRAVE_CONTRAST, 0.1).
-define(DEF_MOD_MUSGRAVE_LACUNARITY, 2.0).
-define(DEF_MOD_MUSGRAVE_OCTAVES, 8.0).
-define(DEF_MOD_DISTORTION_TYPE, blender).

-define(DEF_MOD_DISTORTION_INTENSITY, 10.0).
-define(DEF_MOD_DISTORTION_NOISESIZE, 1.0).
-define(DEF_MOD_ALPHA_INTENSITY, off).

range(T) -> {range,range_1(T)}.

%% Material ranges
range_1(volume_sigma_a)         -> {0.0,1.0};
range_1(volume_sigma_s)         -> {0.0,1.0};
range_1(volume_height)          -> {0.0,1000.0};
range_1(volume_steepness)       -> {0.0,10.0};
range_1(volume_attgridscale)    -> {1,5};
range_1(volume_sharpness)       -> {1.0,100.0};
range_1(volume_cover)           -> {0.0,1.0};
range_1(volume_density)         -> {0.0,1.0};
range_1(volume_minmax_x)        -> {1.0,1000.0};
range_1(volume_minmax_y)        -> {1.0,1000.0};
range_1(volume_minmax_z)        -> {1.0,1000.0};
range_1(meshlight_power)        -> {0.0,10000.0};
range_1(meshlight_samples)      -> {0,512};
range_1(autosmooth_angle)       -> {0.0,180.0};
range_1(ior)                    -> {0.0,3.0};
range_1(glass_ir_depth)         -> {0,32};
range_1(min_refle)              -> {0.0,1.0};
range_1(size)                   -> {0.0,infinity};
range_1(modulation)             -> {-5.0,5.0};
range_1(turbulence)             -> {?NONZERO,infinity};
range_1(scale)                  -> {?NONZERO,infinity};
range_1(cell_size)              -> {0.0,infinity};
range_1(intensity)              -> {0.010,infinity};
range_1(cell_weight1)           -> {-2.0,2.0};
range_1(cell_weight2)           -> {-2.0,2.0};
range_1(cell_weight3)           -> {-2.0,2.0};
range_1(cell_weight4)           -> {-2.0,2.0};
range_1(musgrave_noisesize)     -> {0.0,infinity};
range_1(musgrave_intensity)     -> {0.0,10.0};
range_1(musgrave_contrast)      -> {0.0,10.0};
range_1(musgrave_lacunarity)    -> {0.0,10.0};
range_1(musgrave_octaves)       -> {0.0,8.0};
range_1(distortion_intensity)   -> {0.0,10.0};
range_1(distortion_noisesize)   -> {0.0,infinity};
range_1(sharpness)              -> {1.0,infinity};
range_1(noise_depth)            -> {0,infinity};
range_1(noise_size)             -> {0.0,infinity};
range_1(absorption_dist)        -> {0.1,100.0};
range_1(dispersion_power)       -> {0.0,1.0};
range_1(dispersion_samples)     -> {1,512};
range_1(transparency)           -> {0.0,1.0};
range_1(transmit_filter)        -> {0.0,1.0};
range_1(translucency)           -> {0.0,1.0};
range_1(sss_translucency)       -> {0.0,1.0};
range_1(sigmas_factor)          -> {1.0,10.0};
range_1(diffuse_reflect)        -> {0.0,1.0};
range_1(specular_reflect)       -> {0.0,1.0};
range_1(glossy_reflect)         -> {0.0,1.0};
range_1(emit)                   -> {0.0,25.0};
range_1(exponent)               -> {1.0,2000.0};
range_1(anisotropic_u)          -> {1.0,2000.0};
range_1(anisotropic_v)          -> {1.0,2000.0};
range_1(roughness)              -> {0.0,1.0};
range_1(lightmat_power)         -> {0.0,10.0};
range_1(blend_value)            -> {0.0,1.0};
range_1(oren_nayar_sigma)       -> {0.0,1.0};

%% Light ranges
range_1(power)                  -> {0.0,infinity};
range_1(bias)                   -> {0.0,1.0};
range_1(res)                    -> {0,infinity};
range_1(radius)                 -> {0,infinity};
range_1(blur)                   -> {0.0,1.0};
range_1(samples)                -> {1,infinity};
range_1(spot_ies_samples)       -> {1,512};
range_1(glow_intensity)         -> {0.0,1.0};
range_1(glow_offset)            -> {0.0,infinity};
range_1(blend)                  -> {0.0,1.0};
range_1(photons)                -> {0,infinity};
range_1(depth)                  -> {0,infinity};
range_1(fixedradius)            -> {0.0,infinity};
range_1(search)                 -> {0,infinity};
range_1(cluster)                -> {0.0,infinity};
range_1(turbidity)              -> {0.0,infinity};
range_1(angle_threshold)        -> {0.0,1.0};
range_1(raydepth)               -> {1,infinity};
range_1(shadow_depth)           -> {1,64};
range_1(cache_size)             -> {0.0,infinity};
range_1(shadow_threshold)       -> {0.0,infinity};
range_1(cache_search)           -> {3,infinity};
range_1(exposure_adjust)        -> {0.0,50.0};
range_1(psamples)               -> {0,infinity};
range_1(arealight_radius)       -> {0.0,infinity};
range_1(maxdistance)            -> {0.0,infinity};
range_1(infinite_radius)        -> {0.0,infinity};
range_1(sun_samples)            -> {0,infinity};
range_1(sun_angle)              -> {0.0,80.0};
range_1(sky_background_power)   -> {0.0,infinity};
range_1(sky_background_samples) -> {0,infinity};

%% Render ranges
range_1(pm_diffuse_photons)     -> {1,100000000};
range_1(pm_bounces)             -> {0,50};
range_1(pm_search)              -> {1,10000};
range_1(pm_diffuse_radius)      -> {0.0,100.0};
range_1(pm_caustic_photons)     -> {1,100000000};
range_1(pm_caustic_radius)      -> {0.0,100.0};
range_1(pm_caustic_mix)         -> {1,10000};
range_1(pm_fg_bounces)          -> {1,20};
range_1(pm_fg_samples)          -> {1,4096};
range_1(pt_diffuse_photons)     -> {1,100000000};
range_1(pt_bounces)             -> {0,50};
range_1(pt_caustic_radius)      -> {0.0,100.0};
range_1(pt_caustic_mix)         -> {1,10000};
range_1(pt_caustic_depth)       -> {0,infinity};
range_1(pt_samples)             -> {1,4096};
range_1(sss_photons)            -> {0,infinity};
range_1(sss_depth)              -> {1.0,50.0};
range_1(sss_scale)              -> {0.0,100.0};
range_1(sss_singlescatter_samples)      -> {0.0,50.0};
range_1(caustic_photons)        -> {0,infinity};
range_1(caustic_depth)          -> {0,infinity};
range_1(caustic_mix)            -> {0,infinity};
range_1(caustic_radius)         -> {0.0,1.0};
range_1(ao_distance)            -> {1.0,100.0};
range_1(ao_samples)             -> {1.0,128.0};
range_1(volintegr_stepsize)     -> {0.0,100.0};
range_1(subdivisions)           -> {0,infinity};
range_1(threads_number)         -> {1,100};
range_1(aa_pixelwidth)          -> {1.0,2.0};
range_1(aa_passes)              -> {0,infinity};
range_1(aa_threshold)           -> {0.0,1.0};
range_1(aa_minsamples)          -> {1,infinity};
range_1(gamma)                  -> {0.0,infinity};
range_1(exposure)               -> {0.0,infinity};
range_1(pixels)                 -> {1,infinity};
range_1(lens_ortho_scale)       -> {0.0,100.0};
range_1(lens_angular_max_angle) -> {0.0,360.0};
range_1(lens_angular_angle)     -> {0.0,360.0};
range_1(aperture)               -> {0.0,infinity};
range_1(bokeh_rotation)         -> {-180.0,180.0};
range_1(dof_distance)           -> {0.0,250.0}.




%% Exported plugin callback functions
%%

init() ->
    init_pref(),
    set_var(rendering, false),
    true.

menu({file,export}, Menu) ->
    maybe_append(export, Menu, menu_entry(export));
menu({file,export_selected}, Menu) ->
    maybe_append(export, Menu, menu_entry(export));
menu({file,render}, Menu) ->
    maybe_append(render, Menu, menu_entry(render));
menu({edit,plugin_preferences}, Menu) ->
    Menu++menu_entry(pref);
menu(_, Menu) ->
    Menu.

command({file,{export,{?TAG,A}}}, St) ->
    command_file(export, A, St);
command({file,{export_selected,{?TAG,A}}}, St) ->
    command_file(export_selected, A, St);
command({file,{render,{?TAG,A}}}, St) ->
    command_file(render, A, St);
command({edit,{plugin_preferences,?TAG}}, St) ->
    pref_dialog(St);
command(_Spec, _St) ->
%    erlang:display({?MODULE,?LINE,Spec}),
    next.

dialog({material_editor_setup,Name,Mat}, Dialog) ->
    maybe_append(edit, Dialog, material_dialog(Name, Mat));
dialog({material_editor_result,Name,Mat}, Res) ->
    case is_plugin_active(edit) of
        false ->
            {Mat,Res};
        _ ->
            material_result(Name, Mat, Res)
    end;
dialog({light_editor_setup,Name,Ps}, Dialog) ->
    maybe_append(edit, Dialog, light_dialog(Name, Ps));
dialog({light_editor_result,Name,Ps0}, Res) ->
    case is_plugin_active(edit) of
    false ->
        {Ps0,Res};
    _ ->
        light_result(Name, Ps0, Res)
    end;
dialog(_X, Dialog) ->
    io:format("~p\n", [{_X,Dialog}]),
    Dialog.

%%
%% End of exported plugin callback functions


init_pref() ->
    Renderer = get_pref(renderer, ?DEF_RENDERER),
    RendererPath =
    case filename:pathtype(Renderer) of
        absolute ->
        Renderer;
        _ ->
        case wings_job:find_executable(Renderer) of
            false ->
            false;
            Path ->
            Path
        end
    end,
    case get_pref(dialogs, ?DEF_DIALOGS) of
    auto ->
        set_var(renderer, RendererPath),
        set_var(dialogs, case RendererPath of
                 false -> false;
                 _ -> true
                 end);
    enabled ->
        set_var(renderer, RendererPath),
        set_var(dialogs, true);
    disabled ->
        set_var(renderer, false),
        set_var(dialogs, false)
    end,
    ok.

maybe_append(Condition, Menu, PluginMenu) ->
    case {is_plugin_active(Condition),Menu} of
    {_,[plugin_manager_category]} ->
        Menu++PluginMenu;
    {false,_} ->
        Menu;
    {_,_} ->
        Menu++PluginMenu
    end.

is_plugin_active(Condition) ->
    case Condition of
    export ->
        get_var(dialogs);
    edit ->
        get_var(dialogs);
    render ->
        get_var(renderer)
    end.

menu_entry(render) ->
    [{"YafaRay",?TAG,[option]}];
menu_entry(export) ->
    [{"YafaRay (.xml)",?TAG,[option]}];
menu_entry(pref) ->
    [{"YafaRay",?TAG}].

command_file(render, Attr, St) when is_list(Attr) ->
    set_prefs(Attr),
    case get_var(rendering) of
    false ->
        do_export(export,
              props(render, Attr),
              [{?TAG_RENDER,true}|Attr], St);
    true ->
        wpa:error(?__(1,"Already rendering."))
    end;
command_file(render=Op, Ask, _St) when is_atom(Ask) ->
    export_dialog(Op, Ask, ?__(2,"YafaRay Render Options"),
          fun(Attr) -> {file,{Op,{?TAG,Attr}}} end);
command_file(Op, Attr, St) when is_list(Attr) ->
    %% when Op =:= export; Op =:= export_selected
    set_prefs(Attr),
    do_export(Op, props(Op, Attr), Attr, St);
command_file(Op, Ask, _St) when is_atom(Ask) ->
    export_dialog(Op, Ask, ?__(3,"YafaRay Export Options"),
           fun(Attr) -> {file,{Op,{?TAG,Attr}}} end).

-record(camera_info, {pos,dir,up,fov}).

do_export(Op, Props0, Attr0, St0) ->
    SubDiv = proplists:get_value(subdivisions, Attr0, ?DEF_SUBDIVISIONS),

    Props = [{subdivisions,SubDiv}|Props0],
    [{Pos,Dir,Up},Fov] = wpa:camera_info([pos_dir_up,fov]),
    CameraInfo = #camera_info{pos=Pos,dir=Dir,up=Up,fov=Fov},
    Attr = [CameraInfo,{lights,wpa:lights(St0)}|Attr0],
    ExportFun =
    fun (Filename, Contents) ->
        case catch export(Attr, Filename, Contents) of
            ok ->
            ok;
            Error ->
            io:format(?__(1,"ERROR: Failed to export")++":~n~p~n", [Error]),
            {error,?__(2,"Failed to export")}
        end
    end,
    %% Freeze virtual mirrors.
    Shapes0 = gb_trees:to_list(St0#st.shapes),
    Shapes = [{Id,wpa:vm_freeze(We)} || {Id,We} <- Shapes0],
    St = St0#st{shapes=gb_trees:from_orddict(Shapes)},
    wpa:Op(Props, ExportFun, St).

props(render, Attr) ->
    RenderFormat =
    proplists:get_value(render_format, Attr, ?DEF_RENDER_FORMAT),
    {value,{RenderFormat,Ext,Desc}} =
    lists:keysearch(RenderFormat, 1, wings_job:render_formats()),
    Title = case os:type() of
        {win32,_} -> "Render";
        _Other    -> ?__(1,"Render")
    end,
    [{title,Title},{ext,Ext},{ext_desc,Desc}];
props(export, _Attr) ->
    {Title,File} = case os:type() of
        {win32,_} -> {"Export","YafaRay File"};
        _Other    -> {?__(2,"Export"),?__(5,"YafaRay File")}
    end,
    [{title,Title},{ext,".xml"},{ext_desc,File}];
props(export_selected, _Attr) ->
    {Title,File} = case os:type() of
        {win32,_} -> {"Export Selected","YafaRay File"};
        _Other    -> {?__(4,"Export Selected"),?__(5,"YafaRay File")}
    end,
    [{title,Title},{ext,".xml"},{ext_desc,File}].



%%% Dialogues and results
%%%

%%% Object Specific Material Properties
%%%

material_dialog(_Name, Mat) ->
    Maps = proplists:get_value(maps, Mat, []),
    OpenGL = proplists:get_value(opengl, Mat),
    DefReflected = alpha(proplists:get_value(specular, OpenGL)),
    DefTransmitted = def_transmitted(proplists:get_value(diffuse, OpenGL)),
    DefAbsorptionColor = def_absorption_color(proplists:get_value(diffuse, OpenGL)),
    DefLightmatColor = def_lightmat_color(proplists:get_value(diffuse, OpenGL)),
    YafaRay = proplists:get_value(?TAG, Mat, []),
    Minimized = proplists:get_value(minimized, YafaRay, true),
    ObjectMinimized = proplists:get_value(object_minimized, YafaRay, true),
    DefShaderType = get_pref(shader_type, YafaRay),
    ShaderType =
    proplists:get_value(shader_type, YafaRay, DefShaderType),
%*    UseHardness = proplists:get_value(use_hardness, YafaRay, ?DEF_USE_HARDNESS),
    Object_Type = proplists:get_value(object_type, YafaRay, ?DEF_OBJECT_TYPE),
    Volume_Type = proplists:get_value(volume_type, YafaRay, ?DEF_VOLUME_TYPE),
    Volume_Sigma_a = proplists:get_value(volume_sigma_a, YafaRay, ?DEF_VOLUME_SIGMA_A),
    Volume_Sigma_s = proplists:get_value(volume_sigma_s, YafaRay, ?DEF_VOLUME_SIGMA_S),
    Volume_Height = proplists:get_value(volume_height, YafaRay, ?DEF_VOLUME_HEIGHT),
    Volume_Steepness = proplists:get_value(volume_steepness, YafaRay, ?DEF_VOLUME_STEEPNESS),
    Volume_Attgridscale = proplists:get_value(volume_attgridscale, YafaRay, ?DEF_VOLUME_ATTGRIDSCALE),
    Volume_Sharpness = proplists:get_value(volume_sharpness, YafaRay, ?DEF_VOLUME_SHARPNESS),
    Volume_Cover = proplists:get_value(volume_cover, YafaRay, ?DEF_VOLUME_COVER),
    Volume_Density = proplists:get_value(volume_density, YafaRay, ?DEF_VOLUME_DENSITY),
    Volume_Minmax_X = proplists:get_value(volume_minmax_x, YafaRay, ?DEF_VOLUME_MINMAX_X),
    Volume_Minmax_Y = proplists:get_value(volume_minmax_y, YafaRay, ?DEF_VOLUME_MINMAX_Y),
    Volume_Minmax_Z = proplists:get_value(volume_minmax_z, YafaRay, ?DEF_VOLUME_MINMAX_Z),
    Meshlight_Power = proplists:get_value(meshlight_power, YafaRay, ?DEF_MESHLIGHT_POWER),
    Meshlight_Samples = proplists:get_value(meshlight_samples, YafaRay, ?DEF_MESHLIGHT_SAMPLES),
    Meshlight_Color = proplists:get_value(meshlight_color, YafaRay, ?DEF_MESHLIGHT_COLOR),
    Meshlight_Double_Sided = proplists:get_value(meshlight_double_sided, YafaRay, ?DEF_MESHLIGHT_DOUBLE_SIDED),
    TIR = proplists:get_value(tir, YafaRay, ?DEF_TIR),
    AutosmoothAngle = proplists:get_value(autosmooth_angle, YafaRay, ?DEF_AUTOSMOOTH_ANGLE),
    Autosmooth = proplists:get_value(autosmooth, YafaRay,
                    if AutosmoothAngle == 0.0 -> false;
                    true -> ?DEF_AUTOSMOOTH end),

%%% IOR Material Property for all Materials except Glossy
%%%

    IOR =
        proplists:get_value(ior, YafaRay, ?DEF_IOR),

%%% Color Properties Transmitted = Diffuse and Refracted
%%% Color Properties Reflected = Glossy and Reflected
%%%

    Reflected =
        proplists:get_value(reflected, YafaRay, DefReflected),

    Transmitted =
        proplists:get_value(transmitted, YafaRay, DefTransmitted),


%%% Glass Properties
%%%

    AbsorptionColor =
        proplists:get_value(absorption_color, YafaRay, DefAbsorptionColor),
    AbsorptionDist =
        proplists:get_value(absorption_dist, YafaRay,   ?DEF_ABSORPTION_DIST),
    DispersionPower =
        proplists:get_value(dispersion_power, YafaRay,  ?DEF_DISPERSION_POWER),
    DispersionSamples =
        proplists:get_value(dispersion_samples, YafaRay, ?DEF_DISPERSION_SAMPLES),
        FakeShadows =
        proplists:get_value(fake_shadows, YafaRay,      ?DEF_FAKE_SHADOWS),
    Roughness =
        proplists:get_value(roughness, YafaRay,         ?DEF_ROUGHNESS),
    Glass_IR_Depth =
        proplists:get_value(glass_ir_depth, YafaRay,    ?DEF_GLASS_IR_DEPTH),

%%% Shiny Diffuse Properties
%%% Transmit Filter also for Glass and Rough Glass

   Transparency =
        proplists:get_value(transparency, YafaRay,      ?DEF_TRANSPARENCY),
   TransmitFilter =
        proplists:get_value(transmit_filter, YafaRay,   ?DEF_TRANSMIT_FILTER),
   Translucency =
        proplists:get_value(translucency, YafaRay,      ?DEF_TRANSLUCENCY),
   SpecularReflect =
        proplists:get_value(specular_reflect, YafaRay,  ?DEF_SPECULAR_REFLECT),
   Emit =
        proplists:get_value(emit, YafaRay,              ?DEF_EMIT),


%%% Translucency (SSS) Properties
%%% Povman: add flags for experimental branch??

    SSS_AbsorptionColor =
        proplists:get_value(sss_absorption_color, YafaRay,      ?DEF_SSS_ABSORPTION_COLOR),
    ScatterColor =
        proplists:get_value(scatter_color, YafaRay,             ?DEF_SCATTER_COLOR),
    SigmaSfactor =
        proplists:get_value(sigmas_factor, YafaRay,             ?DEF_SIGMAS_FACTOR),
    SSS_Translucency =
        proplists:get_value(sss_translucency, YafaRay,          ?DEF_SSS_TRANSLUCENCY),
    SSS_Specular_Color =
        proplists:get_value(sss_specular_color, YafaRay,        ?DEF_SSS_SPECULAR_COLOR),


%%% Shiny Diffuse, Glossy, Coated Glossy Properties
%%%

    DiffuseReflect =
        proplists:get_value(diffuse_reflect, YafaRay,   ?DEF_DIFFUSE_REFLECT),
    OrenNayar =
        proplists:get_value(oren_nayar, YafaRay,        ?DEF_OREN_NAYAR),
    OrenNayar_Sigma =
        proplists:get_value(oren_nayar_sigma, YafaRay,  ?DEF_OREN_NAYAR_SIGMA),


%%% Glossy and Coated Glossy Properties
%%%

    GlossyReflect =
        proplists:get_value(glossy_reflect, YafaRay,    ?DEF_GLOSSY_REFLECT),
    Exponent =
        proplists:get_value(exponent, YafaRay,          ?DEF_EXPONENT),
    Anisotropic =
        proplists:get_value(anisotropic, YafaRay,       ?DEF_ANISOTROPIC),
    Anisotropic_U =
        proplists:get_value(anisotropic_u, YafaRay,     ?DEF_ANISOTROPIC_U),
    Anisotropic_V =
        proplists:get_value(anisotropic_v, YafaRay,     ?DEF_ANISOTROPIC_V),


%%% Light Material Properties
%%%

    Lightmat_Color =
        proplists:get_value(lightmat_color, YafaRay,    DefLightmatColor),

    Lightmat_Power =
        proplists:get_value(lightmat_power, YafaRay,    ?DEF_LIGHTMAT_POWER),

%%% Blend Material Properties
%%%


    Blend_Mat1 =
        proplists:get_value(blend_mat1, YafaRay,        ?DEF_BLEND_MAT1),

    Blend_Mat2 =
        proplists:get_value(blend_mat2, YafaRay,        ?DEF_BLEND_MAT2),

    Blend_Value =
        proplists:get_value(blend_value, YafaRay,       ?DEF_BLEND_VALUE),


%%% Object Specific Material Properties Dialog
%%%

    Modulators = proplists:get_value(modulators, YafaRay, def_modulators(Maps)),
    ObjectFrame =
        {vframe,[
            {hframe,[
                {?__(6,"Autosmooth"),Autosmooth,[key(autosmooth)]},
                {label,?__(7,"Angle")},
                {slider,{text,AutosmoothAngle,[
                    range(autosmooth_angle),{width,5},
                    key(autosmooth_angle),
                    hook(enable, ?KEY(autosmooth))]}},
                    help_button({material_dialog,object})
            ]},

        %%% Start Object Type Menu

            {hframe,[
                {vframe,[
                    {menu,[
                        {?__(31,"Mesh"),mesh},
                        {?__(32,"Volume"),volume},
                        {?__(33,"Mesh Light"),meshlight}
                    ], Object_Type, [key(object_type),layout]
                    },
                    {hframe,[
                        {menu,[
                            {?__(82,"Uniform"),uniformvolume},
                            {?__(83,"ExpDensity"),expdensityvolume},
                            {?__(126,"Noise"),noisevolume}
                        ], Volume_Type, [key(volume_type),layout]
                        },

        %% Start Uniform Volume

                        {hframe,[
                            {vframe,[
                                {label,?__(84,"Absorption")},
                                {label,?__(85,"Scatter")},
                                {label,?__(86,"AttgridScale")}
                                                        ]},
                            {vframe,[
                                {text,Volume_Sigma_a,[range(volume_sigma_a),key(volume_sigma_a)]},
                                {text,Volume_Sigma_s,[range(volume_sigma_s),key(volume_sigma_s)]},
                                {text,Volume_Attgridscale,[range(volume_attgridscale),key(volume_attgridscale)]}
                                                        ]},
                            {vframe,[
                                {label,?__(133,"Min/Max X")},
                                {label,?__(134,"Min/Max Y")},
                                {label,?__(135,"Min/Max Z")}
                                                        ]},
                            {vframe,[
                                {text,Volume_Minmax_X,[range(volume_minmax_x),key(volume_minmax_x)]},
                                {text,Volume_Minmax_Y,[range(volume_minmax_y),key(volume_minmax_y)]},
                                {text,Volume_Minmax_Z,[range(volume_minmax_z),key(volume_minmax_z)]}
                                                        ]}
                        ], [hook(open, [member, ?KEY(volume_type), uniformvolume])]
                        },

        %% End Uniform Volume


        %% Start ExpDensity Volume

                        {hframe,[
                            {vframe,[
                                {label,?__(88,"Absorption")},
                                {label,?__(89,"Scatter")},
                                {label,?__(86,"AttgridScale")}
                                                        ]},
                            {vframe,[
                                {text,Volume_Sigma_a,[range(volume_sigma_a),key(volume_sigma_a)]},
                                {text,Volume_Sigma_s,[range(volume_sigma_s),key(volume_sigma_s)]},
                                {text,Volume_Attgridscale,[range(volume_attgridscale),key(volume_attgridscale)]}
                            ]},
                            {vframe,[
                                {label,?__(90,"Height")},
                                {label,?__(91,"Steepness")}
                            ]},
                            {vframe,[
                                {text,Volume_Height,[range(volume_height),key(volume_height)]},
                                {text,Volume_Steepness,[range(volume_steepness),key(volume_steepness)]}
                            ]},
                            {vframe,[
                                {label,?__(136,"Min/Max X")},
                                {label,?__(137,"Min/Max Y")},
                                {label,?__(138,"Min/Max Z")}
                            ]},
                            {vframe,[
                                {text,Volume_Minmax_X,[range(volume_minmax_x),key(volume_minmax_x)]},
                                {text,Volume_Minmax_Y,[range(volume_minmax_y),key(volume_minmax_y)]},
                                {text,Volume_Minmax_Z,[range(volume_minmax_z),key(volume_minmax_z)]}
                            ]}
                        ],[hook(open, [member, ?KEY(volume_type), expdensityvolume])]
                        },

        %% End ExpDensity Volume

        %% Start Noise Volume

                        {hframe,[
                            {vframe,[
                                {label,?__(127,"Absorption")},
                                {label,?__(128,"Scatter")},
                                {label,?__(129,"AttgridScale")}
                                                        ]},
                            {vframe,[
                                {text,Volume_Sigma_a,[range(volume_sigma_a),key(volume_sigma_a)]},
                                {text,Volume_Sigma_s,[range(volume_sigma_s),key(volume_sigma_s)]},
                                {text,Volume_Attgridscale,[range(volume_attgridscale),key(volume_attgridscale)]}
                                                        ]},
                            {vframe,[
                                {label,?__(130,"Sharpness")},
                                {label,?__(131,"Cover")},
                                {label,?__(132,"Density")}
                                                        ]},
                            {vframe,[
                                {text,Volume_Sharpness,[range(volume_sharpness),key(volume_sharpness)]},
                                {text,Volume_Cover,[range(volume_cover),key(volume_cover)]},
                                {text,Volume_Density,[range(volume_density),key(volume_density)]}
                                                        ]},
                            {vframe,[
                                {label,?__(139,"Min/Max X")},
                                {label,?__(140,"Min/Max Y")},
                                {label,?__(141,"Min/Max Z")}
                                                        ]},
                            {vframe,[
                                {text,Volume_Minmax_X,[range(volume_minmax_x),key(volume_minmax_x)]},
                                {text,Volume_Minmax_Y,[range(volume_minmax_y),key(volume_minmax_y)]},
                                {text,Volume_Minmax_Z,[range(volume_minmax_z),key(volume_minmax_z)]}
                                                        ]}
                        ],[hook(open, [member, ?KEY(volume_type), noisevolume])]
                        }

        %%% End Noise Volume

                    ],[hook(open, [member, ?KEY(object_type), volume])]
                    },

                    {hframe,[
                        {vframe,[
                            {label,?__(121,"Power")},
                            {label,?__(122,"Samples")}
                                                ]},
                        {vframe,[
                            {text,Meshlight_Power,[range(meshlight_power),{width,5},key(meshlight_power)]},
                            {text,Meshlight_Samples,[range(meshlight_samples),{width,5},key(meshlight_samples)]}
                                                ]},
                        {vframe,[
                            {label,?__(123,"Color")}]},
                        {vframe,[
                            {slider, {color, Meshlight_Color, [key(meshlight_color)]}}
                                                ]},
                        {vframe,[
                            {button,"Set Default",keep,[diffuse_hook(?KEY(meshlight_color))]},
                            {?__(124,"Double Sided"),Meshlight_Double_Sided,[key(meshlight_double_sided)]}
                        ]}
                    ],[hook(open, [member, ?KEY(object_type), meshlight])]
                    }
                ],[{title,?__(113,"Object Type")}]
                }
            ]
            }

        %%% End Object Type Menu
            ],
            [{title,?__(8,"Object Parameters")},{minimized,ObjectMinimized}, key(object_minimized)]
        },

%%% Shader Specific Material Properties Dialog
%%%

    ShaderFrame =
        {vframe,[
            {menu,[
                {?__(9,"Shiny Diffuse"),shinydiffuse},
                {?__(29,"Glass"),glass},
                {"Rough Glass",rough_glass},
                {"Glossy",glossy},
                {"Coated Glossy",coatedglossy},
                {"Translucent (SSS)",translucent}, % add flags for YafaRay 0.1.3 exp?
                {"Light Material",lightmat},
                {"Blend",blend_mat}
            ], ShaderType, [key(shader_type),layout]
            },

        %%% Define Dialog for Shiny Diffuse Material
        %%%

            {hframe,[
                {vframe,[
                    {label, "Index of Refraction"},
                    {label, "Reflected Color"},
                    {label, "Diffuse Color"},
                    {label, "Transparency"},
                    {label, "Transmit Filter"},
                    {label, "Translucency"},
                    {label, "Diffuse Reflection"},
                    {label, "Mirror Reflection"},
                    {label, "Emit Light"},
                    {"Oren-Nayar",OrenNayar,[key(oren_nayar)]},
                    {"Fresnel Effect",TIR,[key(tir)]},
                    panel
                ]},
                {vframe,[
                    {slider, {text, IOR,[range(ior),{width,5}, key(ior)]}},
                    {slider, {color, Reflected, [key(reflected)]}},
                    {slider, {color, Transmitted, [key(transmitted)]}},
                    {slider, {text,Transparency,[range(transparency), key(transparency)]}},
                    {slider, {text,TransmitFilter,[range(transmit_filter), key(transmit_filter)]}},
                    {slider, {text,Translucency,[range(translucency), key(translucency)]}},
                    {slider, {text,DiffuseReflect,[range(diffuse_reflect), key(diffuse_reflect)]}},
                    {slider, {text,SpecularReflect,[range(specular_reflect), key(specular_reflect)]}},
                    {slider, {text,Emit,[range(emit),{width,8}, key(emit)]}},
                    %%
                    {hframe,[
                        {label, "Sigma"},
                        {text,OrenNayar_Sigma,[
                            range(oren_nayar_sigma),
                            key(oren_nayar_sigma),
                            hook(enable, ['not',[member,?KEY(oren_nayar), ?DEF_OREN_NAYAR]])
                        ]}
                    ]}
                ]},
                {vframe,[
                    panel,panel,
                        {button,"Set Default",keep,[diffuse_hook(?KEY(transmitted))]}
                ]}
            ],[hook(open, [member, ?KEY(shader_type), shinydiffuse])]
            },

%%% Define Dialog for Glass Material
%%%

            {hframe,[
                {vframe,[
                    {label, "Index of Refraction"},
                    {label, "Internal Reflection"},
                    {label, "Reflected Light"},
                    {label, "Filtered Light"},
                    {label, "Absorption Color"},
                    {label, "Absorption Distance"},
                    {label, "Transmit Filter"},
                    {label, "Dispersion Power"},
                    {label, "Dispersion Samples"},
                    {"Fake Shadows",FakeShadows,[key(fake_shadows)]},panel]
                },
                {vframe,[
                    {slider, {text, IOR,[range(ior),{width,5}, key(ior)]}},
                    {slider, {text, Glass_IR_Depth,[range(glass_ir_depth),{width,5}, key(glass_ir_depth)]}},
                    {slider, {color, Reflected, [key(reflected)]}},
                    {slider, {color, Transmitted, [key(transmitted)]}},
                    {slider, {color,AbsorptionColor,[key(absorption_color)]}},
                    {slider, {text, AbsorptionDist,[range(absorption_dist),{width,8}, key(absorption_dist)]}},
                    {slider, {text,TransmitFilter,[range(transmit_filter), key(transmit_filter)]}},
                    {slider, {text,DispersionPower,[range(dispersion_power), key(dispersion_power)]}},
                    {slider, {text, DispersionSamples,[range(dispersion_samples),{width,8}, key(dispersion_samples),
                        hook(enable, ['not',[member,?KEY(dispersion_power),0.0]])]}
                    }]
                },
                {vframe,[
                    panel,panel,panel,
                        {button,"Set Default",keep,[transmitted_hook(?KEY(transmitted))]},
                        {button,"Set Default",keep,[diffuse_hook(?KEY(absorption_color))]}
                    ]}
            ],
            [hook(open, [member, ?KEY(shader_type), glass])]},

%%% Define Dialog for Rough Glass Material
%%%

            {hframe,[
                {vframe,[
                    {label, "Index of Refraction"},
                    {label, "Reflected Light"},
                    {label, "Filtered Light"},
                    {label, "Absorption Color"},
                    {label, "Absorption Distance"},
                    {label, "Transmit Filter"},
                    {label, "Roughness"},
                    {label, "Dispersion Power"},{label, "Dispersion Samples"},
                    {"Fake Shadows",FakeShadows,[key(fake_shadows)]},panel]
                },
                {vframe,[
                    {slider, {text, IOR,[range(ior),{width,5}, key(ior)]}},
                    {slider, {color, Reflected, [key(reflected)]}},
                    {slider, {color, Transmitted, [key(transmitted)]}},
                    {slider, {color,AbsorptionColor,[key(absorption_color)]}},
                    {slider, {text, AbsorptionDist,[range(absorption_dist),{width,8}, key(absorption_dist)]}},
                    {slider, {text,TransmitFilter,[range(transmit_filter), key(transmit_filter)]}},
                    {slider, {text,Roughness,[range(roughness), key(roughness)]}},
                    {slider, {text,DispersionPower,[range(dispersion_power), key(dispersion_power)]}},
                    {slider, {text,DispersionSamples,[range(dispersion_samples), {width,8}, key(dispersion_samples),
                                hook(enable, ['not',[member,?KEY(dispersion_power),0.0]])]}}]
                },
                {vframe,[
                    panel,panel,
                        {button,"Set Default",keep,[transmitted_hook(?KEY(transmitted))]}
                    ]}
            ],
            [hook(open, [member, ?KEY(shader_type), rough_glass])]},

%%% Define Dialog for Glossy Material
%%%

            {hframe,[
                {vframe,[
                    {label, "Glossy Color"}, {label, "Diffuse Color"},
                    {label, "Diffuse Reflection"},{label, "Glossy Reflection"},{label, "Exponent"},
                    {"Oren-Nayar",OrenNayar,[key(oren_nayar)]},
                    panel
                ]},
                {vframe,[
                    {slider, {color, Reflected, [key(reflected)]}},
                    {slider, {color, Transmitted, [key(transmitted)]}},
                    {slider, {text,DiffuseReflect,[range(diffuse_reflect), key(diffuse_reflect)]}},
                    {slider, {text,GlossyReflect,[range(glossy_reflect), key(glossy_reflect)]}},
                    {slider, {text,Exponent,[range(exponent),{width,8}, key(exponent)]}},
                    {hframe,[
                        {label, "Sigma"},
                        {text,OrenNayar_Sigma,[range(oren_nayar_sigma), key(oren_nayar_sigma),
                            hook(enable, ['not',[member,?KEY(oren_nayar), ?DEF_OREN_NAYAR]])]}
                    ]}
                ]},
                {vframe,[
                    panel,
                        {button,"Set Default",keep, [diffuse_hook(?KEY(transmitted))]}
                    ]}
            ],
            [hook(open, [member, ?KEY(shader_type), glossy])]},

%%% Define Dialog for Coated Glossy Material
%%%

            {hframe,[
                {vframe,[
                    {label, "Index of Refraction"},
                    {label, "Glossy Color"},
                    {label, "Diffuse Color"},
                    {label, "Diffuse Reflection"},
                    {label, "Glossy Reflection"},
                    {label, "Exponent"},
                    {"Anisotropic",Anisotropic,[key(anisotropic)]},
                    {"Oren-Nayar",OrenNayar,[key(oren_nayar)]},
                    panel
                ]},
                {vframe,[
                    {slider, {text, IOR,[range(ior),{width,5}, key(ior)]}},
                    {slider, {color, Reflected, [key(reflected)]}},
                    {slider, {color, Transmitted, [key(transmitted)]}},
                    {slider, {text,DiffuseReflect,[range(diffuse_reflect), key(diffuse_reflect)]}},
                    {slider, {text,GlossyReflect,[range(glossy_reflect), key(glossy_reflect)]}},
                    {slider, {text,Exponent,[range(exponent),{width,8}, key(exponent),
                                hook(enable, [member,?KEY(anisotropic), ?DEF_ANISOTROPIC])]}},

                        {hframe,[
                            {label, "Exp U"},
                            {text, Anisotropic_U,[range(anisotropic_u), key(anisotropic_u),
                                hook(enable, ['not',[member,?KEY(anisotropic), ?DEF_ANISOTROPIC]])]},
                            {label, "Exp V"},
                            {text,Anisotropic_V,[range(anisotropic_v), key(anisotropic_v),
                                hook(enable, ['not',[member,?KEY(anisotropic), ?DEF_ANISOTROPIC]])]}
                        ]},
                        {hframe,[
                            {label, "Sigma"},
                            {text,OrenNayar_Sigma,[range(oren_nayar_sigma), key(oren_nayar_sigma),
                                hook(enable, ['not',[member,?KEY(oren_nayar), ?DEF_OREN_NAYAR]])]}
                        ]}
                ]},
                {vframe,[
                    panel,panel,
                        {button,"Set Default",keep, [diffuse_hook(?KEY(transmitted))]}
                    ]
                }
            ],
            [hook(open, [member, ?KEY(shader_type), coatedglossy])]},

%%% Define Dialog for Translucent (SSS) Material
%%%

            {hframe,[
                {vframe,[
                    {label, "Index of Refraction"},
                    {label, "Glossy Color"},
                    {label, "Diffuse Color"},
                    {label, "Specular Color"},
                    {label, "Absorption Color"},
                    {label, "Absorption Distance"},
                    {label, "Scatter Color"},
                    {label, "SigmaSfactor"},
                    {label, "Diffuse Reflection"},
                    {label, "Glossy Reflection"},
                    {label, "Translucency"},
                    {label, "Exponent"},
                    panel
                ]},
                {vframe,[
                    {slider, {text, IOR,[range(ior),{width,5}, key(ior)]}},
                    {slider, {color, Reflected, [key(reflected)]}},
                    {slider, {color, Transmitted, [key(transmitted)]}},
                    {slider, {color, SSS_Specular_Color, [key(sss_specular_color)]}},
                    {slider, {color,SSS_AbsorptionColor,[key(sss_absorption_color)]}},
                    {slider, {text, AbsorptionDist,[range(absorption_dist), {width,8}, key(absorption_dist)]}},
                    {slider, {color,ScatterColor,[key(scatter_color)]}},
                    {slider, {text,SigmaSfactor,[range(sigmas_factor),{width,8}, key(sigmas_factor)]}},
                    {slider, {text,DiffuseReflect,[range(diffuse_reflect), key(diffuse_reflect)]}},
                    {slider, {text,GlossyReflect,[range(glossy_reflect), key(glossy_reflect)]}},
                    {slider, {text,SSS_Translucency,[range(sss_translucency), key(sss_translucency)]}},
                    {slider, {text,Exponent,[range(exponent),{width,8}, key(exponent)]}}
                ]},
                {vframe,[
                    panel,panel,{button,"Set Default", keep, [diffuse_hook(?KEY(transmitted))]}
                ]}
            ],
            [hook(open, [member, ?KEY(shader_type), translucent])]},

%%% Define Dialog for Light Material
%%%

            {hframe,[
                {vframe,[
                    {label, "Color"},
                    {label, "Power"},
                    panel]
                },
                {vframe,[
                    {slider, {color, Lightmat_Color, [key(lightmat_color)]}},
                    {slider, {text,Lightmat_Power,[range(lightmat_power), key(lightmat_power)]}}
                ]},
                {vframe,[
                    {button,"Set Default",keep, [diffuse_hook(?KEY(lightmat_color))]}
                ]}
            ],
            [hook(open, [member, ?KEY(shader_type), lightmat])]},

%%% Start Dialog for Blend Material
%%%

            {hframe,[
                {vframe,[
                    {label, "Material 1"},
                    {label, "Material 2"},
                    {label, "Blend Mix"},
                    panel
                ]},
                {vframe,[
                    {text,Blend_Mat1,[key(blend_mat1)]},
                    {text,Blend_Mat2,[key(blend_mat2)]},
                    {slider, {text,Blend_Value,[range(blend_value), key(blend_value)]}}
                ]}
            ],
            [hook(open, [member, ?KEY(shader_type), blend_mat])]}


%%% End Dialog for Blend Material
        ]},


%%% End of Material Dialogs
%%%


%%
    [{vframe,
      [ObjectFrame,
       ShaderFrame,
       {vframe,
        modulator_dialogs(Modulators, Maps),
        [hook(open, ['not',[member,?KEY(shader_type),block]])]}],
      [{title,?__(28,"YafaRay Options")},{minimized,Minimized},key(minimized)]}].

alpha({R,G,B,A}) -> {R*A,G*A,B*A}.

%%% Define Lightmat Color
def_lightmat_color({Dr,Dg,Db,_Da}) ->
    Dt = 1-0,
    {Dr*Dt,Dg*Dt,Db*Dt}.


%%% Define Absorption Color
def_absorption_color({Dr,Dg,Db,_Da}) ->
    Dt = 1-0,
    {Dr*Dt,Dg*Dt,Db*Dt}.

%%% Grab OpenGL Transmitted Default Button
%%%

def_transmitted({Dr,Dg,Db,_Da}) ->
    Dt = 1-0,
    {Dr*Dt,Dg*Dt,Db*Dt}.

transmitted_hook(Tag) ->
    {hook,fun (update, {_Var,_I,_Val,Sto}) ->
          {Dr,Dg,Db} = gb_trees:get(diffuse, Sto),
          Da = gb_trees:get(opacity, Sto),
          Transmitted = def_transmitted({Dr,Dg,Db,Da}),
          {store,gb_trees:update(Tag, Transmitted, Sto)};
          (_, _) -> void end}.

%%% Grab OpenGL Diffuse Default Button
%%%

def_diffuse({Dr,Dg,Db,_Da}) ->
    Dt = 1-0,
    {Dr*Dt,Dg*Dt,Db*Dt}.


diffuse_hook(Tag) ->
    {hook,fun (update, {_Var,_I,_Val,Sto}) ->
          {Dr,Dg,Db} = gb_trees:get(diffuse, Sto),
          Da = gb_trees:get(opacity, Sto),
          Transmitted = def_diffuse({Dr,Dg,Db,Da}),
          {store,gb_trees:update(Tag, Transmitted, Sto)};
          (_, _) -> void end}.


def_modulators([]) ->
    [];
def_modulators([{diffuse,_}|Maps]) ->
    [{modulator,[{type,{map,diffuse}},{diffuse,1.0}]}
     |def_modulators(Maps)];
def_modulators([{ambient,_}|Maps]) ->
    [{modulator,[{type,{map,ambient}},{ambient,1.0}]}
     |def_modulators(Maps)];
def_modulators([{bump,_}|Maps]) ->
    [{modulator,[{type,{map,bump}},{normal,1.0}]}
     |def_modulators(Maps)];
def_modulators([{gloss,_}|Maps]) ->
    [{modulator,[{type,{map,gloss}},{shininess,1.0}]}
     |def_modulators(Maps)];
def_modulators([_|Maps]) ->
    def_modulators(Maps).

%%% Increase split_list # +1 per line if add Material to Dialog
%%%

material_result(_Name, Mat0, [{?KEY(minimized),_}|_]=Res0) ->
    {Ps1,Res1} = split_list(Res0, 101),
    Ps2 = [{Key,Val} || {?KEY(Key),Val} <- Ps1],
    {Ps,Res} = modulator_result(Ps2, Res1),
    Mat = [?KEY(Ps)|keydelete(?TAG, 1, Mat0)],
    {Mat,Res};
material_result(Name, Mat, Res) ->
    exit({invalid_tag,{?MODULE,?LINE,[Name,Mat,Res]}}).

modulator_dialogs(Modulators, Maps) ->
    modulator_dialogs(Modulators, Maps, 1).

modulator_dialogs([], _Maps, M) ->
    [{hframe,
      [{button,?__(1,"New Modulator"),done,[key(new_modulator)]},
       panel|
       if M =:= 1 -> [{button,?__(2,"Default Modulators"),done}];
      true -> [] end]}];
    modulator_dialogs([Modulator|Modulators], Maps, M) ->
    modulator_dialog(Modulator, Maps, M)++
    modulator_dialogs(Modulators, Maps, M+1).

modulator_dialog({modulator,Ps}, Maps, M) when is_list(Ps) ->
%    erlang:display({?MODULE,?LINE,[Ps,M,Maps]}),
    {Enabled,Mode,Type} = mod_enabled_mode_type(Ps, Maps),
    AlphaIntensity = proplists:get_value(alpha_intensity, Ps, ?DEF_MOD_ALPHA_INTENSITY),
    Minimized = proplists:get_value(minimized, Ps, true),
    SizeX = proplists:get_value(size_x, Ps, ?DEF_MOD_SIZE_X),
    SizeY = proplists:get_value(size_y, Ps, ?DEF_MOD_SIZE_Y),
    SizeZ = proplists:get_value(size_z, Ps, ?DEF_MOD_SIZE_Z),
    Diffuse = proplists:get_value(diffuse, Ps, ?DEF_MOD_DIFFUSE),
    Specular = proplists:get_value(specular, Ps, ?DEF_MOD_SPECULAR),
%%    Ambient = proplists:get_value(ambient, Ps, ?DEF_MOD_AMBIENT),
    Shininess = proplists:get_value(shininess, Ps, ?DEF_MOD_SHININESS),
    Normal = proplists:get_value(normal, Ps, ?DEF_MOD_NORMAL),
    Filename = proplists:get_value(filename, Ps, ?DEF_MOD_FILENAME),
    BrowseProps = [{dialog_type,open_dialog},
                   {extensions,[{".jpg",?__(3,"JPEG compressed image")},
                                {".tga",?__(4,"Targa bitmap")}]}],
%    erlang:display({?MODULE,?LINE,[Filename,AbsnameX,BrowseProps]}),
    Color1 = proplists:get_value(color1, Ps, ?DEF_MOD_COLOR1),
    Color2 = proplists:get_value(color2, Ps, ?DEF_MOD_COLOR2),
    Depth = proplists:get_value(depth, Ps, ?DEF_MOD_DEPTH),
    NoiseSize = proplists:get_value(noise_size, Ps, ?DEF_MOD_NOISESIZE),
    NoiseBasis = proplists:get_value(noise_basis, Ps, ?DEF_MOD_NOISEBASIS),
    Hard = proplists:get_value(hard, Ps, ?DEF_MOD_HARD),
    Turbulence = proplists:get_value(turbulence, Ps, ?DEF_MOD_TURBULENCE),
    Sharpness = proplists:get_value(sharpness, Ps, ?DEF_MOD_SHARPNESS),
    WoodType = proplists:get_value(wood_type, Ps, ?DEF_MOD_WOODTYPE),
    Shape = proplists:get_value(shape, Ps, ?DEF_MOD_SHAPE),
    CellType = proplists:get_value(cell_type, Ps, ?DEF_MOD_CELLTYPE),
    CellShape = proplists:get_value(cell_shape, Ps, ?DEF_MOD_CELLSHAPE),
    CellSize = proplists:get_value(cell_size, Ps, ?DEF_MOD_CELLSIZE),
    Intensity = proplists:get_value(intensity, Ps, ?DEF_MOD_INTENSITY),
    CellWeight1 = proplists:get_value(cell_weight1, Ps, ?DEF_MOD_CELL_WEIGHT1),
    CellWeight2 = proplists:get_value(cell_weight2, Ps, ?DEF_MOD_CELL_WEIGHT2),
    CellWeight3 = proplists:get_value(cell_weight3, Ps, ?DEF_MOD_CELL_WEIGHT3),
    CellWeight4 = proplists:get_value(cell_weight4, Ps, ?DEF_MOD_CELL_WEIGHT4),
    MusgraveType = proplists:get_value(musgrave_type, Ps, ?DEF_MOD_MUSGRAVE_TYPE),

    MusgraveNoiseSize = proplists:get_value(musgrave_noisesize, Ps, ?DEF_MOD_MUSGRAVE_NOISESIZE),
    MusgraveIntensity = proplists:get_value(musgrave_intensity, Ps, ?DEF_MOD_MUSGRAVE_INTENSITY),
    MusgraveContrast = proplists:get_value(musgrave_contrast, Ps, ?DEF_MOD_MUSGRAVE_CONTRAST),
    MusgraveLacunarity = proplists:get_value(musgrave_lacunarity, Ps, ?DEF_MOD_MUSGRAVE_LACUNARITY),
    MusgraveOctaves = proplists:get_value(musgrave_octaves, Ps, ?DEF_MOD_MUSGRAVE_OCTAVES),
    DistortionType = proplists:get_value(distortion_type, Ps, ?DEF_MOD_DISTORTION_TYPE),

    DistortionIntensity = proplists:get_value(distortion_intensity, Ps, ?DEF_MOD_DISTORTION_INTENSITY),
    DistortionNoiseSize = proplists:get_value(distortion_noisesize, Ps, ?DEF_MOD_DISTORTION_NOISESIZE),
    TypeTag = {?TAG,type,M},
    MapsFrame = [{hradio,[{atom_to_list(Map),{map,Map}} || {Map,_} <- Maps],
                  Type,[{key,TypeTag},layout]}],
        [{vframe,[
            {hframe,[
                {?__(5,"Enabled"),Enabled,[{key,{?TAG,enabled,M}}]},
                {menu,[
                    {?__(6,"Mix"),mix},
                    {?__(7,"Add"),add},
                    {?__(8,"Mul"),mul},
                    {?__(109,"Sub"),sub},
                    {?__(110,"Scr"),scr},
                    {?__(111,"Div"),divide},
                    {?__(112,"Dif"),dif},
                    {?__(113,"Dar"),dar},
                    {?__(114,"Lig"),lig}
                ],Mode, [hook(enable, {?TAG,enabled,M})]
                },panel,{button,?__(9,"Delete"),done}
            ]},
            {vframe,[ % hook(enable, {?TAG,enabled,M})
                {hframe,[
                    {menu,[
                        {?__(115,"Alpha Off"),off},
                        {?__(116,"Alpha Transparency"),transparency},
                        {?__(117,"Diffuse+Alpha Transparency"),diffusealphatransparency},
                        {?__(118,"Alpha Translucency"),translucency},
                        {?__(119,"Specularity"),specularity},
                        {?__(120,"Stencil"),stencil}
                    ],AlphaIntensity
                    }
                ]},
                {hframe,[
                    {label,?__(10,"SizeX")},{text,SizeX,[range(size)]},
                    {label,?__(11,"SizeY")},{text,SizeY,[range(size)]},
                    {label,?__(12,"SizeZ")},{text,SizeZ,[range(size)]}
                ]},
                {hframe,[
                    {vframe,[
                        {label,?__(13,"Diffuse")++" "},
                        {label,?__(14,"Specular")},
                        {label,?__(16,"Shininess")},
                        {label,?__(17,"Normal")}
                    ]},
                    {vframe,[
                        {slider,{text,Diffuse,[range(modulation)]}},
                        {slider,{text,Specular,[range(modulation)]}},
                        {slider,{text,Shininess,[range(modulation)]}},
                        {slider,{text,Normal,[range(modulation)]}}
                    ]}
                ]}
            ]
            ++MapsFrame++
            [{hradio,[
                {?__(18,"Image"),image},
                {?__(19,"Clouds"),clouds},
                {?__(20,"Marble"),marble},
                {?__(21,"Wood"),wood},
                {?__(46,"Voronoi"),voronoi},
                {?__(62,"Musgrave"),musgrave},
                {?__(82,"Distorted Noise"),distorted_noise}
            ],Type,[{key,TypeTag},layout]
            },
            {vframe,[
                {hframe,[
                    {hframe,[
                        {label,?__(22,"Filename")},
                        {button,{text,Filename,[{props,BrowseProps}]}}
                    ],[hook(open, [member,{?TAG,type,M},image])]
                    },

%% Clouds,Marble,Wood Specific Procedurals

                    {hframe,[
                        {label,?__(23,"Texture")},{color,Color1},
                        {label,?__(24,"Base")},{color,Color2},
                        {?__(25,"Hard Noise"),Hard},


%%% Start Noise Basis Select

                        {menu,[
                            {?__(36,"Blender-Basis"),blender},
                            {?__(37,"Cellnoise"),cellnoise},
                            {?__(38,"New Perlin"),newperlin},
                            {?__(39,"Perlin"),stdperlin},
                            {?__(40,"Voronoi Crackle"),voronoi_crackle},
                            {?__(41,"Voronoi F1"),voronoi_f1},
                            {?__(42,"Voronoi F2"),voronoi_f2},
                            {?__(43,"Voronoi F3"),voronoi_f3},
                            {?__(44,"Voronoi F4"),voronoi_f4},
                            {?__(45,"Voronoi F1F2"),voronoi_f2f1}
                        ],NoiseBasis,[hook(enable, {?TAG,enabled,M})]
                        }

    %%% End Noise Basis Select

                    ],[hook(open, [member,{?TAG,type,M},clouds,marble,wood,musgrave,distorted_noise])]
                    }

                ]},

        %% Clouds,Marble,Wood Specific Procedurals Line 2
                {hframe,[
                    {hframe,[
                        {label,?__(26,"Noise Size")},{text,NoiseSize,[range(noise_size)]}
                    ],[hook(open, [member,{?TAG,type,M},clouds,marble,wood])]
                    },

    %% Clouds,Marble,Wood Specific Procedurals Line 2

                    {hframe,[
                        {label,?__(27,"Noise Depth")},{text,Depth,[range(noise_depth)]}
                    ],[hook(open, [member,{?TAG,type,M},clouds,marble,wood])]
                    }
                ]},

    %% Marble Specific Procedurals
                {hframe,[
                    {hframe,[
                        {label,?__(28,"Sharpness")},{text,Sharpness,[range(sharpness)]}
                    ],[hook(open, [member,{?TAG,type,M},marble])]
                    },

    %% Marble,Wood Specific Procedurals

                    {hframe,[
                        {hframe,[
                            {label,?__(29,"Turbulence")},{text,Turbulence,[range(turbulence)]},

    %%% Start Shape Select
                            {menu,[
                                {?__(30,"sin"),"sin"},
                                {?__(31,"saw"),saw},
                                {?__(32,"tri"),tri}
                            ],Shape,[hook(enable, {?TAG,enabled,M})]
                            }
    %%% End Shape Select
                        ],[hook(open, [member,{?TAG,type,M},marble,wood])]
                        }
                    ]},

        %% Wood Specific Procedurals
                    {hframe,[
                        %%% Start Wood Type Select
                        {menu,[
                            {?__(33,"Rings"),rings},
                            {?__(34,"Bands"),bands}
                        ],WoodType,[hook(enable, {?TAG,enabled,M})]
                        }

        %%% End Wood Type Select

                    ],[hook(open, [member,{?TAG,type,M},wood])]
                    },

    %%% Voronoi Specific Procedurals
                    {vframe,[
                        {hframe,[

%%% Start Voronoi Cell Type Select

                            {menu,[
                                {?__(47,"Intensity"),intensity},
                                {?__(48,"Color"),col1},
                                {?__(49,"Color+Outline"),col2},
                                {?__(50,"Color+Outline+Intensity"),col3}
                            ],CellType,[hook(enable, {?TAG,enabled,M})]
                            },

%%% End Voronoi Cell Type Select

%%% Start Voronoi Cell Shape Select

                            {menu,[
                                {?__(51,"Actual Distance"),actual},
                                {?__(52,"Distance Squared"),squared},
                                {?__(53,"Manhattan"),manhattan},
                                {?__(54,"Chebychev"),chebychev},
                                {?__(55,"Minkovsky"),minkovsky}
                            ],CellShape,[hook(enable, {?TAG,enabled,M})]
                            }

%%% End Voronoi Cell Shape Select

        %%% Close Voronoi Line 1
                        ],[hook(open, [member,{?TAG,type,M},voronoi])]
                        },

%%% End Voronoi Line 1

%%% Start Voronoi Line 2
                        {hframe,[
                            {hframe,[
                                {label,?__(56,"Cell Size")},{text,CellSize,[range(cell_size)]},
                                {label,?__(57,"Intensity")},{text,Intensity,[range(intensity)]}
                            ],[hook(open, [member,{?TAG,type,M},voronoi])]
                            }
                        ]},

%%% End Voronoi Line 2

%%% Start Voronoi Line 3

                        {hframe,[
                            {hframe,[
                                {label,?__(58,"W1")},{text,CellWeight1,[range(cell_weight1)]},
                                {label,?__(59,"W2")},{text,CellWeight2,[range(cell_weight2)]},
                                {label,?__(60,"W3")},{text,CellWeight3,[range(cell_weight3)]},
                                {label,?__(61,"W4")},{text,CellWeight4,[range(cell_weight4)]}
                            ],[hook(open, [member,{?TAG,type,M},voronoi])]
                            }
                        ]}
%%% End Voronoi Line 3

%%% Close Voronoi
                    ],[hook(open, [member,{?TAG,type,M},voronoi])]
                    },

%%% End Voronoi Specific Procedurals

%%% Start Musgrave Specific Procedurals
                    {vframe,[
                        {hframe,[

%%% Start Musgrave Type Select
                            {menu,[
                                {?__(63,"Multifractal"),multifractal},
                                {?__(64,"Ridged"),ridgedmf},
                                {?__(65,"Hybrid"),hybridmf},
                                {?__(66,"FBM"),fBm}
                            ],MusgraveType,[hook(enable, {?TAG,enabled,M})]
                            },
%%% End Musgrave Type Select
                            {label,?__(77,"Noise Size")},{text,MusgraveNoiseSize,[range(musgrave_noisesize)]},
                            {label,?__(78,"Intensity")},{text,MusgraveIntensity,[range(musgrave_intensity)]}

%%% Close Musgrave Line 1
                        ],[hook(open, [member,{?TAG,type,M},musgrave])]
                        },
%%% End Musgrave Line 1

%%% Start Musgrave Line 2
                        {hframe,[
                            {hframe,[
                                {label,?__(79,"Contrast (H)")},{text,MusgraveContrast,[range(musgrave_contrast)]},
                                {label,?__(80,"Lacunarity")},{text,MusgraveLacunarity,[range(musgrave_lacunarity)]},
                                {label,?__(81,"Octaves")},{text,MusgraveOctaves,[range(musgrave_octaves)]}
                            ],[hook(open, [member,{?TAG,type,M},musgrave])]
                            }
                        ]}
%%% End Musgrave Line 2

%%% Close Musgrave
                    ],[hook(open, [member,{?TAG,type,M},musgrave])]
                    },
%%% End Musgrave Specific Procedurals

%%%% Start Distorted Noise Specific Procedurals


                    {vframe,[
                        {hframe,[
%%% Start Distorted Noise Type Select

                            {menu,[
                                {?__(87,"Blender-Distort"),blender},
                                {?__(88,"Cellnoise"),cellnoise},
                                {?__(89,"New Perlin"),newperlin},
                                {?__(90,"Perlin"),stdperlin},
                                {?__(91,"Voronoi Crackle"),voronoi_crackle},
                                {?__(92,"Voronoi F1"),voronoi_f1},
                                {?__(93,"Voronoi F2"),voronoi_f2},
                                {?__(94,"Voronoi F3"),voronoi_f3},
                                {?__(95,"Voronoi F4"),voronoi_f4},
                                {?__(96,"Voronoi F1F2"),voronoi_f2f1}
                            ],DistortionType,[hook(enable, {?TAG,enabled,M})]
                            },
%%% End Distorted Noise Type Select
                            {label,?__(107,"Noise Size")},{text,DistortionNoiseSize,[range(distortion_noisesize)]},
                            {label,?__(108,"Distortion")},{text,DistortionIntensity,[range(distortion_intensity)]}

%%% Close Distorted Noise Line 1
                        ],[hook(open, [member,{?TAG,type,M},distorted_noise])]
                        }
%%% End Distorted Noise Line 1


%%% Close Distorted Noise
                    ],[hook(open, [member,{?TAG,type,M},distorted_noise])]
                    }

%%%% End Distorted Noise
                ]}
            ]}
            ],[hook(enable, {?TAG,enabled,M})]
            }],[{title,?__(35,"Modulator")++" "++integer_to_list(M)++mod_legend(Enabled, Mode, Type)},
                {minimized,Minimized}]
        }];

modulator_dialog(_Modulator, _Maps, _) ->
    []. % Discard old modulators that anyone may have

mod_enabled_mode_type(Ps, Maps) ->
    {Enabled,Mode} =
        case proplists:get_value(mode, Ps, ?DEF_MOD_MODE) of
            off -> {false,?DEF_MOD_MODE};
            Mode1 -> {proplists:get_value(enabled, Ps, ?DEF_MOD_ENABLED),Mode1}
        end,
    Type = proplists:get_value(type, Ps, ?DEF_MOD_TYPE),
    case Type of
        {map,Map} ->
            case lists:keymember(Map, 1, Maps) of
                true -> {Enabled,Mode,Type};
                false -> {false,Mode,?DEF_MOD_TYPE}
            end;
        _ -> {Enabled,Mode,Type}
    end.

mod_legend(Enabled, Mode, {map,Map}) ->
    mod_legend(Enabled, Mode, atom_to_list(Map));
mod_legend(Enabled, Mode, Type) when is_atom(Mode) ->
    mod_legend(Enabled, wings_util:cap(Mode), Type);
mod_legend(Enabled, Mode, Type) when is_atom(Type) ->
    mod_legend(Enabled, Mode, wings_util:cap(Type));
mod_legend(Enabled, Mode, Type) when is_list(Mode), is_list(Type) ->
    case Enabled of
        true -> " ("++?__(1,"enabled")++", ";
        false -> " ("++?__(2,"disabled")++", "
    end++Mode++", "++Type++")".


modulator_result(Ps, Res) ->
    modulator_result(Ps, Res, 1, []).

modulator_result(Ps, [], _, Modulators) ->
    %% Should not happen
    {[{modulators,reverse(Modulators)}|Ps], []};
modulator_result(Ps, [{?KEY(new_modulator),false},false|Res], 1, []) ->
    {[{modulators,[]}|Ps],Res};
modulator_result(Ps, [{?KEY(new_modulator),false},true|Res], 1, []) ->
    %% Default Modulators
    {Ps,Res};
modulator_result(Ps, [{?KEY(new_modulator),true},_|Res], 1, []) ->
    {[{modulators,[{modulator,[]}]}|Ps],Res};
modulator_result(Ps, [{?KEY(new_modulator),false}|Res], _, Modulators) ->
    {[{modulators,reverse(Modulators)}|Ps],Res};
modulator_result(Ps, [{?KEY(new_modulator),true}|Res], _, Modulators) ->
    {[{modulators,reverse(Modulators, [{modulator,[]}])}|Ps],Res};
modulator_result(Ps, [_Minimized,{{?TAG,enabled,M},_},_Mode,true|Res0],
                 M, Modulators) ->
    %% Delete - Split list # +1 will match the modulator one below.
    {_,Res} = split_list(Res0, 37),
    modulator_result(Ps, Res, M+1, Modulators);
modulator_result(Ps, [Minimized,{{?TAG,enabled,M},Enabled},Mode,false|Res0],
                 M, Modulators) ->
    {Modulator,Res} = modulator(Minimized, Enabled, Mode, Res0, M),
    modulator_result(Ps, Res, M+1, [Modulator|Modulators]).

%%% Increase split_list # +1 per line if add Modulator to Dialog

modulator(Minimized, Enabled, Mode, Res0, M) ->
    {Res1,Res} = split_list(Res0, 37),
    TypeTag = {?TAG,type,M},
    {value,{TypeTag,Type}} = lists:keysearch(TypeTag, 1, Res1),
    [AlphaIntensity,SizeX,SizeY,SizeZ,
     Diffuse,Specular,Shininess,Normal,
     Filename,
     Color1,Color2,Hard,NoiseBasis,NoiseSize,Depth,
     Sharpness,Turbulence,Shape,
     WoodType,CellType,CellShape,CellSize,Intensity,CellWeight1,CellWeight2,CellWeight3,CellWeight4,
     MusgraveType,MusgraveNoiseSize,MusgraveIntensity,MusgraveContrast,
     MusgraveLacunarity,MusgraveOctaves,DistortionType,
     DistortionNoiseSize,DistortionIntensity] %% 17 values = 18-1
        = lists:keydelete(TypeTag, 1, Res1),
    Ps = [{minimized,Minimized},{enabled,Enabled},{mode,Mode},{alpha_intensity,AlphaIntensity},
          {size_x,SizeX},{size_y,SizeY},{size_z,SizeZ},
          {diffuse,Diffuse},{specular,Specular},
          {shininess,Shininess},{normal,Normal},
          {type,Type},
          {filename,Filename},{color1,Color1},{color2,Color2},{hard,Hard},
          {noise_basis,NoiseBasis},{noise_size,NoiseSize},{depth,Depth},
          {sharpness,Sharpness},{turbulence,Turbulence},{shape,Shape},
          {wood_type,WoodType},{cell_type,CellType},{cell_shape,CellShape},
          {cell_size,CellSize},{intensity,Intensity},{cell_weight1,CellWeight1},
          {cell_weight2,CellWeight2},{cell_weight3,CellWeight3},{cell_weight4,CellWeight4},
          {musgrave_type,MusgraveType},
          {musgrave_noisesize,MusgraveNoiseSize},{musgrave_intensity,MusgraveIntensity},
          {musgrave_contrast,MusgraveContrast},{musgrave_lacunarity,MusgraveLacunarity},
          {musgrave_octaves,MusgraveOctaves},{distortion_type,DistortionType},
          {distortion_noisesize,DistortionNoiseSize},
          {distortion_intensity,DistortionIntensity}
          ],
    {{modulator,Ps},Res}.



%%


%%


%%



light_dialog(Name, Ps) ->
    OpenGL = proplists:get_value(opengl, Ps, []),
    YafaRay = proplists:get_value(?TAG, Ps, []),
    Type = proplists:get_value(type, OpenGL, []),
    DefPower = case Type of
                   point -> ?DEF_ATTN_POWER;
                   spot -> ?DEF_ATTN_POWER;
                   area -> ?DEF_ATTN_POWER;
                   _ -> ?DEF_POWER
               end,
    Minimized = proplists:get_value(minimized, YafaRay, true),
    Power = proplists:get_value(power, YafaRay, DefPower),
    [{vframe,
      [{hframe,[{vframe, [{label,?__(1,"Power")}]},
                {vframe,[{text,Power,[range(power),key(power)]}]},
                panel,
                help_button(light_dialog)]}|
       light_dialog(Name, Type, YafaRay)],
      [{title,?__(2,"YafaRay Options")},key(minimized),{minimized,Minimized}]}].


%% Point Light Dialog
light_dialog(_Name, point, Ps) ->
    Type = proplists:get_value(type, Ps, ?DEF_POINT_TYPE),
    CastShadows = proplists:get_value(cast_shadows, Ps, ?DEF_CAST_SHADOWS),

    ArealightRadius = proplists:get_value(arealight_radius, Ps,
                                           ?DEF_AREALIGHT_RADIUS),
    ArealightSamples =
        proplists:get_value(arealight_samples, Ps, ?DEF_AREALIGHT_SAMPLES),

    [{vframe,[
        {hradio,[
            {?__(3,"Pointlight"),pointlight},
            {?__(5,"Spherelight"),spherelight}
        ],Type,[key(type),layout]
        },
        {?__(11,"Cast Shadows"),CastShadows,[key(cast_shadows),hook(open,[member,?KEY(type),pointlight])]},
        {vframe,[
            {hframe,[
                {label,?__(15,"Radius")},
                {text,ArealightRadius,[range(arealight_radius), key(arealight_radius)]}
            ]},
            {hframe,[
                {label,?__(17,"Samples")},
                {text,ArealightSamples,[range(samples),key(arealight_samples)]}
            ]}
        ],[hook(open, [member,?KEY(type),spherelight])]
        }
    ]}];

%% Spot Light Dialog
light_dialog(_Name, spot, Ps) ->
    Type = proplists:get_value(type, Ps, ?DEF_SPOT_TYPE),
    CastShadows = proplists:get_value(cast_shadows, Ps, ?DEF_CAST_SHADOWS),

    SpotPhotonOnly = proplists:get_value(spot_photon_only, Ps, ?DEF_SPOT_PHOTON_ONLY),
    SpotSoftShadows = proplists:get_value(spot_soft_shadows, Ps, ?DEF_SPOT_SOFT_SHADOWS),

     SpotIESFilename = proplists:get_value(spot_ies_filename, Ps,
                                      ?DEF_SPOT_IES_FILENAME),

     SpotIESSamples = proplists:get_value(spot_ies_samples, Ps,
                                      ?DEF_SPOT_IES_SAMPLES),


    BrowsePropsIES = [
        {dialog_type,open_dialog},
        {extensions,[{".ies",?__(99,"IES")}]}
    ],

    %%
    [
        {hframe,[
            {hradio,[
                {?__(29,"Spotlight"),spotlight},
                {?__(30,"IES"),spot_ies}
            ],Type,[layout,key(type)]
            }
        ]},
        {vframe,[
            {hframe,[
                {?__(97,"Photon Only"),SpotPhotonOnly,[key(spot_photon_only)]},
                {?__(34,"Cast Shadows"),CastShadows,[key(cast_shadows)]},
                {?__(98,"Soft Shadows"),SpotSoftShadows,[key(spot_soft_shadows)]},
                {label,?__(35,"Samples")},{text,SpotIESSamples,[range(spot_ies_samples),key(spot_ies_samples),
                    hook(enable, ['not',[member,?KEY(spot_soft_shadows), ?DEF_SPOT_SOFT_SHADOWS]])]}
            ]}
        ],[hook(open, [member,?KEY(type), spotlight])]
        },
    {vframe,[
        {hframe,[
            {label,?__(100,"Filename")},
            {button,{text,SpotIESFilename, [key(spot_ies_filename),{props,BrowsePropsIES}]}}
        ]},
        {hframe,[
            {hframe,[
                {?__(38,"Soft Shadows"),SpotSoftShadows,[key(spot_soft_shadows)]},
                {label,?__(37,"Samples")},{text,SpotIESSamples,[range(spot_ies_samples),key(spot_ies_samples),
                     hook(enable, ['not',[member,?KEY(spot_soft_shadows),?DEF_SPOT_SOFT_SHADOWS]])]}
            ]}
        ]}
    ],[hook(open, [member,?KEY(type), spot_ies])]
    }
    ];

%% Infinite Light Dialog
light_dialog(_Name, infinite, Ps) ->
    Type = proplists:get_value(type, Ps, ?DEF_INFINITE_TYPE),
    CastShadows = proplists:get_value(cast_shadows, Ps, ?DEF_CAST_SHADOWS),
    SunSamples = proplists:get_value(sun_samples, Ps, ?DEF_SUN_SAMPLES),
    SunAngle = proplists:get_value(sun_angle, Ps, ?DEF_SUN_ANGLE),
    SkyBackgroundLight = proplists:get_value(sky_background_light, Ps, ?DEF_SKY_BACKGROUND_LIGHT),
    SkyBackgroundPower = proplists:get_value(sky_background_power, Ps, ?DEF_SKY_BACKGROUND_POWER),
    SkyBackgroundSamples = proplists:get_value(sky_background_samples, Ps, ?DEF_SKY_BACKGROUND_SAMPLES),
    InfiniteTrue = proplists:get_value(infinite_true, Ps, ?DEF_INFINITE_TRUE),
    InfiniteRadius = proplists:get_value(infinite_radius, Ps, ?DEF_INFINITE_RADIUS),
    Bg = proplists:get_value(background, Ps, ?DEF_BACKGROUND),
    %%
    BgColor = proplists:get_value(background_color, Ps, ?DEF_BACKGROUND_COLOR),
    ConstantBackPower = proplists:get_value(constant_back_power, Ps, ?DEF_CONSTANT_BACK_POWER),
    %%
    HorizonColor = proplists:get_value(horizon_color, Ps, ?DEF_HORIZON_COLOR),
    ZenithColor = proplists:get_value(zenith_color, Ps, ?DEF_ZENITH_COLOR),
    GradientBackPower = proplists:get_value(gradient_back_power, Ps, ?DEF_GRADIENT_BACK_POWER),
    %%
    Turbidity = proplists:get_value(turbidity, Ps, ?DEF_TURBIDITY),
    A_var = proplists:get_value(a_var, Ps, ?DEF_SUNSKY_VAR),
    B_var = proplists:get_value(b_var, Ps, ?DEF_SUNSKY_VAR),
    C_var = proplists:get_value(c_var, Ps, ?DEF_SUNSKY_VAR),
    D_var = proplists:get_value(d_var, Ps, ?DEF_SUNSKY_VAR),
    E_var = proplists:get_value(e_var, Ps, ?DEF_SUNSKY_VAR),
    %%
    [
        {vframe,[
            {hradio,[
                {?__(110,"Sunlight"),sunlight},
                {?__(111,"Directional"),directional}
            ],Type,[key(type),layout]
            },
            %% Sunlight Settings Start
            {hframe,[
                {label,?__(114,"Samples")}, {text,SunSamples,[key(sun_samples),range(sun_samples)]},
                {label,?__(115,"Angle")}, {text,SunAngle,[key(sun_angle),range(sun_angle)]}
            ],[hook(open, [member,?KEY(type),sunlight])]
            },
            {?__(42,"Cast Shadows"),CastShadows,[key(cast_shadows), hook(open, [member,?KEY(type),sunlight])]},

%% Sunlight Settings End
            {?__(112,"Infinite"),InfiniteTrue,[key(infinite_true),hook(open, [member,?KEY(type),directional])]},

%% Directional Semi-infinite Radius
            {hframe,[
                {label,?__(113,"Semi-infinite Radius")},{text,InfiniteRadius,[range(infinite_radius),key(infinite_radius),
                hook(enable, ['not',[member,?KEY(infinite_true),?DEF_INFINITE_TRUE]])]}
            ],[hook(open, [member,?KEY(type),directional])]
            },
%% End Directional Semi-infinite Radius

            {vframe,[
                {hradio,[
                    {?__(43,"Constant"),constant},
                    {?__(101,"Gradient"),gradientback},
                    {?__(44,"Sunsky"),sunsky},
                    {?__(45,"None"), undefined}
                ],Bg,[layout,key(background)]
                },
%% Constant Background
                {hframe,[
                    {label,?__(46,"Color")},{color,BgColor,[key(background_color)]},
                    {label,?__(104,"Power")},{text,ConstantBackPower,[key(constant_back_power),range(power)]}
                ],[hook(open, [member,?KEY(background),constant])]
                },
%% Gradient Background
                {hframe,[
                    {label,?__(102,"Horizon Color")},{color,HorizonColor,[key(horizon_color)]},
                    {label,?__(103,"Zenith Color")},{color,ZenithColor,[key(zenith_color)]},
                    {label,?__(104,"Power")},{text,GradientBackPower,[key(gradient_back_power),range(power)]}
                ],[hook(open, [member,?KEY(background),gradientback])]
                },
%% Sunsky Background
                {vframe,[
                    {hframe,[]},
                    {hframe,[
                        {vframe,[
                            {label,?__(47,"Turbidity")},
                            {label,"a: "++?__(48,"Horizon Brightness")},
                            {label,"b: "++?__(49,"Horizon Spread")},
                            {label,"c: "++?__(50,"Sun Brightness")},
                            {label,"d: "++?__(51,"Sun Contraction")},
                            {label,"e: "++?__(52,"Sun Backscatter")}
                        ]},
                        {vframe,[
                            {text,Turbidity,[range(turbidity),key(turbidity)]},
                            {text,A_var,[key(a_var)]},
                            {text,B_var,[key(b_var)]},
                            {text,C_var,[key(c_var)]},
                            {text,D_var,[key(d_var)]},
                            {text,E_var,[key(e_var)]}
                        ]}
                    ]},
%% Start Skylight Settings
                    {?__(116,"Skylight"),SkyBackgroundLight,[key(sky_background_light),
                        hook(open, [member,?KEY(background),sunsky])]},
%% Skylight Power
                    {hframe,[
                        {label,?__(117,"Power")},
                        {text,SkyBackgroundPower,[range(sky_background_power),key(sky_background_power),
                            hook(enable, ['not',[member,?KEY(sky_background_light), ?DEF_SKY_BACKGROUND_LIGHT]])]}
%% End Enable Disable Text field
                    ],[hook(open, [member,?KEY(background),sunsky])]
                    },
%% Skylight Samples
                    {hframe,[
                        {label,?__(118,"Samples")},
                        {text,SkyBackgroundSamples,[range(sky_background_samples),key(sky_background_samples),
                            hook(enable, ['not',[member,?KEY(sky_background_light), ?DEF_SKY_BACKGROUND_LIGHT]])]}
%% End Enable Disable Text field
                    ],[hook(open, [member,?KEY(background),sunsky])]
                    }
%% End Skylight Samples

%% End Skylight Settings
                ],[hook(open, [member,?KEY(background),sunsky])]
                }
            ],[{title,?__(53,"Background")}]
            }
        ]}
    ];

%% Ambient Light Dialog
light_dialog(_Name, ambient, Ps) ->
    Bg = proplists:get_value(background, Ps, ?DEF_BACKGROUND),
    BgColor = proplists:get_value(background_color, Ps, ?DEF_BACKGROUND_COLOR),
    ConstantBackPower = proplists:get_value(constant_back_power, Ps, ?DEF_CONSTANT_BACK_POWER),
%%
    HorizonColor = proplists:get_value(horizon_color, Ps, ?DEF_HORIZON_COLOR),
    ZenithColor = proplists:get_value(zenith_color, Ps, ?DEF_ZENITH_COLOR),
    GradientBackPower = proplists:get_value(gradient_back_power, Ps, ?DEF_GRADIENT_BACK_POWER),
%%
    BgFnameImage = proplists:get_value(background_filename_image, Ps,
                                       ?DEF_BACKGROUND_FILENAME),
    BrowsePropsImage = [{dialog_type,open_dialog},
                        {extensions,[{".jpg",?__(54,"JPEG compressed image")},
                                     {".tga",?__(55,"Targa bitmap")}]}],
    BgFnameHDRI = proplists:get_value(background_filename_HDRI, Ps,
                                      ?DEF_BACKGROUND_FILENAME),
    BrowsePropsHDRI = [{dialog_type,open_dialog},
                       {extensions,[{".hdr",?__(56,"High Dynamic Range image")},
                                    {".exr",?__(95,"OpenEXR image")}]}],
    BgExpAdj = proplists:get_value(background_exposure_adjust, Ps,
                                   ?DEF_BACKGROUND_EXPOSURE_ADJUST),
    BgMapping = proplists:get_value(background_mapping, Ps,
                                    ?DEF_BACKGROUND_MAPPING),
    BgPower = proplists:get_value(background_power, Ps,
                                  ?DEF_BACKGROUND_POWER),
    BgPrefilter = proplists:get_value(background_prefilter, Ps,
                                  ?DEF_BACKGROUND_PREFILTER),
    BgEnlight = proplists:get_value(background_enlight, Ps,
                                  ?DEF_BACKGROUND_ENLIGHT),
    %%
    Type = proplists:get_value(type, Ps, ?DEF_AMBIENT_TYPE),
    Samples = proplists:get_value(samples, Ps, ?DEF_SAMPLES),


    %%


    %%
    CacheMinimized = proplists:get_value(cache_minimized, Ps, true),
    Cache = proplists:get_value(cache, Ps, ?DEF_CACHE),
    CacheSize = proplists:get_value(cache_size, Ps, ?DEF_CACHE_SIZE),
    AngleThreshold = proplists:get_value(angle_threshold, Ps,
                                         ?DEF_ANGLE_THRESHOLD),
    AngleKey = ?KEY(angle_threshold),
    AngleRange = range(angle_threshold),
    ShadowThreshold = proplists:get_value(shadow_threshold, Ps,
                                          ?DEF_SHADOW_THRESHOLD),
    Gradient = proplists:get_value(gradient, Ps, ?DEF_GRADIENT),
    ShowSamples = proplists:get_value(show_samples, Ps, ?DEF_SHOW_SAMPLES),
    Search = proplists:get_value(search, Ps, ?DEF_SEARCH),
    %%

    [{hradio,[
        {?__(57,"Hemilight"), hemilight}
        ],
        Type,[layout,key(type)]},
    %% Hemilight and Pathlight


    %% Pathlight
        {vframe,[
            {hframe,[
                {"",Cache,[key(cache)]},
                {hframe,[
                    {vframe,[
                        {label,?__(68,"Size")},
                        {label,?__(69,"Angle Threshold")},
                        panel,
                        {label,?__(70,"Shadow Threshold")},
                        {?__(71,"Gradient"),Gradient,[key(gradient)]},
                        {label,?__(72,"Search")}
                    ]},
                    {vframe,[
                        {text,CacheSize,[key(cache_size),range(cache_size)]},
                        {text,AngleThreshold,[{key,AngleKey},AngleRange]},
                        {slider,[{key,AngleKey},AngleRange]},
                        {text,ShadowThreshold,[key(shadow_threshold), range(shadow_threshold)]},
                        {?__(73,"Show Samples"),ShowSamples,[key(show_samples)]},
                        {text,Search,[key(search),range(cache_search)]}
                    ]}
                ],[{title,?__(74,"Irradiance Cache")},{minimized, CacheMinimized}, key(cache_minimized),hook(enable, ?KEY(cache))]
                }
            ],[hook(enable, ['not',?KEY(direct)])]
            }
        ],[hook(open, [member,?KEY(type),pathlight])]
        },
    %% Global Photonlight

    %% Backgrounds
        {vframe,[
            {hradio,[
                {?__(79,"HDRI"),'HDRI'},
                {?__(80,"Image"),image},
                {?__(81,"Constant"),constant},
                {?__(105,"Gradient"),gradientback},
                {?__(82,"None"), undefined}
            ],Bg,[layout,key(background)]
            },
        %% HDRI Background
            {hframe,[
                {label,?__(83,"Filename")},
                {button,{text,BgFnameHDRI,[key(background_filename_HDRI),{props,BrowsePropsHDRI}]}},
                {label,?__(61,"Samples")},
                {text,Samples,[range(samples),key(samples)]}
            ],[hook(open, [member,?KEY(background),'HDRI'])]
            },
        %% Image Background
            {hframe,[
                {label,?__(84,"Filename")},
                {button,{text,BgFnameImage,[key(background_filename_image), {props,BrowsePropsImage}]}},
                {label,?__(60,"Samples")},
                {text,Samples,[range(samples),key(samples)]}
            ],[hook(open, [member,?KEY(background),image])]
            },
        %% HDRI Background Settings
            {hframe,[
                {hframe,[
                    {label,?__(85,"Exposure")},
                    {text,BgExpAdj,[key(background_exposure_adjust), range(exposure_adjust)]},
                    {menu,[
                        {?__(86,"Light Probe (Angular)"),probe},
                        {?__(87,"Spherical (Lat-Long)"),spherical}
                    ],BgMapping,[key(background_mapping)]
                    }
                ],[hook(open, [member,?KEY(background),'HDRI'])]
                },
                {hframe,[
                    {label,?__(88,"Power")},
                    {text,BgPower,[key(background_power),range(power)]}
                ],[hook(open, [member,?KEY(background),image])]
                },
                {?__(89,"Enlight"),BgEnlight,[key(background_enlight)]},
                {?__(96,"Prefilter"),BgPrefilter,[key(background_prefilter)]}
            ],[hook(open, [member,?KEY(background),'HDRI',image])]
            },

        %% Constant Background
            {hframe,[
                {label,?__(90,"Color")},
                {color,BgColor,[key(background_color)]},
                {label,?__(109,"Power")},
                {text,ConstantBackPower,[key(constant_back_power),range(power)]}
            ],[hook(open, [member,?KEY(background),constant])]
            },

        %% Gradient Background
            {hframe,[
                {label,?__(106,"Horizon Color")},{color,HorizonColor,[key(horizon_color)]},
                {label,?__(107,"Zenith Color")},{color,ZenithColor,[key(zenith_color)]},
                {label,?__(108,"Power")},{text,GradientBackPower,[key(gradient_back_power),range(power)]}
            ],[hook(open, [member,?KEY(background),gradientback])]
            }

        ],[{title,?__(91,"Background")}]
        }
    ];

%% Area Light Dialog

light_dialog(_Name, area, Ps) ->
    ArealightSamples =
        proplists:get_value(arealight_samples, Ps, ?DEF_AREALIGHT_SAMPLES),

    CastShadows =
        proplists:get_value(cast_shadows, Ps, ?DEF_CAST_SHADOWS),

    [{?__(92,"Cast Shadows"),CastShadows,[key(cast_shadows)]},
        {hframe,[
            {label,?__(93,"Samples")},
                {text,ArealightSamples,[range(samples),key(arealight_samples)]}
        ]}
    ];

light_dialog(_Name, _Type, _Ps) ->
%%%    erlang:display({?MODULE,?LINE,{_Name,_Type,_Ps}}),
    [].

light_result(_Name, Ps0,
             [{?KEY(minimized),Minimized},{?KEY(power),Power}|Res0]) ->
    {LightPs0,Res1} = light_result(Res0),
    LightPs = [{Key,Val} || {?KEY(Key),Val} <- LightPs0],
    Ps = [{?TAG,[{minimized,Minimized},{power,Power}|LightPs]}
          |keydelete(?TAG, 1, Ps0)],
%    erlang:display({?MODULE,?LINE,[Ps,Res1]}),
    {Ps,Res1}.

%% Point
light_result([{?KEY(type),pointlight}|_]=Ps) ->
    split_list(Ps, 4);
light_result([{?KEY(type),spherelight}|_]=Ps) ->
    split_list(Ps, 4);
%% Spot
light_result([{?KEY(type),spotlight}|_]=Ps) ->
    split_list(Ps, 8);
light_result([{?KEY(type),spot_ies}|_]=Ps) ->
    split_list(Ps, 8);
%% Infinite
light_result([{?KEY(type),sunlight}|_]=Ps) ->
    split_list(Ps, 21);
light_result([{?KEY(type),directional}|_]=Ps) ->
    split_list(Ps, 21);
light_result([_,{?KEY(background),_}|_]=Ps) ->
    split_list(Ps, 21);
%% Area
light_result([_,{?KEY(arealight_samples),_}|_]=Ps) ->
    split_list(Ps, 2);
%% Ambient
light_result([{?KEY(type),hemilight}|_]=Ps) ->
    split_list(Ps, 24);
light_result([{?KEY(type),pathlight}|_]=Ps) ->
    split_list(Ps, 24);
light_result([{?KEY(type),globalphotonlight}|_]=Ps) ->
    split_list(Ps, 24);
light_result(Ps) ->
%    erlang:display({?MODULE,?LINE,Ps}),
    {[],Ps}.


    pref_dialog(St) ->
    [{dialogs,Dialogs},{renderer,Renderer},
    {options,Options},{shader_type,ShaderType}] =
        get_user_prefs([{dialogs,?DEF_DIALOGS},{renderer,?DEF_RENDERER},
                        {options,?DEF_OPTIONS},{shader_type,?DEF_SHADER_TYPE}]),



    Dialog =[
        {vframe,[
            {hframe,[
                {menu,[
                    {?__(1,"Disabled Dialogs"),disabled},
                    {?__(2,"Automatic Dialogs"),auto},
                    {?__(3,"Enabled Dialogs"),enabled}
                ],Dialogs,[{key,dialogs}]
                },panel, help_button(pref_dialog)
            ]},
            {hframe,[
                {vframe,[
                    {label,?__(4,"Executable")},
                    {label,?__(5,"Options")},
                    {label,"Default Shader"}
                ]},
                {vframe,[
                    {button,{text,Renderer,[{key,renderer}, wings_job:browse_props()]}},
                    {text,Options,[{key,options}]},
                    {menu,[
                        {"Shiny Diffuse",shinydiffuse},
                        {"Glass",glass},
                        {"Rough Glass",rough_glass},
                        {"Glossy",glossy},
                        {"Coated Glossy",coatedglossy},
                        {"Translucent (SSS)",translucent},
                        {"Light Material",lightmat}
                    ],ShaderType, [{key,shader_type},layout]
                    }
                ]}
            ]}
        ]}
    ], wpa:dialog(?__(6,"YafaRay Options"), Dialog, fun (Attr) -> pref_result(Attr,St) end).

pref_result(Attr, St) ->
    set_user_prefs(Attr),
    init_pref(),
    St.



export_dialog(Op, Ask, Title, Fun) ->
    Keep = {Op,Fun},
    wpa:dialog(Ask, Title,
               export_dialog_qs(Op, get_prefs(export_prefs())
                                ++[save,load,reset]),
               export_dialog_fun(Keep)).

export_dialog_fun(Keep) ->
    fun (Attr) -> export_dialog_loop(Keep, Attr) end.

%% Export Render Options Dialog Settings
export_prefs() ->
    [{subdivisions,?DEF_SUBDIVISIONS},
     {keep_xml,?DEF_KEEP_XML},
     {threads_number,?DEF_THREADS_NUMBER},
     {threads_auto,?DEF_THREADS_AUTO},
     {lighting_method,?DEF_LIGHTING_METHOD},
     {use_caustics,?DEF_USE_CAUSTICS},
     {caustic_photons,?DEF_CAUSTIC_PHOTONS},
     {caustic_depth,?DEF_CAUSTIC_DEPTH},
     {caustic_mix,?DEF_CAUSTIC_MIX},
     {caustic_radius,?DEF_CAUSTIC_RADIUS},
     {do_ao,?DEF_DO_AO},
     {ao_distance,?DEF_AO_DISTANCE},
     {ao_samples,?DEF_AO_SAMPLES},
     {ao_color,?DEF_AO_COLOR},
     {pm_diffuse_photons,?DEF_PM_DIFFUSE_PHOTONS},
     {pm_bounces,?DEF_PM_BOUNCES},
     {pm_search,?DEF_PM_SEARCH},
     {pm_diffuse_radius,?DEF_PM_DIFFUSE_RADIUS},
     {pm_caustic_photons,?DEF_PM_CAUSTIC_PHOTONS},
     {pm_caustic_radius,?DEF_PM_CAUSTIC_RADIUS},
     {pm_caustic_mix,?DEF_PM_CAUSTIC_MIX},
     {pm_use_background,?DEF_PM_USE_BACKGROUND},
     {pm_use_fg,?DEF_PM_USE_FG},
     {pm_fg_bounces,?DEF_PM_FG_BOUNCES},
     {pm_fg_samples,?DEF_PM_FG_SAMPLES},
     {pm_fg_show_map,?DEF_PM_FG_SHOW_MAP},
     {pt_diffuse_photons,?DEF_PT_DIFFUSE_PHOTONS},
     {pt_bounces,?DEF_PT_BOUNCES},
     {pt_caustic_type,?DEF_PT_CAUSTIC_TYPE},
     {pt_caustic_radius,?DEF_PT_CAUSTIC_RADIUS},
     {pt_caustic_mix,?DEF_PT_CAUSTIC_MIX},
     {pt_caustic_depth,?DEF_PT_CAUSTIC_DEPTH},
     {pt_use_background,?DEF_PT_USE_BACKGROUND},
     {pt_samples,?DEF_PT_SAMPLES},
     {volintegr_type,?DEF_VOLINTEGR_TYPE},
     {volintegr_adaptive,?DEF_VOLINTEGR_ADAPTIVE},
     {volintegr_optimize,?DEF_VOLINTEGR_OPTIMIZE},
     {volintegr_stepsize,?DEF_VOLINTEGR_STEPSIZE},
     {use_sss,?DEF_USE_SSS},
     {sss_photons,?DEF_SSS_PHOTONS},
     {sss_depth,?DEF_SSS_DEPTH},
     {sss_scale,?DEF_SSS_SCALE},
     {sss_singlescatter_samples,?DEF_SSS_SINGLESCATTER_SAMPLES},
     {raydepth,?DEF_RAYDEPTH},
     {gamma,?DEF_GAMMA},
     {bias,?DEF_BIAS},
     {exposure,?DEF_EXPOSURE},
     {transparent_shadows,?DEF_TRANSPARENT_SHADOWS},
     {shadow_depth,?DEF_SHADOW_DEPTH},
     {render_format,?DEF_RENDER_FORMAT},
     {exr_flag_float,false},
     {exr_flag_zbuf,false},
     {exr_flag_compression,?DEF_EXR_FLAG_COMPRESSION},
     {aa_passes,?DEF_AA_PASSES},
     {aa_minsamples,?DEF_AA_MINSAMPLES},
     {aa_jitterfirst,?DEF_AA_JITTERFIRST},
     {aa_threshold,?DEF_AA_THRESHOLD},
     {aa_pixelwidth,?DEF_AA_PIXELWIDTH},
     {clamp_rgb,?DEF_CLAMP_RGB},
     {aa_filter_type,?DEF_AA_FILTER_TYPE},
     {background_color,?DEF_BACKGROUND_COLOR},
     {save_alpha,?DEF_SAVE_ALPHA},
     {background_transp_refract,?DEF_BACKGROUND_TRANSP_REFRACT},
     {lens_type,?DEF_LENS_TYPE},
     {lens_ortho_scale,?DEF_LENS_ORTHO_SCALE},
     {lens_angular_circular,?DEF_LENS_ANGULAR_CIRCULAR},
     {lens_angular_mirrored,?DEF_LENS_ANGULAR_MIRRORED},
     {lens_angular_max_angle,?DEF_LENS_ANGULAR_MAX_ANGLE},
     {lens_angular_angle,?DEF_LENS_ANGULAR_ANGLE},
     {bokeh_use_QMC,?DEF_USE_QMC},
     {width,?DEF_WIDTH},
     {aperture,?DEF_APERTURE},
     {bokeh_type,?DEF_BOKEH_TYPE},
     {height,?DEF_HEIGHT},
     {aperture,?DEF_APERTURE},
     {bokeh_bias,?DEF_BOKEH_BIAS},
     {bokeh_rotation,?DEF_BOKEH_ROTATION},
     {dof_distance,?DEF_DOF_DISTANCE}].

export_dialog_qs(Op,
                 [{subdivisions,SubDiv},
                  {keep_xml,KeepXML},
                  {threads_number,ThreadsNumber},
                  {threads_auto,ThreadsAuto},
                  {lighting_method,Lighting_Method},
                  {use_caustics,UseCaustics},
                  {caustic_photons,Caustic_Photons},
                  {caustic_depth,Caustic_Depth},
                  {caustic_mix,Caustic_Mix},
                  {caustic_radius,Caustic_Radius},
                  {do_ao,Do_AO},
                  {ao_distance,AO_Distance},
                  {ao_samples,AO_Samples},
                  {ao_color,AO_Color},
                  {pm_diffuse_photons,PM_Diffuse_Photons},
                  {pm_bounces,PM_Bounces},
                  {pm_search,PM_Search},
                  {pm_diffuse_radius,PM_Diffuse_Radius},
                  {pm_caustic_photons,PM_Caustic_Photons},
                  {pm_caustic_radius,PM_Caustic_Radius},
                  {pm_caustic_mix,PM_Caustic_Mix},
                  {pm_use_background,PM_Use_Background},
                  {pm_use_fg,PM_Use_FG},
                  {pm_fg_bounces,PM_FG_Bounces},
                  {pm_fg_samples,PM_FG_Samples},
                  {pm_fg_show_map,PM_FG_Show_Map},
                  {pt_diffuse_photons,PT_Diffuse_Photons},
                  {pt_bounces,PT_Bounces},
                  {pt_caustic_type,PT_Caustic_Type},
                  {pt_caustic_radius,PT_Caustic_Radius},
                  {pt_caustic_mix,PT_Caustic_Mix},
                  {pt_caustic_depth,PT_Caustic_Depth},
                  {pt_use_background,PT_Use_Background},
                  {pt_samples,PT_Samples},
                  {volintegr_type,Volintegr_Type},
                  {volintegr_adaptive,Volintegr_Adaptive},
                  {volintegr_optimize,Volintegr_Optimize},
                  {volintegr_stepsize,Volintegr_Stepsize},
                  {use_sss,UseSSS},
                  {sss_photons,SSS_Photons},
                  {sss_depth,SSS_Depth},
                  {sss_scale,SSS_Scale},
                  {sss_singlescatter_samples,SSS_SingleScatter_Samples},
                  {raydepth,Raydepth},
                  {gamma,Gamma},
                  {bias,Bias},
                  {exposure,Exposure},
                  {transparent_shadows,TransparentShadows},
                  {shadow_depth,ShadowDepth},
                  {render_format,RenderFormat},
                  {exr_flag_float,ExrFlagFloat},
                  {exr_flag_zbuf,ExrFlagZbuf},
                  {exr_flag_compression,ExrFlagCompression},
                  {aa_passes,AA_passes},
                  {aa_minsamples,AA_minsamples},
                  {aa_jitterfirst,AA_jitterfirst},
                  {aa_threshold,AA_threshold},
                  {aa_pixelwidth,AA_pixelwidth},
                  {clamp_rgb,ClampRGB},
                  {aa_filter_type,AA_Filter_Type},
                  {background_color,BgColor},
                  {save_alpha,SaveAlpha},
                  {background_transp_refract,BackgroundTranspRefract},
                  {lens_type,Lens_Type},
                  {lens_ortho_scale,Lens_Ortho_Scale},
                  {lens_angular_circular,Lens_Angular_Circular},
                  {lens_angular_mirrored,Lens_Angular_Mirrored},
                  {lens_angular_max_angle,Lens_Angular_Max_Angle},
                  {lens_angular_angle,Lens_Angular_Angle},
                  {bokeh_use_QMC,BokehUseQMC},
                  {width,Width},
                  {aperture,Aperture},
                  {bokeh_type,BokehType},
                  {height,Height},
                  {aperture,_Aperture},
                  {bokeh_bias,BokehBias},
                  {bokeh_rotation,BokehRotation},
                  {dof_distance,Dof_Distance},
                  _Save,_Load,_Reset]) ->
    BiasFlags = [
        range(bias),
        {key,bias}],
        [
            {hframe,[
                {label,?__(1,"Sub-division Steps")},
                {text,SubDiv,[{key,subdivisions},range(subdivisions)]},
                case Op of
                    render ->
                    {?__(2,"Write .xml file       "),KeepXML,[{key,keep_xml}]};
                    _ ->
                        {value,KeepXML,[{key,keep_xml}]}
                end,

%% Start Threads setting
                {hframe,[
                    {label,"Threads"},
                    {text,ThreadsNumber,[range(threads_number),
                        {key,threads_number}, hook(enable, ['not',[member,threads_auto,true]])
                    ]}
                ]},
%% End Threads setting
                {?__(160,"Auto"),ThreadsAuto,[{key,threads_auto}]}

            ],[{title,?__(3,"Pre-rendering")}]
            },

            {hframe,[
                {vframe,[
                    {menu,[
                        {?__(114,"Direct Light"),directlighting},
                        {?__(115,"Photon Mapping - Global Illumination"),photonmapping},
                        {?__(140,"Path Tracing - Global Illumination"),pathtracing},
                        {?__(116,"Bidirectional Path Tracing - Global Illumination"),bidirectional}
                    ], Lighting_Method, [{key,lighting_method},layout]
                    },

%% Start Direct Lighting Menu Section


                    {hframe,[
                        {vframe,[
                            {menu,[
                                {?__(82,"Caustics Off"),false},
                                {?__(83,"Caustics On"),true}
                            ],UseCaustics, [{key,use_caustics},layout]
                            },
                            {hframe,[
                                {vframe,[
                                    {label,?__(84,"Photons")},
                                    {label,?__(85,"Depth")}
                                ]},
                                {vframe,[
                                    {text,Caustic_Photons,[range(caustic_photons),{key,caustic_photons}]},
                                    {text,Caustic_Depth,[range(caustic_depth),{key,caustic_depth}]}
                                ]},
                                {vframe,[
                                    {label,?__(86,"Mix")},
                                    {label,?__(87,"Radius")}
                                ]},
                                {vframe,[
                                    {text,Caustic_Mix,[range(caustic_mix),{key,caustic_mix}]},
                                    {text,Caustic_Radius,[range(caustic_radius),{key,caustic_radius}]}
                                ]}
                            ],[hook(open, [member,use_caustics,true])]
                            }
                        ]},
                        {vframe,[
                            {menu,[
                                {?__(95,"Ambient Occlusion Off"),false},
                                {?__(96,"Ambient Occlusion On"),true}
                            ], Do_AO, [{key,do_ao},layout]
                            },
                            {hframe,[
                                {vframe,[
                                {label,?__(97,"AO Distance")},
                                {label,?__(98,"AO Samples")}
                            ]},
                                {vframe, [
                                {text,AO_Distance,[range(ao_distance),{key,ao_distance}]},
                                {text,AO_Samples,[range(ao_samples),{key,ao_samples}]}
                            ]},
                                {vframe,[
                                {label,?__(99,"AO Color")}
                            ]},
                                {vframe,[
                                {color,AO_Color,[{key,ao_color}]}
                            ]}
                            ],[hook(open, [member,do_ao,true])]
                            }
                    ]}
                    ],[hook(open, [member,lighting_method,directlighting])]
                    },

 %% Start Photon Mapping Menu Section

                    {hframe,[
                        {vframe,[
                            {label,?__(121,"Photons")},
                            {label,?__(122,"Bounces")},
                            {label,?__(123,"Search")},
                            {label,?__(124,"Diffuse Radius")}
                        ]},
                        {vframe,[
                            {text,PM_Diffuse_Photons,[range(pm_diffuse_photons),{key,pm_diffuse_photons}]},
                            {text,PM_Bounces,[range(pm_bounces),{key,pm_bounces}]},
                            {text,PM_Search,[range(pm_search),{key,pm_search}]},
                            {text,PM_Diffuse_Radius,[range(pm_diffuse_radius),{key,pm_diffuse_radius}]}
                        ]},
                        {vframe,[
                            {label,?__(125,"Caustic Photons")},
                            {label,?__(126,"Caustic Radius")},
                            {label,?__(127,"Caustic Mix")}
                        ]},
                        {vframe,[
                            {text,PM_Caustic_Photons,[range(pm_caustic_photons),{key,pm_caustic_photons}]},
                            {text,PM_Caustic_Radius,[range(pm_caustic_radius),{key,pm_caustic_radius}]},
                            {text,PM_Caustic_Mix,[range(pm_caustic_mix),{key,pm_caustic_mix}]},
                            {?__(157,"Use Bkgnd"),PM_Use_Background,[{key,pm_use_background}]}
                        ]},
                        {vframe,[
                            {menu,[
                                {?__(128,"Final Gather Off"),false},
                                {?__(129,"Final Gather On"),true}
                            ],PM_Use_FG, [{key,pm_use_fg},layout]
                            },
                            {hframe,[
                        {vframe,[
                            {label,?__(130,"FG Bounces")},
                            {label,?__(131,"FG Samples")}
                        ]},
                        {vframe,[
                            {text,PM_FG_Bounces,[range(pm_fg_bounces),{key,pm_fg_bounces}]},
                            {text,PM_FG_Samples,[range(pm_fg_samples),{key,pm_fg_samples}]},
                            {?__(132,"Show Map"),PM_FG_Show_Map,[{key,pm_fg_show_map}]}
                        ]}
                        ],[hook(open, [member,pm_use_fg,true])]
                        }
                        ]}
                    ],[hook(open, [member,lighting_method,photonmapping])]
                    },

 %% Start Path Tracing Menu Section

                    {hframe,[
                        {vframe,[
                            {label,?__(141,"Photons")},
                            {label,?__(142,"Bounces")}
                        ]},
                        {vframe,[
                            {text,PT_Diffuse_Photons,[range(pt_diffuse_photons),{key,pt_diffuse_photons}]},
                            {text,PT_Bounces,[range(pt_bounces),{key,pt_bounces}]}
                        ]},
                        {vframe,[
                            {label,?__(145,"Caustic Type")},
                            {label,?__(146,"Caustic Radius")},
                            {label,?__(147,"Caustic Mix")},
                            {label,?__(148,"Caustic Depth")}
                        ]},
                        {vframe,[
                            {menu,[
                                {?__(153,"path"),path},
                                {?__(154,"photons"),photons},
                                {?__(155,"both"),both},
                                {?__(156,"none"),none}
                            ],PT_Caustic_Type, [{key,pt_caustic_type},layout]
                            },
                            {text,PT_Caustic_Radius,[range(pt_caustic_radius),{key,pt_caustic_radius}]},
                            {text,PT_Caustic_Mix,[range(pt_caustic_mix),{key,pt_caustic_mix}]},
                            {text,PT_Caustic_Depth,[range(pt_caustic_depth),{key,pt_caustic_depth}]}
                        ]},
                        {vframe,[
                            {hframe,[
                                {vframe,[
                                    {label,?__(152,"Path Samples")},
                                    {?__(158,"Use Bkgnd"),PT_Use_Background,[{key,pt_use_background}]}
                                ]},
                                {vframe,[
                                    {text,PT_Samples,[range(pt_samples),{key,pt_samples}]}
                                ]}
                            ]}
                        ]}
                    ],[hook(open, [member,lighting_method,pathtracing])]
                    }
                ],[{title,?__(113,"Lighting")}]
                }
            ]},
            {hframe,[
                {menu,[
                    {?__(89,"None"),none},
                    {?__(90,"SingleScatter"),singlescatterintegrator}
                ],Volintegr_Type, [{key,volintegr_type},layout]
                },
                {hframe,[
                    {vframe,[
                        {?__(91,"Adaptive"),Volintegr_Adaptive,[{key,volintegr_adaptive}]},
                        {?__(92,"Optimize"),Volintegr_Optimize,[{key,volintegr_optimize}]}
                    ]},
                    {vframe,[
                        {label,?__(93,"StepSize")}
                    ]},
                    {vframe,[
                        {text,Volintegr_Stepsize,[range(volintegr_stepsize),{key,volintegr_stepsize}]}
                    ]}
                ],[hook(open, [member,volintegr_type,singlescatterintegrator])]
                }
            ],[{title,?__(88,"Volumetrics")}]
            },

            {hframe,[
                {menu,[
                    {?__(75,"Disabled"),false},
                    {?__(76,"Enabled"),true}
                ],UseSSS,[{key,use_sss},layout]
                },
                {hframe,[
                    {vframe,[
                        {label,?__(77,"Photons")},
                        {label,?__(78,"Depth")}
                    ]},
                    {vframe,[
                        {text,SSS_Photons,[range(sss_photons),{key,sss_photons}]},
                        {text,SSS_Depth,[range(sss_depth),{key,sss_depth}]}
                    ]},
                    {vframe,[
                        {label,?__(79,"Scale")},
                        {label,?__(80,"SingleScatter Samples")}
                    ]},
                    {vframe,[
                        {text,SSS_Scale,[range(sss_scale),{key,sss_scale}]},
                        {text,SSS_SingleScatter_Samples,[range(sss_singlescatter_samples),
                            {key,sss_singlescatter_samples}]}
                    ]}
                ],[hook(open, [member,use_sss,true])]
                }
            ],[{title,?__(74,"SubSurface Scattering - YafaRay 0.1.3 - Photon Mapping, Path Tracing")}]
            },
            {hframe,[
                {vframe,[
                    {label,?__(4,"Raydepth")},
                    {label,?__(5,"Gamma")}
                ]},
                {vframe,[
                    {text,Raydepth,[range(raydepth),{key,raydepth}]},
                    {text,Gamma,[range(gamma),{key,gamma}]}
                ]},
                {vframe,[
                    {label,?__(6,"Bias")},
                    {label,?__(7,"Exposure")}
                ]},
                {vframe,[
                    {text,Bias,BiasFlags},
                    {text,Exposure,[range(exposure),{key,exposure}]}
                ]},
                {vframe,[
                    {vframe,[
                        {menu,[
                            {?__(133,"Transp Shadows Off"),false},
                            {?__(134,"Transp Shadows On"),true}
                        ],TransparentShadows,[{key,transparent_shadows},layout]
                        },
                        {hframe,[
                            {vframe,[
                                {label,?__(135,"Depth")}
                            ]},
                            {vframe,[
                                {text,ShadowDepth,[range(shadow_depth),{key,shadow_depth}]}
                            ]}
                        ],[hook(open, [member,transparent_shadows,true])]
                        }
                    ]}
                ]}
            ],[{title,?__(8,"Render")}]
            },
            {hframe,[
                {menu,[
                    {Ext++" ("++Desc++")",Format}
                    || {Format,Ext,Desc} <- wings_job:render_formats(),
                   (Format == tga) or (Format == tif) or (Format == png) or
                   (Format == hdr) or (Format == exr)
                ],RenderFormat,[{key,render_format},layout]
                },
                {hframe,[
                    {?__(9,"Float"),ExrFlagFloat,[{key,exr_flag_float}]},
                    {?__(10,"Zbuf"),ExrFlagZbuf,[{key,exr_flag_zbuf}]},
                    {label," "++?__(11,"Compression:")},
                    {menu,[
                        {?__(12,"none"),compression_none},
                        {"piz",compression_piz},
                        {"rle",compression_rle},
                        {"pxr24",compression_pxr24},
                        {"zip",compression_zip}
                    ],ExrFlagCompression,[{key,exr_flag_compression}]
                    }
                ],[hook(open, [member,render_format,exr])]
                }
            ],[{title,?__(13,"Image Output")}]
            },
            {hframe,[
                {vframe,[
                    {hframe,[
                        {vframe,[
                            {label,?__(14,"AA. Passes")},
                            {label,?__(15,"Min. Samples")}
                        ]},
                        {vframe,[
                            {text,AA_passes,[range(aa_passes),{key,aa_passes}]},
                            {text,AA_minsamples,[range(aa_minsamples),{key,aa_minsamples}]}
                        ]}
                    ]},
                    {?__(16,"AA_jitterfirst"),AA_jitterfirst,[{key,aa_jitterfirst}]}
                ]},
                {vframe,[
                    {hframe,[
                        {vframe,[
                            {label,?__(17,"Threshold")},
                            {label,?__(18,"Pixelwidth")}
                        ]},
                        {vframe,[
                            {text,AA_threshold,[range(aa_threshold),{key,aa_threshold}]},
                            {text,AA_pixelwidth,[range(aa_pixelwidth),{key,aa_pixelwidth}]}
                        ]}
                    ]},
                    {?__(19,"Clamp RGB"),ClampRGB,[{key,clamp_rgb}]}
                ]},
                {vframe,[
                    {menu,[
                        {?__(136,"Box Filter"),box},
                        {?__(137,"Gaussian Filter"),gauss},
                        {?__(138,"Mitchell-Netravali Filter"),mitchell},
                        {?__(139,"Lanczos Filter"),lanczos}
                    ],AA_Filter_Type,[{key,aa_filter_type},layout]
                    }
                ]}
            ],[{title,?__(20,"Anti-Aliasing")}]
            },
            {hframe,[
                {label,?__(21,"Default Color")},
                {color,BgColor,[{key,background_color}]},
                {label,?__(22,"Alpha Channel:")},
                {menu,[
                    {?__(23,"Off"),false},
                    {?__(61,"On"),true},
                    {?__(24,"Premultiply"),premultiply},
                    {?__(25,"Backgroundmask"),backgroundmask}
                ],SaveAlpha,[{key,save_alpha}]
                },
                {?__(159,"Transp Refraction"),BackgroundTranspRefract,[{key,background_transp_refract}]}
            ],[{title,?__(26,"Background")}]
            },
        %% Camera
            {hframe,[
                {vframe,[
                    {menu,[
                        {?__(102,"Perspective"),perspective},
                        {?__(103,"Orthographic"),orthographic},
                        {?__(104,"Architect"),architect},
                        {?__(105,"Fish Eye (Angular)"),angular}
                    ],Lens_Type,[{key,lens_type},layout]
                    },
                    {hframe,[
                        {vframe,[
                            {label,?__(108,"Scale")}
                        ]},
                        {vframe,[
                            {text,Lens_Ortho_Scale,[range(lens_ortho_scale),{key,lens_ortho_scale}]}
                        ]}
                    ],[hook(open, [member,lens_type,orthographic])]
                    },
                    {hframe,[
                        {vframe,[
                            {?__(109,"Circular"),Lens_Angular_Circular,[{key,lens_angular_circular}]},
                            {?__(110,"Mirrored"),Lens_Angular_Mirrored,[{key,lens_angular_mirrored}]}
                        ]},
                        {vframe,[
                            {label,?__(111,"Circle/Max Angle")},
                            {label,?__(112,"Frame/Angle")}
                        ]},
                        {vframe,[
                            {text,Lens_Angular_Max_Angle,[range(lens_angular_max_angle),{key,lens_angular_max_angle}]},
                            {text,Lens_Angular_Angle,[range(lens_angular_angle),{key,lens_angular_angle}]}
                        ]}
                    ],[hook(open, [member,lens_type,angular])]
                    },
                    {hframe,[
                        panel,
                        {?__(32,"Use QMC"),BokehUseQMC, [{key,bokeh_use_QMC},hook(enable,['not',[member,aperture,0.0]])]
                        }
                    ]},panel
                ]},
                {vframe,[
                    {label,?__(33,"Width")},
                    {label,?__(34,"Aperture")},
                    {label,?__(35,"DOF Type")},
                    {label,?__(36,"DOF Rotation")},
                    {label,?__(100,"DOF Distance")}
                ]},
                {vframe,[
                    {hframe,[
                        {vframe,[
                            {text,Width,[range(pixels),{key,width},{width,6}]},
                            {text,Aperture,[range(aperture),{key,aperture},{width,6}]},
                            {menu,[
                                {?__(37,"Disk1"),disk1},
                                {?__(38,"Disk2"),disk2},
                                {?__(39,"Triangle"),triangle},
                                {?__(40,"Square"),square},
                                {?__(41,"Pentagon"),pentagon},
                                {?__(42,"Hexagon"),hexagon},
                                {?__(43,"Ring"),ring}
                            ], BokehType,[{key,bokeh_type},hook(enable,['not',[member,aperture,0.0]])]
                            }
                        ]},
                        {vframe,[
                            {label,?__(44,"Height")},
                            {label,?__(45,"f-stop")},
                            {label,?__(46,"Bias")}
                        ]},
                        %%
                        {vframe,[
                            {text,Height,[range(pixels),{key,height},{width,6}]},
                            {menu,[
                                {F,math:sqrt(A)}
                                || {F,A} <- [{"1.0",1/1},{"1.4",1/2},{"2",1/4},
                                        {"2.8",1/8},{"4",1/16},{"5.6",1/32},
                                        {"8",1/64},{"11",1/128},{"16",1/256},
                                        {"22",1/512},{"32",1/1024},
                                        {?__(47,"pinhole"),0.0}]
                            ],Aperture,[{key,aperture}]
                            },
                            {menu,[
                                {?__(48,"Uniform"),uniform},
                                {?__(49,"Center"),center},
                                {?__(50,"Edge"),edge}
                            ],BokehBias,[{key,bokeh_bias},hook(enable,['not',[member,aperture,0.0]])]
                            }
                        ]}
                    ]},
                    {slider,{text,BokehRotation,[range(bokeh_rotation),{key,bokeh_rotation},
                        hook(enable,['not',[member,aperture,0.0]])]}},
                    {slider,{text,Dof_Distance,[range(dof_distance),{key,dof_distance},
                        hook(enable,['not',[member,aperture,0.0]])]}}
                ]}
            ],[{title,?__(51,"Camera")}]
            },
            {hframe,[
                {button,?__(55,"Save"),done,[{info,?__(56,"Save to user preferences")}]},
                {button,?__(57,"Load"),done,[{info,?__(58,"Load from user preferences")}]},
                {button,?__(59,"Reset"),done,[{info,?__(60,"Reset to default values")}]}
            ]}
        ].

%%% Increase split_list # +1 per line if add Render Settings to Dialog
%%%


export_dialog_loop({Op,Fun}=Keep, Attr) ->
    {Prefs,Buttons} = split_list(Attr, 78),
    case Buttons of
        [true,false,false] -> % Save
            set_user_prefs(Prefs),
            {dialog,
             export_dialog_qs(Op, Attr),
             export_dialog_fun(Keep)};
        [false,true,false] -> % Load
            {dialog,
             export_dialog_qs(Op,
                              get_user_prefs(export_prefs())
                              ++[save,load,reset]),
             export_dialog_fun(Keep)};
        [false,false,true] -> % Reset
            {dialog,
             export_dialog_qs(Op,
                              export_prefs()++[save,load,reset]),
             export_dialog_fun(Keep)};
        [false,false,false] -> % Ok
            Fun(Prefs)
    end.

%% General purpose hook handling is_minimized and is_disabled.
%% Does lookup in Store for combinations of values.
%%
hook(Props) when is_list(Props) ->
    {hook,
     fun (is_minimized, {_Var,I,Store}) ->
             case proplists:lookup(open, Props) of
                 {_,Expr} ->
                     not hook_eval(Expr, I, Store);
                 none -> void
             end;
         (is_disabled, {_Var,I,Store}) ->
             case proplists:lookup(enable, Props) of
                 {_,Expr} ->
                     not hook_eval(Expr, I, Store);
                 none -> void
             end;
         (_, _) -> void
     end}.

hook(Op, Expr) -> hook([{Op,Expr}]).

hook_eval(['not',Expr], I, Store) ->
    not hook_eval(Expr, I, Store);
hook_eval(['and'|Exprs], I, Store) ->
    hook_and(Exprs, I, Store);
hook_eval(['or'|Exprs], I, Store) ->
    hook_or(Exprs, I, Store);
hook_eval([member,Expr|Keys], I, Store) ->
    lists:member(hook_eval(Expr, I, Store), Keys);
hook_eval([key,Key], I, Store) ->
    hook_key(Key, I, Store);
hook_eval(Key, I, Store) when not is_list(Key) ->
    hook_key(Key, I, Store).

hook_key(Key, I, Store) when is_integer(Key) ->
    gb_trees:get(I+Key, Store);
hook_key(Key, _I, Store) ->
    gb_trees:get(Key, Store).

hook_and([Expr], I, Store) ->
    hook_eval(Expr, I, Store);
hook_and([Expr|Exprs], I, Store) ->
    hook_eval(Expr, I, Store) andalso hook_and(Exprs, I, Store).

hook_or([Expr], I, Store) ->
    hook_eval(Expr, I, Store);
hook_or([Expr|Exprs], I, Store) ->
    hook_eval(Expr, I, Store) orelse hook_or(Exprs, I, Store).



%%% Export and rendering functions
%%%

export(Attr, Filename, #e3d_file{objs=Objs,mat=Mats,creator=Creator}) ->
    wpa:popup_console(),
    ExportTS = erlang:now(),
    Render = proplists:get_value(?TAG_RENDER, Attr, false),
    KeepXML = proplists:get_value(keep_xml, Attr, ?DEF_KEEP_XML),
    RenderFormat =
        proplists:get_value(render_format, Attr, ?DEF_RENDER_FORMAT),
    ExportDir = filename:dirname(Filename),
    {ExportFile,RenderFile} =
        case {Render,KeepXML} of
            {true,true} ->
                {filename:rootname(Filename)++".xml",
                 Filename};
            {true,false} ->
                {filename:join(ExportDir,
                               ?MODULE_STRING++"-"
                               ++wings_job:uniqstr()++".xml"),
                 Filename};
            {false,_} ->
                {value,{RenderFormat,Ext,_}} =
                    lists:keysearch(RenderFormat, 1,
                                    wings_job:render_formats()),
                {Filename,filename:rootname(Filename)++Ext}
        end,
    F = open(ExportFile, export),
    io:format(?__(1,"Exporting  to:")++" ~s~n"++
              ?__(2,"for render to:")++" ~s~n", [ExportFile,RenderFile]),
    CreatorChg = re:replace(Creator,"-","_",[global]),
    CameraName = "x_Camera",
    ConstBgName = "x_ConstBackground",
    Lights = proplists:get_value(lights, Attr, []),
    %%
    println(F,  "<?xml version=\"1.0\"?>~n"++
                "<!-- ~s: Exported from ~s -->~n"++
            "~n"++

            "<scene type=\"triangle\">", [filename:basename(ExportFile), CreatorChg]),
    %%
    section(F, "Materials"),
    MatsGb =
        foldl(fun ({Name,Mat}, Gb) ->
                      export_shader(F, "w_"++format(Name), Mat, ExportDir),
                      println(F),
                      gb_trees:insert(Name, Mat, Gb)
              end, gb_trees:empty(), Mats),
    %%
%*   MatsBlend =
        foldl(fun ({Name,Mat}, Gb) ->
                      export_shaderblend(F, "w_"++format(Name), Mat, ExportDir),
                      println(F),
                      gb_trees:insert(Name, Mat, Gb)
              end, gb_trees:empty(), Mats),


    %%

%%Start Micheus Code for Meshlights Even Better
section(F, "Objects"),
    foldr(fun (#e3d_object{name=Name,obj=Mesh}, Id) ->
            export_object(F, "w_"++format(Name), Mesh, MatsGb, Id),
            println(F),
            Id+1
        end, 1, Objs),
%%End Micheus Code for Meshlights Even Better


    %%
    section(F, "Lights"),
    BgLights =
        reverse(
          foldl(fun ({Name,Ps}=Light, Bgs) ->
                        Bg = export_light(F, "w_"++format(Name), Ps),
                        println(F),
                        case Bg of
                            undefined -> Bgs;
                            _ -> [Light|Bgs]
                        end
                end, [], Lights)),
    %%
    section(F, "Background, Camera, Filter and Render"),
    warn_multiple_backgrounds(BgLights),
    BgName =
        case BgLights of
            [] ->
                BgColor = proplists:get_value(background_color, Attr,
                                              ?DEF_BACKGROUND_COLOR),
                Ps = [{?TAG,[{background,constant},
                             {background_color,BgColor}]}],
                export_background(F, ConstBgName, Ps),
                ConstBgName;
            [{Name,Ps}|_] ->
                N = "w_"++format(Name),
                export_background(F, N, Ps),
                N
        end,
    println(F),
    export_camera(F, CameraName, Attr),
    println(F),
    export_render(F, CameraName, BgName, filename:basename(RenderFile), Attr),
    %%
    println(F),
    println(F, "</scene>"),
    close(F),
    %%
    [{options,Options}] =
        get_user_prefs([{options,?DEF_OPTIONS}]),
    case {get_var(renderer),Render} of
        {_,false} ->
            wings_job:export_done(ExportTS),
            io:nl();
        {false,true} ->
            %% Should not happen since the file->render dialog
            %% must have been disabled
            if KeepXML -> ok; true -> file:delete(ExportFile) end,
            no_renderer;
        {_,true} when ExportFile == RenderFile ->
            export_file_is_render_file;
        {Renderer,true} ->
    SaveAlpha = proplists:get_value(save_alpha, Attr),
        AlphaChannel =  case SaveAlpha of
                false -> "";
                _ ->
                    "-a "
            end,

            ArgStr = Options++case Options of
                                  [] -> [];
                                  _ -> " "
                              end
                ++wings_job:quote(filename:basename(ExportFile)),
            PortOpts = [{cd,filename:dirname(ExportFile)}],
            Handler =
                fun (Status) ->
                        if KeepXML -> ok; true -> file:delete(ExportFile) end,
                        set_var(rendering, false),
                        case Status of
                            ok -> {RenderFormat,RenderFile};
                            _  -> Status
                        end
                end,
            file:delete(RenderFile),
            set_var(rendering, true),
            wings_job:render(ExportTS, Renderer,AlphaChannel++"-f "++format(RenderFormat)++" "++ArgStr++" "++wings_job:quote(filename:rootname(Filename))++" ", PortOpts, Handler)
    end.

warn_multiple_backgrounds([]) ->
    ok;
warn_multiple_backgrounds([_]) ->
    ok;
warn_multiple_backgrounds(BgLights) ->
    io:format(?__(1,"WARNING: Multiple backgrounds")++" - ", []),
    foreach(fun ({Name,_}) ->
                    io:put_chars([format(Name), $ ])
            end, BgLights),
    io:nl(),
    ok.



% template(F, Fun_0) ->
%     println(F, "<!-- Begin Template"),
%     Fun_0(),
%     println(F, "End Template -->").

section(F, Name) ->
    println(F, [io_lib:nl(),"<!-- Section ",Name," -->",io_lib:nl()]).

%%% Export Material Properties
%%%


export_shader(F, Name, Mat, ExportDir) ->
    YafaRay = proplists:get_value(?TAG, Mat, []),

     DefShaderType = get_pref(shader_type, YafaRay),
     ShaderType =
        proplists:get_value(shader_type, YafaRay, DefShaderType),

    case ShaderType of

        shinydiffuse ->
            export_shinydiffuse_shader(F, Name, Mat, ExportDir, YafaRay);
        glossy ->
            export_glossy_shader(F, Name, Mat, ExportDir, YafaRay);
        coatedglossy ->
            export_coatedglossy_shader(F, Name, Mat, ExportDir, YafaRay);

        translucent ->
            export_translucent_shader(F, Name, Mat, ExportDir, YafaRay);

       glass ->
            export_glass_shader(F, Name, Mat, ExportDir, YafaRay);

       lightmat ->
            export_lightmat_shader(F, Name, Mat, ExportDir, YafaRay);

       rough_glass ->
            export_rough_glass_shader(F, Name, Mat, ExportDir, YafaRay);

        blend_mat ->
            ok

            end.

%%% Export Shiny Diffuse Material
%%%

export_shinydiffuse_shader(F, Name, Mat, ExportDir, YafaRay) ->
    OpenGL = proplists:get_value(opengl, Mat),
    Maps = proplists:get_value(maps, Mat, []),
    Modulators = proplists:get_value(modulators, YafaRay, def_modulators(Maps)),
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
                  case export_texture(F, [Name,$_,format(N)],
                                      Maps, ExportDir, M) of
                      off -> N+1;
                      ok ->
                          println(F),
                          N+1
                  end;
              (_, N) ->
                  N % Ignore old modulators
          end, 1, Modulators),
    println(F, "<material name=\"~s\">~n"++
            "<type sval=\"shinydiffusemat\"/>", [Name]),
    DiffuseA = {_,_,_,Opacity} = proplists:get_value(diffuse, OpenGL),

    Specular = alpha(proplists:get_value(specular, OpenGL)),
    DefReflected = Specular,
    DefTransmitted = def_transmitted(DiffuseA),

    %% XXX Wings scaling of shininess is weird. Commonly this value
    %% is the cosine power and as such in the range 0..infinity.
    %% OpenGL limits this to 0..128 which mostly is sufficient.
    println(F, "       <hard fval=\"~.10f\"/>",
                   [proplists:get_value(shininess, OpenGL)*128.0]),
    export_rgb(F, mirror_color,
               proplists:get_value(reflected, YafaRay, DefReflected)),
    export_rgb(F, color,
               proplists:get_value(transmitted, YafaRay, DefTransmitted)),

    IOR = proplists:get_value(ior, YafaRay, ?DEF_IOR),
    TIR = proplists:get_value(tir, YafaRay, ?DEF_TIR),


    Transparency =
        proplists:get_value(transparency, YafaRay, ?DEF_TRANSPARENCY),
    TransmitFilter =
        proplists:get_value(transmit_filter, YafaRay, ?DEF_TRANSMIT_FILTER),
    Translucency =
        proplists:get_value(translucency, YafaRay, ?DEF_TRANSLUCENCY),
    DiffuseReflect =
        proplists:get_value(diffuse_reflect, YafaRay, ?DEF_DIFFUSE_REFLECT),
    SpecularReflect =
        proplists:get_value(specular_reflect, YafaRay, ?DEF_SPECULAR_REFLECT),
    Emit =
        proplists:get_value(emit, YafaRay, ?DEF_EMIT),
    OrenNayar =
        proplists:get_value(oren_nayar, YafaRay, ?DEF_OREN_NAYAR),
    DefAbsorptionColor =
        def_absorption_color(proplists:get_value(diffuse, OpenGL)),

    AbsorptionColor =
        proplists:get_value(absorption_color, YafaRay, DefAbsorptionColor),


    case AbsorptionColor of
        [ ] -> ok;
        {AbsR,AbsG,AbsB} ->
            AbsD =
                proplists:get_value(absorption_dist, YafaRay,
                                    ?DEF_ABSORPTION_DIST),
            export_rgb(F, absorption, {-math:log(max(AbsR, ?NONZERO))/AbsD,
                                       -math:log(max(AbsG, ?NONZERO))/AbsD,
                                       -math:log(max(AbsB, ?NONZERO))/AbsD})
    end,
    DispersionPower =
        proplists:get_value(dispersion_power, YafaRay, ?DEF_DISPERSION_POWER),
    case DispersionPower of
        0.0 -> ok;
        _   ->
            DispersionSamples =
                proplists:get_value(dispersion_samples, YafaRay,
                                    ?DEF_DISPERSION_SAMPLES),
            DispersionJitter =
                proplists:get_value(dispersion_jitter, YafaRay,
                            ?DEF_DISPERSION_JITTER),
            println(F, "       "
                    "        <dispersion_samples ival=\"~w\"/>~n"
                    "        <dispersion_jitter bval=\"~s\"/>",
                    [DispersionSamples,
                     format(DispersionJitter)])
    end,

    case OrenNayar of
        false -> ok;
        _ ->
           OrenNayarSigma = proplists:get_value(oren_nayar_sigma, YafaRay,
                                        ?DEF_OREN_NAYAR_SIGMA),

            println(F, "        <diffuse_brdf sval=\"oren_nayar\"/>~n"
                    "        <sigma fval=\"~.10f\"/>",
                    [OrenNayarSigma])
    end,


    println(F, "        <IOR fval=\"~.10f\"/>~n"
            "        <fresnel_effect bval=\"~s\"/>~n"
            "        <transmit_filter fval=\"~.10f\"/>~n"
            "        <translucency fval=\"~.10f\"/>~n"
            "        <transparency fval=\"~.10f\"/>~n"
            "        <diffuse_reflect fval=\"~.10f\"/>~n"
            "        <specular_reflect fval=\"~.10f\"/>~n"
            "        <emit fval=\"~.10f\"/>~n",
            [IOR,format(TIR),TransmitFilter,Translucency,Transparency,DiffuseReflect,SpecularReflect,Emit]),
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
                  case export_modulator(F, [Name,$_,format(N)],
                                        Maps, M, Opacity) of
                      off -> N+1;
                      ok ->
                          println(F),
                          N+1
                  end;
              (_, N) ->
                  N % Ignore old modulators
          end, 1, Modulators),
    println(F, "</material>").



%%% Export Glossy Material
%%%

export_glossy_shader(F, Name, Mat, ExportDir, YafaRay) ->
    OpenGL = proplists:get_value(opengl, Mat),
    Maps = proplists:get_value(maps, Mat, []),
    Modulators = proplists:get_value(modulators, YafaRay, def_modulators(Maps)),
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
                  case export_texture(F, [Name,$_,format(N)],
                                      Maps, ExportDir, M) of
                      off -> N+1;
                      ok ->
                          println(F),
                          N+1
                  end;
              (_, N) ->
                  N % Ignore old modulators
          end, 1, Modulators),
    println(F, "<material name=\"~s\">~n"++
            "<type sval=\"glossy\"/>", [Name]),
    DiffuseA = {_,_,_,Opacity} = proplists:get_value(diffuse, OpenGL),

    Specular = alpha(proplists:get_value(specular, OpenGL)),
    DefReflected = Specular,
    DefTransmitted = def_transmitted(DiffuseA),

    %% XXX Wings scaling of shininess is weird. Commonly this value
    %% is the cosine power and as such in the range 0..infinity.
    %% OpenGL limits this to 0..128 which mostly is sufficient.
    println(F, "       <hard fval=\"~.10f\"/>",
                   [proplists:get_value(shininess, OpenGL)*128.0]),
    export_rgb(F, color,
               proplists:get_value(reflected, YafaRay, DefReflected)),
    export_rgb(F, diffuse_color,
               proplists:get_value(transmitted, YafaRay, DefTransmitted)),


    DiffuseReflect = proplists:get_value(diffuse_reflect, YafaRay, ?DEF_DIFFUSE_REFLECT),

    GlossyReflect = proplists:get_value(glossy_reflect, YafaRay, ?DEF_GLOSSY_REFLECT),

    Exponent = proplists:get_value(exponent, YafaRay, ?DEF_EXPONENT),

    OrenNayar = proplists:get_value(oren_nayar, YafaRay, ?DEF_OREN_NAYAR),

    DefAbsorptionColor = def_absorption_color(proplists:get_value(diffuse, OpenGL)),

    AbsorptionColor =
        proplists:get_value(absorption_color, YafaRay, DefAbsorptionColor),


    case AbsorptionColor of
        [ ] -> ok;
        {AbsR,AbsG,AbsB} ->
            AbsD =
                proplists:get_value(absorption_dist, YafaRay,
                                    ?DEF_ABSORPTION_DIST),
            export_rgb(F, absorption, {-math:log(max(AbsR, ?NONZERO))/AbsD,
                                       -math:log(max(AbsG, ?NONZERO))/AbsD,
                                       -math:log(max(AbsB, ?NONZERO))/AbsD})
    end,
    DispersionPower =
        proplists:get_value(dispersion_power, YafaRay, ?DEF_DISPERSION_POWER),
    case DispersionPower of
        0.0 -> ok;
        _   ->
            DispersionSamples =
                proplists:get_value(dispersion_samples, YafaRay,
                                    ?DEF_DISPERSION_SAMPLES),
            DispersionJitter =
                proplists:get_value(dispersion_jitter, YafaRay,
                            ?DEF_DISPERSION_JITTER),
            println(F, "       "
                    "        <dispersion_samples ival=\"~w\"/>~n"
                    "        <dispersion_jitter bval=\"~s\"/>",
                    [DispersionSamples,
                     format(DispersionJitter)])
    end,

    case OrenNayar of
        false -> ok;
        _ ->
           OrenNayarSigma = proplists:get_value(oren_nayar_sigma, YafaRay,
                                        ?DEF_OREN_NAYAR_SIGMA),

            println(F, "        <diffuse_brdf sval=\"oren_nayar\"/>~n"
                    "        <sigma fval=\"~.10f\"/>",
                    [OrenNayarSigma])
    end,



    println(F, "  <diffuse_reflect fval=\"~.10f\"/>~n"
            "        <glossy_reflect fval=\"~.10f\"/>~n"
            "        <exponent fval=\"~.10f\"/>~n",
            [DiffuseReflect,GlossyReflect,Exponent]),
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
                  case export_modulator(F, [Name,$_,format(N)],
                                        Maps, M, Opacity) of
                      off -> N+1;
                      ok ->
                          println(F),
                          N+1
                  end;
              (_, N) ->
                  N % Ignore old modulators
          end, 1, Modulators),
    println(F, "</material>").




%%% Export Coated Glossy Material
%%%


export_coatedglossy_shader(F, Name, Mat, ExportDir, YafaRay) ->
    OpenGL = proplists:get_value(opengl, Mat),
    Maps = proplists:get_value(maps, Mat, []),
    Modulators = proplists:get_value(modulators, YafaRay, def_modulators(Maps)),
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
                  case export_texture(F, [Name,$_,format(N)],
                                      Maps, ExportDir, M) of
                      off -> N+1;
                      ok ->
                          println(F),
                          N+1
                  end;
              (_, N) ->
                  N % Ignore old modulators
          end, 1, Modulators),
    println(F, "<material name=\"~s\">~n"++
            "<type sval=\"coated_glossy\"/>", [Name]),
    DiffuseA = {_,_,_,Opacity} = proplists:get_value(diffuse, OpenGL),

    Specular = alpha(proplists:get_value(specular, OpenGL)),
    DefReflected = Specular,
    DefTransmitted = def_transmitted(DiffuseA),

    %% XXX Wings scaling of shininess is weird. Commonly this value
    %% is the cosine power and as such in the range 0..infinity.
    %% OpenGL limits this to 0..128 which mostly is sufficient.
    println(F, "       <hard fval=\"~.10f\"/>",
                   [proplists:get_value(shininess, OpenGL)*128.0]),
    export_rgb(F, color,
               proplists:get_value(reflected, YafaRay, DefReflected)),
    export_rgb(F, diffuse_color,
               proplists:get_value(transmitted, YafaRay, DefTransmitted)),

    IOR = proplists:get_value(ior, YafaRay, ?DEF_IOR),

    DiffuseReflect = proplists:get_value(diffuse_reflect, YafaRay, ?DEF_DIFFUSE_REFLECT),

    GlossyReflect = proplists:get_value(glossy_reflect, YafaRay, ?DEF_GLOSSY_REFLECT),

    Exponent = proplists:get_value(exponent, YafaRay, ?DEF_EXPONENT),

    Anisotropic = proplists:get_value(anisotropic, YafaRay, ?DEF_ANISOTROPIC),

    Anisotropic_U = proplists:get_value(anisotropic_u, YafaRay, ?DEF_ANISOTROPIC_U),

    Anisotropic_V = proplists:get_value(anisotropic_v, YafaRay, ?DEF_ANISOTROPIC_V),

    OrenNayar = proplists:get_value(oren_nayar, YafaRay, ?DEF_OREN_NAYAR),

    DefAbsorptionColor = def_absorption_color(proplists:get_value(diffuse, OpenGL)),

    AbsorptionColor =
        proplists:get_value(absorption_color, YafaRay, DefAbsorptionColor),


    case AbsorptionColor of
        [ ] -> ok;
        {AbsR,AbsG,AbsB} ->
            AbsD =
                proplists:get_value(absorption_dist, YafaRay,
                                    ?DEF_ABSORPTION_DIST),
            export_rgb(F, absorption, {-math:log(max(AbsR, ?NONZERO))/AbsD,
                                       -math:log(max(AbsG, ?NONZERO))/AbsD,
                                       -math:log(max(AbsB, ?NONZERO))/AbsD})
    end,
    DispersionPower =
        proplists:get_value(dispersion_power, YafaRay, ?DEF_DISPERSION_POWER),
    case DispersionPower of
        0.0 -> ok;
        _   ->
            DispersionSamples =
                proplists:get_value(dispersion_samples, YafaRay,
                                    ?DEF_DISPERSION_SAMPLES),
            DispersionJitter =
                proplists:get_value(dispersion_jitter, YafaRay,
                            ?DEF_DISPERSION_JITTER),
            println(F, "       "
                    "        <dispersion_samples ival=\"~w\"/>~n"
                    "        <dispersion_jitter bval=\"~s\"/>",
                    [DispersionSamples,
                     format(DispersionJitter)])
    end,

    case OrenNayar of
        false -> ok;
        _ ->
           OrenNayarSigma = proplists:get_value(oren_nayar_sigma, YafaRay,
                                        ?DEF_OREN_NAYAR_SIGMA),

            println(F, "        <diffuse_brdf sval=\"oren_nayar\"/>~n"
                    "        <sigma fval=\"~.10f\"/>",
                    [OrenNayarSigma])
    end,



    println(F, "        <IOR fval=\"~.10f\"/>~n"
            "        <diffuse_reflect fval=\"~.10f\"/>~n"
            "        <glossy_reflect fval=\"~.10f\"/>~n"
            "        <anisotropic bval=\"~s\"/>~n"
            "        <exp_u fval=\"~.10f\"/>~n"
            "        <exp_v fval=\"~.10f\"/>~n"
            "        <exponent fval=\"~.10f\"/>~n",
            [IOR,DiffuseReflect,GlossyReflect,Anisotropic,Anisotropic_U,Anisotropic_V,Exponent]),
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
                  case export_modulator(F, [Name,$_,format(N)],
                                        Maps, M, Opacity) of
                      off -> N+1;
                      ok ->
                          println(F),
                          N+1
                  end;
              (_, N) ->
                  N % Ignore old modulators
          end, 1, Modulators),
    println(F, "</material>").



%%% Export Translucent (SSS) Material
%%%


export_translucent_shader(F, Name, Mat, ExportDir, YafaRay) ->
    OpenGL = proplists:get_value(opengl, Mat),
    Maps = proplists:get_value(maps, Mat, []),
    Modulators = proplists:get_value(modulators, YafaRay, def_modulators(Maps)),
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
                  case export_texture(F, [Name,$_,format(N)],
                                      Maps, ExportDir, M) of
                      off -> N+1;
                      ok ->
                          println(F),
                          N+1
                  end;
              (_, N) ->
                  N % Ignore old modulators
          end, 1, Modulators),
    println(F, "<material name=\"~s\">~n"++
            "<type sval=\"translucent\"/>", [Name]),
    DiffuseA = {_,_,_,Opacity} = proplists:get_value(diffuse, OpenGL),

    Specular = alpha(proplists:get_value(specular, OpenGL)),
    DefReflected = Specular,
    DefTransmitted = def_transmitted(DiffuseA),


    SSS_AbsorptionColor =
        proplists:get_value(sss_absorption_color, YafaRay, ?DEF_SSS_ABSORPTION_COLOR),



   ScatterColor =
        proplists:get_value(scatter_color, YafaRay, ?DEF_SCATTER_COLOR),

    SSS_Specular_Color =
        proplists:get_value(sss_specular_color, YafaRay, ?DEF_SSS_SPECULAR_COLOR),

    %% XXX Wings scaling of shininess is weird. Commonly this value
    %% is the cosine power and as such in the range 0..infinity.
    %% OpenGL limits this to 0..128 which mostly is sufficient.
    println(F, "       <hard ival=\"~.10f\"/>",
                   [proplists:get_value(shininess, OpenGL)*128.0]),
    export_rgb(F, glossy_color,
               proplists:get_value(reflected, YafaRay, DefReflected)),
    export_rgb(F, color,
               proplists:get_value(transmitted, YafaRay, DefTransmitted)),

    export_rgb(F, specular_color,
               proplists:get_value(sss_specular_color, YafaRay, SSS_Specular_Color)),



    case SSS_AbsorptionColor of
        [ ] -> ok;
        {AbsR,AbsG,AbsB} ->
            AbsD =
                proplists:get_value(absorption_dist, YafaRay,
                                    ?DEF_ABSORPTION_DIST),
            export_rgb(F, sigmaA, {-math:log(max(AbsR, ?NONZERO))/AbsD,
                                   -math:log(max(AbsG, ?NONZERO))/AbsD,
                                   -math:log(max(AbsB, ?NONZERO))/AbsD})
    end,

    export_rgb(F, sigmaS,
               proplists:get_value(scatter_color, YafaRay, ScatterColor)),

    IOR = proplists:get_value(ior, YafaRay, ?DEF_IOR),




    SigmaSfactor = proplists:get_value(sigmas_factor, YafaRay, ?DEF_SIGMAS_FACTOR),

    DiffuseReflect = proplists:get_value(diffuse_reflect, YafaRay, ?DEF_DIFFUSE_REFLECT),

    GlossyReflect = proplists:get_value(glossy_reflect, YafaRay, ?DEF_GLOSSY_REFLECT),

    SSS_Translucency = proplists:get_value(sss_translucency, YafaRay, ?DEF_SSS_TRANSLUCENCY),

    Exponent = proplists:get_value(exponent, YafaRay, ?DEF_EXPONENT),

    DispersionPower =
        proplists:get_value(dispersion_power, YafaRay, ?DEF_DISPERSION_POWER),
    case DispersionPower of
        0.0 -> ok;
        _   ->
            DispersionSamples =
                proplists:get_value(dispersion_samples, YafaRay,
                                    ?DEF_DISPERSION_SAMPLES),
            DispersionJitter =
                proplists:get_value(dispersion_jitter, YafaRay,
                            ?DEF_DISPERSION_JITTER),
            println(F, "       "
                    "        <dispersion_samples ival=\"~w\"/>~n"
                    "        <dispersion_jitter bval=\"~s\"/>",
                    [DispersionSamples,
                     format(DispersionJitter)])


    end,
    println(F, "        <IOR fval=\"~.10f\"/>~n"
            "        <sigmaS_factor fval=\"~.10f\"/>~n"
            "        <diffuse_reflect fval=\"~.10f\"/>~n"
            "        <glossy_reflect fval=\"~.10f\"/>~n"
            "        <sss_transmit fval=\"~.10f\"/>~n"
            "        <exponent fval=\"~.10f\"/>~n",
            [IOR,SigmaSfactor,DiffuseReflect,GlossyReflect,SSS_Translucency,Exponent]),
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
                  case export_modulator(F, [Name,$_,format(N)],
                                        Maps, M, Opacity) of
                      off -> N+1;
                      ok ->
                          println(F),
                          N+1
                  end;
              (_, N) ->
                  N % Ignore old modulators
          end, 1, Modulators),
    println(F, "</material>").



%%% Export Glass Material
%%%

export_glass_shader(F, Name, Mat, ExportDir, YafaRay) ->
    OpenGL = proplists:get_value(opengl, Mat),
    Maps = proplists:get_value(maps, Mat, []),
    Modulators = proplists:get_value(modulators, YafaRay, def_modulators(Maps)),
    %%
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
        case export_texture(F, [Name,$_,format(N)],
                            Maps, ExportDir, M) of
            off -> N+1;
            ok ->
                println(F),
                N+1
        end;
        (_, N) ->
            N % Ignore old modulators
    end, 1, Modulators),
    println(F,
        "<material name=\"~s\">~n"
        "       <type sval=\"glass\"/>",
        [Name]),

    DiffuseA = {_,_,_,Opacity} = proplists:get_value(diffuse, OpenGL),

    Specular = alpha(proplists:get_value(specular, OpenGL)),

    DefReflected = Specular,

    DefTransmitted = def_transmitted(DiffuseA),

    %% XXX Wings scaling of shininess is weird. Commonly this value
    %% is the cosine power and as such in the range 0..infinity.
    %% OpenGL limits this to 0..128 which mostly is sufficient.
    println(F, "       <hard fval=\"~.10f\"/>",
                   [proplists:get_value(shininess, OpenGL)*128.0]),
    export_rgb(F, mirror_color,
               proplists:get_value(reflected, YafaRay, DefReflected)),
    export_rgb(F, filter_color,
               proplists:get_value(transmitted, YafaRay, DefTransmitted)),

    IOR = proplists:get_value(ior, YafaRay, ?DEF_IOR),

    Glass_IR_Depth = proplists:get_value(glass_ir_depth, YafaRay, ?DEF_GLASS_IR_DEPTH),

    TransmitFilter = proplists:get_value(transmit_filter, YafaRay, ?DEF_TRANSMIT_FILTER),

    DefAbsorptionColor = def_absorption_color(proplists:get_value(diffuse, OpenGL)),

    AbsorptionColor = proplists:get_value(absorption_color, YafaRay, DefAbsorptionColor),

    case AbsorptionColor of
        [ ] -> ok;
        {_AbsR,_AbsG,_AbsB} ->
            AbsD =
                proplists:get_value(absorption_dist, YafaRay, ?DEF_ABSORPTION_DIST),
        %%
        export_rgb(F, absorption,
               proplists:get_value(absorption_color, YafaRay, AbsorptionColor)),

            println(F,
                "       <absorption_dist fval=\"~.10f\"/>~n"
                "       <transmit_filter fval=\"~.10f\"/>~n",
                [AbsD,TransmitFilter])
    end,
    DispersionPower =
        proplists:get_value(dispersion_power, YafaRay, ?DEF_DISPERSION_POWER),
    %%
    case DispersionPower of
        0.0 -> ok;
        _   ->
            DispersionSamples =
                proplists:get_value(dispersion_samples, YafaRay, ?DEF_DISPERSION_SAMPLES),

            println(F,
                "       <dispersion_power fval=\"~.10f\"/>~n"
                "       <dispersion_samples ival=\"~w\"/>~n",
                [DispersionPower,DispersionSamples])
    end,

    FakeShadows =
        proplists:get_value(fake_shadows, YafaRay, ?DEF_FAKE_SHADOWS),

    println(F,
        "       <IOR fval=\"~.10f\"/>~n"
        "       <glass_internal_reflect_depth ival=\"~w\"/>~n"
        "       <fake_shadows bval=\"~s\"/>~n"
        "",
        [IOR,Glass_IR_Depth,format(FakeShadows)]),

    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
                case export_modulator(F, [Name,$_,format(N)],Maps, M, Opacity) of

                    off -> N+1;
                    ok ->
                        println(F),
                        N+1
                end;
            (_, N) ->
                N % Ignore old modulators
        end, 1, Modulators),
    println(F, "</material>").


%%% Export Rough Glass Material
%%%

export_rough_glass_shader(F, Name, Mat, ExportDir, YafaRay) ->
    OpenGL = proplists:get_value(opengl, Mat),
    Maps = proplists:get_value(maps, Mat, []),
    Modulators = proplists:get_value(modulators, YafaRay, def_modulators(Maps)),
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
                  case export_texture(F, [Name,$_,format(N)],
                                      Maps, ExportDir, M) of
                      off -> N+1;
                      ok ->
                          println(F),
                          N+1
                  end;
              (_, N) ->
                  N % Ignore old modulators
          end, 1, Modulators),
    println(F, "<material name=\"~s\">~n"++
            "<type sval=\"rough_glass\"/>", [Name]),
    DiffuseA = {_,_,_,Opacity} = proplists:get_value(diffuse, OpenGL),

    Specular = alpha(proplists:get_value(specular, OpenGL)),
    DefReflected = Specular,
    DefTransmitted = def_transmitted(DiffuseA),

    %% XXX Wings scaling of shininess is weird. Commonly this value
    %% is the cosine power and as such in the range 0..infinity.
    %% OpenGL limits this to 0..128 which mostly is sufficient.
    println(F, "       <hard fval=\"~.10f\"/>",
                   [proplists:get_value(shininess, OpenGL)*128.0]),
    export_rgb(F, mirror_color,
               proplists:get_value(reflected, YafaRay, DefReflected)),
    export_rgb(F, filter_color,
               proplists:get_value(transmitted, YafaRay, DefTransmitted)),

    IOR = proplists:get_value(ior, YafaRay, ?DEF_IOR),

    TransmitFilter = proplists:get_value(transmit_filter, YafaRay, ?DEF_TRANSMIT_FILTER),

    Roughness = proplists:get_value(roughness, YafaRay, ?DEF_ROUGHNESS),

    DefAbsorptionColor = def_absorption_color(proplists:get_value(diffuse, OpenGL)),

    AbsorptionColor =
        proplists:get_value(absorption_color, YafaRay, DefAbsorptionColor),


  case AbsorptionColor of
    [ ] -> ok;
    {_AbsR,_AbsG,_AbsB} ->
        AbsD =
                proplists:get_value(absorption_dist, YafaRay,
                                    ?DEF_ABSORPTION_DIST),
            export_rgb(F, absorption,
                       proplists:get_value(absorption_color, YafaRay, AbsorptionColor)),

            println(F, "<absorption_dist fval=\"~.10f\"/>~n"
            "        <transmit_filter fval=\"~.10f\"/>~n"
            "        <roughness fval=\"~.10f\"/>~n",[AbsD,TransmitFilter,Roughness])
    end,
    DispersionPower =
        proplists:get_value(dispersion_power, YafaRay, ?DEF_DISPERSION_POWER),
    case DispersionPower of
        0.0 -> ok;
        _   ->
            DispersionSamples =
                proplists:get_value(dispersion_samples, YafaRay,
                                    ?DEF_DISPERSION_SAMPLES),

            println(F, "        <dispersion_power fval=\"~.10f\"/>~n"
                    "        <dispersion_samples ival=\"~w\"/>~n",

                    [DispersionPower,DispersionSamples
                    ])
    end,

     FakeShadows =
        proplists:get_value(fake_shadows, YafaRay, ?DEF_FAKE_SHADOWS),

    println(F, "        <IOR fval=\"~.10f\"/>~n"
                "       <fake_shadows bval=\"~s\"/>~n"

            "",
            [IOR,format(FakeShadows)]),
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
                  case export_modulator(F, [Name,$_,format(N)],
                                        Maps, M, Opacity) of
                      off -> N+1;
                      ok ->
                          println(F),
                          N+1
                  end;
              (_, N) ->
                  N % Ignore old modulators
          end, 1, Modulators),
    println(F, "</material>").



%%% Export Light Material
%%%

export_lightmat_shader(F, Name, Mat, ExportDir, YafaRay) ->
    OpenGL = proplists:get_value(opengl, Mat),
    Maps = proplists:get_value(maps, Mat, []),
    Modulators = proplists:get_value(modulators, YafaRay, def_modulators(Maps)),
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
                  case export_texture(F, [Name,$_,format(N)],
                                      Maps, ExportDir, M) of
                      off -> N+1;
                      ok ->
                          println(F),
                          N+1
                  end;
              (_, N) ->
                  N % Ignore old modulators
          end, 1, Modulators),
    println(F, "<material name=\"~s\">~n"++
            "<type sval=\"light_mat\"/>", [Name]),
    _DiffuseA = {_,_,_,Opacity} = proplists:get_value(diffuse, OpenGL),

    DefLightmatColor = def_lightmat_color(proplists:get_value(diffuse, OpenGL)),

    Lightmat_Color =
        proplists:get_value(lightmat_color, YafaRay, DefLightmatColor),




    %% XXX Wings scaling of shininess is weird. Commonly this value
    %% is the cosine power and as such in the range 0..infinity.
    %% OpenGL limits this to 0..128 which mostly is sufficient.

    export_rgb(F, color,
               proplists:get_value(lightmat_color, YafaRay, Lightmat_Color)),


    Lightmat_Power = proplists:get_value(lightmat_power, YafaRay, ?DEF_LIGHTMAT_POWER),



    println(F, "  <power fval=\"~.10f\"/>~n",
            [Lightmat_Power]),
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
                  case export_modulator(F, [Name,$_,format(N)],
                                        Maps, M, Opacity) of
                      off -> N+1;
                      ok ->
                          println(F),
                          N+1
                  end;
              (_, N) ->
                  N % Ignore old modulators
          end, 1, Modulators),
    println(F, "</material>").






%%% End of Basic Materials Export
%%%
%%% Start Blend Materials Export

export_shaderblend(F, Name, Mat, ExportDir) ->
    YafaRay = proplists:get_value(?TAG, Mat, []),

     DefShaderType = get_pref(shader_type, YafaRay),
     ShaderType =
        proplists:get_value(shader_type, YafaRay, DefShaderType),

    case ShaderType of

      blend_mat ->
            export_blend_mat_shader(F, Name, Mat, ExportDir, YafaRay);

        shinydiffuse ->
            ok;
        glossy ->
            ok;
        coatedglossy ->
            ok;

        translucent ->
            ok;

       glass ->
            ok;

       lightmat ->
            ok;

       rough_glass ->
           ok

            end.

%%% Export Blend Material


export_blend_mat_shader(F, Name, Mat, ExportDir, YafaRay) ->
    OpenGL = proplists:get_value(opengl, Mat),
    Maps = proplists:get_value(maps, Mat, []),
    Modulators = proplists:get_value(modulators, YafaRay, def_modulators(Maps)),
    %%
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
        case export_texture(F, [Name,$_,format(N)], Maps, ExportDir, M) of
            off -> N+1;
            ok ->
                println(F),
                N+1
        end;
        (_, N) ->
            N % Ignore old modulators
        end, 1, Modulators),

    println(F, "<material name=\"~s\">~n"++
            "<type sval=\"blend_mat\"/>", [Name]),
    DiffuseA = {_,_,_,Opacity} = proplists:get_value(diffuse, OpenGL),

    Specular = alpha(proplists:get_value(specular, OpenGL)),
    DefReflected = Specular,
    DefTransmitted = def_transmitted(DiffuseA),

    %% XXX Wings scaling of shininess is weird. Commonly this value
    %% is the cosine power and as such in the range 0..infinity.
    %% OpenGL limits this to 0..128 which mostly is sufficient.
    println(F, "       <hard fval=\"~.10f\"/>",
                   [proplists:get_value(shininess, OpenGL)*128.0]),
    export_rgb(F, color,
               proplists:get_value(reflected, YafaRay, DefReflected)),
    export_rgb(F, diffuse_color,
               proplists:get_value(transmitted, YafaRay, DefTransmitted)),




    Blend_Mat1 = proplists:get_value(blend_mat1, YafaRay, ?DEF_BLEND_MAT1),

    Blend_Mat2 = proplists:get_value(blend_mat2, YafaRay, ?DEF_BLEND_MAT2),

    Blend_Value = proplists:get_value(blend_value, YafaRay, ?DEF_BLEND_VALUE),

    println(F, "  <material1 sval=\"""w_""\~s\"/>~n"
            "        <material2 sval=\"""w_""\~s\"/>~n"
            "        <blend_value fval=\"~.10f\"/>~n",
            [Blend_Mat1,Blend_Mat2,Blend_Value]),
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
        case export_modulator(F, [Name,$_,format(N)], Maps, M, Opacity) of
            off -> N+1;
            ok ->
                println(F),
                N+1
        end;
        (_, N) ->
            N % Ignore old modulators
    end, 1, Modulators),
    println(F, "</material>").

%%% End Blend Materials Export


%%% Start Texture Export
%%%

export_texture(F, Name, Maps, ExportDir, {modulator,Ps}) when is_list(Ps) ->
    case mod_enabled_mode_type(Ps, Maps) of
        {false,_,_} ->
            off;
        {true,_,image} ->
            Filename = proplists:get_value(filename, Ps, ?DEF_MOD_FILENAME),
            export_texture(F, Name, image, Filename);
        {true,_,jpeg} -> %% Old tag
            Filename = proplists:get_value(filename, Ps, ?DEF_MOD_FILENAME),
            export_texture(F, Name, image, Filename);
        {true,_,{map,Map}} ->
            case proplists:get_value(Map, Maps, undefined) of
                undefined ->
                    exit({unknown_texture_map,{?MODULE,?LINE,[Name,Map]}});
                #e3d_image{name=ImageName}=Image ->
                    MapFile = ImageName++".tga",
                    ok = e3d_image:save(Image,
                                        filename:join(ExportDir, MapFile)),
                    export_texture(F, Name, image, MapFile)
            end;
        {true,_,Type} ->
            export_texture(F, Name, Type, Ps)
    end.


export_texture(F, Name, image, Filename) ->
    println(F,
        "<texture name=\"~s\">~n"
        "       <filename sval=\"~s\"/>~n"
        "       <type sval=\"image\"/>~n"
        "</texture>", [Name,Filename]);

export_texture(F, Name, Type, Ps) ->

    %%% Start Work-Around for YafaRay Texture Name TEmytex Requirement for Noise Volume

    TextureNameChg = re:replace(Name,"w_TEmytex_1","TEmytex",[global]),
    println(F,
        "<texture name=\"~s\">~n"
        "       <type sval=\"~s\"/>",
        [TextureNameChg,format(Type)]),

    %%% End Work-Around for YafaRay Texture Name TEmytex Requirement for Noise Volume

    Color1 = proplists:get_value(color1, Ps, ?DEF_MOD_COLOR1),

    Color2 = proplists:get_value(color2, Ps, ?DEF_MOD_COLOR2),

    Hard = proplists:get_value(hard, Ps, ?DEF_MOD_HARD),

    NoiseBasis = proplists:get_value(noise_basis, Ps, ?DEF_MOD_NOISEBASIS),

    NoiseSize = proplists:get_value(noise_size, Ps, ?DEF_MOD_NOISESIZE),

    export_rgb(F, color1, Color1),
    export_rgb(F, color2, Color2),
    println(F,
        "       <hard bval=\"~s\"/>~n"
        "       <noise_type sval=\"~s\"/>~n"
        "       <size fval=\"~.6f\"/>",
        [format(Hard),NoiseBasis,NoiseSize]),

    case Type of

        clouds ->
            Depth = proplists:get_value(depth, Ps, ?DEF_MOD_DEPTH),
            println(F,
                "       <depth ival=\"~w\"/>",
                [Depth]);

        marble ->
            Depth = proplists:get_value(depth, Ps, ?DEF_MOD_DEPTH),

            Turbulence = proplists:get_value(turbulence, Ps, ?DEF_MOD_TURBULENCE),

            Sharpness = proplists:get_value(sharpness, Ps, ?DEF_MOD_SHARPNESS),

            Shape = proplists:get_value(shape, Ps, ?DEF_MOD_SHAPE),

            println(F,
                "       <depth ival=\"~w\"/>~n"
                "       <turbulence fval=\"~.6f\"/>~n"
                "       <sharpness fval=\"~.6f\"/>~n"
                "       <shape sval=\"~s\"/>",
                [Depth,Turbulence,Sharpness,Shape]);
        wood ->
            WoodType = proplists:get_value(wood_type, Ps, ?DEF_MOD_WOODTYPE),

            Turbulence = proplists:get_value(turbulence, Ps, ?DEF_MOD_TURBULENCE),

            Shape = proplists:get_value(shape, Ps, ?DEF_MOD_SHAPE),

            %% Coordinate rotation, see export_pos/3.
            println(F,
                "       <wood_type sval=\"~s\"/>~n"
                "       <turbulence fval=\"~.6f\"/>~n"
                "       <shape sval=\"~s\"/>",
                [WoodType,Turbulence,Shape]);

        voronoi ->
            CellType = proplists:get_value(cell_type, Ps, ?DEF_MOD_CELLTYPE),

            CellShape = proplists:get_value(cell_shape, Ps, ?DEF_MOD_CELLSHAPE),

            CellSize = proplists:get_value(cell_size, Ps, ?DEF_MOD_CELLSIZE),

            Intensity = proplists:get_value(intensity, Ps, ?DEF_MOD_INTENSITY),

            CellWeight1 = proplists:get_value(cell_weight1, Ps, ?DEF_MOD_CELL_WEIGHT1),

            CellWeight2 = proplists:get_value(cell_weight2, Ps, ?DEF_MOD_CELL_WEIGHT2),

            CellWeight3 = proplists:get_value(cell_weight3, Ps, ?DEF_MOD_CELL_WEIGHT3),

            CellWeight4 = proplists:get_value(cell_weight4, Ps, ?DEF_MOD_CELL_WEIGHT4),

            %% Coordinate rotation, see export_pos/3.
            println(F,
                "       <color_type sval=\"~s\"/>~n"
                "       <distance_metric sval=\"~s\"/>~n"
                "       <size fval=\"~.6f\"/>~n"
                "       <intensity fval=\"~.6f\"/>~n"
                "       <weight1 fval=\"~.6f\"/>~n"
                "       <weight2 fval=\"~.6f\"/>~n"
                "       <weight3 fval=\"~.6f\"/>~n"
                "       <weight4 fval=\"~.6f\"/>",
                [CellType,CellShape,CellSize,Intensity,CellWeight1,CellWeight2,CellWeight3,CellWeight4]);

        musgrave ->
            MusgraveType = proplists:get_value(musgrave_type, Ps, ?DEF_MOD_MUSGRAVE_TYPE),

            NoiseBasis = proplists:get_value(noise_basis, Ps, ?DEF_MOD_NOISEBASIS),

            MusgraveNoiseSize = proplists:get_value(musgrave_noisesize, Ps, ?DEF_MOD_MUSGRAVE_NOISESIZE),

            MusgraveIntensity = proplists:get_value(musgrave_intensity, Ps, ?DEF_MOD_MUSGRAVE_INTENSITY),

            MusgraveContrast = proplists:get_value(musgrave_contrast, Ps, ?DEF_MOD_MUSGRAVE_CONTRAST),

            MusgraveLacunarity = proplists:get_value(musgrave_lacunarity, Ps, ?DEF_MOD_MUSGRAVE_LACUNARITY),

            MusgraveOctaves = proplists:get_value(musgrave_octaves, Ps, ?DEF_MOD_MUSGRAVE_OCTAVES),

            %% Coordinate rotation, see export_pos/3.
            println(F,
                "       <musgrave_type sval=\"~s\"/>~n"
                "       <noise_type sval=\"~s\"/>~n"
                "       <size fval=\"~.6f\"/>~n"
                "       <intensity fval=\"~.6f\"/>~n"
                "       <H fval=\"~.6f\"/>~n"
                "       <lacunarity fval=\"~.6f\"/>~n"
                "       <octaves fval=\"~.6f\"/>",
                [MusgraveType, NoiseBasis, MusgraveNoiseSize, MusgraveIntensity,
                    MusgraveContrast,MusgraveLacunarity,MusgraveOctaves]);

        distorted_noise ->

            NoiseBasis = proplists:get_value(noise_basis, Ps, ?DEF_MOD_NOISEBASIS),

            DistortionType = proplists:get_value(distortion_type, Ps, ?DEF_MOD_DISTORTION_TYPE),

            DistortionNoiseSize = proplists:get_value(distortion_noisesize, Ps, ?DEF_MOD_DISTORTION_NOISESIZE),

            DistortionIntensity = proplists:get_value(distortion_intensity, Ps, ?DEF_MOD_DISTORTION_INTENSITY),


            %% Coordinate rotation, see export_pos/3.
            println(F,
                "       <noise_type1 sval=\"~s\"/>~n"
                "       <noise_type2 sval=\"~s\"/>~n"
                "       <size fval=\"~.6f\"/>~n"
                "       <distort fval=\"~.6f\"/>~n",
                [NoiseBasis, DistortionType, DistortionNoiseSize, DistortionIntensity]);
        _ ->
            ok
    end,
    println(F, "</texture>").



export_modulator(F, Texname, Maps, {modulator,Ps}, Opacity) when is_list(Ps) ->
    case mod_enabled_mode_type(Ps, Maps) of
        {false,_,_} ->
            off;
        {true,Mode,Type} ->
            AlphaIntensity = proplists:get_value(alpha_intensity, Ps, ?DEF_MOD_ALPHA_INTENSITY),

%%% Start Change Number from Texname for UpperLayer

            UpperLayerName =
                case AlphaIntensity of
                        stencil -> re:replace(Texname,"_2","_1",[global]);
                        _-> re:replace(Texname,"_1","_2",[global])
                end,

%%% End Change Number from Texname for UpperLayer

%%% Start Change Number from Texname for Stencil Input

            StencilInputName =
                case AlphaIntensity of
                        stencil -> re:replace(Texname,"_2","_3",[global]);
                        _-> ""
                end,

%%% End Change Number from Texname for Stencil Input

%%% Start Change Number from Texname for Stencil UpperLayer Name 2

            StencilUpperLayerName2 =
                case AlphaIntensity of
                        stencil -> re:replace(Texname,"_1","_2",[global]);
                        _-> ""
                end,

%%% End Change Number from Texname for Stencil UpperLayer Name 2


            _SizeX = proplists:get_value(size_x, Ps, ?DEF_MOD_SIZE_X),
            _SizeY = proplists:get_value(size_y, Ps, ?DEF_MOD_SIZE_Y),
            _SizeZ = proplists:get_value(size_z, Ps, ?DEF_MOD_SIZE_Z),
            Diffuse = proplists:get_value(diffuse, Ps, ?DEF_MOD_DIFFUSE),
            _Specular = proplists:get_value(specular, Ps, ?DEF_MOD_SPECULAR),
            Ambient = proplists:get_value(ambient, Ps, ?DEF_MOD_AMBIENT),
            Shininess = proplists:get_value(shininess, Ps, ?DEF_MOD_SHININESS),
            Normal = proplists:get_value(normal, Ps, ?DEF_MOD_NORMAL),
            _Color = Diffuse * Opacity,
            _HardValue = Shininess,
            _Transmission = Diffuse * (1.0 - Opacity),
            _Reflection = Ambient,
            TexCo =
                case Type of
                    image -> "<texco sval=\"uv\"/>";
                    jpeg -> "<texco sval=\"uv\"/>";
                    {map,_} -> "<texco sval=\"uv\"/>";
                    marble -> "<texco sval=\"global\"/>";
                    wood -> "<texco sval=\"global\"/>";
                    clouds -> "<texco sval=\"global\"/>";
                    _ -> ""
                end,

            ModeNumber =
                case Mode of
                    mix -> "0";
                    add -> "1";
                    mul -> "2";
                    sub -> "3";
                    scr -> "4";
                    divide -> "5";
                    dif -> "6";
                    dar -> "7";
                    lig -> "8";
                    _ -> ""
                end,

%% Start Identify Modulator # (w_default_Name_1 or w_default_Name_2)
            Split=re:split(Texname,"_",[{return, list}]),
            Num=lists:last(Split),
            UpperLayer =
                case {Num,Mode,AlphaIntensity} of
                        {"1",mix,_} ->  "";
                        {"1",_,_} ->  "<upper_layer sval=\""++UpperLayerName++"\"/>";
                        {"2",_,stencil} ->  "<upper_layer sval=\""++UpperLayerName++"\"/>";
                        _ -> ""
                end,
%% End Identify Modulator #

            UpperColor =
                case Num of
                        "1" ->  "<upper_color r=\"1\" g=\"1\" b=\"1\" a=\"1\"/>";
                        _ -> ""
                end,

            UseAlpha =
                 case {Num,AlphaIntensity} of
                        {"1",off} ->  "";
                        {_,transparency} -> "<do_scalar bval=\"true\"/>";
                        {_,diffusealphatransparency} -> "<use_alpha bval=\"true\"/>";
                        {_,translucency} -> "<do_scalar bval=\"true\"/>";
                        {_,specularity} -> "<do_scalar bval=\"true\"/>";
                        {_,stencil} -> "<use_alpha bval=\"true\"/>";
                        _ -> ""
                 end,


            ShaderType =
                case {Normal,AlphaIntensity} of
                    {0.0,off} -> "<diffuse_shader";
                    {0.0,transparency} -> "<transparency_shader";
                    {0.0,diffusealphatransparency} -> "<diffuse_shader";
                    {0.0,translucency} -> "<translucency_shader";
                    {0.0,specularity} -> "<glossy_reflect_shader";
                    {0.0,stencil} -> "<diffuse_shader";
                    _ -> "<bump_shader"
                end,

            ShaderName =
                case {Num,Mode} of
                        {"1",_} ->   "  "++ShaderType++" sval=\""++Texname++"\"/>";
                        {_,mix} ->   "  "++ShaderType++" sval=\""++Texname++"\"/>";
                        _ -> ""
                end,


                case AlphaIntensity of
                        stencil ->
%%Stencil Export Start
                    println(F,
                        " <!--Start Stencil Section Here-->

                        <list_element>
                        <element sval=\"shader_node\"/>
                        <name sval=\"~s\"/>
                        <input sval=\"~s_mod\"/>

                        <noRGB bval=\"true\"/>
                        <stencil bval=\"true\"/>
                        "++UpperLayer++"

                        <type sval=\"layer\"/>
                        <mode ival=\""++ModeNumber++"\"/>
                        </list_element>

                        <list_element>
                        <element sval=\"shader_node\"/>
                        <name sval=\"~s_mod\"/>
                        "++TexCo++"
                        <mapping sval=\"plain\"/>
                        <texture sval=\"~s\"/>
                        <type sval=\"texture_mapper\"/>
                        <bump_strength fval=\"~.3f\"/>
                        </list_element>

                        <diffuse_shader sval=\"diff_layer2\"/>
                        <list_element>
                        <element sval=\"shader_node\"/>
                        <name sval=\"diff_layer2\"/>
                        <input sval=\""++StencilInputName++"_mod\"/>
                        <upper_layer sval=\""++StencilUpperLayerName2++"\"/>
                        <type sval=\"layer\"/>
                        <mode ival=\""++ModeNumber++"\"/>
                        </list_element>

        <!--End Stencil Section Here-->",
                    [Texname,Texname,Texname,Texname,Normal]);
%%Stencil Export End
                        _ ->

                 println(F,
                    "  "++ShaderName++"
                    <list_element>
                    <element sval=\"shader_node\"/>
                    <name sval=\"~s\"/>
                    <input sval=\"~s_mod\"/>
                    "++UpperLayer++"
                    "++UpperColor++"
                    "++UseAlpha++"
                    <type sval=\"layer\"/>
                    <mode ival=\""++ModeNumber++"\"/>
                    </list_element>
                    <list_element>
                    <element sval=\"shader_node\"/>
                    <name sval=\"~s_mod\"/>
                    "++TexCo++"
                    <mapping sval=\"plain\"/>
                    <texture sval=\"~s\"/>
                    <type sval=\"texture_mapper\"/>
                    <bump_strength fval=\"~.3f\"/>
                    </list_element>",
                    [Texname,Texname,Texname,Texname,Normal])

                 end

end.



export_rgb(F, Type, {R,G,B,_}) ->
    export_rgb(F, Type, {R,G,B});
export_rgb(F, Type, {R,G,B}) ->
    println(F, ["        <",format(Type)," r=\"",format(R),
                "\" g=\"",format(G),"\" b=\"",format(B),"\"/>"]).




%% Return object with arealight faces only
%%
export_object(F, NameStr, Mesh=#e3d_mesh{fs=Fs}, MatsGb, Id) ->
    %% Find the default material
    MM = sort(foldl(fun (#e3d_face{mat=[M|_]}, Ms) -> [M|Ms] end, [], Fs)),
    [{_Count,DefaultMaterial}|_] = reverse(sort(count_equal(MM))),
    MatPs = gb_trees:get(DefaultMaterial, MatsGb),
    export_object_1(F, NameStr, Mesh, DefaultMaterial, MatPs, Id).

%% Count the number of subsequent equal elements in the list.
%% Returns list of {Count,Element}.
%%
count_equal([H|T]) ->
    count_equal(T, 1, H, []).
%%
count_equal([], C, H, R) ->
    [{C,H}|R];
count_equal([H|T], C, H, R) ->
    count_equal(T, C+1, H, R);
count_equal([H|T], C, K, R) ->
    count_equal(T, 1, H, [{C,K}|R]).



    export_object_1(F, NameStr, Mesh0=#e3d_mesh{he=He0}, DefaultMaterial, MatPs, Id) ->
    YafaRay = proplists:get_value(?TAG, MatPs, []),
    _OpenGL = proplists:get_value(opengl, MatPs),
    UseHardness = proplists:get_value(use_hardness, YafaRay, ?DEF_USE_HARDNESS),
    Object_Type = proplists:get_value(object_type, YafaRay, ?DEF_OBJECT_TYPE),

    Volume_Sigma_a = proplists:get_value(volume_sigma_a, YafaRay, ?DEF_VOLUME_SIGMA_A),
    Volume_Sigma_s = proplists:get_value(volume_sigma_s, YafaRay, ?DEF_VOLUME_SIGMA_S),
    Volume_Height = proplists:get_value(volume_height, YafaRay, ?DEF_VOLUME_HEIGHT),
    Volume_Steepness = proplists:get_value(volume_steepness, YafaRay, ?DEF_VOLUME_STEEPNESS),
    Volume_Attgridscale = proplists:get_value(volume_attgridscale, YafaRay, ?DEF_VOLUME_ATTGRIDSCALE),
    Volume_Sharpness = proplists:get_value(volume_sharpness, YafaRay, ?DEF_VOLUME_SHARPNESS),
    Volume_Cover = proplists:get_value(volume_cover, YafaRay, ?DEF_VOLUME_COVER),
    Volume_Density = proplists:get_value(volume_density, YafaRay, ?DEF_VOLUME_DENSITY),
    Volume_Minmax_X = proplists:get_value(volume_minmax_x, YafaRay, ?DEF_VOLUME_MINMAX_X),
    Volume_Minmax_Y = proplists:get_value(volume_minmax_y, YafaRay, ?DEF_VOLUME_MINMAX_Y),
    Volume_Minmax_Z = proplists:get_value(volume_minmax_z, YafaRay, ?DEF_VOLUME_MINMAX_Z),
    Meshlight_Power = proplists:get_value(meshlight_power, YafaRay, ?DEF_MESHLIGHT_POWER),
    Meshlight_Samples = proplists:get_value(meshlight_samples, YafaRay, ?DEF_MESHLIGHT_SAMPLES),
    Meshlight_Color = proplists:get_value(meshlight_color, YafaRay, ?DEF_MESHLIGHT_COLOR),

    Meshlight_Double_Sided = proplists:get_value(meshlight_double_sided, YafaRay, ?DEF_MESHLIGHT_DOUBLE_SIDED),
    AutosmoothAngle =
        proplists:get_value(autosmooth_angle, YafaRay, ?DEF_AUTOSMOOTH_ANGLE),

    Autosmooth = proplists:get_value(autosmooth, YafaRay,
                                     if AutosmoothAngle == 0.0 -> false;
                                        true -> ?DEF_AUTOSMOOTH end),


    %% Pre-process mesh
    Mesh1 = #e3d_mesh{} =
        case {He0,UseHardness} of
            {[_|_],true} ->
                io:format(?__(1,"Mesh ~s: slitting hard edges..."), [NameStr]),
                M1 = e3d_mesh:slit_hard_edges(Mesh0, [slit_end_vertices]),
                io:format(?__(2,"done")++"~n"),
                M1;
            _ -> Mesh0
        end,


        io:format(?__(3,"Mesh ~s: triangulating..."), [NameStr]),
    #e3d_mesh{fs=Fs,vs=Vs,vc=Vc,tx=Tx} = e3d_mesh:triangulate(Mesh1),
    io:format(?__(4,"done")++"~n"),
    io:format(?__(5,"Mesh ~s: exporting..."), [NameStr]),
    %%

%% Add Export Object Name Start

    println(F, "<!--Object Name ~s, Object # ~w-->", [NameStr,Id]),

%% Add Export Object Name End

         HasUV = case Tx of
                []-> "false";
                _ ->
                "true"

        end,



                case Object_Type of
                mesh ->
                    println(F," "),
                    println(F,
                        "<mesh id=\"~w\" vertices=\"~w\" faces=\"~w\"  has_uv=\"~s\"  type=\"0\">",
                        [Id, length(Vs), length(Fs), HasUV]),
                    println(F," ");

                volume ->
                    println(F," "),
                    println(F, "<volumeregion name=\"volumename\">"),

            case proplists:get_value(volume_type, YafaRay,
                                     ?DEF_VOLUME_TYPE) of
                uniformvolume ->
                    println(F, "<type sval=\"UniformVolume\"/>");


                expdensityvolume ->
                    println(F, "<type sval=\"ExpDensityVolume\"/>"),
                    println(F, "<a fval=\"~.10f\"/>",[Volume_Height]),
                    println(F, "<b fval=\"~.10f\"/>",[Volume_Steepness]);


                noisevolume ->
                    println(F, "<type sval=\"NoiseVolume\"/>"),
                    println(F, "<sharpness fval=\"~.10f\"/>",[Volume_Sharpness]),
                    println(F, "<cover fval=\"~.10f\"/>",[Volume_Cover]),
                    println(F, "<density fval=\"~.10f\"/>",[Volume_Density]),
                    println(F, "<texture sval=\"TEmytex\"/>")

            end,


                    println(F, "<attgridScale ival=\"~w\"/>",[Volume_Attgridscale]),
                    println(F, "<maxX fval=\"~.10f\"/>",[Volume_Minmax_Z]),
                    println(F, "<maxY fval=\"~.10f\"/>",[Volume_Minmax_X]),
                    println(F, "<maxZ fval=\"~.10f\"/>",[Volume_Minmax_Y]),
                    println(F, "<minX fval=\"-\~.10f\"/>",[Volume_Minmax_Z]),
                    println(F, "<minY fval=\"-\~.10f\"/>",[Volume_Minmax_X]),
                    println(F, "<minZ fval=\"-\~.10f\"/>",[Volume_Minmax_Y]),
                    println(F, "<sigma_a fval=\"~.10f\"/>",[Volume_Sigma_a]),
                    println(F, "<sigma_s fval=\"~.10f\"/>",[Volume_Sigma_s]),
                    println(F," ");


                meshlight ->
                    println(F," "),
                    println(F, "<light name=\"~s\">",[NameStr]),

                        export_rgb(F, color,
               proplists:get_value(meshlight_color, YafaRay, Meshlight_Color)),

%%
                    println(F, "<object ival= \"~w\"/>",[Id]),
                    println(F, "<power fval=\"~.10f\"/>",[Meshlight_Power]),
                    println(F, "<samples ival=\"~w\"/>",[Meshlight_Samples]),
                    println(F, "<double_sided bval=\"~s\"/>",[Meshlight_Double_Sided]),
                    println(F, "<type sval=\"~s\"/>",[Object_Type]),
                    println(F, "</light>"),
                    println(F," "),
                    println(F, "<mesh id=\"~w\" type=\"0\">",[Id]),
                    println(F," ")

                    end,

    export_vertices(F, Vs),

%% Add Export UV_Vectors Part 1 Start
        case HasUV of
                "false" -> ok;
                "true" -> println(F, "        "),
                    println(F, "<!--uv_vectors Quantity=\"~w\" -->",[length(Tx)]),
                    println(F, "        "),
                    export_vectors2D(F, Tx)
        end,

%% Add Export UV_Vectors Part 1 End


    export_faces(F, Fs, DefaultMaterial, list_to_tuple(Tx), list_to_tuple(Vc)),


            case Object_Type of
                mesh ->
                    println(F," "),
                    println(F, "</mesh>"),
                    println(F," ");

                volume ->
                    println(F," "),
                    println(F, "</volumeregion>"),
                    println(F," ");

                meshlight ->
                    println(F," "),
                    println(F, "</mesh>"),
                    println(F," ")

                end,


    case Autosmooth of
        false ->
            println(F, "");
        true ->
            println(F, "    <smooth ID=\"~w\" angle=\"~.3f\"/>", [Id,AutosmoothAngle])
    end,

    io:format(?__(6,"done")++"~n").


export_vertices(_F, []) ->
    ok;
export_vertices(F, [Pos|T]) ->
    export_pos(F, p, Pos),
    export_vertices(F, T).



%% The coordinate system is rotated to make sunsky background
%% and environment images work as expected.
%% It assumes `South Y=East Z=Up in YafaRay coordinates.
%% Hence Z=South, X=East, Y=Up in Wings coordinates.
%%
export_pos(F, Type, {X,Y,Z}) ->
    println(F,
        ["\t<",format(Type)," x=\"",format(Z),"\" y=\"",format(X),"\" z=\"",format(Y),"\"/>"]).

%%Add Export UV_Vectors Part 2 Start

export_vectors2D(_F, [])->
        ok;

export_vectors2D(F, [{X, Y} | List])->
        println(F, "<uv u=\"~f\" v=\"~f\"/>", [X, Y]),
        export_vectors2D(F, List).

%%Add Export UV_Vectors Part 2 End

export_faces(_F, [], _DefMat, _TxT, _VColT) ->
    ok;
export_faces(F, [#e3d_face{mat=[Mat|_],tx=Tx,vs=[A,B,C],vc=VCols}|T],

                DefaultMaterial, TxT, VColT) ->

         Shader =
        case Mat of
            DefaultMaterial -> ["  <set_material sval=\"w_",format(Mat),"\"/>"];
                    _ -> ["  <set_material sval=\"w_",format(Mat),"\"/>"]
        end,




         UVIndices = case Tx of
                []-> " uv_a=\"0\" uv_b=\"0\" uv_c=\"0\"/>";
                _ ->
                        {U, V, W} = list_to_tuple(Tx),
(io_lib:format(" uv_a=\"~w\" uv_b=\"~w\" uv_c=\"~w\"/>", [U, V, W]))

        end,


    VCol = case {VColT,VCols} of
               {{},[]} -> "";
               {{},_} ->
                   io:format(?__(3,"WARNING! Face refers to non-existing "
                             "vertex colors")++"~n"),
                   "";
               {_,[]} ->
                   %%io:format("WARNING! Face missing vertex colors~n"),
                   "";
               {_,[VcA,VcB,VcC]} ->
                   {VcAr,VcAg,VcAb} = element(1+VcA, VColT),
                   {VcBr,VcBg,VcBb} = element(1+VcB, VColT),
                   {VcCr,VcCg,VcCb} = element(1+VcC, VColT),
                   [io_lib:nl(),"           vcol_a_r=\"",format(VcAr),
                    "\" vcol_a_g=\"",format(VcAg),
                    "\" vcol_a_b=\"",format(VcAb),"\"",
                    io_lib:nl(),"           vcol_b_r=\"",format(VcBr),
                    "\" vcol_b_g=\"",format(VcBg),
                    "\" vcol_b_b=\"",format(VcBb),"\"",
                    io_lib:nl(),"           vcol_c_r=\"",format(VcCr),
                    "\" vcol_c_g=\"",format(VcCg),
                    "\" vcol_c_b=\"",format(VcCb),"\""];
               _ ->
                   io:format(?__(4,"WARNING! Face has ~w =/= 3 vertex colors")++"~n",
                             [length(VCols)]),
                   ""
           end,
    println(F, [Shader, "        <f a=\"",format(A),
                "\" b=\"",format(B),"\" c=\"",format(C),"\"", UVIndices,
                VCol]),


                export_faces(F, T, DefaultMaterial, TxT, VColT).


export_light(F, Name, Ps) ->
    case proplists:get_value(visible, Ps, true) of
        true ->
            OpenGL = proplists:get_value(opengl, Ps, []),
            YafaRay = proplists:get_value(?TAG, Ps, []),
            Type = proplists:get_value(type, OpenGL, []),
            export_light(F, Name, Type, OpenGL, YafaRay);
        _ ->
            undefined
    end.

%% Export Point Light

export_light(F, Name, point, OpenGL, YafaRay) ->
    Power = proplists:get_value(power, YafaRay, ?DEF_ATTN_POWER),
    Position = proplists:get_value(position, OpenGL, {0.0,0.0,0.0}),
    Diffuse = proplists:get_value(diffuse, OpenGL, {1.0,1.0,1.0,1.0}),
    Type = proplists:get_value(type, YafaRay, ?DEF_POINT_TYPE),
    println(F,
        "<light name=\"~s\">~n"
        "       <type sval=\"~w\"/>~n"
        "       <power fval=\"~.3f\"/>",
        [Name,Type,Power]),
    case Type of
        pointlight ->
            CastShadows = proplists:get_value(cast_shadows, YafaRay, ?DEF_CAST_SHADOWS),

            println(F,"       <cast_shadows bval=\"~s\"/>", [format(CastShadows)]);

        spherelight ->
            ArealightRadius = proplists:get_value(arealight_radius, YafaRay, ?DEF_AREALIGHT_RADIUS),

            ArealightSamples = proplists:get_value(arealight_samples, YafaRay, ?DEF_AREALIGHT_SAMPLES),

            println(F,
                "       <radius fval=\"~.10f\"/>~n"
                "       <samples ival=\"~w\"/>",
                [ArealightRadius,ArealightSamples])
    end,

    export_pos(F, from, Position),
    export_rgb(F, color, Diffuse),

    println(F, "</light>"),
    undefined;

%% Export Infinite Light Sun and Directional

export_light(F, Name, infinite, OpenGL, YafaRay) ->
    Bg = proplists:get_value(background, YafaRay, ?DEF_BACKGROUND),
    Type = proplists:get_value(type, YafaRay, ?DEF_INFINITE_TYPE),
     InfiniteTrue = proplists:get_value(infinite_true, YafaRay, ?DEF_INFINITE_TRUE),
    Power = proplists:get_value(power, YafaRay, ?DEF_POWER),
    Position = proplists:get_value(position, OpenGL, {0.0,0.0,0.0}),
    Diffuse = proplists:get_value(diffuse, OpenGL, {1.0,1.0,1.0,1.0}),
    SunSamples = proplists:get_value(sun_samples, YafaRay, ?DEF_SUN_SAMPLES),
    SunAngle = proplists:get_value(sun_angle, YafaRay, ?DEF_SUN_ANGLE),

%% Directional Infinite Light Start
    case Type of
        directional when Power > 0.0 ->
            println(F,
                "<light name=\"~s\">~n"
                "       <type sval=\"~w\"/>~n"
                "       <power fval=\"~.3f\"/>",
                [Name, Type, Power]),

%% Add Semi-infinite Start

            case proplists:get_value(infinite_true, YafaRay,
                                     ?DEF_INFINITE_TRUE) of
                false ->
                    InfiniteRadius = proplists:get_value(infinite_radius, YafaRay,
                                                      ?DEF_INFINITE_RADIUS),
                    println(F,
                        "       <infinite bval=\"~s\"/>~n"
                        "       <radius fval=\"~.10f\"/>",
                        [format(InfiniteTrue),InfiniteRadius]),
                        export_pos(F, from, Position);
                true -> ok
            end,
%% Add Semi-infinite End

                    export_pos(F, direction, Position),
                    export_rgb(F, color, Diffuse),
                    println(F, "</light>"),

                Bg;


        directional -> Bg;


%% Directional Infinite Light End
%% Sunlight Infinite Light Start
        sunlight when Power > 0.0 ->
            println(F,
                "<light name=\"~s\">~n"
                "       <type sval=\"~w\"/>~n"
                "       <power fval=\"~.10f\"/>~n"
                "       <samples ival=\"~w\"/>~n"
                "       <angle fval=\"~.3f\"/>",
                [Name, Type, Power, SunSamples, SunAngle]),
            export_pos(F, direction, Position),
            export_rgb(F, color, Diffuse),
            println(F, "</light>"),

        Bg;
        sunlight -> Bg

%% Sunlight Infinite Light End
    end;

%% Export Spot Light

export_light(F, Name, spot, OpenGL, YafaRay) ->
    Power = proplists:get_value(power, YafaRay, ?DEF_ATTN_POWER),
    Position = proplists:get_value(position, OpenGL, {0.0,0.0,0.0}),
    AimPoint = proplists:get_value(aim_point, OpenGL, {0.0,0.0,1.0}),
    ConeAngle = proplists:get_value(cone_angle, OpenGL, ?DEF_CONE_ANGLE),
    Diffuse = proplists:get_value(diffuse, OpenGL, {1.0,1.0,1.0,1.0}),
    Type = proplists:get_value(type, YafaRay, ?DEF_SPOT_TYPE),
    println(F,
        "<light name=\"~s\">~n"
        "\t<power fval=\"~.3f\"/> ",
        [Name,Power]),
    case Type of
        spotlight ->

            SpotPhotonOnly = proplists:get_value(spot_photon_only, YafaRay, ?DEF_SPOT_PHOTON_ONLY),

            SpotSoftShadows = proplists:get_value(spot_soft_shadows, YafaRay, ?DEF_SPOT_SOFT_SHADOWS),

            SpotIESSamples = proplists:get_value(spot_ies_samples, YafaRay, ?DEF_SPOT_IES_SAMPLES),

            CastShadows = proplists:get_value(cast_shadows, YafaRay, ?DEF_CAST_SHADOWS),

            SpotExponent = proplists:get_value(spot_exponent, OpenGL, ?DEF_SPOT_EXPONENT),

            Blend = proplists:get_value(blend, YafaRay, ?DEF_BLEND),
            print(F,
                "\t<type sval=\"spotlight\"/>~n"
                "\t<cast_shadows bval=\"~s\"/>~n"
                "\t<photon_only bval=\"~s\"/>~n"
                "\t<size ival=\"~.3f\"/>~n"
                "\t<beam_falloff fval=\"~.10f\"/>~n"
                "\t<blend fval=\"~.3f\"/>~n"
                "\t<soft_shadows bval=\"~s\"/>~n"
                "\t<samples ival=\"~w\"/>~n",
                [format(CastShadows), SpotPhotonOnly, ConeAngle, SpotExponent, Blend,SpotSoftShadows,SpotIESSamples]);

        spot_ies ->

            SpotSoftShadows =
                proplists:get_value(spot_soft_shadows, YafaRay, ?DEF_SPOT_SOFT_SHADOWS),


            SpotIESFilename = proplists:get_value(spot_ies_filename, YafaRay,
                                      ?DEF_SPOT_IES_FILENAME),

            SpotIESSamples = proplists:get_value(spot_ies_samples, YafaRay,
                                      ?DEF_SPOT_IES_SAMPLES),

            println(F,
                "       <type sval=\"ieslight\"/>~n"
                "       <angle fval=\"~.3f\"/>~n"
                "       <soft_shadows bval=\"~s\"/>~n"
                "       <samples ival=\"~w\"/>~n"
                "       <file sval=\"~s\"/>",
                [ConeAngle,SpotSoftShadows,SpotIESSamples,SpotIESFilename])
    end,
    export_pos(F, from, Position),
    export_pos(F, to, AimPoint),
    export_rgb(F, color, Diffuse),
    println(F, "</light>"),
    undefined;

%% Export Ambient Light

export_light(F, Name, ambient, _OpenGL, YafaRay) ->
    Type = proplists:get_value(type, YafaRay, ?DEF_AMBIENT_TYPE),
    Power = proplists:get_value(power, YafaRay, ?DEF_POWER),
    Bg = proplists:get_value(background, YafaRay, ?DEF_BACKGROUND),
    case Type of
        hemilight when Power > 0.0 ->
            println(F,"",
                    []),
            println(F, "",
                    []),
            case proplists:get_value(use_maxdistance, YafaRay, ?DEF_USE_MAXDISTANCE) of
                true ->
                    Maxdistance = proplists:get_value(maxdistance, YafaRay, ?DEF_MAXDISTANCE),
                    println(F,
                        "       <maxdistance fval=\"~.10f\"/>",
                        [Maxdistance]);
                false -> ok
            end,

            println(F, ""),
            Bg;
        hemilight -> Bg;
        pathlight when Power > 0.0 ->
            println(F,
                "<light type sval=\"~w\" name sval=\"~s\" power fval=\"~.3f\"",
                [Type,Name,Power]),
            UseQMC = proplists:get_value(use_QMC, YafaRay, ?DEF_USE_QMC),

            Depth = proplists:get_value(depth, YafaRay, ?DEF_DEPTH),

            CausDepth = proplists:get_value(caus_depth, YafaRay, ?DEF_CAUS_DEPTH),

            Direct = proplists:get_value(direct, YafaRay, ?DEF_DIRECT),

            Samples = proplists:get_value(samples, YafaRay, ?DEF_SAMPLES),

            print(F,"       use_QMC=\"~s\" samples=\"~w\" "
                  "depth=\"~w\" caus_depth=\"~w\"",
                  [format(UseQMC),Samples,Depth,CausDepth]),
            case Direct of
                true ->
                    print(F, " direct=\"on\"");
                false ->
                    case proplists:get_value(cache, YafaRay, ?DEF_CACHE) of
                        true ->
                            CacheSize =
                                proplists:get_value(cache_size, YafaRay,
                                                    ?DEF_CACHE_SIZE),
                            AngleThreshold =
                                proplists:get_value(angle_threshold, YafaRay,
                                                    ?DEF_ANGLE_THRESHOLD),
                            ShadowThreshold =
                                proplists:get_value(shadow_threshold, YafaRay,
                                                    ?DEF_SHADOW_THRESHOLD),
                            Gradient =
                                proplists:get_value(gradient, YafaRay,
                                                    ?DEF_GRADIENT),
                            ShowSamples =
                                proplists:get_value(show_samples, YafaRay,
                                                    ?DEF_SHOW_SAMPLES),
                            Search =
                                proplists:get_value(search, YafaRay, ?DEF_SEARCH),
                            print(F, " cache=\"on\"~n"
                                  "       cache_size=\"~.10f\" "
                                  "angle_threshold=\"~.10f\"~n"
                                  "       shadow_threshold=\"~.10f\" "
                                  "gradient=\"~s\"~n"
                                  "       show_samples=\"~s\" search=\"~w\"",
                                  [CacheSize,AngleThreshold,
                                   ShadowThreshold,format(Gradient),
                                   format(ShowSamples),Search]);
                        false -> ok
                    end
            end,
            println(F, ">"),
            PathlightMode = proplists:get_value(pathlight_mode, YafaRay,
                                                ?DEF_PATHLIGHT_MODE),
            case PathlightMode of
                undefined ->
                    ok;
                _ ->
                    println(F, "    <mode sval=\"~s\"/>",
                            [format(PathlightMode)])
            end,
            case proplists:get_value(use_maxdistance, YafaRay,
                                     ?DEF_USE_MAXDISTANCE) of
                true ->
                    Maxdistance = proplists:get_value(maxdistance, YafaRay,
                                                      ?DEF_MAXDISTANCE),
                    println(F, "    <maxdistance fval=\"~.10f\"/>",
                            [Maxdistance]);
                false -> ok
            end,
            println(F, "</light>"),
            Bg;
        pathlight -> Bg;
        globalphotonlight ->
            println(F,"<light type sval=\"~w\" name sval=\"~s\"", [Type,Name]),
            GplPhotons = proplists:get_value(
                           globalphotonlight_photons, YafaRay,
                           ?DEF_GLOBALPHOTONLIGHT_PHOTONS),
            GplRadius = proplists:get_value(
                          globalphotonlight_radius, YafaRay,
                          ?DEF_GLOBALPHOTONLIGHT_RADIUS),
            GplDepth = proplists:get_value(
                         globalphotonlight_depth, YafaRay,
                         ?DEF_GLOBALPHOTONLIGHT_DEPTH),
            GplSearch = proplists:get_value(
                          globalphotonlight_search, YafaRay,
                          ?DEF_GLOBALPHOTONLIGHT_SEARCH),
            println(F,"       photons ival=\"~w\" radius=\"~.3f\" "
                    "depth=\"~w\" search=\"~w\">",
                    [GplPhotons,GplRadius,GplDepth,GplSearch]),
            println(F, "</light>"),
            Bg
    end;

%% Export Area Light

export_light(F, Name, area, OpenGL, YafaRay) ->
    Color = proplists:get_value(diffuse, OpenGL, {1.0,1.0,1.0,1.0}),
    #e3d_mesh{vs=Vs,fs=Fs0} = proplists:get_value(mesh, OpenGL, #e3d_mesh{}),
    VsT = list_to_tuple(Vs),
    Power = proplists:get_value(power, YafaRay, ?DEF_ATTN_POWER),
    Samples = proplists:get_value(arealight_samples, YafaRay,
                                           ?DEF_AREALIGHT_SAMPLES),
    Dummy = proplists:get_value(dummy, YafaRay, ?DEF_DUMMY),
    Fs = foldr(fun (Face, Acc) ->
                        e3d_mesh:quadrangulate_face(Face, Vs)++Acc
                end, [], Fs0),
    As = e3d_mesh:face_areas(Fs, Vs),
    Area = foldl(fun (A, Acc) -> A+Acc end, 0.0, As),
    AFs = zip_lists(As, Fs),
    foldl(
      fun ({Af,#e3d_face{vs=VsF}}, I) ->
            case catch Power*Af/Area of
                {'EXIT',{badarith,_}} -> I;
                Pwr ->
                    NameI = Name++"_"++integer_to_list(I),
                    [A,B,C,D] = quadrangle_vertices(VsF, VsT),
                    println(F,
                        "<light name=\"~s\"> <type sval=\"arealight\"/>"
                        "<power fval=\"~.3f\"/>~n"
                        "<samples ival=\"~w\"/>"++
                        if Dummy -> "";
                            true ->
                                ""
                        end++"",
                        [NameI,Pwr,Samples]++
                        if Dummy -> [];
                            true -> []
                        end),
                    export_rgb(F, color, Color),
                    export_pos(F, corner, A),
                    export_pos(F, from, B),
                    export_pos(F, point1, C),
                    export_pos(F, point2, D),
                    println(F, "</light>"),
                    I+1
            end
      end, 1, AFs),
    undefined;
export_light(_F, Name, Type, _OpenGL, _YafaRay) ->
    io:format(?__(1,"WARNING: Ignoring unknown light \"~s\" type: ~p")++"~n",
              [Name, format(Type)]),
    undefined.

%% Cut the longest edge of a triangle in half to make it a quad.
%% Lookup vertex positions.
%%
quadrangle_vertices([V1,V2,V3], VsT) ->
    P1 = element(V1+1, VsT),
    P2 = element(V2+1, VsT),
    P3 = element(V3+1, VsT),
    [L12,L23,L31] =
        [e3d_vec:dot(L, L) ||
            L <- [e3d_vec:sub(P1, P2),e3d_vec:sub(P2, P3),
                  e3d_vec:sub(P3, P1)]],
    if L23 > L31 ->
            if L12 > L23 -> [P1,e3d_vec:average([P1,P2]),P2,P3];
               true -> [P1,P2,e3d_vec:average([P2,P3]),P3]
            end;
       true -> [P1,P2,P3,e3d_vec:average([P3,P1])]
    end;
quadrangle_vertices([V1,V2,V3,V4], VsT) ->
    [element(V1+1, VsT),element(V2+1, VsT),
     element(V3+1, VsT),element(V4+1, VsT)].


export_camera(F, Name, Attr) ->
    #camera_info{pos=Pos,dir=Dir,up=Up,fov=Fov} =
        proplists:lookup(camera_info, Attr),
    Width = proplists:get_value(width, Attr),
    Height = proplists:get_value(height, Attr),
    Lens_Type = proplists:get_value(lens_type, Attr),
    Lens_Ortho_Scale = proplists:get_value(lens_ortho_scale, Attr),
    Lens_Angular_Circular = proplists:get_value(lens_angular_circular, Attr),
    Lens_Angular_Mirrored = proplists:get_value(lens_angular_mirrored, Attr),
    Lens_Angular_Max_Angle = proplists:get_value(lens_angular_max_angle, Attr),
    Lens_Angular_Angle = proplists:get_value(lens_angular_angle, Attr),
    Ro = math:pi()/180.0,
    %% Fov is vertical angle from lower to upper border.
    %% YafaRay focal plane is 1 unit wide.
    FocalDist = 0.5 / ((Width/Height) * math:tan(limit_fov(Fov)*0.5*Ro)),
    Aperture = proplists:get_value(aperture, Attr),
    println(F,
        "<camera name=\"~s\">~n"
        "\t<resx ival=\"~w\"/>~n"
        "\t<resy ival=\"~w\"/>~n"
        "\t<focal fval=\"~.10f\"/>~n"++
        if Aperture > 0.0 ->
            "\t<dof_distance fval=\"~.10f\"/>~n"
            "\t<aperture fval=\"~.10f\"/>~n"
            "\t<use_qmc bval=\"~s\"/>~n"
            "\t<bokeh_type sval=\"~s\"/>~n"
            "\t<bokeh_bias sval=\"~s\"/>~n"
            "\t<bokeh_rotation fval=\"~.10f\"/>~n"
            "\t<dof_distance fval=\"~.10f\"/>~n";
            true -> ""
            end++

        case Lens_Type of
            perspective ->
                "\t<type sval=\"~s\"/>~n";
            orthographic ->
                "\t<type sval=\"~s\"/>~n"
                "\t<scale fval=\"~.10f\"/>~n";
            architect ->
                "\t<type sval=\"~s\"/>~n";
            angular ->
                "\t<type sval=\"~s\"/>~n"
                "\t<circular bval=\"~s\"/>~n"
                "\t<mirrored bval=\"~s\"/>~n"
                "\t<max_angle fval=\"~.10f\"/>~n"
                "\t<angle fval=\"~.10f\"/>~n"
            end,

            [Name,Width,Height,FocalDist]++
            if Aperture > 0.0 ->
                [e3d_vec:len(Dir),
                Aperture,
                format(proplists:get_value(bokeh_use_QMC, Attr)),
                format(proplists:get_value(bokeh_type, Attr)),
                format(proplists:get_value(bokeh_bias, Attr)),
                proplists:get_value(bokeh_rotation, Attr),
                proplists:get_value(dof_distance, Attr)];
                true -> []
            end++


            case Lens_Type of
                perspective -> [format(Lens_Type)];
                orthographic  -> [format(Lens_Type),Lens_Ortho_Scale];
                architect    -> [format(Lens_Type)];
                angular    -> [format(Lens_Type),
                    format(Lens_Angular_Circular),
                    format(Lens_Angular_Mirrored),
                    Lens_Angular_Max_Angle,
                    Lens_Angular_Angle]

            end

            ),
    export_pos(F, from, Pos),
    export_pos(F, to, e3d_vec:add(Pos, Dir)),
    export_pos(F, up, e3d_vec:add(Pos, Up)),
    println(F, "</camera>").

limit_fov(Fov) when Fov < 1.0 -> 1.0;
limit_fov(Fov) when Fov > 179.0 -> 179.0;
limit_fov(Fov) -> Fov.



export_background(F, Name, Ps) ->
    OpenGL = proplists:get_value(opengl, Ps, []),
    YafaRay = proplists:get_value(?TAG, Ps, []),
    Bg = proplists:get_value(background, YafaRay, ?DEF_BACKGROUND),
    case Bg of
%% Constant Background Export
        constant ->
            print(F,
                "<background name=\"~s\">~n", [Name]),
            println(F,
                "\t<type sval=\"~s\"/>", [format(Bg)]),

            BgColor = proplists:get_value(background_color, YafaRay, ?DEF_BACKGROUND_COLOR),

            export_rgb(F, color, BgColor),

            ConstantBackPower = proplists:get_value(constant_back_power, YafaRay, ?DEF_CONSTANT_BACK_POWER),
            println(F,
                "\t<power fval=\"~w\"/>~n", [ConstantBackPower]);

%% Gradient Background Export
        gradientback ->
            print(F,
                "<background name=\"~s\">~n", [Name]),

            println(F,
                "\t<type sval=\"~s\"/>~n", [format(Bg)]),

            HorizonColor = proplists:get_value(horizon_color, YafaRay, ?DEF_HORIZON_COLOR),
            export_rgb(F, horizon_color, HorizonColor),

            ZenithColor = proplists:get_value(zenith_color, YafaRay, ?DEF_ZENITH_COLOR),
            export_rgb(F, zenith_color, ZenithColor),

            GradientBackPower = proplists:get_value(gradient_back_power, YafaRay, ?DEF_GRADIENT_BACK_POWER),
            println(F,
                "\t<power fval=\"~w\"/>~n", [GradientBackPower]);

%% Sunsky Background Export
        sunsky ->
%%%         Power = proplists:get_value(power, YafaRay, ?DEF_POWER),
            Turbidity = proplists:get_value(turbidity, YafaRay, ?DEF_TURBIDITY),
            A_var = proplists:get_value(a_var, YafaRay, ?DEF_SUNSKY_VAR),
            B_var = proplists:get_value(b_var, YafaRay, ?DEF_SUNSKY_VAR),
            C_var = proplists:get_value(c_var, YafaRay, ?DEF_SUNSKY_VAR),
            D_var = proplists:get_value(d_var, YafaRay, ?DEF_SUNSKY_VAR),
            E_var = proplists:get_value(e_var, YafaRay, ?DEF_SUNSKY_VAR),

    SkyBackgroundLight = proplists:get_value(sky_background_light, YafaRay, ?DEF_SKY_BACKGROUND_LIGHT),
    SkyBackgroundSamples = proplists:get_value(sky_background_samples, YafaRay, ?DEF_SKY_BACKGROUND_SAMPLES),

    Position = proplists:get_value(position, OpenGL, {1.0,1.0,1.0}),

    print(F,
        "<background name=\"~s\">~n"
        "\t<type sval=\"~s\"/>~n",
        [Name,format(Bg)]),

        println(F,
            "\t<turbidity fval=\"~.3f\"/>~n"
            "\t<a_var fval=\"~.3f\"/>~n"
            "\t<b_var fval=\"~.3f\"/>~n"
            "\t<c_var fval=\"~.3f\"/>~n"
            "\t<d_var fval=\"~.3f\"/>~n"
            "\t<e_var fval=\"~.3f\"/>~n"
            "\t<add_sun bval=\"false\"/>",
            [Turbidity,A_var,B_var,C_var,D_var,E_var]),


%% Add Skylight Start

        case proplists:get_value(sky_background_light, YafaRay, ?DEF_SKY_BACKGROUND_LIGHT) of
            true ->
                SkyBackgroundPower =
                    proplists:get_value(sky_background_power, YafaRay, ?DEF_SKY_BACKGROUND_POWER),
                SkyBackgroundSamples =
                    proplists:get_value(sky_background_samples, YafaRay, ?DEF_SKY_BACKGROUND_SAMPLES),
                println(F,
                    "\t<background_light bval=\"~s\"/>~n"
                    "\t<power fval=\"~.3f\"/>~n"
                    "\t<light_samples ival=\"~w\"/>",
                    [format(SkyBackgroundLight),SkyBackgroundPower,SkyBackgroundSamples]);

            false -> ok
            end,
%% Add Skylight End

            export_pos(F, from, Position);


%% HDRI Background Export
        'HDRI' ->
            BgFname = proplists:get_value(background_filename_HDRI, YafaRay,
                                          ?DEF_BACKGROUND_FILENAME),
            BgExpAdj = proplists:get_value(background_exposure_adjust, YafaRay,
                                           ?DEF_BACKGROUND_EXPOSURE_ADJUST),
            BgMapping = proplists:get_value(background_mapping, YafaRay,
                                            ?DEF_BACKGROUND_MAPPING),
            Samples = proplists:get_value(samples, YafaRay, ?DEF_SAMPLES),

            print(F,
                "<texture name=\"world_texture\">~n"
                "\t<filename sval=\"~s\"/>~n"
                "\t<interpolate sval=\"bilinear\"/>~n"
                "\t<type sval=\"image\"/>~n"
                "</texture>~n",
                [BgFname]),
            println(F,
                "<background name=\"~s\">~n"
                "\t<type sval=\"textureback\"/>~n",
                [Name]),
            println(F,
                "\t<power fval=\"~w\"/>~n"
                "\t<mapping sval=\"~s\"/>~n",
                [BgExpAdj,format(BgMapping)]),

            case proplists:get_value(background_enlight, YafaRay,
                                     ?DEF_BACKGROUND_ENLIGHT) of
                true ->
                    println(F, "\t<ibl bval=\"true\"/>"),
                    println(F, "\t<ibl_samples ival=\"~w\"/>",[Samples]);
                false ->
                    println(F, "\t<ibl bval=\"false\"/>")
            end,


           print(F, "\t<texture sval=\"world_texture\"/>");

%% Image Background Export
        image ->
            BgFname = proplists:get_value(background_filename_image, YafaRay, ?DEF_BACKGROUND_FILENAME),

            BgPower = proplists:get_value(background_power, YafaRay, ?DEF_BACKGROUND_POWER),

            Samples = proplists:get_value(samples, YafaRay, ?DEF_SAMPLES),

            print(F,
            "<texture name=\"world_texture\">~n"
            "\t<filename sval=\"~s\"/>~n"
            "\t<interpolate sval=\"bilinear\"/>~n"
            "\t<type sval=\"image\"/>~n"
            "\t</texture>~n",
            [BgFname]),

            println(F,
                "<background name=\"~s\">~n"
                "\t<type sval=\"textureback\"/>~n",
                [Name]),

            println(F, " <power fval=\"~.3f\"/>", [BgPower]),

%% Add Enlight Texture Start
            case proplists:get_value(background_enlight, YafaRay, ?DEF_BACKGROUND_ENLIGHT) of
                true ->
                    println(F, "\t<ibl bval=\"true\"/>"),
                    println(F, "\t<ibl_samples ival=\"~w\"/>",[Samples]);
                false ->
                    println(F, "\t<ibl bval=\"false\"/>")
            end,

%% Add Enlight Texture End

            println(F, "\t<texture sval=\"world_texture\" />~n")
    end,
    println(F, "</background>").


export_render(F, CameraName, BackgroundName, Outfile, Attr) ->
    AA_passes = proplists:get_value(aa_passes, Attr),
    AA_minsamples = proplists:get_value(aa_minsamples, Attr),
    AA_pixelwidth = proplists:get_value(aa_pixelwidth, Attr),
    AA_threshold = proplists:get_value(aa_threshold, Attr),
    ClampRGB = proplists:get_value(clamp_rgb, Attr),
    BackgroundTranspRefract = proplists:get_value(background_transp_refract, Attr),
    AA_Filter_Type = proplists:get_value(aa_filter_type, Attr),
    SaveAlpha = proplists:get_value(save_alpha, Attr),
    Raydepth = proplists:get_value(raydepth, Attr),
    TransparentShadows = proplists:get_value(transparent_shadows, Attr),
    ShadowDepth = proplists:get_value(shadow_depth, Attr),
    Gamma = proplists:get_value(gamma, Attr),
    Exposure = proplists:get_value(exposure, Attr),
    RenderFormat = proplists:get_value(render_format, Attr),
    ExrFlagFloat = proplists:get_value(exr_flag_float, Attr),
    ExrFlagZbuf = proplists:get_value(exr_flag_zbuf, Attr),
    ExrFlagCompression = proplists:get_value(exr_flag_compression, Attr),
    Width = proplists:get_value(width, Attr),
    Height = proplists:get_value(height, Attr),
    UseSSS = proplists:get_value(use_sss, Attr),
    SSS_Photons = proplists:get_value(sss_photons, Attr),
    SSS_Depth = proplists:get_value(sss_depth, Attr),
    SSS_Scale = proplists:get_value(sss_scale, Attr),
    SSS_SingleScatter_Samples = proplists:get_value(sss_singlescatter_samples, Attr),
    UseCaustics = proplists:get_value(use_caustics, Attr),
    Caustic_Photons = proplists:get_value(caustic_photons, Attr),
    Caustic_Depth = proplists:get_value(caustic_depth, Attr),
    Caustic_Mix = proplists:get_value(caustic_mix, Attr),
    Caustic_Radius = proplists:get_value(caustic_radius, Attr),
    Do_AO = proplists:get_value(do_ao, Attr),
    AO_Distance = proplists:get_value(ao_distance, Attr),
    AO_Samples = proplists:get_value(ao_samples, Attr),
    AO_Color =  proplists:get_value(ao_color,Attr),
    Lighting_Method = proplists:get_value(lighting_method, Attr),
    PM_Diffuse_Photons = proplists:get_value(pm_diffuse_photons, Attr),
    PM_Bounces = proplists:get_value(pm_bounces, Attr),
    PM_Search = proplists:get_value(pm_search, Attr),
    PM_Diffuse_Radius = proplists:get_value(pm_diffuse_radius, Attr),
    PM_Caustic_Photons = proplists:get_value(pm_caustic_photons, Attr),
    PM_Caustic_Radius =  proplists:get_value(pm_caustic_radius, Attr),
    PM_Caustic_Mix = proplists:get_value(pm_caustic_mix, Attr),
    PM_Use_Background = proplists:get_value(pm_use_background, Attr),
    PM_Use_FG = proplists:get_value(pm_use_fg, Attr),
    PM_FG_Bounces = proplists:get_value(pm_fg_bounces, Attr),
    PM_FG_Samples = proplists:get_value(pm_fg_samples, Attr),
    PM_FG_Show_Map = proplists:get_value(pm_fg_show_map, Attr),
    PT_Diffuse_Photons = proplists:get_value(pt_diffuse_photons, Attr),
    PT_Bounces = proplists:get_value(pt_bounces, Attr),
    PT_Caustic_Type = proplists:get_value(pt_caustic_type, Attr),
    PT_Caustic_Radius =  proplists:get_value(pt_caustic_radius, Attr),
    PT_Caustic_Mix = proplists:get_value(pt_caustic_mix, Attr),
    PT_Caustic_Depth = proplists:get_value(pt_caustic_depth, Attr),
    PT_Use_Background = proplists:get_value(pt_use_background, Attr),
    PT_Samples = proplists:get_value(pt_samples, Attr),
    Volintegr_Type = proplists:get_value(volintegr_type, Attr),
    Volintegr_Adaptive = proplists:get_value(volintegr_adaptive, Attr),
    Volintegr_Optimize = proplists:get_value(volintegr_optimize, Attr),
    Volintegr_Stepsize = proplists:get_value(volintegr_stepsize, Attr),
    ThreadsAuto = proplists:get_value(threads_auto, Attr),
    ThreadsNumber = proplists:get_value(threads_number, Attr),
println(F," "),
println(F, "<integrator name=\"default\">"),


            case Lighting_Method of
                directlighting ->
                    println(F," "),
                    println(F, "\t<type sval=\"~s\"/>",[Lighting_Method]),
                    println(F, "\t<raydepth ival=\"~w\"/>",[Raydepth]),
                    println(F, "\t<transpShad bval=\"~s\"/>",[format(TransparentShadows)]),
                    println(F, "\t<shadowDepth ival=\"~w\"/>",[ShadowDepth]),
                    println(F," ");

                photonmapping ->
                    println(F," "),
                    println(F, "\t<type sval=\"~s\"/>",[Lighting_Method]),
                    println(F, "\t<raydepth ival=\"~w\"/>",[Raydepth]),
                    println(F, "\t<transpShad bval=\"~s\"/>",[format(TransparentShadows)]),
                    println(F, "\t<shadowDepth ival=\"~w\"/>",[ShadowDepth]),
                    println(F, "\t<photons ival=\"~w\"/>",[PM_Diffuse_Photons]),
                    println(F, "\t<bounces ival=\"~w\"/>",[PM_Bounces]),
                    println(F, "\t<search ival=\"~w\"/>",[PM_Search]),
                    println(F, "\t<diffuseRadius fval=\"~.10f\"/>",[PM_Diffuse_Radius]),
                    println(F, "\t<cPhotons ival=\"~w\"/>",[PM_Caustic_Photons]),
                    println(F, "\t<causticRadius fval=\"~.10f\"/>",[PM_Caustic_Radius]),
                    println(F, "\t<caustic_mix ival=\"~w\"/>",[PM_Caustic_Mix]),
                    println(F, "\t<finalGather bval=\"~s\"/>",[PM_Use_FG]),
                    println(F, "\t<fg_bounces ival=\"~w\"/>",[PM_FG_Bounces]),
                    println(F, "\t<fg_samples ival=\"~w\"/>",[PM_FG_Samples]),
                    println(F, "\t<show_map bval=\"~s\"/>",[PM_FG_Show_Map]),
                    println(F, "\t<use_background bval=\"~s\"/>",[PM_Use_Background]),
                    println(F," ");

                pathtracing ->
                    println(F," "),
                    println(F, "\t<type sval=\"~s\"/>",[Lighting_Method]),
                    println(F, "\t<raydepth ival=\"~w\"/>",[Raydepth]),
                    println(F, "\t<transpShad bval=\"~s\"/>",[format(TransparentShadows)]),
                    println(F, "\t<shadowDepth ival=\"~w\"/>",[ShadowDepth]),
                    println(F, "\t<photons ival=\"~w\"/>",[PT_Diffuse_Photons]),
                    println(F, "\t<bounces ival=\"~w\"/>",[PT_Bounces]),
                    println(F, "\t<caustic_type sval=\"~s\"/>",[PT_Caustic_Type]),
                    println(F, "\t<caustic_radius fval=\"~.10f\"/>",[PT_Caustic_Radius]),
                    println(F, "\t<caustic_mix ival=\"~w\"/>",[PT_Caustic_Mix]),
                    println(F, "\t<caustic_depth ival=\"~w\"/>",[PT_Caustic_Depth]),
                    println(F, "\t<path_samples ival=\"~w\"/>",[PT_Samples]),
                    println(F, "\t<use_background bval=\"~s\"/>",[PT_Use_Background]),
                    println(F," ");

                bidirectional ->
                    println(F," "),
                    println(F, "\t<type sval=\"~s\"/>",[Lighting_Method]),
                    println(F, "\t<raydepth ival=\"~w\"/>",[Raydepth]),
                    println(F," ")

                end,

            case UseCaustics of
                true ->
                    println(F, "\t<caustics bval=\"true\"/>"),
                    println(F, "\t<photons ival=\"~w\"/>",[Caustic_Photons]),
                    println(F, "\t<caustic_depth ival=\"~w\"/>",[Caustic_Depth]),
                    println(F, "\t<caustic_mix ival=\"~w\"/>",[Caustic_Mix]),
                    println(F, "\t<caustic_radius fval=\"~.10f\"/>",[Caustic_Radius]);

                false ->
                    println(F, "\t<caustics bval=\"false\"/>")

                end,

            case Do_AO of
                true ->
                    println(F, "\t<do_AO bval=\"true\"/>"),
                    println(F, "\t<AO_distance fval=\"~.10f\"/>",[AO_Distance]),
                    println(F, "\t<AO_samples fval=\"~.10f\"/>",[AO_Samples]),
                    export_rgb(F, "AO_color",AO_Color);


                false ->
                    println(F, "\t<do_AO bval=\"false\"/>")

                end,


            case UseSSS of
                true ->
                    println(F, "\t<useSSS bval=\"true\"/>"),
                    println(F, "\t<sssPhotons ival=\"~w\"/>",[SSS_Photons]),
                    println(F, "\t<sssDepth ival=\"~w\"/>",[SSS_Depth]),
                    println(F, "\t<sssScale fval=\"~.10f\"/>",[SSS_Scale]),
                    println(F, "\t<singleScatterSamples ival=\"~w\"/>",[SSS_SingleScatter_Samples]);

                false ->
                    println(F, "\t<ibl bval=\"false\"/>")

                end,

println(F, "</integrator>"),

            case Volintegr_Type of
                none ->
                    println(F," "),
                    println(F, "<integrator name=\"volintegr\">"),
                    println(F, "        <type sval=\"~s\"/>",[Volintegr_Type]),
                    println(F, "</integrator>"),
                    println(F," ");

                singlescatterintegrator ->
                    println(F," "),
                    println(F, "<integrator name=\"volintegr\">"),
                    println(F, "        <type sval=\"SingleScatterIntegrator\"/>"),
                    println(F, "        <adaptive bval=\"~s\"/>",[format(Volintegr_Adaptive)]),
                    println(F, "        <optimize bval=\"~s\"/>",[format(Volintegr_Optimize)]),
                    println(F, "        <stepSize fval=\"~.10f\"/>",[Volintegr_Stepsize]),
                    println(F, "</integrator>"),
                    println(F," ")
                end,

    ExrFlags =
        case RenderFormat of
            exr ->
                [if ExrFlagFloat -> "float "; true -> "" end,
                 if ExrFlagZbuf -> "zbuf "; true -> "" end,
                 format(ExrFlagCompression)];
            _ -> ""
        end,
    println(F,
        "<render>~n"
        "\t<camera_name sval=\"~s\"/>~n"
        "\t<filter_type sval=\"~s\"/>~n"
        "\t<AA_passes ival=\"~w\"/>~n"
        "\t<AA_threshold fval=\"~.10f\"/>~n"
        "\t<AA_minsamples ival=\"~w\"/>~n"
        "\t<AA_pixelwidth fval=\"~.10f\"/>~n"++
        case SaveAlpha of
            premultiply ->
                "\t<premult bval=\"true\"/>~n";
            backgroundmask ->
                "\t<alpha_backgroundmask=\"on\"/>~n";
                _ -> ""
            end++

            "\t<clamp_rgb bval=\"~s\"/>~n"
            "\t<bg_transp_refract bval=\"~s\"/>~n"
            "\t<background_name sval=\"~s\"/>~n"++
            case RenderFormat of
                tga -> "";
                _   -> "\t<output_type sval=\"~s\"/>~n"
            end++
            case RenderFormat of
                exr -> "\t<exr_flags sval=\"~s\"/>~n";
                _   -> ""
            end++

            "\t<width ival=\"~w\"/>~n"
            "\t<height ival=\"~w\"/>~n"
            "\t<outfile sval=\"~s\"/>~n"
            "\t<indirect_samples sval=\"0\"/>~n"
            "\t<indirect_power sval=\"1.0\"/>~n"
            "\t<exposure fval=\"~.10f\"/>~n"++
            case SaveAlpha of
                false -> "";
                _ ->
                    "\t<save_alpha bval=\"on\"/>~n"
            end++
            "\t<gamma fval=\"~.10f\"/>~n"
            "    ",
            [CameraName,AA_Filter_Type,AA_passes,AA_threshold, AA_minsamples,AA_pixelwidth,
                format(ClampRGB),format(BackgroundTranspRefract),BackgroundName]++
            case RenderFormat of
                tga -> [];
                _   -> [format(RenderFormat)]
            end++
            case RenderFormat of
                exr -> [ExrFlags];
                _   -> []
            end++

            [Width,Height,Outfile,Exposure,Gamma]),

    println(F, "\t<integrator_name sval=\"default\"/>~n"),

            case ThreadsAuto of
                true ->
                    println(F, "\t<threads ival=\"-1\"/>~n");

                false ->
                    println(F, "\t<threads ival=\"~w\"/>~n",[ThreadsNumber])

            end,

    println(F, "\t<volintegrator_name sval=\"volintegr\"/>~n"),
    println(F, "</render>").

%%% Noisy file output functions. Fail if anything goes wrong.
%%%

open(Filename, export) ->
    case file:open(Filename, [write,raw,delayed_write]) of
        {ok, F} ->
            F;
        Error ->
            erlang:error(Error, [Filename, export])
    end.

println(F) ->
    println(F, "").

print(F, DeepString) ->
    case file:write(F, DeepString) of
        ok ->
            ok;
        Error ->
            erlang:error(Error, [F,DeepString])
    end.

println(F, DeepString) ->
    case file:write(F, [DeepString,io_lib:nl()]) of
        ok ->
            ok;
        Error ->
            erlang:error(Error, [F,DeepString])
    end.

print(F, Format, Args) ->
    case file:write(F, io_lib:format(Format, Args)) of
        ok ->
            ok;
        Error ->
            erlang:error(Error, [F,Format,Args])
    end.

println(F, Format, Args) ->
    case file:write(F, [io_lib:format(Format, Args),io_lib:nl()]) of
        ok ->
            ok;
        Error ->
            erlang:error(Error, [F,Format,Args])
    end.

close(F) ->
    case file:close(F) of
        ok ->
            ok;
        Error ->
            erlang:error(Error, [F])
    end.



%% Convert certain terms to printable strings in a
%% hopefully efficient way.

format(F) when is_float(F) ->
    I = abs(trunc(F)),
    D = abs(F) - float(I),
    if F < 0 ->
            [$-,integer_to_list(I)|format_decimals(D)];
       true ->
            [integer_to_list(I)|format_decimals(D)]
    end;
format(I) when is_integer(I) ->
    integer_to_list(I);
format(true) ->
    "true";
format(false) ->
    "false";
format(A) when is_atom(A) ->
    atom_to_list(A);
format(L) when is_list(L) ->
    L.

format_decimals(F) when is_float(F), F >= 0.0 ->
    format_decimals_1(F).

format_decimals_1(0.0) ->
    ".0";
format_decimals_1(F) when is_float(F) ->
    G = 10.0 * F,
    I = trunc(G),
    D = G - float(I),
    [$.,(I+$0)|format_decimals_2(D)].

format_decimals_2(0.0) ->
    [];
format_decimals_2(F) when is_float(F) ->
    G = 100.0 * F,
    I = trunc(G),
    D = G - float(I),
    if I < 10 ->
            [$0,(I+$0)|format_decimals_3(D)];
       true ->
            [integer_to_list(I)|format_decimals_3(D)]
    end.

format_decimals_3(0.0) ->
    [];
format_decimals_3(F) when is_float(F) ->
    G = 1000.0 * F,
    I = trunc(G),
    D = G - float(I),
    if I < 10 ->
            [$0,$0,(I+$0)|format_decimals_4(D)];
       I < 100 ->
            [$0,integer_to_list(I)|format_decimals_4(D)];
       true ->
            [integer_to_list(I)|format_decimals_4(D)]
    end.

format_decimals_4(0.0) ->
    [];
format_decimals_4(F) when is_float(F) ->
    G = 10000.0 * F,
    I = trunc(G),
    if I < 100 ->
            if I < 10 ->
                    [$0,$0,$0,(I+$0)];
               true ->
                    [$0,$0|integer_to_list(I)]
            end;
       true ->
            if I < 1000 ->
                    [$0|integer_to_list(I)];
               true ->
                    integer_to_list(I)
            end
    end.

%% Set and get preference variables saved in the .wings file for this module

set_prefs(Attr) ->
    wpa:scene_pref_set(?MODULE, Attr).

set_user_prefs(Attr) ->
    wpa:pref_set(?MODULE, Attr).

get_pref(Key, Def) ->
    [{Key,Val}] = get_prefs([{Key,Def}]),
    Val.

get_prefs(KeyDefs) when is_list(KeyDefs) ->
    get_prefs_1(KeyDefs, make_ref()).

get_prefs_1([], _Undefined) ->
    [];
get_prefs_1([{Key,Def}|KeyDefs], Undefined) ->
    [{Key,case wpa:scene_pref_get(?MODULE, Key, Undefined) of
              Undefined ->
                  wpa:pref_get(?MODULE, Key, Def);
              Val ->
                  Val
          end}|get_prefs_1(KeyDefs, Undefined)].

get_user_prefs(KeyDefs) when is_list(KeyDefs) ->
    [{Key,wpa:pref_get(?MODULE, Key, Def)} || {Key,Def} <- KeyDefs].

%% Set and get global variables (in the process dictionary)
%% per wings session for this module.

set_var(Name, undefined) ->
    erase_var(Name);
set_var(Name, Value) ->
    put({?MODULE,Name}, Value).

get_var(Name) ->
    get({?MODULE,Name}).

erase_var(Name) ->
    erase({?MODULE,Name}).


%% Split a list into a list of length Pos, and the tail
%%
split_list(List, Pos) when is_list(List), is_integer(Pos), Pos >= 0 ->
    case split_list1(List, Pos, []) of
        {_,_}=Result ->
            Result;
        Error ->
            erlang:error(Error, [List, Pos])
    end.
%%
split_list1(List, 0, Head) ->
    {lists:reverse(Head),List};
split_list1([], _Pos, _) ->
    badarg;
split_list1([H|T], Pos, Head) ->
    split_list1(T, Pos-1, [H|Head]).

%% Zip lists together into a list of tuples
%%
zip_lists([], []) -> [];
zip_lists([H1|T1], [H2|T2]) -> [{H1,H2}|zip_lists(T1, T2)].



%%% %% {lists:filter(Pred, List),lists:filter(fun(X) -> not Pred(X) end, List)}
%%% filter2(Pred, List) -> filter2_1(Pred, List, [], []).
%%% %%
%%% filter2_1(_Pred, [], True, False) ->
%%%     {reverse(True),reverse(False)};
%%% filter2_1(Pred, [H|T], True, False) ->
%%%     case Pred(H) of
%%%     true -> filter2_1(Pred, T, [H|True], False);
%%%     false -> filter2_1(Pred, T, True, [H|False])
%%%     end.

max(X, Y) when X > Y -> X;
max(_, Y) -> Y.


-ifdef(print_mesh_1).
print_mesh(#e3d_mesh{type=T,vs=Vs,vc=Vc,tx=Tx,ns=Ns,fs=Fs,he=He,matrix=M}) ->
    io:format("#e3d_mesh{type=~p,~nvs=~p,~nvc=~p,~ntx=~p,~nns=~p,~nfs=~p,~n"
              "he=~p,~nmatrix=~p}.~n",
              [T,Vs,Vc,Tx,Ns,Fs,He,M]).
-endif.

help_button(Subject) ->
    Title = help(title, Subject),
    TextFun = fun () -> help(text, Subject) end,
    {help,Title,TextFun}.

help(title, {material_dialog,object}) ->
    ?__(6,"YafaRay Material Properties: Object Parameters");
help(text, {material_dialog,object}) ->
    [?__(7,"Object Parameters are applied to whole objects, namely those "
      "that have this material on a majority of their faces."),
     ?__(8,"Mapping to YafaRay object parameters:"),
     ?__(9,"Cast Shadow -> 'shadow'."),
     ?__(10,"Emit Rad -> 'emit_rad' -> Emit Radiosity."),
     ?__(11,"Recv Rad -> 'recv_rad' -> Receive Radiosity."),
     ?__(12,"Use Edge Hardness -> Emulate hard edges by "
      "slitting the object mesh along hard edges."),
     ?__(13,"Autosmooth Angle -> 'autosmooth'."),
     ?__(14,"A Photon Light must be present for Emit Rad and Recv Rad "
     "to have an affect. Set Fresnel Parameters to add Caustics.")];
help(title, {material_dialog,fresnel}) ->
    ?__(15,"YafaRay Material Properties: Fresnel Parameters");
help(text, {material_dialog,fresnel}) ->
    [?__(16,"Fresnel Parameters affect how rays reflect off and refract in "
      "glass-like materials. This is a different light model than the "
      "OpenGL (Diffuse,Specular,Shininess) model and they do not often "
      "go well together. "
      "A Photon Light must be present to produce Caustics."),
     ?__(17,"Mapping to YafaRay shader parameters:"),
     ?__(18,"Index Of Refraction -> 'ior' -> 1.5 for Glass/Caustics."),
     ?__(19,"Total Internal Reflection -> 'tir' -> Enable for Glass."),
     ?__(20,"Minimum Reflection -> 'min_refle' -> 1.0 for Metal."),
     ?__(21,"Reflected -> 'reflected' -> Reflective Caustics."),
     ?__(22,"Transmitted -> 'transmitted' -> Glass/Refractive Caustics."),
     ?__(23,"Set Default -> Sets 'transmitted' to Diffuse * (1 - Opacity). "
      "This makes a semi-transparent object in OpenGL look the same in "
      "YafaRay provided that Index Of Refraction is 1.1 minimum."),
     ?__(24,"Grazing Angle Colors -> Use the secondary Reflected and Transmitted "
      "colors following that show from grazing angles of the material. "
      "For a glass with green edges set Transmitted to white and "
      "Grazing Angle Transmitted to green."),
     ?__(25,"Absorption -> Sets the desired color for white light travelling "
      "the given distance through the material.")];
%%
help(title, light_dialog) ->
    ?__(26,"YafaRay Light Properties");
help(text, light_dialog) ->
    [?__(27,"OpenGL properties that map to YafaRay light parameters are:"),
     ?__(28,"Diffuse -> 'color'"),
     ?__(29,"All other OpenGl properties are ignored, particulary the "
      "Attenuation properties."),
     ?__(30,"Spotlight set to Photonlight is used to produce Caustics or Radiosity. "
      "Photonlight set to Caustic for Caustics. "
      "Photonlight set to Diffuse for Radiosity. "),
     ?__(31,"The Enlight checkbox in a Hemilight with an image background "
      "activates the background image as ambient light source instead of "
      "the defined ambient color by excluding the 'color' tag "
      "from the Hemilight."),
     ?__(32,"Note: For a YafaRay Global Photon Light (one of the Ambient lights) - "
      "the Power parameter is ignored")];
help(title, pref_dialog) ->
    ?__(33,"YafaRay Options");
help(text, pref_dialog) ->
    [?__(34,"These are user preferences for the YafaRay exporter plugin"),
     ?__(35,"Automatic Dialogs: ")
     ++wings_help:cmd([?__(36,"File"),?__(37,"Export"),?__(38,"YafaRay")])++", "
     ++wings_help:cmd([?__(39,"File"),?__(40,"Export Selected"),?__(41,"YafaRay")])++" "++?__(42,"and")++" "
     ++wings_help:cmd([?__(43,"File"),?__(44,"Render"),?__(45,"YafaRay")])++" "++
     ?__(46,"are enabled if the rendering executable is found (in the path), "
     "or if the rendering executable is specified with an absolute path."),
     %%
     ?__(47,"Disabled Dialogs:")++" "
     ++wings_help:cmd([?__(48,"File"),?__(49,"Export"),?__(50,"YafaRay")])++", "
     ++wings_help:cmd([?__(51,"File"),?__(52,"Export Selected"),?__(53,"YafaRay")])++" "++?__(54,"and")++" "
     ++wings_help:cmd([?__(55,"File"),?__(56,"Render"),?__(57,"YafaRay")])++" "++
     ?__(58,"are disabled."),
     %%
     ?__(59,"Enabled Dialogs:")++" "
     ++wings_help:cmd([?__(60,"File"),?__(61,"Export"),?__(62,"YafaRay")])++" "++?__(63,"and")++" "
     ++wings_help:cmd([?__(64,"File"),?__(65,"Export Selected"),?__(66,"YafaRay")])++" "++
     ?__(67,"are always enabled, but")++" "
     ++wings_help:cmd([?__(68,"File"),?__(69,"Render"),?__(70,"YafaRay")])++" "++
     ?__(71,"is still as for \"Automatic Dialogs\"."),
     %%
     ?__(72,"Executable: The rendering command for the YafaRay raytrace "
      "renderer ('c:/yafaray/bin/yafaray-xml.exe') that is supposed to "
      "be found in the executables search path; or, the absolute path of "
      "that executable. You may have to add YafaRay to your computer's "
      "Path Settings. My Computer > Properties > Advanced Tab > "
      "Environment Variables > User Variables > Path > Edit > Variable "
      "Value > add 'c:/yafaray', without ' '. Notice that each added item "
      "has a semicolon (;) before and after it."),
     ?__(73,"Options: Rendering command line options to be inserted between the "
      "executable and the .xml filename. -dp (add render settings badge) "
      "-vl (verbosity level) -pp (plugins path)'c:/yafaray/bin/plugins'. ")].
