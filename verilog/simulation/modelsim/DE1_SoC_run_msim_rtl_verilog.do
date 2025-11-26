transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/stlp/Documents/quartus\ project\ template {C:/Users/stlp/Documents/quartus project template/de1_soc_golden_top.v}

