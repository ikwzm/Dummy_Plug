#
# create_project.tcl  Tcl script for creating project
#
set project_directory       [file dirname [info script]]
set project_name            "reader_test_1"
set device_parts            "xc7z010clg400-1"
#
# Create project
#
create_project -force $project_name $project_directory
#
# Set project properties
#
set_property "part"               $device_parts    [get_projects $project_name]
set_property "default_lib"        "xil_defaultlib" [get_projects $project_name]
set_property "simulator_language" "Mixed"          [get_projects $project_name]
set_property "target_language"    "VHDL"           [get_projects $project_name]
#
# Create fileset "sources_1"
#
if {[string equal [get_filesets -quiet sources_1] ""]} {
    create_fileset -srcset sources_1
}
#
# Create fileset "constrs_1"
#
if {[string equal [get_filesets -quiet constrs_1] ""]} {
    create_fileset -constrset constrs_1
}
#
# Create fileset "sim_1"
#
if {[string equal [get_filesets -quiet sim_1] ""]} {
    create_fileset -simset sim_1
}
#
# Import source files
#
set dummy_plug_src_list [list]
lappend dummy_plug_src_list {../../../src/main/vhdl/core/util.vhd}
lappend dummy_plug_src_list {../../../src/main/vhdl/core/vocal.vhd}
lappend dummy_plug_src_list {../../../src/main/vhdl/core/reader.vhd}
lappend dummy_plug_src_list {../../../src/main/vhdl/core/sync.vhd}
lappend dummy_plug_src_list {../../../src/main/vhdl/core/core.vhd}
add_files -fileset sim_1 -norecurse $dummy_plug_src_list
set_property library Dummy_Plug [get_files $dummy_plug_src_list]
set work_src_list [list]
lappend work_src_list       {../../../src/test/vhdl/core/reader_test_1.vhd}
add_files -fileset sim_1 -norecurse $work_src_list
set_property "top"     "DUMMY_PLUG_READER_TEST_1"  [get_filesets sim_1]
set scenario_file [file join $project_directory ".." ".." ".." "src" "test" "scenarios" "core" "reader_test_1.snr" ]
set_property "generic" "TEST_FILE=$scenario_file" [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {all} -objects [get_filesets sim_1]

update_compile_order -fileset sim_1
#
# Close project
#
close_project
