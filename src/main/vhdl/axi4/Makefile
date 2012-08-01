ENTITY_FILES = axi4_master_player.vhd  \
               axi4_slave_player.vhd   \
               axi4_signal_printer.vhd \
               ${ENDLIST}

axi4_models.vhd : ${ENTITY_FILES}
	../../../../tools/MakeComponentPackage -verbose \
            -title   'AXI4 Dummy Plug Component Package' \
            -version 1.0.1 \
            -author  'Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>' \
            -library DUMMY_PLUG \
            -package AXI4_MODELS \
            -output  axi4_models.vhd \
            ${ENTITY_FILES}

clean:
	-rm axi4_models.vhd
