open preamble semanticPrimitivesTheory astTheory evalPropsTheory
open terminationTheory

(* TODO: this theory should be moved entirely into evalPropsTheory and/or other
         things under (top-level) semantics/proofs *)

val _ = new_theory"sourceProps"

val pmatch_extend = Q.store_thm("pmatch_extend",
`(!cenv s p v env env' env''.
  pmatch cenv s p v env = Match env'
  ⇒
  ?env''. env' = env'' ++ env ∧ MAP FST env'' = pat_bindings p []) ∧
 (!cenv s ps vs env env' env''.
  pmatch_list cenv s ps vs env = Match env'
  ⇒
  ?env''. env' = env'' ++ env ∧ MAP FST env'' = pats_bindings ps [])`,
 ho_match_mp_tac pmatch_ind >>
 rw [pat_bindings_def, pmatch_def] >>
 every_case_tac >>
 fs [] >>
 rw [] >>
 res_tac >>
 qexists_tac `env'''++env''` >>
 rw [] >>
 metis_tac [pat_bindings_accum]);

val Boolv_11 = store_thm("Boolv_11[simp]",``Boolv b1 = Boolv b2 ⇔ (b1 = b2)``,rw[Boolv_def]);

val find_recfun_el = Q.store_thm("find_recfun_el",
  `!f funs x e n.
    ALL_DISTINCT (MAP (\(f,x,e). f) funs) ∧
    n < LENGTH funs ∧
    EL n funs = (f,x,e)
    ⇒
    find_recfun f funs = SOME (x,e)`,
  simp[find_recfun_ALOOKUP] >>
  induct_on `funs` >>
  rw [] >>
  cases_on `n` >>
  fs [] >>
  PairCases_on `h` >>
  fs [] >>
  rw [] >>
  res_tac >>
  fs [MEM_MAP, MEM_EL, FORALL_PROD] >>
  metis_tac []);

val _ = export_theory()
