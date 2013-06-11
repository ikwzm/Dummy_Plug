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

      class Base
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

        attr_reader :name, :width, :default_transaction

        def initialize(name, params = Hash.new())
          @name                = name
          @width               = SignalWidth.new(params)
          @default_transaction = Transaction.new({
            :Width              => @width                                                     ,
            :MaxTransactionSize => params.key?(:MAX_TRAN_SIZE) ? params[:MAX_TRAN_SIZE] : 4096,
            :ID                 => params.key?(:ID           ) ? params[:ID           ] : 0   ,
            :DataSize           => calc_data_size(@width.data)                                ,
            :BurstType          => "INCR"                                                     ,
            :Response           => "OKAY"                                                     ,
            :AddrWait           => Dummy_Plug::ScenarioWriter::ConstantNumberGenerater.new(0) ,
            :DataWait           => Dummy_Plug::ScenarioWriter::ConstantNumberGenerater.new(0) ,
            :ResponseWait       => Dummy_Plug::ScenarioWriter::ConstantNumberGenerater.new(0) ,
          })
        end

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

        class Transaction
          def initialize(args)
            @address      = nil
            @data         = nil
            @burst_length = nil
            @burst_type   = nil
            setup(args)
          end

          def setup(args)
            @width                = args[:Width             ] if args.key?(:Width             )
            @max_transaction_size = args[:MaxTransactionSize] if args.key?(:MaxTransactionSize)
            @id                   = args[:ID                ] if args.key?(:ID                )
            @address              = args[:Address           ] if args.key?(:Address           )
            @data_size            = args[:DataSize          ] if args.key?(:DataSize          )
            @addr_wait            = args[:AddrWait          ] if args.key?(:AddrWait          )
            @data                 = args[:Data              ] if args.key?(:Data              )
            @response             = args[:Response          ] if args.key?(:Response          )
            @data_wait            = args[:DataWait          ] if args.key?(:DataWait          )
            @resp_wait            = args[:ResponseWait      ] if args.key?(:ResponseWait      )
            @burst_length         = args[:BurstLength       ] if args.key?(:BurstLength       )
            @burst_type           = args[:BurstType         ] if args.key?(:BurstType         )
            if @data then
              @byte_data    = generate_byte_data_array(@data)
              @burst_length = calc_burst_length(@byte_data) if (@burst_length == nil)
            end
          end
 
          def copy(args = Hash.new())
            transaction = self.dup
            transaction.setup(args)
            return transaction
          end

          def calc_burst_length(byte_data_array)
            data_width = 2**@data_size
            address_lo = @address % data_width
            return (((byte_data_array.size+address_lo+(data_width-1))/data_width)-1).truncate
          end

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
              else

              end
            }
            return byte_data
          end

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
            str += tab + "USER  : " + sprintf("%d"    , @user         ) + "\n" if (@user       != nil)
            str += tab + "DATA  : ["+ (@byte_data.collect{ |d| sprintf("0x%02X",d)}).join(',') + "]\n"
            return str
          end

        end

      end

      class Master < Base
        def initialize(name, params = Hash.new())
          super(name, params)
        end
        def read(args)
          transaction = @default_transaction.copy(args)
          transaction.generate_address_channel_signals("  - ")
        end
      end

      class Slave  < Base
        def initialize(name, params = Hash.new())
          super(name, params)
        end
      end
    end
  end
end
