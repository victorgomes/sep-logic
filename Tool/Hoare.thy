theory Hoare
  imports Semantics
begin

definition ht :: "'a pred \<Rightarrow> 'a predT \<Rightarrow> 'a pred \<Rightarrow> bool" ("(3\<turnstile> _/ (2_)/ _)" [100, 55, 100] 50) where
  "\<turnstile> p F q \<longleftrightarrow> p \<le> F q"

lemma hl_seq: "mono F \<Longrightarrow> \<turnstile> r G q \<Longrightarrow> \<turnstile> p F r \<Longrightarrow> \<turnstile> p F; G q"
  by (auto simp: ht_def mono_def)

lemma hl_skip: "p \<le> q \<Longrightarrow> \<turnstile> p skip q"
  by (auto simp: ht_def)

lemma hl_if: "\<turnstile> (p \<sqinter> b) F q \<Longrightarrow> \<turnstile> (p - b) G q \<Longrightarrow> \<turnstile> p (if_comm b F G) q"
  by (auto simp: ht_def if_comm_def)

lemma hl_weaken: "mono F \<Longrightarrow> q \<le> q' \<Longrightarrow> \<turnstile> p F q \<Longrightarrow> \<turnstile> p F q'"
  by (auto simp: ht_def mono_def)

lemma hl_strenthen: "p' \<le> p \<Longrightarrow> \<turnstile> p F q \<Longrightarrow> \<turnstile> p' F q"
  by (auto simp: ht_def)

lemma iteration: "p \<le> F q \<Longrightarrow> p \<le> F\<^sup>\<star> q"
proof -
  assume assm: "p \<le> F q"
  have "F \<le> F\<^sup>\<star>"
    by (metis PT.Sup.qpower.simps PT.Sup.qstar_refi comp_id)
  thus ?thesis using assm
    by force
qed

lemma hl_while: "mono x \<Longrightarrow> p \<le> i \<Longrightarrow> i - b \<le> q \<Longrightarrow> (i \<sqinter> b) \<le> x i \<Longrightarrow> \<turnstile> p (while_inv_comm b i x) q"
  apply (simp add: ht_def while_inv_comm_def)
  apply (auto intro!: iteration )
  apply (rule rev_predicate1D[of "\<lambda>s. x i s"])
  prefer 2
  apply (rule monoD[of x])
  by auto

lemma sl_frame: "local F \<Longrightarrow> \<turnstile> p F q \<Longrightarrow> \<turnstile> (p * r) F (q * r)"
proof (simp add: local_def ht_def)
  assume assm: "\<forall>x y. F x * y \<le> F (x * y)" "p \<le> F q"
  hence "p * r \<le> F q * r"
    by (metis Semantics.Sup.qisor)
  thus "p * r \<le> F (q * r)" using assm
    by auto
qed

lemma hl_assign: "P \<le> Q[` |m| /`x] \<Longrightarrow> \<turnstile> P (`x := ` |m| ) Q"
  by (auto simp: ht_def)

lemma sl_mutation: "P \<le> \<lbrace>`x \<mapsto> -\<rbrace> * (\<lbrace> `x \<mapsto> `m \<rbrace> -* Q) \<Longrightarrow> \<turnstile> P (@`x := `m) Q"
  sorry

ML {*

val hoare_step_tac = 
  resolve_tac [
      @{thm order_refl},
      @{thm mono_seq},
      @{thm mono_assign},
      @{thm mono_mutation},
      @{thm hl_assign}, 
      @{thm sl_mutation},
      @{thm hl_if}, 
      @{thm hl_skip}, 
      @{thm hl_seq},
      @{thm hl_while}
    ] 

val hoare_tac = REPEAT_ALL_NEW (CHANGED o hoare_step_tac)

*}

method_setup hoare_simp = {*
  Scan.succeed (fn ctxt => SIMPLE_METHOD (
    ALLGOALS hoare_tac 
    THEN ALLGOALS (asm_full_simp_tac ctxt)
  ))
*}

method_setup hoare_step = {*
  Scan.succeed (fn ctxt => SIMPLE_METHOD (
    ALLGOALS hoare_step_tac 
  ))
*}

method_setup hoare = {*
  Scan.succeed (fn ctxt => SIMPLE_METHOD (
    ALLGOALS hoare_tac
  ))
*}
end
