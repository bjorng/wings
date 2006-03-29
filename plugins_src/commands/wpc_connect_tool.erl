%%
%%  wpc_connect_tool.erl --
%%
%%     Connect/Cut mode plugin.
%%
%%  Copyright (c) 2004 Dan Gudmundsson
%%
%%  See the file "license.terms" for information on usage and redistribution
%%  of this file, and for a DISCLAIMER OF ALL WARRANTIES.
%%
%%     $Id: wpc_connect_tool.erl,v 1.26 2006/03/29 19:25:54 dgud Exp $
%%
-module(wpc_connect_tool).

-export([init/0,menu/2,command/2]).
-export([line_intersect2d/4]).

-define(NEED_ESDL, 1).
-define(NEED_OPENGL, 1).

-include_lib("wings.hrl").

-import(lists, [foldl/3,last/1,member/2,reverse/1,reverse/2,
		seq/2,sort/1]).
%% State info
-record(cs, {v=[],  %% Connected vertices
	     last,  %% Last vertex selected (for ending loop)
	     we,    %% Current we
	     st,    %% Working St
	     cpos,  %% Cursor Position
	     mode=normal, %% or slide
	     loop_cut = false, %% Cut all around
	     backup,%% State to go back when something is wrong
	     ost}). %% Original St

%% Vertex info
-record(vi, {id,    %% Vertex Id
	     mm,    %% MatrixMode
	     pos}). %% Vertex Pos

-define(EPS, 0.000001).

init() -> true.

menu({tools}, Menu0) ->
    Menu0 ++ [separator,
	      {?__(1,"Connect"), connect,
	       ?__(2,"Mode for quickly connecting vertices and edges")}
	     ];
menu(_, Menu) -> Menu.

command({tools,connect}, St0) ->
    wings:mode_restriction([vertex,edge]), %% ,face
    Active = wings_wm:this(),
    wings_wm:callback(fun() -> wings_u:menu_restriction(Active, [view]) end),
    St = wings_undo:init(St0#st{selmode=edge,sel=[],sh=true}),
    wings_draw:refresh_dlists(St),
    C = #cs{ost=St0, st=St},
    help(C),
    {seq,push,update_connect_handler(C)};
command(_, _) -> next.

%% Event handler for connect mode

update_connect_handler(#cs{st=St}=C) ->
    wings_wm:current_state(St),
    wings_draw:update_sel_dlist(),
    wings_wm:dirty(),
    {replace,fun(Ev) -> handle_connect_event(Ev, C) end}.

handle_connect_event(redraw, C) ->
    help(C),
    redraw(C),
    keep;
handle_connect_event(Ev, #cs{st=St}=C) ->
    Cam = wings_camera:event(Ev, St),
    case Cam of
	next -> handle_connect_event0(Ev, C);
	Other -> Other
    end.

handle_connect_event0(#keyboard{sym=?SDLK_ESCAPE}, C) ->
    exit_connect(C);
handle_connect_event0(#mousemotion{}=Ev, #cs{st=St, v=VL}=C) ->
    Update = VL /= [],
    Redraw = fun() -> redraw(C) end,
    Options = [{always_dirty,Update}, 
	       {filter, fun(Hit) -> filter_hl(Hit,C) end}],
    case wings_pick:hilite_event(Ev, St, Redraw, Options) of
	next -> handle_connect_event1(Ev, C);
	Other -> Other
    end;
handle_connect_event0(Ev=#keyboard{unicode=Char}, S=#cs{loop_cut=LC}) ->
    case Char of
	$1 -> update_connect_handler(S#cs{loop_cut=(not LC)});
	_ -> handle_connect_event1(Ev, S)
    end;
handle_connect_event0(Ev, S) -> handle_connect_event1(Ev, S).

handle_connect_event1(#mousebutton{button=1,x=X,y=Y,state=?SDL_PRESSED},
		      #cs{st=St0}=C0) ->
    case wpa:pick(X,Y,St0) of
	{add,MM,St = #st{selmode=edge,sel=[{Shape,Edge0}],shapes=Sh}} ->
	    #we{es=Es} = gb_trees:get(Shape, Sh),
	    [Edge] = gb_sets:to_list(Edge0),
	    #edge{vs=V1,ve=V2} = gb_trees:get(Edge, Es),
	    case cut_edge(X,Y,MM,St,C0) of
		C0 -> 
		    keep;
		C ->
		    wings_draw:refresh_dlists(C#cs.st),
		    {drag, Drag} = slide(C,V1,V2),
		    wings_wm:later({slide_setup,Drag}),
		    update_connect_handler(C#cs{mode=slide,backup=C0})
	    end;
	_Other ->
	    keep
    end;
handle_connect_event1(#mousebutton{button=1,x=X,y=Y,state=?SDL_RELEASED},
		      #cs{st=St0}=C0) ->
    case wpa:pick(X,Y,St0) of
	{add,MM,St} ->
	    C = do_connect(X,Y,MM,St,C0),
	    update_hook(C),
	    wings_draw:refresh_dlists(C#cs.st),
	    update_connect_handler(C);
	_Other ->
	    keep
    end;
handle_connect_event1(#mousebutton{button=3,state=?SDL_RELEASED}, C) ->
    exit_connect(C);
handle_connect_event1(init_opengl, #cs{st=St}) ->
    wings:init_opengl(St),
    wings_draw:refresh_dlists(St),
    keep;
handle_connect_event1(quit=Ev, C) ->
    wings_wm:later(Ev),
    exit_connect(C);
handle_connect_event1(got_focus, C = #cs{st=St}) ->
    update_connect_handler(C#cs{st=St#st{selmode=edge,sel=[],sh=true}});
handle_connect_event1({current_state,St}, #cs{st=St}) ->    
    keep; %% Ignore my own changes.
handle_connect_event1({current_state,St}=Ev, C) ->
    case topological_change(St) of
	false ->
	    wings_draw:refresh_dlists(St),
	    update_connect_handler(C#cs{st=St});
	true ->
	    wings_wm:later(Ev),
	    wings:unregister_postdraw_hook(geom,?MODULE),
	    pop
    end;
handle_connect_event1({slide_setup,Drag},_C) ->
    wings_drag:do_drag(Drag,none);
handle_connect_event1({new_state,St0=#st{shapes=Sh}},
		      C0=#cs{mode=slide,we=Shape,v=[V|VR],backup=Old}) ->
    #we{vp=Vtab} = gb_trees:get(Shape, Sh),
    Pos = gb_trees:get(V#vi.id, Vtab),
    St1 = St0#st{sel=[],temp_sel=none, sh=true},    
    C1 = C0#cs{mode=normal,v=[V#vi{pos=Pos}|VR],st=St1},
    case connect_edge(C1) of
	C1 when VR /= [] -> 
	    update_hook(Old),
	    wings_draw:refresh_dlists(Old#cs.st),
	    update_connect_handler(Old);
	C ->
	    St = wings_undo:save(Old#cs.st,C#cs.st),
	    update_hook(C),
	    wings_draw:refresh_dlists(St),
	    update_connect_handler(C#cs{st=St})
    end;
handle_connect_event1({new_state,St}=Ev, C) ->
    case topological_change(St) of
	false ->
	    wings_draw:refresh_dlists(St),
	    update_connect_handler(C#cs{st=St});
	true ->
	    wings_wm:later(Ev),
	    wings:unregister_postdraw_hook(geom,?MODULE),
	    pop
    end;
handle_connect_event1({action,Action}, #cs{st=St0}=C) ->
    case Action of
	{select,Cmd} -> select_cmd(Cmd, C);
	{view,auto_rotate} -> keep;
	{view,smoothed_preview} -> keep;
	{view,aim} ->
	    St = fake_selection(St0),
	    wings_view:command(aim, St),
	    update_connect_handler(C);
	{view,Cmd} ->
	    case wings_view:command(Cmd, St0) of
		keep ->
		    keep;
		#st{}=St ->
		    refresh_dlists(Cmd, St),
		    update_connect_handler(C#cs{st=St})
	    end;
	{edit,undo_toggle} ->
	    St = wings_undo:undo_toggle(St0),
	    undo_refresh(St,C);
	{edit,undo} ->
	    St = wings_undo:undo(St0),
	    undo_refresh(St,C);
	{edit,redo} ->
	    St = wings_undo:redo(St0),
	    undo_refresh(St,C);
	Other ->
	    wings_wm:later({action,Other}),
	    exit_connect(C)
    end;
handle_connect_event1(Ev, #cs{st=St}) ->
    case wings_hotkey:event(Ev, St) of
	next -> keep;
	Other -> wings_wm:later({action,Other})
    end.

undo_refresh(St0,C0) ->
    St = St0#st{sel=[],temp_sel=none,sh=true},
    C = C0#cs{v=[],we=undefined,last=undefined,mode=normal,st=St},
    update_hook(C),
    wings_draw:refresh_dlists(St),
    update_connect_handler(C).

exit_connect(#cs{ost=St,st=#st{shapes=Shs,views=Views}}) ->
    wings:unregister_postdraw_hook(geom, ?MODULE),
    wings_wm:later({new_state,St#st{shapes=Shs,views=Views}}),
    pop.

refresh_dlists(wireframe_selected, _) -> ok;
refresh_dlists(shade_selected, _) -> ok;
refresh_dlists(toggle_wireframe, _) -> ok;
refresh_dlists(orthogonal_view, _) -> ok;
refresh_dlists(aim, _) -> ok;
refresh_dlists(frame, _) -> ok;
refresh_dlists(toggle_lights, _) -> ok;
refresh_dlists({along,_}, _) -> ok;
refresh_dlists({toggle_lights,_}, _) -> ok;
refresh_dlists(_, St) -> wings_draw:refresh_dlists(St).

select_cmd(deselect, #cs{st=St0}=C) ->
    St = wings_sel:reset(St0),
    update_connect_handler(C#cs{st=St});
select_cmd(vertex=M, C) -> mode_change(M, C);
select_cmd(edge=M, C) -> mode_change(M, C);
% select_cmd(face=M, C) -> mode_change(M, C);
% select_cmd(body=M, C) -> mode_change(M, C);
% select_cmd({adjacent,M}, C) -> mode_change(M, C);
select_cmd(_, _) -> keep.

mode_change(Mode, #cs{st=St0}=C) ->
    St = St0#st{selmode=Mode,sh=false},
    update_connect_handler(C#cs{st=St}).

topological_change(#st{shapes=Shs}) ->
    R = wings_dl:fold(fun(#dlo{src_we=We}, [We|Wes]) -> Wes;
			 (#dlo{drag=none}, [_|Wes]) -> Wes;
			 (_, _) -> changed
		      end, gb_trees:values(Shs)),
    R =:= changed.

redraw(#cs{st=St}) ->
    wings:redraw("", St),
    keep.

%%filter_hl(Hit,Cstate) -> true|false
filter_hl(_, _) -> true.  %% Debug connection
%% filter_hl(_, #cs{v=[]}) -> true;
%% filter_hl({_,_,{Sh,_}},#cs{we=Prev}) when Sh /= Prev ->
%%     false;
%% filter_hl({edge,_,{Shape,Edge}}, #cs{last=Id,st=#st{shapes=Sh}}) ->
%%     We = #we{es=Es} = gb_trees:get(Shape,Sh),
%%     Ok = vertex_fs(Id, We),
%%     #edge{lf=F1,rf=F2} = gb_trees:get(Edge, Es),
%%     Fs = ordsets:from_list([F1,F2]),
%%     length(ordsets:intersection(Fs,Ok)) == 1;
%% filter_hl({vertex,_,{_,Id1}}, #cs{last=Id1}) -> true; %% Allow quitting
%% filter_hl({vertex,_,{Shape,Id1}}, #cs{last=Id2,st=#st{shapes=Sh}}) ->
%%     We = gb_trees:get(Shape,Sh),
%%     Ok = vertex_fs(Id2, We),
%%     Fs = vertex_fs(Id1, We),
%%     length(ordsets:intersection(Fs,Ok)) == 1.

do_connect(_X,_Y,MM,St0=#st{selmode=vertex,sel=[{Shape,Sel0}],shapes=Sh},
	   C0=#cs{v=VL,loop_cut=LC,we=Prev}) ->
    [Id1] = gb_sets:to_list(Sel0),
    We0 = gb_trees:get(Shape, Sh),
    Pos = gb_trees:get(Id1, We0#we.vp),
    St1 = St0#st{sel=[],temp_sel=none, sh=true},
    Fs = vertex_fs(Id1, We0),
    VI = #vi{id=Id1,mm=MM,pos=Pos},
    case VL of
	[] ->
	    C0#cs{v=[VI],we=Shape,last=Id1,st=St1};
	[#vi{id=Id1}|_] -> 
	    C0#cs{v=[],we=undefined,last=undefined,st=St1};
	[#vi{id=Id2}|_] when Prev == Shape ->
	    Ok = vertex_fs(Id2,We0),
	    try 
		We=#we{}=connect_link(get_line(Id1,Id2,MM,We0),
				      Id1,Fs,Id2,Ok,LC,MM,We0),
		St2 = St1#st{shapes=gb_trees:update(Shape,We, Sh)},
		St = wings_undo:save(St0, St2),
		C0#cs{v=[VI],we=Shape,last=Id1,st=St}
	    catch _:_What -> 
%%    		    io:format("~p catched ~w ~p~n",[?LINE,_What,erlang:get_stacktrace()]),
		    C0
	    end;
	_ -> %% Wrong we, ignore 
	    C0
    end;
do_connect(_,_,_,_,C) -> 
    C.

connect_edge(C0=#cs{v=[_]}) -> C0;
connect_edge(C0=#cs{v=[VI=#vi{id=Id1,mm=MM},#vi{id=Id2}],loop_cut=LC,we=Shape,st=St0}) ->
    We0 = gb_trees:get(Shape, St0#st.shapes),
    Fs = vertex_fs(Id1,We0),
    Ok = vertex_fs(Id2,We0),
    try 
	We=#we{}= connect_link(get_line(Id1,Id2,MM,We0),
			       Id1,Fs,Id2,Ok,LC,MM,We0),
	St = St0#st{shapes=gb_trees:update(Shape,We,St0#st.shapes)},
	C0#cs{v=[VI],last=Id1,st=St}
    catch _E:_What -> 
%%	    io:format("~p ignored ~w ~p~n", [?LINE,_What,erlang:get_stacktrace()]),
	    C0
    end.

cut_edge(X,Y,MM,St0=#st{selmode=edge,sel=[{Shape,Sel0}],shapes=Sh},
	 C0=#cs{v=VL,we=Prev}) ->
    [Edge] = gb_sets:to_list(Sel0),
    We0 = gb_trees:get(Shape, Sh),
    if 
	Prev /= undefined, Prev /= Shape ->
	    C0;	    %% Wrong We, Ignore
	true ->
	    St1 = St0#st{sel=[],temp_sel=none,sh=true},
	    {Pos,_Fs} = calc_edgepos(X,Y,Edge,MM,We0,VL),
	    {We1,Id1} = wings_edge:fast_cut(Edge, Pos, We0),
	    VI = #vi{id=Id1,mm=MM,pos=Pos},
	    St = St1#st{shapes=gb_trees:update(Shape,We1,Sh)},
	    C0#cs{v=[VI|VL],we=Shape,last=Id1,st=St}
    end.
	       
vertex_fs(Id, We) ->
    Fs = wings_vertex:fold(fun(_,Face,_,Acc) -> [Face|Acc] end, [], Id, We),
    ordsets:from_list(Fs).

connect_link(CutLine,IdStart,FacesStart,IdEnd,FacesEnd,LC,MM,We0) ->
    Prev = gb_sets:from_list([IdStart,IdEnd]),
    We1 = connect_link1(CutLine,IdStart,FacesStart,IdEnd,FacesEnd,Prev,
			{normal,MM},We0),
    case LC of  %% loop cut
	true ->
%%	    io:format("**********Second**********~n",[]),
	    FsStart = vertex_fs(IdStart,We1),
	    FsEnd   = vertex_fs(IdEnd,We1),
	    connect_link1(CutLine,IdStart,FsStart,IdEnd,FsEnd,Prev,
			  {inverted,MM},We1);
	false ->  We1
    end.
connect_link1(CutLine,IdStart,FacesStart,IdEnd,FacesEnd,Prev0,NMM,We0) ->
%%    io:format("~p cut ~p <=> ~p ~n", [?LINE, IdStart, IdEnd]),
    case connect_done(FacesStart,FacesEnd,Prev0,NMM,We0) of
	{true,LastFace} -> %% Done
	    wings_vertex:connect(LastFace,[IdStart,IdEnd],We0);
	{false,_} ->	    
	    Find = check_possible(CutLine,Prev0,NMM,We0),
	    Cuts = wings_face:fold_faces(Find,[],FacesStart,We0),
	    Selected = select_way(lists:usort(Cuts),We0,NMM),
	    {We1,Id1} = case Selected of
			    {vertex,Id,_Face} ->
				{We0, Id};
			    {edge,Edge,_Face,_,Pos} ->
				wings_edge:fast_cut(Edge, Pos, We0)
			end,
	    Ok = vertex_fs(Id1,We1),
%% 	    io:format("~p ~p of ~p fs ~w~n", [?LINE, Id1, Cuts, Selected]),
%% 	    io:format("~p ~w ~w ~w~n", [?LINE, Ok,FacesStart,ordsets:intersection(Ok,FacesStart)]),
	    [First] = ordsets:intersection(Ok,FacesStart),
	    We = wings_vertex:connect(First,[Id1,IdStart],We1),
	    Prev = gb_sets:insert(Id1, Prev0),
	    connect_link1(CutLine,Id1,Ok,IdEnd,FacesEnd,Prev,NMM,We)
    end.

check_possible(CutLine,Prev,{_,MM},We) ->
    fun(Face, _V, Edge, #edge{vs=Vs,ve=Ve}, Acc) -> 
	    case gb_sets:is_member(Vs,Prev) orelse 
		gb_sets:is_member(Ve,Prev) of
		true -> %% Already used.
		    Acc;
		false ->
		    Edge2D = get_line(Vs,Ve,MM,We),
		    InterRes = line_intersect2d(CutLine,Edge2D),
		    case InterRes of
			{false,{1,Pos2D}} -> 
			    [{edge,Edge,Face,false,
			      pos2Dto3D(Pos2D,Edge2D,Vs,Ve,We)}|Acc];
			{false,_} -> Acc;
			{true, Pos2D} ->
			    [{edge,Edge,Face,true,
			      pos2Dto3D(Pos2D,Edge2D,Vs,Ve,We)}|Acc];
			{{point, 3},_Pos2d} -> 
			    [{vertex,Vs,Face}|Acc];
			{{point, 4},_Pos2d} -> 
			    [{vertex,Ve,Face}|Acc];
			_Else -> 
			    Acc
		    end
	    end	    
    end.

connect_done(End,Start,Prev,MM,We) ->
    First = gb_sets:size(Prev) == 2,
    case ordsets:intersection(Start,End) of
	[LastFace] when First -> %% Done
	    {check_normal(LastFace,MM,We), LastFace};
	[LastFace] -> 
	    {true,LastFace};
	List ->  %% Arrgh imageplane like construction workarounds
	    GoodNormals = [Face || Face <- List, check_normal(Face,MM,We)],
%%	    io:format("~p ~w from ~w~n", [?LINE,GoodNormals,List]),
	    case GoodNormals of
		[Face] -> {true,Face}; 
		_ ->      {false,undefined}
	    end
    end.

select_way([],_,_) -> exit(vertices_are_not_possible_to_connect);
select_way([Cut],_,_) -> Cut;
select_way(Cuts,We,NMM = {Mode,_}) ->     
    Priortize = 
	fun(Cut = {edge,_,Face,Intersect,_}) ->
		FaceScreen = check_normal(Face,NMM,We),
		if 
		    FaceScreen and Intersect ->  {1,Cut};
		    FaceScreen -> {3,Cut};
		    Intersect, Mode == normal ->    {4,Cut};
		    Intersect, Mode == inverted ->  {7,Cut};
		    true ->  {6,Cut}
		end;
	   (Cut = {vertex,_,Face}) ->
		FaceScreen = check_normal(Face,NMM,We),
		if 
		    FaceScreen -> {2,Cut};
		    Mode == inverted -> {8,Cut};
		    true -> {5,Cut}
		end
	end,
    Sorted = lists:sort(lists:map(Priortize, Cuts)),
%%    io:format("~p ~p ~p~n",[?LINE, Mode, Sorted]),
    [{_P,Cut}|_R] = Sorted,
    Cut.

check_normal(Face,{Way,MM},We = #we{id=Id}) ->
    {MVM,_PM,_} = wings_u:get_matrices(Id, MM),
    Normal0 = wings_face:normal(Face,We),
    {_,_,Z} = e3d_mat:mul_vector(list_to_tuple(MVM),Normal0),
    if 
	Way == normal, Z > 0.1 -> true;
	Way == inverted, Z < -0.1 -> true;
	true -> false
    end.

pos2Dto3D({IX,IY}, {V1Sp,V2Sp}, V1,V2,#we{vp=Vs}) ->
    Pos1 = gb_trees:get(V1, Vs),
    Pos2 = gb_trees:get(V2, Vs),
    TotDist = e3d_vec:dist(V1Sp,V2Sp),
    Dist = e3d_vec:dist(V1Sp,{float(IX),float(IY),0.0}) / TotDist,
    Vec = e3d_vec:mul(e3d_vec:sub(Pos2,Pos1),Dist),
    e3d_vec:add(Pos1, Vec).

get_line(V1,V2,MM,#we{id=Id,vp=Vs}) ->
    P1 = gb_trees:get(V1, Vs),
    P2 = gb_trees:get(V2, Vs),
    Matrices = wings_u:get_matrices(Id, MM),
    V1Sp = setelement(3,obj_to_screen(Matrices, P1),0.0),
    V2Sp = setelement(3,obj_to_screen(Matrices, P2),0.0),
    {V1Sp,V2Sp}.

calc_edgepos(X,Y0,Edge,MM,#we{id=Id,es=Es,vp=Vs},VL) ->
    {_,H} = wings_wm:win_size(),
    Y = H-Y0,
    #edge{vs=V1,ve=V2,lf=F1,rf=F2} = gb_trees:get(Edge, Es),
    Pos1 = gb_trees:get(V1, Vs),
    Pos2 = gb_trees:get(V2, Vs),
    Matrices = wings_u:get_matrices(Id, MM),
    V1Sp = setelement(3,obj_to_screen(Matrices, Pos1),0.0),
    V2Sp = setelement(3,obj_to_screen(Matrices, Pos2),0.0),
    Dist = 
	case VL of
	    [] ->
		V1Dist  = e3d_vec:dist(V1Sp,{float(X),float(Y),0.0}),
		V2Dist  = e3d_vec:dist(V2Sp,{float(X),float(Y),0.0}),
		%%TotDist = e3d_vec:dist(V1Sp,V2Sp),
		TotDist = V1Dist+V2Dist,
		V1Dist/TotDist;
	    [#vi{pos=Start0}|_] ->
		Start = setelement(3, obj_to_screen(Matrices, Start0), 0.0),
		{IX,IY} = 
		    case line_intersect2d(Start,{float(X),float(Y),0.0},V1Sp,V2Sp) of
			{false,{_, paralell}} -> exit(paralell);
			{false,{_,IPoint}} -> IPoint;
			{_, IPoint} -> IPoint 
%%%			{{point,_},IPoint} -> IPoint
		    end,
		TotDist = e3d_vec:dist(V1Sp,V2Sp),
		e3d_vec:dist(V1Sp,{float(IX),float(IY),0.0}) / TotDist
	end,
    Vec = e3d_vec:mul(e3d_vec:sub(Pos2,Pos1),Dist),
    Pos = e3d_vec:add(Pos1, Vec),
    {Pos, ordsets:from_list([F1,F2])}.

line_intersect2d({V1,V2},{V3,V4}) ->
    line_intersect2d(V1,V2,V3,V4).
line_intersect2d({X1,Y1,_},{X2,Y2,_},{X3,Y3,_},{X4,Y4,_}) ->
    line_intersect2d({X1,Y1},{X2,Y2},{X3,Y3},{X4,Y4});
line_intersect2d({X1,Y1},{X2,Y2},{X3,Y3},{X4,Y4}) ->
    Div = ((Y4-Y3)*(X2-X1)-(X4-X3)*(Y2-Y1)),
    if Div == 0.0 -> {false,{both,paralell}};
       true ->
	    Ua = ((X4-X3)*(Y1-Y3)-(Y4-Y3)*(X1-X3)) / Div,
	    Ub = ((X2-X1)*(Y1-Y3)-(Y2-Y1)*(X1-X3)) / Div,
	    X = X1 + Ua*(X2-X1),
	    Y = Y1 + Ua*(Y2-Y1),
	    
	    if 
		(Ua < -?EPS); (Ua > 1.0+?EPS) ->
		    if (Ub < -?EPS); (Ub > 1.0+?EPS) -> 
			    {false,{both,{X,Y}}};
		       true -> 
			    {false,{1,{X,Y}}}
		    end;
		(Ub < -?EPS); (Ub > 1.0+?EPS)  ->
		    {false, {2, {X,Y}}};
		(Ua > -?EPS), (Ua < 1.0+?EPS) ->
		    if (Ub > ?EPS), (Ub < 1.0-?EPS) -> {true, {X,Y}};
		       Ub > -?EPS, Ub < ?EPS -> {{point,3},{X,Y}};
		       true -> {{point,4},{X,Y}}
		    end;
		true ->
		    if 
			Ua > -?EPS, Ua < ?EPS -> {{point,1},{X,Y}};
			true -> {{point,2},{X,Y}}
		    end
	    end
    end.

obj_to_screen({MVM,PM,VP}, {X,Y,Z}) ->
    glu:project(X, Y, Z, MVM, PM, VP).

help(Cs = #cs{v=[]}) ->
    Msg1 = wings_msg:button_format(?__(1,"Select vertex or cut edge [press button to slide]")),
    Msg2 = wings_camera:help(),
    Msg3 = wings_msg:button_format([], [], ?__(2,"Exit Connect")),
    Msg = wings_msg:join([Msg1,Msg2,Msg3]),    
    wings_wm:message(Msg, lc_help(Cs));
help(Cs) ->
    Msg1 = wings_msg:button_format(?__(3,"Connects edges/vertices [reselect last vertex to end]")),
    Msg2 = wings_camera:help(),
    Msg3 = wings_msg:button_format([], [], ?__(4,"Exit Connect")),
    Msg = wings_msg:join([Msg1,Msg2,Msg3]),
    wings_wm:message(Msg, lc_help(Cs)).

lc_help(#cs{loop_cut=true}) -> "[1] " ++ ?__(1,"Loop Connect Off");
lc_help(_) ->                  "[1] " ++ ?__(2,"Loop Connect On").

fake_selection(St) ->
    wings_dl:fold(fun(#dlo{src_sel=none}, S) ->
			  %% No selection, try highlighting.
			  fake_sel_1(S);
		     (#dlo{src_we=#we{id=Id},src_sel={Mode,Els}}, S) ->
			  S#st{selmode=Mode,sel=[{Id,Els}]}
		  end, St).

fake_sel_1(St0) ->
    case wings_pref:get_value(use_temp_sel) of
	false -> St0;
	true ->
	    {_,X,Y} = wings_wm:local_mouse_state(),
	    case wings_pick:do_pick(X, Y, St0) of
		{add,_,St} -> St;
		_ -> St0
	    end
    end.

update_hook(#cs{v=[]}) ->
    wings:unregister_postdraw_hook(geom,?MODULE);
update_hook(C) ->
    Hook = fun(_St) -> draw_connect(C) end,
    wings:register_postdraw_hook(geom,?MODULE,Hook).

draw_connect(#cs{v=[#vi{pos=Pos0,mm=MM},#vi{pos=Pos1}],we=Id}) ->
    Matrices = wings_u:get_matrices(Id, MM),
    Pos01 = setelement(3, obj_to_screen(Matrices, Pos0), 0.0),
    Matrices = wings_u:get_matrices(Id, MM),
    Pos11 = setelement(3, obj_to_screen(Matrices, Pos1), 0.0),
    gldraw_connect(Pos01,Pos11);
draw_connect(#cs{v=[#vi{pos=Pos0,mm=MM}],we=Id}) ->
    {_W,H} = wings_wm:win_size(),
    {_,X,Y0} = wings_wm:local_mouse_state(),
    Y = H-Y0,
    Matrices = wings_u:get_matrices(Id, MM),
    Pos = setelement(3, obj_to_screen(Matrices, Pos0), 0.0),
    gldraw_connect(Pos, {X,Y,0.0}).

gldraw_connect(Pos0, Pos1) ->
    {W,H} = wings_wm:win_size(),
    gl:pushAttrib(?GL_ALL_ATTRIB_BITS),
    gl:disable(?GL_LIGHTING),
    gl:disable(?GL_DEPTH_TEST),    
    gl:disable(?GL_ALPHA_TEST),
    gl:color3f(0, 0, 0),
    gl:matrixMode(?GL_PROJECTION),
    gl:loadIdentity(),
    glu:ortho2D(0, W, 0, H),
    gl:matrixMode(?GL_MODELVIEW),
    gl:loadIdentity(),
    gl:'begin'(?GL_LINES),
    gl:vertex3fv(Pos0),
    gl:vertex3fv(Pos1),
    gl:'end'(),
    gl:popAttrib().

slide(C=#cs{st=St=#st{shapes=Sh},we=Shape,v=[#vi{id=Id1,mm=MM}|_]},S,E) ->
    #we{vp=Vtab} = gb_trees:get(Shape, Sh),
    Start0 = gb_trees:get(S, Vtab),
    End0   = gb_trees:get(E, Vtab),
    Curr   = gb_trees:get(Id1, Vtab),
    Matrices = wings_u:get_matrices(Shape, MM),
    P0 = {P0x,P0y,_} = obj_to_screen(Matrices, Start0),
    P1 = {P1x,P1y,_} = obj_to_screen(Matrices, End0),
    %% Decide what's up and down.
    {Dx,Dy,_} = e3d_vec:sub(P1, P0),
    {Start,End} = 
	if 
	    abs(Dx) > abs(Dy), P0x < P1x ->  {Start0,End0};
	    abs(Dx) > abs(Dy) ->             {End0,Start0};
	    P0y < P1y ->  {Start0,End0};
	    true ->       {End0,Start0}
	end,
    {Tvs,Sel,Init} = slide_make_tvs(Id1,Curr,Start,End,Shape,C),
    Units = [{percent,{0.0+2*?EPS,1.0-2*?EPS}}],
    Flags = [{initial,[Init]}],
    wings_drag:setup(Tvs, Units, Flags, wings_sel:set(vertex, Sel, St)).

slide_make_tvs(V,Curr,Start,End,Id,C) ->
    Dir = e3d_vec:sub(End, Start),
    TotDist = e3d_vec:len(Dir),
    Dist = e3d_vec:dist(Start,Curr),
    CursorPos  = Dist/TotDist,
    
    Fun = fun(I,Acc) -> sliding(I, Acc, V, Start, Dir, C) end,
    Sel = [{Id,gb_sets:singleton(V)}],
    {[{Id,{[V],Fun}}],Sel,CursorPos}.

sliding([Dx|_],Acc,V,Start,Dir,C= #cs{v=[Vi|Vr]}) ->
    Pos = e3d_vec:add_prod(Start, Dir, Dx),
    if Vr == [] -> ignore; %% No line when sliding single vertex
       true -> update_hook(C#cs{v=[Vi#vi{pos=Pos}|Vr]})
    end,
    [{V,Pos}|Acc].
