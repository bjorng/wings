%%
%%  wpc_obj.erl --
%%
%%     Wavefront import/export.
%%
%%  Copyright (c) 2002-2005 Bjorn Gustavsson
%%
%%  See the file "license.terms" for information on usage and redistribution
%%  of this file, and for a DISCLAIMER OF ALL WARRANTIES.
%%
%%     $Id: wpc_obj.erl,v 1.16 2006/01/08 18:02:00 giniu Exp $
%%

-module(wpc_obj).

-export([init/0,menu/2,command/2]).

-include("wings_intl.hrl").

init() ->
    true.

menu({file,import}, Menu) ->
    menu_entry(Menu);
menu({file,export}, Menu) ->
    menu_entry(Menu);
menu({file,export_selected}, Menu) ->
    menu_entry(Menu);
menu(_, Menu) -> Menu.

command({file,{import,{obj,Ask}}}, St) ->
    do_import(Ask, St);
command({file,{export,{obj,Ask}}}, St) ->
    Exporter = fun(Ps, Fun) -> wpa:export(Ps, Fun, St) end,
    do_export(Ask, export, Exporter, St);
command({file,{export_selected,{obj,Ask}}}, St) ->
    Exporter = fun(Ps, Fun) -> wpa:export_selected(Ps, Fun, St) end,
    do_export(Ask, export_selected, Exporter, St);
command(_, _) ->
    next.

menu_entry(Menu) ->
    Menu ++ [{"Wavefront (.obj)...",obj,[option]}].

props() ->
    [{ext,".obj"},{ext_desc,?__(1,"Wavefront File")}].

%%%
%%% Import.
%%%

do_import(Ask, _St) when is_atom(Ask) ->
    wpa:dialog(Ask, ?__(1,"Wavefront Import Options"), dialog(import),
	       fun(Res) ->
		       {file,{import,{obj,Res}}}
	       end);
do_import(Attr, St) ->
    set_pref(Attr),
    wpa:import(props(), import_fun(Attr), St).

import_fun(Attr) ->
    fun(Filename) ->
	    case e3d_obj:import(Filename) of
		{ok,E3dFile0} ->
		    E3dFile = import_transform(E3dFile0, Attr),
		    {ok,E3dFile};
		{error,Error} ->
		    {error,Error}
	    end
    end.

%%%
%%% Export.
%%%

do_export(Ask, Op, _Exporter, _St) when is_atom(Ask) ->
    wpa:dialog(Ask, ?__(1,"Wavefront Export Options"), dialog(export),
	       fun(Res) ->
		       {file,{Op,{obj,Res}}}
	       end);
do_export(Attr, _Op, Exporter, _St) when is_list(Attr) ->
    set_pref(Attr),
    SubDivs = proplists:get_value(subdivisions, Attr, 0),
    Tesselation = proplists:get_value(tesselation, Attr, none),
    Uvs = proplists:get_bool(include_uvs, Attr),
    Ps = [{tesselation,Tesselation},{subdivisions,SubDivs},
	  {include_uvs,Uvs},{include_colors,false}|props()],
    Exporter(Ps, export_fun(Attr)).

export_fun(Attr) ->
    fun(Filename, Contents) ->
	    export_1(Filename, Contents, Attr)
    end.

export_1(Filename, Contents0, Attr) ->
    Filetype = proplists:get_value(default_filetype, Attr, ".tga"),
    Contents1 = export_transform(Contents0, Attr),
    Contents = wpa:save_images(Contents1, filename:dirname(Filename), Filetype),
    case e3d_obj:export(Filename, Contents, Attr) of
	ok -> ok;
	{error,_}=Error -> Error
    end.

dialog(import) ->
    [wpa:dialog_template(?MODULE, import)];
dialog(export) ->
    wpa:pref_set_default(?MODULE, default_filetype, ".tga"),
    [{?__(1,"One group per material"),get_pref(group_per_material, true),
      [{key,group_per_material}]},
     {?__(2,"Vue d'Esprit workaround"),get_pref(dot_slash_mtllib, false),
      [{key,dot_slash_mtllib}]},
     panel,
     wpa:dialog_template(?MODULE, tesselation),
     panel,
     wpa:dialog_template(?MODULE, export, [include_colors])].

get_pref(Key, Def) ->
    wpa:pref_get(?MODULE, Key, Def).

set_pref(KeyVals) ->
    wpa:pref_set(?MODULE, KeyVals).

export_transform(Contents, Attr) ->
    Mat = wpa:export_matrix(Attr),
    e3d_file:transform(Contents, Mat).

import_transform(Contents, Attr) ->
    Mat = wpa:import_matrix(Attr),
    e3d_file:transform_matrix(Contents, Mat).
