-----------------------------------------------------------------------------
--
-- AXI Master用 Bus Function Mode (BFM)
--
-- このコードはFPGAの部屋(http://marsee101.blog19.fc2.com/blog-entry-2110.html)から拝借しています。
--
-----------------------------------------------------------------------------
-- 2012/02/25 : M_AXI_AWBURST＝1 (INCR) にのみ対応、AWSIZE, ARSIZE = 000 (1byte), 001 (2bytes), 010 (4bytes) のみ対応。

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- use ieee.std_logic_misc.all;

package m_seq_bfm_pack is
    function M_SEQ16_BFM_F(mseq16in : std_logic_vector
        )return std_logic_vector;
end package m_seq_bfm_pack;
package body m_seq_bfm_pack is
    function M_SEQ16_BFM_F(mseq16in : std_logic_vector
        )return std_logic_vector is
            variable mseq16 : std_logic_vector(15 downto 0);
            variable xor_result : std_logic;
    begin
        xor_result := mseq16in(15) xor mseq16in(12) xor mseq16in(10) xor mseq16in(8) xor mseq16in(7) xor mseq16in(6) xor mseq16in(3) xor mseq16in(2);
        mseq16 := mseq16in(14 downto 0) & xor_result;
        return mseq16;
    end M_SEQ16_BFM_F;
end m_seq_bfm_pack;


library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_unsigned.all;
-- use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

library work;
use work.m_seq_bfm_pack.all;

--library unisim;
--use unisim.vcomponents.all;

entity axi_master_bfm is
  generic (
    C_M_AXI_ID_WIDTH     : integer := 1;
    C_M_AXI_ADDR_WIDTH   : integer := 32;
    C_M_AXI_DATA_WIDTH   : integer := 32;
    C_M_AXI_AWUSER_WIDTH : integer := 1;
    C_M_AXI_ARUSER_WIDTH : integer := 1;
    C_M_AXI_WUSER_WIDTH  : integer := 1;
    C_M_AXI_RUSER_WIDTH  : integer := 1;
    C_M_AXI_BUSER_WIDTH  : integer := 1;
    
    C_M_AXI_TARGET        : integer := 0;
    C_OFFSET_WIDTH        : integer := 10; -- 割り当てるRAMのアドレスのビット幅
    C_M_AXI_BURST_LEN    : integer := 256;
    
    WRITE_RANDOM_WAIT    : integer := 1; -- Write Transaction のデータ転送の時にランダムなWaitを発生させる=1, Waitしない=0
    READ_RANDOM_WAIT    : integer := 0 -- Read Transaction のデータ転送の時にランダムなWaitを発生させる=1, Waitしない=0
    );
  port(
    -- System Signals
    ACLK    : in std_logic;
    ARESETN : in std_logic;

    -- Master Interface Write Address Ports
    M_AXI_AWID     : in  std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
    M_AXI_AWADDR   : in  std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    M_AXI_AWLEN    : in  std_logic_vector(8-1 downto 0);
    M_AXI_AWSIZE   : in  std_logic_vector(3-1 downto 0);
    M_AXI_AWBURST  : in  std_logic_vector(2-1 downto 0);
    M_AXI_AWLOCK   : in  std_logic_vector(2-1 downto 0);
    -- M_AXI_AWLOCK   : in  std_logic;
    M_AXI_AWCACHE  : in  std_logic_vector(4-1 downto 0);
    M_AXI_AWPROT   : in  std_logic_vector(3-1 downto 0);
    M_AXI_AWQOS    : in  std_logic_vector(4-1 downto 0);
    M_AXI_AWUSER   : in  std_logic_vector(C_M_AXI_AWUSER_WIDTH-1 downto 0);
    M_AXI_AWVALID  : in  std_logic;
    M_AXI_AWREADY  : out std_logic;

    -- Master Interface Write Data Ports
    M_AXI_WDATA  : in  std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
    M_AXI_WSTRB  : in  std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
    M_AXI_WLAST  : in  std_logic;
    M_AXI_WUSER  : in  std_logic_vector(C_M_AXI_WUSER_WIDTH-1 downto 0);
    M_AXI_WVALID : in  std_logic;
    M_AXI_WREADY : out std_logic;

    -- Master Interface Write Response Ports
    M_AXI_BID    : out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
    M_AXI_BRESP  : out std_logic_vector(2-1 downto 0);
    M_AXI_BUSER  : out std_logic_vector(C_M_AXI_BUSER_WIDTH-1 downto 0);
    M_AXI_BVALID : out std_logic;
    M_AXI_BREADY : in  std_logic;

    -- Master Interface Read Address Ports
    M_AXI_ARID     : in  std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
    M_AXI_ARADDR   : in  std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    M_AXI_ARLEN    : in  std_logic_vector(8-1 downto 0);
    M_AXI_ARSIZE   : in  std_logic_vector(3-1 downto 0);
    M_AXI_ARBURST  : in  std_logic_vector(2-1 downto 0);
    M_AXI_ARLOCK   : in  std_logic_vector(2-1 downto 0);
    M_AXI_ARCACHE  : in  std_logic_vector(4-1 downto 0);
    M_AXI_ARPROT   : in  std_logic_vector(3-1 downto 0);
    M_AXI_ARQOS    : in  std_logic_vector(4-1 downto 0);
    M_AXI_ARUSER   : in  std_logic_vector(C_M_AXI_ARUSER_WIDTH-1 downto 0);
    M_AXI_ARVALID  : in  std_logic;
    M_AXI_ARREADY  : out std_logic;

    -- Master Interface Read Data Ports
    M_AXI_RID    : out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
    M_AXI_RDATA  : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
    M_AXI_RRESP  : out std_logic_vector(2-1 downto 0);
    M_AXI_RLAST  : out std_logic;
    M_AXI_RUSER  : out std_logic_vector(C_M_AXI_RUSER_WIDTH-1 downto 0);
    M_AXI_RVALID : out std_logic;
    M_AXI_RREADY : in  std_logic
    );

end axi_master_bfm;

architecture implementation of axi_master_bfm is

constant    AxBURST_FIXED    : std_logic_vector := "00";
constant    AxBURST_INCR    : std_logic_vector := "01";
constant    AxBURST_WRAP    : std_logic_vector := "10";

constant    RESP_OKAY        : std_logic_vector := "00";
constant    RESP_EXOKAY        : std_logic_vector := "01";
constant    RESP_SLVERR        : std_logic_vector := "10";
constant    RESP_DECERR        : std_logic_vector := "11";

constant    DATA_BUS_BYTES     : natural := C_M_AXI_DATA_WIDTH/8; -- データバスのビット幅
constant    ADD_INC_OFFSET    : natural := natural(log(real(DATA_BUS_BYTES), 2.0));

-- RAMの生成
constant    SLAVE_ADDR_NUMBER    : integer := 2**(C_OFFSET_WIDTH - ADD_INC_OFFSET);
type ram_array_def is array (SLAVE_ADDR_NUMBER-1 downto 0) of bit_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
signal ram_array : ram_array_def := (others => (others => '0'));

-- for write transaction
type write_transaction_state is (idle_wr, awr_wait, awr_accept, wr_burst);
type write_response_state is (idle_wres, bvalid_assert);
type write_wready_state is (idle_wrdy, wready_assert);
signal wrt_cs : write_transaction_state;
signal wrres : write_response_state;
signal wrwr : write_wready_state;
signal addr_inc_step_wr : integer := 1;
signal awready         : std_logic;
signal wr_addr         : unsigned(C_OFFSET_WIDTH-1 downto 0);
signal wr_bid         : std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
signal wr_bresp     : std_logic_vector(1 downto 0);
signal wr_bvalid     : std_logic;
signal m_seq16_wr    : std_logic_vector(15 downto 0);
signal wready        : std_logic;
type wready_state is (idle_wready, assert_wready, deassert_wready);
signal cs_wready : wready_state;
signal cdc_we : std_logic;

-- for read transaction
type read_transaction_state is (idle_rd, arr_wait, arr_accept, rd_burst);
type read_last_state is (idle_rlast, rlast_assert);
signal rdt_cs : read_transaction_state;
signal rdlast : read_last_state;
signal addr_inc_step_rd : integer := 1;
signal arready         : std_logic;
signal rd_addr         : unsigned(C_OFFSET_WIDTH-1 downto 0);
signal rd_axi_count    : unsigned(7 downto 0);
signal rvalid        : std_logic;
signal rlast        : std_logic;
signal m_seq16_rd    : std_logic_vector(15 downto 0);
type rvalid_state is (idle_rvalid, assert_rvalid, deassert_rvalid);
signal cs_rvalid : rvalid_state;

signal reset_1d, reset_2d, reset : std_logic := '1';

begin
    -- ARESETN をACLK で同期化
    process (ACLK) begin
        if ACLK'event and ACLK='1' then 
            reset_1d <= not ARESETN;
            reset_2d <= reset_1d;
        end if;
    end process;
    reset <= reset_2d;
    
    -- AXI4バス Write Transaction State Machine
    process (ACLK) begin
        if ACLK'event and ACLK='1' then 
            if reset='1' then
                wrt_cs <= idle_wr;
                awready <= '0';
            else
                case (wrt_cs) is
                    when idle_wr =>
                        if M_AXI_AWVALID='1' then -- M_AXI_AWVALID が1にアサートされた
                            if rdt_cs=idle_rd then -- Read Transaction が終了している（Writeの方が優先順位が高い）
                                wrt_cs <= awr_accept;
                                awready <= '1';
                            else -- Read Transaction が終了していないのでWait
                                wrt_cs <= awr_wait;
                            end if;
                        end if;
                    when awr_wait => -- Read Transaction の終了待ち
                        if rdt_cs=idle_rd or rdt_cs=arr_wait then -- Read Transaction が終了
                            wrt_cs <= awr_accept;
                            awready <= '1';
                        end if;
                    when awr_accept => -- M_AXI_AWREADY をアサート
                        wrt_cs <= wr_burst;
                        awready <= '0';
                    when wr_burst => -- Writeデータの転送
                        if M_AXI_WLAST='1' and M_AXI_WVALID='1' and wready='1' then -- Write Transaction 終了
                            wrt_cs <= idle_wr;
                        end if;
                end case;
            end if;
        end if;
    end process;
    M_AXI_AWREADY <= awready;
    
    -- m_seq_wr、16ビットのM系列を計算する
    process (ACLK) begin
        if ACLK'event and ACLK='1' then 
            if reset='1' then
                m_seq16_wr <= (0 => '1', others => '0');
            else
                if WRITE_RANDOM_WAIT=1 then -- Write Transaction 時にランダムなWaitを挿入する
                    if wrt_cs=wr_burst and M_AXI_WVALID='1' then
                        m_seq16_wr <= M_SEQ16_BFM_F(m_seq16_wr);
                    end if;
                else -- Wait無し
                    m_seq16_wr <= (others => '0');
                end if;
            end if;
        end if;
    end process;
                
    -- wready の処理、M系列を計算して128以上だったらWaitする。
    process (ACLK) begin
        if ACLK'event and ACLK='1' then 
            if reset='1' then
                cs_wready <= idle_wready;
                wready <= '0';
            else
                case (cs_wready) is
                    when idle_wready =>
                        if wrt_cs=awr_accept then -- 次はwr_burst
                            if m_seq16_wr(7)='0' then -- wready='1'
                                cs_wready <= assert_wready;
                                wready <= '1';
                            else -- m_seq16_wr(7)='1' then -- wready='0'
                                cs_wready <= deassert_wready;
                                wready <= '0';
                            end if;
                        end if;
                    when assert_wready => -- 一度wreadyがアサートされたら、1つのトランザクションが終了するまでwready='1'
                        if wrt_cs=wr_burst and M_AXI_WLAST='1' and M_AXI_WVALID='1' then -- 終了
                            cs_wready <= idle_wready;
                            wready <= '0';
                        elsif wrt_cs=wr_burst and M_AXI_WVALID='1' then -- 1つのトランザクション終了。
                            if m_seq16_wr(7)='1' then
                                cs_wready <= deassert_wready;
                                wready <= '0';
                            end if;
                        end if;
                    when deassert_wready =>
                        if m_seq16_wr(7)='0' then -- wready='1'
                            cs_wready <= assert_wready;
                            wready <= '1';
                        end if;
                end case;
            end if;
        end if;
    end process;
    
    M_AXI_WREADY <= wready;
    cdc_we <= '1' when wrt_cs=wr_burst and wready='1' and M_AXI_WVALID='1' else '0';
    
    -- addr_inc_step_wr の処理
    process (ACLK) begin
        if ACLK'event and ACLK='1' then 
            if reset='1' then
                addr_inc_step_wr <= 1;
            else
                if wrt_cs=awr_accept then
                    case (M_AXI_AWSIZE) is
                        when "000" => -- 8ビット転送
                            addr_inc_step_wr <= 1;
                        when "001" => -- 16ビット転送
                            addr_inc_step_wr <= 2;
                        when "010" => -- 32ビット転送
                            addr_inc_step_wr <= 4;
                        when "011" => -- 64ビット転送
                            addr_inc_step_wr <= 8;
                        when "100" => -- 128ビット転送
                            addr_inc_step_wr <= 16;
                        when "101" => -- 256ビット転送
                            addr_inc_step_wr <= 32;
                        when "110" => -- 512ビット転送
                            addr_inc_step_wr <= 64;
                        when others => --"111" => -- 1024ビット転送
                            addr_inc_step_wr <= 128;
                    end case;
                end if;
            end if;
        end if;
    end process;
    
    -- wr_addr の処理
    process (ACLK) begin
        if ACLK'event and ACLK='1' then 
            if reset='1' then
                wr_addr <= (others => '0');
            else
                if wrt_cs=awr_accept then
                    wr_addr <= unsigned(M_AXI_AWADDR(wr_addr'range));
                elsif wrt_cs=wr_burst and M_AXI_WVALID='1' and wready='1' then -- アドレスを進める
                    wr_addr <= wr_addr + addr_inc_step_wr;
                end if;
            end if;
        end if;
    end process;
    
    -- wr_bid の処理
    process (ACLK) begin
        if ACLK'event and ACLK='1' then 
            if reset='1' then
                wr_bid <= "0";
            else
                if wrt_cs=awr_accept then
                    wr_bid <= M_AXI_AWID;
                end if;
            end if;
        end if;
    end process;
    M_AXI_BID <= wr_bid;
    
    -- wr_bresp の処理
    -- M_AXI_AWBURSTがINCRの時はOKAYを返す。それ以外はSLVERRを返す。
    process (ACLK) begin
        if ACLK'event and ACLK='1' then 
            if reset='1' then
                wr_bresp <= (others => '0');
            else
                if wrt_cs=awr_accept then
                    if M_AXI_AWBURST=AxBURST_INCR then -- バーストタイプがアドレス・インクリメントタイプ
                        wr_bresp <= RESP_OKAY; -- Write Transaction は成功
                    else
                        wr_bresp <= RESP_SLVERR; -- エラー
                    end if;
                end if;
            end if;
        end if;
    end process;
    M_AXI_BRESP <= wr_bresp;
    
    -- wr_bvalid の処理
    -- Write Transaction State Machineには含まない。axi_master のシミュレーションを見ると１クロックで終了しているので、長い間、Master側の都合でWaitしていることは考えない。
    -- 次のWrite転送まで遅延しているようであれば、Write Transaction State Machine に入れてブロックすることも考える必要がある。
    process (ACLK) begin
        if ACLK'event and ACLK='1' then 
            if reset='1' then
                wr_bvalid <= '0';
            else
                if M_AXI_WLAST='1' and M_AXI_WVALID='1' and wready='1' then -- Write Transaction 終了
                    wr_bvalid <= '1';
                elsif wr_bvalid='1' and M_AXI_BREADY='1' then -- wr_bvalid が１でMaster側のReadyも１ならばWrite resonse channel の転送も終了
                    wr_bvalid <= '0';
                end if;
            end if;
        end if;
    end process;
    M_AXI_BVALID <= wr_bvalid;
    M_AXI_BUSER <= (others => '0');
    
    
    -- AXI4バス Read Transaction State Machine
    process (ACLK) begin
        if ACLK'event and ACLK='1' then 
            if reset='1' then
                rdt_cs <= idle_rd;
                arready <= '0';
            else
                case (rdt_cs) is
                    when idle_rd =>
                        if M_AXI_ARVALID='1' then -- Read Transaction 要求
                            if wrt_cs=idle_wr and M_AXI_AWVALID='0' then -- Write Transaction State Machine がidle でWrite要求もない
                                rdt_cs <= arr_accept;
                                arready <= '1';
                            else -- Write Transaction が終了していないのでWait
                                rdt_cs <= arr_wait;
                            end if;
                        end if;
                    when arr_wait => -- Write Transaction の終了待ち
                        if wrt_cs=idle_wr and M_AXI_AWVALID='0' then -- Write Transaction State Machine がidle でWrite要求もない
                            rdt_cs <= arr_accept;
                            arready <= '1';
                        end if;
                    when arr_accept => -- M_AXI_ARREADY をアサート
                        rdt_cs <= rd_burst;
                        arready <= '0';
                    when rd_burst => -- Readデータの転送
                        if rd_axi_count=0 and rvalid='1' and M_AXI_RREADY='1' then -- Read Transaction 終了
                            rdt_cs <= idle_rd;
                        end if;
                end case;
            end if;
        end if;
    end process;
    M_AXI_ARREADY <= arready;

    -- m_seq_rd、16ビットのM系列を計算する
    process (ACLK) begin
        if ACLK'event and ACLK='1' then 
            if reset='1' then
                m_seq16_rd <= (others => '1'); -- Writeとシードを変更する
            else
                if READ_RANDOM_WAIT=1 then -- Read Transaciton のデータ転送でランダムなWaitを挿入する場合
                    if rdt_cs=rd_burst and M_AXI_RREADY='1' then
                        m_seq16_rd <= M_SEQ16_BFM_F(m_seq16_rd);
                    end if;
                else -- Wati無し
                    m_seq16_rd <= (others => '0');
                end if;
            end if;
        end if;
    end process;
                
    -- rvalid の処理、M系列を計算して128以上だったらWaitする。
    process (ACLK) begin
        if ACLK'event and ACLK='1' then 
            if reset='1' then
                cs_rvalid <= idle_rvalid;
                rvalid <= '0';
            else
                case (cs_rvalid) is
                    when idle_rvalid =>
                        if rdt_cs=arr_accept then -- 次はrd_burst
                            if m_seq16_rd(7)='0' then -- rvalid='1'
                                cs_rvalid <= assert_rvalid;
                                rvalid <= '1';
                            else -- m_seq16_rd(7)='1' then -- rvalid='0'
                                cs_rvalid <= deassert_rvalid;
                                rvalid <= '0';
                            end if;
                        end if;
                    when assert_rvalid => -- 一度rvalidがアサートされたら、1つのトランザクションが終了するまでrvalid='1'
                        if rdt_cs=rd_burst and rlast='1' and M_AXI_RREADY='1' then -- 終了
                            cs_rvalid <= idle_rvalid;
                            rvalid <= '0';
                        elsif rdt_cs=rd_burst and M_AXI_RREADY='1' then -- 1つのトランザクション終了。
                            if m_seq16_rd(7)='1' then
                                cs_rvalid <= deassert_rvalid;
                                rvalid <= '0';
                            end if;
                        end if;
                    when deassert_rvalid =>
                        if m_seq16_rd(7)='0' then -- rvalid='1'
                            cs_rvalid <= assert_rvalid;
                            rvalid <= '1';
                        end if;
                end case;
            end if;
        end if;
    end process;
    
    M_AXI_RVALID <= rvalid;
    
    -- addr_inc_step_rd の処理
    process (ACLK) begin
        if ACLK'event and ACLK='1' then 
            if reset='1' then
                addr_inc_step_rd <= 1;
            else
                if rdt_cs=arr_accept then
                    case (M_AXI_ARSIZE) is
                        when "000" => -- 8ビット転送
                            addr_inc_step_rd <= 1;
                        when "001" => -- 16ビット転送
                            addr_inc_step_rd <= 2;
                        when "010" => -- 32ビット転送
                            addr_inc_step_rd <= 4;
                        when "011" => -- 64ビット転送
                            addr_inc_step_rd <= 8;
                        when "100" => -- 128ビット転送
                            addr_inc_step_rd <= 16;
                        when "101" => -- 256ビット転送
                            addr_inc_step_rd <= 32;
                        when "110" => -- 512ビット転送
                            addr_inc_step_rd <= 64;
                        when others => -- "111" => -- 1024ビット転送
                            addr_inc_step_rd <= 128;
                    end case;
                end if;
            end if;
        end if;
    end process;
    
    -- rd_addr の処理
    process (ACLK) begin
        if ACLK'event and ACLK='1' then 
            if reset='1' then
                rd_addr <= (others => '0');
            else
                if rdt_cs=arr_accept then
                    rd_addr <= unsigned(M_AXI_ARADDR(rd_addr'range));
                elsif rdt_cs=rd_burst and M_AXI_RREADY='1' and rvalid='1' then
                    rd_addr <= rd_addr + addr_inc_step_rd;
                end if;
            end if;
        end if;
    end process;
    
    -- rd_axi_count の処理（AXIバス側のデータカウント）
    process (ACLK) begin
        if ACLK'event and ACLK='1' then 
            if reset='1' then
                rd_axi_count <= (others => '0');
            else
                if rdt_cs=arr_accept then -- rd_axi_count のロード
                    rd_axi_count <= resize(unsigned(M_AXI_ARLEN),rd_axi_count'length) ;
                elsif rdt_cs=rd_burst and rvalid='1' and M_AXI_RREADY='1' then -- Read Transaction が1つ終了
                    rd_axi_count <= rd_axi_count - 1;
                end if;
            end if;
        end if;
    end process;
    
    -- rdlast State Machine
    process (ACLK) begin
        if ACLK'event and ACLK='1' then 
            if reset='1' then
                rdlast <= idle_rlast;
                rlast <= '0';
            else
                case (rdlast) is
                    when idle_rlast =>
                        if rd_axi_count=1 and rvalid='1' and M_AXI_RREADY='1' then -- バーストする場合
                            rdlast <= rlast_assert;
                            rlast <= '1';
                        elsif rdt_cs=arr_accept and unsigned(M_AXI_ARLEN)=0 then -- 転送数が1の場合
                            rdlast <= rlast_assert;
                            rlast <= '1';
                        end if;
                    when rlast_assert => 
                        if rvalid='1' and M_AXI_RREADY='1' then -- Read Transaction 終了（rd_axi_count=0は決定）
                            rdlast <= idle_rlast;
                            rlast <= '0';
                        end if;
                end case;
            end if;
        end if;
    end process;
    M_AXI_RLAST <= rlast;
    
    -- M_AXI_RID, M_AXI_RUSER の処理
    process (ACLK) begin
        if ACLK'event and ACLK='1' then 
            if reset='1' then
                M_AXI_RID <= (others => '0');
            else
                if rdt_cs=arr_accept then
                    M_AXI_RID <= M_AXI_ARID;
                end if;
            end if;
        end if;
    end process;
    M_AXI_RUSER <= (others => '0');
    
    -- M_AXI_RRESP は、M_AXI_ARBURST がINCR の場合はOKAYを返す。それ以外はSLVERRを返す。
    process (ACLK) begin
        if ACLK'event and ACLK='1' then 
            if reset='1' then
                M_AXI_RRESP <= (others => '0');
            else
                if rdt_cs=arr_accept then
                    if M_AXI_ARBURST=AxBURST_INCR then
                        M_AXI_RRESP <= RESP_OKAY;
                    else
                        M_AXI_RRESP <= RESP_SLVERR;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    -- RAM
    process (ACLK) begin
        if ACLK'event and ACLK='1' then 
            if cdc_we='1' then
                for i in 0 to C_M_AXI_DATA_WIDTH/8-1 loop
                    if M_AXI_WSTRB(i)='1' then -- Byte Enable
                        ram_array(TO_INTEGER(wr_addr(C_OFFSET_WIDTH-1 downto ADD_INC_OFFSET)))(i*8+7 downto i*8) <= To_bitvector(M_AXI_WDATA(i*8+7 downto i*8));
                    end if;
                end loop;
            end if;
        end if;
    end process;
    M_AXI_RDATA <= To_stdlogicvector(ram_array(TO_INTEGER(rd_addr(C_OFFSET_WIDTH-1 downto ADD_INC_OFFSET))));

end implementation;
