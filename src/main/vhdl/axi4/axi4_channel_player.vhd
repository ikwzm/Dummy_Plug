-----------------------------------------------------------------------------------
--!     @file    axi4_channel_player.vhd
--!     @brief   AXI4 A/R/W/B Channel Dummy Plug Player.
--!     @version 1.2.0
--!     @date    2012/10/27
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012 Ichiro Kawazome
--      All rights reserved.
--
--      Redistribution and use in source and binary forms, with or without
--      modification, are permitted provided that the following conditions
--      are met:
--
--        1. Redistributions of source code must retain the above copyright
--           notice, this list of conditions and the following disclaimer.
--
--        2. Redistributions in binary form must reproduce the above copyright
--           notice, this list of conditions and the following disclaimer in
--           the documentation and/or other materials provided with the
--           distribution.
--
--      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
--      A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
--      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
--      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
--      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
--      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
--      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
--      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
--      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.AXI4_CORE.all;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.SYNC.SYNC_PLUG_NUM_TYPE;
use     DUMMY_PLUG.SYNC.SYNC_REQ_VECTOR;
use     DUMMY_PLUG.SYNC.SYNC_ACK_VECTOR;
-----------------------------------------------------------------------------------
--! @brief   AXI4_CHANNEL_PLAYER :
-----------------------------------------------------------------------------------
entity  AXI4_CHANNEL_PLAYER is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        SCENARIO_FILE   : --! @brief シナリオファイルの名前.
                          STRING;
        NAME            : --! @brief 固有名詞.
                          STRING;
        FULL_NAME       : --! @brief メッセージ出力用の固有名詞.
                          STRING;
        CHANNEL         : --! @brief チャネルタイプ.
                          AXI4_CHANNEL_TYPE;
        MASTER          : --! @brief マスターモードを指定する.
                          boolean   := FALSE;
        SLAVE           : --! @brief スレーブモードを指定する.
                          boolean   := FALSE;
        READ_ENABLE     : --! @brief リードトランザクションの可/不可を指定する.
                          boolean   := TRUE;
        WRITE_ENABLE    : --! @brief ライトトランザクションの可/不可を指定する.
                          boolean   := TRUE;
        OUTPUT_DELAY    : --! @brief 出力信号遅延時間
                          time;
        WIDTH           : --! @brief AXI4 IS WIDTH :
                          AXI4_SIGNAL_WIDTH_TYPE;
        SYNC_WIDTH      : --! @brief シンクロ用信号の本数.
                          integer :=  1;
        SYNC_LOCAL_WAIT : --! @brief ローカル同期時のウェイトクロック数.
                          integer := 2;
        GPI_WIDTH       : --! @brief GPI(General Purpose Input)信号のビット幅.
                          integer := 8;
        GPO_WIDTH       : --! @brief GPO(General Purpose Output)信号のビット幅.
                          integer := 8;
        FINISH_ABORT    : --! @brief FINISH コマンド実行時にシミュレーションを
                          --!        アボートするかどうかを指定するフラグ.
                          boolean := true
    );
    -------------------------------------------------------------------------------
    -- 入出力ポートの定義.
    -------------------------------------------------------------------------------
    port(
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
        ACLK            : in    std_logic;
        ARESETn         : in    std_logic;
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
        ARADDR_I        : in    std_logic_vector(WIDTH.ARADDR -1 downto 0);
        ARADDR_O        : out   std_logic_vector(WIDTH.ARADDR -1 downto 0);
        ARLEN_I         : in    AXI4_ALEN_TYPE;
        ARLEN_O         : out   AXI4_ALEN_TYPE;
        ARSIZE_I        : in    AXI4_ASIZE_TYPE;
        ARSIZE_O        : out   AXI4_ASIZE_TYPE;
        ARBURST_I       : in    AXI4_ABURST_TYPE;
        ARBURST_O       : out   AXI4_ABURST_TYPE;
        ARLOCK_I        : in    AXI4_ALOCK_TYPE;
        ARLOCK_O        : out   AXI4_ALOCK_TYPE;
        ARCACHE_I       : in    AXI4_ACACHE_TYPE;
        ARCACHE_O       : out   AXI4_ACACHE_TYPE;
        ARPROT_I        : in    AXI4_APROT_TYPE;
        ARPROT_O        : out   AXI4_APROT_TYPE;
        ARQOS_I         : in    AXI4_AQOS_TYPE;
        ARQOS_O         : out   AXI4_AQOS_TYPE;
        ARREGION_I      : in    AXI4_AREGION_TYPE;
        ARREGION_O      : out   AXI4_AREGION_TYPE;
        ARUSER_I        : in    std_logic_vector(WIDTH.ARUSER -1 downto 0);
        ARUSER_O        : out   std_logic_vector(WIDTH.ARUSER -1 downto 0);
        ARID_I          : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        ARID_O          : out   std_logic_vector(WIDTH.ID     -1 downto 0);
        ARVALID_I       : in    std_logic;
        ARVALID_O       : out   std_logic;
        ARREADY_I       : in    std_logic;
        ARREADY_O       : out   std_logic;
        ---------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        ---------------------------------------------------------------------------
        RVALID_I        : in    std_logic;
        RVALID_O        : out   std_logic;
        RLAST_I         : in    std_logic;
        RLAST_O         : out   std_logic;
        RDATA_I         : in    std_logic_vector(WIDTH.RDATA  -1 downto 0);
        RDATA_O         : out   std_logic_vector(WIDTH.RDATA  -1 downto 0);
        RRESP_I         : in    AXI4_RESP_TYPE;
        RRESP_O         : out   AXI4_RESP_TYPE;
        RUSER_I         : in    std_logic_vector(WIDTH.RUSER  -1 downto 0);
        RUSER_O         : out   std_logic_vector(WIDTH.RUSER  -1 downto 0);
        RID_I           : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        RID_O           : out   std_logic_vector(WIDTH.ID     -1 downto 0);
        RREADY_I        : in    std_logic;
        RREADY_O        : out   std_logic;
        ---------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
        AWADDR_I        : in    std_logic_vector(WIDTH.AWADDR -1 downto 0);
        AWADDR_O        : out   std_logic_vector(WIDTH.AWADDR -1 downto 0);
        AWLEN_I         : in    AXI4_ALEN_TYPE;
        AWLEN_O         : out   AXI4_ALEN_TYPE;
        AWSIZE_I        : in    AXI4_ASIZE_TYPE;
        AWSIZE_O        : out   AXI4_ASIZE_TYPE;
        AWBURST_I       : in    AXI4_ABURST_TYPE;
        AWBURST_O       : out   AXI4_ABURST_TYPE;
        AWLOCK_I        : in    AXI4_ALOCK_TYPE;
        AWLOCK_O        : out   AXI4_ALOCK_TYPE;
        AWCACHE_I       : in    AXI4_ACACHE_TYPE;
        AWCACHE_O       : out   AXI4_ACACHE_TYPE;
        AWPROT_I        : in    AXI4_APROT_TYPE;
        AWPROT_O        : out   AXI4_APROT_TYPE;
        AWQOS_I         : in    AXI4_AQOS_TYPE;
        AWQOS_O         : out   AXI4_AQOS_TYPE;
        AWREGION_I      : in    AXI4_AREGION_TYPE;
        AWREGION_O      : out   AXI4_AREGION_TYPE;
        AWUSER_I        : in    std_logic_vector(WIDTH.AWUSER -1 downto 0);
        AWUSER_O        : out   std_logic_vector(WIDTH.AWUSER -1 downto 0);
        AWID_I          : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        AWID_O          : out   std_logic_vector(WIDTH.ID     -1 downto 0);
        AWVALID_I       : in    std_logic;
        AWVALID_O       : out   std_logic;
        AWREADY_I       : in    std_logic;
        AWREADY_O       : out   std_logic;
        ---------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        ---------------------------------------------------------------------------
        WLAST_I         : in    std_logic;
        WLAST_O         : out   std_logic;
        WDATA_I         : in    std_logic_vector(WIDTH.WDATA  -1 downto 0);
        WDATA_O         : out   std_logic_vector(WIDTH.WDATA  -1 downto 0);
        WSTRB_I         : in    std_logic_vector(WIDTH.WDATA/8-1 downto 0);
        WSTRB_O         : out   std_logic_vector(WIDTH.WDATA/8-1 downto 0);
        WUSER_I         : in    std_logic_vector(WIDTH.WUSER  -1 downto 0);
        WUSER_O         : out   std_logic_vector(WIDTH.WUSER  -1 downto 0);
        WID_I           : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        WID_O           : out   std_logic_vector(WIDTH.ID     -1 downto 0);
        WVALID_I        : in    std_logic;
        WVALID_O        : out   std_logic;
        WREADY_I        : in    std_logic;
        WREADY_O        : out   std_logic;
        ---------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        ---------------------------------------------------------------------------
        BRESP_I         : in    AXI4_RESP_TYPE;
        BRESP_O         : out   AXI4_RESP_TYPE;
        BUSER_I         : in    std_logic_vector(WIDTH.BUSER  -1 downto 0);
        BUSER_O         : out   std_logic_vector(WIDTH.BUSER  -1 downto 0);
        BID_I           : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        BID_O           : out   std_logic_vector(WIDTH.ID     -1 downto 0);
        BVALID_I        : in    std_logic;
        BVALID_O        : out   std_logic;
        BREADY_I        : in    std_logic;
        BREADY_O        : out   std_logic;
        ---------------------------------------------------------------------------
        -- シンクロ用信号.
        ---------------------------------------------------------------------------
        SYNC_REQ        : out   SYNC_REQ_VECTOR(SYNC_WIDTH-1 downto 0);
        SYNC_ACK        : in    SYNC_ACK_VECTOR(SYNC_WIDTH-1 downto 0) := (others => '0');
        SYNC_LOCAL_REQ  : out   SYNC_REQ_VECTOR(0 downto 0);
        SYNC_LOCAL_ACK  : in    SYNC_ACK_VECTOR(0 downto 0);
        SYNC_TRANS_REQ  : out   SYNC_REQ_VECTOR(0 downto 0);
        SYNC_TRANS_ACK  : in    SYNC_ACK_VECTOR(0 downto 0);
        ---------------------------------------------------------------------------
        -- トランザクション用信号.
        ---------------------------------------------------------------------------
        TRAN_I          : in    AXI4_TRANSACTION_SIGNAL_TYPE;
        TRAN_O          : out   AXI4_TRANSACTION_SIGNAL_TYPE;
        --------------------------------------------------------------------------
        -- General Purpose Input 信号
        --------------------------------------------------------------------------
        GPI             : in    std_logic_vector(GPI_WIDTH-1 downto 0) := (others => '0');
        --------------------------------------------------------------------------
        -- General Purpose Output 信号
        --------------------------------------------------------------------------
        GPO             : out   std_logic_vector(GPO_WIDTH-1 downto 0);
        --------------------------------------------------------------------------
        -- レポートステータス出力.
        --------------------------------------------------------------------------
        REPORT_STATUS   : out   REPORT_STATUS_TYPE;
        --------------------------------------------------------------------------
        -- シミュレーション終了通知信号.
        --------------------------------------------------------------------------
        FINISH          : out   std_logic
    );
end AXI4_CHANNEL_PLAYER;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.AXI4_CORE.all;
use     DUMMY_PLUG.CORE.all;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.UTIL.all;
use     DUMMY_PLUG.READER.all;
-----------------------------------------------------------------------------------
--! @brief   AXI4_CHANNEL_PLAYER :
-----------------------------------------------------------------------------------
architecture MODEL of AXI4_CHANNEL_PLAYER is
    -------------------------------------------------------------------------------
    --! @brief 入力信号のどれかに変化があるまで待つサブプログラム.
    -------------------------------------------------------------------------------
    procedure  WAIT_ON_SIGNALS is
    begin
        wait on 
            ACLK       , -- In  :
            ARADDR_I   , -- In  :
            ARLEN_I    , -- In  :
            ARSIZE_I   , -- In  :
            ARBURST_I  , -- In  :
            ARLOCK_I   , -- In  :
            ARCACHE_I  , -- In  :
            ARPROT_I   , -- In  :
            ARQOS_I    , -- In  :
            ARREGION_I , -- In  :
            ARUSER_I   , -- In  :
            ARID_I     , -- In  :
            ARVALID_I  , -- In  :
            ARREADY_I  , -- In  :
            AWADDR_I   , -- In  :
            AWLEN_I    , -- In  :
            AWSIZE_I   , -- In  :
            AWBURST_I  , -- In  :
            AWLOCK_I   , -- In  :
            AWCACHE_I  , -- In  :
            AWPROT_I   , -- In  :
            AWQOS_I    , -- In  :
            AWREGION_I , -- In  :
            AWUSER_I   , -- In  :
            AWID_I     , -- In  :
            AWVALID_I  , -- In  :
            AWREADY_I  , -- In  :
            RLAST_I    , -- In  :
            RDATA_I    , -- In  :
            RRESP_I    , -- In  :
            RUSER_I    , -- In  :
            RID_I      , -- In  :
            RVALID_I   , -- In  :
            RREADY_I   , -- In  :
            WLAST_I    , -- In  :
            WDATA_I    , -- In  :
            WSTRB_I    , -- In  :
            WUSER_I    , -- In  :
            WID_I      , -- In  :
            WVALID_I   , -- In  :
            WREADY_I   , -- In  :
            BRESP_I    , -- In  :
            BUSER_I    , -- In  :
            BID_I      , -- In  :
            BVALID_I   , -- In  :
            BREADY_I   , -- In  :
            GPI        ; -- In  :
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 全チャネルの期待値と信号の値を比較するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SIGNALS     信号の期待値.
    --! @param    MATCH       比較した結果。マッチすれば TRUE、しなければ FALSE.
    -------------------------------------------------------------------------------
    procedure MATCH_AXI4_CHANNEL(
                  SIGNALS       : in    AXI4_CHANNEL_SIGNAL_TYPE;
                  MATCH         : out   boolean
    ) is
        variable  ar_match      :       boolean;
        variable  aw_match      :       boolean;
        variable  r_match       :       boolean;
        variable  w_match       :       boolean;
    begin
        ---------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナルの比較
        ---------------------------------------------------------------------------
        if (WRITE_ENABLE) then
            aw_match := MATCH_STD_LOGIC(SIGNALS.AW.VALID               ,AWVALID_I ) and 
                        MATCH_STD_LOGIC(SIGNALS.AW.READY               ,AWREADY_I ) and 
                        MATCH_STD_LOGIC(SIGNALS.AW.ID(AWID_I'range)    ,AWID_I    ) and 
                        MATCH_STD_LOGIC(SIGNALS.AW.ADDR(AWADDR_I'range),AWADDR_I  ) and 
                        MATCH_STD_LOGIC(SIGNALS.AW.LEN                 ,AWLEN_I   ) and 
                        MATCH_STD_LOGIC(SIGNALS.AW.SIZE                ,AWSIZE_I  ) and 
                        MATCH_STD_LOGIC(SIGNALS.AW.BURST               ,AWBURST_I ) and 
                        MATCH_STD_LOGIC(SIGNALS.AW.LOCK                ,AWLOCK_I  ) and 
                        MATCH_STD_LOGIC(SIGNALS.AW.CACHE               ,AWCACHE_I ) and 
                        MATCH_STD_LOGIC(SIGNALS.AW.PROT                ,AWPROT_I  ) and
                        MATCH_STD_LOGIC(SIGNALS.AW.QOS                 ,AWQOS_I   ) and
                        MATCH_STD_LOGIC(SIGNALS.AW.REGION              ,AWREGION_I) and
                        MATCH_STD_LOGIC(SIGNALS.AW.USER(AWUSER_I'range),AWUSER_I  );
        else
            aw_match := TRUE;
        end if;
        ---------------------------------------------------------------------------
        -- ライトチャネルシグナル/ライト応答チャネルシグナルの比較
        ---------------------------------------------------------------------------
        if (WRITE_ENABLE) then
            w_match  := MATCH_STD_LOGIC(SIGNALS.W.VALID                ,WVALID_I  ) and 
                        MATCH_STD_LOGIC(SIGNALS.W.READY                ,WREADY_I  ) and 
                        MATCH_STD_LOGIC(SIGNALS.B.VALID                ,BVALID_I  ) and 
                        MATCH_STD_LOGIC(SIGNALS.B.READY                ,BREADY_I  ) and
                        MATCH_STD_LOGIC(SIGNALS.W.ID(WID_I'range)      ,WID_I     ) and 
                        MATCH_STD_LOGIC(SIGNALS.B.ID(BID_I'range)      ,BID_I     ) and 
                        MATCH_STD_LOGIC(SIGNALS.W.DATA(WDATA_I'range)  ,WDATA_I   ) and 
                        MATCH_STD_LOGIC(SIGNALS.W.STRB(WSTRB_I'range)  ,WSTRB_I   ) and 
                        MATCH_STD_LOGIC(SIGNALS.W.LAST                 ,WLAST_I   ) and 
                        MATCH_STD_LOGIC(SIGNALS.B.RESP                 ,BRESP_I   ) and
                        MATCH_STD_LOGIC(SIGNALS.W.USER(WUSER_I'range)  ,WUSER_I   ) and 
                        MATCH_STD_LOGIC(SIGNALS.B.USER(BUSER_I'range)  ,BUSER_I   );
        else
            w_match  := TRUE;
        end if;
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナルの比較
        ---------------------------------------------------------------------------
        if (READ_ENABLE) then
            ar_match := MATCH_STD_LOGIC(SIGNALS.AR.VALID               ,ARVALID_I ) and 
                        MATCH_STD_LOGIC(SIGNALS.AR.READY               ,ARREADY_I ) and 
                        MATCH_STD_LOGIC(SIGNALS.AR.ID(ARID_I'range)    ,ARID_I    ) and 
                        MATCH_STD_LOGIC(SIGNALS.AR.ADDR(ARADDR_I'range),ARADDR_I  ) and 
                        MATCH_STD_LOGIC(SIGNALS.AR.LEN                 ,ARLEN_I   ) and 
                        MATCH_STD_LOGIC(SIGNALS.AR.SIZE                ,ARSIZE_I  ) and 
                        MATCH_STD_LOGIC(SIGNALS.AR.BURST               ,ARBURST_I ) and 
                        MATCH_STD_LOGIC(SIGNALS.AR.LOCK                ,ARLOCK_I  ) and 
                        MATCH_STD_LOGIC(SIGNALS.AR.CACHE               ,ARCACHE_I ) and 
                        MATCH_STD_LOGIC(SIGNALS.AR.PROT                ,ARPROT_I  ) and
                        MATCH_STD_LOGIC(SIGNALS.AR.QOS                 ,ARQOS_I   ) and
                        MATCH_STD_LOGIC(SIGNALS.AR.REGION              ,ARREGION_I) and
                        MATCH_STD_LOGIC(SIGNALS.AR.USER(ARUSER_I'range),ARUSER_I  );
        else
            ar_match := TRUE;
        end if;
        ---------------------------------------------------------------------------
        -- リードデータチャネルシグナルの比較
        ---------------------------------------------------------------------------
        if (READ_ENABLE) then
            r_match  := MATCH_STD_LOGIC(SIGNALS.R.VALID                ,RVALID_I  ) and 
                        MATCH_STD_LOGIC(SIGNALS.R.READY                ,RREADY_I  ) and 
                        MATCH_STD_LOGIC(SIGNALS.R.ID(RID_I'range)      ,RID_I     ) and 
                        MATCH_STD_LOGIC(SIGNALS.R.DATA(RDATA_I'range)  ,RDATA_I   ) and 
                        MATCH_STD_LOGIC(SIGNALS.R.LAST                 ,RLAST_I   ) and 
                        MATCH_STD_LOGIC(SIGNALS.R.USER(RUSER_I'range)  ,RUSER_I   );
        else
            r_match  := TRUE;
        end if;
        MATCH := ar_match and aw_match and r_match and w_match;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief アドレスチャネルの期待値と信号の値を比較するサブプログラム.
    -------------------------------------------------------------------------------
    procedure MATCH_AXI4_CHANNEL(
        variable  CORE          : inout CORE_TYPE;
                  NAME          : in    STRING;
                  SIGNALS       : in    AXI4_A_CHANNEL_SIGNAL_TYPE;
                  MATCH         : out   boolean;
        signal    ADDR          : in    std_logic_vector;
        signal    LEN           : in    AXI4_ALEN_TYPE;
        signal    SIZE          : in    AXI4_ASIZE_TYPE;
        signal    BURST         : in    AXI4_ABURST_TYPE;
        signal    LOCK          : in    AXI4_ALOCK_TYPE;
        signal    CACHE         : in    AXI4_ACACHE_TYPE;
        signal    PROT          : in    AXI4_APROT_TYPE;
        signal    QOS           : in    AXI4_AQOS_TYPE;
        signal    REGION        : in    AXI4_AREGION_TYPE;
        signal    USER          : in    std_logic_vector;
        signal    ID            : in    std_logic_vector;
        signal    VALID         : in    std_logic;
        signal    READY         : in    std_logic
    ) is
        variable  count         :       integer;
    begin
        count := 0;
        if (MATCH_STD_LOGIC(SIGNALS.VALID           ,VALID ) = FALSE) then
            REPORT_MISMATCH(CORE, NAME & "VALID " &
                            BIN_TO_STRING(VALID) & " /= " &
                            BIN_TO_STRING(SIGNALS.VALID));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.READY           ,READY ) = FALSE) then
            REPORT_MISMATCH(CORE, NAME & "READY " & 
                            BIN_TO_STRING(READY) & " /= " &
                            BIN_TO_STRING(SIGNALS.READY));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.ADDR(ADDR'range),ADDR  ) = FALSE) then
            REPORT_MISMATCH(CORE, NAME & "ADDR " &
                            HEX_TO_STRING(ADDR ) & " /= " &
                            HEX_TO_STRING(SIGNALS.ADDR(ADDR'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.LEN             ,LEN   ) = FALSE) then
            REPORT_MISMATCH(CORE, NAME & "LEN " &
                            BIN_TO_STRING(LEN  ) & " /= " &
                            BIN_TO_STRING(SIGNALS.LEN));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.SIZE            ,SIZE  ) = FALSE) then
            REPORT_MISMATCH(CORE, NAME & "SIZE " &
                            BIN_TO_STRING(SIZE ) & " /= " &
                            BIN_TO_STRING(SIGNALS.SIZE));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.BURST           ,BURST ) = FALSE) then
            REPORT_MISMATCH(CORE, NAME & "BURST " &
                            BIN_TO_STRING(BURST) & " /= " &
                            BIN_TO_STRING(SIGNALS.BURST));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.LOCK            ,LOCK  ) = FALSE) then
            REPORT_MISMATCH(CORE, NAME & "LOCK " &
                            BIN_TO_STRING(LOCK ) & " /= " &
                            BIN_TO_STRING(SIGNALS.LOCK));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.CACHE           ,CACHE ) = FALSE) then
            REPORT_MISMATCH(CORE, NAME & "CACHE " &
                            BIN_TO_STRING(CACHE) & " /= " &
                            BIN_TO_STRING(SIGNALS.CACHE));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.PROT            ,PROT  ) = FALSE) then
            REPORT_MISMATCH(CORE, NAME & "PROT " &
                            BIN_TO_STRING(PROT ) & " /= " &
                            BIN_TO_STRING(SIGNALS.PROT));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.QOS             ,QOS   ) = FALSE) then
            REPORT_MISMATCH(CORE, NAME & "QOS " &
                            HEX_TO_STRING(QOS  ) & " /= " &
                            HEX_TO_STRING(SIGNALS.QOS));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.REGION          ,REGION) = FALSE) then
            REPORT_MISMATCH(CORE, NAME & "REGION " &
                            HEX_TO_STRING(REGION) & " /= " &
                            HEX_TO_STRING(SIGNALS.REGION));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.ID(ID'range)    ,ID    ) = FALSE) then
            REPORT_MISMATCH(CORE, NAME & "ID " &
                            HEX_TO_STRING(ID   ) & " /= " &
                            HEX_TO_STRING(SIGNALS.ID(ID'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.USER(USER'range),USER  ) = FALSE) then
            REPORT_MISMATCH(CORE, NAME & "USER " &
                            HEX_TO_STRING(USER ) & " /= " &
                            HEX_TO_STRING(SIGNALS.USER(USER'range)));
            count := count + 1;
        end if;
        MATCH := (count = 0);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ライトアドレスチャネルの期待値と信号の値を比較するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    CORE        コア変数.
    --! @param    SIGNALS     信号の期待値.
    --! @param    MATCH       比較した結果。マッチすれば TRUE、しなければ FALSE.
    -------------------------------------------------------------------------------
    procedure MATCH_AXI4_AW_CHANNEL(
        variable  CORE      : inout CORE_TYPE;
                  SIGNALS   : in    AXI4_A_CHANNEL_SIGNAL_TYPE;
                  MATCH     : out   boolean
    ) is
    begin
        MATCH_AXI4_CHANNEL(
            CORE        => CORE         , -- I/O :
            NAME        => "AW"         , -- In  :
            SIGNALS     => SIGNALS      , -- In  :
            MATCH       => MATCH        , -- Out :
            ADDR        => AWADDR_I     , -- In  :
            LEN         => AWLEN_I      , -- In  :
            SIZE        => AWSIZE_I     , -- In  :
            BURST       => AWBURST_I    , -- In  :
            LOCK        => AWLOCK_I     , -- In  :
            CACHE       => AWCACHE_I    , -- In  :
            PROT        => AWPROT_I     , -- In  :
            QOS         => AWQOS_I      , -- In  :
            REGION      => AWREGION_I   , -- In  :
            USER        => AWUSER_I     , -- In  :
            ID          => AWID_I       , -- In  :
            VALID       => AWVALID_I    , -- In  :
            READY       => AWREADY_I      -- In  :
        );
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief リードアドレスチャネルの期待値と信号の値を比較するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    CORE        コア変数.
    --! @param    SIGNALS     信号の期待値.
    --! @param    MATCH       比較した結果。マッチすれば TRUE、しなければ FALSE.
    -------------------------------------------------------------------------------
    procedure MATCH_AXI4_AR_CHANNEL(
        variable  CORE      : inout CORE_TYPE;
                  SIGNALS   : in    AXI4_A_CHANNEL_SIGNAL_TYPE;
                  MATCH     : out   boolean
    ) is
    begin
        MATCH_AXI4_CHANNEL(
            CORE        => CORE         , -- I/O :
            NAME        => "AR"         , -- In  :
            SIGNALS     => SIGNALS      , -- In  :
            MATCH       => MATCH        , -- Out :
            ADDR        => ARADDR_I     , -- In  :
            LEN         => ARLEN_I      , -- In  :
            SIZE        => ARSIZE_I     , -- In  :
            BURST       => ARBURST_I    , -- In  :
            LOCK        => ARLOCK_I     , -- In  :
            CACHE       => ARCACHE_I    , -- In  :
            PROT        => ARPROT_I     , -- In  :
            QOS         => ARQOS_I      , -- In  :
            REGION      => ARREGION_I   , -- In  :
            USER        => ARUSER_I     , -- In  :
            ID          => ARID_I       , -- In  :
            VALID       => ARVALID_I    , -- In  :
            READY       => ARREADY_I      -- In  :
        );
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ライトデータチャネルの期待値と信号の値を比較するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    CORE        コア変数.
    --! @param    SIGNALS     信号の期待値.
    --! @param    MATCH       比較した結果。マッチすれば TRUE、しなければ FALSE.
    -------------------------------------------------------------------------------
    procedure MATCH_AXI4_W_CHANNEL(
        variable  CORE      : inout CORE_TYPE;
                  SIGNALS   : in    AXI4_W_CHANNEL_SIGNAL_TYPE;
                  MATCH     : out   boolean
    ) is
        variable  count     :       integer;
    begin
        count := 0;
        if (MATCH_STD_LOGIC(SIGNALS.VALID              ,WVALID_I) = FALSE) then
            REPORT_MISMATCH(CORE, "WVALID " & 
                            BIN_TO_STRING(WVALID_I) & " /= " &
                            BIN_TO_STRING(SIGNALS.VALID));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.READY              ,WREADY_I) = FALSE) then
            REPORT_MISMATCH(CORE, "WREADY " &
                            BIN_TO_STRING(WREADY_I) & " /= " &
                            BIN_TO_STRING(SIGNALS.READY));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.DATA(WDATA_I'range),WDATA_I ) = FALSE) then
            REPORT_MISMATCH(CORE, "WDATA " &
                            HEX_TO_STRING(WDATA_I ) & " /= " &
                            HEX_TO_STRING(SIGNALS.DATA(WDATA_I'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.STRB(WSTRB_I'range),WSTRB_I ) = FALSE) then
            REPORT_MISMATCH(CORE, "WSTRB " &
                            BIN_TO_STRING(WSTRB_I ) & " /= " &
                            BIN_TO_STRING(SIGNALS.STRB(WSTRB_I'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.LAST               ,WLAST_I ) = FALSE) then
            REPORT_MISMATCH(CORE, "WLAST " &
                            BIN_TO_STRING(WLAST_I ) & " /= " &
                            BIN_TO_STRING(SIGNALS.LAST));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.ID(WID_I'range)    ,WID_I   ) = FALSE) then
            REPORT_MISMATCH(CORE, "WID " &
                            HEX_TO_STRING(WID_I   ) & " /= " &
                            HEX_TO_STRING(SIGNALS.ID(WID_I'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.USER(WUSER_I'range),WUSER_I ) = FALSE) then
            REPORT_MISMATCH(CORE, "WUSER " &
                            HEX_TO_STRING(WUSER_I ) & " /= " &
                            HEX_TO_STRING(SIGNALS.USER(WUSER_I'range)));
            count := count + 1;
        end if;
        MATCH := (count = 0);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ライト応答チャネルの期待値と信号の値を比較するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    CORE        コア変数.
    --! @param    SIGNALS     信号の期待値.
    --! @param    MATCH       比較した結果。マッチすれば TRUE、しなければ FALSE.
    -------------------------------------------------------------------------------
    procedure MATCH_AXI4_B_CHANNEL(
        variable  CORE      : inout CORE_TYPE;
                  SIGNALS   : in    AXI4_B_CHANNEL_SIGNAL_TYPE;
                  MATCH     : out   boolean
    ) is
        variable  count     :       integer;
    begin
        count := 0;
        if (MATCH_STD_LOGIC(SIGNALS.VALID              ,BVALID_I) = FALSE) then
            REPORT_MISMATCH(CORE, "BVALID " & 
                            BIN_TO_STRING(BVALID_I)  & " /= " &
                            BIN_TO_STRING(SIGNALS.VALID));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.READY              ,BREADY_I) = FALSE) then
            REPORT_MISMATCH(CORE, "BREADY " &
                            BIN_TO_STRING(BREADY_I)  & " /= " &
                            BIN_TO_STRING(SIGNALS.READY));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.RESP               ,BRESP_I ) = FALSE) then
            REPORT_MISMATCH(CORE, "BRESP "  &
                            BIN_TO_STRING(BRESP_I )  & " /= " &
                            BIN_TO_STRING(SIGNALS.RESP));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.ID(BID_I'range)    ,BID_I   ) = FALSE) then
            REPORT_MISMATCH(CORE, "BID "    &
                            HEX_TO_STRING(BID_I   )  & " /= " &
                            HEX_TO_STRING(SIGNALS.ID(BID_I'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.USER(BUSER_I'range),BUSER_I ) = FALSE) then
            REPORT_MISMATCH(CORE, "BUSER "  &
                            HEX_TO_STRING(BUSER_I )  & " /= " &
                            HEX_TO_STRING(SIGNALS.USER(BUSER_I'range)));
            count := count + 1;
        end if;
        MATCH := (count = 0);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief リードデータチャネルの期待値と信号の値を比較するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    CORE        コア変数.
    --! @param    SIGNALS     信号の期待値.
    --! @param    MATCH       比較した結果。マッチすれば TRUE、しなければ FALSE.
    -------------------------------------------------------------------------------
    procedure MATCH_AXI4_R_CHANNEL(
        variable  CORE      : inout CORE_TYPE;
                  SIGNALS   : in    AXI4_R_CHANNEL_SIGNAL_TYPE;
                  MATCH     : out   boolean
    ) is
        variable  count     :       integer;
    begin
        count := 0;
        if (MATCH_STD_LOGIC(SIGNALS.VALID              ,RVALID_I) = FALSE) then
            REPORT_MISMATCH(CORE, "RVALID " & 
                            BIN_TO_STRING(RVALID_I) & " /= " &
                            BIN_TO_STRING(SIGNALS.VALID));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.READY              ,RREADY_I) = FALSE) then
            REPORT_MISMATCH(CORE, "RREADY " &
                            BIN_TO_STRING(RREADY_I) & " /= " &
                            BIN_TO_STRING(SIGNALS.READY));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.DATA(RDATA_I'range),RDATA_I ) = FALSE) then
            REPORT_MISMATCH(CORE, "RDATA " &
                            HEX_TO_STRING(RDATA_I ) & " /= " &
                            HEX_TO_STRING(SIGNALS.DATA(RDATA_I'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.LAST               ,RLAST_I ) = FALSE) then
            REPORT_MISMATCH(CORE, "RLAST " &
                            BIN_TO_STRING(RLAST_I ) & " /= " &
                            BIN_TO_STRING(SIGNALS.LAST));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.RESP               ,RRESP_I ) = FALSE) then
            REPORT_MISMATCH(CORE, "RRESP " &
                            BIN_TO_STRING(RRESP_I ) & " /= " &
                            BIN_TO_STRING(SIGNALS.RESP));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.ID(RID_I'range)    ,RID_I   ) = FALSE) then
            REPORT_MISMATCH(CORE, "RID " &
                            HEX_TO_STRING(RID_I   ) & " /= " &
                            HEX_TO_STRING(SIGNALS.ID(RID_I'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.USER(RUSER_I'range),RUSER_I ) = FALSE) then
            REPORT_MISMATCH(CORE, "RUSER " &
                            HEX_TO_STRING(RUSER_I ) & " /= " &
                            HEX_TO_STRING(SIGNALS.USER(RUSER_I'range)));
            count := count + 1;
        end if;
        MATCH := (count = 0);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 全チャネルの期待値と信号の値を比較するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    CORE        コア変数.
    --! @param    SIGNALS     信号の期待値.
    --! @param    MATCH       比較した結果。マッチすれば TRUE、しなければ FALSE.
    -------------------------------------------------------------------------------
    procedure  MATCH_AXI4_CHANNEL(
        variable  CORE      : inout CORE_TYPE;
                  SIGNALS   : in    AXI4_CHANNEL_SIGNAL_TYPE;
                  MATCH     : out   boolean
    ) is
        variable  aw_match  :       boolean;
        variable  w_match   :       boolean;
        variable  b_match   :       boolean;
        variable  ar_match  :       boolean;
        variable  r_match   :       boolean;
    begin
        if (WRITE_ENABLE) then
            MATCH_AXI4_AW_CHANNEL(CORE, SIGNALS.AW, aw_match);
            MATCH_AXI4_W_CHANNEL (CORE, SIGNALS.W , w_match );
            MATCH_AXI4_B_CHANNEL (CORE, SIGNALS.B , b_match );
        else
            aw_match := TRUE;
            w_match  := TRUE;
            b_match  := TRUE;
        end if;
        if (READ_ENABLE) then
            MATCH_AXI4_AR_CHANNEL(CORE, SIGNALS.AR, ar_match);
            MATCH_AXI4_R_CHANNEL (CORE, SIGNALS.R , r_match );
        else
            ar_match := TRUE;
            r_match  := TRUE;
        end if;
        MATCH := aw_match and w_match and b_match and ar_match and r_match;
    end procedure;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure  WAIT_UNTIL_XFER_AR(
        variable  CORE      : inout CORE_TYPE;
                  PROC_NAME : in    STRING;
                  TIMEOUT   : in    integer
    ) is
        variable  count     :       integer;
    begin
        count := 0;
        WAIT_LOOP: loop
            wait until (ACLK'event and ACLK = '1');
            exit when  (ARVALID_I = '1' and ARREADY_I = '1');
            if (count >= TIMEOUT) then
                EXECUTE_ABORT(core, PROC_NAME, "WAIT AR Time Out!");
            end if;
            count := count + 1;
        end loop;
    end procedure;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure  WAIT_UNTIL_XFER_AW(
        variable  CORE      : inout CORE_TYPE;
                  PROC_NAME : in    STRING;
                  TIMEOUT   : in    integer
    ) is
        variable  count     :       integer;
    begin
        count := 0;
        WAIT_LOOP: loop
            wait until (ACLK'event and ACLK = '1');
            exit when  (AWVALID_I = '1' and AWREADY_I = '1');
            if (count >= TIMEOUT) then
                EXECUTE_ABORT(core, PROC_NAME, "WAIT AW Time Out!");
            end if;
            count := count + 1;
        end loop;
    end procedure;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure  WAIT_UNTIL_XFER_R(
        variable  CORE      : inout CORE_TYPE;
                  PROC_NAME : in    STRING;
                  TIMEOUT   : in    integer;
                  LAST      : in    std_logic
    ) is
        variable  count     :       integer;
    begin
        count := 0;
        WAIT_LOOP: loop
            wait until (ACLK'event and ACLK = '1');
            exit when  (RVALID_I = '1' and RREADY_I = '1' and (LAST = '0' or RLAST_I = '1'));
            if (count >= TIMEOUT) then
                EXECUTE_ABORT(core, PROC_NAME, "WAIT R Time Out!");
            end if;
            count := count + 1;
        end loop;
    end procedure;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure  WAIT_UNTIL_XFER_W(
        variable  CORE      : inout CORE_TYPE;
                  PROC_NAME : in    STRING;
                  TIMEOUT   : in    integer;
                  LAST      : in    std_logic
    ) is
        variable  count     :       integer;
    begin
        count := 0;
        WAIT_LOOP: loop
            wait until (ACLK'event and ACLK = '1');
            exit when  (WVALID_I = '1' and WREADY_I = '1' and (LAST = '0' or WLAST_I = '1'));
            if (count >= TIMEOUT) then
                EXECUTE_ABORT(core, PROC_NAME, "WAIT W Time Out!");
            end if;
            count := count + 1;
        end loop;
    end procedure;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure  WAIT_UNTIL_XFER_B(
        variable  CORE      : inout CORE_TYPE;
                  PROC_NAME : in    STRING;
                  TIMEOUT   : in    integer
    ) is
        variable  count     :       integer;
    begin
        count := 0;
        WAIT_LOOP: loop
            wait until (ACLK'event and ACLK = '1');
            exit when  (BVALID_I = '1' and BREADY_I = '1');
            if (count >= TIMEOUT) then
                EXECUTE_ABORT(core, PROC_NAME, "WAIT B Time Out!");
            end if;
            count := count + 1;
        end loop;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief チャネル信号変数の初期化.
    -------------------------------------------------------------------------------
    function  GEN_INIT_SIGNALS return AXI4_CHANNEL_SIGNAL_TYPE is
        variable  value : AXI4_CHANNEL_SIGNAL_TYPE;
    begin
        value := AXI4_CHANNEL_SIGNAL_DONTCARE;
        if (MASTER) then
            case CHANNEL is
                when AXI4_CHANNEL_AR =>
                    value.AR       := AXI4_A_CHANNEL_SIGNAL_NULL;
                    value.AR.READY := '-';
                when AXI4_CHANNEL_AW =>
                    value.AW       := AXI4_A_CHANNEL_SIGNAL_NULL;
                    value.AW.READY := '-';
                when AXI4_CHANNEL_W  =>
                    value.W        := AXI4_W_CHANNEL_SIGNAL_NULL;
                    value.W.READY  := '-';
                when AXI4_CHANNEL_R  => 
                    value.R        := AXI4_R_CHANNEL_SIGNAL_DONTCARE;
                    value.R.READY  := '0';
                when AXI4_CHANNEL_B  =>
                    value.B        := AXI4_B_CHANNEL_SIGNAL_DONTCARE;
                    value.B.READY  := '0';
                when others =>
                    null;
            end case;
        end if;
        if (SLAVE) then
            case CHANNEL is
                when AXI4_CHANNEL_AR =>
                    value.AR       := AXI4_A_CHANNEL_SIGNAL_DONTCARE;
                    value.AR.READY := '0';
                when AXI4_CHANNEL_AW =>
                    value.AW       := AXI4_A_CHANNEL_SIGNAL_DONTCARE;
                    value.AW.READY := '0';
                when AXI4_CHANNEL_W  =>
                    value.W        := AXI4_W_CHANNEL_SIGNAL_DONTCARE;
                    value.W.READY  := '0';
                when AXI4_CHANNEL_R  => 
                    value.R        := AXI4_R_CHANNEL_SIGNAL_NULL;
                    value.R.READY  := '-';
                when AXI4_CHANNEL_B  => 
                    value.B        := AXI4_B_CHANNEL_SIGNAL_NULL;
                    value.B.READY  := '-';
                when others =>
                    null;
            end case;
        end if;
        return value;
    end function;
    constant  INIT_SIGNALS  : AXI4_CHANNEL_SIGNAL_TYPE := GEN_INIT_SIGNALS;
    -------------------------------------------------------------------------------
    -- キーワードの定義.
    -------------------------------------------------------------------------------
    subtype   KEYWORD_TYPE is STRING(1 to 5);
    constant  KEY_NULL      : KEYWORD_TYPE := "     ";
    constant  KEY_AR        : KEYWORD_TYPE := "AR   ";
    constant  KEY_AW        : KEYWORD_TYPE := "AW   ";
    constant  KEY_W         : KEYWORD_TYPE := "W    ";
    constant  KEY_R         : KEYWORD_TYPE := "R    ";
    constant  KEY_B         : KEYWORD_TYPE := "B    ";
    constant  KEY_SAY       : KEYWORD_TYPE := "SAY  ";
    constant  KEY_SYNC      : KEYWORD_TYPE := "SYNC ";
    constant  KEY_WAIT      : KEYWORD_TYPE := "WAIT ";
    constant  KEY_CHECK     : KEYWORD_TYPE := "CHECK";
    constant  KEY_OUT       : KEYWORD_TYPE := "OUT  ";
    constant  KEY_DEBUG     : KEYWORD_TYPE := "DEBUG";
    constant  KEY_REPORT    : KEYWORD_TYPE := "REPOR";
    constant  KEY_READ      : KEYWORD_TYPE := "READ ";
    constant  KEY_WRITE     : KEYWORD_TYPE := "WRITE";
    function  GENERATE_KEY_CHANNEL return KEYWORD_TYPE is
    begin
        case CHANNEL is
            when AXI4_CHANNEL_AR => return KEY_AR;
            when AXI4_CHANNEL_AW => return KEY_AW;
            when AXI4_CHANNEL_R  => return KEY_R;
            when AXI4_CHANNEL_W  => return KEY_W;
            when AXI4_CHANNEL_B  => return KEY_B;
            when others          => return KEY_NULL;
        end case;
    end function;
    constant  KEY_CHANNEL   : KEYWORD_TYPE := GENERATE_KEY_CHANNEL;
    -------------------------------------------------------------------------------
    --! @brief ローカル同期オペレーション.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    CORE        コア変数.
    --! @param    SYNC_REQ    同期開始信号出力.
    --! @param    SYNC_ACK    同期応答信号入力.
    -------------------------------------------------------------------------------
    procedure LOCAL_SYNC(
        variable  CORE       : inout CORE_TYPE;
        signal    SYNC_REQ   : out   SYNC_REQ_VECTOR(0 downto 0);
        signal    SYNC_ACK   : in    SYNC_ACK_VECTOR(0 downto 0)
    ) is
        constant  PROC_NAME  :       string := "LOCAL_SYNC";
        variable  sync_count :       SYNC_REQ_VECTOR(0 downto 0);
    begin
        REPORT_DEBUG(CORE, PROC_NAME, "BEGIN");
        sync_count(0) := SYNC_LOCAL_WAIT;
        SYNC_BEGIN(SYNC_REQ,           sync_count);
        REPORT_DEBUG(CORE, PROC_NAME, "SYNC");
        SYNC_END  (SYNC_REQ, SYNC_ACK, sync_count);
        REPORT_DEBUG(CORE, PROC_NAME, "END");
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief CHECKオペレーション.信号が指定された値になっているかチェック.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    CORE        コア変数.
    --! @param    STREAM      入力ストリーム.
    -------------------------------------------------------------------------------
    procedure EXECUTE_CHECK(
        variable  CORE           : inout CORE_TYPE;
        file      STREAM         :       TEXT
    ) is
        constant  PROC_NAME      : string := "EXECUTE_CHECK";
        variable  next_event     : EVENT_TYPE;
        variable  keyword        : KEYWORD_TYPE;
        variable  match          : boolean;
        variable  axi_signals    : AXI4_CHANNEL_SIGNAL_TYPE;
        variable  gpi_signals    : std_logic_vector(GPI'range);
    begin
        REPORT_DEBUG(CORE, PROC_NAME, "BEGIN");
        SEEK_EVENT(CORE, STREAM, next_event);
        case next_event is
            when EVENT_MAP_BEGIN =>
                READ_EVENT(CORE, STREAM, EVENT_MAP_BEGIN);
                axi_signals := AXI4_CHANNEL_SIGNAL_DONTCARE;
                gpi_signals := (others => '-');
                MAP_READ_LOOP: loop
                    MAP_READ_PREPARE_FOR_NEXT(
                        SELF       => CORE            ,  -- I/O:
                        STREAM     => STREAM          ,  -- I/O:
                        EVENT      => next_event         -- I/O:
                    );
                    MAP_READ_AXI4_CHANNEL(
                        CORE       => CORE            ,  -- I/O:
                        STREAM     => STREAM          ,  -- I/O:
                        CHANNEL    => CHANNEL         ,  -- In :
                        READ       => READ_ENABLE     ,  -- In :
                        WRITE      => WRITE_ENABLE    ,  -- In :
                        WIDTH      => WIDTH           ,  -- In :
                        SIGNALS    => axi_signals     ,  -- I/O:
                        EVENT      => next_event         -- I/O:
                    );
                    MAP_READ_STD_LOGIC_VECTOR(
                        SELF       => CORE            ,  -- I/O:
                        STREAM     => STREAM          ,  -- I/O:
                        KEY        => "GPI"           ,  -- In :
                        VAL        => gpi_signals     ,  -- I/O:
                        EVENT      => next_event         -- I/O:
                    );
                    case next_event is
                        when EVENT_SCALAR  =>
                            COPY_KEY_WORD(CORE, keyword);
                            EXECUTE_UNDEFINED_MAP_KEY(CORE, STREAM, keyword);
                        when EVENT_MAP_END =>
                            exit MAP_READ_LOOP;
                        when others        =>
                            READ_ERROR(CORE, PROC_NAME, "need EVENT_MAP_END but " &
                                       EVENT_TO_STRING(next_event));
                    end case;
                end loop;
                MATCH_AXI4_CHANNEL(CORE, axi_signals, match);
                MATCH_GPI         (CORE, gpi_signals, GPI, match);
            when others =>
                READ_ERROR(CORE, PROC_NAME, "SEEK_EVENT NG");
        end case;
        REPORT_DEBUG(CORE, PROC_NAME, "END");
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief  WAITオペレーション. 指定された条件まで待機.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    CORE        コア変数.
    --! @param    STREAM      入力ストリーム.
    -------------------------------------------------------------------------------
    procedure EXECUTE_WAIT(
        variable  CORE           : inout CORE_TYPE;
        file      STREAM         :       TEXT
    ) is
        constant  PROC_NAME      : string := "EXECUTE_WAIT";
        variable  next_event     : EVENT_TYPE;
        variable  keyword        : KEYWORD_TYPE;
        variable  wait_count     : integer;
        variable  scan_len       : integer;
        variable  timeout        : integer;
        variable  wait_on        : boolean;
        variable  axi_match      : boolean;
        variable  gpi_match      : boolean;
        variable  axi_signals    : AXI4_CHANNEL_SIGNAL_TYPE;
        variable  gpi_signals    : std_logic_vector(GPI'range);
    begin
        REPORT_DEBUG(CORE, PROC_NAME, "BEGIN");
        timeout   := DEFAULT_WAIT_TIMEOUT;
        wait_on   := FALSE;
        SEEK_EVENT(CORE, STREAM, next_event);
        case next_event is
            when EVENT_SCALAR =>
                READ_EVENT(CORE, STREAM, EVENT_SCALAR);
                STRING_TO_INTEGER(
                    STR     => CORE.str_buf(1 to CORE.str_len),
                    VAL     => wait_count,
                    STR_LEN => scan_len
                );
                if (scan_len = 0) then
                    wait_count := 1;
                end if;
                if (wait_count > 0) then
                    for i in 1 to wait_count loop
                        wait until (ACLK'event and ACLK = '1');
                    end loop;
                end if;
                wait_count := 0;
            when EVENT_MAP_BEGIN =>
                READ_EVENT(CORE, STREAM, EVENT_MAP_BEGIN);
                axi_signals := AXI4_CHANNEL_SIGNAL_DONTCARE;
                gpi_signals := (others => '-');
                MAP_READ_LOOP: loop
                    REPORT_DEBUG(core, PROC_NAME, "MAP_READ_LOOP");
                    MAP_READ_PREPARE_FOR_NEXT(
                        SELF       => CORE            ,  -- I/O:
                        STREAM     => STREAM          ,  -- I/O:
                        EVENT      => next_event         -- I/O:
                    );
                    MAP_READ_AXI4_CHANNEL(
                        CORE       => CORE            ,  -- I/O:
                        STREAM     => STREAM          ,  -- I/O:
                        CHANNEL    => CHANNEL         ,  -- In :
                        READ       => READ_ENABLE     ,  -- In :
                        WRITE      => WRITE_ENABLE    ,  -- In :
                        WIDTH      => WIDTH           ,  -- In :
                        SIGNALS    => axi_signals     ,  -- I/O:
                        EVENT      => next_event         -- I/O:
                    );
                    MAP_READ_STD_LOGIC_VECTOR(
                        SELF       => CORE            ,  -- I/O:
                        STREAM     => STREAM          ,  -- I/O:
                        KEY        => "GPI"           ,  -- In :
                        VAL        => gpi_signals     ,  -- I/O:
                        EVENT      => next_event         -- I/O:
                    );
                    MAP_READ_INTEGER(
                        SELF       => CORE            ,  -- I/O:
                        STREAM     => STREAM          ,  -- I/O:
                        KEY        => "TIMEOUT"       ,  -- In :
                        VAL        => timeout         ,  -- I/O:
                        EVENT      => next_event         -- I/O:
                    );
                    MAP_READ_BOOLEAN(
                        SELF       => CORE            ,  -- I/O:
                        STREAM     => STREAM          ,  -- I/O:
                        KEY        => "ON"            ,  -- In :
                        VAL        => wait_on         ,  -- I/O:
                        EVENT      => next_event         -- I/O:
                    );
                    case next_event is
                        when EVENT_SCALAR  =>
                            COPY_KEY_WORD(CORE, keyword);
                            EXECUTE_UNDEFINED_MAP_KEY(CORE, STREAM, keyword);
                        when EVENT_MAP_END =>
                            exit MAP_READ_LOOP;
                        when others        =>
                            READ_ERROR(CORE, PROC_NAME, "need EVENT_MAP_END but " &
                                       EVENT_TO_STRING(next_event));
                    end case;
                end loop;
                if (wait_on) then
                    SIG_LOOP:loop
                        REPORT_DEBUG(CORE, PROC_NAME, "SIG_LOOP");
                        WAIT_ON_SIGNALS;
                        MATCH_AXI4_CHANNEL(axi_signals, axi_match);
                        gpi_match := MATCH_STD_LOGIC(gpi_signals, GPI);
                        exit when(axi_match and gpi_match);
                        if (ACLK'event and ACLK = '1') then
                            if (timeout > 0) then
                                timeout := timeout - 1;
                            else
                                EXECUTE_ABORT(CORE, PROC_NAME, "Time Out!");
                            end if;
                        end if;
                    end loop;
                else
                    CLK_LOOP:loop
                        REPORT_DEBUG(CORE, PROC_NAME, "CLK_LOOP");
                        wait until (ACLK'event and ACLK = '1');
                        MATCH_AXI4_CHANNEL(axi_signals, axi_match);
                        gpi_match := MATCH_STD_LOGIC(gpi_signals, GPI);
                        exit when(axi_match and gpi_match);
                        if (timeout > 0) then
                            timeout := timeout - 1;
                        else
                            EXECUTE_ABORT(CORE, PROC_NAME, "Time Out!");
                        end if;
                    end loop;
                end if;
            when others =>
                READ_ERROR(CORE, PROC_NAME, "SEEK_EVENT NG");
        end case;
        REPORT_DEBUG(CORE, PROC_NAME, "END");
    end procedure;
begin 
    -------------------------------------------------------------------------------
    -- メインチャネル.
    -------------------------------------------------------------------------------
    CHANNEL_M: if (CHANNEL = AXI4_CHANNEL_M) generate
        PROCESS_M: process
            -----------------------------------------------------------------------
            -- 各種変数の定義.
            -----------------------------------------------------------------------
            file      stream        : TEXT;
            variable  core          : CORE_TYPE;
            variable  keyword       : KEYWORD_TYPE;
            variable  operation     : OPERATION_TYPE;
            variable  gpo_signals   : std_logic_vector(GPO'range);
            -----------------------------------------------------------------------
            --! @brief  SYNCオペレーション. 
            --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            --! @param    CORE        コア変数.
            --! @param    STREAM      入力ストリーム.
            --! @param    OPERATION   オペレーション.
            -----------------------------------------------------------------------
            procedure EXECUTE_SYNC(
                variable  CORE      : inout CORE_TYPE;
                file      STREAM    :       TEXT;
                          OPERATION : in    OPERATION_TYPE
            ) is
                constant  PROC_NAME : string := "EXECUTE_SYNC";
                variable  port_num  : integer;
                variable  wait_num  : integer;
            begin
                REPORT_DEBUG  (CORE, PROC_NAME, "BEGIN");
                READ_SYNC_ARGS(CORE, STREAM, OPERATION, port_num, wait_num);
                REPORT_DEBUG  (CORE, PROC_NAME, "PORT=" & INTEGER_TO_STRING(port_num) &
                                               " WAIT=" & INTEGER_TO_STRING(wait_num));
                LOCAL_SYNC(CORE, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                if (SYNC_REQ'low <= port_num and port_num <= SYNC_REQ'high) then
                    CORE_SYNC(CORE, port_num, wait_num, SYNC_REQ, SYNC_ACK);
                end if;
                REPORT_DEBUG  (CORE, PROC_NAME, "END");
            end procedure;
        begin
            -----------------------------------------------------------------------
            -- ダミープラグコアの初期化.
            -----------------------------------------------------------------------
            CORE_INIT(
                SELF        => core,          -- 初期化するコア変数.
                NAME        => NAME,          -- コアの名前.
                VOCAL_NAME  => FULL_NAME,     -- メッセージ出力用の名前.
                STREAM      => stream,        -- シナリオのストリーム.
                STREAM_NAME => SCENARIO_FILE, -- シナリオのストリーム名.
                OPERATION   => operation      -- コアのオペレーション.
            );
            -----------------------------------------------------------------------
            -- 変数の初期化.
            -----------------------------------------------------------------------
            gpo_signals := (others => 'Z');
            core.debug  := 0;
            -----------------------------------------------------------------------
            -- 信号の初期化
            -----------------------------------------------------------------------
            SYNC_REQ       <= (0 =>10, others => 0);
            SYNC_LOCAL_REQ <= (        others => 0);
            SYNC_TRANS_REQ <= (        others => 0);
            FINISH         <= '0';
            REPORT_STATUS  <= core.report_status;
            -----------------------------------------------------------------------
            -- リセット解除待ち
            -----------------------------------------------------------------------
            wait until(ACLK'event and ACLK = '1' and ARESETn = '1');
            -----------------------------------------------------------------------
            -- メインオペレーションループ
            -----------------------------------------------------------------------
            while (operation /= OP_FINISH) loop
                REPORT_STATUS <= core.report_status;
                READ_OPERATION(core, stream, operation, keyword);
                case operation is
                    when OP_DOC_BEGIN       => EXECUTE_SYNC  (core, stream, operation);
                    when OP_SCALAR =>
                        case keyword is
                            when KEY_SYNC   => EXECUTE_SYNC  (core, stream, operation);
                            when others     => EXECUTE_UNDEFINED_SCALAR(core, stream, keyword);
                        end case;
                    when OP_MAP             =>
                        REPORT_DEBUG(core, string'("MAIN_LOOP:OP_MAP(") & keyword & ")");
                        case keyword is
                            when KEY_AR     |
                                 KEY_AW     |
                                 KEY_R      |
                                 KEY_W      |
                                 KEY_B      => EXECUTE_SKIP  (core, stream);
                            when KEY_REPORT => EXECUTE_REPORT(core, stream);
                            when KEY_DEBUG  => EXECUTE_DEBUG (core, stream);
                            when KEY_SAY    => EXECUTE_SAY   (core, stream);
                            when KEY_WAIT   => EXECUTE_WAIT  (core, stream);
                            when KEY_CHECK  => EXECUTE_CHECK (core, stream);
                            when KEY_OUT    => EXECUTE_OUT   (core, stream, gpo_signals, GPO);
                            when KEY_SYNC   => EXECUTE_SYNC  (core, stream, operation);
                            when KEY_READ   => if (READ_ENABLE ) then
                                                   EXECUTE_SKIP(core, stream);
                                               else
                                                   EXECUTE_UNDEFINED_MAP_KEY(core, stream, keyword);
                                               end if;
                            when KEY_WRITE  => if (WRITE_ENABLE) then
                                                   EXECUTE_SKIP(core, stream);
                                               else
                                                   EXECUTE_UNDEFINED_MAP_KEY(core, stream, keyword);
                                               end if;
                            when others     => EXECUTE_UNDEFINED_MAP_KEY(core, stream, keyword);
                        end case;
                    when OP_FINISH => exit;
                    when others    => null;
                end case;
            end loop;
            REPORT_STATUS <= core.report_status;
            FINISH        <= '1';
            if (FINISH_ABORT) then
                assert FALSE report "Simulation complete." severity FAILURE;
            end if;
            wait;
        end process;
    end generate;
    -------------------------------------------------------------------------------
    -- アドレスチャネル
    -------------------------------------------------------------------------------
    CHANNEL_A:if (CHANNEL = AXI4_CHANNEL_AW or CHANNEL = AXI4_CHANNEL_AR) generate
        PROCESS_A: process
            ---------------------------------------------------------------------------
            -- 各種変数の定義.
            ---------------------------------------------------------------------------
            file      stream        : TEXT;
            variable  core          : CORE_TYPE;
            variable  keyword       : KEYWORD_TYPE;
            variable  operation     : OPERATION_TYPE;
            variable  out_signals   : AXI4_CHANNEL_SIGNAL_TYPE;
            variable  chk_a_signals : AXI4_A_CHANNEL_SIGNAL_TYPE;
            variable  tran_info     : AXI4_TRANSACTION_SIGNAL_TYPE;
            -----------------------------------------------------------------------
            --! @brief 信号変数(SIGNALS)の値をポートに出力するサブプログラム.
            --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            --! @param    SIGNALS    出力する信号の値を指定する変数.
            -----------------------------------------------------------------------
            procedure EXECUTE_OUTPUT(SIGNALS: in AXI4_CHANNEL_SIGNAL_TYPE) is
            begin 
                if (MASTER and WRITE_ENABLE and CHANNEL = AXI4_CHANNEL_AW) then
                    AWADDR_O  <= SIGNALS.AW.ADDR(AWADDR_O'range)after OUTPUT_DELAY;
                    AWVALID_O <= SIGNALS.AW.VALID               after OUTPUT_DELAY;
                    AWLEN_O   <= SIGNALS.AW.LEN                 after OUTPUT_DELAY;
                    AWSIZE_O  <= SIGNALS.AW.SIZE                after OUTPUT_DELAY;
                    AWBURST_O <= SIGNALS.AW.BURST               after OUTPUT_DELAY;
                    AWLOCK_O  <= SIGNALS.AW.LOCK                after OUTPUT_DELAY;
                    AWCACHE_O <= SIGNALS.AW.CACHE               after OUTPUT_DELAY;
                    AWPROT_O  <= SIGNALS.AW.PROT                after OUTPUT_DELAY;
                    AWQOS_O   <= SIGNALS.AW.QOS                 after OUTPUT_DELAY;
                    AWREGION_O<= SIGNALS.AW.REGION              after OUTPUT_DELAY;
                    AWUSER_O  <= SIGNALS.AW.id(AWUSER_O'range)  after OUTPUT_DELAY;
                    AWID_O    <= SIGNALS.AW.id(AWID_O'range)    after OUTPUT_DELAY;
                end if;
                if (MASTER and READ_ENABLE  and CHANNEL = AXI4_CHANNEL_AR) then
                    ARADDR_O  <= SIGNALS.AR.ADDR(ARADDR_O'range)after OUTPUT_DELAY;
                    ARVALID_O <= SIGNALS.AR.VALID               after OUTPUT_DELAY;
                    ARLEN_O   <= SIGNALS.AR.LEN                 after OUTPUT_DELAY;
                    ARSIZE_O  <= SIGNALS.AR.SIZE                after OUTPUT_DELAY;
                    ARBURST_O <= SIGNALS.AR.BURST               after OUTPUT_DELAY;
                    ARLOCK_O  <= SIGNALS.AR.LOCK                after OUTPUT_DELAY;
                    ARCACHE_O <= SIGNALS.AR.CACHE               after OUTPUT_DELAY;
                    ARPROT_O  <= SIGNALS.AR.PROT                after OUTPUT_DELAY;
                    ARQOS_O   <= SIGNALS.AR.QOS                 after OUTPUT_DELAY;
                    ARREGION_O<= SIGNALS.AR.REGION              after OUTPUT_DELAY;
                    ARUSER_O  <= SIGNALS.AR.id(ARUSER_O'range)  after OUTPUT_DELAY;
                    ARID_O    <= SIGNALS.AR.id(ARID_O'range)    after OUTPUT_DELAY;
                end if;
                if (SLAVE  and WRITE_ENABLE and CHANNEL = AXI4_CHANNEL_AW) then
                    AWREADY_O <= SIGNALS.AW.READY               after OUTPUT_DELAY;
                end if;
                if (SLAVE  and READ_ENABLE  and CHANNEL = AXI4_CHANNEL_AR) then
                    ARREADY_O <= SIGNALS.AR.READY               after OUTPUT_DELAY;
                end if;
            end procedure;
            -----------------------------------------------------------------------
            --! @brief トランザクションの情報をシナリオから読むサブプログラム.
            --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            --! @param    PROC_NAME  プロシージャの名前.
            --! @param    TIMEOUT    タイムアウトのクロック数.
            -----------------------------------------------------------------------
            procedure READ_TRANSACTION_INFO(
                          PROC_NAME  : in     string ;
                variable  TIMEOUT    : inout  integer
            ) is
                variable  next_event : EVENT_TYPE;
                variable  ADDR_WIDTH : integer;
                variable  AUSER_WIDTH: integer;
                variable  DUSER_WIDTH: integer;
                variable  BUSER_WIDTH: integer;
            begin
                case CHANNEL is
                    when AXI4_CHANNEL_AR =>
                        ADDR_WIDTH  := WIDTH.ARADDR;
                        AUSER_WIDTH := WIDTH.ARUSER;
                        DUSER_WIDTH := WIDTH.RUSER;
                        BUSER_WIDTH := 1;
                    when AXI4_CHANNEL_AW =>
                        ADDR_WIDTH  := WIDTH.AWADDR;
                        AUSER_WIDTH := WIDTH.AWUSER;
                        DUSER_WIDTH := WIDTH.WUSER;
                        BUSER_WIDTH := WIDTH.BUSER;
                    when others =>
                        null;
                end case;
                TIMEOUT  := DEFAULT_WAIT_TIMEOUT;
                SEEK_EVENT(core, stream, next_event);
                case next_event is
                    when EVENT_MAP_BEGIN =>
                        READ_EVENT(core, stream, EVENT_MAP_BEGIN);
                        MAP_READ_LOOP: loop
                            MAP_READ_PREPARE_FOR_NEXT(
                                SELF       => core            ,  -- I/O:
                                STREAM     => stream          ,  -- I/O:
                                EVENT      => next_event         -- I/O:
                            );
                            MAP_READ_AXI4_TRANSACTION(
                                CORE       => core            ,  -- I/O:
                                STREAM     => stream          ,  -- I/O:
                                ADDR_WIDTH => ADDR_WIDTH      ,  -- In :
                                AUSER_WIDTH=> AUSER_WIDTH     ,  -- In :
                                DUSER_WIDTH=> DUSER_WIDTH     ,  -- In :
                                BUSER_WIDTH=> BUSER_WIDTH     ,  -- In :
                                ID_WIDTH   => WIDTH.ID        ,  -- In :
                                TRANS      => tran_info       ,  -- I/O:
                                EVENT      => next_event         -- I/O:
                            );
                            MAP_READ_INTEGER(
                                SELF       => core            ,  -- I/O:
                                STREAM     => stream          ,  -- I/O:
                                KEY        => "TIMEOUT"       ,  -- In :
                                VAL        => TIMEOUT         ,  -- I/O:
                                EVENT      => next_event         -- I/O:
                            );
                            case next_event is
                                when EVENT_SCALAR  =>
                                    COPY_KEY_WORD(core, keyword);
                                    EXECUTE_UNDEFINED_MAP_KEY(core, stream, keyword);
                                when EVENT_MAP_END =>
                                    exit MAP_READ_LOOP;
                                when others        =>
                                    READ_ERROR(core, PROC_NAME, "need EVENT_MAP_END but " &
                                               EVENT_TO_STRING(next_event));
                            end case;
                        end loop;
                    when others =>
                        READ_ERROR(core, PROC_NAME, "SEEK_EVENT NG");
                end case;
            end procedure;
            -----------------------------------------------------------------------
            --! @brief マスターリードランザクション(アドレスチャネル)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure EXECUTE_TRANSACTION_MASTER_READ_ADDR is
                constant  PROC_NAME  : string := "EXECUTE_TRANSACTION_MASTER_READ_ADDR";
                variable  timeout    : integer;
            begin
                REPORT_DEBUG(core, PROC_NAME, "BEGIN");
                tran_info       := AXI4_TRANSACTION_SIGNAL_NULL;
                tran_info.DUSER := (others => '-');
                tran_info.VALID := '1';
                READ_TRANSACTION_INFO(PROC_NAME, timeout);
                LOCAL_SYNC(core, SYNC_TRANS_REQ, SYNC_TRANS_ACK);
                TRAN_O <= tran_info;
                out_signals.AR.ADDR(ARADDR_O'range) := tran_info.ADDR (ARADDR_O'range);
                out_signals.AR.USER(ARUSER_O'range) := tran_info.AUSER(ARUSER_O'range);
                out_signals.AR.ID  (ARID_O  'range) := tran_info.ID   (ARID_O  'range);
                out_signals.AR.WRITE                := '0';
                out_signals.AR.LEN                  := tran_info.LEN;
                out_signals.AR.SIZE                 := tran_info.SIZE;
                out_signals.AR.BURST                := tran_info.BURST;
                out_signals.AR.LOCK                 := tran_info.LOCK;
                out_signals.AR.CACHE                := tran_info.CACHE;
                out_signals.AR.PROT                 := tran_info.PROT;
                out_signals.AR.QOS                  := tran_info.QOS;
                out_signals.AR.REGION               := tran_info.REGION;
                out_signals.AR.VALID                := '1';
                EXECUTE_OUTPUT(out_signals);
                wait until (ACLK'event and ACLK = '0');
                TRAN_O.VALID <= '0';
                WAIT_UNTIL_XFER_AR(core, PROC_NAME, timeout);
                out_signals.AR                      := AXI4_A_CHANNEL_SIGNAL_NULL;
                EXECUTE_OUTPUT(out_signals);
                REPORT_DEBUG(core, PROC_NAME, "END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief マスターライトトランザクション(アドレスチャネル)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure EXECUTE_TRANSACTION_MASTER_WRITE_ADDR is
                constant  PROC_NAME  : string := "EXECUTE_TRANSACTION_MASTER_WRITE_ADDR";
                variable  timeout    : integer;
            begin
                REPORT_DEBUG(core, PROC_NAME, "BEGIN");
                tran_info       := AXI4_TRANSACTION_SIGNAL_NULL;
                tran_info.BUSER := (others => '-');
                tran_info.VALID := '1';
                READ_TRANSACTION_INFO(PROC_NAME, timeout);
                LOCAL_SYNC(core, SYNC_TRANS_REQ, SYNC_TRANS_ACK);
                TRAN_O <= tran_info;
                out_signals.AW.ADDR(AWADDR_O'range) := tran_info.ADDR (AWADDR_O'range);
                out_signals.AW.USER(AWUSER_O'range) := tran_info.AUSER(AWUSER_O'range);
                out_signals.AW.ID  (AWID_O  'range) := tran_info.ID   (AWID_O  'range);
                out_signals.AW.WRITE                := '1';
                out_signals.AW.LEN                  := tran_info.LEN;
                out_signals.AW.SIZE                 := tran_info.SIZE;
                out_signals.AW.BURST                := tran_info.BURST;
                out_signals.AW.LOCK                 := tran_info.LOCK;
                out_signals.AW.CACHE                := tran_info.CACHE;
                out_signals.AW.PROT                 := tran_info.PROT;
                out_signals.AW.QOS                  := tran_info.QOS;
                out_signals.AW.REGION               := tran_info.REGION;
                out_signals.AW.VALID                := '1';
                EXECUTE_OUTPUT(out_signals);
                wait until (ACLK'event and ACLK = '0');
                TRAN_O.VALID <= '0';
                WAIT_UNTIL_XFER_AW(core, PROC_NAME, timeout);
                out_signals.AW                      := AXI4_A_CHANNEL_SIGNAL_NULL;
                EXECUTE_OUTPUT(out_signals);
                REPORT_DEBUG(core, PROC_NAME, "END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief スレーブリードトランザクション(アドレスチャネル)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure EXECUTE_TRANSACTION_SLAVE_READ_ADDR is
                constant  PROC_NAME  : string := "EXECUTE_TRANSACTION_SLAVE_READ_ADDR";
                variable  timeout    : integer;
                variable  match      : boolean;
            begin
                REPORT_DEBUG(core, PROC_NAME, "BEGIN");
                tran_info       := AXI4_TRANSACTION_SIGNAL_DONTCARE;
                tran_info.VALID := '1';
                READ_TRANSACTION_INFO(PROC_NAME, timeout);
                LOCAL_SYNC(core, SYNC_TRANS_REQ, SYNC_TRANS_ACK);
                TRAN_O       <= tran_info;
                ARREADY_O    <= '1';
                wait until (ACLK'event and ACLK = '0');
                TRAN_O.VALID <= '0';
                WAIT_UNTIL_XFER_AR(core, PROC_NAME, timeout);
                ARREADY_O    <= '0';
                chk_a_signals.ADDR(ARADDR_I'range) := tran_info.ADDR (ARADDR_I'range);
                chk_a_signals.USER(ARUSER_I'range) := tran_info.AUSER(ARUSER_I'range);
                chk_a_signals.ID  (ARID_I  'range) := tran_info.ID   (ARID_I  'range);
                chk_a_signals.WRITE                := tran_info.WRITE;
                chk_a_signals.LEN                  := tran_info.LEN;
                chk_a_signals.SIZE                 := tran_info.SIZE;
                chk_a_signals.BURST                := tran_info.BURST;
                chk_a_signals.LOCK                 := tran_info.LOCK;
                chk_a_signals.CACHE                := tran_info.CACHE;
                chk_a_signals.PROT                 := tran_info.PROT;
                chk_a_signals.QOS                  := tran_info.QOS;
                chk_a_signals.REGION               := tran_info.REGION;
                chk_a_signals.VALID                := '1';
                chk_a_signals.READY                := '1';
                MATCH_AXI4_AR_CHANNEL(core, chk_a_signals, match);
                REPORT_DEBUG(core, PROC_NAME, "END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief スレーブライトトランザクション(アドレスチャネル)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure EXECUTE_TRANSACTION_SLAVE_WRITE_ADDR is
                constant  PROC_NAME  : string := "EXECUTE_TRANSACTION_SLAVE_WRITE_ADDR";
                variable  timeout    : integer;
                variable  match      : boolean;
            begin
                REPORT_DEBUG(core, PROC_NAME, "BEGIN");
                tran_info       := AXI4_TRANSACTION_SIGNAL_DONTCARE;
                tran_info.VALID := '1';
                READ_TRANSACTION_INFO(PROC_NAME, timeout);
                LOCAL_SYNC(core, SYNC_TRANS_REQ, SYNC_TRANS_ACK);
                TRAN_O       <= tran_info;
                AWREADY_O    <= '1';
                wait until (ACLK'event and ACLK = '0');
                TRAN_O.VALID <= '0';
                WAIT_UNTIL_XFER_AW(core, PROC_NAME, timeout);
                AWREADY_O    <= '0';
                chk_a_signals.ADDR(AWADDR_I'range) := tran_info.ADDR (AWADDR_I'range);
                chk_a_signals.USER(AWUSER_I'range) := tran_info.AUSER(AWUSER_I'range);
                chk_a_signals.ID  (AWID_I  'range) := tran_info.ID   (AWID_I  'range);
                chk_a_signals.WRITE                := tran_info.WRITE;
                chk_a_signals.LEN                  := tran_info.LEN;
                chk_a_signals.SIZE                 := tran_info.SIZE;
                chk_a_signals.BURST                := tran_info.BURST;
                chk_a_signals.LOCK                 := tran_info.LOCK;
                chk_a_signals.CACHE                := tran_info.CACHE;
                chk_a_signals.PROT                 := tran_info.PROT;
                chk_a_signals.QOS                  := tran_info.QOS;
                chk_a_signals.REGION               := tran_info.REGION;
                chk_a_signals.VALID                := '1';
                chk_a_signals.READY                := '1';
                MATCH_AXI4_AW_CHANNEL(core, chk_a_signals, match);
                REPORT_DEBUG(core, PROC_NAME, "END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief チャネルオペレーション(SCALAR)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure EXECUTE_CHANNEL_SCALAR_OPERATION is
            begin 
                SKIP_EVENT(core, stream, EVENT_SCALAR);
            end procedure;
            -----------------------------------------------------------------------
            --! @brief チャネルオペレーション(MAP)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure EXECUTE_CHANNEL_MAP_OPERATION is
                constant  PROC_NAME  : string := "EXECUTE_CHANNEL_MAP_OPERATION";
                variable  next_event : EVENT_TYPE;
            begin
                REPORT_DEBUG(core, PROC_NAME, "BEGIN");
                READ_EVENT(core, stream, EVENT_MAP_BEGIN);
                MAP_READ_LOOP: loop
                    MAP_READ_PREPARE_FOR_NEXT(
                        SELF       => core            ,  -- I/O:
                        STREAM     => stream          ,  -- I/O:
                        EVENT      => next_event         -- I/O:
                    );
                    MAP_READ_AXI4_CHANNEL(
                        CORE       => core            ,  -- In :
                        STREAM     => stream          ,  -- I/O:
                        CHANNEL    => CHANNEL         ,  -- In :
                        READ       => READ_ENABLE     ,  -- In :
                        WRITE      => WRITE_ENABLE    ,  -- In :
                        WIDTH      => WIDTH           ,  -- In :
                        SIGNALS    => out_signals     ,  -- I/O:
                        EVENT      => next_event         -- Out:
                    );
                    EXECUTE_OUTPUT(out_signals);
                    case next_event is
                        when EVENT_SCALAR  =>
                            COPY_KEY_WORD(core, keyword);
                            case keyword is
                                when KEY_DEBUG  => EXECUTE_DEBUG (core, stream);
                                when KEY_REPORT => EXECUTE_REPORT(core, stream);
                                when KEY_SAY    => EXECUTE_SAY   (core, stream);
                                when KEY_WAIT   => EXECUTE_WAIT  (core, stream);
                                when KEY_CHECK  => EXECUTE_CHECK (core, stream);
                                when others     => EXECUTE_UNDEFINED_MAP_KEY(core, stream, keyword);
                            end case;
                        when EVENT_MAP_END =>
                            exit MAP_READ_LOOP;
                        when others        =>
                            READ_ERROR(core, PROC_NAME, "need EVENT_MAP_END but " &
                                       EVENT_TO_STRING(next_event));
                    end case;
                end loop;
                REPORT_DEBUG(core, PROC_NAME, "END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief チャネルオペレーションループ
            -----------------------------------------------------------------------
            procedure EXECUTE_CHANNEL_OPERATION is
                constant  PROC_NAME  : string := "EXECUTE_CHANNEL_OPERATION";
                variable  next_event : EVENT_TYPE;
                variable  seq_level  : integer;
            begin
                REPORT_DEBUG(core, PROC_NAME, "BEGIN");
                seq_level := 0;
                SEQ_LOOP: loop
                    SEEK_EVENT(core, stream, next_event);
                    case next_event is
                        when EVENT_SEQ_BEGIN =>
                            READ_EVENT(core, stream, EVENT_SEQ_BEGIN);
                            seq_level := seq_level + 1;
                        when EVENT_SEQ_END   =>
                            READ_EVENT(core, stream, EVENT_SEQ_END  );
                            seq_level := seq_level - 1;
                        when EVENT_MAP_BEGIN =>
                            EXECUTE_CHANNEL_MAP_OPERATION;
                        when EVENT_SCALAR    =>
                            EXECUTE_CHANNEL_SCALAR_OPERATION;
                        when EVENT_ERROR     =>
                            READ_ERROR(core, PROC_NAME, "SEEK_EVENT NG");
                        when others          =>
                            SKIP_EVENT(core, stream, next_event);
                            -- ERROR
                    end case;
                    exit when (seq_level <= 0);
                end loop;
                REPORT_DEBUG(core, PROC_NAME, "END");
            end procedure;
        begin
            -----------------------------------------------------------------------
            -- ダミープラグコアの初期化.
            -----------------------------------------------------------------------
            CORE_INIT(
                SELF        => core,          -- 初期化するコア変数.
                NAME        => NAME,          -- コアの名前.
                VOCAL_NAME  => FULL_NAME,     -- メッセージ出力用の名前.
                STREAM      => stream,        -- シナリオのストリーム.
                STREAM_NAME => SCENARIO_FILE, -- シナリオのストリーム名.
                OPERATION   => operation      -- コアのオペレーション.
            );
            -----------------------------------------------------------------------
            -- 変数の初期化.
            -----------------------------------------------------------------------
            out_signals := INIT_SIGNALS;
            -----------------------------------------------------------------------
            -- 信号の初期化
            -----------------------------------------------------------------------
            SYNC_LOCAL_REQ <= (others => 0);
            SYNC_TRANS_REQ <= (others => 0);
            FINISH         <= '0';
            REPORT_STATUS  <= core.report_status;
            EXECUTE_OUTPUT(out_signals);
            core.debug := 0;
            -----------------------------------------------------------------------
            -- メインオペレーションループ
            -----------------------------------------------------------------------
            while (operation /= OP_FINISH) loop
                REPORT_STATUS <= core.report_status;
                READ_OPERATION(core, stream, operation, keyword);
                case operation is
                    when OP_DOC_BEGIN   => LOCAL_SYNC(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                    when OP_MAP         =>
                        REPORT_DEBUG(core, string'("MAIN_LOOP:OP_MAP(") & keyword & ")");
                        if    (keyword = KEY_CHANNEL) then
                            EXECUTE_CHANNEL_OPERATION;
                        elsif (keyword = KEY_REPORT ) then
                            EXECUTE_REPORT(core, stream);
                        elsif (keyword = KEY_SYNC   ) then
                            LOCAL_SYNC(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                            EXECUTE_SKIP(core, stream);
                        elsif (CHANNEL = AXI4_CHANNEL_AR and MASTER and READ_ENABLE  and keyword = KEY_READ ) then
                            EXECUTE_TRANSACTION_MASTER_READ_ADDR;
                        elsif (CHANNEL = AXI4_CHANNEL_AR and SLAVE  and READ_ENABLE  and keyword = KEY_READ ) then
                            EXECUTE_TRANSACTION_SLAVE_READ_ADDR;
                        elsif (CHANNEL = AXI4_CHANNEL_AW and MASTER and WRITE_ENABLE and keyword = KEY_WRITE) then
                            EXECUTE_TRANSACTION_MASTER_WRITE_ADDR;
                        elsif (CHANNEL = AXI4_CHANNEL_AW and SLAVE  and WRITE_ENABLE and keyword = KEY_WRITE) then
                            EXECUTE_TRANSACTION_SLAVE_WRITE_ADDR;
                        else
                            REPORT_DEBUG(core, string'("MAIN_LOOP:OP_MAP:SKIP BEGIN"));
                            EXECUTE_SKIP(core, stream);
                            REPORT_DEBUG(core, string'("MAIN_LOOP:OP_MAP:SKIP END"));
                        end if;
                    when OP_SCALAR      =>
                        if (keyword = KEY_SYNC) then
                            LOCAL_SYNC(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                        else
                            EXECUTE_UNDEFINED_SCALAR(core, stream, keyword);
                        end if;
                    when OP_FINISH      => exit;
                    when others         => null;
                end case;
            end loop;
            REPORT_STATUS <= core.report_status;
            FINISH        <= '1';
            if (FINISH_ABORT) then
                assert FALSE report "Simulation complete." severity FAILURE;
            end if;
            wait;
        end process;
    end generate;
    -------------------------------------------------------------------------------
    -- データチャネル
    -------------------------------------------------------------------------------
    CHANNEL_D:if (CHANNEL = AXI4_CHANNEL_W  or CHANNEL = AXI4_CHANNEL_B  or CHANNEL = AXI4_CHANNEL_R) generate
        PROCESS_D: process
            ---------------------------------------------------------------------------
            -- 各種変数の定義.
            ---------------------------------------------------------------------------
            file      stream        : TEXT;
            variable  core          : CORE_TYPE;
            variable  keyword       : KEYWORD_TYPE;
            variable  operation     : OPERATION_TYPE;
            variable  out_signals   : AXI4_CHANNEL_SIGNAL_TYPE;
            variable  chk_r_signals : AXI4_R_CHANNEL_SIGNAL_TYPE;
            variable  chk_w_signals : AXI4_W_CHANNEL_SIGNAL_TYPE;
            variable  chk_b_signals : AXI4_B_CHANNEL_SIGNAL_TYPE;
            variable  tran_info     : AXI4_TRANSACTION_SIGNAL_TYPE;
            variable  aligned_addr  : integer;
            variable  number_bytes  : integer;
            variable  lower_lane    : integer;
            variable  upper_lane    : integer;
            variable  burst_len     : integer;
            variable  data_pos      : integer;
            variable  data_bits     : integer;
            variable  data_bytes    : integer;
            variable  timeout       : integer;
            variable  match         : boolean;
            -----------------------------------------------------------------------
            --! @brief 信号変数(SIGNALS)の値をポートに出力するサブプログラム.
            --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            --! @param    SIGNALS    出力する信号の値を指定する変数.
            -----------------------------------------------------------------------
            procedure EXECUTE_OUTPUT(
                          SIGNALS  : in AXI4_CHANNEL_SIGNAL_TYPE
            ) is
            begin 
                if (MASTER and WRITE_ENABLE and CHANNEL = AXI4_CHANNEL_W) then
                    WDATA_O   <= SIGNALS.W.DATA(WDATA_O'range)  after OUTPUT_DELAY;
                    WLAST_O   <= SIGNALS.W.LAST                 after OUTPUT_DELAY;
                    WSTRB_O   <= SIGNALS.W.STRB(WSTRB_O'range)  after OUTPUT_DELAY;
                    WUSER_O   <= SIGNALS.W.USER(WUSER_O'range)  after OUTPUT_DELAY;
                    WID_O     <= SIGNALS.W.ID(WID_O'range)      after OUTPUT_DELAY;
                    WVALID_O  <= SIGNALS.W.VALID                after OUTPUT_DELAY;
                end if;
                if (MASTER and WRITE_ENABLE and CHANNEL = AXI4_CHANNEL_B) then
                    BREADY_O  <= SIGNALS.B.READY                after OUTPUT_DELAY;
                end if;
                if (MASTER and READ_ENABLE  and CHANNEL = AXI4_CHANNEL_R) then
                    RREADY_O  <= SIGNALS.R.READY                after OUTPUT_DELAY;
                end if;
                if (SLAVE  and WRITE_ENABLE and CHANNEL = AXI4_CHANNEL_W) then
                    WREADY_O  <= SIGNALS.W.READY                after OUTPUT_DELAY;
                end if;
                if (SLAVE  and WRITE_ENABLE and CHANNEL = AXI4_CHANNEL_B) then
                    BRESP_O   <= SIGNALS.B.RESP                 after OUTPUT_DELAY;
                    BUSER_O   <= SIGNALS.B.USER(BUSER_O'range)  after OUTPUT_DELAY;
                    BID_O     <= SIGNALS.B.ID(BID_O'range)      after OUTPUT_DELAY;
                    BVALID_O  <= SIGNALS.B.VALID                after OUTPUT_DELAY;
                end if;
                if (SLAVE  and READ_ENABLE  and CHANNEL = AXI4_CHANNEL_R) then
                    RDATA_O   <= SIGNALS.R.DATA(RDATA_O'range)  after OUTPUT_DELAY;
                    RRESP_O   <= SIGNALS.R.RESP                 after OUTPUT_DELAY;
                    RLAST_O   <= SIGNALS.R.LAST                 after OUTPUT_DELAY;
                    RUSER_O   <= SIGNALS.R.USER(RUSER_O'range)  after OUTPUT_DELAY;
                    RID_O     <= SIGNALS.R.ID(RID_O'range)      after OUTPUT_DELAY;
                    RVALID_O  <= SIGNALS.R.VALID                after OUTPUT_DELAY;
                end if;
            end procedure;
            -----------------------------------------------------------------------
            --! @brief アドレスチャネルからのトランザクション情報をTRAN_I信号から
            --!        取り込んで内部変数にセットするサブプログラム.
            --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            --! @param    PROC_NAME  プロシージャの名前.
            --! @param    DATA_WIDTH データのビット幅.
            -----------------------------------------------------------------------
            procedure GET_TRANSACTION_INFO(
                          PROC_NAME   : in string;
                          DATA_WIDTH  : in integer
            ) is
            begin
                REPORT_DEBUG(core, PROC_NAME, "GET_TRANSACTION_INFO BEGIN");
                wait until (TRAN_I.VALID'event and TRAN_I.VALID = '1');
                tran_info := TRAN_I;
                TRANSACTION_TO_ADDR_AND_BYTES(tran_info, aligned_addr, number_bytes);
                case DATA_WIDTH is
                    when   16   => lower_lane := TO_INTEGER(unsigned(tran_info.ADDR(0 downto 0)));
                    when   32   => lower_lane := TO_INTEGER(unsigned(tran_info.ADDR(1 downto 0)));
                    when   64   => lower_lane := TO_INTEGER(unsigned(tran_info.ADDR(2 downto 0)));
                    when  128   => lower_lane := TO_INTEGER(unsigned(tran_info.ADDR(3 downto 0)));
                    when  256   => lower_lane := TO_INTEGER(unsigned(tran_info.ADDR(4 downto 0)));
                    when  512   => lower_lane := TO_INTEGER(unsigned(tran_info.ADDR(5 downto 0)));
                    when 1024   => lower_lane := TO_INTEGER(unsigned(tran_info.ADDR(6 downto 0)));
                    when others => lower_lane := 0;
                end case;
                timeout    := 10000;
                burst_len  := TO_INTEGER(unsigned(tran_info.LEN))+1;
                data_pos   := 0;
                data_bits  := tran_info.DATA_LEN;
                data_bytes := (data_bits+7)/8;
                if (number_bytes - aligned_addr > data_bytes) then
                    upper_lane := lower_lane + data_bytes - 1;
                else
                    upper_lane := lower_lane + number_bytes - aligned_addr - 1;
                end if;
                REPORT_DEBUG(core, PROC_NAME, "GET_TRANSACTION_INFO END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief GET_TRANSACTION_INFO で取り込んだトランザクション情報から
            --!        ワード毎のリードデータチャネル信号の値を生成するサブプログラム.
            --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            --! @param    PROC_NAME  プロシージャの名前.
            --! @param    LAST       最後のワードであることを指定する.
            --! @param    DEFAULT    指定の無いstd_logicの値.
            --! @param    SIGNALS    生成されたワード毎の信号を出力する.
            -----------------------------------------------------------------------
            procedure GENERATE_R_SIGNAL(
                          PROC_NAME   : in  string;
                          LAST        : in  boolean;
                          DEFAULT     : in  std_logic;
                          SIGNALS     : out AXI4_R_CHANNEL_SIGNAL_TYPE
            ) is
                constant  word_bytes  :     integer := WIDTH.RDATA/8;
            begin 
                SIGNALS.USER  := tran_info.DUSER;
                SIGNALS.ID    := tran_info.ID;
                SIGNALS.VALID := '1';
                SIGNALS.READY := '1';
                if (LAST) then
                    SIGNALS.RESP := tran_info.RESP;
                    SIGNALS.LAST := '1';
                else
                    SIGNALS.RESP := (others => DEFAULT);
                    SIGNALS.LAST := '0';
                end if;
                for lane in 0 to word_bytes-1 loop
                    if (lower_lane <= lane and lane <= upper_lane) then
                        for bit in 0 to 7 loop
                            if (data_pos < data_bits) then
                                SIGNALS.DATA(lane*8+bit) := tran_info.DATA(data_pos);
                                data_pos := data_pos + 1;
                            else
                                SIGNALS.DATA(lane*8+bit) := DEFAULT;
                            end if;
                        end loop;
                    else
                        SIGNALS.DATA(lane*8+7 downto lane*8) := (lane*8+7 downto lane*8 => DEFAULT);
                    end if;
                end loop;
                lower_lane := (upper_lane + 1)  mod word_bytes;
                upper_lane := lower_lane + number_bytes - 1;
                if (upper_lane >= word_bytes) then
                    upper_lane := word_bytes - 1;
                end if;
            end procedure;
            -----------------------------------------------------------------------
            --! @brief GET_TRANSACTION_INFO で取り込んだトランザクション情報から
            --!        ワード毎のライトデータチャネル信号の値を生成するサブプログラム.
            --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            --! @param    PROC_NAME  プロシージャの名前.
            --! @param    LAST       最後のワードであることを指定する.
            --! @param    DEFAULT    指定の無いstd_logicの値.
            --! @param    SIGNALS    生成されたワード毎の信号を出力する.
            -----------------------------------------------------------------------
            procedure GENERATE_W_SIGNAL(
                          PROC_NAME   : in  string;
                          LAST        : in  boolean;
                          DEFAULT     : in  std_logic;
                          SIGNALS     : out AXI4_W_CHANNEL_SIGNAL_TYPE
            ) is
                constant  word_bytes  :     integer := WIDTH.WDATA/8;
            begin
                SIGNALS.USER  := tran_info.DUSER;
                SIGNALS.VALID := '1';
                SIGNALS.READY := '1';
                if (LAST) then
                    SIGNALS.LAST := '1';
                else
                    SIGNALS.LAST := '0';
                end if;                
                for lane in 0 to word_bytes-1 loop
                    SIGNALS.STRB(lane) := '0';
                    if (lower_lane <= lane and lane <= upper_lane) then
                        for bit in 0 to 7 loop
                            if (data_pos < data_bits) then
                                SIGNALS.DATA(lane*8+bit) := tran_info.DATA(data_pos);
                                data_pos := data_pos + 1;
                                SIGNALS.STRB(lane) := '1';
                            else
                                SIGNALS.DATA(lane*8+bit) := DEFAULT;
                            end if;
                        end loop;
                    else
                        SIGNALS.DATA(lane*8+7 downto lane*8) := (lane*8+7 downto lane*8 => DEFAULT);
                    end if;
                end loop;
                lower_lane := (upper_lane + 1)  mod word_bytes;
                upper_lane := lower_lane + number_bytes - 1;
                if (upper_lane >= word_bytes) then
                    upper_lane := word_bytes - 1;
                end if;
            end procedure;
            -----------------------------------------------------------------------
            --! @brief GET_TRANSACTION_INFO で取り込んだトランザクション情報から
            --!        ワード毎のライト応答チャネル信号の値を生成するサブプログラム.
            --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            --! @param    PROC_NAME  プロシージャの名前.
            --! @param    SIGNALS    生成されたワード毎の信号を出力する.
            -----------------------------------------------------------------------
            procedure GENERATE_B_SIGNAL(
                          PROC_NAME   : in  string;
                          SIGNALS     : out AXI4_B_CHANNEL_SIGNAL_TYPE
            ) is
            begin
                SIGNALS.USER  := tran_info.BUSER;
                SIGNALS.ID    := tran_info.ID;
                SIGNALS.RESP  := tran_info.RESP;
                SIGNALS.VALID := '1';
                SIGNALS.READY := '1';
            end procedure;
            -----------------------------------------------------------------------
            --! @brief マスターリードトランザクション(データチャネル)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure EXECUTE_TRANSACTION_MASTER_READ_DATA is
                constant  PROC_NAME  : string := "EXECUTE_TRANSACTION_MASTER_READ_DATA";
            begin
                REPORT_DEBUG(core, PROC_NAME, "BEGIN");
                EXECUTE_SKIP(core, stream);
                LOCAL_SYNC(core, SYNC_TRANS_REQ, SYNC_TRANS_ACK);
                GET_TRANSACTION_INFO(PROC_NAME, WIDTH.RDATA);
                for i in 1 to burst_len loop
                    RREADY_O <= '1' after OUTPUT_DELAY;
                    GENERATE_R_SIGNAL(
                        PROC_NAME => PROC_NAME,
                        LAST      => (i = burst_len),
                        DEFAULT   => '-',
                        SIGNALS   => chk_r_signals
                    );
                    WAIT_UNTIL_XFER_R(core, PROC_NAME, timeout, '0');
                    MATCH_AXI4_R_CHANNEL(core, chk_r_signals, match);
                end loop;
                RREADY_O <= '0' after OUTPUT_DELAY;
                REPORT_DEBUG(core, PROC_NAME, "END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief スレーブリードトランザクション(データチャネル)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure EXECUTE_TRANSACTION_SLAVE_READ_DATA is
                constant  PROC_NAME  : string := "EXECUTE_TRANSACTION_SLAVE_READ_DATA";
            begin
                REPORT_DEBUG(core, PROC_NAME, "BEGIN");
                EXECUTE_SKIP(core, stream);
                LOCAL_SYNC(core, SYNC_TRANS_REQ, SYNC_TRANS_ACK);
                GET_TRANSACTION_INFO(PROC_NAME, WIDTH.RDATA);
                for i in 1 to burst_len loop
                    GENERATE_R_SIGNAL(
                        PROC_NAME => PROC_NAME, 
                        LAST      => (i = burst_len),
                        DEFAULT   => '0',
                        SIGNALS   => out_signals.R
                    );
                    EXECUTE_OUTPUT(out_signals);
                    WAIT_UNTIL_XFER_R(core, PROC_NAME, timeout, '0');
                end loop;
                out_signals.R := AXI4_R_CHANNEL_SIGNAL_NULL;
                EXECUTE_OUTPUT(out_signals);
                REPORT_DEBUG(core, PROC_NAME, "END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief マスターライトトランザクション(データチャネル)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure EXECUTE_TRANSACTION_MASTER_WRITE_DATA is
                constant  PROC_NAME  : string := "EXECUTE_TRANSACTION_MASTER_WRITE_DATA";
            begin
                REPORT_DEBUG(core, PROC_NAME, "BEGIN");
                EXECUTE_SKIP(core, stream);
                LOCAL_SYNC(core, SYNC_TRANS_REQ, SYNC_TRANS_ACK);
                GET_TRANSACTION_INFO(PROC_NAME, WIDTH.WDATA);
                for i in 1 to burst_len loop
                    GENERATE_W_SIGNAL(
                        PROC_NAME => PROC_NAME, 
                        LAST      => (i = burst_len),
                        DEFAULT   => '0',
                        SIGNALS   => out_signals.W
                    );
                    EXECUTE_OUTPUT(out_signals);
                    WAIT_UNTIL_XFER_W(core, PROC_NAME, timeout, '0');
                end loop;
                out_signals.W := AXI4_W_CHANNEL_SIGNAL_NULL;
                EXECUTE_OUTPUT(out_signals);
                REPORT_DEBUG(core, PROC_NAME, "END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief スレーブライトトランザクション(データチャネル)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure EXECUTE_TRANSACTION_SLAVE_WRITE_DATA is
                constant  PROC_NAME  : string := "EXECUTE_TRANSACTION_SLAVE_WRITE_DATA";
            begin
                REPORT_DEBUG(core, PROC_NAME, "BEGIN");
                EXECUTE_SKIP(core, stream);
                LOCAL_SYNC(core, SYNC_TRANS_REQ, SYNC_TRANS_ACK);
                GET_TRANSACTION_INFO(PROC_NAME, WIDTH.WDATA);
                for i in 1 to burst_len loop
                    WREADY_O <= '1' after OUTPUT_DELAY;
                    GENERATE_W_SIGNAL(
                        PROC_NAME => PROC_NAME,
                        LAST      => (i = burst_len),
                        DEFAULT   => '-',
                        SIGNALS   => chk_w_signals
                    );
                    chk_w_signals.ID := (others => '-');
                    WAIT_UNTIL_XFER_W(core, PROC_NAME, timeout, '0');
                    MATCH_AXI4_W_CHANNEL(core, chk_w_signals, match);
                end loop;
                WREADY_O <= '0' after OUTPUT_DELAY;
                REPORT_DEBUG(core, PROC_NAME, "END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief マスターライトトランザクション(応答チャネル)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure EXECUTE_TRANSACTION_MASTER_WRITE_RESP is
                constant  PROC_NAME  : string := "EXECUTE_TRANSACTION_MASTER_WRITE_RESP";
            begin
                REPORT_DEBUG(core, PROC_NAME, "BEGIN");
                EXECUTE_SKIP(core, stream);
                LOCAL_SYNC(core, SYNC_TRANS_REQ, SYNC_TRANS_ACK);
                GET_TRANSACTION_INFO(PROC_NAME, WIDTH.WDATA);
                timeout := 10000;
                WAIT_UNTIL_XFER_AW(core, PROC_NAME, timeout);
                GENERATE_B_SIGNAL(
                    PROC_NAME => PROC_NAME, 
                    SIGNALS   => chk_b_signals
                );
                BREADY_O <= '1' after OUTPUT_DELAY;
                WAIT_UNTIL_XFER_B (core, PROC_NAME, timeout);
                BREADY_O <= '0' after OUTPUT_DELAY;
                MATCH_AXI4_B_CHANNEL(core, chk_b_signals, match);
                REPORT_DEBUG(core, PROC_NAME, "END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief スレーブライトトランザクション(応答チャネル)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure EXECUTE_TRANSACTION_SLAVE_WRITE_RESP is
                constant  PROC_NAME  : string := "EXECUTE_TRANSACTION_SLAVE_WRITE_RESP";
            begin
                REPORT_DEBUG(core, PROC_NAME, "BEGIN");
                EXECUTE_SKIP(core, stream);
                LOCAL_SYNC(core, SYNC_TRANS_REQ, SYNC_TRANS_ACK);
                GET_TRANSACTION_INFO(PROC_NAME, WIDTH.WDATA);
                timeout := 10000;
                WAIT_UNTIL_XFER_AW(core, PROC_NAME, timeout);
                GENERATE_B_SIGNAL(
                    PROC_NAME => PROC_NAME, 
                    SIGNALS   => out_signals.B
                );
                WAIT_UNTIL_XFER_W (core, PROC_NAME, timeout, '1');
                EXECUTE_OUTPUT(out_signals);
                WAIT_UNTIL_XFER_B (core, PROC_NAME, timeout);
                out_signals.B := AXI4_B_CHANNEL_SIGNAL_NULL;
                EXECUTE_OUTPUT(out_signals);
                REPORT_DEBUG(core, PROC_NAME, "END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief チャネルオペレーション(SCALAR)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure EXECUTE_CHANNEL_SCALAR_OPERATION is
            begin 
                SKIP_EVENT(core, stream, EVENT_SCALAR);
            end procedure;
            -----------------------------------------------------------------------
            --! @brief チャネルオペレーション(MAP)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure EXECUTE_CHANNEL_MAP_OPERATION is
                constant  PROC_NAME  : string := "EXECUTE_CHANNEL_MAP_OPERATION";
                variable  next_event : EVENT_TYPE;
            begin
                REPORT_DEBUG(core, PROC_NAME, "BEGIN");
                READ_EVENT(core, stream, EVENT_MAP_BEGIN);
                MAP_READ_LOOP: loop
                    MAP_READ_PREPARE_FOR_NEXT(
                        SELF       => core            ,  -- I/O:
                        STREAM     => stream          ,  -- I/O:
                        EVENT      => next_event         -- I/O:
                    );
                    MAP_READ_AXI4_CHANNEL(
                        CORE       => core            ,  -- In :
                        STREAM     => stream          ,  -- I/O:
                        CHANNEL    => CHANNEL         ,  -- In :
                        READ       => READ_ENABLE     ,  -- In :
                        WRITE      => WRITE_ENABLE    ,  -- In :
                        WIDTH      => WIDTH           ,  -- In :
                        SIGNALS    => out_signals     ,  -- I/O:
                        EVENT      => next_event         -- Out:
                    );
                    EXECUTE_OUTPUT(out_signals);
                    case next_event is
                        when EVENT_SCALAR  =>
                            COPY_KEY_WORD(core, keyword);
                            case keyword is
                                when KEY_DEBUG  => EXECUTE_DEBUG (core, stream);
                                when KEY_REPORT => EXECUTE_REPORT(core, stream);
                                when KEY_SAY    => EXECUTE_SAY   (core, stream);
                                when KEY_WAIT   => EXECUTE_WAIT  (core, stream);
                                when KEY_CHECK  => EXECUTE_CHECK (core, stream);
                                when others     => EXECUTE_UNDEFINED_MAP_KEY(core, stream, keyword);
                            end case;
                        when EVENT_MAP_END =>
                            exit MAP_READ_LOOP;
                        when others        =>
                            READ_ERROR(core, PROC_NAME, "need EVENT_MAP_END but " &
                                       EVENT_TO_STRING(next_event));
                    end case;
                end loop;
                REPORT_DEBUG(core, PROC_NAME, "END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief チャネルオペレーションループ
            -----------------------------------------------------------------------
            procedure EXECUTE_CHANNEL_OPERATION is
                constant  PROC_NAME  : string := "EXECUTE_CHANNEL_OPERATION";
                variable  next_event : EVENT_TYPE;
                variable  seq_level  : integer;
            begin
                REPORT_DEBUG(core, PROC_NAME, "BEGIN");
                seq_level := 0;
                SEQ_LOOP: loop
                    SEEK_EVENT(core, stream, next_event);
                    case next_event is
                        when EVENT_SEQ_BEGIN =>
                            READ_EVENT(core, stream, EVENT_SEQ_BEGIN);
                            seq_level := seq_level + 1;
                        when EVENT_SEQ_END   =>
                            READ_EVENT(core, stream, EVENT_SEQ_END  );
                            seq_level := seq_level - 1;
                        when EVENT_MAP_BEGIN =>
                            EXECUTE_CHANNEL_MAP_OPERATION;
                        when EVENT_SCALAR    =>
                            EXECUTE_CHANNEL_SCALAR_OPERATION;
                        when EVENT_ERROR     =>
                            READ_ERROR(core, PROC_NAME, "SEEK_EVENT NG");
                        when others          =>
                            SKIP_EVENT(core, stream, next_event);
                            -- ERROR
                    end case;
                    exit when (seq_level <= 0);
                end loop;
                REPORT_DEBUG(core, PROC_NAME, "END");
            end procedure;
        begin
            -----------------------------------------------------------------------
            -- ダミープラグコアの初期化.
            -----------------------------------------------------------------------
            CORE_INIT(
                SELF        => core,          -- 初期化するコア変数.
                NAME        => NAME,          -- コアの名前.
                VOCAL_NAME  => FULL_NAME,     -- メッセージ出力用の名前.
                STREAM      => stream,        -- シナリオのストリーム.
                STREAM_NAME => SCENARIO_FILE, -- シナリオのストリーム名.
                OPERATION   => operation      -- コアのオペレーション.
            );
            -----------------------------------------------------------------------
            -- 変数の初期化.
            -----------------------------------------------------------------------
            out_signals := INIT_SIGNALS;
            -----------------------------------------------------------------------
            -- 信号の初期化
            -----------------------------------------------------------------------
            SYNC_LOCAL_REQ <= (others => 0);
            SYNC_TRANS_REQ <= (others => 0);
            FINISH         <= '0';
            REPORT_STATUS  <= core.report_status;
            EXECUTE_OUTPUT(out_signals);
            core.debug := 0;
            -----------------------------------------------------------------------
            -- メインオペレーションループ
            -----------------------------------------------------------------------
            while (operation /= OP_FINISH) loop
                REPORT_STATUS <= core.report_status;
                READ_OPERATION(core, stream, operation, keyword);
                case operation is
                    when OP_DOC_BEGIN   => LOCAL_SYNC(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                    when OP_MAP         =>
                        REPORT_DEBUG(core, string'("MAIN_LOOP:OP_MAP(") & keyword & ")");
                        if    (keyword = KEY_CHANNEL) then
                            EXECUTE_CHANNEL_OPERATION;
                        elsif (keyword = KEY_REPORT ) then
                            EXECUTE_REPORT(core, stream);
                        elsif (keyword = KEY_SYNC   ) then
                            LOCAL_SYNC(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                            EXECUTE_SKIP(core, stream);
                        elsif (CHANNEL = AXI4_CHANNEL_R and MASTER and READ_ENABLE  and keyword = KEY_READ ) then
                            EXECUTE_TRANSACTION_MASTER_READ_DATA;
                        elsif (CHANNEL = AXI4_CHANNEL_R and SLAVE  and READ_ENABLE  and keyword = KEY_READ ) then
                            EXECUTE_TRANSACTION_SLAVE_READ_DATA;
                        elsif (CHANNEL = AXI4_CHANNEL_W and MASTER and WRITE_ENABLE and keyword = KEY_WRITE) then
                            EXECUTE_TRANSACTION_MASTER_WRITE_DATA;
                        elsif (CHANNEL = AXI4_CHANNEL_W and SLAVE  and WRITE_ENABLE and keyword = KEY_WRITE) then
                            EXECUTE_TRANSACTION_SLAVE_WRITE_DATA;
                        elsif (CHANNEL = AXI4_CHANNEL_B and MASTER and WRITE_ENABLE and keyword = KEY_WRITE) then
                            EXECUTE_TRANSACTION_MASTER_WRITE_RESP;
                        elsif (CHANNEL = AXI4_CHANNEL_B and SLAVE  and WRITE_ENABLE and keyword = KEY_WRITE) then
                            EXECUTE_TRANSACTION_SLAVE_WRITE_RESP;
                        else
                            REPORT_DEBUG(core, string'("MAIN_LOOP:OP_MAP:SKIP BEGIN"));
                            EXECUTE_SKIP(core, stream);
                            REPORT_DEBUG(core, string'("MAIN_LOOP:OP_MAP:SKIP END"));
                        end if;
                    when OP_SCALAR      =>
                        if (keyword = KEY_SYNC) then
                            LOCAL_SYNC(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                        else
                            EXECUTE_UNDEFINED_SCALAR(core, stream, keyword);
                        end if;
                    when OP_FINISH      => exit;
                    when others         => null;
                end case;
            end loop;
            REPORT_STATUS <= core.report_status;
            FINISH        <= '1';
            if (FINISH_ABORT) then
                assert FALSE report "Simulation complete." severity FAILURE;
            end if;
            wait;
        end process;
    end generate;
end MODEL;
