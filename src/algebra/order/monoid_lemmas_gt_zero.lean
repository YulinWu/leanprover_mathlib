/-
Copyright (c) 2022 Damiano Testa. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Damiano Testa
-/
import algebra.covariant_and_contravariant

/-!
# Multiplication by ·positive· elements is monotonic

Let `α` be a type with `<` and `0`.  We use the type `{x : α // 0 < x}` of positive elements of `α`
to prove results about monotonicity of multiplication.  We also introduce the local notation `α>0`
for the subtype `{x : α // 0 < x}`:

*  the notation `α>0` to stands for `{x : α // 0 < x}`.

If the type `α` also has a multiplication, then we also define the multiplications on the left and
on the right of an element of `α>0` and an element of `α`:

*  `pos_mul : α>0 → α → α` is defined as `pos_mul a b = a * b`, with `a` coerced to `α` by virtue of
  being in a subtype of `α`;
*  `mul_pos : α>0 → α → α` is defined as `mul_pos a b = b * a`, with `a` coerced to `α` by virtue of
  being in a subtype of `α`.

We combine this with (`contravariant_`) `covariant_class`es to assume that multiplication by
positive elements is (strictly) monotone on a `mul_zero_class`, `monoid_with_zero`,...
More specifically, we use extensively the following typeclasses:

* monotone left
* * `covariant_class α>0 α pos_mul (≤)`, abbreviated `pos_mul_mono α`,
    expressing that multiplication by positive elements on the left is monotone;
* * `covariant_class α>0 α pos_mul (<)`, abbreviated `pos_mul_strict_mono α`,
    expressing that multiplication by positive elements on the left is strictly monotone;
* monotone right
* * `covariant_class α>0 α mul_pos (≤)`, abbreviated `mul_pos_mono α`,
    expressing that multiplication by positive elements on the right is monotone;
* * `covariant_class α>0 α mul_pos (<)`, abbreviated `mul_pos_strict_mono α`,
    expressing that multiplication by positive elements on the right is strictly monotone.
* reverse monotone left
* * `contravariant_class α>0 α pos_mul (≤)`, abbreviated `pos_mul_mono_rev α`,
    expressing that multiplication by positive elements on the left is reverse monotone;
* * `contravariant_class α>0 α pos_mul (<)`, abbreviated `pos_mul_strict_mono_rev α`,
    expressing that multiplication by positive elements on the left is strictly reverse monotone;
* reverse reverse monotone right
* * `contravariant_class α>0 α mul_pos (≤)`, abbreviated `mul_pos_mono_rev α`,
    expressing that multiplication by positive elements on the right is reverse monotone;
* * `contravariant_class α>0 α mul_pos (<)`, abbreviated `mul_pos_strict_mono_rev α`,
    expressing that multiplication by positive elements on the right is strictly reverse monotone.

##  Formalization comments

We use `α>0 = {x : α // 0 < x}` with a strict inequality since in most cases what happens with `0`
is clear.  This creates a few bumps in the first couple of proofs, where we have to split cases on
whether an element is `0` or not, but goes smoothly after that.  A further advantage is that we
only introduce notation for the positive elements and we do not need also the non-negative ones.
-/

/- I am changing the file `algebra/order/monoid_lemmas` incrementally, with the idea of
reproducing almost all of the proofs in `algebra/order/ring` with weaker assumptions. -/

universe u
variable {α : Type u}

/-  Notation for positive elements
https://
leanprover.zulipchat.com/#narrow/stream/113488-general/topic/notation.20for.20positive.20elements
-/
local notation `α>0` := {x : α // 0 < x}

namespace zero_lt

/--
`pos_mul` is the multiplication of an element of the subtype `α>0 = {x : α // 0 < x}` of positive
elements by an element of the type itself.  The element of the subtype appears on the left:
`pos_mul a b = a * b`.

`mul_pos` is the multiplication in the other order. -/
@[protected]
private def pos_mul [has_zero α] [has_lt α] [has_mul α] : α>0 → α → α :=
λ x y, x * y

/--
`mul_pos` is the multiplication of an element of the subtype `α>0 = {x : α // 0 < x}` of positive
elements by an element of the type itself.  The element of the subtype appears on the right:
`mul_pos a b = b * a`.

`pos_mul` is the multiplication in the other order. -/
@[protected]
private def mul_pos [has_zero α] [has_lt α] [has_mul α] : α>0 → α → α :=
λ x y, y * x

section abbreviations_strict_mono
variables (X : Type u) [has_mul X] [has_zero X] [has_lt X]

abbreviation pos_mul_strict_mono : Prop :=
covariant_class {x : X // 0 < x} X pos_mul (<)

abbreviation mul_pos_strict_mono : Prop :=
covariant_class {x : X // 0 < x} X mul_pos (<)

abbreviation pos_mul_strict_mono_rev : Prop :=
contravariant_class {x : X // 0 < x} X pos_mul (<)

abbreviation mul_pos_strict_mono_rev : Prop :=
contravariant_class {x : X // 0 < x} X mul_pos (<)

end abbreviations_strict_mono

section abbreviations_mono
variables (X : Type*) [has_mul X] [has_zero X] [preorder X]

abbreviation pos_mul_mono : Prop :=
covariant_class {x : X // 0 < x} X pos_mul (≤)

abbreviation mul_pos_mono : Prop :=
covariant_class {x : X // 0 < x} X mul_pos (≤)

abbreviation pos_mul_mono_rev : Prop :=
contravariant_class {x : X // 0 < x} X pos_mul (≤)

abbreviation mul_pos_mono_rev : Prop :=
contravariant_class {x : X // 0 < x} X mul_pos (≤)

end abbreviations_mono

section has_mul_zero_lt
variables [has_mul α] [has_zero α] [has_lt α]

lemma mul_lt_mul_left' [pos_mul_strict_mono α] {a b c : α} (bc : b < c) (a0 : 0 < a) :
  a * b < a * c :=
let a₀ : α>0 := ⟨a, a0⟩ in show pos_mul a₀ b < pos_mul a₀ c, from covariant_class.elim a₀ bc

lemma mul_lt_mul_right' [mul_pos_strict_mono α]
  {a b c : α} (bc : b < c) (a0 : 0 < a) :
  b * a < c * a :=
let a₀ : α>0 := ⟨a, a0⟩ in show mul_pos a₀ b < mul_pos a₀ c, by exact covariant_class.elim a₀ bc

-- proven with `a0 : 0 ≤ a` as `lt_of_mul_lt_mul_left''`
lemma lt_of_mul_lt_mul_left' [pos_mul_strict_mono_rev α]
  {a b c : α} (bc : a * b < a * c) (a0 : 0 < a) :
  b < c :=
let a₀ : α>0 := ⟨a, a0⟩ in contravariant_class.elim a₀ (id bc : pos_mul a₀ b < pos_mul a₀ c)

-- proven with `a0 : 0 ≤ a` as `lt_of_mul_lt_mul_right''`
lemma lt_of_mul_lt_mul_right' [mul_pos_strict_mono_rev α]
  {a b c : α} (bc : b * a < c * a) (a0 : 0 < a) :
  b < c :=
let a₀ : α>0 := ⟨a, a0⟩ in contravariant_class.elim a₀ (id bc : mul_pos a₀ b < mul_pos a₀ c)

@[simp]
lemma mul_lt_mul_iff_left [pos_mul_strict_mono α] [pos_mul_strict_mono_rev α]
  {a b c : α} (a0 : 0 < a) :
  a * b < a * c ↔ b < c :=
let a₀ : α>0 := ⟨a, a0⟩ in by apply rel_iff_cov α>0 α pos_mul (<) a₀

@[simp]
lemma mul_lt_mul_iff_right [mul_pos_strict_mono α] [mul_pos_strict_mono_rev α]
  {a b c : α} (a0 : 0 < a) :
  b * a < c * a ↔ b < c :=
let a₀ : α>0 := ⟨a, a0⟩ in rel_iff_cov α>0 α mul_pos (<) a₀

end has_mul_zero_lt

end zero_lt
