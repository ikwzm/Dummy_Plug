-----------------------------------------------------------------------------------
--!     @file    axi4_master_player.vhd
--!     @brief   AXI4 Master Dummy Plug Player.
--!     @version 0.0.1
--!     @date    2012/4/29
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
use     DUMMY_PLUG.SYNC.SYNC_SIG_VECTOR;
use     DUMMY_PLUG.SYNC.SYNC_PLUG_NUM_TYPE;
-----------------------------------------------------------------------------------
--! @brief   AXI4_MASTER_PLAYER :
-----------------------------------------------------------------------------------
entity  AXI4_MASTER_PLAYER is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        SCENARIO_FILE   : --! @brief シナリオファイルの名前.
                          STRING;
        NAME            : --! @brief 固有名詞.
                          STRING;
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
        AVALID          : inout std_logic;
        ADDR            : inout std_logic_vector(AXI4_A_WIDTH   -1 downto 0);
        AWRITE          : inout std_logic;
        ALEN            : inout AXI4_ALEN_TYPE;
        ASIZE           : inout AXI4_ASIZE_TYPE;
        ABURST          : inout AXI4_ABURST_TYPE;
        ALOCK           : inout AXI4_ALOCK_TYPE;
        ACACHE          : inout AXI4_ACACHE_TYPE;
        APROT           : inout AXI4_APROT_TYPE;
        AID             : inout std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
        AREADY          : in    std_logic;
        --------------------------------------------------------------------------
        -- リードチャネルシグナル.
        --------------------------------------------------------------------------
        RVALID          : in    std_logic;
        RLAST           : in    std_logic;
        RDATA           : in    std_logic_vector(AXI4_R_WIDTH   -1 downto 0);
        RRESP           : in    AXI4_RESP_TYPE;
        RID             : in    std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
        RREADY          : inout std_logic;
        --------------------------------------------------------------------------
        -- ライトチャネルシグナル.
        --------------------------------------------------------------------------
        WVALID          : inout std_logic;
        WLAST           : inout std_logic;
        WDATA           : inout std_logic_vector(AXI4_W_WIDTH   -1 downto 0);
        WSTRB           : inout std_logic_vector(AXI4_W_WIDTH/8 -1 downto 0);
        WID             : inout std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
        WREADY          : in    std_logic;
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
        BVALID          : in    std_logic;
        BRESP           : in    AXI4_RESP_TYPE;
        BID             : in    std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
        BREADY          : inout std_logic;
        --------------------------------------------------------------------------
        -- シンクロ用信号
        --------------------------------------------------------------------------
        SYNC            : inout SYNC_SIG_VECTOR (SYNC_WIDTH     -1 downto 0);
        FINISH          : out   std_logic
    );
end AXI4_MASTER_PLAYER;
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
--
-----------------------------------------------------------------------------------
architecture MODEL of AXI4_MASTER_PLAYER is
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
    -- メインプロシージャ
    -------------------------------------------------------------------------------
    MAIN: process
        file      stream        : TEXT;
        variable  core          : CORE_TYPE;
        variable  operation     : OPERATION_TYPE;
        variable  op_code       : STRING(1 to 3);
        constant  OP_SAY        : STRING(1 to 3) := "SAY";
        procedure LOCAL_SYNC(
            signal   SYNC_REQ   : out   SYNC_REQ_VECTOR;
            signal   SYNC_ACK   : in    SYNC_ACK_VECTOR 
        ) is
            variable sync_count :       SYNC_REQ_VECTOR(SYNC_REQ'range);
        begin
            sync_count(SYNC_LOCAL_PORT) := SYNC_LOCAL_WAIT;
            SYNC_BEGIN(sync_m_req,             sync_count);
            SYNC_END  (sync_m_req, sync_m_ack, sync_count);
        end procedure;
    begin
        ---------------------------------------------------------------------------
        -- ダミープラグコアの初期化.
        ---------------------------------------------------------------------------
        CORE_INIT(
            SELF        => core,          --! 初期化するコア変数.
            NAME        => NAME,          --! コアの名前.
            STREAM      => stream,        --! シナリオのストリーム.
            STREAM_NAME => SCENARIO_FILE, --! シナリオのストリーム名.
            OPERATION   => operation      --! コアのオペレーション.
        );
        ---------------------------------------------------------------------------
        -- 信号の初期化
        ---------------------------------------------------------------------------
        sync_req   <= (0 => 10, others => 0);
        sync_m_req <= (others => 0);
        FINISH     <= '0';
        wait until(ACLK'event and ACLK = '1' and ARESETn = '1');
        ---------------------------------------------------------------------------
        -- メインオペレーションループ
        ---------------------------------------------------------------------------
        core.debug := 0;
        MAIN_LOOP: while (operation /= OP_FINISH) loop
            READ_OPERATION(core, stream, operation, op_code);
            case operation is
                when OP_DOC_BEGIN =>
                    LOCAL_SYNC(sync_m_req, sync_m_ack);
                    CORE_SYNC(core, 0, 2, sync_req, sync_ack);
                when OP_MAP    =>
                    case op_code is
                        when OP_SAY => EXECUTE_SAY (core, stream);
                        when others => EXECUTE_SKIP(core, stream);
                    end case;
                when OP_SCALAR =>
                when OP_FINISH => exit;
                when others    => null;
            end case;
        end loop;
        FINISH <= '1';
        if (FINISH_ABORT) then
            assert FALSE report "Simulation complete." severity FAILURE;
        end if;
        wait;
    end process;
    -------------------------------------------------------------------------------
    -- アドレスチャネル用のプレイヤー
    -------------------------------------------------------------------------------
    A: AXI4_CHANNEL_PLAYER 
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE,
            CHANNEL         => 'A',
            MASTER          => TRUE,
            SLAVE           => FALSE,
            NAME            => NAME,
            AXI4_ID_WIDTH   => AXI4_ID_WIDTH,
            AXI4_A_WIDTH    => AXI4_A_WIDTH,
            AXI4_W_WIDTH    => AXI4_W_WIDTH,
            AXI4_R_WIDTH    => AXI4_R_WIDTH,
            SYNC_PORT       => SYNC_LOCAL_PORT,
            SYNC_WAIT       => SYNC_LOCAL_WAIT
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
            AVALID_I        => AVALID      , -- In :
            AVALID_O        => AVALID      , -- Out:
            ADDR_I          => ADDR        , -- In :
            ADDR_O          => ADDR        , -- Out:
            AWRITE_I        => AWRITE      , -- In :
            AWRITE_O        => AWRITE      , -- Out:
            ALEN_I          => ALEN        , -- In :
            ALEN_O          => ALEN        , -- Out:
            ASIZE_I         => ASIZE       , -- In :
            ASIZE_O         => ASIZE       , -- Out:
            ABURST_I        => ABURST      , -- In :
            ABURST_O        => ABURST      , -- Out:
            ALOCK_I         => ALOCK       , -- In :
            ALOCK_O         => ALOCK       , -- Out:
            ACACHE_I        => ACACHE      , -- In :
            ACACHE_O        => ACACHE      , -- Out:
            APROT_I         => APROT       , -- In :
            APROT_O         => APROT       , -- Out:
            AID_I           => AID         , -- In :
            AID_O           => AID         , -- Out:
            AREADY_I        => AREADY      , -- In :
            AREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- リードチャネルシグナル.
            -----------------------------------------------------------------------
            RVALID_I        => RVALID      , -- In :
            RVALID_O        => open        , -- Out:
            RLAST_I         => RLAST       , -- In :
            RLAST_O         => open        , -- Out:
            RDATA_I         => RDATA       , -- In :
            RDATA_O         => open        , -- Out:
            RRESP_I         => RRESP       , -- In :
            RRESP_O         => open        , -- Out:
            RID_I           => RID         , -- In :
            RID_O           => open        , -- Out:
            RREADY_I        => RREADY      , -- In :
            RREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライトチャネルシグナル.
            -----------------------------------------------------------------------
            WVALID_I        => WVALID      , -- In :
            WVALID_O        => open        , -- Out:
            WLAST_I         => WLAST       , -- In :
            WLAST_O         => open        , -- Out:
            WDATA_I         => WDATA       , -- In :
            WDATA_O         => open        , -- Out:
            WSTRB_I         => WSTRB       , -- In :
            WSTRB_O         => open        , -- Out:
            WID_I           => WID         , -- In :
            WID_O           => open        , -- Out:
            WREADY_I        => WREADY      , -- In :
            WREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            -----------------------------------------------------------------------
            BVALID_I        => BVALID      , -- In :
            BVALID_O        => open        , -- Out:
            BRESP_I         => BRESP       , -- In :
            BRESP_O         => open        , -- Out:
            BID_I           => BID         , -- In :
            BID_O           => open        , -- Out:
            BREADY_I        => BREADY      , -- In :
            BREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- シンクロ用信号
            -----------------------------------------------------------------------
            SYNC_REQ        => sync_a_req  , -- Out:
            SYNC_ACK        => sync_a_ack    -- In :
        );
    -------------------------------------------------------------------------------
    -- ライトチャネル用のプレイヤー
    -------------------------------------------------------------------------------
    W: AXI4_CHANNEL_PLAYER 
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE,
            CHANNEL         => 'W',
            MASTER          => TRUE,
            SLAVE           => FALSE,
            NAME            => NAME,
            AXI4_ID_WIDTH   => AXI4_ID_WIDTH,
            AXI4_A_WIDTH    => AXI4_A_WIDTH,
            AXI4_W_WIDTH    => AXI4_W_WIDTH,
            AXI4_R_WIDTH    => AXI4_R_WIDTH,
            SYNC_PORT       => SYNC_LOCAL_PORT,
            SYNC_WAIT       => SYNC_LOCAL_WAIT
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
            AVALID_I        => AVALID      , -- In :
            AVALID_O        => open        , -- Out:
            ADDR_I          => ADDR        , -- In :
            ADDR_O          => open        , -- Out:
            AWRITE_I        => AWRITE      , -- In :
            AWRITE_O        => open        , -- Out:
            ALEN_I          => ALEN        , -- In :
            ALEN_O          => open        , -- Out:
            ASIZE_I         => ASIZE       , -- In :
            ASIZE_O         => open        , -- Out:
            ABURST_I        => ABURST      , -- In :
            ABURST_O        => open        , -- Out:
            ALOCK_I         => ALOCK       , -- In :
            ALOCK_O         => open        , -- Out:
            ACACHE_I        => ACACHE      , -- In :
            ACACHE_O        => open        , -- Out:
            APROT_I         => APROT       , -- In :
            APROT_O         => open        , -- Out:
            AID_I           => AID         , -- In :
            AID_O           => open        , -- Out:
            AREADY_I        => AREADY      , -- In :
            AREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- リードチャネルシグナル.
            -----------------------------------------------------------------------
            RVALID_I        => RVALID      , -- In :
            RVALID_O        => open        , -- Out:
            RLAST_I         => RLAST       , -- In :
            RLAST_O         => open        , -- Out:
            RDATA_I         => RDATA       , -- In :
            RDATA_O         => open        , -- Out:
            RRESP_I         => RRESP       , -- In :
            RRESP_O         => open        , -- Out:
            RID_I           => RID         , -- In :
            RID_O           => open        , -- Out:
            RREADY_I        => RREADY      , -- In :
            RREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライトチャネルシグナル.
            -----------------------------------------------------------------------
            WVALID_I        => WVALID      , -- In :
            WVALID_O        => WVALID      , -- Out:
            WLAST_I         => WLAST       , -- In :
            WLAST_O         => WLAST       , -- Out:
            WDATA_I         => WDATA       , -- In :
            WDATA_O         => WDATA       , -- Out:
            WSTRB_I         => WSTRB       , -- In :
            WSTRB_O         => WSTRB       , -- Out:
            WID_I           => WID         , -- In :
            WID_O           => WID         , -- Out:
            WREADY_I        => WREADY      , -- In :
            WREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            -----------------------------------------------------------------------
            BVALID_I        => BVALID      , -- In :
            BVALID_O        => open        , -- Out:
            BRESP_I         => BRESP       , -- In :
            BRESP_O         => open        , -- Out:
            BID_I           => BID         , -- In :
            BID_O           => open        , -- Out:
            BREADY_I        => BREADY      , -- In :
            BREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- シンクロ用信号
            -----------------------------------------------------------------------
            SYNC_REQ        => sync_w_req  , -- Out:
            SYNC_ACK        => sync_w_ack    -- In :
        );
    -------------------------------------------------------------------------------
    -- リードチャネル用のプレイヤー
    -------------------------------------------------------------------------------
    R: AXI4_CHANNEL_PLAYER 
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE,
            CHANNEL         => 'R',
            MASTER          => TRUE,
            SLAVE           => FALSE,
            NAME            => NAME,
            AXI4_ID_WIDTH   => AXI4_ID_WIDTH,
            AXI4_A_WIDTH    => AXI4_A_WIDTH,
            AXI4_W_WIDTH    => AXI4_W_WIDTH,
            AXI4_R_WIDTH    => AXI4_R_WIDTH,
            SYNC_PORT       => SYNC_LOCAL_PORT,
            SYNC_WAIT       => SYNC_LOCAL_WAIT
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
            AVALID_I        => AVALID      , -- In :
            AVALID_O        => open        , -- Out:
            ADDR_I          => ADDR        , -- In :
            ADDR_O          => open        , -- Out:
            AWRITE_I        => AWRITE      , -- In :
            AWRITE_O        => open        , -- Out:
            ALEN_I          => ALEN        , -- In :
            ALEN_O          => open        , -- Out:
            ASIZE_I         => ASIZE       , -- In :
            ASIZE_O         => open        , -- Out:
            ABURST_I        => ABURST      , -- In :
            ABURST_O        => open        , -- Out:
            ALOCK_I         => ALOCK       , -- In :
            ALOCK_O         => open        , -- Out:
            ACACHE_I        => ACACHE      , -- In :
            ACACHE_O        => open        , -- Out:
            APROT_I         => APROT       , -- In :
            APROT_O         => open        , -- Out:
            AID_I           => AID         , -- In :
            AID_O           => open        , -- Out:
            AREADY_I        => AREADY      , -- In :
            AREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- リードチャネルシグナル.
            -----------------------------------------------------------------------
            RVALID_I        => RVALID      , -- In :
            RVALID_O        => open        , -- Out:
            RLAST_I         => RLAST       , -- In :
            RLAST_O         => open        , -- Out:
            RDATA_I         => RDATA       , -- In :
            RDATA_O         => open        , -- Out:
            RRESP_I         => RRESP       , -- In :
            RRESP_O         => open        , -- Out:
            RID_I           => RID         , -- In :
            RID_O           => open        , -- Out:
            RREADY_I        => RREADY      , -- In :
            RREADY_O        => RREADY      , -- Out:
            -----------------------------------------------------------------------
            -- ライトチャネルシグナル.
            -----------------------------------------------------------------------
            WVALID_I        => WVALID      , -- In :
            WVALID_O        => open        , -- Out:
            WLAST_I         => WLAST       , -- In :
            WLAST_O         => open        , -- Out:
            WDATA_I         => WDATA       , -- In :
            WDATA_O         => open        , -- Out:
            WSTRB_I         => WSTRB       , -- In :
            WSTRB_O         => open        , -- Out:
            WID_I           => WID         , -- In :
            WID_O           => open        , -- Out:
            WREADY_I        => WREADY      , -- In :
            WREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            -----------------------------------------------------------------------
            BVALID_I        => BVALID      , -- In :
            BVALID_O        => open        , -- Out:
            BRESP_I         => BRESP       , -- In :
            BRESP_O         => open        , -- Out:
            BID_I           => BID         , -- In :
            BID_O           => open        , -- Out:
            BREADY_I        => BREADY      , -- In :
            BREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- シンクロ用信号
            -----------------------------------------------------------------------
            SYNC_REQ        => sync_r_req  , -- Out:
            SYNC_ACK        => sync_r_ack    -- In :
        );
    -------------------------------------------------------------------------------
    -- 応答チャネル用のプロシージャ
    -------------------------------------------------------------------------------
    B: AXI4_CHANNEL_PLAYER 
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE,
            CHANNEL         => 'B',
            MASTER          => TRUE,
            SLAVE           => FALSE,
            NAME            => NAME,
            AXI4_ID_WIDTH   => AXI4_ID_WIDTH,
            AXI4_A_WIDTH    => AXI4_A_WIDTH,
            AXI4_W_WIDTH    => AXI4_W_WIDTH,
            AXI4_R_WIDTH    => AXI4_R_WIDTH,
            SYNC_PORT       => SYNC_LOCAL_PORT,
            SYNC_WAIT       => SYNC_LOCAL_WAIT
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
            AVALID_I        => AVALID      , -- In :
            AVALID_O        => open        , -- Out:
            ADDR_I          => ADDR        , -- In :
            ADDR_O          => open        , -- Out:
            AWRITE_I        => AWRITE      , -- In :
            AWRITE_O        => open        , -- Out:
            ALEN_I          => ALEN        , -- In :
            ALEN_O          => open        , -- Out:
            ASIZE_I         => ASIZE       , -- In :
            ASIZE_O         => open        , -- Out:
            ABURST_I        => ABURST      , -- In :
            ABURST_O        => open        , -- Out:
            ALOCK_I         => ALOCK       , -- In :
            ALOCK_O         => open        , -- Out:
            ACACHE_I        => ACACHE      , -- In :
            ACACHE_O        => open        , -- Out:
            APROT_I         => APROT       , -- In :
            APROT_O         => open        , -- Out:
            AID_I           => AID         , -- In :
            AID_O           => open        , -- Out:
            AREADY_I        => AREADY      , -- In :
            AREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- リードチャネルシグナル.
            -----------------------------------------------------------------------
            RVALID_I        => RVALID      , -- In :
            RVALID_O        => open        , -- Out:
            RLAST_I         => RLAST       , -- In :
            RLAST_O         => open        , -- Out:
            RDATA_I         => RDATA       , -- In :
            RDATA_O         => open        , -- Out:
            RRESP_I         => RRESP       , -- In :
            RRESP_O         => open        , -- Out:
            RID_I           => RID         , -- In :
            RID_O           => open        , -- Out:
            RREADY_I        => RREADY      , -- In :
            RREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライトチャネルシグナル.
            -----------------------------------------------------------------------
            WVALID_I        => WVALID      , -- In :
            WVALID_O        => open        , -- Out:
            WLAST_I         => WLAST       , -- In :
            WLAST_O         => open        , -- Out:
            WDATA_I         => WDATA       , -- In :
            WDATA_O         => open        , -- Out:
            WSTRB_I         => WSTRB       , -- In :
            WSTRB_O         => open        , -- Out:
            WID_I           => WID         , -- In :
            WID_O           => open        , -- Out:
            WREADY_I        => WREADY      , -- In :
            WREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            -----------------------------------------------------------------------
            BVALID_I        => BVALID      , -- In :
            BVALID_O        => open        , -- Out:
            BRESP_I         => BRESP       , -- In :
            BRESP_O         => open        , -- Out:
            BID_I           => BID         , -- In :
            BID_O           => open        , -- Out:
            BREADY_I        => BREADY      , -- In :
            BREADY_O        => BREADY      , -- Out:
            -----------------------------------------------------------------------
            -- シンクロ用信号
            -----------------------------------------------------------------------
            SYNC_REQ        => sync_b_req  , -- Out:
            SYNC_ACK        => sync_b_ack    -- In :
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
