GHDL=ghdl
GHDLFLAGS=--mb-comments
WORK=DUMMY_PLUG

TEST_BENCH = mt19937ar_test_bench \
             $(END_LIST)

all: $(TEST_BENCH)

clean:
	rm -f *.o *.cf $(TEST_BENCH)

mt19937ar_test_bench: mt19937ar.o mt19937ar_test_bench.o 
	 $(GHDL) -e $(GHDLFLAGS) $@
	-$(GHDL) -r $(GHDLRUNFLAGS) $@

mt19937ar_test_bench.o: ../../../src/test/vhdl/core/mt19937ar_test_bench.vhd
	$(GHDL) -a $(GHDLFLAGS) --work=work $<

mt19937ar.o:  ../../../src/main/vhdl/core/mt19937ar.vhd
	$(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

