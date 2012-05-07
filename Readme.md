
*Dummy Plug*
============

##Notice##

*Dummy Plug* is at the moment(2012/5/3) but is not officially released yet.

##What's *Dummy Plug*##

*Dummy Plug* is a simple bus function model library written by VHDL Only.  

This models corresponds to the master and slave model of AXI4. 

*Dummy Plug* sequentially reads the scenario file that is written in a format like YAML, 
and outputs the signal pattern.

For example, when the master performs a write transaction will write the scenario, as follows.

        --- # AIX DUMMU-PLUG SAMPLE SCENARIO 1    # Start Scenario. Synchronize All Dummy Plug.
        - - MASTER                                # Name of Dummy Plug.
          - SAY: >                                # SAY Operation. Print String to STDOUT
            AIX DUMMU-PLUG SAMPLE SCENARIO 1 START
          - AW:                                   # Write Address Channel Action.
            - VALID  : 0                          # AWVALID <= 0
              ADDR   : "32'h00000000"             # AWADDR  <= 0x00000000
              SIZE   : "'b000"                    # AWSIZE  <= 000
              LEN    : 0                          # AWLEN   <= 0
              AID    : 0                          # AWID    <= 0
            - WAIT   : 10                         # wait for 10 clocks.
            - ADDR   : "32'h00000010"             # AWADDR  <= 0x00000010
              SIZE   : "'b010"                    # AWSIZE  <= 010
              LEN    : 0                          # AWLEN   <= 0
              ID     : 7                          # AWID    <= 7
              VALID  : 1                          # AWVALID <= 1
            - WAIT   : {VALID : 1, READY : 1}     # wait until AWVALID = 1 and AWREADY = 1
            - VALID  : 0                          # AWVALID <= 0
            - WAIT   : {BVALID: 1, BREADY: 1}     # wait until BVALID = 1 and BREADY = 1
          - W:                                    # Write Data Channel Action.
            - DATA   : 0                          # WDATA  <= 0x00000000
              STRB   : 0                          # WSTRB  <= 0000
              LAST   : 0                          # WLAST  <= 0
              ID     : 0                          # WID    <= 0
              VALID  : 0                          # WVALID <= 0;
            - WAIT   : {AWVALID: 1, AWREADY: 1}   # wait until AWVALID = 1 and AWREADY = 1
            - DATA   : "32'h76543210"             # WDATA  <= 0x76543210
              STRB   : "4'b1111"                  # WSTRB  <= 1111
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
            - CHECK  :                            # check BRESP and BID
                RESP   : "2'b01"                  # 
                ID     : 7                        #
            - READY  : 0                          # BREADY <= 0
        - - SLAVE                                 # Name of Dummy Plug.
          - AW:                                   # Write Address Channel Action.
            - READY  : 0                          # AWREADY <= 0
            - WAIT   : {VALID: 1, TIMEOUT: 10}    # wait until AWVALID = 1
            - READY  : 1                          # AWREADY <= 1
            - WAIT   : {VALID: 1, READY: 1}       # wait until AWVALID = 1 and AWREADY = 1
            - CHECK  :                            # check AWADDR, AWLEN, AWSIZE, AWID
                ADDR   : "32'h00000010"           # 
                SIZE   : "'b010"                  #
                LEN    : 0                        #
                ID     : 7                        #
            - READY  : 0                          # AWREADY <= 0
          - W:                                    # Write Data Channel Action.
            - READY  : 0                          # WREADY <= 0
            - WAIT   : {AWVALID: 1, AWREADY: 1}   # wait until AWVALID = 1 and AWREADY = 1
            - READY  : 1                          # WREADY <= 1
            - WAIT   : {VALID: 1, READY: 1}       # wait until WVALID = 1 and WREADY = 1
            - CHECK  :                            # check WDATA, WSTRB, WLAST, WID
                DATA   : "32'h76543210"           # 
                STRB   : "4'b1111"                #
                LAST   : 1                        #
                ID     : 7                        #
            - READY  : 0                          # WREADY <= '0'
          - B:                                    # Write Responce Channel Action.
            - VALID  : 0                          # BVALID <= 0
            - WAIT   : {WVALID: 1, WREADY: 1}     # wait until WVALID = 1 and WREADY = 1
            - VALID  : 1                          # BVALID <= 1
              RESP   : "2'b01"                    # BRESP  <= 01
              ID     : 7                          # BID    <= 7
            - WAIT   : {VALID: 1, READY: 1}       # wait until BVALID = 1 and BREADY = 1
            - VALID  : 0                          # BVALID <= 1
              RESP   : "2'b00"                    # BRESP  <= 00
        ---                                       # 
        - - Master                                # Name of Dummy Plug.
          - SAY: >                                # SAY Operation. Print String to STDOUT
            AIX DUMMU-PLUG SAMPLE SCENARIO 1 DONE
        ---

##Trial##

*Dummy Plug* is checking operation by GHDL.  
When "cd sim/ghdl" and "make",  library and test bench is compiled and it is begun to run.

##License##

2-clause BSD license


