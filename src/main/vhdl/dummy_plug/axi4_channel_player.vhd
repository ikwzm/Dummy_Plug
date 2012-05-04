-----------------------------------------------------------------------------------
--!     @file    axi4_channel_player.vhd
--!     @brief   AXI4 A/R/W/B Channel Dummy Plug Player.
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
use     DUMMY_PLUG.SYNC.SYNC_REQ_VECTOR;
use     DUMMY_PLUG.SYNC.SYNC_ACK_VECTOR;
use     DUMMY_PLUG.SYNC.SYNC_PLUG_NUM_TYPE;
-----------------------------------------------------------------------------------
--! @brief   AXI4_CHANNEL_PLAYER :
-----------------------------------------------------------------------------------
entity  AXI4_CHANNEL_PLAYER is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        SCENARIO_FILE   : --! @brief シナリオファイルの名前.
                          STRING;
        CHANNEL         : --! @brief チャネル識別子.
                          --!      * 'M' 'A' 'W' 'R' 'B' の何れかを指定する.
                          CHARACTER := 'A';
        MASTER          : --! @brief マスターモードを指定する.
                          boolean   := FALSE;
        SLAVE           : --! @brief スレーブモードを指定する.
                          boolean   := FALSE;
        READ            : --! @brief リードモードを指定する.
                          boolean   := TRUE;
        WRITE           : --! @brief ライトモードを指定する.
                          boolean   := TRUE;
        NAME            : --! @brief ダミープラグの固有名詞.
                          STRING;
        FULL_NAME       : --! @brief メッセージ出力用の固有名詞.
                          STRING;
        OUTPUT_DELAY    : --! @brief 出力信号遅延時間
                          time;
        AXI4_ID_WIDTH   : --! @brief AXI4 IS WIDTH :
                          integer :=  4;
        AXI4_A_WIDTH    : --! @brief AXI4 ADDR WIDTH :
                          integer := 32;
        AXI4_W_WIDTH    : --! @brief AXI4 WRITE DATA WIDTH :
                          integer := 32;
        AXI4_R_WIDTH    : --! @brief AXI4 READ DATA WIDTH :
                          integer := 32;
        SYNC_WIDTH      : --! @brief 外部シンクロ用信号の本数.
                          integer :=  1;
        SYNC_LOCAL_PORT : --! @brief ローカル同期信号のポート番号.
                          integer := 0;
        SYNC_LOCAL_WAIT : --! @brief ローカル同期時のウェイトクロック数.
                          integer := 2;
        FINISH_ABORT    : --! @brief FINISH コマンド実行時にシミュレーションを
                          --!        アボートするかどうかを指定するフラグ.
                          boolean := false
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
        SYNC_REQ        : out   SYNC_REQ_VECTOR(SYNC_WIDTH-1 downto 0);
        SYNC_ACK        : in    SYNC_ACK_VECTOR(SYNC_WIDTH-1 downto 0) := (others => '0');
        SYNC_LOCAL_REQ  : out   SYNC_REQ_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT);
        SYNC_LOCAL_ACK  : in    SYNC_ACK_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT);
        FINISH          : out   std_logic
    );
end AXI4_CHANNEL_PLAYER;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
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
architecture MODEL of AXI4_CHANNEL_PLAYER is
    -------------------------------------------------------------------------------
    --! 
    -------------------------------------------------------------------------------
    procedure  MATCH_AXI4_CHANNEL(
                 SIGNALS    : in    AXI4_CHANNEL_SIGNAL_TYPE;
                 MATCH      : out   boolean
    ) is
    begin 
        MATCH_AXI4_CHANNEL(
            SIGNALS    => SIGNALS ,
            MATCH      => MATCH   ,
            AVALID     => AVALID_I,
            ADDR       => ADDR_I  ,
            AWRITE     => AWRITE_I,
            ALEN       => ALEN_I  ,
            ASIZE      => ASIZE_I ,
            ABURST     => ABURST_I,
            ALOCK      => ALOCK_I ,
            ACACHE     => ACACHE_I,
            APROT      => APROT_I ,
            AID        => AID_I   ,
            AREADY     => AREADY_I,
            RVALID     => RVALID_I,
            RLAST      => RLAST_I ,
            RDATA      => RDATA_I ,
            RRESP      => RRESP_I ,
            RID        => RID_I   ,
            RREADY     => RREADY_I,
            WVALID     => WVALID_I,
            WLAST      => WLAST_I ,
            WDATA      => WDATA_I ,
            WSTRB      => WSTRB_I ,
            WID        => WID_I   ,
            WREADY     => WREADY_I,
            BVALID     => BVALID_I,
            BRESP      => BRESP_I ,
            BID        => BID_I   ,
            BREADY     => BREADY_I
         );
    end procedure;
    -------------------------------------------------------------------------------
    --! 
    -------------------------------------------------------------------------------
    procedure  MATCH_AXI4_CHANNEL(
        variable CORE       : inout CORE_TYPE;
                 SIGNALS    : in    AXI4_CHANNEL_SIGNAL_TYPE;
                 MATCH      : out   boolean
    ) is
    begin 
        MATCH_AXI4_CHANNEL(
            SELF       => CORE    ,
            SIGNALS    => SIGNALS ,
            MATCH      => MATCH   ,
            AVALID     => AVALID_I,
            ADDR       => ADDR_I  ,
            AWRITE     => AWRITE_I,
            ALEN       => ALEN_I  ,
            ASIZE      => ASIZE_I ,
            ABURST     => ABURST_I,
            ALOCK      => ALOCK_I ,
            ACACHE     => ACACHE_I,
            APROT      => APROT_I ,
            AID        => AID_I   ,
            AREADY     => AREADY_I,
            RVALID     => RVALID_I,
            RLAST      => RLAST_I ,
            RDATA      => RDATA_I ,
            RRESP      => RRESP_I ,
            RID        => RID_I   ,
            RREADY     => RREADY_I,
            WVALID     => WVALID_I,
            WLAST      => WLAST_I ,
            WDATA      => WDATA_I ,
            WSTRB      => WSTRB_I ,
            WID        => WID_I   ,
            WREADY     => WREADY_I,
            BVALID     => BVALID_I,
            BRESP      => BRESP_I ,
            BID        => BID_I   ,
            BREADY     => BREADY_I
         );
    end procedure;
begin 
    -------------------------------------------------------------------------------
    -- チャネルプロシージャ
    -------------------------------------------------------------------------------
    process
        ---------------------------------------------------------------------------
        -- 各種変数の定義.
        ---------------------------------------------------------------------------
        constant  CHANNEL_NAME  : STRING(1 to 1) := (1 => CHANNEL);
        file      stream        : TEXT;
        variable  core          : CORE_TYPE;
        variable  operation     : OPERATION_TYPE;
        variable  keyword       : STRING(1 to 5);
        constant  KEY_CHANNEL   : STRING(1 to 5) := (1 => CHANNEL, others => ' ');
        constant  KEY_SAY       : STRING(1 to 5) := "SAY  ";
        constant  KEY_SYNC      : STRING(1 to 5) := "SYNC ";
        constant  KEY_WAIT      : STRING(1 to 5) := "WAIT ";
        constant  KEY_CHECK     : STRING(1 to 5) := "CHECK";
        constant  KEY_PORT      : STRING(1 to 5) := "PORT ";
        constant  KEY_LOCAL     : STRING(1 to 5) := "LOCAL";
        constant  KEY_TIMEOUT   : STRING(1 to 5) := "TIMEO";
        variable  out_signals   : AXI4_CHANNEL_SIGNAL_TYPE;
        variable  chk_signals   : AXI4_CHANNEL_SIGNAL_TYPE;
        ---------------------------------------------------------------------------
        --! @brief 
        ---------------------------------------------------------------------------
        procedure SCAN_INTEGER(VAL: out integer;LEN: out integer) is
        begin
            STRING_TO_INTEGER(core.str_buf(1 to core.str_len), VAL, LEN);
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief 
        ---------------------------------------------------------------------------
        procedure EXECUTE_UNDEFINED_MAP_KEY(KEY:in STRING) is
        begin
            EXECUTE_UNDEFINED_MAP_KEY(core, stream, KEY);
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief 
        ---------------------------------------------------------------------------
        procedure EXECUTE_UNDEFINED_SCALAR(KEY:in STRING) is
        begin
            EXECUTE_UNDEFINED_SCALAR(core, stream, KEY);
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief チャネル信号変数の初期化.
        ---------------------------------------------------------------------------
        function  GEN_INIT_SIGNALS return AXI4_CHANNEL_SIGNAL_TYPE is
            variable value : AXI4_CHANNEL_SIGNAL_TYPE;
        begin
            if (MASTER) then
                case CHANNEL is
                    when 'A'    => value.A       := AXI4_A_CHANNEL_SIGNAL_NULL;
                                   value.A.READY := '-';
                                   value.R       := AXI4_R_CHANNEL_SIGNAL_DONTCARE;
                                   value.W       := AXI4_W_CHANNEL_SIGNAL_DONTCARE;
                                   value.B       := AXI4_B_CHANNEL_SIGNAL_DONTCARE;
                    when 'W'    => value.A       := AXI4_A_CHANNEL_SIGNAL_DONTCARE;
                                   value.R       := AXI4_R_CHANNEL_SIGNAL_DONTCARE;
                                   value.W       := AXI4_W_CHANNEL_SIGNAL_NULL;
                                   value.W.READY := '-';
                                   value.B       := AXI4_B_CHANNEL_SIGNAL_DONTCARE;
                    when 'R'    => value.A       := AXI4_A_CHANNEL_SIGNAL_DONTCARE;
                                   value.R       := AXI4_R_CHANNEL_SIGNAL_DONTCARE;
                                   value.R.READY := '0';
                                   value.W       := AXI4_W_CHANNEL_SIGNAL_DONTCARE;
                                   value.B       := AXI4_B_CHANNEL_SIGNAL_DONTCARE;
                    when 'B'    => value.A       := AXI4_A_CHANNEL_SIGNAL_DONTCARE;
                                   value.R       := AXI4_R_CHANNEL_SIGNAL_DONTCARE;
                                   value.W       := AXI4_W_CHANNEL_SIGNAL_DONTCARE;
                                   value.B       := AXI4_B_CHANNEL_SIGNAL_DONTCARE;
                                   value.B.READY := '0';
                    when others => value         := AXI4_CHANNEL_SIGNAL_DONTCARE;
                end case;
            end if;
            if (SLAVE) then
                case CHANNEL is
                    when 'A'    => value.A       := AXI4_A_CHANNEL_SIGNAL_DONTCARE;
                                   value.A.READY := '0';
                                   value.R       := AXI4_R_CHANNEL_SIGNAL_DONTCARE;
                                   value.W       := AXI4_W_CHANNEL_SIGNAL_DONTCARE;
                                   value.B       := AXI4_B_CHANNEL_SIGNAL_DONTCARE;
                    when 'W'    => value.A       := AXI4_A_CHANNEL_SIGNAL_DONTCARE;
                                   value.R       := AXI4_R_CHANNEL_SIGNAL_DONTCARE;
                                   value.W       := AXI4_W_CHANNEL_SIGNAL_DONTCARE;
                                   value.W.READY := '0';
                                   value.B       := AXI4_B_CHANNEL_SIGNAL_DONTCARE;
                    when 'R'    => value.A       := AXI4_A_CHANNEL_SIGNAL_DONTCARE;
                                   value.R       := AXI4_R_CHANNEL_SIGNAL_NULL;
                                   value.R.READY := '-';
                                   value.W       := AXI4_W_CHANNEL_SIGNAL_DONTCARE;
                                   value.B       := AXI4_B_CHANNEL_SIGNAL_DONTCARE;
                    when 'B'    => value.A       := AXI4_A_CHANNEL_SIGNAL_DONTCARE;
                                   value.R       := AXI4_R_CHANNEL_SIGNAL_DONTCARE;
                                   value.W       := AXI4_W_CHANNEL_SIGNAL_DONTCARE;
                                   value.B       := AXI4_B_CHANNEL_SIGNAL_NULL;
                                   value.B.READY := '-';
                    when others => value         := AXI4_CHANNEL_SIGNAL_DONTCARE;
                end case;
            end if;
            return value;
        end function;
        constant  INIT_SIGNALS  : AXI4_CHANNEL_SIGNAL_TYPE := GEN_INIT_SIGNALS;
        ---------------------------------------------------------------------------
        --! @brief 信号変数(out_signals)の値をポートに出力するサブプログラム.
        ---------------------------------------------------------------------------
        procedure EXECUTE_OUTPUT is
        begin 
            if (MASTER) then
                case CHANNEL is
                    when 'A' =>
                        if (READ or WRITE) then
                            ADDR_O   <= out_signals.A.ADDR(ADDR_O'range) after OUTPUT_DELAY;
                            AWRITE_O <= out_signals.A.WRITE              after OUTPUT_DELAY;
                            AVALID_O <= out_signals.A.VALID              after OUTPUT_DELAY;
                            ALEN_O   <= out_signals.A.LEN                after OUTPUT_DELAY;
                            ASIZE_O  <= out_signals.A.SIZE               after OUTPUT_DELAY;
                            ABURST_O <= out_signals.A.BURST              after OUTPUT_DELAY;
                            ALOCK_O  <= out_signals.A.LOCK               after OUTPUT_DELAY;
                            ACACHE_O <= out_signals.A.CACHE              after OUTPUT_DELAY;
                            APROT_O  <= out_signals.A.PROT               after OUTPUT_DELAY;
                            AID_O    <= out_signals.A.id(AID_O'range)    after OUTPUT_DELAY;
                        end if;
                    when 'W' =>
                        if (WRITE) then
                            WDATA_O  <= out_signals.W.DATA(WDATA_O'range)after OUTPUT_DELAY;
                            WLAST_O  <= out_signals.W.LAST               after OUTPUT_DELAY;
                            WSTRB_O  <= out_signals.W.STRB(WSTRB_O'range)after OUTPUT_DELAY;
                            WID_O    <= out_signals.W.ID(WID_O'range)    after OUTPUT_DELAY;
                            WVALID_O <= out_signals.W.VALID              after OUTPUT_DELAY;
                        end if;
                    when 'R' =>
                        if (READ) then
                            RREADY_O <= out_signals.R.READY              after OUTPUT_DELAY;
                        end if;
                    when 'B' =>
                        if (WRITE) then
                            BREADY_O <= out_signals.B.READY              after OUTPUT_DELAY;
                        end if;
                    when others =>
                        null;
                end case;
            end if;
            if (SLAVE) then
                case CHANNEL is
                    when 'A' =>
                        if (READ or WRITE) then
                            AREADY_O <= out_signals.A.READY              after OUTPUT_DELAY;
                        end if;
                    when 'W' =>
                        if (WRITE) then
                            WREADY_O <= out_signals.W.READY              after OUTPUT_DELAY;
                        end if;
                    when 'R' =>
                        if (READ) then
                            RDATA_O  <= out_signals.R.DATA(RDATA_O'range)after OUTPUT_DELAY;
                            RRESP_O  <= out_signals.R.RESP               after OUTPUT_DELAY;
                            RLAST_O  <= out_signals.R.LAST               after OUTPUT_DELAY;
                            RID_O    <= out_signals.R.ID(RID_O'range)    after OUTPUT_DELAY;
                            RVALID_O <= out_signals.R.VALID              after OUTPUT_DELAY;
                        end if;
                    when 'B' =>
                        if (WRITE) then
                            BRESP_O  <= out_signals.B.RESP               after OUTPUT_DELAY;
                            BID_O    <= out_signals.B.ID(BID_O'range)    after OUTPUT_DELAY;
                            BVALID_O <= out_signals.B.VALID              after OUTPUT_DELAY;
                        end if;
                    when others =>
                        null;
                end case;
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief ローカル同期オペレーション.
        ---------------------------------------------------------------------------
        procedure LOCAL_SYNC is
            variable sync_count : SYNC_REQ_VECTOR(SYNC_LOCAL_REQ'range);
        begin
            REPORT_DEBUG(core, string'("LOCAL_SYNC BEGIN"));
            sync_count(SYNC_LOCAL_PORT) := SYNC_LOCAL_WAIT;
            SYNC_BEGIN(SYNC_LOCAL_REQ,                 sync_count);
            REPORT_DEBUG(core, string'("LOCAL_SYNC WAIT"));
            SYNC_END  (SYNC_LOCAL_REQ, SYNC_LOCAL_ACK, sync_count);
            REPORT_DEBUG(core, string'("LOCAL_SYNC END"));
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief CHECKオペレーション.信号が指定された値になっているかチェック.
        ---------------------------------------------------------------------------
        procedure EXECUTE_CHECK is
            variable read_good  : boolean;
            variable skip_good  : boolean;
            variable next_event : EVENT_TYPE;
            variable match      : boolean;
        begin
            SEEK_EVENT(core, stream, next_event);
            case next_event is
                when EVENT_MAP_BEGIN =>
                    READ_EVENT(core, stream, EVENT_MAP_BEGIN, read_good);
                    chk_signals := AXI4_CHANNEL_SIGNAL_DONTCARE;
                    READ_AXI4_CHANNEL(
                        SELF       => core            ,  -- In :
                        STREAM     => stream          ,  -- I/O:
                        CHANNEL    => CHANNEL         ,  -- In :
                        R_ENABLE   => READ            ,  -- In :
                        W_ENABLE   => WRITE           ,  -- In :
                        ID_WIDTH   => AXI4_ID_WIDTH   ,  -- In :
                        A_WIDTH    => AXI4_A_WIDTH    ,  -- In :
                        R_WIDTH    => AXI4_R_WIDTH    ,  -- In :
                        W_WIDTH    => AXI4_W_WIDTH    ,  -- In :
                        SIGNALS    => chk_signals     ,  -- I/O:
                        CURR_EVENT => next_event         -- Out:
                    );
                    assert (next_event = EVENT_MAP_END)
                        report "Internal Read Error in " & FULL_NAME & " EXECUTE_CHECK"
                        severity FAILURE;
                    READ_EVENT(core, stream, EVENT_MAP_END, read_good);
                    MATCH_AXI4_CHANNEL(core, chk_signals, match);
                when others =>
                    SKIP_EVENT(core, stream, next_event,    skip_good);
                    -- ERROR
            end case;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  WAITオペレーション. 指定された条件まで待機.
        ---------------------------------------------------------------------------
        procedure EXECUTE_WAIT is
            variable read_good  : boolean;
            variable skip_good  : boolean;
            variable next_event : EVENT_TYPE;
            variable wait_count : integer;
            variable scan_len   : integer;
            variable timeout    : integer;
            variable match      : boolean;
        begin
            timeout := 10000000;
            SEEK_EVENT(core, stream, next_event);
            case next_event is
                when EVENT_SCALAR =>
                    READ_EVENT(core, stream, EVENT_SCALAR, read_good);
                    SCAN_INTEGER(wait_count, scan_len);
                    if (read_good = FALSE or scan_len = 0) then
                        wait_count := 1;
                    end if;
                    if (wait_count > 0) then
                        for i in 1 to wait_count loop
                            wait until (ACLK'event and ACLK = '1');
                        end loop;
                    end if;
                    wait_count := 0;
                when EVENT_MAP_BEGIN =>
                    READ_EVENT(core, stream, EVENT_MAP_BEGIN, read_good);
                    chk_signals := AXI4_CHANNEL_SIGNAL_DONTCARE;
                    MAP_LOOP: loop
                        READ_AXI4_CHANNEL(
                            SELF       => core            ,  -- In :
                            STREAM     => stream          ,  -- I/O:
                            CHANNEL    => CHANNEL         ,  -- In :
                            R_ENABLE   => READ            ,  -- In :
                            W_ENABLE   => WRITE           ,  -- In :
                            ID_WIDTH   => AXI4_ID_WIDTH   ,  -- In :
                            A_WIDTH    => AXI4_A_WIDTH    ,  -- In :
                            R_WIDTH    => AXI4_R_WIDTH    ,  -- In :
                            W_WIDTH    => AXI4_W_WIDTH    ,  -- In :
                            SIGNALS    => chk_signals     ,  -- I/O:
                            CURR_EVENT => next_event         -- Out:
                        );
                        case next_event is
                            when EVENT_SCALAR  =>
                                COPY_KEY_WORD(core, keyword);
                                case keyword is
                                    when KEY_TIMEOUT =>
                                        SEEK_EVENT(core, stream, next_event);
                                        read_good := TRUE;
                                        scan_len  := 0;
                                        if (next_event = EVENT_SCALAR) then
                                            READ_EVENT(core, stream, next_event, read_good);
                                            SCAN_INTEGER(timeout, scan_len);
                                        end if;
                                        if (read_good = FALSE or scan_len = 0) then
                                            timeout := 10000000;
                                        end if;
                                    when others    => EXECUTE_UNDEFINED_MAP_KEY(keyword);
                                end case;
                            when EVENT_MAP_END =>
                                exit MAP_LOOP;
                            when others        =>
                                SKIP_EVENT(core, stream, next_event,    skip_good);
                                -- ERROR
                        end case;
                    end loop;
                    CHK_LOOP:loop
                        wait until (ACLK'event and ACLK = '1');
                        MATCH_AXI4_CHANNEL(chk_signals, match);
                        exit when(match);
                        timeout := timeout - 1;
                        if (timeout < 0) then
                            EXECUTE_ABORT(core, string'("WAIT Time Out!"));
                        end if;
                    end loop;
                when others =>
                    SKIP_EVENT(core, stream, next_event,    skip_good);
                    -- ERROR
            end case;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  SYNCオペレーション. 
        ---------------------------------------------------------------------------
        procedure EXECUTE_SYNC(operation: in OPERATION_TYPE) is
            variable read_good  : boolean;
            variable skip_good  : boolean;
            variable next_event : EVENT_TYPE;
            variable port_num   : integer;
            variable wait_num   : integer;
            variable scan_len   : integer;
            variable match      : boolean;
            variable map_level  : integer;
            type     STATE_TYPE is (STATE_NULL, STATE_SCALAR_PORT,
                                    STATE_MAP_KEY, STATE_MAP_PORT, STATE_MAP_WAIT, STATE_ERROR);
            variable state      : STATE_TYPE;
        begin
            port_num := 0;
            wait_num := 2;
            case operation is
                when OP_MAP       =>
                    map_level := 0;
                    state     := STATE_SCALAR_PORT;
                    OP_MAP_LOOP: loop
                        SEEK_EVENT(core, stream, next_event);
                        case next_event is
                            when EVENT_MAP_BEGIN =>
                                READ_EVENT(core, stream, next_event, read_good);
                                map_level := map_level + 1;
                                state     := STATE_MAP_KEY;
                            when EVENT_MAP_END   =>
                                READ_EVENT(core, stream, next_event, read_good);
                                map_level := map_level - 1;
                                state     := STATE_NULL;
                            when EVENT_SCALAR    =>
                                READ_EVENT(core, stream, next_event, read_good);
                                case state is
                                    when STATE_MAP_KEY =>
                                        COPY_KEY_WORD(core, keyword);
                                        case keyword is
                                            when KEY_PORT => state := STATE_MAP_PORT;
                                            when KEY_WAIT => state := STATE_MAP_WAIT;
                                            when others   => state := STATE_ERROR;
                                        end case;
                                    when STATE_SCALAR_PORT | STATE_MAP_PORT =>
                                        COPY_KEY_WORD(core, keyword);
                                        if    (keyword = KEY_LOCAL) then
                                            port_num := -1;
                                        else
                                            SCAN_INTEGER(port_num, scan_len);
                                            if (SYNC_REQ'low <= port_num and port_num <= SYNC_REQ'high) then
                                                port_num := -2;
                                            end if;
                                        end if;
                                        if (state = STATE_MAP_PORT) then
                                            state := STATE_MAP_KEY;
                                        else
                                            state := STATE_NULL;
                                        end if;
                                    when STATE_MAP_WAIT =>
                                        SCAN_INTEGER(wait_num, scan_len);
                                        state := STATE_MAP_KEY;
                                    when others =>
                                        state := STATE_MAP_KEY;
                                end case;
                            when others =>
                                SKIP_EVENT(core, stream, next_event, skip_good);
                        end case;
                        exit when (map_level = 0);
                    end loop;
                    assert (next_event = EVENT_MAP_END)
                        report "Internal Read Error in " & FULL_NAME & " EXECUTE_WAIT"
                        severity FAILURE;
                    READ_EVENT(core, stream, EVENT_MAP_END, read_good);
                when OP_DOC_BEGIN => null;
                when OP_SCALAR    => null;
                when others       => null;
            end case;
            LOCAL_SYNC;
            if (port_num >= 0) then
                CORE_SYNC(core, port_num, wait_num, SYNC_REQ, SYNC_ACK);
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief チャネルオペレーション(SCALAR)実行サブプログラム.
        ---------------------------------------------------------------------------
        procedure EXECUTE_CHANNEL_SCALAR_OPERATION is
            variable skip_good : boolean;
        begin 
            SKIP_EVENT(core, stream, EVENT_SCALAR, skip_good);
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief チャネルオペレーション(MAP)実行サブプログラム.
        ---------------------------------------------------------------------------
        procedure EXECUTE_CHANNEL_MAP_OPERATION is
            variable next_event : EVENT_TYPE;
            variable read_good  : boolean;
            variable skip_good  : boolean;
        begin
            READ_EVENT(core, stream, EVENT_MAP_BEGIN, read_good);
            MAP_LOOP: loop
                READ_AXI4_CHANNEL(
                    SELF       => core            ,  -- In :
                    STREAM     => stream          ,  -- I/O:
                    CHANNEL    => CHANNEL         ,  -- In :
                    R_ENABLE   => READ            ,  -- In :
                    W_ENABLE   => WRITE           ,  -- In :
                    ID_WIDTH   => AXI4_ID_WIDTH   ,  -- In :
                    A_WIDTH    => AXI4_A_WIDTH    ,  -- In :
                    R_WIDTH    => AXI4_R_WIDTH    ,  -- In :
                    W_WIDTH    => AXI4_W_WIDTH    ,  -- In :
                    SIGNALS    => out_signals     ,  -- I/O:
                    CURR_EVENT => next_event         -- Out:
                );
                EXECUTE_OUTPUT;
                case next_event is
                    when EVENT_SCALAR  =>
                        COPY_KEY_WORD(core, keyword);
                        case keyword is
                            when KEY_WAIT  => EXECUTE_WAIT;
                            when KEY_CHECK => EXECUTE_CHECK;
                            when others    => EXECUTE_UNDEFINED_MAP_KEY(keyword);
                        end case;
                    when EVENT_MAP_END =>
                        exit MAP_LOOP;
                    when others        =>
                        SKIP_EVENT(core, stream, next_event,    skip_good);
                        -- ERROR
                end case;
            end loop;
        end procedure;
        ---------------------------------------------------------------------------
        -- チャネルオペレーションループ
        ---------------------------------------------------------------------------
        procedure EXECUTE_CHANNEL_OPERATION is
            variable next_event : EVENT_TYPE;
            variable read_good  : boolean;
            variable skip_good  : boolean;
            variable seq_level  : integer;
        begin
            seq_level := 0;
            SEQ_LOOP: loop
                SEEK_EVENT(core, stream, next_event);
                case next_event is
                    when EVENT_SEQ_BEGIN =>
                        READ_EVENT(core, stream, EVENT_SEQ_BEGIN, read_good);
                        seq_level := seq_level + 1;
                    when EVENT_SEQ_END   =>
                        READ_EVENT(core, stream, EVENT_SEQ_END,   read_good);
                        seq_level := seq_level - 1;
                    when EVENT_MAP_BEGIN =>
                        EXECUTE_CHANNEL_MAP_OPERATION;
                    when EVENT_SCALAR    =>
                        EXECUTE_CHANNEL_SCALAR_OPERATION;
                    when others          =>
                        SKIP_EVENT(core, stream, next_event,      skip_good);
                        -- ERROR
                end case;
                exit when (seq_level <= 0);
            end loop;
        end procedure;
    begin
        ---------------------------------------------------------------------------
        -- ダミープラグコアの初期化.
        ---------------------------------------------------------------------------
        CORE_INIT(
            SELF        => core,          --! 初期化するコア変数.
            NAME        => NAME,          --! コアの名前.
            VOCAL_NAME  => FULL_NAME,     --! 
            STREAM      => stream,        --! シナリオのストリーム.
            STREAM_NAME => SCENARIO_FILE, --! シナリオのストリーム名.
            OPERATION   => operation      --! コアのオペレーション.
        );
        ---------------------------------------------------------------------------
        -- 変数の初期化.
        ---------------------------------------------------------------------------
        out_signals := INIT_SIGNALS;
        chk_signals := INIT_SIGNALS;
        ---------------------------------------------------------------------------
        -- 信号の初期化
        ---------------------------------------------------------------------------
        SYNC_REQ       <= (0 =>10, others => 0);
        SYNC_LOCAL_REQ <= (        others => 0);
        FINISH         <= '0';
        EXECUTE_OUTPUT;
        core.debug := 0;
        ---------------------------------------------------------------------------
        -- メインオペレーションループ
        ---------------------------------------------------------------------------
        if (CHANNEL = 'M') then
            wait until(ACLK'event and ACLK = '1' and ARESETn = '1');
            while (operation /= OP_FINISH) loop
                READ_OPERATION(core, stream, operation, keyword);
                case operation is
                    when OP_DOC_BEGIN     => EXECUTE_SYNC(operation);
                    when OP_MAP    =>
                        case keyword is
                            when KEY_SAY   => EXECUTE_SAY (core, stream);
                            when KEY_SYNC  => EXECUTE_SYNC(operation);
                            when KEY_WAIT  => EXECUTE_WAIT;
                            when KEY_CHECK => EXECUTE_CHECK;
                            when others    => EXECUTE_SKIP(core, stream);
                        end case;
                    when OP_SCALAR =>
                        case keyword is
                            when KEY_SYNC  => EXECUTE_SYNC(operation);
                            when others    => null;
                        end case;
                    when OP_FINISH => exit;
                    when others    => null;
                end case;
            end loop;
        else
            while (operation /= OP_FINISH) loop
                READ_OPERATION(core, stream, operation, keyword);
                case operation is
                    when OP_DOC_BEGIN   => LOCAL_SYNC;
                    when OP_MAP         =>
                        if    (keyword = KEY_CHANNEL) then
                            EXECUTE_CHANNEL_OPERATION;
                        elsif (keyword = KEY_SYNC) then
                            LOCAL_SYNC;
                            EXECUTE_SKIP(core, stream);
                        else
                            EXECUTE_SKIP(core, stream);
                        end if;
                    when OP_SCALAR      =>
                        if (keyword = KEY_SYNC) then
                            LOCAL_SYNC;
                        else
                            EXECUTE_UNDEFINED_SCALAR(core, stream, keyword);
                        end if;
                    when OP_FINISH      => exit;
                    when others         => null;
                end case;
            end loop;
        end if;
        FINISH <= '1';
        if (FINISH_ABORT) then
            assert FALSE report "Simulation complete." severity FAILURE;
        end if;
        wait;
    end process;
end MODEL;
