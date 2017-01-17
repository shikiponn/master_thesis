clear all

//////時間効果あり///////

insheet using panel_data_small.csv
xtset pref_id fiscal_year
xtset // 確認

//山梨を落とす
drop if pref_id == 16
//1人当たり(割合)に直す
gen  suicide_rate = suicide_per_1000
gen log_suicide = log(suicide_rate)
gen log_loony = log(loony_per_1000)
gen log_grp = log(grp_per_1000/1000)
//成人一人当たり
gen cons = cons_per_1000adult/1000
*gen log_cons = log(cons_per_1000adult/1000)
//gen cons_adult = cons_per_1000adult
//gen log_liver_disease_per_10002 = log_liver_disease_per_1000^2
gen burdenrate2 = burdenrate^2
gen log_over65rate = log(over65rate)
gen log_unempr = log(unempr)
// 二乗項等を作成
gen cons2 = cons^2
//gen log_grp = log(grp)
gen t_trend = fiscal_year - 11
gen t_trend2 = t_trend^2
gen t_trend3 = t_trend^3
gen xterm = burdenrate*t_trend
gen l_birth_rate = log(birth_rate)
gen l_marriage_rate = log(marriage_rate)
gen l_divorce_rate = log(divorce_rate)
//////
//時間固定効果なし
//////

//noiv
xi: xtivreg2  log_suicide  cons log_loony  log_over65rate  log_grp log_unempr l_birth_rate l_marriage_rate l_divorce_rate, fe cluster(pref_id) first small
est sto noivwot
//操作変数；負担率
xi: xtivreg2  log_suicide  log_loony  log_over65rate  log_grp log_unempr l_birth_rate l_marriage_rate l_divorce_rate (cons = burdenrate), fe cluster(pref_id) first small
weakivtest
est sto ivburdenwot

//////
//時間固定効果あり
//////

//noiv
xi: xtivreg2  log_suicide  cons log_loony  log_over65rate log_grp log_unempr i.fiscal_year l_birth_rate l_marriage_rate l_divorce_rate , fe cluster(pref_id) first small
est sto noivwt
//操作変数；負担率
xi: xtivreg2  log_suicide  log_loony  log_over65rate log_grp log_unempr i.fiscal_year l_birth_rate l_marriage_rate l_divorce_rate (cons = burdenrate), fe cluster(pref_id) first small
weakivtest
est sto ivburdenwt


///
///タイムトレンド1
///
//noiv
xtivreg2  log_suicide  cons log_loony  log_over65rate log_grp log_unempr t_trend cons, fe cluster(pref_id) first small
est sto noivt1
//操作変数；負担率
xtivreg2  log_suicide  log_loony  log_over65rate log_grp log_unempr t_trend (cons = burdenrate), fe cluster(pref_id) first small
//weakivtest
est sto ivburdent1

///
///タイムトレンド2
///
//noiv
*xtivreg2  suicide_rate  log_loony  over65rate log_grp unempr l_birth_rate l_marriage_rate l_divorce_rate t_trend t_trend2 log_cons, fe cluster(pref_id) first small
*est sto noivt2
//操作変数；負担率
*xtivreg2  suicide_rate  log_loony  over65rate log_grp unempr l_birth_rate l_marriage_rate l_divorce_rate t_trend t_trend2 (log_cons = burdenrate), fe cluster(pref_id) first small
*weakivtest
*est sto ivburdent2


///
///タイムトレンド 消費の2乗
///
///
///タイムトレンド1
///

// IVなし二乗項
*xtivreg2  suicide_rate  log_loony  over65rate log_grp unempr t_trend cons cons2, fe cluster(pref_id) first small
*est sto noiv21

//IV2二乗項
*xtivreg2  suicide_rate  log_loony  over65rate log_grp unempr t_trend (cons cons2 = burdenrate burdenrate2), fe cluster(pref_id) first small
*weakivtest
*est sto ivburden21

///
///タイムトレンド2
///
// IVなし二乗項
*xtivreg2  suicide_rate  log_loony  over65rate log_grp unempr l_birth_rate l_marriage_rate l_divorce_rate t_trend t_trend2 cons cons2, fe cluster(pref_id) first small
*est sto noiv22

//IV2二乗項
*xtivreg2  suicide_rate  log_loony  over65rate log_grp unempr l_birth_rate l_marriage_rate l_divorce_rate t_trend t_trend2 (cons cons2 = burdenrate burdenrate2), fe cluster(pref_id) first small
*weakivtest
*est sto ivburden22


//タイムトレンド2
esttab noivwot ivburdenwot noivwt ivburdenwt  noivt1 ivburdent1  using result4paper2.tex, se ar2 aic star(* 0.1 ** 0.05 *** 0.001) keep(cons log_loony  log_over65rate l_birth_rate l_marriage_rate l_divorce_rate log_grp log_unempr   t_trend) b(3) mtitles( "noIVwot" "burden rate wot"  "noIV wt" "burden rate wt" "noIV t2" "burden rate t2" "noIV22" "burden rate22") replace


//タイムトレンド1
//esttab noivwot ivburdenwot noivwt ivburdenwt  noivt1 ivburdent1 noivt2 ivburdent2  noiv22 ivburden22  using all-result2.tex, se ar2 aic star(* 0.1 ** 0.05 *** 0.001) keep(log_cons cons cons2 log_loony over65rate log_grp unempr  t_trend t_trend2 ) b(3) mtitles( "noIVwot" "burden rate wot"  "noIV wt" "burden rate wt" "noIV t1" "burden rate t1" "noIV t2" "burden rate t2" "noIV22" "burden rate22") replace

//係数に高齢化の二乗を入れたがAICが悪くなるだけであった
//all2
//esttab noivwot ivburdenwot noivwt ivburdenwt noivt1 ivburdent1 noivt2 ivburdent2  using result4paper1.tex, se ar2 aic star(* 0.1 ** 0.05 *** 0.001) keep(log_cons  log_loony over65rate over65rate2 log_grp unempr  t_trend) b(3) mtitles( "noIVwot" "burden rate wot"  "noIV wt" "burden rate wt" "noIV t" "burden rate t" "noIV21" "burden rate21") replace

///検証用
///
///タイムトレンド2
///

//////
//時間固定効果あり
//////

//noiv
*xi: xtivreg2  suicide_rate over65rate log_grp unempr l_birth_rate l_marriage_rate l_divorce_rate log_cons, fe cluster(pref_id) first small
*est sto cnoivwot
//操作変数；負担率
*xi: xtivreg2  suicide_rate over65rate  log_grp unempr l_birth_rate l_marriage_rate l_divorce_rate (log_cons = burdenrate), fe cluster(pref_id) first small
*est sto civburdenwot



//noiv
*xtivreg2  suicide_rate log_cons over65rate  log_grp unempr l_birth_rate l_marriage_rate l_divorce_rate t_trend t_trend2 , fe cluster(pref_id) first small
*est sto cnoivt2
//操作変数；負担率
*xtivreg2  suicide_rate over65rate log_grp unempr l_birth_rate l_marriage_rate l_divorce_rate  t_trend t_trend2 (log_cons = burdenrate), fe cluster(pref_id) first small
*est sto civburdent2

*esttab cnoivwot civburdenwot cnoivt2 civburdent2  using check.tex, se ar2 aic star(* 0.1 ** 0.05 *** 0.001) keep(log_cons over65rate log_grp unempr l_birth_rate l_marriage_rate l_divorce_rate t_trend t_trend2) b(3) mtitles(  "noIV wot" "burden rate wot" "noIV t2" "burden rate t2" ) replace
