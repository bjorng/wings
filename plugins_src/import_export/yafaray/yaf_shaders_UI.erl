%%
%%  yaf_shaders_UI.erl
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


modulator_dialogs(Modulators, Maps) ->
    modulator_dialogs(Modulators, Maps, 1).

modulator_dialogs([], _Maps, M) ->
    [{hframe,
      [{button,?__(801,"New Modulator"),done,[key(new_modulator)]},
       panel|
       if M =:= 1 -> [{button,?__(802,"Default Modulators"),done}];
      true -> [] end]}];
    modulator_dialogs([Modulator|Modulators], Maps, M) ->
    modulator_dialog(Modulator, Maps, M)++
    modulator_dialogs(Modulators, Maps, M+1).

modulator_dialog({modulator,Ps}, Maps, M) when is_list(Ps) ->
    %erlang:display({?MODULE,?LINE,[Ps,M,Maps]}),
    {Enabled, Mode, TexType} = mod_enabled_mode_type(Ps, Maps),

    Minimized = proplists:get_value(minimized, Ps, true),

    SizeX = proplists:get_value(size_x, Ps, ?DEF_MOD_SIZE_X),
    SizeY = proplists:get_value(size_y, Ps, ?DEF_MOD_SIZE_Y),
    SizeZ = proplists:get_value(size_z, Ps, ?DEF_MOD_SIZE_Z),

    ModFactor = proplists:get_value(mod_factor, Ps, ?DEF_MOD_FACTOR),

    %Specular = proplists:get_value(specular, Ps, ?DEF_MOD_SPECULAR),
    %Ambient = proplists:get_value(ambient, Ps, ?DEF_MOD_AMBIENT),
    %Shininess = proplists:get_value(shininess, Ps, ?DEF_MOD_SHININESS),
    %Normal = proplists:get_value(normal, Ps, ?DEF_MOD_NORMAL),
    Filename = proplists:get_value(filename, Ps, ?DEF_MOD_FILENAME),
    BrowseProps = [{dialog_type,open_dialog},
                   {extensions,[{".jpg",?__(803,"JPEG compressed image")},
                                {".tga",?__(804,"Targa bitmap")}]}],
    %    erlang:display({?MODULE,?LINE,[Filename,AbsnameX,BrowseProps]}),
    Color1 = proplists:get_value(color1, Ps, ?DEF_MOD_COLOR1),
    Color2 = proplists:get_value(color2, Ps, ?DEF_MOD_COLOR2),
    Depth = proplists:get_value(depth, Ps, ?DEF_MOD_DEPTH),
    NoiseSize = proplists:get_value(noise_size, Ps, ?DEF_MOD_NOISESIZE),
    NoiseBasis = proplists:get_value(noise_basis, Ps, ?DEF_MOD_NOISEBASIS),
    Hard = proplists:get_value(hard, Ps, ?DEF_MOD_HARD),
    Turbulence = proplists:get_value(turbulence, Ps, ?DEF_MOD_TURBULENCE),
    Sharpness = proplists:get_value(sharpness, Ps, ?DEF_MOD_SHARPNESS),
    WoodType = proplists:get_value(wood_type, Ps, ?DEF_MOD_WOODTYPE),
    Shape = proplists:get_value(shape, Ps, ?DEF_MOD_SHAPE),
    CellType = proplists:get_value(cell_type, Ps, ?DEF_MOD_CELLTYPE),
    CellShape = proplists:get_value(cell_shape, Ps, ?DEF_MOD_CELLSHAPE),
    CellSize = proplists:get_value(cell_size, Ps, ?DEF_MOD_CELLSIZE),
    Intensity = proplists:get_value(intensity, Ps, ?DEF_MOD_INTENSITY),
    CellWeight1 = proplists:get_value(cell_weight1, Ps, ?DEF_MOD_CELL_WEIGHT1),
    CellWeight2 = proplists:get_value(cell_weight2, Ps, ?DEF_MOD_CELL_WEIGHT2),
    CellWeight3 = proplists:get_value(cell_weight3, Ps, ?DEF_MOD_CELL_WEIGHT3),
    CellWeight4 = proplists:get_value(cell_weight4, Ps, ?DEF_MOD_CELL_WEIGHT4),
    MusgraveType = proplists:get_value(musgrave_type, Ps, ?DEF_MOD_MUSGRAVE_TYPE),

    MusgraveNoiseSize = proplists:get_value(musgrave_noisesize, Ps, ?DEF_MOD_MUSGRAVE_NOISESIZE),
    MusgraveIntensity = proplists:get_value(musgrave_intensity, Ps, ?DEF_MOD_MUSGRAVE_INTENSITY),
    MusgraveContrast = proplists:get_value(musgrave_contrast, Ps, ?DEF_MOD_MUSGRAVE_CONTRAST),
    MusgraveLacunarity = proplists:get_value(musgrave_lacunarity, Ps, ?DEF_MOD_MUSGRAVE_LACUNARITY),
    MusgraveOctaves = proplists:get_value(musgrave_octaves, Ps, ?DEF_MOD_MUSGRAVE_OCTAVES),
    DistortionType = proplists:get_value(distortion_type, Ps, ?DEF_MOD_DISTORTION_TYPE),

    DistortionIntensity = proplists:get_value(distortion_intensity, Ps, ?DEF_MOD_DISTORTION_INTENSITY),
    DistortionNoiseSize = proplists:get_value(distortion_noisesize, Ps, ?DEF_MOD_DISTORTION_NOISESIZE),
    TypeTag = {?TAG,type,M},

    %% specials..
    OffX = proplists:get_value(offsetx, Ps, ?DEF_MOD_OFFSET_X),

    OffY = proplists:get_value(offsety, Ps, ?DEF_MOD_OFFSET_Y),

    OffZ = proplists:get_value(offsetz, Ps, ?DEF_MOD_OFFSET_Z),

    Coordinates = proplists:get_value(coordinates, Ps, ?DEF_COORDINATES),

    Projection = proplists:get_value(projection, Ps, ?DEF_PROJECTION),

    BlendMode = proplists:get_value(blend_mode, Ps, ?DEF_BLENDING_MODE),

    ModShaderType = proplists:get_value(mod_shader_type, Ps, ?DEF_MOD_SHADER_TYPE),

    _StencilMode = proplists:get_value(stencil_mode, Ps, ?DEF_MOD_STENCIL),
    %

    MapsFrame = [{hradio,[{atom_to_list(Map),{map,Map}} || {Map,_} <- Maps], TexType,[{key,TypeTag},layout]}],

    [
        {vframe,[
            {hframe,[
                {?__(805,"Enabled"),Enabled,[{key,{?TAG,enabled,M}}]},
                panel,
                {menu,[
                    {?__(806,"Mix"),mix},
                    {?__(807,"Add"),add},
                    {?__(808,"Multiply"),mul},
                    {?__(809,"Subtrac"),sub},
                    {?__(810,"Screen"),scr},
                    {?__(811,"Divide"),divide},
                    {?__(812,"Difference"),dif},
                    {?__(813,"Darking"),dar},
                    {?__(814,"Lighting"),lig}
                ],BlendMode,[hook(enable,{?TAG,enabled,M})]
                },
                {label,?__(815,"<- Blend Mode")},
                panel,{button,?__(816,"Delete"),done},
                panel,help_button(shader_dialog)
            ]},
            {vframe,[
                {hframe,[
                    {label,?__(817,"Shader Type")},
                    {menu,[
                        {?__(818,"Diffuse Shader"),diff},
                        {?__(819,"Mirror shader"),spec},
                        {?__(820,"Transparency shader"),transp},
                        {?__(821,"Translucency shader"),translu},
                        {?__(822,"Mirror color shader"),colorspec},
                        {?__(823,"Bumpmap shader"),bump}
                    ],ModShaderType
                    }
                ]},
                {hframe,[
                    {vframe,[
                        {label,?__(824,"Coordinates:")},
                        {label,?__(825,"Projection:")}
                    ]},
                    {vframe,[
                        {menu,[
                            {?__(826,"UV"),uv},
                            {?__(827,"Global"),global}
                        ],Coordinates
                        },
                        {menu,[
                            {?__(828,"Flat"),plain},
                            {?__(829,"Cube"),cube},
                            {?__(830,"Tube"),tube},
                            {?__(831,"Sphere"),sphere}
                        ],Projection}
                    ]},
                    {vframe,[
                        {hframe,[
                            {label,?__(832,"Size   X:")},{text,SizeX,[range(size),{width,6}]},
                            {label,?__(833," Y:")}, {text,SizeY,[range(size),{width,5}]},
                            {label,?__(834," Z:")}, {text,SizeZ,[range(size),{width,5}]}
                        ]},
                        {hframe,[
                            {label,?__(835,"Offset X:")},{text,OffX,[range(size),{width,5}]},
                            {label,?__(836," Y:")},{text,OffY,[range(size),{width,5}]},
                            {label,?__(837," Z:")},{text,OffZ,[range(size),{width,5}]}
                        ]}

                    ]}
                    %{hframe,[{label,?__(1025,"Stencil"),StencilMode}]}
                ],[{title,?__(838,"Texture settings")}]}, % aqui acaba la horizontal
                {hframe,[
                    {label,?__(839,"Shader factor:")},
                    {slider,{text,ModFactor,[range(modulation)]}}

                ]}
            ]
            ++MapsFrame++
            [
                {hradio,[
                    {?__(18,"Image"),image},
                    {?__(19,"Clouds"),clouds},
                    {?__(20,"Marble"),marble},
                    {?__(21,"Wood"),wood},
                    {?__(46,"Voronoi"),voronoi},
                    {?__(62,"Musgrave"),musgrave},
                    {?__(82,"Distorted Noise"),distorted_noise}
                ], TexType,[{key,TypeTag},layout]
                },
                {vframe,[
                    {hframe,[
                        {hframe,[
                            {label,?__(22,"Filename")},
                            {button,{text,Filename,[{props,BrowseProps}]}}
                        ],[hook(open, [member,{?TAG,type,M},image])]
                        },

                        %% Clouds,Marble,Wood Specific Procedurals

                        {hframe,[
                            {label,?__(23,"Texture")},{color,Color1},
                            {label,?__(24,"Base")},{color,Color2},
                            {?__(25,"Hard Noise"),Hard},

                        %%% Start Noise Basis Select

                            {menu,[
                                {?__(36,"Blender-Basis"),blender},
                                {?__(37,"Cellnoise"),cellnoise},
                                {?__(38,"New Perlin"),newperlin},
                                {?__(39,"Perlin"),stdperlin},
                                {?__(40,"Voronoi Crackle"),voronoi_crackle},
                                {?__(41,"Voronoi F1"),voronoi_f1},
                                {?__(42,"Voronoi F2"),voronoi_f2},
                                {?__(43,"Voronoi F3"),voronoi_f3},
                                {?__(44,"Voronoi F4"),voronoi_f4},
                                {?__(45,"Voronoi F1F2"),voronoi_f2f1}
                            ],NoiseBasis,[hook(enable, {?TAG,enabled,M})]
                            }
                        ],[hook(open, [member,{?TAG,type,M},clouds,marble,wood,musgrave,distorted_noise])]
                        }
                    ]},
                    %% Clouds,Marble,Wood Specific Procedurals Line 2
                    {hframe,[
                        {hframe,[
                            {label,?__(26,"Noise Size")},
                            {text,NoiseSize,[range(noise_size)]}
                        ],[hook(open, [member,{?TAG,type,M},clouds,marble,wood])]
                        },
                        %% Clouds,Marble,Wood Specific Procedurals Line 2
                        {hframe,[
                            {label,?__(27,"Noise Depth")},
                            {text,Depth,[range(noise_depth)]}
                        ],[hook(open, [member,{?TAG,type,M},clouds,marble,wood])]
                        }
                    ]},
                    %% Marble Specific Procedurals
                    {hframe,[
                        {hframe,[
                            {label,?__(28,"Sharpness")},
                            {text,Sharpness,[range(sharpness)]}
                        ],[hook(open, [member,{?TAG,type,M},marble])]
                        },
                        {hframe,[
                            {hframe,[
                                {label,?__(29,"Turbulence")},
                                {text,Turbulence,[range(turbulence)]},
                                {menu,[ %% Shape Select
                                    {?__(30,"sin"),"sin"},
                                    {?__(31,"saw"),saw},
                                    {?__(32,"tri"),tri}
                                ], Shape,[hook(enable, {?TAG,enabled,M})]
                                }
                            ],[hook(open, [member,{?TAG,type,M},marble,wood])]
                            }
                        ]},
                        %% Wood Specific Procedurals
                        {hframe,[
                            {menu,[
                                {?__(33,"Rings"),rings},
                                {?__(34,"Bands"),bands}
                            ],WoodType,[hook(enable, {?TAG,enabled,M})]
                            }
                        ],[hook(open, [member,{?TAG,type,M},wood])]
                        },
                        %%% Voronoi Specific Procedurals
                        {vframe,[
                            {hframe,[ %%% Start Voronoi Cell Type Select
                                {menu,[
                                    {?__(47,"Intensity"),intensity},
                                    {?__(48,"Color"),col1},
                                    {?__(49,"Color+Outline"),col2},
                                    {?__(50,"Color+Outline+Intensity"),col3}
                                ],CellType,[hook(enable, {?TAG,enabled,M})]
                                },
                                %%% Start Voronoi Cell Shape Select
                                {menu,[
                                    {?__(51,"Actual Distance"),actual},
                                    {?__(52,"Distance Squared"),squared},
                                    {?__(53,"Manhattan"),manhattan},
                                    {?__(54,"Chebychev"),chebychev},
                                    {?__(55,"Minkovsky"),minkovsky}
                                ],CellShape,[hook(enable, {?TAG,enabled,M})]
                                }
                            ],[hook(open, [member,{?TAG,type,M},voronoi])]
                            },
                            %%% Start Voronoi Line 2
                            {hframe,[
                                {hframe,[
                                    {label,?__(56,"Cell Size")},{text,CellSize,[range(cell_size)]},
                                    {label,?__(57,"Intensity")},{text,Intensity,[range(intensity)]}
                                ],[hook(open, [member,{?TAG,type,M},voronoi])]
                                }
                            ]},
                            %%% Start Voronoi Line 3
                            {hframe,[
                                {hframe,[
                                    {label,?__(58,"W1")},{text,CellWeight1,[range(cell_weight1)]},
                                    {label,?__(59,"W2")},{text,CellWeight2,[range(cell_weight2)]},
                                    {label,?__(60,"W3")},{text,CellWeight3,[range(cell_weight3)]},
                                    {label,?__(61,"W4")},{text,CellWeight4,[range(cell_weight4)]}
                                ],[hook(open, [member,{?TAG,type,M},voronoi])]
                                }
                            ]}
                        ],[hook(open, [member,{?TAG,type,M},voronoi])]
                        },
                        %%% Start Musgrave Specific Procedurals
                        {vframe,[
                            {hframe,[ %%% Start Musgrave Type Select
                                {menu,[
                                    {?__(63,"Multifractal"),multifractal},
                                    {?__(64,"Ridged"),ridgedmf},
                                    {?__(65,"Hybrid"),hybridmf},
                                    {?__(66,"FBM"),fBm}
                                ],MusgraveType,[hook(enable, {?TAG,enabled,M})]
                                },
                                {label,?__(77,"Noise Size")},{text,MusgraveNoiseSize,[range(musgrave_noisesize)]},
                                {label,?__(78,"Intensity")},{text,MusgraveIntensity,[range(musgrave_intensity)]}
                            ],[hook(open, [member,{?TAG,type,M},musgrave])]
                            },
                            %%% Start Musgrave Line 2
                            {hframe,[
                                {hframe,[
                                    {label,?__(79,"Contrast (H)")},{text,MusgraveContrast,[range(musgrave_contrast)]},
                                    {label,?__(80,"Lacunarity")},{text,MusgraveLacunarity,[range(musgrave_lacunarity)]},
                                    {label,?__(81,"Octaves")},{text,MusgraveOctaves,[range(musgrave_octaves)]}
                                ],[hook(open, [member,{?TAG,type,M},musgrave])]
                                }
                            ]}
                        ],[hook(open, [member,{?TAG,type,M},musgrave])]
                        },
                        %%%% Start Distorted Noise Specific Procedurals
                        {vframe,[
                            {hframe,[
                                {menu,[
                                    {?__(87,"Blender-Distort"),blender},
                                    {?__(88,"Cellnoise"),cellnoise},
                                    {?__(89,"New Perlin"),newperlin},
                                    {?__(90,"Perlin"),stdperlin},
                                    {?__(91,"Voronoi Crackle"),voronoi_crackle},
                                    {?__(92,"Voronoi F1"),voronoi_f1},
                                    {?__(93,"Voronoi F2"),voronoi_f2},
                                    {?__(94,"Voronoi F3"),voronoi_f3},
                                    {?__(95,"Voronoi F4"),voronoi_f4},
                                    {?__(96,"Voronoi F1F2"),voronoi_f2f1}
                                ], DistortionType,[hook(enable, {?TAG,enabled,M})]
                                },
                                {label,?__(107,"Noise Size")},{text,DistortionNoiseSize,[range(distortion_noisesize)]},
                                {label,?__(108,"Distortion")},{text,DistortionIntensity,[range(distortion_intensity)]}
                            ],[hook(open, [member,{?TAG,type,M},distorted_noise])]
                            }
                        ],[hook(open, [member,{?TAG,type,M},distorted_noise])]
                        }
                    ]}
                ]}
            ],[hook(enable, {?TAG,enabled,M})]
            }],[{title,?__(35,"Shader slot")++" "++integer_to_list(M)++mod_legend(Enabled, Mode, TexType)},{minimized,Minimized}]
        }
    ];

modulator_dialog(_Modulator, _Maps, _) ->
    []. % Discard old modulators that anyone may have

mod_enabled_mode_type(Ps, Maps) ->
    {Enabled,Mode} =
        case proplists:get_value(mode, Ps, ?DEF_BLENDING_MODE) of
            off -> {false,?DEF_BLENDING_MODE};
            Mode1 -> {proplists:get_value(enabled, Ps, ?DEF_MOD_ENABLED),Mode1} % not work
        end,
    TexType = proplists:get_value(textype, Ps, ?DEF_MOD_TYPE),

    %erlang:display(TexType),
    %%--------------------->
    case TexType of
        {map,Map} ->
            case lists:keymember(Map, 1, Maps) of
                true -> {Enabled, Mode, TexType};
                false -> {false, Mode, ?DEF_MOD_TYPE}
            end;
        _ -> {Enabled, Mode, TexType}
    end.

%%-------->
mod_legend(Enabled, Mode, {map,Map}) ->
    mod_legend(Enabled, Mode, atom_to_list(Map));

%------->
mod_legend(Enabled, Mode, TexType) when is_atom(Mode) -> % povman last test
    mod_legend(Enabled, wings_util:cap(Mode), TexType);


%---------->
mod_legend(Enabled, Mode, TexType) when is_atom(TexType) ->
    mod_legend(Enabled, Mode, wings_util:cap(TexType));

%---->
mod_legend(Enabled, Mode, TexType) when is_list(Mode), is_list(TexType) ->
    case Enabled of
        true -> " ("++?__(1,"enabled")++", ";
        false -> " ("++?__(2,"disabled")++", "
    end++Mode++", "++TexType++")".


modulator_result(Ps, Res) ->
    modulator_result(Ps, Res, 1, []).

modulator_result(Ps, [], _, Modulators) ->
    %% Should not happen
    {[{modulators,reverse(Modulators)}|Ps], []};

modulator_result(Ps, [{?KEY(new_modulator),false},false|Res], 1, []) ->
    {[{modulators,[]}|Ps],Res};

modulator_result(Ps, [{?KEY(new_modulator),false},true|Res], 1, []) ->
    %% Default Modulators
    {Ps,Res};

modulator_result(Ps, [{?KEY(new_modulator),true},_|Res], 1, []) ->
    {[{modulators,[{modulator,[]}]}|Ps],Res};

modulator_result(Ps, [{?KEY(new_modulator),false}|Res], _, Modulators) ->
    {[{modulators,reverse(Modulators)}|Ps],Res};

modulator_result(Ps, [{?KEY(new_modulator),true}|Res], _, Modulators) ->
    {[{modulators,reverse(Modulators, [{modulator,[]}])}|Ps],Res};

modulator_result(Ps, [_Minimized,{{?TAG,enabled,M},_},_Mode,true|Res0], M, Modulators) ->
    %% Delete - Split list # +1 will match the modulator one below.
    {_,Res} = split_list(Res0, 39), % org: 37
    modulator_result(Ps, Res, M+1, Modulators);

modulator_result(Ps, [Minimized,{{?TAG,enabled,M},Enabled},BlendMode,false|Res0],
                 M, Modulators) ->
    {Modulator,Res} = modulator(Minimized, Enabled, BlendMode, Res0, M),
    modulator_result(Ps, Res, M+1, [Modulator|Modulators]).


%%% Increase split_list # +1 per line if add Modulator to Dialog

modulator(Minimized, Enabled, Mode, Res0, M) ->
    {Res1,Res} = split_list(Res0, 39), % org : 37
    TypeTag = {?TAG,type,M},
    {value,{TypeTag,TexType}} = lists:keysearch(TypeTag, 1, Res1),

    [
    ModShaderType,
    Coordinates,
    Projection,
    %StencilMode,
    SizeX, SizeY, SizeZ, OffX, OffY, OffZ,
    ModFactor,
    Filename, %28
    Color1,Color2,Hard,NoiseBasis,NoiseSize,Depth,
    Sharpness, Turbulence, Shape,
    WoodType, CellType, CellShape, CellSize, Intensity,
    CellWeight1, CellWeight2, CellWeight3, CellWeight4,
    MusgraveType, MusgraveNoiseSize, MusgraveIntensity,
    MusgraveContrast, MusgraveLacunarity, MusgraveOctaves, DistortionType,
    DistortionNoiseSize,DistortionIntensity] = lists:keydelete(TypeTag, 1, Res1),
    %
    Ps = [
        {minimized,Minimized},
        {enabled,Enabled},
        {mode,Mode},
        {mod_shader_type,ModShaderType},
        {coordinates,Coordinates},
        {projection,Projection},
        %{stencil_mode,StencilMode},
        {size_x,SizeX},{size_y,SizeY},{size_z,SizeZ},
        {offsetx,OffX},{offsety,OffY},{offsetz,OffZ},
        {mod_factor,ModFactor},
        {textype,TexType},
        {filename,Filename},{color1,Color1},{color2,Color2},{hard,Hard},
        {noise_basis,NoiseBasis},{noise_size,NoiseSize},{depth,Depth},
        {sharpness,Sharpness},{turbulence,Turbulence},{shape,Shape},
        {wood_type,WoodType},{cell_type,CellType},{cell_shape,CellShape},
        {cell_size,CellSize},{intensity,Intensity},{cell_weight1,CellWeight1},
        {cell_weight2,CellWeight2},{cell_weight3,CellWeight3},{cell_weight4,CellWeight4},
        {musgrave_type,MusgraveType},
        {musgrave_noisesize,MusgraveNoiseSize},{musgrave_intensity,MusgraveIntensity},
        {musgrave_contrast,MusgraveContrast},{musgrave_lacunarity,MusgraveLacunarity},
        {musgrave_octaves,MusgraveOctaves},{distortion_type,DistortionType},
        {distortion_noisesize,DistortionNoiseSize},
        {distortion_intensity,DistortionIntensity}
        ],{{modulator,Ps},Res}.