open preamble
     stack_namesTheory
     stackSemTheory stackPropsTheory
local open dep_rewrite in end

val _ = new_theory"stack_namesProof";

(* TODO: move *)

val BIJ_IMP_11 = prove(
  ``BIJ f UNIV UNIV ==> !x y. (f x = f y) = (x = y)``,
  fs [BIJ_DEF,INJ_DEF] \\ metis_tac []);

val FLOOKUP_MAP_KEYS = Q.store_thm("FLOOKUP_MAP_KEYS",
  `INJ f (FDOM m) UNIV ⇒
   FLOOKUP (MAP_KEYS f m) k =
   OPTION_BIND (some x. k = f x ∧ x ∈ FDOM m) (FLOOKUP m)`,
  strip_tac >> DEEP_INTRO_TAC some_intro >>
  simp[FLOOKUP_DEF,MAP_KEYS_def]);

val FLOOKUP_MAP_KEYS_MAPPED = Q.store_thm("FLOOKUP_MAP_KEYS_MAPPED",
  `INJ f UNIV UNIV ⇒
   FLOOKUP (MAP_KEYS f m) (f k) = FLOOKUP m k`,
  strip_tac >>
  `INJ f (FDOM m) UNIV` by metis_tac[INJ_SUBSET,SUBSET_UNIV,SUBSET_REFL] >>
  simp[FLOOKUP_MAP_KEYS] >>
  DEEP_INTRO_TAC some_intro >> rw[] >>
  fs[INJ_DEF] >> fs[FLOOKUP_DEF] >> metis_tac[]);

val DRESTRICT_MAP_KEYS_IMAGE = Q.store_thm("DRESTRICT_MAP_KEYS_IMAGE",
  `INJ f UNIV UNIV ⇒
   DRESTRICT (MAP_KEYS f fm) (IMAGE f s) = MAP_KEYS f (DRESTRICT fm s)`,
  rw[fmap_eq_flookup,FLOOKUP_DRESTRICT] >>
  dep_rewrite.DEP_REWRITE_TAC[FLOOKUP_MAP_KEYS,FDOM_DRESTRICT] >>
  conj_tac >- ( metis_tac[IN_INTER,IN_UNIV,INJ_DEF] ) >>
  DEEP_INTRO_TAC some_intro >>
  DEEP_INTRO_TAC some_intro >>
  rw[FLOOKUP_DRESTRICT] >> rw[] >> fs[] >>
  metis_tac[INJ_DEF,IN_UNIV]);

val DOMSUB_MAP_KEYS = Q.store_thm("DRESTRICT_MAP_KEYS",
  `BIJ f UNIV UNIV ⇒
   (MAP_KEYS f fm) \\ (f s) = MAP_KEYS f (fm \\ s)`,
  rw[fmap_domsub] >>
  dep_rewrite.DEP_REWRITE_TAC[GSYM DRESTRICT_MAP_KEYS_IMAGE] >>
  rw[] >- fs[BIJ_DEF] >>
  AP_TERM_TAC >>
  rw[EXTENSION] >>
  fs[BIJ_DEF,INJ_DEF,SURJ_DEF] >>
  metis_tac[]);

(* -- *)

val rename_state_def = Define `
  rename_state f s =
   s with
   <| regs := MAP_KEYS (find_name f) s.regs
    ; code := fromAList (compile f (toAList s.code))
    ; ffi_save_regs := IMAGE (find_name f) s.ffi_save_regs
    |>`

val rename_state_with_clock = Q.store_thm("rename_state_with_clock",
  `rename_state f (s with clock := k) = rename_state f s with clock := k`,
  EVAL_TAC);

val dec_clock_rename_state = Q.store_thm("dec_clock_rename_state",
  `dec_clock (rename_state x y) = rename_state x (dec_clock y)`,
  EVAL_TAC >> simp[state_component_equality]);

val mem_load_rename_state = Q.store_thm("mem_load_rename_state[simp]",
  `mem_load x (rename_state f s) = mem_load x s`,
  EVAL_TAC);

val mem_store_rename_state = Q.store_thm("mem_store_rename_state[simp]",
  `mem_store x y (rename_state f s) = OPTION_MAP (rename_state f) (mem_store x y s)`,
  EVAL_TAC >> rw[] >> EVAL_TAC);

val get_var_find_name = store_thm("get_var_find_name[simp]",
  ``BIJ (find_name f) UNIV UNIV ==>
    get_var (find_name f v) (rename_state f s) = get_var v s``,
  fs [get_var_def,rename_state_def,FLOOKUP_DEF,MAP_KEYS_def]
  \\ rpt strip_tac \\ imp_res_tac BIJ_IMP_11 \\ fs []
  \\ rw [] \\ fs [] \\ once_rewrite_tac [EQ_SYM_EQ]
  \\ match_mp_tac (MAP_KEYS_def |> SPEC_ALL |> CONJUNCT2 |> MP_CANON)
  \\ fs [INJ_DEF]);

val get_var_imm_find_name = Q.store_thm("get_var_imm_find_name[simp]",
  `BIJ (find_name f) UNIV UNIV ⇒
   get_var_imm (ri_find_name f ri) (rename_state f s) =
   get_var_imm ri s`,
  Cases_on`ri`>>EVAL_TAC>>strip_tac>>
  dep_rewrite.DEP_REWRITE_TAC[FLOOKUP_MAP_KEYS] >>
  conj_tac >- metis_tac[INJ_DEF,BIJ_IMP_11,IN_UNIV] >>
  DEEP_INTRO_TAC some_intro >> simp[] >>
  fs[GSYM find_name_def] >>
  metis_tac[BIJ_DEF,INJ_DEF,IN_UNIV,FLOOKUP_DEF]);

val FLOOKUP_rename_state_find_name = Q.store_thm("FLOOKUP_rename_state_find_name[simp]",
  `BIJ (find_name f) UNIV UNIV ⇒
   FLOOKUP (rename_state f s).regs (find_name f k) = FLOOKUP s.regs k`,
  rw[BIJ_DEF] >>
  rw[rename_state_def] >>
  simp[FLOOKUP_MAP_KEYS_MAPPED]);

val prog_comp_eta = Q.prove(
  `prog_comp f = λ(x,y). (x,comp f y)`,
  rw[prog_comp_def,FUN_EQ_THM,FORALL_PROD])

val find_code_rename_state = Q.store_thm("find_code_rename_state[simp]",
  `BIJ (find_name f) UNIV UNIV ⇒
   find_code (dest_find_name f dest) (rename_state f s).regs (rename_state f s).code =
   OPTION_MAP (comp f) (find_code dest s.regs s.code)`,
  strip_tac >>
  Cases_on`dest`>>rw[find_code_def,rename_state_def,dest_find_name_def] >- (
    simp[lookup_fromAList,compile_def,prog_comp_eta,ALOOKUP_MAP,ALOOKUP_toAList] >>
    metis_tac[] ) >>
  dep_rewrite.DEP_REWRITE_TAC[FLOOKUP_MAP_KEYS] >>
  conj_tac >- metis_tac[BIJ_IMP_11,INJ_DEF,IN_UNIV] >>
  DEEP_INTRO_TAC some_intro >> simp[] >>
  reverse conj_tac >- (
    rw[] >> simp[FLOOKUP_DEF] >> rw[] >> metis_tac[] ) >>
  rw[] >>
  `x = y` by metis_tac[BIJ_IMP_11] >>
  rw[FLOOKUP_DEF] >>
  simp[lookup_fromAList,compile_def,prog_comp_eta,ALOOKUP_MAP,ALOOKUP_toAList] >>
  CASE_TAC >> simp[] >>
  CASE_TAC >> simp[] >>
  metis_tac[]);

val set_var_find_name = Q.store_thm("set_var_find_name",
  `BIJ (find_name f) UNIV UNIV ⇒
   rename_state f (set_var x y z) =
   set_var (find_name f x) y (rename_state f z)`,
  rw[set_var_def,rename_state_def,state_component_equality] >>
  match_mp_tac MAP_KEYS_FUPDATE >>
  metis_tac[BIJ_IMP_11,INJ_DEF,IN_UNIV]);

val inst_rename = Q.store_thm("inst_rename",
  `BIJ (find_name f) UNIV UNIV ⇒
   inst (inst_find_name f i) (rename_state f s) =
   OPTION_MAP (rename_state f) (inst i s)`,
  rw[inst_def] >>
  rw[inst_find_name_def] >>
  CASE_TAC >> fs[] >- (
    EVAL_TAC >>
    simp[state_component_equality] >>
    dep_rewrite.DEP_REWRITE_TAC[MAP_KEYS_FUPDATE] >>
    conj_tac >- (
      fs[BIJ_IFF_INV,INJ_DEF] >>
      metis_tac[] ) >>
    simp[fmap_eq_flookup,FLOOKUP_UPDATE] >>
    gen_tac >>
    `INJ (find_name f) (FDOM s.regs) UNIV` by
      metis_tac[BIJ_IMP_11,INJ_DEF,IN_UNIV] >>
    simp[FLOOKUP_MAP_KEYS] >>
    DEEP_INTRO_TAC some_intro >> simp[] >>
    simp[find_name_def] ) >>
  CASE_TAC >> fs[assign_def,word_exp_def] >>
  every_case_tac >> fs[LET_THM,word_exp_def,ri_find_name_def,wordSemTheory.num_exp_def] >>
  rw[] >> fs[] >> rfs[] >> rw[set_var_find_name]
  \\ every_case_tac \\ fs [wordSemTheory.word_op_def]
  \\ rw [] \\ fs [] \\ fs [BIJ_DEF,INJ_DEF] \\ res_tac \\ fs [])

val MAP_FST_compile = Q.store_thm("MAP_FST_compile[simp]",
  `MAP FST (stack_names$compile f c) = MAP FST c`,
  rw[compile_def,MAP_MAP_o,MAP_EQ_f,prog_comp_def,FORALL_PROD]);

val comp_correct = Q.prove(
  `!p s r t.
     evaluate (p,s) = (r,t) /\ BIJ (find_name f) UNIV UNIV /\
     ~s.use_alloc /\ ~s.use_store /\ ~s.use_stack ==>
     evaluate (comp f p, rename_state f s) = (r, rename_state f t)`,
  recInduct evaluate_ind \\ rpt strip_tac
  THEN1 (fs [evaluate_def,comp_def] \\ rpt var_eq_tac)
  THEN1 (fs [evaluate_def,comp_def] \\ rpt var_eq_tac \\ CASE_TAC \\ fs [])
  THEN1 (fs [evaluate_def,comp_def,rename_state_def] \\ rpt var_eq_tac \\ fs [])
  THEN1 (fs [evaluate_def,comp_def] >>
    every_case_tac >> fs[] >> rveq >> fs[] >>
    imp_res_tac inst_rename >> fs[])
  THEN1 (fs [evaluate_def,comp_def,rename_state_def] >> rveq >> fs[])
  THEN1 (fs [evaluate_def,comp_def,rename_state_def] >> rveq >> fs[])
  THEN1 (fs [evaluate_def,comp_def,rename_state_def] \\ rw []
         \\ fs [] \\ rw [] \\ fs [empty_env_def,dec_clock_def])
  THEN1
   (simp [Once evaluate_def,Once comp_def]
    \\ fs [evaluate_def,LET_DEF] \\ split_pair_tac \\ fs []
    \\ rw [] \\ fs [] \\ rfs [] \\ fs []
    \\ imp_res_tac evaluate_consts \\ fs [])
  THEN1 (fs [evaluate_def,comp_def] \\ rpt var_eq_tac \\ every_case_tac \\ fs [])
  THEN1 (fs [evaluate_def,comp_def] \\ rpt var_eq_tac \\ every_case_tac \\ fs [])
  THEN1 (
    fs[evaluate_def] >>
    simp[Once comp_def] >>
    simp[evaluate_def] >>
    BasicProvers.TOP_CASE_TAC >> fs[] >>
    BasicProvers.TOP_CASE_TAC >> fs[] >>
    BasicProvers.TOP_CASE_TAC >> fs[] >>
    BasicProvers.TOP_CASE_TAC >> fs[] >>
    BasicProvers.TOP_CASE_TAC >> fs[] )
  (* JumpLess *)
  THEN1 (
    simp[Once comp_def] >>
    fs[evaluate_def] >>
    BasicProvers.TOP_CASE_TAC >> fs[] >>
    BasicProvers.TOP_CASE_TAC >> fs[] >>
    BasicProvers.TOP_CASE_TAC >> fs[] >>
    BasicProvers.TOP_CASE_TAC >> fs[] >>
    BasicProvers.TOP_CASE_TAC >> fs[] >>
    fs[find_code_def] >>
    simp[Once rename_state_def] >>
    simp[lookup_fromAList] >>
    BasicProvers.TOP_CASE_TAC >> fs[] >- (
      imp_res_tac ALOOKUP_FAILS >>
      qpat_assum`_ = (r,_)`mp_tac >>
      BasicProvers.TOP_CASE_TAC >> fs[] >>
      `dest ∈ domain s.code` by metis_tac[domain_lookup] >>
      `¬MEM dest (MAP FST (compile f (toAList s.code)))` by (
        simp[MEM_MAP,EXISTS_PROD] ) >>
      fs[] >>
      metis_tac[toAList_domain] ) >>
    simp[Once rename_state_def] >>
    imp_res_tac ALOOKUP_MEM >>
    `MEM dest (MAP FST (compile f (toAList s.code)))` by (
      simp[MEM_MAP,EXISTS_PROD] >> metis_tac[]) >>
    fs[] >>
    `dest ∈ domain s.code` by metis_tac[toAList_domain] >>
    fs[domain_lookup] >> fs[] >>
    IF_CASES_TAC >> fs[] >- (rveq >> EVAL_TAC >> simp[state_component_equality] ) >>
    qpat_assum`_ = (r,_)`mp_tac >>
    BasicProvers.TOP_CASE_TAC >> fs[] >>
    fs[compile_def,MEM_MAP,EXISTS_PROD,prog_comp_def] >>
    fs[MEM_toAList] >> rveq >>
    fs[dec_clock_rename_state] >>
    BasicProvers.TOP_CASE_TAC >> fs[])
  (* Call *)
  THEN1 (
    simp[Once comp_def] >>
    fs[evaluate_def] >>
    BasicProvers.TOP_CASE_TAC >> fs[] >- (
      pop_assum mp_tac >>
      reverse BasicProvers.TOP_CASE_TAC >> fs[] >- (
        BasicProvers.TOP_CASE_TAC >> simp[] >>
        BasicProvers.TOP_CASE_TAC >> simp[] >>
        BasicProvers.TOP_CASE_TAC >> simp[] ) >>
      qpat_assum`_ = (r,_)`mp_tac >>
      BasicProvers.TOP_CASE_TAC >> fs[] >>
      reverse(Cases_on`handler`)>>fs[]>-(
        (fn g => subterm split_pair_case_tac (#2 g) g) >> simp[] ) >>
      simp[Once rename_state_def] >>
      IF_CASES_TAC >> fs[] >- (
        rw[] >> EVAL_TAC >> simp[state_component_equality] ) >>
      simp[dec_clock_rename_state] >>
      BasicProvers.TOP_CASE_TAC >> fs[] >>
      BasicProvers.TOP_CASE_TAC >> fs[] ) >>
    (fn g => subterm split_pair_case_tac (#2 g) g) >> simp[] >>
    rveq >> pop_assum mp_tac >>
    BasicProvers.TOP_CASE_TAC >> fs[] >>
    (fn g => subterm split_pair_case_tac (#2 g) g) >> simp[] >>
    strip_tac >> rveq >> fs[] >>
    simp[Once rename_state_def] >>
    simp[DOMSUB_MAP_KEYS] >>
    simp[
      find_code_rename_state
      |> Q.GEN`s` |> Q.SPEC`s with regs := s.regs \\ lr`
      |> SIMP_RULE (std_ss)[Once rename_state_def] |> SIMP_RULE (srw_ss())[]
      |> SIMP_RULE std_ss [EVAL``(rename_state f (s with regs := x)).code = (rename_state f s).code``|>EQT_ELIM]] >>
    qpat_assum`_ = (r,_)`mp_tac >>
    BasicProvers.TOP_CASE_TAC >> fs[] >>
    simp[Once rename_state_def] >>
    IF_CASES_TAC >> fs[] >- (
      rw[] >> EVAL_TAC >> simp[state_component_equality] ) >>
    simp[GSYM set_var_find_name,dec_clock_rename_state] >>
    BasicProvers.TOP_CASE_TAC >> fs[] >>
    BasicProvers.TOP_CASE_TAC >> fs[] >>
    BasicProvers.TOP_CASE_TAC >> fs[] >- (
      rw[] >> rfs[] >>
      first_x_assum match_mp_tac >>
      imp_res_tac evaluate_consts >>
      fs[rename_state_def] ) >>
    BasicProvers.TOP_CASE_TAC >> fs[] >>
    BasicProvers.TOP_CASE_TAC >> fs[] >>
    BasicProvers.TOP_CASE_TAC >> fs[] >>
    BasicProvers.TOP_CASE_TAC >> fs[] >>
    strip_tac >> fs[] >>
    first_x_assum match_mp_tac >>
    imp_res_tac evaluate_consts >>
    fs[rename_state_def] )
  (* FFI *)
  THEN1 (
    simp[Once comp_def] >>
    fs[evaluate_def] >>
    BasicProvers.TOP_CASE_TAC >> fs[] >>
    BasicProvers.TOP_CASE_TAC >> fs[] >>
    BasicProvers.TOP_CASE_TAC >> fs[] >>
    BasicProvers.TOP_CASE_TAC >> fs[] >>
    simp[Once rename_state_def] >>
    simp[Once rename_state_def] >>
    simp[Once rename_state_def] >>
    BasicProvers.TOP_CASE_TAC >> fs[] >>
    fs[LET_THM] >>
    simp[EVAL``(rename_state f s).ffi``] >>
    split_pair_tac >> fs[] >> rveq >>
    simp[rename_state_def,state_component_equality] >>
    dep_rewrite.DEP_REWRITE_TAC[DRESTRICT_MAP_KEYS_IMAGE] >>
    metis_tac[BIJ_DEF])
  THEN1 (
    simp[Once comp_def] >> fs[evaluate_def] >>
    rveq >> fs[set_var_find_name] )
  \\ (
    simp[Once comp_def] >> fs[evaluate_def] >>
    simp[Once rename_state_def] >> rveq >> simp[] ));

val compile_semantics = store_thm("compile_semantics",
  ``BIJ (find_name f) UNIV UNIV /\
    ~s.use_alloc /\ ~s.use_store /\ ~s.use_stack ==>
    semantics start (rename_state f s) = semantics start s``,
  simp[GSYM AND_IMP_INTRO] >> ntac 4 strip_tac >>
  simp[semantics_def] >>
  simp[
    comp_correct
    |> Q.SPEC`Call NONE (INL start) NONE`
    |> SIMP_RULE(srw_ss())[comp_def,dest_find_name_def]
    |> Q.SPEC`s with clock := k`
    |> SIMP_RULE(srw_ss()++QUANT_INST_ss[pair_default_qp])[GSYM AND_IMP_INTRO]
    |> SIMP_RULE std_ss [rename_state_with_clock]
    |> UNDISCH_ALL] >>
  simp[rename_state_def] >>
  srw_tac[QUANT_INST_ss[pair_default_qp]][]);

val _ = export_theory();