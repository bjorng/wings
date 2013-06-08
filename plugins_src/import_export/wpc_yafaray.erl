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

%% defines here
%%
-include("yafaray/yaf_defines.erl").
%%

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
    maybe_append(edit, Dialog, light_dialog(Name, Ps)); %% luces

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
            do_export(export, props(render, Attr), [{?TAG_RENDER,true}|Attr], St);
        true ->
            wpa:error(?__(1,"Already rendering."))
    end;

command_file(render=Op, Ask, _St) when is_atom(Ask) ->
    export_dialog(Op, Ask, ?__(2,"YafaRay Render Options"),fun(Attr) ->
        {file,{Op,{?TAG,Attr}}}
    end);

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
        {win32,_} ->
            {"Export Selected","YafaRay File"};
        _Other    ->
            {?__(4,"Export Selected"),?__(5,"YafaRay File")}
    end,
    [{title,Title},{ext,".xml"},{ext_desc,File}].


%%% Dialogues and results
%%%
-include("yafaray/yaf_materials_UI.erl").
%% povman : material dialogs..---------->
%%------------------------------------>

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

%% Modulators: A shader material slots..

-include("yafaray/yaf_shaders_UI.erl").

%%
%% YafaRay Lights dialogs

-include("yafaray/yaf_lights_UI.erl").

%%------------------------

    pref_dialog(St) ->
        [{dialogs,Dialogs},{renderer,Renderer},{options,Options},{shader_type,ShaderType}] =
            get_user_prefs([
                {dialogs,?DEF_DIALOGS},
                {renderer,?DEF_RENDERER},
                {options,?DEF_OPTIONS},
                {shader_type,?DEF_SHADER_TYPE}]),

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
     {pm_caustic_radius,?DEF_PM_CAUSTIC_RADIUS},        %%--> 20
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
     {sss_photons,?DEF_SSS_PHOTONS},                    %%--> 40
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
     {aa_filter_type,?DEF_AA_FILTER_TYPE},              %%--> 60
     {background_color,?DEF_BACKGROUND_COLOR}, %---------------->
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
     {dof_distance,?DEF_DOF_DISTANCE},
     {background, ?DEF_BACKGROUND} %% add element for finded : 79
     ].

%
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
    [
        {hframe,[
            {button,?__(1,"New Modulator(shader)"),done,[key(new_modulator)]},
            panel|
            if M =:= 1 -> [{button,?__(2,"Default Modulators"),done}];
            true -> []
            end
        ]}
    ];
    modulator_dialogs([Modulator|Modulators], Maps, M) ->
        modulator_dialog(Modulator, Maps, M)++
        modulator_dialogs(Modulators, Maps, M+1).

-include("yafaray/yaf_render_UI.erl").
%% export dialogs

%%% Increase split_list # +1 per line if add Render Settings to Dialog
%%%

export_dialog_loop({Op,Fun}=Keep, Attr) ->
    {Prefs,Buttons} = split_list(Attr, 79), %% povman: add index?? old value 78
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
    println(F,
        "<?xml version=\"1.0\"?>\n"
        "<!-- ~s: Exported from ~s -->\n"
        "<scene type=\"triangle\">",
         [filename:basename(ExportFile), CreatorChg]),
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
    BgLights = reverse(foldl(fun ({Name,Ps}=Light, Bgs) ->
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
                BgColor = proplists:get_value(background_color, Attr,?DEF_BACKGROUND_COLOR),
                Ps = [{?TAG,[{background,constant},{background_color,BgColor}]}],
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

    AlphaChannel =
        case SaveAlpha of
            false -> "";
            _ ->    "-a "
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
        wings_job:render(
            ExportTS, Renderer,
            AlphaChannel++"-f "++format(RenderFormat)++" "++ArgStr++" "++wings_job:quote(filename:rootname(Filename))++" ",
            PortOpts, Handler)
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
%%%%%% Export Shiny Diffuse Material
%%
-include("yafaray/yaf_export_materials.erl").

%%% Start Texture Export
%%%
-include("yafaray/yaf_export_texture.erl").


export_rgb(F, Type, {R,G,B,_}) ->
    export_rgb(F, Type, {R,G,B});

export_rgb(F, Type, {R,G,B}) ->
    println(F, ["\t<",format(Type)," r=\"",format(R),
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

%% to export objects..
-include("yafaray/yaf_export_objects.erl").


%% lights
-include("yafaray/yaf_export_lights.erl").

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
            "\t<dof_distance fval=\"~.10f\"/>\n"
            "\t<aperture fval=\"~.10f\"/>\n"
            "\t<use_qmc bval=\"~s\"/>\n"
            "\t<bokeh_type sval=\"~s\"/>\n"
            "\t<bokeh_bias sval=\"~s\"/>\n"
            "\t<bokeh_rotation fval=\"~.10f\"/>\n"
            "\t<dof_distance fval=\"~.10f\"/>\n";
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
                orthographic -> [format(Lens_Type),Lens_Ortho_Scale];
                architect -> [format(Lens_Type)];
                angular -> [format(Lens_Type),
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

    %% Constant Background Export
    case Bg of
        constant ->
            print(F,
                "<background name=\"~s\">\n"
                "\t<type sval=\"~s\"/>\n", [Name, format(Bg)]),

            BgColor = proplists:get_value(background_color, YafaRay, ?DEF_BACKGROUND_COLOR),

            export_rgb(F, color, BgColor),

            ConstantBackPower = proplists:get_value(constant_back_power, YafaRay, ?DEF_CONSTANT_BACK_POWER),
            println(F,
                "\t<power fval=\"~w\"/>~n",
                [ConstantBackPower]);

        %% Gradient Background Export
        gradientback ->
            print(F,
                "<background name=\"~s\">\n"
                "\t<type sval=\"~s\"/>\n",
                [Name, format(Bg)]),

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
                [Name, format(Bg)]),

            println(F,
                "\t<turbidity fval=\"~.3f\"/>\n"
                "\t<a_var fval=\"~.3f\"/>\n"
                "\t<b_var fval=\"~.3f\"/>\n"
                "\t<c_var fval=\"~.3f\"/>\n"
                "\t<d_var fval=\"~.3f\"/>\n"
                "\t<e_var fval=\"~.3f\"/>\n"
                "\t<add_sun bval=\"false\"/>",
                [Turbidity, A_var, B_var, C_var,D_var, E_var]),

            %% Add Skylight
            case proplists:get_value(sky_background_light, YafaRay, ?DEF_SKY_BACKGROUND_LIGHT) of
                true ->
                    SkyBackgroundPower =
                        proplists:get_value(sky_background_power, YafaRay, ?DEF_SKY_BACKGROUND_POWER),

                    SkyBackgroundSamples =
                        proplists:get_value(sky_background_samples, YafaRay, ?DEF_SKY_BACKGROUND_SAMPLES),

                    println(F,
                        "\t<background_light bval=\"~s\"/>\n"
                        "\t<power fval=\"~.3f\"/>\n"
                        "\t<light_samples ival=\"~w\"/>",
                        [format(SkyBackgroundLight), SkyBackgroundPower, SkyBackgroundSamples]);

                false -> ok
            end,

            export_pos(F, from, Position);


        %% HDRI Background Export
        'HDRI' ->
            BgFname = proplists:get_value(background_filename_HDRI, YafaRay, ?DEF_BACKGROUND_FILENAME),

            BgExpAdj = proplists:get_value(background_exposure_adjust, YafaRay, ?DEF_BACKGROUND_EXPOSURE_ADJUST),

            BgMapping = proplists:get_value(background_mapping, YafaRay, ?DEF_BACKGROUND_MAPPING),

            Samples = proplists:get_value(samples, YafaRay, ?DEF_SAMPLES),

            println(F,
                "\n<texture name=\"world_texture\">\n"
                "\t<filename sval=\"~s\"/>\n"
                "\t<interpolate sval=\"bilinear\"/>\n"
                "\t<type sval=\"image\"/>\n"
                "</texture>",
                [BgFname]),

            println(F,
                "<background name=\"~s\">\n"
                "\t<type sval=\"textureback\"/>",
                [Name]),

            println(F,
                "\t<power fval=\"~w\"/>\n"
                "\t<mapping sval=\"~s\"/>",
                [BgExpAdj, format(BgMapping)]),

            case proplists:get_value(background_enlight, YafaRay,?DEF_BACKGROUND_ENLIGHT) of
                true ->
                    println(F,
                        "\t<ibl bval=\"true\"/>\n"
                        "\t<ibl_samples ival=\"~w\"/>",
                        [Samples]);
                false ->
                    println(F, "\t<ibl bval=\"false\"/>")
            end,

           print(F, "\t<texture sval=\"world_texture\"/>\n");

        %% Image Background Export
        image ->
            BgFname = proplists:get_value(background_filename_image, YafaRay, ?DEF_BACKGROUND_FILENAME),

            BgPower = proplists:get_value(background_power, YafaRay, ?DEF_BACKGROUND_POWER),

            Samples = proplists:get_value(samples, YafaRay, ?DEF_SAMPLES),

            print(F,
                "<\ntexture name=\"world_texture\">\n"
                "\t<filename sval=\"~s\"/>\n"
                "\t<interpolate sval=\"bilinear\"/>\n"
                "\t<type sval=\"image\"/>\n"
                "</texture>",
                [BgFname]),

            println(F,
                "<\nbackground name=\"~s\">\n"
                "\t<type sval=\"textureback\"/>",
                [Name]),

            println(F, "\t<power fval=\"~.3f\"/>", [BgPower]),

        %% Add Enlight Texture Start
            case proplists:get_value(background_enlight, YafaRay, ?DEF_BACKGROUND_ENLIGHT) of
                true ->
                    println(F,
                        "\t<ibl bval=\"true\"/>\n"
                        "\t<ibl_samples ival=\"~w\"/>",
                        [Samples]);
                false ->
                    println(F, "\t<ibl bval=\"false\"/>")
            end,

            println(F, "\t<texture sval=\"world_texture\"/>")
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
    %%-> volume integrator
    Volintegr_Type = proplists:get_value(volintegr_type, Attr),
    Volintegr_Adaptive = proplists:get_value(volintegr_adaptive, Attr),
    Volintegr_Optimize = proplists:get_value(volintegr_optimize, Attr),
    Volintegr_Stepsize = proplists:get_value(volintegr_stepsize, Attr),
    ThreadsAuto = proplists:get_value(threads_auto, Attr),
    ThreadsNumber = proplists:get_value(threads_number, Attr),

    println(F, "\n<integrator name=\"default\">"),

    case Lighting_Method of
        directlighting ->
            println(F,
                "\t<type sval=\"~s\"/>\n"
                "\t<raydepth ival=\"~w\"/>\n"
                "\t<transpShad bval=\"~s\"/>\n"
                "\t<shadowDepth ival=\"~w\"/>",
                [Lighting_Method, Raydepth, format(TransparentShadows), ShadowDepth]),
                %%
                case Do_AO of
                    true ->
                        println(F,
                            "\t<do_AO bval=\"true\"/>\n"
                            "\t<AO_distance fval=\"~.10f\"/>\n"
                            "\t<AO_samples fval=\"~.10f\"/>",
                            [AO_Distance, AO_Samples]),
                        %
                        export_rgb(F, "AO_color",AO_Color);
                    false ->
                        println(F, "\t<do_AO bval=\"false\"/>")
                end,
                %%
                case UseCaustics of
                    true ->
                        println(F,
                            "\t<caustics bval=\"true\"/>\n"
                            "\t<photons ival=\"~w\"/>\n"
                            "\t<caustic_depth ival=\"~w\"/>\n"
                            "\t<caustic_mix ival=\"~w\"/>\n"
                            "\t<caustic_radius fval=\"~.10f\"/>",
                            [Caustic_Photons, Caustic_Depth, Caustic_Mix, Caustic_Radius]);
                    false ->
                        println(F, "\t<caustics bval=\"false\"/>")
                end;

        photonmapping ->
            println(F,
                "\t<type sval=\"~s\"/>\n"
                "\t<raydepth ival=\"~w\"/>\n"
                "\t<transpShad bval=\"~s\"/>\n"
                "\t<shadowDepth ival=\"~w\"/>",
                [Lighting_Method, Raydepth, format(TransparentShadows) ,ShadowDepth]),

            println(F,
                "\t<photons ival=\"~w\"/>\n"
                "\t<bounces ival=\"~w\"/>\n"
                "\t<search ival=\"~w\"/>\n"
                "\t<diffuseRadius fval=\"~.10f\"/>",
                [PM_Diffuse_Photons, PM_Bounces, PM_Search, PM_Diffuse_Radius]),

            println(F,
                "\t<cPhotons ival=\"~w\"/>\n"
                "\t<causticRadius fval=\"~.10f\"/>\n"
                "\t<caustic_mix ival=\"~w\"/>",
                [PM_Caustic_Photons, PM_Caustic_Radius, PM_Caustic_Mix]),

            println(F,
                "\t<finalGather bval=\"~s\"/>\n"
                "\t<fg_bounces ival=\"~w\"/>\n"
                "\t<fg_samples ival=\"~w\"/>\n"
                "\t<show_map bval=\"~s\"/>",
                [PM_Use_FG, PM_FG_Bounces, PM_FG_Samples, PM_FG_Show_Map]);

        pathtracing ->
            println(F,
                "\t<type sval=\"~s\"/>\n"
                "\t<raydepth ival=\"~w\"/>\n"
                "\t<transpShad bval=\"~s\"/>\n"
                "\t<shadowDepth ival=\"~w\"/>",
                [Lighting_Method, Raydepth, format(TransparentShadows) ,ShadowDepth]),

            %% need more review for some 'case' type
            println(F, "\t<photons ival=\"~w\"/>",[PT_Diffuse_Photons]),
            println(F, "\t<bounces ival=\"~w\"/>",[PT_Bounces]),
            println(F, "\t<caustic_type sval=\"~s\"/>",[PT_Caustic_Type]),
            println(F, "\t<caustic_radius fval=\"~.10f\"/>",[PT_Caustic_Radius]),
            println(F, "\t<caustic_mix ival=\"~w\"/>",[PT_Caustic_Mix]),
            println(F, "\t<caustic_depth ival=\"~w\"/>",[PT_Caustic_Depth]),
            println(F, "\t<path_samples ival=\"~w\"/>",[PT_Samples]),
            println(F, "\t<use_background bval=\"~s\"/>",[PT_Use_Background]);

        bidirectional ->
            println(F,
                "\t<type sval=\"~s\"/>\n"
                "\t<raydepth ival=\"~w\"/>\n"
                "\t<transpShad bval=\"~s\"/>\n"
                "\t<shadowDepth ival=\"~w\"/>",
                [Lighting_Method, Raydepth, format(TransparentShadows), ShadowDepth])
        end,

    case UseSSS of
        true ->
            println(F,
                "\t<useSSS bval=\"true\"/>\n"
                "\t<sssPhotons ival=\"~w\"/>\n"
                "\t<sssDepth ival=\"~w\"/>\n"
                "\t<sssScale fval=\"~.10f\"/>\n"
                "\t<singleScatterSamples ival=\"~w\"/>",
                [SSS_Photons, SSS_Depth, SSS_Scale, SSS_SingleScatter_Samples]);

        false ->
            println(F,"") % povman: fix test for ibl ??
            %%println(F, "\t<ibl bval=\"false\"/>")

    end,

    println(F, "</integrator>"),

    case Volintegr_Type of
        none ->
            println(F,
                "\n<integrator name=\"volintegr\">\n"
                "\t<type sval=\"~s\"/>\n"
                "</integrator>",
                [Volintegr_Type]);

        singlescatterintegrator ->
            println(F,
                "\n<integrator name=\"volintegr\">\n"
                "\t<type sval=\"SingleScatterIntegrator\"/>\n"
                "\t<adaptive bval=\"~s\"/>\n"
                "\t<optimize bval=\"~s\"/>\n"
                "\t<stepSize fval=\"~.10f\"/>\n"
                "</integrator>",
                [format(Volintegr_Adaptive), format(Volintegr_Optimize), Volintegr_Stepsize])
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
        "\n<render>\n"
        "\t<AA_passes ival=\"~w\"/>\n"
        "\t<AA_threshold fval=\"~.10f\"/>\n"
        "\t<AA_minsamples ival=\"~w\"/>\n"
        "\t<AA_pixelwidth fval=\"~.10f\"/>\n"
        "\t<filter_type sval=\"~s\"/>\n"
        "\t<camera_name sval=\"~s\"/>",
        [AA_passes, AA_threshold, AA_minsamples, AA_pixelwidth, AA_Filter_Type, CameraName]),

    case SaveAlpha of

        true ->
            println(F, "\t<save_alpha bval=\"true\"/>");

        premultiply ->
            println(F, "\t<premult bval=\"true\"/>");

        backgroundmask ->
            println(F, "\t<alpha_backgroundmask bval=\"true\"/>");

        _ ->
            println(F, "\t<save_alpha bval=\"false\"/>")
    end,

    println(F,
        "\t<clamp_rgb bval=\"~s\"/>\n"
        "\t<bg_transp_refract bval=\"~s\"/>\n"
        "\t<background_name sval=\"~s\"/>",
        [format(ClampRGB), format(BackgroundTranspRefract), BackgroundName]),

    case RenderFormat of
        tga ->
            println(F,
                "\t<output_type sval=\"tga\"/>");
        exr ->
            println(F,
                "\t<output_type sval=\"exr\"/>\n"
                "\t<exr_flags sval=\"~s\"/>",   % unused in 0.1.2 ??
                [ExrFlags]);
        _ ->
            println(F,"")
    end,

    println(F,
        "\t<width ival=\"~w\"/>\n"
        "\t<height ival=\"~w\"/>\n"
        "\t<outfile sval=\"~s\"/>\n"
        "\t<indirect_samples sval=\"0\"/>\n"    %% unused in 0.1.2 ??
        "\t<indirect_power sval=\"1.0\"/>\n"    %% unused in 0.1.2 ??
        "\t<exposure fval=\"~.10f\"/>",         %% unused in 0.1.2 ??
        [Width, Height, Outfile, Exposure]),

    println(F,"\t<gamma fval=\"~.10f\"/>", [Gamma]),

    println(F, "\t<integrator_name sval=\"default\"/>"),

    case ThreadsAuto of
        true ->
            println(F, "\t<threads ival=\"-1\"/>");
        false ->
            println(F, "\t<threads ival=\"~w\"/>",[ThreadsNumber])
    end,

    println(F, "\t<volintegrator_name sval=\"volintegr\"/>"),
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

-include("yafaray/yaf_help.erl").