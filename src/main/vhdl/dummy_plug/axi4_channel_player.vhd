-----------------------------------------------------------------------------------
--!     @file    axi4_channel_player.vhd
--!     @brief   AXI4 A/R/W/B Channel Dummy Plug Player.
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
use     DUMMY_PLUG.SYNC.SYNC_REQ_VECTOR;
use     DUMMY_PLUG.SYNC.SYNC_ACK_VECTOR;
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
        SYNC_REQ        : out   SYNC_REQ_VECTOR(SYNC_PORT downto SYNC_PORT);
        SYNC_ACK        : in    SYNC_ACK_VECTOR(SYNC_PORT downto SYNC_PORT)
    );
end AXI4_CHANNEL_PLAYER;
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
architecture MODEL of AXI4_CHANNEL_PLAYER is
    -------------------------------------------------------------------------------
    --! 
    -------------------------------------------------------------------------------
    procedure  MATCH_AXI4_CHANNEL(
        variable CORE       : inout CORE_TYPE;            --! コア変数.
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
begin 
    -------------------------------------------------------------------------------
    -- チャネルプロシージャ
    -------------------------------------------------------------------------------
    process
        ---------------------------------------------------------------------------
        -- 各種変数の定義.
        ---------------------------------------------------------------------------
        constant  CHANNEL_NAME  : STRING(1 to 1) := (1 => CHANNEL);
        constant  FULL_NAME     : STRING := NAME & "." & CHANNEL_NAME;
        file      stream        : TEXT;
        variable  core          : CORE_TYPE;
        variable  operation     : OPERATION_TYPE;
        variable  op_code       : STRING(1 to 3);
        constant  OP_MY         : STRING(1 to 3) := CHANNEL_NAME & "  ";
        variable  signals       : AXI4_CHANNEL_SIGNAL_TYPE;
        variable  key_word      : STRING(1 to 4);
        constant  KEY_WAIT      : STRING(1 to 4) := "WAIT";
        ---------------------------------------------------------------------------
        -- チャネル信号変数の初期化.
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
        -- 信号変数の値を出力するサブプログラム.
        ---------------------------------------------------------------------------
        procedure EXECUTE_OUTPUT is
        begin 
            if (MASTER) then
                case CHANNEL is
                    when 'A'    => ADDR_O   <= signals.A.ADDR(ADDR_O'range);
                                   AWRITE_O <= signals.A.WRITE;
                                   AVALID_O <= signals.A.VALID;
                                   ALEN_O   <= signals.A.LEN;
                                   ASIZE_O  <= signals.A.SIZE;
                                   ABURST_O <= signals.A.BURST;
                                   ALOCK_O  <= signals.A.LOCK;
                                   ACACHE_O <= signals.A.CACHE;
                                   APROT_O  <= signals.A.PROT;
                                   AID_O    <= signals.A.id(AID_O'range);
                    when 'W'    => WDATA_O  <= signals.W.DATA(WDATA_O'range);
                                   WLAST_O  <= signals.W.LAST;
                                   WSTRB_O  <= signals.W.STRB(WSTRB_O'range);
                                   WID_O    <= signals.W.ID(WID_O'range);
                                   WVALID_O <= signals.W.VALID;
                    when 'R'    => RREADY_O <= signals.R.READY;
                    when 'B'    => BREADY_O <= signals.B.READY;
                    when others => null;
                end case;
            end if;
            if (SLAVE) then
                case CHANNEL is
                    when 'A'    => AREADY_O <= signals.A.READY;
                    when 'W'    => WREADY_O <= signals.W.READY;
                    when 'R'    => RDATA_O  <= signals.R.DATA(RDATA_O'range);
                                   RRESP_O  <= signals.R.RESP;
                                   RLAST_O  <= signals.R.LAST;
                                   RID_O    <= signals.R.ID(RID_O'range);
                                   RVALID_O <= signals.R.VALID;
                    when 'B'    => BRESP_O  <= signals.B.RESP;
                                   BID_O    <= signals.B.ID(BID_O'range);
                                   BVALID_O <= signals.B.VALID;
                    when others => null;
                end case;
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        -- WAITオペレーション.
        ---------------------------------------------------------------------------
        procedure LOCAL_SYNC is
            variable sync_count : SYNC_REQ_VECTOR(SYNC_REQ'range);
        begin
            REPORT_DEBUG(core, string'("LOCAL_SYNC BEGIN"));
            sync_count(SYNC_PORT) := SYNC_WAIT;
            SYNC_BEGIN(SYNC_REQ,           sync_count);
            REPORT_DEBUG(core, string'("LOCAL_SYNC WAIT"));
            SYNC_END  (SYNC_REQ, SYNC_ACK, sync_count);
            REPORT_DEBUG(core, string'("LOCAL_SYNC END"));
        end procedure;
        ---------------------------------------------------------------------------
        -- WAITオペレーション.
        ---------------------------------------------------------------------------
        procedure EXECUTE_WAIT is
            variable read_good  :       boolean;
            variable skip_good  :       boolean;
            variable next_event :       EVENT_TYPE;
            variable signals    :       AXI4_CHANNEL_SIGNAL_TYPE;
            variable wait_count :       integer;
            variable match      :       boolean;
        begin 
            SEEK_EVENT(core, stream, next_event);
            case next_event is
                when EVENT_SCALAR =>
                    READ_INTEGER(core.reader, stream, wait_count, read_good);
                    if (read_good = FALSE) then
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
                    signals := AXI4_CHANNEL_SIGNAL_DONTCARE;
                    READ_AXI4_CHANNEL(
                        SELF       => core            ,  -- In :
                        STREAM     => stream          ,  -- I/O:
                        CHANNEL    => CHANNEL         ,  -- In :
                        ID_WIDTH   => AXI4_ID_WIDTH   ,  -- In :
                        A_WIDTH    => AXI4_A_WIDTH    ,  -- In :
                        R_WIDTH    => AXI4_R_WIDTH    ,  -- In :
                        W_WIDTH    => AXI4_W_WIDTH    ,  -- In :
                        SIGNALS    => signals         ,  -- I/O:
                        CURR_EVENT => next_event         -- Out:
                    );
                    assert (next_event = EVENT_MAP_END)
                        report "Internal Read Error in " & FULL_NAME & " EXECUTE_WAIT"
                        severity FAILURE;
                    READ_EVENT(core, stream, EVENT_MAP_END, read_good);
                    CHK_LOOP:loop
                        wait until (ACLK'event and ACLK = '1');
                        MATCH_AXI4_CHANNEL(core, signals, match);
                        exit when(match);
                    end loop;
                when others =>
                    SKIP_EVENT(core, stream, next_event,    skip_good);
                    -- ERROR
            end case;
        end procedure;
        ---------------------------------------------------------------------------
        -- チャネルオペレーション(SCALAR)
        ---------------------------------------------------------------------------
        procedure EXECUTE_SCALAR is
            variable skip_good : boolean;
        begin 
            SKIP_EVENT(core, stream, EVENT_SCALAR, skip_good);
        end procedure;
        ---------------------------------------------------------------------------
        -- チャネルオペレーション(MAP)
        ---------------------------------------------------------------------------
        procedure EXECUTE_MAP is
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
                    ID_WIDTH   => AXI4_ID_WIDTH   ,  -- In :
                    A_WIDTH    => AXI4_A_WIDTH    ,  -- In :
                    R_WIDTH    => AXI4_R_WIDTH    ,  -- In :
                    W_WIDTH    => AXI4_W_WIDTH    ,  -- In :
                    SIGNALS    => signals         ,  -- I/O:
                    CURR_EVENT => next_event         -- Out:
                );
                EXECUTE_OUTPUT;
                case next_event is
                    when EVENT_SCALAR  =>
                        COPY_KEY_WORD(core, key_word);
                        case key_word is
                            when KEY_WAIT => EXECUTE_WAIT;
                            when others   => EXECUTE_UNDEFINED_MAP_KEY(core, stream, key_word);
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
        procedure EXECUTE_CHANNEL_LOOP is
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
                        EXECUTE_MAP;
                    when EVENT_SCALAR    =>
                        EXECUTE_SCALAR;
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
        -- 信号の初期化
        ---------------------------------------------------------------------------
        SYNC_REQ <= (others => 0);
        signals := INIT_SIGNALS;
        EXECUTE_OUTPUT;
        ---------------------------------------------------------------------------
        -- メインオペレーションループ
        ---------------------------------------------------------------------------
        core.debug := 0;
        MAIN_LOOP: while (operation /= OP_FINISH) loop
            READ_OPERATION(core, stream, operation, op_code);
            case operation is
                when OP_DOC_BEGIN   => LOCAL_SYNC;
                when OP_MAP         =>
                    if (op_code = OP_MY) then
                        EXECUTE_CHANNEL_LOOP;
                    else
                        EXECUTE_SKIP(core, stream);
                    end if;
                when OP_SCALAR      => EXECUTE_UNDEFINED_SCALAR(core, stream, op_code);
                when OP_FINISH      => exit;
                when others         => null;
            end case;
        end loop;
        wait;
    end process;
end MODEL;
