%%
%%  yaf_materials.erl
%%
%%  YafaRay Materials User Interface.
%%
%%  Copyright (c) 2003-2008 Raimo Niskanen
%%  Code Converted from Yafray to YafaRay by Bernard Oortman (Wings3d user oort)
%%  Meshlight Export Perfected with Assistance from Micheus
%%  See the file "license.terms" for information on usage and redistribution
%%  of this file, and for a DISCLAIMER OF ALL WARRANTIES.
%%
%%


%%% Object Specific Material Properties
%%%

material_dialog(_Name, Mat) ->
    Maps = proplists:get_value(maps, Mat, []),

    OpenGL = proplists:get_value(opengl, Mat),

    DefReflected = alpha(proplists:get_value(specular, OpenGL)),

    DefTransmitted = def_transmitted(proplists:get_value(diffuse, OpenGL)),

    DefAbsorptionColor = def_absorption_color(proplists:get_value(diffuse, OpenGL)),

    DefLightmatColor = def_lightmat_color(proplists:get_value(diffuse, OpenGL)),

    YafaRay = proplists:get_value(?TAG, Mat, []),

    Minimized = proplists:get_value(minimized, YafaRay, true),

    ObjectMinimized = proplists:get_value(object_minimized, YafaRay, true),

    DefShaderType = get_pref(shader_type, YafaRay),

    ShaderType = proplists:get_value(shader_type, YafaRay, DefShaderType),

%*    UseHardness = proplists:get_value(use_hardness, YafaRay, ?DEF_USE_HARDNESS),

    Object_Type = proplists:get_value(object_type, YafaRay, ?DEF_OBJECT_TYPE),

    Volume_Type = proplists:get_value(volume_type, YafaRay, ?DEF_VOLUME_TYPE),

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

    Meshlight_Double_Sided = proplists:get_value(meshlight_double_sided, YafaRay, ?DEF_MESHLIGHT_DOUBLE_SIDED),

    TIR = proplists:get_value(tir, YafaRay, ?DEF_TIR),

    AutosmoothAngle = proplists:get_value(autosmooth_angle, YafaRay, ?DEF_AUTOSMOOTH_ANGLE),

    Autosmooth = proplists:get_value(autosmooth, YafaRay,
                    if AutosmoothAngle == 0.0 -> false;
                    true -> ?DEF_AUTOSMOOTH end),

%%% IOR Material Property for all Materials except Glossy
%%%
    IOR = proplists:get_value(ior, YafaRay, ?DEF_IOR),

%%% Color Properties Transmitted = Diffuse and Refracted
%%% Color Properties Reflected = Glossy and Reflected
%%%
    Reflected = proplists:get_value(reflected, YafaRay, DefReflected),

    Transmitted = proplists:get_value(transmitted, YafaRay, DefTransmitted),

%%% Glass Properties
%%%
    AbsorptionColor = proplists:get_value(absorption_color, YafaRay,    DefAbsorptionColor),

    AbsorptionDist = proplists:get_value(absorption_dist, YafaRay,      ?DEF_ABSORPTION_DIST),

    DispersionPower = proplists:get_value(dispersion_power, YafaRay,    ?DEF_DISPERSION_POWER),

    DispersionSamples = proplists:get_value(dispersion_samples, YafaRay, ?DEF_DISPERSION_SAMPLES),

    FakeShadows = proplists:get_value(fake_shadows, YafaRay,            ?DEF_FAKE_SHADOWS),

    Roughness = proplists:get_value(roughness, YafaRay,                 ?DEF_ROUGHNESS),

    Glass_IR_Depth = proplists:get_value(glass_ir_depth, YafaRay,       ?DEF_GLASS_IR_DEPTH),

%%% Shiny Diffuse Properties
%%% Transmit Filter also for Glass and Rough Glass

    Transparency = proplists:get_value(transparency, YafaRay,           ?DEF_TRANSPARENCY),

    TransmitFilter = proplists:get_value(transmit_filter, YafaRay,      ?DEF_TRANSMIT_FILTER),

    Translucency = proplists:get_value(translucency, YafaRay,           ?DEF_TRANSLUCENCY),

    SpecularReflect = proplists:get_value(specular_reflect, YafaRay,    ?DEF_SPECULAR_REFLECT),

    Emit = proplists:get_value(emit, YafaRay, ?DEF_EMIT),

%%% Translucency (SSS) Properties
%%%
    SSS_AbsorptionColor = proplists:get_value(sss_absorption_color, YafaRay,    ?DEF_SSS_ABSORPTION_COLOR),

    ScatterColor = proplists:get_value(scatter_color, YafaRay,                  ?DEF_SCATTER_COLOR),

    SigmaSfactor = proplists:get_value(sigmas_factor, YafaRay,                  ?DEF_SIGMAS_FACTOR),

    SSS_Translucency = proplists:get_value(sss_translucency, YafaRay,           ?DEF_SSS_TRANSLUCENCY),

    SSS_Specular_Color = proplists:get_value(sss_specular_color, YafaRay,       ?DEF_SSS_SPECULAR_COLOR),

%%% Shiny Diffuse, Glossy, Coated Glossy Properties
%%%
    DiffuseReflect = proplists:get_value(diffuse_reflect, YafaRay,      ?DEF_DIFFUSE_REFLECT),

    OrenNayar = proplists:get_value(oren_nayar, YafaRay,                ?DEF_OREN_NAYAR),

    OrenNayar_Sigma = proplists:get_value(oren_nayar_sigma, YafaRay,    ?DEF_OREN_NAYAR_SIGMA),

%%% Glossy and Coated Glossy Properties
%%%
    GlossyReflect = proplists:get_value(glossy_reflect, YafaRay,?DEF_GLOSSY_REFLECT),

    Exponent = proplists:get_value(exponent, YafaRay,           ?DEF_EXPONENT),

    Anisotropic = proplists:get_value(anisotropic, YafaRay,     ?DEF_ANISOTROPIC),

    Anisotropic_U = proplists:get_value(anisotropic_u, YafaRay, ?DEF_ANISOTROPIC_U),

    Anisotropic_V = proplists:get_value(anisotropic_v, YafaRay, ?DEF_ANISOTROPIC_V),

%%% Light Material Properties
%%%
    Lightmat_Color = proplists:get_value(lightmat_color, YafaRay,    DefLightmatColor),

    Lightmat_Power = proplists:get_value(lightmat_power, YafaRay,    ?DEF_LIGHTMAT_POWER),

%%% Blend Material Properties
%%%
    Blend_Mat1 = proplists:get_value(blend_mat1, YafaRay,        ?DEF_BLEND_MAT1),

    Blend_Mat2 = proplists:get_value(blend_mat2, YafaRay,        ?DEF_BLEND_MAT2),

    Blend_Value = proplists:get_value(blend_value, YafaRay,       ?DEF_BLEND_VALUE),

%%% Object Specific Material Properties Dialog
%%%
    Modulators = proplists:get_value(modulators, YafaRay, def_modulators(Maps)),

    ObjectFrame =
        {vframe,[
            {hframe,[
                {?__(6,"Autosmooth"),Autosmooth,[key(autosmooth)]},
                {label,?__(7,"Angle")},
                {slider,{text,AutosmoothAngle,
                    [range(autosmooth_angle),{width,5},key(autosmooth_angle),hook(enable, ?KEY(autosmooth))]}
                },help_button({material_dialog,object})
            ]},
            %%% Object Type Menu
            {hframe,[
                {vframe,[
                    {menu,[
                        {?__(31,"Mesh"),mesh},
                        {?__(32,"Volume"),volume},
                        {?__(33,"Mesh Light"),meshlight}
                    ], Object_Type, [key(object_type),layout]
                    },
                    {hframe,[
                        {menu,[
                            {?__(82,"Uniform"),uniformvolume},
                            {?__(83,"ExpDensity"),expdensityvolume},
                            {?__(126,"Noise"),noisevolume}
                        ], Volume_Type, [key(volume_type),layout]
                        },
                        %% Uniform Volume
                        {hframe,[
                            {vframe,[
                                {label,?__(84,"Absorption")},
                                {label,?__(85,"Scatter")},
                                {label,?__(86,"AttgridScale")}
                            ]},
                            {vframe,[
                                {text,Volume_Sigma_a,[range(volume_sigma_a),key(volume_sigma_a)]},
                                {text,Volume_Sigma_s,[range(volume_sigma_s),key(volume_sigma_s)]},
                                {text,Volume_Attgridscale,[range(volume_attgridscale),key(volume_attgridscale)]}
                            ]},
                            {vframe,[
                                {label,?__(133,"Min/Max X")},
                                {label,?__(134,"Min/Max Y")},
                                {label,?__(135,"Min/Max Z")}
                            ]},
                            {vframe,[
                                {text,Volume_Minmax_X,[range(volume_minmax_x),key(volume_minmax_x)]},
                                {text,Volume_Minmax_Y,[range(volume_minmax_y),key(volume_minmax_y)]},
                                {text,Volume_Minmax_Z,[range(volume_minmax_z),key(volume_minmax_z)]}
                            ]}
                        ],[hook(open, [member, ?KEY(volume_type), uniformvolume])]
                        },
                        %% ExpDensity Volume
                        {hframe,[
                            {vframe,[
                                {label,?__(88,"Absorption")},
                                {label,?__(89,"Scatter")},
                                {label,?__(86,"AttgridScale")}
                            ]},
                            {vframe,[
                                {text,Volume_Sigma_a,[range(volume_sigma_a),key(volume_sigma_a)]},
                                {text,Volume_Sigma_s,[range(volume_sigma_s),key(volume_sigma_s)]},
                                {text,Volume_Attgridscale,[range(volume_attgridscale),key(volume_attgridscale)]}
                            ]},
                            {vframe,[
                                {label,?__(90,"Height")},
                                {label,?__(91,"Steepness")}
                            ]},
                            {vframe,[
                                {text,Volume_Height,[range(volume_height),key(volume_height)]},
                                {text,Volume_Steepness,[range(volume_steepness),key(volume_steepness)]}
                            ]},
                            {vframe,[
                                {label,?__(136,"Min/Max X")},
                                {label,?__(137,"Min/Max Y")},
                                {label,?__(138,"Min/Max Z")}
                            ]},
                            {vframe,[
                                {text,Volume_Minmax_X,[range(volume_minmax_x),key(volume_minmax_x)]},
                                {text,Volume_Minmax_Y,[range(volume_minmax_y),key(volume_minmax_y)]},
                                {text,Volume_Minmax_Z,[range(volume_minmax_z),key(volume_minmax_z)]}
                            ]}
                        ],[hook(open, [member, ?KEY(volume_type), expdensityvolume])]
                        },
                        %% Noise Volume
                        {hframe,[
                            {vframe,[
                                {label,?__(127,"Absorption")},
                                {label,?__(128,"Scatter")},
                                {label,?__(129,"AttgridScale")}
                            ]},
                            {vframe,[
                                {text,Volume_Sigma_a,[range(volume_sigma_a),key(volume_sigma_a)]},
                                {text,Volume_Sigma_s,[range(volume_sigma_s),key(volume_sigma_s)]},
                                {text,Volume_Attgridscale,[range(volume_attgridscale),key(volume_attgridscale)]}
                            ]},
                            {vframe,[
                                {label,?__(130,"Sharpness")},
                                {label,?__(131,"Cover")},
                                {label,?__(132,"Density")}
                            ]},
                            {vframe,[
                                {text,Volume_Sharpness,[range(volume_sharpness),key(volume_sharpness)]},
                                {text,Volume_Cover,[range(volume_cover),key(volume_cover)]},
                                {text,Volume_Density,[range(volume_density),key(volume_density)]}
                            ]},
                            {vframe,[
                                {label,?__(139,"Min/Max X")},
                                {label,?__(140,"Min/Max Y")},
                                {label,?__(141,"Min/Max Z")}
                            ]},
                            {vframe,[
                                {text,Volume_Minmax_X,[range(volume_minmax_x),key(volume_minmax_x)]},
                                {text,Volume_Minmax_Y,[range(volume_minmax_y),key(volume_minmax_y)]},
                                {text,Volume_Minmax_Z,[range(volume_minmax_z),key(volume_minmax_z)]}
                            ]}
                        ],[hook(open, [member, ?KEY(volume_type), noisevolume])]
                        }
                    ],[hook(open, [member, ?KEY(object_type), volume])]
                    },
                    {hframe,[
                        {vframe,[
                            {label,?__(121,"Power")},
                            {label,?__(122,"Samples")}
                        ]},
                        {vframe,[
                            {text,Meshlight_Power,[range(meshlight_power),{width,5},key(meshlight_power)]},
                            {text,Meshlight_Samples,[range(meshlight_samples),{width,5},key(meshlight_samples)]}
                        ]},
                        {vframe,[
                            {label,?__(123,"Color")}]},
                        {vframe,[
                            {slider, {color, Meshlight_Color, [key(meshlight_color)]}}
                        ]},
                        {vframe,[
                            {button,"Set Default",keep,[diffuse_hook(?KEY(meshlight_color))]},
                            {?__(124,"Double Sided"),Meshlight_Double_Sided,[key(meshlight_double_sided)]}
                        ]}
                    ],[hook(open, [member, ?KEY(object_type), meshlight])]
                    }
                ],[{title,?__(113,"Object Type")}]
                }
            ]}
        %%% End Object Type Menu
        ],[{title,?__(8,"Object Parameters")},{minimized,ObjectMinimized}, key(object_minimized)]
        },

%%% Shader Specific Material Properties Dialog
%%%

    ShaderFrame =
        {vframe,[
            {menu,[
                {?__(9,"Shiny Diffuse"),shinydiffuse},
                {?__(29,"Glass"),glass},
                {"Rough Glass",rough_glass},
                {"Glossy",glossy},
                {"Coated Glossy",coatedglossy},
                {"Translucent (SSS)",translucent}, % add flags for YafaRay 0.1.3 exp?
                {"Light Material",lightmat},
                {"Blend",blend_mat}
            ], ShaderType, [key(shader_type),layout]
            },
            %%% Shiny Diffuse Material
            {hframe,[
                {hframe,[help_button(shiny_help_dialog)]},
                {vframe,[
                    {label, "Index of Refraction"},
                    {label, "Reflected Color"},
                    {label, "Diffuse Color"},
                    {label, "Transparency"},
                    {label, "Transmit Filter"},
                    {label, "Translucency"},
                    {label, "Diffuse Reflection"},
                    {label, "Mirror Reflection"},
                    {label, "Emit Light"},
                    {"Oren-Nayar",OrenNayar,[key(oren_nayar)]},
                    %{"Fresnel Effect",TIR,[key(tir)]}, %% povman . test move
                    panel
                ]},
                {vframe,[
                    {slider, {text, IOR,[range(ior),{width,5}, key(ior)]}},
                    {slider, {color, Reflected, [key(reflected)]}},
                    {slider, {color, Transmitted, [key(transmitted)]}},
                    {slider, {text,Transparency,[range(transparency), key(transparency)]}},
                    {slider, {text,TransmitFilter,[range(transmit_filter), key(transmit_filter)]}},
                    {slider, {text,Translucency,[range(translucency), key(translucency)]}},
                    {slider, {text,DiffuseReflect,[range(diffuse_reflect), key(diffuse_reflect)]}},
                    {slider, {text,SpecularReflect,[range(specular_reflect), key(specular_reflect)]}},
                    {slider, {text,Emit,[range(emit),{width,8}, key(emit)]}},
                    %%
                    {hframe,[
                        {label, "Sigma"},
                        {text,OrenNayar_Sigma,[
                            range(oren_nayar_sigma),
                            key(oren_nayar_sigma),
                            hook(enable, ['not',[member,?KEY(oren_nayar), ?DEF_OREN_NAYAR]])
                        ]},
                        {"Fresnel Effect",TIR,[key(tir)]}
                    ]}
                ]},
                {vframe,[
                    panel,panel,
                        {button,"Set Default",keep,[diffuse_hook(?KEY(transmitted))]}
                ]}
            ],[hook(open, [member, ?KEY(shader_type), shinydiffuse])]
            },
            %%% Glass Material
            {hframe,[
                {vframe,[
                    {label, "Index of Refraction"},
                    {label, "Internal Reflection"},
                    {label, "Reflected Light"},
                    {label, "Filtered Light"},
                    {label, "Absorption Color"},
                    {label, "Absorption Distance"},
                    {label, "Transmit Filter"},
                    {label, "Dispersion Power"},
                    {label, "Dispersion Samples"},
                    {"Fake Shadows",FakeShadows,[key(fake_shadows)]},
                    panel
                ]},
                {vframe,[
                    {slider, {text, IOR,[range(ior),{width,5}, key(ior)]}},
                    {slider, {text, Glass_IR_Depth,[range(glass_ir_depth),{width,5}, key(glass_ir_depth)]}},
                    {slider, {color, Reflected, [key(reflected)]}},
                    {slider, {color, Transmitted, [key(transmitted)]}},
                    {slider, {color, AbsorptionColor,[key(absorption_color)]}},
                    {slider, {text, AbsorptionDist,[range(absorption_dist),{width,8}, key(absorption_dist)]}},
                    {slider, {text, TransmitFilter,[range(transmit_filter), key(transmit_filter)]}},
                    {slider, {text, DispersionPower,[range(dispersion_power), key(dispersion_power)]}},
                    {slider, {text, DispersionSamples,[range(dispersion_samples),{width,8}, key(dispersion_samples),
                                                        hook(enable, ['not',[member,?KEY(dispersion_power),0.0]])]}
                    }]
                },
                {vframe,[
                    panel,panel,panel,
                    {button,"Set Default",keep,[transmitted_hook(?KEY(transmitted))]},
                    {button,"Set Default",keep,[diffuse_hook(?KEY(absorption_color))]}
                ]}
            ],[hook(open, [member, ?KEY(shader_type), glass])]
            },
            %%% Rough Glass Material
            {hframe,[
                {vframe,[
                    {label, "Index of Refraction"},
                    {label, "Reflected Light"},
                    {label, "Filtered Light"},
                    {label, "Absorption Color"},
                    {label, "Absorption Distance"},
                    {label, "Transmit Filter"},
                    {label, "Roughness"},
                    {label, "Dispersion Power"},
                    {label, "Dispersion Samples"},
                    {"Fake Shadows",FakeShadows,[key(fake_shadows)]},
                    panel
                ]},
                {vframe,[
                    {slider, {text, IOR,[range(ior),{width,5}, key(ior)]}},
                    {slider, {color, Reflected, [key(reflected)]}},
                    {slider, {color, Transmitted, [key(transmitted)]}},
                    {slider, {color,AbsorptionColor,[key(absorption_color)]}},
                    {slider, {text, AbsorptionDist,[range(absorption_dist),{width,8}, key(absorption_dist)]}},
                    {slider, {text,TransmitFilter,[range(transmit_filter), key(transmit_filter)]}},
                    {slider, {text,Roughness,[range(roughness), key(roughness)]}},
                    {slider, {text,DispersionPower,[range(dispersion_power), key(dispersion_power)]}},
                    {slider, {text,DispersionSamples,[range(dispersion_samples), {width,8}, key(dispersion_samples),
                                hook(enable, ['not',[member,?KEY(dispersion_power),0.0]])]}}
                ]},
                {vframe,[
                    panel, panel,
                    {button,"Set Default",keep,[transmitted_hook(?KEY(transmitted))]}
                ]}
            ],[hook(open, [member, ?KEY(shader_type), rough_glass])]
            },
            %%% Glossy Material
            {hframe,[
                {hframe,[help_button(glossy_help_dialog)]},
                {vframe,[
                    {label, "Glossy Color"}, {label, "Diffuse Color"},
                    {label, "Diffuse Reflection"},{label, "Glossy Reflection"},{label, "Exponent"},
                    {"Oren-Nayar",OrenNayar,[key(oren_nayar)]},
                    panel
                ]},
                {vframe,[
                    {slider, {color, Reflected, [key(reflected)]}},
                    {slider, {color, Transmitted, [key(transmitted)]}},
                    {slider, {text,DiffuseReflect,[range(diffuse_reflect), key(diffuse_reflect)]}},
                    {slider, {text,GlossyReflect,[range(glossy_reflect), key(glossy_reflect)]}},
                    {slider, {text,Exponent,[range(exponent),{width,8}, key(exponent)]}},
                    {hframe,[
                        {label, "Sigma"},
                        {text,OrenNayar_Sigma,[range(oren_nayar_sigma), key(oren_nayar_sigma),
                            hook(enable, ['not',[member,?KEY(oren_nayar), ?DEF_OREN_NAYAR]])]}
                    ]}
                ]},
                {vframe,[
                    panel,
                    {button,"Set Default",keep, [diffuse_hook(?KEY(transmitted))]}
                ]}
            ],[hook(open, [member, ?KEY(shader_type), glossy])]
            },
            %%% Coated Glossy Material
            %%%
            {hframe,[
                {vframe,[
                    {label, "Index of Refraction"},
                    {label, "Glossy Color"},
                    {label, "Diffuse Color"},
                    {label, "Diffuse Reflection"},
                    {label, "Glossy Reflection"},
                    {label, "Exponent"},
                    {"Anisotropic",Anisotropic,[key(anisotropic)]},
                    {"Oren-Nayar",OrenNayar,[key(oren_nayar)]},
                    panel
                ]},
                {vframe,[
                    {slider, {text, IOR,[range(ior),{width,5}, key(ior)]}},
                    {slider, {color, Reflected, [key(reflected)]}},
                    {slider, {color, Transmitted, [key(transmitted)]}},
                    {slider, {text,DiffuseReflect,[range(diffuse_reflect), key(diffuse_reflect)]}},
                    {slider, {text,GlossyReflect,[range(glossy_reflect), key(glossy_reflect)]}},
                    {slider, {text,Exponent,[range(exponent),{width,8}, key(exponent),
                                hook(enable, [member,?KEY(anisotropic), ?DEF_ANISOTROPIC])]}},

                    {hframe,[
                        {label, "Exp U"},
                        {text, Anisotropic_U,[range(anisotropic_u), key(anisotropic_u),
                                            hook(enable, ['not',[member,?KEY(anisotropic), ?DEF_ANISOTROPIC]])]},
                        {label, "Exp V"},
                        {text,Anisotropic_V,[range(anisotropic_v), key(anisotropic_v),
                                            hook(enable, ['not',[member,?KEY(anisotropic), ?DEF_ANISOTROPIC]])]}
                    ]},
                    {hframe,[
                        {label, "Sigma"},
                        {text,OrenNayar_Sigma,[range(oren_nayar_sigma), key(oren_nayar_sigma),
                                                hook(enable, ['not',[member,?KEY(oren_nayar), ?DEF_OREN_NAYAR]])]}
                    ]}
                ]},
                {vframe,[
                    panel,
                    panel,
                    {button,"Set Default",keep, [diffuse_hook(?KEY(transmitted))]}
                ]}
            ],[hook(open, [member, ?KEY(shader_type), coatedglossy])]
            },
            %%% Translucent (SSS) Material
            {hframe,[
                {vframe,[
                    {label, "Index of Refraction"},
                    {label, "Glossy Color"},
                    {label, "Diffuse Color"},
                    {label, "Specular Color"},
                    {label, "Absorption Color"},
                    {label, "Absorption Distance"},
                    {label, "Scatter Color"},
                    {label, "SigmaSfactor"},
                    {label, "Diffuse Reflection"},
                    {label, "Glossy Reflection"},
                    {label, "Translucency"},
                    {label, "Exponent"},
                    panel
                ]},
                {vframe,[
                    {slider, {text, IOR,[range(ior),{width,5}, key(ior)]}},
                    {slider, {color, Reflected, [key(reflected)]}},
                    {slider, {color, Transmitted, [key(transmitted)]}},
                    {slider, {color, SSS_Specular_Color, [key(sss_specular_color)]}},
                    {slider, {color,SSS_AbsorptionColor,[key(sss_absorption_color)]}},
                    {slider, {text, AbsorptionDist,[range(absorption_dist), {width,8}, key(absorption_dist)]}},
                    {slider, {color,ScatterColor,[key(scatter_color)]}},
                    {slider, {text,SigmaSfactor,[range(sigmas_factor),{width,8}, key(sigmas_factor)]}},
                    {slider, {text,DiffuseReflect,[range(diffuse_reflect), key(diffuse_reflect)]}},
                    {slider, {text,GlossyReflect,[range(glossy_reflect), key(glossy_reflect)]}},
                    {slider, {text,SSS_Translucency,[range(sss_translucency), key(sss_translucency)]}},
                    {slider, {text,Exponent,[range(exponent),{width,8}, key(exponent)]}}
                ]},
                {vframe,[
                    panel,
                    panel,
                    {button,"Set Default", keep, [diffuse_hook(?KEY(transmitted))]}
                ]}
            ],[hook(open, [member, ?KEY(shader_type), translucent])]
            },
            %%% Light Material
            {hframe,[
                {vframe,[
                    {label, "Color"},
                    {label, "Power"},
                    panel
                ]},
                {vframe,[
                    {slider, {color, Lightmat_Color, [key(lightmat_color)]}},
                    {slider, {text,Lightmat_Power,[range(lightmat_power), key(lightmat_power)]}}
                ]},
                {vframe,[
                    {button,"Set Default",keep, [diffuse_hook(?KEY(lightmat_color))]}
                ]}
            ],[hook(open, [member, ?KEY(shader_type), lightmat])]
            },
            %%% Blend Material
            {hframe,[
                {vframe,[
                    {label, "Material 1"},
                    {label, "Material 2"},
                    {label, "Blend Mix"},
                    panel
                ]},
                {vframe,[
                    {text,Blend_Mat1,[key(blend_mat1)]},
                    {text,Blend_Mat2,[key(blend_mat2)]},
                    {slider, {text,Blend_Value,[range(blend_value), key(blend_value)]}}
                ]}
            ],[hook(open, [member, ?KEY(shader_type), blend_mat])]
            }
        ]},

    %% Shader types slots
    [
        {vframe,[
            ObjectFrame,
            ShaderFrame,
            {vframe, modulator_dialogs(Modulators, Maps),[hook(open, ['not',[member,?KEY(shader_type),block]])]}
        ],[{title,?__(28,"YafaRay Options")},{minimized,Minimized},key(minimized)]}
    ].