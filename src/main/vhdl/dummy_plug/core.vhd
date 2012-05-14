-----------------------------------------------------------------------------------
--!     @file    core.vhd
--!     @brief   Core Package for Dummy Plug.
--!     @version 0.0.5
--!     @date    2012/5/15
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
use     DUMMY_PLUG.READER;
use     DUMMY_PLUG.VOCAL;
use     DUMMY_PLUG.SYNC;
-----------------------------------------------------------------------------------
--! @brief Dummy Plug のコアパッケージ.
-----------------------------------------------------------------------------------
package CORE is
    -------------------------------------------------------------------------------
    --! @brief オペレーションタイプ
    -------------------------------------------------------------------------------
    type      OPERATION_TYPE is (
              OP_INIT        ,--! コアオペレーションの開始.
              OP_DOC_BEGIN   ,--! シナリオのブロック開始オペレーション.
              OP_DOC_END     ,--! シナリオのブロック終了オペレーション.
              OP_MAP         ,--! マップオペレーション.
              OP_SCALAR      ,--! スカラーオペレーション.
              OP_FINISH       --! コアオペレーションの終了.
    );
    -------------------------------------------------------------------------------
    --! @brief オペレーション処理状態タイプ
    -------------------------------------------------------------------------------
    type      STATE_TYPE is (
              STATE_NULL     , --! 初期済み状態.
              STATE_STREAM   , --!
              STATE_DOCUMENT , --!
              STATE_TOP_SEQ  , --! コア名チェックモード.
              STATE_OP_MAP   , --! マップオペレーションモード.
              STATE_OP_SCALAR, --! スカラーオペレーションモード.
              STATE_MAP_VAL  , --! 
              STATE_MAP_SEQ  , --! 
              STATE_MAP_END  , --! 
              STATE_SEQ_VAL  , --!
              STATE_SEQ_SKIP , --!
              STATE_FINISH     --!
    );
    -------------------------------------------------------------------------------
    --! @brief ステータスレポートタイプ.
    -------------------------------------------------------------------------------
    type      REPORT_STATUS_TYPE is record
        valid               : boolean;
        warning_count       : integer;
        mismatch_count      : integer;
        error_count         : integer;
        failure_count       : integer;
    end record;
    constant  REPORT_STATUS_NULL : REPORT_STATUS_TYPE := (
        valid               => FALSE,
        warning_count       => 0,
        mismatch_count      => 0,
        error_count         => 0,
        failure_count       => 0
    );
    type      REPORT_STATUS_VECTOR is array (integer range <>) of  REPORT_STATUS_TYPE;
    -------------------------------------------------------------------------------
    --! @brief スクラッチ用文字列領域の大きさの定義.
    -------------------------------------------------------------------------------
    constant  STR_BUF_SIZE  : integer := 1024;
    -------------------------------------------------------------------------------
    --! @brief コアの各種状態を保持する構造体.
    -------------------------------------------------------------------------------
    type      CORE_TYPE is record
        name                : LINE;                       --! インスタンス名を保持.
        reader              : READER.READER_TYPE;         --! リーダー用変数.
        vocal               : VOCAL.VOCAL_TYPE;           --! ボーカル用変数.
        str_buf             : STRING(1 to STR_BUF_SIZE);  --! スクラッチ用文字列バッファ.
        str_len             : integer;                    --! str_bufに格納されている文字数.
        prev_state          : STATE_TYPE;                 --! 一つ前の状態.
        curr_state          : STATE_TYPE;                 --! 現在の状態.
        report_status       : REPORT_STATUS_TYPE;         --! 各種状態をレポートする変数.
        debug               : integer;                    --! デバッグ用変数.
    end record;
    -------------------------------------------------------------------------------
    --! @brief コア変数の初期化用定数を生成する関数.
    -------------------------------------------------------------------------------
    function  NEW_CORE(
                 NAME       : STRING;                     --! コアの識別名.
                 STREAM_NAME: STRING                      --! シナリオのストリーム名.
    ) return CORE_TYPE;
    -------------------------------------------------------------------------------
    --! @brief コア変数の初期化用定数を生成する関数.
    -------------------------------------------------------------------------------
    function  NEW_CORE(
                 NAME       : STRING;                     --! コアの識別名.
                 VOCAL_NAME : STRING;                     --! メッセージ用の識別名.
                 STREAM_NAME: STRING                      --! シナリオのストリーム名.
    ) return CORE_TYPE;
    -------------------------------------------------------------------------------
    --! @brief コア変数の初期化サブプログラム.
    -------------------------------------------------------------------------------
    procedure CORE_INIT(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
                 NAME       : in    STRING;               --! コアの識別名.
        file     STREAM     :       TEXT;                 --! シナリオのストリーム.
                 STREAM_NAME: in    STRING;               --! シナリオのストリーム名.
        variable OPERATION  : out   OPERATION_TYPE        --! オペレーションコマンド.
    );
    -------------------------------------------------------------------------------
    --! @brief コア変数の初期化サブプログラム.
    -------------------------------------------------------------------------------
    procedure CORE_INIT(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
                 NAME       : in    STRING;               --! コアの識別名.
                 VOCAL_NAME :       STRING;               --! メッセージ用の識別名.
        file     STREAM     :       TEXT;                 --! シナリオのストリーム.
                 STREAM_NAME: in    STRING;               --! シナリオのストリーム名.
        variable OPERATION  : out   OPERATION_TYPE        --! オペレーションコマンド.
    );
    -------------------------------------------------------------------------------
    --! @brief コアからオペレーションコマンドを読むサブプログラム.
    -------------------------------------------------------------------------------
    procedure READ_OPERATION(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! シナリオのストリーム.
        variable OPERATION  : out   OPERATION_TYPE;       --! オペレーションコマンド.
        variable OP_WORD    : out   string                --! オペレーションキーワード.
    );
    -------------------------------------------------------------------------------
    --! @brief SYNCオペレーションの引数を読むサブプログラム.
    -------------------------------------------------------------------------------
    procedure READ_SYNC_ARGS(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 OPERATION  : in    OPERATION_TYPE;       --! オペレーションコマンド.
                 SYNC_PORT  : out   integer;              --! ポート番号.
                 SYNC_WAIT  : out   integer               --! ウェイトクロック数.
    );
    -------------------------------------------------------------------------------
    --! @brief 同期オペレーション.
    -------------------------------------------------------------------------------
    procedure CORE_SYNC(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
                 NUM        : in    integer;              --! 同期チャネル番号.
                 COUNT      : in    integer;              --! 同期までの待ちクロック数.
        signal   SYNC_REQ   : out   SYNC.SYNC_REQ_VECTOR; --! SYNC要求信号出力.
        signal   SYNC_ACK   : in    SYNC.SYNC_ACK_VECTOR  --! SYNC応答信号入力.
    );
    -------------------------------------------------------------------------------
    --! @brief 次に読み取ることのできるイベントまで読み飛ばすサブプログラム.
    -------------------------------------------------------------------------------
    procedure SEEK_EVENT(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 NEXT_EVENT : out   READER.EVENT_TYPE     --! 見つかったイベント.
    );
    -------------------------------------------------------------------------------
    --! @brief ストリームからイベントを読み取るサブプログラム.
    --!        ただしスカラー、文字列などは読み捨てる.
    -------------------------------------------------------------------------------
    procedure READ_EVENT(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 EVENT      : in    READER.EVENT_TYPE     --! 読み取るイベント.
    );
    -------------------------------------------------------------------------------
    --! @brief ストリームからEVENTを読み飛ばすサブプログラム.
    --!        EVENTがMAP_BEGINやSEQ_BEGINの場合は、対応するMAP_ENDまたはSEQ_ENDまで
    --!        読み飛ばすことに注意.
    -------------------------------------------------------------------------------
    procedure SKIP_EVENT(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 EVENT      : in    READER.EVENT_TYPE     --! 読み飛ばすイベント.
    );
    -------------------------------------------------------------------------------
    --! @brief ストリームから読んだスカラーとキーワードがマッチするかどうか調べる.
    -------------------------------------------------------------------------------
    procedure MATCH_KEY_WORD(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
                 KEY_WORD   : in    STRING;               --! キーワード.
                 MATCH      : out   boolean               --! マッチするかどうか.
    );
    -------------------------------------------------------------------------------
    --! @brief READ_EVENTで読み取った文字列をキーワードに変換する.
    -------------------------------------------------------------------------------
    procedure COPY_KEY_WORD(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
                 KEY_WORD   : out   STRING                --! キーワード.
    );
    -------------------------------------------------------------------------------
    --! @brief SAYオペレーションを実行する.
    -------------------------------------------------------------------------------
    procedure EXECUTE_SAY(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT                  --! 入力ストリーム.
    );
    -------------------------------------------------------------------------------
    --! @brief SKIPオペレーションを実行する.
    -------------------------------------------------------------------------------
    procedure EXECUTE_SKIP(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT                  --! 入力ストリーム.
    );
    -------------------------------------------------------------------------------
    --! @brief REPORTフラグを書き換えるオペレーションを実行する.
    -------------------------------------------------------------------------------
    procedure EXECUTE_REPORT(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT                  --! 入力ストリーム.
    );
    -------------------------------------------------------------------------------
    --! @brief DEBUGフラグを書き換えるオペレーションを実行する.
    -------------------------------------------------------------------------------
    procedure EXECUTE_DEBUG(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT                  --! 入力ストリーム.
    );
    -------------------------------------------------------------------------------
    --! @brief 不正なSCALARオペレーションを警告して読み飛ばす.
    -------------------------------------------------------------------------------
    procedure EXECUTE_UNDEFINED_SCALAR(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 OP_WORD    : in    STRING
    );
    -------------------------------------------------------------------------------
    --! @brief 不正なMAPオペレーションを警告して読み飛ばす.
    -------------------------------------------------------------------------------
    procedure EXECUTE_UNDEFINED_MAP_KEY(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 OP_WORD    : in    STRING
    );
    -------------------------------------------------------------------------------
    --! @brief シナリオのマップからキーと値を読み出す処理を開始するサブプログラム.
    -------------------------------------------------------------------------------
    procedure MAP_READ_NEXT(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 EVENT      : inout READER.EVENT_TYPE     --! 次のイベント.
    );
    -------------------------------------------------------------------------------
    --! @brief シナリオのマップからキーを指定してstd_logic_vectorタイプの値を読む.
    -------------------------------------------------------------------------------
    procedure MAP_READ_STD_LOGIC_VECTOR(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 KEY        : in    STRING;               --! 信号名
                 VAL        : inout std_logic_vector;     --! 値出力.
                 EVENT      : inout READER.EVENT_TYPE     --! 次のイベント.
    );
    -------------------------------------------------------------------------------
    --! @brief シナリオのマップからキーを指定してintegerタイプの値を読む.
    -------------------------------------------------------------------------------
    procedure MAP_READ_INTEGER(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 KEY        : in    STRING;               --! 信号名
                 VAL        : inout integer;              --! 値出力.
                 EVENT      : inout READER.EVENT_TYPE     --! 次のイベント.
    );
    -------------------------------------------------------------------------------
    --! @brief シナリオのマップからキーを指定してbooleanタイプの値を読む.
    -------------------------------------------------------------------------------
    procedure MAP_READ_BOOLEAN(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 KEY        : in    STRING;               --! 信号名
                 VAL        : inout boolean;              --! 値出力.
                 EVENT      : inout READER.EVENT_TYPE     --! 次のイベント.
    );
    -------------------------------------------------------------------------------
    --! @brief コア変数のデバッグ用ダンプ
    -------------------------------------------------------------------------------
    procedure REPORT_DEBUG     (SELF:inout CORE_TYPE; NAME,MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief コア変数のデバッグ用ダンプ
    -------------------------------------------------------------------------------
    procedure REPORT_DEBUG     (SELF:inout CORE_TYPE; MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にREMARKメッセージを出力するサブプログラム.
    -------------------------------------------------------------------------------
    procedure REPORT_REMARK    (SELF:inout CORE_TYPE; MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にNOTEメッセージを出力するサブプログラム.
    -------------------------------------------------------------------------------
    procedure REPORT_NOTE      (SELF:inout CORE_TYPE; MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にWARNINGメッセージを出力するサブプログラム.
    -------------------------------------------------------------------------------
    procedure REPORT_WARNING   (SELF:inout CORE_TYPE; MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にMISMATCHメッセージを出力するサブプログラム.
    -------------------------------------------------------------------------------
    procedure REPORT_MISMATCH  (SELF:inout CORE_TYPE; MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にERRORメッセージを出力するサブプログラム.
    -------------------------------------------------------------------------------
    procedure REPORT_ERROR     (SELF:inout CORE_TYPE; MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にFAILUREメッセージを出力するサブプログラム.
    -------------------------------------------------------------------------------
    procedure REPORT_FAILURE   (SELF:inout CORE_TYPE; MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief シナリオリードエラーによる中断.
    -------------------------------------------------------------------------------
    procedure READ_ERROR       (SELF:inout CORE_TYPE; MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief シナリオリードエラーによる中断.
    -------------------------------------------------------------------------------
    procedure READ_ERROR       (SELF:inout CORE_TYPE; NAME, MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief 致命的エラーによる中断.
    -------------------------------------------------------------------------------
    procedure EXECUTE_ABORT    (SELF:inout CORE_TYPE; MESSAGE: in STRING);
    -------------------------------------------------------------------------------
    --! @brief 致命的エラーによる中断.
    -------------------------------------------------------------------------------
    procedure EXECUTE_ABORT    (SELF:inout CORE_TYPE; NAME, MESSAGE: in STRING);
    -------------------------------------------------------------------------------
    --! @brief ステータスレポートを集計する関数.
    -------------------------------------------------------------------------------
    function  MARGE_REPORT_STATUS(REPORTS: REPORT_STATUS_VECTOR) return REPORT_STATUS_TYPE;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    component MARCHAL
        generic (
            SCENARIO_FILE   : STRING;
            NAME            : STRING;
            SYNC_PLUG_NUM   : SYNC.SYNC_PLUG_NUM_TYPE;
            SYNC_WIDTH      : integer;
            FINISH_ABORT    : boolean
        );
        port(
            CLK             : in    std_logic;
            RESET           : out   std_logic;
            SYNC            : inout SYNC.SYNC_SIG_VECTOR(SYNC_WIDTH-1 downto 0);
            REPORT_STATUS   : out   REPORT_STATUS_TYPE;
            FINISH          : out   std_logic
        );
    end component;
end CORE;
-----------------------------------------------------------------------------------
--! @brief Dummy Plug のコアパッケージ本体.
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.READER.all;
use     DUMMY_PLUG.VOCAL.all;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.UTIL.INTEGER_TO_STRING;
use     DUMMY_PLUG.UTIL.BOOLEAN_TO_STRING;
use     DUMMY_PLUG.UTIL.STRING_TO_BOOLEAN;
use     DUMMY_PLUG.UTIL.STRING_TO_INTEGER;
use     DUMMY_PLUG.UTIL.STRING_TO_STD_LOGIC_VECTOR;
package body CORE is
    -------------------------------------------------------------------------------
    --! @brief コア変数のデバッグ用ダンプ
    -------------------------------------------------------------------------------
    procedure REPORT_DEBUG     (SELF: inout CORE_TYPE;MESSAGE:in STRING) is
    begin
        if (SELF.debug > 0) then
            REPORT_DEBUG(SELF.vocal, MESSAGE);
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief コア変数のデバッグ用ダンプ
    -------------------------------------------------------------------------------
    procedure REPORT_DEBUG     (SELF: inout CORE_TYPE; NAME, MESSAGE:in STRING) is
    begin
        if (SELF.debug > 0) then
            REPORT_DEBUG(SELF.vocal, NAME & " " & MESSAGE);
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にREMARKメッセージを出力するサブプログラム.
    -------------------------------------------------------------------------------
    procedure REPORT_REMARK    (SELF:inout CORE_TYPE;MESSAGE:in STRING) is
    begin
        REPORT_REMARK(SELF.vocal, MESSAGE);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にNOTEメッセージを出力するサブプログラム.
    -------------------------------------------------------------------------------
    procedure REPORT_NOTE      (SELF:inout CORE_TYPE;MESSAGE:in STRING) is
    begin
        REPORT_NOTE(SELF.vocal, MESSAGE);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にWARNINGメッセージを出力するサブプログラム.
    -------------------------------------------------------------------------------
    procedure REPORT_WARNING   (SELF:inout CORE_TYPE;MESSAGE:in STRING) is
    begin
        REPORT_WARNING(SELF.vocal, MESSAGE);
        SELF.report_status.warning_count := SELF.report_status.warning_count + 1;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にMISMATCHメッセージを出力するサブプログラム.
    -------------------------------------------------------------------------------
    procedure REPORT_MISMATCH  (SELF:inout CORE_TYPE;MESSAGE:in STRING) is
    begin
        REPORT_MISMATCH(SELF.vocal, MESSAGE);
        SELF.report_status.mismatch_count := SELF.report_status.mismatch_count + 1;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にERRORメッセージを出力するサブプログラム.
    -------------------------------------------------------------------------------
    procedure REPORT_ERROR     (SELF:inout CORE_TYPE;MESSAGE:in STRING) is
    begin
        REPORT_ERROR(SELF.vocal, MESSAGE);
        SELF.report_status.error_count := SELF.report_status.error_count + 1;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にFAILUREメッセージを出力するサブプログラム.
    -------------------------------------------------------------------------------
    procedure REPORT_FAILURE   (SELF:inout CORE_TYPE;MESSAGE:in STRING) is
    begin
        REPORT_FAILURE(SELF.vocal, MESSAGE);
        SELF.report_status.failure_count := SELF.report_status.failure_count + 1;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief コア変数の初期化用定数を生成する関数.
    -------------------------------------------------------------------------------
    function  NEW_CORE(
                 NAME       : STRING;                     --! コアの識別名.
                 STREAM_NAME: STRING                      --! シナリオのストリーム名.
    ) return CORE_TYPE is
        variable self       : CORE_TYPE;
    begin
        return NEW_CORE(NAME, NAME, STREAM_NAME);
    end function;
    -------------------------------------------------------------------------------
    --! @brief コア変数の初期化用定数を生成する関数.
    -------------------------------------------------------------------------------
    function  NEW_CORE(
                 NAME       : STRING;                     --! コアの識別名.
                 VOCAL_NAME : STRING;                     --! コアの識別名.
                 STREAM_NAME: STRING                      --! シナリオのストリーム名.
    ) return CORE_TYPE is
        variable self       : CORE_TYPE;
    begin
        WRITE(self.name, NAME);
        self.reader        := NEW_READER(NAME, STREAM_NAME);
        self.vocal         := NEW_VOCAL (VOCAL_NAME);
        self.debug         := 0;           
        self.prev_state    := STATE_NULL;
        self.curr_state    := STATE_NULL;
        self.report_status := REPORT_STATUS_NULL;
        self.report_status.valid := TRUE;
        return self;
    end function;
    -------------------------------------------------------------------------------
    --! @brief コア変数の初期化サブプログラム.
    -------------------------------------------------------------------------------
    procedure CORE_INIT(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
                 NAME       : in    STRING;               --! コアの識別名.
        file     STREAM     :       TEXT;                 --! シナリオのストリーム.
                 STREAM_NAME: in    STRING;               --! シナリオのストリーム名.
        variable OPERATION  : out   OPERATION_TYPE        --! オペレーションコマンド.
    ) is
    begin
        file_open(STREAM, STREAM_NAME, READ_MODE);
        SELF      := NEW_CORE(NAME, STREAM_NAME);
        OPERATION := OP_INIT;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief コア変数の初期化サブプログラム.
    -------------------------------------------------------------------------------
    procedure CORE_INIT(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
                 NAME       : in    STRING;               --! コアの識別名.
                 VOCAL_NAME :       STRING;               --! メッセージ用の識別名.
        file     STREAM     :       TEXT;                 --! シナリオのストリーム.
                 STREAM_NAME: in    STRING;               --! シナリオのストリーム名.
        variable OPERATION  : out   OPERATION_TYPE        --! オペレーションコマンド.
    ) is
    begin
        file_open(STREAM, STREAM_NAME, READ_MODE);
        SELF      := NEW_CORE(NAME,VOCAL_NAME, STREAM_NAME);
        OPERATION := OP_INIT;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 次に読み取ることのできるイベントまで読み飛ばすサブプログラム.
    -------------------------------------------------------------------------------
    procedure SEEK_EVENT(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 NEXT_EVENT : out   EVENT_TYPE            --! 見つかったイベント.
    ) is
    begin
        SEEK_EVENT(SELF.reader, STREAM, NEXT_EVENT);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ストリームからイベントを読み取るサブプログラム.
    --!        ただしスカラー、文字列などは読み捨てる.
    -------------------------------------------------------------------------------
    procedure READ_EVENT(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 EVENT      : in    EVENT_TYPE            --! 読み取るイベント.
    ) is
        constant PROC_NAME  :       string := "READ_EVENT";
        variable read_len   :       integer;
        variable read_good  :       boolean;
    begin 
        READ_EVENT(SELF.reader, STREAM, EVENT, SELF.str_buf, SELF.str_len, read_len, read_good);
        if (read_good = FALSE) then
            READ_ERROR(SELF, PROC_NAME, "READ_EVENT NG");
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ストリームからEVENTを読み飛ばすサブプログラム.
    --!        EVENTがMAP_BEGINやSEQ_BEGINの場合は、対応するMAP_ENDまたはSEQ_ENDまで
    --!        読み飛ばすことに注意.
    -------------------------------------------------------------------------------
    procedure SKIP_EVENT(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 EVENT      : in    EVENT_TYPE            --! 読み飛ばすイベント.
    ) is
        constant PROC_NAME  :       string := "SKIP_EVENT";
        variable skip_good  :       boolean;
    begin
        SKIP_EVENT(SELF.reader, STREAM, EVENT, skip_good);
        if (skip_good = FALSE) then
            READ_ERROR(SELF, PROC_NAME, "SKIP_EVENT NG");
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ストリームから読んだスカラーとキーワードがマッチするかどうか調べる.
    -------------------------------------------------------------------------------
    procedure MATCH_KEY_WORD(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
                 KEY_WORD   : in    STRING;               --! キーワード.
                 MATCH      : out   boolean               --! マッチするかどうか.
    ) is
    begin
        if (SELF.str_len /= KEY_WORD'length) then
            match := FALSE;
        else
            match := (SELF.str_buf(1 to SELF.str_len) = KEY_WORD);
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 最も外側のシーケンスの各ノードに現れる最初のノードを調べて、
    --         自分の名前があるか調べる.
    -------------------------------------------------------------------------------
    procedure check_my_name(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! シナリオのストリーム.
        variable FOUND      : out   boolean               --! 名前があるかどうかを返す.
    ) is
        constant PROC_NAME  :       string := "check_my_name";
        variable get_event  :       EVENT_TYPE;
        variable seq_level  :       integer;
        variable match      :       boolean;
    begin
        seq_level := 0;
        FOUND     := FALSE;
        MAIN_LOOP: loop
            SEEK_EVENT(SELF, STREAM, get_event);
            case get_event is
                when EVENT_SEQ_BEGIN  =>
                    READ_EVENT(SELF, STREAM, get_event);
                    seq_level := seq_level + 1;
                when EVENT_SEQ_END    =>
                    if (seq_level > 0) then
                        READ_EVENT(SELF, STREAM, get_event);
                        seq_level := seq_level - 1;
                    end if;
                    exit when (seq_level = 0);
                when EVENT_SCALAR     =>
                    READ_EVENT(SELF, STREAM, get_event);
                    MATCH_KEY_WORD(SELF, SELF.name(SELF.name'range), match);
                    if (match) then
                        FOUND := TRUE;
                    end if;
                    exit when (seq_level = 0);
                when EVENT_ERROR     =>
                    READ_ERROR(SELF, PROC_NAME, "SEEK_EVENT NG");
                when others =>
                    SKIP_EVENT(SELF, STREAM, get_event);
            end case;
        end loop;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 最も外側のシーケンスの各ノードに現れる最初のノードを調べて、
    --         次に遷移する状態を返す.
    -------------------------------------------------------------------------------
    procedure check_first_node(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! シナリオのストリーム.
        variable NEXT_STATE : out   STATE_TYPE            --! 次に遷移する状態.
    ) is
        constant PROC_NAME  :       string := "check_first_node";
        variable next_event :       EVENT_TYPE;
        variable found      :       boolean;
    begin
        CHECK_LOOP: loop
            SEEK_EVENT(SELF, STREAM, next_event);
            case next_event is
                -------------------------------------------------------------------
                -- エラーだった場合.
                -------------------------------------------------------------------
                when EVENT_ERROR =>
                    READ_ERROR(SELF, PROC_NAME, "SEEK_EVENT NG");
                -------------------------------------------------------------------
                -- 最初のノードがマップだった場合.
                -- * 例１ ID: {...}
                -- * 例２ ID: [{...},{...}]
                -------------------------------------------------------------------
                when EVENT_MAP_BEGIN =>
                    READ_EVENT(SELF, STREAM, next_event);
                    check_my_name(SELF, STREAM, found);
                    if (found) then
                        SEEK_EVENT(SELF, STREAM, next_event);
                        if (next_event = EVENT_SEQ_BEGIN) then
                            READ_EVENT(SELF, STREAM, next_event);
                            NEXT_STATE := STATE_MAP_SEQ;
                        else
                            NEXT_STATE := STATE_MAP_VAL;
                        end if;
                    else
                        SEEK_EVENT(SELF, STREAM, next_event);
                        SKIP_EVENT(SELF, STREAM, next_event);
                        NEXT_STATE := STATE_TOP_SEQ;
                    end if;
                    exit;
                -------------------------------------------------------------------
                -- 最初のノードがシーケンスだった場合.
                -- * 例１ [ID, {...}]
                -------------------------------------------------------------------
                when EVENT_SEQ_BEGIN =>
                    READ_EVENT(SELF, STREAM, next_event);
                    check_my_name(SELF, STREAM, found);
                    if (found) then
                        NEXT_STATE := STATE_SEQ_VAL;
                    else
                        NEXT_STATE := STATE_SEQ_SKIP;
                    end if;
                    exit;
                -------------------------------------------------------------------
                -- 最初のノードがTAG PROPERTYまたはアンカーの場合は単純に読み飛ばす.
                -------------------------------------------------------------------
                when EVENT_TAG_PROP | EVENT_ANCHOR =>
                    SKIP_EVENT(SELF, STREAM, next_event);
                    next;
                -------------------------------------------------------------------
                -- 最初のノードがマップでもシーケンスでもなかった場合はエラー.
                -------------------------------------------------------------------
                when others =>
                    SKIP_EVENT(SELF, STREAM, next_event);
                    NEXT_STATE := STATE_TOP_SEQ;
                    exit;
            end case;
        end loop;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief READ_EVENTで読み取った文字列をキーワードに変換する.
    -------------------------------------------------------------------------------
    procedure COPY_KEY_WORD(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        variable KEY_WORD   : out   STRING                --! キーワード文字列.
    ) is
        variable skip       :       boolean;
        alias    key_buf    :       string(1 to KEY_WORD'length) is KEY_WORD;
    begin
        skip := false;
        for i in key_buf'range loop
            if (i <= SELF.str_len and skip = false) then
                case SELF.str_buf(i) is
                    when 'a' => key_buf(i) := 'A';
                    when 'b' => key_buf(i) := 'B';
                    when 'c' => key_buf(i) := 'C';
                    when 'd' => key_buf(i) := 'D';
                    when 'e' => key_buf(i) := 'E';
                    when 'f' => key_buf(i) := 'F';
                    when 'g' => key_buf(i) := 'G';
                    when 'h' => key_buf(i) := 'H';
                    when 'i' => key_buf(i) := 'I';
                    when 'j' => key_buf(i) := 'J';
                    when 'k' => key_buf(i) := 'K';
                    when 'l' => key_buf(i) := 'L';
                    when 'm' => key_buf(i) := 'M';
                    when 'n' => key_buf(i) := 'N';
                    when 'o' => key_buf(i) := 'O';
                    when 'p' => key_buf(i) := 'P';
                    when 'q' => key_buf(i) := 'Q';
                    when 'r' => key_buf(i) := 'R';
                    when 's' => key_buf(i) := 'S';
                    when 't' => key_buf(i) := 'T';
                    when 'u' => key_buf(i) := 'U';
                    when 'v' => key_buf(i) := 'V';
                    when 'w' => key_buf(i) := 'W';
                    when 'x' => key_buf(i) := 'X';
                    when 'y' => key_buf(i) := 'Y';
                    when 'z' => key_buf(i) := 'Z';
                    when 'A'|'B'|'C'|'D'|'E'|'F'|'G'|'H'|'I'|'J'|'K'|'L'|'M'|
                         'N'|'O'|'P'|'Q'|'R'|'S'|'T'|'U'|'V'|'W'|'X'|'Y'|'Z'|
                         '0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9'|'_'|'.'|':'|'-'|
                         '?' => key_buf(i) := SELF.str_buf(i);
                    when others =>
                        skip := true;
                end case;
            else
                key_buf(i) := ' ';
            end if;
        end loop;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief コアからオペレーションコマンドを読むサブプログラム.
    -------------------------------------------------------------------------------
    procedure READ_OPERATION(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! シナリオのストリーム.
        variable OPERATION  : out   OPERATION_TYPE;       --! オペレーションコマンド.
        variable OP_WORD    : out   string                --! オペレーションキーワード.
    ) is
        constant PROC_NAME  :       string := "READ_OPERATION";
        variable next_event :       EVENT_TYPE;
        variable next_state :       STATE_TYPE;
        procedure REPORT_DEBUG(state:in STRING;event:EVENT_TYPE) is
        begin
            REPORT_DEBUG(SELF, PROC_NAME, string'("state=") & state & 
                               string'(" next_event=") & EVENT_TO_STRING(event));
            if (SELF.debug > 1) then
                DEBUG_DUMP(SELF.reader);
            end if;
        end procedure;
    begin
        SELF.vocal.enable_debug := TRUE;
        MAIN_LOOP: loop
            SEEK_EVENT(SELF, STREAM, next_event);
            if (next_event = EVENT_ERROR) then
                READ_ERROR(SELF, PROC_NAME, "SEEK_EVENT NG");
            end if;
            case SELF.curr_state is
                -------------------------------------------------------------------
                -- 初期状態.
                -------------------------------------------------------------------
                when STATE_NULL | STATE_STREAM =>
                    REPORT_DEBUG(string'("STATE_STREAM"),next_event);
                    case next_event is
                        when EVENT_DOC_BEGIN  => 
                            READ_EVENT(SELF, STREAM, next_event);
                            SELF.curr_state := STATE_DOCUMENT;
                            OPERATION       := OP_DOC_BEGIN;
                            exit;
                        when EVENT_STREAM_END =>
                            READ_EVENT(SELF, STREAM, next_event);
                            SELF.curr_state := STATE_NULL;
                            OPERATION       := OP_FINISH;
                            exit;
                        when others =>
                            SKIP_EVENT(SELF, STREAM, next_event);
                    end case;
                -------------------------------------------------------------------
                -- ドキュメント処理中.
                -------------------------------------------------------------------
                when STATE_DOCUMENT =>
                    REPORT_DEBUG(string'("STATE_DOCUMENT"), next_event);
                    case next_event is
                        when EVENT_SEQ_BEGIN =>
                            READ_EVENT(SELF, STREAM, next_event);
                            SELF.curr_state := STATE_TOP_SEQ;
                        when EVENT_DOC_END   =>
                            READ_EVENT(SELF, STREAM, next_event);
                            SELF.curr_state := STATE_STREAM;
                            OPERATION       := OP_DOC_END;
                            exit;
                        when others =>
                            READ_EVENT(SELF, STREAM, next_event);
                            -- ERROR
                    end case;
                -------------------------------------------------------------------
                -- 最も外側のシーケンス処理中.
                -- シーケンスの各ノードに現れる最初のノードによって、
                -- 以降の状態が変化する.
                -- * 例１ - ID:{...}           #=>STATE_MAP_VAL
                -- * 例２ - ID:[{...},{...}]   #=>STATE_MAP_SEQ
                -- * 例３ - [ID,{...},{...}]   #=>STATE_SEQ_VAL or STATE_SEQ_SKIP
                -------------------------------------------------------------------
                when STATE_TOP_SEQ  =>
                    REPORT_DEBUG(string'("STATE_TOP_SEQ"), next_event);
                    case next_event is
                        when EVENT_SEQ_END =>
                            READ_EVENT(SELF, STREAM, next_event);
                            SELF.curr_state := STATE_DOCUMENT;
                        when others =>
                            check_first_node(SELF, STREAM, next_state);
                            SELF.curr_state := next_state;
                    end case;
                -------------------------------------------------------------------
                -- ID:{...} を処理する状態.
                -------------------------------------------------------------------
                when STATE_MAP_VAL =>
                    REPORT_DEBUG(string'("STATE_MAP_VAL"), next_event);
                    case next_event is
                        when EVENT_MAP_BEGIN =>
                            READ_EVENT(SELF, STREAM, next_event);
                            SEEK_EVENT(SELF, STREAM, next_event);
                            READ_EVENT(SELF, STREAM, next_event);
                            COPY_KEY_WORD(SELF, OP_WORD);
                            SELF.curr_state := STATE_OP_MAP;
                            SELF.prev_state := STATE_MAP_END;
                            OPERATION       := OP_MAP;
                            exit;
                        when EVENT_SCALAR =>
                            READ_EVENT(SELF, STREAM, next_event);
                            COPY_KEY_WORD(SELF, OP_WORD);
                            SELF.curr_state := STATE_OP_SCALAR;
                            SELF.prev_state := STATE_TOP_SEQ;
                            OPERATION       := OP_SCALAR;
                            exit;
                        when others =>
                            SKIP_EVENT(SELF, STREAM, next_event);
                    end case;
                -------------------------------------------------------------------
                -- ID:[{...},{...}] を処理する状態.
                -------------------------------------------------------------------
                when STATE_MAP_SEQ =>
                    REPORT_DEBUG(string'("STATE_MAP_SEQ"), next_event);
                    case next_event is
                        when EVENT_SEQ_END =>
                            READ_EVENT(SELF, STREAM, next_event);
                            SELF.curr_state := STATE_MAP_END;
                        when EVENT_MAP_BEGIN =>
                            READ_EVENT(SELF, STREAM, next_event);
                            SEEK_EVENT(SELF, STREAM, next_event);
                            READ_EVENT(SELF, STREAM, next_event);
                            COPY_KEY_WORD(SELF, OP_WORD);
                            SELF.curr_state := STATE_OP_MAP;
                            SELF.prev_state := STATE_MAP_SEQ;
                            OPERATION       := OP_MAP;
                            exit;
                        when EVENT_SCALAR =>
                            READ_EVENT(SELF, STREAM, next_event);
                            COPY_KEY_WORD(SELF, OP_WORD);
                            SELF.curr_state := STATE_OP_SCALAR;
                            SELF.prev_state := STATE_MAP_SEQ;
                            OPERATION       := OP_SCALAR;
                            exit;
                        when others =>
                            SKIP_EVENT(SELF, STREAM, next_event);
                    end case;
                -------------------------------------------------------------------
                -- [ID,{...},{...}] を処理する状態.
                -------------------------------------------------------------------
                when STATE_SEQ_VAL =>
                    REPORT_DEBUG(string'("STATE_SEQ_VAL"), next_event);
                    case next_event is
                        when EVENT_SEQ_END =>
                            READ_EVENT(SELF, STREAM, next_event);
                            SELF.curr_state := STATE_TOP_SEQ;
                        when EVENT_MAP_BEGIN =>
                            READ_EVENT(SELF, STREAM, next_event);
                            SEEK_EVENT(SELF, STREAM, next_event);
                            READ_EVENT(SELF, STREAM, next_event);
                            COPY_KEY_WORD(SELF, OP_WORD);
                            SELF.curr_state := STATE_OP_MAP;
                            SELF.prev_state := STATE_SEQ_VAL;
                            OPERATION       := OP_MAP;
                            exit;
                        when EVENT_SCALAR =>
                            READ_EVENT(SELF, STREAM, next_event);
                            COPY_KEY_WORD(SELF, OP_WORD);
                            SELF.curr_state := STATE_OP_SCALAR;
                            SELF.prev_state := STATE_SEQ_VAL;
                            OPERATION       := OP_SCALAR;
                            exit;
                        when others =>
                            SKIP_EVENT(SELF, STREAM, next_event);
                    end case;
                -------------------------------------------------------------------
                -- [ID,{...},{...}]を読み飛ばす状態.
                -------------------------------------------------------------------
                when STATE_SEQ_SKIP =>
                    REPORT_DEBUG(string'("STATE_SEQ_SKIP"), next_event);
                    case next_event is
                        when EVENT_SEQ_END =>
                            READ_EVENT(SELF, STREAM, next_event);
                            SELF.curr_state := STATE_TOP_SEQ;
                        when others => 
                            SKIP_EVENT(SELF, STREAM, next_event);
                    end case;
                -------------------------------------------------------------------
                -- {ID: {...}} または {ID: [{...},{...}]}の最後のEVENT_MAP_ENDを
                -- 読む状態.
                -------------------------------------------------------------------
                when STATE_MAP_END =>
                    REPORT_DEBUG(string'("STATE_MAP_END"), next_event);
                    case next_event is
                        when EVENT_MAP_END =>
                            READ_EVENT(SELF, STREAM, next_event);
                            SELF.curr_state := STATE_TOP_SEQ;
                        when others =>
                            READ_ERROR(SELF, PROC_NAME,
                                       "need EVENT_MAP_END but " &
                                       EVENT_TO_STRING(next_event) &
                                       " in STATE_MAP_END");
                    end case;
                -------------------------------------------------------------------
                -- OP_MAPを処理している状態.
                -------------------------------------------------------------------
                when STATE_OP_MAP =>
                    REPORT_DEBUG(string'("STATE_OP_MAP"), next_event);
                    case next_event is
                        when EVENT_MAP_END =>
                            READ_EVENT(SELF, STREAM, next_event);
                            SELF.curr_state := SELF.prev_state;
                        when others =>
                            READ_ERROR(SELF, PROC_NAME,
                                       "need EVENT_MAP_END but " &
                                       EVENT_TO_STRING(next_event) &
                                       " in STATE_OP_MAP");
                    end case;
                -------------------------------------------------------------------
                -- OP_SCALARを処理している状態.
                -------------------------------------------------------------------
                when STATE_OP_SCALAR =>
                    REPORT_DEBUG(string'("STATE_OP_SCALAR"), next_event);
                    SELF.curr_state := SELF.prev_state;
                -------------------------------------------------------------------
                -- 不正な状態(ありえないはず).
                -------------------------------------------------------------------
                when others =>
                    EXECUTE_ABORT(SELF, PROC_NAME, "bad state");
            end case;
        end loop;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief SYNCオペレーションの引数を読むサブプログラム.
    -------------------------------------------------------------------------------
    procedure READ_SYNC_ARGS(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 OPERATION  : in    OPERATION_TYPE;       --! オペレーションコマンド.
                 SYNC_PORT  : out   integer;              --! ポート番号.
                 SYNC_WAIT  : out   integer               --! ウェイトクロック数.
    ) is
        constant PROC_NAME  : string := "READ_SYNC_ARGS";
        variable next_event : EVENT_TYPE;
        variable port_num   : integer;
        variable wait_num   : integer;
        variable scan_len   : integer;
        variable match      : boolean;
        variable map_level  : integer;
        type     STATE_TYPE is (STATE_NULL, STATE_SCALAR_PORT,
                                STATE_MAP_KEY, STATE_MAP_PORT, STATE_MAP_WAIT, STATE_ERROR);
        variable state      : STATE_TYPE;
        variable keyword    : STRING(1 to 5);
        constant KEY_WAIT   : STRING(1 to 5) := "WAIT ";
        constant KEY_PORT   : STRING(1 to 5) := "PORT ";
        constant KEY_LOCAL  : STRING(1 to 5) := "LOCAL";
    begin
        port_num := 0;
        wait_num := 2;
        case OPERATION is
            when OP_MAP =>
                map_level := 0;
                state     := STATE_SCALAR_PORT;
                OP_MAP_LOOP: loop
                    SEEK_EVENT(SELF, STREAM, next_event);
                    case next_event is
                        when EVENT_MAP_BEGIN =>
                            READ_EVENT(SELF, STREAM, next_event);
                            map_level := map_level + 1;
                            state     := STATE_MAP_KEY;
                        when EVENT_MAP_END   =>
                            READ_EVENT(SELF, STREAM, next_event);
                            map_level := map_level - 1;
                            state     := STATE_NULL;
                        when EVENT_SCALAR    =>
                            READ_EVENT(SELF, STREAM, next_event);
                            case state is
                                when STATE_MAP_KEY =>
                                    COPY_KEY_WORD(SELF, keyword);
                                    case keyword is
                                        when KEY_PORT => state := STATE_MAP_PORT;
                                        when KEY_WAIT => state := STATE_MAP_WAIT;
                                        when others   => state := STATE_ERROR;
                                    end case;
                                when STATE_SCALAR_PORT | STATE_MAP_PORT =>
                                    COPY_KEY_WORD(SELF, keyword);
                                    if    (keyword = KEY_LOCAL) then
                                        port_num := -1;
                                    else
                                        STRING_TO_INTEGER(SELF.str_buf(1 to SELF.str_len), port_num, scan_len);
                                    end if;
                                    if (state = STATE_MAP_PORT) then
                                        state := STATE_MAP_KEY;
                                    else
                                        state := STATE_NULL;
                                    end if;
                                when STATE_MAP_WAIT =>
                                    STRING_TO_INTEGER(SELF.str_buf(1 to SELF.str_len), wait_num, scan_len);
                                    state := STATE_MAP_KEY;
                                when others =>
                                    state := STATE_MAP_KEY;
                            end case;
                        when EVENT_ERROR =>
                            READ_ERROR(SELF, PROC_NAME, "SEEK_EVENT NG");
                        when others =>
                            SKIP_EVENT(SELF, stream, next_event);
                    end case;
                    exit when (map_level = 0);
                end loop;
                if (next_event /= EVENT_MAP_END) then
                    READ_ERROR(SELF, PROC_NAME, "need EVENT_MAP_END but " &
                                                 EVENT_TO_STRING(next_event));
                end if;
            when OP_DOC_BEGIN => null;
            when OP_SCALAR    => null;
            when others       => null;
        end case;
        SYNC_PORT := port_num;
        SYNC_WAIT := wait_num;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 同期オペレーション.
    -------------------------------------------------------------------------------
    procedure CORE_SYNC(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
                 NUM        : in    integer;              --! 同期チャネル番号.
                 COUNT      : in    integer;              --! 同期までの待ちクロック数.
        signal   SYNC_REQ   : out   SYNC_REQ_VECTOR;      --! SYNC要求信号出力.
        signal   SYNC_ACK   : in    SYNC_ACK_VECTOR       --! SYNC応答信号入力.
    ) is 
        variable sync_count :       SYNC_REQ_VECTOR(SYNC_REQ'range);
    begin 
        sync_count(NUM) := COUNT;
        SYNC_BEGIN(SYNC_REQ,           sync_count);
        SYNC_END  (SYNC_REQ, SYNC_ACK, sync_count);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief SAYオペレーションを実行する.
    -------------------------------------------------------------------------------
    procedure EXECUTE_SAY(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT                  --! 入力ストリーム.
    ) is
        constant PROC_NAME  :       STRING := "EXECUTE_SAY";
        variable next_event :       EVENT_TYPE;
    begin
        REPORT_DEBUG(SELF, PROC_NAME, "BEGIN");
        SEEK_EVENT(SELF, STREAM, next_event);
        if (next_event = EVENT_SCALAR) then
            READ_EVENT(SELF, STREAM, next_event);
            SAY(SELF.vocal, SELF.str_buf(1 to SELF.str_len));
        else
            SKIP_EVENT(SELF, STREAM, next_event);
        end if;
        REPORT_DEBUG(SELF, PROC_NAME, "END");
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief SKIPオペレーションを実行する.
    -------------------------------------------------------------------------------
    procedure EXECUTE_SKIP(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT                  --! 入力ストリーム.
    ) is
        constant PROC_NAME  :       STRING := "EXECUTE_SKIP";
        variable next_event :       EVENT_TYPE;
    begin
        REPORT_DEBUG(SELF, PROC_NAME, "BEGIN");
        SEEK_EVENT(SELF, STREAM, next_event);
        if (next_event = EVENT_ERROR) then
            READ_ERROR(SELF, PROC_NAME, "SEEK_EVENT NG");
        else
            SKIP_EVENT(SELF, STREAM, next_event);
        end if;
        REPORT_DEBUG(SELF, PROC_NAME, "END");
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief REPORTフラグを書き換えるオペレーションを実行する.
    -------------------------------------------------------------------------------
    procedure EXECUTE_REPORT(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT                  --! 入力ストリーム.
    ) is
        constant PROC_NAME  :       STRING := "EXECUTE_REPORT";
        variable next_event :       EVENT_TYPE;
        constant KEY_DEBUG  :       STRING(1 to 3) := "DEB";
        constant KEY_REMARK :       STRING(1 to 3) := "REM";
        constant KEY_NOTE   :       STRING(1 to 3) := "NOT";
        constant KEY_WARNING:       STRING(1 to 3) := "WAR";
        constant KEY_MISMATCH:      STRING(1 to 3) := "MIS";
        constant KEY_ERROR  :       STRING(1 to 3) := "ERR";
        constant KEY_FAILURE:       STRING(1 to 3) := "FAI";
        constant KEY_GET    :       STRING(1 to 3) := "GET";
        constant KEY_NONE   :       STRING(1 to 3) := "   ";
        variable key_word   :       STRING(1 to 3);
        variable map_level  :       integer;
        variable map_value  :       boolean;
        variable scan_len   :       integer;
    begin
        REPORT_DEBUG(SELF, PROC_NAME, "BEGIN");
        map_level := 0;
        map_value := FALSE;
        key_word  := KEY_GET;
        SCAN_LOOP: loop
            SEEK_EVENT(SELF, STREAM, next_event);
            case next_event is
                when EVENT_ERROR     =>
                    READ_ERROR(SELF, PROC_NAME, "SEEK_EVENT NG");
                when EVENT_MAP_BEGIN =>
                    READ_EVENT(SELF, STREAM, next_event);
                    map_level := map_level + 1;
                when EVENT_MAP_END   =>
                    READ_EVENT(SELF, STREAM, next_event);
                    map_level := map_level - 1;
                when EVENT_SCALAR =>
                    READ_EVENT(SELF, STREAM, next_event);
                    if (key_word = KEY_GET) then
                        COPY_KEY_WORD(SELF, key_word);
                        case key_word is
                            when KEY_DEBUG   => null;
                            when KEY_REMARK  => null;
                            when KEY_NOTE    => null;
                            when KEY_WARNING => null;
                            when KEY_MISMATCH=> null;
                            when KEY_ERROR   => null;
                            when KEY_FAILURE => null;
                            when others      =>
                                READ_ERROR(SELF, PROC_NAME, "Illegal keyword");
                                key_word := KEY_NONE;
                        end case;
                    else
                        STRING_TO_BOOLEAN(SELF.str_buf(1 to SELF.str_len), map_value, scan_len);
                        if (scan_len > 0) then
                            case key_word is
                                when KEY_DEBUG   => SELF.vocal.enable_debug    := map_value;
                                when KEY_REMARK  => SELF.vocal.enable_remark   := map_value;
                                when KEY_NOTE    => SELF.vocal.enable_note     := map_value;
                                when KEY_WARNING => SELF.vocal.enable_warning  := map_value;
                                when KEY_MISMATCH=> SELF.vocal.enable_mismatch := map_value;
                                when KEY_ERROR   => SELF.vocal.enable_error    := map_value;
                                when KEY_FAILURE => SELF.vocal.enable_failure  := map_value;
                                when others      => null;
                            end case;
                        else
                            READ_ERROR(SELF, PROC_NAME, "Illegal boolean value");
                        end if;
                        key_word := KEY_GET;
                    end if;
                when others =>
                    READ_ERROR(SELF, PROC_NAME, EVENT_TO_STRING(next_event));
                    SKIP_EVENT(SELF, STREAM, next_event);
            end case;
            exit when (map_level = 0);
        end loop;
        REPORT_DEBUG(SELF, PROC_NAME, "END");
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief DEBUGフラグを書き換えるオペレーションを実行する.
    -------------------------------------------------------------------------------
    procedure EXECUTE_DEBUG(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT                  --! 入力ストリーム.
    ) is
        constant PROC_NAME  :       string := "EXECUTE_DEBUG";
        variable next_event :       EVENT_TYPE;
        variable scan_len   :       integer;
        variable debug      :       integer;
    begin 
        REPORT_DEBUG(SELF, PROC_NAME, "BEGIN");
        SEEK_EVENT(SELF, STREAM, next_event);
        case next_event is
            when EVENT_SCALAR =>
                READ_EVENT(SELF, STREAM, EVENT_SCALAR);
                STRING_TO_INTEGER(SELF.str_buf(1 to SELF.str_len), debug, scan_len);
                if (scan_len > 0) then
                    SELF.debug := debug;
                    REPORT_DEBUG(SELF, PROC_NAME & " ON");
                end if;
            when others =>
                READ_ERROR(SELF, PROC_NAME, EVENT_TO_STRING(next_event));
                SKIP_EVENT(SELF, STREAM, next_event);
        end case;
        REPORT_DEBUG(SELF, PROC_NAME, "END");
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 不正なSCALARオペレーションを警告して読み飛ばす.
    -------------------------------------------------------------------------------
    procedure EXECUTE_UNDEFINED_SCALAR(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 OP_WORD    : in    STRING
    ) is
    begin
        REPORT_READ_ERROR(SELF.vocal, string'("Undefined Scalar Operation(") & OP_WORD & ")");
        DEBUG_DUMP(SELF.reader);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 不正なMAPオペレーションを警告して読み飛ばす.
    -------------------------------------------------------------------------------
    procedure EXECUTE_UNDEFINED_MAP_KEY(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 OP_WORD    : in    STRING
   ) is
        variable next_event :       EVENT_TYPE;
    begin
        REPORT_READ_ERROR(SELF.vocal, string'("Undefined Map Operation(") & OP_WORD & ")");
        DEBUG_DUMP(SELF.reader);
        SEEK_EVENT(SELF, STREAM, next_event);
        SKIP_EVENT(SELF, STREAM, next_event);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 致命的エラーによる中断.
    -------------------------------------------------------------------------------
    procedure EXECUTE_ABORT(SELF: inout CORE_TYPE; MESSAGE: in STRING) is
    begin
        REPORT_FAILURE(SELF.vocal, MESSAGE);
        DEBUG_DUMP(SELF.reader);
        assert FALSE report MESSAGE severity FAILURE;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 致命的エラーによる中断.
    -------------------------------------------------------------------------------
    procedure EXECUTE_ABORT(SELF: inout CORE_TYPE; NAME, MESSAGE: in STRING) is
    begin
        REPORT_FAILURE(SELF.vocal, NAME & " " & MESSAGE);
        DEBUG_DUMP(SELF.reader);
        assert FALSE report NAME & " " & MESSAGE severity FAILURE;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief シナリオリードエラーによる中断.
    -------------------------------------------------------------------------------
    procedure READ_ERROR(SELF:inout CORE_TYPE;MESSAGE:in STRING) is
    begin
        REPORT_READ_ERROR(SELF.vocal, string'("Read Error ") & MESSAGE);
        DEBUG_DUMP(SELF.reader);
        assert FALSE report string'("Read Error ") & MESSAGE severity FAILURE;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief シナリオリードエラーによる中断.
    -------------------------------------------------------------------------------
    procedure READ_ERROR(SELF:inout CORE_TYPE;NAME, MESSAGE:in STRING) is
    begin
        REPORT_READ_ERROR(SELF.vocal, NAME & " Read Error " & MESSAGE);
        DEBUG_DUMP(SELF.reader);
        assert FALSE report NAME & " Read Error " & MESSAGE severity FAILURE;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ステータスレポートを集計する関数.
    -------------------------------------------------------------------------------
    function  MARGE_REPORT_STATUS(REPORTS: REPORT_STATUS_VECTOR) return REPORT_STATUS_TYPE is
        variable status : REPORT_STATUS_TYPE;
    begin
        status := REPORT_STATUS_NULL;
        for i in REPORTS'range loop
            if (REPORTS(i).valid) then
                status.valid          := TRUE;
                status.warning_count  := status.warning_count  + REPORTS(i).warning_count;
                status.mismatch_count := status.mismatch_count + REPORTS(i).mismatch_count;
                status.error_count    := status.error_count    + REPORTS(i).error_count;
                status.failure_count  := status.failure_count  + REPORTS(i).failure_count;
            end if;
        end loop;
        return status;
    end function;
    -------------------------------------------------------------------------------
    --! @brief シナリオのマップからキーと値を読み出す処理を開始するサブプログラム.
    -------------------------------------------------------------------------------
    procedure MAP_READ_NEXT(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 EVENT      : inout READER.EVENT_TYPE     --! 次のイベント.
    ) is
    begin
        SEEK_EVENT(SELF, STREAM, EVENT);
        if (EVENT = EVENT_SCALAR) then
            READ_EVENT(SELF, STREAM, EVENT_SCALAR);
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief シナリオのマップからキーを指定してstd_logic_vectorタイプの値を読む.
    --!      * マップに指定されたキーが無いときは、何もしない。
    --!        VALに値を上書きすることも無い.
    --!      * このサブプログラムを呼ぶときは、すでにMAP_READ_NEXTを実行済みに
    --!        しておかなければならない。
    -------------------------------------------------------------------------------
    procedure MAP_READ_STD_LOGIC_VECTOR(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 KEY        : in    STRING;               --! 信号名
                 VAL        : inout std_logic_vector;     --! 信号の値.
                 EVENT      : inout EVENT_TYPE            --! 次のイベント.
    ) is
        constant PROC_NAME  :       string := "MAP_READ_STD_LOGIC_VECTOR";
        variable next_event :       EVENT_TYPE;
        variable key_word   :       string(1 to KEY'length);
        variable pos        :       integer;
        variable port_num   :       integer;
        variable read_len   :       integer;
        variable value      :       std_logic_vector(0 downto 0);
        variable val_size   :       integer;
    begin
        REPORT_DEBUG(SELF, PROC_NAME, "BEGIN");
        next_event := EVENT;
        MAP_LOOP: loop
            case next_event is
                when EVENT_SCALAR  =>
                    pos := SELF.str_buf'low;
                    if (SELF.str_len < 6) then
                        exit MAP_LOOP;
                    end if;
                    COPY_KEY_WORD(SELF, key_word);
                    if (key_word = KEY) then
                        pos := pos + key_word'length;
                        if (SELF.str_buf(pos) /= '(' ) then
                            exit MAP_LOOP;
                        end if;
                        pos := pos + 1;
                        STRING_TO_INTEGER(
                            STR  => SELF.str_buf(pos to SELF.str_len),
                            VAL  => port_num,
                            LEN  => read_len
                        );
                        if (read_len = 0 or pos+read_len /= SELF.str_len) then
                            exit MAP_LOOP;
                        end if;
                        if (SELF.str_buf(pos+read_len) /= ')') then
                            exit MAP_LOOP;
                        end if;
                        SEEK_EVENT(SELF, STREAM, next_event);
                        if (next_event /= EVENT_SCALAR) then
                            READ_ERROR(SELF, PROC_NAME, "READ_VAL NG KEY=" & KEY);
                        end if;
                        READ_EVENT(SELF, STREAM, EVENT_SCALAR);
                        STRING_TO_STD_LOGIC_VECTOR(
                            STR  => SELF.str_buf(1 to SELF.str_len),
                            VAL  => value,
                            LEN  => read_len,
                            SIZE => val_size
                        );
                        if (VAL'low <= port_num and port_num <= VAL'high) then
                            VAL(port_num) := value(0);
                        else
                            READ_ERROR(SELF, PROC_NAME, "OUT OF RANGE KEY =" & KEY &
                                       " index=" & INTEGER_TO_STRING(port_num) &
                                       " range=" & INTEGER_TO_STRING(VAL'low ) &
                                       ":"       & INTEGER_TO_STRING(VAL'high));
                        end if;
                    else
                        exit MAP_LOOP;
                    end if;
                when EVENT_MAP_END => exit MAP_LOOP;
                when others        => exit MAP_LOOP;
            end case;
            MAP_READ_NEXT(SELF, STREAM, next_event);
        end loop;
        EVENT := next_event;
        REPORT_DEBUG(SELF, PROC_NAME, "END");
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief シナリオのマップからキーを指定してintegerタイプの値を読む.
    --!      * マップに指定されたキーが無いときは、何もしない。
    --!        VALに値を上書きすることも無い.
    --!      * このサブプログラムを呼ぶときは、すでにMAP_READ_NEXTを実行済みに
    --!        しておかなければならない。
    -------------------------------------------------------------------------------
    procedure MAP_READ_INTEGER(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 KEY        : in    STRING;               --! 信号名
                 VAL        : inout integer;              --! 値出力.
                 EVENT      : inout EVENT_TYPE            --! 次のイベント.
    ) is
        constant PROC_NAME  :       string := "MAP_READ_INTEGER";
        variable next_event :       EVENT_TYPE;
        variable key_word   :       string(1 to KEY'length);
        variable read_len   :       integer;
        variable value      :       integer;
    begin
        REPORT_DEBUG(SELF, PROC_NAME, "BEGIN");
        next_event := EVENT;
        if (next_event = EVENT_SCALAR) then
            COPY_KEY_WORD(SELF, key_word);
            if (key_word = KEY) then
                SEEK_EVENT(SELF, STREAM, next_event);
                read_len := 0;
                if (next_event = EVENT_SCALAR) then
                    READ_EVENT(SELF, STREAM, next_event);
                    STRING_TO_INTEGER(
                        STR  => SELF.str_buf(1 to SELF.str_len),
                        VAL  => value,
                        LEN  => read_len
                    );
                end if;
                if (read_len > 0) then
                     VAL := value;
                     REPORT_DEBUG(SELF, PROC_NAME, "KEY="  & KEY &
                                  " VAL=" & INTEGER_TO_STRING(VAL));
                else
                     READ_ERROR(SELF, PROC_NAME, "READ_VAL NG KEY=" & KEY);
                end if;
                MAP_READ_NEXT(SELF, STREAM, next_event);
            end if;
        end if;
        EVENT := next_event;
        REPORT_DEBUG(SELF, PROC_NAME, "END");
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief シナリオのマップからキーを指定してbooleanタイプの値を読む.
    --!      * マップに指定されたキーが無いときは、何もしない。
    --!        VALに値を上書きすることも無い.
    --!      * このサブプログラムを呼ぶときは、すでにMAP_READ_NEXTを実行済みに
    --!        しておかなければならない。
    -------------------------------------------------------------------------------
    procedure MAP_READ_BOOLEAN(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 KEY        : in    STRING;               --! 信号名
                 VAL        : inout boolean;              --! 値出力.
                 EVENT      : inout READER.EVENT_TYPE     --! 次のイベント.
    ) is
        constant PROC_NAME  :       string := "MAP_READ_BOOLEAN";
        variable next_event :       EVENT_TYPE;
        variable key_word   :       string(1 to KEY'length);
        variable read_len   :       integer;
        variable value      :       boolean;
    begin
        REPORT_DEBUG(SELF, PROC_NAME, "BEGIN");
        next_event := EVENT;
        if (next_event = EVENT_SCALAR) then
            COPY_KEY_WORD(SELF, key_word);
            if (key_word = KEY) then
                SEEK_EVENT(SELF, STREAM, next_event);
                read_len := 0;
                if (next_event = EVENT_SCALAR) then
                    READ_EVENT(SELF, STREAM, next_event);
                    STRING_TO_BOOLEAN(
                        STR  => SELF.str_buf(1 to SELF.str_len),
                        VAL  => value,
                        LEN  => read_len
                    );
                end if;
                if (read_len > 0) then
                     VAL := value;
                     REPORT_DEBUG(SELF, PROC_NAME, "KEY="  & KEY &
                                  " VAL=" & BOOLEAN_TO_STRING(VAL));
                else
                     READ_ERROR(SELF, PROC_NAME, "READ_VAL NG KEY=" & KEY);
                end if;
                MAP_READ_NEXT(SELF, STREAM, next_event);
            end if;
        end if;
        EVENT := next_event;
        REPORT_DEBUG(SELF, PROC_NAME, "END");
    end procedure;
end CORE;
