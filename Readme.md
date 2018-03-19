*Dummy Plug*
============

## What's *Dummy Plug*

*Dummy Plug* is a simple bus functional model library written by VHDL Only.  

This models corresponds to the master and slave model of AXI4. 

*Dummy Plug* sequentially reads the scenario file that is written in a format like YAML, 
and outputs the signal pattern.

For example, when the master performs a write transaction will write the scenario, as follows.

        --- # AIX DUMMU-PLUG SAMPLE SCENARIO 1    # Start Scenario. Synchronize All Dummy Plug.
        - - MASTER                                # Name of Dummy Plug.
          - SAY: >                                # SAY Operation. Print String to STDOUT
            AIX DUMMU-PLUG SAMPLE SCENARIO 1 RUN  #
          - AW:                                   # Write Address Channel Action.
            - VALID  : 0                          # AWVALID <= 0
              ADDR   : 0x00000000                 # AWADDR  <= 32'h00000000
              SIZE   : 0                          # AWSIZE  <= 3'b000
              LEN    : 1                          # AWLEN   <= 8'h00
              AID    : 0                          # AWID    <= 0
            - WAIT   : 10                         # wait for 10 clocks.
            - ADDR   : 0x00000010                 # AWADDR  <= 32'h00000010
              SIZE   : 4                          # AWSIZE  <= 3'b010
              LEN    : 1                          # AWLEN   <= 8'h00
              ID     : 7                          # AWID    <= 7
              VALID  : 1                          # AWVALID <= 1
            - WAIT   : {VALID : 1, READY : 1}     # wait until AWVALID = 1 and AWREADY = 1
            - VALID  : 0                          # AWVALID <= 0
            - WAIT   : {BVALID: 1, BREADY: 1}     # wait until BVALID = 1 and BREADY = 1
          - W:                                    # Write Data Channel Action.
            - DATA   : 0                          # WDATA  <= 32'h00000000
              STRB   : 0                          # WSTRB  <= 4'b0000
              LAST   : 0                          # WLAST  <= 'b0
              ID     : 0                          # WID    <= 0
              VALID  : 0                          # WVALID <= 'b0;
            - WAIT   : {AWVALID: 1, ON: on}       # wait until AWVALID = 1 
            - DATA   : "32'h76543210"             # WDATA  <= 32'h76543210
              STRB   : "4'b1111"                  # WSTRB  <= 4'b1111
              LAST   : 1                          # WLAST  <= 1
              ID     : 7                          # WID    <= 7
              VALID  : 1                          # WVALID <= 1
            - WAIT   : {VALID: 1, READY: 1}       # wait until WVALID = 1 and WREADY = 1
            - WVALID : 0                          # WVALID <= 0
          - B:                                    # Write Responce Channel Action.
            - READY  : 0                          # BREADY <= 0
            - WAIT   : {AWVALID: 1, AWREADY: 1}   # wait until AWVALID = 1 and AWREADY = 1
            - READY  : 1                          # BREADY <= 1
            - WAIT   : {VALID: 1, READY: 1}       # wait until BVALID = 1 and BREADY = 1
            - CHECK  :                            # check 
                RESP   : EXOKAY                   #    BRESP = 'b01
                ID     : 7                        #    BID   = 7
            - READY  : 0                          # BREADY <= 0
        - - SLAVE                                 # Name of Dummy Plug.
          - AW:                                   # Write Address Channel Action.
            - READY  : 0                          # AWREADY <= 0
            - WAIT   : {VALID: 1, TIMEOUT: 10}    # wait until AWVALID = 1
            - READY  : 1                          # AWREADY <= 1
            - WAIT   : {VALID: 1, READY: 1}       # wait until AWVALID = 1 and AWREADY = 1
            - CHECK  :                            # check 
                ADDR   : "32'h00000010"           #   AWADDR = 0x00000010
                SIZE   : 4                        #   AWSIZE = 3'b010
                LEN    : 1                        #   AWLEN  = 8'h00
                ID     : 7                        #   AWID   = 7
            - READY  : 0                          #   AWREADY <= 0
          - W:                                    # Write Data Channel Action.
            - READY  : 0                          # WREADY <= 0
            - WAIT   : {AWVALID: 1, AWREADY: 1}   # wait until AWVALID = 1 and AWREADY = 1
            - READY  : 1                          # WREADY <= 1
            - WAIT   : {VALID: 1, READY: 1}       # wait until WVALID = 1 and WREADY = 1
            - CHECK  :                            # check
                DATA   : "32'h76543210"           #   WDATA  = 32'h76543210
                STRB   : "4'b1111"                #   WSTRB  = 4'b1111
                LAST   : 1                        #   WLAST  = 1
                ID     : 7                        #   WID    = 7
            - READY  : 0                          # WREADY <= 0
          - B:                                    # Write Responce Channel Action.
            - VALID  : 0                          # BVALID <= 0
            - WAIT   : {WVALID: 1, WREADY: 1}     # wait until WVALID = 1 and WREADY = 1
            - VALID  : 1                          # BVALID <= 1
              RESP   : EXOKAY                     # BRESP  <= 'b01
              ID     : 7                          # BID    <= 7
            - WAIT   : {VALID: 1, READY: 1}       # wait until BVALID = 1 and BREADY = 1
            - VALID  : 0                          # BVALID <= 1
              RESP   : OKAY                       # BRESP  <= 'b00
        ---                                       # 
        - - Master                                # Name of Dummy Plug.
          - SAY: >                                # SAY Operation. Print String to STDOUT
            AIX DUMMU-PLUG SAMPLE SCENARIO 1 DONE
        ---

## Trial

The operation of *Dummy Plug* is confirmed with the following simulator.

 - GHDL 0.29
 - [GHDL 0.35](https://github.com/ghdl/ghdl)
 - [nvc](https://github.com/nickg/nvc)
 - [Vivado 2017.2 Xilinx](https://www.xilinx.com/products/design-tools/vivado/simulator.html)

### GHDL-0.35

```console
shell$ cd sim/ghdl-0.35/axi4
shell$ make
```

### NVC

```console
shell$ cd sim/nvc/lib
shell$ make
shell$ cd sim/nvc/axi4
shell$ make
```

## License

2-clause BSD license


