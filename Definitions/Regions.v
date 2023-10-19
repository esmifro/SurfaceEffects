Require Import Ascii.
Require Import Definitions.Keys.

(* Static Labels *)
Definition RgnId :=  nat.

(* Program Variables *)
Definition VarId := ascii.

Inductive Region : bool * bool * bool -> Set :=
  | Rgn2_Const : forall fv bv, RgnId -> Region (true, fv, bv)
  | Rgn2_FVar : forall c bv, VarId -> Region (c, true, bv)
  | Rgn2_BVar : forall c fv, nat -> Region (c, fv, true).
Definition Region_in_Expr := Region (true, true, false).
Definition Region_in_Type := Region (true, true, true).


Module R := FMapAVL.Make (AsciiVars).
Module RMapP := FMapFacts.Facts R.
Module RMapProp := FMapFacts.Properties R.

Definition Rho := R.t nat.


Definition find_R (k: Region_in_Expr) (m: Rho) : option RgnId :=
 match k with 
  | Rgn2_Const fv bv n => Some n
  | Rgn2_FVar c bv n => R.find (elt := RgnId) n m
  | Rgn2_BVar c fv n => None                               
 end.

Definition update_R (p: VarId * RgnId) (m : Rho) := R.add (fst p) (snd p) m.


(*Export R.
Export RMapP.
Export RMapProp.*)