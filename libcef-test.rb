require("ffi");

module LibC
  extend FFI::Library
  ffi_lib FFI::Library::LIBC
  
  # memory allocators
  attach_function :malloc, [:size_t], :pointer
  attach_function :calloc, [:size_t], :pointer
  attach_function :valloc, [:size_t], :pointer
  attach_function :realloc, [:pointer, :size_t], :pointer
  attach_function :free, [:pointer], :void
  
  # memory movers
  attach_function :memcpy, [:pointer, :pointer, :size_t], :pointer
  attach_function :bcopy, [:pointer, :pointer, :size_t], :void
  
end # module LibC

module MyLibrary
  extend FFI::Library
  ffi_lib("/home/avishek/Code/chromium-tar/home/src_tarball/tarball/chromium/src/cef/binary_distrib/cef_binary_3.1339.959_linux/Debug/lib.target/libcef.so");
  attach_function(:cef_do_message_loop_work, [], :void);
  attach_function(:cef_browser_host_create_browser_sync, [:pointer, :pointer, :pointer, :pointer], :pointer);
  attach_function(:cef_initialize, [:pointer, :pointer, :pointer], :int);
  attach_function(:cef_string_ascii_to_utf16, [:string, :size_t, :pointer], :int);
  puts("That wasn't so bad!");
  enum :LogSeverity, [
  :LOGSEVERITY_DEFAULT,
  :LOGSEVERITY_VERBOSE,
  :LOGSEVERITY_INFO,
  :LOGSEVERITY_WARNING,
  :LOGSEVERITY_ERROR,
  :LOGSEVERITY_ERROR_REPORT,
  :LOGSEVERITY_DISABLE, 99];

  class CefBase < FFI::Struct
    layout :size, :size_t,
            :add_ref, :pointer,
            :release, :pointer,
            :get_refct, :pointer;
  end

  class CefString < FFI::Struct
  	layout :str, :pointer,
  		   :length, :int,
  		   :dtor, :pointer;
  end

  def self.cefString(s)
    ptr = FFI::MemoryPointer.new :pointer;
    MyLibrary.cef_string_ascii_to_utf16(s, s.length, ptr);
    ptr = ptr.get_pointer(0);
  	str = CefString.new;
  	str[:str] = ptr;
  	str[:length] = s.length;
  	return str;
  end

  class WindowInfo < FFI::Struct
  	layout :parent_widget, :pointer,
  		   :widget, :pointer
  end
  class MainArgs < FFI::Struct
  	layout :argc, :int,
  		   :argv, :pointer
  end
  class CefSettings < FFI::Struct
	layout :size, :size_t,
		   :single_process, :int,
		  :browser_subprocess_path, CefString,
		  :multi_threaded_message_loop, :bool,
		  :command_line_args_disabled, :bool,
		  :cache_path, CefString,
		  :user_agent, CefString,
		  :product_version, CefString,
		  :locale, CefString,
		  :log_file, CefString,
		  :log_severity, :LogSeverity,
		  :release_dcheck_enabled, :bool,
		  :javascript_flags, CefString,
		  :auto_detect_proxy_settings_enabled, :bool,
		  :resources_dir_path, CefString,
		  :locales_dir_path, CefString,
		  :pack_loading_disabled, :bool,
		  :remote_debugging_port, :int,
		  :uncaught_exception_stack_size, :int,
		  :context_safety_implementation, :int
  end

  class CefApp < FFI::Struct
      layout :base, CefBase,
      :on_before_command_line_processing, :pointer,
      :on_register_custom_schemes, :pointer,
      :_cef_resource_bundle_handler_t, :pointer,
      :_cef_browser_process_handler_t, :pointer,
      :_cef_render_process_handler_t, :pointer
  end
end

mainArgs = MyLibrary::MainArgs.new;
mainArgs[:argc] = 0;
mainArgs[:argv] = LibC.malloc(0);
settings = MyLibrary::CefSettings.new;
# settings[:pack_loading_disabled] = true;

locales_dir_path = "/home/avishek/Code/chromium-tar/home/src_tarball/tarball/chromium/src/cef/binary_distrib/cef_binary_3.1339.959_linux/Debug/locales";
resources_dir_path = "/home/avishek/Code/chromium-tar/home/src_tarball/tarball/chromium/src/cef/binary_distrib/cef_binary_3.1339.959_linux/Debug";
url = "http://google.com";

settings[:locales_dir_path] = MyLibrary.cefString(locales_dir_path);
settings[:resources_dir_path] = MyLibrary.cefString(resources_dir_path);
settings[:command_line_args_disabled] = true;
app = MyLibrary::CefApp.new;
result = MyLibrary.cef_initialize(mainArgs, settings, nil);
puts("Result: " + result.to_s);
browser = MyLibrary.cef_browser_host_create_browser_sync(MyLibrary::WindowInfo.new, nil, MyLibrary.cefString(url), nil);
# MyLibrary.cef_do_message_loop_work();
