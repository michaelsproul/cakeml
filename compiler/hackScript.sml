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

(*
val inject_specs_def = Define `
  inject_specs specs (Tmod (SOME
`;

val inject_specs_def fn_names =
*)

val mod_with_name_def = Define `
  mod_with_name nm md = case md of
    Tmod nm' _ _ => nm = nm' |
    _ => F
`;

val find_mod_def = Define `
  find_mod name = FILTER (mod_with_name name)
`;

val res = check_inf ``basis``;
