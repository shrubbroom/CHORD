TESTBENCH = tb
RESULT    = tb
V_FLAG    = -g2005-sv

#------------------------------------------------------------------------------
# You should't be changing what is below
#------------------------------------------------------------------------------
all: simulate

simulate:
	iverilog -o $(TESTBENCH).vvp $(TESTBENCH).v
	vvp $(TESTBENCH).vvp

gtkwave:
	gtkwave $(RESULT).vcd &

clean:
	rm -rf *.txt *.vcd *.vvp
