require 'spoon'

#
# Do a recursive ls on the current directory, redirecting output to /tmp/ls.out
#

file_actions = Spoon::FileActions.new
file_actions.close(1)
file_actions.open(1, "/tmp/ls.out", File::WRONLY | File::TRUNC | File::CREAT, 0600)
spawn_attr = Spoon::SpawnAttributes.new
pid = Spoon.posix_spawn('/usr/bin/env', file_actions, spawn_attr, %w(env ls -R))

Process.waitpid(pid)
