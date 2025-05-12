cd "C:\Users\Usuario\Desktop\STATA 2022\VIDEO 4 FASE-1"

use "EPF_pescado_carne_2019(2).dta", clear
br
//Fase 1

//Apartado A

replace renta = renta/1000

egen zgtot_pescado=std(gtot_pescado)
egen zrenta=std(renta)
sort zgtot_pescado
order zgtot_pescado gtot_pescado
keep if zgtot_pescado<=3 & zrenta<=3

egen zgtot_carne=std(gtot_carne)
sort zgtot_carne
order zgtot_carne gtot_carne
keep if zgtot_carne<=3 & zrenta<=3

sum gtot_carne if gtot_carne>0, detail
scalar p25_CARNE=r(p25)
scalar p50_CARNE=r(p50)
scalar p75_CARNE=r(p75)
 
gen consumo_CARNE = 1 if gtot_carne==0
replace consumo_CARNE=2 if gtot_carne>0 & gtot_carne<=p25_CARNE
replace consumo_CARNE=3 if gtot_carne>p25_CARNE & gtot_carne<=p50_CARNE
replace consumo_CARNE=4 if gtot_carne>p50_CARNE & gtot_carne<=p75_CARNE
replace consumo_CARNE=5 if gtot_carne>p75_CARNE & gtot_carne<.

sum consumidor renta EDADSP i.ESTUDIOSSP hombresp i.CCAA diaria1 diaria0-diaria3 i.consumo_CARNE

table ( ESTUDIOSSP ) ( hombresp ) (), nototals statistic(mean gtot_pescado)
//collect export "C:\Users\Usuario\Desktop\TFG\Tablas\gtot_pescado1.xlsx", as(xlsx) sheet(Sheet1) cell(A1) replace
table ( CCAA ) ( hombresp ) (), nototals statistic(mean gtot_pescado)
//collect export "C:\Users\Usuario\Desktop\TFG\Tablas\gtot_pescado2.xlsx", as(xlsx) sheet(Sheet1) cell(A1) replace
table ( consumo_CARNE ) ( hombresp ) (), nototals statistic(mean gtot_pescado)
//collect export "C:\Users\Usuario\Desktop\TFG\Tablas\gtot_pescado3.xlsx", as(xlsx) sheet(Sheet1) cell(A1) replace
table ( ESTUDIOSSP ) ( hombresp ) (), nototals statistic(mean consumidor)
//collect export "C:\Users\Usuario\Desktop\TFG\Tablas\consumidor1.xlsx", as(xlsx) sheet(Sheet1) cell(A1) replace
table ( CCAA ) ( hombresp ) (), nototals statistic(mean consumidor)
//collect export "C:\Users\Usuario\Desktop\TFG\Tablas\consumidor2.xlsx", as(xlsx) sheet(Sheet1) cell(A1) replace
table ( consumo_CARNE ) ( hombresp ) (), nototals statistic(mean consumidor)
//collect export "C:\Users\Usuario\Desktop\TFG\Tablas\consumidor3.xlsx", as(xlsx) sheet(Sheet1) cell(A1) replace

//Apartado B

stepwise, pr(0.1): logit consumidor renta  (EDADSP c.EDADSP#c.EDADSP) hombresp (i.ESTUDIOSSP) (i.CCAA) (diaria0-diaria3) (i.consumo_CARNE), vce(robust)
//outreg2 using logit11.xls, replace ctitle(Logit) dec(3)
//Apartado C

qui logit consumidor renta EDADSP hombresp i.CCAA diaria0-diaria3 i.consumo_CARNE, vce(robust)
//outreg2 using logit1.xls, replace ctitle(Logit) dec(3)
margins, dydx(renta EDADSP i.CCAA diaria0-diaria3 i.consumo_CARNE) post 
//outreg2 using elasticdad2.xls, replace ctitle(dydx) dec(3)
//Apartado D

qui logit consumidor renta EDADSP c.EDADSP#c.EDADSP hombresp diaria0-diaria3 i.consumo_CARNE, vce(robust)
margins, dydx(renta) at(renta=(0.1(0.2)2.5))
marginsplot
marginsplot, noci

qui logit consumidor renta EDADSP c.EDADSP#c.EDADSP hombresp diaria0-diaria3 i.consumo_CARNE, vce(robust)
margins, eyex(renta) 

//Apartado E

qui logit  consumidor renta EDADSP c.EDADSP#c.EDADSP hombresp diaria0-diaria3 i.consumo_CARNE, vce(robust)
estimates store logit0
predict p_logit0, pr
predict v, xb
sum p_logit0 consumidor

preserve

gen renta_round=(renta)
replace renta_round=round(renta_round, 0.01)
collapse p_logit0, by(renta_round)

graph twoway (scatter p_logit0 renta_round , msize(vsmall)) (lpoly p_logit0 renta_round) , title("Predicción vs renta") ytitle("Predicción de la decisión de consumir pescado") xtitle("Renta pc") saving(scatter_prediccion.gph,replace)

restore

qui logit  consumidor renta EDADSP c.EDADSP#c.EDADSP hombresp diaria0-diaria3 i.consumo_CARNE, vce(robust)
estat classification 

qui logit  consumidor renta EDADSP c.EDADSP#c.EDADSP hombresp diaria0-diaria3 i.consumo_CARNE, vce(robust)
lroc, title ("ROC curve")

qui logit  consumidor renta EDADSP c.EDADSP#c.EDADSP hombresp diaria0-diaria3 i.consumo_CARNE, vce(robust)
lsens, title("Buying desicion")

qui logit  consumidor renta EDADSP c.EDADSP#c.EDADSP hombresp diaria0-diaria3 i.consumo_CARNE, vce(robust)
estat classification, cutoff(0.30)
estat classification, cutoff(0.70)
