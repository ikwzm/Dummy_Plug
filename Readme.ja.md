*Dummy Plug*
============

## *Dummy Plug* とは

*Dummy Plug* は VHDL だけで書かれたとってもシンプルなバス機能モデルのライブラリです.  

AXI4のマスターモデルとスレーブモデルに対応しています.  

*Dummy Plug* はYAMLライクなフォーマットで記述されたシナリオファイルを順次読み込んで、信号パターンを出力します.

例えばマスターがライトトランザクションを実行する際は次のようにシナリオを書きます.

        --- # AIX DUMMU-PLUG SAMPLE SCENARIO 1    # シナリオの章の開始.これで全てのダミープラグが同期.
        - - MASTER                                # マスター用ダミープラグの名前. 
          - SAY: >                                # SAY Operation. Print String to STDOUT
            AIX DUMMU-PLUG SAMPLE SCENARIO 1 RUN  #
          - AW:                                   # ライトアドレスチャネルの挙動.
            - VALID  : 0                          # AWVALID <= 0
              ADDR   : 0x00000000                 # AWADDR  <= 32'h00000000
              SIZE   : 1                          # AWSIZE  <= 3'b000
              LEN    : 1                          # AWLEN   <= 8'h00
              AID    : 0                          # AWID    <= 0
            - WAIT   : 10                         # 10クロック待つ.
            - ADDR   : 0x00000010                 # AWADDR  <= 32'h00000010
              SIZE   : 4                          # AWSIZE  <= 3'b010
              LEN    : 1                          # AWLEN   <= 8'h00
              ID     : 7                          # AWID    <= 7
              VALID  : 1                          # AWVALID <= 1
            - WAIT   : {VALID : 1, READY : 1}     # AWVALID = 1 and AWREADY = 1まで待つ.
            - VALID  : 0                          # AWVALID <= 0
            - WAIT   : {BVALID: 1, BREADY: 1}     # BVALID = 1 and BREADY = 1まで待つ.
          - W:                                    # ライトチャネルの挙動.
            - DATA   : 0                          # WDATA  <= 0x00000000
              STRB   : 0                          # WSTRB  <= 0000
              LAST   : 0                          # WLAST  <= 0
              ID     : 0                          # WID    <= 0
              VALID  : 0                          # WVALID <= 0;
            - WAIT   : {AWVALID: 1, ON: on}       # AWVALID = 1 まで待つ.
            - DATA   : "32'h76543210"             # WDATA  <= 32'h76543210
              STRB   : "4'b1111"                  # WSTRB  <= 4'b1111
              LAST   : 1                          # WLAST  <= 1
              ID     : 7                          # WID    <= 7
              VALID  : 1                          # WVALID <= 1
            - WAIT   : {VALID: 1, READY: 1}       # WVALID = 1 and WREADY = 1まで待つ.
            - WVALID : 0                          # WVALID <= 0
          - B:                                    # ライト応答チャネルの挙動.
            - READY  : 0                          # BREADY <= 0
            - WAIT   : {AWVALID: 1, AWREADY: 1}   # AWVALID = 1 and AWREADY = 1まで待つ.
            - READY  : 1                          # BREADY <= 1
            - WAIT   : {VALID: 1, READY: 1}       # BVALID = 1 and BREADY = 1まで待つ.
            - CHECK  :                            # 指定された値になっているか調べる.
                RESP   : EXOKAY                   #   BRESP = 2'b01
                ID     : 7                        #   BID   = 7
            - READY  : 0                          # BREADY <= 0
        - - SLAVE                                 # スレーブ用ダミープラグの名前. 
          - AW:                                   # アドレスチャネルの挙動.
            - READY  : 0                          # AWREADY <= 0
            - WAIT   : {VALID: 1, TIMEOUT: 10}    # AWVALID = 1 まで待つ.ただし10クロック以内.
            - READY  : 1                          # AWREADY <= 1
            - WAIT   : {VALID: 1, READY: 1}       # AWVALID = 1 and AWREADY = 1 まで待つ.
            - CHECK  :                            # 指定した値になっているか調べる.
                ADDR   : "32'h00000010"           #   AWADDR = 0x00000010
                SIZE   : 4                        #   AWSIZE = 3'b010
                LEN    : 1                        #   AWLEN  = 8'h00
                ID     : 7                        #   AWID   = 7
            - READY  : 0                          # AWREADY <= 0
          - W:                                    # ライトチャネルの挙動.
            - READY  : 0                          # WREADY <= 0
            - WAIT   : {AWVALID: 1, AWREADY: 1}   # AWVALID = 1 and AWREADY = 1 まで待つ.
            - READY  : 1                          # WREADY <= 1
            - WAIT   : {VALID: 1, READY: 1}       # WVALID = 1 and WREADY = 1 まで待つ.
            - CHECK  :                            # 指定された値になっているか調べる.
                DATA   : "32'h76543210"           #   WDATA  = 32'h76543210
                STRB   : "4'b1111"                #   WSTRB  = 4'b1111
                LAST   : 1                        #   WLAST  = 1
                ID     : 7                        #   WID    = 7
            - READY  : 0                          # WREADY <= 0
          - B:                                    # ライト応答チャネルの挙動.
            - VALID  : 0                          # BVALID <= 0
            - WAIT   : {WVALID: 1, WREADY: 1}     # WVALID = 1 and WREADY = 1まで待つ.
            - VALID  : 1                          # BVALID <= 1
              RESP   : EXOKAY                     # BRESP  <= 2'b01
              ID     : 7                          # BID    <= 7
            - WAIT   : {VALID: 1, READY: 1}       # BVALID = 1 and BREADY = 1まで待つ.
            - VALID  : 0                          # BVALID <= 1
              RESP   : OKAY                       # BRESP  <= 2'b00
        ---                                       # これで全てのダミープラグが同期.
        - - Master                                # ダミープラグの名前. 
          - SAY: >                                # SAYコマンド. 文字列をコンソールに出力.
            AIX DUMMU-PLUG SAMPLE SCENARIO 1 DONE
        ---

## お試し

*Dummy Plug* は次のシミュレーターで動作を確認しています。

 - GHDL 0.29
 - [GHDL 0.35](https://github.com/ghdl/ghdl)
 - [nvc](https://github.com/nickg/nvc)
 - [Vivado 2017.2 Xilinx](https://www.xilinx.com/products/design-tools/vivado/simulator.html)

### GHDL 0.29

```console
shell$ cd sim/ghdl-0.29/axi4
shell$ make
```

### GHDL 0.35

```console
shell$ cd sim/ghdl-0.35/axi4
shell$ make
```

### nvc

```console
shell$ cd sim/nvc/lib
shell$ make
shell$ cd sim/nvc/axi4
shell$ make
```

### Vivado 2017.2

```console
Vivado% vivado -mode batch -source simulate_axi4_test_1_1.tcl
Vivado% vivado -mode batch -source simulate_axi4_test_1_2.tcl
Vivado% vivado -mode batch -source simulate_axi4_test_1_3.tcl
Vivado% vivado -mode batch -source simulate_axi4_test_1_4.tcl
```

## ライセンス

二条項BSDライセンス (2-clause BSD license) で公開しています。

