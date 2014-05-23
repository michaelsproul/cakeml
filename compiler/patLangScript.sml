(*Generated by Lem from patLang.lem.*)
open HolKernel Parse boolLib bossLib;
open lem_pervasivesTheory semanticPrimitivesTheory astTheory bigStepTheory exhLangTheory conLangTheory decLangTheory compilerLibTheory;

val _ = numLib.prefer_num();



val _ = new_theory "patLang"

(* Removes pattern-matching and variable names. Follows exhLang.
 *
 * The AST of patLang differs from exhLang in that it uses de Bruijn indices,
 * there are no Mat expressions, Handle expressions are simplified to catch and
 * bind any exception without matching on it, and there are new Tag_eq and El
 * expressions for checking the constructor of a compound value and retrieving
 * its arguments. 
 *
 * The values and semantics of patLang are the same as exhLang, modulo the
 * changes to expressions.
 *
 *)

(*open import Pervasives*)
(*open import SemanticPrimitives*)
(*open import Ast*)
(*open import BigStep*)
(*open import ExhLang*)
(*open import ConLang*)
(*open import DecLang*)
(*open import CompilerLib*)

(* TODO: Lem's builtin find index has a different type *)
(*val find_index : forall 'a. 'a -> list 'a -> nat -> maybe nat*) (* to pick up the definition in miscTheory *)

val _ = Hol_datatype `
 op_pat =
    Op_pat of op_i2
  | Tag_eq_pat of num
  | El_pat of num`;


val _ = Hol_datatype `
 exp_pat =
    Raise_pat of exp_pat
  | Handle_pat of exp_pat => exp_pat
  | Lit_pat of lit
  | Con_pat of num => exp_pat list
  | Var_local_pat of num
  | Var_global_pat of num
  | Fun_pat of exp_pat
  | App_pat of op_pat => exp_pat list
  | If_pat of exp_pat => exp_pat => exp_pat
  | Let_pat of exp_pat => exp_pat
  | Seq_pat of exp_pat => exp_pat
  | Letrec_pat of exp_pat list => exp_pat
  | Extend_global_pat of num`;


val _ = Hol_datatype `
 v_pat =
    Litv_pat of lit
  | Conv_pat of num => v_pat list
  | Closure_pat of v_pat list => exp_pat
  | Recclosure_pat of v_pat list => exp_pat list => num
  | Loc_pat of num`;


(*val sIf_pat : exp_pat -> exp_pat -> exp_pat -> exp_pat*)
val _ = Define `

(sIf_pat e1 e2 e3 =  
(if (e2 = Lit_pat (Bool T)) /\ (e3 = Lit_pat (Bool F)) then e1 else
  (case e1 of
    Lit_pat (Bool b) => if b then e2 else e3
  | _ => If_pat e1 e2 e3
  )))`;


(*val fo_pat : exp_pat -> bool*)
 val _ = Define `

(fo_pat (Raise_pat _) = T)
/\
(fo_pat (Handle_pat e1 e2) = (fo_pat e1 /\ fo_pat e2))
/\
(fo_pat (Lit_pat _) = T)
/\
(fo_pat (Con_pat _ es) = (fo_list_pat es))
/\
(fo_pat (Var_local_pat _) = F)
/\
(fo_pat (Var_global_pat _) = F)
/\
(fo_pat (Fun_pat _) = F)
/\
(fo_pat (App_pat op _) =
  ((op <> (Op_pat (Op_i2 Opapp))) /\  
(op <> (Op_pat (Op_i2 Opderef))) /\
  (! n. op <> El_pat n)))
/\
(fo_pat (If_pat _ e2 e3) = (fo_pat e2 /\ fo_pat e3))
/\
(fo_pat (Let_pat _ e2) = (fo_pat e2))
/\
(fo_pat (Seq_pat _ e2) = (fo_pat e2))
/\
(fo_pat (Letrec_pat _ e) = (fo_pat e))
/\
(fo_pat (Extend_global_pat _) = T)
/\
(fo_list_pat [] = T)
/\
(fo_list_pat (e::es) = (fo_pat e /\ fo_list_pat es))`;


(*val pure_op : op -> bool*)
val _ = Define `
 (pure_op op =
  ((op <> Opref) /\  
(op <> Equality) /\  
(op <> Opapp) /\  
(op <> Opassign) /\  
(op <> Aupdate) /\  
(op <> Aalloc) /\  
(op <> (Opn Divide)) /\  
(op <> (Opn Modulo))))`;


(*val pure_op_pat : op_pat -> bool*)
 val _ = Define `

(pure_op_pat (Op_pat (Op_i2 op)) = (pure_op op))
/\
(pure_op_pat (Op_pat (Init_global_var_i2 _)) = F)
/\
(pure_op_pat (Tag_eq_pat _) = T)
/\
(pure_op_pat (El_pat _) = T)`;


(*val pure_pat : exp_pat -> bool*)
 val _ = Define `

(pure_pat (Raise_pat _) = F)
/\
(pure_pat (Handle_pat e1 _) = (pure_pat e1))
/\
(pure_pat (Lit_pat _) = T)
/\
(pure_pat (Con_pat _ es) = (pure_list_pat es))
/\
(pure_pat (Var_local_pat _) = T)
/\
(pure_pat (Var_global_pat _) = T)
/\
(pure_pat (Fun_pat _) = T)
/\
(pure_pat (App_pat op es) = (pure_list_pat es /\
  (pure_op_pat op \/ ((op = Op_pat(Op_i2 Equality)) /\ fo_list_pat es))))
/\
(pure_pat (If_pat e1 e2 e3) = (pure_pat e1 /\ pure_pat e2 /\ pure_pat e3))
/\
(pure_pat (Let_pat e1 e2) = (pure_pat e1 /\ pure_pat e2))
/\
(pure_pat (Seq_pat e1 e2) = (pure_pat e1 /\ pure_pat e2))
/\
(pure_pat (Letrec_pat _ e) = (pure_pat e))
/\
(pure_pat (Extend_global_pat _) = F)
/\
(pure_list_pat [] = T)
/\
(pure_list_pat (e::es) = (pure_pat e /\ pure_list_pat es))`;


(*val ground_pat : nat -> exp_pat -> bool*)
 val _ = Define `

(ground_pat n (Raise_pat e) = (ground_pat n e))
/\
(ground_pat n (Handle_pat e1 e2) = (ground_pat n e1 /\ ground_pat (n+ 1) e2))
/\
(ground_pat _ (Lit_pat _) = T)
/\
(ground_pat n (Con_pat _ es) = (ground_list_pat n es))
/\
(ground_pat n (Var_local_pat k) = (k < n))
/\
(ground_pat _ (Var_global_pat _) = T)
/\
(ground_pat _ (Fun_pat _) = F)
/\
(ground_pat n (App_pat _ es) = (ground_list_pat n es))
/\
(ground_pat n (If_pat e1 e2 e3) = (ground_pat n e1 /\ ground_pat n e2 /\ ground_pat n e3))
/\
(ground_pat n (Let_pat e1 e2) = (ground_pat n e1 /\ ground_pat (n+ 1) e2))
/\
(ground_pat n (Seq_pat e1 e2) = (ground_pat n e1 /\ ground_pat n e2))
/\
(ground_pat _ (Letrec_pat _ _) = F)
/\
(ground_pat _ (Extend_global_pat _) = T)
/\
(ground_list_pat _ [] = T)
/\
(ground_list_pat n (e::es) = (ground_pat n e /\ ground_list_pat n es))`;


(*val sLet_pat : exp_pat -> exp_pat -> exp_pat*)
 val _ = Define `

(sLet_pat e1 (Var_local_pat 0) = e1)
/\
(sLet_pat e1 e2 =  
(if ground_pat( 0) e2
  then if pure_pat e1
  then e2
  else Seq_pat e1 e2
  else Let_pat e1 e2))`;


(* bind elements 0..k of the variable n in reverse order above e (first element
 * becomes most recently bound) *)
(*val Let_Els_pat : nat -> nat -> exp_pat -> exp_pat*)
 val Let_Els_pat_defn = Hol_defn "Let_Els_pat" `

(Let_Els_pat _ 0 e = e)
/\
(Let_Els_pat n k e =  
(sLet_pat (App_pat (El_pat (k -  1)) [Var_local_pat n])
     (Let_Els_pat (n+ 1) (k -  1) e)))`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) Defn.save_defn Let_Els_pat_defn;

(* return an expression that evaluates to whether the pattern matches the most
 * recently bound variable *)
(*val pat_to_pat : pat_exh -> exp_pat*)
(* return an expression that evaluates to whether all the m patterns match the
 * m most recently bound variables; n counts 0..m *)
(*val pats_to_pat : nat -> list pat_exh -> exp_pat*)
 val pat_to_pat_defn = Hol_defn "pat_to_pat" `

(pat_to_pat (Pvar_exh _) = (Lit_pat (Bool T)))
/\
(pat_to_pat (Plit_exh l) = (App_pat (Op_pat (Op_i2 Equality)) [Var_local_pat( 0); Lit_pat l]))
/\
(pat_to_pat (Pcon_exh tag []) =  
(App_pat (Op_pat (Op_i2 Equality)) [Var_local_pat( 0); Con_pat tag []]))
/\
(pat_to_pat (Pcon_exh tag ps) =  
(sIf_pat (App_pat (Tag_eq_pat tag) [Var_local_pat( 0)])
    (Let_Els_pat( 0) (LENGTH ps) (pats_to_pat( 0) ps))
    (Lit_pat (Bool F))))
/\
(pat_to_pat (Pref_exh p) =  
(sLet_pat (App_pat (Op_pat (Op_i2 Opderef)) [Var_local_pat( 0)])
    (pat_to_pat p)))
/\
(pats_to_pat _ [] = (Lit_pat (Bool T)))
/\
(pats_to_pat n (p::ps) =  
(sIf_pat (sLet_pat (Var_local_pat n) (pat_to_pat p))
    (pats_to_pat (n+ 1) ps)
    (Lit_pat (Bool F))))`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) Defn.save_defn pat_to_pat_defn;

(* given a pattern in a context of bound variables where the most recently
 * bound variable is the value to be matched, return a function that binds new
 * variables (including all the pattern variables) over an expression and the
 * new context of bound variables for the expression as well as the number of
 * newly bound variables *)
(*val row_to_pat : list (maybe varN) -> pat_exh -> list (maybe varN) * nat * (exp_pat -> exp_pat)*)
(*val cols_to_pat : list (maybe varN) -> nat -> nat -> list pat_exh -> list (maybe varN) * nat * (exp_pat -> exp_pat)*)
 val row_to_pat_defn = Hol_defn "row_to_pat" `

(row_to_pat (NONE::bvs) (Pvar_exh x) = ((SOME x::bvs), 0, (\ e .  e)))
/\
(row_to_pat bvs (Plit_exh _) = (bvs, 0, (\ e .  e)))
/\
(row_to_pat bvs (Pcon_exh _ ps) = (cols_to_pat bvs( 0)( 0) ps))
/\
(row_to_pat bvs (Pref_exh p) =  
(let (bvs,m,f) = (row_to_pat (NONE::bvs) p) in
    (bvs,( 1+m), (\ e .  sLet_pat (App_pat (Op_pat (Op_i2 Opderef)) [Var_local_pat( 0)]) (f e)))))
/\
(row_to_pat bvs _ = (bvs, 0, (\ e .  e))) (* should not happen *)
/\
(cols_to_pat bvs _ _ [] = (bvs, 0, (\ e .  e)))
/\
(cols_to_pat bvs n k (p::ps) =  
(let (bvs,m,f) = (row_to_pat (NONE::bvs) p) in
  let (bvs,ms,fs) = (cols_to_pat bvs ((n+ 1)+m) (k+ 1) ps) in
    (bvs,(( 1+m)+ms),       
(\ e . 
           sLet_pat (App_pat (El_pat k) [Var_local_pat n])
             (f (fs e))))))`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) Defn.save_defn row_to_pat_defn;

(* translate to i4 under a context of bound variables *)
(*val exp_to_pat : list (maybe varN) -> exp_exh -> exp_pat*)
(*val exps_to_pat : list (maybe varN) -> list exp_exh -> list exp_pat*)
(*val funs_to_pat : list (maybe varN) -> list (varN * varN * exp_exh) -> list exp_pat*)
(* assumes the value being matched is most recently bound *)
(*val pes_to_pat : list (maybe varN) -> list (pat_exh * exp_exh) -> exp_pat*)
 val exp_to_pat_defn = Hol_defn "exp_to_pat" `

(exp_to_pat bvs (Raise_exh e) = (Raise_pat (exp_to_pat bvs e)))
/\
(exp_to_pat bvs (Handle_exh e1 pes) =  
(Handle_pat (exp_to_pat bvs e1) (pes_to_pat (NONE::bvs) pes)))
/\
(exp_to_pat _ (Lit_exh l) = (Lit_pat l))
/\
(exp_to_pat bvs (Con_exh tag es) = (Con_pat tag (exps_to_pat bvs es)))
/\
(exp_to_pat bvs (Var_local_exh x) =  
((case misc$find_index (SOME x) bvs( 0) of
    SOME k => Var_local_pat k
  | NONE => Lit_pat Unit (* should not happen *)
  )))
/\
(exp_to_pat _ (Var_global_exh n) = (Var_global_pat n))
/\
(exp_to_pat bvs (Fun_exh x e) = (Fun_pat (exp_to_pat (SOME x::bvs) e)))
/\
(exp_to_pat bvs (App_exh op es) =  
(App_pat (Op_pat op) (exps_to_pat bvs es)))
/\
(exp_to_pat bvs (If_exh e1 e2 e3) =  
(sIf_pat (exp_to_pat bvs e1) (exp_to_pat bvs e2) (exp_to_pat bvs e3)))
/\
(exp_to_pat bvs (Mat_exh e pes) =  
(sLet_pat (exp_to_pat bvs e) (pes_to_pat (NONE::bvs) pes)))
/\
(exp_to_pat bvs (Let_exh (SOME x) e1 e2) =  
(sLet_pat (exp_to_pat bvs e1) (exp_to_pat (SOME x::bvs) e2)))
/\
(exp_to_pat bvs (Let_exh NONE e1 e2) =  
(Seq_pat (exp_to_pat bvs e1) (exp_to_pat bvs e2)))
/\
(exp_to_pat bvs (Letrec_exh funs e) =  
(let bvs = ((MAP (\p10351 .  
  (case (p10351 ) of ( (f,_,_) ) => SOME f )) funs) ++ bvs) in
  Letrec_pat (funs_to_pat bvs funs) (exp_to_pat bvs e)))
/\
(exp_to_pat _ (Extend_global_exh n) = (Extend_global_pat n))
/\
(exps_to_pat _ [] = ([]))
/\
(exps_to_pat bvs (e::es) =  
(exp_to_pat bvs e :: exps_to_pat bvs es))
/\
(funs_to_pat _ [] = ([]))
/\
(funs_to_pat bvs ((_,x,e)::funs) =  
(exp_to_pat (SOME x::bvs) e :: funs_to_pat bvs funs))
/\
(pes_to_pat bvs [(p,e)] = 
  ((case row_to_pat bvs p of (bvs,_,f) => f (exp_to_pat bvs e) )))
/\
(pes_to_pat bvs ((p,e)::pes) =  
(sIf_pat (pat_to_pat p)
    ((case row_to_pat bvs p of (bvs,_,f) => f (exp_to_pat bvs e) ))
    (pes_to_pat bvs pes)))
/\
(pes_to_pat _ _ = (Lit_pat Unit))`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) Defn.save_defn exp_to_pat_defn; (* should not happen *)

(*val build_rec_env_pat : list exp_pat -> list v_pat -> list v_pat*)
val _ = Define `
 (build_rec_env_pat funs cl_env =  
(GENLIST (Recclosure_pat cl_env funs) (LENGTH funs)))`;


(*val do_opapp_pat : list v_pat -> maybe (list v_pat * exp_pat)*)
val _ = Define `
 (do_opapp_pat vs =  
((case vs of
      [Closure_pat env e; v] => SOME ((v::env), e)
    | [Recclosure_pat env funs n; v] =>
        if n < LENGTH funs then
          SOME ((v::((build_rec_env_pat funs env)++env)), EL n funs)
        else
          NONE
    | _ => NONE
    )))`;


(*val do_eq_pat : v_pat -> v_pat -> eq_result*)
 val do_eq_pat_defn = Hol_defn "do_eq_pat" `

(do_eq_pat (Litv_pat l1) (Litv_pat l2) =  
(Eq_val (l1 = l2)))
/\
(do_eq_pat (Loc_pat l1) (Loc_pat l2) = (Eq_val (l1 = l2)))
/\
(do_eq_pat (Conv_pat tag1 vs1) (Conv_pat tag2 vs2) =  
(if (tag1 = tag2) /\ (LENGTH vs1 = LENGTH vs2) then
    do_eq_list_pat vs1 vs2
  else
    Eq_val F))
/\
(do_eq_pat (Closure_pat _ _) (Closure_pat _ _) = Eq_closure)
/\
(do_eq_pat (Closure_pat _ _) (Recclosure_pat _ _ _) = Eq_closure)
/\
(do_eq_pat (Recclosure_pat _ _ _) (Closure_pat _ _) = Eq_closure)
/\
(do_eq_pat (Recclosure_pat _ _ _) (Recclosure_pat _ _ _) = Eq_closure)
/\
(do_eq_pat _ _ = Eq_type_error)
/\
(do_eq_list_pat [] [] = (Eq_val T))
/\
(do_eq_list_pat (v1::vs1) (v2::vs2) =  
((case do_eq_pat v1 v2 of
      Eq_closure => Eq_closure
    | Eq_type_error => Eq_type_error
    | Eq_val r =>
        if ~ r then
          Eq_val F
        else
          do_eq_list_pat vs1 vs2
  )))
/\
(do_eq_list_pat _ _ = (Eq_val F))`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) Defn.save_defn do_eq_pat_defn;

(*val prim_exn_pat : nat -> v_pat*)
val _ = Define `
 (prim_exn_pat tag = (Conv_pat tag []))`;


(*val do_app_pat : count_store_genv v_pat -> op_pat -> list v_pat -> maybe (count_store_genv v_pat * result v_pat v_pat)*)
val _ = Define `
 (do_app_pat ((cnt,s),genv) op vs =  
((case (op,vs) of
      (Op_pat (Op_i2 (Opn op)), [Litv_pat (IntLit n1); Litv_pat (IntLit n2)]) =>
        if ((op = Divide) \/ (op = Modulo)) /\ (n2 =( 0 : int)) then
          SOME (((cnt,s),genv), Rerr (Rraise (prim_exn_pat div_tag)))
        else
          SOME (((cnt,s),genv), Rval (Litv_pat (IntLit (opn_lookup op n1 n2))))
    | (Op_pat (Op_i2 (Opb op)), [Litv_pat (IntLit n1); Litv_pat (IntLit n2)]) =>
        SOME (((cnt,s),genv), Rval (Litv_pat (Bool (opb_lookup op n1 n2))))
    | (Op_pat (Op_i2 Equality), [v1; v2]) =>
        (case do_eq_pat v1 v2 of
            Eq_type_error => NONE
          | Eq_closure => SOME (((cnt,s),genv), Rerr (Rraise (prim_exn_pat eq_tag)))
          | Eq_val b => SOME (((cnt,s),genv), Rval(Litv_pat (Bool b)))
        )
    | (Op_pat (Op_i2 Opassign), [Loc_pat lnum; v]) =>
        (case store_assign lnum (Refv v) s of
          SOME st => SOME (((cnt,st),genv), Rval (Litv_pat Unit))
        | NONE => NONE
        )
    | (Op_pat (Op_i2 Opderef), [Loc_pat n]) =>
        (case store_lookup n s of
            SOME (Refv v) => SOME (((cnt,s),genv),Rval v)
          | _ => NONE
        )
    | (Op_pat (Op_i2 Opref), [v]) =>
        let (s',n) = (store_alloc (Refv v) s) in
          SOME (((cnt,s'),genv), Rval (Loc_pat n))
    | (Op_pat (Init_global_var_i2 idx), [v]) =>
        if idx < LENGTH genv then
          (case EL idx genv of
              NONE => SOME (((cnt,s), LUPDATE (SOME v) idx genv), Rval (Litv_pat Unit))
            | SOME _ => NONE
          )
        else
          NONE
    | (Op_pat (Op_i2 Aalloc), [Litv_pat (IntLit n); Litv_pat (Word8 w)]) =>
        if n <( 0 : int) then
          SOME (((cnt,s),genv), Rerr (Rraise (prim_exn_pat size_tag)))
        else
          let (st,lnum) =            
(store_alloc (W8array (REPLICATE (Num (ABS ( n))) w)) s)
          in
            SOME (((cnt,st),genv), Rval (Loc_pat lnum))
    | (Op_pat (Op_i2 Asub), [Loc_pat lnum; Litv_pat (IntLit i)]) =>
        (case store_lookup lnum s of
            SOME (W8array ws) =>
              if i <( 0 : int) then
                SOME (((cnt,s),genv), Rerr (Rraise (prim_exn_pat size_tag)))
              else
                let n = (Num (ABS ( i))) in
                  if n >= LENGTH ws then
                    SOME (((cnt,s),genv), Rerr (Rraise (prim_exn_pat size_tag)))
                  else
                    SOME (((cnt,s),genv), Rval (Litv_pat (Word8 (EL n ws))))
          | _ => NONE
        )
    | (Op_pat (Op_i2 Alength), [Loc_pat n]) =>
        (case store_lookup n s of
            SOME (W8array ws) =>
              SOME (((cnt,s),genv),Rval (Litv_pat (IntLit (int_of_num (LENGTH ws)))))
          | _ => NONE
        )
    | (Op_pat (Op_i2 Aupdate), [Loc_pat lnum; Litv_pat (IntLit i); Litv_pat (Word8 w)]) =>
        (case store_lookup lnum s of
          SOME (W8array ws) =>
            if i <( 0 : int) then
              SOME (((cnt,s),genv), Rerr (Rraise (prim_exn_pat size_tag)))
            else
              let n = (Num (ABS ( i))) in
                if n >= LENGTH ws then
                  SOME (((cnt,s),genv), Rerr (Rraise (prim_exn_pat size_tag)))
                else
                  (case store_assign lnum (W8array (LUPDATE w n ws)) s of
                      NONE => NONE
                    | SOME st => SOME (((cnt,st),genv), Rval (Litv_pat Unit))
                  )
        | _ => NONE
        )
    | (Tag_eq_pat n, [Conv_pat tag _]) =>
        SOME (((cnt,s),genv), Rval (Litv_pat (Bool (tag = n))))
    | (El_pat n, [Conv_pat _ vs]) =>
        if n < LENGTH vs then
          SOME (((cnt,s),genv), Rval (EL n vs))
        else
          NONE
    | _ => NONE
  )))`;


(*val do_if_pat : v_pat -> exp_pat -> exp_pat -> maybe exp_pat*)
val _ = Define `
 (do_if_pat v e1 e2 =  
(if v = Litv_pat (Bool T) then
    SOME e1
  else if v = Litv_pat (Bool F) then
    SOME e2
  else
    NONE))`;


val _ = Hol_reln ` (! ck env l s.
T
==>
evaluate_pat ck env s (Lit_pat l) (s, Rval (Litv_pat l)))

/\ (! ck env e s1 s2 v.
(evaluate_pat ck s1 env e (s2, Rval v))
==>
evaluate_pat ck s1 env (Raise_pat e) (s2, Rerr (Rraise v)))

/\ (! ck env e s1 s2 err.
(evaluate_pat ck s1 env e (s2, Rerr err))
==>
evaluate_pat ck s1 env (Raise_pat e) (s2, Rerr err))

/\ (! ck s1 s2 env e1 v e2.
(evaluate_pat ck s1 env e1 (s2, Rval v))
==>
evaluate_pat ck s1 env (Handle_pat e1 e2) (s2, Rval v))

/\ (! ck s1 s2 env e1 e2 v bv.
(evaluate_pat ck env s1 e1 (s2, Rerr (Rraise v)) /\
evaluate_pat ck (v::env) s2 e2 bv)
==>
evaluate_pat ck env s1 (Handle_pat e1 e2) bv)

/\ (! ck s1 s2 env e1 e2 err.
(evaluate_pat ck env s1 e1 (s2, Rerr err) /\
((err = Rtimeout_error) \/ (err = Rtype_error)))
==>
evaluate_pat ck env s1 (Handle_pat e1 e2) (s2, Rerr err))

/\ (! ck env tag es vs s s'.
(evaluate_list_pat ck env s es (s', Rval vs))
==>
evaluate_pat ck env s (Con_pat tag es) (s', Rval (Conv_pat tag vs)))

/\ (! ck env tag es err s s'.
(evaluate_list_pat ck env s es (s', Rerr err))
==>
evaluate_pat ck env s (Con_pat tag es) (s', Rerr err))

/\ (! ck env n s.
(LENGTH env > n)
==>
evaluate_pat ck env s (Var_local_pat n) (s, Rval (EL n env)))

/\ (! ck env n s.
(~ (LENGTH env > n))
==>
evaluate_pat ck env s (Var_local_pat n) (s, Rerr Rtype_error))

/\ (! ck env n v s genv.
((LENGTH genv > n) /\
(EL n genv = SOME v))
==>
evaluate_pat ck env (s,genv) (Var_global_pat n) ((s,genv), Rval v))

/\ (! ck env n s genv.
((LENGTH genv > n) /\
(EL n genv = NONE))
==>
evaluate_pat ck env (s,genv) (Var_global_pat n) ((s,genv), Rerr Rtype_error))

/\ (! ck env n s genv.
(~ (LENGTH genv > n))
==>
evaluate_pat ck env (s,genv) (Var_global_pat n) ((s,genv), Rerr Rtype_error))

/\ (! ck env e s.
T
==>
evaluate_pat ck env s (Fun_pat e) (s, Rval (Closure_pat env e)))

/\ (! ck env s1 es count s2 genv2 vs env2 e2 bv.
(evaluate_list_pat ck env s1 es (((count,s2),genv2), Rval vs) /\
(do_opapp_pat vs = SOME (env2, e2)) /\
(ck ==> ~ (count =( 0))) /\
evaluate_pat ck env2 (((if ck then count -  1 else count),s2),genv2) e2 bv)
==>
evaluate_pat ck env s1 (App_pat (Op_pat (Op_i2 Opapp)) es) bv)

/\ (! ck env s1 es count s2 genv2 vs env2 e2.
(evaluate_list_pat ck env s1 es (((count,s2),genv2), Rval vs) /\
(do_opapp_pat vs = SOME (env2, e2)) /\
(count = 0) /\
ck)
==>
evaluate_pat ck env s1 (App_pat (Op_pat (Op_i2 Opapp)) es) ((( 0,s2),genv2), Rerr Rtimeout_error))

/\ (! ck env s1 es s2 vs.
(evaluate_list_pat ck env s1 es (s2, Rval vs) /\
(do_opapp_pat vs = NONE))
==>
evaluate_pat ck env s1 (App_pat (Op_pat (Op_i2 Opapp)) es) (s2, Rerr Rtype_error))

/\ (! ck env s1 op es s2 vs s3 res.
(evaluate_list_pat ck env s1 es (s2, Rval vs) /\
(do_app_pat s2 op vs = SOME (s3, res)) /\
(op <> Op_pat (Op_i2 Opapp)))
==>
evaluate_pat ck env s1 (App_pat op es) (s3, res))

/\ (! ck env s1 op es s2 vs.
(evaluate_list_pat ck env s1 es (s2, Rval vs) /\
(do_app_pat s2 op vs = NONE) /\
(op <> Op_pat (Op_i2 Opapp)))
==>
evaluate_pat ck env s1 (App_pat op es) (s2, Rerr Rtype_error))

/\ (! ck env s1 op es s2 err.
(evaluate_list_pat ck env s1 es (s2, Rerr err))
==>
evaluate_pat ck env s1 (App_pat op es) (s2, Rerr err))

/\ (! ck env e1 e2 e3 v e' bv s1 s2.
(evaluate_pat ck env s1 e1 (s2, Rval v) /\
(do_if_pat v e2 e3 = SOME e') /\
evaluate_pat ck env s2 e' bv)
==>
evaluate_pat ck env s1 (If_pat e1 e2 e3) bv)

/\ (! ck env e1 e2 e3 v s1 s2.
(evaluate_pat ck env s1 e1 (s2, Rval v) /\
(do_if_pat v e2 e3 = NONE))
==>
evaluate_pat ck env s1 (If_pat e1 e2 e3) (s2, Rerr Rtype_error))

/\ (! ck env e1 e2 e3 err s s'.
(evaluate_pat ck env s e1 (s', Rerr err))
==>
evaluate_pat ck env s (If_pat e1 e2 e3) (s', Rerr err))

/\ (! ck env e1 e2 v bv s1 s2.
(evaluate_pat ck env s1 e1 (s2, Rval v) /\
evaluate_pat ck (v::env) s2 e2 bv)
==>
evaluate_pat ck env s1 (Let_pat e1 e2) bv)

/\ (! ck env e1 e2 err s s'.
(evaluate_pat ck env s e1 (s', Rerr err))
==>
evaluate_pat ck env s (Let_pat e1 e2) (s', Rerr err))

/\ (! ck env e1 e2 v bv s1 s2.
(evaluate_pat ck env s1 e1 (s2, Rval v) /\
evaluate_pat ck env s2 e2 bv)
==>
evaluate_pat ck env s1 (Seq_pat e1 e2) bv)

/\ (! ck env e1 e2 err s s'.
(evaluate_pat ck env s e1 (s', Rerr err))
==>
evaluate_pat ck env s (Seq_pat e1 e2) (s', Rerr err))

/\ (! ck env funs e bv s.
(evaluate_pat ck ((build_rec_env_pat funs env)++env) s e bv)
==>
evaluate_pat ck env s (Letrec_pat funs e) bv)

/\ (! ck env n s genv.
T
==>
evaluate_pat ck env (s,genv) (Extend_global_pat n) ((s,(genv++GENLIST (\n10655 .  
  (case (n10655 ) of ( _ ) => NONE )) n)), Rval (Litv_pat Unit)))

/\ (! ck env s.
T
==>
evaluate_list_pat ck env s [] (s, Rval []))

/\ (! ck env e es v vs s1 s2 s3.
(evaluate_pat ck env s1 e (s2, Rval v) /\
evaluate_list_pat ck env s2 es (s3, Rval vs))
==>
evaluate_list_pat ck env s1 (e::es) (s3, Rval (v::vs)))

/\ (! ck env e es err s s'.
(evaluate_pat ck env s e (s', Rerr err))
==>
evaluate_list_pat ck env s (e::es) (s', Rerr err))

/\ (! ck env e es v err s1 s2 s3.
(evaluate_pat ck env s1 e (s2, Rval v) /\
evaluate_list_pat ck env s2 es (s3, Rerr err))
==>
evaluate_list_pat ck env s1 (e::es) (s3, Rerr err))`;
val _ = export_theory()

