%%
%%  yaf_export_materials.erl
%%
%%  YafaRay Shader Modulators User Interface.
%%
%%  Copyright (c) 2003-2008 Raimo Niskanen
%%  Code Converted from Yafray to YafaRay by Bernard Oortman (Wings3d user oort)
%%  Meshlight Export Perfected with Assistance from Micheus
%%  See the file "license.terms" for information on usage and redistribution
%%  of this file, and for a DISCLAIMER OF ALL WARRANTIES.
%%
%%

export_shader(F, Name, Mat, ExportDir) ->

    YafaRay = proplists:get_value(?TAG, Mat, []),

    DefShaderType = get_pref(shader_type, YafaRay),

    ShaderType = proplists:get_value(shader_type, YafaRay, DefShaderType),

    case ShaderType of

        shinydiffuse ->
            export_shinydiffuse_shader(F, Name, Mat, ExportDir, YafaRay);

        glossy ->
            export_glossy_shader(F, Name, Mat, ExportDir, YafaRay);

        coatedglossy ->
            export_coatedglossy_shader(F, Name, Mat, ExportDir, YafaRay);

        translucent ->
            export_translucent_shader(F, Name, Mat, ExportDir, YafaRay);

        glass ->
            export_glass_shader(F, Name, Mat, ExportDir, YafaRay);

        lightmat ->
            export_lightmat_shader(F, Name, Mat, ExportDir, YafaRay);

        rough_glass ->
            export_rough_glass_shader(F, Name, Mat, ExportDir, YafaRay);

        blend_mat ->
            ok

        end.

%%% Shiny Diffuse Material
%%
export_shinydiffuse_shader(F, Name, Mat, ExportDir, YafaRay) ->

    OpenGL = proplists:get_value(opengl, Mat),

    Maps = proplists:get_value(maps, Mat, []),

    Modulators = proplists:get_value(modulators, YafaRay, def_modulators(Maps)),

    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
            case export_texture(F, [Name,$_,format(N)], Maps, ExportDir, M) of
                    off -> N+1;
                    ok ->
                        println(F),
                        N+1
                end;
            (_, N) ->
                N % Ignore old modulators
        end, 1, Modulators),

    println(F,
        "<material name=\"~s\">~n"
        "\t<type sval=\"shinydiffusemat\"/>", [Name]),

    DiffuseA = {_,_,_,Opacity} = proplists:get_value(diffuse, OpenGL),

    Specular = alpha(proplists:get_value(specular, OpenGL)),

    DefReflected = Specular,

    DefTransmitted = def_transmitted(DiffuseA),

    %% XXX Wings scaling of shininess is weird. Commonly this value
    %% is the cosine power and as such in the range 0..infinity.
    %% OpenGL limits this to 0..128 which mostly is sufficient.

    println(F,
        "\t<hard fval=\"~.10f\"/>",
        [proplists:get_value(shininess, OpenGL)*128.0]),

    export_rgb(F, mirror_color, proplists:get_value(reflected, YafaRay, DefReflected)),

    export_rgb(F, color, proplists:get_value(transmitted, YafaRay, DefTransmitted)),

    IOR = proplists:get_value(ior, YafaRay, ?DEF_IOR),

    TIR = proplists:get_value(tir, YafaRay, ?DEF_TIR),

    Transparency = proplists:get_value(transparency, YafaRay, ?DEF_TRANSPARENCY),

    TransmitFilter = proplists:get_value(transmit_filter, YafaRay, ?DEF_TRANSMIT_FILTER),

    Translucency = proplists:get_value(translucency, YafaRay, ?DEF_TRANSLUCENCY),

    DiffuseReflect = proplists:get_value(diffuse_reflect, YafaRay, ?DEF_DIFFUSE_REFLECT),

    SpecularReflect = proplists:get_value(specular_reflect, YafaRay, ?DEF_SPECULAR_REFLECT),

    Emit = proplists:get_value(emit, YafaRay, ?DEF_EMIT),

    OrenNayar = proplists:get_value(oren_nayar, YafaRay, ?DEF_OREN_NAYAR),

    DefAbsorptionColor = def_absorption_color(proplists:get_value(diffuse, OpenGL)),

    AbsorptionColor = proplists:get_value(absorption_color, YafaRay, DefAbsorptionColor),

    case AbsorptionColor of
        [ ] -> ok;
        {AbsR,AbsG,AbsB} ->
            AbsD = proplists:get_value(absorption_dist, YafaRay,?DEF_ABSORPTION_DIST),
            export_rgb(F, absorption, {-math:log(max(AbsR, ?NONZERO))/AbsD,
                                       -math:log(max(AbsG, ?NONZERO))/AbsD,
                                       -math:log(max(AbsB, ?NONZERO))/AbsD})
    end,

    DispersionPower = proplists:get_value(dispersion_power, YafaRay, ?DEF_DISPERSION_POWER),

    case DispersionPower of
        0.0 -> ok;
        _   ->
            DispersionSamples =
                proplists:get_value(dispersion_samples, YafaRay, ?DEF_DISPERSION_SAMPLES),
            DispersionJitter =
                proplists:get_value(dispersion_jitter, YafaRay, ?DEF_DISPERSION_JITTER),
            println(F,
                "\t<dispersion_samples ival=\"~w\"/>\n"
                "\t<dispersion_jitter bval=\"~s\"/>",
                [DispersionSamples, format(DispersionJitter)])
    end,

    case OrenNayar of
        false -> ok;
        _ ->
            OrenNayarSigma = proplists:get_value(oren_nayar_sigma, YafaRay, ?DEF_OREN_NAYAR_SIGMA),

            println(F,
                "\t<diffuse_brdf sval=\"oren_nayar\"/>~n"
                "\t<sigma fval=\"~.10f\"/>",
                [OrenNayarSigma])
    end,

    println(F,
        "\t<IOR fval=\"~.10f\"/>~n"
        "\t<fresnel_effect bval=\"~s\"/>~n"
        "\t<transmit_filter fval=\"~.10f\"/>~n"
        "\t<translucency fval=\"~.10f\"/>~n"
        "\t<transparency fval=\"~.10f\"/>~n"
        "\t<diffuse_reflect fval=\"~.10f\"/>~n"
        "\t<specular_reflect fval=\"~.10f\"/>~n"
        "\t<emit fval=\"~.10f\"/>~n",
        [IOR,format(TIR),TransmitFilter,Translucency,Transparency,DiffuseReflect,SpecularReflect,Emit]),
    %
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
            case export_modulator(F, [Name,$_,format(N)], Maps, M, Opacity) of
                    off -> N+1;
                    ok ->
                        println(F),
                        N+1
                end;
            (_, N) ->
                N % Ignore old modulators
        end, 1, Modulators),

    println(F, "</material>").


%%% Glossy material
%%
export_glossy_shader(F, Name, Mat, ExportDir, YafaRay) ->
    OpenGL = proplists:get_value(opengl, Mat),
    Maps = proplists:get_value(maps, Mat, []),
    Modulators = proplists:get_value(modulators, YafaRay, def_modulators(Maps)),
    %
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
            case export_texture(F, [Name,$_,format(N)],Maps, ExportDir, M) of
                off -> N+1;
                ok ->
                    println(F),
                    N+1
                end;
            (_, N) ->
                N % Ignore old modulators
        end, 1, Modulators),
    %
    println(F,
        "<material name=\"~s\">~n" %++
        "\t<type sval=\"glossy\"/>",[Name]),

    DiffuseA = {_,_,_,Opacity} = proplists:get_value(diffuse, OpenGL),

    Specular = alpha(proplists:get_value(specular, OpenGL)),

    DefReflected = Specular,

    DefTransmitted = def_transmitted(DiffuseA),

    %% XXX Wings scaling of shininess is weird. Commonly this value
    %% is the cosine power and as such in the range 0..infinity.
    %% OpenGL limits this to 0..128 which mostly is sufficient.
    println(F, "\t<hard fval=\"~.10f\"/>", [proplists:get_value(shininess, OpenGL)*128.0]),

    export_rgb(F, color, proplists:get_value(reflected, YafaRay, DefReflected)),

    export_rgb(F, diffuse_color, proplists:get_value(transmitted, YafaRay, DefTransmitted)),

    DiffuseReflect = proplists:get_value(diffuse_reflect, YafaRay, ?DEF_DIFFUSE_REFLECT),

    GlossyReflect = proplists:get_value(glossy_reflect, YafaRay, ?DEF_GLOSSY_REFLECT),

    Exponent = proplists:get_value(exponent, YafaRay, ?DEF_EXPONENT),

    OrenNayar = proplists:get_value(oren_nayar, YafaRay, ?DEF_OREN_NAYAR),

    DefAbsorptionColor = def_absorption_color(proplists:get_value(diffuse, OpenGL)),

    AbsorptionColor = proplists:get_value(absorption_color, YafaRay, DefAbsorptionColor),

    case AbsorptionColor of
        [ ] -> ok;
        {AbsR,AbsG,AbsB} ->
            AbsD =
                proplists:get_value(absorption_dist, YafaRay, ?DEF_ABSORPTION_DIST),

            export_rgb(F, absorption, {-math:log(max(AbsR, ?NONZERO))/AbsD,
                                       -math:log(max(AbsG, ?NONZERO))/AbsD,
                                       -math:log(max(AbsB, ?NONZERO))/AbsD})
    end,
    DispersionPower =
        proplists:get_value(dispersion_power, YafaRay, ?DEF_DISPERSION_POWER),
    case DispersionPower of
        0.0 -> ok;
        _   ->
            DispersionSamples =
                proplists:get_value(dispersion_samples, YafaRay, ?DEF_DISPERSION_SAMPLES),
            DispersionJitter =
                proplists:get_value(dispersion_jitter, YafaRay, ?DEF_DISPERSION_JITTER),
            println(F,
                "\t<dispersion_samples ival=\"~w\"/>\n"
                "\t<dispersion_jitter bval=\"~s\"/>",
                [DispersionSamples, format(DispersionJitter)])
    end,

    case OrenNayar of
        false -> ok;
        _ ->
           OrenNayarSigma = proplists:get_value(oren_nayar_sigma, YafaRay, ?DEF_OREN_NAYAR_SIGMA),

            println(F,
                "\t<diffuse_brdf sval=\"oren_nayar\"/>~n"
                "\t<sigma fval=\"~.10f\"/>",
                [OrenNayarSigma])
    end,

    println(F,
        "\t<diffuse_reflect fval=\"~.10f\"/>~n"
        "\t<glossy_reflect fval=\"~.10f\"/>~n"
        "\t<exponent fval=\"~.10f\"/>",
        [DiffuseReflect,GlossyReflect,Exponent]),
    %
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
            case export_modulator(F, [Name,$_,format(N)], Maps, M, Opacity) of
                off -> N+1;
                ok ->
                    println(F),
                    N+1
                end;
            (_, N) ->
                N % Ignore old modulators
        end, 1, Modulators),

    println(F, "</material>").

%% coated glossy
%%
export_coatedglossy_shader(F, Name, Mat, ExportDir, YafaRay) ->
    OpenGL = proplists:get_value(opengl, Mat),
    Maps = proplists:get_value(maps, Mat, []),
    Modulators = proplists:get_value(modulators, YafaRay, def_modulators(Maps)),
    %
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
        case export_texture(F, [Name,$_,format(N)],Maps, ExportDir, M) of
            off -> N+1;
            ok ->
                println(F),
                N+1
            end;
            (_, N) ->
                N % Ignore old modulators
        end, 1, Modulators),

    println(F,
        "<material name=\"~s\">~n"
        "\t<type sval=\"coated_glossy\"/>", [Name]),

    DiffuseA = {_,_,_,Opacity} = proplists:get_value(diffuse, OpenGL),

    Specular = alpha(proplists:get_value(specular, OpenGL)),

    DefReflected = Specular,

    DefTransmitted = def_transmitted(DiffuseA),

    %% XXX Wings scaling of shininess is weird. Commonly this value
    %% is the cosine power and as such in the range 0..infinity.
    %% OpenGL limits this to 0..128 which mostly is sufficient.

    println(F,
        "\t<hard fval=\"~.10f\"/>", [proplists:get_value(shininess, OpenGL)*128.0]),

    export_rgb(F, color, proplists:get_value(reflected, YafaRay, DefReflected)),

    export_rgb(F, diffuse_color, proplists:get_value(transmitted, YafaRay, DefTransmitted)),

    IOR = proplists:get_value(ior, YafaRay, ?DEF_IOR),

    DiffuseReflect = proplists:get_value(diffuse_reflect, YafaRay, ?DEF_DIFFUSE_REFLECT),

    GlossyReflect = proplists:get_value(glossy_reflect, YafaRay, ?DEF_GLOSSY_REFLECT),

    Exponent = proplists:get_value(exponent, YafaRay, ?DEF_EXPONENT),

    Anisotropic = proplists:get_value(anisotropic, YafaRay, ?DEF_ANISOTROPIC),

    Anisotropic_U = proplists:get_value(anisotropic_u, YafaRay, ?DEF_ANISOTROPIC_U),

    Anisotropic_V = proplists:get_value(anisotropic_v, YafaRay, ?DEF_ANISOTROPIC_V),

    OrenNayar = proplists:get_value(oren_nayar, YafaRay, ?DEF_OREN_NAYAR),

    DefAbsorptionColor = def_absorption_color(proplists:get_value(diffuse, OpenGL)),

    AbsorptionColor = proplists:get_value(absorption_color, YafaRay, DefAbsorptionColor),

    case AbsorptionColor of
        [ ] -> ok;
        {AbsR,AbsG,AbsB} ->
            AbsD =
                proplists:get_value(absorption_dist, YafaRay, ?DEF_ABSORPTION_DIST),

            export_rgb(F, absorption, {-math:log(max(AbsR, ?NONZERO))/AbsD,
                                       -math:log(max(AbsG, ?NONZERO))/AbsD,
                                       -math:log(max(AbsB, ?NONZERO))/AbsD})
    end,
    DispersionPower = proplists:get_value(dispersion_power, YafaRay, ?DEF_DISPERSION_POWER),
    %
    case DispersionPower of
        0.0 -> ok;
        _   ->
            DispersionSamples =
                proplists:get_value(dispersion_samples, YafaRay, ?DEF_DISPERSION_SAMPLES),
            DispersionJitter =
                proplists:get_value(dispersion_jitter, YafaRay, ?DEF_DISPERSION_JITTER),
            println(F,
                "\t"
                "\t<dispersion_samples ival=\"~w\"/>~n"
                "\t<dispersion_jitter bval=\"~s\"/>",
                [DispersionSamples, format(DispersionJitter)])
    end,

    case OrenNayar of
        false -> ok;
        _ ->
           OrenNayarSigma = proplists:get_value(oren_nayar_sigma, YafaRay, ?DEF_OREN_NAYAR_SIGMA),

            println(F,
                "\t<diffuse_brdf sval=\"oren_nayar\"/>~n"
                "\t<sigma fval=\"~.10f\"/>",
                [OrenNayarSigma])
    end,

    println(F,
        "\t<IOR fval=\"~.10f\"/>~n"
        "\t<diffuse_reflect fval=\"~.10f\"/>~n"
        "\t<glossy_reflect fval=\"~.10f\"/>~n"
        "\t<anisotropic bval=\"~s\"/>~n"
        "\t<exp_u fval=\"~.10f\"/>~n"
        "\t<exp_v fval=\"~.10f\"/>~n"
        "\t<exponent fval=\"~.10f\"/>~n",
        [IOR, DiffuseReflect, GlossyReflect, Anisotropic, Anisotropic_U, Anisotropic_V, Exponent]),
    %
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
            case export_modulator(F, [Name,$_,format(N)], Maps, M, Opacity) of
                off -> N+1;
                ok ->
                    println(F),
                    N+1
                end;
            (_, N) ->
                N % Ignore old modulators
        end, 1, Modulators),

    println(F, "</material>").

%% Translucent shader
%%
export_translucent_shader(F, Name, Mat, ExportDir, YafaRay) ->

    OpenGL = proplists:get_value(opengl, Mat),

    Maps = proplists:get_value(maps, Mat, []),

    Modulators = proplists:get_value(modulators, YafaRay, def_modulators(Maps)),

    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
            case export_texture(F, [Name,$_,format(N)], Maps, ExportDir, M) of
                off -> N+1;
                ok ->
                    println(F),
                    N+1
                end;
            (_, N) ->
                N % Ignore old modulators
        end, 1, Modulators),
    println(F,
        "<material name=\"~s\">~n"++
        "\t<type sval=\"translucent\"/>", [Name]),

    DiffuseA = {_,_,_,Opacity} = proplists:get_value(diffuse, OpenGL),

    Specular = alpha(proplists:get_value(specular, OpenGL)),

    DefReflected = Specular,

    DefTransmitted = def_transmitted(DiffuseA),

    SSS_AbsorptionColor = proplists:get_value(sss_absorption_color, YafaRay, ?DEF_SSS_ABSORPTION_COLOR),

    ScatterColor = proplists:get_value(scatter_color, YafaRay, ?DEF_SCATTER_COLOR),

    SSS_Specular_Color = proplists:get_value(sss_specular_color, YafaRay, ?DEF_SSS_SPECULAR_COLOR),

    %% XXX Wings scaling of shininess is weird. Commonly this value
    %% is the cosine power and as such in the range 0..infinity.
    %% OpenGL limits this to 0..128 which mostly is sufficient.

    println(F,
        "\t<hard ival=\"~.10f\"/>",
        [proplists:get_value(shininess, OpenGL)*128.0]),

    export_rgb(F, glossy_color, proplists:get_value(reflected, YafaRay, DefReflected)),

    export_rgb(F, color, proplists:get_value(transmitted, YafaRay, DefTransmitted)),

    export_rgb(F, specular_color, proplists:get_value(sss_specular_color, YafaRay, SSS_Specular_Color)),

    case SSS_AbsorptionColor of
        [ ] -> ok;
        {AbsR,AbsG,AbsB} ->
            AbsD = proplists:get_value(absorption_dist, YafaRay, ?DEF_ABSORPTION_DIST),

            export_rgb(F, sigmaA, {-math:log(max(AbsR, ?NONZERO))/AbsD,
                                   -math:log(max(AbsG, ?NONZERO))/AbsD,
                                   -math:log(max(AbsB, ?NONZERO))/AbsD})
    end,

    export_rgb(F, sigmaS, proplists:get_value(scatter_color, YafaRay, ScatterColor)),

    IOR = proplists:get_value(ior, YafaRay, ?DEF_IOR),

    SigmaSfactor = proplists:get_value(sigmas_factor, YafaRay, ?DEF_SIGMAS_FACTOR),

    DiffuseReflect = proplists:get_value(diffuse_reflect, YafaRay, ?DEF_DIFFUSE_REFLECT),

    GlossyReflect = proplists:get_value(glossy_reflect, YafaRay, ?DEF_GLOSSY_REFLECT),

    SSS_Translucency = proplists:get_value(sss_translucency, YafaRay, ?DEF_SSS_TRANSLUCENCY),

    Exponent = proplists:get_value(exponent, YafaRay, ?DEF_EXPONENT),

    DispersionPower = proplists:get_value(dispersion_power, YafaRay, ?DEF_DISPERSION_POWER),
    %
    case DispersionPower of
        0.0 -> ok;
        _   ->
            DispersionSamples =  proplists:get_value(dispersion_samples, YafaRay, ?DEF_DISPERSION_SAMPLES),

            DispersionJitter = proplists:get_value(dispersion_jitter, YafaRay, ?DEF_DISPERSION_JITTER),

            println(F,
                "\t<dispersion_samples ival=\"~w\"/>~n"
                "\t<dispersion_jitter bval=\"~s\"/>",
                [DispersionSamples, format(DispersionJitter)])
    end,
    println(F,
        "\t<IOR fval=\"~.10f\"/>~n"
        "\t<sigmaS_factor fval=\"~.10f\"/>~n"
        "\t<diffuse_reflect fval=\"~.10f\"/>~n"
        "\t<glossy_reflect fval=\"~.10f\"/>~n"
        "\t<sss_transmit fval=\"~.10f\"/>~n"
        "\t<exponent fval=\"~.10f\"/>~n",
        [IOR, SigmaSfactor, DiffuseReflect, GlossyReflect, SSS_Translucency, Exponent]),
    %
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
            case export_modulator(F, [Name,$_,format(N)], Maps, M, Opacity) of
                off -> N+1;
                ok ->
                    println(F),
                    N+1
                end;
            (_, N) ->
                N % Ignore old modulators
        end, 1, Modulators),

    println(F, "</material>").

%% Glass Material
%%
export_glass_shader(F, Name, Mat, ExportDir, YafaRay) ->
    OpenGL = proplists:get_value(opengl, Mat),
    Maps = proplists:get_value(maps, Mat, []),
    Modulators = proplists:get_value(modulators, YafaRay, def_modulators(Maps)),
    %%
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
        case export_texture(F, [Name,$_,format(N)],
                            Maps, ExportDir, M) of
            off -> N+1;
            ok ->
                println(F),
                N+1
        end;
        (_, N) ->
            N % Ignore old modulators
    end, 1, Modulators),

    println(F,
        "<material name=\"~s\">~n"
        "\t<type sval=\"glass\"/>",
        [Name]),

    DiffuseA = {_,_,_,Opacity} = proplists:get_value(diffuse, OpenGL),

    Specular = alpha(proplists:get_value(specular, OpenGL)),

    DefReflected = Specular,

    DefTransmitted = def_transmitted(DiffuseA),

    %% XXX Wings scaling of shininess is weird. Commonly this value
    %% is the cosine power and as such in the range 0..infinity.
    %% OpenGL limits this to 0..128 which mostly is sufficient.

    println(F,
        "\t<hard fval=\"~.10f\"/>",
        [proplists:get_value(shininess, OpenGL)*128.0]),

    export_rgb(F, mirror_color, proplists:get_value(reflected, YafaRay, DefReflected)),

    export_rgb(F, filter_color, proplists:get_value(transmitted, YafaRay, DefTransmitted)),

    IOR = proplists:get_value(ior, YafaRay, ?DEF_IOR),

    Glass_IR_Depth = proplists:get_value(glass_ir_depth, YafaRay, ?DEF_GLASS_IR_DEPTH),

    TransmitFilter = proplists:get_value(transmit_filter, YafaRay, ?DEF_TRANSMIT_FILTER),

    DefAbsorptionColor = def_absorption_color(proplists:get_value(diffuse, OpenGL)),

    AbsorptionColor = proplists:get_value(absorption_color, YafaRay, DefAbsorptionColor),

    case AbsorptionColor of
        [ ] -> ok;
        {_AbsR,_AbsG,_AbsB} ->
            AbsD =
                proplists:get_value(absorption_dist, YafaRay, ?DEF_ABSORPTION_DIST),
        %%
        export_rgb(F, absorption,
               proplists:get_value(absorption_color, YafaRay, AbsorptionColor)),

            println(F,
                "\t<absorption_dist fval=\"~.10f\"/>\n"
                "\t<transmit_filter fval=\"~.10f\"/>",
                [AbsD,TransmitFilter])
    end,
    DispersionPower = proplists:get_value(dispersion_power, YafaRay, ?DEF_DISPERSION_POWER),
    %%
    case DispersionPower of
        0.0 -> ok;
        _   ->
            DispersionSamples = proplists:get_value(dispersion_samples, YafaRay, ?DEF_DISPERSION_SAMPLES),

            println(F,
                "\t<dispersion_power fval=\"~.10f\"/>\n"
                "\t<dispersion_samples ival=\"~w\"/>",
                [DispersionPower,DispersionSamples])
    end,

    FakeShadows = proplists:get_value(fake_shadows, YafaRay, ?DEF_FAKE_SHADOWS),

    println(F,
        "\t<IOR fval=\"~.10f\"/>\n"
        "\t<glass_internal_reflect_depth ival=\"~w\"/>\n"
        "\t<fake_shadows bval=\"~s\"/>",
        [IOR,Glass_IR_Depth,format(FakeShadows)]),

    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
            case export_modulator(F, [Name,$_,format(N)],Maps, M, Opacity) of
                off -> N+1;
                ok ->
                    println(F),
                    N+1
                end;
            (_, N) ->
                N % Ignore old modulators
        end, 1, Modulators),

    println(F, "</material>").

%%% Export Rough Glass Material
%%%

export_rough_glass_shader(F, Name, Mat, ExportDir, YafaRay) ->

    OpenGL = proplists:get_value(opengl, Mat),

    Maps = proplists:get_value(maps, Mat, []),

    Modulators = proplists:get_value(modulators, YafaRay, def_modulators(Maps)),

    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
            case export_texture(F, [Name,$_,format(N)], Maps, ExportDir, M) of
                    off -> N+1;
                    ok ->
                        println(F),
                        N+1
                end;
            (_, N) ->
                N % Ignore old modulators
        end, 1, Modulators),

    println(F,
        "<material name=\"~s\">\n"
        "\t<type sval=\"rough_glass\"/>",
        [Name]),

    DiffuseA = {_,_,_,Opacity} = proplists:get_value(diffuse, OpenGL),

    Specular = alpha(proplists:get_value(specular, OpenGL)),

    DefReflected = Specular,

    DefTransmitted = def_transmitted(DiffuseA),

    %% XXX Wings scaling of shininess is weird. Commonly this value
    %% is the cosine power and as such in the range 0..infinity.
    %% OpenGL limits this to 0..128 which mostly is sufficient.
    println(F,
        "\t<hard fval=\"~.10f\"/>",
        [proplists:get_value(shininess, OpenGL)*128.0]),

    export_rgb(F, mirror_color, proplists:get_value(reflected, YafaRay, DefReflected)),

    export_rgb(F, filter_color, proplists:get_value(transmitted, YafaRay, DefTransmitted)),

    IOR = proplists:get_value(ior, YafaRay, ?DEF_IOR),

    TransmitFilter = proplists:get_value(transmit_filter, YafaRay, ?DEF_TRANSMIT_FILTER),

    Roughness = proplists:get_value(roughness, YafaRay, ?DEF_ROUGHNESS),

    DefAbsorptionColor = def_absorption_color(proplists:get_value(diffuse, OpenGL)),

    AbsorptionColor = proplists:get_value(absorption_color, YafaRay, DefAbsorptionColor),

    case AbsorptionColor of
        [ ] -> ok;
        {_AbsR,_AbsG,_AbsB} ->
            AbsD = proplists:get_value(absorption_dist, YafaRay, ?DEF_ABSORPTION_DIST),

            export_rgb(F, absorption, proplists:get_value(absorption_color, YafaRay, AbsorptionColor)),

            println(F,
                "<absorption_dist fval=\"~.10f\"/>\n"
                "\t<transmit_filter fval=\"~.10f\"/>\n"
                "\t<roughness fval=\"~.10f\"/>",
                [AbsD,TransmitFilter,Roughness])
    end,

    DispersionPower = proplists:get_value(dispersion_power, YafaRay, ?DEF_DISPERSION_POWER),
    case DispersionPower of
        0.0 -> ok;
        _   ->
            DispersionSamples =
                proplists:get_value(dispersion_samples, YafaRay, ?DEF_DISPERSION_SAMPLES),

            println(F,
                "\t<dispersion_power fval=\"~.10f\"/>\n"
                "\t<dispersion_samples ival=\"~w\"/>",
                [DispersionPower,DispersionSamples])
    end,

    FakeShadows = proplists:get_value(fake_shadows, YafaRay, ?DEF_FAKE_SHADOWS),

    println(F,
        "\t<IOR fval=\"~.10f\"/>\n"
        "\t<fake_shadows bval=\"~s\"/>",
        [IOR,format(FakeShadows)]),
    %
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
            case export_modulator(F, [Name,$_,format(N)], Maps, M, Opacity) of
                    off -> N+1;
                    ok ->
                        println(F),
                        N+1
                end;
            (_, N) ->
                N % Ignore old modulators
        end, 1, Modulators),
    println(F, "</material>").

%%% Export Light Material
%%%

export_lightmat_shader(F, Name, Mat, ExportDir, YafaRay) ->
    OpenGL = proplists:get_value(opengl, Mat),
    Maps = proplists:get_value(maps, Mat, []),
    Modulators = proplists:get_value(modulators, YafaRay, def_modulators(Maps)),
    %
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
            case export_texture(F, [Name,$_,format(N)], Maps, ExportDir, M) of
                    off -> N+1;
                    ok ->
                        println(F),
                        N+1
                end;
            (_, N) ->
                N % Ignore old modulators
        end, 1, Modulators),
    println(F,
        "<material name=\"~s\">\n"
        "\t<type sval=\"light_mat\"/>",
        [Name]),

    _DiffuseA = {_,_,_,Opacity} = proplists:get_value(diffuse, OpenGL),

    DefLightmatColor = def_lightmat_color(proplists:get_value(diffuse, OpenGL)),

    Lightmat_Color = proplists:get_value(lightmat_color, YafaRay, DefLightmatColor),

    %% XXX Wings scaling of shininess is weird. Commonly this value
    %% is the cosine power and as such in the range 0..infinity.
    %% OpenGL limits this to 0..128 which mostly is sufficient.

    export_rgb(F, color, proplists:get_value(lightmat_color, YafaRay, Lightmat_Color)),

    Lightmat_Power = proplists:get_value(lightmat_power, YafaRay, ?DEF_LIGHTMAT_POWER),

    println(F, "\t<power fval=\"~.10f\"/>~n", [Lightmat_Power]),
    %
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
            case export_modulator(F, [Name,$_,format(N)], Maps, M, Opacity) of
                    off -> N+1;
                    ok ->
                        println(F),
                        N+1
                end;
            (_, N) ->
                N % Ignore old modulators
        end, 1, Modulators),

    println(F, "</material>").

%%% Start Blend Materials Export

export_shaderblend(F, Name, Mat, ExportDir) ->

    YafaRay = proplists:get_value(?TAG, Mat, []),

    DefShaderType = get_pref(shader_type, YafaRay),

    ShaderType = proplists:get_value(shader_type, YafaRay, DefShaderType),

    case ShaderType of
        blend_mat ->
            export_blend_mat_shader(F, Name, Mat, ExportDir, YafaRay);

        shinydiffuse ->
            ok;
        glossy ->
            ok;
        coatedglossy ->
            ok;
        translucent ->
            ok;
       glass ->
            ok;
       lightmat ->
            ok;
       rough_glass ->
           ok

        end.

%%% Export Blend Material

export_blend_mat_shader(F, Name, Mat, ExportDir, YafaRay) ->
    OpenGL = proplists:get_value(opengl, Mat),
    Maps = proplists:get_value(maps, Mat, []),
    Modulators = proplists:get_value(modulators, YafaRay, def_modulators(Maps)),
    %%
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
            case export_texture(F, [Name,$_,format(N)], Maps, ExportDir, M) of
                off -> N+1;
                ok ->
                    println(F),
                    N+1
                end;
            (_, N) ->
                N % Ignore old modulators
        end, 1, Modulators),

    println(F,
        "<material name=\"~s\">\n"
        "\t<type sval=\"blend_mat\"/>",
        [Name]),

    DiffuseA = {_,_,_,Opacity} = proplists:get_value(diffuse, OpenGL),

    Specular = alpha(proplists:get_value(specular, OpenGL)),

    DefReflected = Specular,

    DefTransmitted = def_transmitted(DiffuseA),

    %% XXX Wings scaling of shininess is weird. Commonly this value
    %% is the cosine power and as such in the range 0..infinity.
    %% OpenGL limits this to 0..128 which mostly is sufficient.

    println(F,
        "\t<hard fval=\"~.10f\"/>",
        [proplists:get_value(shininess, OpenGL)*128.0]),

    export_rgb(F, color, proplists:get_value(reflected, YafaRay, DefReflected)),

    export_rgb(F, diffuse_color, proplists:get_value(transmitted, YafaRay, DefTransmitted)),

    Blend_Mat1 = proplists:get_value(blend_mat1, YafaRay, ?DEF_BLEND_MAT1),

    Blend_Mat2 = proplists:get_value(blend_mat2, YafaRay, ?DEF_BLEND_MAT2),

    Blend_Value = proplists:get_value(blend_value, YafaRay, ?DEF_BLEND_VALUE),

    println(F,
        "<material1 sval=\"""w_""\~s\"/>\n"
        "\t<material2 sval=\"""w_""\~s\"/>\n"
        "\t<blend_value fval=\"~.10f\"/>",
        [Blend_Mat1, Blend_Mat2, Blend_Value]),
    %
    foldl(fun ({modulator,Ps}=M, N) when is_list(Ps) ->
            case export_modulator(F, [Name,$_,format(N)], Maps, M, Opacity) of
                off -> N+1;
                ok ->
                    println(F),
                    N+1
                end;
            (_, N) ->
                N % Ignore old modulators
        end, 1, Modulators),

    println(F, "</material>").
