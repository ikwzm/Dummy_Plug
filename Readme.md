*Dummy Plug*
============

##Notice##

*Dummy Plug* is at the moment(2012/5/2) but is not officially released yet.

##What's *Dummy Plug*##

*Dummy Plug* is a simple bus function model library written by VHDL Only.  

This models corresponds to the master and slave model of AXI4. 

* Dummy Plug * sequentially reads the scenario file that is written in a format like YAML, 
and outputs the signal pattern.

For example, when the master performs a write transaction will write the scenario, as follows.

        --- # AIX DUMMU-PLUG SAMPLE SCENARIO 1    # Start Scenario. Synchronize All Dummy Plug.
        - - MASTER                                # Name of Dummy Plug.
          - SAY: >                                # SAY Operation. Print String to STDOUT
            AIX DUMMU-PLUG SAMPLE SCENARIO 1 START
        - - MASTER                                # Name of Dummy Plug.
          - A:                                    # Address Channel Action.
            - AVALID : 0                          # AVALID <= '0'
            - WAIT   : 10                         # wait for 10 clocks.
            - ADDR   : "32'h00000010"             # ADDR   <= "00000010"
              AWRITE : 1                          # AWRITE <= '1'
              ASIZE  : "'b010"                    # ASIZE  <= 010
              AVALID : 1                          # AVALID <= '1'
            - WAIT   : {AVALID: 1, AREADY: 1}     # wait until AVALID = '1' and AREADY = '1'
            - AVALID : 0                          # AVALID <= '0'
            - WAIT   : {BVALID: 1, BREADY: 1}     # wait until BVALID = '1' and BREADY = '1'
          - W:                                    # Write Channel Action.
            - WVALID : 0                          # WVALID <= '0';
            - WAIT   : {AVALID: 1, AREADY: 1}     # wait until AVALID = '1' and AREADY = '1'
            - WDATA  : "32'h76543210"             # WDATA  <= "76543210"
              WSTRB  : "4'b1111"                  # WSTRB  <= "1111"
              WLAST  : 1                          # WLAST  <= '1'
              WVALID : 1                          # WVALID <= '1'
            - WAIT   : {WVALID: 1, WREADY: 1}     # wait until WVALID = '1' and WREADY = '1'
            - WVALID : 0                          # WVALID <= '0'
          - B:                                    # Write Responce Channel Action.
            - BVALID : 0                          # BVALID <= '0'
            - WAIT   : {AVALID: 1, AREADY: 1}     # wait until AVALID = '1' and AREADY = '1'
            - BVALID : 1                          # BVALID <= '1'
            - WAIT   : {BVALID: 1, BREADY: 1}     # wait until BVALID = '1' and BREADY = '1'
            - BVALID : 0                          # BVALID <= '0'
        ---                                       # Synchronize All Dummy Plug.
        - - Master                                # Name of Dummy Plug.
          - SAY: >                                # SAY Operation. Print String to STDOUT
            AIX DUMMU-PLUG SAMPLE SCENARIO 1 DONE
        ---

##License##

2-clause BSD license


