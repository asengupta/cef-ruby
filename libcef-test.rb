#!/usr/bin/env ruby
require("rubygems")
require("ffi");
require("securerandom")
ThreadID = SecureRandom.random_number

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
  @nonGC = {}

  ffi_lib [FFI::CURRENT_PROCESS, "/home/avishek/Code/chromium-tar/home/src_tarball/tarball/chromium/src/cef/binary_distrib/cef_binary_3.1339.959_linux/Debug/lib.target/libcef.so"];
  attach_function(:cef_do_message_loop_work, [], :void, :blocking => true);
  attach_function(:cef_browser_host_create_browser_sync, [:pointer, :pointer, :pointer, :pointer], :pointer, :blocking => true);
  attach_function(:cef_browser_host_create_browser, [:pointer, :pointer, :pointer, :pointer], :pointer, :blocking => true);
  attach_function(:cef_initialize, [:pointer, :pointer, :pointer], :int, :blocking => true);
  attach_function(:cef_string_ascii_to_utf16, [:string, :size_t, :pointer], :int, :blocking => true);
  attach_function(:cef_run_message_loop, [], :void, :blocking => true);
  attach_function(:cef_shutdown, [], :void, :blocking => true);
  attach_function(:cef_execute_process, [:pointer, :pointer], :int, :blocking => true);

  NavigationType = enum(:NAVIGATION_LINK_CLICKED, 0,
    :NAVIGATION_FORM_SUBMITTED,
    :NAVIGATION_BACK_FORWARD,
    :NAVIGATION_RELOAD,
    :NAVIGATION_FORM_RESUBMITTED,
    :NAVIGATION_OTHER
  );

  LogSeverity = enum :LogSeverity, [
  :LOGSEVERITY_DEFAULT,
  :LOGSEVERITY_VERBOSE,
  :LOGSEVERITY_INFO,
  :LOGSEVERITY_WARNING,
  :LOGSEVERITY_ERROR,
  :LOGSEVERITY_ERROR_REPORT,
  :LOGSEVERITY_DISABLE, 99];

  callback :int_pointer, [:pointer], :int

  class CefBase < FFI::Struct
    layout :size, :size_t,
            :add_ref, :int_pointer,
            :release, :int_pointer,
            :get_refct, :int_pointer;
  end

  @addReference = FFI::Function.new(:int, [:pointer]) do |me|
    # puts "Adding a reference..."
    1
  end

  @releaseReference = FFI::Function.new(:int, [CefBase.ptr]) do |me|
    # puts "Removing a reference..."
    1
  end
  
  @getReferenceCount = FFI::Function.new(:int, [CefBase.ptr]) do |me|
    # puts "Reference count is hardcoded..."
    2
  end

  def self.cefBase
    base = CefBase.new
    base[:size] = 1000 # That ought to satisfy them
    base[:add_ref] = @addReference
    base[:release] = @releaseReference
    base[:get_refct] = @getReferenceCount
    base
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
      :get_resource_bundle_handler, :pointer,
      :get_browser_process_handler, :pointer,
      :get_render_process_handler, :pointer
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
          :get_proxy_handler, :pointer,
          :on_context_initialized, :pointer,
          :on_before_child_process_launch, :pointer,
          :on_render_process_thread_created, :pointer
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

  callback :add_custom_scheme_signature, [:pointer, :pointer, :int, :int, :int], :int

  class CefSchemeRegistrar < FFI::Struct
    layout :base, CefBase,
          :add_custom_scheme, :add_custom_scheme_signature
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
          :get_resource_handler, :pointer,
          :on_resource_redirect, :pointer,
          :get_auth_credentials, :pointer,
          :on_quota_request, :pointer,
          :get_cookie_manager, :pointer,
          :on_protocol_execution, :pointer,
          :on_before_plugin_load, :pointer
  end

  class CefClient < FFI::Struct
  end

  class CefClient
    layout :base, CefBase,
          :get_context_menu_handler, :pointer,
          :get_dialog_handler, :pointer,
          :get_display_handler, :pointer,
          :get_download_handler, :pointer,
          :get_focus_handler, :pointer,
          :get_geolocation_handler, :pointer,
          :get_jsdialog_handler, :pointer,
          :get_keyboard_handler, :pointer,
          :get_life_span_handler, :pointer,
          :get_load_handler, :pointer,
          :get_render_handler, :pointer,
          :get_request_handler, :pointer,
          :on_process_message_received, :pointer
  end

  @getProxyForUrl = FFI::Function.new(:void, [:pointer]) do |me, url, proxy_info|
      # TODO: Create _cef_proxy_info_t
      puts "Getting URL";
    end
  def self.cefProxyHandler
    handler = CefLifeCycle::CefProxyHandler.new
    handler[:base] = self.cefBase
    handler[:get_proxy_for_url] = @getProxyForUrl
    handler
  end

  @nonGC[:proxyHandler] = self.cefProxyHandler

  @getCefProxyHandler = FFI::Function.new(:pointer, [:pointer]) do |me|
      puts "Getting proxy handler"
      @nonGC[:proxyHandler]
    end

  @onContextInitialised = FFI::Function.new(:void, [:pointer]) do |me|
      puts "[#{ThreadID}] Initialised context"
    end
  @onBeforeChildProcessLaunch = FFI::Function.new(:void, [:pointer, :pointer]) do |me, command_line|
      puts "[#{ThreadID}] Before launching child process"
    end
  @onRenderProcessThreadCreated = FFI::Function.new(:void, [:pointer, :pointer]) do |me, extra_info|
      # TODO: Create _cef_list_value_t type
      puts "[#{ThreadID}] On creating render process"
    end

  def self.cefBrowserProcessHandler
    handler = CefLifeCycle::CefBrowserProcessHandler.new
    handler[:base] = self.cefBase
    handler[:get_proxy_handler] = @getCefProxyHandler
    handler[:on_context_initialized] = @onContextInitialised
    handler[:on_before_child_process_launch] = @onBeforeChildProcessLaunch
    handler[:on_render_process_thread_created] = @onRenderProcessThreadCreated
    puts "[#{ThreadID}] Created new BrowserHandler: " + handler.to_s
    handler
  end

  def self.cefRenderProcessHandler
    handler = CefLifeCycle::CefRenderProcessHandler.new
    handler[:base] = self.cefBase
    handler[:on_render_thread_created] = @onRenderThreadCreated
    handler[:on_web_kit_initialized] = @onWebKitInitialised
    handler[:on_browser_created] = @onBrowserCreated
    handler[:on_browser_destroyed] = @onBrowserDestroyed
    handler[:on_before_navigation] = @onBeforeNavigation
    handler[:on_context_created] = @onContextCreated
    handler[:on_context_released] = @onContextReleased
    handler[:on_uncaught_exception] = @onUncaughtException
    handler[:on_focused_node_changed] = @onFocusedNodeChanged
    handler[:on_process_message_received] = @onRenderProcessHandlerProcessMessageReceived

    handler
  end

  @onLoadingStateChange = 
  FFI::Function.new(:void, [CefDisplayHandler.ptr, :pointer, :int, :int, :int]) do |me, browser, isLoading, canGoBack, canGoForward|
    puts "On loading state change..."
  end

  @onAddressStateChange = 
  FFI::Function.new(:void, [CefDisplayHandler.ptr, :pointer, :pointer, CefString.ptr]) do |me, browser, frame, url|
    puts "On address change..."
  end

  @onTitleChange = 
  FFI::Function.new(:void, [CefDisplayHandler.ptr, :pointer, CefString.ptr]) do |me, browser, title|
    puts "On title change..."
  end

  @onTooltip = 
  FFI::Function.new(:int, [CefDisplayHandler.ptr, :pointer, CefString.ptr]) do |me, browser, text|
    puts "On tooltip..."
    1
  end

  @onStatusMessage = 
  FFI::Function.new(:void, [CefDisplayHandler.ptr, :pointer, CefString.ptr]) do |me, browser, value|
    puts "On status message..."
  end

  @onConsoleMessage = 
  FFI::Function.new(:int, [CefDisplayHandler.ptr, :pointer, CefString.ptr, CefString.ptr, :int]) do |me, browser, message, source, line|
    puts "On console message..."
    0
  end

  def self.cefDisplayHandler
    handler = CefDisplayHandler.new
    handler[:base] = self.cefBase
    handler[:on_loading_state_change] = @onLoadingStateChange
    handler[:on_address_change] = @onAddressStateChange
    handler[:on_title_change] = @onTitleChange
    handler[:on_tooltip] = @onTooltip
    handler[:on_status_message] = @onStatusMessage
    handler[:on_console_message] = @onConsoleMessage
    handler
  end

  @nonGC[:displayHandler] = self.cefDisplayHandler
  @nonGC[:browserProcessHandler] = self.cefBrowserProcessHandler
  @nonGC[:renderProcessHandler] = self.cefRenderProcessHandler


  @onRenderThreadCreated =     FFI::Function.new(:void, [:pointer, :pointer]) do |me, extra_info|
      puts "On render thread created...boooya!!"
    end
  @onWebKitInitialised =     FFI::Function.new(:void, [:pointer]) do |me|
      puts "On WebKit initialised...boooya!!"
    end
  @onBrowserCreated =     FFI::Function.new(:void, [:pointer, :pointer]) do |me, browser|
      puts "On browser created...boooya!!"
    end

  @onBrowserDestroyed =     FFI::Function.new(:void, [:pointer, :pointer]) do |me, browser|
      puts "On browser destroyed...boooya!!"
    end

  @onBeforeNavigation =     FFI::Function.new(:void, [:pointer, :pointer, :pointer, :pointer, :uint8, :int]) do |me, browser, frame, request, navigation_type, is_redirect|
      # TODO: Declare _cef_request_t
      # The uint8 is a NavigationType
      puts "On before navigation...boooya!!"
    end

  @onContextCreated =     FFI::Function.new(:void, [:pointer, :pointer, :pointer, :pointer]) do |me, browser, frame, v8_context|
      # TODO: Declare _cef_v8context_t
      puts "On context created...boooya!!"
    end

  @onContextReleased =     FFI::Function.new(:void, [:pointer, :pointer, :pointer, :pointer]) do |me, browser, frame, v8_context|
      # TODO: Declare _cef_v8context_t
      puts "On context released...boooya!!"
    end

  @onUncaughtException =     FFI::Function.new(:void, [:pointer, :pointer, :pointer, :pointer, :pointer, :pointer]) do |me, browser, frame, v8_context, v8_exception, v8_stacktrace|
      # TODO: Declare _cef_v8exception_t
      # TODO: Declare _cef_v8stack_trace_t
      puts "On uncaught exception...boooya!!"
    end

  @onFocusedNodeChanged =     FFI::Function.new(:void, [:pointer, :pointer, :pointer, :pointer]) do |me, browser, frame, dom_node|
      # TODO: Declare _cef_domnode_t
      puts "On focused node changed...boooya!!"
    end

  @onRenderProcessHandlerProcessMessageReceived = 
  FFI::Function.new(:int, [CefRenderProcessHandler.ptr, :pointer, :uint8, :pointer]) do |me, browser, source_process, message|
      # TODO: Implement _cef_process_message_t
      # TODO: Look at cef_process_id_t
      puts "Received a message..."
      true
    end

  @onCefClientProcessMessageReceived =       FFI::Function.new(:int, [CefClient.ptr, :pointer, :uint8, :pointer]) do |me, browser, source_process, message|
      # TODO: Implement _cef_process_message_t
      # TODO: Look at cef_process_id_t
      puts "Received a message..."
      true
    end

  @onBeforeCommandLineProcessing =     FFI::Function.new(:void, [:pointer, :pointer, :pointer]) do |me, process_type, command_line|
      puts "In before command line processing...boooya!!"
    end

  @onRegisterCustomSchemes =     FFI::Function.new(:void, [:pointer, :pointer]) do |me, registrar|
      puts "[#{ThreadID}] Registering schemes like it's 1857...#{registrar.address} [#{registrar}]"
      registrar = CefBase.new(registrar)
      puts "Translated it to #{registrar.to_s}"
      base = registrar[:release]
      puts "Resolved release to: #{base}"
      base.call(registrar)
    end

  @getCefResourceBundleHandler =     FFI::Function.new(:pointer, [:pointer]) do |me|
      puts "In getting resource bundler...boooya!!"
      handler = CefResourceBundleHandler.new
      handler[:base] = self.cefBase
      handler
    end

  @getCefBrowserProcessHandler =     FFI::Function.new(CefBrowserProcessHandler.ptr, [:pointer]) do |me|
      puts "In getting browser process handler...boooya!!"
      puts @nonGC[:browserProcessHandler].pointer.to_s 
      @nonGC[:browserProcessHandler]
    end

  @getCefRenderProcessHandler =     FFI::Function.new(:pointer, [:pointer]) do |me|
      puts "In getting render process handler...boooya!!"
      @nonGC[:renderProcessHandler]
    end

  def self.cefApp
    app = CefApp.new
    app[:base] = self.cefBase

    app[:on_before_command_line_processing] = @onBeforeCommandLineProcessing
    app[:on_register_custom_schemes] = @onRegisterCustomSchemes
    app[:get_resource_bundle_handler] = @getCefResourceBundleHandler
    app[:get_browser_process_handler] = @getCefBrowserProcessHandler
    app[:get_render_process_handler] = @getCefRenderProcessHandler
    app
  end

  @onBeforePopup = 
  FFI::Function.new(:int, [CefLifeSpanHandler.ptr, :pointer, :pointer, WindowInfo.ptr, :pointer, BrowserSettings.ptr]) do |me, browser, popupFeatures, windowInfo, client, browserSettings|
    puts "In before on popup..."
    1
  end

  @onAfterCreated = FFI::Function.new(:void, [CefLifeSpanHandler.ptr, :pointer]) do |me, browser|
    puts "On after created..."
  end

  @runModal = FFI::Function.new(:int, [CefLifeSpanHandler.ptr, :pointer]) do |me, browser|
    puts "In running modal..."
    1
  end

  @doClose = FFI::Function.new(:int, [CefLifeSpanHandler.ptr, :pointer]) do |me, broswer|
    puts "In do close..."
    1
  end

  @onBeforeClose = FFI::Function.new(:void, [CefLifeSpanHandler.ptr, :pointer]) do |me, browser|
    puts "In before close..."
  end

  def self.cefLifespanHandler
      handler = CefLifeSpanHandler.new
      handler[:base] = self.cefBase

      handler[:on_before_popup] = @onBeforePopup
      handler[:on_after_created] = @onAfterCreated
      handler[:run_modal] = @runModal
      handler[:do_close] = @doClose
      handler[:on_before_close] = @onBeforeClose
      handler
  end

  @nonGC[:lifespanHandler] = self.cefLifespanHandler

    @onBeforeResourceLoad = 
    FFI::Function.new(:bool, [CefRequestHandler.ptr, :pointer, :pointer, :pointer]) do |me, browser, frame, request|
      puts "In before resource load..."
      return false
    end
    @getResourceHandler = 
    FFI::Function.new(:pointer, [CefRequestHandler.ptr, :pointer, :pointer, :pointer]) do |me, browser, frame, request|
      puts "Getting resource handler..."
      return nil;
      # TODO: Set up _cef_request_handler_t, _cef_browser_t, _cef_frame_t, _cef_request_t, _cef_resource_handler_t
    end

    @onResourceRedirect = 
    FFI::Function.new(:void, [CefRequestHandler.ptr, :pointer, :pointer, CefString.ptr, CefString.ptr]) do |me, browser, frame, oldUrl, newUrl|
      puts "On resource redirect..."
      return nil;
    end

    @getAuthCredentials = 
    FFI::Function.new(:int, [CefRequestHandler.ptr, :pointer, :pointer, :int, CefString.ptr, :int, CefString.ptr, CefString.ptr, :pointer]) do |me, browser, frame, isProxy, host, port, realm, scheme, authCallback|
      puts "Getting auth credentials..."
      return 1;
    end

    @onQuotaRequest = 
    FFI::Function.new(:int, [CefRequestHandler.ptr, :pointer, CefString.ptr, :int64, :pointer]) do |me, browser, originUrl, newSize, quotaCallback|
      puts "On quota request..."
      return 1
    end

    @getCookieManager = 
    FFI::Function.new(:pointer, [CefRequestHandler.ptr, :pointer, CefString.ptr]) do |me, browser, mainUrl|
      puts "Getting cookie manager..."
      return nil
    end

    @onProtocolExecution = 
    FFI::Function.new(:void, [CefRequestHandler.ptr, :pointer, CefString.ptr, :pointer]) do |me, browser, url, allowOSExecution|
      puts "On protocol execution..."
    end

    @onBeforePluginLoad = 
    FFI::Function.new(:int, [CefRequestHandler.ptr, :pointer, CefString.ptr, CefString.ptr, :pointer]) do |me, browser, url, policyUrl, pluginInfo|
      puts "On before plugin load..."
      # TODO: Set up _cef_web_plugin_info_t
      return 0
    end

    def self.cefRequestHandler
      handler = CefRequestHandler.new
      handler[:base] = self.cefBase
      handler[:on_before_resource_load] = @onBeforeResourceLoad
      handler[:get_resource_handler] = @getResourceHandler
      handler[:on_resource_redirect] = @onResourceRedirect
      handler[:get_auth_credentials] = @getAuthCredentials
      handler[:on_quota_request] = @onQuotaRequest
      handler[:get_cookie_manager] = @getCookieManager
      handler[:on_protocol_execution] = @onProtocolExecution
      handler[:on_before_plugin_load] = @onBeforePluginLoad
      handler
    end

  @nonGC[:requestHandler] = self.cefRequestHandler

  def self.cefClient
    client = CefLifeCycle::CefClient.new
    client[:base] = self.cefBase

    client[:get_display_handler] = FFI::Function.new(:pointer, [:pointer]) do |client|
      puts "Getting display handler..."
      handler = CefDisplayHandler.new
      handler[:base] = self.cefBase
      handler
    end
    client[:get_keyboard_handler] = FFI::Function.new(:pointer, [:pointer]) do |client|
      puts "Getting keyboard handler..."
      handler = CefKeyboardHandler.new
      handler[:base] = self.cefBase
      handler
    end
    client[:get_dialog_handler] = FFI::Function.new(:pointer, [:pointer]) do |client|
      puts "Getting dialog handler..."
      handler = CefDialogHandler.new
      handler[:base] = self.cefBase
      handler
    end
    client[:get_context_menu_handler] = FFI::Function.new(:pointer, [:pointer]) do |client|
      puts "Getting context menu handler..."
      handler = CefContextMenuHandler.new
      handler[:base] = self.cefBase
      handler
    end

    client[:get_request_handler] = FFI::Function.new(CefRequestHandler.ptr, [:pointer]) do |client|
      puts "Getting request handler..." + @nonGC[:requestHandler].to_s
      # self.cefRequestHandler
      @nonGC[:requestHandler]
    end
    client[:get_render_handler] = FFI::Function.new(:pointer, [:pointer]) do |client|
      puts "Getting render handler..."
      handler = CefRenderHandler.new
      handler[:base] = self.cefBase
      handler
    end
    client[:get_load_handler] = FFI::Function.new(:pointer, [:pointer]) do |client|
      puts "Getting load handler..."
      handler = CefLoadHandler.new
      handler[:base] = self.cefBase
      handler
    end
    client[:get_jsdialog_handler] = FFI::Function.new(:pointer, [:pointer]) do |client|
      puts "Getting JS Dialog handler..."
      handler = CefJavascriptDialogHandler.new
      handler[:base] = self.cefBase
      handler
    end
    client[:get_geolocation_handler] = FFI::Function.new(:pointer, [:pointer]) do |client|
      puts "Getting geolocation handler..."
      handler = CefGeolocationHandler.new
      handler[:base] = self.cefBase
      handler
    end
    client[:get_focus_handler] = FFI::Function.new(:pointer, [:pointer]) do |client|
      puts "Getting focus handler..."
      handler = CefFocusHandler.new
      handler[:base] = self.cefBase
      handler
    end
    client[:get_download_handler] = FFI::Function.new(:pointer, [:pointer]) do |client|
      puts "Getting download handler..."
      handler = CefDownloadHandler.new
      handler[:base] = self.cefBase
      handler
    end
    client[:get_life_span_handler] = FFI::Function.new(CefLifeSpanHandler.ptr, [:pointer]) do |client|
      puts "Getting lifespan handler..."
      @nonGC[:lifespanHandler]
    end
    client[:on_process_message_received] = @onCefClientProcessMessageReceived
    #   FFI::Function.new(:int, [:pointer, :pointer, :uint8, :pointer]) do |me, browser, source_process, message|
    #   # TODO: Implement _cef_process_message_t
    #   # TODO: Look at cef_process_id_t
    #   puts "Received a message..."
    #   true
    # end
    client
  end
end

def run(command_line_args)
    puts "Invoked with..." + command_line_args.to_s + "\n\n"

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

    settings = cefSettings();
    app = CefLifeCycle.cefApp;
    puts "About to execute..."
    exitCode = CefLifeCycle.cef_execute_process(mainArgs, app);
    puts "Exit Code = " + exitCode.to_s
    return exitCode if exitCode >= 0

    Gtk.gtk_init(0, nil);
    result = CefLifeCycle.cef_initialize(mainArgs, settings, app);
    top = Gtk.gtk_window_new(:GTK_WINDOW_TOPLEVEL);
    vbox = Gtk.gtk_vbox_new(false, 0);
    window_info = CefLifeCycle::WindowInfo.new;

    window_info[:parent_widget] = vbox;


    browser_settings = browserSettings();
    url = "http://google.com";

    client = CefLifeCycle.cefClient;

    puts("CEF Initialisation: " + result.to_s);
    worked = CefLifeCycle.cef_browser_host_create_browser_sync(window_info, client, CefLifeCycle.cefString(url), browser_settings);
    # puts "Blahahahahahah"
    Gtk.gtk_container_add(top, vbox);
    Gtk.gtk_widget_show(top);
    puts("Browser address=" + worked.to_s + "*********************************************");
    # Gtk.gtk_main();
    puts "Blahahaha ****************************************1"
    CefLifeCycle.cef_run_message_loop();
    # CefLifeCycle.cef_do_message_loop_work();
    puts "Blahahaha ****************************************2"
    # CefLifeCycle.cef_shutdown();
    puts "Blahahaha ****************************************3"
end

def cefSettings
    locales_dir_path = "/home/avishek/Code/chromium-tar/home/src_tarball/tarball/chromium/src/cef/binary_distrib/cef_binary_3.1339.959_linux/Debug/locales";
    resources_dir_path = "/home/avishek/Code/chromium-tar/home/src_tarball/tarball/chromium/src/cef/binary_distrib/cef_binary_3.1339.959_linux/Debug";

    settings = CefLifeCycle::CefSettings.new
    settings[:size] = 1000

    settings[:single_process] = true
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
  browser_settings[:size] = 1000

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
  browser_settings[:local_storage_disabled] = true
  browser_settings[:databases_disabled] = true
  browser_settings[:application_cache_disabled] = false
  browser_settings[:webgl_disabled] = true
  browser_settings[:accelerated_compositing_disabled] = true
  browser_settings[:accelerated_layers_disabled] = true
  browser_settings[:accelerated_video_disabled] = true
  browser_settings[:accelerated_2d_canvas_disabled] = true
  browser_settings[:accelerated_plugins_disabled] = true
  browser_settings[:developer_tools_disabled] = true

  return browser_settings;
end



# run(["Soething"]);
