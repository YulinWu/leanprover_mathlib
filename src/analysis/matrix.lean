/-
Copyright (c) 2021 Heather Macbeth. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Heather Macbeth
-/
import analysis.normed_space.basic
import analysis.normed_space.pi_Lp
import analysis.inner_product_space.pi_L2

/-!
# Matrices as a normed space

In this file we provide the following non-instances on matrices, using the elementwise norm:

* `matrix.semi_normed_group`
* `matrix.normed_group`
* `matrix.normed_space`

These are not declared as instances because there are several natural choices for defining the norm
of a matrix.
-/

noncomputable theory

open_locale nnreal matrix

namespace matrix

variables {R l m n α β : Type*} [fintype l] [fintype m] [fintype n]

section semi_normed_group
variables [semi_normed_group α] [semi_normed_group β]

/-- Seminormed group instance (using sup norm of sup norm) for matrices over a seminormed group. Not
declared as an instance because there are several natural choices for defining the norm of a
matrix. -/
protected def semi_normed_group : semi_normed_group (matrix m n α) :=
pi.semi_normed_group

local attribute [instance] matrix.semi_normed_group

lemma norm_le_iff {r : ℝ} (hr : 0 ≤ r) {A : matrix m n α} :
  ∥A∥ ≤ r ↔ ∀ i j, ∥A i j∥ ≤ r :=
by simp [pi_norm_le_iff hr]

lemma nnnorm_le_iff {r : ℝ≥0} {A : matrix m n α} :
  ∥A∥₊ ≤ r ↔ ∀ i j, ∥A i j∥₊ ≤ r :=
by simp [pi_nnnorm_le_iff]

lemma norm_lt_iff {r : ℝ} (hr : 0 < r) {A : matrix m n α} :
  ∥A∥ < r ↔ ∀ i j, ∥A i j∥ < r :=
by simp [pi_norm_lt_iff hr]

lemma nnnorm_lt_iff {r : ℝ≥0} (hr : 0 < r) {A : matrix m n α} :
  ∥A∥₊ < r ↔ ∀ i j, ∥A i j∥₊ < r :=
by simp [pi_nnnorm_lt_iff hr]

lemma norm_entry_le_entrywise_sup_norm (A : matrix m n α) {i : m} {j : n} :
  ∥A i j∥ ≤ ∥A∥ :=
(norm_le_pi_norm (A i) j).trans (norm_le_pi_norm A i)

lemma nnnorm_entry_le_entrywise_sup_nnnorm (A : matrix m n α) {i : m} {j : n} :
  ∥A i j∥₊ ≤ ∥A∥₊ :=
(nnnorm_le_pi_nnnorm (A i) j).trans (nnnorm_le_pi_nnnorm A i)

@[simp] lemma nnnorm_transpose (A : matrix m n α) : ∥Aᵀ∥₊ = ∥A∥₊ :=
by { simp_rw [pi.nnnorm_def], exact finset.sup_comm _ _ _ }
@[simp] lemma norm_transpose (A : matrix m n α) : ∥Aᵀ∥ = ∥A∥ := congr_arg coe $ nnnorm_transpose A

@[simp] lemma nnnorm_map_eq (A : matrix m n α) (f : α → β) (hf : ∀ a, ∥f a∥₊ = ∥a∥₊) :
  ∥A.map f∥₊ = ∥A∥₊ :=
by simp_rw [pi.nnnorm_def, matrix.map, hf]
@[simp] lemma norm_map_eq (A : matrix m n α) (f : α → β) (hf : ∀ a, ∥f a∥ = ∥a∥) :
  ∥A.map f∥ = ∥A∥ :=
(congr_arg (coe : ℝ≥0 → ℝ) $ nnnorm_map_eq A f $ λ a, subtype.ext $ hf a : _)

@[simp] lemma nnnorm_col (v : m → α) : ∥col v∥₊ = ∥v∥₊ := by simp [pi.nnnorm_def]
@[simp] lemma norm_col (v : m → α) : ∥col v∥ = ∥v∥ := congr_arg coe $ nnnorm_col v

@[simp] lemma nnnorm_row (v : n → α) : ∥row v∥₊ = ∥v∥₊ := by simp [pi.nnnorm_def]
@[simp] lemma norm_row (v : n → α) : ∥row v∥ = ∥v∥ := congr_arg coe $ nnnorm_row v

@[simp] lemma nnnorm_diagonal [decidable_eq n] (v : n → α) : ∥diagonal v∥₊ = ∥v∥₊ :=
begin
  simp_rw pi.nnnorm_def,
  congr' 1 with i : 1,
  refine le_antisymm (finset.sup_le $ λ j hj, _) _,
  { obtain rfl | hij := eq_or_ne i j,
    { rw diagonal_apply_eq },
    { rw [diagonal_apply_ne hij, nnnorm_zero],
      exact zero_le _ }, },
  { refine eq.trans_le _ (finset.le_sup (finset.mem_univ i)),
    rw diagonal_apply_eq }
end

@[simp] lemma norm_diagonal [decidable_eq n] (v : n → α) : ∥diagonal v∥ = ∥v∥ :=
congr_arg coe $ nnnorm_diagonal v

/-- Note this is safe as an instance as it carries no data. -/
instance [nonempty n] [decidable_eq n] [has_one α] [norm_one_class α] :
  norm_one_class (matrix n n α) :=
⟨(norm_diagonal _).trans $ norm_one⟩

end semi_normed_group

/-- Normed group instance (using sup norm of sup norm) for matrices over a normed group.  Not
declared as an instance because there are several natural choices for defining the norm of a
matrix. -/
protected def normed_group [normed_group α] : normed_group (matrix m n α) :=
pi.normed_group

section normed_space
local attribute [instance] matrix.semi_normed_group

variables [normed_field R] [semi_normed_group α] [normed_space R α]

/-- Normed space instance (using sup norm of sup norm) for matrices over a normed space.  Not
declared as an instance because there are several natural choices for defining the norm of a
matrix. -/
protected def normed_space : normed_space R (matrix m n α) :=
pi.normed_space

end normed_space


section frobenius

open_locale matrix big_operators

instance frobenius_semi_normed_group [semi_normed_group α] :
  semi_normed_group (matrix m n α) :=
(by apply_instance : semi_normed_group (pi_Lp 2 (λ i : m, pi_Lp 2 (λ j : n, α))))

instance frobenius_normed_group [normed_group α] :
  normed_group (matrix m n α) :=
(by apply_instance : normed_group (pi_Lp 2 (λ i : m, pi_Lp 2 (λ j : n, α))))

instance frobenius_normed_space [normed_field R] [semi_normed_group α] [normed_space R α] :
  normed_space R (matrix m n α) :=
(by apply_instance : normed_space R (pi_Lp 2 (λ i : m, pi_Lp 2 (λ j : n, α))))

lemma frobenius_nnnorm_def [semi_normed_group α] (A : matrix m n α) :
  ∥A∥₊ = (∑ i j, ∥A i j∥₊ ^ (2 : ℝ)) ^ (1/2 : ℝ) :=
by simp_rw [pi_Lp.nnnorm_eq, ←nnreal.rpow_mul, div_mul_cancel (1 : ℝ) two_ne_zero, nnreal.rpow_one]

lemma frobenius_norm_def [semi_normed_group α] (A : matrix m n α) :
  ∥A∥ = (∑ i j, ∥A i j∥ ^ (2 : ℝ)) ^ (1/2 : ℝ) :=
(congr_arg coe (frobenius_nnnorm_def A)).trans $ by simp [nnreal.coe_sum]

lemma frobenius_nnnorm_mul [is_R_or_C α] (A : matrix l m α) (B : matrix m n α) :
  ∥A ⬝ B∥₊ ≤ ∥A∥₊ * ∥B∥₊ :=
begin
  simp_rw [frobenius_nnnorm_def],
  rw [←nnreal.mul_rpow],
  simp_rw [matrix.mul_apply],
  rw @finset.sum_comm _ n m,
  rw [finset.sum_mul_sum, finset.sum_product],
  refine nnreal.rpow_le_rpow _ one_half_pos.le,
  refine finset.sum_le_sum (λ i hi, finset.sum_le_sum $ λ j hj, _),
  rw [← nnreal.rpow_le_rpow_iff one_half_pos, ← nnreal.rpow_mul,
    mul_div_cancel' (1 : ℝ) two_ne_zero, nnreal.rpow_one, nnreal.mul_rpow,
      ←pi_Lp.nnnorm_eq, ←pi_Lp.nnnorm_eq],
  dsimp,
  let a : pi_Lp 2 _ := A i,
  let a' : pi_Lp 2 _ := λ j, star (a j),
  let b : pi_Lp 2 _ := λ k, B k j,
  letI : inner_product_space α (pi_Lp 2 (λ i : m, α)) := pi_Lp.inner_product_space _,
  change ∥∑ k, a k * b k∥₊ ≤ ∥a∥₊ * ∥b∥₊,
  convert nnnorm_inner_le_nnnorm a' b using 2,
  { simp,
    simp_rw [star_ring_end_apply, star_star], },
  simp [pi_Lp.nnnorm_eq, a'],
  simp_rw [star_ring_end_apply, nnnorm_star],
end

lemma frobenius_norm_mul [is_R_or_C α] (A : matrix l m α) (B : matrix m n α) :
  ∥A ⬝ B∥ ≤ ∥A∥ * ∥B∥ :=
frobenius_nnnorm_mul A B

instance frobenius_normed_ring [is_R_or_C α] [decidable_eq m] : normed_ring (matrix m m α) :=
{ norm := has_norm.norm,
  norm_mul := frobenius_norm_mul,
  ..matrix.frobenius_semi_normed_group }

end frobenius
end matrix
