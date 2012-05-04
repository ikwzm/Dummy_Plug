-----------------------------------------------------------------------------------
--!     @file    axi4_core_player.vhd
--!     @brief   AXI4 Master/Slave Core Dummy Plug Player.
--!     @version 0.0.3
--!     @date    2012/5/4
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
use     DUMMY_PLUG.SYNC.SYNC_PLUG_NUM_TYPE;
use     DUMMY_PLUG.SYNC.SYNC_SIG_VECTOR;
use     DUMMY_PLUG.SYNC.SYNC_REQ_VECTOR;
use     DUMMY_PLUG.SYNC.SYNC_ACK_VECTOR;
-----------------------------------------------------------------------------------
--! @brief   AXI4_CORE_PLAYER :
-----------------------------------------------------------------------------------
entity  AXI4_CORE_PLAYER is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        SCENARIO_FILE   : --! @brief シナリオファイルの名前.
                          STRING;
        NAME            : --! @brief 固有名詞.
                          STRING;
        MASTER          : --! @brief マスターモードを指定する.
                          boolean   := FALSE;
        SLAVE           : --! @brief スレーブモードを指定する.
                          boolean   := FALSE;
        READ            : --! @brief リードモードを指定する.
                          boolean   := TRUE;
        WRITE           : --! @brief ライトモードを指定する.
                          boolean   := TRUE;
        OUTPUT_DELAY    : --! @brief 出力信号遅延時間
                          time    := 0 ns;
        AXI4_ID_WIDTH   : --! @brief AXI4 IS WIDTH :
                          integer :=  4;
        AXI4_A_WIDTH    : --! @brief AXI4 ADDR WIDTH :
                          integer := 32;
        AXI4_W_WIDTH    : --! @brief AXI4 WRITE DATA WIDTH :
                          integer := 32;
        AXI4_R_WIDTH    : --! @brief AXI4 READ DATA WIDTH :
                          integer := 32;
        SYNC_PLUG_NUM   : --! @brief シンクロ用信号のプラグ番号.
                          SYNC_PLUG_NUM_TYPE := 1;
        SYNC_WIDTH      : --! @brief シンクロ用信号の本数.
                          integer :=  1;
        FINISH_ABORT    : --! @brief FINISH コマンド実行時にシミュレーションを
                          --!        アボートするかどうかを指定するフラグ.
                          boolean := true
    );
    -------------------------------------------------------------------------------
    -- 入出力ポートの定義.
    -------------------------------------------------------------------------------
    port(
        --------------------------------------------------------------------------
        -- グローバルシグナル.
        --------------------------------------------------------------------------
        ACLK            : in    std_logic;
        ARESETn         : in    std_logic;
        --------------------------------------------------------------------------
        -- アドレスチャネルシグナル.
        --------------------------------------------------------------------------
        AVALID_I        : in    std_logic;
        AVALID_O        : out   std_logic;
        ADDR_I          : in    std_logic_vector(AXI4_A_WIDTH   -1 downto 0);
        ADDR_O          : out   std_logic_vector(AXI4_A_WIDTH   -1 downto 0);
        AWRITE_I        : in    std_logic;
        AWRITE_O        : out   std_logic;
        ALEN_I          : in    AXI4_ALEN_TYPE;
        ALEN_O          : out   AXI4_ALEN_TYPE;
        ASIZE_I         : in    AXI4_ASIZE_TYPE;
        ASIZE_O         : out   AXI4_ASIZE_TYPE;
        ABURST_I        : in    AXI4_ABURST_TYPE;
        ABURST_O        : out   AXI4_ABURST_TYPE;
        ALOCK_I         : in    AXI4_ALOCK_TYPE;
        ALOCK_O         : out   AXI4_ALOCK_TYPE;
        ACACHE_I        : in    AXI4_ACACHE_TYPE;
        ACACHE_O        : out   AXI4_ACACHE_TYPE;
        APROT_I         : in    AXI4_APROT_TYPE;
        APROT_O         : out   AXI4_APROT_TYPE;
        AID_I           : in    std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
        AID_O           : out   std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
        AREADY_I        : in    std_logic;
        AREADY_O        : out   std_logic;
        --------------------------------------------------------------------------
        -- リードチャネルシグナル.
        --------------------------------------------------------------------------
        RVALID_I        : in    std_logic;
        RVALID_O        : out   std_logic;
        RLAST_I         : in    std_logic;
        RLAST_O         : out   std_logic;
        RDATA_I         : in    std_logic_vector(AXI4_R_WIDTH   -1 downto 0);
        RDATA_O         : out   std_logic_vector(AXI4_R_WIDTH   -1 downto 0);
        RRESP_I         : in    AXI4_RESP_TYPE;
        RRESP_O         : out   AXI4_RESP_TYPE;
        RID_I           : in    std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
        RID_O           : out   std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
        RREADY_I        : in    std_logic;
        RREADY_O        : out   std_logic;
        --------------------------------------------------------------------------
        -- ライトチャネルシグナル.
        --------------------------------------------------------------------------
        WVALID_I        : in    std_logic;
        WVALID_O        : out   std_logic;
        WLAST_I         : in    std_logic;
        WLAST_O         : out   std_logic;
        WDATA_I         : in    std_logic_vector(AXI4_W_WIDTH   -1 downto 0);
        WDATA_O         : out   std_logic_vector(AXI4_W_WIDTH   -1 downto 0);
        WSTRB_I         : in    std_logic_vector(AXI4_W_WIDTH/8 -1 downto 0);
        WSTRB_O         : out   std_logic_vector(AXI4_W_WIDTH/8 -1 downto 0);
        WID_I           : in    std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
        WID_O           : out   std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
        WREADY_I        : in    std_logic;
        WREADY_O        : out   std_logic;
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
        BVALID_I        : in    std_logic;
        BVALID_O        : out   std_logic;
        BRESP_I         : in    AXI4_RESP_TYPE;
        BRESP_O         : out   AXI4_RESP_TYPE;
        BID_I           : in    std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
        BID_O           : out   std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
        BREADY_I        : in    std_logic;
        BREADY_O        : out   std_logic;
        --------------------------------------------------------------------------
        -- シンクロ用信号
        --------------------------------------------------------------------------
        SYNC            : inout SYNC_SIG_VECTOR (SYNC_WIDTH     -1 downto 0);
        FINISH          : out   std_logic
    );
end AXI4_CORE_PLAYER;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.AXI4_CORE.all;
use     DUMMY_PLUG.SYNC.all;
-----------------------------------------------------------------------------------
--! @brief  AXI4_CORE_PLAYER :
-----------------------------------------------------------------------------------
architecture MODEL of AXI4_CORE_PLAYER is
    -------------------------------------------------------------------------------
    --! SYNC 制御信号
    -------------------------------------------------------------------------------
    signal    sync_rst          : std_logic := '0';
    signal    sync_clr          : std_logic := '0';
    signal    sync_req          : SYNC_REQ_VECTOR(SYNC'range);
    signal    sync_ack          : SYNC_ACK_VECTOR(SYNC'range);
    -------------------------------------------------------------------------------
    --! ローカル同期制御信号
    -------------------------------------------------------------------------------
    constant  SYNC_LOCAL_WAIT   : integer := 2;
    constant  SYNC_LOCAL_PORT   : integer := 0;
    signal    sync_m_req        : SYNC_REQ_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT) := (others => 0);
    signal    sync_m_ack        : SYNC_ACK_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT);
    signal    sync_a_req        : SYNC_REQ_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT) := (others => 0);
    signal    sync_a_ack        : SYNC_ACK_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT);
    signal    sync_w_req        : SYNC_REQ_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT) := (others => 0);
    signal    sync_w_ack        : SYNC_ACK_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT);
    signal    sync_r_req        : SYNC_REQ_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT) := (others => 0);
    signal    sync_r_ack        : SYNC_ACK_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT);
    signal    sync_b_req        : SYNC_REQ_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT) := (others => 0);
    signal    sync_b_ack        : SYNC_ACK_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT);
begin
    -------------------------------------------------------------------------------
    -- メイン用のプレイヤー
    -------------------------------------------------------------------------------
    M: AXI4_CHANNEL_PLAYER 
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE,
            NAME            => NAME,
            FULL_NAME       => NAME,
            CHANNEL         => 'M',
            MASTER          => FALSE,
            SLAVE           => FALSE,
            READ            => READ,
            WRITE           => WRITE,
            OUTPUT_DELAY    => OUTPUT_DELAY,
            AXI4_ID_WIDTH   => AXI4_ID_WIDTH,
            AXI4_A_WIDTH    => AXI4_A_WIDTH,
            AXI4_W_WIDTH    => AXI4_W_WIDTH,
            AXI4_R_WIDTH    => AXI4_R_WIDTH,
            SYNC_WIDTH      => SYNC_WIDTH,
            SYNC_LOCAL_PORT => SYNC_LOCAL_PORT,
            SYNC_LOCAL_WAIT => SYNC_LOCAL_WAIT,
            FINISH_ABORT    => FINISH_ABORT
        )
        port map(
            -----------------------------------------------------------------------
            -- グローバルシグナル.
            -----------------------------------------------------------------------
            ACLK            => ACLK        , -- In :
            ARESETn         => ARESETn     , -- In :
            -----------------------------------------------------------------------
            -- アドレスチャネルシグナル.
            -----------------------------------------------------------------------
            AVALID_I        => AVALID_I    , -- In :
            AVALID_O        => open        , -- Out:
            ADDR_I          => ADDR_I      , -- In :
            ADDR_O          => open        , -- Out:
            AWRITE_I        => AWRITE_I    , -- In :
            AWRITE_O        => open        , -- Out:
            ALEN_I          => ALEN_I      , -- In :
            ALEN_O          => open        , -- Out:
            ASIZE_I         => ASIZE_I     , -- In :
            ASIZE_O         => open        , -- Out:
            ABURST_I        => ABURST_I    , -- In :
            ABURST_O        => open        , -- Out:
            ALOCK_I         => ALOCK_I     , -- In :
            ALOCK_O         => open        , -- Out:
            ACACHE_I        => ACACHE_I    , -- In :
            ACACHE_O        => open        , -- Out:
            APROT_I         => APROT_I     , -- In :
            APROT_O         => open        , -- Out:
            AID_I           => AID_I       , -- In :
            AID_O           => open        , -- Out:
            AREADY_I        => AREADY_I    , -- In :
            AREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- リードチャネルシグナル.
            -----------------------------------------------------------------------
            RVALID_I        => RVALID_I    , -- In :
            RVALID_O        => open        , -- Out:
            RLAST_I         => RLAST_I     , -- In :
            RLAST_O         => open        , -- Out:
            RDATA_I         => RDATA_I     , -- In :
            RDATA_O         => open        , -- Out:
            RRESP_I         => RRESP_I     , -- In :
            RRESP_O         => open        , -- Out:
            RID_I           => RID_I       , -- In :
            RID_O           => open        , -- Out:
            RREADY_I        => RREADY_I    , -- In :
            RREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライトチャネルシグナル.
            -----------------------------------------------------------------------
            WVALID_I        => WVALID_I    , -- In :
            WVALID_O        => open        , -- Out:
            WLAST_I         => WLAST_I     , -- In :
            WLAST_O         => open        , -- Out:
            WDATA_I         => WDATA_I     , -- In :
            WDATA_O         => open        , -- Out:
            WSTRB_I         => WSTRB_I     , -- In :
            WSTRB_O         => open        , -- Out:
            WID_I           => WID_I       , -- In :
            WID_O           => open        , -- Out:
            WREADY_I        => WREADY_I    , -- In :
            WREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            -----------------------------------------------------------------------
            BVALID_I        => BVALID_I    , -- In :
            BVALID_O        => open        , -- Out:
            BRESP_I         => BRESP_I     , -- In :
            BRESP_O         => open        , -- Out:
            BID_I           => BID_I       , -- In :
            BID_O           => open        , -- Out:
            BREADY_I        => BREADY_I    , -- In :
            BREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- シンクロ用信号
            -----------------------------------------------------------------------
            SYNC_REQ        => sync_req    , -- Out:
            SYNC_ACK        => sync_ack    , -- In :
            SYNC_LOCAL_REQ  => sync_m_req  , -- Out:
            SYNC_LOCAL_ACK  => sync_m_ack  , -- In :
            FINISH          => FINISH        -- Out:
        );
    -------------------------------------------------------------------------------
    -- アドレスチャネル用のプレイヤー
    -------------------------------------------------------------------------------
    A: AXI4_CHANNEL_PLAYER 
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE,
            NAME            => NAME,
            FULL_NAME       => NAME & ".A",
            CHANNEL         => 'A',
            MASTER          => MASTER,
            SLAVE           => SLAVE,
            READ            => READ,
            WRITE           => WRITE,
            OUTPUT_DELAY    => OUTPUT_DELAY,
            AXI4_ID_WIDTH   => AXI4_ID_WIDTH,
            AXI4_A_WIDTH    => AXI4_A_WIDTH,
            AXI4_W_WIDTH    => AXI4_W_WIDTH,
            AXI4_R_WIDTH    => AXI4_R_WIDTH,
            SYNC_WIDTH      => SYNC_WIDTH,
            SYNC_LOCAL_PORT => SYNC_LOCAL_PORT,
            SYNC_LOCAL_WAIT => SYNC_LOCAL_WAIT,
            FINISH_ABORT    => FINISH_ABORT
        )
        port map(
            -----------------------------------------------------------------------
            -- グローバルシグナル.
            -----------------------------------------------------------------------
            ACLK            => ACLK        , -- In :
            ARESETn         => ARESETn     , -- In :
            -----------------------------------------------------------------------
            -- アドレスチャネルシグナル.
            -----------------------------------------------------------------------
            AVALID_I        => AVALID_I    , -- In :
            AVALID_O        => AVALID_O    , -- Out:
            ADDR_I          => ADDR_I      , -- In :
            ADDR_O          => ADDR_O      , -- Out:
            AWRITE_I        => AWRITE_I    , -- In :
            AWRITE_O        => AWRITE_O    , -- Out:
            ALEN_I          => ALEN_I      , -- In :
            ALEN_O          => ALEN_O      , -- Out:
            ASIZE_I         => ASIZE_I     , -- In :
            ASIZE_O         => ASIZE_O     , -- Out:
            ABURST_I        => ABURST_I    , -- In :
            ABURST_O        => ABURST_O    , -- Out:
            ALOCK_I         => ALOCK_I     , -- In :
            ALOCK_O         => ALOCK_O     , -- Out:
            ACACHE_I        => ACACHE_I    , -- In :
            ACACHE_O        => ACACHE_O    , -- Out:
            APROT_I         => APROT_I     , -- In :
            APROT_O         => APROT_O     , -- Out:
            AID_I           => AID_I       , -- In :
            AID_O           => AID_O       , -- Out:
            AREADY_I        => AREADY_I    , -- In :
            AREADY_O        => AREADY_O    , -- Out:
            -----------------------------------------------------------------------
            -- リードチャネルシグナル.
            -----------------------------------------------------------------------
            RVALID_I        => RVALID_I    , -- In :
            RVALID_O        => open        , -- Out:
            RLAST_I         => RLAST_I     , -- In :
            RLAST_O         => open        , -- Out:
            RDATA_I         => RDATA_I     , -- In :
            RDATA_O         => open        , -- Out:
            RRESP_I         => RRESP_I     , -- In :
            RRESP_O         => open        , -- Out:
            RID_I           => RID_I       , -- In :
            RID_O           => open        , -- Out:
            RREADY_I        => RREADY_I    , -- In :
            RREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライトチャネルシグナル.
            -----------------------------------------------------------------------
            WVALID_I        => WVALID_I    , -- In :
            WVALID_O        => open        , -- Out:
            WLAST_I         => WLAST_I     , -- In :
            WLAST_O         => open        , -- Out:
            WDATA_I         => WDATA_I     , -- In :
            WDATA_O         => open        , -- Out:
            WSTRB_I         => WSTRB_I     , -- In :
            WSTRB_O         => open        , -- Out:
            WID_I           => WID_I       , -- In :
            WID_O           => open        , -- Out:
            WREADY_I        => WREADY_I    , -- In :
            WREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            -----------------------------------------------------------------------
            BVALID_I        => BVALID_I    , -- In :
            BVALID_O        => open        , -- Out:
            BRESP_I         => BRESP_I     , -- In :
            BRESP_O         => open        , -- Out:
            BID_I           => BID_I       , -- In :
            BID_O           => open        , -- Out:
            BREADY_I        => BREADY_I    , -- In :
            BREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- シンクロ用信号
            -----------------------------------------------------------------------
            SYNC_REQ        => open        , -- Out:
            SYNC_ACK        => sync_ack    , -- In :
            SYNC_LOCAL_REQ  => sync_a_req  , -- Out:
            SYNC_LOCAL_ACK  => sync_a_ack  , -- In :
            FINISH          => open          -- Out:
        );
    -------------------------------------------------------------------------------
    -- ライトチャネル用のプレイヤー
    -------------------------------------------------------------------------------
    W: AXI4_CHANNEL_PLAYER 
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE,
            NAME            => NAME,
            FULL_NAME       => NAME & ".W",
            CHANNEL         => 'W',
            MASTER          => MASTER,
            SLAVE           => SLAVE,
            READ            => READ,
            WRITE           => WRITE,
            OUTPUT_DELAY    => OUTPUT_DELAY,
            AXI4_ID_WIDTH   => AXI4_ID_WIDTH,
            AXI4_A_WIDTH    => AXI4_A_WIDTH,
            AXI4_W_WIDTH    => AXI4_W_WIDTH,
            AXI4_R_WIDTH    => AXI4_R_WIDTH,
            SYNC_WIDTH      => SYNC_WIDTH,
            SYNC_LOCAL_PORT => SYNC_LOCAL_PORT,
            SYNC_LOCAL_WAIT => SYNC_LOCAL_WAIT,
            FINISH_ABORT    => FINISH_ABORT
        )
        port map(
            -----------------------------------------------------------------------
            -- グローバルシグナル.
            -----------------------------------------------------------------------
            ACLK            => ACLK        , -- In :
            ARESETn         => ARESETn     , -- In :
            -----------------------------------------------------------------------
            -- アドレスチャネルシグナル.
            -----------------------------------------------------------------------
            AVALID_I        => AVALID_I    , -- In :
            AVALID_O        => open        , -- Out:
            ADDR_I          => ADDR_I      , -- In :
            ADDR_O          => open        , -- Out:
            AWRITE_I        => AWRITE_I    , -- In :
            AWRITE_O        => open        , -- Out:
            ALEN_I          => ALEN_I      , -- In :
            ALEN_O          => open        , -- Out:
            ASIZE_I         => ASIZE_I     , -- In :
            ASIZE_O         => open        , -- Out:
            ABURST_I        => ABURST_I    , -- In :
            ABURST_O        => open        , -- Out:
            ALOCK_I         => ALOCK_I     , -- In :
            ALOCK_O         => open        , -- Out:
            ACACHE_I        => ACACHE_I    , -- In :
            ACACHE_O        => open        , -- Out:
            APROT_I         => APROT_I     , -- In :
            APROT_O         => open        , -- Out:
            AID_I           => AID_I       , -- In :
            AID_O           => open        , -- Out:
            AREADY_I        => AREADY_I    , -- In :
            AREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- リードチャネルシグナル.
            -----------------------------------------------------------------------
            RVALID_I        => RVALID_I    , -- In :
            RVALID_O        => open        , -- Out:
            RLAST_I         => RLAST_I     , -- In :
            RLAST_O         => open        , -- Out:
            RDATA_I         => RDATA_I     , -- In :
            RDATA_O         => open        , -- Out:
            RRESP_I         => RRESP_I     , -- In :
            RRESP_O         => open        , -- Out:
            RID_I           => RID_I       , -- In :
            RID_O           => open        , -- Out:
            RREADY_I        => RREADY_I    , -- In :
            RREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライトチャネルシグナル.
            -----------------------------------------------------------------------
            WVALID_I        => WVALID_I    , -- In :
            WVALID_O        => WVALID_O    , -- Out:
            WLAST_I         => WLAST_I     , -- In :
            WLAST_O         => WLAST_O     , -- Out:
            WDATA_I         => WDATA_I     , -- In :
            WDATA_O         => WDATA_O     , -- Out:
            WSTRB_I         => WSTRB_I     , -- In :
            WSTRB_O         => WSTRB_O     , -- Out:
            WID_I           => WID_I       , -- In :
            WID_O           => WID_O       , -- Out:
            WREADY_I        => WREADY_I    , -- In :
            WREADY_O        => WREADY_O    , -- Out:
            -----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            -----------------------------------------------------------------------
            BVALID_I        => BVALID_I    , -- In :
            BVALID_O        => open        , -- Out:
            BRESP_I         => BRESP_I     , -- In :
            BRESP_O         => open        , -- Out:
            BID_I           => BID_I       , -- In :
            BID_O           => open        , -- Out:
            BREADY_I        => BREADY_I    , -- In :
            BREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- シンクロ用信号
            -----------------------------------------------------------------------
            SYNC_REQ        => open        , -- Out:
            SYNC_ACK        => sync_ack    , -- In :
            SYNC_LOCAL_REQ  => sync_w_req  , -- Out:
            SYNC_LOCAL_ACK  => sync_w_ack  , -- In :
            FINISH          => open          -- Out:
        );
    -------------------------------------------------------------------------------
    -- リードチャネル用のプレイヤー
    -------------------------------------------------------------------------------
    R: AXI4_CHANNEL_PLAYER 
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE,
            NAME            => NAME,
            FULL_NAME       => NAME & ".R",
            CHANNEL         => 'R',
            MASTER          => MASTER,
            SLAVE           => SLAVE,
            READ            => READ,
            WRITE           => WRITE,
            OUTPUT_DELAY    => OUTPUT_DELAY,
            AXI4_ID_WIDTH   => AXI4_ID_WIDTH,
            AXI4_A_WIDTH    => AXI4_A_WIDTH,
            AXI4_W_WIDTH    => AXI4_W_WIDTH,
            AXI4_R_WIDTH    => AXI4_R_WIDTH,
            SYNC_WIDTH      => SYNC_WIDTH,
            SYNC_LOCAL_PORT => SYNC_LOCAL_PORT,
            SYNC_LOCAL_WAIT => SYNC_LOCAL_WAIT,
            FINISH_ABORT    => FINISH_ABORT
        )
        port map(
            -----------------------------------------------------------------------
            -- グローバルシグナル.
            -----------------------------------------------------------------------
            ACLK            => ACLK        , -- In :
            ARESETn         => ARESETn     , -- In :
            -----------------------------------------------------------------------
            -- アドレスチャネルシグナル.
            -----------------------------------------------------------------------
            AVALID_I        => AVALID_I    , -- In :
            AVALID_O        => open        , -- Out:
            ADDR_I          => ADDR_I      , -- In :
            ADDR_O          => open        , -- Out:
            AWRITE_I        => AWRITE_I    , -- In :
            AWRITE_O        => open        , -- Out:
            ALEN_I          => ALEN_I      , -- In :
            ALEN_O          => open        , -- Out:
            ASIZE_I         => ASIZE_I     , -- In :
            ASIZE_O         => open        , -- Out:
            ABURST_I        => ABURST_I    , -- In :
            ABURST_O        => open        , -- Out:
            ALOCK_I         => ALOCK_I     , -- In :
            ALOCK_O         => open        , -- Out:
            ACACHE_I        => ACACHE_I    , -- In :
            ACACHE_O        => open        , -- Out:
            APROT_I         => APROT_I     , -- In :
            APROT_O         => open        , -- Out:
            AID_I           => AID_I       , -- In :
            AID_O           => open        , -- Out:
            AREADY_I        => AREADY_I    , -- In :
            AREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- リードチャネルシグナル.
            -----------------------------------------------------------------------
            RVALID_I        => RVALID_I    , -- In :
            RVALID_O        => RVALID_O    , -- Out:
            RLAST_I         => RLAST_I     , -- In :
            RLAST_O         => RLAST_O     , -- Out:
            RDATA_I         => RDATA_I     , -- In :
            RDATA_O         => RDATA_O     , -- Out:
            RRESP_I         => RRESP_I     , -- In :
            RRESP_O         => RRESP_O     , -- Out:
            RID_I           => RID_I       , -- In :
            RID_O           => RID_O       , -- Out:
            RREADY_I        => RREADY_I    , -- In :
            RREADY_O        => RREADY_O    , -- Out:
            -----------------------------------------------------------------------
            -- ライトチャネルシグナル.
            -----------------------------------------------------------------------
            WVALID_I        => WVALID_I    , -- In :
            WVALID_O        => open        , -- Out:
            WLAST_I         => WLAST_I     , -- In :
            WLAST_O         => open        , -- Out:
            WDATA_I         => WDATA_I     , -- In :
            WDATA_O         => open        , -- Out:
            WSTRB_I         => WSTRB_I     , -- In :
            WSTRB_O         => open        , -- Out:
            WID_I           => WID_I       , -- In :
            WID_O           => open        , -- Out:
            WREADY_I        => WREADY_I    , -- In :
            WREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            -----------------------------------------------------------------------
            BVALID_I        => BVALID_I    , -- In :
            BVALID_O        => open        , -- Out:
            BRESP_I         => BRESP_I     , -- In :
            BRESP_O         => open        , -- Out:
            BID_I           => BID_I       , -- In :
            BID_O           => open        , -- Out:
            BREADY_I        => BREADY_I    , -- In :
            BREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- シンクロ用信号
            -----------------------------------------------------------------------
            SYNC_REQ        => open        , -- Out:
            SYNC_ACK        => sync_ack    , -- In :
            SYNC_LOCAL_REQ  => sync_r_req  , -- Out:
            SYNC_LOCAL_ACK  => sync_r_ack  , -- In :
            FINISH          => open          -- Out:
        );
    -------------------------------------------------------------------------------
    -- 応答チャネル用のプロシージャ
    -------------------------------------------------------------------------------
    B: AXI4_CHANNEL_PLAYER 
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE,
            NAME            => NAME,
            FULL_NAME       => NAME & ".B",
            CHANNEL         => 'B',
            MASTER          => MASTER,
            SLAVE           => SLAVE,
            READ            => READ,
            WRITE           => WRITE,
            OUTPUT_DELAY    => OUTPUT_DELAY,
            AXI4_ID_WIDTH   => AXI4_ID_WIDTH,
            AXI4_A_WIDTH    => AXI4_A_WIDTH,
            AXI4_W_WIDTH    => AXI4_W_WIDTH,
            AXI4_R_WIDTH    => AXI4_R_WIDTH,
            SYNC_WIDTH      => SYNC_WIDTH,
            SYNC_LOCAL_PORT => SYNC_LOCAL_PORT,
            SYNC_LOCAL_WAIT => SYNC_LOCAL_WAIT,
            FINISH_ABORT    => FINISH_ABORT
        )
        port map(
            -----------------------------------------------------------------------
            -- グローバルシグナル.
            -----------------------------------------------------------------------
            ACLK            => ACLK        , -- In :
            ARESETn         => ARESETn     , -- In :
            -----------------------------------------------------------------------
            -- アドレスチャネルシグナル.
            -----------------------------------------------------------------------
            AVALID_I        => AVALID_I    , -- In :
            AVALID_O        => open        , -- Out:
            ADDR_I          => ADDR_I      , -- In :
            ADDR_O          => open        , -- Out:
            AWRITE_I        => AWRITE_I    , -- In :
            AWRITE_O        => open        , -- Out:
            ALEN_I          => ALEN_I      , -- In :
            ALEN_O          => open        , -- Out:
            ASIZE_I         => ASIZE_I     , -- In :
            ASIZE_O         => open        , -- Out:
            ABURST_I        => ABURST_I    , -- In :
            ABURST_O        => open        , -- Out:
            ALOCK_I         => ALOCK_I     , -- In :
            ALOCK_O         => open        , -- Out:
            ACACHE_I        => ACACHE_I    , -- In :
            ACACHE_O        => open        , -- Out:
            APROT_I         => APROT_I     , -- In :
            APROT_O         => open        , -- Out:
            AID_I           => AID_I       , -- In :
            AID_O           => open        , -- Out:
            AREADY_I        => AREADY_I    , -- In :
            AREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- リードチャネルシグナル.
            -----------------------------------------------------------------------
            RVALID_I        => RVALID_I    , -- In :
            RVALID_O        => open        , -- Out:
            RLAST_I         => RLAST_I     , -- In :
            RLAST_O         => open        , -- Out:
            RDATA_I         => RDATA_I     , -- In :
            RDATA_O         => open        , -- Out:
            RRESP_I         => RRESP_I     , -- In :
            RRESP_O         => open        , -- Out:
            RID_I           => RID_I       , -- In :
            RID_O           => open        , -- Out:
            RREADY_I        => RREADY_I    , -- In :
            RREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライトチャネルシグナル.
            -----------------------------------------------------------------------
            WVALID_I        => WVALID_I    , -- In :
            WVALID_O        => open        , -- Out:
            WLAST_I         => WLAST_I     , -- In :
            WLAST_O         => open        , -- Out:
            WDATA_I         => WDATA_I     , -- In :
            WDATA_O         => open        , -- Out:
            WSTRB_I         => WSTRB_I     , -- In :
            WSTRB_O         => open        , -- Out:
            WID_I           => WID_I       , -- In :
            WID_O           => open        , -- Out:
            WREADY_I        => WREADY_I    , -- In :
            WREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            -----------------------------------------------------------------------
            BVALID_I        => BVALID_I    , -- In :
            BVALID_O        => BVALID_O    , -- Out:
            BRESP_I         => BRESP_I     , -- In :
            BRESP_O         => BRESP_O     , -- Out:
            BID_I           => BID_I       , -- In :
            BID_O           => BID_O       , -- Out:
            BREADY_I        => BREADY_I    , -- In :
            BREADY_O        => BREADY_O    , -- Out:
            -----------------------------------------------------------------------
            -- シンクロ用信号
            -----------------------------------------------------------------------
            SYNC_REQ        => open        , -- Out:
            SYNC_ACK        => sync_ack    , -- In :
            SYNC_LOCAL_REQ  => sync_b_req  , -- Out:
            SYNC_LOCAL_ACK  => sync_b_ack  , -- In :
            FINISH          => open          -- Out:
        );
    -------------------------------------------------------------------------------
    -- このコア用の同期回路
    -------------------------------------------------------------------------------
    SYNC_DRIVER: for i in SYNC'range generate
        UNIT: SYNC_SIG_DRIVER generic map (SYNC_PLUG_NUM) port map (
            CLK      => ACLK,                -- In :
            RST      => sync_rst,            -- In :
            CLR      => sync_clr,            -- In :
            SYNC     => SYNC(i),             -- I/O:
            REQ      => sync_req(i),         -- In :
            ACK      => sync_ack(i)          -- Out:
        );
    end generate;
    sync_rst <= '0' when (ARESETn = '1') else '1';
    sync_clr <= '0';
    -------------------------------------------------------------------------------
    -- このコア内部のローカルな同期回路
    -------------------------------------------------------------------------------
    SYNC_LOCAL : SYNC_LOCAL_HUB generic map (5)
        port map (
            CLK      => ACLK,
            RST      => sync_rst,
            CLR      => sync_clr,
            REQ(1)   => sync_m_req(SYNC_LOCAL_PORT),
            REQ(2)   => sync_a_req(SYNC_LOCAL_PORT),
            REQ(3)   => sync_w_req(SYNC_LOCAL_PORT),
            REQ(4)   => sync_r_req(SYNC_LOCAL_PORT),
            REQ(5)   => sync_b_req(SYNC_LOCAL_PORT),
            ACK(1)   => sync_m_ack(SYNC_LOCAL_PORT),
            ACK(2)   => sync_a_ack(SYNC_LOCAL_PORT),
            ACK(3)   => sync_w_ack(SYNC_LOCAL_PORT),
            ACK(4)   => sync_r_ack(SYNC_LOCAL_PORT),
            ACK(5)   => sync_b_ack(SYNC_LOCAL_PORT)
        );
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
