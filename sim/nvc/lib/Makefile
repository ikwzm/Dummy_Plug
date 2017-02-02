srcdir=../../../src/main/vhdl
NVC=nvc

dummy_plug_data = \
	dummy_plug/DUMMY_PLUG.UTIL                       \
	dummy_plug/DUMMY_PLUG.READER                     \
	dummy_plug/DUMMY_PLUG.VOCAL                      \
	dummy_plug/DUMMY_PLUG.SYNC                       \
	dummy_plug/DUMMY_PLUG.CORE                       \
	dummy_plug/DUMMY_PLUG.MARCHAL                    \
	dummy_plug/DUMMY_PLUG.AXI4_TYPES                 \
	dummy_plug/DUMMY_PLUG.AXI4_CORE                  \
	dummy_plug/DUMMY_PLUG.AXI4_CHANNEL_PLAYER        \
	dummy_plug/DUMMY_PLUG.AXI4_MASTER_PLAYER         \
	dummy_plug/DUMMY_PLUG.AXI4_MODELS                \
	dummy_plug/DUMMY_PLUG.AXI4_SIGNAL_PRINTER        \
	dummy_plug/DUMMY_PLUG.AXI4_SLAVE_PLAYER          \
	dummy_plug/DUMMY_PLUG.AXI4_STREAM_PLAYER         \
	dummy_plug/DUMMY_PLUG.AXI4_MASTER_PLAYER         \
	dummy_plug/DUMMY_PLUG.AXI4_STREAM_SLAVE_PLAYER   \
	dummy_plug/DUMMY_PLUG.AXI4_STREAM_SIGNAL_PRINTER \
	$(ENDLIST)

all  : $(dummy_plug_data)

clean:
	rm -rf dummy_plug

dummy_plug/DUMMY_PLUG.UTIL                       : $(srcdir)/core/util.vhd
	$(NVC) --work=dummy_plug -a $<

dummy_plug/DUMMY_PLUG.READER                     : $(srcdir)/core/reader.vhd
	$(NVC) --work=dummy_plug -a $<

dummy_plug/DUMMY_PLUG.VOCAL                      : $(srcdir)/core/vocal.vhd
	$(NVC) --work=dummy_plug -a $<

dummy_plug/DUMMY_PLUG.SYNC                       : $(srcdir)/core/sync.vhd
	$(NVC) --work=dummy_plug -a $<

dummy_plug/DUMMY_PLUG.CORE                       : $(srcdir)/core/core.vhd
	$(NVC) --work=dummy_plug -a $<

dummy_plug/DUMMY_PLUG.MARCHAL                    : $(srcdir)/core/marchal.vhd
	$(NVC) --work=dummy_plug -a $<

dummy_plug/DUMMY_PLUG.AXI4_TYPES                 : $(srcdir)/axi4/axi4_types.vhd
	$(NVC) --work=dummy_plug -a $<

dummy_plug/DUMMY_PLUG.AXI4_CORE                  : $(srcdir)/axi4/axi4_core.vhd
	$(NVC) --work=dummy_plug -a $<

dummy_plug/DUMMY_PLUG.AXI4_CHANNEL_PLAYER        : $(srcdir)/axi4/axi4_channel_player.vhd
	$(NVC) --work=dummy_plug -a $<

dummy_plug/DUMMY_PLUG.AXI4_MASTER_PLAYER         : $(srcdir)/axi4/axi4_master_player.vhd
	$(NVC) --work=dummy_plug -a $<

dummy_plug/DUMMY_PLUG.AXI4_MODELS                : $(srcdir)/axi4/axi4_models.vhd
	$(NVC) --work=dummy_plug -a $<

dummy_plug/DUMMY_PLUG.AXI4_SIGNAL_PRINTER        : $(srcdir)/axi4/axi4_signal_printer.vhd
	$(NVC) --work=dummy_plug -a $<

dummy_plug/DUMMY_PLUG.AXI4_SLAVE_PLAYER          : $(srcdir)/axi4/axi4_slave_player.vhd
	$(NVC) --work=dummy_plug -a $<

dummy_plug/DUMMY_PLUG.AXI4_STREAM_PLAYER         : $(srcdir)/axi4/axi4_stream_player.vhd
	$(NVC) --work=dummy_plug -a $<

dummy_plug/DUMMY_PLUG.AXI4_STREAM_MASTER_PLAYER  : $(srcdir)/axi4/axi4_stream_master_player.vhd
	$(NVC) --work=dummy_plug -a $<

dummy_plug/DUMMY_PLUG.AXI4_STREAM_SLAVE_PLAYER   : $(srcdir)/axi4/axi4_stream_slave_player.vhd
	$(NVC) --work=dummy_plug -a $<

dummy_plug/DUMMY_PLUG.AXI4_STREAM_SIGNAL_PRINTER : $(srcdir)/axi4/axi4_stream_signal_printer.vhd
	$(NVC) --work=dummy_plug -a $<

