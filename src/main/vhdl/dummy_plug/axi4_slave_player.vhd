-----------------------------------------------------------------------------------
--!     @file    axi4_slave_player.vhd
--!     @brief   AXI4 Slave Dummy Plug Player.
--!     @version 0.0.2
--!     @date    2012/5/2
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
--! @brief   AXI4_SLAVE_PLAYER :
-----------------------------------------------------------------------------------
entity  AXI4_SLAVE_PLAYER is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        SCENARIO_FILE   : --! @brief シナリオファイルの名前.
                          STRING;
        NAME            : --! @brief 固有名詞.
                          STRING;
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
        AVALID          : in    std_logic;
        ADDR            : in    std_logic_vector(AXI4_A_WIDTH   -1 downto 0);
        AWRITE          : in    std_logic;
        ALEN            : in    AXI4_ALEN_TYPE;
        ASIZE           : in    AXI4_ASIZE_TYPE;
        ABURST          : in    AXI4_ABURST_TYPE;
        ALOCK           : in    AXI4_ALOCK_TYPE;
        ACACHE          : in    AXI4_ACACHE_TYPE;
        APROT           : in    AXI4_APROT_TYPE;
        AID             : in    std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
        AREADY          : inout std_logic;
        --------------------------------------------------------------------------
        -- リードチャネルシグナル.
        --------------------------------------------------------------------------
        RVALID          : inout std_logic;
        RLAST           : inout std_logic;
        RDATA           : inout std_logic_vector(AXI4_R_WIDTH   -1 downto 0);
        RRESP           : inout AXI4_RESP_TYPE;
        RID             : inout std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
        RREADY          : in    std_logic;
        --------------------------------------------------------------------------
        -- ライトチャネルシグナル.
        --------------------------------------------------------------------------
        WVALID          : in    std_logic;
        WLAST           : in    std_logic;
        WDATA           : in    std_logic_vector(AXI4_W_WIDTH   -1 downto 0);
        WSTRB           : in    std_logic_vector(AXI4_W_WIDTH/8 -1 downto 0);
        WID             : in    std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
        WREADY          : inout std_logic;
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
        BVALID          : inout std_logic;
        BRESP           : inout AXI4_RESP_TYPE;
        BID             : inout std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
        BREADY          : in    std_logic;
        --------------------------------------------------------------------------
        -- シンクロ用信号
        --------------------------------------------------------------------------
        SYNC            : inout SYNC_SIG_VECTOR (SYNC_WIDTH     -1 downto 0);
        FINISH          : out   std_logic
    );
end AXI4_SLAVE_PLAYER;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_CORE.AXI4_CORE_PLAYER;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
architecture MODEL of AXI4_SLAVE_PLAYER is
begin
    -------------------------------------------------------------------------------
    --! @brief AXI4_CORE_PLAYER
    -------------------------------------------------------------------------------
    CORE: AXI4_CORE_PLAYER 
        ---------------------------------------------------------------------------
        -- ジェネリック変数.
        ---------------------------------------------------------------------------
        generic map(
            SCENARIO_FILE   => SCENARIO_FILE,
            MASTER          => FALSE,
            SLAVE           => TRUE,
            NAME            => NAME,
            OUTPUT_DELAY    => OUTPUT_DELAY,
            AXI4_ID_WIDTH   => AXI4_ID_WIDTH,
            AXI4_A_WIDTH    => AXI4_A_WIDTH,
            AXI4_W_WIDTH    => AXI4_W_WIDTH,
            AXI4_R_WIDTH    => AXI4_R_WIDTH,
            SYNC_PLUG_NUM   => SYNC_PLUG_NUM,
            SYNC_WIDTH      => SYNC_WIDTH,
            FINISH_ABORT    => FINISH_ABORT
        )
        --------------------------------------------------------------------------
        -- 入出力ポート.
        --------------------------------------------------------------------------
        port map(
            ----------------------------------------------------------------------
            -- グローバルシグナル.
            ----------------------------------------------------------------------
            ACLK            => ACLK     ,  -- In  :
            ARESETn         => ARESETn  ,  -- In  :
            ----------------------------------------------------------------------
            -- アドレスチャネルシグナル.
            ----------------------------------------------------------------------
            AVALID_I        => AVALID   ,  -- In  :
            AVALID_O        => open     ,  -- Out :
            ADDR_I          => ADDR     ,  -- In  :
            ADDR_O          => open     ,  -- Out :
            AWRITE_I        => AWRITE   ,  -- In  :
            AWRITE_O        => open     ,  -- Out :
            ALEN_I          => ALEN     ,  -- In  :
            ALEN_O          => open     ,  -- Out :
            ASIZE_I         => ASIZE    ,  -- In  :
            ASIZE_O         => open     ,  -- Out :
            ABURST_I        => ABURST   ,  -- In  :
            ABURST_O        => open     ,  -- Out :
            ALOCK_I         => ALOCK    ,  -- In  :
            ALOCK_O         => open     ,  -- Out :
            ACACHE_I        => ACACHE   ,  -- In  :
            ACACHE_O        => open     ,  -- Out :
            APROT_I         => APROT    ,  -- In  :
            APROT_O         => open     ,  -- Out :
            AID_I           => AID      ,  -- In  :
            AID_O           => open     ,  -- Out :
            AREADY_I        => AREADY   ,  -- In  :
            AREADY_O        => AREADY   ,  -- Out :
            ----------------------------------------------------------------------
            -- リードチャネルシグナル.
            ----------------------------------------------------------------------
            RVALID_I        => RVALID   ,  -- In  :
            RVALID_O        => RVALID   ,  -- Out :
            RLAST_I         => RLAST    ,  -- In  :
            RLAST_O         => RLAST    ,  -- Out :
            RDATA_I         => RDATA    ,  -- In  :
            RDATA_O         => RDATA    ,  -- Out :
            RRESP_I         => RRESP    ,  -- In  :
            RRESP_O         => RRESP    ,  -- Out :
            RID_I           => RID      ,  -- In  :
            RID_O           => RID      ,  -- Out :
            RREADY_I        => RREADY   ,  -- In  :
            RREADY_O        => open     ,  -- Out :
            ----------------------------------------------------------------------
            -- ライトチャネルシグナル.
            ----------------------------------------------------------------------
            WVALID_I        => WVALID   ,  -- In  :
            WVALID_O        => open     ,  -- Out :
            WLAST_I         => WLAST    ,  -- In  :
            WLAST_O         => open     ,  -- Out :
            WDATA_I         => WDATA    ,  -- In  :
            WDATA_O         => open     ,  -- Out :
            WSTRB_I         => WSTRB    ,  -- In  :
            WSTRB_O         => open     ,  -- Out :
            WID_I           => WID      ,  -- In  :
            WID_O           => open     ,  -- Out :
            WREADY_I        => WREADY   ,  -- In  :
            WREADY_O        => WREADY   ,  -- Out :
            ----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            ----------------------------------------------------------------------
            BVALID_I        => BVALID   ,  -- In  :
            BVALID_O        => BVALID   ,  -- Out :
            BRESP_I         => BRESP    ,  -- In  :
            BRESP_O         => BRESP    ,  -- Out :
            BID_I           => BID      ,  -- In  :
            BID_O           => BID      ,  -- Out :
            BREADY_I        => BREADY   ,  -- In  :
            BREADY_O        => open     ,  -- Out :
            ----------------------------------------------------------------------
            -- シンクロ用信号
            ----------------------------------------------------------------------
            SYNC            => SYNC     ,  -- I/O :
            FINISH          => FINISH      -- Out :
        );
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
