open preamble ml_translatorLib ml_progLib
open listTheory

(*this library depends on nothing*)
val _ = new_theory"listProg"
val _ = ml_prog_update (open_module "List");



val _ = append_dec ``Dtabbrev ["'a"] "list" (Tapp [Tvar "'a"] (TC_name (Short "list")))``;


val result = translate NULL_DEF;


val result = translate LENGTH;


val result = translate APPEND;


val result = translate HD;

val result = translate tl_def;
val result = next_ml_names := ["tl_hol_def"];
val result = translate TL;


val result = translate LAST_DEF;


val result = translate getItem_def;


val result = translate (EL |> REWRITE_RULE[GSYM nth_def]);


val result = translate (TAKE_def |> REWRITE_RULE[GSYM take_def]);


val result = translate (DROP_def |> REWRITE_RULE[GSYM drop_def]);


val result = next_ml_names := ["rev_def"];
val result = translate REVERSE_DEF;


val result = next_ml_names := ["concat_def"];
val result = translate FLAT;


val result = translate REV_DEF;


val result = translate MAP;


val result = translate mapPartial_def;


val result = translate find_def;


val result = translate FILTER;


val result = translate partition_aux_def;
val result = translate partition_def;


val result = translate FOLDL;


val result = translate FOLDR;


val result = translate EXISTS_DEF;


val result = next_ml_names := ["all_def"];
val result = translate EVERY_DEF;


val result = translate GENLIST_AUX;
val result = translate GENLIST_GENLIST_AUX;
val result = translate (GENLIST |> REWRITE_RULE[GSYM tabulate_def]);


val result = translate collate_def;

val result = translate zip_def;

val result = translate scanl_def;

val result = translate scanr_def;



(*Extra translations from std_preludeLib.sml *)

val result = translate SUM;
val result = translate UNZIP;
val result = translate SNOC;
val result = translate PAD_RIGHT;
val result = translate PAD_LEFT;
val result = translate MEMBER_def;
val result = translate (ALL_DISTAINCE |> REWRITE_RULE [MEMBER_INTRO]);
val result = translate isPREFIX;
val result = translate FRONT_DEF;
val result = translate (splitAtPki_def |> REWRITE_RULE [SUC_LEMMA])

val front_side_def = Q.prove(
  `!xs. front_side xs = ~(xs = [])`,
  Induct THEN ONCE_REWRITE_TAC [fetch "-" "front_side_def"]
  THEN FULL_SIMP_TAC (srw_ss()) [CONTAINER_def])
  |> update_precondition;

val zip_side_def = Q.prove(
  `!x. zip_side x = (LENGTH (FST x) = LENGTH (SND x))`,
  Cases THEN Q.SPEC_TAC (`r`,`r`) THEN Induct_on `q` THEN Cases_on `r`
  THEN ONCE_REWRITE_TAC [fetch "-" "zip_side_def"]
  THEN FULL_SIMP_TAC (srw_ss()) [])
  |> update_precondition;

val el_side_def = Q.prove(
  `!n xs. el_side n xs = (n < LENGTH xs)`,
  Induct THEN Cases_on `xs` THEN ONCE_REWRITE_TAC [fetch "-" "el_side_def"]
  THEN FULL_SIMP_TAC (srw_ss()) [CONTAINER_def])
  |> update_precondition;

val last_side_def = Q.prove(
  `!xs. last_side xs = ~(xs = [])`,
  Induct THEN ONCE_REWRITE_TAC [fetch "-" "last_side_def"]
  THEN FULL_SIMP_TAC (srw_ss()) [CONTAINER_def])
  |> update_precondition;


val ml_prog_update (close_module NONE);
val _ = export_theory()
