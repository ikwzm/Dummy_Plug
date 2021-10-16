NVC=nvc
MAKE=make

SRC_MAIN_VHDL_PATH=../../../src/main/vhdl
SRC_TEST_VHDL_PATH=../../../src/test/vhdl
SRC_TEST_SCENARIO_PATH=../../../src/test/scenarios

TEST_BENCH = dummy_plug_reader_test_1        \
             dummy_plug_axi4_test_1_1        \
             dummy_plug_axi4_test_1_2        \
             dummy_plug_axi4_test_1_3        \
             dummy_plug_axi4_test_1_4        \
             dummy_plug_axi4_stream_test_1_1 \
             $(END_LIST)

LIB_PATH        = ../lib
LIB_DUMMY_PLUG  = $(LIB_PATH)/dummy_plug/_NVC_LIB

all: $(TEST_BENCH)

clean:
	$(MAKE) -C ../lib clean
	rm -r work

dummy_plug_reader_test_1 : work/WORK.DUMMY_PLUG_READER_TEST_1.elab $(SRC_TEST_SCENARIO_PATH)/core/reader_test_1.snr
	-$(NVC) -L ../lib/ -r DUMMY_PLUG_READER_TEST_1

dummy_plug_axi4_test_1_1 : work/WORK.DUMMY_PLUG_AXI4_TEST_1_1.elab $(SRC_TEST_SCENARIO_PATH)/axi4/axi4_test_1_1.snr
	-$(NVC) -L ../lib/ -r DUMMY_PLUG_AXI4_TEST_1_1

dummy_plug_axi4_test_1_2 : work/WORK.DUMMY_PLUG_AXI4_TEST_1_2.elab $(SRC_TEST_SCENARIO_PATH)/axi4/axi4_test_1_2.snr
	-$(NVC) -L ../lib/ -r DUMMY_PLUG_AXI4_TEST_1_2

dummy_plug_axi4_test_1_3 : work/WORK.DUMMY_PLUG_AXI4_TEST_1_3.elab $(SRC_TEST_SCENARIO_PATH)/axi4/axi4_test_1_3.snr
	-$(NVC) -L ../lib/ -r DUMMY_PLUG_AXI4_TEST_1_3

dummy_plug_axi4_test_1_4 : work/WORK.DUMMY_PLUG_AXI4_TEST_1_4.elab $(SRC_TEST_SCENARIO_PATH)/axi4/axi4_test_1_4.snr
	-$(NVC) -L ../lib/ -r DUMMY_PLUG_AXI4_TEST_1_4

dummy_plug_axi4_stream_test_1_1 : work/WORK.DUMMY_PLUG_AXI4_STREAM_TEST_1_1.elab $(SRC_TEST_SCENARIO_PATH)/axi4/axi4_stream_test_1_1.snr
	-$(NVC) -L ../lib/ -r DUMMY_PLUG_AXI4_STREAM_TEST_1_1

work/WORK.DUMMY_PLUG_READER_TEST_1.elab : work/WORK.DUMMY_PLUG_READER_TEST_1
	$(NVC) -L ../lib/ -e DUMMY_PLUG_READER_TEST_1

work/WORK.DUMMY_PLUG_AXI4_TEST_1_1.elab : work/WORK.DUMMY_PLUG_AXI4_TEST_1_1 work/WORK.DUMMY_PLUG_AXI4_TEST_1
	$(NVC) -L ../lib/ -e DUMMY_PLUG_AXI4_TEST_1_1

work/WORK.DUMMY_PLUG_AXI4_TEST_1_2.elab : work/WORK.DUMMY_PLUG_AXI4_TEST_1_2 work/WORK.DUMMY_PLUG_AXI4_TEST_1
	$(NVC) -L ../lib/ -e DUMMY_PLUG_AXI4_TEST_1_2

work/WORK.DUMMY_PLUG_AXI4_TEST_1_3.elab : work/WORK.DUMMY_PLUG_AXI4_TEST_1_3 work/WORK.DUMMY_PLUG_AXI4_TEST_1
	$(NVC) -L ../lib/ -e DUMMY_PLUG_AXI4_TEST_1_3

work/WORK.DUMMY_PLUG_AXI4_TEST_1_4.elab : work/WORK.DUMMY_PLUG_AXI4_TEST_1_4 work/WORK.DUMMY_PLUG_AXI4_TEST_1
	$(NVC) -L ../lib/ -e DUMMY_PLUG_AXI4_TEST_1_4

work/WORK.DUMMY_PLUG_AXI4_STREAM_TEST_1_1.elab : work/WORK.DUMMY_PLUG_AXI4_STREAM_TEST_1_1 work/WORK.DUMMY_PLUG_AXI4_STREAM_TEST_1
	$(NVC) -L ../lib/ -e DUMMY_PLUG_AXI4_STREAM_TEST_1_1

analyze: work/WORK.DUMMY_PLUG_AXI4_TEST_1          \
         work/WORK.DUMMY_PLUG_AXI4_TEST_1_1        \
         work/WORK.DUMMY_PLUG_AXI4_TEST_1_2        \
         work/WORK.DUMMY_PLUG_AXI4_TEST_1_3        \
         work/WORK.DUMMY_PLUG_AXI4_TEST_1_4        \
         work/WORK.DUMMY_PLUG_AXI4_STREAM_TEST_1   \
         work/WORK.DUMMY_PLUG_AXI4_STREAM_TEST_1_1

work/WORK.DUMMY_PLUG_READER_TEST_1 : $(SRC_TEST_VHDL_PATH)/core/reader_test_1.vhd                $(LIB_DUMMY_PLUG)
	$(NVC) -L ../lib/ -a $<

work/WORK.DUMMY_PLUG_AXI4_TEST_1   : $(SRC_TEST_VHDL_PATH)/axi4/axi4_test_1.vhd                  $(LIB_DUMMY_PLUG)
	$(NVC) -L ../lib/ -a $<

work/WORK.DUMMY_PLUG_AXI4_TEST_1_1 : $(SRC_TEST_VHDL_PATH)/axi4/axi4_test_1_1.vhd                $(LIB_DUMMY_PLUG)
	$(NVC) -L ../lib/ -a $<

work/WORK.DUMMY_PLUG_AXI4_TEST_1_2 : $(SRC_TEST_VHDL_PATH)/axi4/axi4_test_1_2.vhd                $(LIB_DUMMY_PLUG)
	$(NVC) -L ../lib/ -a $<

work/WORK.DUMMY_PLUG_AXI4_TEST_1_3 : $(SRC_TEST_VHDL_PATH)/axi4/axi4_test_1_3.vhd                $(LIB_DUMMY_PLUG)
	$(NVC) -L ../lib/ -a $<

work/WORK.DUMMY_PLUG_AXI4_TEST_1_4 : $(SRC_TEST_VHDL_PATH)/axi4/axi4_test_1_4.vhd                $(LIB_DUMMY_PLUG)
	$(NVC) -L ../lib/ -a $<

work/WORK.DUMMY_PLUG_AXI4_STREAM_TEST_1   : $(SRC_TEST_VHDL_PATH)/axi4/axi4_stream_test_1.vhd    $(LIB_DUMMY_PLUG)
	$(NVC) -L ../lib/ -a $<

work/WORK.DUMMY_PLUG_AXI4_STREAM_TEST_1_1 : $(SRC_TEST_VHDL_PATH)/axi4/axi4_stream_test_1_1.vhd  $(LIB_DUMMY_PLUG)
	$(NVC) -L ../lib/ -a $<

$(LIB_DUMMY_PLUG):
	$(MAKE) -C $(LIB_PATH) all

