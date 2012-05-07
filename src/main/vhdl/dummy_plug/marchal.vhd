-----------------------------------------------------------------------------------
--!     @file    marchal.vhd
--!     @brief   Marchal Dummy Plug Player.
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
use     DUMMY_PLUG.SYNC.SYNC_SIG_VECTOR;
use     DUMMY_PLUG.SYNC.SYNC_PLUG_NUM_TYPE;
-----------------------------------------------------------------------------------
--! @brief   MARCHAL
-----------------------------------------------------------------------------------
entity  MARCHAL is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        SCENARIO_FILE   : --! @brief シナリオファイルの名前.
                          STRING;
        NAME            : --! @brief 固有名詞.
                          STRING;
        SYNC_PLUG_NUM   : --! @brief シンクロ用信号のプラグ番号.
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
        CLK             : in    std_logic;
        --------------------------------------------------------------------------
        -- グローバルシグナル.
        --------------------------------------------------------------------------
        RESET           : out   std_logic;
        --------------------------------------------------------------------------
        -- シンクロ用信号
        --------------------------------------------------------------------------
        SYNC            : inout SYNC_SIG_VECTOR(SYNC_WIDTH-1 downto 0);
        FINISH          : out   std_logic
    );
end MARCHAL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.CORE.all;
use     DUMMY_PLUG.SYNC.all;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
architecture MODEL of MARCHAL is
    -------------------------------------------------------------------------------
    --! SYNC 制御信号
    -------------------------------------------------------------------------------
    signal    sync_req          : SYNC_REQ_VECTOR(SYNC'range);
    signal    sync_ack          : SYNC_ACK_VECTOR(SYNC'range);
    signal    sync_rst          : std_logic := '0';
    signal    sync_clr          : std_logic := '0';
    signal    sync_debug        : boolean   := FALSE;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process
        file      stream        : TEXT;
        variable  core          : CORE_TYPE;
        variable  operation     : OPERATION_TYPE;
        variable  op_code       : STRING(1 to 3);
        constant  OP_SAY        : STRING(1 to 3) := "SAY";
    begin
        ---------------------------------------------------------------------------
        --! ダミープラグコアの初期化.
        ---------------------------------------------------------------------------
        CORE_INIT(
            SELF        => core,          --! 初期化するコア変数.
            NAME        => NAME,          --! コアの名前.
            STREAM      => stream,        --! シナリオのストリーム.
            STREAM_NAME => SCENARIO_FILE, --! シナリオのストリーム名.
            OPERATION   => operation      --! コアのオペレーション.
        );
        ---------------------------------------------------------------------------
        --! リセット信号の生成.
        ---------------------------------------------------------------------------
        sync_req <= (0 => 10, others => 0);
        FINISH   <= '0';
        sync_rst <= '1';
        sync_clr <= '0';
        RESET    <= '1';
        wait until(CLK'event and CLK = '1');
        sync_rst <= '0';
        RESET    <= '0';
        wait until(CLK'event and CLK = '1');
        ---------------------------------------------------------------------------
        --! ダミーコアメインループ
        ---------------------------------------------------------------------------
        core.debug := 0;
        MAIN_LOOP: while (operation /= OP_FINISH) loop
            READ_OPERATION(core, stream, operation, op_code);
            case operation is
                when OP_DOC_BEGIN =>
                    CORE_SYNC(core, 0, 2, sync_req, sync_ack);
                when OP_MAP    =>
                    case op_code is
                        when OP_SAY => EXECUTE_SAY (core, stream);
                        when others => EXECUTE_SKIP(core, stream);
                    end case;
                when OP_SCALAR =>
                when OP_FINISH => exit;
                when others    => null;
            end case;
        end loop;
        FINISH <= '1';
        if (FINISH_ABORT) then
            assert FALSE report "Simulation complete." severity FAILURE;
        end if;
        wait;
    end process;
    -------------------------------------------------------------------------------
    --! @ SYNC制御
    -------------------------------------------------------------------------------
    SYNC_DRIVER: for i in SYNC'range generate
        UNIT: SYNC_SIG_DRIVER
            generic map (
                NAME     => string'("MARCHAL:SYNC"),
                PLUG_NUM => SYNC_PLUG_NUM
            )
            port map (
                CLK      => CLK ,                -- In :
                RST      => sync_rst,            -- In :
                CLR      => sync_clr,            -- In :
                DEBUG    => sync_debug,          -- In :
                SYNC     => SYNC(i),             -- I/O:
                REQ      => sync_req(i),         -- In :
                ACK      => sync_ack(i)          -- Out:
            );
    end generate;
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
