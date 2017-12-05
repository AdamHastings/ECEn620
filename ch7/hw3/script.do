restart -f
add wave -position insertpoint  \
sim:/top/clk
add wave -position insertpoint  \
sim:/top/if0/rst
add wave -position insertpoint  \
sim:/top/if0/write
add wave -position insertpoint  \
sim:/top/if0/mem_word
add wave -position insertpoint  \
sim:/top/if0/address
add wave -position insertpoint  \
sim:/top/if0/Bus_1
run 0
add wave -position insertpoint  \
sim:/top/t0/env.drv.ASCII_op
add wave -position insertpoint  \
sim:/top/rspm0/Processor/R0_out \
sim:/top/rspm0/Processor/R1_out \
sim:/top/rspm0/Processor/R2_out \
sim:/top/rspm0/Processor/R3_out
run -all