(*Generated by Lem from semantics/ast.lem.*)
open bossLib Theory Parse res_quanTheory
open finite_mapTheory listTheory pairTheory pred_setTheory integerTheory
open set_relationTheory sortingTheory stringTheory wordsTheory

val _ = numLib.prefer_num();

val _ = new_theory "Ast"

open MiniMLTheory TokensTheory

(* An AST that can be the result of parsing, and then elaborated into the type
 * annotated AST in miniML.lem.  We are assuming that constructors start with
 * capital letters, and non-constructors start with lower case (as in OCaml) so
 * that the parser can determine what is a constructor application.  Example
 * syntax in comments before each node.
 * 
 * Also, an elaboration from this syntax to the AST in miniML.lem.  The
 * elaboration spots variables and types that are bound to ML primitives.  The
 * elaboration isn't particularly sophisticated: primitives are always turned
 * into functions, and we don't look for places where the primitive is already
 * applied, so 1 + 2 becomes (fun x y -> x + y) 1 2.  The elaboration also
 * prefixes datatype constructors and types with their paths, so
 *
 * structure S = struct
 *   datatype t = C
 *   val x = C
 * end
 *
 * becomes
 *
 * structure S = struct
 *   datatype t = C
 *   val x = S.C
 * end
 * 
 *)

(*open MiniML*)

val _ = Hol_datatype `
 ast_pat =
    (* x *)
    Ast_Pvar of varN
    (* 1 *)
    (* true *)
    (* () *)
  | Ast_Plit of lit
    (* C(x,y) *)
    (* D *)
    (* E x *)
  | Ast_Pcon of conN id => ast_pat list
    (* ref x *)
  | Ast_Pref of ast_pat`;


val _ = Hol_datatype `
 ast_exp =
    (* raise 4 *)
    Ast_Raise of error
    (* e handle x => e *)
  | Ast_Handle of ast_exp => varN => ast_exp
    (* 1 *)
    (* true *)
    (* () *)
  | Ast_Lit of lit
    (* x *)
  | Ast_Var of varN id
    (* C(x,y) *)
    (* D *)
    (* E x *)
  | Ast_Con of conN id => ast_exp list
    (* fn x => e *)
  | Ast_Fun of varN => ast_exp
    (* e e *)
  | Ast_App of ast_exp => ast_exp
    (* e andalso e *)
    (* e orelse e *)
  | Ast_Log of log => ast_exp => ast_exp
    (* if e then e else e *)
  | Ast_If of ast_exp => ast_exp => ast_exp
    (* case e of C(x,y) => x | D y => y *)
  | Ast_Mat of ast_exp => (ast_pat # ast_exp) list
    (* let val x = e in e end *)
  | Ast_Let of varN => ast_exp => ast_exp
    (* let fun f x = e and g y = e in e end *) 
  | Ast_Letrec of (varN # varN # ast_exp) list => ast_exp`;


val _ = Hol_datatype `
 ast_t =
    (* 'a *)
    Ast_Tvar of tvarN
    (* t *)
    (* num t *)
    (* (num,bool) t *)
  | Ast_Tapp of ast_t list => typeN id
    (* t -> t *)
  | Ast_Tfn of ast_t => ast_t`;


(* type t = C of t1 * t2 | D of t2  * t3
 * and 'a u = E of 'a
 * and ('a,'b) v = F of 'b u | G of 'a u *)
val _ = type_abbrev( "ast_type_def" , ``: ( tvarN list # typeN # (conN # ast_t list) list) list``);

val _ = Hol_datatype `
 ast_dec =
    (* val (C(x,y)) = C(1,2) *) 
    Ast_Dlet of ast_pat => ast_exp
    (* fun f x = e and g y = f *) 
  | Ast_Dletrec of (varN # varN # ast_exp) list
    (* see above *)
  | Ast_Dtype of ast_type_def`;


val _ = type_abbrev( "ast_decs" , ``: ast_dec list``);

val _ = Hol_datatype `
 ast_spec =
    Ast_Sval of varN => ast_t
  | Ast_Stype of ast_type_def
  | Ast_Stype_opq of typeN`;


val _ = type_abbrev( "ast_specs" , ``: ast_spec list``);

val _ = Hol_datatype `
 ast_top =
    Ast_Tmod of modN => ast_specs option => ast_decs
  | Ast_Tdec of ast_dec`;


val _ = type_abbrev( "ast_prog" , ``: ast_top list``);

(*val elab_p : ast_pat -> pat unit*) 
 val elab_p_defn = Hol_defn "elab_p" `

(elab_p (Ast_Pvar n) = Pvar n NONE)
/\
(elab_p (Ast_Plit l) = Plit l)
/\
(elab_p (Ast_Pcon cn ps) = Pcon cn (elab_ps ps))
/\
(elab_p (Ast_Pref p) = Pref (elab_p p))
/\
(elab_ps [] = [])
/\
(elab_ps (p::ps) = elab_p p :: elab_ps ps)`;

val _ = Defn.save_defn elab_p_defn;

val _ = Hol_datatype `
 ops =
    Is_uop of uop
  | Is_op of op
  | Is_local`;


val _ = type_abbrev( "binding_env" , ``: (varN, ops) env``);

(*val init_env : binding_env*)
val _ = Define `
 init_env =
  [("+", Is_op (Opn Plus));
   ("-", Is_op (Opn Minus));
   ("*", Is_op (Opn Times));
   ("div", Is_op (Opn Divide));
   ("mod", Is_op (Opn Modulo));
   ("<", Is_op (Opb Lt));
   (">", Is_op (Opb Gt));
   ("<=", Is_op (Opb Leq));
   (">=", Is_op (Opb Geq));
   ("=", Is_op Equality);
   (":=", Is_op Opassign);
   ("!", Is_uop Opderef);
   ("ref", Is_uop Opref)]`;


val _ = type_abbrev( "ctor_env" , ``: (conN, ( conN id)) env``);

(*val elab_t : list typeN -> ast_t -> t*)
(*val elab_e : ctor_env -> binding_env -> ast_exp -> exp unit*)
(*val elab_funs : ctor_env -> binding_env -> list (varN * varN * ast_exp) -> 
                list (varN * option unit * varN * option unit * exp unit)*)
(*val elab_dec : option modN -> list typeN -> ctor_env -> binding_env -> ast_dec -> list typeN * ctor_env * binding_env * dec unit*)
(*val elab_decs : option modN -> list typeN -> ctor_env -> binding_env -> list ast_dec -> list (dec unit)*)
(*val elab_spec : list typeN -> list ast_spec -> list spec*)
(*val elab_prog : list typeN -> ctor_env -> binding_env -> list ast_top -> list (top unit)*)

(*val get_pat_bindings : forall 'a. pat 'a -> binding_env*)
val _ = Define `
 (get_pat_bindings p = MAP (\ x . (x, Is_local)) (pat_bindings p []))`;


val _ = Define `
 (get_funs_bindings funs = MAP (\ (x,y,z) . (x, Is_local)) funs)`;


 val elab_e_defn = Hol_defn "elab_e" `

(elab_e ctors bound (Ast_Raise err) =
  Raise err)
/\
(elab_e ctors bound (Ast_Handle e1 x e2) =
  Handle (elab_e ctors bound e1) x (elab_e ctors (bind x Is_local bound) e2))
/\
(elab_e ctors bound (Ast_Lit l) =
  Lit l)
/\ (elab_e ctors bound (Ast_Var (Long m n)) =
  Var (Long m n) NONE)
/\ (elab_e ctors bound (Ast_Var (Short n)) =
  (case lookup n bound of
      NONE => Var (Short n) NONE
    | SOME Is_local => Var (Short n) NONE
    | SOME (Is_op op) =>
        Fun "x" NONE (Fun "y" NONE (App op (Var (Short "x") NONE) (Var (Short "y") NONE)))
    | SOME (Is_uop uop) =>
        Fun "x" NONE (Uapp uop (Var (Short "x") NONE))
  ))
/\ 
(elab_e ctors bound (Ast_Con (Long mn cn) es) =
  Con (Long mn cn) ( MAP (elab_e ctors bound) es))
/\
(elab_e ctors bound (Ast_Con (Short cn) es) =
  (case lookup cn ctors of
      SOME cid =>
        Con cid ( MAP (elab_e ctors bound) es)
    | NONE =>
        Con (Short cn) ( MAP (elab_e ctors bound) es)
  ))
/\
(elab_e ctors bound (Ast_Fun n e) =
  Fun n NONE (elab_e ctors (bind n Is_local bound) e))
/\
(elab_e ctors bound (Ast_App e1 e2) =
  App Opapp (elab_e ctors bound e1) (elab_e ctors bound e2))
/\
(elab_e ctors bound (Ast_Log log e1 e2) =
  Log log (elab_e ctors bound e1) (elab_e ctors bound e2))
/\
(elab_e ctors bound (Ast_If e1 e2 e3) =
  If (elab_e ctors bound e1) (elab_e ctors bound e2) (elab_e ctors bound e3))
/\
(elab_e ctors bound (Ast_Mat e pes) =
  Mat (elab_e ctors bound e) 
      ( MAP (\ (p,e) . 
                   let p' = elab_p p in
                     (p', elab_e ctors (merge (get_pat_bindings p') bound) e))
                pes))
/\
(elab_e ctors bound (Ast_Let x e1 e2) =
  Let NONE x NONE (elab_e ctors bound e1) (elab_e ctors (bind x Is_local bound) e2))
/\
(elab_e ctors bound (Ast_Letrec funs e) =
  Letrec NONE (elab_funs ctors (merge (get_funs_bindings funs) bound) funs) 
              (elab_e ctors bound e))
/\
(elab_funs ctors bound [] =
  [])
/\
(elab_funs ctors bound ((n1,n2,e)::funs) =
  (n1,NONE,n2,NONE,elab_e ctors (bind n2 Is_local bound) e) :: elab_funs ctors bound funs)`;

val _ = Defn.save_defn elab_e_defn;

 val get_prim_type_def = Define `
 (get_prim_type tn =
  (case tn of
      "int" => SOME TC_int
    | "bool" => SOME TC_bool
    | "unit" => SOME TC_unit
    | "ref" => SOME TC_ref
    | _ => NONE
  ))`;


 val elab_t_defn = Hol_defn "elab_t" `

(elab_t type_bound (Ast_Tvar n) = Tvar n)
/\
(elab_t type_bound (Ast_Tfn t1 t2) =
  Tfn (elab_t type_bound t1) (elab_t type_bound t2))
/\
(elab_t type_bound (Ast_Tapp ts (Long m tn)) =
  let ts' = MAP (elab_t type_bound) ts in
    Tapp ts' (TC_name (Long m tn)))
/\
(elab_t type_bound (Ast_Tapp ts (Short tn)) =
  let ts' = MAP (elab_t type_bound) ts in
    if MEM tn type_bound then
      Tapp ts' (TC_name (Short tn))
    else 
      (case get_prim_type tn of
          NONE => Tapp ts' (TC_name (Short tn))
        | SOME tc0 => Tapp ts' tc0
      ))`;

val _ = Defn.save_defn elab_t_defn;

val _ = Define `
 (get_ctors_bindings mn t = FLAT
    ( MAP (\ (tvs,tn,ctors) . MAP (\ (cn,t) . (cn, mk_id mn cn)) ctors) t))`;

   
val _ = Define `
 (elab_td type_bound (tvs,tn,ctors) =
  (tvs, tn, MAP (\ (cn,t) . (cn, MAP (elab_t type_bound) t)) ctors))`;


 val elab_dec_def = Define `

(elab_dec mn type_bound ctors bound (Ast_Dlet p e) =
  let p' = elab_p p in
    ([], emp, get_pat_bindings p', Dlet NONE p' (elab_e ctors bound e)))
/\
(elab_dec mn type_bound ctors bound (Ast_Dletrec funs) =
  let bound' = get_funs_bindings funs in
    ([], emp, bound', Dletrec NONE (elab_funs ctors (merge bound' bound) funs)))
/\
(elab_dec mn type_bound ctors bound (Ast_Dtype t) = 
  let type_bound' = MAP (\ (tvs,tn,ctors) . tn) t in
  (type_bound',
   merge (get_ctors_bindings mn t) ctors,
   emp, 
   Dtype ( MAP (elab_td (type_bound' ++ type_bound)) t)))`;


 val elab_decs_defn = Hol_defn "elab_decs" `

(elab_decs mn type_bound ctors bound [] = [])
/\
(elab_decs mn type_bound ctors bound (d::ds) = 
  let (type_bound', ctors', bound', d') = elab_dec mn type_bound ctors bound d in
  let ds' = elab_decs mn (type_bound' ++ type_bound) (merge ctors' ctors) (merge bound' bound) ds in
    d' ::ds')`;

val _ = Defn.save_defn elab_decs_defn;

 val elab_spec_defn = Hol_defn "elab_spec" `
 
(elab_spec type_bound [] = [])
/\
(elab_spec type_bound (Ast_Sval x t::spec) =
  Sval x (elab_t type_bound t) :: elab_spec type_bound spec)
/\
(elab_spec type_bound (Ast_Stype td :: spec) =
  let type_bound' = MAP (\ (tvs,tn,ctors) . tn) td in
    Stype ( MAP (elab_td (type_bound' ++ type_bound)) td) :: elab_spec (type_bound' ++ type_bound) spec)
/\
(elab_spec type_bound (Ast_Stype_opq tn::spec) =
  Stype_opq tn :: elab_spec (tn ::type_bound) spec)`;

val _ = Defn.save_defn elab_spec_defn;

 val elab_prog_defn = Hol_defn "elab_prog" `

(elab_prog type_bound ctors bound [] = [])
/\
(elab_prog type_bound ctors bound (Ast_Tdec d::prog) =
  let (type_bound', ctors', bound', d') = elab_dec NONE type_bound ctors bound d in
  let prog' = elab_prog (type_bound' ++ type_bound) (merge ctors' ctors) (merge bound' bound) prog in
    Tdec d' ::prog')
/\
(elab_prog type_bound ctors bound (Ast_Tmod mn spec ds::prog) =
  let ds' = elab_decs (SOME mn) type_bound ctors bound ds in
  let prog' = elab_prog type_bound ctors bound prog in
    Tmod mn (option_map (elab_spec type_bound) spec) ds' ::prog')`;

val _ = Defn.save_defn elab_prog_defn;
val _ = export_theory()

