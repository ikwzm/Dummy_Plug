-----------------------------------------------------------------------------------
--!     @file    axi4_core.vhd
--!     @brief   AXI4 Dummy Plug Core Package.
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
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.CORE;
use     DUMMY_PLUG.SYNC;
use     DUMMY_PLUG.READER;
-----------------------------------------------------------------------------------
--! @brief AXI4 Dummy Plug のコアパッケージ.
-----------------------------------------------------------------------------------
package AXI4_CORE is
    -------------------------------------------------------------------------------
    --! @brief AXI4 チャネルのタイプ.
    -------------------------------------------------------------------------------
    type      AXI4_CHANNEL_TYPE is (
        AXI4_CHANNEL_AR,
        AXI4_CHANNEL_AW,
        AXI4_CHANNEL_R,
        AXI4_CHANNEL_W,
        AXI4_CHANNEL_B,
        AXI4_CHANNEL_M
    );
    -------------------------------------------------------------------------------
    --! @brief AXI4 ID の最大ビット幅
    -------------------------------------------------------------------------------
    constant  AXI4_ID_MAX_WIDTH : integer := 8;
    -------------------------------------------------------------------------------
    --! @brief AXI4 ADDR の最大ビット幅
    -------------------------------------------------------------------------------
    constant  AXI4_ADDR_MAX_WIDTH   : integer := 64;
    -------------------------------------------------------------------------------
    --! @brief AXI4 DATA の最大ビット幅
    -------------------------------------------------------------------------------
    constant  AXI4_DATA_MAX_WIDTH  : integer := 128;
    -------------------------------------------------------------------------------
    --! @brief AXI4 WSTRB の最大ビット幅
    -------------------------------------------------------------------------------
    constant  AXI4_STRB_MAX_WIDTH  : integer := AXI4_DATA_MAX_WIDTH/8;
    -------------------------------------------------------------------------------
    --! @brief AXI4 USER の最大ビット幅
    -------------------------------------------------------------------------------
    constant  AXI4_USER_MAX_WIDTH  : integer := 32;
    -------------------------------------------------------------------------------
    --! @brief AXI4 アドレスチャネル信号の構造体
    -------------------------------------------------------------------------------
    type      AXI4_A_CHANNEL_SIGNAL_TYPE is record
        ADDR     : std_logic_vector(AXI4_ADDR_MAX_WIDTH -1 downto 0);
        WRITE    : std_logic;
        LEN      : AXI4_ALEN_TYPE;
        SIZE     : AXI4_ASIZE_TYPE;
        BURST    : AXI4_ABURST_TYPE;
        LOCK     : AXI4_ALOCK_TYPE;
        CACHE    : AXI4_ACACHE_TYPE;
        PROT     : AXI4_APROT_TYPE;
        QOS      : AXI4_AQOS_TYPE;
        REGION   : AXI4_AREGION_TYPE;
        USER     : std_logic_vector(AXI4_USER_MAX_WIDTH -1 downto 0);
        ID       : std_logic_vector(AXI4_ID_MAX_WIDTH   -1 downto 0);
        VALID    : std_logic;
        READY    : std_logic;
    end record;
    constant  AXI4_A_CHANNEL_SIGNAL_DONTCARE : AXI4_A_CHANNEL_SIGNAL_TYPE := (
        ADDR    => (others => '-'),
        WRITE   => '-',
        LEN     => (others => '-'),
        SIZE    => (others => '-'),
        BURST   => (others => '-'),
        LOCK    => (others => '-'),
        CACHE   => (others => '-'),
        PROT    => (others => '-'),
        QOS     => (others => '-'),
        REGION  => (others => '-'),
        USER    => (others => '-'),
        ID      => (others => '-'),
        VALID   => '-',
        READY   => '-'
    );
    constant  AXI4_A_CHANNEL_SIGNAL_NULL     : AXI4_A_CHANNEL_SIGNAL_TYPE := (
        ADDR    => (others => '0'),
        WRITE   => '0',
        LEN     => (others => '0'),
        SIZE    => (others => '0'),
        BURST   => (others => '0'),
        LOCK    => (others => '0'),
        CACHE   => (others => '0'),
        PROT    => (others => '0'),
        QOS     => (others => '0'),
        REGION  => (others => '0'),
        USER    => (others => '0'),
        ID      => (others => '0'),
        VALID   => '0',
        READY   => '0'
    );
    -------------------------------------------------------------------------------
    --! @brief AXI4 リードチャネル信号の構造体
    -------------------------------------------------------------------------------
    type      AXI4_R_CHANNEL_SIGNAL_TYPE is record
        DATA     : std_logic_vector(AXI4_DATA_MAX_WIDTH-1 downto 0);
        RESP     : AXI4_RESP_TYPE;
        LAST     : std_logic;
        USER     : std_logic_vector(AXI4_USER_MAX_WIDTH-1 downto 0);
        ID       : std_logic_vector(AXI4_ID_MAX_WIDTH  -1 downto 0);
        VALID    : std_logic;
        READY    : std_logic;
    end record;
    constant  AXI4_R_CHANNEL_SIGNAL_DONTCARE : AXI4_R_CHANNEL_SIGNAL_TYPE := (
        DATA    => (others => '-'),
        RESP    => (others => '-'),
        LAST    => '-',
        USER    => (others => '-'),
        ID      => (others => '-'),
        VALID   => '-',
        READY   => '-'
    );        
    constant  AXI4_R_CHANNEL_SIGNAL_NULL     : AXI4_R_CHANNEL_SIGNAL_TYPE := (
        DATA    => (others => '0'),
        RESP    => (others => '0'),
        LAST    => '0',
        USER    => (others => '0'),
        ID      => (others => '0'),
        VALID   => '0',
        READY   => '0'
    );        
    -------------------------------------------------------------------------------
    --! @brief AXI4 ライトチャネル信号の構造体
    -------------------------------------------------------------------------------
    type      AXI4_W_CHANNEL_SIGNAL_TYPE is record
        DATA     : std_logic_vector(AXI4_DATA_MAX_WIDTH-1 downto 0);
        LAST     : std_logic;
        STRB     : std_logic_vector(AXI4_STRB_MAX_WIDTH-1 downto 0);
        USER     : std_logic_vector(AXI4_USER_MAX_WIDTH-1 downto 0);
        ID       : std_logic_vector(AXI4_ID_MAX_WIDTH  -1 downto 0);
        VALID    : std_logic;
        READY    : std_logic;
    end record;
    constant  AXI4_W_CHANNEL_SIGNAL_DONTCARE : AXI4_W_CHANNEL_SIGNAL_TYPE := (
        DATA    => (others => '-'),
        LAST    => '-',
        STRB    => (others => '-'),
        USER    => (others => '-'),
        ID      => (others => '-'),
        VALID   => '-',
        READY   => '-'
    );        
    constant  AXI4_W_CHANNEL_SIGNAL_NULL     : AXI4_W_CHANNEL_SIGNAL_TYPE := (
        DATA    => (others => '0'),
        LAST    => '0',
        STRB    => (others => '0'),
        USER    => (others => '0'),
        ID      => (others => '0'),
        VALID   => '0',
        READY   => '0'
    );        
    -------------------------------------------------------------------------------
    --! @brief AXI4 ライト応答チャネル信号の構造体
    -------------------------------------------------------------------------------
    type      AXI4_B_CHANNEL_SIGNAL_TYPE is record
        RESP     : AXI4_RESP_TYPE;
        USER     : std_logic_vector(AXI4_USER_MAX_WIDTH-1 downto 0);
        ID       : std_logic_vector(AXI4_ID_MAX_WIDTH  -1 downto 0);
        VALID    : std_logic;
        READY    : std_logic;
    end record;
    constant  AXI4_B_CHANNEL_SIGNAL_DONTCARE : AXI4_B_CHANNEL_SIGNAL_TYPE := (
        RESP    => (others => '-'),
        ID      => (others => '-'),
        USER    => (others => '-'),
        VALID   => '-',
        READY   => '-'
    );        
    constant  AXI4_B_CHANNEL_SIGNAL_NULL     : AXI4_B_CHANNEL_SIGNAL_TYPE := (
        RESP    => (others => '0'),
        USER    => (others => '0'),
        ID      => (others => '0'),
        VALID   => '0',
        READY   => '0'
    );        
    -------------------------------------------------------------------------------
    --! @brief AXI4 チャネル信号の構造体
    -------------------------------------------------------------------------------
    type      AXI4_CHANNEL_SIGNAL_TYPE is record
        AR       : AXI4_A_CHANNEL_SIGNAL_TYPE;
        R        : AXI4_R_CHANNEL_SIGNAL_TYPE;
        AW       : AXI4_A_CHANNEL_SIGNAL_TYPE;
        W        : AXI4_W_CHANNEL_SIGNAL_TYPE;
        B        : AXI4_B_CHANNEL_SIGNAL_TYPE;
    end record;
    constant  AXI4_CHANNEL_SIGNAL_DONTCARE : AXI4_CHANNEL_SIGNAL_TYPE := (
        AR      => AXI4_A_CHANNEL_SIGNAL_DONTCARE,
        R       => AXI4_R_CHANNEL_SIGNAL_DONTCARE,
        AW      => AXI4_A_CHANNEL_SIGNAL_DONTCARE,
        W       => AXI4_W_CHANNEL_SIGNAL_DONTCARE,
        B       => AXI4_B_CHANNEL_SIGNAL_DONTCARE
    );
    constant  AXI4_CHANNEL_SIGNAL_NULL     : AXI4_CHANNEL_SIGNAL_TYPE := (
        AR      => AXI4_A_CHANNEL_SIGNAL_NULL,
        R       => AXI4_R_CHANNEL_SIGNAL_NULL,
        AW      => AXI4_A_CHANNEL_SIGNAL_NULL,
        W       => AXI4_W_CHANNEL_SIGNAL_NULL,
        B       => AXI4_B_CHANNEL_SIGNAL_NULL
    );
    -------------------------------------------------------------------------------
    --! @brief READERのマップからチャネル信号の構造体を読み取るサブプログラム.
    -------------------------------------------------------------------------------
    procedure READ_AXI4_CHANNEL(
        variable SELF       : inout CORE.CORE_TYPE;       --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 CHANNEL    : in    AXI4_CHANNEL_TYPE;    --! チャネルのタイプ.
                 READ       : in    boolean;              --! リード可/不可を指定.
                 WRITE      : in    boolean;              --! ライト可/不可を指定.
                 WIDTH      : in    AXI4_SIGNAL_WIDTH_TYPE;
                 SIGNALS    : inout AXI4_CHANNEL_SIGNAL_TYPE;
                 CURR_EVENT : out   READER.EVENT_TYPE
    );
    -------------------------------------------------------------------------------
    --! @brief 構造体の値と信号を比較するサブプログラム.
    -------------------------------------------------------------------------------
    procedure MATCH_AXI4_CHANNEL(
                 SIGNALS    : in    AXI4_CHANNEL_SIGNAL_TYPE;
                 READ       : in    boolean;
                 WRITE      : in    boolean;
                 MATCH      : out   boolean;
        signal   ARADDR     : in    std_logic_vector;
        signal   ARLEN      : in    AXI4_ALEN_TYPE;
        signal   ARSIZE     : in    AXI4_ASIZE_TYPE;
        signal   ARBURST    : in    AXI4_ABURST_TYPE;
        signal   ARLOCK     : in    AXI4_ALOCK_TYPE;
        signal   ARCACHE    : in    AXI4_ACACHE_TYPE;
        signal   ARPROT     : in    AXI4_APROT_TYPE;
        signal   ARQOS      : in    AXI4_AQOS_TYPE;
        signal   ARREGION   : in    AXI4_AREGION_TYPE;
        signal   ARUSER     : in    std_logic_vector;
        signal   ARID       : in    std_logic_vector;
        signal   ARVALID    : in    std_logic;
        signal   ARREADY    : in    std_logic;
        signal   AWADDR     : in    std_logic_vector;
        signal   AWLEN      : in    AXI4_ALEN_TYPE;
        signal   AWSIZE     : in    AXI4_ASIZE_TYPE;
        signal   AWBURST    : in    AXI4_ABURST_TYPE;
        signal   AWLOCK     : in    AXI4_ALOCK_TYPE;
        signal   AWCACHE    : in    AXI4_ACACHE_TYPE;
        signal   AWPROT     : in    AXI4_APROT_TYPE;
        signal   AWQOS      : in    AXI4_AQOS_TYPE;
        signal   AWREGION   : in    AXI4_AREGION_TYPE;
        signal   AWUSER     : in    std_logic_vector;
        signal   AWID       : in    std_logic_vector;
        signal   AWVALID    : in    std_logic;
        signal   AWREADY    : in    std_logic;
        signal   RLAST      : in    std_logic;
        signal   RDATA      : in    std_logic_vector;
        signal   RRESP      : in    AXI4_RESP_TYPE;
        signal   RUSER      : in    std_logic_vector;
        signal   RID        : in    std_logic_vector;
        signal   RVALID     : in    std_logic;
        signal   RREADY     : in    std_logic;
        signal   WLAST      : in    std_logic;
        signal   WDATA      : in    std_logic_vector;
        signal   WSTRB      : in    std_logic_vector;
        signal   WUSER      : in    std_logic_vector;
        signal   WID        : in    std_logic_vector;
        signal   WVALID     : in    std_logic;
        signal   WREADY     : in    std_logic;
        signal   BRESP      : in    AXI4_RESP_TYPE;
        signal   BUSER      : in    std_logic_vector;
        signal   BID        : in    std_logic_vector;
        signal   BVALID     : in    std_logic;
        signal   BREADY     : in    std_logic
    );
    -------------------------------------------------------------------------------
    --! @brief 構造体の値と信号を比較するサブプログラム.
    -------------------------------------------------------------------------------
    procedure MATCH_AXI4_CHANNEL(
        variable SELF       : inout CORE.CORE_TYPE;
                 SIGNALS    : in    AXI4_CHANNEL_SIGNAL_TYPE;
                 READ       : in    boolean;
                 WRITE      : in    boolean;
                 MATCH      : out   boolean;
        signal   ARADDR     : in    std_logic_vector;
        signal   ARLEN      : in    AXI4_ALEN_TYPE;
        signal   ARSIZE     : in    AXI4_ASIZE_TYPE;
        signal   ARBURST    : in    AXI4_ABURST_TYPE;
        signal   ARLOCK     : in    AXI4_ALOCK_TYPE;
        signal   ARCACHE    : in    AXI4_ACACHE_TYPE;
        signal   ARPROT     : in    AXI4_APROT_TYPE;
        signal   ARQOS      : in    AXI4_AQOS_TYPE;
        signal   ARREGION   : in    AXI4_AREGION_TYPE;
        signal   ARUSER     : in    std_logic_vector;
        signal   ARID       : in    std_logic_vector;
        signal   ARVALID    : in    std_logic;
        signal   ARREADY    : in    std_logic;
        signal   AWADDR     : in    std_logic_vector;
        signal   AWLEN      : in    AXI4_ALEN_TYPE;
        signal   AWSIZE     : in    AXI4_ASIZE_TYPE;
        signal   AWBURST    : in    AXI4_ABURST_TYPE;
        signal   AWLOCK     : in    AXI4_ALOCK_TYPE;
        signal   AWCACHE    : in    AXI4_ACACHE_TYPE;
        signal   AWPROT     : in    AXI4_APROT_TYPE;
        signal   AWQOS      : in    AXI4_AQOS_TYPE;
        signal   AWREGION   : in    AXI4_AREGION_TYPE;
        signal   AWUSER     : in    std_logic_vector;
        signal   AWID       : in    std_logic_vector;
        signal   AWVALID    : in    std_logic;
        signal   AWREADY    : in    std_logic;
        signal   RLAST      : in    std_logic;
        signal   RDATA      : in    std_logic_vector;
        signal   RRESP      : in    AXI4_RESP_TYPE;
        signal   RUSER      : in    std_logic_vector;
        signal   RID        : in    std_logic_vector;
        signal   RVALID     : in    std_logic;
        signal   RREADY     : in    std_logic;
        signal   WLAST      : in    std_logic;
        signal   WDATA      : in    std_logic_vector;
        signal   WSTRB      : in    std_logic_vector;
        signal   WUSER      : in    std_logic_vector;
        signal   WID        : in    std_logic_vector;
        signal   WVALID     : in    std_logic;
        signal   WREADY     : in    std_logic;
        signal   BRESP      : in    AXI4_RESP_TYPE;
        signal   BUSER      : in    std_logic_vector;
        signal   BID        : in    std_logic_vector;
        signal   BVALID     : in    std_logic;
        signal   BREADY     : in    std_logic
    );
    -------------------------------------------------------------------------------
    --! @brief AXI4_CORE_PLAYER
    -------------------------------------------------------------------------------
    component AXI4_CORE_PLAYER is
        ---------------------------------------------------------------------------
        -- ジェネリック変数.
        ---------------------------------------------------------------------------
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
                              time;
            WIDTH           : --! @brief AXI4 IS WIDTH :
                              AXI4_SIGNAL_WIDTH_TYPE;
            SYNC_PLUG_NUM   : --! @brief シンクロ用信号のプラグ番号.
                              SYNC.SYNC_PLUG_NUM_TYPE := 1;
            SYNC_WIDTH      : --! @brief シンクロ用信号の本数.
                              integer :=  1;
            FINISH_ABORT    : --! @brief FINISH コマンド実行時にシミュレーションを
                              --!        アボートするかどうかを指定するフラグ.
                              boolean := true
        );
        --------------------------------------------------------------------------
        -- 入出力ポートの定義.
        --------------------------------------------------------------------------
        port(
            ----------------------------------------------------------------------
            -- グローバルシグナル.
            ----------------------------------------------------------------------
            ACLK            : in    std_logic;
            ARESETn         : in    std_logic;
            ----------------------------------------------------------------------
            -- リードアドレスチャネルシグナル.
            ----------------------------------------------------------------------
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
            ----------------------------------------------------------------------
            -- リードデータチャネルシグナル.
            ----------------------------------------------------------------------
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
            ----------------------------------------------------------------------
            -- ライトアドレスチャネルシグナル.
            ----------------------------------------------------------------------
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
            ----------------------------------------------------------------------
            -- ライトデータチャネルシグナル.
            ----------------------------------------------------------------------
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
            ----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            ----------------------------------------------------------------------
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
            ----------------------------------------------------------------------
            -- シンクロ用信号
            ----------------------------------------------------------------------
            SYNC            : inout SYNC.SYNC_SIG_VECTOR(SYNC_WIDTH-1 downto 0);
            FINISH          : out   std_logic
        );
    end component;
    -------------------------------------------------------------------------------
    --! @brief AXI4_CHANNEL_PLAYER
    -------------------------------------------------------------------------------
    component  AXI4_CHANNEL_PLAYER is
        ---------------------------------------------------------------------------
        -- ジェネリック変数.
        ---------------------------------------------------------------------------
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
            FINISH_ABORT    : --! @brief FINISH コマンド実行時にシミュレーションを
                              --!        アボートするかどうかを指定するフラグ.
                              boolean := true
        );
        --------------------------------------------------------------------------
        -- 入出力ポートの定義.
        --------------------------------------------------------------------------
        port(
            ----------------------------------------------------------------------
            -- グローバルシグナル.
            ----------------------------------------------------------------------
            ACLK            : in    std_logic;
            ARESETn         : in    std_logic;
            ----------------------------------------------------------------------
            -- リードアドレスチャネルシグナル.
            ----------------------------------------------------------------------
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
            ----------------------------------------------------------------------
            -- リードデータチャネルシグナル.
            ----------------------------------------------------------------------
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
            ----------------------------------------------------------------------
            -- ライトアドレスチャネルシグナル.
            ----------------------------------------------------------------------
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
            ----------------------------------------------------------------------
            -- ライトデータチャネルシグナル.
            ----------------------------------------------------------------------
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
            ----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            ----------------------------------------------------------------------
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
            -----------------------------------------------------------------------
            -- シンクロ用信号
            -----------------------------------------------------------------------
            SYNC_REQ        : out   SYNC.SYNC_REQ_VECTOR(SYNC_WIDTH-1 downto 0);
            SYNC_ACK        : in    SYNC.SYNC_ACK_VECTOR(SYNC_WIDTH-1 downto 0) := (others => '0');
            SYNC_LOCAL_REQ  : out   SYNC.SYNC_REQ_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT);
            SYNC_LOCAL_ACK  : in    SYNC.SYNC_ACK_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT);
            FINISH          : out   std_logic
        );
    end component;
end     AXI4_CORE;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.CORE.all;
use     DUMMY_PLUG.READER.all;
use     DUMMY_PLUG.VOCAL.all;
use     DUMMY_PLUG.UTIL.STRING_TO_STD_LOGIC_VECTOR;
use     DUMMY_PLUG.UTIL.MATCH_STD_LOGIC;
use     DUMMY_PLUG.UTIL.BIN_TO_STRING;
use     DUMMY_PLUG.UTIL.HEX_TO_STRING;
-----------------------------------------------------------------------------------
--! @brief AXI4 Dummy Plug のコアパッケージ本体.
-----------------------------------------------------------------------------------
package body AXI4_CORE is
    -------------------------------------------------------------------------------
    --! @brief 信号名の定義.
    -------------------------------------------------------------------------------
    subtype   KEY_TYPE     is STRING(1 to 7);

    constant  KEY_ADDR      : KEY_TYPE := "ADDR   ";
    constant  KEY_WRITE     : KEY_TYPE := "WRITE  ";
    constant  KEY_LEN       : KEY_TYPE := "LEN    ";
    constant  KEY_SIZE      : KEY_TYPE := "SIZE   ";
    constant  KEY_BURST     : KEY_TYPE := "BURST  ";
    constant  KEY_LOCK      : KEY_TYPE := "LOCK   ";
    constant  KEY_CACHE     : KEY_TYPE := "CACHE  ";
    constant  KEY_PROT      : KEY_TYPE := "PROT   ";
    constant  KEY_QOS       : KEY_TYPE := "QOS    ";
    constant  KEY_REGION    : KEY_TYPE := "REGION ";
    constant  KEY_USER      : KEY_TYPE := "USER   ";
    constant  KEY_ID        : KEY_TYPE := "ID     ";
    constant  KEY_DATA      : KEY_TYPE := "DATA   ";
    constant  KEY_RESP      : KEY_TYPE := "RESP   ";
    constant  KEY_LAST      : KEY_TYPE := "LAST   ";
    constant  KEY_STRB      : KEY_TYPE := "STRB   ";
    constant  KEY_VALID     : KEY_TYPE := "VALID  ";
    constant  KEY_READY     : KEY_TYPE := "READY  ";

    constant  KEY_AWRITE    : KEY_TYPE := "AWRITE ";
    constant  KEY_ALEN      : KEY_TYPE := "ALEN   ";
    constant  KEY_ASIZE     : KEY_TYPE := "ASIZE  ";
    constant  KEY_ABURST    : KEY_TYPE := "ABURST ";
    constant  KEY_ALOCK     : KEY_TYPE := "ALOCK  ";
    constant  KEY_ACACHE    : KEY_TYPE := "ACACHE ";
    constant  KEY_APROT     : KEY_TYPE := "APROT  ";
    constant  KEY_AQOS      : KEY_TYPE := "AQOS   ";
    constant  KEY_AREGION   : KEY_TYPE := "AREGION";
    constant  KEY_AUSER     : KEY_TYPE := "AUSER  ";
    constant  KEY_AID       : KEY_TYPE := "AID    ";
    constant  KEY_AVALID    : KEY_TYPE := "AVALID ";
    constant  KEY_AREADY    : KEY_TYPE := "AREADY ";
    
    constant  KEY_AWADDR    : KEY_TYPE := "AWADDR ";
    constant  KEY_AWLEN     : KEY_TYPE := "AWLEN  ";
    constant  KEY_AWSIZE    : KEY_TYPE := "AWSIZE ";
    constant  KEY_AWBURST   : KEY_TYPE := "AWBURST";
    constant  KEY_AWLOCK    : KEY_TYPE := "AWLOCK ";
    constant  KEY_AWCACHE   : KEY_TYPE := "AWCACHE";
    constant  KEY_AWPROT    : KEY_TYPE := "AWPROT ";
    constant  KEY_AWQOS     : KEY_TYPE := "AWQOS  ";
    constant  KEY_AWUSER    : KEY_TYPE := "AWUSER ";
    constant  KEY_AWREGION  : KEY_TYPE := "AWREGIO";
    constant  KEY_AWID      : KEY_TYPE := "AWID   ";
    constant  KEY_AWVALID   : KEY_TYPE := "AWVALID";
    constant  KEY_AWREADY   : KEY_TYPE := "AWREADY";
    
    constant  KEY_ARADDR    : KEY_TYPE := "ARADDR ";
    constant  KEY_ARLEN     : KEY_TYPE := "ARLEN  ";
    constant  KEY_ARSIZE    : KEY_TYPE := "ARSIZE ";
    constant  KEY_ARBURST   : KEY_TYPE := "ARBURST";
    constant  KEY_ARLOCK    : KEY_TYPE := "ARLOCK ";
    constant  KEY_ARCACHE   : KEY_TYPE := "ARCACHE";
    constant  KEY_ARPROT    : KEY_TYPE := "ARPROT ";
    constant  KEY_ARQOS     : KEY_TYPE := "ARQOS  ";
    constant  KEY_ARUSER    : KEY_TYPE := "ARUSER ";
    constant  KEY_ARREGION  : KEY_TYPE := "ARREGIO";
    constant  KEY_ARID      : KEY_TYPE := "ARID   ";
    constant  KEY_ARVALID   : KEY_TYPE := "ARVALID";
    constant  KEY_ARREADY   : KEY_TYPE := "ARREADY";
    
    constant  KEY_RDATA     : KEY_TYPE := "RDATA  ";
    constant  KEY_RRESP     : KEY_TYPE := "RRESP  ";
    constant  KEY_RLAST     : KEY_TYPE := "RLAST  ";
    constant  KEY_RUSER     : KEY_TYPE := "RUSER  ";
    constant  KEY_RID       : KEY_TYPE := "RID    ";
    constant  KEY_RVALID    : KEY_TYPE := "RVALID ";
    constant  KEY_RREADY    : KEY_TYPE := "RREADY ";

    constant  KEY_WDATA     : KEY_TYPE := "WDATA  ";
    constant  KEY_WSTRB     : KEY_TYPE := "WSTRB  ";
    constant  KEY_WLAST     : KEY_TYPE := "WLAST  ";
    constant  KEY_WUSER     : KEY_TYPE := "WUSER  ";
    constant  KEY_WID       : KEY_TYPE := "WID    ";
    constant  KEY_WVALID    : KEY_TYPE := "WVALID ";
    constant  KEY_WREADY    : KEY_TYPE := "WREADY ";

    constant  KEY_BRESP     : KEY_TYPE := "BRESP  ";
    constant  KEY_BUSER     : KEY_TYPE := "BUSER  ";
    constant  KEY_BID       : KEY_TYPE := "BID    ";
    constant  KEY_BVALID    : KEY_TYPE := "BVALID ";
    constant  KEY_BREADY    : KEY_TYPE := "BREADY ";
    -------------------------------------------------------------------------------
    --! @brief READERから読み取る信号の種類を示すタイプの定義.
    -------------------------------------------------------------------------------
    type      READ_AXI4_SIGNAL_TYPE is (
              READ_NONE     ,
              READ_ARADDR   ,
              READ_ARSIZE   ,
              READ_ARLEN    ,
              READ_ARBURST  ,
              READ_ARLOCK   ,
              READ_ARCACHE  ,
              READ_ARPROT   ,
              READ_ARQOS    ,
              READ_ARREGION ,
              READ_ARUSER   ,
              READ_ARID     ,
              READ_ARVALID  ,
              READ_ARREADY  ,
              READ_AWADDR   ,
              READ_AWSIZE   ,
              READ_AWLEN    ,
              READ_AWBURST  ,
              READ_AWLOCK   ,
              READ_AWCACHE  ,
              READ_AWPROT   ,
              READ_AWQOS    ,
              READ_AWREGION ,
              READ_AWUSER   ,
              READ_AWID     ,
              READ_AWVALID  ,
              READ_AWREADY  ,
              READ_RDATA    ,
              READ_RRESP    ,
              READ_RLAST    ,
              READ_RUSER    ,
              READ_RID      ,
              READ_RVALID   ,
              READ_RREADY   ,
              READ_WDATA    ,
              READ_WSTRB    ,
              READ_WLAST    ,
              READ_WUSER    ,
              READ_WID      ,
              READ_WVALID   ,
              READ_WREADY   ,
              READ_BRESP    ,
              READ_BUSER    ,
              READ_BID      ,
              READ_BVALID   ,
              READ_BREADY   
    );
    -------------------------------------------------------------------------------
    --! @brief KEY_WORD から READ_AXI4_SIGNAL_TYPEに変換する関数.
    -------------------------------------------------------------------------------
    function  to_read_axi4_signal(
                 KEY_WORD   : KEY_TYPE;
                 CHANNEL    : AXI4_CHANNEL_TYPE;
                 R,W        : boolean
    ) return READ_AXI4_SIGNAL_TYPE is
        variable val        : READ_AXI4_SIGNAL_TYPE;
    begin
        if (W and not R) then
            case KEY_WORD is
                when KEY_ID         =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AW => return READ_AWID ;
                        when AXI4_CHANNEL_W  => return READ_WID  ;
                        when AXI4_CHANNEL_B  => return READ_BID  ;
                        when others          => null;
                    end case;
                when KEY_USER       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AW => return READ_AWUSER;
                        when AXI4_CHANNEL_W  => return READ_WUSER;
                        when AXI4_CHANNEL_B  => return READ_BUSER;
                        when others          => null;
                    end case;
                when KEY_VALID      =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AW => return READ_AWVALID;
                        when AXI4_CHANNEL_W  => return READ_WVALID;
                        when AXI4_CHANNEL_B  => return READ_BVALID;
                        when others           => null;
                    end case;
                when KEY_READY      =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AW => return READ_AWREADY;
                        when AXI4_CHANNEL_W  => return READ_WREADY;
                        when AXI4_CHANNEL_B  => return READ_BREADY;
                        when others          => null;
                    end case;
                when KEY_DATA       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_W  => return READ_WDATA;
                        when others          => null;
                    end case;
                when KEY_LAST       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_W  => return READ_WLAST;
                        when others          => null;
                    end case;
                when KEY_RESP       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_B  => return READ_BRESP;
                        when others          => null;
                    end case;
                when KEY_ADDR       => 
                    case CHANNEL is
                        when AXI4_CHANNEL_AW => return READ_AWADDR;
                        when others          => null;
                    end case;
                when KEY_LEN        =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AW => return READ_AWLEN;
                        when others          => null;
                    end case;
                when KEY_SIZE       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AW => return READ_AWSIZE;
                        when others          => null;
                    end case;
                when KEY_BURST      =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AW => return READ_AWBURST;
                        when others          => null;
                    end case;
                when KEY_LOCK       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AW => return READ_AWLOCK;
                        when others          => null;
                    end case;
                when KEY_CACHE      =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AW => return READ_AWCACHE;
                        when others          => null;
                    end case;
                when KEY_PROT       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AW => return READ_AWPROT;
                        when others          => null;
                    end case;
                when KEY_QOS        =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AW => return READ_AWQOS;
                        when others          => null;
                    end case;
                when KEY_REGION     =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AW => return READ_AWREGION;
                        when others          => null;
                    end case;
                when KEY_STRB       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_W  => return READ_WSTRB;
                        when others          => null;
                    end case;
                when KEY_AWADDR              => return READ_AWADDR;
                when KEY_AWLEN               => return READ_AWLEN;   
                when KEY_AWSIZE              => return READ_AWSIZE;  
                when KEY_AWBURST             => return READ_AWBURST; 
                when KEY_AWLOCK              => return READ_AWLOCK;  
                when KEY_AWCACHE             => return READ_AWCACHE; 
                when KEY_AWPROT              => return READ_AWPROT;  
                when KEY_AWQOS               => return READ_AWQOS;   
                when KEY_AWREGION            => return READ_AWREGION;
                when KEY_AWUSER              => return READ_AWUSER;  
                when KEY_AWID                => return READ_AWID;    
                when KEY_AWVALID             => return READ_AWVALID; 
                when KEY_AWREADY             => return READ_AWREADY; 
                when KEY_ALEN                => return READ_AWLEN;   
                when KEY_ASIZE               => return READ_AWSIZE;  
                when KEY_ABURST              => return READ_AWBURST; 
                when KEY_ALOCK               => return READ_AWLOCK;  
                when KEY_ACACHE              => return READ_AWCACHE; 
                when KEY_APROT               => return READ_AWPROT;  
                when KEY_AQOS                => return READ_AWQOS;   
                when KEY_AREGION             => return READ_AWREGION;
                when KEY_AUSER               => return READ_AWUSER;  
                when KEY_AID                 => return READ_AWID;    
                when KEY_AVALID              => return READ_AWVALID; 
                when KEY_AREADY              => return READ_AWREADY; 
                when KEY_WDATA               => return READ_WDATA;  
                when KEY_WSTRB               => return READ_WSTRB;  
                when KEY_WLAST               => return READ_WLAST;  
                when KEY_WUSER               => return READ_WUSER;  
                when KEY_WID                 => return READ_WID;    
                when KEY_WVALID              => return READ_WVALID; 
                when KEY_WREADY              => return READ_WREADY; 
                when KEY_BRESP               => return READ_BRESP;  
                when KEY_BUSER               => return READ_BUSER;  
                when KEY_BID                 => return READ_BID;    
                when KEY_BVALID              => return READ_BVALID; 
                when KEY_BREADY              => return READ_BREADY; 
                when others                  => null;
            end case;
        elsif (R and not W) then
            case KEY_WORD is
                when KEY_ID         =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARID ;
                        when AXI4_CHANNEL_R  => return READ_RID  ;
                        when others          => null;
                    end case;
                when KEY_USER       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARUSER;  
                        when AXI4_CHANNEL_R  => return READ_RUSER;
                        when others          => null;
                    end case;
                when KEY_VALID      =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARVALID; 
                        when AXI4_CHANNEL_R  => return READ_RVALID; 
                        when others          => null;
                    end case;
                when KEY_READY      =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARREADY; 
                        when AXI4_CHANNEL_R  => return READ_RREADY; 
                        when others          => null;
                    end case;
                when KEY_DATA       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_R  => return READ_RDATA;
                        when others          => null;
                    end case;
                when KEY_LAST       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_R  => return READ_RLAST;
                        when others          => null;
                    end case;
                when KEY_RESP       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_R  => return READ_RRESP;
                        when others          => null;
                    end case;
                when KEY_ADDR       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARADDR;
                        when others          => null;
                    end case;
                when KEY_LEN        =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARLEN;
                        when others          => null;
                    end case;
                when KEY_SIZE       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARSIZE;  
                        when others          => null;
                    end case;
                when KEY_BURST      =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARBURST;
                        when others          => null;
                    end case;
                when KEY_LOCK       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARLOCK;
                        when others          => null;
                    end case;
                when KEY_CACHE      =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARCACHE;
                        when others          => null;
                    end case;
                when KEY_PROT       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARPROT;
                        when others          => null;
                    end case;
                when KEY_QOS        =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARQOS;  
                        when others          => null;
                    end case;
                when KEY_REGION     =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARREGION;
                        when others          => null;
                    end case;
                when KEY_ARADDR              => return READ_ARADDR;   
                when KEY_ARLEN               => return READ_ARLEN;   
                when KEY_ARSIZE              => return READ_ARSIZE;  
                when KEY_ARBURST             => return READ_ARBURST; 
                when KEY_ARLOCK              => return READ_ARLOCK;  
                when KEY_ARCACHE             => return READ_ARCACHE; 
                when KEY_ARPROT              => return READ_ARPROT;  
                when KEY_ARQOS               => return READ_ARQOS;   
                when KEY_ARREGION            => return READ_ARREGION;
                when KEY_ARUSER              => return READ_ARUSER;  
                when KEY_ARID                => return READ_ARID;    
                when KEY_ARVALID             => return READ_ARVALID; 
                when KEY_ARREADY             => return READ_ARREADY;
                when KEY_ALEN                => return READ_ARLEN;   
                when KEY_ASIZE               => return READ_ARSIZE;  
                when KEY_ABURST              => return READ_ARBURST; 
                when KEY_ALOCK               => return READ_ARLOCK;  
                when KEY_ACACHE              => return READ_ARCACHE; 
                when KEY_APROT               => return READ_ARPROT;  
                when KEY_AQOS                => return READ_ARQOS;   
                when KEY_AREGION             => return READ_ARREGION;
                when KEY_AUSER               => return READ_ARUSER;  
                when KEY_AID                 => return READ_ARID;    
                when KEY_AVALID              => return READ_ARVALID; 
                when KEY_AREADY              => return READ_ARREADY; 
                when KEY_RDATA               => return READ_RDATA;  
                when KEY_RRESP               => return READ_RRESP;  
                when KEY_RLAST               => return READ_RLAST;  
                when KEY_RUSER               => return READ_RUSER;  
                when KEY_RID                 => return READ_RID;    
                when KEY_RVALID              => return READ_RVALID; 
                when KEY_RREADY              => return READ_RREADY; 
                when others                  => null;
            end case;
        elsif (R or W) then
            case KEY_WORD is
                when KEY_ID         =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARID ;
                        when AXI4_CHANNEL_AW => return READ_AWID ;
                        when AXI4_CHANNEL_R  => return READ_RID  ;
                        when AXI4_CHANNEL_W  => return READ_WID  ;
                        when AXI4_CHANNEL_B  => return READ_BID  ;
                        when others          => null;
                    end case;
                when KEY_USER       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARUSER;
                        when AXI4_CHANNEL_AW => return READ_AWUSER;
                        when AXI4_CHANNEL_R  => return READ_RUSER;
                        when AXI4_CHANNEL_W  => return READ_WUSER;
                        when AXI4_CHANNEL_B  => return READ_BUSER;
                        when others          => null;
                    end case;
                when KEY_VALID      =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARVALID;
                        when AXI4_CHANNEL_AW => return READ_AWVALID;
                        when AXI4_CHANNEL_R  => return READ_RVALID;
                        when AXI4_CHANNEL_W  => return READ_WVALID;
                        when AXI4_CHANNEL_B  => return READ_BVALID;
                        when others          => null;
                    end case;
                when KEY_READY      =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARREADY;
                        when AXI4_CHANNEL_AW => return READ_AWREADY;
                        when AXI4_CHANNEL_R  => return READ_RREADY;
                        when AXI4_CHANNEL_W  => return READ_WREADY;
                        when AXI4_CHANNEL_B  => return READ_BREADY;
                        when others          => null;
                    end case;
                when KEY_DATA       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_R  => return READ_RDATA;
                        when AXI4_CHANNEL_W  => return READ_WDATA;
                        when others          => null;
                    end case;
                when KEY_LAST       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_R  => return READ_RLAST;
                        when AXI4_CHANNEL_W  => return READ_WLAST;
                        when others          => null;
                    end case;
                when KEY_RESP       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_R  => return READ_RRESP;
                        when AXI4_CHANNEL_B  => return READ_BRESP;
                        when others          => null;
                    end case;
                when KEY_ADDR       => 
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARADDR; 
                        when AXI4_CHANNEL_AW => return READ_AWADDR; 
                        when others          => null;
                    end case;
                when KEY_LEN        =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARLEN; 
                        when AXI4_CHANNEL_AW => return READ_AWLEN; 
                        when others          => null;
                    end case;
                when KEY_SIZE       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARSIZE;
                        when AXI4_CHANNEL_AW => return READ_AWSIZE;
                        when others          => null;
                    end case;
                when KEY_BURST      =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARBURST;
                        when AXI4_CHANNEL_AW => return READ_AWBURST;
                        when others          => null;
                    end case;
                when KEY_LOCK       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARLOCK;
                        when AXI4_CHANNEL_AW => return READ_AWLOCK;
                        when others          => null;
                    end case;
                when KEY_CACHE      =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARCACHE;
                        when AXI4_CHANNEL_AW => return READ_AWCACHE;
                        when others          => null;
                    end case;
                when KEY_PROT       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARPROT;
                        when AXI4_CHANNEL_AW => return READ_AWPROT;
                        when others          => null;
                    end case;
                when KEY_QOS        =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARQOS;
                        when AXI4_CHANNEL_AW => return READ_AWQOS;
                        when others          => null;
                    end case;
                when KEY_REGION     =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARREGION;
                        when AXI4_CHANNEL_AW => return READ_AWREGION;
                        when others          => null;
                    end case;
                when KEY_STRB       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_W  => return READ_WSTRB;
                        when others          => null;
                    end case;
                when KEY_ARADDR              => return READ_ARADDR;
                when KEY_ARLEN               => return READ_ARLEN; 
                when KEY_ARSIZE              => return READ_ARSIZE;
                when KEY_ARBURST             => return READ_ARBURST;
                when KEY_ARLOCK              => return READ_ARLOCK;
                when KEY_ARCACHE             => return READ_ARCACHE;
                when KEY_ARPROT              => return READ_ARPROT;
                when KEY_ARQOS               => return READ_ARQOS; 
                when KEY_ARREGION            => return READ_ARREGION;
                when KEY_ARUSER              => return READ_ARUSER;
                when KEY_ARID                => return READ_ARID;  
                when KEY_ARVALID             => return READ_ARVALID;
                when KEY_ARREADY             => return READ_ARREADY;
                when KEY_AWADDR              => return READ_AWADDR;
                when KEY_AWLEN               => return READ_AWLEN; 
                when KEY_AWSIZE              => return READ_AWSIZE;
                when KEY_AWBURST             => return READ_AWBURST;
                when KEY_AWLOCK              => return READ_AWLOCK;
                when KEY_AWCACHE             => return READ_AWCACHE;
                when KEY_AWPROT              => return READ_AWPROT;
                when KEY_AWQOS               => return READ_AWQOS; 
                when KEY_AWREGION            => return READ_AWREGION;
                when KEY_AWUSER              => return READ_AWUSER;
                when KEY_AWID                => return READ_AWID;  
                when KEY_AWVALID             => return READ_AWVALID;
                when KEY_AWREADY             => return READ_AWREADY;
                when KEY_RDATA               => return READ_RDATA;
                when KEY_RRESP               => return READ_RRESP;
                when KEY_RLAST               => return READ_RLAST;
                when KEY_RUSER               => return READ_RUSER;
                when KEY_RID                 => return READ_RID;  
                when KEY_RVALID              => return READ_RVALID;
                when KEY_RREADY              => return READ_RREADY;
                when KEY_WDATA               => return READ_WDATA;
                when KEY_WSTRB               => return READ_WSTRB;
                when KEY_WLAST               => return READ_WLAST;
                when KEY_WUSER               => return READ_WUSER;
                when KEY_WID                 => return READ_WID;  
                when KEY_WVALID              => return READ_WVALID;
                when KEY_WREADY              => return READ_WREADY;
                when KEY_BRESP               => return READ_BRESP;
                when KEY_BUSER               => return READ_BUSER;
                when KEY_BID                 => return READ_BID;  
                when KEY_BVALID              => return READ_BVALID;
                when KEY_BREADY              => return READ_BREADY;
                when others                  => null;
            end case;
        end if;
        return READ_NONE;
    end function;
    -------------------------------------------------------------------------------
    --! @brief READERのマップからチャネル信号の構造体を読み取るサブプログラム.
    -------------------------------------------------------------------------------
    procedure READ_AXI4_CHANNEL(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 CHANNEL    : in    AXI4_CHANNEL_TYPE;    --! チャネルタイプを指定.
                 READ       : in    boolean;              --! リード可/不可を指定.
                 WRITE      : in    boolean;              --! ライト可/不可を指定.
                 WIDTH      : in    AXI4_SIGNAL_WIDTH_TYPE;
                 SIGNALS    : inout AXI4_CHANNEL_SIGNAL_TYPE;
                 CURR_EVENT : out   READER.EVENT_TYPE
    ) is
        variable next_event :       EVENT_TYPE;
        variable read_good  :       boolean;
        variable skip_good  :       boolean;
        variable key_word   :       KEY_TYPE;
        procedure READ_VAL(VAL: out std_logic_vector) is
            variable read_good : boolean;
            variable read_len  : integer;
            variable val_size  : integer;
        begin
            READ_EVENT(SELF, STREAM, EVENT_SCALAR, read_good);
            STRING_TO_STD_LOGIC_VECTOR(
              STR  => SELF.str_buf(1 to SELF.str_len),
              VAL  => VAL,
              LEN  => read_len,
              SIZE => val_size
            );
        end procedure;
        procedure READ_VAL(VAL: out std_logic) is
            variable read_good : boolean;
            variable read_len  : integer;
            variable val_size  : integer;
            variable vec       : std_logic_vector(0 downto 0);
        begin
            READ_EVENT(SELF, STREAM, EVENT_SCALAR, read_good);
            STRING_TO_STD_LOGIC_VECTOR(
              STR  => SELF.str_buf(1 to SELF.str_len),
              VAL  => vec,
              LEN  => read_len,
              SIZE => val_size
            );
            VAL := vec(0);
        end procedure;
    begin
        MAP_LOOP: loop
            SEEK_EVENT(SELF, STREAM, next_event);
            case next_event is
                when EVENT_SCALAR  =>
                    READ_EVENT(SELF, STREAM, EVENT_SCALAR , read_good);
                    COPY_KEY_WORD(SELF, key_word);
                    case to_read_axi4_signal(key_word, CHANNEL, READ, WRITE) is
                        when READ_ARID     => READ_VAL(SIGNALS.AR.ID  (WIDTH.ID     -1 downto 0));
                        when READ_ARADDR   => READ_VAL(SIGNALS.AR.ADDR(WIDTH.ARADDR -1 downto 0));
                        when READ_ARLEN    => READ_VAL(SIGNALS.AR.LEN   );
                        when READ_ARSIZE   => READ_VAL(SIGNALS.AR.SIZE  );
                        when READ_ARBURST  => READ_VAL(SIGNALS.AR.BURST );
                        when READ_ARLOCK   => READ_VAL(SIGNALS.AR.LOCK  );
                        when READ_ARCACHE  => READ_VAL(SIGNALS.AR.CACHE );
                        when READ_ARPROT   => READ_VAL(SIGNALS.AR.PROT  );
                        when READ_ARQOS    => READ_VAL(SIGNALS.AR.QOS   );
                        when READ_ARREGION => READ_VAL(SIGNALS.AR.REGION);
                        when READ_ARUSER   => READ_VAL(SIGNALS.AR.USER(WIDTH.ARUSER -1 downto 0));
                        when READ_ARVALID  => READ_VAL(SIGNALS.AR.VALID );
                        when READ_ARREADY  => READ_VAL(SIGNALS.AR.READY );
                        when READ_AWID     => READ_VAL(SIGNALS.AW.ID  (WIDTH.ID     -1 downto 0));
                        when READ_AWADDR   => READ_VAL(SIGNALS.AW.ADDR(WIDTH.ARADDR -1 downto 0));
                        when READ_AWLEN    => READ_VAL(SIGNALS.AW.LEN   );
                        when READ_AWSIZE   => READ_VAL(SIGNALS.AW.SIZE  );
                        when READ_AWBURST  => READ_VAL(SIGNALS.AW.BURST );
                        when READ_AWLOCK   => READ_VAL(SIGNALS.AW.LOCK  );
                        when READ_AWCACHE  => READ_VAL(SIGNALS.AW.CACHE );
                        when READ_AWPROT   => READ_VAL(SIGNALS.AW.PROT  );
                        when READ_AWQOS    => READ_VAL(SIGNALS.AW.QOS   );
                        when READ_AWREGION => READ_VAL(SIGNALS.AW.REGION);
                        when READ_AWUSER   => READ_VAL(SIGNALS.AW.USER(WIDTH.ARUSER -1 downto 0));
                        when READ_AWVALID  => READ_VAL(SIGNALS.AW.VALID );
                        when READ_AWREADY  => READ_VAL(SIGNALS.AW.READY );
                        when READ_RID      => READ_VAL(SIGNALS.R.ID   (WIDTH.ID     -1 downto 0));
                        when READ_RUSER    => READ_VAL(SIGNALS.R.USER (WIDTH.RUSER  -1 downto 0));
                        when READ_RDATA    => READ_VAL(SIGNALS.R.DATA (WIDTH.RDATA  -1 downto 0));
                        when READ_RRESP    => READ_VAL(SIGNALS.R.RESP  );
                        when READ_RLAST    => READ_VAL(SIGNALS.R.LAST  );
                        when READ_RVALID   => READ_VAL(SIGNALS.R.VALID );
                        when READ_RREADY   => READ_VAL(SIGNALS.R.READY );
                        when READ_WID      => READ_VAL(SIGNALS.W.ID   (WIDTH.ID     -1 downto 0));
                        when READ_WUSER    => READ_VAL(SIGNALS.W.USER (WIDTH.WUSER  -1 downto 0));
                        when READ_WDATA    => READ_VAL(SIGNALS.W.DATA (WIDTH.WDATA  -1 downto 0));
                        when READ_WSTRB    => READ_VAL(SIGNALS.W.STRB (WIDTH.WDATA/8-1 downto 0));
                        when READ_WLAST    => READ_VAL(SIGNALS.W.LAST  );
                        when READ_WVALID   => READ_VAL(SIGNALS.W.VALID );
                        when READ_WREADY   => READ_VAL(SIGNALS.W.READY );
                        when READ_BID      => READ_VAL(SIGNALS.B.ID   (WIDTH.ID     -1 downto 0));
                        when READ_BUSER    => READ_VAL(SIGNALS.B.USER (WIDTH.BUSER  -1 downto 0));
                        when READ_BRESP    => READ_VAL(SIGNALS.B.RESP  );
                        when READ_BVALID   => READ_VAL(SIGNALS.B.VALID );
                        when READ_BREADY   => READ_VAL(SIGNALS.B.READY );
                        when others        => exit MAP_LOOP;
                    end case;
                when EVENT_MAP_END =>         exit MAP_LOOP;
                when others        =>         exit MAP_LOOP;
            end case;
        end loop;
        CURR_EVENT := next_event;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 構造体の値と信号を比較するサブプログラム.
    -------------------------------------------------------------------------------
    procedure MATCH_AXI4_CHANNEL(
                 SIGNALS    : in    AXI4_CHANNEL_SIGNAL_TYPE;
                 READ       : in    boolean;
                 WRITE      : in    boolean;
                 MATCH      : out   boolean;
        signal   ARADDR     : in    std_logic_vector;
        signal   ARLEN      : in    AXI4_ALEN_TYPE;
        signal   ARSIZE     : in    AXI4_ASIZE_TYPE;
        signal   ARBURST    : in    AXI4_ABURST_TYPE;
        signal   ARLOCK     : in    AXI4_ALOCK_TYPE;
        signal   ARCACHE    : in    AXI4_ACACHE_TYPE;
        signal   ARPROT     : in    AXI4_APROT_TYPE;
        signal   ARQOS      : in    AXI4_AQOS_TYPE;
        signal   ARREGION   : in    AXI4_AREGION_TYPE;
        signal   ARUSER     : in    std_logic_vector;
        signal   ARID       : in    std_logic_vector;
        signal   ARVALID    : in    std_logic;
        signal   ARREADY    : in    std_logic;
        signal   AWADDR     : in    std_logic_vector;
        signal   AWLEN      : in    AXI4_ALEN_TYPE;
        signal   AWSIZE     : in    AXI4_ASIZE_TYPE;
        signal   AWBURST    : in    AXI4_ABURST_TYPE;
        signal   AWLOCK     : in    AXI4_ALOCK_TYPE;
        signal   AWCACHE    : in    AXI4_ACACHE_TYPE;
        signal   AWPROT     : in    AXI4_APROT_TYPE;
        signal   AWQOS      : in    AXI4_AQOS_TYPE;
        signal   AWREGION   : in    AXI4_AREGION_TYPE;
        signal   AWUSER     : in    std_logic_vector;
        signal   AWID       : in    std_logic_vector;
        signal   AWVALID    : in    std_logic;
        signal   AWREADY    : in    std_logic;
        signal   RLAST      : in    std_logic;
        signal   RDATA      : in    std_logic_vector;
        signal   RRESP      : in    AXI4_RESP_TYPE;
        signal   RUSER      : in    std_logic_vector;
        signal   RID        : in    std_logic_vector;
        signal   RVALID     : in    std_logic;
        signal   RREADY     : in    std_logic;
        signal   WLAST      : in    std_logic;
        signal   WDATA      : in    std_logic_vector;
        signal   WSTRB      : in    std_logic_vector;
        signal   WUSER      : in    std_logic_vector;
        signal   WID        : in    std_logic_vector;
        signal   WVALID     : in    std_logic;
        signal   WREADY     : in    std_logic;
        signal   BRESP      : in    AXI4_RESP_TYPE;
        signal   BUSER      : in    std_logic_vector;
        signal   BID        : in    std_logic_vector;
        signal   BVALID     : in    std_logic;
        signal   BREADY     : in    std_logic
    ) is
        variable ar_match   :       boolean;
        variable aw_match   :       boolean;
        variable r_match    :       boolean;
        variable w_match    :       boolean;
    begin
        ---------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナルの比較
        ---------------------------------------------------------------------------
        if (WRITE) then
            aw_match := MATCH_STD_LOGIC(SIGNALS.AW.VALID             ,AWVALID ) and 
                        MATCH_STD_LOGIC(SIGNALS.AW.READY             ,AWREADY ) and 
                        MATCH_STD_LOGIC(SIGNALS.AW.ID(AWID'range)    ,AWID    ) and 
                        MATCH_STD_LOGIC(SIGNALS.AW.ADDR(AWADDR'range),AWADDR  ) and 
                        MATCH_STD_LOGIC(SIGNALS.AW.LEN               ,AWLEN   ) and 
                        MATCH_STD_LOGIC(SIGNALS.AW.SIZE              ,AWSIZE  ) and 
                        MATCH_STD_LOGIC(SIGNALS.AW.BURST             ,AWBURST ) and 
                        MATCH_STD_LOGIC(SIGNALS.AW.LOCK              ,AWLOCK  ) and 
                        MATCH_STD_LOGIC(SIGNALS.AW.CACHE             ,AWCACHE ) and 
                        MATCH_STD_LOGIC(SIGNALS.AW.PROT              ,AWPROT  ) and
                        MATCH_STD_LOGIC(SIGNALS.AW.QOS               ,AWQOS   ) and
                        MATCH_STD_LOGIC(SIGNALS.AW.REGION            ,AWREGION) and
                        MATCH_STD_LOGIC(SIGNALS.AW.USER(AWUSER'range),AWUSER  );
        else
            aw_match := TRUE;
        end if;
        ---------------------------------------------------------------------------
        -- ライトチャネルシグナル/ライト応答チャネルシグナルの比較
        ---------------------------------------------------------------------------
        if (WRITE) then
            w_match  := MATCH_STD_LOGIC(SIGNALS.W.VALID              ,WVALID  ) and 
                        MATCH_STD_LOGIC(SIGNALS.W.READY              ,WREADY  ) and 
                        MATCH_STD_LOGIC(SIGNALS.B.VALID              ,BVALID  ) and 
                        MATCH_STD_LOGIC(SIGNALS.B.READY              ,BREADY  ) and
                        MATCH_STD_LOGIC(SIGNALS.W.ID(WID'range)      ,WID     ) and 
                        MATCH_STD_LOGIC(SIGNALS.B.ID(BID'range)      ,BID     ) and 
                        MATCH_STD_LOGIC(SIGNALS.W.DATA(WDATA'range)  ,WDATA   ) and 
                        MATCH_STD_LOGIC(SIGNALS.W.STRB(WSTRB'range)  ,WSTRB   ) and 
                        MATCH_STD_LOGIC(SIGNALS.W.LAST               ,WLAST   ) and 
                        MATCH_STD_LOGIC(SIGNALS.B.RESP               ,BRESP   ) and
                        MATCH_STD_LOGIC(SIGNALS.W.USER(WUSER'range)  ,WUSER   ) and 
                        MATCH_STD_LOGIC(SIGNALS.B.USER(BUSER'range)  ,BUSER   );
        else
            w_match  := TRUE;
        end if;
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナルの比較
        ---------------------------------------------------------------------------
        if (READ) then
            ar_match := MATCH_STD_LOGIC(SIGNALS.AR.VALID             ,ARVALID ) and 
                        MATCH_STD_LOGIC(SIGNALS.AR.READY             ,ARREADY ) and 
                        MATCH_STD_LOGIC(SIGNALS.AR.ID(ARID'range)    ,ARID    ) and 
                        MATCH_STD_LOGIC(SIGNALS.AR.ADDR(ARADDR'range),ARADDR  ) and 
                        MATCH_STD_LOGIC(SIGNALS.AR.LEN               ,ARLEN   ) and 
                        MATCH_STD_LOGIC(SIGNALS.AR.SIZE              ,ARSIZE  ) and 
                        MATCH_STD_LOGIC(SIGNALS.AR.BURST             ,ARBURST ) and 
                        MATCH_STD_LOGIC(SIGNALS.AR.LOCK              ,ARLOCK  ) and 
                        MATCH_STD_LOGIC(SIGNALS.AR.CACHE             ,ARCACHE ) and 
                        MATCH_STD_LOGIC(SIGNALS.AR.PROT              ,ARPROT  ) and
                        MATCH_STD_LOGIC(SIGNALS.AR.QOS               ,ARQOS   ) and
                        MATCH_STD_LOGIC(SIGNALS.AR.REGION            ,ARREGION) and
                        MATCH_STD_LOGIC(SIGNALS.AR.USER(ARUSER'range),ARUSER  );
        else
            ar_match := TRUE;
        end if;
        ---------------------------------------------------------------------------
        -- リードデータチャネルシグナルの比較
        ---------------------------------------------------------------------------
        if (READ) then
            r_match  := MATCH_STD_LOGIC(SIGNALS.R.VALID              ,RVALID  ) and 
                        MATCH_STD_LOGIC(SIGNALS.R.READY              ,RREADY  ) and 
                        MATCH_STD_LOGIC(SIGNALS.R.ID(RID'range)      ,RID     ) and 
                        MATCH_STD_LOGIC(SIGNALS.R.DATA(RDATA'range)  ,RDATA   ) and 
                        MATCH_STD_LOGIC(SIGNALS.R.LAST               ,RLAST   ) and 
                        MATCH_STD_LOGIC(SIGNALS.R.USER(RUSER'range)  ,RUSER   );
        else
            r_match  := TRUE;
        end if;
        MATCH := ar_match and aw_match and r_match and w_match;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 構造体の値と信号を比較するサブプログラム.
    -------------------------------------------------------------------------------
    procedure MATCH_AXI4_CHANNEL(
        variable SELF       : inout CORE_TYPE;
                 SIGNALS    : in    AXI4_CHANNEL_SIGNAL_TYPE;
                 READ       : in    boolean;
                 WRITE      : in    boolean;
                 MATCH      : out   boolean;
        signal   ARADDR     : in    std_logic_vector;
        signal   ARLEN      : in    AXI4_ALEN_TYPE;
        signal   ARSIZE     : in    AXI4_ASIZE_TYPE;
        signal   ARBURST    : in    AXI4_ABURST_TYPE;
        signal   ARLOCK     : in    AXI4_ALOCK_TYPE;
        signal   ARCACHE    : in    AXI4_ACACHE_TYPE;
        signal   ARPROT     : in    AXI4_APROT_TYPE;
        signal   ARQOS      : in    AXI4_AQOS_TYPE;
        signal   ARREGION   : in    AXI4_AREGION_TYPE;
        signal   ARUSER     : in    std_logic_vector;
        signal   ARID       : in    std_logic_vector;
        signal   ARVALID    : in    std_logic;
        signal   ARREADY    : in    std_logic;
        signal   AWADDR     : in    std_logic_vector;
        signal   AWLEN      : in    AXI4_ALEN_TYPE;
        signal   AWSIZE     : in    AXI4_ASIZE_TYPE;
        signal   AWBURST    : in    AXI4_ABURST_TYPE;
        signal   AWLOCK     : in    AXI4_ALOCK_TYPE;
        signal   AWCACHE    : in    AXI4_ACACHE_TYPE;
        signal   AWPROT     : in    AXI4_APROT_TYPE;
        signal   AWQOS      : in    AXI4_AQOS_TYPE;
        signal   AWREGION   : in    AXI4_AREGION_TYPE;
        signal   AWUSER     : in    std_logic_vector;
        signal   AWID       : in    std_logic_vector;
        signal   AWVALID    : in    std_logic;
        signal   AWREADY    : in    std_logic;
        signal   RLAST      : in    std_logic;
        signal   RDATA      : in    std_logic_vector;
        signal   RRESP      : in    AXI4_RESP_TYPE;
        signal   RUSER      : in    std_logic_vector;
        signal   RID        : in    std_logic_vector;
        signal   RVALID     : in    std_logic;
        signal   RREADY     : in    std_logic;
        signal   WLAST      : in    std_logic;
        signal   WDATA      : in    std_logic_vector;
        signal   WSTRB      : in    std_logic_vector;
        signal   WUSER      : in    std_logic_vector;
        signal   WID        : in    std_logic_vector;
        signal   WVALID     : in    std_logic;
        signal   WREADY     : in    std_logic;
        signal   BRESP      : in    AXI4_RESP_TYPE;
        signal   BUSER      : in    std_logic_vector;
        signal   BID        : in    std_logic_vector;
        signal   BVALID     : in    std_logic;
        signal   BREADY     : in    std_logic
    ) is
        variable count      :       integer;
    begin
        count := 0;
        ---------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナルの比較
        ---------------------------------------------------------------------------
        if (WRITE) then
            if (MATCH_STD_LOGIC(SIGNALS.AW.VALID             ,AWVALID ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("AWVALID ") &
                                BIN_TO_STRING(AWVALID) & " /= " &
                                BIN_TO_STRING(SIGNALS.AW.VALID));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.AW.READY             ,AWREADY ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("AWREADY ") & 
                                BIN_TO_STRING(AWREADY) & " /= " &
                                BIN_TO_STRING(SIGNALS.AW.READY));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.AW.ADDR(AWADDR'range),AWADDR  ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("AWADDR ") &
                                HEX_TO_STRING(AWADDR ) & " /= " &
                                HEX_TO_STRING(SIGNALS.AW.ADDR(AWADDR'range)));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.AW.LEN               ,AWLEN   ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("AWLEN ") &
                                BIN_TO_STRING(AWLEN  ) & " /= " &
                                BIN_TO_STRING(SIGNALS.AW.LEN));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.AW.SIZE              ,AWSIZE  ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("AWSIZE ") &
                                BIN_TO_STRING(AWSIZE ) & " /= " &
                                BIN_TO_STRING(SIGNALS.AW.SIZE));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.AW.BURST             ,AWBURST ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("AWBURST ") &
                                BIN_TO_STRING(AWBURST) & " /= " &
                                BIN_TO_STRING(SIGNALS.AW.BURST));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.AW.LOCK              ,AWLOCK  ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("ALOCK ") &
                                BIN_TO_STRING(AWLOCK ) & " /= " &
                                BIN_TO_STRING(SIGNALS.AW.LOCK));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.AW.CACHE             ,AWCACHE ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("AWCACHE ") &
                                BIN_TO_STRING(AWCACHE) & " /= " &
                                BIN_TO_STRING(SIGNALS.AW.CACHE));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.AW.PROT              ,AWPROT  ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("AWPROT ") &
                                BIN_TO_STRING(AWPROT ) & " /= " &
                                BIN_TO_STRING(SIGNALS.AW.PROT));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.AW.QOS               ,AWQOS   ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("AWQOS ") &
                                HEX_TO_STRING(AWQOS  ) & " /= " &
                                HEX_TO_STRING(SIGNALS.AW.QOS));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.AW.REGION            ,AWREGION) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("AWREGION ") &
                                HEX_TO_STRING(AWREGION) & " /= " &
                                HEX_TO_STRING(SIGNALS.AW.REGION));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.AW.ID(AWID'range)    ,AWID    ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("AWID ") &
                                HEX_TO_STRING(AWID   ) & " /= " &
                                HEX_TO_STRING(SIGNALS.AW.ID(AWID'range)));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.AW.USER(AWUSER'range),AWUSER  ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("AWUSER ") &
                                HEX_TO_STRING(AWUSER ) & " /= " &
                                HEX_TO_STRING(SIGNALS.AW.USER(AWUSER'range)));
                count := count + 1;
            end if;
        end if;
        ---------------------------------------------------------------------------
        -- ライトチャネルシグナルの比較
        ---------------------------------------------------------------------------
        if (WRITE) then
            if (MATCH_STD_LOGIC(SIGNALS.W.VALID            ,WVALID ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("WVALID ") &
                                BIN_TO_STRING(WVALID) & " /= " &
                                BIN_TO_STRING(SIGNALS.W.VALID));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.W.READY            ,WREADY ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("WREADY ") &
                                BIN_TO_STRING(WREADY) & " /= " &
                                BIN_TO_STRING(SIGNALS.W.READY));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.W.DATA(WDATA'range),WDATA  ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("WDATA ") &
                                HEX_TO_STRING(WDATA ) & " /= " &
                                HEX_TO_STRING(SIGNALS.W.DATA(WDATA'range)));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.W.LAST             ,WLAST  ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("WLAST ") &
                                BIN_TO_STRING(WLAST ) & " /= " &
                                BIN_TO_STRING(SIGNALS.W.LAST));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.W.STRB(WSTRB'range),WSTRB  ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("WSTRB ") &
                                BIN_TO_STRING(WSTRB ) & " /= " &
                                BIN_TO_STRING(SIGNALS.W.STRB(WSTRB'range)));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.W.ID(WID'range)    ,WID    ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("WID ") &
                                HEX_TO_STRING(WID   ) & " /= " &
                                HEX_TO_STRING(SIGNALS.W.ID(WID'range)));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.W.USER(WUSER'range),WUSER  ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("WUSER ") &
                                BIN_TO_STRING(WUSER ) & " /= " &
                                BIN_TO_STRING(SIGNALS.W.USER(WUSER'range)));
                count := count + 1;
            end if;
        end if;
        ---------------------------------------------------------------------------
        -- ライト応答チャネルシグナルの比較
        ---------------------------------------------------------------------------
        if (WRITE) then
            if (MATCH_STD_LOGIC(SIGNALS.B.VALID            ,BVALID ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("BVALID ") &
                                BIN_TO_STRING(BVALID) & " /= " &
                                BIN_TO_STRING(SIGNALS.B.VALID));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.B.READY            ,BREADY ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("BREADY ") &
                                BIN_TO_STRING(BREADY) & " /= " &
                                BIN_TO_STRING(SIGNALS.B.READY));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.B.RESP             ,BRESP  ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("BRESP ") &
                                BIN_TO_STRING(BRESP ) & " /= " &
                                BIN_TO_STRING(SIGNALS.B.RESP));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.B.ID(BID'range)    ,BID    ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("BID ") &
                                HEX_TO_STRING(BID   ) & " /= " &
                                HEX_TO_STRING(SIGNALS.B.ID(BID'range)));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.B.USER(BUSER'range),BUSER  ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("BUSER ") &
                                HEX_TO_STRING(BUSER ) & " /= " &
                                HEX_TO_STRING(SIGNALS.B.USER(BUSER'range)));
                count := count + 1;
            end if;
        end if;
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナルの比較
        ---------------------------------------------------------------------------
        if (READ) then
            if (MATCH_STD_LOGIC(SIGNALS.AR.VALID             ,ARVALID ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("ARVALID ") &
                                BIN_TO_STRING(ARVALID) & " /= " &
                                BIN_TO_STRING(SIGNALS.AR.VALID));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.AR.READY             ,ARREADY ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("ARREADY ") & 
                                BIN_TO_STRING(ARREADY) & " /= " &
                                BIN_TO_STRING(SIGNALS.AR.READY));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.AR.ADDR(ARADDR'range),ARADDR  ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("ARADDR ") &
                                HEX_TO_STRING(ARADDR ) & " /= " &
                                HEX_TO_STRING(SIGNALS.AR.ADDR(ARADDR'range)));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.AR.LEN               ,ARLEN   ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("ARLEN ") &
                                BIN_TO_STRING(ARLEN  ) & " /= " &
                                BIN_TO_STRING(SIGNALS.AR.LEN));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.AR.SIZE              ,ARSIZE  ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("ARSIZE ") &
                                BIN_TO_STRING(ARSIZE ) & " /= " &
                                BIN_TO_STRING(SIGNALS.AR.SIZE));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.AR.BURST             ,ARBURST ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("ARBURST ") &
                                BIN_TO_STRING(ARBURST) & " /= " &
                                BIN_TO_STRING(SIGNALS.AR.BURST));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.AR.LOCK              ,ARLOCK  ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("ALOCK ") &
                                BIN_TO_STRING(ARLOCK ) & " /= " &
                                BIN_TO_STRING(SIGNALS.AR.LOCK));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.AR.CACHE             ,ARCACHE ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("ARCACHE ") &
                                BIN_TO_STRING(ARCACHE) & " /= " &
                                BIN_TO_STRING(SIGNALS.AR.CACHE));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.AR.PROT              ,ARPROT  ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("ARPROT ") &
                                BIN_TO_STRING(ARPROT ) & " /= " &
                                BIN_TO_STRING(SIGNALS.AR.PROT));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.AR.QOS               ,ARQOS   ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("ARQOS ") &
                                HEX_TO_STRING(ARQOS  ) & " /= " &
                                HEX_TO_STRING(SIGNALS.AR.QOS));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.AR.REGION            ,ARREGION) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("ARREGION ") &
                                HEX_TO_STRING(ARREGION) & " /= " &
                                HEX_TO_STRING(SIGNALS.AR.REGION));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.AR.ID(ARID'range)    ,ARID    ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("ARID ") &
                                HEX_TO_STRING(ARID   ) & " /= " &
                                HEX_TO_STRING(SIGNALS.AR.ID(ARID'range)));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.AR.USER(ARUSER'range),ARUSER  ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("ARUSER ") &
                                HEX_TO_STRING(ARUSER ) & " /= " &
                                HEX_TO_STRING(SIGNALS.AR.USER(ARUSER'range)));
                count := count + 1;
            end if;
        end if;
        ---------------------------------------------------------------------------
        -- リードチャネルシグナルの比較
        ---------------------------------------------------------------------------
        if (READ) then
            if (MATCH_STD_LOGIC(SIGNALS.R.VALID            ,RVALID ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("RVALID ") & 
                                BIN_TO_STRING(RVALID) & " /= " &
                                BIN_TO_STRING(SIGNALS.R.VALID));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.R.READY            ,RREADY ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("RREADY ") &
                                BIN_TO_STRING(RREADY) & " /= " &
                                BIN_TO_STRING(SIGNALS.R.READY));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.R.DATA(RDATA'range),RDATA  ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("RDATA ") &
                                HEX_TO_STRING(RDATA ) & " /= " &
                                HEX_TO_STRING(SIGNALS.R.DATA(RDATA'range)));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.R.LAST             ,RLAST  ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("RLAST ") &
                                BIN_TO_STRING(RLAST ) & " /= " &
                                BIN_TO_STRING(SIGNALS.R.LAST));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.R.RESP             ,RRESP  ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("RRESP ") &
                                BIN_TO_STRING(RRESP ) & " /= " &
                                BIN_TO_STRING(SIGNALS.R.RESP));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.R.ID(RID'range)    ,RID    ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("RID ") &
                                HEX_TO_STRING(RID   ) & " /= " &
                                HEX_TO_STRING(SIGNALS.R.ID(RID'range)));
                count := count + 1;
            end if;
            if (MATCH_STD_LOGIC(SIGNALS.R.USER(RUSER'range),RUSER  ) = FALSE) then
                REPORT_MISMATCH(SELF.vocal, string'("RUSER ") &
                                HEX_TO_STRING(RUSER ) & " /= " &
                                HEX_TO_STRING(SIGNALS.R.USER(RUSER'range)));
                count := count + 1;
            end if;
        end if;
        MATCH := (count = 0);
    end procedure;
end AXI4_CORE;
