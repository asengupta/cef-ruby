#!/usr/bin/env ruby
require("rubygems")
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

module Gtk
  extend FFI::Library
  ffi_lib("/home/avishek/Code/chromium-tar/home/src_tarball/tarball/chromium/src/cef/binary_distrib/cef_binary_3.1339.959_linux/Debug/lib.target/libcef.so");
  enum :GtkWindowType, [
    :GTK_WINDOW_TOPLEVEL,
    :GTK_WINDOW_POPUP
  ];

  enum :ProcessID, [
    :PID_BROWSER,
    :PID_RENDERER
  ];

  attach_function(:gtk_window_new, [:GtkWindowType], :pointer);
  attach_function(:gtk_drawing_area_new, [], :pointer);
  attach_function(:gtk_init, [:int, :pointer], :void);
  attach_function(:gtk_container_add, [:pointer, :pointer], :void);
  attach_function(:gtk_widget_show, [:pointer], :void);
  attach_function(:gtk_widget_show_all, [:pointer], :void);
  attach_function(:gtk_main, [], :void);
  attach_function(:gtk_vbox_new, [:bool, :int], :pointer);
end

module CefLifeCycle
  extend FFI::Library
  ffi_lib [FFI::CURRENT_PROCESS, "/home/avishek/Code/chromium-tar/home/src_tarball/tarball/chromium/src/cef/binary_distrib/cef_binary_3.1339.959_linux/Debug/lib.target/libcef.so"];
  attach_function(:cef_do_message_loop_work, [], :void);
  attach_function(:cef_browser_host_create_browser_sync, [:pointer, :pointer, :pointer, :pointer], :pointer);
  attach_function(:cef_browser_host_create_browser, [:pointer, :pointer, :pointer, :pointer], :pointer);
  attach_function(:cef_initialize, [:pointer, :pointer, :pointer], :int);
  attach_function(:cef_string_ascii_to_utf16, [:string, :size_t, :pointer], :int);
  attach_function(:cef_run_message_loop, [], :void);
  attach_function(:cef_shutdown, [], :void);
  attach_function(:cef_execute_process, [:pointer, :pointer], :int);

  enum :NavigationType, [
    :NAVIGATION_LINK_CLICKED, 0,
    :NAVIGATION_FORM_SUBMITTED,
    :NAVIGATION_BACK_FORWARD,
    :NAVIGATION_RELOAD,
    :NAVIGATION_FORM_RESUBMITTED,
    :NAVIGATION_OTHER
  ];

  LogSeverity = enum :LogSeverity, [
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
    CefLifeCycle.cef_string_ascii_to_utf16(s, s.length, ptr);
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
		   :single_process, :bool,
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

  class BrowserSettings < FFI::Struct
    layout :size, :size_t,
          :standard_font_family, CefString,
          :fixed_font_family, CefString,
          :serif_font_family, CefString,
          :sans_serif_font_family, CefString,
          :cursive_font_family, CefString,
          :fantasy_font_family, CefString,
          :default_font_size, :int,
          :default_fixed_font_size, :int,
          :minimum_font_size, :int,
          :minimum_logical_font_size, :int,
          :remote_fonts_disabled, :bool,
          :default_encoding, CefString,
          :encoding_detector_enabled, :bool,
          :javascript_disabled, :bool,
          :javascript_open_windows_disallowed, :bool,
          :javascript_close_windows_disallowed, :bool,
          :javascript_access_clipboard_disallowed, :bool,
          :dom_paste_disabled, :bool,
          :caret_browsing_enabled, :bool,
          :java_disabled, :bool,
          :plugins_disabled, :bool,
          :universal_access_from_file_urls_allowed, :bool,
          :file_access_from_file_urls_allowed, :bool,
          :web_security_disabled, :bool,
          :xss_auditor_enabled, :bool,
          :image_load_disabled, :bool,
          :shrink_standalone_images_to_fit, :bool,
          :site_specific_quirks_disabled, :bool,
          :text_area_resize_disabled, :bool,
          :page_cache_disabled, :bool,
          :tab_to_links_disabled, :bool,
          :hyperlink_auditing_disabled, :bool,
          :user_style_sheet_enabled, :bool,
          :user_style_sheet_location, CefString,
          :author_and_user_styles_disabled, :bool,
          :local_storage_disabled, :bool,
          :databases_disabled, :bool,
          :application_cache_disabled, :bool,
          :webgl_disabled, :bool,
          :accelerated_compositing_disabled, :bool,
          :accelerated_layers_disabled, :bool,
          :accelerated_video_disabled, :bool,
          :accelerated_2d_canvas_disabled, :bool,
          :accelerated_plugins_disabled, :bool,
          :developer_tools_disabled, :bool
  end

  class CefApp < FFI::Struct
      layout :base, CefBase,
      :on_before_command_line_processing, :pointer,
      :on_register_custom_schemes, :pointer,
      :_cef_resource_bundle_handler_t, :pointer,
      :_cef_browser_process_handler_t, :pointer,
      :_cef_render_process_handler_t, :pointer
  end

  class CefCommandLine < FFI::Struct
  end

  class CefCommandLine
    layout :base, CefBase,
          :is_valid, :pointer,
          :is_read_only, :pointer,
          :copy, :pointer,
          :init_from_argv, :pointer,
          :init_from_string, :pointer,
          :reset, :pointer,
          :get_argv, :pointer,
          :get_command_line_string, :pointer,
          :get_program, :pointer,
          :set_program, :pointer,
          :has_switches, :pointer,
          :has_switch, :pointer,
          :get_switch_value, :pointer,
          :get_switches, :pointer,
          :append_switch, :pointer,
          :append_switch_with_value, :pointer,
          :has_arguments, :pointer,
          :get_arguments, :pointer,
          :append_argument, :pointer,
          :prepend_wrapper, :pointer
  end

  class CefResourceBundleHandler < FFI::Struct
    layout :base, CefBase,
          :get_localized_string, :pointer,
          :get_data_resource, :pointer
  end

  class CefProxyHandler < FFI::Struct
    layout :base, CefBase,
          :get_proxy_for_url, :pointer
  end

  class CefBrowserProcessHandler < FFI::Struct
    layout :base, CefBase,
          :_cef_proxy_handler_t, :pointer,
          :on_context_initialized, :pointer,
          :on_before_child_process_launch, :pointer,
          :on_render_process_thread_created, :pointer
  end

  def self.cefProxyHandler
    handler = CefLifeCycle::CefProxyHandler.new
    handler[:get_proxy_for_url] = FFI::Function.new(:void, [:pointer]) do |me, url, proxy_info|
      # TODO: Create _cef_proxy_info_t
      puts "Getting URL";
    end
    handler
  end

  def self.cefBrowserProcessHandler
    handler = CefLifeCycle.CefBrowserProcessHandler.new
    handler[:_cef_proxy_handler_t] = FFI::Function.new(:pointer, [:pointer]) do |me|
      puts "Getting proxy handler"
      self.cefProxyHandler
    end
    handler[:on_context_initialized] = FFI::Function.new(:void, [:pointer]) do |me|
      puts "Initialised context"
    end
    handler[:on_before_child_process_launch] = FFI::Function.new(:void, [:pointer, :pointer]) do |me, command_line|
      puts "Before launching child process"
    end
    handler[:on_render_process_thread_created] = FFI::Function.new(:void, [:pointer, :pointer]) do |me, extra_info|
      # TODO: Create _cef_list_value_t type
      puts "On creating render process"
    end
    handler
  end

  class CefRenderProcessHandler < FFI::Struct
    layout :base, CefBase,
          :on_render_thread_created, :pointer,
          :on_web_kit_initialized, :pointer,
          :on_browser_created, :pointer,
          :on_browser_destroyed, :pointer,
          :on_before_navigation, :pointer,
          :on_context_created, :pointer,
          :on_context_released, :pointer,
          :on_uncaught_exception, :pointer,
          :on_focused_node_changed, :pointer,
          :on_process_message_received, :pointer
  end


  def self.cefRenderProcessHandler
    handler = CefLifeCycle::CefRenderProcessHandler.new
    handler[:on_render_thread_created] = 
    FFI::Function.new(:void, [:pointer, :pointer]) do |me, extra_info|
      puts "In before command line processing...boooya!!"
    end
    handler[:on_web_kit_initialized] = 
    FFI::Function.new(:void, [:pointer]) do |me|
      puts "In before command line processing...boooya!!"
    end
    handler[:on_browser_created] = 
    FFI::Function.new(:void, [:pointer, :pointer]) do |me, browser|
      puts "In before command line processing...boooya!!"
    end
    handler[:on_browser_destroyed] = 
    FFI::Function.new(:void, [:pointer, :pointer]) do |me, browser|
      puts "In before command line processing...boooya!!"
    end
    handler[:on_before_navigation] = 
    FFI::Function.new(:void, [:pointer, :pointer, :pointer, :pointer, :NavigationType, :int]) do |me, browser, frame, request, navigation_type, is_redirect|
      # TODO: Declare _cef_request_t
      puts "In before command line processing...boooya!!"
    end
    handler[:on_context_created] = 
    FFI::Function.new(:void, [:pointer, :pointer, :pointer, :pointer]) do |me, browser, frame, v8_context|
      # TODO: Declare _cef_v8context_t
      puts "In before command line processing...boooya!!"
    end
    handler[:on_context_released] = 
    FFI::Function.new(:void, [:pointer, :pointer, :pointer, :pointer]) do |me, browser, frame, v8_context|
      # TODO: Declare _cef_v8context_t
      puts "In before command line processing...boooya!!"
    end
    handler[:on_uncaught_exception] = 
    FFI::Function.new(:void, [:pointer, :pointer, :pointer, :pointer, :pointer, :pointer]) do |me, browser, frame, v8_context, v8_exception, v8_stacktrace|
      # TODO: Declare _cef_v8exception_t
      # TODO: Declare _cef_v8stack_trace_t
      puts "In before command line processing...boooya!!"
    end
    handler[:on_focused_node_changed] = 
    FFI::Function.new(:void, [:pointer, :pointer, :pointer, :pointer]) do |me, browser, frame, dom_node|
      # TODO: Declare _cef_domnode_t
      puts "In before command line processing...boooya!!"
    end
    handler[:on_process_message_received] = 
      FFI::Function.new(:int, [:pointer, :pointer, :int, :pointer]) do |browser, source_process, message|
      # TODO: Implement _cef_process_message_t
      # TODO: Look at cef_process_id_t
      puts "Received a message..."
      42
    end

    handler
  end

  def self.cefApp
    app = CefApp.new
    app[:on_before_command_line_processing] = 
    FFI::Function.new(:void, [:pointer, :pointer, :pointer]) do |me, process_type, command_line|
      puts "In before command line processing...boooya!!"
    end
    app[:on_register_custom_schemes] = 
    FFI::Function.new(:void, [:pointer, :pointer]) do |me, registrar|
      puts "In registering custom schemes...boooya!!"
    end

    app[:_cef_resource_bundle_handler_t] = 
    FFI::Function.new(:void, [:pointer]) do |me|
      puts "In getting resource bundler...boooya!!"
      CefResourceBundleHandler.new
    end
    app[:_cef_browser_process_handler_t] = 
    FFI::Function.new(:void, [:pointer]) do |me|
      puts "In getting browser process handler...boooya!!"
      self.cefBrowserProcessHandler
    end
    app[:_cef_render_process_handler_t] = 
    FFI::Function.new(:void, [:pointer]) do |me|
      puts "In getting render process handler...boooya!!"
      self.cefRenderProcessHandler
    end
    app
  end

  class CefContextMenuHandler < FFI::Struct
    layout :base, CefBase,
          :on_before_context_menu, :pointer,
          :on_context_menu_command, :pointer,
          :on_context_menu_dismissed, :pointer
  end

  class CefDialogHandler < FFI::Struct
    layout :base, CefBase,
          :on_file_dialog, :pointer
  end

  class CefDisplayHandler < FFI::Struct
    layout :base, CefBase,
          :on_loading_state_change, :pointer,
          :on_address_change, :pointer,
          :on_title_change, :pointer,
          :on_tooltip, :pointer,
          :on_status_message, :pointer,
          :on_console_message, :pointer
  end

  class CefDownloadHandler < FFI::Struct
    layout :base, CefBase,
          :on_before_download, :pointer,
          :on_download_updated, :pointer
  end

  class CefFocusHandler < FFI::Struct
    layout :base, CefBase,
          :on_take_focus, :pointer,
          :on_set_focus, :pointer,
          :on_got_focus, :pointer
  end

  class CefGeolocationHandler < FFI::Struct
    layout :base, CefBase,
          :on_request_geolocation_permission, :pointer,
          :on_cancel_geolocation_permission, :pointer
  end

  class CefJavascriptDialogHandler < FFI::Struct
    layout :base, CefBase,
          :on_jsdialog, :pointer,
          :on_before_unload_dialog, :pointer,
          :on_reset_dialog_state, :pointer
  end

  class CefKeyboardHandler < FFI::Struct
    layout :base, CefBase,
          :on_pre_key_event, :pointer,
          :on_key_event, :pointer
  end

  class CefLifeSpanHandler < FFI::Struct
    layout :base, CefBase,
          :on_before_popup, :pointer,
          :on_after_created, :pointer,
          :run_modal, :pointer,
          :do_close, :pointer,
          :on_before_close, :pointer
  end

  class CefLoadHandler < FFI::Struct
    layout :base, CefBase,
          :on_load_start, :pointer,
          :on_load_end, :pointer,
          :on_load_error, :pointer,
          :on_render_process_terminated, :pointer,
          :on_plugin_crashed, :pointer
  end

  class CefRenderHandler < FFI::Struct
    layout :base, CefBase,
          :get_root_screen_rect, :pointer,
          :get_view_rect, :pointer,
          :get_screen_point, :pointer,
          :on_popup_show, :pointer,
          :on_popup_size, :pointer,
          :on_paint, :pointer,
          :on_cursor_change, :pointer
  end

  class CefRequestHandler < FFI::Struct
    layout :base, CefBase,
          :on_before_resource_load, :pointer,
          :_cef_resource_handler_t, :pointer,
          :on_resource_redirect, :pointer,
          :get_auth_credentials, :pointer,
          :on_quota_request, :pointer,
          :_cef_cookie_manager_t, :pointer,
          :on_protocol_execution, :pointer,
          :on_before_plugin_load, :pointer
  end

  class CefClient < FFI::Struct
  end

  class CefClient
    layout :base, CefBase,
          :_cef_context_menu_handler_t, :pointer,
          :_cef_dialog_handler_t, :pointer,
          :_cef_display_handler_t, :pointer,
          :_cef_download_handler_t, :pointer,
          :_cef_focus_handler_t, :pointer,
          :_cef_geolocation_handler_t, :pointer,
          :_cef_jsdialog_handler_t, :pointer,
          :_cef_keyboard_handler_t, :pointer,
          :_cef_life_span_handler_t, :pointer,
          :_cef_load_handler_t, :pointer,
          :_cef_render_handler_t, :pointer,
          :_cef_request_handler_t, :pointer,
          :on_process_message_received, :pointer
  end

  def self.cefClient
    client = CefLifeCycle::CefClient.new
    client[:_cef_keyboard_handler_t] = FFI::Function.new(:pointer, [:pointer]) do |client|
      return CefKeyboardHandler.new
    end
    client[:_cef_dialog_handler_t] = FFI::Function.new(:pointer, [:pointer]) do |client|
      return CefDialogHandler.new
    end
    client[:_cef_context_menu_handler_t] = FFI::Function.new(:pointer, [:pointer]) do |client|
      return CefContextMenuHandler.new
    end
    client[:_cef_request_handler_t] = FFI::Function.new(:pointer, [:pointer]) do |client|
      return CefRequestHandler.new
    end
    client[:_cef_render_handler_t] = FFI::Function.new(:pointer, [:pointer]) do |client|
      return CefRenderHandler.new
    end
    client[:_cef_load_handler_t] = FFI::Function.new(:pointer, [:pointer]) do |client|
      return CefLoadHandler.new
    end
    client[:_cef_keyboard_handler_t] = FFI::Function.new(:pointer, [:pointer]) do |client|
      return CefKeyboardHandler.new
    end
    client[:_cef_jsdialog_handler_t] = FFI::Function.new(:pointer, [:pointer]) do |client|
      return CefJavascriptDialogHandler.new
    end
    client[:_cef_geolocation_handler_t] = FFI::Function.new(:pointer, [:pointer]) do |client|
      return CefGeolocationHandler.new
    end
    client[:_cef_focus_handler_t] = FFI::Function.new(:pointer, [:pointer]) do |client|
      return CefFocusHandler.new
    end
    client[:_cef_download_handler_t] = FFI::Function.new(:pointer, [:pointer]) do |client|
      return CefDownloadHandler.new
    end
    client[:_cef_life_span_handler_t] = FFI::Function.new(:pointer, [:pointer]) do |client|
      return CefLifeSpanHandler.new
    end
    client[:on_process_message_received] = 
      FFI::Function.new(:int, [:pointer, :pointer, :int, :pointer]) do |browser, source_process, message|
      # TODO: Implement _cef_process_message_t
      # TODO: Look at cef_process_id_t
      puts "Received a message..."
      42
    end
    client
  end
end

def run(command_line_args)
    puts "Invoked with..." + command_line_args.to_s

    mainArgs = CefLifeCycle::MainArgs.new;
    args = [];
    command_line_args.each do |a|
      args << FFI::MemoryPointer.from_string(a);
    end
    args << nil;
    argv = FFI::MemoryPointer.new(:pointer, args.length)
        args.each_with_index do |p, i|
        argv[i].put_pointer(0, p);
    end
    mainArgs[:argc] = command_line_args.length;
    mainArgs[:argv] = argv;

    app = CefLifeCycle.cefApp;
    puts "About to execute..."
    exitCode = CefLifeCycle.cef_execute_process(mainArgs, app);
    puts "Exit Code = " + exitCode.to_s
    return exitCode if exitCode >= 0

    Gtk.gtk_init(0, nil);
    top = Gtk.gtk_window_new(:GTK_WINDOW_TOPLEVEL);
    vbox = Gtk.gtk_vbox_new(false, 0);
    window_info = CefLifeCycle::WindowInfo.new;
    window_info[:parent_widget] = vbox;


    settings = cefSettings();
    browser_settings = browserSettings();
    url = "http://google.com";

    client = CefLifeCycle.cefClient;
    result = CefLifeCycle.cef_initialize(mainArgs, settings, app);
    CefLifeCycle.cef_run_message_loop();

    puts("CEF Initialisation: " + result.to_s);
    worked = CefLifeCycle.cef_browser_host_create_browser_sync(window_info, client, CefLifeCycle.cefString(url), browser_settings);
    puts("Browser address=" + worked.to_s);
    Gtk.gtk_container_add(top, vbox);
    Gtk.gtk_widget_show(top);
    Gtk.gtk_main();
    CefLifeCycle.cef_shutdown();
end

def cefSettings
    locales_dir_path = "/home/avishek/Code/chromium-tar/home/src_tarball/tarball/chromium/src/cef/binary_distrib/cef_binary_3.1339.959_linux/Debug/locales";
    resources_dir_path = "/home/avishek/Code/chromium-tar/home/src_tarball/tarball/chromium/src/cef/binary_distrib/cef_binary_3.1339.959_linux/Debug";

    settings = CefLifeCycle::CefSettings.new
    settings[:single_process] = false
    # settings[:browser_subprocess_path] = CefLifeCycle.cefString("./embed.out")
    settings[:multi_threaded_message_loop] = false
    settings[:command_line_args_disabled] = false
    settings[:cache_path] = CefLifeCycle.cefString("./cache-mojo")
    settings[:user_agent] = CefLifeCycle.cefString("Chrome")
    settings[:product_version] = CefLifeCycle.cefString("12212")
    settings[:locale] = CefLifeCycle.cefString("en-US")
    settings[:log_file] = CefLifeCycle.cefString("./chromium.log")
    # settings[:log_severity] = 1,
    settings[:release_dcheck_enabled] = false
    settings[:javascript_flags] = CefLifeCycle.cefString("")
    settings[:auto_detect_proxy_settings_enabled] = false
    settings[:pack_loading_disabled] = false
    # settings[:remote_debugging_port] = 12121
    settings[:uncaught_exception_stack_size] = 200
    settings[:context_safety_implementation] = 0
    settings[:locales_dir_path] = CefLifeCycle.cefString(locales_dir_path);
    settings[:resources_dir_path] = CefLifeCycle.cefString(resources_dir_path);
    settings
end

def browserSettings
  browser_settings = CefLifeCycle::BrowserSettings.new;
  browser_settings[:standard_font_family] = CefLifeCycle.cefString("Arial")
  browser_settings[:fixed_font_family] = CefLifeCycle.cefString("Arial")
  browser_settings[:sans_serif_font_family] = CefLifeCycle.cefString("Arial")
  browser_settings[:serif_font_family] = CefLifeCycle.cefString("Arial")
  browser_settings[:cursive_font_family] = CefLifeCycle.cefString("Arial")
  browser_settings[:fantasy_font_family] = CefLifeCycle.cefString("Arial")
  browser_settings[:default_font_size] = 20
  browser_settings[:minimum_font_size] = 20
  browser_settings[:default_fixed_font_size] = 20
  browser_settings[:minimum_logical_font_size] = 20
  browser_settings[:default_encoding] = CefLifeCycle.cefString("UTF-16")
  browser_settings[:encoding_detector_enabled] = true
  browser_settings[:javascript_disabled] = false
  browser_settings[:javascript_open_windows_disallowed] = false
  browser_settings[:javascript_close_windows_disallowed] = false
  browser_settings[:javascript_access_clipboard_disallowed] = false
  browser_settings[:dom_paste_disabled] = false
  browser_settings[:caret_browsing_enabled] = false
  browser_settings[:java_disabled] = false
  browser_settings[:plugins_disabled] = true
  browser_settings[:universal_access_from_file_urls_allowed] = true
  browser_settings[:file_access_from_file_urls_allowed] = false
  browser_settings[:xss_auditor_enabled] = false
  browser_settings[:image_load_disabled] = false
  browser_settings[:shrink_standalone_images_to_fit] = true
  browser_settings[:site_specific_quirks_disabled] = true
  browser_settings[:text_area_resize_disabled] = true
  browser_settings[:page_cache_disabled] = true
  browser_settings[:tab_to_links_disabled] = false
  browser_settings[:hyperlink_auditing_disabled] = true
  browser_settings[:user_style_sheet_enabled] = false
  browser_settings[:user_style_sheet_location] = CefLifeCycle.cefString(".")
  browser_settings[:author_and_user_styles_disabled] = true
  browser_settings[:local_storage_disabled] = false
  browser_settings[:databases_disabled] = false
  browser_settings[:application_cache_disabled] = false
  browser_settings[:webgl_disabled] = false
  browser_settings[:accelerated_compositing_disabled] = false
  browser_settings[:accelerated_layers_disabled] = false
  browser_settings[:accelerated_video_disabled] = false
  browser_settings[:accelerated_2d_canvas_disabled] = false
  browser_settings[:accelerated_plugins_disabled] = true
  browser_settings[:developer_tools_disabled] = true

  return browser_settings;
end



# run(["Soething"]);