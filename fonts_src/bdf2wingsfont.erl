%%
%%  bdf2wingsfont.erl --
%%
%%     Conversion of BDF fonts to Wings' own font format.
%%
%%  Copyright (c) 2005 Bjorn Gustavsson
%%
%%  See the file "license.terms" for information on usage and redistribution
%%  of this file, and for a DISCLAIMER OF ALL WARRANTIES.
%%
%%     $Id: bdf2wingsfont.erl,v 1.1 2005/04/04 13:59:25 bjorng Exp $
%%

-module(bdf2wingsfont).
-export([convert/1]).

-import(lists, [reverse/1,sort/1]).

-record(glyph,
	{code,					%Unicode for glyph.
	 bbx,					%Bounding box.
	 dwidth,				%Width.
	 bitmap}).

convert([Out|SrcFonts]) ->
    G = read_fonts(SrcFonts, []),
    io:format("Output file: ~s\n", [Out]),
    write_font(G, Out),
    init:stop().

read_fonts([N|Ns], Acc) ->
    io:format("Reading ~s\n", [N]),
    {ok,F} = file:open(N, [read,read_ahead]),
    G = read_font(F),
    file:close(F),
    read_fonts(Ns, G++Acc);
read_fonts([], Acc) ->
    sort(Acc).

read_font(F) ->
    case read_line(F) of
	["STARTFONT","2.1"] ->
	    Ps = read_props(F),
	    io:format("~p\n", [Ps]),
	    G = read_font_glyphs(F),
	    to_unicode(G, Ps);
	Other ->
	    io:format("~p\n", [Other]),
	    error(invalid_bdf_file)
    end.

read_props(F) ->
    case read_line(F) of
	["STARTPROPERTIES",N0] ->
	    N = list_to_integer(N0),
	    read_props_1(F, N, []);
	_ ->
	    read_props(F)
    end.

read_props_1(_, 0, Acc) -> Acc;
read_props_1(F, N, Acc) ->
    P = read_one_prop(F),
    read_props_1(F, N-1, [P|Acc]).

read_one_prop(F) ->
    read_one_prop_1(io:get_line(F, ''), []).

read_one_prop_1([C|Cs], Key) when C =< $\s ->
    read_one_prop_2(Cs, reverse(Key));
read_one_prop_1([C|Cs], Key) ->
    read_one_prop_1(Cs, [C|Key]).

read_one_prop_2([C|Cs], Key) when C =< $\s ->
    read_one_prop_2(Cs, Key);
read_one_prop_2(Cs, Key) ->
    Val0 = reverse(skip_whitespace(reverse(Cs))),
    Val = convert_val(Val0),
    {Key,Val}.

convert_val("\""++Str0) ->
    "\""++Str = reverse(Str0),
    reverse(Str);
convert_val(Str) ->
    list_to_integer(Str).

read_font_glyphs(F) ->
    case read_line(F) of
	["CHARS",N0] ->
	    N = list_to_integer(N0),
	    read_font_glyphs(F, N, []);
	_ ->
	    read_font_glyphs(F)
    end.

read_font_glyphs(_, 0, Acc) -> Acc;
read_font_glyphs(F, N, Acc) ->
    case read_line(F) of
	["STARTCHAR"|_] ->
	    G = read_one_glyph(F),
	    read_font_glyphs(F, N-1, [G|Acc])
    end.

read_one_glyph(F) ->
    read_one_glyph_1(F, #glyph{}).

read_one_glyph_1(F, G) ->
    case read_line(F) of
	["ENCODING",Code0] ->
	    Code = list_to_integer(Code0),
	    read_one_glyph_1(F, G#glyph{code=Code});
	["DWIDTH"|Ints] ->
	    Dwidth = [list_to_integer(S) || S <- Ints],
	    read_one_glyph_1(F, G#glyph{dwidth=Dwidth});
	["BBX"|Ints] ->
	    BBx = [list_to_integer(S) || S <- Ints],
	    read_one_glyph_1(F, G#glyph{bbx=BBx});
	["SWIDTH"|_] ->
	    read_one_glyph_1(F, G);
	["BITMAP"] ->
	    Bitmap = read_bitmap(F, []),
	    G#glyph{bitmap=Bitmap}
    end.
    
read_bitmap(F, Acc) ->
    case read_line(F) of
	["ENDCHAR"] ->
	    list_to_binary(Acc);
	[Hex0] ->
	    {ok,[Hex],[]} = io_lib:fread("~16u", Hex0),
	    read_bitmap(F, [Hex|Acc])
    end.

to_unicode(Gs, Ps) ->
    "ISO8859" = proplists:get_value("CHARSET_REGISTRY", Ps),
    case proplists:get_value("CHARSET_ENCODING", Ps) of
	"1" -> Gs;
	"-"++Enc ->
	    to_unicode_1(Gs, "map-ISO8859-"++Enc);
	Enc ->
	    to_unicode_1(Gs, "map-ISO8859-"++Enc)
    end.

to_unicode_1(Gs, MapName) ->
    Map = read_map(MapName),
    [G#glyph{code=gb_trees:get(C, Map)} || #glyph{code=C}=G <- Gs].

read_map(MapName) ->
    {ok,F} = file:open(MapName, [read,read_ahead]),
    Map = read_map_1(F, []),
    file:close(F),
    Map.

read_map_1(F, Acc) ->
    case read_map_line(F) of
	eof ->
	    gb_trees:from_orddict(orddict:from_list(Acc));
	["0x"++From0,"0x"++To0|_] ->
	    {ok,[From],[]} = io_lib:fread("~16u", From0),
	    {ok,[To],[]} = io_lib:fread("~16u", To0),
	    read_map_1(F, [{From,To}|Acc])
    end.

error(Term) ->
    throw({error,Term}).

read_map_line(F) ->
    case skip_whitespace(io:get_line(F, '')) of
	eof -> eof;
	"#"++_ -> read_map_line(F);
	Cs -> collect_tokens(Cs)
    end.

read_line(F) ->
    case read_line_1(io:get_line(F, ''), F) of
	["COMMENT"|_] -> read_line(F);
	Line -> Line
    end.

read_line_1(eof, _) ->
    error(eof);
read_line_1([], Fd) ->
    %% Blank line - ignore and read the next line.
    read_line(Fd);
read_line_1([Ctrl|Line], Fd) when Ctrl =< $\s ->
    %% Ignore any leading whitespace (especially TAB and spaces).
    read_line_1(Line, Fd);
read_line_1(Line, _) ->
    collect_tokens(Line).

collect_tokens(Line) ->
    collect_tokens_1(Line, [], []).

collect_tokens_1([C|T], [], Tokens) when C =< $\s ->
    collect_tokens_1(T, [], Tokens);
collect_tokens_1([C|T], Curr, Tokens) when C =< $\s ->
    collect_tokens_1(T, [], [reverse(Curr)|Tokens]);
collect_tokens_1([H|T], Curr, Tokens) ->
    collect_tokens_1(T, [H|Curr], Tokens);
collect_tokens_1([], [], Tokens) ->
    reverse(Tokens);
collect_tokens_1([], Curr, Tokens) ->
    collect_tokens_1([], [], [reverse(Curr)|Tokens]).

skip_whitespace([C|Cs]) when C =< $\s ->    
    skip_whitespace(Cs);
skip_whitespace(Cs) -> Cs.

write_font(G, Out) ->
    Term = write_font_1(G, 0, [], []),
    Bin = term_to_binary(Term, [compressed]),
    file:write_file(Out, Bin),
    ok.

write_font_1([#glyph{code=C,bbx=BBx,dwidth=Dwidth,bitmap=B}|Gs],
	     Offset, GlAcc, BiAcc) ->
    [W,H,Xorig,Yorig] = BBx,
    [Xmove,0] = Dwidth,
    G = {C,W,H,-Xorig,-Yorig,Xmove,Offset},
    write_font_1(Gs, Offset+size(B), [G|GlAcc], [B|BiAcc]);
write_font_1([], _, GlAcc, BiAcc) ->
    Desc = "Small (6x11)",
    Font = {Desc,6,11,reverse(GlAcc),list_to_binary(reverse(BiAcc))},
    {wings_font,?wings_version,Font}.