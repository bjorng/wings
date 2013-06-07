%%
%%  yaf_lights.erl
%%
%%  YafaRay Lights User Interface.
%%
%%  Copyright (c) 2003-2008 Raimo Niskanen
%%  Code Converted from Yafray to YafaRay by Bernard Oortman (Wings3d user oort)
%%  Meshlight Export Perfected with Assistance from Micheus
%%  See the file "license.terms" for information on usage and redistribution
%%  of this file, and for a DISCLAIMER OF ALL WARRANTIES.
%%
%%

light_dialog(Name, Ps) ->
    OpenGL = proplists:get_value(opengl, Ps, []),

    YafaRay = proplists:get_value(?TAG, Ps, []),

    Type = proplists:get_value(type, OpenGL, []),

    DefPower =
        case Type of
            point -> ?DEF_ATTN_POWER;
            spot -> ?DEF_ATTN_POWER;
            area -> ?DEF_ATTN_POWER;
            _ -> ?DEF_POWER
        end,

    Minimized = proplists:get_value(minimized, YafaRay, true),

    Power = proplists:get_value(power, YafaRay, DefPower),
    [
        {vframe,[
            {hframe,[
                {vframe,[
                    {label,?__(1,"Power")}
                ]},
                {vframe,[
                    {text,Power,[range(power),key(power)]}
                ]},
                panel,
                help_button(light_dialog)
            ]}| light_dialog(Name, Type, YafaRay)
            ],[{title,?__(2,"YafaRay Options")},key(minimized),{minimized,Minimized}]
        }].

%% Point Light Dialog

light_dialog(_Name, point, Ps) ->
    Type = proplists:get_value(type, Ps, ?DEF_POINT_TYPE),

    CastShadows = proplists:get_value(cast_shadows, Ps, ?DEF_CAST_SHADOWS), %% unused in YafaRay 0.1.2

    ArealightRadius = proplists:get_value(arealight_radius, Ps, ?DEF_AREALIGHT_RADIUS),

    ArealightSamples = proplists:get_value(arealight_samples, Ps, ?DEF_AREALIGHT_SAMPLES),

    [
        {vframe,[
            {hradio,[
                {?__(3,"Pointlight"),pointlight},
                {?__(5,"Spherelight"),spherelight}
            ],Type,[key(type),layout]
            },
            {?__(11,"Cast Shadows"),CastShadows,[key(cast_shadows),hook(open,[member,?KEY(type),pointlight])]},
            {vframe,[
                {hframe,[
                    {label,?__(15,"Radius")},
                    {text,ArealightRadius,[range(arealight_radius), key(arealight_radius)]}
                ]},
                {hframe,[
                    {label,?__(17,"Samples")},
                    {text,ArealightSamples,[range(samples),key(arealight_samples)]}
                ]}
            ],[hook(open, [member,?KEY(type),spherelight])]
            }
        ]}
    ];

%% Spot Light Dialog
light_dialog(_Name, spot, Ps) ->
    Type = proplists:get_value(type, Ps, ?DEF_SPOT_TYPE),

    CastShadows = proplists:get_value(cast_shadows, Ps, ?DEF_CAST_SHADOWS),

    SpotPhotonOnly = proplists:get_value(spot_photon_only, Ps, ?DEF_SPOT_PHOTON_ONLY),

    SpotSoftShadows = proplists:get_value(spot_soft_shadows, Ps, ?DEF_SPOT_SOFT_SHADOWS),

    SpotIESFilename = proplists:get_value(spot_ies_filename, Ps, ?DEF_SPOT_IES_FILENAME),

    SpotIESSamples = proplists:get_value(spot_ies_samples, Ps, ?DEF_SPOT_IES_SAMPLES),

    BrowsePropsIES = [
        {dialog_type,open_dialog},
        {extensions,[{".ies",?__(99,"IES")}]}
    ],

    %%
    [
        {hframe,[
            {hradio,[
                {?__(29,"Spotlight"),spotlight},
                {?__(30,"IES"),spot_ies}
            ],Type,[layout,key(type)]
            }
        ]},
        {vframe,[
            {hframe,[
                {?__(97,"Photon Only"),SpotPhotonOnly,[key(spot_photon_only)]},
                {?__(34,"Cast Shadows"),CastShadows,[key(cast_shadows)]},
                {?__(98,"Soft Shadows"),SpotSoftShadows,[key(spot_soft_shadows)]},
                {label,?__(35,"Samples")},
                {text,SpotIESSamples,[range(spot_ies_samples),key(spot_ies_samples),
                    hook(enable, ['not',[member,?KEY(spot_soft_shadows), ?DEF_SPOT_SOFT_SHADOWS]])]}
            ]}
        ],[hook(open, [member,?KEY(type), spotlight])]
        },
        {vframe,[
            {hframe,[
                {label,?__(100,"Filename")},
                {button,{text,SpotIESFilename, [key(spot_ies_filename),{props,BrowsePropsIES}]}}
            ]},
            {hframe,[
                {hframe,[
                    {?__(38,"Soft Shadows"),SpotSoftShadows,[key(spot_soft_shadows)]},
                    {label,?__(37,"Samples")},
                    {text,SpotIESSamples,[range(spot_ies_samples),key(spot_ies_samples),
                        hook(enable, ['not',[member,?KEY(spot_soft_shadows),?DEF_SPOT_SOFT_SHADOWS]])]}
                ]}
            ]}
        ],[hook(open, [member,?KEY(type), spot_ies])]
        }
    ];

%% Infinite Light Dialog
light_dialog(_Name, infinite, Ps) ->

    Type = proplists:get_value(type, Ps, ?DEF_INFINITE_TYPE),

    CastShadows = proplists:get_value(cast_shadows, Ps, ?DEF_CAST_SHADOWS),

    SunSamples = proplists:get_value(sun_samples, Ps, ?DEF_SUN_SAMPLES),

    SunAngle = proplists:get_value(sun_angle, Ps, ?DEF_SUN_ANGLE),

    SkyBackgroundLight = proplists:get_value(sky_background_light, Ps, ?DEF_SKY_BACKGROUND_LIGHT),
    SkyBackgroundPower = proplists:get_value(sky_background_power, Ps, ?DEF_SKY_BACKGROUND_POWER),
    SkyBackgroundSamples = proplists:get_value(sky_background_samples, Ps, ?DEF_SKY_BACKGROUND_SAMPLES),

    InfiniteTrue = proplists:get_value(infinite_true, Ps, ?DEF_INFINITE_TRUE),

    InfiniteRadius = proplists:get_value(infinite_radius, Ps, ?DEF_INFINITE_RADIUS),

    Bg = proplists:get_value(background, Ps, ?DEF_BACKGROUND),
    %%
    BgColor = proplists:get_value(background_color, Ps, ?DEF_BACKGROUND_COLOR),
    ConstantBackPower = proplists:get_value(constant_back_power, Ps, ?DEF_CONSTANT_BACK_POWER),
    %%
    HorizonColor = proplists:get_value(horizon_color, Ps, ?DEF_HORIZON_COLOR),
    ZenithColor = proplists:get_value(zenith_color, Ps, ?DEF_ZENITH_COLOR),
    GradientBackPower = proplists:get_value(gradient_back_power, Ps, ?DEF_GRADIENT_BACK_POWER),
    %%
    Turbidity = proplists:get_value(turbidity, Ps, ?DEF_TURBIDITY),
    A_var = proplists:get_value(a_var, Ps, ?DEF_SUNSKY_VAR),
    B_var = proplists:get_value(b_var, Ps, ?DEF_SUNSKY_VAR),
    C_var = proplists:get_value(c_var, Ps, ?DEF_SUNSKY_VAR),
    D_var = proplists:get_value(d_var, Ps, ?DEF_SUNSKY_VAR),
    E_var = proplists:get_value(e_var, Ps, ?DEF_SUNSKY_VAR),
    %%

    [
        {vframe,[
            {hradio,[
                {?__(110,"Sunlight"),sunlight},
                {?__(111,"Directional"),directional}
            ],Type,[key(type),layout]
            },
            %% Sunlight Settings Start
            {hframe,[
                {label,?__(114,"Samples")},
                {text,SunSamples,[key(sun_samples),range(sun_samples)]},
                {label,?__(115,"Angle")},
                {text,SunAngle,[key(sun_angle),range(sun_angle)]}
            ],[hook(open, [member,?KEY(type),sunlight])]
            },
            {?__(42,"Cast Shadows"),CastShadows,[key(cast_shadows), hook(open, [member,?KEY(type),sunlight])]},

%% Sunlight Settings End
            {?__(112,"Infinite"),InfiniteTrue,[key(infinite_true),hook(open, [member,?KEY(type),directional])]},

%% Directional Semi-infinite Radius
            {hframe,[
                {label,?__(113,"Semi-infinite Radius")},
                {text,InfiniteRadius,[range(infinite_radius),key(infinite_radius),
                hook(enable, ['not',[member,?KEY(infinite_true),?DEF_INFINITE_TRUE]])]}
            ],[hook(open, [member,?KEY(type),directional])]
            },
            %% this part is for background environment ------------------------------->
            {vframe,[
                {hradio,[
                    {?__(43,"Constant"),constant},
                    {?__(101,"Gradient"),gradientback},
                    {?__(44,"Sunsky"),sunsky},
                    {?__(45,"None"), undefined}
                ],Bg,[layout,key(background)]
                },
        %% Constant Background
                {hframe,[
                    {label,?__(46,"Color")},{color,BgColor,[key(background_color)]},
                    {label,?__(104,"Power")},{text,ConstantBackPower,[key(constant_back_power),range(power)]}
                ],[hook(open, [member,?KEY(background),constant])]
                },
        %% Gradient Background
                {hframe,[
                    {label,?__(102,"Horizon Color")},{color,HorizonColor,[key(horizon_color)]},
                    {label,?__(103,"Zenith Color")},{color,ZenithColor,[key(zenith_color)]},
                    {label,?__(104,"Power")},{text,GradientBackPower,[key(gradient_back_power),range(power)]}
                ],[hook(open, [member,?KEY(background),gradientback])]
                },
        %% Sunsky Background
                {vframe,[
                    {hframe,[]},
                    {hframe,[
                        {vframe,[
                            {label,?__(47,"Turbidity")},
                            {label,"a: "++?__(48,"Horizon Brightness")},
                            {label,"b: "++?__(49,"Horizon Spread")},
                            {label,"c: "++?__(50,"Sun Brightness")},
                            {label,"d: "++?__(51,"Sun Contraction")},
                            {label,"e: "++?__(52,"Sun Backscatter")}
                        ]},
                        {vframe,[
                            {text,Turbidity,[range(turbidity),key(turbidity)]},
                            {text,A_var,[key(a_var)]},
                            {text,B_var,[key(b_var)]},
                            {text,C_var,[key(c_var)]},
                            {text,D_var,[key(d_var)]},
                            {text,E_var,[key(e_var)]}
                        ]}
                    ]},
        %% Start Skylight Settings
                    {?__(116,"Skylight"),SkyBackgroundLight,[key(sky_background_light),
                        hook(open, [member,?KEY(background),sunsky])]},
        %% Skylight Power
                    {hframe,[
                        {label,?__(117,"Power")},
                        {text,SkyBackgroundPower,[range(sky_background_power),key(sky_background_power),
                            hook(enable, ['not',[member,?KEY(sky_background_light), ?DEF_SKY_BACKGROUND_LIGHT]])]}
        %% End Enable Disable Text field
                    ],[hook(open, [member,?KEY(background),sunsky])]
                    },
        %% Skylight Samples
                    {hframe,[
                        {label,?__(118,"Samples")},
                        {text,SkyBackgroundSamples,[range(sky_background_samples),key(sky_background_samples),
                            hook(enable, ['not',[member,?KEY(sky_background_light), ?DEF_SKY_BACKGROUND_LIGHT]])]}
        %% End Enable Disable Text field
                    ],[hook(open, [member,?KEY(background),sunsky])]
                    }
        %% End Skylight Samples

        %% End Skylight Settings
                ],[hook(open, [member,?KEY(background),sunsky])]
                }
            ],[{title,?__(53,"Background")}]
            }
            %% ----------------------------------------------------------->
        ]}
    ];

%% Ambient Light Dialog
light_dialog(_Name, ambient, Ps) ->
    Bg = proplists:get_value(background, Ps, ?DEF_BACKGROUND),
    BgColor = proplists:get_value(background_color, Ps, ?DEF_BACKGROUND_COLOR),
    ConstantBackPower = proplists:get_value(constant_back_power, Ps, ?DEF_CONSTANT_BACK_POWER),
%%
    HorizonColor = proplists:get_value(horizon_color, Ps, ?DEF_HORIZON_COLOR),
    ZenithColor = proplists:get_value(zenith_color, Ps, ?DEF_ZENITH_COLOR),
    GradientBackPower = proplists:get_value(gradient_back_power, Ps, ?DEF_GRADIENT_BACK_POWER),
%%
    BgFnameImage = proplists:get_value(background_filename_image, Ps,
                                       ?DEF_BACKGROUND_FILENAME),
    BrowsePropsImage = [{dialog_type,open_dialog},
                        {extensions,[{".jpg",?__(54,"JPEG compressed image")},
                                     {".tga",?__(55,"Targa bitmap")}]}],
    BgFnameHDRI = proplists:get_value(background_filename_HDRI, Ps,
                                      ?DEF_BACKGROUND_FILENAME),
    BrowsePropsHDRI = [{dialog_type,open_dialog},
                       {extensions,[{".hdr",?__(56,"High Dynamic Range image")},
                                    {".exr",?__(95,"OpenEXR image")}]}],
    BgExpAdj = proplists:get_value(background_exposure_adjust, Ps,
                                   ?DEF_BACKGROUND_EXPOSURE_ADJUST),
    BgMapping = proplists:get_value(background_mapping, Ps,
                                    ?DEF_BACKGROUND_MAPPING),
    BgPower = proplists:get_value(background_power, Ps,
                                  ?DEF_BACKGROUND_POWER),
    BgPrefilter = proplists:get_value(background_prefilter, Ps,
                                  ?DEF_BACKGROUND_PREFILTER),
    BgEnlight = proplists:get_value(background_enlight, Ps,
                                  ?DEF_BACKGROUND_ENLIGHT),
    %%
    Type = proplists:get_value(type, Ps, ?DEF_AMBIENT_TYPE),
    Samples = proplists:get_value(samples, Ps, ?DEF_SAMPLES),

    %%
    %%
    CacheMinimized = proplists:get_value(cache_minimized, Ps, true),
    Cache = proplists:get_value(cache, Ps, ?DEF_CACHE),
    CacheSize = proplists:get_value(cache_size, Ps, ?DEF_CACHE_SIZE),
    AngleThreshold = proplists:get_value(angle_threshold, Ps,
                                         ?DEF_ANGLE_THRESHOLD),
    AngleKey = ?KEY(angle_threshold),
    AngleRange = range(angle_threshold),
    ShadowThreshold = proplists:get_value(shadow_threshold, Ps,
                                          ?DEF_SHADOW_THRESHOLD),
    Gradient = proplists:get_value(gradient, Ps, ?DEF_GRADIENT),
    ShowSamples = proplists:get_value(show_samples, Ps, ?DEF_SHOW_SAMPLES),
    Search = proplists:get_value(search, Ps, ?DEF_SEARCH),
    %%

    [{hradio,[
        {?__(57,"Hemilight"), hemilight}
        ],
        Type,[layout,key(type)]},
    %% Hemilight and Pathlight


    %% Pathlight
        {vframe,[
            {hframe,[
                {"",Cache,[key(cache)]},
                {hframe,[
                    {vframe,[
                        {label,?__(68,"Size")},
                        {label,?__(69,"Angle Threshold")},
                        panel,
                        {label,?__(70,"Shadow Threshold")},
                        {?__(71,"Gradient"),Gradient,[key(gradient)]},
                        {label,?__(72,"Search")}
                    ]},
                    {vframe,[
                        {text,CacheSize,[key(cache_size),range(cache_size)]},
                        {text,AngleThreshold,[{key,AngleKey},AngleRange]},
                        {slider,[{key,AngleKey},AngleRange]},
                        {text,ShadowThreshold,[key(shadow_threshold), range(shadow_threshold)]},
                        {?__(73,"Show Samples"),ShowSamples,[key(show_samples)]},
                        {text,Search,[key(search),range(cache_search)]}
                    ]}
                ],[{title,?__(74,"Irradiance Cache")},{minimized, CacheMinimized}, key(cache_minimized),hook(enable, ?KEY(cache))]
                }
            ],[hook(enable, ['not',?KEY(direct)])]
            }
        ],[hook(open, [member,?KEY(type),pathlight])]
        },
    %% Global Photonlight

    %% Backgrounds
        {vframe,[
            {hradio,[
                {?__(79,"HDRI"),'HDRI'},
                {?__(80,"Image"),image},
                {?__(81,"Constant"),constant},
                {?__(105,"Gradient"),gradientback},
                {?__(82,"None"), undefined}
            ],Bg,[layout,key(background)]
            },
            % HDRI Background
            {hframe,[
                {label,?__(83,"Filename")},
                {button,{text,BgFnameHDRI,[key(background_filename_HDRI),{props,BrowsePropsHDRI}]}},
                {label,?__(61,"Samples")},
                {text,Samples,[range(samples),key(samples)]}
            ],[hook(open, [member,?KEY(background),'HDRI'])]
            },
            %% Image Background
            {hframe,[
                {label,?__(84,"Filename")},
                {button,{text,BgFnameImage,[key(background_filename_image), {props,BrowsePropsImage}]}},
                {label,?__(60,"Samples")},
                {text,Samples,[range(samples),key(samples)]}
            ],[hook(open, [member,?KEY(background),image])]
            },
            %% HDRI Background Settings
            {hframe,[
                {hframe,[
                    {label,?__(85,"Power")},
                    {text,BgExpAdj,[key(background_exposure_adjust), range(exposure_adjust)]},
                    {menu,[
                        {?__(86,"Light Probe (Angular)"),probe},
                        {?__(87,"Spherical (Lat-Long)"),spherical}
                    ],BgMapping,[key(background_mapping)]
                    }
                ],[hook(open, [member,?KEY(background),'HDRI'])]
                },
                {hframe,[
                    {label,?__(88,"Power")},
                    {text,BgPower,[key(background_power),range(power)]}
                ],[hook(open, [member,?KEY(background),image])]
                },
                {?__(89,"Use IBL"),BgEnlight,[key(background_enlight)]},
                {?__(96,"Prefilter"),BgPrefilter,[key(background_prefilter)]}
            ],[hook(open, [member,?KEY(background),'HDRI',image])]
            },

            %% Constant Background
            {hframe,[
                {label,?__(90,"Color")},
                {color,BgColor,[key(background_color)]},
                {label,?__(109,"Power")},
                {text,ConstantBackPower,[key(constant_back_power),range(power)]}
            ],[hook(open, [member,?KEY(background),constant])]
            },

            %% Gradient Background
            {hframe,[
                {label,?__(106,"Horizon Color")},{color,HorizonColor,[key(horizon_color)]},
                {label,?__(107,"Zenith Color")},{color,ZenithColor,[key(zenith_color)]},
                {label,?__(108,"Power")},{text,GradientBackPower,[key(gradient_back_power),range(power)]}
            ],[hook(open, [member,?KEY(background),gradientback])]
            }
        ],[{title,?__(91,"Background")}]
        }
    ];

%% Area Light Dialog

light_dialog(_Name, area, Ps) ->

    ArealightSamples = proplists:get_value(arealight_samples, Ps, ?DEF_AREALIGHT_SAMPLES),

    CastShadows = proplists:get_value(cast_shadows, Ps, ?DEF_CAST_SHADOWS),

    [{?__(92,"Cast Shadows"),CastShadows,[key(cast_shadows)]},
        {hframe,[
            {label,?__(93,"Samples")},
            {text,ArealightSamples,[range(samples),key(arealight_samples)]}
        ]}
    ];

light_dialog(_Name, _Type, _Ps) ->
%%%    erlang:display({?MODULE,?LINE,{_Name,_Type,_Ps}}),
    [].

light_result(_Name, Ps0, [{?KEY(minimized),Minimized},{?KEY(power),Power}|Res0]) ->
    {LightPs0,Res1} = light_result(Res0),
    LightPs = [{Key,Val} || {?KEY(Key),Val} <- LightPs0],
    Ps = [{?TAG,[{minimized,Minimized},{power,Power}|LightPs]}
          |keydelete(?TAG, 1, Ps0)],
%    erlang:display({?MODULE,?LINE,[Ps,Res1]}),
    {Ps,Res1}.

%% Point
light_result([{?KEY(type),pointlight}|_]=Ps) ->
    split_list(Ps, 4);

light_result([{?KEY(type),spherelight}|_]=Ps) ->
    split_list(Ps, 4);

%% Spot
light_result([{?KEY(type),spotlight}|_]=Ps) ->
    split_list(Ps, 8);

light_result([{?KEY(type),spot_ies}|_]=Ps) ->
    split_list(Ps, 8);

%% Infinite
light_result([{?KEY(type),sunlight}|_]=Ps) ->
    split_list(Ps, 21);

light_result([{?KEY(type),directional}|_]=Ps) ->
    split_list(Ps, 21);

light_result([_,{?KEY(background),_}|_]=Ps) ->
    split_list(Ps, 21);

%% Area
light_result([_,{?KEY(arealight_samples),_}|_]=Ps) ->
    split_list(Ps, 2);

%% Ambient
light_result([{?KEY(type),hemilight}|_]=Ps) ->
    split_list(Ps, 24);

light_result([{?KEY(type),pathlight}|_]=Ps) ->
    split_list(Ps, 24);

light_result([{?KEY(type),globalphotonlight}|_]=Ps) ->
    split_list(Ps, 24);

light_result(Ps) ->
%    erlang:display({?MODULE,?LINE,Ps}),
    {[],Ps}.