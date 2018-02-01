
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name hdmi495 -dir "C:/Users/Ying Yu/Desktop/SelectIO/hdmi495/planAhead_run_2" -part xc6slx25ftg256-3
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/Users/Ying Yu/Desktop/SelectIO/hdmi495/dvi_demo.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Users/Ying Yu/Desktop/SelectIO/hdmi495} {ipcore_dir} }
add_files [list {ipcore_dir/ddsc.ncf}] -fileset [get_property constrset [current_run]]
set_param project.pinAheadLayout  yes
set_property target_constrs_file "dvi_demo.ucf" [current_fileset -constrset]
add_files [list {dvi_demo.ucf}] -fileset [get_property constrset [current_run]]
link_design
