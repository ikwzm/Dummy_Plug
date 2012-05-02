-----------------------------------------------------------------------------------
--!     @file    axi4_core.vhd
--!     @brief   Core Package for AXI4 Dummy Plug.
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
    --! @brief AXI4 ID の最大ビット幅
    -------------------------------------------------------------------------------
    constant  AXI4_ID_MAX_WIDTH : integer := 8;
    -------------------------------------------------------------------------------
    --! @brief AXI4 ADDR の最大ビット幅
    -------------------------------------------------------------------------------
    constant  AXI4_A_MAX_WIDTH  : integer := 64;
    -------------------------------------------------------------------------------
    --! @brief AXI4 WDATA の最大ビット幅
    -------------------------------------------------------------------------------
    constant  AXI4_W_MAX_WIDTH  : integer := 128;
    -------------------------------------------------------------------------------
    --! @brief AXI4 RDATA の最大ビット幅
    -------------------------------------------------------------------------------
    constant  AXI4_R_MAX_WIDTH  : integer := 128;
    -------------------------------------------------------------------------------
    --! @brief AXI4 アドレスチャネル信号の構造体
    -------------------------------------------------------------------------------
    type      AXI4_A_CHANNEL_SIGNAL_TYPE is record
        ADDR     : std_logic_vector(AXI4_A_MAX_WIDTH  -1 downto 0);
        WRITE    : std_logic;
        LEN      : AXI4_ALEN_TYPE;
        SIZE     : AXI4_ASIZE_TYPE;
        BURST    : AXI4_ABURST_TYPE;
        LOCK     : AXI4_ALOCK_TYPE;
        CACHE    : AXI4_ACACHE_TYPE;
        PROT     : AXI4_APROT_TYPE;
        ID       : std_logic_vector(AXI4_ID_MAX_WIDTH -1 downto 0);
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
        ID      => (others => '0'),
        VALID   => '0',
        READY   => '0'
    );
    -------------------------------------------------------------------------------
    --! @brief AXI4 リードチャネル信号の構造体
    -------------------------------------------------------------------------------
    type      AXI4_R_CHANNEL_SIGNAL_TYPE is record
        DATA     : std_logic_vector(AXI4_R_MAX_WIDTH  -1 downto 0);
        RESP     : AXI4_RESP_TYPE;
        LAST     : std_logic;
        ID       : std_logic_vector(AXI4_ID_MAX_WIDTH -1 downto 0);
        VALID    : std_logic;
        READY    : std_logic;
    end record;
    constant  AXI4_R_CHANNEL_SIGNAL_DONTCARE : AXI4_R_CHANNEL_SIGNAL_TYPE := (
        DATA    => (others => '-'),
        RESP    => (others => '-'),
        LAST    => '-',
        ID      => (others => '-'),
        VALID   => '-',
        READY   => '-'
    );        
    constant  AXI4_R_CHANNEL_SIGNAL_NULL     : AXI4_R_CHANNEL_SIGNAL_TYPE := (
        DATA    => (others => '0'),
        RESP    => (others => '0'),
        LAST    => '0',
        ID      => (others => '0'),
        VALID   => '0',
        READY   => '0'
    );        
    -------------------------------------------------------------------------------
    --! @brief AXI4 ライトチャネル信号の構造体
    -------------------------------------------------------------------------------
    type      AXI4_W_CHANNEL_SIGNAL_TYPE is record
        DATA     : std_logic_vector(AXI4_W_MAX_WIDTH  -1 downto 0);
        LAST     : std_logic;
        STRB     : std_logic_vector(AXI4_W_MAX_WIDTH/8-1 downto 0);
        ID       : std_logic_vector(AXI4_ID_MAX_WIDTH -1 downto 0);
        VALID    : std_logic;
        READY    : std_logic;
    end record;
    constant  AXI4_W_CHANNEL_SIGNAL_DONTCARE : AXI4_W_CHANNEL_SIGNAL_TYPE := (
        DATA    => (others => '-'),
        LAST    => '-',
        STRB    => (others => '-'),
        ID      => (others => '-'),
        VALID   => '-',
        READY   => '-'
    );        
    constant  AXI4_W_CHANNEL_SIGNAL_NULL     : AXI4_W_CHANNEL_SIGNAL_TYPE := (
        DATA    => (others => '0'),
        LAST    => '0',
        STRB    => (others => '0'),
        ID      => (others => '0'),
        VALID   => '0',
        READY   => '0'
    );        
    -------------------------------------------------------------------------------
    --! @brief AXI4 ライト応答チャネル信号の構造体
    -------------------------------------------------------------------------------
    type      AXI4_B_CHANNEL_SIGNAL_TYPE is record
        RESP     : AXI4_RESP_TYPE;
        ID       : std_logic_vector(AXI4_ID_MAX_WIDTH -1 downto 0);
        VALID    : std_logic;
        READY    : std_logic;
    end record;
    constant  AXI4_B_CHANNEL_SIGNAL_DONTCARE : AXI4_B_CHANNEL_SIGNAL_TYPE := (
        RESP    => (others => '-'),
        ID      => (others => '-'),
        VALID   => '-',
        READY   => '-'
    );        
    constant  AXI4_B_CHANNEL_SIGNAL_NULL     : AXI4_B_CHANNEL_SIGNAL_TYPE := (
        RESP    => (others => '0'),
        ID      => (others => '0'),
        VALID   => '0',
        READY   => '0'
    );        
    -------------------------------------------------------------------------------
    --! @brief AXI4 チャネル信号の構造体
    -------------------------------------------------------------------------------
    type      AXI4_CHANNEL_SIGNAL_TYPE is record
        A        : AXI4_A_CHANNEL_SIGNAL_TYPE;
        R        : AXI4_R_CHANNEL_SIGNAL_TYPE;
        W        : AXI4_W_CHANNEL_SIGNAL_TYPE;
        B        : AXI4_B_CHANNEL_SIGNAL_TYPE;
    end record;
    constant  AXI4_CHANNEL_SIGNAL_DONTCARE : AXI4_CHANNEL_SIGNAL_TYPE := (
        A       => AXI4_A_CHANNEL_SIGNAL_DONTCARE,
        R       => AXI4_R_CHANNEL_SIGNAL_DONTCARE,
        W       => AXI4_W_CHANNEL_SIGNAL_DONTCARE,
        B       => AXI4_B_CHANNEL_SIGNAL_DONTCARE
    );
    constant  AXI4_CHANNEL_SIGNAL_NULL     : AXI4_CHANNEL_SIGNAL_TYPE := (
        A       => AXI4_A_CHANNEL_SIGNAL_NULL,
        R       => AXI4_R_CHANNEL_SIGNAL_NULL,
        W       => AXI4_W_CHANNEL_SIGNAL_NULL,
        B       => AXI4_B_CHANNEL_SIGNAL_NULL
    );
    -------------------------------------------------------------------------------
    --! @brief READERのマップからチャネル信号の構造体を読み取るサブプログラム.
    -------------------------------------------------------------------------------
    procedure READ_AXI4_CHANNEL(
        variable SELF       : inout CORE.CORE_TYPE;       --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 CHANNEL    : in    character;            --! 'A','R','W','B'を指定.
                 ID_WIDTH   : in    integer;
                 A_WIDTH    : in    integer;
                 R_WIDTH    : in    integer;
                 W_WIDTH    : in    integer;
                 SIGNALS    : inout AXI4_CHANNEL_SIGNAL_TYPE;
                 CURR_EVENT : out   READER.EVENT_TYPE
    );
    -------------------------------------------------------------------------------
    --! @brief 構造体の値と信号を比較するサブプログラム.
    -------------------------------------------------------------------------------
    procedure MATCH_AXI4_CHANNEL(
                 SIGNALS    : in    AXI4_CHANNEL_SIGNAL_TYPE;
                 MATCH      : out   boolean;
        signal   AVALID     : in    std_logic;
        signal   ADDR       : in    std_logic_vector;
        signal   AWRITE     : in    std_logic;
        signal   ALEN       : in    AXI4_ALEN_TYPE;
        signal   ASIZE      : in    AXI4_ASIZE_TYPE;
        signal   ABURST     : in    AXI4_ABURST_TYPE;
        signal   ALOCK      : in    AXI4_ALOCK_TYPE;
        signal   ACACHE     : in    AXI4_ACACHE_TYPE;
        signal   APROT      : in    AXI4_APROT_TYPE;
        signal   AID        : in    std_logic_vector;
        signal   AREADY     : in    std_logic;
        signal   RVALID     : in    std_logic;
        signal   RLAST      : in    std_logic;
        signal   RDATA      : in    std_logic_vector;
        signal   RRESP      : in    AXI4_RESP_TYPE;
        signal   RID        : in    std_logic_vector;
        signal   RREADY     : in    std_logic;
        signal   WVALID     : in    std_logic;
        signal   WLAST      : in    std_logic;
        signal   WDATA      : in    std_logic_vector;
        signal   WSTRB      : in    std_logic_vector;
        signal   WID        : in    std_logic_vector;
        signal   WREADY     : in    std_logic;
        signal   BVALID     : in    std_logic;
        signal   BRESP      : in    AXI4_RESP_TYPE;
        signal   BID        : in    std_logic_vector;
        signal   BREADY     : in    std_logic
    );
    -------------------------------------------------------------------------------
    --! @brief 構造体の値と信号を比較するサブプログラム.
    -------------------------------------------------------------------------------
    procedure MATCH_AXI4_CHANNEL(
        variable SELF       : inout CORE.CORE_TYPE;
                 SIGNALS    : in    AXI4_CHANNEL_SIGNAL_TYPE;
                 MATCH      : out   boolean;
        signal   AVALID     : in    std_logic;
        signal   ADDR       : in    std_logic_vector;
        signal   AWRITE     : in    std_logic;
        signal   ALEN       : in    AXI4_ALEN_TYPE;
        signal   ASIZE      : in    AXI4_ASIZE_TYPE;
        signal   ABURST     : in    AXI4_ABURST_TYPE;
        signal   ALOCK      : in    AXI4_ALOCK_TYPE;
        signal   ACACHE     : in    AXI4_ACACHE_TYPE;
        signal   APROT      : in    AXI4_APROT_TYPE;
        signal   AID        : in    std_logic_vector;
        signal   AREADY     : in    std_logic;
        signal   RVALID     : in    std_logic;
        signal   RLAST      : in    std_logic;
        signal   RDATA      : in    std_logic_vector;
        signal   RRESP      : in    AXI4_RESP_TYPE;
        signal   RID        : in    std_logic_vector;
        signal   RREADY     : in    std_logic;
        signal   WVALID     : in    std_logic;
        signal   WLAST      : in    std_logic;
        signal   WDATA      : in    std_logic_vector;
        signal   WSTRB      : in    std_logic_vector;
        signal   WID        : in    std_logic_vector;
        signal   WREADY     : in    std_logic;
        signal   BVALID     : in    std_logic;
        signal   BRESP      : in    AXI4_RESP_TYPE;
        signal   BID        : in    std_logic_vector;
        signal   BREADY     : in    std_logic
    );
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
            CHANNEL         : --! @brief チャネル識別子.
                              --!      * 'A' 'W' 'R' 'B' の何れかを指定する.
                              CHARACTER := 'A';
            MASTER          : --! @brief マスターモードを指定する.
                              boolean   := FALSE;
            SLAVE           : --! @brief スレーブモードを指定する.
                              boolean   := FALSE;
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
            SYNC_PORT       : --! @brief ローカル同期信号のポート番号.
                              integer := 0;
            SYNC_WAIT       : --! @brief ローカル同期時のウェイトクロック数.
                              integer := 2
        );
        ---------------------------------------------------------------------------
        -- 入出力ポートの定義.
        ---------------------------------------------------------------------------
        port(
            -----------------------------------------------------------------------
            -- グローバルシグナル.
            -----------------------------------------------------------------------
            ACLK            : in    std_logic;
            ARESETn         : in    std_logic;
            -----------------------------------------------------------------------
            -- アドレスチャネルシグナル.
            -----------------------------------------------------------------------
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
            -----------------------------------------------------------------------
            -- リードチャネルシグナル.
            -----------------------------------------------------------------------
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
            -----------------------------------------------------------------------
            -- ライトチャネルシグナル.
            -----------------------------------------------------------------------
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
            -----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            -----------------------------------------------------------------------
            BVALID_I        : in    std_logic;
            BVALID_O        : out   std_logic;
            BRESP_I         : in    AXI4_RESP_TYPE;
            BRESP_O         : out   AXI4_RESP_TYPE;
            BID_I           : in    std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
            BID_O           : out   std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
            BREADY_I        : in    std_logic;
            BREADY_O        : out   std_logic;
            -----------------------------------------------------------------------
            -- シンクロ用信号
            -----------------------------------------------------------------------
            SYNC_REQ        : out   SYNC.SYNC_REQ_VECTOR(SYNC_PORT downto SYNC_PORT);
            SYNC_ACK        : in    SYNC.SYNC_ACK_VECTOR(SYNC_PORT downto SYNC_PORT)
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
    --
    -------------------------------------------------------------------------------
    constant  KEY_ADDR      : STRING(1 to 6) := "ADDR  ";
    constant  KEY_WRITE     : STRING(1 to 6) := "WRITE ";
    constant  KEY_LEN       : STRING(1 to 6) := "LEN   ";
    constant  KEY_SIZE      : STRING(1 to 6) := "SIZE  ";
    constant  KEY_BURST     : STRING(1 to 6) := "BURST ";
    constant  KEY_LOCK      : STRING(1 to 6) := "LOCK  ";
    constant  KEY_CACHE     : STRING(1 to 6) := "CACHE ";
    constant  KEY_PROT      : STRING(1 to 6) := "PROT  ";
    constant  KEY_ID        : STRING(1 to 6) := "ID    ";
    constant  KEY_DATA      : STRING(1 to 6) := "DATA  ";
    constant  KEY_RESP      : STRING(1 to 6) := "RESP  ";
    constant  KEY_LAST      : STRING(1 to 6) := "LAST  ";
    constant  KEY_STRB      : STRING(1 to 6) := "STRB  ";
    constant  KEY_VALID     : STRING(1 to 6) := "VALID ";
    constant  KEY_READY     : STRING(1 to 6) := "READY ";
    constant  KEY_AWRITE    : STRING(1 to 6) := "AWRITE";
    constant  KEY_ALEN      : STRING(1 to 6) := "ALEN  ";
    constant  KEY_ASIZE     : STRING(1 to 6) := "ASIZE ";
    constant  KEY_ABURST    : STRING(1 to 6) := "ABURST";
    constant  KEY_ALOCK     : STRING(1 to 6) := "ALOCK ";
    constant  KEY_ACACHE    : STRING(1 to 6) := "ACACHE";
    constant  KEY_APROT     : STRING(1 to 6) := "APROT ";
    constant  KEY_AID       : STRING(1 to 6) := "AID   ";
    constant  KEY_AVALID    : STRING(1 to 6) := "AVALID";
    constant  KEY_AREADY    : STRING(1 to 6) := "AREADY";
    constant  KEY_RDATA     : STRING(1 to 6) := "RDATA ";
    constant  KEY_RRESP     : STRING(1 to 6) := "RRESP ";
    constant  KEY_RLAST     : STRING(1 to 6) := "RLAST ";
    constant  KEY_RID       : STRING(1 to 6) := "RID   ";
    constant  KEY_RVALID    : STRING(1 to 6) := "RVALID";
    constant  KEY_RREADY    : STRING(1 to 6) := "RREADY";
    constant  KEY_WDATA     : STRING(1 to 6) := "WDATA ";
    constant  KEY_WSTRB     : STRING(1 to 6) := "WSTRB ";
    constant  KEY_WLAST     : STRING(1 to 6) := "WLAST ";
    constant  KEY_WID       : STRING(1 to 6) := "WID   ";
    constant  KEY_WVALID    : STRING(1 to 6) := "WVALID";
    constant  KEY_WREADY    : STRING(1 to 6) := "WREADY";
    constant  KEY_BRESP     : STRING(1 to 6) := "BRESP ";
    constant  KEY_BID       : STRING(1 to 6) := "BID   ";
    constant  KEY_BVALID    : STRING(1 to 6) := "BVALID";
    constant  KEY_BREADY    : STRING(1 to 6) := "BREADY";
    -------------------------------------------------------------------------------
    --! @brief READERのマップからチャネル信号の構造体を読み取るサブプログラム.
    -------------------------------------------------------------------------------
    procedure READ_AXI4_CHANNEL(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 CHANNEL    : in    character;            --! 'A','R','W','B'を指定.
                 ID_WIDTH   : in    integer;
                 A_WIDTH    : in    integer;
                 R_WIDTH    : in    integer;
                 W_WIDTH    : in    integer;
                 SIGNALS    : inout AXI4_CHANNEL_SIGNAL_TYPE;
                 CURR_EVENT : out   READER.EVENT_TYPE
    ) is
        variable next_event :       EVENT_TYPE;
        variable read_good  :       boolean;
        variable skip_good  :       boolean;
        variable key_word   :       STRING(1 to 6);
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
                    case key_word is
                        when KEY_ID         =>
                            case CHANNEL is
                                when 'A'    => READ_VAL(SIGNALS.A.ID(ID_WIDTH-1 downto 0));
                                when 'R'    => READ_VAL(SIGNALS.R.ID(ID_WIDTH-1 downto 0));
                                when 'W'    => READ_VAL(SIGNALS.W.ID(ID_WIDTH-1 downto 0));
                                when 'B'    => READ_VAL(SIGNALS.B.ID(ID_WIDTH-1 downto 0));
                                when others => exit MAP_LOOP;
                            end case;
                        when KEY_DATA       =>
                            case CHANNEL is
                                when 'R'    => READ_VAL(SIGNALS.R.DATA(R_WIDTH-1 downto 0));
                                when 'W'    => READ_VAL(SIGNALS.W.DATA(W_WIDTH-1 downto 0));
                                when others => exit MAP_LOOP;
                            end case;
                        when KEY_LAST       =>
                            case CHANNEL is
                                when 'R'    => READ_VAL(SIGNALS.R.LAST);
                                when 'W'    => READ_VAL(SIGNALS.W.LAST);
                                when others => exit MAP_LOOP;
                            end case;
                        when KEY_RESP       =>
                            case CHANNEL is
                                when 'R'    => READ_VAL(SIGNALS.R.RESP);
                                when 'B'    => READ_VAL(SIGNALS.B.RESP);
                                when others => exit MAP_LOOP;
                            end case;
                        when KEY_VALID      =>
                            case CHANNEL is
                                when 'A'    => READ_VAL(SIGNALS.A.VALID);
                                when 'R'    => READ_VAL(SIGNALS.R.VALID);
                                when 'W'    => READ_VAL(SIGNALS.W.VALID);
                                when 'B'    => READ_VAL(SIGNALS.B.VALID);
                                when others => exit MAP_LOOP;
                            end case;
                        when KEY_READY      =>
                            case CHANNEL is
                                when 'A'    => READ_VAL(SIGNALS.A.READY);
                                when 'R'    => READ_VAL(SIGNALS.R.READY);
                                when 'W'    => READ_VAL(SIGNALS.W.READY);
                                when 'B'    => READ_VAL(SIGNALS.B.READY);
                                when others => exit MAP_LOOP;
                            end case;
                        when KEY_ADDR       => READ_VAL(SIGNALS.A.ADDR(A_WIDTH  -1 downto 0));
                        when KEY_WRITE      =>
                            case CHANNEL is
                                when 'A'    => READ_VAL(SIGNALS.A.WRITE);
                                when others => exit MAP_LOOP;
                            end case;
                        when KEY_LEN        =>
                            case CHANNEL is
                                when 'A'    => READ_VAL(SIGNALS.A.LEN);
                                when others => exit MAP_LOOP;
                            end case;
                        when KEY_SIZE       =>
                            case CHANNEL is
                                when 'A'    => READ_VAL(SIGNALS.A.SIZE);
                                when others => exit MAP_LOOP;
                            end case;
                        when KEY_BURST      =>
                            case CHANNEL is
                                when 'A'    => READ_VAL(SIGNALS.A.BURST);
                                when others => exit MAP_LOOP;
                            end case;
                        when KEY_LOCK       =>
                            case CHANNEL is
                                when 'a'    => READ_VAL(SIGNALS.A.LOCK);
                                when others => exit MAP_LOOP;
                            end case;
                        when KEY_CACHE      =>
                            case CHANNEL is
                                when 'A'    => READ_VAL(SIGNALS.A.CACHE);
                                when others => exit MAP_LOOP;
                            end case;
                        when KEY_PROT       =>
                            case CHANNEL is
                                when 'A'    => READ_VAL(SIGNALS.A.PROT);
                                when others => exit MAP_LOOP;
                            end case;
                        when KEY_STRB       =>
                            case CHANNEL is
                                when 'W'    => READ_VAL(SIGNALS.W.STRB(W_WIDTH/8-1 downto 0));
                                when others => exit MAP_LOOP;
                            end case;
                        when KEY_AWRITE     => READ_VAL(SIGNALS.A.WRITE);
                        when KEY_ALEN       => READ_VAL(SIGNALS.A.LEN);
                        when KEY_ASIZE      => READ_VAL(SIGNALS.A.SIZE);
                        when KEY_ABURST     => READ_VAL(SIGNALS.A.BURST);
                        when KEY_ALOCK      => READ_VAL(SIGNALS.A.LOCK);
                        when KEY_ACACHE     => READ_VAL(SIGNALS.A.CACHE);
                        when KEY_APROT      => READ_VAL(SIGNALS.A.PROT);
                        when KEY_AID        => READ_VAL(SIGNALS.A.ID(ID_WIDTH   -1 downto 0));
                        when KEY_AVALID     => READ_VAL(SIGNALS.A.VALID);
                        when KEY_AREADY     => READ_VAL(SIGNALS.A.READY);
                        when KEY_RDATA      => READ_VAL(SIGNALS.R.DATA(R_WIDTH  -1 downto 0));
                        when KEY_RRESP      => READ_VAL(SIGNALS.R.RESP);
                        when KEY_RLAST      => READ_VAL(SIGNALS.R.LAST);
                        when KEY_RID        => READ_VAL(SIGNALS.R.ID);
                        when KEY_RVALID     => READ_VAL(SIGNALS.R.VALID);
                        when KEY_RREADY     => READ_VAL(SIGNALS.R.READY);
                        when KEY_WDATA      => READ_VAL(SIGNALS.W.DATA(W_WIDTH  -1 downto 0));
                        when KEY_WSTRB      => READ_VAL(SIGNALS.W.DATA(W_WIDTH/8-1 downto 0));
                        when KEY_WLAST      => READ_VAL(SIGNALS.W.LAST);
                        when KEY_WID        => READ_VAL(SIGNALS.W.ID);
                        when KEY_WVALID     => READ_VAL(SIGNALS.W.VALID);
                        when KEY_WREADY     => READ_VAL(SIGNALS.W.READY);
                        when KEY_BRESP      => READ_VAL(SIGNALS.B.RESP);
                        when KEY_BID        => READ_VAL(SIGNALS.B.ID);
                        when KEY_BVALID     => READ_VAL(SIGNALS.B.VALID);
                        when KEY_BREADY     => READ_VAL(SIGNALS.B.READY);
                        when others         => exit MAP_LOOP;
                    end case;
                when EVENT_MAP_END =>
                 -- READ_EVENT(SELF, STREAM, EVENT_MAP_END, read_good);
                    exit MAP_LOOP;
                when others        =>
                    exit MAP_LOOP;
            end case;
        end loop;
        CURR_EVENT := next_event;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 構造体の値と信号を比較するサブプログラム.
    -------------------------------------------------------------------------------
    procedure MATCH_AXI4_CHANNEL(
                 SIGNALS    : in    AXI4_CHANNEL_SIGNAL_TYPE;
                 MATCH      : out   boolean;
        signal   AVALID     : in    std_logic;
        signal   ADDR       : in    std_logic_vector;
        signal   AWRITE     : in    std_logic;
        signal   ALEN       : in    AXI4_ALEN_TYPE;
        signal   ASIZE      : in    AXI4_ASIZE_TYPE;
        signal   ABURST     : in    AXI4_ABURST_TYPE;
        signal   ALOCK      : in    AXI4_ALOCK_TYPE;
        signal   ACACHE     : in    AXI4_ACACHE_TYPE;
        signal   APROT      : in    AXI4_APROT_TYPE;
        signal   AID        : in    std_logic_vector;
        signal   AREADY     : in    std_logic;
        signal   RVALID     : in    std_logic;
        signal   RLAST      : in    std_logic;
        signal   RDATA      : in    std_logic_vector;
        signal   RRESP      : in    AXI4_RESP_TYPE;
        signal   RID        : in    std_logic_vector;
        signal   RREADY     : in    std_logic;
        signal   WVALID     : in    std_logic;
        signal   WLAST      : in    std_logic;
        signal   WDATA      : in    std_logic_vector;
        signal   WSTRB      : in    std_logic_vector;
        signal   WID        : in    std_logic_vector;
        signal   WREADY     : in    std_logic;
        signal   BVALID     : in    std_logic;
        signal   BRESP      : in    AXI4_RESP_TYPE;
        signal   BID        : in    std_logic_vector;
        signal   BREADY     : in    std_logic
    ) is
    begin
        MATCH := MATCH_STD_LOGIC(SIGNALS.A.VALID            ,AVALID ) and 
                 MATCH_STD_LOGIC(SIGNALS.A.READY            ,AREADY ) and 
                 MATCH_STD_LOGIC(SIGNALS.R.VALID            ,RVALID ) and 
                 MATCH_STD_LOGIC(SIGNALS.R.READY            ,RREADY ) and 
                 MATCH_STD_LOGIC(SIGNALS.W.VALID            ,WVALID ) and 
                 MATCH_STD_LOGIC(SIGNALS.W.READY            ,WREADY ) and 
                 MATCH_STD_LOGIC(SIGNALS.B.VALID            ,BVALID ) and 
                 MATCH_STD_LOGIC(SIGNALS.B.READY            ,BREADY ) and
            
                 MATCH_STD_LOGIC(SIGNALS.A.ID(AID'range)    ,AID    ) and 
                 MATCH_STD_LOGIC(SIGNALS.R.ID(RID'range)    ,RID    ) and 
                 MATCH_STD_LOGIC(SIGNALS.W.ID(WID'range)    ,WID    ) and 
                 MATCH_STD_LOGIC(SIGNALS.B.ID(BID'range)    ,BID    ) and 

                 MATCH_STD_LOGIC(SIGNALS.A.ADDR(ADDR'range) ,ADDR   ) and 
                 MATCH_STD_LOGIC(SIGNALS.A.WRITE            ,AWRITE ) and 
                 MATCH_STD_LOGIC(SIGNALS.A.LEN              ,ALEN   ) and 
                 MATCH_STD_LOGIC(SIGNALS.A.SIZE             ,ASIZE  ) and 
                 MATCH_STD_LOGIC(SIGNALS.A.BURST            ,ABURST ) and 
                 MATCH_STD_LOGIC(SIGNALS.A.LOCK             ,ALOCK  ) and 
                 MATCH_STD_LOGIC(SIGNALS.A.CACHE            ,ACACHE ) and 
                 MATCH_STD_LOGIC(SIGNALS.A.PROT             ,APROT  ) and 

                 MATCH_STD_LOGIC(SIGNALS.R.DATA(RDATA'range),RDATA  ) and 
                 MATCH_STD_LOGIC(SIGNALS.R.LAST             ,RLAST  ) and 
                 MATCH_STD_LOGIC(SIGNALS.R.RESP             ,RRESP  ) and 

                 MATCH_STD_LOGIC(SIGNALS.W.DATA(WDATA'range),WDATA  ) and 
                 MATCH_STD_LOGIC(SIGNALS.W.STRB(WSTRB'range),WSTRB  ) and 
                 MATCH_STD_LOGIC(SIGNALS.W.LAST             ,WLAST  ) and 

                 MATCH_STD_LOGIC(SIGNALS.B.RESP             ,BRESP  ) ;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 構造体の値と信号を比較するサブプログラム.
    -------------------------------------------------------------------------------
    procedure MATCH_AXI4_CHANNEL(
        variable SELF       : inout CORE_TYPE;
                 SIGNALS    : in    AXI4_CHANNEL_SIGNAL_TYPE;
                 MATCH      : out   boolean;
        signal   AVALID     : in    std_logic;
        signal   ADDR       : in    std_logic_vector;
        signal   AWRITE     : in    std_logic;
        signal   ALEN       : in    AXI4_ALEN_TYPE;
        signal   ASIZE      : in    AXI4_ASIZE_TYPE;
        signal   ABURST     : in    AXI4_ABURST_TYPE;
        signal   ALOCK      : in    AXI4_ALOCK_TYPE;
        signal   ACACHE     : in    AXI4_ACACHE_TYPE;
        signal   APROT      : in    AXI4_APROT_TYPE;
        signal   AID        : in    std_logic_vector;
        signal   AREADY     : in    std_logic;
        signal   RVALID     : in    std_logic;
        signal   RLAST      : in    std_logic;
        signal   RDATA      : in    std_logic_vector;
        signal   RRESP      : in    AXI4_RESP_TYPE;
        signal   RID        : in    std_logic_vector;
        signal   RREADY     : in    std_logic;
        signal   WVALID     : in    std_logic;
        signal   WLAST      : in    std_logic;
        signal   WDATA      : in    std_logic_vector;
        signal   WSTRB      : in    std_logic_vector;
        signal   WID        : in    std_logic_vector;
        signal   WREADY     : in    std_logic;
        signal   BVALID     : in    std_logic;
        signal   BRESP      : in    AXI4_RESP_TYPE;
        signal   BID        : in    std_logic_vector;
        signal   BREADY     : in    std_logic
    ) is
        variable count      :       integer;
    begin
        count := 0;
        if (MATCH_STD_LOGIC(SIGNALS.A.VALID            ,AVALID ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("AVALID ") &
                            BIN_TO_STRING(AVALID) & " /= " & BIN_TO_STRING(SIGNALS.A.VALID));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.A.READY            ,AREADY ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("AREADY ") & 
                            BIN_TO_STRING(AREADY) & " /= " & BIN_TO_STRING(SIGNALS.A.READY));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.R.VALID            ,RVALID ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("RVALID ") & 
                            BIN_TO_STRING(RVALID) & " /= " & BIN_TO_STRING(SIGNALS.R.VALID));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.R.READY            ,RREADY ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("RREADY ") &
                            BIN_TO_STRING(RREADY) & " /= " & BIN_TO_STRING(SIGNALS.R.READY));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.W.VALID            ,WVALID ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("WVALID ") &
                            BIN_TO_STRING(WVALID) & " /= " & BIN_TO_STRING(SIGNALS.W.VALID));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.W.READY            ,WREADY ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("WREADY ") &
                            BIN_TO_STRING(WREADY) & " /= " & BIN_TO_STRING(SIGNALS.W.READY));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.B.VALID            ,BVALID ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("BVALID ") &
                            BIN_TO_STRING(BVALID) & " /= " & BIN_TO_STRING(SIGNALS.B.VALID));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.B.READY            ,BREADY ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("BREADY ") &
                            BIN_TO_STRING(BREADY) & " /= " & BIN_TO_STRING(SIGNALS.B.READY));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.A.ID(AID'range)    ,AID    ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("AID    ") &
                            HEX_TO_STRING(AID   ) & " /= " & HEX_TO_STRING(SIGNALS.A.ID(AID'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.R.ID(RID'range)    ,RID    ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("RID    ") &
                            HEX_TO_STRING(RID   ) & " /= " & HEX_TO_STRING(SIGNALS.R.ID(RID'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.W.ID(WID'range)    ,WID    ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("WID    ") &
                            HEX_TO_STRING(WID   ) & " /= " & HEX_TO_STRING(SIGNALS.W.ID(WID'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.B.ID(BID'range)    ,BID    ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("BID    ") &
                            HEX_TO_STRING(BID   ) & " /= " & HEX_TO_STRING(SIGNALS.B.ID(BID'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.A.ADDR(ADDR'range) ,ADDR   ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("ADDR   ") &
                            HEX_TO_STRING(ADDR  ) & " /= " & HEX_TO_STRING(SIGNALS.A.ADDR(ADDR'range) ));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.A.WRITE            ,AWRITE ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("AWRITE ") &
                            BIN_TO_STRING(AWRITE) & " /= " & BIN_TO_STRING(SIGNALS.A.WRITE));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.A.LEN              ,ALEN   ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("ALEN   ") &
                            BIN_TO_STRING(ALEN  ) & " /= " & BIN_TO_STRING(SIGNALS.A.LEN));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.A.SIZE             ,ASIZE  ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("ASIZE  ") &
                            BIN_TO_STRING(ASIZE ) & " /= " & BIN_TO_STRING(SIGNALS.A.SIZE));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.A.BURST            ,ABURST ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("ABURST ") &
                            BIN_TO_STRING(ABURST) & " /= " & BIN_TO_STRING(SIGNALS.A.BURST));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.A.LOCK             ,ALOCK  ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("ALOCK  ") &
                            BIN_TO_STRING(ALOCK ) & " /= " & BIN_TO_STRING(SIGNALS.A.LOCK));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.A.CACHE            ,ACACHE ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("ACACHE ") &
                            BIN_TO_STRING(ACACHE) & " /= " & BIN_TO_STRING(SIGNALS.A.CACHE));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.A.PROT             ,APROT  ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("APROT  ") &
                            BIN_TO_STRING(APROT ) & " /= " & BIN_TO_STRING(SIGNALS.A.PROT));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.R.DATA(RDATA'range),RDATA  ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("RDATA  ") &
                            HEX_TO_STRING(RDATA ) & " /= " & HEX_TO_STRING(SIGNALS.R.DATA(RDATA'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.R.LAST             ,RLAST  ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("RLAST  ") &
                            BIN_TO_STRING(RLAST ) & " /= " & BIN_TO_STRING(SIGNALS.R.LAST));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.R.RESP             ,RRESP  ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("RRESP  ") &
                            BIN_TO_STRING(RRESP ) & " /= " & BIN_TO_STRING(SIGNALS.R.RESP));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.W.DATA(WDATA'range),WDATA  ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("WDATA  ") &
                            HEX_TO_STRING(WDATA ) & " /= " & HEX_TO_STRING(SIGNALS.W.DATA(WDATA'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.W.LAST             ,WLAST  ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("WLAST  ") &
                            BIN_TO_STRING(WLAST ) & " /= " & BIN_TO_STRING(SIGNALS.W.LAST));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.W.STRB(WSTRB'range),WSTRB  ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("WSTRB  ") &
                            BIN_TO_STRING(WSTRB ) & " /= " & BIN_TO_STRING(SIGNALS.W.STRB(WSTRB'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(SIGNALS.B.RESP             ,BRESP  ) = FALSE) then
            REPORT_MISMATCH(SELF.vocal, string'("BRESP  ") &
                            BIN_TO_STRING(BRESP ) & " /= " & BIN_TO_STRING(SIGNALS.B.RESP));
            count := count + 1;
        end if;
        MATCH := (count = 0);
    end procedure;
end AXI4_CORE;
