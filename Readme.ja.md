*Dummy Plug*
============

##ご注意##

現時点(2012/5/2)ではまだ正式にリリースしているわけではありません。

##*Dummy Plug* とは##

*Dummy Plug* は VHDL だけで書かれたとってもシンプルなバス機能モデルのライブラリです.  

AXI4のマスターモデルとスレーブモデルに対応しています.  

*Dummy Plug* はYAMLライクなフォーマットで記述されたシナリオファイルを順次読み込んで、信号パターンを出力します.

例えばマスターがライトトランザクションを実行する際は次のようにシナリオを書きます.

        --- # AIX DUMMU-PLUG SAMPLE SCENARIO 1    # シナリオの章の開始.これで全てのダミープラグが同期.
        - - MASTER                                # ダミープラグの名前. 
          - SAY: >                                # SAYコマンド. 文字列をコンソールに出力.
            AIX DUMMU-PLUG SAMPLE SCENARIO 1 START
        - - MASTER                                # ダミープラグの名前. 
          - A:                                    # アドレスチャネルの挙動.
            - AVALID : 0                          # AVALID <= '0'
            - WAIT   : 10                         # 10クロック待つ.
            - ADDR   : "32'h00000010"             # ADDR   <= "00000010"
              AWRITE : 1                          # AWRITE <= '1'
              ASIZE  : "'b010"                    # ASIZE  <= 010
              AVALID : 1                          # AVALID <= '1'
            - WAIT   : {AVALID: 1, AREADY: 1}     # AVALID = '1' and AREADY = '1'まで待つ.
            - AVALID : 0                          # AVALID <= '0'
            - WAIT   : {BVALID: 1, BREADY: 1}     # BVALID = '1' and BREADY = '1'まで待つ.
          - W:                                    # ライトチャネルの挙動.
            - WVALID : 0                          # WVALID <= '0';
            - WAIT   : {AVALID: 1, AREADY: 1}     # AVALID = '1' and AREADY = '1'まで待つ.
            - WDATA  : "32'h76543210"             # WDATA  <= "76543210"
              WSTRB  : "4'b1111"                  # WSTRB  <= "1111"
              WLAST  : 1                          # WLAST  <= '1'
              WVALID : 1                          # WVALID <= '1'
            - WAIT   : {WVALID: 1, WREADY: 1}     # WVALID = '1' and WREADY = '1'まで待つ.
            - WVALID : 0                          # WVALID <= '0'
          - B:                                    # ライト応答チャネルの挙動.
            - BVALID : 0                          # BVALID <= '0'
            - WAIT   : {AVALID: 1, AREADY: 1}     # AVALID = '1' and AREADY = '1'まで待つ.
            - BVALID : 1                          # BVALID <= '1'
            - WAIT   : {BVALID: 1, BREADY: 1}     # BVALID = '1' and BREADY = '1'まで待つ.
            - BVALID : 0                          # BVALID <= '0'
        ---                                       # これで全てのダミープラグが同期.
        - - Master                                # ダミープラグの名前. 
          - SAY: >                                # SAYコマンド. 文字列をコンソールに出力.
            AIX DUMMU-PLUG SAMPLE SCENARIO 1 DONE
        ---

###ライセンス###

二条項BSDライセンス (2-clause BSD license) で公開しています。

