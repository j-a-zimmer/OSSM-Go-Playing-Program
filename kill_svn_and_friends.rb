#!/usr/bin/ruby

# This file is expected not only to be in the commons repository but also
# in all home directories of users on remote machines involved in
# installations.

require 'fileutils'

def rem(name)
   name = name[-1] == "/" ? name : name+"/"
   Dir.new(name).entries.
      reject{|i| File.directory?(name+i) and (i == "." or i == "..")}.
         each do |elt|
      item = name+elt
      if File.directory?(item)
         if elt == ".svn" 
            FileUtils.rm_r "#{name}.svn"
         else
            rem(item)
         end
      elsif item =~ /\..+\.sw.$/ or item =~ /~$/
         File.delete(item)
      end
   end
end

rem(ARGV[0])
