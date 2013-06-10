#!/usr/bin/env ruby
# -*- coding: euc-jp -*-
#---------------------------------------------------------------------------------
#
#       Version     :   0.0.1
#       Created     :   2013/6/11
#       File name   :   number-generater.rb
#       Author      :   Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
#       Description :   番号(整数)を生成するクラスを定義しているモジュール.
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
module Dummy_Plug
  module ScenarioWriter
    module NumberGenerater
      class Base
      end
      #---------------------------------------------------------------------------
      # 常に同じ値を生成するクラス
      #---------------------------------------------------------------------------
      class Constant < Base
        attr_reader :num, :done
        def initialize(num)
          @num  = num
          @done = false
        end
        def next
          return @num
        end
        def reset
        end
      end
      #---------------------------------------------------------------------------
      # 一度だけ値を生成するクラス
      #---------------------------------------------------------------------------
      class Once < Base
        attr_reader :num, :done
        def initialize(num)
          @num  = num
          @done = false
        end
        def next
          if @done == false
            @done = true
            return @num
          else
            return nil
          end
        end
        def reset
          @done = false
        end
      end
      #---------------------------------------------------------------------------
      # 指定された配列から順番に値を生成するクラス
      #---------------------------------------------------------------------------
      class Queue < Base
        attr_reader :nums, :index, :done
        def initialize(nums)
          @nums  = Array.new(nums)
          @index = 0
          @done  = (@index >= @nums.size)
        end
        def next
          if @done == false
            num = @nums[@index]
            @index = @index + 1
          else
            num = nil
          end
          @done  = (@index >= @nums.size)
          return num
        end
        def reset
          @index = 0
          @done  = (@index >= @nums.size)
        end
      end
      #---------------------------------------------------------------------------
      # 指定された配列から順番に値を生成するクラス
      #---------------------------------------------------------------------------
      class Ring < Base
        attr_reader :nums, :index, :done
        def initialize(nums)
          @nums  = Array.new(nums)
          @index = 0
          @done  = false
        end
        def next
          if @index < @nums.size
            num = @nums[@index]
            @index = @index + 1
          else
            num = @nums[0]
            @index = 1
          end
          return num
        end
        def reset
          @index = 0
        end
      end
      #---------------------------------------------------------------------------
      # 指定された配列からランダムに値を生成するクラス
      #---------------------------------------------------------------------------
      class Random < Base
        attr_reader :nums, :done
        def initialize(nums)
          @nums  = Array.new(nums)
          @done  = false
        end
        def next
          return @nums[rand(@nums.size)]
        end
        def reset
        end
      end
      #---------------------------------------------------------------------------
      # 値を生成するクラスを複合したクラス
      #---------------------------------------------------------------------------
      class Composite < Base
        attr_reader :args, :index, :done
        def initialize(args)
          index = 1
          @args = Array.new()
          args.each {|arg|
            p arg.class
            case arg.class.to_s
            when "Dummy_Plug::ScenarioWriter::NumberGenerater::Constant"  then
              @args.push(arg)
            when "Dummy_Plug::ScenarioWriter::NumberGenerater::Once"      then
              @args.push(arg)
            when "Dummy_Plug::ScenarioWriter::NumberGenerater::Queue"     then
              @args.push(arg)
            when "Dummy_Plug::ScenarioWriter::NumberGenerater::Ring"      then
              @args.push(arg)
            when "Dummy_Plug::ScenarioWriter::NumberGenerater::Random"    then
              @args.push(arg)
            when "Dummy_Plug::ScenarioWriter::NumberGenerater::Composite" then
              @args.push(arg)
            when "Array" then
              if index < args.size
                @args.push(Dummy_Plug::ScenarioWriter::NumberGenerater::Queue.new(arg))
              else
                @args.push(Dummy_Plug::ScenarioWriter::NumberGenerater::Ring.new(arg))
              end
            when "Fixnum" then
              if index < args.size
                @args.push(Dummy_Plug::ScenarioWriter::NumberGenerater::Once.new(arg))
              else
                @args.push(Dummy_Plug::ScenarioWriter::NumberGenerater::Constant.new(arg))
              end
            end
            index = index + 1
          }
          @index = 0
          @done  = (@index >= @args.size)
        end
        def next
          if @done == false
            num = @args[@index].next
            if @args[@index].done
              @index = @index + 1
            end
            @done = (@index >= @args.size)
          else
            num = nil
          end
          return num
        end
        def reset
          @args.each {|nums| nums.reset}
          @index = 0
          @done  = (@index >= @args.size)
        end
      end
    end
  end
end
