
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name hdmi495 -dir "C:/Users/Ying Yu/Desktop/SelectIO/hdmi495/planAhead_run_3" -part xc6slx25ftg256-3
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "dvi_demo.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {DRAM16XN.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {serdes_1_to_5_diff_data.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {phsaligner.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {chnlbond.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {decode.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {synchro.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {serdes_n_to_1.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {dvi_decoder.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {convert_30to15_fifo.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {top.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set_property top dvi_demo $srcset
add_files [list {dvi_demo.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx25ftg256-3
