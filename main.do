clear all

*ssc install estout, replace
*ssc install xtivreg2
*ssc install xtoverid
*ssc install ivreg2
*ssc install ranktest
*ssc install weakivtest
*ssc install avar
//////時間効果あり///////
cd /Users/shiki/Dropbox/workspace/papers/data/tex/result/large/mod2/
*insheet using panel_data_comp_till25_4.csv
insheet using panel_data_comp_till25_4.csv
xtset pref_id fiscal_year
xtset // 確認

//山梨を落とす
drop if pref_id == 16
//1人当たり(割合)に直す
gen  suicide_rate = (suicide_per_1000) 
gen log_suicide = log(suicide_rate) 

gen loony_rate = loony_per_1000
gen log_loony = log(loony_rate) 

gen log_grp = log(grp_per_1000/1000) 
//成人一人当たり
gen cons_rate = cons_per_1000adult/1000 //水準
//gen log_cons = log(cons_per_1000adult/1000)

gen log_unempr = log(unempr)
gen log_over65rate = log(over65rate)


gen t_trend = fiscal_year - 11
gen t_trend2 = t_trend^2
gen t_trend3 = t_trend^3



//////
//時間固定効果なし
//////

//noiv
xi: xtivreg2  log_suicide cons_rate log_loony  log_over65rate log_grp log_unempr, fe cluster(pref_id) first small
est sto noivwot
//操作変数；負担率
xi: xtivreg2  log_suicide log_loony  log_over65rate log_grp log_unempr  (cons_rate = burdenrate), fe cluster(pref_id) first small
weakivtest
est sto ivburdenwot

//////
//時間固定効果あり
//////

//noiv
xi: xtivreg2 log_suicide cons_rate log_loony  log_over65rate log_grp log_unempr i.fiscal_year, fe cluster(pref_id) first small
est sto noivwt
//操作変数；負担率
xi: xtivreg2 log_suicide log_loony  log_over65rate log_grp log_unempr i.fiscal_year (cons_rate = burdenrate), fe cluster(pref_id) first small
weakivtest
est sto ivburdenwt


///
///タイムトレンド1
///
//noiv
xtivreg2 log_suicide cons_rate log_loony  log_over65rate log_grp log_unempr t_trend , fe cluster(pref_id) first small
est sto noivt1
//操作変数；負担率
xtivreg2  log_suicide log_loony  log_over65rate log_grp log_unempr t_trend (cons_rate = burdenrate), fe cluster(pref_id) first small
//weakivtest
est sto ivburdent1

///
///タイムトレンド2
///
//noiv
*xtivreg2 log_suicide cons_rate log_loony  log_over65rate log_grp log_unempr t_trend t_trend2, fe cluster(pref_id) first small
*est sto noivt2
//操作変数；負担率
*xtivreg2 log_suicide log_loony  log_over65rate log_grp log_unempr t_trend t_trend2 (cons_rate = burdenrate), fe cluster(pref_id) first small
*weakivtest
*est sto ivburdent2




//タイムトレンド2
esttab noivwot ivburdenwot noivwt ivburdenwt  noivt1 ivburdent1 using result4paper.tex, se ar2 aic star(* 0.1 ** 0.05 *** 0.001) keep(cons_rate log_loony  log_over65rate log_grp log_unempr  t_trend) b(3) mtitles( "noIVwot" "burden rate wot"  "noIV wt" "burden rate wt" "noIV t1" "burden rate t1" "noIVt2" "burden ratet2") replace


///検証用
///
///タイムトレンド2
///

//////
//時間固定効果あり
//////

//noiv
xi: xtivreg2 log_suicide cons_rate  log_over65rate log_grp log_unempr, fe cluster(pref_id) first small
est sto cnoivwot
//操作変数；負担率
xi: xtivreg2  log_suicide log_over65rate log_grp log_unempr (cons_rate = burdenrate), fe cluster(pref_id) first small
est sto civburdenwot



//noiv
xtivreg2  log_suicide cons_rate log_over65rate log_grp log_unempr t_trend  , fe cluster(pref_id) first small
est sto cnoivt1
//操作変数；負担率
xtivreg2  log_suicide  log_over65rate log_grp log_unempr  t_trend  (cons_rate = burdenrate), fe cluster(pref_id) first small
est sto civburdent1

esttab cnoivwot civburdenwot cnoivt1 civburdent1  using check.tex, se ar2 aic star(* 0.1 ** 0.05 *** 0.001) keep(cons_rate  log_over65rate log_grp log_unempr t_trend ) b(3) mtitles(  "noIV wot" "burden rate wot" "noIV t2" "burden rate t2" ) replace
