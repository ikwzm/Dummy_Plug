#!/usr/bin/env ruby
# -*- coding: euc-jp -*-
#---------------------------------------------------------------------------------
#
#       Version     :   0.0.1
#       Created     :   2013/6/11
#       File name   :   axi4.rb
#       Author      :   Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
#       Description :   AXI4用シナリオ生成モジュール
#
#---------------------------------------------------------------------------------
#
#       Copyright (C) 2012,2013 Ichiro Kawazome
#       All rights reserved.
# 
#       Redistribution and use in source and binary forms, with or without
#       modification, are permitted provided that the following conditions
#       are met:
# 
#         1. Redistributions of source code must retain the above copyright
#            notice, this list of conditions and the following disclaimer.
# 
#         2. Redistributions in binary form must reproduce the above copyright
#            notice, this list of conditions and the following disclaimer in
#            the documentation and/or other materials provided with the
#            distribution.
# 
#       THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#       "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#       LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#       A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
#       OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#       SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#       LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#       DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#       THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#       OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
#---------------------------------------------------------------------------------
require_relative "./number-generater"
module Dummy_Plug
  module ScenarioWriter
    module AXI4
      #---------------------------------------------------------------------------
      # AXI4::Transaction
      #---------------------------------------------------------------------------
      class Transaction
        attr_reader   :name, :write
        attr_reader   :max_transaction_size
        attr_reader   :address, :burst_length, :burst_type, :data_size
        attr_reader   :id, :lock, :cache, :qos, :region, :addr_user
        attr_reader   :data, :data_user, :byte_data, :data_pos
        attr_reader   :response, :resp_user
        attr_accessor :addr_wait, :data_wait, :resp_wait
        #-------------------------------------------------------------------------
        # initialize
        #-------------------------------------------------------------------------
        def initialize(args)
          @write        = nil
          @address      = nil
          @data         = nil
          @burst_length = nil
          @burst_type   = nil
          @data_size    = nil
          @data_pos     = 0
          @data_offset  = 0
          setup(args)
        end
        #-------------------------------------------------------------------------
        # 指定された辞書に基づいて内部変数を設定するメソッド.
        #-------------------------------------------------------------------------
        def setup(args)
          @name                 = args[:Name              ] if args.key?(:Name              )
          @write                = ((args.key?(:Write) and args[:Write] == 1) or
                                   (args.key?(:Read ) and args[:Read ] == 0))
          @max_transaction_size = args[:MaxTransactionSize] if args.key?(:MaxTransactionSize)
          @id                   = args[:ID                ] if args.key?(:ID                )
          @lock                 = args[:Lock              ] if args.key?(:Lock              )
          @cache                = args[:Cache             ] if args.key?(:Cache             )
          @qos                  = args[:QOS               ] if args.key?(:QOS               )
          @region               = args[:Region            ] if args.key?(:Region            )
          @address              = args[:Address           ] if args.key?(:Address           )
          @data_size            = args[:DataSize          ] if args.key?(:DataSize          )
          @burst_length         = args[:BurstLength       ] if args.key?(:BurstLength       )
          @burst_type           = args[:BurstType         ] if args.key?(:BurstType         )
          @addr_user            = args[:AddressUser       ] if args.key?(:AddressUser       )
          @data                 = args[:Data              ] if args.key?(:Data              )
          @data_user            = args[:DataUser          ] if args.key?(:DataUser          )
          @response             = args[:Response          ] if args.key?(:Response          )
          @resp_user            = args[:ResponseUser      ] if args.key?(:ResponseUser      )
          @addr_wait            = args[:AddrWait          ] if args.key?(:AddrWait          )
          @data_wait            = args[:DataWait          ] if args.key?(:DataWait          )
          @resp_wait            = args[:ResponseWait      ] if args.key?(:ResponseWait      )

          if @data then
            @byte_data    = generate_byte_data_array(@data)
            @burst_length = calc_burst_length(@byte_data) if (@burst_length == nil)
          end
        end
        #-------------------------------------------------------------------------
        # 自分自身のコピーを生成して返すメソッド.
        #-------------------------------------------------------------------------
        def clone(args = Hash.new())
          transaction = self.dup
          transaction.setup(args)
          return transaction
        end
        #-------------------------------------------------------------------------
        # バイトデータ配列からバースト長を計算するメソッド.
        #-------------------------------------------------------------------------
        def calc_burst_length(byte_data_array)
          data_width = 2**@data_size
          address_lo = @address % data_width
          return (((byte_data_array.size+address_lo+(data_width-1))/data_width)-1).truncate
        end
        #-------------------------------------------------------------------------
        # ワードデータを含む配列をバイトデータの配列に変換するメソッド.
        #-------------------------------------------------------------------------
        def generate_byte_data_array(data_array)
          byte_data = Array.new()
          data_array.each {|word_data|
            if    word_data.class.name == "Fixnum" then
              byte_data.push((word_data & 0xFF))
            elsif word_data.class.name == "String" 
              if word_data =~ /^0x([0-9a-fA-F]+)$/ then
                word_str  = $1
                byte_size = (word_str.length+1)/2
                byte_size.downto(1) {|i|
                  byte_data.push(word_str.slice(2*(i-1),2).hex)
                }
              end
            else # T.B.D
            end
          }
          return byte_data
        end
        #-------------------------------------------------------------------------
        # アドレスチャネル信号の設定値を Dummy_Plug 形式で出力するメソッド.
        #-------------------------------------------------------------------------
        def generate_address_channel_signals(tag)
          tab = " " * tag.length
          str  = tag + "ADDR  : " + sprintf("0x%08X", @address      ) + "\n" +
                 tab + "SIZE  : " + sprintf("%d"    , 2**@data_size ) + "\n" +
                 tab + "LEN   : " + sprintf("%d"    , @burst_length ) + "\n"
          str += tab + "ID    : " + sprintf("%d"    , @id           ) + "\n" if (@id         != nil)
          str += tab + "BURST : " + sprintf("%s"    , @burst_type   ) + "\n" if (@burst_type != nil)
          str += tab + "LOCK  : " + sprintf("%d"    , @lock         ) + "\n" if (@lock       != nil)
          str += tab + "CACHE : " + sprintf("%d"    , @cache        ) + "\n" if (@cache      != nil)
          str += tab + "QOS   : " + sprintf("%d"    , @qos          ) + "\n" if (@qos        != nil)
          str += tab + "REGION: " + sprintf("%d"    , @region       ) + "\n" if (@region     != nil)
          str += tab + "USER  : " + sprintf("%d"    , @addr_user    ) + "\n" if (@addr_user  != nil)
          return str
        end
        #-------------------------------------------------------------------------
        # データチャネル信号の設定値を Dummy_Plug 形式で出力するメソッド.
        #-------------------------------------------------------------------------
        def generate_data_channel_signals(tag, width, write, nil_data)
          tab = " " * tag.length
          if @data_pos == 0 then
            @data_offset = @address     % width
          else
            @data_offset = @data_offset % width
          end
          last_word = false
          word_size = (2**@data_size) - (@data_offset % (2**@data_size))
          if @data_pos + word_size >= @byte_data.size then
              last_word = true
              word_size = @byte_data.size - @data_pos
          end
          word_data = Array.new(width, nil)
          word_data[@data_offset...@data_offset+word_size] = @byte_data[@data_pos...@data_pos+word_size]
          @data_pos    += word_size
          @data_offset += word_size
          str  = tag + sprintf("DATA  : %d'h", 8*width) + word_data.reverse.collect{ |d| 
                   if d == nil then 
                     nil_data
                   else
                     sprintf("%02X",d)
                   end
          }.join('') + "\n"
          if write then
            str += tab + sprintf("STRB  : %d'b", width) + word_data.reverse.collect{ |d| 
                     if d == nil then 
                       "0"
                     else
                       "1"
                     end
            }.join('') + "\n"
          else
            str += tab + "RESP  : " + @response + "\n"
          end
          str += tab + "LAST  : " + ((last_word) ? "1" : "0") + "\n"
          return str
        end
      end
      #---------------------------------------------------------------------------
      # AXI4::SignalWidth
      #---------------------------------------------------------------------------
      class SignalWidth
        attr_accessor :id, :addr, :data, :a_len , :a_cache,
                      :a_user, :r_user , :w_user, :b_user
        def initialize(params = Hash.new())
          @id      = params.key?(:ID_WIDTH     ) ? params[:ID_WIDTH     ] :  0
          @addr    = params.key?(:ADDR_WIDTH   ) ? params[:ADDR_WIDTH   ] : 32
          @data    = params.key?(:DATA_WIDTH   ) ? params[:DATA_WIDTH   ] : 32
          @a_len   = params.key?(:A_LEN_WIDTH  ) ? params[:A_LEN_WIDTH  ] :  8
          @a_cache = params.key?(:A_CACHE_WIDTH) ? params[:A_CACHE_WIDTH] :  1
          @a_user  = params.key?(:A_USER_WIDTH ) ? params[:A_USER_WIDTH ] :  0
          @r_user  = params.key?(:R_USER_WIDTH ) ? params[:R_USER_WIDTH ] :  0
          @w_user  = params.key?(:W_USER_WIDTH ) ? params[:W_USER_WIDTH ] :  0
          @b_user  = params.key?(:B_USER_WIDTH ) ? params[:B_USER_WIDTH ] :  0
        end
      end
      #---------------------------------------------------------------------------
      # AXI4::Base
      #---------------------------------------------------------------------------
      class Base
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        attr_reader :name, :width, :read_transaction, :write_transaction
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        def initialize(name, params = Hash.new())
          @name                 = name
          @width                = SignalWidth.new(params)
          @default_transaction  = Transaction.new({
            :MaxTransactionSize => params.key?(:MAX_TRAN_SIZE) ? params[:MAX_TRAN_SIZE] : 4096,
            :ID                 => params.key?(:ID           ) ? params[:ID           ] : 0   ,
            :DataSize           => calc_data_size(@width.data)                                ,
            :BurstType          => "INCR"                                                     ,
            :Response           => "OKAY"                                                     ,
            :AddrWait           => Dummy_Plug::ScenarioWriter::ConstantNumberGenerater.new(0) ,
            :DataWait           => Dummy_Plug::ScenarioWriter::ConstantNumberGenerater.new(0) ,
            :ResponseWait       => Dummy_Plug::ScenarioWriter::ConstantNumberGenerater.new(0) ,
          })
          @read_transaction     = @default_transaction.clone({:Read  => 1})
          @write_transaction    = @default_transaction.clone({:Write => 1})
          @null_transaction     = @default_transaction.clone({:Address => 0, :BurstLength => 0})
        end
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        def calc_data_size(data_width)
          case data_width
          when    8 then 0
          when   16 then 1
          when   32 then 2
          when   64 then 3
          when  128 then 4
          when  256 then 5
          when  512 then 6
          when 1024 then 7
          else           nil
          end
        end
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        def read(args)
          return transaction_read(@read_transaction.clone(args))
        end
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        def write(args)
          return transaction_write(@write_transaction.clone(args))
        end
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        def execute(transaction)
          if transaction.write then
            return transaction_write(transaction)
          else
            return transaction_read (transaction)
          end
        end
      end
      #---------------------------------------------------------------------------
      # AXI4::Master
      #---------------------------------------------------------------------------
      class Master < Base
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        def initialize(name, params = Hash.new())
          super(name, params)
        end
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        def transaction_address(tag, channel_name, transaction)
          str    = tag + channel_name + ":\n"
          tab    = " " * tag.length
          indent = tab + "- "
          wait = transaction.addr_wait.next
          if wait > 0 then
            str += indent + "VALID : 0\n"
            str += @null_transaction.generate_address_channel_signals(indent)
            str += indent + "WAIT  : " + wait.to_s + "\n"
          end
          str   += indent + "VALID : 1\n"
          str   += transaction.generate_address_channel_signals(indent)
          str   += indent + "WAIT  : {VALID : 1, READY : 1}\n"
          str   += indent + "VALID : 0\n"
          str   += @null_transaction.generate_address_channel_signals(indent)
          return str
        end
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        def transaction_read(transaction)
          str    = "- - " + @name.to_s + "\n"
          str   += transaction_address(
                   "  - ", "AR", transaction
                   )
          str   += "  - R :\n"
          str   += "    - READY : 0\n"
          data_wait = transaction.data_wait.next
          if data_wait < 0 then
            str += "    - WAIT  : {ARVALID : 1, ARREADY : 1}\n"
          end  
          while (transaction.data_pos < transaction.byte_data.size) do
            data_wait = transaction.data_wait.next
            str += "    - WAIT  : " + data_wait.to_s + "\n"
            str += "    - READY : 1\n"
            str += "    - WAIT  : {VALID : 1, READY : 1}\n"
            str += "    - CHECK :\n"
            str += transaction.generate_data_channel_signals("        ", @width.data/8, false, "--")
            str += "    - READY : 0\n"
          end
          return str
        end
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        def transaction_write(transaction)
          str    = "- - " + @name.to_s + "\n"
          str   += transaction_address(
                   "  - ", "AW", transaction
                   )
          str   += "  - W :\n"
          str   += "    - VALID : 0\n"
          data_wait = transaction.data_wait.next
          if data_wait < 0 then
            str += "    - WAIT  : {AWVALID : 1, AWREADY : 1}\n"
          end  
          while (transaction.data_pos < transaction.byte_data.size) do
            data_wait = transaction.data_wait.next
            str += "    - WAIT  : " + data_wait.to_s + "\n"
            str += "    - VALID : 1\n"
            str += transaction.generate_data_channel_signals("        ", @width.data/8, true, "FF")
            str += "    - WAIT  : {VALID : 1, READY : 1}\n"
            str += "    - READY : 0\n"
          end
          str   += "  - B :\n"
          str   += "    - READY : 0\n"
          resp_wait = transaction.resp_wait.next
          if resp_wait < 0 then
            str += "    - WAIT  : {AWVALID : 1, AWREADY : 1}\n"
          end
          resp_wait = transaction.resp_wait.next
          str   += "    - WAIT  : " + resp_wait.to_s + "\n"
          str   += "    - READY : 1\n"
          str   += "    - WAIT  : {VALID : 1, READY : 1}\n"
          str   += "    - CHECK : {RESP  : " + transaction.response + "}\n"
          str   += "    - READY : 0\n"
          return str
        end
      end
      #---------------------------------------------------------------------------
      # AXI4::Slave
      #---------------------------------------------------------------------------
      class Slave  < Base
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        def initialize(name, params = Hash.new())
          super(name, params)
        end
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        def transaction_address(tag, channel_name, transaction)
          str    = tag + channel_name + ":\n"
          tab    = " " * tag.length
          indent = tab + "- "
          wait = transaction.addr_wait.next
          if wait > 0 then
            str += indent + "READY : 0\n"
            str += indent + "WAIT  : " + wait.to_s + "\n"
          end
          str   += indent + "READY : 1\n"
          str   += indent + "WAIT  : {VALID : 1, READY : 1}\n"
          str   += indent + "CHECK : \n"
          str   += transaction.generate_address_channel_signals(tab+"    ")
          str   += indent + "READY : 0\n"
          return str
        end
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        def transaction_read(transaction)
          str    = "- - " + @name.to_s + "\n"
          str   += transaction_address(
                   "  - ", "AR", transaction
                   )

          str   += "  - R :\n"
          str   += "    - VALID : 0\n"
          data_wait = transaction.data_wait.next
          if data_wait < 0 then
            str += "    - WAIT  : {ARVALID : 1, ARREADY : 1}\n"
          end  
          while (transaction.data_pos < transaction.byte_data.size) do
            data_wait = transaction.data_wait.next
            str += "    - WAIT  : " + data_wait.to_s + "\n"
            str += "    - VALID : 1\n"
            str += transaction.generate_data_channel_signals("      ", @width.data/8, false, "FF")
            str += "    - WAIT  : {VALID : 1, READY : 1}\n"
            str += "    - READY : 0\n"
          end
          return str
        end
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        def transaction_write(transaction)
          str    = "- - " + @name.to_s + "\n"
          str   += transaction_address(
                   "  - ", "AW", transaction
                   )
          str   += "  - W :\n"
          str   += "    - READY : 0\n"
          data_wait = transaction.data_wait.next
          if data_wait < 0 then
            str += "    - WAIT  : {AWVALID : 1, AWREADY : 1}\n"
          end  
          while (transaction.data_pos < transaction.byte_data.size) do
            data_wait = transaction.data_wait.next
            str += "    - WAIT  : " + data_wait.to_s + "\n"
            str += "    - READY : 1\n"
            str += "    - WAIT  : {VALID : 1, READY : 1}\n"
            str += "    - CHECK :\n"
            str += transaction.generate_data_channel_signals("        ", @width.data/8, true, "--")
            str += "    - READY : 0\n"
          end
          str   += "  - B :\n"
          str   += "    - VALID : 0\n"
          resp_wait = transaction.resp_wait.next
          if resp_wait < 0 then
            str += "    - WAIT  : {AWVALID : 1, AWREADY : 1}\n"
          end  
          resp_wait = transaction.resp_wait.next
          str   += "    - WAIT  : " + resp_wait.to_s + "\n"
          str   += "    - VALID : 1\n"
          str   += "      RESP  : " + transaction.response + "\n"
          str   += "    - WAIT  : {VALID : 1, READY : 1}\n"
          str   += "    - VALID : 0\n"
          return str
        end
      end
    end
  end
end
