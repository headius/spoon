require 'ffi'
require 'rbconfig'

module Spoon
  extend FFI::Library
  ffi_lib 'c'
  
  if RbConfig::CONFIG['host_os'] =~ /mingw|mswin|bccwin/
    P_NOWAIT = 1
    
    attach_function :_spawnve, [:int, :string, :pointer, :pointer], :int
    attach_function :_spawnvpe, [:int, :string, :pointer, :pointer], :int
    
    ffi_lib 'kernel32'
    ffi_convention :stdcall
    attach_function :_get_process_id, :GetProcessId, [:int], :ulong
    
    def self.spawn(*args)
      spawn_args = _prepare_spawn_args(args)
      _get_process_id(_spawnve(*spawn_args))
    end
    
    def self.spawnp(*args)
      spawn_args = _prepare_spawn_args(args)
      _get_process_id(_spawnvpe(*spawn_args))
    end
    
    private
    
    def self._prepare_spawn_args(args)
      args_ary = FFI::MemoryPointer.new(:pointer, args.length + 1)
      str_ptrs = args.map {|str| FFI::MemoryPointer.from_string(str)}
      args_ary.put_array_of_pointer(0, str_ptrs)

      env_ary = FFI::MemoryPointer.new(:pointer, ENV.length + 1)
      env_ptrs = ENV.map {|key,value| FFI::MemoryPointer.from_string("#{key}=#{value}")}
      env_ary.put_array_of_pointer(0, env_ptrs)
      
      [P_NOWAIT, args[0], args_ary, env_ary]
    end
  else
    # int
    # posix_spawn(pid_t *restrict pid, const char *restrict path,
    #     const posix_spawn_file_actions_t *file_actions,
    #     const posix_spawnattr_t *restrict attrp, char *const argv[restrict],
    #     char *const envp[restrict]);
    
    attach_function :_posix_spawn, :posix_spawn, [:pointer, :string, :pointer, :pointer, :pointer, :pointer], :int
    attach_function :_posix_spawnp, :posix_spawnp, [:pointer, :string, :pointer, :pointer, :pointer, :pointer], :int
    
    def self.spawn(*args)
      spawn_args = _prepare_spawn_args(args)
      _posix_spawn(*spawn_args)
      spawn_args[0].read_int
    end
    
    def self.spawnp(*args)
      spawn_args = _prepare_spawn_args(args)
      _posix_spawnp(*spawn_args)
      spawn_args[0].read_int
    end
    
    private
    
    def self._prepare_spawn_args(args)
      pid_ptr = FFI::MemoryPointer.new(:pid_t, 1)

      args_ary = FFI::MemoryPointer.new(:pointer, args.length + 1)
      str_ptrs = args.map {|str| FFI::MemoryPointer.from_string(str)}
      args_ary.put_array_of_pointer(0, str_ptrs)

      env_ary = FFI::MemoryPointer.new(:pointer, ENV.length + 1)
      env_ptrs = ENV.map {|key,value| FFI::MemoryPointer.from_string("#{key}=#{value}")}
      env_ary.put_array_of_pointer(0, env_ptrs)
      
      [pid_ptr, args[0], nil, nil, args_ary, env_ary]
    end
  end
end

if __FILE__ == $0
  pid = Spoon.spawn('/usr/bin/vim')

  Process.waitpid(pid)
end
