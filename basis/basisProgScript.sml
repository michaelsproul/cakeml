open preamble ml_translatorLib ml_progLib cfLib basisFunctionsLib
     CommandLineProofTheory TextIOProofTheory

val _ = new_theory "basisProg"

val _ = translation_extends"TextIOProg";

val print_eval_thm = derive_eval_thm"print"``Var(Long"TextIO"(Short"print"))``
val () = ml_prog_update (add_Dlet print_eval_thm "print" [])

val res = register_type``:'a app_list``;
val MISC_APP_LIST_TYPE_def = theorem"MISC_APP_LIST_TYPE_def";

val print_app_list = process_topdecs
  `fun print_app_list ls =
   (case ls of
      Nil => ()
    | List ls => TextIO.print_list ls
    | Append l1 l2 => (print_app_list l1; print_app_list l2))`;
val () = append_prog print_app_list;

val print_app_list_spec = Q.store_thm("print_app_list_spec",
  `∀ls lv out. MISC_APP_LIST_TYPE STRING_TYPE ls lv ⇒
   app (p:'ffi ffi_proj) ^(fetch_v "print_app_list" (get_ml_prog_state())) [lv]
     (STDIO fs) (POSTv v. &UNIT_TYPE () v * STDIO (add_stdout fs (concat (append ls))))`,
  reverse(Cases_on`STD_streams fs`) >- (rw[STDIO_def] \\ xpull) \\
  pop_assum mp_tac \\ simp[PULL_FORALL] \\ qid_spec_tac`fs` \\
  reverse (Induct_on`ls`) \\ rw[MISC_APP_LIST_TYPE_def]
  >- (
    xcf "print_app_list" (get_ml_prog_state())
    \\ xmatch \\ xcon
    \\ DEP_REWRITE_TAC[GEN_ALL add_stdo_nil]
    \\ xsimpl \\ metis_tac[STD_streams_stdout])
  >- (
    xcf "print_app_list" (get_ml_prog_state())
    \\ xmatch
    \\ xlet_auto >- xsimpl
    \\ xapp
    \\ qmatch_goalsub_abbrev_tac`STDIO fs'`
    \\ CONV_TAC SWAP_EXISTS_CONV \\ qexists_tac`fs'` \\ xsimpl
    \\ simp[Abbr`fs'`,STD_streams_add_stdout]
    \\ DEP_REWRITE_TAC[GEN_ALL add_stdo_o]
    \\ simp[mlstringTheory.concat_thm,mlstringTheory.strcat_thm]
    \\ xsimpl
    \\ metis_tac[STD_streams_stdout])
  \\ xcf "print_app_list" (get_ml_prog_state())
  \\ xmatch
  \\ xapp
  \\ simp[]);

val _ = (append_prog o process_topdecs)
  `fun print_int i = TextIO.print (Int.toString i)`;

val print_int_spec = Q.store_thm("print_int_spec",
  `INT i iv ⇒
   app (p:'ffi ffi_proj) ^(fetch_v "print_int" (get_ml_prog_state())) [iv]
     (STDIO fs) (POSTv v. &UNIT_TYPE () v * STDIO (add_stdout fs (toString i)))`,
  xcf"print_int"(get_ml_prog_state())
  \\ xlet_auto >- xsimpl
  \\ xapp \\ xsimpl);

val basis_st = get_ml_prog_state ();

val basis_prog_state = save_thm("basis_prog_state",
  ml_progLib.pack_ml_prog_state basis_st);

val basis_prog = basis_st |> remove_snocs
  |> get_thm |> concl |> rator |> rator |> rator |> rand

val basis_def = Define `basis = ^basis_prog`;

val _ = export_theory ()
