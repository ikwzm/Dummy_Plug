
GHDL=ghdl
GHDLFLAGS=--mb-comments
WORK=dummy_plug
SRC_MAIN_VHDL_PATH=../../../src/main/vhdl
SRC_TEST_VHDL_PATH=../../../src/test/vhdl

TEST_BENCH = dummy_plug_reader_test_1        \
             dummy_plug_axi4_test_1_1        \
             dummy_plug_axi4_test_1_2        \
             dummy_plug_axi4_test_1_3        \
             dummy_plug_axi4_test_1_4        \
             dummy_plug_axi4_test_1_5        \
             dummy_plug_axi4_stream_test_1_1 \
             dummy_plug_axi4_memory_test_1   \
             dummy_plug_axi4_memory_test_2   \
             $(END_LIST)

all: $(TEST_BENCH)

clean:
	rm -f *.o *.cf $(TEST_BENCH)

%.o : %.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

$(TEST_BENCH) : $(addsuffix .o,$(TEST_BENCH))
	 $(GHDL) -e $(GHDLFLAGS) --work=work $@
	 $(GHDL) -r $(GHDLFLAGS) --work=work $@


DUMMY_PLUG_CORE_SRC_PATH = $(SRC_MAIN_VHDL_PATH)/core
DUMMY_PLUG_CORE_PACKAGE  = util.o reader.o sync.o vocal.o core.o
DUMMY_PLUG_CORE          = $(DUMMY_PLUG_CORE_PACKAGE) marchal.o

core.o                     : reader.o vocal.o sync.o util.o
marchal.o                  : reader.o vocal.o sync.o util.o core.o

util.o                     : $(DUMMY_PLUG_CORE_SRC_PATH)/util.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

vocal.o                    : $(DUMMY_PLUG_CORE_SRC_PATH)/vocal.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

reader.o                   : $(DUMMY_PLUG_CORE_SRC_PATH)/reader.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

sync.o                     : $(DUMMY_PLUG_CORE_SRC_PATH)/sync.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

core.o                     : $(DUMMY_PLUG_CORE_SRC_PATH)/core.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

marchal.o                  : $(DUMMY_PLUG_CORE_SRC_PATH)/marchal.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

DUMMY_PLUG_AXI4_SRC_PATH = $(SRC_MAIN_VHDL_PATH)/axi4
DUMMY_PLUG_AXI4_PACKAGE  = axi4_types.o axi4_models.o 
DUMMY_PLUG_AXI4          = $(DUMMY_PLUG_CORE)           \
                           $(DUMMY_PLUG_AXI4_PACKAGE)   \
                           axi4_master_player.o         \
                           axi4_slave_player.o          \
                           axi4_memory_player.o         \
                           axi4_stream_master_player.o  \
                           axi4_stream_slave_player.o   \
                           axi4_signal_printer.o        \
                           axi4_stream_signal_printer.o \
                           $(END_LIST)

axi4_core.o                    : axi4_types.o $(DUMMY_PLUG_CORE_PACKAGE)
axi4_models.o                  : axi4_types.o $(DUMMY_PLUG_CORE_PACKAGE)
axi4_signal_printer.o          : axi4_types.o $(DUMMY_PLUG_CORE_PACKAGE)
axi4_stream_signal_printer.o   : axi4_types.o $(DUMMY_PLUG_CORE_PACKAGE)
axi4_channel_player.o          : axi4_types.o axi4_core.o 
axi4_master_player.o           : axi4_types.o axi4_core.o axi4_channel_player.o
axi4_slave_player.o            : axi4_types.o axi4_core.o axi4_channel_player.o
axi4_stream_player.o           : axi4_types.o axi4_core.o
axi4_stream_master_player.o    : axi4_types.o axi4_core.o axi4_stream_player.o
axi4_stream_slave_player.o     : axi4_types.o axi4_core.o axi4_stream_player.o
axi4_memory_player.o           : axi4_types.o axi4_core.o

axi4_types.o                       : $(DUMMY_PLUG_AXI4_SRC_PATH)/axi4_types.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_core.o                        : $(DUMMY_PLUG_AXI4_SRC_PATH)/axi4_core.vhd   
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_models.o                      : $(DUMMY_PLUG_AXI4_SRC_PATH)/axi4_models.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_channel_player.o              : $(DUMMY_PLUG_AXI4_SRC_PATH)/axi4_channel_player.vhd 
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_master_player.o               : $(DUMMY_PLUG_AXI4_SRC_PATH)/axi4_master_player.vhd 
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_slave_player.o                : $(DUMMY_PLUG_AXI4_SRC_PATH)/axi4_slave_player.vhd  
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_memory_player.o               : $(DUMMY_PLUG_AXI4_SRC_PATH)/axi4_memory_player.vhd  
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_stream_player.o               : $(DUMMY_PLUG_AXI4_SRC_PATH)/axi4_stream_player.vhd 
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_stream_master_player.o        : $(DUMMY_PLUG_AXI4_SRC_PATH)/axi4_stream_master_player.vhd 
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_stream_slave_player.o         : $(DUMMY_PLUG_AXI4_SRC_PATH)/axi4_stream_slave_player.vhd 
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_signal_printer.o              : $(DUMMY_PLUG_AXI4_SRC_PATH)/axi4_signal_printer.vhd  
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_stream_signal_printer.o       : $(DUMMY_PLUG_AXI4_SRC_PATH)/axi4_stream_signal_printer.vhd  
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<


dummy_plug_reader_test_1.o         : $(SRC_TEST_VHDL_PATH)/core/reader_test_1.vhd $(DUMMY_PLUG_CORE)
	 $(GHDL) -a $(GHDLFLAGS) --work=work $<

dummy_plug_axi4_test_1.o           : $(SRC_TEST_VHDL_PATH)/axi4/axi4_test_1.vhd   $(DUMMY_PLUG_AXI4)
	 $(GHDL) -a $(GHDLFLAGS) --work=work $<

dummy_plug_axi4_test_1_1.o         : $(SRC_TEST_VHDL_PATH)/axi4/axi4_test_1_1.vhd dummy_plug_axi4_test_1.o $(DUMMY_PLUG_AXI4)
	 $(GHDL) -a $(GHDLFLAGS) --work=work $<

dummy_plug_axi4_test_1_2.o         : $(SRC_TEST_VHDL_PATH)/axi4/axi4_test_1_2.vhd dummy_plug_axi4_test_1.o $(DUMMY_PLUG_AXI4)
	 $(GHDL) -a $(GHDLFLAGS) --work=work $<

dummy_plug_axi4_test_1_3.o         : $(SRC_TEST_VHDL_PATH)/axi4/axi4_test_1_3.vhd dummy_plug_axi4_test_1.o $(DUMMY_PLUG_AXI4)
	 $(GHDL) -a $(GHDLFLAGS) --work=work $<

dummy_plug_axi4_test_1_4.o         : $(SRC_TEST_VHDL_PATH)/axi4/axi4_test_1_4.vhd dummy_plug_axi4_test_1.o $(DUMMY_PLUG_AXI4)
	 $(GHDL) -a $(GHDLFLAGS) --work=work $<

dummy_plug_axi4_test_1_5.o         : $(SRC_TEST_VHDL_PATH)/axi4/axi4_test_1_5.vhd dummy_plug_axi4_test_1.o $(DUMMY_PLUG_AXI4)
	 $(GHDL) -a $(GHDLFLAGS) --work=work $<

dummy_plug_axi4_stream_test_1.o    : $(SRC_TEST_VHDL_PATH)/axi4/axi4_stream_test_1.vhd   $(DUMMY_PLUG_AXI4)
	 $(GHDL) -a $(GHDLFLAGS) --work=work $<

dummy_plug_axi4_stream_test_1_1.o  : $(SRC_TEST_VHDL_PATH)/axi4/axi4_stream_test_1_1.vhd dummy_plug_axi4_stream_test_1.o $(DUMMY_PLUG_AXI4)
	 $(GHDL) -a $(GHDLFLAGS) --work=work $<

dummy_plug_axi4_memory_test.o      : $(SRC_TEST_VHDL_PATH)/axi4/axi4_memory_test.vhd   $(DUMMY_PLUG_AXI4)
	 $(GHDL) -a $(GHDLFLAGS) --work=work $<

dummy_plug_axi4_memory_test_1.o    : $(SRC_TEST_VHDL_PATH)/axi4/axi4_memory_test_1.vhd dummy_plug_axi4_memory_test.o $(DUMMY_PLUG_AXI4)
	 $(GHDL) -a $(GHDLFLAGS) --work=work $<

dummy_plug_axi4_memory_test_2.o    : $(SRC_TEST_VHDL_PATH)/axi4/axi4_memory_test_2.vhd dummy_plug_axi4_memory_test.o $(DUMMY_PLUG_AXI4)
	 $(GHDL) -a $(GHDLFLAGS) --work=work $<

