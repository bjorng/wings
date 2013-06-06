%%
%%  yaf_defines.erl
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

modulator_dialog({modulator,Ps}, Maps, M) when is_list(Ps) ->
    % erlang:display({?MODULE,?LINE,[Ps,M,Maps]}),

    {Enabled,Mode,Type} = mod_enabled_mode_type(Ps, Maps),

    AlphaIntensity = proplists:get_value(alpha_intensity, Ps, ?DEF_MOD_ALPHA_INTENSITY),

    Minimized = proplists:get_value(minimized, Ps, true),

    SizeX = proplists:get_value(size_x, Ps, ?DEF_MOD_SIZE_X),

    SizeY = proplists:get_value(size_y, Ps, ?DEF_MOD_SIZE_Y),

    SizeZ = proplists:get_value(size_z, Ps, ?DEF_MOD_SIZE_Z),

    Diffuse = proplists:get_value(diffuse, Ps, ?DEF_MOD_DIFFUSE),

    Specular = proplists:get_value(specular, Ps, ?DEF_MOD_SPECULAR),

    %% Ambient = proplists:get_value(ambient, Ps, ?DEF_MOD_AMBIENT),

    Shininess = proplists:get_value(shininess, Ps, ?DEF_MOD_SHININESS),

    Normal = proplists:get_value(normal, Ps, ?DEF_MOD_NORMAL),

    Filename = proplists:get_value(filename, Ps, ?DEF_MOD_FILENAME),

    BrowseProps = [{dialog_type,open_dialog},
                   {extensions,[{".jpg",?__(3,"JPEG compressed image")},
                                {".tga",?__(4,"Targa bitmap")}]}],
    %% erlang:display({?MODULE,?LINE,[Filename,AbsnameX,BrowseProps]}),

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

    MapsFrame = [{hradio,[{atom_to_list(Map),{map,Map}} || {Map,_} <- Maps],
                  Type,[{key,TypeTag},layout]}],
    [
        {vframe,[
            {hframe,[
                {?__(5,"Enabled"),Enabled,[{key,{?TAG,enabled,M}}]},
                {menu,[
                    {?__(6,"Mix"),mix},
                    {?__(7,"Add"),add},
                    {?__(8,"Mul"),mul},
                    {?__(109,"Sub"),sub},
                    {?__(110,"Scr"),scr},
                    {?__(111,"Div"),divide},
                    {?__(112,"Dif"),dif},
                    {?__(113,"Dar"),dar},
                    {?__(114,"Lig"),lig}
                ],Mode, [hook(enable, {?TAG,enabled,M})]
                },panel,{button,?__(9,"Delete"),done}
            ]},
            {vframe,[ % hook(enable, {?TAG,enabled,M})
                {hframe,[
                    {menu,[
                        {?__(115,"Alpha Off"),off},
                        {?__(116,"Alpha Transparency"),transparency},
                        {?__(117,"Diffuse+Alpha Transparency"),diffusealphatransparency},
                        {?__(118,"Alpha Translucency"),translucency},
                        {?__(119,"Specularity"),specularity},
                        {?__(120,"Stencil"),stencil}
                    ],AlphaIntensity
                    }
                ]},
                {hframe,[
                    {label,?__(10,"SizeX")},{text,SizeX,[range(size)]},
                    {label,?__(11,"SizeY")},{text,SizeY,[range(size)]},
                    {label,?__(12,"SizeZ")},{text,SizeZ,[range(size)]}
                ]},
                {hframe,[
                    {vframe,[
                        {label,?__(13,"Diffuse")++" "},
                        {label,?__(14,"Specular")},
                        {label,?__(16,"Shininess")},
                        {label,?__(17,"Normal")}
                    ]},
                    {vframe,[
                        {slider,{text,Diffuse,[range(modulation)]}},
                        {slider,{text,Specular,[range(modulation)]}},
                        {slider,{text,Shininess,[range(modulation)]}},
                        {slider,{text,Normal,[range(modulation)]}}
                    ]}
                ]}
            ]
            ++MapsFrame++
            [{hradio,[
                {?__(18,"Image"),image},
                {?__(19,"Clouds"),clouds},
                {?__(20,"Marble"),marble},
                {?__(21,"Wood"),wood},
                {?__(46,"Voronoi"),voronoi},
                {?__(62,"Musgrave"),musgrave},
                {?__(82,"Distorted Noise"),distorted_noise}
            ],Type,[{key,TypeTag},layout]
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

                        {menu,[ %% Start Noise Basis Select
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
                {hframe,[
                    {hframe,[
                        {label,?__(26,"Noise Size")},
                        {text,NoiseSize,[range(noise_size)]}
                    ],[hook(open, [member,{?TAG,type,M},clouds,marble,wood])]
                    },
                    {hframe,[
                        {label,?__(27,"Noise Depth")},
                        {text,Depth,[range(noise_depth)]}
                    ],[hook(open, [member,{?TAG,type,M},clouds,marble,wood])]
                    }
                ]},
                {hframe,[ %% Marble Specific Procedurals
                    {hframe,[
                        {label,?__(28,"Sharpness")},
                        {text,Sharpness,[range(sharpness)]}
                    ],[hook(open, [member,{?TAG,type,M},marble])]
                    },
                    %% Marble,Wood Specific Procedurals
                    {hframe,[
                        {hframe,[
                            {label,?__(29,"Turbulence")},
                            {text,Turbulence,[range(turbulence)]},
                            {menu,[ %% Shape Select
                                {?__(30,"sin"),"sin"},
                                {?__(31,"saw"),saw},
                                {?__(32,"tri"),tri}
                            ],Shape,[hook(enable, {?TAG,enabled,M})]
                            }
                        ],[hook(open, [member,{?TAG,type,M},marble,wood])]
                        }
                    ]},
                    {hframe,[ %% Wood Specific Procedurals
                        {menu,[
                            {?__(33,"Rings"),rings},
                            {?__(34,"Bands"),bands}
                        ],WoodType,[hook(enable, {?TAG,enabled,M})]
                        }
                    ],[hook(open, [member,{?TAG,type,M},wood])]
                    },
                    {vframe,[ %% Voronoi Specific Procedurals
                        {hframe,[
                            {menu,[ %% Voronoi Cell Type Select
                                {?__(47,"Intensity"),intensity},
                                {?__(48,"Color"),col1},
                                {?__(49,"Color+Outline"),col2},
                                {?__(50,"Color+Outline+Intensity"),col3}
                            ],CellType,[hook(enable, {?TAG,enabled,M})]
                            },
                            {menu,[ %% Voronoi Cell Shape Select
                                {?__(51,"Actual Distance"),actual},
                                {?__(52,"Distance Squared"),squared},
                                {?__(53,"Manhattan"),manhattan},
                                {?__(54,"Chebychev"),chebychev},
                                {?__(55,"Minkovsky"),minkovsky}
                            ],CellShape,[hook(enable, {?TAG,enabled,M})]
                            }
                        ],[hook(open, [member,{?TAG,type,M},voronoi])]
                        },
                        {hframe,[
                            {hframe,[
                                {label,?__(56,"Cell Size")},{text,CellSize,[range(cell_size)]},
                                {label,?__(57,"Intensity")},{text,Intensity,[range(intensity)]}
                            ],[hook(open, [member,{?TAG,type,M},voronoi])]
                            }
                        ]},
                        {hframe,[
                            {hframe,[
                                {label,?__(58,"W1")},{text,CellWeight1,[range(cell_weight1)]},
                                {label,?__(59,"W2")},{text,CellWeight2,[range(cell_weight2)]},
                                {label,?__(60,"W3")},{text,CellWeight3,[range(cell_weight3)]},
                                {label,?__(61,"W4")},{text,CellWeight4,[range(cell_weight4)]}
                            ],[hook(open, [member,{?TAG,type,M},voronoi])]
                            }
                        ]}
                        %%% Close Voronoi
                    ],[hook(open, [member,{?TAG,type,M},voronoi])]
                    },
                    {vframe,[
                        {hframe,[ %% Musgrave Type Select
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
                    %%% Start Distorted Noise Specific Procedurals
                    {vframe,[
                        {hframe,[ %%Distorted Noise Type Select
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
                            ],DistortionType,[hook(enable, {?TAG,enabled,M})]
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
            }],[{title,?__(35,"Modulator")++" "++integer_to_list(M)++mod_legend(Enabled, Mode, Type)},
                {minimized,Minimized}]
        }
    ];

modulator_dialog(_Modulator, _Maps, _) ->
    []. % Discard old modulators that anyone may have

mod_enabled_mode_type(Ps, Maps) ->
    {Enabled,Mode} =
        case proplists:get_value(mode, Ps, ?DEF_MOD_MODE) of
            off -> {false,?DEF_MOD_MODE};
            Mode1 -> {proplists:get_value(enabled, Ps, ?DEF_MOD_ENABLED),Mode1}
        end,
    Type = proplists:get_value(type, Ps, ?DEF_MOD_TYPE),
    case Type of
        {map,Map} ->
            case lists:keymember(Map, 1, Maps) of
                true -> {Enabled,Mode,Type};
                false -> {false,Mode,?DEF_MOD_TYPE}
            end;
        _ -> {Enabled,Mode,Type}
    end.

mod_legend(Enabled, Mode, {map,Map}) ->
    mod_legend(Enabled, Mode, atom_to_list(Map));

mod_legend(Enabled, Mode, Type) when is_atom(Mode) ->
    mod_legend(Enabled, wings_util:cap(Mode), Type);

mod_legend(Enabled, Mode, Type) when is_atom(Type) ->
    mod_legend(Enabled, Mode, wings_util:cap(Type));

mod_legend(Enabled, Mode, Type) when is_list(Mode), is_list(Type) ->
    case Enabled of
        true -> " ("++?__(1,"enabled")++", ";
        false -> " ("++?__(2,"disabled")++", "
    end++Mode++", "++Type++")".


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

modulator_result(Ps, [_Minimized,{{?TAG,enabled,M},_},_Mode,true|Res0],
                 M, Modulators) ->
    %% Delete - Split list # +1 will match the modulator one below.
    {_,Res} = split_list(Res0, 37),
    modulator_result(Ps, Res, M+1, Modulators);
modulator_result(Ps, [Minimized,{{?TAG,enabled,M},Enabled},Mode,false|Res0],
                 M, Modulators) ->
    {Modulator,Res} = modulator(Minimized, Enabled, Mode, Res0, M),
    modulator_result(Ps, Res, M+1, [Modulator|Modulators]).

%%% Increase split_list # +1 per line if add Modulator to Dialog

modulator(Minimized, Enabled, Mode, Res0, M) ->
    {Res1,Res} = split_list(Res0, 37),
    TypeTag = {?TAG,type,M},
    {value,{TypeTag,Type}} = lists:keysearch(TypeTag, 1, Res1),
    [AlphaIntensity,SizeX,SizeY,SizeZ,
     Diffuse,Specular,Shininess,Normal,
     Filename,
     Color1,Color2,Hard,NoiseBasis,NoiseSize,Depth,
     Sharpness,Turbulence,Shape,
     WoodType,CellType,CellShape,CellSize,Intensity,CellWeight1,CellWeight2,CellWeight3,CellWeight4,
     MusgraveType,MusgraveNoiseSize,MusgraveIntensity,MusgraveContrast,
     MusgraveLacunarity,MusgraveOctaves,DistortionType,
     DistortionNoiseSize,DistortionIntensity] %% 17 values = 18-1
        = lists:keydelete(TypeTag, 1, Res1),
    Ps = [{minimized,Minimized},{enabled,Enabled},{mode,Mode},{alpha_intensity,AlphaIntensity},
          {size_x,SizeX},{size_y,SizeY},{size_z,SizeZ},
          {diffuse,Diffuse},{specular,Specular},
          {shininess,Shininess},{normal,Normal},
          {type,Type},
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
          ],
    {{modulator,Ps},Res}.
