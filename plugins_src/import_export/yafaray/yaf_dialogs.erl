%%
%%  yaf_dialogs.erl
%%
%%  YafaRay Export Dialogs User Interface.
%%
%%  Copyright (c) 2003-2008 Raimo Niskanen
%%  Code Converted from Yafray to YafaRay by Bernard Oortman (Wings3d user oort)
%%  Meshlight Export Perfected with Assistance from Micheus
%%  See the file "license.terms" for information on usage and redistribution
%%  of this file, and for a DISCLAIMER OF ALL WARRANTIES.
%%
%%

export_dialog_qs(Op,
                [{subdivisions,SubDiv},
                {keep_xml,KeepXML},
                {threads_number,ThreadsNumber},
                {threads_auto,ThreadsAuto},
                {lighting_method,Lighting_Method},
                {use_caustics,UseCaustics},
                {caustic_photons,Caustic_Photons},
                {caustic_depth,Caustic_Depth},
                {caustic_mix,Caustic_Mix},
                {caustic_radius,Caustic_Radius},
                {do_ao,Do_AO},
                {ao_distance,AO_Distance},
                {ao_samples,AO_Samples},
                {ao_color,AO_Color},
                {pm_diffuse_photons,PM_Diffuse_Photons},
                {pm_bounces,PM_Bounces},
                {pm_search,PM_Search},
                {pm_diffuse_radius,PM_Diffuse_Radius},
                {pm_caustic_photons,PM_Caustic_Photons},
                {pm_caustic_radius,PM_Caustic_Radius},
                {pm_caustic_mix,PM_Caustic_Mix},
                {pm_use_background,PM_Use_Background},
                {pm_use_fg,PM_Use_FG},
                {pm_fg_bounces,PM_FG_Bounces},
                {pm_fg_samples,PM_FG_Samples},
                {pm_fg_show_map,PM_FG_Show_Map},
                {pt_diffuse_photons,PT_Diffuse_Photons},
                {pt_bounces,PT_Bounces},
                {pt_caustic_type,PT_Caustic_Type},
                {pt_caustic_radius,PT_Caustic_Radius},
                {pt_caustic_mix,PT_Caustic_Mix},
                {pt_caustic_depth,PT_Caustic_Depth},
                {pt_use_background,PT_Use_Background},
                {pt_samples,PT_Samples},
                {volintegr_type,Volintegr_Type},
                {volintegr_adaptive,Volintegr_Adaptive},
                {volintegr_optimize,Volintegr_Optimize},
                {volintegr_stepsize,Volintegr_Stepsize},
                {use_sss,UseSSS},
                {sss_photons,SSS_Photons},
                {sss_depth,SSS_Depth},
                {sss_scale,SSS_Scale},
                {sss_singlescatter_samples,SSS_SingleScatter_Samples},
                {raydepth,Raydepth},
                {gamma,Gamma},
                {bias,Bias},
                {exposure,Exposure},
                {transparent_shadows,TransparentShadows},
                {shadow_depth,ShadowDepth},
                {render_format,RenderFormat},
                {exr_flag_float,ExrFlagFloat},
                {exr_flag_zbuf,ExrFlagZbuf},
                {exr_flag_compression,ExrFlagCompression},
                {aa_passes,AA_passes},
                {aa_minsamples,AA_minsamples},
                {aa_jitterfirst,AA_jitterfirst},
                {aa_threshold,AA_threshold},
                {aa_pixelwidth,AA_pixelwidth},
                {clamp_rgb,ClampRGB},
                {aa_filter_type,AA_Filter_Type},
                {background_color,BgColor},
                {save_alpha,SaveAlpha},
                {background_transp_refract,BackgroundTranspRefract},
                % povman test ----->
                %79{use_IBL, UseIBL},
                {background_type, BackgroundType},
                % end ------->
                {lens_type,Lens_Type},
                {lens_ortho_scale,Lens_Ortho_Scale},
                {lens_angular_circular,Lens_Angular_Circular},
                {lens_angular_mirrored,Lens_Angular_Mirrored},
                {lens_angular_max_angle,Lens_Angular_Max_Angle},
                {lens_angular_angle,Lens_Angular_Angle},
                {bokeh_use_QMC,BokehUseQMC},
                {width,Width},
                {aperture,Aperture},
                {bokeh_type,BokehType},
                {height,Height},
                {aperture,_Aperture},
                {bokeh_bias,BokehBias},
                {bokeh_rotation,BokehRotation},
                {dof_distance,Dof_Distance},
                _Save,_Load,_Reset]) ->

    BiasFlags = [range(bias),{key,bias}],
    [
        {hframe,[
            {label,?__(1,"Sub-division Steps")},
            {text,SubDiv,[{key,subdivisions},range(subdivisions)]},
            case Op of
                render ->
                {?__(2,"Write .xml file       "),KeepXML,[{key,keep_xml}]};
                _ ->
                    {value,KeepXML,[{key,keep_xml}]}
            end,

%% Start Threads setting
            {hframe,[
                {label,"Threads"},
                {text,ThreadsNumber,[range(threads_number),
                    {key,threads_number}, hook(enable, ['not',[member,threads_auto,true]])
                ]}
            ]},
%% End Threads setting
            {?__(160,"Auto"),ThreadsAuto,[{key,threads_auto}]}
        ],[{title,?__(3,"Pre-rendering")}]
        },
        {hframe,[
            {vframe,[
                {menu,[
                    {?__(114,"Direct Light"),directlighting},
                    {?__(115,"Photon Mapping - Global Illumination"),photonmapping},
                    {?__(140,"Path Tracing - Global Illumination"),pathtracing},
                    {?__(116,"Bidirectional Path Tracing - Global Illumination"),bidirectional}
                ], Lighting_Method, [{key,lighting_method},layout]
                },
                % Start Direct Lighting Menu Section
                {hframe,[
                    {vframe,[
                        {menu,[
                            {?__(82,"Caustics Off"),false},
                            {?__(83,"Caustics On"),true}
                        ],UseCaustics, [{key,use_caustics},layout]
                        },
                        {hframe,[
                            {vframe,[
                                {label,?__(84,"Photons")},
                                {label,?__(85,"Depth")}
                            ]},
                            {vframe,[
                                {text,Caustic_Photons,[range(caustic_photons),{key,caustic_photons}]},
                                {text,Caustic_Depth,[range(caustic_depth),{key,caustic_depth}]}
                            ]},
                            {vframe,[
                                {label,?__(86,"Mix")},
                                {label,?__(87,"Radius")}
                            ]},
                            {vframe,[
                                {text,Caustic_Mix,[range(caustic_mix),{key,caustic_mix}]},
                                {text,Caustic_Radius,[range(caustic_radius),{key,caustic_radius}]}
                            ]}
                        ],[hook(open, [member,use_caustics,true])]
                        }
                    ]},
                    {vframe,[
                        {menu,[
                            {?__(95,"Ambient Occlusion Off"),false},
                            {?__(96,"Ambient Occlusion On"),true}
                        ], Do_AO, [{key,do_ao},layout]
                        },
                        {hframe,[
                            {vframe,[
                                {label,?__(97,"AO Distance")},
                                {label,?__(98,"AO Samples")}
                            ]},
                            {vframe, [
                                {text,AO_Distance,[range(ao_distance),{key,ao_distance}]},
                                {text,AO_Samples,[range(ao_samples),{key,ao_samples}]}
                            ]},
                            {vframe,[
                                {label,?__(99,"AO Color")}
                            ]},
                            {vframe,[
                                {color,AO_Color,[{key,ao_color}]}
                            ]}
                        ],[hook(open, [member,do_ao,true])]
                        }
                ]}
                ],[hook(open, [member,lighting_method,directlighting])]
                },
                %% Start Photon Mapping Menu Section
                {hframe,[
                    {vframe,[
                        {label,?__(121,"Photons")},
                        {label,?__(122,"Bounces")},
                        {label,?__(123,"Search")},
                        {label,?__(124,"Diffuse Radius")}
                    ]},
                    {vframe,[
                        {text,PM_Diffuse_Photons,[range(pm_diffuse_photons),{key,pm_diffuse_photons}]},
                        {text,PM_Bounces,[range(pm_bounces),{key,pm_bounces}]},
                        {text,PM_Search,[range(pm_search),{key,pm_search}]},
                        {text,PM_Diffuse_Radius,[range(pm_diffuse_radius),{key,pm_diffuse_radius}]}
                    ]},
                    {vframe,[
                        {label,?__(125,"Caustic Photons")},
                        {label,?__(126,"Caustic Radius")},
                        {label,?__(127,"Caustic Mix")}
                    ]},
                    {vframe,[
                        {text,PM_Caustic_Photons,[range(pm_caustic_photons),{key,pm_caustic_photons}]},
                        {text,PM_Caustic_Radius,[range(pm_caustic_radius),{key,pm_caustic_radius}]},
                        {text,PM_Caustic_Mix,[range(pm_caustic_mix),{key,pm_caustic_mix}]},
                        {?__(157,"Use Bkgnd"),PM_Use_Background,[{key,pm_use_background}]}
                    ]},
                    {vframe,[
                        {menu,[
                            {?__(128,"Final Gather Off"),false},
                            {?__(129,"Final Gather On"),true}
                        ],PM_Use_FG, [{key,pm_use_fg},layout]
                        },
                        {hframe,[
                            {vframe,[
                                {label,?__(130,"FG Bounces")},
                                {label,?__(131,"FG Samples")}
                            ]},
                            {vframe,[
                                {text,PM_FG_Bounces,[range(pm_fg_bounces),{key,pm_fg_bounces}]},
                                {text,PM_FG_Samples,[range(pm_fg_samples),{key,pm_fg_samples}]},
                                {?__(132,"Show Map"),PM_FG_Show_Map,[{key,pm_fg_show_map}]}
                            ]}
                        ],[hook(open, [member,pm_use_fg,true])]
                        }
                    ]}
                ],[hook(open, [member,lighting_method,photonmapping])]
                },
                %% Start Path Tracing Menu Section
                {hframe,[
                    {vframe,[
                        {label,?__(141,"Photons")},
                        {label,?__(142,"Bounces")}
                    ]},
                    {vframe,[
                        {text,PT_Diffuse_Photons,[range(pt_diffuse_photons),{key,pt_diffuse_photons}]},
                        {text,PT_Bounces,[range(pt_bounces),{key,pt_bounces}]}
                    ]},
                    {vframe,[
                        {label,?__(145,"Caustic Type")},
                        {label,?__(146,"Caustic Radius")},
                        {label,?__(147,"Caustic Mix")},
                        {label,?__(148,"Caustic Depth")}
                    ]},
                    {vframe,[
                        {menu,[
                            {?__(153,"path"),path},
                            {?__(154,"photons"),photons},
                            {?__(155,"both"),both},
                            {?__(156,"none"),none}
                        ],PT_Caustic_Type, [{key,pt_caustic_type},layout]
                        },
                        {text,PT_Caustic_Radius,[range(pt_caustic_radius),{key,pt_caustic_radius}]},
                        {text,PT_Caustic_Mix,[range(pt_caustic_mix),{key,pt_caustic_mix}]},
                        {text,PT_Caustic_Depth,[range(pt_caustic_depth),{key,pt_caustic_depth}]}
                    ]},
                    {vframe,[
                        {hframe,[
                            {vframe,[
                                {label,?__(152,"Path Samples")},
                                {?__(158,"Use Bkgnd"),PT_Use_Background,[{key,pt_use_background}]}
                            ]},
                            {vframe,[
                                {text,PT_Samples,[range(pt_samples),{key,pt_samples}]}
                            ]}
                        ]}
                    ]}
                ],[hook(open, [member,lighting_method,pathtracing])]
                }
            ],[{title,?__(113,"Lighting")}]
            }
        ]},
        {hframe,[
            {menu,[
                {?__(89,"None"),none},
                {?__(90,"SingleScatter"),singlescatterintegrator}
            ],Volintegr_Type, [{key,volintegr_type},layout]
            },
            {hframe,[
                {vframe,[
                    {?__(91,"Adaptive"),Volintegr_Adaptive,[{key,volintegr_adaptive}]},
                    {?__(92,"Optimize"),Volintegr_Optimize,[{key,volintegr_optimize}]}
                ]},
                {vframe,[
                    {label,?__(93,"StepSize")}
                ]},
                {vframe,[
                    {text,Volintegr_Stepsize,[range(volintegr_stepsize),{key,volintegr_stepsize}]}
                ]}
            ],[hook(open, [member,volintegr_type,singlescatterintegrator])]
            }
        ],[{title,?__(88,"Volumetrics")}]
        },
        {hframe,[
            {menu,[
                {?__(75,"Disabled"),false},
                {?__(76,"Enabled"),true}
            ],UseSSS,[{key,use_sss},layout]
            },
            {hframe,[
                {vframe,[
                    {label,?__(77,"Photons")},
                    {label,?__(78,"Depth")}
                ]},
                {vframe,[
                    {text,SSS_Photons,[range(sss_photons),{key,sss_photons}]},
                    {text,SSS_Depth,[range(sss_depth),{key,sss_depth}]}
                ]},
                {vframe,[
                    {label,?__(79,"Scale")},
                    {label,?__(80,"SingleScatter Samples")}
                ]},
                {vframe,[
                    {text,SSS_Scale,[range(sss_scale),{key,sss_scale}]},
                    {text,SSS_SingleScatter_Samples,[range(sss_singlescatter_samples),
                        {key,sss_singlescatter_samples}]}
                ]}
            ],[hook(open, [member,use_sss,true])]
            }
        ],[{title,?__(74,"SubSurface Scattering - YafaRay 0.1.3 - Photon Mapping, Path Tracing")}]
        },
        {hframe,[
            {vframe,[
                {label,?__(4,"Raydepth")},
                {label,?__(5,"Gamma")}
            ]},
            {vframe,[
                {text,Raydepth,[range(raydepth),{key,raydepth}]},
                {text,Gamma,[range(gamma),{key,gamma}]}
            ]},
            {vframe,[
                {label,?__(6,"Bias")},
                {label,?__(7,"Exposure")}
            ]},
            {vframe,[
                {text,Bias,BiasFlags},
                {text,Exposure,[range(exposure),{key,exposure}]}
            ]},
            {vframe,[
                {vframe,[
                    {menu,[
                        {?__(133,"Transp Shadows Off"),false},
                        {?__(134,"Transp Shadows On"),true}
                    ],TransparentShadows,[{key,transparent_shadows},layout]
                    },
                    {hframe,[
                        {vframe,[
                            {label,?__(135,"Depth")}
                        ]},
                        {vframe,[
                            {text,ShadowDepth,[range(shadow_depth),{key,shadow_depth}]}
                        ]}
                    ],[hook(open, [member,transparent_shadows,true])]
                    }
                ]}
            ]}
        ],[{title,?__(8,"Render")}]
        },
        {hframe,[
            {menu,[
                {Ext++" ("++Desc++")",Format}||
                {Format,Ext,Desc} <- wings_job:render_formats(),
                (Format == tga) or (Format == tif) or (Format == png) or
                   (Format == hdr) or (Format == exr)
            ],RenderFormat,[{key,render_format},layout]
            },
            {hframe,[
                {?__(9,"Float"),ExrFlagFloat,[{key,exr_flag_float}]},
                {?__(10,"Zbuf"),ExrFlagZbuf,[{key,exr_flag_zbuf}]},
                {label," "++?__(11,"Compression:")},
                {menu,[
                    {?__(12,"none"),compression_none},
                    {"piz",compression_piz},
                    {"rle",compression_rle},
                    {"pxr24",compression_pxr24},
                    {"zip",compression_zip}
                ],ExrFlagCompression,[{key,exr_flag_compression}]
                }
            ],[hook(open, [member,render_format,exr])]
            }
        ],[{title,?__(13,"Image Output")}]
        },
        {hframe,[
            {vframe,[
                {hframe,[
                    {vframe,[
                        {label,?__(14,"AA. Passes")},
                        {label,?__(15,"Min. Samples")}
                    ]},
                    {vframe,[
                        {text,AA_passes,[range(aa_passes),{key,aa_passes}]},
                        {text,AA_minsamples,[range(aa_minsamples),{key,aa_minsamples}]}
                    ]}
                ]},
                {?__(16,"AA_jitterfirst"),AA_jitterfirst,[{key,aa_jitterfirst}]}
            ]},
            {vframe,[
                {hframe,[
                    {vframe,[
                        {label,?__(17,"Threshold")},
                        {label,?__(18,"Pixelwidth")}
                    ]},
                    {vframe,[
                        {text,AA_threshold,[range(aa_threshold),{key,aa_threshold}]},
                        {text,AA_pixelwidth,[range(aa_pixelwidth),{key,aa_pixelwidth}]}
                    ]}
                ]},
                {?__(19,"Clamp RGB"),ClampRGB,[{key,clamp_rgb}]}
            ]},
            {vframe,[
                {menu,[
                    {?__(136,"Box Filter"),box},
                    {?__(137,"Gaussian Filter"),gauss},
                    {?__(138,"Mitchell-Netravali Filter"),mitchell},
                    {?__(139,"Lanczos Filter"),lanczos}
                ],AA_Filter_Type,[{key,aa_filter_type},layout]
                }
            ]}
        ],[{title,?__(20,"Anti-Aliasing")}]
        },
        {hframe,[
            {vframe,[
                %{label,?__(1000,"Background Type:")},
                {menu,[
                    {?__(1001,"Color"),constant_color},
                    {?__(1002,"Gradient"), gradient_color},
                    {?__(1003,"Texture"), texture_ibl},
                    {?__(1004,"SunSky"), sunsky},
                    {?__(1005,"DarkTide SunSky"),darksky}
                ],BackgroundType,[{key,background_type}]
                }
            ]},
            {vframe,[
                {label,?__(21,"Default Color")},
                {color,BgColor,[{key,background_color}]},
                {label,?__(22,"Alpha Channel:")},
                {menu,[
                    {?__(23,"Off"),false},
                    {?__(61,"On"),true},
                    {?__(24,"Premultiply"),premultiply},
                    {?__(25,"Backgroundmask"),backgroundmask}
                ],SaveAlpha,[{key,save_alpha}]
                }
            ]},
            %{?__(1001,"Use IBL"),UseIBL,[{key, use_IBL}]}, % povman IBL
            {?__(159,"Transp Refraction"),BackgroundTranspRefract,[{key,background_transp_refract}]}
        ],[{title,?__(26,"World Environment Settings")}]
        },
        %% Camera ------------------------------------------>
        {hframe,[
            {vframe,[
                {menu,[
                    {?__(102,"Perspective"),perspective},
                    {?__(103,"Orthographic"),orthographic},
                    {?__(104,"Architect"),architect},
                    {?__(105,"Fish Eye (Angular)"),angular}
                ],Lens_Type,[{key,lens_type},layout]
                },
                {hframe,[
                    {vframe,[
                        {label,?__(108,"Scale")}
                    ]},
                    {vframe,[
                        {text,Lens_Ortho_Scale,[range(lens_ortho_scale),{key,lens_ortho_scale}]}
                    ]}
                ],[hook(open, [member,lens_type,orthographic])]
                },
                {hframe,[
                    {vframe,[
                        {?__(109,"Circular"),Lens_Angular_Circular,[{key,lens_angular_circular}]},
                        {?__(110,"Mirrored"),Lens_Angular_Mirrored,[{key,lens_angular_mirrored}]}
                    ]},
                    {vframe,[
                        {label,?__(111,"Circle/Max Angle")},
                        {label,?__(112,"Frame/Angle")}
                    ]},
                    {vframe,[
                        {text,Lens_Angular_Max_Angle,[range(lens_angular_max_angle),{key,lens_angular_max_angle}]},
                        {text,Lens_Angular_Angle,[range(lens_angular_angle),{key,lens_angular_angle}]}
                    ]}
                ],[hook(open, [member,lens_type,angular])]
                },
                {hframe,[
                    panel,
                    {?__(32,"Use QMC"),BokehUseQMC, [{key,bokeh_use_QMC},hook(enable,['not',[member,aperture,0.0]])]}
                ]},panel
            ]},
            {vframe,[
                {label,?__(33,"Width")},
                {label,?__(34,"Aperture")},
                {label,?__(35,"DOF Type")},
                {label,?__(36,"DOF Rotation")},
                {label,?__(100,"DOF Distance")}
            ]},
            {vframe,[
                {hframe,[
                    {vframe,[
                        {text,Width,[range(pixels),{key,width},{width,6}]},
                        {text,Aperture,[range(aperture),{key,aperture},{width,6}]},
                        {menu,[
                            {?__(37,"Disk1"),disk1},
                            {?__(38,"Disk2"),disk2},
                            {?__(39,"Triangle"),triangle},
                            {?__(40,"Square"),square},
                            {?__(41,"Pentagon"),pentagon},
                            {?__(42,"Hexagon"),hexagon},
                            {?__(43,"Ring"),ring}
                        ], BokehType,[{key,bokeh_type},hook(enable,['not',[member,aperture,0.0]])]
                        }
                    ]},
                    {vframe,[
                        {label,?__(44,"Height")},
                        {label,?__(45,"f-stop")},
                        {label,?__(46,"Bias")}
                    ]},
                    %%
                    {vframe,[
                        {text,Height,[range(pixels),{key,height},{width,6}]},
                        {menu,[
                            {F,math:sqrt(A)}
                            || {F,A} <- [{"1.0",1/1},{"1.4",1/2},{"2",1/4},
                                    {"2.8",1/8},{"4",1/16},{"5.6",1/32},
                                    {"8",1/64},{"11",1/128},{"16",1/256},
                                    {"22",1/512},{"32",1/1024},
                                    {?__(47,"pinhole"),0.0}]
                        ],Aperture,[{key,aperture}]
                        },
                        {menu,[
                            {?__(48,"Uniform"),uniform},
                            {?__(49,"Center"),center},
                            {?__(50,"Edge"),edge}
                        ],BokehBias,[{key,bokeh_bias},hook(enable,['not',[member,aperture,0.0]])]
                        }
                    ]}
                ]},
                {slider,{text,BokehRotation,[range(bokeh_rotation),{key,bokeh_rotation},
                    hook(enable,['not',[member,aperture,0.0]])]}},
                {slider,{text,Dof_Distance,[range(dof_distance),{key,dof_distance},
                        hook(enable,['not',[member,aperture,0.0]])]}}
            ]}
        ],[{title,?__(51,"Camera")}]
        },
        {hframe,[
            {button,?__(55,"Save"),done,[{info,?__(56,"Save to user preferences")}]},
            {button,?__(57,"Load"),done,[{info,?__(58,"Load from user preferences")}]},
            {button,?__(59,"Reset"),done,[{info,?__(60,"Reset to default values")}]}
        ]}
    ].
