-----------------------------------------------------------------------------------
--!     @file    axi4_master_player.vhd
--!     @brief   AXI4 Master Dummy Plug Player.
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
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_CORE.AXI4_CORE_PLAYER;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
architecture MODEL of AXI4_MASTER_PLAYER is
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
            MASTER          => TRUE,
            SLAVE           => FALSE,
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
            AVALID_O        => AVALID   ,  -- Out :
            ADDR_I          => ADDR     ,  -- In  :
            ADDR_O          => ADDR     ,  -- Out :
            AWRITE_I        => AWRITE   ,  -- In  :
            AWRITE_O        => AWRITE   ,  -- Out :
            ALEN_I          => ALEN     ,  -- In  :
            ALEN_O          => ALEN     ,  -- Out :
            ASIZE_I         => ASIZE    ,  -- In  :
            ASIZE_O         => ASIZE    ,  -- Out :
            ABURST_I        => ABURST   ,  -- In  :
            ABURST_O        => ABURST   ,  -- Out :
            ALOCK_I         => ALOCK    ,  -- In  :
            ALOCK_O         => ALOCK    ,  -- Out :
            ACACHE_I        => ACACHE   ,  -- In  :
            ACACHE_O        => ACACHE   ,  -- Out :
            APROT_I         => APROT    ,  -- In  :
            APROT_O         => APROT    ,  -- Out :
            AID_I           => AID      ,  -- In  :
            AID_O           => AID      ,  -- Out :
            AREADY_I        => AREADY   ,  -- In  :
            AREADY_O        => open     ,  -- Out :
            ----------------------------------------------------------------------
            -- リードチャネルシグナル.
            ----------------------------------------------------------------------
            RVALID_I        => RVALID   ,  -- In  :
            RVALID_O        => open     ,  -- Out :
            RLAST_I         => RLAST    ,  -- In  :
            RLAST_O         => open     ,  -- Out :
            RDATA_I         => RDATA    ,  -- In  :
            RDATA_O         => open     ,  -- Out :
            RRESP_I         => RRESP    ,  -- In  :
            RRESP_O         => open     ,  -- Out :
            RID_I           => RID      ,  -- In  :
            RID_O           => open     ,  -- Out :
            RREADY_I        => RREADY   ,  -- In  :
            RREADY_O        => RREADY   ,  -- Out :
            ----------------------------------------------------------------------
            -- ライトチャネルシグナル.
            ----------------------------------------------------------------------
            WVALID_I        => WVALID   ,  -- In  :
            WVALID_O        => WVALID   ,  -- Out :
            WLAST_I         => WLAST    ,  -- In  :
            WLAST_O         => WLAST    ,  -- Out :
            WDATA_I         => WDATA    ,  -- In  :
            WDATA_O         => WDATA    ,  -- Out :
            WSTRB_I         => WSTRB    ,  -- In  :
            WSTRB_O         => WSTRB    ,  -- Out :
            WID_I           => WID      ,  -- In  :
            WID_O           => WID      ,  -- Out :
            WREADY_I        => WREADY   ,  -- In  :
            WREADY_O        => open     ,  -- Out :
            ----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            ----------------------------------------------------------------------
            BVALID_I        => BVALID   ,  -- In  :
            BVALID_O        => open     ,  -- Out :
            BRESP_I         => BRESP    ,  -- In  :
            BRESP_O         => open     ,  -- Out :
            BID_I           => BID      ,  -- In  :
            BID_O           => open     ,  -- Out :
            BREADY_I        => BREADY   ,  -- In  :
            BREADY_O        => BREADY   ,  -- Out :
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
