#!/usr/bin/env ruby

require 'rubygems'
require 'cinch'
require 'mechanize'

bot = Cinch::Bot.new do
    configure do |c|
        c.nick = "rebot"
        c.username = "rebot"
        c.server = "irc.tddirc.net"
        c.channels = ["#failbot"]
    end

#    on :message, /^\.regex (.*?)\s*(s)?\/(.+)\/(\w*)$/ do |m,string,sub,regex,mods|
    on :message, /^\.regex (.*?)\s(s)?\/(.*?)\/([a-z]*)$/ do |m,string,sub,regex,mods|

        #Declare result string
        line = "[res: 0] "

        ## we'll rescue errors if shit goes nuts
        begin
            ## match index incrementor 
            i       = 0

            ## s///?
            if sub.nil?

                ## Throw an error if the expression doesnt compile
                regex   = Regexp.try_convert( /#{regex}/ )

                ## is string a url?

                puts "\n\n###########################"
                puts "string: #{string}"
                puts "############################\n\n"
                
                if string =~ /^https?:\/\/\S+$/
                    a = Mechanize.new()
                    string = a.get(string).content
                end

                
                puts "\n\n###########################"
                puts "string: #{string}"
                puts "############################\n\n"


                ## if global, do scan() instead of match()
                if mods.match(/g/)

                    string.scan( /#{Regexp.new(regex)}/ ).each do |a|

                        offset  = string.index( a[0] )
                        line    += "[\x02#{i}\x02:#{offset + 1}-#{offset + a[0].length}: \"#{a[0]}\"] "
                        i       += 1
                    end
                else

                    ## Match and format MatchData to Array, iterate through each backreference
                    string.match( /#{Regexp.new(regex)}/ ).to_a.each do |a|

                        ## find offset of backreference and append it to the result string
                        offset  = string.index( a )

                        line    += "[#{i}:\x02#{offset + 1}\x02-\x02#{offset + a.length }\x02: \"#{a}\"] "

                        i       += 1
                    end
                end
            else   
                ## s/// search and replace
                regex.match(/(?<search>.*?)(?<!\\)\/(?<replace>.+)/) do |m|
                needle = Regexp.try_convert( /#{m[:search]}/ )

                line += string.gsub!( Regexp.new(needle), m[:replace] )
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
