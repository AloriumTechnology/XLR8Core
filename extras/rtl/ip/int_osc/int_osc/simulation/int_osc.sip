set_global_assignment -entity "int_osc" -library "lib_int_osc" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "int_osc" -library "lib_int_osc" -name IP_TOOL_VERSION "17.1"
set_global_assignment -entity "int_osc" -library "lib_int_osc" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_int_osc" -name SPD_FILE [file join $::quartus(sip_path) "../int_osc.spd"]
set_global_assignment -library "lib_int_osc" -name MISC_FILE [file join $::quartus(sip_path) "../../int_osc.qsys"]

set_global_assignment -library "lib_int_osc" -name MISC_FILE [file join $::quartus(sip_path) "int_osc.v"]
set_global_assignment -library "lib_int_osc" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_int_osc.v"]
set_global_assignment -library "lib_int_osc" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_int_osc.sdc"]
