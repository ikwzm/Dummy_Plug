-----------------------------------------------------------------------------------
--!     @file    vocal.vhd
--!     @brief   Package for Dummy Plug Message Output.
--!     @version 2.0.0
--!     @date    2025/9/14
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2025 Ichiro Kawazome
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
-----------------------------------------------------------------------------------
--! @brief Dummy Plug の各種文字列を標準出力に出力するパッケージ.
-----------------------------------------------------------------------------------
package VOCAL is
    -------------------------------------------------------------------------------
    --! @brief コアの名前を保持する構造体.
    -------------------------------------------------------------------------------
    type      VOCAL_NAME_TYPE is record
        str                 : STRING(1 to 1024);
        lo                  : integer;
        hi                  : integer;
        len                 : integer;
    end record;
    -------------------------------------------------------------------------------
    --! @brief 各種タグを保持する構造体.
    -------------------------------------------------------------------------------
    type      VOCAL_TAG_TYPE is record
        str                 : STRING(1 to 32);
        lo                  : integer;
        hi                  : integer;
        len                 : integer;
    end record;
    -------------------------------------------------------------------------------
    --! @brief 各種タグを設定する関数.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        タグ変数.
    --! @param    TAG         セットするタグ.
    -------------------------------------------------------------------------------
    procedure SET_VOCAL_TAG(variable SELF:inout VOCAL_TAG_TYPE;TAG:in STRING);
    -------------------------------------------------------------------------------
    --! @brief 各種の状態を保持する構造体.
    -------------------------------------------------------------------------------
    type      VOCAL_TYPE is record
        name                : VOCAL_NAME_TYPE;
        tag_debug           : VOCAL_TAG_TYPE;
        tag_remark          : VOCAL_TAG_TYPE;
        tag_note            : VOCAL_TAG_TYPE;
        tag_warning         : VOCAL_TAG_TYPE;
        tag_mismatch        : VOCAL_TAG_TYPE;
        tag_error           : VOCAL_TAG_TYPE;
        tag_failure         : VOCAL_TAG_TYPE;
        tag_read_error      : VOCAL_TAG_TYPE;
        tag_field_width     : integer;
        time_field_width    : integer;
        name_field_width    : integer;
        enable_debug        : boolean;
        enable_remark       : boolean;
        enable_note         : boolean;
        enable_warning      : boolean;
        enable_mismatch     : boolean;
        enable_error        : boolean;
        enable_failure      : boolean;
    end record;
    -------------------------------------------------------------------------------
    --! @brief 各種の状態を保持する構造体の初期化用定数を生成する関数.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    NAME    名前.
    --! @return        生成した定数.
    -------------------------------------------------------------------------------
    function  NEW_VOCAL(NAME: STRING) return VOCAL_TYPE;
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にDEBUGメッセージを出力するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF    ボーカル変数.
    --! @param    MESSAGE 出力するメッセージ.
    -------------------------------------------------------------------------------
    procedure REPORT_DEBUG   (SELF:inout VOCAL_TYPE;MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にREMARKメッセージを出力するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF    ボーカル変数.
    --! @param    MESSAGE 出力するメッセージ.
    -------------------------------------------------------------------------------
    procedure REPORT_REMARK  (SELF:inout VOCAL_TYPE;MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にNOTEメッセージを出力するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF    ボーカル変数.
    --! @param    MESSAGE 出力するメッセージ.
    -------------------------------------------------------------------------------
    procedure REPORT_NOTE    (SELF:inout VOCAL_TYPE;MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にWARNINGメッセージを出力するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF    ボーカル変数.
    --! @param    MESSAGE 出力するメッセージ.
    -------------------------------------------------------------------------------
    procedure REPORT_WARNING (SELF:inout VOCAL_TYPE;MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にMISMATCHメッセージを出力するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF    ボーカル変数.
    --! @param    MESSAGE 出力するメッセージ.
    -------------------------------------------------------------------------------
    procedure REPORT_MISMATCH(SELF:inout VOCAL_TYPE;MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にERRORメッセージを出力するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF    ボーカル変数.
    --! @param    MESSAGE 出力するメッセージ.
    -------------------------------------------------------------------------------
    procedure REPORT_ERROR   (SELF:inout VOCAL_TYPE;MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にFAILUREメッセージを出力するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF    ボーカル変数.
    --! @param    MESSAGE 出力するメッセージ.
    -------------------------------------------------------------------------------
    procedure REPORT_FAILURE (SELF:inout VOCAL_TYPE;MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にシナリオリードエラーメッセージを出力するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF    ボーカル変数.
    --! @param    MESSAGE 出力するメッセージ.
    -------------------------------------------------------------------------------
    procedure REPORT_READ_ERROR(SELF:inout VOCAL_TYPE;MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)に適当にメッセージを出力するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF    ボーカル変数.
    --! @param    MESSAGE 出力するメッセージ.
    -------------------------------------------------------------------------------
    procedure SAY  (SELF:inout VOCAL_TYPE;MESSAGE:in STRING);
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)に適当にメッセージを出力するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF    ボーカル変数.
    --! @param    MESSAGE 出力するメッセージ.
    -------------------------------------------------------------------------------
    procedure SHOUT(SELF:inout VOCAL_TYPE;MESSAGE:in STRING);
end VOCAL;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     std.textio.all;
-----------------------------------------------------------------------------------
--! @brief Dummy Plug の各種文字列を標準出力に出力するパッケージの本体.
-----------------------------------------------------------------------------------
package body  VOCAL is
    -------------------------------------------------------------------------------
    --! @brief 名前を設定する関数.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        名前の変数.
    --! @param    NAME        セットする識別名.
    -------------------------------------------------------------------------------
    procedure set_vocal_name(
        variable  SELF          : inout VOCAL_NAME_TYPE;
                  NAME          : in    STRING
    ) is
    begin
        if (NAME'length > SELF.str'length) then
            SELF.len := SELF.str'length;
        else
            SELF.len := NAME'length;
        end if;
        SELF.lo := 1;
        SELF.hi := SELF.len;
        SELF.str(SELF.lo to SELF.hi) := NAME(SELF.lo to SELF.hi);
    end set_vocal_name;
    -------------------------------------------------------------------------------
    --! @brief デフォルトの出力用タグ
    -------------------------------------------------------------------------------
    constant  DEFAULT_TAG_DEBUG          : STRING  := ">>>>> Debug   :";
    constant  DEFAULT_TAG_REMARK         : STRING  := "----- Remark  :";
    constant  DEFAULT_TAG_NOTE           : STRING  := "----- Note    :";
    constant  DEFAULT_TAG_WARNING        : STRING  := "+++++ Warning :";
    constant  DEFAULT_TAG_MISMATCH       : STRING  := "????? Mismatch:";
    constant  DEFAULT_TAG_ERROR          : STRING  := "***** Error   :";
    constant  DEFAULT_TAG_FAILURE        : STRING  := "##### Failure :";
    constant  DEFAULT_TAG_READ_ERROR     : STRING  := "!!!!Read Error:";
    -------------------------------------------------------------------------------
    --! @brief 各種タグを設定する関数.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        タグ変数.
    --! @param    TAG         セットするタグ.
    -------------------------------------------------------------------------------
    procedure SET_VOCAL_TAG(
        variable  SELF          : inout VOCAL_TAG_TYPE;
                  TAG           : in    STRING
    ) is
    begin 
        if (TAG'length > SELF.str'length) then
            SELF.len := SELF.str'length;
        else
            SELF.len := TAG'length;
        end if;
        SELF.lo := 1;
        SELF.hi := SELF.len;
        SELF.str(SELF.lo to SELF.hi) := TAG(SELF.lo to SELF.hi);
    end SET_VOCAL_TAG;
    -------------------------------------------------------------------------------
    --! @brief デフォルトの各フィールド幅
    -------------------------------------------------------------------------------
    constant  DEFAULT_TIME_FIELD_WIDTH   : integer := 13;
    constant  DEFAULT_NAME_FIELD_WIDTH   : integer := 8;
    constant  DEFAULT_TAG_FIELD_WIDTH    : integer := -15;
    -------------------------------------------------------------------------------
    --! @brief 各種の状態を保持する構造体の初期化用定数を生成する関数.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    NAME    名前.
    --! @return           生成した定数.
    -------------------------------------------------------------------------------
    function  NEW_VOCAL(
                 NAME       : STRING 
    ) return VOCAL_TYPE is
        variable self       : VOCAL_TYPE;
    begin
        set_vocal_name(self.name         , NAME);
        SET_VOCAL_TAG(self.tag_debug     , DEFAULT_TAG_DEBUG     );
        SET_VOCAL_TAG(self.tag_remark    , DEFAULT_TAG_REMARK    );
        SET_VOCAL_TAG(self.tag_note      , DEFAULT_TAG_NOTE      );
        SET_VOCAL_TAG(self.tag_warning   , DEFAULT_TAG_WARNING   );
        SET_VOCAL_TAG(self.tag_mismatch  , DEFAULT_TAG_MISMATCH  );
        SET_VOCAL_TAG(self.tag_error     , DEFAULT_TAG_ERROR     );
        SET_VOCAL_TAG(self.tag_failure   , DEFAULT_TAG_FAILURE   );
        SET_VOCAL_TAG(self.tag_read_error, DEFAULT_TAG_READ_ERROR);
        self.time_field_width := DEFAULT_TIME_FIELD_WIDTH;
        self.name_field_width := DEFAULT_NAME_FIELD_WIDTH;
        self.tag_field_width  := DEFAULT_TAG_FIELD_WIDTH;
        self.enable_debug     := FALSE;
        self.enable_remark    := TRUE;
        self.enable_note      := TRUE;
        self.enable_warning   := TRUE;
        self.enable_mismatch  := TRUE;
        self.enable_error     := TRUE;
        self.enable_failure   := TRUE;
        return self;
    end function;
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にメッセージを出力するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF    ボーカル変数.
    --! @param    TAG     タグ.
    --! @param    MESSAGE 出力するメッセージ.
    -------------------------------------------------------------------------------
    procedure REPORT_MESSAGE(SELF:inout VOCAL_TYPE; TAG:inout VOCAL_TAG_TYPE; MESSAGE:in STRING) is
        variable text_line   : LINE;
    begin
        if    (SELF.tag_field_width > 0) then
            WRITE(text_line, TAG.str(TAG.lo to TAG.hi), RIGHT,  SELF.tag_field_width);
            WRITE(text_line, string'(" "));
        elsif (SELF.tag_field_width < 0) then
            WRITE(text_line, TAG.str(TAG.lo to TAG.hi), LEFT , -SELF.tag_field_width);
            WRITE(text_line, string'(" "));
        end if;
        if    (SELF.time_field_width > 0) then
            WRITE(text_line, Now, RIGHT,  SELF.time_field_width);
        elsif (SELF.time_field_width < 0) then
            WRITE(text_line, Now, LEFT , -SELF.time_field_width);
        end if;
        WRITE(text_line, " (" & SELF.name.str(SELF.name.lo to SELF.name.hi) & ") " & MESSAGE);
        WRITELINE(OUTPUT, text_line);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にDEBUGメッセージを出力するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF    ボーカル変数.
    --! @param    MESSAGE 出力するメッセージ.
    -------------------------------------------------------------------------------
    procedure REPORT_DEBUG(SELF:inout VOCAL_TYPE;MESSAGE:in STRING) is
    begin
        if (SELF.enable_debug) then 
            REPORT_MESSAGE(SELF, SELF.tag_debug, MESSAGE);
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にREMARKメッセージを出力するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF    ボーカル変数.
    --! @param    MESSAGE 出力するメッセージ.
    -------------------------------------------------------------------------------
    procedure REPORT_REMARK(SELF:inout VOCAL_TYPE;MESSAGE:in STRING) is
    begin
        if (SELF.enable_remark) then 
            REPORT_MESSAGE(SELF, SELF.tag_remark, MESSAGE);
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にNOTEメッセージを出力するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF    ボーカル変数.
    --! @param    MESSAGE 出力するメッセージ.
    -------------------------------------------------------------------------------
    procedure REPORT_NOTE(SELF:inout VOCAL_TYPE;MESSAGE:in STRING) is
    begin
        if (SELF.enable_note) then 
            REPORT_MESSAGE(SELF, SELF.tag_note, MESSAGE);
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にWARNINGメッセージを出力するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF    ボーカル変数.
    --! @param    MESSAGE 出力するメッセージ.
    -------------------------------------------------------------------------------
    procedure REPORT_WARNING(SELF:inout VOCAL_TYPE;MESSAGE:in STRING) is
    begin
        if (SELF.enable_warning) then 
            REPORT_MESSAGE(SELF, SELF.tag_warning, MESSAGE);
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にMISMATCHメッセージを出力するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF    ボーカル変数.
    --! @param    MESSAGE 出力するメッセージ.
    -------------------------------------------------------------------------------
    procedure REPORT_MISMATCH(SELF:inout VOCAL_TYPE;MESSAGE:in STRING) is
    begin
        if (SELF.enable_mismatch) then 
            REPORT_MESSAGE(SELF, SELF.tag_mismatch, MESSAGE);
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にERRORメッセージを出力するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF    ボーカル変数.
    --! @param    MESSAGE 出力するメッセージ.
    -------------------------------------------------------------------------------
    procedure REPORT_ERROR(SELF:inout VOCAL_TYPE;MESSAGE:in STRING) is
    begin
        if (SELF.enable_error) then 
            REPORT_MESSAGE(SELF, SELF.tag_error, MESSAGE);
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にFAILUREメッセージを出力するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF    ボーカル変数.
    --! @param    MESSAGE 出力するメッセージ.
    -------------------------------------------------------------------------------
    procedure REPORT_FAILURE(SELF:inout VOCAL_TYPE;MESSAGE:in STRING) is
    begin
        if (SELF.enable_failure) then 
            REPORT_MESSAGE(SELF, SELF.tag_failure, MESSAGE);
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)にシナリオリードエラーメッセージを出力するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF    ボーカル変数.
    --! @param    MESSAGE 出力するメッセージ.
    -------------------------------------------------------------------------------
    procedure REPORT_READ_ERROR(SELF:inout VOCAL_TYPE;MESSAGE:in STRING) is
    begin
        REPORT_MESSAGE(SELF, SELF.tag_read_error, MESSAGE);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)に適当にメッセージを出力するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF    ボーカル変数.
    --! @param    MESSAGE 出力するメッセージ.
    -------------------------------------------------------------------------------
    procedure SAY(SELF:inout VOCAL_TYPE;MESSAGE:in STRING) is
        variable text_line   : LINE;
    begin
        if    (SELF.time_field_width > 0) then
            WRITE(text_line, Now, RIGHT,  SELF.time_field_width);
            WRITE(text_line, string'("|"));
        elsif (SELF.time_field_width < 0) then
            WRITE(text_line, Now, LEFT , -SELF.time_field_width);
            WRITE(text_line, string'("|"));
        end if;
        if    (SELF.name_field_width > 0) then
            WRITE(text_line, SELF.name.str(SELF.name.lo to SELF.name.hi), RIGHT,  SELF.name_field_width);
            WRITE(text_line, string'(" < "));
        elsif (SELF.name_field_width < 0) then
            WRITE(text_line, SELF.name.str(SELF.name.lo to SELF.name.hi), LEFT , -SELF.name_field_width);
            WRITE(text_line, string'(" < "));
        end if;
        WRITE(text_line, MESSAGE);
        WRITELINE(OUTPUT, text_line);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 標準出力(OUTPUT)に適当にメッセージを出力するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF    ボーカル変数.
    --! @param    MESSAGE 出力するメッセージ.
    -------------------------------------------------------------------------------
    procedure SHOUT(SELF:inout VOCAL_TYPE;MESSAGE:in STRING) is
        variable text_line   : LINE;
    begin
        if    (SELF.time_field_width > 0) then
            WRITE(text_line, Now, RIGHT,  SELF.time_field_width);
            WRITE(text_line, string'("|"));
        elsif (SELF.time_field_width < 0) then
            WRITE(text_line, Now, LEFT , -SELF.time_field_width);
            WRITE(text_line, string'("|"));
        end if;
        if    (SELF.name_field_width > 0) then
            WRITE(text_line, SELF.name.str(SELF.name.lo to SELF.name.hi), RIGHT,  SELF.name_field_width);
            WRITE(text_line, string'(" < "));
        elsif (SELF.name_field_width < 0) then
            WRITE(text_line, SELF.name.str(SELF.name.lo to SELF.name.hi), LEFT , -SELF.name_field_width);
            WRITE(text_line, string'(" < "));
        end if;
        WRITE(text_line, MESSAGE);
        WRITELINE(OUTPUT, text_line);
    end procedure;
end VOCAL;
