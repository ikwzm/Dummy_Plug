-----------------------------------------------------------------------------------
--!     @file    axi4_channel_player.vhd
--!     @brief   AXI4 A/R/W/B Channel Dummy Plug Player.
--!     @version 0.0.5
--!     @date    2012/5/15
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
        READ            : --! @brief リードモードを指定する.
                          boolean   := TRUE;
        WRITE           : --! @brief ライトモードを指定する.
                          boolean   := TRUE;
        OUTPUT_DELAY    : --! @brief 出力信号遅延時間
                          time;
        WIDTH           : --! @brief AXI4 IS WIDTH :
                          AXI4_SIGNAL_WIDTH_TYPE;
        SYNC_WIDTH      : --! @brief シンクロ用信号の本数.
                          integer :=  1;
        SYNC_LOCAL_PORT : --! @brief ローカル同期信号のポート番号.
                          integer := 0;
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
        SYNC_LOCAL_REQ  : out   SYNC_REQ_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT);
        SYNC_LOCAL_ACK  : in    SYNC_ACK_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT);
        ---------------------------------------------------------------------------
        -- GPIO
        ---------------------------------------------------------------------------
        GPI             : in    std_logic_vector(GPI_WIDTH-1 downto 0) := (others => '0');
        GPO             : out   std_logic_vector(GPO_WIDTH-1 downto 0);
        ---------------------------------------------------------------------------
        -- 各種状態出力.
        ---------------------------------------------------------------------------
        REPORT_STATUS   : out   REPORT_STATUS_TYPE;
        FINISH          : out   std_logic
    );
end AXI4_CHANNEL_PLAYER;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
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
    --! 
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
    --! 
    -------------------------------------------------------------------------------
    procedure  WAIT_UNTIL_XFER_AR(
        variable CORE       : inout CORE_TYPE;
                 PROC_NAME  : in    STRING;
                 TIMEOUT    : in    integer
    ) is
        variable count      :       integer;
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
    --! 
    -------------------------------------------------------------------------------
    procedure  WAIT_UNTIL_XFER_AW(
        variable CORE       : inout CORE_TYPE;
                 PROC_NAME  : in    STRING;
                 TIMEOUT    : in    integer
    ) is
        variable count      :       integer;
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
    --! 
    -------------------------------------------------------------------------------
    procedure  WAIT_UNTIL_XFER_R(
        variable CORE       : inout CORE_TYPE;
                 PROC_NAME  : in    STRING;
                 TIMEOUT    : in    integer;
                 LAST       : in    std_logic
    ) is
        variable count      :       integer;
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
    --! 
    -------------------------------------------------------------------------------
    procedure  WAIT_UNTIL_XFER_W(
        variable CORE       : inout CORE_TYPE;
                 PROC_NAME  : in    STRING;
                 TIMEOUT    : in    integer;
                 LAST       : in    std_logic
    ) is
        variable count      :       integer;
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
    --! 
    -------------------------------------------------------------------------------
    procedure  WAIT_UNTIL_XFER_B(
        variable CORE       : inout CORE_TYPE;
                 PROC_NAME  : in    STRING;
                 TIMEOUT    : in    integer
    ) is
        variable count      :       integer;
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
    --! 
    -------------------------------------------------------------------------------
    procedure  MATCH_GPI(
        variable CORE       : inout CORE_TYPE;
                 SIGNALS    : in    std_logic_vector;
                 MATCH      : out   boolean
    ) is
        variable count      :       integer;
    begin
        count := 0;
        for i in GPI'range loop
            if (MATCH_STD_LOGIC(SIGNALS(i), GPI(i)) = FALSE) then
                REPORT_MISMATCH(CORE, string'("GPI(") & INTEGER_TO_STRING(i) & ") " &
                                BIN_TO_STRING(GPI(i)) & " /= " &
                                BIN_TO_STRING(SIGNALS(i)));
                count := count + 1;
            end if;
        end loop;
        MATCH := (count = 0);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 全チャネルの期待値と信号の値を比較するサブプログラム.
    -------------------------------------------------------------------------------
    procedure  MATCH_AXI4_CHANNEL(
                 SIGNALS    : in    AXI4_CHANNEL_SIGNAL_TYPE;
                 MATCH      : out   boolean
    ) is
    begin 
        MATCH_AXI4_CHANNEL(
            SIGNALS    => SIGNALS    , -- In  :
            READ       => READ       , -- In  :
            WRITE      => WRITE      , -- In  :
            MATCH      => MATCH      , -- Out :
            ARADDR     => ARADDR_I   , -- In  :
            ARLEN      => ARLEN_I    , -- In  :
            ARSIZE     => ARSIZE_I   , -- In  :
            ARBURST    => ARBURST_I  , -- In  :
            ARLOCK     => ARLOCK_I   , -- In  :
            ARCACHE    => ARCACHE_I  , -- In  :
            ARPROT     => ARPROT_I   , -- In  :
            ARQOS      => ARQOS_I    , -- In  :
            ARREGION   => ARREGION_I , -- In  :
            ARUSER     => ARUSER_I   , -- In  :
            ARID       => ARID_I     , -- In  :
            ARVALID    => ARVALID_I  , -- In  :
            ARREADY    => ARREADY_I  , -- In  :
            AWADDR     => AWADDR_I   , -- In  :
            AWLEN      => AWLEN_I    , -- In  :
            AWSIZE     => AWSIZE_I   , -- In  :
            AWBURST    => AWBURST_I  , -- In  :
            AWLOCK     => AWLOCK_I   , -- In  :
            AWCACHE    => AWCACHE_I  , -- In  :
            AWPROT     => AWPROT_I   , -- In  :
            AWQOS      => AWQOS_I    , -- In  :
            AWREGION   => AWREGION_I , -- In  :
            AWUSER     => AWUSER_I   , -- In  :
            AWID       => AWID_I     , -- In  :
            AWVALID    => AWVALID_I  , -- In  :
            AWREADY    => AWREADY_I  , -- In  :
            RLAST      => RLAST_I    , -- In  :
            RDATA      => RDATA_I    , -- In  :
            RRESP      => RRESP_I    , -- In  :
            RUSER      => RUSER_I    , -- In  :
            RID        => RID_I      , -- In  :
            RVALID     => RVALID_I   , -- In  :
            RREADY     => RREADY_I   , -- In  :
            WLAST      => WLAST_I    , -- In  :
            WDATA      => WDATA_I    , -- In  :
            WSTRB      => WSTRB_I    , -- In  :
            WUSER      => WUSER_I    , -- In  :
            WID        => WID_I      , -- In  :
            WVALID     => WVALID_I   , -- In  :
            WREADY     => WREADY_I   , -- In  :
            BRESP      => BRESP_I    , -- In  :
            BUSER      => BUSER_I    , -- In  :
            BID        => BID_I      , -- In  :
            BVALID     => BVALID_I   , -- In  :
            BREADY     => BREADY_I     -- In  :
         );
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ライトアドレスチャネルの期待値と信号の値を比較するサブプログラム.
    -------------------------------------------------------------------------------
    procedure MATCH_AXI4_AW_CHANNEL(
        variable CORE       : inout CORE_TYPE;
                 SIGNALS    : in    AXI4_A_CHANNEL_SIGNAL_TYPE;
                 MATCH      : out   boolean
    ) is
    begin
        MATCH_AXI4_CHANNEL(
            SELF    => CORE      , -- I/O :
            NAME    => "AW"      , -- In  :
            SIGNALS => SIGNALS   , -- In  :
            MATCH   => MATCH     , -- Out :
            ADDR    => AWADDR_I  , -- In  :
            LEN     => AWLEN_I   , -- In  :
            SIZE    => AWSIZE_I  , -- In  :
            BURST   => AWBURST_I , -- In  :
            LOCK    => AWLOCK_I  , -- In  :
            CACHE   => AWCACHE_I , -- In  :
            PROT    => AWPROT_I  , -- In  :
            QOS     => AWQOS_I   , -- In  :
            REGION  => AWREGION_I, -- In  :
            USER    => AWUSER_I  , -- In  :
            ID      => AWID_I    , -- In  :
            VALID   => AWVALID_I , -- In  :
            READY   => AWREADY_I   -- In  :
        );
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ライトデータチャネルの期待値と信号の値を比較するサブプログラム.
    -------------------------------------------------------------------------------
    procedure MATCH_AXI4_W_CHANNEL(
        variable CORE       : inout CORE_TYPE;
                 SIGNALS    : in    AXI4_W_CHANNEL_SIGNAL_TYPE;
                 MATCH      : out   boolean
    ) is
    begin
        MATCH_AXI4_CHANNEL(
            SELF    => CORE      , -- I/O :
            NAME    => "W"       , -- In  :
            SIGNALS => SIGNALS   , -- In  :
            MATCH   => MATCH     , -- Out :
            LAST    => WLAST_I   , -- In  :
            DATA    => WDATA_I   , -- In  :
            STRB    => WSTRB_I   , -- In  :
            USER    => WUSER_I   , -- In  :
            ID      => WID_I     , -- In  :
            VALID   => WVALID_I  , -- In  :
            READY   => WREADY_I    -- In  :
        );
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ライト応答チャネルの期待値と信号の値を比較するサブプログラム.
    -------------------------------------------------------------------------------
    procedure MATCH_AXI4_B_CHANNEL(
        variable CORE       : inout CORE_TYPE;
                 SIGNALS    : in    AXI4_B_CHANNEL_SIGNAL_TYPE;
                 MATCH      : out   boolean
    ) is
    begin
        MATCH_AXI4_CHANNEL(
            SELF    => CORE      , -- I/O :
            NAME    => "B"       , -- In  :
            SIGNALS => SIGNALS   , -- In  :
            MATCH   => MATCH     , -- Out :
            RESP    => BRESP_I   , -- In  :
            USER    => BUSER_I   , -- In  :
            ID      => BID_I     , -- In  :
            VALID   => BVALID_I  , -- In  :
            READY   => BREADY_I    -- In  :
        );
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief リードアドレスチャネルの期待値と信号の値を比較するサブプログラム.
    -------------------------------------------------------------------------------
    procedure MATCH_AXI4_AR_CHANNEL(
        variable SELF       : inout CORE_TYPE;
                 SIGNALS    : in    AXI4_A_CHANNEL_SIGNAL_TYPE;
                 MATCH      : out   boolean
    ) is
    begin
        MATCH_AXI4_CHANNEL(
            SELF    => SELF      , -- I/O :
            NAME    => "AR"      , -- In  :
            SIGNALS => SIGNALS   , -- In  :
            MATCH   => MATCH     , -- Out :
            ADDR    => ARADDR_I  , -- In  :
            LEN     => ARLEN_I   , -- In  :
            SIZE    => ARSIZE_I  , -- In  :
            BURST   => ARBURST_I , -- In  :
            LOCK    => ARLOCK_I  , -- In  :
            CACHE   => ARCACHE_I , -- In  :
            PROT    => ARPROT_I  , -- In  :
            QOS     => ARQOS_I   , -- In  :
            REGION  => ARREGION_I, -- In  :
            USER    => ARUSER_I  , -- In  :
            ID      => ARID_I    , -- In  :
            VALID   => ARVALID_I , -- In  :
            READY   => ARREADY_I   -- In  :
        );
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief リードデータチャネルの期待値と信号の値を比較するサブプログラム.
    -------------------------------------------------------------------------------
    procedure MATCH_AXI4_R_CHANNEL(
        variable CORE       : inout CORE_TYPE;
                 SIGNALS    : in    AXI4_R_CHANNEL_SIGNAL_TYPE;
                 MATCH      : out   boolean
    ) is
    begin
        MATCH_AXI4_CHANNEL(
            SELF    => CORE      , -- I/O :
            NAME    => "R"       , -- In  :
            SIGNALS => SIGNALS   , -- In  :
            MATCH   => MATCH     , -- Out :
            LAST    => RLAST_I   , -- In  :
            DATA    => RDATA_I   , -- In  :
            RESP    => RRESP_I   , -- In  :
            USER    => RUSER_I   , -- In  :
            ID      => RID_I     , -- In  :
            VALID   => RVALID_I  , -- In  :
            READY   => RREADY_I    -- In  :
        );
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 全チャネルの期待値と信号の値を比較するサブプログラム.
    -------------------------------------------------------------------------------
    procedure  MATCH_AXI4_CHANNEL(
        variable CORE       : inout CORE_TYPE;
                 SIGNALS    : in    AXI4_CHANNEL_SIGNAL_TYPE;
                 MATCH      : out   boolean
    ) is
        variable aw_match   :       boolean;
        variable w_match    :       boolean;
        variable b_match    :       boolean;
        variable ar_match   :       boolean;
        variable r_match    :       boolean;
    begin
        if (WRITE) then
            MATCH_AXI4_AW_CHANNEL(CORE, SIGNALS.AW, aw_match);
            MATCH_AXI4_W_CHANNEL (CORE, SIGNALS.W , w_match );
            MATCH_AXI4_B_CHANNEL (CORE, SIGNALS.B , b_match );
        else
            aw_match := TRUE;
            w_match  := TRUE;
            b_match  := TRUE;
        end if;
        if (READ) then
            MATCH_AXI4_AR_CHANNEL(CORE, SIGNALS.AR, ar_match);
            MATCH_AXI4_R_CHANNEL (CORE, SIGNALS.R , r_match );
        else
            ar_match := TRUE;
            r_match  := TRUE;
        end if;
        MATCH := aw_match and w_match and b_match and ar_match and r_match;
    end procedure;
    -------------------------------------------------------------------------------
    --! 
    -------------------------------------------------------------------------------
    procedure  MAP_READ_AXI4_CHANNEL(
        variable  CORE     : inout CORE_TYPE;
        file      STREAM   :       TEXT;
        variable  SIGNALS  : inout AXI4_CHANNEL_SIGNAL_TYPE;
        variable  EVENT    : inout EVENT_TYPE
    ) is
    begin
        MAP_READ_AXI4_CHANNEL(
            SELF           => CORE                 ,  -- In :
            STREAM         => STREAM               ,  -- I/O:
            CHANNEL        => CHANNEL              ,  -- In :
            READ           => READ                 ,  -- In :
            WRITE          => WRITE                ,  -- In :
            WIDTH          => WIDTH                ,  -- In :
            SIGNALS        => SIGNALS              ,  -- I/O:
            EVENT          => EVENT                   -- I/O:
        );
    end procedure;
begin 
    -------------------------------------------------------------------------------
    -- チャネルプロシージャ
    -------------------------------------------------------------------------------
    process
        ---------------------------------------------------------------------------
        -- キーワードの定義.
        ---------------------------------------------------------------------------
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
        ---------------------------------------------------------------------------
        -- トランザクションデータバッファサイズ
        ---------------------------------------------------------------------------
        function  GENERATE_DATA_BUF_SIZE return integer is
        begin
            case CHANNEL is
                when AXI4_CHANNEL_R  => return AXI4_XFER_MAX_BYTES*8;
                when AXI4_CHANNEL_W  => return AXI4_XFER_MAX_BYTES*8;
                when others          => return 1;
            end case;
        end function;
        constant  DATA_BUF_SIZE : integer      := GENERATE_DATA_BUF_SIZE;
        ---------------------------------------------------------------------------
        -- 各種変数の定義.
        ---------------------------------------------------------------------------
        file      stream        : TEXT;
        variable  core          : CORE_TYPE;
        variable  keyword       : KEYWORD_TYPE;
        variable  operation     : OPERATION_TYPE;
        variable  out_signals   : AXI4_CHANNEL_SIGNAL_TYPE;
        variable  chk_signals   : AXI4_CHANNEL_SIGNAL_TYPE;
        variable  tmp_signals   : AXI4_CHANNEL_SIGNAL_TYPE;
        variable  gpi_signals   : std_logic_vector(GPI'range);
        variable  gpo_signals   : std_logic_vector(GPO'range);
        variable  data_buf      : std_logic_vector(DATA_BUF_SIZE-1 downto 0);
        ---------------------------------------------------------------------------
        --! @brief 
        ---------------------------------------------------------------------------
        procedure SCAN_INTEGER(VAL: out integer;LEN: out integer) is
        begin
            STRING_TO_INTEGER(core.str_buf(1 to core.str_len), VAL, LEN);
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief 
        ---------------------------------------------------------------------------
        procedure EXECUTE_UNDEFINED_MAP_KEY(KEY:in STRING) is
        begin
            EXECUTE_UNDEFINED_MAP_KEY(core, stream, KEY);
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief 
        ---------------------------------------------------------------------------
        procedure EXECUTE_UNDEFINED_SCALAR(KEY:in STRING) is
        begin
            EXECUTE_UNDEFINED_SCALAR(core, stream, KEY);
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief チャネル信号変数の初期化.
        ---------------------------------------------------------------------------
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
        ---------------------------------------------------------------------------
        --! @brief 信号変数(out_signals)の値をポートに出力するサブプログラム.
        ---------------------------------------------------------------------------
        procedure EXECUTE_OUTPUT is
        begin 
            if (MASTER and WRITE) then
                case CHANNEL is
                    when AXI4_CHANNEL_AW =>
                        AWADDR_O  <= out_signals.AW.ADDR(AWADDR_O'range)after OUTPUT_DELAY;
                        AWVALID_O <= out_signals.AW.VALID               after OUTPUT_DELAY;
                        AWLEN_O   <= out_signals.AW.LEN                 after OUTPUT_DELAY;
                        AWSIZE_O  <= out_signals.AW.SIZE                after OUTPUT_DELAY;
                        AWBURST_O <= out_signals.AW.BURST               after OUTPUT_DELAY;
                        AWLOCK_O  <= out_signals.AW.LOCK                after OUTPUT_DELAY;
                        AWCACHE_O <= out_signals.AW.CACHE               after OUTPUT_DELAY;
                        AWPROT_O  <= out_signals.AW.PROT                after OUTPUT_DELAY;
                        AWQOS_O   <= out_signals.AW.QOS                 after OUTPUT_DELAY;
                        AWREGION_O<= out_signals.AW.REGION              after OUTPUT_DELAY;
                        AWUSER_O  <= out_signals.AW.id(AWUSER_O'range)  after OUTPUT_DELAY;
                        AWID_O    <= out_signals.AW.id(AWID_O'range)    after OUTPUT_DELAY;
                    when AXI4_CHANNEL_W =>
                        WDATA_O   <= out_signals.W.DATA(WDATA_O'range)  after OUTPUT_DELAY;
                        WLAST_O   <= out_signals.W.LAST                 after OUTPUT_DELAY;
                        WSTRB_O   <= out_signals.W.STRB(WSTRB_O'range)  after OUTPUT_DELAY;
                        WUSER_O   <= out_signals.W.USER(WUSER_O'range)  after OUTPUT_DELAY;
                        WID_O     <= out_signals.W.ID(WID_O'range)      after OUTPUT_DELAY;
                        WVALID_O  <= out_signals.W.VALID                after OUTPUT_DELAY;
                    when AXI4_CHANNEL_B =>
                        BREADY_O  <= out_signals.B.READY                after OUTPUT_DELAY;
                    when others =>
                        null;
                end case;
            end if;
            if (MASTER and READ) then
                case CHANNEL is
                    when AXI4_CHANNEL_AR =>
                        ARADDR_O  <= out_signals.AR.ADDR(ARADDR_O'range)after OUTPUT_DELAY;
                        ARVALID_O <= out_signals.AR.VALID               after OUTPUT_DELAY;
                        ARLEN_O   <= out_signals.AR.LEN                 after OUTPUT_DELAY;
                        ARSIZE_O  <= out_signals.AR.SIZE                after OUTPUT_DELAY;
                        ARBURST_O <= out_signals.AR.BURST               after OUTPUT_DELAY;
                        ARLOCK_O  <= out_signals.AR.LOCK                after OUTPUT_DELAY;
                        ARCACHE_O <= out_signals.AR.CACHE               after OUTPUT_DELAY;
                        ARPROT_O  <= out_signals.AR.PROT                after OUTPUT_DELAY;
                        ARQOS_O   <= out_signals.AR.QOS                 after OUTPUT_DELAY;
                        ARREGION_O<= out_signals.AR.REGION              after OUTPUT_DELAY;
                        ARUSER_O  <= out_signals.AR.id(ARUSER_O'range)  after OUTPUT_DELAY;
                        ARID_O    <= out_signals.AR.id(ARID_O'range)    after OUTPUT_DELAY;
                    when AXI4_CHANNEL_R =>
                        RREADY_O  <= out_signals.R.READY                after OUTPUT_DELAY;
                    when others =>
                        null;
                end case;
            end if;
            if (SLAVE and WRITE) then
                case CHANNEL is
                    when AXI4_CHANNEL_AW =>
                        AWREADY_O <= out_signals.AW.READY               after OUTPUT_DELAY;
                    when AXI4_CHANNEL_W  =>
                        WREADY_O  <= out_signals.W.READY                after OUTPUT_DELAY;
                    when AXI4_CHANNEL_B  =>
                        BRESP_O   <= out_signals.B.RESP                 after OUTPUT_DELAY;
                        BUSER_O   <= out_signals.B.USER(BUSER_O'range)  after OUTPUT_DELAY;
                        BID_O     <= out_signals.B.ID(BID_O'range)      after OUTPUT_DELAY;
                        BVALID_O  <= out_signals.B.VALID                after OUTPUT_DELAY;
                    when others =>
                        null;
                end case;
            end if;
            if (SLAVE and READ) then
                case CHANNEL is
                    when AXI4_CHANNEL_AR =>
                        ARREADY_O <= out_signals.AR.READY               after OUTPUT_DELAY;
                    when AXI4_CHANNEL_R  =>
                        RDATA_O   <= out_signals.R.DATA(RDATA_O'range)  after OUTPUT_DELAY;
                        RRESP_O   <= out_signals.R.RESP                 after OUTPUT_DELAY;
                        RLAST_O   <= out_signals.R.LAST                 after OUTPUT_DELAY;
                        RUSER_O   <= out_signals.R.USER(RUSER_O'range)  after OUTPUT_DELAY;
                        RID_O     <= out_signals.R.ID(RID_O'range)      after OUTPUT_DELAY;
                        RVALID_O  <= out_signals.R.VALID                after OUTPUT_DELAY;
                    when others =>
                        null;
                end case;
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief ローカル同期オペレーション.
        ---------------------------------------------------------------------------
        procedure LOCAL_SYNC is
            constant  PROC_NAME  : string := "LOCAL_SYNC";
            variable  sync_count : SYNC_REQ_VECTOR(SYNC_LOCAL_REQ'range);
        begin
            REPORT_DEBUG(core, PROC_NAME, "BEGIN");
            sync_count(SYNC_LOCAL_PORT) := SYNC_LOCAL_WAIT;
            SYNC_BEGIN(SYNC_LOCAL_REQ,                 sync_count);
            REPORT_DEBUG(core, PROC_NAME, "SYNC");
            SYNC_END  (SYNC_LOCAL_REQ, SYNC_LOCAL_ACK, sync_count);
            REPORT_DEBUG(core, PROC_NAME, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief CHECKオペレーション.信号が指定された値になっているかチェック.
        ---------------------------------------------------------------------------
        procedure EXECUTE_CHECK is
            constant  PROC_NAME  : string := "EXECUTE_CHECK";
            variable  next_event : EVENT_TYPE;
            variable  match      : boolean;
        begin
            REPORT_DEBUG(core, PROC_NAME, "BEGIN");
            SEEK_EVENT(core, stream, next_event);
            case next_event is
                when EVENT_MAP_BEGIN =>
                    READ_EVENT(core, stream, EVENT_MAP_BEGIN);
                    chk_signals := AXI4_CHANNEL_SIGNAL_DONTCARE;
                    gpi_signals := (others => '-');
                    MAP_READ_LOOP: loop
                        MAP_READ_PREPARE_FOR_NEXT(
                            SELF       => core            ,  -- I/O:
                            STREAM     => stream          ,  -- I/O:
                            EVENT      => next_event         -- I/O:
                        );
                        MAP_READ_AXI4_CHANNEL(
                            CORE       => core            ,  -- I/O:
                            STREAM     => stream          ,  -- I/O:
                            SIGNALS    => chk_signals     ,  -- I/O:
                            EVENT      => next_event         -- I/O:
                        );
                        MAP_READ_STD_LOGIC_VECTOR(
                            SELF       => core            ,  -- I/O:
                            STREAM     => stream          ,  -- I/O:
                            KEY        => "GPI"           ,  -- In :
                            VAL        => gpi_signals     ,  -- I/O:
                            EVENT      => next_event         -- I/O:
                        );
                        case next_event is
                            when EVENT_SCALAR  =>
                                COPY_KEY_WORD(core, keyword);
                                EXECUTE_UNDEFINED_MAP_KEY(keyword);
                            when EVENT_MAP_END =>
                                exit MAP_READ_LOOP;
                            when others        =>
                                READ_ERROR(core, PROC_NAME, "need EVENT_MAP_END but " &
                                           EVENT_TO_STRING(next_event));
                        end case;
                    end loop;
                    MATCH_AXI4_CHANNEL(core, chk_signals, match);
                    MATCH_GPI         (core, gpi_signals, match);
                when others =>
                    READ_ERROR(core, PROC_NAME, "SEEK_EVENT NG");
            end case;
            REPORT_DEBUG(core, PROC_NAME, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  WAITオペレーション. 指定された条件まで待機.
        ---------------------------------------------------------------------------
        procedure EXECUTE_WAIT is
            constant  PROC_NAME  : string := "EXECUTE_WAIT";
            variable  next_event : EVENT_TYPE;
            variable  wait_count : integer;
            variable  scan_len   : integer;
            variable  timeout    : integer;
            variable  wait_on    : boolean;
            variable  axi_match  : boolean;
            variable  gpi_match  : boolean;
        begin
            REPORT_DEBUG(core, PROC_NAME, "BEGIN");
            timeout   := DEFAULT_WAIT_TIMEOUT;
            wait_on   := FALSE;
            SEEK_EVENT(core, stream, next_event);
            case next_event is
                when EVENT_SCALAR =>
                    READ_EVENT(core, stream, EVENT_SCALAR);
                    SCAN_INTEGER(wait_count, scan_len);
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
                    READ_EVENT(core, stream, EVENT_MAP_BEGIN);
                    chk_signals := AXI4_CHANNEL_SIGNAL_DONTCARE;
                    gpi_signals := (others => '-');
                    MAP_READ_LOOP: loop
                        REPORT_DEBUG(core, PROC_NAME, "MAP_READ_LOOP");
                        MAP_READ_PREPARE_FOR_NEXT(
                            SELF       => core            ,  -- I/O:
                            STREAM     => stream          ,  -- I/O:
                            EVENT      => next_event         -- I/O:
                        );
                        MAP_READ_AXI4_CHANNEL(
                            CORE       => core            ,  -- I/O:
                            STREAM     => stream          ,  -- I/O:
                            SIGNALS    => chk_signals     ,  -- I/O:
                            EVENT      => next_event         -- I/O:
                        );
                        MAP_READ_STD_LOGIC_VECTOR(
                            SELF       => core            ,  -- I/O:
                            STREAM     => stream          ,  -- I/O:
                            KEY        => "GPI"           ,  -- In :
                            VAL        => gpi_signals     ,  -- I/O:
                            EVENT      => next_event         -- I/O:
                        );
                        MAP_READ_INTEGER(
                            SELF       => core            ,  -- I/O:
                            STREAM     => stream          ,  -- I/O:
                            KEY        => "TIMEOUT"       ,  -- In :
                            VAL        => timeout         ,  -- I/O:
                            EVENT      => next_event         -- I/O:
                        );
                        MAP_READ_BOOLEAN(
                            SELF       => core            ,  -- I/O:
                            STREAM     => stream          ,  -- I/O:
                            KEY        => "ON"            ,  -- In :
                            VAL        => wait_on         ,  -- I/O:
                            EVENT      => next_event         -- I/O:
                        );
                        case next_event is
                            when EVENT_SCALAR  =>
                                COPY_KEY_WORD(core, keyword);
                                EXECUTE_UNDEFINED_MAP_KEY(keyword);
                            when EVENT_MAP_END =>
                                exit MAP_READ_LOOP;
                            when others        =>
                                READ_ERROR(core, PROC_NAME, "need EVENT_MAP_END but " &
                                           EVENT_TO_STRING(next_event));
                        end case;
                    end loop;
                    if (wait_on) then
                        SIG_LOOP:loop
                            REPORT_DEBUG(core, PROC_NAME, "SIG_LOOP");
                            WAIT_ON_SIGNALS;
                            MATCH_AXI4_CHANNEL(chk_signals, axi_match);
                            gpi_match := MATCH_STD_LOGIC(gpi_signals, GPI);
                            exit when(axi_match and gpi_match);
                            if (ACLK'event and ACLK = '1') then
                                if (timeout > 0) then
                                    timeout := timeout - 1;
                                else
                                    EXECUTE_ABORT(core, PROC_NAME, "Time Out!");
                                end if;
                            end if;
                        end loop;
                    else
                        CLK_LOOP:loop
                            REPORT_DEBUG(core, PROC_NAME, "CLK_LOOP");
                            wait until (ACLK'event and ACLK = '1');
                            MATCH_AXI4_CHANNEL(chk_signals, axi_match);
                            gpi_match := MATCH_STD_LOGIC(gpi_signals, GPI);
                            exit when(axi_match and gpi_match);
                            if (timeout > 0) then
                                timeout := timeout - 1;
                            else
                                EXECUTE_ABORT(core, PROC_NAME, "Time Out!");
                            end if;
                        end loop;
                    end if;
                when others =>
                    READ_ERROR(core, PROC_NAME, "SEEK_EVENT NG");
            end case;
            REPORT_DEBUG(core, PROC_NAME, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  SYNCオペレーション. 
        ---------------------------------------------------------------------------
        procedure EXECUTE_SYNC(operation: in OPERATION_TYPE) is
            constant  PROC_NAME  : string := "EXECUTE_SYNC";
            variable  port_num   : integer;
            variable  wait_num   : integer;
        begin
            REPORT_DEBUG  (core, PROC_NAME, "BEGIN");
            READ_SYNC_ARGS(core, stream, operation, port_num, wait_num);
            REPORT_DEBUG  (core, PROC_NAME, "PORT=" & INTEGER_TO_STRING(port_num) &
                                           " WAIT=" & INTEGER_TO_STRING(wait_num));
            LOCAL_SYNC;
            if (SYNC_REQ'low <= port_num and port_num <= SYNC_REQ'high) then
                CORE_SYNC(core, port_num, wait_num, SYNC_REQ, SYNC_ACK);
            end if;
            REPORT_DEBUG  (core, PROC_NAME, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief トランザクションの情報をシナリオから読むサブプログラム.
        ---------------------------------------------------------------------------
        procedure READ_TRANSACTION_INFO(
                      PROC_NAME  : in     STRING;
                      ADDR_WIDTH : in     integer;
                      USER_WIDTH : in     integer;
            variable  A_CHANNEL  : inout  AXI4_A_CHANNEL_SIGNAL_TYPE;
            variable  RESP       : inout  AXI4_RESP_TYPE;
            variable  DATA_BUF   : inout  std_logic_vector;
            variable  DATA_LEN   : inout  integer;
            variable  TIMEOUT    : inout  integer
        ) is
            variable  next_event : EVENT_TYPE;
        begin
            TIMEOUT  := DEFAULT_WAIT_TIMEOUT;
            DATA_LEN := 0;
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
                            SELF       => core            ,  -- I/O:
                            STREAM     => stream          ,  -- I/O:
                            ADDR_WIDTH => ADDR_WIDTH      ,  -- In :
                            USER_WIDTH => USER_WIDTH      ,  -- In :
                            ID_WIDTH   => WIDTH.ID        ,  -- In :
                            A_CHANNEL  => A_CHANNEL       ,  -- I/O:
                            RESP       => RESP            ,  -- I/O:
                            DATA_BUF   => DATA_BUF        ,  -- I/O:
                            DATA_LEN   => DATA_LEN        ,  -- I/O:
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
                                EXECUTE_UNDEFINED_MAP_KEY(keyword);
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
        ---------------------------------------------------------------------------
        --! @brief マスターリードトランザクション実行サブプログラム.
        ---------------------------------------------------------------------------
        procedure EXECUTE_TRANSACTION_MASTER_READ is
            constant  PROC_NAME  : string := "EXECUTE_TRANSACTION_MASTER_READ";
            variable  data_len   : integer;
            variable  timeout    : integer;
            variable  match      : boolean;
            variable  a_channel  : AXI4_A_CHANNEL_SIGNAL_TYPE;
            variable  responce   : AXI4_RESP_TYPE;
        begin
            REPORT_DEBUG(core, PROC_NAME, "BEGIN");
            a_channel := AXI4_A_CHANNEL_SIGNAL_NULL;
            READ_TRANSACTION_INFO(
                PROC_NAME  => PROC_NAME   ,
                ADDR_WIDTH => WIDTH.ARADDR,
                USER_WIDTH => WIDTH.ARUSER,
                A_CHANNEL  => a_channel   ,
                RESP       => responce    ,
                DATA_BUF   => data_buf    ,
                DATA_LEN   => data_len    ,
                TIMEOUT    => timeout
            );
            if (data_len > 0) then
                case CHANNEL is
                    when AXI4_CHANNEL_AR =>
                        out_signals.AR       := a_channel;
                        out_signals.AR.VALID := '1';
                        EXECUTE_OUTPUT;
                        WAIT_UNTIL_XFER_AR(core, PROC_NAME, timeout);
                        out_signals.AR       := AXI4_A_CHANNEL_SIGNAL_NULL;
                        EXECUTE_OUTPUT;
                    when AXI4_CHANNEL_R =>
                        out_signals.R.READY  := '0';
                        EXECUTE_OUTPUT;
                        WAIT_UNTIL_XFER_AR(core, PROC_NAME, timeout);
                        out_signals.R.VALID  := '1';
                        WAIT_UNTIL_XFER_R (core, PROC_NAME, timeout, '1');
                        out_signals.R        := AXI4_R_CHANNEL_SIGNAL_NULL;
                        EXECUTE_OUTPUT;
                    when others => null;
                end case;
            end if;
            REPORT_DEBUG(core, PROC_NAME, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief スレーブリードトランザクション実行サブプログラム.
        ---------------------------------------------------------------------------
        procedure EXECUTE_TRANSACTION_SLAVE_READ is
            constant PROC_NAME  : string := "EXECUTE_TRANSACTION_SLAVE_READ";
            variable  data_len   : integer;
            variable  timeout    : integer;
            variable  match      : boolean;
            variable  a_channel  : AXI4_A_CHANNEL_SIGNAL_TYPE;
            variable  responce   : AXI4_RESP_TYPE;
        begin
            REPORT_DEBUG(core, PROC_NAME, "BEGIN");
            a_channel := AXI4_A_CHANNEL_SIGNAL_NULL;
            READ_TRANSACTION_INFO(
                PROC_NAME  => PROC_NAME   ,
                ADDR_WIDTH => WIDTH.ARADDR,
                USER_WIDTH => WIDTH.ARUSER,
                A_CHANNEL  => a_channel   ,
                RESP       => responce    ,
                DATA_BUF   => data_buf    ,
                DATA_LEN   => data_len    ,
                TIMEOUT    => timeout
            );
            if (data_len > 0) then
            end if;
            REPORT_DEBUG(core, PROC_NAME, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief マスターライトトランザクション実行サブプログラム.
        ---------------------------------------------------------------------------
        procedure EXECUTE_TRANSACTION_MASTER_WRITE is
            constant  PROC_NAME  : string := "EXECUTE_TRANSACTION_MASTER_WRITE";
            variable  data_len   : integer;
            variable  timeout    : integer;
            variable  match      : boolean;
            variable  a_channel  : AXI4_A_CHANNEL_SIGNAL_TYPE;
            variable  b_channel  : AXI4_B_CHANNEL_SIGNAL_TYPE;
        begin
            REPORT_DEBUG(core, PROC_NAME, "BEGIN");
            a_channel := AXI4_A_CHANNEL_SIGNAL_NULL;
            b_channel := AXI4_B_CHANNEL_SIGNAL_NULL;
            READ_TRANSACTION_INFO(
                PROC_NAME  => PROC_NAME     ,
                ADDR_WIDTH => WIDTH.AWADDR  ,
                USER_WIDTH => WIDTH.AWUSER  ,
                A_CHANNEL  => a_channel     ,
                RESP       => b_channel.RESP,
                DATA_BUF   => data_buf      ,
                DATA_LEN   => data_len      ,
                TIMEOUT    => timeout
            );
            if (data_len > 0) then
                case CHANNEL is
                    when AXI4_CHANNEL_AW =>
                        out_signals.AW       := a_channel;
                        out_signals.AW.VALID := '1';
                        EXECUTE_OUTPUT;
                        WAIT_UNTIL_XFER_AW(core, PROC_NAME, timeout);
                        out_signals.AW       := AXI4_A_CHANNEL_SIGNAL_NULL;
                        EXECUTE_OUTPUT;
                    when AXI4_CHANNEL_B =>
                        out_signals.B.READY := '0';
                        EXECUTE_OUTPUT;
                        WAIT_UNTIL_XFER_AW(core, PROC_NAME, timeout);
                        out_signals.B.READY := '1';
                        EXECUTE_OUTPUT;
                        WAIT_UNTIL_XFER_B (core, PROC_NAME, timeout);
                        MATCH_AXI4_B_CHANNEL(core, b_channel, match);
                        out_signals.B.READY := '0';
                        EXECUTE_OUTPUT;
                    when others => null;
                end case;
            end if;
            REPORT_DEBUG(core, PROC_NAME, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief スレーブライトトランザクション実行サブプログラム.
        ---------------------------------------------------------------------------
        procedure EXECUTE_TRANSACTION_SLAVE_WRITE is
            constant  PROC_NAME  : string := "EXECUTE_TRANSACTION_SLAVE_WRITE";
            variable  data_len   : integer;
            variable  timeout    : integer;
            variable  match      : boolean;
            variable  a_channel  : AXI4_A_CHANNEL_SIGNAL_TYPE;
            variable  b_channel  : AXI4_B_CHANNEL_SIGNAL_TYPE;
        begin
            REPORT_DEBUG(core, PROC_NAME, "BEGIN");
            a_channel := AXI4_A_CHANNEL_SIGNAL_NULL;
            b_channel := AXI4_B_CHANNEL_SIGNAL_NULL;
            READ_TRANSACTION_INFO(
                PROC_NAME  => PROC_NAME     ,
                ADDR_WIDTH => WIDTH.AWADDR  ,
                USER_WIDTH => WIDTH.AWUSER  ,
                A_CHANNEL  => a_channel     ,
                RESP       => b_channel.RESP,
                DATA_BUF   => data_buf      ,
                DATA_LEN   => data_len      ,
                TIMEOUT    => timeout
            );
            if (data_len > 0) then
                case CHANNEL is
                    when AXI4_CHANNEL_AW =>
                        out_signals.AW.READY := '1';
                        EXECUTE_OUTPUT;
                        WAIT_UNTIL_XFER_AW(core, PROC_NAME, timeout);
                        MATCH_AXI4_AW_CHANNEL(core, a_channel, match);
                        out_signals.AW.READY := '0';
                        EXECUTE_OUTPUT;
                    when AXI4_CHANNEL_B =>
                        out_signals.B := AXI4_B_CHANNEL_SIGNAL_NULL;
                        EXECUTE_OUTPUT;
                        WAIT_UNTIL_XFER_W(core, PROC_NAME, timeout, '1');
                        out_signals.B.RESP   := b_channel.RESP;
                        out_signals.B.ID     := a_channel.ID;
                        out_signals.B.VALID  := '1';
                        EXECUTE_OUTPUT;
                        WAIT_UNTIL_XFER_B(core, PROC_NAME, timeout);
                        out_signals.B := AXI4_B_CHANNEL_SIGNAL_NULL;
                        EXECUTE_OUTPUT;
                    when others => null;
                end case;
            end if;
            REPORT_DEBUG(core, PROC_NAME, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief リードトランザクション実行サブプログラム.
        ---------------------------------------------------------------------------
        procedure EXECUTE_TRANSACTION_READ is
            constant  PROC_NAME  : string := "EXECUTE_TRANSACTION_READ";
        begin
            REPORT_DEBUG(core, PROC_NAME, "BEGIN");
            case CHANNEL is
                when AXI4_CHANNEL_AR |
                     AXI4_CHANNEL_R  =>
                    if (MASTER and READ ) then
                        EXECUTE_TRANSACTION_MASTER_READ;
                    end if;
                    if (SLAVE  and READ ) then
                        EXECUTE_TRANSACTION_SLAVE_READ;
                    end if;
                when others =>
                        EXECUTE_SKIP(core, stream);
            end case;
            REPORT_DEBUG(core, PROC_NAME, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief ライトトランザクション実行サブプログラム.
        ---------------------------------------------------------------------------
        procedure EXECUTE_TRANSACTION_WRITE is
            constant  PROC_NAME  : string := "EXECUTE_TRANSACTION_WRITE";
        begin
            REPORT_DEBUG(core, PROC_NAME, "BEGIN");
            case CHANNEL is
                when AXI4_CHANNEL_AW |
                     AXI4_CHANNEL_W  |
                     AXI4_CHANNEL_B  =>
                    if (MASTER and WRITE) then
                        EXECUTE_TRANSACTION_MASTER_WRITE;
                    end if;
                    if (SLAVE  and WRITE) then
                        EXECUTE_TRANSACTION_SLAVE_WRITE;
                    end if;
                when others =>
                        EXECUTE_SKIP(core, stream);
            end case;
            REPORT_DEBUG(core, PROC_NAME, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief チャネルオペレーション(SCALAR)実行サブプログラム.
        ---------------------------------------------------------------------------
        procedure EXECUTE_CHANNEL_SCALAR_OPERATION is
        begin 
            SKIP_EVENT(core, stream, EVENT_SCALAR);
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief チャネルオペレーション(MAP)実行サブプログラム.
        ---------------------------------------------------------------------------
        procedure EXECUTE_CHANNEL_MAP_OPERATION is
            constant  PROC_NAME  : string := "EXECUTE_CHANNEL_MAP_OPERATION";
            variable  next_event : EVENT_TYPE;
        begin
            REPORT_DEBUG(core, PROC_NAME, "BEGIN");
            READ_EVENT(core, stream, EVENT_MAP_BEGIN);
            MAP_READ_LOOP: loop
                MAP_READ_PREPARE_FOR_NEXT(core, stream, next_event);
                MAP_READ_AXI4_CHANNEL(
                    CORE       => core            ,  -- In :
                    STREAM     => stream          ,  -- I/O:
                    SIGNALS    => out_signals     ,  -- I/O:
                    EVENT      => next_event         -- Out:
                );
                EXECUTE_OUTPUT;
                case next_event is
                    when EVENT_SCALAR  =>
                        COPY_KEY_WORD(core, keyword);
                        case keyword is
                            when KEY_DEBUG  => EXECUTE_DEBUG (core, stream);
                            when KEY_REPORT => EXECUTE_REPORT(core, stream);
                            when KEY_SAY    => EXECUTE_SAY   (core, stream);
                            when KEY_WAIT   => EXECUTE_WAIT;
                            when KEY_CHECK  => EXECUTE_CHECK;
                            when others     => EXECUTE_UNDEFINED_MAP_KEY(keyword);
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
        ---------------------------------------------------------------------------
        --! @brief チャネルオペレーションループ
        ---------------------------------------------------------------------------
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
        ---------------------------------------------------------------------------
        -- ダミープラグコアの初期化.
        ---------------------------------------------------------------------------
        CORE_INIT(
            SELF        => core,          --! 初期化するコア変数.
            NAME        => NAME,          --! コアの名前.
            VOCAL_NAME  => FULL_NAME,     --! 
            STREAM      => stream,        --! シナリオのストリーム.
            STREAM_NAME => SCENARIO_FILE, --! シナリオのストリーム名.
            OPERATION   => operation      --! コアのオペレーション.
        );
        ---------------------------------------------------------------------------
        -- 変数の初期化.
        ---------------------------------------------------------------------------
        out_signals := INIT_SIGNALS;
        chk_signals := INIT_SIGNALS;
        gpo_signals := (others => 'Z');
        ---------------------------------------------------------------------------
        -- 信号の初期化
        ---------------------------------------------------------------------------
        SYNC_REQ       <= (0 =>10, others => 0);
        SYNC_LOCAL_REQ <= (        others => 0);
        FINISH         <= '0';
        REPORT_STATUS  <= core.report_status;
        EXECUTE_OUTPUT;
        core.debug := 0;
        ---------------------------------------------------------------------------
        -- メインオペレーションループ
        ---------------------------------------------------------------------------
        if (CHANNEL = AXI4_CHANNEL_M) then
            wait until(ACLK'event and ACLK = '1' and ARESETn = '1');
            while (operation /= OP_FINISH) loop
                REPORT_STATUS <= core.report_status;
                READ_OPERATION(core, stream, operation, keyword);
                case operation is
                    when OP_DOC_BEGIN      => EXECUTE_SYNC(operation);
                    when OP_MAP    =>
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
                            when KEY_OUT    => EXECUTE_OUT   (core, stream, gpo_signals, GPO);
                            when KEY_SYNC   => EXECUTE_SYNC  (operation);
                            when KEY_WAIT   => EXECUTE_WAIT;
                            when KEY_CHECK  => EXECUTE_CHECK;
                            when KEY_READ   => EXECUTE_TRANSACTION_READ;
                            when KEY_WRITE  => EXECUTE_TRANSACTION_WRITE;
                            when others     => EXECUTE_UNDEFINED_MAP_KEY(keyword);
                        end case;
                    when OP_SCALAR =>
                        case keyword is
                            when KEY_SYNC  => EXECUTE_SYNC(operation);
                            when others    => EXECUTE_UNDEFINED_SCALAR(keyword);
                        end case;
                    when OP_FINISH => exit;
                    when others    => null;
                end case;
            end loop;
        else
            while (operation /= OP_FINISH) loop
                REPORT_STATUS <= core.report_status;
                READ_OPERATION(core, stream, operation, keyword);
                case operation is
                    when OP_DOC_BEGIN   => LOCAL_SYNC;
                    when OP_MAP         =>
                        REPORT_DEBUG(core, string'("MAIN_LOOP:OP_MAP(") & keyword & ")");
                        if    (keyword = KEY_CHANNEL) then
                            EXECUTE_CHANNEL_OPERATION;
                        elsif (keyword = KEY_REPORT ) then
                            EXECUTE_REPORT(core, stream);
                        elsif (keyword = KEY_SYNC   ) then
                            LOCAL_SYNC;
                            EXECUTE_SKIP(core, stream);
                        elsif (keyword = KEY_READ   ) then
                            EXECUTE_TRANSACTION_READ;
                        elsif (keyword = KEY_WRITE  ) then
                            EXECUTE_TRANSACTION_WRITE;
                        else
                            REPORT_DEBUG(core, string'("MAIN_LOOP:OP_MAP:SKIP BEGIN"));
                            EXECUTE_SKIP(core, stream);
                            REPORT_DEBUG(core, string'("MAIN_LOOP:OP_MAP:SKIP END"));
                        end if;
                    when OP_SCALAR      =>
                        if (keyword = KEY_SYNC) then
                            LOCAL_SYNC;
                        else
                            EXECUTE_UNDEFINED_SCALAR(keyword);
                        end if;
                    when OP_FINISH      => exit;
                    when others         => null;
                end case;
            end loop;
        end if;
        REPORT_STATUS <= core.report_status;
        FINISH        <= '1';
        if (FINISH_ABORT) then
            assert FALSE report "Simulation complete." severity FAILURE;
        end if;
        wait;
    end process;
end MODEL;
