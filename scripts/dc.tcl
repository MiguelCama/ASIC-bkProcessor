# ICC2 Testing 
# Design : bkProcessor

# Search Path and Logic Library Setup
# Search Path and Logic Library Setup
set_host_options -max_cores     8
set_app_var search_path "$search_path ./rtl ./libs ./ref"
set_app_var target_library "[glob ./ref/DBs/*.db]"
set_app_var link_library "* $target_library"

#set_app_var current_path "../"
#define_design_lib WORK -path ./
#set_app_var search_path "$search_path ./ref/DBs"
#set_app_var target_library [glob ./ref/DBs/*.db]  
#set_app_var link_library $target


# RTL Reading and Link
analyze -format sverilog { bkAlu.v bkRegBank.v bkMux2.v bkMux4.v bkMemory.v bkController.v bkProcessor.v}
elaborate bkProcessor

# Timing
set clk_val 50
create_clock -period $clk_val [get_port clk]
set_clock_uncertainty -setup [expr {$clk_val*0.1}] clk
set_clock_transition -max [expr {$clk_val*0.20}] clk
set_clock_latency -source -max [expr {$clk_val*0.05}] clk
set_input_delay -max [expr {$clk_val*0.4}] -clock clk [remove_from_collection [all_inputs] clk]
set_output_delay -max [expr {$clk_val*0.5}] -clock clk [all_outputs]
set_load -max 1 [all_outputs]
set_input_transition -min [expr {$clk_val*0.01}] [all_inputs]
set_input_transition -max [expr {$clk_val*0.10}] [all_inputs]

# Pre-compile Reports

report_clock -skew > reports/check_timing.rpt
report_timing > reports/report_clock.rpt
check_timing > reports/check_timing.rpt
check_design > reports/check_design.rpt

# Compile/Synthesis

compile_ultra 

# Post-compile Reports

report_qor  > reports/report_qor.rpt
report_constraints -all_violators > reports/report_constraints.rpt
report_timing > reports/report_timing.rpt
report_cells  > reports/report_cells.rpt

# Save Design


write_file -format verilog -hier -out ./projectMiguel.v
write_sdc ./projectMiguel.sdc
write_parasitics -output ./projectMiguel.spef


# Exit
# Execute ---- >dc_shell -f scripts/dc.tcl | tee -i logs/dc.log