%%
%%  wings_s.erl --
%%
%%     Common text strings.
%%
%%  Copyright (c) 2004 Bjorn Gustavsson
%%
%%  See the file "license.terms" for information on usage and redistribution
%%  of this file, and for a DISCLAIMER OF ALL WARRANTIES.
%%
%%     $Id: wings_s.erl,v 1.5 2004/10/16 12:22:04 bjorng Exp $
%%

-module(wings_s).
-export([yes/0,no/0,cancel/0,accept/0,
	 lmb/0,mmb/0,rmb/0,
	 modkey/1,shift/0,ctrl/0,alt/0,command/0,
	 key/1,dir/1,dir_axis/1,
	 camera_mode/1]).

-include("wings.hrl").

yes() -> ?STR(yes,1,"Yes").
no() -> ?STR(no,1,"No").
cancel() -> ?STR(cancel,1,"Cancel").
accept() -> ?STR(accept,1,"Accept").
    
%% Mouse buttons.
lmb() -> ?STR(mouse_b,l,"L").
mmb() -> ?STR(mouse_b,m,"M").
rmb() -> ?STR(mouse_b,r,"R").

%% Modifier keys.
shift() ->   ?STR(mod,shift,"Shift").
ctrl() ->    ?STR(mod,ctrl,"Ctrl").
alt() ->     ?STR(mod,alt,"Alt").
command() -> ?STR(mod,command,"Command").		%Command key on Mac.

modkey(shift) -> shift();
modkey(ctrl) -> ctrl();
modkey(alt) -> alt();
modkey(command) -> command().

%% Returns key name within square brackets.
key(Key) -> [$[,key_1(Key),$]].

key_1(shift) -> shift();
key_1(ctrl) -> ctrl();
key_1(alt) -> alt();
key_1(command) -> command();
key_1(Key) when is_atom(Key) -> atom_to_list(Key);
key_1(Key) when is_list(Key) -> Key.

%% All directions.        
dir(x) -> ?STR(dir,x,"X");
dir(y) -> ?STR(dir,y,"Y");
dir(z) -> ?STR(dir,z,"Z");
dir(all) -> ?STR(dir,all,"All");
dir(last_axis) -> ?STR(dir,la,"last axis");
dir(default_axis) -> ?STR(dir,da,"default axis");
dir(normal) -> ?STR(dir,n,"Normal");
dir(free) ->  ?STR(dir,f,"Free");
dir(uniform) ->  ?STR(dir,u,"Uniform");
dir({radial,Axis}) ->  ?STR(dir,r,"Radial") ++ " " ++ dir(Axis);
dir(radial_x) ->  ?STR(dir,r,"Radial") ++ " " ++ dir(x);
dir(radial_y) ->  ?STR(dir,r,"Radial") ++ " " ++ dir(y);
dir(radial_z) ->  ?STR(dir,r,"Radial") ++ " " ++ dir(z).

dir_axis(Axis) -> 
    io_lib:format(?STR(dir,the_axis,"the ~s axis"), [dir(Axis)]).

%% Camera modes; probably don't need to be translated, but could
%% need to be transliterad for languages with non-Latin alphabets.
camera_mode(blender) -> ?STR(camera_mode,blender,"Blender");
camera_mode(nendo) -> ?STR(camera_mode,nendo,"Nendo");
camera_mode(mirai) -> ?STR(camera_mode,mirai,"Mirai");
camera_mode(tds) -> ?STR(camera_mode,tds,"3ds max");
camera_mode(maya) -> ?STR(camera_mode,maya,"Maya");
camera_mode(mb) -> ?STR(camera_mode,mb,"Motionbuilder").
