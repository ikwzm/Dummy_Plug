-----------------------------------------------------------------------------------
--!     @file    aix4_test_2.vhd
--!     @brief   TEST BENCH No.1 for DUMMY_PLUG.AXI4_MODELS
--!     @version 0.0.4
--!     @date    2012/5/7
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
use     DUMMY_PLUG.AXI4_MODELS.AXI4_SIGNAL_PRINTER;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.CORE.MARCHAL;
entity  DUMMY_PLUG_AXI4_TEST_2 is
end     DUMMY_PLUG_AXI4_TEST_2;
architecture MODEL of DUMMY_PLUG_AXI4_TEST_2 is
    ------------------------------------------------------------------------------
    -- シナリオファイル名.
    ------------------------------------------------------------------------------
    constant SCENARIO_FILE       : STRING  := "../../src/test/resouces/axi4_test_2.snr";
    ------------------------------------------------------------------------------
    -- 各種定数
    ------------------------------------------------------------------------------
    constant PERIOD              : time    := 10 ns;
    constant DELAY               : time    :=  1 ns;
    constant SYNC_WIDTH          : integer :=  2;
    constant C_M_AXI_ID_WIDTH    : integer :=  1;
    constant C_M_AXI_ADDR_WIDTH  : integer := 32;
    constant C_M_AXI_DATA_WIDTH  : integer := 32;
    constant C_M_AXI_AWUSER_WIDTH: integer :=  1;
    constant C_M_AXI_ARUSER_WIDTH: integer :=  1;
    constant C_M_AXI_WUSER_WIDTH : integer :=  1;
    constant C_M_AXI_RUSER_WIDTH : integer :=  1;
    constant C_M_AXI_BUSER_WIDTH : integer :=  1;
    ------------------------------------------------------------------------------
    -- グローバルシグナル.
    ------------------------------------------------------------------------------
    signal   ACLK            : std_logic;
    signal   ARESETn         : std_logic;
    signal   RESET           : std_logic;
    ------------------------------------------------------------------------------
    -- アドレスチャネルシグナル.
    ------------------------------------------------------------------------------
    signal   M_AXI_AWID      : std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
    signal   M_AXI_AWADDR    : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    signal   M_AXI_AWWRITE   : std_logic;
    signal   M_AXI_AWLEN     : AXI4_ALEN_TYPE;
    signal   M_AXI_AWSIZE    : AXI4_ASIZE_TYPE;
    signal   M_AXI_AWBURST   : AXI4_ABURST_TYPE;
    signal   M_AXI_AWLOCK    : AXI4_ALOCK_TYPE;
    signal   M_AXI_AWCACHE   : AXI4_ACACHE_TYPE;
    signal   M_AXI_AWPROT    : AXI4_APROT_TYPE;
    signal   M_AXI_AWQOS     : AXI4_AQOS_TYPE;
    signal   M_AXI_AWREGION  : AXI4_AREGION_TYPE;
    signal   M_AXI_AWUSER    : std_logic_vector(C_M_AXI_AWUSER_WIDTH-1 downto 0);
    signal   M_AXI_AWVALID   : std_logic;
    signal   M_AXI_AWREADY   : std_logic;
    ------------------------------------------------------------------------------
    -- ライトチャネルシグナル.
    ------------------------------------------------------------------------------
    signal   M_AXI_WID       : std_logic_vector(C_M_AXI_ID_WIDTH    -1 downto 0);
    signal   M_AXI_WDATA     : std_logic_vector(C_M_AXI_DATA_WIDTH  -1 downto 0);
    signal   M_AXI_WSTRB     : std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
    signal   M_AXI_WLAST     : std_logic;
    signal   M_AXI_WUSER     : std_logic_vector(C_M_AXI_WUSER_WIDTH -1 downto 0);
    signal   M_AXI_WVALID    : std_logic;
    signal   M_AXI_WREADY    : std_logic;
    ------------------------------------------------------------------------------
    -- ライト応答チャネルシグナル.
    ------------------------------------------------------------------------------
    signal   M_AXI_BID       : std_logic_vector(C_M_AXI_ID_WIDTH    -1 downto 0);
    signal   M_AXI_BRESP     : AXI4_RESP_TYPE;
    signal   M_AXI_BUSER     : std_logic_vector(C_M_AXI_BUSER_WIDTH -1 downto 0);
    signal   M_AXI_BVALID    : std_logic;
    signal   M_AXI_BREADY    : std_logic;
    ------------------------------------------------------------------------------
    -- アドレスチャネルシグナル.
    ------------------------------------------------------------------------------
    signal   M_AXI_ARID      : std_logic_vector(C_M_AXI_ID_WIDTH    -1 downto 0);
    signal   M_AXI_ARADDR    : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    signal   M_AXI_ARWRITE   : std_logic;
    signal   M_AXI_ARLEN     : AXI4_ALEN_TYPE;
    signal   M_AXI_ARSIZE    : AXI4_ASIZE_TYPE;
    signal   M_AXI_ARBURST   : AXI4_ABURST_TYPE;
    signal   M_AXI_ARLOCK    : AXI4_ALOCK_TYPE;
    signal   M_AXI_ARCACHE   : AXI4_ACACHE_TYPE;
    signal   M_AXI_ARPROT    : AXI4_APROT_TYPE;
    signal   M_AXI_ARQOS     : AXI4_AQOS_TYPE;
    signal   M_AXI_ARREGION  : AXI4_AREGION_TYPE;
    signal   M_AXI_ARUSER    : std_logic_vector(C_M_AXI_ARUSER_WIDTH-1 downto 0);
    signal   M_AXI_ARVALID   : std_logic;
    signal   M_AXI_ARREADY   : std_logic;
    ------------------------------------------------------------------------------
    -- リードチャネルシグナル.
    ------------------------------------------------------------------------------
    signal   M_AXI_RID       : std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
    signal   M_AXI_RDATA     : std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
    signal   M_AXI_RRESP     : AXI4_RESP_TYPE;
    signal   M_AXI_RLAST     : std_logic;
    signal   M_AXI_RUSER     : std_logic_vector(C_M_AXI_RUSER_WIDTH-1 downto 0);
    signal   M_AXI_RVALID    : std_logic;
    signal   M_AXI_RREADY    : std_logic;
    ------------------------------------------------------------------------------
    -- シンクロ用信号
    ------------------------------------------------------------------------------
    signal   SYNC            : SYNC_SIG_VECTOR (SYNC_WIDTH     -1 downto 0);
    signal   N_FINISH        : std_logic;
    signal   M_FINISH        : std_logic;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    component axi_master_bfm
      generic (
        C_M_AXI_ID_WIDTH     : integer := 1;
        C_M_AXI_ADDR_WIDTH   : integer := 32;
        C_M_AXI_DATA_WIDTH   : integer := 32;
        C_M_AXI_AWUSER_WIDTH : integer := 1;
        C_M_AXI_ARUSER_WIDTH : integer := 1;
        C_M_AXI_WUSER_WIDTH  : integer := 1;
        C_M_AXI_RUSER_WIDTH  : integer := 1;
        C_M_AXI_BUSER_WIDTH  : integer := 1;
    
        C_M_AXI_TARGET       : integer := 0;
        C_OFFSET_WIDTH       : integer := 10; -- 割り当てるRAMのアドレスのビット幅
        C_M_AXI_BURST_LEN    : integer := 256;
    
        WRITE_RANDOM_WAIT    : integer := 1; -- Write Transaction のデータ転送の時にランダムなWaitを発生させる=1, Waitしない=0
        READ_RANDOM_WAIT     : integer := 0 -- Read Transaction のデータ転送の時にランダムなWaitを発生させる=1, Waitしない=0
        );
      port(
        -- System Signals
        ACLK    : in std_logic;
        ARESETN : in std_logic;

        -- Master Interface Write Address Ports
        M_AXI_AWID     : in  std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
        M_AXI_AWADDR   : in  std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
        M_AXI_AWLEN    : in  std_logic_vector(8-1 downto 0);
        M_AXI_AWSIZE   : in  std_logic_vector(3-1 downto 0);
        M_AXI_AWBURST  : in  std_logic_vector(2-1 downto 0);
        M_AXI_AWLOCK   : in  std_logic_vector(2-1 downto 0);
        M_AXI_AWCACHE  : in  std_logic_vector(4-1 downto 0);
        M_AXI_AWPROT   : in  std_logic_vector(3-1 downto 0);
        M_AXI_AWQOS    : in  std_logic_vector(4-1 downto 0);
        M_AXI_AWUSER   : in  std_logic_vector(C_M_AXI_AWUSER_WIDTH-1 downto 0);
        M_AXI_AWVALID  : in  std_logic;
        M_AXI_AWREADY  : out std_logic;

        -- Master Interface Write Data Ports
        M_AXI_WDATA  : in  std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
        M_AXI_WSTRB  : in  std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
        M_AXI_WLAST  : in  std_logic;
        M_AXI_WUSER  : in  std_logic_vector(C_M_AXI_WUSER_WIDTH-1 downto 0);
        M_AXI_WVALID : in  std_logic;
        M_AXI_WREADY : out std_logic;
    
        -- Master Interface Write Response Ports
        M_AXI_BID    : out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
        M_AXI_BRESP  : out std_logic_vector(2-1 downto 0);
        M_AXI_BUSER  : out std_logic_vector(C_M_AXI_BUSER_WIDTH-1 downto 0);
        M_AXI_BVALID : out std_logic;
        M_AXI_BREADY : in  std_logic;

        -- Master Interface Read Address Ports
        M_AXI_ARID     : in  std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
        M_AXI_ARADDR   : in  std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
        M_AXI_ARLEN    : in  std_logic_vector(8-1 downto 0);
        M_AXI_ARSIZE   : in  std_logic_vector(3-1 downto 0);
        M_AXI_ARBURST  : in  std_logic_vector(2-1 downto 0);
        M_AXI_ARLOCK   : in  std_logic_vector(2-1 downto 0);
        M_AXI_ARCACHE  : in  std_logic_vector(4-1 downto 0);
        M_AXI_ARPROT   : in  std_logic_vector(3-1 downto 0);
        M_AXI_ARQOS    : in  std_logic_vector(4-1 downto 0);
        M_AXI_ARUSER   : in  std_logic_vector(C_M_AXI_ARUSER_WIDTH-1 downto 0);
        M_AXI_ARVALID  : in  std_logic;
        M_AXI_ARREADY  : out std_logic;

        -- Master Interface Read Data Ports
        M_AXI_RID    : out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
        M_AXI_RDATA  : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
        M_AXI_RRESP  : out std_logic_vector(2-1 downto 0);
        M_AXI_RLAST  : out std_logic;
        M_AXI_RUSER  : out std_logic_vector(C_M_AXI_RUSER_WIDTH-1 downto 0);
        M_AXI_RVALID : out std_logic;
        M_AXI_RREADY : in  std_logic
      );
    end component;
begin
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
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
            FINISH          => N_FINISH          -- Out :
        );
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    M: AXI4_MASTER_PLAYER
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE,
            NAME            => "MASTER",
            READ            => TRUE,
            WRITE           => TRUE,
            OUTPUT_DELAY    => DELAY,
            WIDTH           => (ID     => C_M_AXI_ID_WIDTH,
                                AWADDR => C_M_AXI_ADDR_WIDTH,
                                ARADDR => C_M_AXI_ADDR_WIDTH,
                                RDATA  => C_M_AXI_DATA_WIDTH,
                                WDATA  => C_M_AXI_DATA_WIDTH,
                                AWUSER => 1,
                                ARUSER => 1,
                                RUSER  => 1,
                                WUSER  => 1,
                                BUSER  => 1
                               ),
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
        -- リードアドレスチャネルシグナル.
        --------------------------------------------------------------------------
            ARADDR          => M_AXI_ARADDR    , -- Out :
            ARLEN           => M_AXI_ARLEN     , -- Out :
            ARSIZE          => M_AXI_ARSIZE    , -- Out :
            ARBURST         => M_AXI_ARBURST   , -- Out :
            ARLOCK          => M_AXI_ARLOCK    , -- Out :
            ARCACHE         => M_AXI_ARCACHE   , -- Out :
            ARPROT          => M_AXI_ARPROT    , -- Out :
            ARQOS           => M_AXI_ARQOS     , -- Out :
            ARREGION        => M_AXI_ARREGION  , -- Out : 
            ARUSER          => M_AXI_ARUSER    , -- Out :
            ARID            => M_AXI_ARID      , -- Out :
            ARVALID         => M_AXI_ARVALID   , -- Out :
            ARREADY         => M_AXI_ARREADY   , -- In  :
        --------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        --------------------------------------------------------------------------
            RLAST           => M_AXI_RLAST     , -- In  :
            RDATA           => M_AXI_RDATA     , -- In  :
            RRESP           => M_AXI_RRESP     , -- In  :
            RUSER           => M_AXI_RUSER     , -- In  :
            RID             => M_AXI_RID       , -- In  :
            RVALID          => M_AXI_RVALID    , -- In  :
            RREADY          => M_AXI_RREADY    , -- Out :
        --------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        --------------------------------------------------------------------------
            AWADDR          => M_AXI_AWADDR    , -- Out :
            AWLEN           => M_AXI_AWLEN     , -- Out :
            AWSIZE          => M_AXI_AWSIZE    , -- Out :
            AWBURST         => M_AXI_AWBURST   , -- Out :
            AWLOCK          => M_AXI_AWLOCK    , -- Out :
            AWCACHE         => M_AXI_AWCACHE   , -- Out :
            AWPROT          => M_AXI_AWPROT    , -- Out :
            AWQOS           => M_AXI_AWQOS     , -- Out :
            AWREGION        => M_AXI_AWREGION  , -- Out : 
            AWUSER          => M_AXI_AWUSER    , -- Out :
            AWID            => M_AXI_AWID      , -- Out :
            AWVALID         => M_AXI_AWVALID   , -- Out :
            AWREADY         => M_AXI_AWREADY   , -- In  :
        -------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        -------------------------------------------------------------------------
            WLAST           => M_AXI_WLAST     , -- Out :
            WDATA           => M_AXI_WDATA     , -- Out :
            WSTRB           => M_AXI_WSTRB     , -- Out :
            WUSER           => M_AXI_WUSER     , -- Out :
            WID             => M_AXI_WID       , -- Out :
            WVALID          => M_AXI_WVALID    , -- Out :
            WREADY          => M_AXI_WREADY    , -- In  :
        -------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        -------------------------------------------------------------------------
            BRESP           => M_AXI_BRESP     , -- In  :
            BUSER           => M_AXI_BUSER     , -- In  :
            BID             => M_AXI_BID       , -- In  :
            BVALID          => M_AXI_BVALID    , -- In  :
            BREADY          => M_AXI_BREADY    , -- Out :
        -------------------------------------------------------------------------
        -- シンクロ用信号
        -------------------------------------------------------------------------
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
            FINISH          => M_FINISH          -- Out :
        );
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    DUT: axi_master_bfm
        generic map (
            C_M_AXI_ID_WIDTH     => C_M_AXI_ID_WIDTH,
            C_M_AXI_ADDR_WIDTH   => C_M_AXI_ADDR_WIDTH,
            C_M_AXI_DATA_WIDTH   => C_M_AXI_DATA_WIDTH,
            C_M_AXI_AWUSER_WIDTH => C_M_AXI_AWUSER_WIDTH,
            C_M_AXI_ARUSER_WIDTH => C_M_AXI_ARUSER_WIDTH,
            C_M_AXI_WUSER_WIDTH  => C_M_AXI_WUSER_WIDTH,
            C_M_AXI_RUSER_WIDTH  => C_M_AXI_RUSER_WIDTH,
            C_M_AXI_BUSER_WIDTH  => C_M_AXI_BUSER_WIDTH,
            C_M_AXI_TARGET       => 0,
            C_OFFSET_WIDTH       => 10,
            C_M_AXI_BURST_LEN    => 256,
            WRITE_RANDOM_WAIT    => 1,
            READ_RANDOM_WAIT     => 0
        )
        port map(
            -- System Signals
            ACLK            => ACLK            , -- In  :
            ARESETN         => ARESETn         , -- In  :

            -- Master Interface Write Address Ports
            M_AXI_AWID      => M_AXI_AWID      , -- In  :
            M_AXI_AWADDR    => M_AXI_AWADDR    , -- In  :
            M_AXI_AWLEN     => M_AXI_AWLEN     , -- In  :
            M_AXI_AWSIZE    => M_AXI_AWSIZE    , -- In  :
            M_AXI_AWBURST   => M_AXI_AWBURST   , -- In  :
            M_AXI_AWLOCK    => M_AXI_AWLOCK    , -- In  :
            M_AXI_AWCACHE   => M_AXI_AWCACHE   , -- In  :
            M_AXI_AWPROT    => M_AXI_AWPROT    , -- In  :
            M_AXI_AWQOS     => M_AXI_AWQOS     , -- In  :
            M_AXI_AWUSER    => M_AXI_AWUSER    , -- In  :
            M_AXI_AWVALID   => M_AXI_AWVALID   , -- In  :
            M_AXI_AWREADY   => M_AXI_AWREADY   , -- Out :

            -- Master Interface Write Data Ports
            M_AXI_WDATA     => M_AXI_WDATA     , -- In  :
            M_AXI_WSTRB     => M_AXI_WSTRB     , -- In  :
            M_AXI_WLAST     => M_AXI_WLAST     , -- In  :
            M_AXI_WUSER     => M_AXI_WUSER     , -- In  :
            M_AXI_WVALID    => M_AXI_WVALID    , -- In  :
            M_AXI_WREADY    => M_AXI_WREADY    , -- Out :
    
            -- Master Interface Write Response Ports
            M_AXI_BID       => M_AXI_BID       , -- Out :
            M_AXI_BRESP     => M_AXI_BRESP     , -- Out :
            M_AXI_BUSER     => M_AXI_BUSER     , -- Out :
            M_AXI_BVALID    => M_AXI_BVALID    , -- Out :
            M_AXI_BREADY    => M_AXI_BREADY    , -- In  :

            -- Master Interface Read Address Ports
            M_AXI_ARID      => M_AXI_ARID      , -- In  :
            M_AXI_ARADDR    => M_AXI_ARADDR    , -- In  :
            M_AXI_ARLEN     => M_AXI_ARLEN     , -- In  :
            M_AXI_ARSIZE    => M_AXI_ARSIZE    , -- In  :
            M_AXI_ARBURST   => M_AXI_ARBURST   , -- In  :
            M_AXI_ARLOCK    => M_AXI_ARLOCK    , -- In  :
            M_AXI_ARCACHE   => M_AXI_ARCACHE   , -- In  :
            M_AXI_ARPROT    => M_AXI_ARPROT    , -- In  :
            M_AXI_ARQOS     => M_AXI_ARQOS     , -- In  :
            M_AXI_ARUSER    => M_AXI_ARUSER    , -- In  :
            M_AXI_ARVALID   => M_AXI_ARVALID   , -- In  :
            M_AXI_ARREADY   => M_AXI_ARREADY   , -- Out :

            -- Master Interface Read Data Ports
            M_AXI_RID       => M_AXI_RID       , -- Out :
            M_AXI_RDATA     => M_AXI_RDATA     , -- Out :
            M_AXI_RRESP     => M_AXI_RRESP     , -- Out :
            M_AXI_RLAST     => M_AXI_RLAST     , -- Out :
            M_AXI_RUSER     => M_AXI_RUSER     , -- Out :
            M_AXI_RVALID    => M_AXI_RVALID    , -- Out :
            M_AXI_RREADY    => M_AXI_RREADY      -- In  :
        );
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    PRINT: AXI4_SIGNAL_PRINTER 
        generic map (
            NAME            => "AXI4_TEST_2",
            TAG             => "",
            TAG_WIDTH       => 0,
            TIME_WIDTH      => 13,
            WIDTH           => (ID     => C_M_AXI_ID_WIDTH,
                                AWADDR => C_M_AXI_ADDR_WIDTH,
                                ARADDR => C_M_AXI_ADDR_WIDTH,
                                RDATA  => C_M_AXI_DATA_WIDTH,
                                WDATA  => C_M_AXI_DATA_WIDTH,
                                AWUSER => 1,
                                ARUSER => 1,
                                RUSER  => 1,
                                WUSER  => 1,
                                BUSER  => 1
                               )
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
            ARADDR          => M_AXI_ARADDR    , -- In  :
            ARLEN           => M_AXI_ARLEN     , -- In  :
            ARSIZE          => M_AXI_ARSIZE    , -- In  :
            ARBURST         => M_AXI_ARBURST   , -- In  :
            ARLOCK          => M_AXI_ARLOCK    , -- In  :
            ARCACHE         => M_AXI_ARCACHE   , -- In  :
            ARPROT          => M_AXI_ARPROT    , -- In  :
            ARQOS           => M_AXI_ARQOS     , -- In  :
            ARREGION        => M_AXI_ARREGION  , -- In  :
            ARUSER          => M_AXI_ARUSER    , -- In  :
            ARID            => M_AXI_ARID      , -- In  :
            ARVALID         => M_AXI_ARVALID   , -- In  :
            ARREADY         => M_AXI_ARREADY   , -- In  :
        --------------------------------------------------------------------------
        -- リードチャネルシグナル.
        --------------------------------------------------------------------------
            RLAST           => M_AXI_RLAST     , -- In  :
            RDATA           => M_AXI_RDATA     , -- In  :
            RRESP           => M_AXI_RRESP     , -- In  :
            RUSER           => M_AXI_RUSER     , -- In  :
            RID             => M_AXI_RID       , -- In  :
            RVALID          => M_AXI_RVALID    , -- In  :
            RREADY          => M_AXI_RREADY    , -- In  :
        --------------------------------------------------------------------------
        -- アドレスチャネルシグナル.
        --------------------------------------------------------------------------
            AWADDR          => M_AXI_AWADDR    , -- In  :
            AWLEN           => M_AXI_AWLEN     , -- In  :
            AWSIZE          => M_AXI_AWSIZE    , -- In  :
            AWBURST         => M_AXI_AWBURST   , -- In  :
            AWLOCK          => M_AXI_AWLOCK    , -- In  :
            AWCACHE         => M_AXI_AWCACHE   , -- In  :
            AWPROT          => M_AXI_AWPROT    , -- In  :
            AWQOS           => M_AXI_AWQOS     , -- In  :
            AWREGION        => M_AXI_AWREGION  , -- In  :
            AWUSER          => M_AXI_AWUSER    , -- In  :
            AWID            => M_AXI_AWID      , -- In  :
            AWVALID         => M_AXI_AWVALID   , -- In  :
            AWREADY         => M_AXI_AWREADY   , -- In  :
        --------------------------------------------------------------------------
        -- ライトチャネルシグナル.
        --------------------------------------------------------------------------
            WLAST           => M_AXI_WLAST     , -- In  :
            WDATA           => M_AXI_WDATA     , -- In  :
            WSTRB           => M_AXI_WSTRB     , -- In  :
            WUSER           => M_AXI_WUSER     , -- In  :
            WID             => M_AXI_WID       , -- In  :
            WVALID          => M_AXI_WVALID    , -- In  :
            WREADY          => M_AXI_WREADY    , -- In  :
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
            BVALID          => M_AXI_BVALID    , -- In  :
            BUSER           => M_AXI_BUSER     , -- In  :
            BRESP           => M_AXI_BRESP     , -- In  :
            BID             => M_AXI_BID       , -- In  :
            BREADY          => M_AXI_BREADY      -- In  :
        );
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
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

    
