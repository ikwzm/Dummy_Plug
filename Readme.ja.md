*Dummy Plug*
============

##ご注意##

現時点(2012/5/3)ではまだ正式にリリースしているわけではありません。

##*Dummy Plug* とは##

*Dummy Plug* は VHDL だけで書かれたとってもシンプルなバス機能モデルのライブラリです.  

AXI4のマスターモデルとスレーブモデルに対応しています.  

*Dummy Plug* はYAMLライクなフォーマットで記述されたシナリオファイルを順次読み込んで、信号パターンを出力します.

例えばマスターがライトトランザクションを実行する際は次のようにシナリオを書きます.

        --- # AIX DUMMU-PLUG SAMPLE SCENARIO 1    # シナリオの章の開始.これで全てのダミープラグが同期.
        - - MASTER                                # マスター用ダミープラグの名前. 
          - A:                                    # アドレスチャネルの挙動.
            - AVALID : 0                          # AVALID <= '0'
              ADDR   : "32'h00000000"             # ADDR   <= "00000000"
              AWRITE : 0                          # AWRITE <= '0'
              ASIZE  : "'b000"                    # ASIZE  <= 000
              AID    : 0                          # AID    <= 0
            - WAIT   : 10                         # 10クロック待つ.
            - ADDR   : "32'h00000010"             # ADDR   <= "00000010"
              AWRITE : 1                          # AWRITE <= '1'
              ASIZE  : "'b010"                    # ASIZE  <= 010
              AID    : 7                          # AID    <= 7
              AVALID : 1                          # AVALID <= '1'
            - WAIT   : {AVALID: 1, AREADY: 1}     # AVALID = '1' and AREADY = '1'まで待つ.
            - AVALID : 0                          # AVALID <= '0'
            - WAIT   : {BVALID: 1, BREADY: 1}     # BVALID = '1' and BREADY = '1'まで待つ.
          - W:                                    # ライトチャネルの挙動.
            - WDATA  : 0                          # WDATA  <= "00000000"
              WSTRB  : 0                          # WSTRB  <= "0000"
              WLAST  : 0                          # WLAST  <= '0'
              WID    : 0                          # WID    <= 0
              WVALID : 0                          # WVALID <= '0';
            - WAIT   : {AVALID: 1, AREADY: 1}     # AVALID = '1' and AREADY = '1'まで待つ.
            - WDATA  : "32'h76543210"             # WDATA  <= "76543210"
              WSTRB  : "4'b1111"                  # WSTRB  <= "1111"
              WLAST  : 1                          # WLAST  <= '1'
              WID    : 7                          # WID    <= 7
              WVALID : 1                          # WVALID <= '1'
            - WAIT   : {WVALID: 1, WREADY: 1}     # WVALID = '1' and WREADY = '1'まで待つ.
            - WVALID : 0                          # WVALID <= '0'
          - B:                                    # ライト応答チャネルの挙動.
            - BREADY : 0                          # BVALID <= '0'
            - WAIT   : {AVALID: 1, AREADY: 1}     # AVALID = '1' and AREADY = '1'まで待つ.
            - BREADY : 1                          # BVALID <= '1'
            - WAIT   : {BVALID: 1, BREADY: 1}     # BVALID = '1' and BREADY = '1'まで待つ.
            - CHECK  :                            # BRESP, BID が
                BRESP  : "2'b01"                  # 指定された値になっているか調べる.
                BID    : 7                        #
            - BREADY : 0                          # BVALID <= '0'
        - - SLAVE                                 # スレーブ用ダミープラグの名前. 
          - A:                                    # アドレスチャネルの挙動.
            - AREADY : 0                          # AREADY <= '0'
            - WAIT   : {AVALID: 1, TIMEOUT: 10}   # AVALID = 1 まで待つ.ただし10クロック以内.
            - AREADY : 1                          # AREADY <= '1'
            - WAIT   : {AVALID: 1, AREADY: 1}     # AVALID = 1 and AREADY = 1 まで待つ.
            - CHECK  :                            # ADDR, AWRITE, ASIZE, AID が
                ADDR   : "32'h00000010"           # 指定した値になっているか調べる.
                AWRITE : 1                        #
                ASIZE  : "'b010"                  #
                AID    : 7                        #
            - AREADY : 0                          # AREADY <= '0'
          - W:                                    # ライトチャネルの挙動.
            - WREADY : 0                          # WREADY <= '0'
            - WAIT   : {AVALID: 1, AREADY: 1}     # AVALID = 1 and AREADY = 1 まで待つ.
            - WREADY : 1                          # WREADY <= '1'
            - WAIT   : {WVALID: 1, WREADY: 1}     # WVALID = 1 and WREADY = 1 まで待つ.
            - CHECK  :                            # WDATA, WSTRB, WLAST, WID　が
                WDATA  : "32'h76543210"           # 指定された値になっているか調べる.
                WSTRB  : "4'b1111"                #
                WLAST  : 1                        #
                WID    : 7                        #
            - WREADY : 0                          # WREADY <= '0'
          - B:                                    # ライト応答チャネルの挙動.
            - BVALID : 0                          # BVALID <= '0'
            - WAIT   : {WVALID: 1, WREADY: 1}     # WVALID = '1' and WREADY = '1'まで待つ.
            - BVALID : 1                          # BVALID <= '1'
              BRESP  : "2'b01"                    # BRESP  <= "01"
              BID    : 7                          # BID    <= 7
            - WAIT   : {BVALID: 1, BREADY: 1}     # BVALID = '1' and BREADY = '1'まで待つ.
            - BVALID : 0                          # BVALID <= '1'
              BRESP  : "2'b00"                    # BRESP  <= "00"
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

