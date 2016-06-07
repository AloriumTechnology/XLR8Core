# Copyright (c) 2016 Alorim Technology.  All right reserved.
#
# Quartus settings for XLR8 project
#  http://www.aloriumtech.com/xlr8
#  https://github.com/AloriumTechnology
#
# This isn't the complete list of all settings needed for the
#  xlr8 project, it is just the settings that are common for
#  most/all configurations. This file should be sourced by a
#  higher level qsf file that has the rest of the settings needed

if {![info exists COREDIR]} {set COREDIR ../../../XLR8Core/extras}

set_global_assignment -name SEARCH_PATH $COREDIR/rtl
set_global_assignment -name QIP_FILE $COREDIR/rtl/ip/int_osc/int_osc/synthesis/int_osc.qip
set_global_assignment -name SIP_FILE $COREDIR/rtl/ip/int_osc/int_osc/simulation/int_osc.sip
set_global_assignment -name QIP_FILE $COREDIR/rtl/ip/pll16/pll16.qip
set_global_assignment -name QIP_FILE $COREDIR/rtl/ip/ram2p16384x16/ram2p16384x16.qip
set_global_assignment -name SDC_FILE $COREDIR/quartus/altera_modular_adc_control.sdc
set_global_assignment -name SDC_FILE $COREDIR/quartus/altera_onchip_flash.sdc
# End of xlr8_top_core.tcl
