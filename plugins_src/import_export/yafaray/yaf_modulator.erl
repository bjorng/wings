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

            ModShaderType = proplists:get_value(mod_shader_type, Ps, ?DEF_MOD_SHADER_TYPE),
            Diffuse = proplists:get_value(mod_factor, Ps, ?DEF_MOD_FACTOR),
            _Specular = proplists:get_value(specular, Ps, ?DEF_MOD_SPECULAR),
            Ambient = proplists:get_value(ambient, Ps, ?DEF_MOD_AMBIENT),
            Shininess = proplists:get_value(shininess, Ps, ?DEF_MOD_SHININESS),
            _Color = Diffuse * Opacity,
            _HardValue = Shininess,
            _Transmission = Diffuse * (1.0 - Opacity),
            _Reflection = Ambient,
            erlang:display("Modulator. Shader used is: "++format(ModShaderType)), %-------------->


            %% Identify Modulator # (w_default_Name_1 or w_default_Name_2)

            Split=re:split(Texname,"_",[{return, list}]),

            Num=lists:last(Split),

            %_UpperLayer =
            %    case {Num, BlendMode, ModShaderType} of
            %            {"1",mix,_} ->  "";
            %            {"1",_,_} ->  UpperLayerName;
            %            {"2",_,stencil} -> UpperLayerName;
            %            _ -> ""
            %    end,



            %% in normal cases, this color is the same of 'diffuse'
            _UpperColor =
                 case Num of
                        "1" ->  "<upper_color r=\"1\" g=\"1\" b=\"1\" a=\"1\"/>";
                        _ -> ""
                 end,

            _UseAlpha =
                 case {Num, ModShaderType} of
                        {"1",diff} ->  "<do_scalar bval=\"false\"/>";
                        {_,transparency} -> "<do_scalar bval=\"true\"/>";
                        {_,diffusealphatransparency} -> "<use_alpha bval=\"true\"/>";
                        {_,translucency} -> "<do_scalar bval=\"true\"/>";
                        {_,specularity} -> "<do_scalar bval=\"true\"/>";
                        {_,stencil} -> "<use_alpha bval=\"true\"/>";
                        _ -> ""
                 end,
            _Normal = proplists:get_value(normal, Ps, ?DEF_MOD_NORMAL),

            %%% Change Number from Texname for UpperLayer  ModShaderType
            _UpperLayerName =
                case ModShaderType of % TODO: change for stencil mode
                        stencil ->
                            re:replace(Texname,"_2","_1",[global]);
                        _->
                            re:replace(Texname,"_1","_2",[global])
                end,

            % different types for each shader
            % TODO: ModShaderType not work atm..
            ShaderType =
                case ModShaderType of
                    diff -> "<diffuse_shader sval=\""++Texname++"\"/>";
                    transp -> "<transparency_shader sval=\""++Texname++"\"/>";
                    translu -> "<translucency_shader sval=\""++Texname++"\"/>";
                    spec -> "<glossy_reflect_shader sval=\""++Texname++"\"/>";
                    _ -> "" %"<diffuse_shader"
                end,
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

            %% color factor amount controled with 'Factor Modulator' slider in UI
            Factor = proplists:get_value(mod_factor, Ps, ?DEF_MOD_FACTOR),
            println(F,"\t\t<colfac fval=\"~w\"/>",[Factor]),

            %% If use value but not color, the form is..
            %% println(F,"\t\t<valfac fval=\"1\"/>"),
            %
            CellType = proplists:get_value(cell_type, Ps, ?DEF_MOD_CELLTYPE),
            %
            %%--------------------------->
            erlang:display("Texture type is :"++TexType),

            IsColor = case TexType of
                    image -> true;
                    {map,_} -> true;
                    voronoi -> case CellType of
                                    intensity -> true;
                                    _ -> false
                                end;
                    _ -> false
                end,


            %isColor = case TexType of
            %        image -> true;
            %        _-> false
            %    end,

            println(F,"\t\t<color_input bval=\"~s\"/>",[IsColor]),

            % def color for 'blended' by default
            println(F,"\t\t<def_col r=\"0.81\" g=\"0.8\" b=\"0.81\" a=\"1\"/>"),
            %
            println(F,"\t\t<def_val fval=\"1\"/>"),

            % swich to use texture values
            %TODO: have an error with Blendmode value

            {DoColor, DoScalar} =
                case ModShaderType of
                    diff -> {true, false};
                    _-> {false,true}
                end,
            %
            println(F,"\t\t<do_color bval=\"~s\"/>",[DoColor]),
            %
            println(F,"\t\t<do_scalar bval=\"~s\"/>",[DoScalar]),
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
            println(F,"\t\t<mode ival=\"~s\"/>",[ModeNumber]),
            %
            println(F,"\t\t<name sval=\"~s\"/>",[Texname]),
            %
            println(F,"\t\t<noRGB bval=\"false\"/>"),
            %
            println(F,"\t\t<stencil bval=\"false\"/>"),
            %
            println(F, "\t\t<upper_value fval=\"0\"/>"),
            %
            println(F,"\t\t<type sval=\"layer\"/>"),

            % close list element shader
            println(F,"\t</list_element>"),

            %%%-------------------------------->
            % open list element for mapper
            %
            println(F,"\t<list_element>\n"
                "\t\t<element sval=\"shader_node\"/>"),

            % projection mapping coordinates type
            MappingType = proplists:get_value(projection, Ps, ?DEF_PROJECTION),

            println(F, "\t\t<mapping sval=\"~s\"/>",[MappingType]),
            println(F, "\t\t<name sval=\"~s_mod\"/>",[Texname]),
            %
            OffX = proplists:get_value(offsetx, Ps, ?DEF_MOD_OFFSET_X),
            OffY = proplists:get_value(offsetx, Ps, ?DEF_MOD_OFFSET_Y),
            OffZ = proplists:get_value(offsetx, Ps, ?DEF_MOD_OFFSET_Z),
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
            TexCo = case TexType of
                        image ->    "uv";
                        jpeg ->     "uv";
                        {map,_} ->  "uv";
                        marble ->   "global";
                        wood ->     "global";
                        clouds ->   "global";
                        _ -> "global"
                    end,
            %
            println(F, "\t\t<texco sval=\"~s\"/>",[TexCo]),
            println(F, "\t\t<texture sval=\"~s\"/>",[Texname]),
            println(F, "\t\t<type sval=\"texture_mapper\"/>"),
            % if bumpmap..
            %println(F, "\t\t<bump_strength fval=\"0.0\"/>"),
            % close mapper element
            println(F, "\t</list_element>")

end.


