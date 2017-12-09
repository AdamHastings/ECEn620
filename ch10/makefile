VERILOG_FILES = opcodes_include.v Control_Unit.v Clock_Unit.v mux5_1.v mux3_1.v Alu_RISC.v Register_Unit.v Processing_Unit.v RISC_SPM.v Transaction_pkg.sv Generator_pkg.sv Agent_pkg.sv Driver_pkg.sv CovPort_pkg.sv risc_spm_iface.sv Environment_pkg.sv test.sv top.sv
# VHDL_FILES = package_timing.vhd package_utility.vhd async.vhd
TOPLEVEL = top

halp:
	@echo "Make targets:"
	@echo "> make vcs          	# Compile and run with VCS"
	@echo "> make questa_gui   	# Compile and run with Questa in GUI mode"
	@echo "> make questa_batch 	# Compile and run with Questa in batch mode"
	@echo "> make clean        	# Clean up all intermediate files"
	@echo "> make tar          	# Create a tar file for the current directory"
	@echo "> make help         	# This message"

#############################################################################
# VCS section
# VCS_FLAGS = -sverilog -debug  -l comp.log
# vcs: simv
# 	./simv -l sim.log

# simv:   ${VERILOG_FILES} ${VHDL_FILES} clean
# 	mkdir work
# 	vhdlan ${VHDL_FILES}
# 	vlogan ${VCS_FLAGS} ${VERILOG_FILES}
# 	vcs ${TOPLEVEL}

#############################################################################
# Questa section
questa_gui: 
	vlib work
	vmap work work
	# vcom ${VHDL_FILES}
	vlog -sv ${VERILOG_FILES}
	vsim -novopt -cvg63 -t ps -do "view wave;do wave.do;run -all" ${TOPLEVEL}

questa_batch: ${VHDL_FILES} ${VERILOG_FILES} clean
	vlib work
	vmap work work
	# vcom ${VHDL_FILES}
	vlog -sv ${VERILOG_FILES}
	vsim -c -novopt -cvg63 -t ps -do "run -all" ${TOPLEVEL}

#############################################################################
# Housekeeping

clean:
	@# VCS Stuff
	@rm -rf simv* csrc* *.log *.key vcdplus.vpd *.log .vcsmx_rebuild vc_hdrs.h .vlogan*
	@# Questa stuff
	@rm -rf work transcript vsim.wlf
	@# Unix stuff
	@rm -rf  *~ core.*