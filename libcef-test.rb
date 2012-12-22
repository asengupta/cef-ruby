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
  enum :GtkWindowType, [
    :GTK_WINDOW_TOPLEVEL,
    :GTK_WINDOW_POPUP
  ];
  ffi_lib("/home/avishek/Code/chromium-tar/home/src_tarball/tarball/chromium/src/cef/binary_distrib/cef_binary_3.1339.959_linux/Debug/lib.target/libcef.so");
  attach_function(:cef_do_message_loop_work, [], :void);
  attach_function(:cef_browser_host_create_browser_sync, [:pointer, :pointer, :pointer, :pointer], :pointer);
  attach_function(:cef_browser_host_create_browser, [:pointer, :pointer, :pointer, :pointer], :pointer);
  attach_function(:cef_initialize, [:pointer, :pointer, :pointer], :int);
  attach_function(:cef_string_ascii_to_utf16, [:string, :size_t, :pointer], :int);
  attach_function(:gtk_window_new, [:GtkWindowType], :pointer);
  attach_function(:gtk_drawing_area_new, [], :pointer);
  attach_function(:gtk_init, [:int, :pointer], :void);
  attach_function(:gtk_container_add, [:pointer, :pointer], :void);
  attach_function(:gtk_widget_show, [:pointer], :void);
  attach_function(:gtk_main, [], :void);

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

  class BrowserSettings < FFI::Struct
    layout :size, :size_t,
          :standard_font_family, :pointer,
          :fixed_font_family, :pointer,
          :serif_font_family, :pointer,
          :sans_serif_font_family, :pointer,
          :cursive_font_family, :pointer,
          :fantasy_font_family, :pointer,
          :default_font_size, :int,
          :default_fixed_font_size, :int,
          :minimum_font_size, :int,
          :minimum_logical_font_size, :int,
          :remote_fonts_disabled, :bool,
          :default_encoding, :pointer,
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
          :user_style_sheet_location, :pointer,
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

  class CefContextMenuHandler
    layout :base, CefBase,
          :on_before_context_menu, :pointer,
          :on_context_menu_command, :pointer,
          :on_context_menu_dismissed, :pointer
  end

  class CefDialogHandler
    layout :base, CefBase,
          :on_file_dialog, :pointer
  end

  class CefDisplayHandler
    layout :base, CefBase,
          :on_loading_state_change, :pointer,
          :on_address_change, :pointer,
          :on_title_change, :pointer,
          :on_tooltip, :pointer,
          :on_status_message, :pointer,
          :on_console_message, :pointer
  end

  class CefDownloadHandler
    layout :base, CefBase,
          :on_before_download, :pointer,
          :on_download_updated, :pointer
  end

  class CefFocusHandler
    layout :base, CefBase,
          :on_take_focus, :pointer,
          :on_set_focus, :pointer,
          :on_got_focus, :pointer
  end

  class CefGeolocationHandler
    layout :base, CefBase,
          :on_request_geolocation_permission, :pointer,
          :on_cancel_geolocation_permission, :pointer
  end

  class CefJavascriptDialogHandler
    layout :base, CefBase,
          :on_jsdialog, :pointer,
          :on_before_unload_dialog, :pointer,
          :on_reset_dialog_state, :pointer
  end

  class CefKeyboardHandler
    layout :base, CefBase,
          :on_pre_key_event, :pointer,
          :on_key_event, :pointer
  end

  class CefLifeSpanHandler
    layout :base, CefBase,
          :on_before_popup, :pointer,
          :on_after_created, :pointer,
          :run_modal, :pointer,
          :do_close, :pointer,
          :on_before_close, :pointer
  end

  class CefLoadHandler
    layout :base, CefBase,
          :on_load_start, :pointer,
          :on_load_end, :pointer,
          :on_load_error, :pointer,
          :on_render_process_terminated, :pointer,
          :on_plugin_crashed, :pointer
  end

  class CefRenderHandler
    layout :base, CefBase,
          :get_root_screen_rect, :pointer,
          :get_view_rect, :pointer,
          :get_screen_point, :pointer,
          :on_popup_show, :pointer,
          :on_popup_size, :pointer,
          :on_paint, :pointer,
          :on_cursor_change, :pointer
  end

  class CefRequestHandler
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
          :_cef_context_menu_handler_t, CefContextMenuHandler,
          :_cef_dialog_handler_t, CefDialogHandler,
          :_cef_display_handler_t, CefDisplayHandler,
          :_cef_download_handler_t, CefDownloadHandler,
          :_cef_focus_handler_t, CefFocusHandler,
          :_cef_geolocation_handler_t, CefGeolocationHandler,
          :_cef_jsdialog_handler_t, CefJavascriptDialogHandler,
          :_cef_keyboard_handler_t, CefKeyboardHandler,
          :_cef_life_span_handler_t, CefLifeSpanHandler,
          :_cef_load_handler_t, CefLoadHandler,
          :_cef_render_handler_t, CefRequestHandler,
          :_cef_request_handler_t, CefRequestHandler,
          :on_process_message_received, :pointer
  end
end

require 'gtk2'

class RubyApp

    def initialize
        MyLibrary.gtk_init(0, nil)
        top = MyLibrary.gtk_window_new(:GTK_WINDOW_TOPLEVEL);
        area = MyLibrary.gtk_drawing_area_new();
        MyLibrary.gtk_container_add(top, area);
        mainArgs = MyLibrary::MainArgs.new;
        mainArgs[:argc] = 0;
        mainArgs[:argv] = LibC.malloc(0);
        settings = MyLibrary::CefSettings.new;
        client = MyLibrary::CefClient.new;
        client[:_cef_context_menu_handler_t] = FFI::Function()
        browser_settings = MyLibrary::BrowserSettings.new;
        window_info = MyLibrary::WindowInfo.new;

        window_info[:widget] = area;
        window_info[:parent_widget] = top;

        locales_dir_path = "/home/avishek/Code/chromium-tar/home/src_tarball/tarball/chromium/src/cef/binary_distrib/cef_binary_3.1339.959_linux/Debug/locales";
        resources_dir_path = "/home/avishek/Code/chromium-tar/home/src_tarball/tarball/chromium/src/cef/binary_distrib/cef_binary_3.1339.959_linux/Debug";
        url = "http://google.com";

        settings[:locales_dir_path] = MyLibrary.cefString(locales_dir_path);
        settings[:resources_dir_path] = MyLibrary.cefString(resources_dir_path);
        # settings[:command_line_args_disabled] = true;
        app = MyLibrary::CefApp.new;
        result = MyLibrary.cef_initialize(mainArgs, settings, nil);
        puts("Result: " + result.to_s);
        worked = MyLibrary.cef_browser_host_create_browser(MyLibrary::WindowInfo.new, client, MyLibrary.cefString(url), browser_settings);
        MyLibrary.gtk_widget_show(area);
        MyLibrary.gtk_widget_show(top);
        MyLibrary.gtk_main();
    end
end

window = RubyApp.new
