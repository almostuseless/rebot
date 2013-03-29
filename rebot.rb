#!/usr/bin/env ruby

require 'rubygems'
require 'cinch'
require 'mechanize'

bot = Cinch::Bot.new do
    configure do |c|
        c.nick = "rebot"
        c.username = "rebot"
        c.server = "irc.freenode.net"
        c.channels = ["###failbot"]
    end

    on :message, /^\.regex (.*?)\s(s)?\/(.*?)\/([a-z]*)$/ do |m,string,sub,regex,mods|

        #Declare result string
        line = "[res: \x020\x02, "

        ## we'll rescue errors if shit goes nuts
        begin
            ## match index incrementor 
            i       = 0

            ## s///?
            if sub.nil?

                ## is string a url?
                if string =~ /^https?:\/\/\S+$/
                    a = Mechanize.new()
                    string = a.get(string).content
                end

                ## if global, do scan() instead of match()
                if mods.match(/g/)

                    r = Regexp.new( regex, mods.match(/i/) ? true : false )

                    start = Time.now
                    res = string.scan( r )
                    time = (Time.now - start) * 1000
                    time = time.to_s[0..5] + "ms"
                    time.gsub!(/(\.0+)(\d+)/,"\\1\x02\\2\x02")
                    line += "#{time}] "

                    res.each do |a|

                        offset  = string.index( a[0] )
                        line    += "[\x02#{i}\x02:#{offset + 1}-#{offset + a[0].length}: \"#{a[0]}\"] "
                        i       += 1
                    end
                else

                    
                    ## Match and format MatchData to Array, iterate through each backreference
                    r = Regexp.new( regex, mods.match(/i/) ? true : false )

                    # Time it
                    start = Time.now
                    res = string.match( r )
                    time = (Time.now - start) * 1000
                    time = time.to_s[0..5] + "ms"
                    time.gsub!(/(\.0+)(\d+)/,"\\1\x02\\2\x02")
                    line += "#{time}] "

                    res.to_a.each do |a|

                        ## find offset of backreference and append it to the result string
                        offset  = string.index( a )

                        line    += "[\x02#{i}\x02:#{offset + 1}-#{offset + a.length }: \"#{a}\"] "
                        i       += 1
                    end
                end
            else   
                ## s/// search and replace
                regex.match(/(?<search>.*?)(?<!\\)\/(?<replace>.+)/) do |m|
                needle = Regexp.try_convert( /#{m[:search]}/ )

                start = Time.now
                res  = string.gsub!( Regexp.new(needle), m[:replace] )
                time = (Time.now - start) * 1000
                time = time.to_s[0..5] + "ms"
                time.gsub!(/(\.0+)(\d+)/,"\\1\x02\\2\x02")
                line += "#{time}] "

                line += res
                end
            end

        rescue => e
           line = "[res: -2] #{e}"
        end

        line = "[res: -1]" if line == "[res: \x020\x02] "
    
        m.reply line[0..512]
    end
end

bot.start
