%%
%%  wpc_intersect_edge.erl --
%%
%%     Plug-in for extending an edge to the intersection with a plane.
%%
%%  Copyright (c) 2004 Bjorn Gustavsson.
%%
%%  See the file "license.terms" for information on usage and redistribution
%%  of this file, and for a DISCLAIMER OF ALL WARRANTIES.
%%
%%  Contributed by elrond79.
%%
%%     $Id: wpc_intersect_edge.erl,v 1.4 2005/10/04 20:31:15 giniu Exp $
%%
%%  2000-10-09:  Fixed undo bug (had forgotten to use "{save_state, ...}")
%%  2000-10-01:  Incorporated help text suggestions from Puzzled Paul
%%  2000-09-21:  Normalized line direction (so lineDotPlane dependant only on
%%               angle, not size of LD vector)
%%  2000-09-17:  Tried to make more compliant w/ wings API (Paul Molodowitch)
%%  2000-09-17:  Allowed more than one edge per body (though none can share
%%               verts) and changed method for choosing which vert to move

-module(wpc_intersect_edge).

-export([init/0,menu/2,command/2]).

-include_lib("wpc_intersect.hrl").
-import(lists, [splitwith/2,member/2]).

init() ->
    true.


menu({edge}, Menu) ->
    Menu ++ [separator,menu_item()];
menu(_,Menu) -> Menu.

command({edge,{intersect,Plane}},St) ->
    intersect(Plane, St);
command(_,_) -> next.


%% creates the menu item for the edge intersect command.

menu_item() ->
    {?__(1,"Intersect"),{intersect,fun submenu/2}}.

submenu(help, _) ->
    {?__(1,"Intersect std. planes"),
     ?__(2,"Pick plane and ref point on plane"),
     ?__(3,"Pick plane")};
submenu(1, _) ->
    [standard_planes_menu()];
submenu(2, Ns) ->
    wings_menu:build_command({'ASK',{[{axis,  ?__(4,"Pick axis perpendicular to plane")},
				      {point, ?__(5,"Pick point for plane to pass through")}],[],[]}}, Ns);
submenu(3, Ns) ->
    wings_menu:build_command({'ASK',{[{axis_point, ?__(6,"Pick axis perpendicular to plane (plane will pass through axis's base)")}],[],[]}}, Ns).

standard_planes_menu() ->
    [standard_plane_fun(x),
     standard_plane_fun(y),
     standard_plane_fun(z),
     {advanced,separator},
     {advanced,standard_plane_fun(last_axis)},
     {advanced,standard_plane_fun(default_axis)}].

standard_plane_fun(Vec) ->
    F = fun(1, Ns) ->
		wings_menu:build_command(Vec, Ns);
	   (2, _Ns) ->
		ignore;
	   (3, Ns) ->
		wings_menu:build_command({'ASK',{[point],[Vec]}}, Ns)
	end,
    VecString = intl_vec(Vec),
    if
	Vec == last_axis; Vec == default_axis ->
	    Help0 = ?__(1,"Intersect edge with plane defined by the")++" " ++ VecString;
	true ->
	    PlaneString = case Vec of
			      x -> "YZ";
			      y -> "XZ";
			      z -> "XY"
			  end,
	    Help0 = ?__(2,"Intersect edge with the")++" " ++ PlaneString ++ " "++?__(3,"plane")
    end,
    Help = {Help0,[],?__(4,"Pick point on plane")},
    {wings_util:cap(VecString),F,Help,[]}.

intl_vec(last_axis)    -> ?__(1,"last axis");
intl_vec(default_axis) -> ?__(2,"default axis");
intl_vec(Vec)          -> wings_util:stringify(Vec).

%%%
%%% The edge Intersect command.
%%%

intersect({'ASK',Ask}, St) ->
    wings:ask(Ask, St, fun intersect/2);
intersect({Plane,Center}, St) ->
    intersect(Plane, Center, St);
intersect(Plane, St) when Plane == last_axis; Plane == default_axis ->
    {Center, Normal} = wings_pref:get_value(Plane),
    intersect(Normal, Center, St);
intersect(Plane, St) ->
    intersect(Plane, origin, St).

intersect(Plane, origin, St) ->
    intersect(Plane, {0.0,0.0,0.0}, St);
intersect(Plane0, Center, St) ->
    Plane = e3d_vec:norm(wings_util:make_vector(Plane0)),
    ValidSelection = wpa:sel_fold(fun validateSel/3, valid, St),
    case ValidSelection of
	valid ->
	    {save_state,
	     wpa:sel_map(
	       fun(Es, We) ->
		       intersect_body(Es, Plane, Center, We)
	       end, St)};
	invalid ->
	    wpa:error(?__(1,"Selected edges may not share any vertices")),
	    keep
    end.

validateSel(Edges, We, valid) when is_list(Edges) ->
    validateSelAcc(Edges, We#we.es, []);
validateSel(Edges, We, valid) ->
    validateSel(gb_sets:to_list(Edges), We, valid);
validateSel(_Edges, _We, invalid) ->
    invalid.
    
validateSelAcc(_SelectedEdges,_EdgeTab,invalid) ->
    invalid;
validateSelAcc([],_,_VertexAcc)->
    valid;
validateSelAcc([SelEdge|OtherSelEdges], EdgeTab, VertexAcc) ->
    #edge{vs=V1,ve=V2} = gb_trees:get(SelEdge,EdgeTab),
    InTable = member(V1,VertexAcc) orelse member(V2,VertexAcc),
    case InTable of
	true ->
	    invalid;
	false ->
	    validateSelAcc(OtherSelEdges, EdgeTab, [V1,V2|VertexAcc])
    end.


intersect_body(Edges, Plane, Center, #we{es=EdgeTab,vp=VertPosTab0}=We0) when is_list(Edges) ->
    VertPosTab = intersect_edges(Plane, Center, EdgeTab, VertPosTab0, Edges),
    We = We0#we{vp = VertPosTab},
    wings_we:mirror_flatten(We0, We);
intersect_body(Edges, Plane, Center, We) ->
    intersect_body(gb_sets:to_list(Edges), Plane, Center, We).

intersect_edges(_Plane,_Center,_EdgeTab,VertPosTab,[]) ->
    VertPosTab;
intersect_edges(Plane,Center,EdgeTab,VertPosTab0,[EdgeNum|OtherEdgeNums]) ->
    #edge{vs=V1Num,ve=V2Num}=gb_trees:get(EdgeNum,EdgeTab),
    V1 = gb_trees:get(V1Num,VertPosTab0),
    V2 = gb_trees:get(V2Num,VertPosTab0),
    V1V2 = e3d_vec:norm_sub(V2,V1),
    LineDotPlane = e3d_vec:dot(V1V2,Plane),
    if
	abs(LineDotPlane) < 0.001 ->
	    wpa:error(?__(1,"Line and plane are nearly parallel:\n"
			       "can't find intersection.")),
	    VertPosTab = VertPosTab0;
	true ->
	    %% First, see if V1 and V2 are on same side of plane;
	    %% if so, move the closer one.
	    CenterV1 = e3d_vec:sub(V1,Center),
	    CenterV2 = e3d_vec:sub(V2,Center),

	    V1Dist = e3d_vec:dot(CenterV1,Plane),
	    V2Dist = e3d_vec:dot(CenterV2,Plane),
	    
	    %% If the distances have the same sign, means on same side;
	    if
		V1Dist * V2Dist >= 0 ->
		    if
			abs(V1Dist) < abs(V2Dist) ->
			    VToMove = V1Num;
			true ->
			    VToMove = V2Num
		    end;
		true ->
		    %% If they are on opposite sides, move the one on
		    %% the opposite side of the normal.
		    if 
			V1Dist > V2Dist ->
			    VToMove = V2Num;
			true ->
			    VToMove = V1Num
		    end
	    end,
	    
	    IntersectData = #intersect_data{lineDir = V1V2, linePoint = V1,
					   planeNorm = Plane, planePoint = Center,
					   lineDotPlane = LineDotPlane},
	    VertPosTab = wpc_intersect_vertex:intersect_vertex(VToMove, VertPosTab0, IntersectData)
    end,
    intersect_edges(Plane,Center,EdgeTab,VertPosTab,OtherEdgeNums).
