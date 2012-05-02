-----------------------------------------------------------------------------------
--!     @file    axi4_master_player.vhd
--!     @brief   AXI4 Master Bus Function Model
--!     @version 0.0.2
--!     @date    2012/5/2
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
--! @brief AXI_TYPES 
-----------------------------------------------------------------------------------
package AXI4_TYPES is
    -------------------------------------------------------------------------------
    -- アドレスチャネルのバーストの長さ.
    -------------------------------------------------------------------------------
    constant  AXI4_ALEN_WIDTH      : integer := 4;
    subtype   AXI4_ALEN_TYPE       is std_logic_vector(AXI4_ALEN_WIDTH-1 downto 0);
    constant  AXI4_ALEN_1          : AXI4_ALEN_TYPE := "0000";
    constant  AXI4_ALEN_2          : AXI4_ALEN_TYPE := "0001";
    constant  AXI4_ALEN_3          : AXI4_ALEN_TYPE := "0010";
    constant  AXI4_ALEN_4          : AXI4_ALEN_TYPE := "0011";
    constant  AXI4_ALEN_5          : AXI4_ALEN_TYPE := "0100";
    constant  AXI4_ALEN_6          : AXI4_ALEN_TYPE := "0101";
    constant  AXI4_ALEN_7          : AXI4_ALEN_TYPE := "0110";
    constant  AXI4_ALEN_8          : AXI4_ALEN_TYPE := "0111";
    constant  AXI4_ALEN_9          : AXI4_ALEN_TYPE := "1000";
    constant  AXI4_ALEN_10         : AXI4_ALEN_TYPE := "1001";
    constant  AXI4_ALEN_11         : AXI4_ALEN_TYPE := "1010";
    constant  AXI4_ALEN_12         : AXI4_ALEN_TYPE := "1011";
    constant  AXI4_ALEN_13         : AXI4_ALEN_TYPE := "1100";
    constant  AXI4_ALEN_14         : AXI4_ALEN_TYPE := "1101";
    constant  AXI4_ALEN_15         : AXI4_ALEN_TYPE := "1110";
    constant  AXI4_ALEN_16         : AXI4_ALEN_TYPE := "1111";
    -------------------------------------------------------------------------------
    -- アドレスチャネルのバーストサイズ.
    -------------------------------------------------------------------------------
    constant  AXI4_ASIZE_WIDTH     : integer := 3;
    subtype   AXI4_ASIZE_TYPE      is std_logic_vector(AXI4_ASIZE_WIDTH-1  downto 0);
    constant  AXI4_ASIZE_1BYTE     : AXI4_ASIZE_TYPE := "000";
    constant  AXI4_ASIZE_2BYTE     : AXI4_ASIZE_TYPE := "001";
    constant  AXI4_ASIZE_4BYTE     : AXI4_ASIZE_TYPE := "010";
    constant  AXI4_ASIZE_8BYTE     : AXI4_ASIZE_TYPE := "011";
    constant  AXI4_ASIZE_16BYTE    : AXI4_ASIZE_TYPE := "100";
    constant  AXI4_ASIZE_32BYTE    : AXI4_ASIZE_TYPE := "101";
    constant  AXI4_ASIZE_64BYTE    : AXI4_ASIZE_TYPE := "110";
    constant  AXI4_ASIZE_128BYTE   : AXI4_ASIZE_TYPE := "111";
    -------------------------------------------------------------------------------
    -- アドレスチャネルのバーストタイプ.
    -------------------------------------------------------------------------------
    constant  AXI4_ABURST_WIDTH    : integer := 2;
    subtype   AXI4_ABURST_TYPE     is std_logic_vector(AXI4_ABURST_WIDTH-1 downto 0);
    constant  AXI4_ABURST_FIXED    : AXI4_ABURST_TYPE := "00";
    constant  AXI4_ABURST_INCR     : AXI4_ABURST_TYPE := "01";
    constant  AXI4_ABURST_WRAP     : AXI4_ABURST_TYPE := "10";
    constant  AXI4_ABURST_RESV     : AXI4_ABURST_TYPE := "11";
    -------------------------------------------------------------------------------
    -- アドレスチャネルの排他アクセスタイプ.
    -------------------------------------------------------------------------------
    constant  AXI4_ALOCK_WIDTH     : integer := 2;
    subtype   AXI4_ALOCK_TYPE      is std_logic_vector(AXI4_ALOCK_WIDTH -1 downto 0);
    -------------------------------------------------------------------------------
    -- アドレスチャネルのバーストタイプ.
    -------------------------------------------------------------------------------
    constant  AXI4_ACACHE_WIDTH    : integer := 4;
    subtype   AXI4_ACACHE_TYPE     is std_logic_vector(AXI4_ACACHE_WIDTH-1 downto 0);
    -------------------------------------------------------------------------------
    -- アドレスチャネルの保護ユニットサポート信号.
    -------------------------------------------------------------------------------
    constant  AXI4_APROT_WIDTH     : integer := 3;
    subtype   AXI4_APROT_TYPE      is std_logic_vector(AXI4_APROT_WIDTH -1 downto 0);
    -------------------------------------------------------------------------------
    -- 応答信号のタイプ.
    -------------------------------------------------------------------------------
    constant  AXI4_RESP_WIDTH      : integer := 2;
    subtype   AXI4_RESP_TYPE       is std_logic_vector(AXI4_RESP_WIDTH  -1 downto 0);
    constant  AXI4_RESP_OKAY       : AXI4_RESP_TYPE := "00";
    constant  AXI4_RESP_EXOKAY     : AXI4_RESP_TYPE := "01";
    constant  AXI4_RESP_SLVERR     : AXI4_RESP_TYPE := "10";
    constant  AXI4_RESP_DECERR     : AXI4_RESP_TYPE := "11";

end package;
