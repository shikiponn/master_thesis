clear all

ssc install estout, replace
ssc install xtivreg2
ssc install xtoverid
ssc install ivreg2
ssc install ranktest
ssc install weakivtest
ssc install avar
//////時間効果あり///////

insheet using panel_data_comp_till25_2.csv
xtset pref_id fiscal_year
xtset // 確認

//山梨を落とす
drop if pref_id == 16

// 二乗項等を作成
gen log_cons_per_10002 = log_cons_per_1000^2
gen log_liver_disease_per_10002 = log_liver_disease_per_1000^2
gen burdenrate2 = burdenrate^2
gen cons_per_1 = cons_per_1000/1000
gen cons_per_12 = cons_per_1^2
gen log_grp = log(grp)
gen t_trend = fiscal_year - 11
gen t_trend2 = t_trend^2
gen t_trend3 = t_trend^3
gen xterm = burdenrate*t_trend


//////
//時間固定効果なし
//////

//noiv
xi: xtivreg2 log_suicide_per_1000  log_loony_per_1000  log_adult_population log_grp unempr  log_cons_per_1000, fe cluster(pref_id) first small
est sto noivwot
//操作変数；負担率
xi: xtivreg2 log_suicide_per_1000  log_loony_per_1000  log_adult_population  log_grp unempr  (log_cons_per_1000 = burdenrate), fe cluster(pref_id) first small
weakivtest
est sto ivburdenwot

//////
//時間固定効果あり
//////

//noiv
xi: xtivreg2 log_suicide_per_1000  log_loony_per_1000  log_adult_population log_grp unempr i.fiscal_year log_cons_per_1000, fe cluster(pref_id) first small
est sto noivwt
//操作変数；負担率
xi: xtivreg2 log_suicide_per_1000  log_loony_per_1000  log_adult_population  log_grp unempr i.fiscal_year (log_cons_per_1000 = burdenrate), fe cluster(pref_id) first small
weakivtest
est sto ivburdenwt


///
///タイムトレンド1
///
//noiv
xtivreg2 log_suicide_per_1000  log_loony_per_1000  log_adult_population log_grp unempr t_trend log_cons_per_1000, fe cluster(pref_id) first small
est sto noivt1
//操作変数；負担率
xtivreg2 log_suicide_per_1000  log_loony_per_1000  log_adult_population  log_grp unempr t_trend (log_cons_per_1000 = burdenrate), fe cluster(pref_id) first small
weakivtest
est sto ivburdent1

///
///タイムトレンド2
///
//noiv
xtivreg2 log_suicide_per_1000  log_loony_per_1000  log_adult_population log_grp unempr t_trend t_trend2 log_cons_per_1000, fe cluster(pref_id) first small
est sto noivt2
//操作変数；負担率
xtivreg2 log_suicide_per_1000  log_loony_per_1000  log_adult_population  log_grp unempr t_trend t_trend2 (log_cons_per_1000 = burdenrate), fe cluster(pref_id) first small
weakivtest
est sto ivburdent2


///
///タイムトレンド 消費の2乗
///
///
///タイムトレンド1
///

// IVなし二乗項
xtivreg2 log_suicide_per_1000 log_loony_per_1000 log_adult_population log_grp unempr t_trend cons_per_1 cons_per_12, fe cluster(pref_id) first small
est sto noiv21

//IV2二乗項
xtivreg2 log_suicide_per_1000 log_loony_per_1000 log_adult_population log_grp unempr t_trend (cons_per_1 cons_per_12 = burdenrate burdenrate2), fe cluster(pref_id) first small
weakivtest
est sto ivburden21

///
///タイムトレンド2
///
// IVなし二乗項
xtivreg2 log_suicide_per_1000 log_loony_per_1000 log_adult_population log_grp unempr t_trend t_trend2 cons_per_1 cons_per_12, fe cluster(pref_id) first small
est sto noiv22

//IV2二乗項
xtivreg2 log_suicide_per_1000 log_loony_per_1000 log_adult_population log_grp unempr t_trend t_trend2 (cons_per_1 cons_per_12 = burdenrate burdenrate2), fe cluster(pref_id) first small
weakivtest
est sto ivburden22


//タイムトレンド2
esttab noivwot ivburdenwot noivwt ivburdenwt  noivt2 ivburdent2 noiv22 ivburden22  using result4paper2.tex, se ar2 aic star(* 0.1 ** 0.05 *** 0.001) keep(log_loony_per_1000 log_adult_population log_grp unempr log_cons_per_1000 cons_per_1 cons_per_12 t_trend t_trend2 ) b(3) mtitles( "noIVwot" "burden rate wot"  "noIV wt" "burden rate wt" "noIV t2" "burden rate t2" "noIV22" "burden rate22") replace


//タイムトレンド1
esttab noivwot ivburdenwot noivwt ivburdenwt  noivt1 ivburdent1 noivt2 ivburdent2  noiv22 ivburden22  using all-result2.tex, se ar2 aic star(* 0.1 ** 0.05 *** 0.001) keep(log_loony_per_1000 log_adult_population log_grp unempr log_cons_per_1000 cons_per_1 cons_per_12 t_trend t_trend2 ) b(3) mtitles( "noIVwot" "burden rate wot"  "noIV wt" "burden rate wt" "noIV t1" "burden rate t1" "noIV t2" "burden rate t2" "noIV22" "burden rate22") replace


//all2
esttab noivwot ivburdenwot noivwt ivburdenwt noivt1 ivburdent1 noiv21 ivburden21  using result4paper1.tex, se ar2 aic star(* 0.1 ** 0.05 *** 0.001) keep(log_loony_per_1000 log_adult_population log_grp unempr log_cons_per_1000 cons_per_1 cons_per_12 t_trend) b(3) mtitles( "noIVwot" "burden rate wot"  "noIV wt" "burden rate wt" "noIV t" "burden rate t" "noIV21" "burden rate21") replace

///検証用
///
///タイムトレンド2
///

//////
//時間固定効果あり
//////

//noiv
xi: xtivreg2 log_suicide_per_1000 log_adult_population log_grp unempr i.fiscal_year log_cons_per_1000, fe cluster(pref_id) first small
est sto cnoivwt
//操作変数；負担率
xi: xtivreg2 log_suicide_per_1000 log_adult_population  log_grp unempr i.fiscal_year (log_cons_per_1000 = burdenrate), fe cluster(pref_id) first small
est sto civburdenwt



//noiv
xtivreg2 log_suicide_per_1000 log_adult_population log_grp unempr t_trend t_trend2 log_cons_per_1000, fe cluster(pref_id) first small
est sto cnoivt2
//操作変数；負担率
xtivreg2 log_suicide_per_1000 log_adult_population log_grp unempr t_trend t_trend2 (log_cons_per_1000 = burdenrate), fe cluster(pref_id) first small
est sto civburdent2

esttab cnoivwt civburdenwt  cnoivt2 civburdent2  using check.tex, se ar2 aic star(* 0.1 ** 0.05 *** 0.001) keep(log_cons_per_1000 log_adult_population log_grp unempr t_trend t_trend2) b(3) mtitles(  "noIV wt" "burden rate wt" "noIV t2" "burden rate t2" ) replace
