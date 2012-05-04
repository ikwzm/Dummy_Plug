-----------------------------------------------------------------------------------
--!     @file    sync_alt.vhd
--!     @brief   Package for Synchronize some dummy-plugs.
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
-----------------------------------------------------------------------------------
--! @brief Dummy Plug のモデル間で同期するためのパッケージ.
--!      * 同期のための信号がstd_logic_vectorになっているバージョン.
--!      * 同じパッケージとして sync.vhd があるが、機能は同じはず.
--!        こちらは GHDL(Windows版) で不具合対応.
--!      * GHDL(Windows版)で動作する代わりに、接続できるDUMMY_PLUGの本数に制限がある.
-----------------------------------------------------------------------------------
package SYNC is
    -------------------------------------------------------------------------------
    --! @brief モデル間同期(SYNC)できる本数の最大値.
    -------------------------------------------------------------------------------
    constant  SYNC_MAX_PLUG_SIZE: integer := 32;
    -------------------------------------------------------------------------------
    --! @brief モデル間同期(SYNC)できる本数を指定するタイプ宣言.
    -------------------------------------------------------------------------------
    subtype   SYNC_PLUG_NUM_TYPE   is integer range 1 to SYNC_MAX_PLUG_SIZE;
    -------------------------------------------------------------------------------
    --! @brief モデル間同期(SYNC)のための信号のタイプ宣言.
    -------------------------------------------------------------------------------
    subtype   SYNC_SIG_TYPE        is std_logic_vector(1 to SYNC_MAX_PLUG_SIZE);
    type      SYNC_SIG_VECTOR      is array (INTEGER range <>) of SYNC_SIG_TYPE;
    -------------------------------------------------------------------------------
    --! @brief モデル間同期(SYNC)のための信号を制御するための信号のタイプ宣言.
    -------------------------------------------------------------------------------
    subtype   SYNC_REQ_TYPE        is integer;
    subtype   SYNC_ACK_TYPE        is std_logic;
    type      SYNC_REQ_VECTOR      is array (INTEGER range <>) of SYNC_REQ_TYPE;
    type      SYNC_ACK_VECTOR      is array (INTEGER range <>) of SYNC_ACK_TYPE;
    -------------------------------------------------------------------------------
    --! @brief モデル間同期(SYNC)開始サブプログラム.
    -------------------------------------------------------------------------------
    procedure SYNC_BEGIN(
        signal   SYNC_REQ : out   SYNC_REQ_VECTOR;
                 SYNC_CNT : in    SYNC_REQ_VECTOR
    );
    -------------------------------------------------------------------------------
    --! @brief モデル間同期(SYNC)が完了したかどうかを調べるサブプログラム.
    -------------------------------------------------------------------------------
    procedure SYNC_CHECK(
        signal   SYNC_REQ : out   SYNC_REQ_VECTOR;
        signal   SYNC_ACK : in    SYNC_ACK_VECTOR;
                 SYNC_CNT : inout SYNC_REQ_VECTOR;
                 DONE     : out   boolean
    );
    -------------------------------------------------------------------------------
    --! @brief モデル間同期(SYNC)終了サブプログラム.
    -------------------------------------------------------------------------------
    procedure SYNC_END  (
        signal   SYNC_REQ : out   SYNC_REQ_VECTOR;
        signal   SYNC_ACK : in    SYNC_ACK_VECTOR;
                 SYNC_CNT : in    SYNC_REQ_VECTOR
    );
    -------------------------------------------------------------------------------
    --! @brief モデル間同期(SYNC)信号を制御するコンポーネント.
    -------------------------------------------------------------------------------
    component SYNC_SIG_DRIVER
        generic (
                 PLUG_NUM :       SYNC_PLUG_NUM_TYPE
        );
        port (
                 CLK      : in    std_logic;
                 RST      : in    std_logic;
                 CLR      : in    std_logic;
                 SYNC     : inout SYNC_SIG_TYPE;
                 REQ      : in    SYNC_REQ_TYPE;
                 ACK      : out   SYNC_ACK_TYPE
        );
    end component;
    -------------------------------------------------------------------------------
    --! @brief モジュール内でローカルにモデル間同期するためのコンポーネント.
    -------------------------------------------------------------------------------
    component SYNC_LOCAL_HUB
        generic (
                 PLUG_SIZE:       SYNC_PLUG_NUM_TYPE
        );
        port (
                 CLK      : in    std_logic;
                 RST      : in    std_logic;
                 CLR      : in    std_logic;
                 REQ      : in    SYNC_REQ_VECTOR(1 to PLUG_SIZE);
                 ACK      : out   SYNC_ACK_VECTOR(1 to PLUG_SIZE)
        );
    end component;
end package;
-----------------------------------------------------------------------------------
-- SYNC :
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     std.textio.all;
-----------------------------------------------------------------------------------
--! @brief Dummy Plug のモデル間で同期するためのパッケージ.
-----------------------------------------------------------------------------------
package body SYNC is
    -------------------------------------------------------------------------------
    --! @brief モデル間同期(SYNC)開始サブプログラム.
    -------------------------------------------------------------------------------
    procedure SYNC_BEGIN(
        signal   SYNC_REQ : out   SYNC_REQ_VECTOR;
                 SYNC_CNT : in    SYNC_REQ_VECTOR
    ) is
    begin
        ---------------------------------------------------------------------------
        -- SYNC_REQ信号に SYNC_CNT を出力.
        ---------------------------------------------------------------------------
        SYNC_REQ <= SYNC_CNT;
        ---------------------------------------------------------------------------
        -- SYNC_CNTの値がSYNC_REQ信号に反映されるまでのΔ時間だけ待つ.
        ---------------------------------------------------------------------------
        wait for 0 ns;
        ---------------------------------------------------------------------------
        -- SYNC_SIG_DRIVER にて SYNC_REQ信号が変化して SYNC 信号に反映されるまでの
        -- Δ時間だけ待つ.
        ---------------------------------------------------------------------------
        wait for 0 ns;
        ---------------------------------------------------------------------------
        -- SYNC_SIG_DRIVER にて SYNC信号が変化して SYNC_ACK 信号に反映されるまで
        -- のΔ時間だけ待つ.
        ---------------------------------------------------------------------------
        wait for 0 ns;
    end SYNC_BEGIN;
    -------------------------------------------------------------------------------
    --! @brief モデル間同期(SYNC)が完了したかどうかを調べるサブプログラム.
    -------------------------------------------------------------------------------
    procedure SYNC_CHECK(
        signal   SYNC_REQ : out   SYNC_REQ_VECTOR;
        signal   SYNC_ACK : in    SYNC_ACK_VECTOR;
                 SYNC_CNT : inout SYNC_REQ_VECTOR;
                 DONE     : out   boolean
    ) is 
        variable use_sync :       std_logic_vector(SYNC_CNT'range);
        constant all_done :       std_logic_vector(SYNC_CNT'range) := (others => '0');
    begin
        use_sync := (others => '1');
        for i in SYNC_CNT'range loop
            if (SYNC_CNT(i) > 0 and SYNC_ACK(i) = '1') then
                SYNC_CNT(i) := 0;
                SYNC_REQ(i) <= 0;
            end if;
            if (SYNC_CNT(i) > 0) then
                use_sync(i) := '1';
            else
                use_sync(i) := '0';
            end if;
        end loop;
        DONE := (use_sync = all_done);
    end SYNC_CHECK;
    -------------------------------------------------------------------------------
    --! @brief モデル間同期(SYNC)終了サブプログラム.
    -------------------------------------------------------------------------------
    procedure SYNC_END  (
        signal   SYNC_REQ : out   SYNC_REQ_VECTOR;
        signal   SYNC_ACK : in    SYNC_ACK_VECTOR;
                 SYNC_CNT : in    SYNC_REQ_VECTOR
    ) is 
        variable count    :       SYNC_REQ_VECTOR (SYNC_CNT'range);
        variable done     :       boolean;
    begin
        count := SYNC_CNT;
        ---------------------------------------------------------------------------
        -- SYNC_CHECKを実行して done が TRUE になるまで待つループ.
        ---------------------------------------------------------------------------
        WAIT_SYNC_ACK_LOOP : loop
            SYNC_CHECK(SYNC_REQ => SYNC_REQ, -- Out: SYNC_REQ_VECTOR;
                       SYNC_ACK => SYNC_ACK, -- In : SYNC_ACK_VECTOR;
                       SYNC_CNT => count,    -- I/O: SYNC_REQ_VECTOR;
                       DONE     => done);    -- Out: boolean;
            exit when done;
            wait on SYNC_ACK; -- 超重要 これがないとシミュレーターが無限ループに陥る
        end loop;
        ---------------------------------------------------------------------------
        -- SYNC_CNTをクリアしたのがSYNC_REQ信号に反映されるまでのΔ時間だけ待つ.
        ---------------------------------------------------------------------------
        wait for 0 ns;
    end SYNC_END;
end package body;
-----------------------------------------------------------------------------------
-- SYNC_SIG_DRIVER : 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.SYNC.all;
-----------------------------------------------------------------------------------
--! @brief モデル間同期(SYNC)信号を制御するコンポーネント.
-----------------------------------------------------------------------------------
entity  SYNC_SIG_DRIVER is
    generic (
        PLUG_NUM :       SYNC_PLUG_NUM_TYPE
    );
    port (
        CLK      : in    std_logic;
        RST      : in    std_logic;
        CLR      : in    std_logic;
        SYNC     : inout SYNC_SIG_TYPE;
        REQ      : in    SYNC_REQ_TYPE;
        ACK      : out   SYNC_ACK_TYPE
    );
end     SYNC_SIG_DRIVER;
architecture MODEL of SYNC_SIG_DRIVER is
  component SYNC_SIG_DRIVER_SUB_UNIT
    port (
        CLK      : in    std_logic;
        RST      : in    std_logic;
        CLR      : in    std_logic;
        SYNC_I   : in    SYNC_SIG_TYPE;
        SYNC_O   : out   std_logic;
        REQ      : in    integer  ;
        ACK      : out   std_logic
    );
  end component;
begin
    U: SYNC_SIG_DRIVER_SUB_UNIT port map(
        CLK      => CLK,
        RST      => RST,
        CLR      => CLR,
        SYNC_I   => SYNC,
        SYNC_O   => SYNC(PLUG_NUM),
        REQ      => REQ,
        ACK      => ACK
    );
end MODEL;
-----------------------------------------------------------------------------------
-- SYNC_SIG_DRIVER_SUB_UNIT :
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.SYNC.all;
-----------------------------------------------------------------------------------
--! @brief モデル間同期(SYNC)信号を制御するコンポーネントのサブユニット.
-----------------------------------------------------------------------------------
entity  SYNC_SIG_DRIVER_SUB_UNIT is
    port (
        CLK      : in    std_logic;
        RST      : in    std_logic;
        CLR      : in    std_logic;
        SYNC_I   : in    SYNC_SIG_TYPE;
        SYNC_O   : out   std_logic;
        REQ      : in    SYNC_REQ_TYPE;
        ACK      : out   SYNC_ACK_TYPE
    );
end     SYNC_SIG_DRIVER_SUB_UNIT;
architecture MODEL of SYNC_SIG_DRIVER_SUB_UNIT is
    function ALL_ONE(SYNC : SYNC_SIG_TYPE) return boolean is
        variable sync_vec : SYNC_SIG_TYPE;
        constant all_1    : SYNC_SIG_TYPE := (others => '1');
    begin
        for i in SYNC'range loop
            if (SYNC(i) = '0') then
                sync_vec(i) := '0';
            else
                sync_vec(i) := '1';
            end if;
        end loop;
        if (sync_vec = all_1) then
            return true;
        else
            return false;
        end if;
    end function;
begin
    process 
        variable sync_delay : integer;
    begin
        SYNC_O <= 'Z';
        ACK    <= '0';
        SYNC_LOOP: loop
            if (REQ > 0) then
                sync_delay := REQ;
                if (sync_delay >= 2) then
                    for i in 2 to sync_delay loop
                        wait until (CLK'event and CLK = '1');
                    end loop;
                end if;
                SYNC_O <= 'H';
                wait until (ALL_ONE(SYNC_I));
                SYNC_O <= '0';
                ACK    <= '1';
                wait until (REQ = 0);
                ACK    <= '0';
            elsif (REQ = 0) then
                SYNC_O <= '0';
            else
                SYNC_O <= 'Z';
            end if;
            wait on REQ;
        end loop;
    end process;
end MODEL;
-----------------------------------------------------------------------------------
-- SYNC_LOCAL_HUB : 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.SYNC.all;
-----------------------------------------------------------------------------------
--! @brief モジュール内でローカルにモデル間同期するためのコンポーネント.
-----------------------------------------------------------------------------------
entity SYNC_LOCAL_HUB is
    generic (
        PLUG_SIZE:       SYNC_PLUG_NUM_TYPE
    );
    port (
        CLK      : in    std_logic;
        RST      : in    std_logic;
        CLR      : in    std_logic;
        REQ      : in    SYNC_REQ_VECTOR(1 to PLUG_SIZE);
        ACK      : out   SYNC_ACK_VECTOR(1 to PLUG_SIZE)
    );
end SYNC_LOCAL_HUB;
architecture MODEL of SYNC_LOCAL_HUB is
    signal   sync     : SYNC_SIG_TYPE;
begin
    PLUG : for i in 1 to PLUG_SIZE generate
        DRIVER : SYNC_SIG_DRIVER generic map (i) port map (
            CLK      => CLK   ,   --! In  : 
            RST      => RST   ,   --! In  : 
            CLR      => CLR   ,   --! In  : 
            SYNC     => sync  ,   --! I/O : 
            REQ      => REQ(i),   --! In  : 
            ACK      => ACK(i)    --! Out : 
        );
    end generate;
end MODEL;
----------------------------------------------------------------------------------
--
----------------------------------------------------------------------------------
