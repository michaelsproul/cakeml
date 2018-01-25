open preamble
     inferenceComputeLib
     unifyLib
     unifyTheory
     unifDefTheory
     compilationLib
     basisProgTheory;

(* A simple test for the inferencer, precomputes the basis config, but doesn't store it as a constant *)
val cmp = wordsLib.words_compset ();
val () = computeLib.extend_compset
    [computeLib.Extenders
      [inferenceComputeLib.add_inference_compset,
      basicComputeLib.add_basic_compset
      ],
     computeLib.Defs
      [basisProgTheory.basis_def, t_unify_def, decode_infer_t_def, encode_infer_t_def, run_check_tscheme_inst_aux_def, check_tscheme_inst_aux_def],
     computeLib.Tys[``:infer_st``]
    ] cmp;

val inf_eval = computeLib.CBV_CONV cmp;

fun check_inf prog =
  inf_eval ``infertype_prog init_config ^(prog)``;

val opt_mod = ``
[Tmod "Option"
     (SOME
        [
         Sval "getOpt"
           (Tapp
              [Tapp [Tvar "'a"] (TC_name (Short "option"));
               Tapp [Tvar "'a"; Tvar "'a"] TC_fn] TC_fn);
         Sval "isSome"
           (Tapp
              [Tapp [Tvar "'a"] (TC_name (Short "option"));
               Tapp [] (TC_name (Short "bool"))] TC_fn);
         Sval "valOf"
           (Tapp
              [Tapp [Tvar "'a"] (TC_name (Short "option")); Tvar "'a"]
              TC_fn);
         Sval "join"
           (Tapp
              [Tapp [Tapp [Tvar "'a"] (TC_name (Short "option"))]
                 (TC_name (Short "option"));
               Tapp [Tvar "'a"] (TC_name (Short "option"))] TC_fn);
         Sval "map"
           (Tapp
              [Tapp [Tvar "'a"; Tvar "'b"] TC_fn;
               Tapp
                 [Tapp [Tvar "'a"] (TC_name (Short "option"));
                  Tapp [Tvar "'b"] (TC_name (Short "option"))] TC_fn]
              TC_fn);
         Sval "mapPartial"
           (Tapp
              [Tapp
                 [Tvar "'b";
                  Tapp [Tvar "'a"] (TC_name (Short "option"))] TC_fn;
               Tapp
                 [Tapp [Tvar "'b"] (TC_name (Short "option"));
                  Tapp [Tvar "'a"] (TC_name (Short "option"))] TC_fn]
              TC_fn);
         Sval "compose"
           (Tapp
              [Tapp [Tvar "'b"; Tvar "'a"] TC_fn;
               Tapp
                 [Tapp
                    [Tvar "'c";
                     Tapp [Tvar "'b"] (TC_name (Short "option"))] TC_fn;
                  Tapp
                    [Tvar "'c";
                     Tapp [Tvar "'a"] (TC_name (Short "option"))] TC_fn]
                 TC_fn] TC_fn);
         Sval "composePartial"
           (Tapp
              [Tapp
                 [Tvar "'b";
                  Tapp [Tvar "'a"] (TC_name (Short "option"))] TC_fn;
               Tapp
                 [Tapp
                    [Tvar "'c";
                     Tapp [Tvar "'b"] (TC_name (Short "option"))] TC_fn;
                  Tapp
                    [Tvar "'c";
                     Tapp [Tvar "'a"] (TC_name (Short "option"))] TC_fn]
                 TC_fn] TC_fn);
         Sval "isNone"
           (Tapp
              [Tapp [Tvar "'a"] (TC_name (Short "option"));
               Tapp [] (TC_name (Short "bool"))] TC_fn);
         Sval "map2"
           (Tapp
              [Tapp [Tvar "'b"; Tapp [Tvar "'c"; Tvar "'a"] TC_fn]
                 TC_fn;
               Tapp
                 [Tapp [Tvar "'b"] (TC_name (Short "option"));
                  Tapp
                    [Tapp [Tvar "'c"] (TC_name (Short "option"));
                     Tapp [Tvar "'a"] (TC_name (Short "option"))] TC_fn]
                 TC_fn] TC_fn)])
     [Dtabbrev
        (Locs <|row := 0; col := 0; offset := 0|>
           <|row := 0; col := 0; offset := 0|>) ["'a"] "option"
        (Tapp [Tvar "'a"] (TC_name (Short "option")));
      Dlet
        (Locs <|row := 0; col := 0; offset := 0|>
           <|row := 0; col := 0; offset := 0|>) (Pvar "getOpt")
        (Fun "v3"
           (Fun "v2"
              (Mat (Var (Short "v3"))
                 [(Pcon (SOME (Short "NONE")) [],Var (Short "v2"));
                  (Pcon (SOME (Short "SOME")) [Pvar "v1"],
                   Var (Short "v1"))])));
      Dlet
        (Locs <|row := 0; col := 0; offset := 0|>
           <|row := 0; col := 0; offset := 0|>) (Pvar "isSome")
        (Fun "v2"
           (Mat (Var (Short "v2"))
              [(Pcon (SOME (Short "NONE")) [],
                App (Opb Lt) [Lit (IntLit 0); Lit (IntLit 0)]);
               (Pcon (SOME (Short "SOME")) [Pvar "v1"],
                App (Opb Leq) [Lit (IntLit 0); Lit (IntLit 0)])]));
      Dlet
        (Locs <|row := 0; col := 0; offset := 0|>
           <|row := 0; col := 0; offset := 0|>) (Pvar "valOf")
        (Fun "x1"
           (Mat (Var (Short "x1"))
              [(Pcon (SOME (Short "NONE")) [],
                Raise (Con (SOME (Short "Bind")) []));
               (Pcon (SOME (Short "SOME")) [Pvar "v1"],
                Var (Short "v1"))]));
      Dlet
        (Locs <|row := 0; col := 0; offset := 0|>
           <|row := 0; col := 0; offset := 0|>) (Pvar "join")
        (Fun "v2"
           (Mat (Var (Short "v2"))
              [(Pcon (SOME (Short "NONE")) [],
                Con (SOME (Short "NONE")) []);
               (Pcon (SOME (Short "SOME")) [Pvar "v1"],
                Var (Short "v1"))]));
      Dlet
        (Locs <|row := 0; col := 0; offset := 0|>
           <|row := 0; col := 0; offset := 0|>) (Pvar "map")
        (Fun "v2"
           (Fun "v3"
              (Mat (Var (Short "v3"))
                 [(Pcon (SOME (Short "NONE")) [],
                   Con (SOME (Short "NONE")) []);
                  (Pcon (SOME (Short "SOME")) [Pvar "v1"],
                   Con (SOME (Short "SOME"))
                     [App Opapp
                        [Var (Short "v2"); Var (Short "v1")]])])));
      Dlet
        (Locs <|row := 0; col := 0; offset := 0|>
           <|row := 0; col := 0; offset := 0|>) (Pvar "mapPartial")
        (Fun "v2"
           (Fun "v3"
              (Mat (Var (Short "v3"))
                 [(Pcon (SOME (Short "NONE")) [],
                   Con (SOME (Short "NONE")) []);
                  (Pcon (SOME (Short "SOME")) [Pvar "v1"],
                   App Opapp [Var (Short "v2"); Var (Short "v1")])])));
      Dlet
        (Locs <|row := 0; col := 0; offset := 0|>
           <|row := 0; col := 0; offset := 0|>) (Pvar "compose")
        (Fun "v3"
           (Fun "v4"
              (Fun "v2"
                 (Mat (App Opapp [Var (Short "v4"); Var (Short "v2")])
                    [(Pcon (SOME (Short "NONE")) [],
                      Con (SOME (Short "NONE")) []);
                     (Pcon (SOME (Short "SOME")) [Pvar "v1"],
                      Con (SOME (Short "SOME"))
                        [App Opapp
                           [Var (Short "v3"); Var (Short "v1")]])]))));
      Dlet
        (Locs <|row := 0; col := 0; offset := 0|>
           <|row := 0; col := 0; offset := 0|>) (Pvar "composePartial")
        (Fun "v3"
           (Fun "v4"
              (Fun "v2"
                 (Mat (App Opapp [Var (Short "v4"); Var (Short "v2")])
                    [(Pcon (SOME (Short "NONE")) [],
                      Con (SOME (Short "NONE")) []);
                     (Pcon (SOME (Short "SOME")) [Pvar "v1"],
                      App Opapp
                        [Var (Short "v3"); Var (Short "v1")])]))));
      Dlet
        (Locs <|row := 0; col := 0; offset := 0|>
           <|row := 0; col := 0; offset := 0|>) (Pvar "isNone")
        (Fun "v2"
           (Mat (Var (Short "v2"))
              [(Pcon (SOME (Short "NONE")) [],
                App (Opb Leq) [Lit (IntLit 0); Lit (IntLit 0)]);
               (Pcon (SOME (Short "SOME")) [Pvar "v1"],
                App (Opb Lt) [Lit (IntLit 0); Lit (IntLit 0)])]));
      Dlet
        (Locs <|row := 0; col := 0; offset := 0|>
           <|row := 0; col := 0; offset := 0|>) (Pvar "map2")
        (Fun "v1"
           (Fun "v2"
              (Fun "v3"
                 (If
                    (Log And
                       (App Opapp
                          [Var (Short "isSome"); Var (Short "v2")])
                       (App Opapp
                          [Var (Short "isSome"); Var (Short "v3")]))
                    (Con (SOME (Short "SOME"))
                       [App Opapp
                          [App Opapp
                             [Var (Short "v1");
                              App Opapp
                                [Var (Short "valOf");
                                 Var (Short "v2")]];
                           App Opapp
                             [Var (Short "valOf"); Var (Short "v3")]]])
                    (Con (SOME (Short "NONE")) [])))))]]
``;

val opt_mod = ``[EL 31 basis]``;

val res = check_inf opt_mod;

val res = check_inf ``DROP 32 basis``;

val res = check_inf ``option_prog``;
