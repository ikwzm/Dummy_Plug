-----------------------------------------------------------------------------------
--!     @file    aix4_test_1.vhd
--!     @brief   TEST BENCH No.1 for DUMMY_PLUG.AXI4_MODELS
--!     @version 0.0.1
--!     @date    2012/5/1
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
use     ieee.numeric_std.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_MASTER_PLAYER;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_SLAVE_PLAYER;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_SIGNAL_PRINTER;
use     DUMMY_PLUG.SYNC.all;
entity  DUMMY_PLUG_AXI4_TEST_1 is
end     DUMMY_PLUG_AXI4_TEST_1;
architecture MODEL of DUMMY_PLUG_AXI4_TEST_1 is
    ------------------------------------------------------------------------------
    -- シナリオファイル名.
    ------------------------------------------------------------------------------
    constant SCENARIO_FILE   : STRING  := "../../src/test/resouces/axi4_test_1.snr";
    ------------------------------------------------------------------------------
    -- 各種定数
    ------------------------------------------------------------------------------
    constant PERIOD          : time    := 10 ns;
    constant DELAY           : time    :=  1 ns;
    constant AXI4_A_WIDTH    : integer := 32;
    constant AXI4_ID_WIDTH   : integer :=  4;
    constant AXI4_R_WIDTH    : integer := 32;
    constant AXI4_W_WIDTH    : integer := 32;
    constant SYNC_WIDTH      : integer :=  2;
    ------------------------------------------------------------------------------
    -- グローバルシグナル.
    ------------------------------------------------------------------------------
    signal   ACLK            : std_logic;
    signal   ARESETn         : std_logic;
    signal   RESET           : std_logic;
    ------------------------------------------------------------------------------
    -- アドレスチャネルシグナル.
    ------------------------------------------------------------------------------
    signal   AVALID          : std_logic;
    signal   ADDR            : std_logic_vector(AXI4_A_WIDTH   -1 downto 0);
    signal   AWRITE          : std_logic;
    signal   ALEN            : AXI4_ALEN_TYPE;
    signal   ASIZE           : AXI4_ASIZE_TYPE;
    signal   ABURST          : AXI4_ABURST_TYPE;
    signal   ALOCK           : AXI4_ALOCK_TYPE;
    signal   ACACHE          : AXI4_ACACHE_TYPE;
    signal   APROT           : AXI4_APROT_TYPE;
    signal   AID             : std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
    signal   AREADY          : std_logic;
    ------------------------------------------------------------------------------
    -- リードチャネルシグナル.
    ------------------------------------------------------------------------------
    signal   RVALID          : std_logic;
    signal   RLAST           : std_logic;
    signal   RDATA           : std_logic_vector(AXI4_R_WIDTH   -1 downto 0);
    signal   RRESP           : AXI4_RESP_TYPE;
    signal   RID             : std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
    signal   RREADY          : std_logic;
    ------------------------------------------------------------------------------
    -- ライトチャネルシグナル.
    ------------------------------------------------------------------------------
    signal   WVALID          : std_logic;
    signal   WLAST           : std_logic;
    signal   WDATA           : std_logic_vector(AXI4_W_WIDTH   -1 downto 0);
    signal   WSTRB           : std_logic_vector(AXI4_W_WIDTH/8 -1 downto 0);
    signal   WID             : std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
    signal   WREADY          : std_logic;
    ------------------------------------------------------------------------------
    -- ライト応答チャネルシグナル.
    ------------------------------------------------------------------------------
    signal   BVALID          : std_logic;
    signal   BRESP           : AXI4_RESP_TYPE;
    signal   BID             : std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
    signal   BREADY          : std_logic;
    ------------------------------------------------------------------------------
    -- シンクロ用信号
    ------------------------------------------------------------------------------
    signal   SYNC            : SYNC_SIG_VECTOR (SYNC_WIDTH     -1 downto 0);
    signal   N_FINISH        : std_logic;
    signal   M_FINISH        : std_logic;
    signal   S_FINISH        : std_logic;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    component MARCHAL
        generic (
            SCENARIO_FILE   : STRING;
            NAME            : STRING;
            SYNC_PLUG_NUM   : SYNC_PLUG_NUM_TYPE;
            SYNC_WIDTH      : integer;
            FINISH_ABORT    : boolean
        );
        port(
            CLK             : in    std_logic;
            RESET           : out   std_logic;
            SYNC            : inout SYNC_SIG_VECTOR(SYNC_WIDTH-1 downto 0);
            FINISH          : out   std_logic
        );
    end component;
begin

    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    N: MARCHAL
        generic map(
            SCENARIO_FILE   => SCENARIO_FILE,
            NAME            => "N",
            SYNC_PLUG_NUM   => 1,
            SYNC_WIDTH      => SYNC_WIDTH,
            FINISH_ABORT    => FALSE
        )
        port map(
            CLK             => ACLK            , -- In  :
            RESET           => RESET           , -- In  :
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
            FINISH          => N_FINISH          -- Out :
        );
    ------------------------------------------------------------------------------
    -- AXI4_MASTER_PLAYER
    ------------------------------------------------------------------------------
    M: AXI4_MASTER_PLAYER
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE,
            NAME            => "M",
            OUTPUT_DELAY    => DELAY,
            AXI4_ID_WIDTH   => AXI4_ID_WIDTH,
            AXI4_A_WIDTH    => AXI4_A_WIDTH,
            AXI4_W_WIDTH    => AXI4_W_WIDTH,
            AXI4_R_WIDTH    => AXI4_R_WIDTH,
            SYNC_PLUG_NUM   => 2,
            SYNC_WIDTH      => SYNC_WIDTH,
            FINISH_ABORT    => FALSE
        )
        port map(
        --------------------------------------------------------------------------
        -- グローバルシグナル.
        --------------------------------------------------------------------------
            ACLK            => ACLK            , -- In  :
            ARESETn         => ARESETn         , -- In  :
        --------------------------------------------------------------------------
        -- アドレスチャネルシグナル.
        --------------------------------------------------------------------------
            AVALID          => AVALID          , -- Out :
            ADDR            => ADDR            , -- Out :
            AWRITE          => AWRITE          , -- Out :
            ALEN            => ALEN            , -- Out :
            ASIZE           => ASIZE           , -- Out :
            ABURST          => ABURST          , -- Out :
            ALOCK           => ALOCK           , -- Out :
            ACACHE          => ACACHE          , -- Out :
            APROT           => APROT           , -- Out :
            AID             => AID             , -- Out :
            AREADY          => AREADY          , -- In  :
        --------------------------------------------------------------------------
        -- リードチャネルシグナル.
        --------------------------------------------------------------------------
            RVALID          => RVALID          , -- In  :
            RLAST           => RLAST           , -- In  :
            RDATA           => RDATA           , -- In  :
            RRESP           => RRESP           , -- In  :
            RID             => RID             , -- In  :
            RREADY          => RREADY          , -- Out :
        -------------------------------------------------------------------------
        -- ライトチャネルシグナル.
        -------------------------------------------------------------------------
            WVALID          => WVALID          , -- Out :
            WLAST           => WLAST           , -- Out :
            WDATA           => WDATA           , -- Out :
            WSTRB           => WSTRB           , -- Out :
            WID             => WID             , -- Out :
            WREADY          => WREADY          , -- In  :
        -------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        -------------------------------------------------------------------------
            BVALID          => BVALID          , -- In  :
            BRESP           => BRESP           , -- In  :
            BID             => BID             , -- In  :
            BREADY          => BREADY          , -- Out :
        -------------------------------------------------------------------------
        -- シンクロ用信号
        -------------------------------------------------------------------------
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
            FINISH          => M_FINISH          -- Out :
        );
    ------------------------------------------------------------------------------
    -- AXI4_SLAVE_PLAYER
    ------------------------------------------------------------------------------
    S: AXI4_SLAVE_PLAYER
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE,
            NAME            => "S",
            OUTPUT_DELAY    => DELAY,
            AXI4_ID_WIDTH   => AXI4_ID_WIDTH,
            AXI4_A_WIDTH    => AXI4_A_WIDTH,
            AXI4_W_WIDTH    => AXI4_W_WIDTH,
            AXI4_R_WIDTH    => AXI4_R_WIDTH,
            SYNC_PLUG_NUM   => 3,
            SYNC_WIDTH      => SYNC_WIDTH,
            FINISH_ABORT    => FALSE
        )
        port map(
        --------------------------------------------------------------------------
        -- グローバルシグナル.
        --------------------------------------------------------------------------
            ACLK            => ACLK            , -- In  :
            ARESETn         => ARESETn         , -- In  :
        --------------------------------------------------------------------------
        -- アドレスチャネルシグナル.
        --------------------------------------------------------------------------
            AVALID          => AVALID          , -- In  :
            ADDR            => ADDR            , -- In  :
            AWRITE          => AWRITE          , -- In  :
            ALEN            => ALEN            , -- In  :
            ASIZE           => ASIZE           , -- In  :
            ABURST          => ABURST          , -- In  :
            ALOCK           => ALOCK           , -- In  :
            ACACHE          => ACACHE          , -- In  :
            APROT           => APROT           , -- In  :
            AID             => AID             , -- In  :
            AREADY          => AREADY          , -- Out :
        --------------------------------------------------------------------------
        -- リードチャネルシグナル.
        --------------------------------------------------------------------------
            RVALID          => RVALID          , -- Out :
            RLAST           => RLAST           , -- Out :
            RDATA           => RDATA           , -- Out :
            RRESP           => RRESP           , -- Out :
            RID             => RID             , -- Out :
            RREADY          => RREADY          , -- In  :
        --------------------------------------------------------------------------
        -- ライトチャネルシグナル.
        --------------------------------------------------------------------------
            WVALID          => WVALID          , -- In  :
            WLAST           => WLAST           , -- In  :
            WDATA           => WDATA           , -- In  :
            WSTRB           => WSTRB           , -- In  :
            WID             => WID             , -- In  :
            WREADY          => WREADY          , -- Out :
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
            BVALID          => BVALID          , -- Out :
            BRESP           => BRESP           , -- Out :
            BID             => BID             , -- Out :
            BREADY          => BREADY          , -- In  :
        --------------------------------------------------------------------------
        -- シンクロ用信号
        --------------------------------------------------------------------------
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
            FINISH          => S_FINISH          -- Out :
    );

    PRINT: AXI4_SIGNAL_PRINTER 
        generic map (
            NAME            => "AXI4_TEST_1",
            TAG             => "",
            AXI4_ID_WIDTH   => AXI4_ID_WIDTH,
            AXI4_A_WIDTH    => AXI4_A_WIDTH,
            AXI4_W_WIDTH    => AXI4_W_WIDTH,
            AXI4_R_WIDTH    => AXI4_R_WIDTH
        )
        port map(
        --------------------------------------------------------------------------
        -- グローバルシグナル.
        --------------------------------------------------------------------------
            ACLK            => ACLK            , -- In  :
            ARESETn         => ARESETn         , -- In  :
        --------------------------------------------------------------------------
        -- アドレスチャネルシグナル.
        --------------------------------------------------------------------------
            AVALID          => AVALID          , -- In  :
            ADDR            => ADDR            , -- In  :
            AWRITE          => AWRITE          , -- In  :
            ALEN            => ALEN            , -- In  :
            ASIZE           => ASIZE           , -- In  :
            ABURST          => ABURST          , -- In  :
            ALOCK           => ALOCK           , -- In  :
            ACACHE          => ACACHE          , -- In  :
            APROT           => APROT           , -- In  :
            AID             => AID             , -- In  :
            AREADY          => AREADY          , -- In  :
        --------------------------------------------------------------------------
        -- リードチャネルシグナル.
        --------------------------------------------------------------------------
            RVALID          => RVALID          , -- In  :
            RLAST           => RLAST           , -- In  :
            RDATA           => RDATA           , -- In  :
            RRESP           => RRESP           , -- In  :
            RID             => RID             , -- In  :
            RREADY          => RREADY          , -- In  :
        --------------------------------------------------------------------------
        -- ライトチャネルシグナル.
        --------------------------------------------------------------------------
            WVALID          => WVALID          , -- In  :
            WLAST           => WLAST           , -- In  :
            WDATA           => WDATA           , -- In  :
            WSTRB           => WSTRB           , -- In  :
            WID             => WID             , -- In  :
            WREADY          => WREADY          , -- In  :
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
            BVALID          => BVALID          , -- In  :
            BRESP           => BRESP           , -- In  :
            BID             => BID             , -- In  :
            BREADY          => BREADY            -- In  :
        );
        
    process begin
        ACLK <= '1';
        wait for PERIOD / 2;
        ACLK <= '0';
        wait for PERIOD / 2;
    end process;

    ARESETn <= '1' when (RESET = '0') else '0';

    process begin
        wait until (N_FINISH'event and N_FINISH = '1');
        assert FALSE report "Simulation complete." severity FAILURE;
        wait;
    end process;
    
end MODEL;

