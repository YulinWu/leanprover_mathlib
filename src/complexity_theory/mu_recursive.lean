/-
Copyright (c) 2021 Bolton Bailey. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Bolton Bailey
-/

import data.vector.basic

/-!
# μ-recursive Functions

This file defines μ-recursive functions.
-/

/-- μ-recursive algorithms for functions from ℕ^k to ℕ -/
inductive μ_recursive : ℕ -> Type
| const {k : ℕ} {n : ℕ} : μ_recursive k
| succ : μ_recursive 1
| proj {i k : ℕ} (h : i < k) : μ_recursive k
| comp {m k : ℕ} (h : μ_recursive m) (g : fin m -> μ_recursive k) : μ_recursive k
| ρ {k : ℕ} (g : μ_recursive k) (h : μ_recursive (k + 2)) : μ_recursive (k + 1)
| μ {k : ℕ} (f : μ_recursive (k + 1)) : μ_recursive k
