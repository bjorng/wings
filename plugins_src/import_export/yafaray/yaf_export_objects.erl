%%
%%  yaf_export_objects.erl
%%
%%  YafaRay Export Geometry.
%%
%%  Copyright (c) 2003-2008 Raimo Niskanen
%%  Code Converted from Yafray to YafaRay by Bernard Oortman (Wings3d user oort)
%%  Meshlight Export Perfected with Assistance from Micheus
%%  See the file "license.terms" for information on usage and redistribution
%%  of this file, and for a DISCLAIMER OF ALL WARRANTIES.
%%
%%

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

    Meshlight_Double_Sided =
        proplists:get_value(meshlight_double_sided, YafaRay, ?DEF_MESHLIGHT_DOUBLE_SIDED),
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
    %% povman : is need triangulate mesh? atm, yafaray support rectangles []
    io:format(?__(3,"Mesh ~s: triangulating..."), [NameStr]),
    #e3d_mesh{fs=Fs,vs=Vs,vc=Vc,tx=Tx} = e3d_mesh:triangulate(Mesh1),
    io:format(?__(4,"done")++"~n"),
    io:format(?__(5,"Mesh ~s: exporting..."), [NameStr]),
    %%
    %% Add Export Object Name Start

    println(F, "<!--Object Name ~s, Object # ~w-->", [NameStr,Id]),

    HasUV = case Tx of
                []-> "false";
                _ ->
                "true"
        end,

    case Object_Type of
        mesh ->
            println(F,
                "\n<mesh id=\"~w\" vertices=\"~w\" faces=\"~w\" has_uv=\"~s\" type=\"0\">",
                [Id, length(Vs), length(Fs), HasUV]);

        volume ->
            println(F,
                "\n<volumeregion name=\"volumename\">"),

            case proplists:get_value(volume_type, YafaRay, ?DEF_VOLUME_TYPE) of

                uniformvolume ->
                    println(F, "\t<type sval=\"UniformVolume\"/>");

                expdensityvolume ->
                    println(F,
                        "\t<type sval=\"ExpDensityVolume\"/>\n"
                        "\t<a fval=\"~.10f\"/>\n"
                        "\t<b fval=\"~.10f\"/>",
                        [Volume_Height, Volume_Steepness]);

                noisevolume ->
                    println(F,
                        "\t<type sval=\"NoiseVolume\"/>\n"
                        "\t<sharpness fval=\"~.10f\"/>\n"
                        "\t<cover fval=\"~.10f\"/>\n"
                        "\t<density fval=\"~.10f\"/>"
                        "\t<texture sval=\"TEmytex\"/>",
                        [Volume_Sharpness, Volume_Cover, Volume_Density])
            end,

            println(F, "\t<attgridScale ival=\"~w\"/>",[Volume_Attgridscale]),
            println(F, "\t<maxX fval=\"~.10f\"/>",[Volume_Minmax_Z]),
            println(F, "\t<maxY fval=\"~.10f\"/>",[Volume_Minmax_X]),
            println(F, "\t<maxZ fval=\"~.10f\"/>",[Volume_Minmax_Y]),
            println(F, "\t<minX fval=\"-\~.10f\"/>",[Volume_Minmax_Z]),
            println(F, "\t<minY fval=\"-\~.10f\"/>",[Volume_Minmax_X]),
            println(F, "\t<minZ fval=\"-\~.10f\"/>",[Volume_Minmax_Y]),
            println(F, "\t<sigma_a fval=\"~.10f\"/>",[Volume_Sigma_a]),
            println(F, "\t<sigma_s fval=\"~.10f\"/>",[Volume_Sigma_s]),
            println(F," ");

        meshlight ->
            println(F,"\n<light name=\"~s\">",[NameStr]),

            export_rgb(F, color, proplists:get_value(meshlight_color, YafaRay, Meshlight_Color)),
%%
            println(F, "\t<object ival= \"~w\"/>",[Id]),
            println(F, "\t<power fval=\"~.10f\"/>",[Meshlight_Power]),
            println(F, "\t<samples ival=\"~w\"/>",[Meshlight_Samples]),
            println(F, "\t<double_sided bval=\"~s\"/>",[Meshlight_Double_Sided]),
            println(F, "\t<type sval=\"~s\"/>",[Object_Type]),
            println(F, "</light>"),
            println(F, "<mesh id=\"~w\" type=\"0\">",[Id])
    end,

    export_vertices(F, Vs),

    %% Add Export UV_Vectors Part 1 Start
    case HasUV of
        "false" ->
            ok;
        "true" ->
            println(F,
                "\n<!--uv_vectors Quantity=\"~w\" -->\n",[length(Tx)]),
            export_vectors2D(F, Tx)
    end,

    %% Add Export UV_Vectors Part 1 End

    export_faces(F, Fs, DefaultMaterial, list_to_tuple(Tx), list_to_tuple(Vc)),

    case Object_Type of

        mesh ->
            println(F, "\n</mesh>\n");

        volume ->
            println(F, "\n</volumeregion>\n");

        meshlight ->
            println(F, "\n</mesh>\n")
    end,

    case Autosmooth of
        false ->
            println(F, "");
        true ->
            println(F, "<smooth ID=\"~w\" angle=\"~.3f\"/>", [Id, AutosmoothAngle])
    end,

    io:format(?__(6,"done")++"~n").


export_vertices(_F, []) ->
    ok;
export_vertices(F, [Pos|T]) ->
    export_pos(F, p, Pos),
    %export_pov(F, p, Pos), % povman test
    export_vertices(F, T).

%% The coordinate system is rotated to make sunsky background
%% and environment images work as expected.
%% It assumes `South Y=East Z=Up in YafaRay coordinates.
%% Hence Z=South, X=East, Y=Up in Wings coordinates.
%%
export_pos(F, Type, {X,Y,Z}) ->
    println(F,
        ["\t<",format(Type)," x=\"",format(Z),"\" y=\"",format(X),"\" z=\"",format(Y),"\"/>"]).
%% povman test
%export_pov(F, Type, {X,Y,Z}) ->
%    println(F,
%        ["<!-- <",format(Type)," x=\"",format(Z),"\" y=\"",format(X),"\" z=\"",format(Y),"\"/> -->"]).
%% end test
%%Add Export UV_Vectors Part 2 Start

export_vectors2D(_F, [])->
        ok;

export_vectors2D(F, [{X, Y} | List])->
        println(F,
            "\t<uv u=\"~f\" v=\"~f\"/>", [X, Y]),
        export_vectors2D(F, List).

%%Add Export UV_Vectors Part 2 End

export_faces(_F, [], _DefMat, _TxT, _VColT) ->
    ok;

export_faces(F,
            [#e3d_face{mat=[Mat|_], tx=Tx, vs=[A,B,C]}|T],
            %[#e3d_face{mat=[Mat|_], tx=Tx, vs=[A,B,C], vc=VCols}|T],
            DefaultMaterial, TxT, VColT) ->

    Shader =
        case Mat of
            DefaultMaterial -> ["\t<set_material sval=\"w_",format(Mat),"\"/>\n"];
                    _ -> ["\t<set_material sval=\"w_",format(Mat),"\"/>\n"]
        end,

        UVIndices = case Tx of
            []-> "/>"; % povman : fix for not write un-necesary code " uv_a=\"0\" uv_b=\"0\" uv_c=\"0\"/>";
            _ ->
                {U, V, W} = list_to_tuple(Tx),
        (io_lib:format(" uv_a=\"~w\" uv_b=\"~w\" uv_c=\"~w\"/>", [U, V, W]))

        end,

    %% there is old code from Yafray, atm is unused in 0.1.2
    %% is more better, used face groups for multimaterial.
    %VCol =
    %    case {VColT,VCols} of
    %        {{},[]} -> "";
    %        {{},_} ->
    %            io:format(?__(3,"WARNING! Face refers to non-existing vertex colors")++"~n"),
    %                "";
    %        {_,[]} ->
    %            %%io:format("WARNING! Face missing vertex colors~n"),
    %            "";
    %        {_,[VcA,VcB,VcC]} ->
    %            {VcAr,VcAg,VcAb} = element(1+VcA, VColT),
    %            {VcBr,VcBg,VcBb} = element(1+VcB, VColT),
    %            {VcCr,VcCg,VcCb} = element(1+VcC, VColT),
    %            [io_lib:nl(),"           vcol_a_r=\"",format(VcAr),
    %            "\" vcol_a_g=\"",format(VcAg),
    %            "\" vcol_a_b=\"",format(VcAb),"\"",
    %            io_lib:nl(),"           vcol_b_r=\"",format(VcBr),
    %            "\" vcol_b_g=\"",format(VcBg),
    %            "\" vcol_b_b=\"",format(VcBb),"\"",
    %            io_lib:nl(),"           vcol_c_r=\"",format(VcCr),
    %            "\" vcol_c_g=\"",format(VcCg),
    %            "\" vcol_c_b=\"",format(VcCb),"\""];
    %        _ ->
    %            io:format(?__(4,"WARNING! Face has ~w =/= 3 vertex colors")++"~n",
    %                        [length(VCols)]),
    %                ""
    %    end,

    println(F, [Shader, "\t<f a=\"",format(A), "\" b=\"",format(B),
                "\" c=\"",format(C),"\"", UVIndices]), %, VCol]),

    export_faces(F, T, DefaultMaterial, TxT, VColT).
