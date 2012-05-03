-----------------------------------------------------------------------------------
--!     @file    axi4_models.vhd
--!     @brief   AXI4 Dummy Plug Component Package.
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
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.SYNC.all;
-----------------------------------------------------------------------------------
--! @brief AXI4 Master/Slave Bus Function Model Package.
-----------------------------------------------------------------------------------
package AXI4_MODELS is

-----------------------------------------------------------------------------------
--! @brief   AXI4_MASTER_PLAYER :
-----------------------------------------------------------------------------------
component  AXI4_MASTER_PLAYER
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
end component;

-----------------------------------------------------------------------------------
--! @brief   AXI4_SLAVE_PLAYER :
-----------------------------------------------------------------------------------
component  AXI4_SLAVE_PLAYER
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
        SYNC_PLUG_NUM   : --! @brief シンクロ用信号のチャネル番号.
                          SYNC_PLUG_NUM_TYPE := 1;
        SYNC_WIDTH      : --! @brief シンクロ用信号のビット幅.
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
end component;
component AXI4_SIGNAL_PRINTER
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        NAME            : --! @brief 固有名詞.
                          STRING;
        TAG             : --!
                          STRING;
        TAG_WIDTH       : --! @brief タグを出力する際の文字幅.
                          --!      * TAG_WIDTH>0 =>  TAG_WIDTH幅の右詰.
                          --!      * TAG_WIDTH<0 => -TAG_WIDTH幅の左詰.
                          --!      * TAG_WIDTH=0 => 出力しない.
                          integer := 13;
        TIME_WIDTH      : --! @brief 時間を出力する際の文字幅.
                          --!      * TIME_WIDTH>0 =>  TAG_WIDTH幅の右詰.
                          --!      * TIME_WIDTH<0 => -TAG_WIDTH幅の左詰.
                          --!      * TIEM_WIDTH=0 => 出力しない.
                          integer := 13;
        AXI4_ID_WIDTH   : --! @brief AXI4 IS WIDTH :
                          integer :=  4;
        AXI4_A_WIDTH    : --! @brief AXI4 ADDR WIDTH :
                          integer := 32;
        AXI4_W_WIDTH    : --! @brief AXI4 WRITE DATA WIDTH :
                          integer := 32;
        AXI4_R_WIDTH    : --! @brief AXI4 READ DATA WIDTH :
                          integer := 32
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
        AREADY          : in    std_logic;
        --------------------------------------------------------------------------
        -- リードチャネルシグナル.
        --------------------------------------------------------------------------
        RVALID          : in    std_logic;
        RLAST           : in    std_logic;
        RDATA           : in    std_logic_vector(AXI4_R_WIDTH   -1 downto 0);
        RRESP           : in    AXI4_RESP_TYPE;
        RID             : in    std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
        RREADY          : in    std_logic;
        --------------------------------------------------------------------------
        -- ライトチャネルシグナル.
        --------------------------------------------------------------------------
        WVALID          : in    std_logic;
        WLAST           : in    std_logic;
        WDATA           : in    std_logic_vector(AXI4_W_WIDTH   -1 downto 0);
        WSTRB           : in    std_logic_vector(AXI4_W_WIDTH/8 -1 downto 0);
        WID             : in    std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
        WREADY          : in    std_logic;
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
        BVALID          : in    std_logic;
        BRESP           : in    AXI4_RESP_TYPE;
        BID             : in    std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
        BREADY          : in    std_logic
    );
end component;
end package;
