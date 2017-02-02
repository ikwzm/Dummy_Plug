NVC=nvc
SRC_MAIN_VHDL_PATH=../../../src/main/vhdl
SRC_TEST_VHDL_PATH=../../../src/test/vhdl
SRC_TEST_SCENARIO_PATH=../../../src/test/scenarios

TEST_BENCH = dummy_plug_axi4_test_1_1        \
             dummy_plug_axi4_test_1_2        \
             dummy_plug_axi4_test_1_3        \
             dummy_plug_axi4_test_1_4        \
             $(END_LIST)

all: $(TEST_BENCH)

clean:
	rm -r work

dummy_plug_axi4_test_1_1 : work/_WORK.DUMMY_PLUG_AXI4_TEST_1_1.final.so $(SRC_TEST_SCENARIO_PATH)/axi4/axi4_test_1_1.snr
	-$(NVC) -L ../lib/ -r DUMMY_PLUG_AXI4_TEST_1_1

dummy_plug_axi4_test_1_2 : work/_WORK.DUMMY_PLUG_AXI4_TEST_1_2.final.so $(SRC_TEST_SCENARIO_PATH)/axi4/axi4_test_1_2.snr
	-$(NVC) -L ../lib/ -r DUMMY_PLUG_AXI4_TEST_1_2

dummy_plug_axi4_test_1_3 : work/_WORK.DUMMY_PLUG_AXI4_TEST_1_3.final.so $(SRC_TEST_SCENARIO_PATH)/axi4/axi4_test_1_3.snr
	-$(NVC) -L ../lib/ -r DUMMY_PLUG_AXI4_TEST_1_3

dummy_plug_axi4_test_1_4 : work/_WORK.DUMMY_PLUG_AXI4_TEST_1_4.final.so $(SRC_TEST_SCENARIO_PATH)/axi4/axi4_test_1_4.snr
	-$(NVC) -L ../lib/ -r DUMMY_PLUG_AXI4_TEST_1_4

work/_WORK.DUMMY_PLUG_AXI4_TEST_1_1.final.so : work/WORK.DUMMY_PLUG_AXI4_TEST_1_1 work/WORK.DUMMY_PLUG_AXI4_TEST_1
	$(NVC) -L ../lib/ -e DUMMY_PLUG_AXI4_TEST_1_1

work/_WORK.DUMMY_PLUG_AXI4_TEST_1_2.final.so : work/WORK.DUMMY_PLUG_AXI4_TEST_1_2 work/WORK.DUMMY_PLUG_AXI4_TEST_1
	$(NVC) -L ../lib/ -e DUMMY_PLUG_AXI4_TEST_1_2

work/_WORK.DUMMY_PLUG_AXI4_TEST_1_3.final.so : work/WORK.DUMMY_PLUG_AXI4_TEST_1_3 work/WORK.DUMMY_PLUG_AXI4_TEST_1
	$(NVC) -L ../lib/ -e DUMMY_PLUG_AXI4_TEST_1_3

work/_WORK.DUMMY_PLUG_AXI4_TEST_1_4.final.so : work/WORK.DUMMY_PLUG_AXI4_TEST_1_4 work/WORK.DUMMY_PLUG_AXI4_TEST_1
	$(NVC) -L ../lib/ -e DUMMY_PLUG_AXI4_TEST_1_4

analyze: work/WORK.DUMMY_PLUG_AXI4_TEST_1   \
         work/WORK.DUMMY_PLUG_AXI4_TEST_1_1 \
         work/WORK.DUMMY_PLUG_AXI4_TEST_1_2 \
         work/WORK.DUMMY_PLUG_AXI4_TEST_1_3 \
         work/WORK.DUMMY_PLUG_AXI4_TEST_1_4 \
         work/WORK.DUMMY_PLUG_AXI4_STREAM_TEST_1_1

work/WORK.DUMMY_PLUG_READER_TEST_1 : ../../../src/test/vhdl/core/reader_test_1.vhd
	$(NVC) -L ../lib/ -a $<

work/WORK.DUMMY_PLUG_AXI4_TEST_1   : ../../../src/test/vhdl/axi4/axi4_test_1.vhd
	$(NVC) -L ../lib/ -a $<

work/WORK.DUMMY_PLUG_AXI4_TEST_1_1 : ../../../src/test/vhdl/axi4/axi4_test_1_1.vhd
	$(NVC) -L ../lib/ -a $<

work/WORK.DUMMY_PLUG_AXI4_TEST_1_2 : ../../../src/test/vhdl/axi4/axi4_test_1_2.vhd
	$(NVC) -L ../lib/ -a $<

work/WORK.DUMMY_PLUG_AXI4_TEST_1_3 : ../../../src/test/vhdl/axi4/axi4_test_1_3.vhd
	$(NVC) -L ../lib/ -a $<

work/WORK.DUMMY_PLUG_AXI4_TEST_1_4 : ../../../src/test/vhdl/axi4/axi4_test_1_4.vhd
	$(NVC) -L ../lib/ -a $<

work/WORK.DUMMY_PLUG_AXI4_STREAM_TEST_1   : ../../../src/test/vhdl/axi4/axi4_test_1.vhd
	$(NVC) -L ../lib/ -a $<

work/WORK.DUMMY_PLUG_AXI4_STREAM_TEST_1_1 : ../../../src/test/vhdl/axi4/axi4_test_1_3.vhd
	$(NVC) -L ../lib/ -a $<

