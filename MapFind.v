Require Import Coq.FSets.FSetAVL.
Require Import Coq.FSets.FSetWeakList.
Require Import Coq.MSets.MSetWeakList.
Require Import Coq.FSets.FSetFacts.
Require Import Coq.FSets.FMapAVL.
Require Import Coq.FSets.FMapFacts.
Require Import Coq.Program.Equality.

Require Import Top0.Keys.
Require Import Top0.Definitions.
Require Import Top0.Nameless.


Module STProofs := ST.Raw.Proofs.
Module STMapP := FMapFacts.Facts ST.
Module STMapProp := FMapFacts.Properties ST.

Definition Functional_Map_Union (stty1 stty2 : Sigma) : Sigma :=
  let f := fun (k : nat * nat) (v : tau) (m : Sigma) => ST.add k v m
  in ST.fold f stty1 stty2.


Lemma fold_add_empty:
  forall x e h is_bst is_bst0,
    {| ST.this := ST.Raw.Node  (ST.Raw.Leaf tau) x e  (ST.Raw.Leaf tau) h; ST.is_bst := is_bst |} =
      ST.add x e {| ST.this := ST.Raw.Leaf tau; ST.is_bst := is_bst0 |}.
Proof.
  intros.
  unfold ST.add. unfold ST.Raw.add. simpl.
Admitted.
  

Lemma Functional_Map_Union_find_1:
  forall sttya sttyb (l : ST.key) (t' : tau),
    ST.find (elt:=tau) l (Functional_Map_Union sttya sttyb) = ST.find (elt:=tau) l sttya.
Proof.
  intros.
  unfold Functional_Map_Union. (*ST.fold.*)
  destruct sttya. destruct sttyb. simpl. induction this0.
  - inversion is_bst; subst.
    + reflexivity. 
    + replace (ST.fold (fun (k : nat * nat) (v : tau) (m : Sigma) => ST.add k v m)
                       {| ST.this := ST.Raw.Node l0 x e r h; ST.is_bst := is_bst |}
                       {| ST.this := ST.Raw.Leaf tau; ST.is_bst := is_bst0 |})
        with ( {| ST.this := ST.Raw.Node l0 x e r h; ST.is_bst := is_bst |} ).
      * reflexivity.
      * unfold ST.add, ST.Raw.add. unfold ST.fold, ST.Raw.fold. simpl.
        admit.
  - inversion is_bst0; subst.
    assert (
         ST.find (elt:=tau) l
           (ST.fold (fun (k0 : nat * nat) (v : tau) (m : Sigma) => ST.add k0 v m)
                    {| ST.this := this; ST.is_bst := is_bst |}
                    {| ST.this := this0_1; ST.is_bst := H3 |}) =
           ST.find (elt:=tau) l {| ST.this := this; ST.is_bst := is_bst |}) as HA
        by (apply IHthis0_1).

   assert (
         ST.find (elt:=tau) l
           (ST.fold (fun (k0 : nat * nat) (v : tau) (m : Sigma) => ST.add k0 v m)
                    {| ST.this := this; ST.is_bst := is_bst |}
                    {| ST.this := this0_2; ST.is_bst := H5 |}) =
           ST.find (elt:=tau) l {| ST.this := this; ST.is_bst := is_bst |}) as HB
       by (apply IHthis0_2).
Admitted.
