%%
%%
%%  diffuse modulator


%
export_modulator(F, Texname, Maps, {modulator,Ps}, Opacity) when is_list(Ps) ->

    case mod_enabled_mode_type(Ps, Maps) of

        {false,_,_} ->
            off;
        {true,Mode,Type} ->
            AlphaIntensity = proplists:get_value(alpha_intensity, Ps, ?DEF_MOD_ALPHA_INTENSITY),

            %%% Change Number from Texname for UpperLayer

            UpperLayerName =
                case AlphaIntensity of
                        stencil ->
                            re:replace(Texname,"_2","_1",[global]);
                        _->
                            re:replace(Texname,"_1","_2",[global])
                end,

            %%% Change Number from Texname for Stencil Input

            % povman test for fix stencil  mode crash --------------------------->
            %StencilInputName =
            %    case AlphaIntensity of
            %        stencil -> re:replace(Texname,"_2","_3",[global]);
            %        _-> ""
            %    end,

            %%% Change Number from Texname for Stencil UpperLayer Name 2

            %StencilUpperLayerName2 =
            %    case AlphaIntensity of
            %        stencil -> re:replace(Texname,"_1","_2",[global]);
            %        _-> ""
            %    end,

            %%%

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
                    image ->    "uv";
                    jpeg ->     "uv";
                    {map,_} ->  "uv";
                    marble ->   "global";
                    wood ->     "global";
                    clouds ->   "global";
                    _ -> ""
                end,

            ModeNumber =
                case Mode of
                    mix -> "0"; add -> "1"; mul -> "2"; sub -> "3"; scr -> "4";
                    divide -> "5"; dif -> "6"; dar -> "7"; lig -> "8";
                    _ -> ""
                end,

            %% Identify Modulator # (w_default_Name_1 or w_default_Name_2)
            Split=re:split(Texname,"_",[{return, list}]),
            Num=lists:last(Split),
            UpperLayer =
                case {Num,Mode,AlphaIntensity} of
                        {"1",mix,_} ->  "";
                        {"1",_,_} ->  UpperLayerName;
                        {"2",_,stencil} -> UpperLayerName;
                        _ -> ""
                end,
%% End Identify Modulator #
            %% in normal cases, this color is the same of 'diffuse'
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
            %%% shaders slots for 'shinydiffusemat'
            %   diffuse_shader, mirror_color_shader, transparency_shader,
            %   translucency_shader, mirror_shader, bump_shader
            %


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
                    println(F,"
                    <!--Start Stencil Section Here-->
                    <list_element>
                        <colfac fval=\"1\"/>
                        <color_input bval=\"false\"/>
                        <def_col r=\"1\" g=\"0\" b=\"1\" a=\"1\"/>
                        <def_val fval=\"1\"/>
                        <do_color bval=\"true\"/>
                        <do_scalar bval=\"false\"/>
                        <element sval=\"shader_node\"/>
                        <input sval=\"~s_mod\"/>
                        <mode ival=\"~s\"/>
                        <name sval=\"~s\"/>
                        <noRGB bval=\"true\"/>
                        <stencil bval=\"true\"/>
                        <type sval=\"layer\"/>
                        <upper_layer sval=\"~s\"/>
                    </list_element>",
                    [Texname, ModeNumber, Texname, UpperLayer]),

                    println(F,"
                    <list_element>
                        <element sval=\"shader_node\"/>
                        <mapping sval=\"plain\"/>
                        <name sval=\"~s_mod\"/>
                        <offset x=\"0\" y=\"0\" z=\"0\"/>
                        <proj_x ival=\"1\"/>
                        <proj_y ival=\"2\"/>
                        <proj_z ival=\"3\"/>
                        <scale x=\"1\" y=\"1\" z=\"1\"/>
                        <texco sval=\"~s\"/>
                        <texture sval=\"~s\"/>
                        <type sval=\"texture_mapper\"/>
                        <bump_strength fval=\"~.3f\"/>
                    </list_element>",
                    [Texname, TexCo, Texname,Normal ]);

                _ ->

                    println(F,""++ShaderName++"
                        <list_element>
                            <colfac fval=\"1\"/>
                            <color_input bval=\"false\"/>
                            <def_col r=\"1\" g=\"0\" b=\"1\" a=\"1\"/>
                            <def_val fval=\"1\"/>
                            <element sval=\"shader_node\"/>
                            <name sval=\"~s\"/>
                            <input sval=\"~s_mod\"/>
                            "++UpperLayer++"
                            "++UpperColor++"
                            "++UseAlpha++"
                            <type sval=\"layer\"/>
                            <mode ival=\"~s\"/>
                        </list_element>",
                        [Texname,Texname,ModeNumber]),

                    println(F,"
                        <list_element>
                            <element sval=\"shader_node\"/>
                            <mapping sval=\"plain\"/>
                            <name sval=\"~s_mod\"/>
                            <offset x=\"0\" y=\"0\" z=\"0\"/>
                            <proj_x ival=\"1\"/>
                            <proj_y ival=\"2\"/>
                            <proj_z ival=\"3\"/>
                            <scale x=\"1\" y=\"1\" z=\"1\"/>
                            <texco sval=\"~s\"/>
                            <texture sval=\"~s\"/>
                            <type sval=\"texture_mapper\"/>
                            <bump_strength fval=\"~.3f\"/>
                        </list_element>",
                        [Texname,TexCo,Texname,Normal])

                end

end.


