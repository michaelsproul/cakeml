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
 * syntax in comments before each node. *)

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
  | Ast_Pcon of conN => ast_pat list
    (* ref x *)
  | Ast_Pref of ast_pat`;


val _ = Hol_datatype `
 error =
    Bind_error
  | Div_error
  | Int_error of int`;


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
  | Ast_Var of varN
    (* C(x,y) *)
    (* D *)
    (* E x *)
  | Ast_Con of conN => ast_exp list
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
  | Ast_Tapp of ast_t list => typeN
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
  | Ast_Dletrec of (varN # varN # exp) list
    (* see above *)
  | Ast_Dtype of type_def`;


val _ = type_abbrev( "ast_decs" , ``: ast_dec list``);

val _ = Hol_datatype `
 ast_spec =
    Ast_Sval of ast_t
  | Ast_Stype of ast_type_def
  | Ast_Stype_opq of typeN`;


val _ = type_abbrev( "ast_specs" , ``: ast_spec list``);

val _ = Hol_datatype `
 ast_top =
    Ast_Tmodule of mvarN => ast_specs => ast_decs
  | Ast_Tdec of dec`;


val _ = type_abbrev( "ast_prog" , ``: ast_top list``);
val _ = export_theory()

