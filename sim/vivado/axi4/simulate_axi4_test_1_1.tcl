set project_directory [file dirname [info script]]

source       [file join $project_directory "create_axi4_test_1_1.tcl"]

open_project [file join $project_directory $project_name]

launch_simulation

close_project

