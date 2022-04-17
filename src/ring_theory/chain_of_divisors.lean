/-
Copyright (c) 2021 Paul Lezeau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anne Baanen, Paul Lezeau
-/
import algebra.is_prime_pow
import algebra.squarefree
import order.hom.bounded

/-!

# Chains of divisors

The results in this file show that in the monoid `associates M` of a `unique_factorization_monoid`
`M`, an element `a` is an n-th prime power iff its set of divisors is a strictly increasing chain
of length `n + 1`, meaning that we can find a strictly increasing bijection between `fin (n + 1)`
and the set of factors of `a`.

## Main results
- `divisor_chain.exists_chain_of_prime_pow` : existence of a chain for prime powers.
- `divisor_chain.is_prime_pow_of_has_chain` : elements that have a chain are prime powers.
- `multiplicity_prime_le_multiplicity_image_by_factor_order_iso` : if there is a
  monotone bijection `d` between the set of factors of `a : associates M` and the set of factors of
  `b : associates N`, then, for any prime `p ∣ a`, `multiplicity p a ≤ multiplicity (d p) b`.

## Todo
- Show that under the assumptions of `multiplicity_prime_le_multiplicity_image_by_factor_order_iso`,
  `d p` is prime whenever `p` is prime. Applying
  `multiplicity_prime_le_multiplicity_image_by_factor_order_iso` on `d.symm` then gives us
  `multiplicity p a = multiplicity (d p) b`.
- Create a structure for chains of divisors.

-/


variables {M : Type*} [cancel_comm_monoid_with_zero M]

open unique_factorization_monoid multiplicity irreducible associates

namespace divisor_chain

lemma exists_chain_of_prime_pow {p : associates M} {n : ℕ} (hn : n ≠ 0) (hp : prime p) :
  ∃ c : fin (n + 1) → associates M,
    c 1 = p ∧ strict_mono c ∧
    ∀ {r : associates M}, r ≤ p^n ↔ ∃ i, r = c i :=
begin
  refine ⟨λ i, p^(i : ℕ), _, λ n m h, _, λ y, ⟨λ h, _, _⟩⟩,
  { rw [fin.coe_one', nat.mod_eq_of_lt, pow_one],
    exact nat.lt_succ_of_le (nat.one_le_iff_ne_zero.mpr hn) },
  { exact associates.dvd_not_unit_iff_lt.mp ⟨pow_ne_zero n hp.ne_zero, p^(m - n : ℕ),
      not_is_unit_of_not_is_unit_dvd hp.not_unit (dvd_pow dvd_rfl (nat.sub_pos_of_lt h).ne'),
      (pow_mul_pow_sub p h.le).symm⟩ },
  { obtain ⟨i, i_le, hi⟩ := (dvd_prime_pow hp n).1 h,
    rw associated_iff_eq at hi,
    exact ⟨⟨i, nat.lt_succ_of_le i_le⟩, hi⟩ },
  { rintro ⟨i, rfl⟩,
    exact ⟨p^(n - i : ℕ), (pow_mul_pow_sub p (nat.succ_le_succ_iff.mp i.2)).symm⟩ }
end

lemma element_of_chain_not_is_unit_of_index_ne_zero {n : ℕ} {i : fin (n + 1)} (i_pos : i ≠ 0)
  {c : fin (n + 1) → associates M} (h₁ : strict_mono c) :
  ¬ is_unit (c i) :=
dvd_not_unit.not_unit (associates.dvd_not_unit_iff_lt.2
  (h₁ $ show (0 : fin (n + 1)) < i, from i.pos_iff_ne_zero.mpr i_pos))

lemma first_of_chain_is_unit {q : associates M} {n : ℕ} {c : fin (n + 1) → associates M}
  (h₁ : strict_mono c) (h₂ : ∀ {r}, r ≤ q ↔ ∃ i, r = c i) : is_unit (c 0) :=
begin
  obtain ⟨i, hr⟩ := h₂.mp associates.one_le,
  rw [associates.is_unit_iff_eq_one, ← associates.le_one_iff, hr],
  exact h₁.monotone (fin.zero_le i)
end

/-- The second element of a chain is irreducible. -/
lemma second_of_chain_is_irreducible {q : associates M} {n : ℕ} (hn : n ≠ 0)
  {c : fin (n + 1) → associates M} (h₁ : strict_mono c) (h₂ : ∀ {r}, r ≤ q ↔ ∃ i, r = c i)
  (hq : q ≠ 0) : irreducible (c 1) :=
begin
  cases n, { contradiction },
  refine (associates.is_atom_iff (ne_zero_of_dvd_ne_zero hq (h₂.2 ⟨1, rfl⟩))).mp ⟨_, λ b hb, _⟩,
  { exact ne_bot_of_gt (h₁ (show (0 : fin (n + 2)) < 1, from fin.one_pos)) },
  obtain ⟨⟨i, hi⟩, rfl⟩ := h₂.1 (hb.le.trans (h₂.2 ⟨1, rfl⟩)),
  cases i,
  { exact (associates.is_unit_iff_eq_one _).mp (first_of_chain_is_unit h₁ @h₂) },
  { simpa [fin.lt_iff_coe_lt_coe] using h₁.lt_iff_lt.mp hb },
end

lemma eq_second_of_chain_of_prime_dvd {p q r : associates M} {n : ℕ} (hn : n ≠ 0)
  {c : fin (n + 1) → associates M} (h₁ : strict_mono c)
  (h₂ : ∀ {r : associates M}, r ≤ q ↔ ∃ i, r = c i) (hp : prime p) (hr : r ∣ q) (hp' : p ∣ r) :
  p = c 1 :=
begin
  cases n,
  { contradiction },
  obtain ⟨i, rfl⟩ := h₂.1 (dvd_trans hp' hr),
  refine congr_arg c (eq_of_ge_of_not_gt _ $ λ hi, _),
  { rw [fin.le_iff_coe_le_coe, fin.coe_one, nat.succ_le_iff, ← fin.coe_zero,
        ← fin.lt_iff_coe_lt_coe, fin.pos_iff_ne_zero],
    rintro rfl,
    exact hp.not_unit (first_of_chain_is_unit h₁ @h₂) },
  obtain (rfl | ⟨j, rfl⟩) := i.eq_zero_or_eq_succ,
  { cases hi },
  refine not_irreducible_of_not_unit_dvd_not_unit
    (dvd_not_unit.not_unit (associates.dvd_not_unit_iff_lt.2
    (h₁ (show (0 : fin (n + 2)) < j, from _)) )) _ hp.irreducible,
  { simpa [← fin.succ_zero_eq_one, fin.succ_lt_succ_iff] using hi },
  { refine associates.dvd_not_unit_iff_lt.2 (h₁ _),
    simpa only [fin.coe_eq_cast_succ] using fin.lt_succ }
end

lemma card_subset_divisors_le_length_of_chain {q : associates M}
  {n : ℕ} {c : fin (n + 1) → associates M} (h₂ : ∀ {r}, r ≤ q ↔ ∃ i, r = c i)
  {m : finset (associates M)} (hm : ∀ r, r ∈ m → r ≤ q) : m.card ≤ n + 1 :=
begin
  classical,
  have mem_image : ∀ (r : associates M), r ≤ q → r ∈ finset.univ.image c,
  { intros r hr,
    obtain ⟨i, hi⟩ := h₂.1 hr,
    exact finset.mem_image.2 ⟨i, finset.mem_univ _, hi.symm⟩ },
  rw ←finset.card_fin (n + 1),
  exact (finset.card_le_of_subset $ λ x hx, mem_image x $ hm x hx).trans finset.card_image_le,
end

variables [unique_factorization_monoid M]

lemma element_of_chain_eq_pow_second_of_chain {q r : associates M} {n : ℕ} (hn : n ≠ 0)
  {c : fin (n + 1) → associates M} (h₁ : strict_mono c)
  (h₂ : ∀ {r}, r ≤ q ↔ ∃ i, r = c i) (hr : r ∣ q)
  (hq : q ≠ 0) : ∃ (i : fin (n + 1)), r = (c 1) ^ (i : ℕ) :=
begin
  classical,
  let i := (normalized_factors r).card,
  have hi : normalized_factors r = multiset.repeat (c 1) i,
  { apply multiset.eq_repeat_of_mem,
    intros b hb,
    refine eq_second_of_chain_of_prime_dvd hn h₁ (λ r', h₂) (prime_of_normalized_factor b hb) hr
      (dvd_of_mem_normalized_factors hb) },
  have H : r = (c 1)^i,
  { have := unique_factorization_monoid.normalized_factors_prod (ne_zero_of_dvd_ne_zero hq hr),
    rw [associated_iff_eq, hi, multiset.prod_repeat] at this,
    rw this },

  refine ⟨⟨i, _⟩, H⟩,
  have : (finset.univ.image (λ (m : fin (i + 1)), (c 1) ^ (m : ℕ))).card = i + 1,
  { conv_rhs { rw [← finset.card_fin (i+1)] },
    cases n, { contradiction },
    rw finset.card_image_eq_iff_inj_on,
    refine set.inj_on_of_injective (λ m m' h, fin.ext _) _,
    refine pow_injective_of_not_unit
      (element_of_chain_not_is_unit_of_index_ne_zero (by simp) h₁) _ h,
    exact irreducible.ne_zero (second_of_chain_is_irreducible hn h₁ @h₂ hq) },

  suffices H' : ∀ r ∈ (finset.univ.image (λ (m : fin (i + 1)), (c 1) ^ (m : ℕ))), r ≤ q,
  { simp only [← nat.succ_le_iff, nat.succ_eq_add_one, ← this],
    apply card_subset_divisors_le_length_of_chain @h₂ H' },

  simp only [finset.mem_image],
  rintros r ⟨a, ha, rfl⟩,
  refine dvd_trans _ hr,
  use (c 1)^(i - a),
  rw pow_mul_pow_sub (c 1),
  { exact H },
  { exact nat.succ_le_succ_iff.mp a.2 }
end

lemma eq_pow_second_of_chain_of_has_chain {q : associates M} {n : ℕ} (hn : n ≠ 0)
  {c : fin (n + 1) → associates M} (h₁ : strict_mono c)
  (h₂ : ∀ {r : associates M}, r ≤ q ↔ ∃ i, r = c i) (hq : q ≠ 0) : q = (c 1)^n :=
begin
  classical,
  obtain ⟨i, hi'⟩ := element_of_chain_eq_pow_second_of_chain hn h₁ (λ r, h₂) (dvd_refl q) hq,
  convert hi',
  refine (nat.lt_succ_iff.1 i.prop).antisymm' (nat.le_of_succ_le_succ _),
  calc n + 1 = (finset.univ : finset (fin (n + 1))).card : (finset.card_fin _).symm
         ... = (finset.univ.image c).card :
    (finset.card_image_eq_iff_inj_on.mpr (h₁.injective.inj_on _)).symm
         ... ≤ (finset.univ.image (λ (m : fin (i + 1)), (c 1)^(m : ℕ))).card :
          finset.card_le_of_subset _
         ... ≤ (finset.univ : finset (fin (i + 1))).card : finset.card_image_le
         ... = i + 1 : finset.card_fin _,
  intros r hr,
  obtain ⟨j, -, rfl⟩ := finset.mem_image.1 hr,
  have := h₂.2 ⟨j, rfl⟩,
  rw hi' at this,
  obtain ⟨u, hu, hu'⟩ := (dvd_prime_pow (show prime (c 1), from _) i).1 this,
  refine finset.mem_image.mpr ⟨u, finset.mem_univ _, _⟩,
  { rw associated_iff_eq at hu', rw [fin.coe_coe_of_lt (nat.lt_succ_of_le hu), hu'] },
  { rw ← irreducible_iff_prime, exact second_of_chain_is_irreducible hn h₁ @h₂ hq, }
end

lemma is_prime_pow_of_has_chain {q : associates M} {n : ℕ} (hn : n ≠ 0)
  {c : fin (n + 1) → associates M} (h₁ : strict_mono c)
  (h₂ : ∀ {r : associates M}, r ≤ q ↔ ∃ i, r = c i) (hq : q ≠ 0) : is_prime_pow q :=
⟨c 1, n, irreducible_iff_prime.mp (second_of_chain_is_irreducible hn h₁ @h₂ hq),
  zero_lt_iff.mpr hn, (eq_pow_second_of_chain_of_has_chain hn h₁ @h₂ hq).symm⟩

end divisor_chain

variables {N : Type*} [cancel_comm_monoid_with_zero N]

lemma map_is_unit_of_monotone_is_unit {m u : associates M} {n : associates N}
  (hu : is_unit u) (hu' : u ≤ m) (d : {l : associates M // l ≤ m} ≃o {l : associates N // l ≤ n}) :
  is_unit (d ⟨u, hu'⟩ : associates N) :=
begin
  rw [associates.is_unit_iff_eq_one, ← associates.bot_eq_one],
  suffices : d ⟨u, hu'⟩ = ⟨⊥, bot_le⟩,
  { rw [subtype.ext_iff, subtype.coe_mk] at this,
    exact this },
  haveI : order_bot {l : associates M // l ≤ m} := subtype.order_bot bot_le,
  haveI : order_bot {l : associates N // l ≤ n} := subtype.order_bot bot_le,
  rwa [subtype.mk_bot, map_eq_bot_iff d, subtype.mk_eq_bot_iff, associates.bot_eq_one,
    ← associates.is_unit_iff_eq_one],
  exact bot_le,
end

lemma map_is_unit_iff_is_unit [decidable_eq (associates N)] {m u : associates M} {n : associates N}
  (hu' : u ≤ m) (d : {l : associates M // l ≤ m} ≃o {l : associates N // l ≤ n}) :
  is_unit u ↔ is_unit (d ⟨u, hu'⟩ : associates N) :=
⟨λ hu, map_is_unit_of_monotone_is_unit hu hu' d, λ hu, by
  { rw (show u = ↑(d.symm ⟨↑(d ⟨u, hu'⟩), (d ⟨u, hu'⟩).prop⟩), from by simp),
    exact map_is_unit_of_monotone_is_unit hu _ d.symm }⟩

variables [unique_factorization_monoid N] [unique_factorization_monoid M]

open divisor_chain

lemma pow_image_of_prime_by_factor_order_iso_dvd [decidable_eq (associates M)] {m p : associates M}
  {n : associates N} (hn : n ≠ 0) (hp : p ∈ normalized_factors m)
  (d : {l : associates M // l ≤ m} ≃o {l : associates N // l ≤ n}) {s : ℕ}
  (hs' : p^s ≤ m) : (d ⟨p, dvd_of_mem_normalized_factors hp⟩ : associates N)^s ≤ n :=
begin
  by_cases hs : s = 0,
  { simp [hs], },
  suffices : (d ⟨p, dvd_of_mem_normalized_factors hp⟩ : associates N)^s = ↑(d ⟨p^s, hs'⟩),
  { rw this,
    apply subtype.prop (d ⟨p^s, hs'⟩) },
  obtain ⟨c₁, rfl, hc₁', hc₁''⟩ := exists_chain_of_prime_pow hs (prime_of_normalized_factor p hp),

  set c₂ : fin (s + 1) → associates N := λ t, d ⟨c₁ t, le_trans (hc₁''.2 ⟨t, by simp⟩) hs'⟩,
  have c₂.def : ∀ (t), c₂ t = d ⟨c₁ t, _⟩ := λ t, rfl,
  refine (congr_arg (^s) (c₂.def 1).symm).trans _,
  refine (eq_pow_second_of_chain_of_has_chain hs (λ t u h, _) (λ r, ⟨λ hr, _, _⟩) _).symm,
  { rw [c₂.def, c₂.def, subtype.coe_lt_coe, d.lt_iff_lt, subtype.mk_lt_mk, (hc₁').lt_iff_lt],
    exact h },
  { have : r ≤ n := hr.trans (d ⟨c₁ 1 ^ s, _⟩).2,
    suffices : d.symm ⟨r, this⟩ ≤ ⟨c₁ 1 ^ s, hs'⟩,
    { obtain ⟨i, hi⟩ := hc₁''.1 this,
      use i,
      simp only [c₂.def, ← hi, d.apply_symm_apply, subtype.coe_eta, subtype.coe_mk] },
    conv_rhs { rw ← d.symm_apply_apply ⟨c₁ 1 ^ s, hs'⟩ },
    rw d.symm.le_iff_le,
    simpa only [← subtype.coe_le_coe, subtype.coe_mk] using hr },
  { rintros ⟨i, hr⟩,
    rw [hr, c₂.def, subtype.coe_le_coe, d.le_iff_le],
    simpa [subtype.mk_le_mk] using hc₁''.2 ⟨i, rfl⟩ },
  exact ne_zero_of_dvd_ne_zero hn (subtype.prop (d ⟨c₁ 1 ^ s, _⟩))
end

lemma map_prime_of_monotone_equiv [decidable_eq (associates M)] [decidable_eq (associates N)]
  {m p : associates M} {n : associates N} (hm : m ≠ 0) (hn : n ≠ 0) (hp : p ∈ normalized_factors m)
  (d : {l : associates M // l ≤ m} ≃o {l : associates N // l ≤ n}) :
  prime (d ⟨p, dvd_of_mem_normalized_factors hp⟩ : associates N) :=
begin
  rw ← irreducible_iff_prime,
  refine (associates.is_atom_iff $ ne_zero_of_dvd_ne_zero hn (d ⟨p, _⟩).prop).mp ⟨_, λ b hb, _⟩,
  { rw [ne.def, ← associates.is_unit_iff_eq_bot, ← map_is_unit_iff_is_unit
    (dvd_of_mem_normalized_factors hp) d],
    exact prime.not_unit (prime_of_normalized_factor p hp) },
  { obtain ⟨x, hx⟩ := d.surjective ⟨b, le_trans (le_of_lt hb)
      (d ⟨p, dvd_of_mem_normalized_factors hp⟩).prop⟩,
    rw [← subtype.coe_mk b _ , subtype.coe_lt_coe, ← hx] at hb,
    haveI : order_bot {l : associates M // l ≤ m} := subtype.order_bot bot_le,
    haveI : order_bot {l : associates N // l ≤ n} := subtype.order_bot bot_le,
    suffices : x = ⊥,
    { rw [this, order_iso.map_bot d ] at hx,
      refine (subtype.mk_eq_bot_iff _ _).mp hx.symm,
      exact bot_le },
    obtain ⟨a, ha⟩ := x,
    rw subtype.mk_eq_bot_iff,
    exact ((associates.is_atom_iff $ prime.ne_zero $ prime_of_normalized_factor p hp).mpr
      $ irreducible_of_normalized_factor p hp).right a (subtype.mk_lt_mk.mp $ d.lt_iff_lt.mp hb),
    exact bot_le },
end

lemma mem_normalized_factors_factor_order_iso_of_mem_normalized_factors
  [decidable_eq (associates M)] [decidable_eq (associates N)] {m p : associates M}
  {n : associates N} (hm : m ≠ 0) (hn : n ≠ 0) (hp : p ∈ normalized_factors m)
  (d : {l : associates M // l ≤ m} ≃o {l : associates N // l ≤ n}) :
  ↑(d ⟨p, dvd_of_mem_normalized_factors hp⟩) ∈ normalized_factors n :=
begin
  obtain ⟨q, hq, hq'⟩ := exists_mem_normalized_factors_of_dvd hn
      (map_prime_of_monotone_equiv hm hn hp d).irreducible
      (d ⟨p, dvd_of_mem_normalized_factors hp⟩).prop,
    rw associated_iff_eq at hq',
    rwa hq'
end

variables [decidable_rel ((∣) : M → M → Prop)] [decidable_rel ((∣) : N → N → Prop)]

lemma multiplicity_prime_le_multiplicity_image_by_factor_order_iso [decidable_eq (associates M)]
  {m p : associates M} {n : associates N} (hp : p ∈ normalized_factors m)
  (d : {l : associates M // l ≤ m} ≃o {l : associates N // l ≤ n}) :
  multiplicity p m ≤ multiplicity ↑(d ⟨p, dvd_of_mem_normalized_factors hp⟩) n :=
begin
  by_cases hn : n = 0,
  { simp [hn], },
  by_cases hm : m = 0,
  { simpa [hm] using hp, },
  rw [←enat.coe_get (finite_iff_dom.1 $ finite_prime_left (prime_of_normalized_factor p hp) hm),
    ←pow_dvd_iff_le_multiplicity],
  exact pow_image_of_prime_by_factor_order_iso_dvd hn hp d (pow_multiplicity_dvd _),
end

lemma multiplicity_prime_eq_multiplicity_image_by_factor_order_iso [decidable_eq (associates M)]
  [decidable_eq (associates N)] {m p : associates M} {n : associates N} (hm : m ≠ 0) (hn : n ≠ 0)
  (hp : p ∈ normalized_factors m) (d : {l : associates M // l ≤ m} ≃o {l : associates N // l ≤ n}) :
  multiplicity p m = multiplicity ↑(d ⟨p, dvd_of_mem_normalized_factors hp⟩) n :=
begin
  convert le_antisymm (multiplicity_prime_le_multiplicity_image_by_factor_order_iso hp d) _,
  suffices : multiplicity ↑(d ⟨p, dvd_of_mem_normalized_factors hp⟩) n ≤
    multiplicity ↑(d.symm (d ⟨p, dvd_of_mem_normalized_factors hp⟩)) m,
  { rw [d.symm_apply_apply ⟨p, dvd_of_mem_normalized_factors hp⟩, subtype.coe_mk] at this,
    exact this },
  have := (multiplicity_prime_le_multiplicity_image_by_factor_order_iso
    (mem_normalized_factors_factor_order_iso_of_mem_normalized_factors hm hn hp d) d.symm),
  rw [subtype.coe_eta] at this,
  exact this,
end

variables [unique (Mˣ)] [unique (Nˣ)]

@[simps]
noncomputable def mk_factor_order_iso_of_factor_dvd_equiv
  {m : M} {n : N} (d : {l : M // l ∣ m} ≃ {l : N // l ∣ n}) (hd : ∀ l l',
  ((d l) : N) ∣ (d l') ↔ (l : M) ∣ (l' : M)) :
   {l : associates M // l ≤ associates.mk m} ≃o {l : associates N // l ≤ associates.mk n} :=
{ to_fun := λ l, ⟨associates.mk (d ⟨mk_monoid_equiv.symm ↑l ,
    by obtain ⟨x, hx⟩ := l ;
      rw [subtype.coe_mk, ← mk_monoid_equiv.symm_apply_apply m, mk_monoid_equiv_apply,
      associates.mk_monoid_equiv_symm_dvd_iff_le] ; exact hx⟩),
    mk_le_mk_iff_dvd_iff.mpr (subtype.prop (d ⟨mk_monoid_equiv.symm ↑l,_⟩))⟩,
  inv_fun := λ l, ⟨associates.mk (d.symm (⟨(mk_monoid_equiv.symm ↑l),
    by obtain ⟨x, hx⟩ := l ;
      rw [subtype.coe_mk, ← mk_monoid_equiv.symm_apply_apply n, mk_monoid_equiv_apply,
      associates.mk_monoid_equiv_symm_dvd_iff_le] ; exact hx⟩)),
    mk_le_mk_iff_dvd_iff.mpr (subtype.prop (d.symm ⟨mk_monoid_equiv.symm ↑l,_⟩)) ⟩,
  left_inv := λ ⟨l, hl⟩, by simp only [associates.mk_monoid_equiv_apply_symm_mk, subtype.coe_eta,
    equiv.symm_apply_apply, subtype.coe_mk, associates.mk_monoid_equiv_apply_symm'],
  right_inv := λ ⟨l, hl⟩, by simp only [associates.mk_monoid_equiv_apply_symm_mk, subtype.coe_eta,
    equiv.apply_symm_apply, subtype.coe_mk, associates.mk_monoid_equiv_apply_symm'],
  map_rel_iff' :=
    by rintros ⟨a, ha⟩ ⟨b, hb⟩ ; simp only [subtype.val_eq_coe, subtype.coe_mk,
    equiv.coe_fn_mk, subtype.mk_le_mk, associates.mk_le_mk_iff_dvd_iff, hd, subtype.coe_mk,
    subtype.coe_mk, associates.mk_monoid_equiv_symm_dvd_iff_le] }

variables [decidable_eq M] [decidable_eq N]

lemma mem_normalized_factors_factor_dvd_iso_of_mem_normalized_factors {m p : M} {n : N} (hm : m ≠ 0)
  (hn : n ≠ 0) (hp : p ∈ normalized_factors m) (d : {l : M // l ∣ m} ≃ {l : N // l ∣ n})
  (hd : ∀ l l', ((d l) : N) ∣ (d l') ↔ (l : M) ∣ (l' : M)) :
    ↑(d ⟨p, dvd_of_mem_normalized_factors hp⟩) ∈ normalized_factors n :=
begin
  suffices : prime ↑(d ⟨mk_monoid_equiv.symm (mk_monoid_equiv p),
    by simp [dvd_of_mem_normalized_factors hp]⟩),
  { simp_rw [mk_monoid_equiv_apply, mk_monoid_equiv_apply_symm_mk] at this,
    obtain ⟨q, hq, hq'⟩ := exists_mem_normalized_factors_of_dvd hn (this.irreducible)
      (d ⟨p, by apply dvd_of_mem_normalized_factors ; convert hp⟩).prop,
    rwa associated_iff_eq.mp hq' },
  have : associates.mk ↑(d ⟨mk_monoid_equiv.symm (mk_monoid_equiv p), by simp only
    [dvd_of_mem_normalized_factors hp, mk_monoid_equiv_apply, mk_monoid_equiv_apply_symm_mk]⟩)
      = ↑(mk_factor_order_iso_of_factor_dvd_equiv d hd ⟨(mk_monoid_equiv p), by
      rw mk_monoid_equiv_apply ; exact mk_le_mk_of_dvd (dvd_of_mem_normalized_factors hp) ⟩),
  { rw mk_factor_order_iso_of_factor_dvd_equiv_apply_coe, refl },
  rw [ ← associates.prime_mk, this],
  classical,
  refine map_prime_of_monotone_equiv (mk_ne_zero.mpr hm) (mk_ne_zero.mpr hn) _ _,
   obtain ⟨q, hq, hq'⟩ := exists_mem_normalized_factors_of_dvd (mk_ne_zero.mpr hm)
    ((prime_mk p).mpr (prime_of_normalized_factor p (by convert hp))).irreducible
      (mk_le_mk_of_dvd (dvd_of_mem_normalized_factors (by convert hp))),
    rwa [mk_monoid_equiv_apply, associated_iff_eq.mp hq'],
end

lemma multiplicity_eq_multiplicity_factor_dvd_iso_of_mem_normalized_factor {m p : M} {n : N}
  (hm : m ≠ 0) (hn : n ≠ 0) (hp : p ∈ normalized_factors m)
  (d : {l : M // l ∣ m} ≃ {l : N // l ∣ n}) (hd : ∀ l l', ((d l) : N) ∣ (d l') ↔ (l : M) ∣ l') :
    multiplicity p m = multiplicity ((d ⟨p, dvd_of_mem_normalized_factors hp⟩) : N) n :=
begin
  suffices : multiplicity (associates.mk p) (associates.mk m) = multiplicity (associates.mk
    ↑(d ⟨mk_monoid_equiv.symm (mk_monoid_equiv p), by simp [dvd_of_mem_normalized_factors hp]⟩))
    (associates.mk n),
  { simp only [mk_monoid_equiv_apply, mk_monoid_equiv_apply_symm_mk,
     ← multiplicity_eq_multiplicity_mk] at this,
    exact this },
  have : associates.mk ↑(d ⟨mk_monoid_equiv.symm (mk_monoid_equiv p), by simp only
    [dvd_of_mem_normalized_factors hp, mk_monoid_equiv_apply, mk_monoid_equiv_apply_symm_mk]⟩)
      = ↑(mk_factor_order_iso_of_factor_dvd_equiv d hd ⟨(mk_monoid_equiv p), by
      rw mk_monoid_equiv_apply ; exact mk_le_mk_of_dvd (dvd_of_mem_normalized_factors hp) ⟩),
  { rw mk_factor_order_iso_of_factor_dvd_equiv_apply_coe, refl },
  rw this,
  classical,
  convert multiplicity_prime_eq_multiplicity_image_by_factor_order_iso (mk_ne_zero.mpr hm)
    (mk_ne_zero.mpr hn) _ (mk_factor_order_iso_of_factor_dvd_equiv d hd),
  obtain ⟨q, hq, hq'⟩ := exists_mem_normalized_factors_of_dvd (mk_ne_zero.mpr hm)
    ((prime_mk p).mpr (prime_of_normalized_factor p (by convert hp))).irreducible
      (mk_le_mk_of_dvd (dvd_of_mem_normalized_factors (by convert hp))),
    rwa associated_iff_eq.mp hq',
end
