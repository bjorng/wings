%%
%%
%%  diffuse modulator

% export_modulator(F, [Name,$_,format(N)], Maps, M, Opacity)
%
export_modulator(F, Texname, Maps, {modulator,Ps}, Opacity) when is_list(Ps) ->

    case mod_enabled_mode_type(Ps, Maps) of

        {false,_,_} ->
            off;
        {true, BlendMode, TexType} ->

            Diffuse = proplists:get_value(mod_factor, Ps, ?DEF_MOD_FACTOR),
            _Specular = proplists:get_value(specular, Ps, ?DEF_MOD_SPECULAR),
            Ambient = proplists:get_value(ambient, Ps, ?DEF_MOD_AMBIENT),
            Shininess = proplists:get_value(shininess, Ps, ?DEF_MOD_SHININESS),
            _Color = Diffuse * Opacity,
            _HardValue = Shininess,
            _Transmission = Diffuse * (1.0 - Opacity),
            _Reflection = Ambient,

            ModShaderType = proplists:get_value(mod_shader_type, Ps, ?DEF_MOD_SHADER_TYPE),
            erlang:display("Modulator. Shader used is: "++format(ModShaderType)), %-------------->

            %% Identify Modulator # (w_default_Name_1 or w_default_Name_2)

            Split=re:split(Texname,"_",[{return, list}]),

            Num=lists:last(Split),

            % different types for each shader
            % TODO: esto deberia escribirse en cada material. Cada material, tiene unos shaders especificos.
            %
            {ShaderType,DoColor}=
                case ModShaderType of
                    diff ->     {"\t<diffuse_shader sval=\""++Texname++"\"/>", true};
                    raymirr ->  {"\t<mirror_shader sval=\""++Texname++"\"/>", false};
                    transp ->   {"\t<transparency_shader sval=\""++Texname++"\"/>", false};
                    translu ->  {"\t<translucency_shader sval=\""++Texname++"\"/>", false};
                    mirr ->     {"\t<mirror_color_shader sval=\""++Texname++"\"/>", true};
                    spec ->     {"\t<glossy_reflect_shader sval=\""++Texname++"\"/>", true};
                    colspec ->  {"\t<glossy_shader sval=\""++Texname++"\"/>", true};
                    bump ->     {"\t<bump_shader sval=\""++Texname++"\"/>", false};

                    _ -> {"\t<diffuse_shader sval=\""++Texname++"\"/>",false}
                end,
            %
            _ShaderName =
                case {Num, BlendMode} of
                        {"1",_} ->   "  "++ShaderType++" sval=\""++Texname++"\"/>";
                        {_,mix} ->   "  "++ShaderType++" sval=\""++Texname++"\"/>";
                        _ -> ""
                end,

            %% write shader type. TODO: search better way..
            println(F, ShaderType),

            %% entrie to element shader list
            println(F,"\t<list_element>"),

            %% shader factor amount controled with 'Factor Modulator' slider in UI
            Factor = proplists:get_value(mod_factor, Ps, ?DEF_MOD_FACTOR),
            %% Try use value or color
            FactorType =
                case DoColor of
                    true -> "colfac";
                    _ ->    "valfac"
                end,
            %
            println(F,"\t\t<~s fval=\"~w\"/>",[FactorType,Factor]),
            %
            CellType = proplists:get_value(cell_type, Ps, ?DEF_MOD_CELLTYPE),
            %%--------------------------->
            erlang:display("Texture type is :"++TexType),

            IsColor =
                case TexType of
                    image -> true;
                    {map,_} -> true;
                    voronoi -> case CellType of
                                    intensity -> true;
                                    _ -> false
                                end;
                    _ -> false
                end,

            println(F,"\t\t<color_input bval=\"~s\"/>",[IsColor]),

            % def color for 'blended' by default
            println(F,"\t\t<def_col r=\"0.81\" g=\"0.8\" b=\"0.81\" a=\"1\"/>"),
            %
            println(F,"\t\t<def_val fval=\"1\"/>"),

            % swich to use texture values
            %
            println(F,"\t\t<do_color bval=\"~s\"/>",[DoColor]),
            %
            println(F,"\t\t<do_scalar bval=\"~s\"/>",[not DoColor]),
            %
            println(F,"\t\t<element sval=\"shader_node\"/>"),
            %
            println(F,"\t\t<input sval=\"~s_mod\"/>",[Texname]),
            %
            erlang:display("BlendMode for Modenumber "++format(BlendMode)),
            ModeNumber =
                case BlendMode of
                    mix -> "0"; add -> "1"; mul -> "2"; sub -> "3"; scr -> "4";
                    divide -> "5"; dif -> "6"; dar -> "7"; lig -> "8";
                    _ -> ""
                end,
            println(F, "\t\t<mode ival=\"~s\"/>",[ModeNumber]),
            %
            println(F, "\t\t<name sval=\"~s\"/>",[Texname]),
            %
            println(F, "\t\t<noRGB bval=\"false\"/>"),
            %
            println(F, "\t\t<stencil bval=\"false\"/>"),

            % for layers, is need 'stencil' param and more review code.. :)
            %%
            _UpperColor =
                case Num of
                        "1" ->  "<upper_color r=\"1\" g=\"1\" b=\"1\" a=\"1\"/>";
                        _ -> ""
                end,

            %%% Change Number from Texname for UpperLayer
            _ULayerName =
                case ModShaderType of % TODO: change for stencil mode
                        stencil ->
                            re:replace(Texname,"_2","_1",[global]);
                        _->
                            re:replace(Texname,"_1","_2",[global])
                end,
            %UpperLayer =
            %    case {Num, BlendMode, ModShaderType} of
            %            {"1",mix,_} ->  "";
            %            {"1",_,_} ->  UlayerName;
            %            {"2",_,stencil} -> UlayerName;
            %            _ -> ""
            %    end,

            Ulayer = "",
            %
            case Ulayer of
                "" -> case DoColor of
                            true -> println(F,
                                        "\t\t<upper_color r=\"1\" g=\"1\" b=\"1\" a=\"1\"/>\n"
                                        "\t\t<upper_value fval=\"0\"/>");
                            false -> println(F,
                                        "\t\t<upper_color r=\"0\" g=\"0\" b=\"0\" a=\"1\"/>\n" % alpha = 1 ??
                                        "\t\t<upper_value fval=\"~w\"/>",[Factor])
                        end;
                _ ->
                    println(F,"\t\t<upper_layer sval=\"~s\"/>",[Ulayer])
            end,

            %% for layers, is need te 'stencil' and more review code.. :)
            %if ulayer == "":
            %    if do_color:
            %       yi.paramsSetColor("upper_color", dcol[0], dcol[1], dcol[2])
            %       yi.paramsSetFloat("upper_value", 0)
            %   else:
            %       yi.paramsSetColor("upper_color", 0, 0, 0)
            %       yi.paramsSetFloat("upper_value", dcol[0])
            %else:
            %   yi.paramsSetString("upper_layer", ulayer)
            %
            println(F, "\t\t<type sval=\"layer\"/>"),

            % TODO: Atm, use IsColor value, but need review
            println(F, "\t\t<use_alpha bval=\"~s\"/>",[IsColor]),

            % close list element shader
            println(F, "\t</list_element>"),

            %%%-------------------------------->
            % open list element for mapper
            %
            println(F, "\t<list_element>\n"
                "\t\t<element sval=\"shader_node\"/>"),

            % projection mapping coordinates type
            MappingType = proplists:get_value(projection, Ps, ?DEF_PROJECTION),

            println(F, "\t\t<mapping sval=\"~s\"/>",[MappingType]),
            println(F, "\t\t<name sval=\"~s_mod\"/>",[Texname]),
            %
            OffX = proplists:get_value(offsetx, Ps, ?DEF_MOD_OFFSET_X),
            OffY = proplists:get_value(offsety, Ps, ?DEF_MOD_OFFSET_Y),
            OffZ = proplists:get_value(offsetz, Ps, ?DEF_MOD_OFFSET_Z),
            %
            println(F,
                "\t\t<offset x=\"~w\" y=\"~w\" z=\"~w\"/>",
                [OffX, OffY, OffZ]),
            %
            println(F,
                "\t\t<proj_x ival=\"1\"/>\n"
                "\t\t<proj_y ival=\"2\"/>\n"
                "\t\t<proj_z ival=\"3\"/>"),

            % for scale texture mapping
            SizeX = proplists:get_value(size_x, Ps, ?DEF_MOD_SIZE_X),
            SizeY = proplists:get_value(size_y, Ps, ?DEF_MOD_SIZE_Y),
            SizeZ = proplists:get_value(size_z, Ps, ?DEF_MOD_SIZE_Z),
            %
            println(F, "\t\t<scale x=\"~w\" y=\"~w\" z=\"~w\"/>",
                    [SizeX, SizeY, SizeZ]),

            % texture coordinates type
            Coordinates = proplists:get_value(coordinates, Ps, ?DEF_COORDINATES),
            %
            println(F, "\t\t<texco sval=\"~s\"/>",[Coordinates]),
            println(F, "\t\t<texture sval=\"~s\"/>",[Texname]),
            println(F, "\t\t<type sval=\"texture_mapper\"/>"),
            % if bumpmap..
            case ModShaderType of
                bump ->
                    println(F, "\t\t<bump_strength fval=\"~w\"/>",[Factor*5]);
                _ -> ok
            end,
            % close mapper element
            println(F, "\t</list_element>")

end.


