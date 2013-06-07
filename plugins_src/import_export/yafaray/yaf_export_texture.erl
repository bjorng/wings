%%
%%  yaf_export_texture.erl
%%
%%  YafaRay texture exporter.
%%
%%  Copyright (c) 2003-2008 Raimo Niskanen
%%  Code Converted from Yafray to YafaRay by Bernard Oortman (Wings3d user oort)
%%  Meshlight Export Perfected with Assistance from Micheus
%%  See the file "license.terms" for information on usage and redistribution
%%  of this file, and for a DISCLAIMER OF ALL WARRANTIES.
%%

export_texture(F, Name, Maps, ExportDir, {modulator,Ps}) when is_list(Ps) ->
    case mod_enabled_mode_type(Ps, Maps) of
        {false,_,_} ->
            off;

        {true,_,image} ->
            Filename = proplists:get_value(filename, Ps, ?DEF_MOD_FILENAME),
            export_texture(F, Name, image, Filename);

        {true,_,jpeg} -> %% Old tag
            Filename = proplists:get_value(filename, Ps, ?DEF_MOD_FILENAME),
            export_texture(F, Name, image, Filename);

        {true,_,{map,Map}} ->
            case proplists:get_value(Map, Maps, undefined) of
                undefined ->
                    exit({unknown_texture_map,{?MODULE,?LINE,[Name,Map]}});
                #e3d_image{name=ImageName}=Image ->
                    MapFile = ImageName++".tga",
                    ok = e3d_image:save(Image,
                                        filename:join(ExportDir, MapFile)),
                    export_texture(F, Name, image, MapFile)
            end;

        {true,_,Type} ->
            export_texture(F, Name, Type, Ps)
    end.


export_texture(F, Name, image, Filename) ->
    println(F,
        "<texture name=\"~s\">~n"
        "\t<filename sval=\"~s\"/>~n"
        "\t<type sval=\"image\"/>~n"
        "</texture>", [Name,Filename]);

export_texture(F, Name, Type, Ps) ->

    %%% Start Work-Around for YafaRay Texture Name TEmytex Requirement for Noise Volume

    TextureNameChg = re:replace(Name,"w_TEmytex_1","TEmytex",[global]),
    println(F,
        "<texture name=\"~s\">\n"
        "\t<type sval=\"~s\"/>",
        [TextureNameChg,format(Type)]),

    %%% End Work-Around for YafaRay Texture Name TEmytex Requirement for Noise Volume

    Color1 = proplists:get_value(color1, Ps, ?DEF_MOD_COLOR1),

    Color2 = proplists:get_value(color2, Ps, ?DEF_MOD_COLOR2),

    Hard = proplists:get_value(hard, Ps, ?DEF_MOD_HARD),

    NoiseBasis = proplists:get_value(noise_basis, Ps, ?DEF_MOD_NOISEBASIS),

    NoiseSize = proplists:get_value(noise_size, Ps, ?DEF_MOD_NOISESIZE),

    export_rgb(F, color1, Color1),
    export_rgb(F, color2, Color2),

    println(F,
        "\t<hard bval=\"~s\"/>~n"
        "\t<noise_type sval=\"~s\"/>~n"
        "\t<size fval=\"~.6f\"/>",
        [format(Hard),NoiseBasis,NoiseSize]),

    case Type of

        clouds ->
            Depth = proplists:get_value(depth, Ps, ?DEF_MOD_DEPTH),

            println(F,
                "\t<depth ival=\"~w\"/>",
                [Depth]);

        marble ->
            Depth = proplists:get_value(depth, Ps, ?DEF_MOD_DEPTH),

            Turbulence = proplists:get_value(turbulence, Ps, ?DEF_MOD_TURBULENCE),

            Sharpness = proplists:get_value(sharpness, Ps, ?DEF_MOD_SHARPNESS),

            Shape = proplists:get_value(shape, Ps, ?DEF_MOD_SHAPE),

            println(F,
                "\t<depth ival=\"~w\"/>\n"
                "\t<turbulence fval=\"~.6f\"/>\n"
                "\t<sharpness fval=\"~.6f\"/>\n"
                "\t<shape sval=\"~s\"/>",
                [Depth,Turbulence,Sharpness,Shape]);
        wood ->
            WoodType = proplists:get_value(wood_type, Ps, ?DEF_MOD_WOODTYPE),

            Turbulence = proplists:get_value(turbulence, Ps, ?DEF_MOD_TURBULENCE),

            Shape = proplists:get_value(shape, Ps, ?DEF_MOD_SHAPE),

            %% Coordinate rotation, see export_pos/3.
            println(F,
                "\t<wood_type sval=\"~s\"/>~n"
                "\t<turbulence fval=\"~.6f\"/>~n"
                "\t<shape sval=\"~s\"/>",
                [WoodType, Turbulence, Shape]);

        voronoi ->
            CellType = proplists:get_value(cell_type, Ps, ?DEF_MOD_CELLTYPE),

            CellShape = proplists:get_value(cell_shape, Ps, ?DEF_MOD_CELLSHAPE),

            CellSize = proplists:get_value(cell_size, Ps, ?DEF_MOD_CELLSIZE),

            Intensity = proplists:get_value(intensity, Ps, ?DEF_MOD_INTENSITY),

            CellWeight1 = proplists:get_value(cell_weight1, Ps, ?DEF_MOD_CELL_WEIGHT1),

            CellWeight2 = proplists:get_value(cell_weight2, Ps, ?DEF_MOD_CELL_WEIGHT2),

            CellWeight3 = proplists:get_value(cell_weight3, Ps, ?DEF_MOD_CELL_WEIGHT3),

            CellWeight4 = proplists:get_value(cell_weight4, Ps, ?DEF_MOD_CELL_WEIGHT4),

            %% Coordinate rotation, see export_pos/3.
            println(F,
                "\t<color_type sval=\"~s\"/>\n"
                "\t<distance_metric sval=\"~s\"/>\n"
                "\t<size fval=\"~.6f\"/>\n"
                "\t<intensity fval=\"~.6f\"/>\n"
                "\t<weight1 fval=\"~.6f\"/>\n"
                "\t<weight2 fval=\"~.6f\"/>\n"
                "\t<weight3 fval=\"~.6f\"/>\n"
                "\t<weight4 fval=\"~.6f\"/>",
                [CellType, CellShape, CellSize, Intensity, CellWeight1, CellWeight2, CellWeight3, CellWeight4]);

        musgrave ->
            MusgType = proplists:get_value(musgrave_type, Ps, ?DEF_MOD_MUSGRAVE_TYPE),

            NoiseBasis = proplists:get_value(noise_basis, Ps, ?DEF_MOD_NOISEBASIS),

            MusgNoiseSize = proplists:get_value(musgrave_noisesize, Ps, ?DEF_MOD_MUSGRAVE_NOISESIZE),

            MusgIntensity = proplists:get_value(musgrave_intensity, Ps, ?DEF_MOD_MUSGRAVE_INTENSITY),

            MusgContrast = proplists:get_value(musgrave_contrast, Ps, ?DEF_MOD_MUSGRAVE_CONTRAST),

            MusgLacunarity = proplists:get_value(musgrave_lacunarity, Ps, ?DEF_MOD_MUSGRAVE_LACUNARITY),

            MusgOctaves = proplists:get_value(musgrave_octaves, Ps, ?DEF_MOD_MUSGRAVE_OCTAVES),

            %% Coordinate rotation, see export_pos/3.
            println(F,
                "\t<musgrave_type sval=\"~s\"/>~n"
                "\t<noise_type sval=\"~s\"/>~n"
                "\t<size fval=\"~.6f\"/>~n"
                "\t<intensity fval=\"~.6f\"/>~n"
                "\t<H fval=\"~.6f\"/>~n"
                "\t<lacunarity fval=\"~.6f\"/>~n"
                "\t<octaves fval=\"~.6f\"/>",
                [MusgType, NoiseBasis, MusgNoiseSize, MusgIntensity, MusgContrast, MusgLacunarity, MusgOctaves]);

        distorted_noise ->

            NoiseBasis = proplists:get_value(noise_basis, Ps, ?DEF_MOD_NOISEBASIS),

            DistorType = proplists:get_value(distortion_type, Ps, ?DEF_MOD_DISTORTION_TYPE),

            DistorNoiseSize = proplists:get_value(distortion_noisesize, Ps, ?DEF_MOD_DISTORTION_NOISESIZE),

            DistorIntensity = proplists:get_value(distortion_intensity, Ps, ?DEF_MOD_DISTORTION_INTENSITY),

            %% Coordinate rotation, see export_pos/3.
            println(F,
                "\t<noise_type1 sval=\"~s\"/>\n"
                "\t<noise_type2 sval=\"~s\"/>\n"
                "\t<size fval=\"~.6f\"/>\n"
                "\t<distort fval=\"~.6f\"/>\n",
                [NoiseBasis, DistorType, DistorNoiseSize, DistorIntensity]);
        _ ->
            ok
    end,
    println(F, "</texture>").



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

            StencilInputName =
                case AlphaIntensity of
                    stencil -> re:replace(Texname,"_2","_3",[global]);
                    _-> ""
                end,

            %%% Change Number from Texname for Stencil UpperLayer Name 2

            StencilUpperLayerName2 =
                case AlphaIntensity of
                    stencil -> re:replace(Texname,"_1","_2",[global]);
                    _-> ""
                end,

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
                    image ->    "\t<texco sval=\"uv\"/>";
                    jpeg ->     "\t<texco sval=\"uv\"/>";
                    {map,_} ->  "\t<texco sval=\"uv\"/>";
                    marble ->   "\t<texco sval=\"global\"/>";
                    wood ->     "\t<texco sval=\"global\"/>";
                    clouds ->   "\t<texco sval=\"global\"/>";
                    _ -> ""
                end,

            ModeNumber =
                case Mode of
                    mix -> "0";
                    add -> "1";
                    mul -> "2";
                    sub -> "3";
                    scr -> "4";
                    divide -> "5";
                    dif -> "6";
                    dar -> "7";
                    lig -> "8";
                    _ -> ""
                end,

            %% Identify Modulator # (w_default_Name_1 or w_default_Name_2)
            Split=re:split(Texname,"_",[{return, list}]),
            Num=lists:last(Split),
            UpperLayer =
                case {Num,Mode,AlphaIntensity} of
                        {"1",mix,_} ->  "";
                        {"1",_,_} ->  "\t<upper_layer sval=\""++UpperLayerName++"\"/>\n";
                        {"2",_,stencil} ->  "\t<upper_layer sval=\""++UpperLayerName++"\"/>\n";
                        _ -> ""
                end,
%% End Identify Modulator #

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
                    println(F,
                        " <!--Start Stencil Section Here-->

                        <list_element>
                        <element sval=\"shader_node\"/>
                        <name sval=\"~s\"/>
                        <input sval=\"~s_mod\"/>

                        <noRGB bval=\"true\"/>
                        <stencil bval=\"true\"/>
                        "++UpperLayer++"

                        <type sval=\"layer\"/>
                        <mode ival=\""++ModeNumber++"\"/>
                        </list_element>

                        <list_element>
                        <element sval=\"shader_node\"/>
                        <name sval=\"~s_mod\"/>
                        "++TexCo++"
                        <mapping sval=\"plain\"/>
                        <texture sval=\"~s\"/>
                        <type sval=\"texture_mapper\"/>
                        <bump_strength fval=\"~.3f\"/>
                        </list_element>

                        <diffuse_shader sval=\"diff_layer2\"/>
                        <list_element>
                        <element sval=\"shader_node\"/>
                        <name sval=\"diff_layer2\"/>
                        <input sval=\""++StencilInputName++"_mod\"/>
                        <upper_layer sval=\""++StencilUpperLayerName2++"\"/>
                        <type sval=\"layer\"/>
                        <mode ival=\""++ModeNumber++"\"/>
                        </list_element>

        <!--End Stencil Section Here-->",
                    [Texname,Texname,Texname,Texname,Normal]);
%%Stencil Export End
                        _ ->

                 println(F,
                    "  "++ShaderName++"
                    <list_element>
                    <element sval=\"shader_node\"/>
                    <name sval=\"~s\"/>
                    <input sval=\"~s_mod\"/>
                    "++UpperLayer++"
                    "++UpperColor++"
                    "++UseAlpha++"
                    <type sval=\"layer\"/>
                    <mode ival=\""++ModeNumber++"\"/>
                    </list_element>
                    <list_element>
                    <element sval=\"shader_node\"/>
                    <name sval=\"~s_mod\"/>
                    "++TexCo++"
                    <mapping sval=\"plain\"/>
                    <texture sval=\"~s\"/>
                    <type sval=\"texture_mapper\"/>
                    <bump_strength fval=\"~.3f\"/>
                    </list_element>",
                    [Texname,Texname,Texname,Texname,Normal])

                 end

end.
