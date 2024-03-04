# DFT Testing 
# Design : bkProcessor 

# Search Path and Logic Library Setup
set_app_var search_path "$search_path ./rtl ./libs"
#set_app_var target_library "sky130_fd_sc_hd__ff_100C_1v95.db sky130_fd_sc_hd__ss_100C_1v40.db"
#set_app_var target_library "saed32rvt_pg_ss0.db"  
#set_app_var target_library [glob ./lib/low/*_ss *.db]
set_app_var target_library [glob ./libs/*_ss*.db]
set_app_var link_library "* $target_library"

# RTL Reading and Link
analyze -format sverilog { bkAlu.v bkRegBank.v bkMux2.v bkMux4.v bkMemory.v bkController.v bkProcessor.v}
elaborate bkProcessor
#analyze -format sverilog {alu.v}
#elaborate alu;
if{ [link] == 0 } {
	exit ;
}
link

# Constrains Setup
set clk_val 20
create_clock -period $clk_val  [get_ports clk] -name clk
#create_clock -period $clk_val -name clk
set_clock_uncertainty -setup [expr {$clk_val*0.1}]  [get_clocks clk]
set_clock_transition -max [expr {$clk_val*0.2}] [get_clocks clk]
set_clock_latency -source [expr {$clk_val*0.05}] [get_clocks clk]
set_output_delay -max [expr {$clk_val*0.5}] -clock clk [all_outputs]
set_load -max 1 [all_outputs]

set_input_transition -min [expr {$clk_val*0.01}] [all_inputs]
set_input_transition -max [expr {$clk_val*0.1}] [all_inputs]

# Pre-compile Reports

report_clock -skew > reports1/check_timing.rpt
report_timing > reports1/report_clock.rpt
check_timing > reports1/check_timing.rpt
check_design > reports1/check_design.rpt

# Compile/Synthesis

compile_ultra -no_autoungroup

# Post-compile Reports

report_qor  > reports1/report_qor.rpt
report_constraints -all_violators > reports1/report_constraints.rpt
report_timing > reports1/report_timing.rpt

# Save Design

write -format  ddc  -hier -out mappedRawbk.ddc
write -format  verilog -hier -out mappedRawbk.v

#LAB 2 ----------------------------------------------------------
#2.a Clock gating -----------------------------------------------
compile_ultra -no_autoungroup -gate_clock

# Save clock-gated design reports 
report_qor  > report1/reportCG_qor.rpt
report_constraints -all_violators > reports1/reportCG_constraints.rpt
report_timing > reports1/reportCG_timing.rpt

write -format  ddc  -hier -out mappedCGbk.ddc
write -format  verilog -hier -out mappedCGbk.v


#2.b Optimize registers  ------------------------------------------

optimize_registers

# Save optimized-registers design reports 
report_qor  > reports1/reportOR_qor.rpt
report_constraints -all_violators > reports1/reportOR_constraints.rpt
report_timing > reports1/reportOR_timing.rpt

write -format  ddc  -hier -out mappedORbk.ddc
write -format  verilog -hier -out mappedORbk.v


#2.c Incremental compile  -----------------------------------------

compile_ultra -no_autoungroup -gate_clock -incremental

# Save incremental-compiled design reports 
report_qor  > reports1/reportIC_qor.rpt
report_constraints -all_violators > reports1/reportIC_constraints.rpt
report_timing > reports1/reportIC_timing.rpt

write -format  ddc  -hier -out mappedICbk.ddc
write -format  verilog -hier -out mappedICbk.v

#2.d Area optimization  -----------------------------------------

optimize_netlist -area

# Save incremental-compiled design reports 
report_qor  > reports1/reportAO_qor.rpt
report_constraints -all_violators > reports1/reportAO_constraints.rpt
report_timing > reports1/reportAO_timing.rpt

write -format  ddc  -hier -out mappedAO.ddc
write -format  verilog -hier -out mappedAO.v


#2.e Change Names  -----------------------------------------

change_names -rule verilog -hier

# Save incremental-compiled design reports 
report_qor  > reports1/reportCN_qor.rpt
report_constraints -all_violators > reports1/reportCN_constraints.rpt
report_timing > reports1/reportCN_timing.rpt

write -format  ddc  -hier -out mappedCN.ddc
write -format  verilog -hier -out mappedCN.v

# Exit dc_shell -f dc1.tcl | & tee -i dc1.log
#/evprj030/projects/SAED-lib/SAED32_EDK/lib/stdcell_hvt/db_nldm/
#/evprj030/projects/SAED-lib/SAED32_EDK/lib/stdcell_lvt/db_nldm/
#/evprj030/projects/SAED-lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/