-----------------------------------------------------------------------------------
--!     @file    aix4_test_1.vhd
--!     @brief   TEST BENCH No.1 for DUMMY_PLUG.AXI4_MODELS
--!     @version 0.0.5
--!     @date    2012/5/12
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
use     DUMMY_PLUG.CORE.MARCHAL;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
entity  DUMMY_PLUG_AXI4_TEST_1 is
end     DUMMY_PLUG_AXI4_TEST_1;
architecture MODEL of DUMMY_PLUG_AXI4_TEST_1 is
    -------------------------------------------------------------------------------
    -- シナリオファイル名.
    -------------------------------------------------------------------------------
    constant SCENARIO_FILE   : STRING  := "../../src/test/resouces/axi4_test_1.snr";
    -------------------------------------------------------------------------------
    -- 各種定数
    -------------------------------------------------------------------------------
    constant PERIOD          : time    := 10 ns;
    constant DELAY           : time    :=  1 ns;
    constant WIDTH           : AXI4_SIGNAL_WIDTH_TYPE := (
                                 ID          =>  4,
                                 AWADDR      => 32,
                                 ARADDR      => 32,
                                 WDATA       => 32,
                                 RDATA       => 32,
                                 ARUSER      =>  1,
                                 AWUSER      =>  1,
                                 WUSER       =>  1,
                                 RUSER       =>  1,
                                 BUSER       =>  1);
    constant SYNC_WIDTH      : integer :=  2;
    -------------------------------------------------------------------------------
    -- グローバルシグナル.
    -------------------------------------------------------------------------------
    signal   ACLK            : std_logic;
    signal   ARESETn         : std_logic;
    signal   RESET           : std_logic;
    ------------------------------------------------------------------------------
    -- リードアドレスチャネルシグナル.
    ------------------------------------------------------------------------------
    signal   ARADDR          : std_logic_vector(WIDTH.ARADDR -1 downto 0);
    signal   ARWRITE         : std_logic;
    signal   ARLEN           : AXI4_ALEN_TYPE;
    signal   ARSIZE          : AXI4_ASIZE_TYPE;
    signal   ARBURST         : AXI4_ABURST_TYPE;
    signal   ARLOCK          : AXI4_ALOCK_TYPE;
    signal   ARCACHE         : AXI4_ACACHE_TYPE;
    signal   ARPROT          : AXI4_APROT_TYPE;
    signal   ARQOS           : AXI4_AQOS_TYPE;
    signal   ARREGION        : AXI4_AREGION_TYPE;
    signal   ARUSER          : std_logic_vector(WIDTH.ARUSER -1 downto 0);
    signal   ARID            : std_logic_vector(WIDTH.ID     -1 downto 0);
    signal   ARVALID         : std_logic;
    signal   ARREADY         : std_logic;
    -------------------------------------------------------------------------------
    -- リードデータチャネルシグナル.
    -------------------------------------------------------------------------------
    signal   RVALID          : std_logic;
    signal   RLAST           : std_logic;
    signal   RDATA           : std_logic_vector(WIDTH.RDATA  -1 downto 0);
    signal   RRESP           : AXI4_RESP_TYPE;
    signal   RUSER           : std_logic_vector(WIDTH.RUSER  -1 downto 0);
    signal   RID             : std_logic_vector(WIDTH.ID     -1 downto 0);
    signal   RREADY          : std_logic;
    -------------------------------------------------------------------------------
    -- ライトアドレスチャネルシグナル.
    -------------------------------------------------------------------------------
    signal   AWADDR          : std_logic_vector(WIDTH.AWADDR -1 downto 0);
    signal   AWLEN           : AXI4_ALEN_TYPE;
    signal   AWSIZE          : AXI4_ASIZE_TYPE;
    signal   AWBURST         : AXI4_ABURST_TYPE;
    signal   AWLOCK          : AXI4_ALOCK_TYPE;
    signal   AWCACHE         : AXI4_ACACHE_TYPE;
    signal   AWPROT          : AXI4_APROT_TYPE;
    signal   AWQOS           : AXI4_AQOS_TYPE;
    signal   AWREGION        : AXI4_AREGION_TYPE;
    signal   AWUSER          : std_logic_vector(WIDTH.AWUSER -1 downto 0);
    signal   AWID            : std_logic_vector(WIDTH.ID     -1 downto 0);
    signal   AWVALID         : std_logic;
    signal   AWREADY         : std_logic;
    -------------------------------------------------------------------------------
    -- ライトデータチャネルシグナル.
    -------------------------------------------------------------------------------
    signal   WLAST           : std_logic;
    signal   WDATA           : std_logic_vector(WIDTH.WDATA  -1 downto 0);
    signal   WSTRB           : std_logic_vector(WIDTH.WDATA/8-1 downto 0);
    signal   WUSER           : std_logic_vector(WIDTH.WUSER  -1 downto 0);
    signal   WID             : std_logic_vector(WIDTH.ID     -1 downto 0);
    signal   WVALID          : std_logic;
    signal   WREADY          : std_logic;
    -------------------------------------------------------------------------------
    -- ライト応答チャネルシグナル.
    -------------------------------------------------------------------------------
    signal   BRESP           : AXI4_RESP_TYPE;
    signal   BUSER           : std_logic_vector(WIDTH.BUSER  -1 downto 0);
    signal   BID             : std_logic_vector(WIDTH.ID     -1 downto 0);
    signal   BVALID          : std_logic;
    signal   BREADY          : std_logic;
    -------------------------------------------------------------------------------
    -- シンクロ用信号
    -------------------------------------------------------------------------------
    signal   SYNC            : SYNC_SIG_VECTOR (SYNC_WIDTH     -1 downto 0);
    -------------------------------------------------------------------------------
    -- 各種状態出力.
    -------------------------------------------------------------------------------
    signal   N_REPORT        : REPORT_STATUS_TYPE;
    signal   M_REPORT        : REPORT_STATUS_TYPE;
    signal   S_REPORT        : REPORT_STATUS_TYPE;
    signal   N_FINISH        : std_logic;
    signal   M_FINISH        : std_logic;
    signal   S_FINISH        : std_logic;
begin

    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    N: MARCHAL
        generic map(
            SCENARIO_FILE   => SCENARIO_FILE,
            NAME            => "MARCHAL",
            SYNC_PLUG_NUM   => 1,
            SYNC_WIDTH      => SYNC_WIDTH,
            FINISH_ABORT    => FALSE
        )
        port map(
            CLK             => ACLK            , -- In  :
            RESET           => RESET           , -- In  :
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
            REPORT_STATUS   => N_REPORT        , -- Out :
            FINISH          => N_FINISH          -- Out :
        );
    ------------------------------------------------------------------------------
    -- AXI4_MASTER_PLAYER
    ------------------------------------------------------------------------------
    M: AXI4_MASTER_PLAYER
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE,
            NAME            => "MASTER",
            READ            => TRUE,
            WRITE           => TRUE,
            OUTPUT_DELAY    => DELAY,
            WIDTH           => WIDTH,
            SYNC_PLUG_NUM   => 2,
            SYNC_WIDTH      => SYNC_WIDTH,
            FINISH_ABORT    => FALSE
        )
        port map(
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
            ACLK            => ACLK            , -- In  :
            ARESETn         => ARESETn         , -- In  :
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            ARADDR          => ARADDR          , -- I/O : 
            ARLEN           => ARLEN           , -- I/O : 
            ARSIZE          => ARSIZE          , -- I/O : 
            ARBURST         => ARBURST         , -- I/O : 
            ARLOCK          => ARLOCK          , -- I/O : 
            ARCACHE         => ARCACHE         , -- I/O : 
            ARPROT          => ARPROT          , -- I/O : 
            ARQOS           => ARQOS           , -- I/O : 
            ARREGION        => ARREGION        , -- I/O : 
            ARUSER          => ARUSER          , -- I/O : 
            ARID            => ARID            , -- I/O : 
            ARVALID         => ARVALID         , -- I/O : 
            ARREADY         => ARREADY         , -- In  :    
        ---------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        ---------------------------------------------------------------------------
            RLAST           => RLAST           , -- In  :    
            RDATA           => RDATA           , -- In  :    
            RRESP           => RRESP           , -- In  :    
            RUSER           => RUSER           , -- In  :    
            RID             => RID             , -- In  :    
            RVALID          => RVALID          , -- In  :    
            RREADY          => RREADY          , -- I/O : 
        --------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        --------------------------------------------------------------------------
            AWADDR          => AWADDR          , -- I/O : 
            AWLEN           => AWLEN           , -- I/O : 
            AWSIZE          => AWSIZE          , -- I/O : 
            AWBURST         => AWBURST         , -- I/O : 
            AWLOCK          => AWLOCK          , -- I/O : 
            AWCACHE         => AWCACHE         , -- I/O : 
            AWPROT          => AWPROT          , -- I/O : 
            AWQOS           => AWQOS           , -- I/O : 
            AWREGION        => AWREGION        , -- I/O : 
            AWUSER          => AWUSER          , -- I/O : 
            AWID            => AWID            , -- I/O : 
            AWVALID         => AWVALID         , -- I/O : 
            AWREADY         => AWREADY         , -- In  :    
        --------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        --------------------------------------------------------------------------
            WLAST           => WLAST           , -- I/O : 
            WDATA           => WDATA           , -- I/O : 
            WSTRB           => WSTRB           , -- I/O : 
            WUSER           => WUSER           , -- I/O : 
            WID             => WID             , -- I/O : 
            WVALID          => WVALID          , -- I/O : 
            WREADY          => WREADY          , -- In  :    
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
            BRESP           => BRESP           , -- In  :    
            BUSER           => BUSER           , -- In  :    
            BID             => BID             , -- In  :    
            BVALID          => BVALID          , -- In  :    
            BREADY          => BREADY          , -- I/O : 
        --------------------------------------------------------------------------
        -- シンクロ用信号
        --------------------------------------------------------------------------
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
        --------------------------------------------------------------------------
        -- 各種状態出力.
        --------------------------------------------------------------------------
            REPORT_STATUS   => M_REPORT        , -- Out :
            FINISH          => M_FINISH          -- Out :
        );
    ------------------------------------------------------------------------------
    -- AXI4_SLAVE_PLAYER
    ------------------------------------------------------------------------------
    S: AXI4_SLAVE_PLAYER
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE,
            NAME            => "SLAVE",
            READ            => TRUE,
            WRITE           => TRUE,
            OUTPUT_DELAY    => DELAY,
            WIDTH           => WIDTH,
            SYNC_PLUG_NUM   => 3,
            SYNC_WIDTH      => SYNC_WIDTH,
            FINISH_ABORT    => FALSE
        )
        port map(
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
            ACLK            => ACLK            , -- In  :
            ARESETn         => ARESETn         , -- In  :
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            ARADDR          => ARADDR          , -- In  :    
            ARLEN           => ARLEN           , -- In  :    
            ARSIZE          => ARSIZE          , -- In  :    
            ARBURST         => ARBURST         , -- In  :    
            ARLOCK          => ARLOCK          , -- In  :    
            ARCACHE         => ARCACHE         , -- In  :    
            ARPROT          => ARPROT          , -- In  :    
            ARQOS           => ARQOS           , -- In  :    
            ARREGION        => ARREGION        , -- In  :    
            ARUSER          => ARUSER          , -- In  :    
            ARID            => ARID            , -- In  :    
            ARVALID         => ARVALID         , -- In  :    
            ARREADY         => ARREADY         , -- I/O : 
        ---------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        ---------------------------------------------------------------------------
            RLAST           => RLAST           , -- I/O : 
            RDATA           => RDATA           , -- I/O : 
            RRESP           => RRESP           , -- I/O : 
            RUSER           => RUSER           , -- I/O : 
            RID             => RID             , -- I/O : 
            RVALID          => RVALID          , -- I/O : 
            RREADY          => RREADY          , -- In  :    
        ---------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            AWADDR          => AWADDR          , -- In  :    
            AWLEN           => AWLEN           , -- In  :    
            AWSIZE          => AWSIZE          , -- In  :    
            AWBURST         => AWBURST         , -- In  :    
            AWLOCK          => AWLOCK          , -- In  :    
            AWCACHE         => AWCACHE         , -- In  :    
            AWPROT          => AWPROT          , -- In  :    
            AWQOS           => AWQOS           , -- In  :    
            AWREGION        => AWREGION        , -- In  :    
            AWUSER          => AWUSER          , -- In  :    
            AWID            => AWID            , -- In  :    
            AWVALID         => AWVALID         , -- In  :    
            AWREADY         => AWREADY         , -- I/O : 
        ---------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        ---------------------------------------------------------------------------
            WLAST           => WLAST           , -- In  :    
            WDATA           => WDATA           , -- In  :    
            WSTRB           => WSTRB           , -- In  :    
            WUSER           => WUSER           , -- In  :    
            WID             => WID             , -- In  :    
            WVALID          => WVALID          , -- In  :    
            WREADY          => WREADY          , -- I/O : 
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
            BRESP           => BRESP           , -- I/O : 
            BUSER           => BUSER           , -- I/O : 
            BID             => BID             , -- I/O : 
            BVALID          => BVALID          , -- I/O : 
            BREADY          => BREADY          , -- In  :    
        ---------------------------------------------------------------------------
        -- シンクロ用信号
        ---------------------------------------------------------------------------
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
        --------------------------------------------------------------------------
        -- 各種状態出力.
        --------------------------------------------------------------------------
            REPORT_STATUS   => S_REPORT        , -- Out :
            FINISH          => S_FINISH          -- Out :
    );
    -------------------------------------------------------------------------------
    -- AXI4_SIGNAL_PRINTER
    -------------------------------------------------------------------------------
    PRINT: AXI4_SIGNAL_PRINTER
        generic map (
            NAME            => "AXI4_TEST_1",
            TAG             => "AXI4_TEST_1",
            TAG_WIDTH       => 0,
            TIME_WIDTH      => 13,
            WIDTH           => WIDTH
        )
        port map (
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
            ACLK            => ACLK            , -- In  :
            ARESETn         => ARESETn         , -- In  :
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            ARADDR          => ARADDR          , -- In  :
            ARLEN           => ARLEN           , -- In  :
            ARSIZE          => ARSIZE          , -- In  :
            ARBURST         => ARBURST         , -- In  :
            ARLOCK          => ARLOCK          , -- In  :
            ARCACHE         => ARCACHE         , -- In  :
            ARPROT          => ARPROT          , -- In  :
            ARQOS           => ARQOS           , -- In  :
            ARREGION        => ARREGION        , -- In  :
            ARUSER          => ARUSER          , -- In  :
            ARID            => ARID            , -- In  :
            ARVALID         => ARVALID         , -- In  :
            ARREADY         => ARREADY         , -- In  :
        ---------------------------------------------------------------------------
        -- リードチャネルシグナル.
        ---------------------------------------------------------------------------
            RLAST           => RLAST           , -- In  :
            RDATA           => RDATA           , -- In  :
            RRESP           => RRESP           , -- In  :
            RUSER           => RUSER           , -- In  :
            RID             => RID             , -- In  :
            RVALID          => RVALID          , -- In  :
            RREADY          => RREADY          , -- In  :
        ---------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            AWADDR          => AWADDR          , -- In  :
            AWLEN           => AWLEN           , -- In  :
            AWSIZE          => AWSIZE          , -- In  :
            AWBURST         => AWBURST         , -- In  :
            AWLOCK          => AWLOCK          , -- In  :
            AWCACHE         => AWCACHE         , -- In  :
            AWPROT          => AWPROT          , -- In  :
            AWQOS           => AWQOS           , -- In  :
            AWREGION        => AWREGION        , -- In  :
            AWUSER          => AWUSER          , -- In  :
            AWID            => AWID            , -- In  :
            AWVALID         => AWVALID         , -- In  :
            AWREADY         => AWREADY         , -- In  :
        ---------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        ---------------------------------------------------------------------------
            WLAST           => WLAST           , -- In  :
            WDATA           => WDATA           , -- In  :
            WSTRB           => WSTRB           , -- In  :
            WUSER           => WUSER           , -- In  :
            WID             => WID             , -- In  :
            WVALID          => WVALID          , -- In  :
            WREADY          => WREADY          , -- In  :
        ---------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        ---------------------------------------------------------------------------
            BRESP           => BRESP           , -- In  :
            BUSER           => BUSER           , -- In  :
            BID             => BID             , -- In  :
            BVALID          => BVALID          , -- In  :
            BREADY          => BREADY            -- In  :
    );

    process begin
        ACLK <= '1';
        wait for PERIOD / 2;
        ACLK <= '0';
        wait for PERIOD / 2;
    end process;

    ARESETn <= '1' when (RESET = '0') else '0';

    process
        variable L : LINE;
        constant T : STRING(1 to 7) := "  ***  ";
    begin
        wait until (N_FINISH'event and N_FINISH = '1');
        wait for DELAY;
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "ERROR REPORT");                                  WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ MASTER ]");                                    WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,M_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,M_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,M_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ SLAVE ]");                                     WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,S_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,S_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,S_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        assert (M_REPORT.error_count    =  0) and
               (M_REPORT.mismatch_count =  8) and
               (M_REPORT.warning_count  =  0) and
               (M_REPORT.failure_count  =  0) and
               (S_REPORT.error_count    =  0) and
               (S_REPORT.mismatch_count = 20) and
               (S_REPORT.warning_count  =  0) and
               (S_REPORT.failure_count  =  0)
        report "REPORT Mismatch !!" severity FAILURE;
        assert FALSE report "Simulation complete." severity FAILURE;
        wait;
    end process;
    
 -- SYNC_PRINT_0: SYNC_PRINT generic map(string'("AXI4_TEST_1:SYNC(0)")) port map (SYNC(0));
 -- SYNC_PRINT_1: SYNC_PRINT generic map(string'("AXI4_TEST_1:SYNC(1)")) port map (SYNC(1));
end MODEL;

