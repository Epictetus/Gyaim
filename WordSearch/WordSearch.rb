# -*- coding: utf-8 -*-
# WordSearch.rb
# Gyaim
#
# Created by Toshiyuki Masui on 11/03/15.
# Copyright 2011 Pitecan Systems. All rights reserved.

class WordSearch
  attr :searchMode, true

  def charcode(s)
    sprintf("%02x",s.each_byte.to_a[0])
  end

  def dictdir
    "/tmp"
  end

  def dictfile(code)
    "#{dictdir}/dict#{code}"
  end

  def dict(s)
    @dict[charcode(s)]
  end

  def setdict(s,val)
    @dict[charcode(s)] = val
  end

  # fugopath = NSBundle.mainBundle.pathForResource("fugodic", ofType:"txt")
  # fugopath = "../Resources/fugodic.txt"
  def initialize(fugodic)
    Log.log "Initialize(#{fugodic})"
    @candidates = []
    @dict = {}
    d = dictfile(charcode("kanji"))
#    if !File.exist?(d) || File.mtime(d) < File.mtime(fugodic) then
    if !File.exist?(d) then
      File.open(fugodic){ |f|
        f.each { |line|
          next if line =~ /^#/
          line.chomp!
          (yomi,word) = line.split(/\s+/)
          if yomi && word then
            if dict(yomi).nil? then
              setdict(yomi,[])
            end
            dict(yomi) << [yomi,word]
          end
        }
      }
      @dict.each { |code,dic|
        File.open(dictfile(code),"w"){ |f|
          Marshal.dump(dic,f)
        }
      }
    end
  end

  def search(q,limit=10)
    Log.log "search(#{q})"
    pat = /^#{q}/
    candfound = {}
    @candidates = []
    return if q == ''
    code = charcode(q)
    if !@dict[code] then
      File.open(dictfile(code)){ |f|
        @dict[code] = Marshal.load(f)
      }
    end
    @dict[code].each { |entry|
      yomi = entry[0]
      word = entry[1]
      if yomi =~ pat then
        if !candfound[word] then
          @candidates << word
          candfound[word] = true
          break if @candidates.length > limit
        end
      end
    }
  end
  
  def candidates
    @candidates
  end
end

if __FILE__ == $0 then
  ws = WordSearch.new("/Users/masui/Gyaim/Resources/fugodic.txt")
  ws.search("masui")
  puts ws.candidates
  ws.search("kanj")
  puts ws.candidates
end

