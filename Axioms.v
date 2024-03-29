Require Import Top0.Definitions.
Require Import Top0.Heap.
Require Import Top0.Keys.
Require Import Top0.Nameless.
Require Import Coq.Program.Equality.
Require Import Coq.Sets.Ensembles.
Require Import Top0.MapFind.

Require Import Coq.Classes.EquivDec.
Require Import Coq.Classes.RelationClasses.

(* Use these as constructors inside "Inductive Phi" *)
Axiom Phi_Seq_Nil_L : forall phi, Phi_Seq Phi_Nil phi = phi.
Axiom Phi_Seq_Nil_R : forall phi, Phi_Seq phi Phi_Nil = phi.
Axiom Phi_Par_Nil_R : forall phi, Phi_Par phi Phi_Nil = phi.
Axiom Phi_Par_Nil_L : forall phi, Phi_Par Phi_Nil phi = phi.

Fixpoint eq_phi n m : Prop :=
  match n, m with
  | Phi_Seq Phi_Nil e, e' => eq_phi e e'
  | Phi_Nil,  Phi_Nil  => True
  | Phi_Elem e, Phi_Elem e' => e = e'
  | Phi_Seq e1 e2, Phi_Seq e1' e2' => eq_phi e1 e1' /\ eq_phi e2 e2'
  | Phi_Par e1 e2, Phi_Par e1' e2' =>  eq_phi e1 e1' /\ eq_phi e2 e2'
  | _, _ => False
  end.

(*Theorem eq_phi_is_eq n m : eq_phi n m -> n = m.
Proof.
  dependent induction n; induction m;
    try (solve [unfold eq_phi; intro; subst; reflexivity]);
    try (solve [unfold eq_phi; intro; contradiction]);
    try (solve [unfold eq_phi; intro; inversion H]). 
  - unfold eq_phi; intuition. 
    assert (n1 = m1) by (apply IHn1; assumption).
    assert (n2 = m2) by (apply IHn2; assumption).
    subst. reflexivity.
  - unfold eq_phi; intuition. 
    assert (n1 = m1) by (apply IHn1; assumption).
    assert (n2 = m2) by (apply IHn2; assumption).
    subst. reflexivity.
Qed.*)

Lemma EquivSeqNil:
  forall phi, eq_phi phi phi -> eq_phi (Phi_Seq Phi_Nil phi) phi.
Proof.
  intros. dependent induction phi.  
  - unfold eq_phi. auto.
  - unfold eq_phi. reflexivity.
  - intuition.
  - intuition.
Qed.


(** if \empty; \empty |- e : \tau ! \epsilon
     and \empty ; \empty |- \empty; e => v_1; H_1; \phi_1
     and \empty ; \empty |- \empty; e => v_2; H_2; \phi_2
     then v_1 = v_2 and H_1 = H_2 and \phi_1 = \phi_2.**)

Module HRaw := H.Raw.


Axiom Determinism:
  forall stty (e : Expr) v1 v2 ty (env : Env)  (h1 h2 : Heap) phi_1 phi_2,
    TcVal (stty, v1, ty) ->
    TcVal(stty, v2, ty) ->
    (H.empty Val , Raw.Leaf Val, R.empty nat, e) ⇓ (h1, v1, phi_1) ->
    (H.empty Val, Raw.Leaf Val, R.empty nat, e) ⇓ (h2, v2, phi_2).
      
 (* both ec' and ee' and evaluated with the same context, but twice: inside Bs_Mu_App and BS_EffApp*)
Axiom MuAppAndEffAppShareArgument:
 forall h'' env rho ef env' rho' f x ec' ee' ea aheap v eff facts1 aacts1 bacts1, 
   (forall fheap h' bacts facts v' aacts, 
      (h'', env, rho, ef) ⇓ (fheap, Cls (env', rho', Mu f x ec' ee'), facts) ->
      (fheap, env, rho, ea) ⇓ (aheap, v, aacts) ->
      (aheap, update_rec_E (f, Cls (env', rho', Mu f x ec' ee')) (x, v) env', rho', ec') ⇓ (h', v', bacts) ->
      (h'', env, rho, Mu_App ef ea) ⇓ (h', v', Phi_Seq (Phi_Seq facts aacts)bacts)) -> 
   (* above is the definition of the type constructor BS_Mu_App *)
   (h'', env, rho, Eff_App ef ea) ⇓ (h'', eff, Phi_Seq (Phi_Seq facts1 aacts1) bacts1) ->
   (aheap, update_rec_E (f, Cls (env', rho', Mu f x ec' ee')) (x, v) env', rho', ee') ⇓ (h'', eff, bacts1). 
  
(* Assuming that MuAppIncludesEffectShareArgument is a "specification", this prove the necessary goal *)
Lemma EvaluationEffectFromEffApp:
 forall h'' env rho ef env' rho' f x ec' ee' ea aheap v eff facts1 aacts1 bacts1,
   (h'', env, rho, Eff_App ef ea) ⇓ (h'', eff, Phi_Seq (Phi_Seq facts1 aacts1) bacts1) ->
   (aheap, update_rec_E (f, Cls (env', rho', Mu f x ec' ee')) (x, v) env', rho', ee') ⇓ (h'', eff, bacts1).
Proof.
  intros.
  inversion H using MuAppAndEffAppShareArgument.
  intros. econstructor; eauto.
Qed. 

(* Inside "BigStep" we still don't use "E.Equal" to pass around heaps. 
   We need to resort to Coq equality when doing the proof for PairPar *)  
Axiom ReadOnlyWalkSameHeap:
  forall acts_mu1 acts_mu2 h same_h,
    ReadOnlyPhi (Phi_Par acts_mu1 acts_mu2) ->
    (Phi_Par acts_mu1 acts_mu2, h) ==>* (Phi_Nil, same_h) ->
    (*H.Equal h same_h.*)
    h = same_h.


Axiom Functional_Map_Union_find:
  forall sttya sttyb (l : ST.key),
    ST.find (elt:=tau) l (Functional_Map_Union sttya sttyb) = ST.find (elt:=tau) l sttya.


  
Axiom TcHeap_Extended:
  forall hp hp' ef1 ea1 ef2 ea2 v1 v2 env rho 
  	heap heap_mu1 heap_mu2 sttym sttya acts_mu1 acts_mu2,
    (heap, env, rho, Mu_App ef1 ea1) ⇓ (heap_mu1, v1, acts_mu1) ->

    (heap, env, rho, Mu_App ef2 ea2) ⇓ (heap_mu2, v2, acts_mu2) ->
    (Phi_Par acts_mu1 acts_mu2, hp) ==>* (Phi_Nil, hp') ->
    TcHeap (heap_mu1, sttym) ->
    TcHeap (heap_mu2, sttya) ->
    TcHeap (hp', Functional_Map_Union sttym sttya).


Axiom TcValExtended:
  forall  stty1 stty2 v1 v2 rho ty1 ty2,
    TcVal (stty1, v1, subst_rho rho ty1) ->
    TcVal (stty2, v2, subst_rho rho ty2) ->
    TcVal (Functional_Map_Union stty1 stty2, Pair (v1, v2), subst_rho rho (Ty2_Pair ty1 ty2)).
  


Require Import Coq.Logic.FunctionalExtensionality.
Axiom subst_rho_eps_aux_1 :
 forall rho rho' n x e e1 sa sa',
   lc_type_eps e ->
   lc_type_sa sa' ->
   (fold_subst_eps rho e1) = (fold_subst_eps rho' (closing_rgn_in_eps2 n x e)) ->
   fold_subst_sa rho sa = fold_subst_sa rho' (closing_rgn_in_sa2 n x sa') /\ e1 sa /\ e sa'.
