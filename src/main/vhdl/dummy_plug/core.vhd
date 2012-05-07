-----------------------------------------------------------------------------------
--!     @file    core.vhd
--!     @brief   Core Package for Dummy Plug.
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
              STATE_FINISH    --!
    );
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
                 EVENT      : in    READER.EVENT_TYPE;    --! 読み取るイベント.
                 GOOD       : out   boolean               --! 正常に読み取れたことを示す.
    );
    -------------------------------------------------------------------------------
    --! @brief ストリームからEVENTを読み飛ばすサブプログラム.
    --!        EVENTがMAP_BEGINやSEQ_BEGINの場合は、対応するMAP_ENDまたはSEQ_ENDまで
    --!        読み飛ばすことに注意.
    -------------------------------------------------------------------------------
    procedure SKIP_EVENT(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 EVENT      : in    READER.EVENT_TYPE;    --! 読み飛ばすイベント.
                 GOOD       : out   boolean               --! 正常に読み取れたことを示す.
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
    --! @brief コア変数のデバッグ用ダンプ
    -------------------------------------------------------------------------------
    procedure REPORT_DEBUG     (SELF:inout CORE_TYPE;MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にREMARKメッセージを出力するサブプログラム.
    -------------------------------------------------------------------------------
    procedure REPORT_REMARK    (SELF:inout CORE_TYPE;MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にNOTEメッセージを出力するサブプログラム.
    -------------------------------------------------------------------------------
    procedure REPORT_NOTE      (SELF:inout CORE_TYPE;MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にWARNINGメッセージを出力するサブプログラム.
    -------------------------------------------------------------------------------
    procedure REPORT_WARNING   (SELF:inout CORE_TYPE;MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にMISMATCHメッセージを出力するサブプログラム.
    -------------------------------------------------------------------------------
    procedure REPORT_MISMATCH  (SELF:inout CORE_TYPE;MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にERRORメッセージを出力するサブプログラム.
    -------------------------------------------------------------------------------
    procedure REPORT_ERROR     (SELF:inout CORE_TYPE;MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にFAILUREメッセージを出力するサブプログラム.
    -------------------------------------------------------------------------------
    procedure REPORT_FAILURE   (SELF:inout CORE_TYPE;MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にシナリオリードエラーメッセージを出力するサブプログラム.
    -------------------------------------------------------------------------------
    procedure REPORT_READ_ERROR(SELF:inout CORE_TYPE;MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief 致命的エラーによる中断.
    -------------------------------------------------------------------------------
    procedure EXECUTE_ABORT(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
                 MESSAGE    : in    STRING                --! メッセージ
    );
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
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にMISMATCHメッセージを出力するサブプログラム.
    -------------------------------------------------------------------------------
    procedure REPORT_MISMATCH  (SELF:inout CORE_TYPE;MESSAGE:in STRING) is
    begin
        REPORT_MISMATCH(SELF.vocal, MESSAGE);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にERRORメッセージを出力するサブプログラム.
    -------------------------------------------------------------------------------
    procedure REPORT_ERROR     (SELF:inout CORE_TYPE;MESSAGE:in STRING) is
    begin
        REPORT_ERROR(SELF.vocal, MESSAGE);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にFAILUREメッセージを出力するサブプログラム.
    -------------------------------------------------------------------------------
    procedure REPORT_FAILURE   (SELF:inout CORE_TYPE;MESSAGE:in STRING) is
    begin
        REPORT_FAILURE(SELF.vocal, MESSAGE);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にシナリオリードエラーメッセージを出力するサブプログラム.
    -------------------------------------------------------------------------------
    procedure REPORT_READ_ERROR(SELF:inout CORE_TYPE;MESSAGE:in STRING) is
    begin
        REPORT_READ_ERROR(SELF.vocal, MESSAGE);
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
        self.reader     := NEW_READER(NAME, STREAM_NAME);
        self.vocal      := NEW_VOCAL (VOCAL_NAME);
        self.debug      := 0;
        self.prev_state := STATE_NULL;
        self.curr_state := STATE_NULL;
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
                 EVENT      : in    EVENT_TYPE;           --! 読み取るイベント.
                 GOOD       : out   boolean               --! 正常に読み取れたことを示す.
    ) is
        variable read_len   :       integer;
    begin 
        READ_EVENT(SELF.reader, STREAM, EVENT, SELF.str_buf, SELF.str_len, read_len, GOOD);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ストリームからEVENTを読み飛ばすサブプログラム.
    --!        EVENTがMAP_BEGINやSEQ_BEGINの場合は、対応するMAP_ENDまたはSEQ_ENDまで
    --!        読み飛ばすことに注意.
    -------------------------------------------------------------------------------
    procedure SKIP_EVENT(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 EVENT      : in    EVENT_TYPE;           --! 読み飛ばすイベント.
                 GOOD       : out   boolean               --! 正常に読み取れたことを示す.
    ) is
    begin
        SKIP_EVENT(SELF.reader, STREAM, EVENT, GOOD);
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
        variable get_event  :       EVENT_TYPE;
        variable read_good  :       boolean;
        variable read_len   :       integer;
        variable seq_level  :       integer;
        variable match      :       boolean;
    begin
        seq_level := 0;
        FOUND     := FALSE;
        MAIN_LOOP: loop
            SEEK_EVENT(SELF, STREAM, get_event);
            case get_event is
                when EVENT_SEQ_BEGIN  =>
                    READ_EVENT(SELF, STREAM, get_event, read_good);
                    seq_level := seq_level + 1;
                when EVENT_SEQ_END    =>
                    if (seq_level > 0) then
                        READ_EVENT(SELF, STREAM, get_event, read_good);
                        seq_level := seq_level - 1;
                    end if;
                    exit when (seq_level = 0);
                when EVENT_SCALAR     =>
                    READ_EVENT(SELF, STREAM, get_event, read_good);
                    MATCH_KEY_WORD(SELF, SELF.name(SELF.name'range), match);
                    if (match) then
                        FOUND := TRUE;
                    end if;
                    exit when (seq_level = 0);
                when EVENT_ERROR     =>
                    EXECUTE_ABORT(SELF, string'("Check_My_Name:Read Error"));
                when others =>
                    SKIP_EVENT(SELF, STREAM, get_event, read_good);
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
        variable next_event :       EVENT_TYPE;
        variable read_good  :       boolean;
        variable skip_good  :       boolean;
        variable found      :       boolean;
    begin
        CHECK_LOOP: loop
            SEEK_EVENT(SELF, STREAM, next_event);
            case next_event is
                -------------------------------------------------------------------
                -- エラーだった場合.
                -------------------------------------------------------------------
                when EVENT_ERROR =>
                    EXECUTE_ABORT(SELF, string'("Check_First_Node:Read Error"));
                -------------------------------------------------------------------
                -- 最初のノードがマップだった場合.
                -- * 例１ ID: {...}
                -- * 例２ ID: [{...},{...}]
                -------------------------------------------------------------------
                when EVENT_MAP_BEGIN =>
                    READ_EVENT(SELF, STREAM, next_event, read_good);
                    check_my_name(SELF, STREAM, found);
                    if (found) then
                        SEEK_EVENT(SELF, STREAM, next_event);
                        if (next_event = EVENT_SEQ_BEGIN) then
                            READ_EVENT(SELF, STREAM, next_event, read_good);
                            NEXT_STATE := STATE_MAP_SEQ;
                        else
                            NEXT_STATE := STATE_MAP_VAL;
                        end if;
                    else
                        SEEK_EVENT(SELF, STREAM, next_event);
                        SKIP_EVENT(SELF, STREAM, next_event, skip_good);
                        NEXT_STATE := STATE_TOP_SEQ;
                    end if;
                    exit;
                -------------------------------------------------------------------
                -- 最初のノードがシーケンスだった場合.
                -- * 例１ [ID, {...}]
                -------------------------------------------------------------------
                when EVENT_SEQ_BEGIN =>
                    READ_EVENT(SELF, STREAM, next_event, read_good);
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
                    SKIP_EVENT(SELF, STREAM, next_event, skip_good);
                    next;
                -------------------------------------------------------------------
                -- 最初のノードがマップでもシーケンスでもなかった場合はエラー.
                -------------------------------------------------------------------
                when others =>
                    SKIP_EVENT(SELF, STREAM, next_event, skip_good);
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
        variable next_event :       EVENT_TYPE;
        variable next_state :       STATE_TYPE;
        variable read_good  :       boolean;
        variable skip_good  :       boolean;
        variable read_len   : integer;
        procedure REPORT_DEBUG(state:in STRING;event:EVENT_TYPE) is
        begin
            REPORT_DEBUG(SELF, string'("CORE_MAIN(state=") & state & 
                               string'(",next_event=") & EVENT_TO_STRING(event) & ")");
            if (SELF.debug > 1) then
                DEBUG_DUMP(SELF.reader);
            end if;
        end procedure;
    begin
        SELF.vocal.enable_debug := TRUE;
        MAIN_LOOP: loop
            SEEK_EVENT(SELF, STREAM, next_event);
            if (next_event = EVENT_ERROR) then
                EXECUTE_ABORT(SELF, string'("READ_OPERATION:Read Error"));
            end if;
            case SELF.curr_state is
                -------------------------------------------------------------------
                -- 初期状態.
                -------------------------------------------------------------------
                when STATE_NULL | STATE_STREAM =>
                    REPORT_DEBUG(string'("STATE_STREAM"),next_event);
                    case next_event is
                        when EVENT_DOC_BEGIN  => 
                            READ_EVENT(SELF, STREAM, next_event, read_good);
                            SELF.curr_state := STATE_DOCUMENT;
                            OPERATION       := OP_DOC_BEGIN;
                            exit;
                        when EVENT_STREAM_END =>
                            READ_EVENT(SELF, STREAM, next_event, read_good);
                            SELF.curr_state := STATE_NULL;
                            OPERATION       := OP_FINISH;
                            exit;
                        when others =>
                            SKIP_EVENT(SELF, STREAM, next_event, skip_good);
                    end case;
                -------------------------------------------------------------------
                -- ドキュメント処理中.
                -------------------------------------------------------------------
                when STATE_DOCUMENT =>
                    REPORT_DEBUG(string'("STATE_DOCUMENT"), next_event);
                    case next_event is
                        when EVENT_SEQ_BEGIN =>
                            READ_EVENT(SELF, STREAM, next_event, read_good);
                            SELF.curr_state := STATE_TOP_SEQ;
                        when EVENT_DOC_END   =>
                            READ_EVENT(SELF, STREAM, next_event, read_good);
                            SELF.curr_state := STATE_STREAM;
                            OPERATION       := OP_DOC_END;
                            exit;
                        when others =>
                            READ_EVENT(SELF, STREAM, next_event, read_good);
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
                            READ_EVENT(SELF, STREAM, next_event, read_good);
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
                            READ_EVENT(SELF, STREAM, next_event, read_good);
                            SEEK_EVENT(SELF, STREAM, next_event);
                            READ_EVENT(SELF, STREAM, next_event, read_good);
                            COPY_KEY_WORD(SELF, OP_WORD);
                            SELF.curr_state := STATE_OP_MAP;
                            SELF.prev_state := STATE_MAP_END;
                            OPERATION       := OP_MAP;
                            exit;
                        when EVENT_SCALAR =>
                            READ_EVENT(SELF, STREAM, next_event, read_good);
                            COPY_KEY_WORD(SELF, OP_WORD);
                            SELF.curr_state := STATE_OP_SCALAR;
                            SELF.prev_state := STATE_TOP_SEQ;
                            OPERATION       := OP_SCALAR;
                            exit;
                        when others =>
                            SKIP_EVENT(SELF, STREAM, next_event, skip_good);
                    end case;
                -------------------------------------------------------------------
                -- ID:[{...},{...}] を処理する状態.
                -------------------------------------------------------------------
                when STATE_MAP_SEQ =>
                    REPORT_DEBUG(string'("STATE_MAP_SEQ"), next_event);
                    case next_event is
                        when EVENT_SEQ_END =>
                            READ_EVENT(SELF, STREAM, next_event, read_good);
                            SELF.curr_state := STATE_MAP_END;
                        when EVENT_MAP_BEGIN =>
                            READ_EVENT(SELF, STREAM, next_event, read_good);
                            SEEK_EVENT(SELF, STREAM, next_event);
                            READ_EVENT(SELF, STREAM, next_event, read_good);
                            COPY_KEY_WORD(SELF, OP_WORD);
                            SELF.curr_state := STATE_OP_MAP;
                            SELF.prev_state := STATE_MAP_SEQ;
                            OPERATION       := OP_MAP;
                            exit;
                        when EVENT_SCALAR =>
                            READ_EVENT(SELF, STREAM, next_event, read_good);
                            COPY_KEY_WORD(SELF, OP_WORD);
                            SELF.curr_state := STATE_OP_SCALAR;
                            SELF.prev_state := STATE_MAP_SEQ;
                            OPERATION       := OP_SCALAR;
                            exit;
                        when others =>
                            SKIP_EVENT(SELF, STREAM, next_event, skip_good);
                    end case;
                -------------------------------------------------------------------
                -- [ID,{...},{...}] を処理する状態.
                -------------------------------------------------------------------
                when STATE_SEQ_VAL =>
                    REPORT_DEBUG(string'("STATE_SEQ_VAL"), next_event);
                    case next_event is
                        when EVENT_SEQ_END =>
                            READ_EVENT(SELF, STREAM, next_event, read_good);
                            SELF.curr_state := STATE_TOP_SEQ;
                        when EVENT_MAP_BEGIN =>
                            READ_EVENT(SELF, STREAM, next_event, read_good);
                            SEEK_EVENT(SELF, STREAM, next_event);
                            READ_EVENT(SELF, STREAM, next_event, read_good);
                            COPY_KEY_WORD(SELF, OP_WORD);
                            SELF.curr_state := STATE_OP_MAP;
                            SELF.prev_state := STATE_SEQ_VAL;
                            OPERATION       := OP_MAP;
                            exit;
                        when EVENT_SCALAR =>
                            READ_EVENT(SELF, STREAM, next_event, read_good);
                            COPY_KEY_WORD(SELF, OP_WORD);
                            SELF.curr_state := STATE_OP_SCALAR;
                            SELF.prev_state := STATE_SEQ_VAL;
                            OPERATION       := OP_SCALAR;
                            exit;
                        when others =>
                            SKIP_EVENT(SELF, STREAM, next_event, skip_good);
                    end case;
                -------------------------------------------------------------------
                -- [ID,{...},{...}]を読み飛ばす状態.
                -------------------------------------------------------------------
                when STATE_SEQ_SKIP =>
                    REPORT_DEBUG(string'("STATE_SEQ_SKIP"), next_event);
                    case next_event is
                        when EVENT_SEQ_END =>
                            READ_EVENT(SELF, STREAM, next_event, read_good);
                            SELF.curr_state := STATE_TOP_SEQ;
                        when others => 
                            SKIP_EVENT(SELF, STREAM, next_event, skip_good);
                    end case;
                -------------------------------------------------------------------
                -- {ID: {...}} または {ID: [{...},{...}]}の最後のEVENT_MAP_ENDを
                -- 読む状態.
                -------------------------------------------------------------------
                when STATE_MAP_END =>
                    REPORT_DEBUG(string'("STATE_MAP_END"), next_event);
                    case next_event is
                        when EVENT_MAP_END =>
                            READ_EVENT(SELF, STREAM, next_event, read_good);
                            SELF.curr_state := STATE_TOP_SEQ;
                        when others =>
                            SKIP_EVENT(SELF, STREAM, next_event, skip_good);
                            SELF.curr_state := STATE_TOP_SEQ;
                            -- ERROR
                    end case;
                -------------------------------------------------------------------
                -- OP_MAPを処理している状態.
                -------------------------------------------------------------------
                when STATE_OP_MAP =>
                    REPORT_DEBUG(string'("STATE_OP_MAP"), next_event);
                    case next_event is
                        when EVENT_MAP_END =>
                            READ_EVENT(SELF, STREAM, next_event, read_good);
                            SELF.curr_state := SELF.prev_state;
                        when others =>
                            READ_EVENT(SELF, STREAM, next_event, read_good);
                            SELF.curr_state := SELF.prev_state;
                            -- ERROR
                    end case;
                -------------------------------------------------------------------
                -- OP_SCALARを処理している状態.
                -------------------------------------------------------------------
                when STATE_OP_SCALAR =>
                    REPORT_DEBUG(string'("STATE_OP_SCALAR"), next_event);
                    SELF.curr_state := SELF.prev_state;
                when others =>
                    null;
                    -- ERROR
            end case;
        end loop;
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
        variable next_event :       EVENT_TYPE;
        variable read_good  :       boolean;
        variable skip_good  :       boolean;
    begin
        SEEK_EVENT(SELF, STREAM, next_event);
        if (next_event = EVENT_SCALAR) then
            READ_EVENT(SELF, STREAM, next_event, read_good);
            SAY(SELF.vocal, SELF.str_buf(1 to SELF.str_len));
        else
            SKIP_EVENT(SELF, STREAM, next_event, skip_good);
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief SKIPオペレーションを実行する.
    -------------------------------------------------------------------------------
    procedure EXECUTE_SKIP(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT                  --! 入力ストリーム.
    ) is
        variable next_event :       EVENT_TYPE;
        variable read_good  :       boolean;
    begin
        SEEK_EVENT(SELF, STREAM, next_event);
        if (next_event /= EVENT_ERROR) then
            SKIP_EVENT(SELF, STREAM, next_event, read_good);
            if (read_good = FALSE) then
                EXECUTE_ABORT(SELF, string'("EXECUTE SKIP:Read Error"));
            end if;
        else
                EXECUTE_ABORT(SELF, string'("EXECUTE SKIP:Read Error"));
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 不正なSCALARオペレーションを警告して読み飛ばす.
    -------------------------------------------------------------------------------
    constant  UNDEFINED_TAG        : STRING := "+++++ Warning :";
    procedure EXECUTE_UNDEFINED_SCALAR(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
        file     STREAM     :       TEXT;                 --! 入力ストリーム.
                 OP_WORD    : in    STRING
    ) is
    begin
        DEBUG_DUMP(SELF.reader);
        REPORT_READ_ERROR(SELF.vocal, string'("Undefined Map Operation(") & OP_WORD & ")");
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
        variable read_good  :       boolean;
    begin
        REPORT_READ_ERROR(SELF.vocal, string'("Undefined Scalar Operation(") & OP_WORD & ")");
        DEBUG_DUMP(SELF.reader);
        SEEK_EVENT(SELF, STREAM, next_event);
        SKIP_EVENT(SELF, STREAM, next_event, read_good);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 致命的エラーによる中断.
    -------------------------------------------------------------------------------
    procedure EXECUTE_ABORT(
        variable SELF       : inout CORE_TYPE;            --! コア変数.
                 MESSAGE    : in    STRING
    ) is
    begin
        REPORT_FAILURE(SELF.vocal, MESSAGE);
        DEBUG_DUMP(SELF.reader);
        assert FALSE report MESSAGE severity FAILURE;
    end procedure;
end CORE;
