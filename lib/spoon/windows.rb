# Windows _spawnv

require 'ffi'

module Spoon
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
end
