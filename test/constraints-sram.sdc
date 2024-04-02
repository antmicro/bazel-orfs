puts "===== TEST fetching path to this (constraints-sram.sdc) script ====="
puts "info script gets resolved into a relative '.' path (sourcing tested below)"
set info_script [ info script ]
puts "info_script: $info_script"
set normalize [ file normalize $info_script ]
puts "info_script_normalize: $normalize"
set dirname [ file dirname $normalize ]
puts "info_script_dirname: $dirname"

puts "info nameofexecutable points to the openroad binary"
set info_nameofexecutable [ info nameofexecutable ]
puts "info_nameofexecutable: $info_nameofexecutable"
set normalize [ file normalize $info_nameofexecutable ]
puts "info_nameofexecutable_normalize: $normalize"
set dirname [ file dirname $normalize ]
puts "info_nameofexecutable_dirname: $dirname"

puts "argv0 points to the openroad binary"
set argv $::argv0
puts "argv: $argv"
set argv_normalize [ file normalize $argv0 ]
puts "argv_normalize: $argv_normalize"
set argv_dirname [ file dirname $argv_normalize ]
puts "argv_dirname: $argv_dirname"

puts "frame 0 does not have 'file' key to fetch the script path:"
set stacktrace [ info frame 0]
puts "stacktrace frame0: $stacktrace"
set stacktrace [ info frame 1]
puts "stacktrace frame1: $stacktrace"
set stacktrace [ info frame 2]
puts "stacktrace frame2: $stacktrace"

#set stacktrace [ dict get [ info frame 0 ] file ]
#puts "stacktrace: $stacktrace"
#set stacktrace_normalize [ file normalize $stacktrace ]
#puts "stacktrace_normalize: $stacktrace_normalize"
#set stacktrace_dirname [ file dirname $stacktrace_normalize ]
#puts "stacktrace_dirname: $stacktrace_dirname"

# We expect util.tcl in the same directory as this file
puts "Use the same env var that is used for passing path to constraints-sram.sdc to openroad to find the path to util.tcl"
puts "Path to SDC file: $::env(SDC_FILE)"
set script_path [ file dirname $::env(SDC_FILE) ]
puts "Valid util.tcl path: $script_path/util.tcl"
puts "try: 'source $script_path/util.tcl'"
source $script_path/util.tcl
puts "Sourced successfully"

puts "util.tcl is placed in the same directory as currently executed script but relative path in 'source' won't work"
puts "try: 'source util.tcl' (expect error)"
source util.tcl
puts "===== END TEST ====="

# Set the clock name and period
set clk_period 400 

# Get the list of clock ports
set clk_ports [match_pins .*_clk]
set clk_name [lindex $clk_ports 0]

# Create the clock for each clock port
foreach clk_port_name $clk_ports {
    set clk_port [get_ports $clk_port_name]
    create_clock -name $clk_port_name -period $clk_period $clk_port
}

set clk_io_pct 0.1

# Set input and output delays for all inputs and outputs
set non_clock_inputs [lsearch -inline -all -not -exact [all_inputs] $clk_ports]
set_input_delay  [expr $clk_period * $clk_io_pct] -clock $clk_name $non_clock_inputs 
set_output_delay [expr $clk_period * $clk_io_pct] -clock $clk_name [all_outputs]
