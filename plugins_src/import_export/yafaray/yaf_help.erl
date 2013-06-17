%%
help_button(Subject) ->
    Title = help(title, Subject),
    TextFun = fun () -> help(text, Subject) end,
    {help,Title,TextFun}.

help(title, {material_dialog,object}) ->
    ?__(6,"YafaRay Material Properties: Object Parameters");
help(text, {material_dialog,object}) ->
    [?__(7,"Object Parameters are applied to whole objects, namely those "
      "that have this material on a majority of their faces."),
     ?__(8,"Mapping to YafaRay object parameters:"),
     ?__(9,"Cast Shadow -> 'shadow'."),
     ?__(10,"Emit Rad -> 'emit_rad' -> Emit Radiosity."),
     ?__(11,"Recv Rad -> 'recv_rad' -> Receive Radiosity."),
     ?__(12,"Use Edge Hardness -> Emulate hard edges by "
      "slitting the object mesh along hard edges."),
     ?__(13,"Autosmooth Angle -> 'autosmooth'."),
     ?__(14,"A Photon Light must be present for Emit Rad and Recv Rad "
     "to have an affect. Set Fresnel Parameters to add Caustics.")];
help(title, {material_dialog,fresnel}) ->
    ?__(15,"YafaRay Material Properties: Fresnel Parameters");
help(text, {material_dialog,fresnel}) ->
    [?__(16,"Fresnel Parameters affect how rays reflect off and refract in "
      "glass-like materials. This is a different light model than the "
      "OpenGL (Diffuse,Specular,Shininess) model and they do not often "
      "go well together. "
      "A Photon Light must be present to produce Caustics."),
     ?__(17,"Mapping to YafaRay shader parameters:"),
     ?__(18,"Index Of Refraction -> 'ior' -> 1.5 for Glass/Caustics."),
     ?__(19,"Total Internal Reflection -> 'tir' -> Enable for Glass."),
     ?__(20,"Minimum Reflection -> 'min_refle' -> 1.0 for Metal."),
     ?__(21,"Reflected -> 'reflected' -> Reflective Caustics."),
     ?__(22,"Transmitted -> 'transmitted' -> Glass/Refractive Caustics."),
     ?__(23,"Set Default -> Sets 'transmitted' to Diffuse * (1 - Opacity). "
      "This makes a semi-transparent object in OpenGL look the same in "
      "YafaRay provided that Index Of Refraction is 1.1 minimum."),
     ?__(24,"Grazing Angle Colors -> Use the secondary Reflected and Transmitted "
      "colors following that show from grazing angles of the material. "
      "For a glass with green edges set Transmitted to white and "
      "Grazing Angle Transmitted to green."),
     ?__(25,"Absorption -> Sets the desired color for white light travelling "
      "the given distance through the material.")];

% povman test: for new help
% The chars limits before truncate line is 65
% TODO: sync the numbers with the UI

help(title, glossy_help_dialog) ->
    ?__(1022,"Glossy Help");
help(text, glossy_help_dialog)->
    [?__(1122,"Glossy Material\n
    A glossy reflection means that tiny random bumps on the
    surface of the material cause the reflection to be blurry.
    In fact there is a wide range of materials with such a reflection.
    YafaRay glossy material can be useful for all kinds of finished
    surfaces such as plastics, polished metal, car paint, finished
    wood, lacquered surfaces, painted surfaces, varnished wood,
    glaze, organic materials, etc. The glossy effect can be
    reinforced by using a fine bump map, or by mapping glossy
    reflection with a fine texture.
    For more info visit:
    http://www.yafaray.org/documentation/userguide/material#glossy")];

help(title, shiny_help_dialog) ->
    ?__(1023,"Shiny Diffuse Help");

help(text, shiny_help_dialog) ->
    [?__(1123, "New Help for shinydiffuse material
    Shinydiffuse is a shader with many applications.
    It can be useful to get:
    * Diffuse materials without any specular component.
    * Perfect mirror reflection with or without Fresnel effect.
    * Alpha mapping with shadows calculation derived from the
    * map, for translucency and transparency effects.
    * Translucency with color filtering.
    * Transparency with color filtering.
    * Emit surfaces.
    For instance, this material can be used for rough stone,
    rusted metal, concrete, fabric, clay, asphalt, paper, rough
    wood, chrome balls, shiny plastics, basic car paint,
    curtains, leaves, billboards, etc.
    For more info visit:
    http://www.yafaray.org/documentation/userguide/material#shinydiffuse")];

help(title, shader_dialog) ->
    ?__(10024,"Shader Modulator Settings");

help(text, shader_dialog) ->
    [?__(10025,"Shader Parameters:\n"
    "Next shader help")];

help(title, ibl_dialog) ->
    ?__(10026,"Background Light Settings");

help(text, ibl_dialog) ->
    [?__(10027,"Parameters:\n"
        "\nUse Background Light -> Enable this option to use the background\n"
        "as a light source. A HDR or EXR image is needed.\n"
        "\nPower -> A multiplier for background colors.\n"
        "\nSamples -> Defines the amount of samples taken to calculate the\n"
        "soft shadows. The more samples, the less noisy the shadows but\n"
        "the longer it will take to render."
        "\nThe total amount of light sampling depends as well on the\n"
        "anti-aliasing settings. See AA Help area, for more info.\n"
        "\nDiffuse Photons -> Use the light info for diffuse photons.\n"
        "\nCaustics Photons -> Use the light info for caustics photons.")
    ];

%%
help(title, light_dialog) ->
    ?__(26,"YafaRay Light Properties");

help(text, light_dialog) ->
    [?__(27,"OpenGL properties that map to YafaRay light parameters are:"),
     ?__(28,"Diffuse -> 'color'"),
     ?__(29,"All other OpenGl properties are ignored, particulary the "
      "Attenuation properties."),
     ?__(30,"Spotlight set to Photonlight is used to produce Caustics or Radiosity. "
      "Photonlight set to Caustic for Caustics. "
      "Photonlight set to Diffuse for Radiosity. "),
     ?__(31,"The 'Use IBL' checkbox in a Hemilight with an image background "
      "activates the background image as ambient light source instead of "
      "the defined ambient color by excluding the 'color' tag "
      "from the Hemilight."),
     ?__(32,"Note: For a YafaRay Global Photon Light (one of the Ambient lights) - "
      "the Power parameter is ignored")];
help(title, pref_dialog) ->
    ?__(33,"YafaRay Options");
help(text, pref_dialog) ->
    [?__(34,"These are user preferences for the YafaRay exporter plugin"),
     ?__(35,"Automatic Dialogs: ")
     ++wings_help:cmd([?__(36,"File"),?__(37,"Export"),?__(38,"YafaRay")])++", "
     ++wings_help:cmd([?__(39,"File"),?__(40,"Export Selected"),?__(41,"YafaRay")])++" "++?__(42,"and")++" "
     ++wings_help:cmd([?__(43,"File"),?__(44,"Render"),?__(45,"YafaRay")])++" "++
     ?__(46,"are enabled if the rendering executable is found (in the path), "
     "or if the rendering executable is specified with an absolute path."),
     %%
     ?__(47,"Disabled Dialogs:")++" "
     ++wings_help:cmd([?__(48,"File"),?__(49,"Export"),?__(50,"YafaRay")])++", "
     ++wings_help:cmd([?__(51,"File"),?__(52,"Export Selected"),?__(53,"YafaRay")])++" "++?__(54,"and")++" "
     ++wings_help:cmd([?__(55,"File"),?__(56,"Render"),?__(57,"YafaRay")])++" "++
     ?__(58,"are disabled."),
     %%
     ?__(59,"Enabled Dialogs:")++" "
     ++wings_help:cmd([?__(60,"File"),?__(61,"Export"),?__(62,"YafaRay")])++" "++?__(63,"and")++" "
     ++wings_help:cmd([?__(64,"File"),?__(65,"Export Selected"),?__(66,"YafaRay")])++" "++
     ?__(67,"are always enabled, but")++" "
     ++wings_help:cmd([?__(68,"File"),?__(69,"Render"),?__(70,"YafaRay")])++" "++
     ?__(71,"is still as for \"Automatic Dialogs\"."),
     %%
     ?__(72,"Executable: The rendering command for the YafaRay raytrace "
      "renderer ('c:/yafaray/bin/yafaray-xml.exe') that is supposed to "
      "be found in the executables search path; or, the absolute path of "
      "that executable. You may have to add YafaRay to your computer's "
      "Path Settings. My Computer > Properties > Advanced Tab > "
      "Environment Variables > User Variables > Path > Edit > Variable "
      "Value > add 'c:/yafaray', without ' '. Notice that each added item "
      "has a semicolon (;) before and after it."),
     ?__(73,"Options: Rendering command line options to be inserted between the "
      "executable and the .xml filename. -dp (add render settings badge) "
      "-vl (verbosity level) -pp (plugins path)'c:/yafaray/bin/plugins'. ")].
