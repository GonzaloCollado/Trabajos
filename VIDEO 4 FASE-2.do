cd "C:\Users\Usuario\Desktop\STATA 2022\VIDEO 4 FASE-2"

//Creando la base de datos

use "EPFgastos_2019.dta", clear 
reshape wide GASTO-GASTNOM5, i(NUMERO) j(CODIGO) string
save "GASTOS2019.dta",replace

use "EPFhogar_2019.dta", clear

use "EPFmhogar_2019.dta",clear 
reshape wide CATEGMH-ADULTO, i(NUMERO) j(NORDEN)
save "MIEMBROS2019.dta",replace

use "EPFhogar_2019.dta", clear
merge 1:1 NUMERO ANOENC using "MIEMBROS2019.dta"
drop _merge
merge 1:1 NUMERO ANOENC using "GASTOS2019.dta"

browse	

save "EPF_2019.dta", replace


//Fase 1

use "EPF_2019.dta", clear

drop GASTO01111-GASTNOM501128
drop GASTO01134-GASTNOM512820

//Etiquetas

foreach i of varlist GASTO01131-GASTNOM501131 {
	label variable `i' " `i' PESCADOS FRESCOS O REFRIGERADOS"
}

foreach i of varlist GASTO01132-GASTNOM501132 {
	label variable `i' " `i' PESCADOS CONGELADOS"
}

foreach i of varlist GASTO01133-GASTNOM501133 {
	label variable `i' " `i' MARISCOS FRESCOS O REFRIGERADOS"
}

save "EPF_pescado_2019.dta", replace

//Categoría 1

use "EPF_pescado_2019.dta", clear

foreach i of varlist GASTOMON01131 GASTOMON01133 {
	replace `i' = `i'/FACTOR
}

foreach i of varlist CANTIDAD* {
	replace `i' = `i'/FACTOR
}

drop GASTO01132-GASTNOM501133 

drop GASTO01131 PORCENDES01131 PORCENIMP01131 GASTNOM101131 GASTNOM201131 GASTNOM301131 GASTNOM401131 GASTNOM501131

rename GASTOMON01131 gasto
rename CANTIDAD01131 cantidad

gen producto=1

gen precio=gasto/cantidad

save "EPF_01131_2019.dta",replace

//Categoría 2

use "EPF_pescado_2019.dta", clear

foreach i of varlist GASTOMON01131 GASTOMON01133 {
	replace `i' = `i'/FACTOR
}

foreach i of varlist CANTIDAD* {
	replace `i' = `i'/FACTOR
}
 
drop GASTO01131-GASTNOM501131 
drop GASTO01133-GASTNOM501133 

drop GASTO01132 PORCENDES01132 PORCENIMP01132 GASTNOM101132 GASTNOM201132 GASTNOM301132 GASTNOM401132 GASTNOM501132

rename GASTOMON01132 gasto
rename CANTIDAD01132 cantidad

gen producto=2

gen precio=gasto/cantidad

save "EPF_01132_2019.dta",replace


//Categoría 3

use "EPF_pescado_2019.dta", clear

foreach i of varlist GASTOMON01131 GASTOMON01133 {
	replace `i' = `i'/FACTOR
}

foreach i of varlist CANTIDAD* {
	replace `i' = `i'/FACTOR
}
 
drop GASTO01131-GASTNOM501132 

drop GASTO01133 PORCENDES01133 PORCENIMP01133 GASTNOM101133 GASTNOM201133 GASTNOM301133 GASTNOM401133 GASTNOM501133

rename GASTOMON01133 gasto
rename CANTIDAD01133 cantidad

gen producto=3

gen precio=gasto/cantidad

save "EPF_01133_2019.dta",replace

//Fusión categorías

use "EPF_01131_2019.dta", clear
append using  "EPF_01132_2019.dta"
append using  "EPF_01133_2019.dta"

label define producto 1 "PESCADOS FRESCOS O REFRIGERADOS" 2 "PESCADOS CONGELADOS" 3 "MARISCOS FRESCOS O REFRIGERADOS"
label values producto producto

save "EPF_pescado_2019(2).dta", replace

//Base de datos bien sustitutivo 

use "EPF_2019.dta", clear

keep NUMERO FACTOR GASTO01121-GASTNOM501125

keep NUMERO FACTOR CANTIDAD* GASTOMON*
describe 

foreach i of varlist GASTOMON* {
	replace `i' = `i'/FACTOR
}

foreach i of varlist CANTIDAD* {
	replace `i' = `i'/FACTOR

}

foreach i of varlist GASTOMON* {
	replace `i' = 0 if `i'==.
}

replace CANTIDAD01121=0 if GASTOMON01121==0
replace CANTIDAD01122=0 if GASTOMON01122==0
replace CANTIDAD01123=0 if GASTOMON01123==0
replace CANTIDAD01124=0 if GASTOMON01124==0
replace CANTIDAD01125=0 if GASTOMON01125==0

gen gtot_carne=(GASTOMON01121+GASTOMON01122+GASTOMON01123+GASTOMON01124+GASTOMON01125)
gen gtot_carnemes=gtot_carne/12

gen cons_carne=1 if gtot_carnemes>0 & gtot_carnemes<.
replace cons_carne=0 if gtot_carnemes==0

tab cons_carne

gen p_01121=GASTOMON01121/CANTIDAD01121 
replace p_01121=. if p_01121==0

gen p_01122=GASTOMON01122/CANTIDAD01122 
replace p_01122=. if p_01122==0

gen p_01123=GASTOMON01123/CANTIDAD01123 
replace p_01123=. if p_01123==0

gen p_01124=GASTOMON01124/CANTIDAD01124 
replace p_01124=. if p_01124==0

gen p_01125=GASTOMON01125/CANTIDAD01125 
replace p_01125=. if p_01125==0

gen g01121_mes=GASTOMON01121/12
gen g01122_mes=GASTOMON01122/12
gen g01123_mes=GASTOMON01123/12
gen g01124_mes=GASTOMON01124/12
gen g01125_mes=GASTOMON01125/12

gen q01121_mes=CANTIDAD01121/12
gen q01122_mes=CANTIDAD01122/12
gen q01123_mes=CANTIDAD01123/12
gen q01124_mes=CANTIDAD01124/12
gen q01125_mes=CANTIDAD01125/12

save "EPF_carne_2019.dta", replace

//Fusión bases de datos

use "EPF_pescado_2019(2).dta", clear
drop _merge

merge m:1 NUMERO using "EPF_carne_2019.dta"

save "EPF_pescado_carne_2019.dta", replace

//Variables

use "EPF_pescado_carne_2019.dta", clear

replace gasto=0 if gasto==.

replace cantidad=0 if gasto==0

gen gpescado_mes=gasto/12
gen qpescado_mes=cantidad/12

sort NUMERO
by NUMERO: egen gtot_pescado=total(gpescado_mes)

gen byte consumidor=(gtot_pescado>0 & gtot_pescado<.)
tab consumidor

by NUMERO: gen select=1 if _n==1 

replace precio=. if cantidad==0
sum precio

gen gastmon_ind=GASTMON/FACTOR

sum gastmon_ind

destring TAMANO, replace
tab TAMANO
sum TAMANO

gen gastmon_pc=gastmon_ind/TAMANO

gen gastmonmes_pc=gastmon_pc/12

rename gastmonmes_pc renta

label variable renta "Renta mensual Per Capita"

//Género del sustentador principal
destring SEXOSP, replace
tab SEXOSP
replace SEXOSP=0 if SEXOSP==6
rename SEXOSP hombresp
tab hombresp

//Nivel de estudios del sustentador principal
destring ESTUDIOSSP, replace

//CCAA
destring CCAA, replace

//Tamaño de municipio
destring TAMAMU, replace
tab TAMAMU, gen(municp)

//Número de comidas diarias (dummys)
//Número de comidas y cenas efectuadas por los miembros del hogar (excepto el servicio doméstico, invitados y huéspedes)
replace COMIMH=. if COMIMH==-9
gen byte gcomeh=(COMIMH)
sum gcomeh,detail
histogram gcomeh

qui gen diaria_never=(gcomeh==0)
qui gen diaria0=(gcomeh>0 & gcomeh<=15)
qui gen diaria1=(gcomeh>15 & gcomeh<=31)
qui gen diaria2=(gcomeh>31 & gcomeh<=62)
qui gen diaria3=(gcomeh>62 & gcomeh<.)

save "EPF_pescado_carne_2019(3).dta", replace

//Fase 2
cd "C:\Users\Usuario\Desktop\STATA 2022\VIDEO 4 FASE-2"

use "EPF_pescado_carne_2019(3).dta", clear
br
//Apartado A

list NUMERO producto gpescado_mes in 1/20 

gen byte g1=0
replace g1=gpescado_mes if producto==1
sort NUMERO producto
by NUMERO: egen gt1=total(g1)

gen byte g2=0
replace g2=gpescado_mes if producto==2
sort NUMERO producto
by NUMERO: egen gt2=total(g2)

gen byte g3=0
replace g3=gpescado_mes if producto==3
sort NUMERO producto
by NUMERO: egen gt3=total(g3)


gen pescado1=gt1/gtot_pescado
gen pescado2=gt2/gtot_pescado
gen marisco1=gt3/gtot_pescado

tabstat pescado1 pescado2 marisco1 if gtot_pescado>0, stats(mean sd p25 p50 p75)

gen byte alternativa=1 if gtot_pescado==0
replace alternativa=2 if pescado1>=0.75 & gtot_pescado>0
replace alternativa=3 if pescado2>=0.75 & gtot_pescado>0
replace alternativa=4 if marisco1>=0.75 & gtot_pescado>0
replace alternativa=5 if alternativa==.
by NUMERO: keep if _n==1

table alternativa
//collect export "C:\Users\Usuario\Desktop\TFG\Tablas\todasalternativa.xlsx", as(xlsx) sheet(Sheet1) cell(A1) replace
tab alternativa

//Apartado B

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

table ( ESTUDIOSSP ) ( hombresp ) (), nototals statistic(mean alternativa)
//collect export "C:\Users\Usuario\Desktop\TFG\Tablas\alternativa1.xlsx", as(xlsx) sheet(Sheet1) cell(A1) replace
table ( CCAA ) ( hombresp ) (), nototals statistic(mean alternativa)
//collect export "C:\Users\Usuario\Desktop\TFG\Tablas\alternativa2.xlsx", as(xlsx) sheet(Sheet1) cell(A1) replace
table ( consumo_CARNE ) ( hombresp ) (), nototals statistic(mean alternativa)
//collect export "C:\Users\Usuario\Desktop\TFG\Tablas\alternativa3.xlsx", as(xlsx) sheet(Sheet1) cell(A1) replace
//Apartado C

stepwise, pr(0.1): mlogit alternativa renta EDADSP c.EDADSP#c.EDADSP hombresp i.ESTUDIOSSP i.CCAA diaria0-diaria3 i.consumo_CARNE, base(1) nolog
//outreg2 using mlogit1.xls, replace ctitle(MLogit) dec(3)
//Apartado D

test [2]renta=[3]renta
test [3]renta=[4]renta
test [2]renta=[4]renta

test [2]EDADSP=[3]EDADSP
test [3]EDADSP=[4]EDADSP
test [2]EDADSP=[4]EDADSP

//Apartado E

qui mlogit alternativa renta EDADSP c.EDADSP#c.EDADSP hombresp diaria0-diaria3 i.consumo_CARNE, base(1) nolog

mlogit, rrr

//Apartado F

qui mlogit alternativa renta EDADSP c.EDADSP#c.EDADSP hombresp i.ESTUDIOSSP i.CCAA diaria0-diaria3 i.consumo_CARNE, base(1) nolog
margins, dydx(renta EDADSP hombresp i.ESTUDIOSSP i.CCAA diaria0-diaria3 i.consumo_CARNE) post 
//outreg2 using elasticdad2.xls, replace ctitle(dydx) dec(3)

//Apartado G

qui mlogit alternativa renta EDADSP c.EDADSP#c.EDADSP hombresp diaria0-diaria3 i.consumo_CARNE, base(1) nolog
margins, dydx(renta) at(renta=(0.1(0.2)2.5))
marginsplot
marginsplot, noci

//Apartado H 

qui mlogit alternativa renta hombresp, base(1) nolog

predict p1 p2 p3 p4 p5, p

gen alt1=(alternativa==1)
gen alt2=(alternativa==2)
gen alt3=(alternativa==3)
gen alt4=(alternativa==4)
gen alt5=(alternativa==5)

sum alt1 p1 alt2 p2 alt3 p3 alt4 p4 alt5 p5


qui mlogit alternativa renta hombresp, base(1) nolog 
margins

sort renta
line p2 renta if hombresp ==1 || line p2 renta if hombresp==0, legend(order(1 "male" 2 "female")) ytitle(P(PESCADOS FRESCOS O REFRIGERADOS))
line p3 renta if hombresp ==1 || line p3 renta if hombresp==0, legend(order(1 "male" 2 "female")) ytitle(P(PESCADOS CONGELADOS))
line p4 renta if hombresp ==1 || line p4 renta if hombresp==0, legend(order(1 "male" 2 "female")) ytitle(P(MARISCOS FRESCOS O REFRIGERADOS))

//Apartado I

qui mlogit alternativa renta EDADSP c.EDADSP#c.EDADSP hombresp diaria0-diaria3 i.consumo_CARNE, base(1) nolog

predict p11 p22 p33 p44 p55,p

gen EDADSP2=EDADSP

replace EDADSP=EDADSP+10 

predict p11new p22new p33new p44new p55new,p

sum p11* p22* p33* p44* p55*

gen difp1=p11new-p11
gen difp2=p22new-p22
gen difp3=p33new-p33
gen difp4=p44new-p44
gen difp5=p55new-p55

tabstat difp1 difp2 difp3 difp4 difp5, s(mean)
