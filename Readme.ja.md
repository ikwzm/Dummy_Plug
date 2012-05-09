*Dummy Plug*
============

##ご注意##

現時点(2012/5/9)ではまだ正式にリリースしているわけではありません。

##*Dummy Plug* とは##

*Dummy Plug* は VHDL だけで書かれたとってもシンプルなバス機能モデルのライブラリです.  

AXI4のマスターモデルとスレーブモデルに対応しています.  

*Dummy Plug* はYAMLライクなフォーマットで記述されたシナリオファイルを順次読み込んで、信号パターンを出力します.

例えばマスターがライトトランザクションを実行する際は次のようにシナリオを書きます.

        --- # AIX DUMMU-PLUG SAMPLE SCENARIO 1    # シナリオの章の開始.これで全てのダミープラグが同期.
        - - MASTER                                # マスター用ダミープラグの名前. 
          - AW:                                   # ライトアドレスチャネルの挙動.
            - VALID  : 0                          # AWVALID <= 0
              ADDR   : "32'h00000000"             # AWADDR  <= 0x00000000
              SIZE   : "'b000"                    # AWSIZE  <= 000
              LEN    : 0                          # AWLEN   <= 0
              AID    : 0                          # AWID    <= 0
            - WAIT   : 10                         # 10クロック待つ.
            - ADDR   : "32'h00000010"             # AWADDR  <= 0x00000010
              SIZE   : "'b010"                    # AWSIZE  <= 010
              LEN    : 0                          # AWLEN   <= 0
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
            - WAIT   : {AWVALID: 1, AWREADY: 1}   # AWVALID = 1 and AWREADY = 1まで待つ.
            - DATA   : "32'h76543210"             # WDATA  <= 0x76543210
              STRB   : "4'b1111"                  # WSTRB  <= 1111
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
            - CHECK  :                            # BRESP, BID が
                RESP   : "2'b01"                  # 指定された値になっているか調べる.
                ID     : 7                        #
            - READY  : 0                          # BREADY <= 0
        - - SLAVE                                 # スレーブ用ダミープラグの名前. 
          - AW:                                   # アドレスチャネルの挙動.
            - READY  : 0                          # AWREADY <= 0
            - WAIT   : {VALID: 1, TIMEOUT: 10}    # AWVALID = 1 まで待つ.ただし10クロック以内.
            - READY  : 1                          # AWREADY <= 1
            - WAIT   : {VALID: 1, READY: 1}       # AWVALID = 1 and AWREADY = 1 まで待つ.
            - CHECK  :                            # AWADDR, AWLEN, AWSIZE, AWID が
                ADDR   : "32'h00000010"           # 指定した値になっているか調べる.
                SIZE   : "'b010"                  #
                LEN    : 0                        #
                ID     : 7                        #
            - READY  : 0                          # AWREADY <= 0
          - W:                                    # ライトチャネルの挙動.
            - READY  : 0                          # WREADY <= 0
            - WAIT   : {AWVALID: 1, AWREADY: 1}   # AWVALID = 1 and AWREADY = 1 まで待つ.
            - READY  : 1                          # WREADY <= 1
            - WAIT   : {VALID: 1, READY: 1}       # WVALID = 1 and WREADY = 1 まで待つ.
            - CHECK  :                            # WDATA, WSTRB, WLAST, WID　が
                DATA   : "32'h76543210"           # 指定された値になっているか調べる.
                STRB   : "4'b1111"                #
                LAST   : 1                        #
                ID     : 7                        #
            - READY  : 0                          # WREADY <= '0'
          - B:                                    # ライト応答チャネルの挙動.
            - VALID  : 0                          # BVALID <= 0
            - WAIT   : {WVALID: 1, WREADY: 1}     # WVALID = 1 and WREADY = 1まで待つ.
            - VALID  : 1                          # BVALID <= 1
              RESP   : "2'b01"                    # BRESP  <= 01
              ID     : 7                          # BID    <= 7
            - WAIT   : {VALID: 1, READY: 1}       # BVALID = '1' and BREADY = '1'まで待つ.
            - VALID  : 0                          # BVALID <= 1
              RESP   : "2'b00"                    # BRESP  <= 00
        ---                                       # これで全てのダミープラグが同期.
        - - Master                                # ダミープラグの名前. 
          - SAY: >                                # SAYコマンド. 文字列をコンソールに出力.
            AIX DUMMU-PLUG SAMPLE SCENARIO 1 DONE
        ---

##お試し

*Dummy Plug* は GHDL で動作確認をしています.  
sim/ghdl の下に Makefile があります.  
make コマンドを実行することでライブラリとテストベンチがコンパイルされ走ります.

##ライセンス##

二条項BSDライセンス (2-clause BSD license) で公開しています。

