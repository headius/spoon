require 'rbconfig'

if RbConfig::CONFIG['host_os'] =~ /mingw|mswin|bccwin/
  require 'spoon/windows'
else
  require 'spoon/unix'
end
