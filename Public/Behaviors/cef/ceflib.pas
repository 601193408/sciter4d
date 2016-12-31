(*
 *                       Delphi Chromium Embedded 3
 *
 * Usage allowed under the restrictions of the Lesser GNU General Public License
 * or alternatively the restrictions of the Mozilla Public License 1.1
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * Unit owner : Henri Gourvest <hgourvest@gmail.com>
 * Web site   : http://www.progdigy.com
 * Repository : http://code.google.ctom/p/delphichromiumembedded/
 * Group      : http://groups.google.com/group/delphichromiumembedded
 *
 * Embarcadero Technologies, Inc is not permitted to use or redistribute
 * this source code without explicit permission.
 *
 *)

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
unit ceflib;
{$IFNDEF CPUX64}
  {$ALIGN ON}
  {$MINENUMSIZE 4}
{$ENDIF}
{$I cef.inc}

interface
uses
{$IFDEF DELPHI14_UP}
  Rtti, TypInfo, Variants, Generics.Collections,
{$ENDIF}
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
  Messages,
{$ENDIF}
  SysUtils, Classes, Math, SyncObjs
{$IFDEF MSWINDOWS}
  , Windows
{$ENDIF}
{$IFNDEF FPC}
{$ENDIF}
  ;

type
{$IFDEF UNICODE}
  ustring = type string;
  rbstring = type RawByteString;
{$ELSE}
  {$IFDEF FPC}
    {$if declared(unicodestring)}
      ustring = type unicodestring;
    {$else}
      ustring = type WideString;
    {$ifend}
  {$ELSE}
    ustring = type WideString;
  {$ENDIF}
  rbstring = type AnsiString;
{$ENDIF}

{$if not defined(UInt64)}
  UInt64 = Int64;
{$ifend}

{$ifndef DELPHI16_UP}
  NativeUInt = Cardinal;
  PNativeUInt = ^NativeUInt;
  NativeInt = Integer;
{$endif}

  TCefWindowHandle = {$IFDEF MACOS}Pointer{$ELSE}HWND{$ENDIF};
  TCefCursorHandle = {$IFDEF MACOS}Pointer{$ELSE}HCURSOR{$ENDIF};
  TCefEventHandle  = {$IFDEF MACOS}Pointer{$ELSE}PMsg{$ENDIF};
  TCefTextInputContext = Pointer;
  TCefPlatformThreadId = DWORD;
  TCefPlatformThreadHandle = DWORD;

const
  kNullCursorHandle = 0;
  kNullEventHandle = 0;
  kNullWindowHandle = 0;

type
  {
    CEF�ṩ��UTF-8��UTF-16��UTF-32�ַ�����ת������
    CEF���ַ�����"��"�ڶ��߳����ǰ�ȫ�ģ���"д"����
    �����Ҫ�ڶ��߳����޸�CEF���ַ�������ʹ������Ҫ�������ͬ������
  }

  {
    CEF�ַ�����  wchat_t������Windows����2�ֽڣ�������ƽ̨��4�ֽ�
  }
  Char16 = WideChar;
  PChar16 = PWideChar;

  //32λARGB��ɫֵ, ��Ԥ��������ɫ������һ����֪˳��������ϣ��ȼ���SkColor����
  PCefColor = ^TCefColor;
  TCefColor = Cardinal;


  // ����color��Alphaֵ
  function CefColorGetA(color: TCefColor): Byte;  //(((color) >> 24) & 0xFF)
  // ����color��Redֵ
  function CefColorGetR(color: TCefColor): byte;  //(((color) >> 16) & 0xFF)
  // ����color��Greenֵ
  function CefColorGetG(color: TCefColor): Byte;  //(((color) >>  8) & 0xFF)
  // ����color��Blueֵ
  function CefColorGetB(color: TCefColor): Byte;  //(((color) >>  0) & 0xFF)

  // ��ָ����ɫ�������Ϊһ��cef_color_t��ɫֵ
  function CefColorSetARGB(a, r, g, b: Byte): TCefColor;
  //      static_cast<cef_color_t>( \
  //          (static_cast<unsigned>(a) << 24) | \
  //          (static_cast<unsigned>(r) << 16) | \
  //          (static_cast<unsigned>(g) << 8) | \
  //          (static_cast<unsigned>(b) << 0))

  // ������int32ֵ��ϳ�һ��int64ֵ
  function CefInt64Set(int32_low, int32_high: Integer): Int64;
  //      static_cast<int64>((static_cast<uint32>(int32_low)) | \
  //          (static_cast<int64>(static_cast<int32>(int32_high))) << 32)

  // ����int64ֵ��λ��int32ֵ
  function CefInt64GetLow(const int64_val: Int64): Integer; // static_cast<int32>(int64_val)
  // ����int64ֵ��λ��int32ֵ
  function CefInt64GetHigh(const int64_val: Int64): Integer;
  //    static_cast<int32>((static_cast<int64>(int64_val) >> 32) & 0xFFFFFFFFL)

type
  {
    CEF�ַ������Ͷ���
    ʹ�����ڷ�����|str|������ṩ��Ӧ��|dtor|��ʵ���������ַ������ͷš�
    ������һ���Ѵ��ڵ��ַ�����¼ʱ���������µ�|str|��|dtor|��ֵǰ��Ҫȷ��Ϊ�ɵ�|str|����|dtor|
    ��̬�ַ�����|dtor|ֵΪNULL
    ��������Լ�������Щ������ʹ�������һЩ����
  }
  PCefStringWide = ^TCefStringWide;
  TCefStringWide = record
    str: PWideChar;
    length: NativeUInt;
    dtor: procedure(str: PWideChar); stdcall;
  end;

  PCefStringUtf8 = ^TCefStringUtf8;
  TCefStringUtf8 = record
    str: PAnsiChar;
    length: NativeUInt;
    dtor: procedure(str: PAnsiChar); stdcall;
  end;

  PCefStringUtf16 = ^TCefStringUtf16;
  TCefStringUtf16 = record
    str: PChar16;
    length: NativeUInt;
    dtor: procedure(str: PChar16); stdcall;
  end;


  {
    ����ϵͳ��˵��"�����ַ�����¼ʱԤ���û����ͷ���"��ʱ���Ǳ�Ҫ�ġ�
    �������ЩUserFree������������ΪҪ���û��Լ����ͷ���Щ�ṹ�����ʾ
  }

  PCefStringUserFreeWide = ^TCefStringUserFreeWide;
  TCefStringUserFreeWide = type TCefStringWide;

  PCefStringUserFreeUtf8 = ^TCefStringUserFreeUtf8;
  TCefStringUserFreeUtf8 = type TCefStringUtf8;

  PCefStringUserFreeUtf16 = ^TCefStringUserFreeUtf16;
  TCefStringUserFreeUtf16 = type TCefStringUtf16;

{$IFDEF CEF_STRING_TYPE_UTF8}
  TCefChar = AnsiChar;
  PCefChar = PAnsiChar;
  TCefStringUserFree = TCefStringUserFreeUtf8;
  PCefStringUserFree = PCefStringUserFreeUtf8;
  TCefString = TCefStringUtf8;
  PCefString = PCefStringUtf8;
{$ENDIF}

{$IFDEF CEF_STRING_TYPE_UTF16}
  TCefChar = Char16;
  PCefChar = PChar16;
  TCefStringUserFree = TCefStringUserFreeUtf16;
  PCefStringUserFree = PCefStringUserFreeUtf16;
  TCefString = TCefStringUtf16;
  PCefString = PCefStringUtf16;
{$ENDIF}

{$IFDEF CEF_STRING_TYPE_WIDE}
  TCefChar = WideChar;
  PCefChar = PWideChar;
  TCefStringUserFree = TCefStringUserFreeWide;
  PCefStringUserFree = PCefStringUserFreeWide;
  TCefString = TCefStringWide;
  PCefString = PCefStringWide;
{$ENDIF}

  {
    CEF�ַ������Գ���Ϊǰ׺�ġ���NULL��β�Ŀ��ַ�����������΢���BSTR���͡�
    ʹ��������ЩAPI���������䡢������ͷ�CEF�ַ���
  }

  // CEF�ַ���Mapӳ��� Ϊkey/value�ļ�ֵ�� 
  TCefStringMap = Pointer;

  // CEF�ַ���Multimapsӳ��� Ϊkey/value�ļ�ֵ�� ����Ϊ���������ö��ֵ
  TCefStringMultimap = Pointer;

  // CEF�ַ���Multimapsӳ��� Ϊkey/value��ֵ�Եļ��� 
  TCefStringList = Pointer;

//---------------------------------------------------------------------

  //CefExecuteProcess�����Ĳ����ṹ��
  PCefMainArgs = ^TCefMainArgs;
  TCefMainArgs = record
    instance: HINST;
  end;

  // ������Ϣ�ṹ��
  PCefWindowInfo = ^TCefWindowInfo;
{$IFDEF MACOS}
  TCefWindowInfo = record
    m_windowName: TCefString;   //< ������
    m_x: Integer;               //< X����
    m_y: Integer;               //< Y����
    m_nWidth: Integer;          //< ���
    m_nHeight: Integer;         //< �߶�
    m_bHidden: Integer;         //< �Ƿ�����

    // ����ͼ��NSViewָ��
    m_ParentView: TCefWindowHandle;
    // �������ͼ��NSViewָ��
    m_View: TCefWindowHandle;
  end;
{$ENDIF}

{$IFDEF MSWINDOWS}
  TCefWindowInfo = record
    // CreateWindowEx��Ҫ�ı�׼���� 
    ex_style: DWORD;
    window_name: TCefString;
    style: DWORD;
    x: Integer;
    y: Integer;
    width: Integer;
    height: Integer;
    parent_window: HWND;
    menu: HMENU;

    {
      Ϊtrue(1)ʱ������һ���޴���(����)��Ⱦ����ʱ������Ϊ������������ڣ���������
      ����Ⱦ����ͨ��CefRenderHandler�ӿ���������|parent_window|ֵ�����ڱ�ʶ������
      ��Ϣ����Ϊ�Ի��������Ĳ˵��ȵĸ����ڡ����|parent_window|δ�ṩ����ʹ��
      ��������������һЩ��Ҫ�����ڵĹ��ܽ�������ȷʹ�á�Ҫ����һ���޴����������
      CefSettings.windowless_rendering_enabledҲ��������Ϊtrue��
    }
    windowless_rendering_enabled: Integer;

    {
      Ϊtrue(1)ʱ��Ϊ�޴�����Ⱦ����͸�����Ʒ�ʽ������ʹ��(RGBA=0x00000000)͸������ɫ��
      Ϊfalse(0)ʱ������ɫ��Ϊ��ɫ�Ҳ�͸��
    }
    transparent_painting_enabled: Integer;

    // ����������ڵľ���������ڴ�����Ⱦ
    window: HWND ;
  end;
{$ENDIF}

  // ��־���س̶ȵȼ�
  TCefLogSeverity = (
    // Ĭ����־(��ǰ��INFO��־)
    LOGSEVERITY_DEFAULT,
    // ��ϸ��־
    LOGSEVERITY_VERBOSE,
    // ��Ϣ��־ 
    LOGSEVERITY_INFO,
    // ������־
    LOGSEVERITY_WARNING,
    // ������־
    LOGSEVERITY_ERROR,
    // ��ȫ������־
    LOGSEVERITY_DISABLE = 99
  );

  //����һ��"����"״̬
  TCefState = (
    // ʹ��Ĭ�ϵ�"����"״̬
    STATE_DEFAULT = 0,
    // ʹ������"����"
    STATE_ENABLED,
    // ���û�����"����"
    STATE_DISABLED
  );

  {
    ��ʼ�����á�
    ָ��NULL��0�õ��Ƽ���Ĭ��ֵ����Щ��Ϣ������������Ҳ����ʹ�������п��������á�
  }
  PCefSettings = ^TCefSettings;
  TCefSettings = record
    // ����ṹ��ĳߴ�
    size: NativeUInt;

    {
      ����Ϊtrue��1��Ϊ���������Ⱦ��ʹ�õ����̡�
      ��������ģʽ����Chromium�ٷ�֧�֣��ұ�Ĭ�ϵĶ���̲��ȶ���
      ��ȻҲ��ʹ��������ʹ��"single-process"������
    }
    single_process: Integer;

    {
      ����ΪTrue  (1)ʱ�������ӽ��̵�ɳ�䡣�μ�cef_sandbox_win.h��
      ��ȻҲ��ʹ��������ʹ��"no-sandbox"������
    }
    no_sandbox: Integer;

    {  Ϊ�ӽ���ʹ�ò�ͬ��ִ���ļ�
      ������Ϊ�ӽ��̵�һ�������Ŀ�ִ�г����·����
      Ĭ�������ʹ����������̿�ִ�г��򣬼�cefexecuteprocess()��ϸ˵����
      ��ȻҲ��ʹ��������ʹ��"browser-subprocess-path"������
    }
    browser_subprocess_path: TCefString;

    {
      ����ΪTrue  (1)ʱ����һ���������߳���������������̵���Ϣѭ����
      ���ΪFalse (0)ʱ��CefDoMessageLoopWork()������������Լ���Ӧ�ó������Ϣѭ���б����á�
    }
    multi_threaded_message_loop: Integer;

    {
      ����ΪTrue  (1)ʱ�������޴���(����)��Ⱦ��
      ���������Ҫ������Ⱦʱ������ֵΪfalse(0)����Ϊ��ĳЩϵͳ�п��ܻ�Ӱ������
    }
    windowless_rendering_enabled: Integer;

    {
      ����Ϊtrue��1��,��ֹʹ�ñ�׼��CEF�������в������������������������
      ������Ȼ����ʹ��CEF�����ݽṹ��ͨ��CefApp::OnBeforeCommandLineProcessing()����
    }
    command_line_args_disabled: Integer;

    {
      ���������ݴ�ŵ������ϵ�λ�á�
      ���Ϊ�գ����ΪһЩ����ʹ���ڴ滺�棬Ϊ������ʹ��һ����ʱ�Ĵ��̻��档
      ���ָ���˻���·������localStorage��HTML5���ݿ�ֻ���ڻỰ�б��֡�
    }
    cache_path: TCefString;

    // The location where user data such as spell checking dictionary files will
    // be stored on disk. If empty then the default platform-specific user data
    // directory will be used ("~/.cef_user_data" directory on Linux,
    // "~/Library/Application Support/CEF/User Data" directory on Mac OS X,
    // "Local Settings\Application Data\CEF\User Data" directory under the user
    // profile directory on Windows).
    user_data_path: TCefString;

    {
      ���ֻỰcookies(cookiesû�н�ֹ���ڻ�����Чʱ����)��
      Ĭ�������ʹ��ȫ�ֵ�cookie���������������ֵΪtrue��
      �Ựcookieһ���Ƕ���Ϊ���ݵģ��������վ��������������ǡ�
      ��Ҫ�����˹��ܣ�|cache_path|ֵҲ���뱻ָ�����ô˹��ܡ�
      ��ȻҲ��ʹ��������ʹ��"browser-subprocess-path"������
      Ҳ��ʹ��"persist-session-cookies"�����п��ء�
    }
    persist_session_cookies: Integer;

    {
       ���ᱻ��Ϊ�û�����(User-Agent) HTTPͷ���ص�ֵ��
       ���Ϊ�գ�Ĭ������»�ʹ��User-Agent�ַ�����
       Ҳ��ʹ��"user-agent"���������á�
    }
    user_agent: TCefString;

    {
      Ĭ�ϵ��û�����(User-Agent)�ַ�������Ϊ��Ʒ��һ���ֵ�ֵ��
      ���Ϊ�գ����ʹ��Chromium�Ĳ�Ʒ�汾��Ϣ��
      ���|userAgent|ָ����ֵ��ᱻ���ԡ�
      Ҳ��ʹ��"product-version"����������
    }
    product_version: TCefString;

    {
      ���ᴫ�ݸ�WebKit�ı��ػ��ַ�����
      ���Ϊ�գ���Ĭ�������locale��Ϊ"en-US"��
      ��Linux�и�ֵ�������ԣ�������LANGUAGE��LC_ALL��LC_MESSAGES��������������˳�������
      Ҳ��ʹ��"lang"����������
    }
    locale: TCefString;

    {
      ������־ʹ�õ�Ŀ¼���ļ�����
      ���Ϊ�գ���Ĭ�����������Ϊ"debug.log"���ļ���д����ǰӦ�ó���Ŀ¼�¡�
      Ҳ��ʹ��"log-file"����������
    }
    log_file: TCefString;

    {
      ��־�����ز㼶��ֻ�б�������ؼ������ߵ���Ϣ���ᱻ��¼
    }
    log_severity: TCefLogSeverity;

    {
      ��ʼ��V8 JavaScript����ʱʹ�õ��Զ����ǡ�
      ʹ���Զ����� ����δ���ܺõĲ��Թ���
      Ҳ��ʹ��"js-flags"����������
    }
    javascript_flags: TCefString;

    {

      ��ȫ�޶�·������ԴĿ¼��
      �����ֵΪ�գ���cef.pak��(��)devtools_resources.pak�ļ�����λ��ģ��Ŀ¼��(Windows/Linux)
      ����Ӧ�ó��������ԴĿ¼(MAC OS X)�¡�
      Ҳ��ʹ��"resources-dir-path"����������
    }
    resources_dir_path: TCefString;

    {
      ��ȫ�޶�·���ı��ػ�Ŀ¼��
      �����ֵΪ�գ��򱾵ػ�Ŀ¼����λ�ڵ�ǰģ��Ŀ¼��
      ��Mac OS Xϵͳ�У�pack�ļ����Ǵ�Ӧ�ó��������ԴĿ¼�м��أ���ֵ�������ԡ�
      Ҳ��ʹ��"locales-dir-path"����������
    }
    locales_dir_path: TCefString;

    { ���ð�����
      ����ΪTrue(1)ʱ������Ϊ��Դ�ͱ��ػ�����pack�ļ���
      ������pack�ļ�������ʱ�������������Ⱦ����ͨ��CefApp::GetResourceBundleHandler()����ʱ�������ṩһ����Դ����������
      Ҳ��ʹ��"disable-pack-loading"����������
    }
    pack_loading_disabled: Integer;

    {
     ����Ϊ1024��65535֮���һ��ֵ ��ָ������Զ�̵���ָ���Ķ˿ڡ�
     ���磬���ָ���˶˿�Ϊ8080����Զ�̵��Ե�URLΪhttp://localhost:8080��
     CEF����Զ�̵����κ�CEF��Chrome��������ڡ�
     Ҳ��ʹ��"remote-debugging-port"����������
    }
    remote_debugging_port: Integer;

    {
      
      ����"δ�����쳣"�Ķ�ջ���ٿ�ܵ���Ŀ��
      ָ������0��ֵ������CefV8ContextHandler::OnUncaughtException()�ص��¼���
      ָ��0(Ĭ��)����OnUncaughtException()�¼����ᱻ���á�
      Ҳ��ʹ��"uncaught-exception-stack-size"����������
    }
    uncaught_exception_stack_size: Integer;

    {
      Ĭ������£�����ӵ�е������ı��ͷź�CEF V8�����ý�ʧЧ(IsValid()��������false)��
      ���������Ҫ����ļ�¼�ұ�������ص��������ѱ��ͷź�ʹ��V8���õ��µ��¹ʡ�

      ���ڣ�CEF�ṩ�����ְ�ȫ�Ĳ�ͬ�������Ե�������ʵ�֡�
      Ĭ�ϵ�ʵ��(ֵΪ0)ʹ��һ����ϣֵӳ�������С�����������Ļ�����ӵ�и��õ����ܡ�
      ��һ�ֿ�ѡ��ʵ��(ֵΪ1)ʹ��һ�����ӵ�ÿ���������ϵ�����ֵ�����ڴ������������Ļ�����ӵ�и��õ����ܡ�

      �ڴ���V8����ʱ������ƻ��ֶ�������������������ʱ���������Ҫ���õ����ܣ�
      ��������ø�ֵΪ-1�����������İ�ȫ��
      Ҳ��ʹ��"context-safety-implementation"����������
    }
    context_safety_implementation: Integer;

    {
       ����֤�����
       ����Ϊtrue(1)ʱ��������Ч��SSL֤����ش���
       ���ø����ÿ��ܵ���Ǳ�ڵİ�ȫ©������"�м���"������
       Ӧ�ó���������ϼ�������ʱ��Ӧ�����ø�ѡ�
       Ҳ��ʹ��"ignore-certificate-errors"����������
    }
    ignore_certificate_errors: Integer;

    {
      �������ݵı���͸��ɫ��Ĭ������£�����ɫΪ��ɫ��ֵ��ֻ��RGB������ʹ��
      alpha�����������0�������ֵ������
    }
    background_color: TCefColor;

    // Comma delimited ordered list of language codes without any whitespace that
    // will be used in the "Accept-Language" HTTP header. May be overridden on a
    // per-browser basis using the CefBrowserSettings.accept_language_list value.
    // If both values are empty then "en-US,en" will be used. Can be overridden
    // for individual CefRequestContext instances via the
    // CefRequestContextSettings.accept_language_list value.
    accept_language_list: TCefString;
  end;

  // Request context initialization settings. Specify NULL or 0 to get the
  // recommended default values.
  PCefRequestContextSettings = ^TCefRequestContextSettings;
  TCefRequestContextSettings = record
    // Size of this structure.
    size: NativeUInt;

    // The location where cache data will be stored on disk. If empty then
    // browsers will be created in "incognito mode" where in-memory caches are
    // used for storage and no data is persisted to disk. HTML5 databases such as
    // localStorage will only persist across sessions if a cache path is
    // specified. To share the global browser cache and related configuration set
    // this value to match the CefSettings.cache_path value.
    cache_path: TCefString;

    // To persist session cookies (cookies without an expiry date or validity
    // interval) by default when using the global cookie manager set this value to
    // true. Session cookies are generally intended to be transient and most Web
    // browsers do not persist them. Can be set globally using the
    // CefSettings.persist_session_cookies value. This value will be ignored if
    // |cache_path| is empty or if it matches the CefSettings.cache_path value.
    persist_session_cookies: Integer;

    // Set to true (1) to ignore errors related to invalid SSL certificates.
    // Enabling this setting can lead to potential security vulnerabilities like
    // "man in the middle" attacks. Applications that load content from the
    // internet should not enable this setting. Can be set globally using the
    // CefSettings.ignore_certificate_errors value. This value will be ignored if
    // |cache_path| matches the CefSettings.cache_path value.
    ignore_certificate_errors: Integer;

    // Comma delimited ordered list of language codes without any whitespace that
    // will be used in the "Accept-Language" HTTP header. Can be set globally
    // using the CefSettings.accept_language_list value or overridden on a per-
    // browser basis using the CefBrowserSettings.accept_language_list value. If
    // all values are empty then "en-US,en" will be used. This value will be
    // ignored if |cache_path| matches the CefSettings.cache_path value.
    accept_language_list: TCefString;
  end;

  {
    Cef�������ʼ��������Ϣ��
    ָ��ΪNULL��0�������Ƽ���Ĭ��ֵ��
    ʹ���Զ���ֵ�Ľ������δ���ܺõĲ��Թ���
    ��Щ��Ϣ������һЩ����Ҳ����ͨ�������в���������
  }
  PCefBrowserSettings = ^TCefBrowserSettings;
  TCefBrowserSettings = record
    // �ýṹ��ĳߴ�
    size: NativeUInt;

    // ���޴����������CefRenderHandler::OnPaintÿ�뱻���õ�֡����
    // ��������������������ʣ���ʵ��fps���ܵ��ڸ�ֵ��
    // ��СֵΪ1�����ֵΪ60(Ĭ��30)
    windowless_frame_rate: Integer;

    // �����ֵӳ�䵽webpreferences����������

    // ��������.
    standard_font_family: TCefString;
    fixed_font_family: TCefString;
    serif_font_family: TCefString;
    sans_serif_font_family: TCefString;
    cursive_font_family: TCefString;
    fantasy_font_family: TCefString;
    default_font_size: Integer;
    default_fixed_font_size: Integer;
    minimum_font_size: Integer;
    minimum_logical_font_size: Integer;

    {
      Ĭ�ϵ�Web���ݱ��룬���Ϊ�գ���ֵΪ"ISO-8859-1"��
      Ҳ��ʹ��"default-encoding"����������
    }
    default_encoding: TCefString;

    {
      ���ƴ�Զ��Դ�м������塣
      Ҳ��ʹ��"disable-remote-fonts"����������
    }
    remote_fonts: TCefState;

    {
      ����JavaScript�Ƿ�ɱ�ִ�С�
      Ҳ��ʹ��"disable-javascript"����������
    }
    javascript: TCefState;

    {
      ����JavaScript�Ƿ�������ڴ򿪴�����
      Ҳ��ʹ��"disable-javascript-open-windowst"����������
    }
    javascript_open_windows: TCefState;

    {
      ����JavaScript�Ƿ���Թرշ�ͨ��JavaScript�򿪵Ĵ��ڡ�
      JavaScript��Ȼ���Թر���JavaScript�򿪵Ĵ��ڡ�
      Ҳ��ʹ��"disable-javascript-close-windows"����������
    }
    javascript_close_windows: TCefState;

    {
      ����JavaScript�Ƿ���Է��ʼ��а塣
      Ҳ��ʹ��"disable-javascript-access-clipboard"����������
    }
    javascript_access_clipboard: TCefState;

    {
      �����Ƿ�֧���ڱ༭����ͨ��execCommand("paste")������DOMճ��
      ��������ã���|javascript_access_clipboard|����Ҳ�������á�
      Ҳ��ʹ��"disable-javascript-dom-paste"����������
    }
    javascript_dom_paste: TCefState;

    {
       �����Ƿ����"����"����
       Ҳ��ʹ��"enable-caret-browsing"����������
    }
    caret_browsing: TCefState;

    {
      ����Java����Ƿ񱻼���
      ��ʹ��"disable-java"����������
    }
    java: TCefState;

    {
      �����Ƿ�������в��
      ��ʹ��"disable-plugins"����������
    }
    plugins: TCefState;

    {
      �����ļ�URL�Ƿ���Է�������URL
      ��ʹ��"allow-universal-access-from-files"����������
    }
    universal_access_from_file_urls: TCefState;

    {
      �����ļ�URL�Ƿ���Է��������ļ�URL��
      ��ʹ��"allow-access-from-files"����������
    }
    file_access_from_file_urls: TCefState;

    {
      �����Ƿ�ǿ��Web��ȫ���ƣ�ͬԴ���ԣ�
      ���Ƽ����ô����ã����������з��հ�ȫ��Ϊ�����վ��ű���XSS��
      ��ʹ��"disable-web-security"����������
    }
    web_security: TCefState;

    {
      ����ͼ��URL�Ƿ�������м��ء������Ҫ����Ȼ��ʹ�û���ͼ������Ⱦ��
      ��ʹ��"disable-web-security"����������
    }
    image_loading: TCefState;

    {
      ���ƶ�����ͼ���Ƿ����ŵ����ʵ�ҳ���С��
      ��ʹ��"image-shrink-standalone-to-fit"����������
    }
    image_shrink_standalone_to_fit: TCefState;

    {
      �����ı����Ƿ���Ե�����С
      ��ʹ��"disable-text-area-resize"����������
    }
    text_area_resize: TCefState;

    {
       ����Tab���Ƿ���Ծ۽����ӡ�
       ��ʹ��"disable-tab-to-links"����������
    }
    tab_to_links: TCefState;

    {
       �����Ƿ����ʹ�ñ��ش洢��
       ��ʹ��"disable-local-storage"����������
    }
    local_storage: TCefState;

    {
      �������ݿ��Ƿ����ʹ�á�
      ��ʹ��"disable-databases"����������
    }
    databases: TCefState;

    {
      ����Ӧ�ó��򻺴��Ƿ����ʹ��
      ��ʹ��"disable-application-cache"����������
    }
    application_cache: TCefState;

    {
      ����WebGL�Ƿ����ʹ�á�
      ��ע�⣬WebGL��ҪӲ��֧�֣��Ҽ�ʹӲ��֧�ֲ�����������ϵͳ���ܹ�������
      ��ʹ��"disable-webgl"����������
    }

    webgl: TCefState;

    {
      �ĵ����������ǰ��δָ���ĵ���ɫʱ�������ʹ�õĲ�͸������ɫ��
      Ĭ������£�����ɫ����CefSettings.background_color��ͬ����ʹ��RGB��ɫ������
      alpha�����������0�������ֵ��������
    }
    background_color: TCefColor;

    // Comma delimited ordered list of language codes without any whitespace that
    // will be used in the "Accept-Language" HTTP header. May be set globally
    // using the CefBrowserSettings.accept_language_list value. If both values are
    // empty then "en-US,en" will be used.
    accept_language_list: TCefString;
  end;

  // Return value types.
  TCefReturnValue = (
    // Cancel immediately.
    RV_CANCEL = 0,

    // Continue immediately.
    RV_CONTINUE,

    // Continue asynchronously (usually via a callback).
    RV_CONTINUE_ASYNC
  );

  // URL����ɲ���
  PCefUrlParts = ^TCefUrlParts;
  TCefUrlParts = record
    // ������URL�淶 
    spec: TCefString;
    // �ṹ����ɲ��֣�������ð�� (e.g. "http").
    scheme: TCefString;
    // �û����Ʋ���
    username: TCefString;
    // ���벿�� 
    password: TCefString;
    //�������֣������������������һ��IPv4��ַ �� �÷�������������IPv6��ַ˵�� (e.g., "[2001:db8::1]")
    host: TCefString;
    //�˿ں� ����
    port: TCefString;
    // ԭURL�е�scheme��host��port��������ݣ��൱��������û��������롢ʹ��"/"�滻��·����
    // �������·��֮����������ݣ��������һ����׼url����ֵΪ��
    origin: TCefString;

    // ·�����֣�������������ĵ�һ��б��
    path: TCefString;
    // ��ѯ�ַ��� ���� (����, '?'�ַ��������������).
    query: TCefString;
  end;

  TUrlParts = record
    spec: ustring;
    scheme: ustring;
    username: ustring;
    password: ustring;
    host: ustring;
    port: ustring;
    origin: ustring;
    path: ustring;
    query: ustring;
  end;

  // ʱ����Ϣ. ֵӦ������UTCʱ��
  PCefTime = ^TCefTime;
  TCefTime = record
    year: Integer;          // 4λ���� "2007"
    month: Integer;         // ����1���·� (ֵ 1 = һ��, �Դ�����)
    day_of_week: Integer;   // ����0������ (0 = ����, �Դ�����)
    day_of_month: Integer;  // ����1���·� (1-31)
    hour: Integer;          // ��ǰ���ڵ�"Сʱ"���� (0-23)
    minute: Integer;        // ��ǰСʱ��"����"���� (0-59)
    second: Integer;        // ��ǰ���ӵ�"��"���� (0-59 �������ԭ�������п��ܵ�60).
    millisecond: Integer;   // ��ǰ���"����"���� (0-999)
  end;

  // Cookie��Ϣ
  TCefCookie = record
    // Cookie����
    name: TCefString;
    // Cookieֵ
    value: TCefString;
    {
      ���|domain|Ϊ�գ����ᴴ��һ�� ����cookie ����� ��cookie��
      ��cookie�洢�ļ�����"."��Ϊǰ׺��������������cookie�Ƿ���ڣ��������ǿɼ��ġ�
    }
    domain: TCefString;
    // ���|path|��Ϊ�գ���ֻ���ڸ�·���µ�URL�ſ��Է���cookie
    path: TCefString;
    // ���|secure|Ϊtrue����cookie����HTTPS����ʱ�ű�����
    secure: Integer;
    // ���|httponly|Ϊtrue, ��cookie����HTTP����ʱ�ű�����
    httponly: Integer;
    // cookie�Ĵ������ڡ���ֵ�ڴ���cookieʱ��ϵͳ�Զ����õ�
    creation: TCefTime;
    // cookie������������ڡ���ֵ�ڷ���cookieʱ��ϵͳ�Զ����õ�
    last_access: TCefTime;
    // cookie�������ڣ�����|has_expires|Ϊtrueʱ��Ч
    has_expires: Integer;
    expires: TCefTime;
  end;

  // ������ֹ״ֵ̬
  TCefTerminationStatus = (
    // ��0����״̬
    TS_ABNORMAL_TERMINATION,
    // SIGKILL �� �������������ֹ
    TS_PROCESS_WAS_KILLED,
    // �ֶι���(Segmentation fault)
    TS_PROCESS_CRASHED
  );

  // ·����ֵ
  TCefPathKey = (
    // ��ǰĿ¼
    PK_DIR_CURRENT,
    // ����PK_FILE_EXE��Ŀ¼
    PK_DIR_EXE,
    // ����PK_FILE_MODULE��Ŀ¼
    PK_DIR_MODULE,
    // ��ʱĿ¼
    PK_DIR_TEMP,
    // ��ǰ��ִ�г����·�����ļ���
    PK_FILE_EXE,
    // ����CEF����(ͨ����libcefģ��)��·�����ļ���
    PK_FILE_MODULE,
    // "Local Settings\Application Data" directory under the user profile
    // directory on Windows.
    PK_LOCAL_APP_DATA,
    // "Application Data" directory under the user profile directory on Windows
    // and "~/Library/Application Support" directory on Mac OS X.
    PK_USER_DATA
  );

  // �洢����
  TCefStorageType = (
    //���ش洢
    ST_LOCALSTORAGE = 0,
    //Session�洢
    ST_SESSIONSTORAGE
  );

  // ֧�ֵĴ������ֵ�� �μ�net\base\net_error_list.h
  TCefErrorcode = Integer;

const
  ERR_NONE                            = 0;
  ERR_FAILED                          = -2;
  ERR_ABORTED                         = -3;
  ERR_INVALID_ARGUMENT                = -4;
  ERR_INVALID_HANDLE                  = -5;
  ERR_FILE_NOT_FOUND                  = -6;
  ERR_TIMED_OUT                       = -7;
  ERR_FILE_TOO_BIG                    = -8;
  ERR_UNEXPECTED                      = -9;
  ERR_ACCESS_DENIED                   = -10;
  ERR_NOT_IMPLEMENTED                 = -11;
  ERR_CONNECTION_CLOSED               = -100;
  ERR_CONNECTION_RESET                = -101;
  ERR_CONNECTION_REFUSED              = -102;
  ERR_CONNECTION_ABORTED              = -103;
  ERR_CONNECTION_FAILED               = -104;
  ERR_NAME_NOT_RESOLVED               = -105;
  ERR_INTERNET_DISCONNECTED           = -106;
  ERR_SSL_PROTOCOL_ERROR              = -107;
  ERR_ADDRESS_INVALID                 = -108;
  ERR_ADDRESS_UNREACHABLE             = -109;
  ERR_SSL_CLIENT_AUTH_CERT_NEEDED     = -110;
  ERR_TUNNEL_CONNECTION_FAILED        = -111;
  ERR_NO_SSL_VERSIONS_ENABLED         = -112;
  ERR_SSL_VERSION_OR_CIPHER_MISMATCH  = -113;
  ERR_SSL_RENEGOTIATION_REQUESTED     = -114;
  ERR_CERT_COMMON_NAME_INVALID        = -200;
  ERR_CERT_DATE_INVALID               = -201;
  ERR_CERT_AUTHORITY_INVALID          = -202;
  ERR_CERT_CONTAINS_ERRORS            = -203;
  ERR_CERT_NO_REVOCATION_MECHANISM    = -204;
  ERR_CERT_UNABLE_TO_CHECK_REVOCATION = -205;
  ERR_CERT_REVOKED                    = -206;
  ERR_CERT_INVALID                    = -207;
  ERR_CERT_END                        = -208;
  ERR_INVALID_URL                     = -300;
  ERR_DISALLOWED_URL_SCHEME           = -301;
  ERR_UNKNOWN_URL_SCHEME              = -302;
  ERR_TOO_MANY_REDIRECTS              = -310;
  ERR_UNSAFE_REDIRECT                 = -311;
  ERR_UNSAFE_PORT                     = -312;
  ERR_INVALID_RESPONSE                = -320;
  ERR_INVALID_CHUNKED_ENCODING        = -321;
  ERR_METHOD_NOT_SUPPORTED            = -322;
  ERR_UNEXPECTED_PROXY_AUTH           = -323;
  ERR_EMPTY_RESPONSE                  = -324;
  ERR_RESPONSE_HEADERS_TOO_BIG        = -325;
  ERR_CACHE_MISS                      = -400;
  ERR_INSECURE_RESPONSE               = -501;

type
  // The manner in which a link click should be opened.

  TCefWindowOpenDisposition = (
    WOD_UNKNOWN,
    WOD_SUPPRESS_OPEN,
    WOD_CURRENT_TAB,
    WOD_SINGLETON_TAB,
    WOD_NEW_FOREGROUND_TAB,
    WOD_NEW_BACKGROUND_TAB,
    WOD_NEW_POPUP,
    WOD_NEW_WINDOW,
    WOD_SAVE_TO_DISK,
    WOD_OFF_THE_RECORD,
    WOD_IGNORE_ACTION
  );

// ��ק(drag-and-drop)������Դ��Ŀ��Э���Ĳ�������("Verb")
// ��Щ������WebCore�е�DragActions.hƥ�䣬���Բ�Ҫ�����ǽ����޸�
  TCefDragOperation = (
    //DRAG_OPERATION_NONE    = 0;
    DRAG_OPERATION_COPY,
    DRAG_OPERATION_LINK,
    DRAG_OPERATION_GENERIC,
    DRAG_OPERATION_PRIVATE,
    DRAG_OPERATION_MOVE,
    DRAG_OPERATION_DELETE
    //DRAG_OPERATION_EVERY   = High(Cardinal);
  );
  TCefDragOperations = set of TCefDragOperation;

  // V8���ʿ�������
  TCefV8AccessControl = (
    //V8_ACCESS_CONTROL_DEFAULT               = 0;
    V8_ACCESS_CONTROL_ALL_CAN_READ,
    V8_ACCESS_CONTROL_ALL_CAN_WRITE,
    V8_ACCESS_CONTROL_PROHIBITS_OVERWRITING
  );
  TCefV8AccessControls = set of TCefV8AccessControl;

  // V8 property��������
  TCefV8PropertyAttribute = (
    //V8_PROPERTY_ATTRIBUTE_NONE       = 0;       // ��д, ��ö��, ������
    V8_PROPERTY_ATTRIBUTE_READONLY,  // ����д
    V8_PROPERTY_ATTRIBUTE_DONTENUM,  // ����ö��
    V8_PROPERTY_ATTRIBUTE_DONTDELETE // ��������
  );
  TCefV8PropertyAttributes = set of TCefV8PropertyAttribute;

const
  V8_PROPERTY_ATTRIBUTE_NONE = []; // ��д, ��ö��, ������

type
  // Post dataԪ�ص����ͣ������� �ֽ� �� �ļ� ����
  TCefPostDataElementType = (
    PDE_TYPE_EMPTY  = 0,
    PDE_TYPE_BYTES,
    PDE_TYPE_FILE
  );

  // һ���������Դ(Resource)����
  TCefResourceType = (
    // ����ҳ(��ҳ/����ҳ)
    RT_MAIN_FRAME,
    // Frame �� iframe
    RT_SUB_FRAME,
    // CSS ��ʽ��
    RT_STYLESHEET,
    // �ⲿ�ű�
    RT_SCRIPT,
    // ͼ�� (jpg/gif/png/etc)
    RT_IMAGE,
    // ����
    RT_FONT_RESOURCE,
    // ��������Դ������δ֪������Դ��Ĭ������
    RT_SUB_RESOURCE,
    // һ�������Object(��embed)��ǩ, ��һ������������Դ
    RT_OBJECT,
    // ý����Դ
    RT_MEDIA,
    // һ��ר���߳�(worker)������Դ
    RT_WORKER,
    // һ�������߳�(worker)������Դ
    RT_SHARED_WORKER,
    // ��ȷ��Ԥ������Դ
    RT_PREFETCH,
    // ͼ��
    RT_FAVICON,
    // XMLHttpRequest.
    RT_XHR,
    // һ��<ping>����
    RT_PING,
    // һ�������̵߳�����Դ
    RT_SERVICE_WORKER
  );


  // ����Ĺ���(Transition)����, ��һ�� Դֵ �� 0����������ֵ ���
  TCefTransitionType = Cardinal;
const
    // Դ��һ��"���ӵ��"��"JavaScript��window.open��������"����Ҳ�Ǽ���
    // ��������sub-resource�����Ĭ��ֵ��
    TT_LINK = 0;

    // Դ��һЩ����"��ʾ"�ĵ������������紴��һ���µ�browser��ʹ��LoadURL������
    // ��Ҳ���ڵ�����������δ֪ʱ��Ĭ��ֵ��
    TT_EXPLICIT = 1;

    // Դ��һ����frame�����������ڷǶ���frame���Զ����ص��κ����ݡ�
    // ����, ���һ��ҳ���е�һЩframe�����˹��, ��Щ���URL����������������͡�
    // �û�����û����ʶ�����ҳ���е���������һ��������frame�У����Կ��ܲ�������ЩURL��
    TT_AUTO_SUBFRAME = 3;

    // Դ��һ�����û�����������ʾ��������frame, �����ڻ���/ǰ���б��������µĵ�����Ŀ��
    // ���ǿ��ܱ���Щ��̨�Զ����ص�frame����Ҫ����Ϊ�û����ܻ��ϵ������Ӽ��صĽ����
    TT_MANUAL_SUBFRAME = 4;

    // Դ��һ���û������ı��ύ������ע��: ��ĳЩ�����У��ύһ����������transition����
    // �ﲢû��������룬�����ڽű����ύ��ʱ��
    TT_FORM_SUBMIT = 7;

    // Դ��ͨ��Reload���������·�����ͬURLʱ������ҳ��"���¼���"��
    // ע��: ������һ���ض��ļ����Ƿ���"����"������(���Ƿ��ƹ���������)��
    TT_RELOAD = 8;

    // ͨ�����룬������Դֵʹ�õ�����λ
    TT_SOURCE_MASK = $FF;

    // ��־����
    // ������κ�ֵ����������һ��������־���롣��Щ��־���뽫�����ܻᶨ��ɹ������͡�

    // ���Է���һ��URL�����Ǳ���ֹ��
    TT_BLOCKED_FLAG = $00800000;

    // ʹ����Forward��Back�����������ʷ�е�����
    TT_FORWARD_BACK_FLAG = $01000000;

    // һ���������Ŀ�ʼ
    TT_CHAIN_START_FLAG = $10000000;

    // ���ض������е�������
    TT_CHAIN_END_FLAG = $20000000;

    // JavaScript��ҳ���е�metaˢ�µ��µ��ض���
    TT_CLIENT_REDIRECT_FLAG = $40000000;

    // �ɷ��͵�HTTPͷ���µ��ض���
    TT_SERVER_REDIRECT_FLAG = $80000000;

    // ���ڲ���һ�������Ƿ��漰���ض���
    TT_IS_REDIRECT_MASK = $C0000000;

    // ͨ�����룬�����˱�־����ʹ�õ�����λ
    TT_QUALIFIER_MASK = $FFFFFF00;
 // );

type
  // �Զ���CefURLRequest��Ϊ�ı�־
  TCefUrlRequestFlag = (
    // Ĭ����Ϊ
    //UR_FLAG_NONE                      = 0,
    // I��������ˣ����ڴ�������ʱ����������
    UR_FLAG_SKIP_CACHE,
    // ��������ˣ����û����������cookie�򽫻��ڷ�������ʱһ������ȥ,
    // ����cookie���ܻᱣ������Ӧ�С�
    UR_FLAG_ALLOW_CACHED_CREDENTIALS,
    UR_FLAG_DUMMY_1,
    // ��������ˣ���������������ʱ�������ϴ������¼���
    UR_FLAG_REPORT_UPLOAD_PROGRESS,
    // ��������ˣ��򽫴��������ռ����ؼ�ʱ��Ϣ��
    UR_FLAG_DUMMY_2,
    // ��������ˣ������������ͷ����Ӧͷ������¼��
    UR_FLAG_REPORT_RAW_HEADERS,
    // ��������ˣ���CefURLRequestClient::OnDownloadData������������
    UR_FLAG_NO_DOWNLOAD_DATA,
    // ��������ˣ���5XX�ض�����󽫻ᴫ�����۲��ߣ��������Զ��������ӡ�
    // ��ǰ�ñ�־�������������ʹ�á�
    UR_FLAG_NO_RETRY_ON_5XX
  );
  TCefUrlRequestFlags = set of TCefUrlRequestFlag;

  // ��ʾCefURLRequest״̬�ı�־
  TCefUrlRequestStatus = (
    // λ��״̬
    UR_UNKNOWN = 0,
    // ����ɹ�
    UR_SUCCESS,
    // ���ڵȴ�һ��IO����, �������ʱ�����߽���֪ͨ
    UR_IO_PENDING,
    // ���󱻳���ȡ��
    UR_CANCELED,
    // ������ΪĳЩԭ����ʧ��
    UR_FAILED
  );

  // һ����Ľṹ��
  PCefPoint = ^TCefPoint;
  TCefPoint = record
    x: Integer;
    y: Integer;
  end;

  // һ�����εĽṹ��
  PCefRect = ^TCefRect;
  TCefRect = record
    x: Integer;
    y: Integer;
    width: Integer;
    height: Integer;
  end;

  // һ���ߴ�Ľṹ��
  PCefSize = ^TCefSize;
  TCefSize = record
    width: Integer;
    height: Integer;
  end;

  TCefRectArray = array[0..(High(Integer) div SizeOf(TCefRect))-1] of TCefRect;
  PCefRectArray = ^TCefRectArray;

  // Structure representing a draggable region.
  PCefDraggableRegion = ^TCefDraggableRegion;
  TCefDraggableRegion = record
    // Bounds of the region.
    bounds: TCefRect;
    // True (1) this this region is draggable and false (0) otherwise.
    draggable: Integer;
  end;

  PCefDraggableRegionArray = ^TCefDraggableRegionArray;
  TCefDraggableRegionArray = array[0..(High(Integer) div SizeOf(TCefDraggableRegion))-1]  of TCefDraggableRegion;

  // �Ѵ��ڵĽ���ID
  TCefProcessId = (
    // ���������
    PID_BROWSER,
    // ��Ⱦ����
    PID_RENDERER
  );


  // �Ѵ��ڵ��߳�ID
  TCefThreadId = (
  // BROWSER PROCESS THREADS -- �����������������Ч��
    // ������е����̡߳���CefSettings.multi_threaded_message_loopΪfalseʱ��
    // �������CefInitialize()ʱ���߳�һ�¡�
    TID_UI,

    // ���������ݿ⽻�����߳�
    TID_DB,

    // �������ļ�ϵͳ�������߳�
    TID_FILE,

    // ������ֹ�û��������ļ�ϵͳ�������̡߳�
    TID_FILE_USER_BLOCKING,

    // ���������ͽ�����������̵��߳�
    TID_PROCESS_LAUNCHER,

    // ���ڴ�������HTTP����������߳�
    TID_CACHE,

    // ���ڴ���IPC��������Ϣ���߳�
    TID_IO,

  // RENDER PROCESS THREADS -- ������Ⱦ������Ч

    ///
    // ��Ⱦ�����е����̡߳�����WebKit��V8�����н���
    ///
    TID_RENDERER
  );

  // ֧�ֵ�ֵ����
  TCefValueType = (
    VTYPE_INVALID = 0,
    VTYPE_NULL,
    VTYPE_BOOL,
    VTYPE_INT,
    VTYPE_DOUBLE,
    VTYPE_STRING,
    VTYPE_BINARY,
    VTYPE_DICTIONARY,
    VTYPE_LIST
  );

  // ֧�ֵ�JavaScript�Ի�������
  TCefJsDialogType = (
    JSDIALOGTYPE_ALERT = 0,
    JSDIALOGTYPE_CONFIRM,
    JSDIALOGTYPE_PROMPT
  );

  // ��������Ⱦ������ʱ����Ļ��Ϣ������ṹ��Ӧ�ñ��ͻ������ã�Ȼ����Ϊ
  // CefRenderHandler::GetScreenInfo�Ĳ���
  TCefScreenInfo = record
    // �豸�������ӡ� ָ��������߼����ؼ��ı�����
    device_scale_factor: Single;

    // ÿ���ص���Ļλ���
    depth: Integer;

    // ÿ����ɫ������λ���� ���������ɫ��ƽ���ġ�
    depth_per_component: Integer;

    // ���ںڰ״�ӡ������ֵӦ��Ϊtrue
    is_monochrome: Integer;

    // ���൱��MONITORINFOEX�е�rcMonitor:
    //   "һ����ʾ��ʾ�������ľ���, ʹ��������Ļ����ϵ��ʾ��
    //   ע�⣬����ü�������������ʾ�������ε�һЩ����ֵ����Ϊ��ֵ��"
    //
    // |rect| �� |available_rect| �������ھ���������ͼ����Ⱦ�ı��档
    rect: TCefRect;

    // ���൱��MONITORINFOEX�е�rcWork:
    //   "һ����ʾ��ʾ���������Ա�Ӧ�ó���ʹ�õĹ�������ľ��Σ�ʹ��������Ļ����ϵ��ʾ��
    //   ����ʹ�������������󻯵��������ϡ�rcMonitorʣ����������ϵͳ���ڣ������������ͱ�����
    //   ע�⣬����ü�������������ʾ�������ε�һЩ����ֵ����Ϊ��ֵ��"
    //
    // |rect| �� |available_rect| �������ھ���������ͼ����Ⱦ�ı��档
    ///
    available_rect: TCefRect;
  end;

  // ֧�ֵĲ˵�ID����Ӣ�﷭�����ΪCefResourceBundleHandler::GetLocalizedString()
  // �ṩIDS_MENU_*�ַ���
  TCefMenuId = (
    // ����.
    MENU_ID_BACK                = 100,
    MENU_ID_FORWARD             = 101,
    MENU_ID_RELOAD              = 102,
    MENU_ID_RELOAD_NOCACHE      = 103,
    MENU_ID_STOPLOAD            = 104,

    // �༭.
    MENU_ID_UNDO                = 110,
    MENU_ID_REDO                = 111,
    MENU_ID_CUT                 = 112,
    MENU_ID_COPY                = 113,
    MENU_ID_PASTE               = 114,
    MENU_ID_DELETE              = 115,
    MENU_ID_SELECT_ALL          = 116,

    // ����
    MENU_ID_FIND                = 130,
    MENU_ID_PRINT               = 131,
    MENU_ID_VIEW_SOURCE         = 132,

    // ƴд��飬���ʸ�������
    MENU_ID_SPELLCHECK_SUGGESTION_0        = 200,
    MENU_ID_SPELLCHECK_SUGGESTION_1        = 201,
    MENU_ID_SPELLCHECK_SUGGESTION_2        = 202,
    MENU_ID_SPELLCHECK_SUGGESTION_3        = 203,
    MENU_ID_SPELLCHECK_SUGGESTION_4        = 204,
    MENU_ID_SPELLCHECK_SUGGESTION_LAST     = 204,
    MENU_ID_NO_SPELLING_SUGGESTIONS        = 205,
    MENU_ID_ADD_TO_DICTIONARY              = 206,

    // Custom menu items originating from the renderer process. For example,
    // plugin placeholder menu items or Flash menu items.
    MENU_ID_CUSTOM_FIRST        = 220,
    MENU_ID_CUSTOM_LAST         = 250,

    // �����û��Զ���Ĳ˵�IDӦ����MENU_ID_USER_FIRST��MENU_ID_USER_LAST֮�䣬
    // �Ա��⸲��Chromium��CEF��tools/gritsettings/resource_id�ļ��ж����ID
    MENU_ID_USER_FIRST          = 26500,
    MENU_ID_USER_LAST           = 28500
  );

  // ��갴ť����
  TCefMouseButtonType = (
    MBT_LEFT,
    MBT_MIDDLE,
    MBT_RIGHT
  );

  // ����Ԫ������
  TCefPaintElementType = (
    PET_VIEW,
    PET_POPUP
  );

  // ֧�ֵ�ʱ��λ��־
  TCefEventFlag = (
    //EVENTFLAG_NONE                = 0,
    EVENTFLAG_CAPS_LOCK_ON,
    EVENTFLAG_SHIFT_DOWN,
    EVENTFLAG_CONTROL_DOWN,
    EVENTFLAG_ALT_DOWN,
    EVENTFLAG_LEFT_MOUSE_BUTTON,
    EVENTFLAG_MIDDLE_MOUSE_BUTTON,
    EVENTFLAG_RIGHT_MOUSE_BUTTON,
    // Mac OS-X command key.
    EVENTFLAG_COMMAND_DOWN,
    EVENTFLAG_NUM_LOCK_ON,
    EVENTFLAG_IS_KEY_PAD,
    EVENTFLAG_IS_LEFT,
    EVENTFLAG_IS_RIGHT
  );
  TCefEventFlags = set of TCefEventFlag;

  // ����¼���Ϣ
  PCefMouseEvent = ^TCefMouseEvent;
  TCefMouseEvent = record
    // �������ͼ��ߵ�X����
    x: Integer;

    // �������ͼ�ϱߵ�Y����
    y: Integer;

    // λ��־���������µİ�����Ϣ���μ�cef_event_flags_t
    modifiers: TCefEventFlags;
  end;

  // ֧�ֵĲ˵�������
  TCefMenuItemType = (
    MENUITEMTYPE_NONE,
    MENUITEMTYPE_COMMAND,
    MENUITEMTYPE_CHECK,
    MENUITEMTYPE_RADIO,
    MENUITEMTYPE_SEPARATOR,
    MENUITEMTYPE_SUBMENU
  );

  // ֧�ֵ������Ĳ˵����ͱ�־
  TCefContextMenuTypeFlag = (
    // û�нڵ㱻ѡ��
    //CM_TYPEFLAG_NONE        = 0,
    // ����ҳ��ѡ��
    CM_TYPEFLAG_PAGE,
    // һ����frame��ѡ��
    CM_TYPEFLAG_FRAME,
    // һ�����ӱ�ѡ��
    CM_TYPEFLAG_LINK,
    // һ��media�ڵ㱻ѡ��
    CM_TYPEFLAG_MEDIA,
    // ��һ���ı��������ݱ�ѡ��
    CM_TYPEFLAG_SELECTION,
    // һ���ɱ༭��Ԫ�ر�ѡ��
    CM_TYPEFLAG_EDITABLE
  );
  TCefContextMenuTypeFlags = set of TCefContextMenuTypeFlag;

  // ֧�ֵ������Ĳ˵�ý������
  TCefContextMenuMediaType = (
    // ����������û�нڵ�
    CM_MEDIATYPE_NONE,
    // һ��image�ڵ㱻ѡ��
    CM_MEDIATYPE_IMAGE,
    // һ��video�ڵ㱻ѡ��
    CM_MEDIATYPE_VIDEO,
    // һ��audio�ڵ㱻ѡ��
    CM_MEDIATYPE_AUDIO,
    // һ���ļ��ڵ㱻ѡ��
    CM_MEDIATYPE_FILE,
    // һ������ڵ㱻ѡ��
    CM_MEDIATYPE_PLUGIN
  );

  // ֧�ֵ������Ĳ˵�״̬λ��־
  TCefContextMenuMediaStateFlag = (
    //CM_MEDIAFLAG_NONE                  = 0,
    CM_MEDIAFLAG_ERROR,
    CM_MEDIAFLAG_PAUSED,
    CM_MEDIAFLAG_MUTED,
    CM_MEDIAFLAG_LOOP,
    CM_MEDIAFLAG_CAN_SAVE,
    CM_MEDIAFLAG_HAS_AUDIO,
    CM_MEDIAFLAG_HAS_VIDEO,
    CM_MEDIAFLAG_CONTROL_ROOT_ELEMENT,
    CM_MEDIAFLAG_CAN_PRINT,
    CM_MEDIAFLAG_CAN_ROTATE
  );
  TCefContextMenuMediaStateFlags = set of TCefContextMenuMediaStateFlag;

  // ֧�ֵ������ı༭״̬λ��־
  TCefContextMenuEditStateFlag = (
    //CM_EDITFLAG_NONE            = 0,
    CM_EDITFLAG_CAN_UNDO,
    CM_EDITFLAG_CAN_REDO,
    CM_EDITFLAG_CAN_CUT,
    CM_EDITFLAG_CAN_COPY,
    CM_EDITFLAG_CAN_PASTE,
    CM_EDITFLAG_CAN_DELETE,
    CM_EDITFLAG_CAN_SELECT_ALL,
    CM_EDITFLAG_CAN_TRANSLATE
 );
 TCefContextMenuEditStateFlags = set of TCefContextMenuEditStateFlag;

  // �����¼�����
  TCefKeyEventType = (
    // ����"up"��"down"�İ�������֪ͨ
    KEYEVENT_RAWKEYDOWN = 0,
    // ���������µ�֪ͨ��������һ����Ӧ���̺������ϵ�һ���ַ���
    // ��ʹ��KEYEVENT_CHAR�����������ַ�
    KEYEVENT_KEYDOWN,
    // һ���������ͷŵ�֪ͨ
    KEYEVENT_KEYUP,
    // һ���ַ��������֪ͨ��ʹ�ø��¼��������ı����롣����һ���ַ������ܻ�
    // ����0��1������Keydown�¼�����ȡ���ڰ��������ػ��Լ�����ϵͳ�� 
    KEYEVENT_CHAR
  );

  // �����¼���Ϣ
  PCefKeyEvent = ^TCefKeyEvent;
  TCefKeyEvent = record
    // �����¼�����
    kind: TCefKeyEventType;

    // λ��־���������µİ�����Ϣ���μ�cef_event_flags_t
    modifiers: TCefEventFlags;

    // Windows�������롣���ֵ��DOM�淶ʹ�á�
    // ��ʱ��ֱ���������¼�(��Windows)����ʱ����ʹ�õ�ӳ�亯����ָ����
    // �μ�WebCore/platform/chromium/KeyboardCodes.h���г���ֵ��
    windows_key_code: Integer;

    // ĳƽ̨ʵ�����ɵİ�������
    native_key_code: Integer;

    // ָʾ�¼��Ƿ���һ��"system key"�¼�(����μ�
    // http://msdn.microsoft.com/en-us/library/ms646286(VS.85).aspx).
    // ���ڷ�windowsƽ̨�����ֵӦ������Ϊfalse
    is_system_key: Integer;

    // �������ɵ��ַ�
    character: WideChar;

    // ��|character|��ͬ����δ���κ���modifiers(��shift)���µ��ַ��޸ġ�
    // �������ڴ����ݼ�
    unmodified_character: WideChar;

    // �����ǰ������ҳ����һ���ɱ༭�ֶ���ʱΪTrue�� This is
    // �������жϵ�ǰ��׼�����¼��Ƿ�����
    focus_on_editable_field: Integer;
  end;

  // ����Դ
  TCefFocusSource = (
    // Դ��ͨ��API(LoadURL()��)���µ���ʾ����
    FOCUS_SOURCE_NAVIGATION = 0,
    // Դ��ϵͳ���ɵĽ����¼�
    FOCUS_SOURCE_SYSTEM
  );

  // ��������
  TCefNavigationType = (
    NAVIGATION_LINK_CLICKED,
    NAVIGATION_FORM_SUBMITTED,
    NAVIGATION_BACK_FORWARD,
    NAVIGATION_RELOAD,
    NAVIGATION_FORM_RESUBMITTED,
    NAVIGATION_OTHER
  );

  // ֧�ֵ�XML�������͡�������֧��ASCII�� ISO-8859-1��UTF16 (LE��BE)(Ĭ��)��
  // �����������ͱ���ת����UTF8���ڴ��������������BOM�ܱ���⵽�Ҷ��ڵĽ��������ã�
  //���Զ���Ӧ��Ӧ�Ľ�������
  TCefXmlEncodingType = (
    XML_ENCODING_NONE = 0,
    XML_ENCODING_UTF8,
    XML_ENCODING_UTF16LE,
    XML_ENCODING_UTF16BE,
    XML_ENCODING_ASCII
  );

  // XML�ڵ�����
  TCefXmlNodeType = (
    XML_NODE_UNSUPPORTED = 0,
    XML_NODE_PROCESSING_INSTRUCTION,
    XML_NODE_DOCUMENT_TYPE,
    XML_NODE_ELEMENT_START,
    XML_NODE_ELEMENT_END,
    XML_NODE_ATTRIBUTE,
    XML_NODE_TEXT,
    XML_NODE_CDATA,
    XML_NODE_ENTITY_REFERENCE,
    XML_NODE_WHITESPACE,
    XML_NODE_COMMENT
  );

  // ������������
  PCefPopupFeatures = ^TCefPopupFeatures;
  TCefPopupFeatures = record
    x: Integer;
    xSet: Integer;
    y: Integer;
    ySet: Integer;
    width: Integer;
    widthSet: Integer;
    height: Integer;
    heightSet: Integer;

    menuBarVisible: Integer;
    statusBarVisible: Integer;
    toolBarVisible: Integer;
    locationBarVisible: Integer;
    scrollbarsVisible: Integer;
    resizable: Integer;

    fullscreen: Integer;
    dialog: Integer;
    additionalFeatures: TCefStringList;
  end;

  // DOM�ĵ�����
  TCefDomDocumentType = (
    DOM_DOCUMENT_TYPE_UNKNOWN = 0,
    DOM_DOCUMENT_TYPE_HTML,
    DOM_DOCUMENT_TYPE_XHTML,
    DOM_DOCUMENT_TYPE_PLUGIN
  );

  // DOM�¼������־
  TCefDomEventCategory = Integer;
const
  DOM_EVENT_CATEGORY_UNKNOWN = $0;
  DOM_EVENT_CATEGORY_UI = $1;
  DOM_EVENT_CATEGORY_MOUSE = $2;
  DOM_EVENT_CATEGORY_MUTATION = $4;
  DOM_EVENT_CATEGORY_KEYBOARD = $8;
  DOM_EVENT_CATEGORY_TEXT = $10;
  DOM_EVENT_CATEGORY_COMPOSITION = $20;
  DOM_EVENT_CATEGORY_DRAG = $40;
  DOM_EVENT_CATEGORY_CLIPBOARD = $80;
  DOM_EVENT_CATEGORY_MESSAGE = $100;
  DOM_EVENT_CATEGORY_WHEEL = $200;
  DOM_EVENT_CATEGORY_BEFORE_TEXT_INSERTED = $400;
  DOM_EVENT_CATEGORY_OVERFLOW = $800;
  DOM_EVENT_CATEGORY_PAGE_TRANSITION = $1000;
  DOM_EVENT_CATEGORY_POPSTATE = $2000;
  DOM_EVENT_CATEGORY_PROGRESS = $4000;
  DOM_EVENT_CATEGORY_XMLHTTPREQUEST_PROGRESS = $8000;

type
  // DOM�¼�����׶�
  TCefDomEventPhase = (
    DOM_EVENT_PHASE_UNKNOWN = 0,
    DOM_EVENT_PHASE_CAPTURING,
    DOM_EVENT_PHASE_AT_TARGET,
    DOM_EVENT_PHASE_BUBBLING
  );

  // DOM�ڵ�����
  TCefDomNodeType = (
    DOM_NODE_TYPE_UNSUPPORTED = 0,
    DOM_NODE_TYPE_ELEMENT,
    DOM_NODE_TYPE_ATTRIBUTE,
    DOM_NODE_TYPE_TEXT,
    DOM_NODE_TYPE_CDATA_SECTION,
    DOM_NODE_TYPE_PROCESSING_INSTRUCTIONS,
    DOM_NODE_TYPE_COMMENT,
    DOM_NODE_TYPE_DOCUMENT,
    DOM_NODE_TYPE_DOCUMENT_TYPE,
    DOM_NODE_TYPE_DOCUMENT_FRAGMENT
  );

  // �ļ��Ի���ģʽ
  TCefFileDialogMode = (
    // �������û�ѡ��֮ǰҪ���ļ��Ѿ�����
    FILE_DIALOG_OPEN,

    // ����FILE_DIALOG_OPEN, ��������ѡ�����򿪵��ļ�
    FILE_DIALOG_OPEN_MULTIPLE,
	
    // Like Open, but selects a folder to open.
    FILE_DIALOG_OPEN_FOLDER,

    // ����ѡ��һ�������ڵ��ļ�����������ļ��Ѵ��ڻ���ʾ�Ƿ񸲸�
    FILE_DIALOG_SAVE
  );

const
  // General mask defining the bits used for the type values.
  FILE_DIALOG_TYPE_MASK = $FF;

  // Qualifiers.
  // Any of the type values above can be augmented by one or more qualifiers.
  // These qualifiers further define the dialog behavior.

  // Prompt to overwrite if the user selects an existing file with the Save
  // dialog.
  FILE_DIALOG_OVERWRITEPROMPT_FLAG = $01000000;

  // Do not display read-only files.
  FILE_DIALOG_HIDEREADONLY_FLAG = $02000000;


type
  // ����λ�ô�����Ϣ
  TCefGeopositionErrorCode = (
    GEOPOSITON_ERROR_NONE,
    GEOPOSITON_ERROR_PERMISSION_DENIED,
    GEOPOSITON_ERROR_POSITION_UNAVAILABLE,
    GEOPOSITON_ERROR_TIMEOUT
  );

  // ����λ����Ϣ. ����ṹ������Զ�Ӧ��JavaScript�е�Position������(�������ǵ����Ͳ�̫һ��)��
  PCefGeoposition = ^TCefGeoposition;
  TCefGeoposition = record
    // ʮ���Ʊ�γ�� (WGS84����ϵ).
    latitude: Double;

    // ʮ���������� (WGS84����ϵ).
    longitude: Double;

    // �߿վ��ȣ���ȷ����(ͬ�ϣ�WGS84��׼).
    altitude: Double;

    // ˮƽ���ã���ȷ����
    accuracy: Double;

    // ���θ߶ȣ���ȷ����
    altitude_accuracy: Double;

    // ��������˳ʱ�뷽���ƫת�Ƕ�
    heading: Double;

    // �豸���ʵ�ˮƽ����(m/s)
    speed: Double;

    // ��UTCʱ��������ڵĺ���ֵ����ȡ��������ϵͳʱ��
    timestamp: TCefTime;

    // ������룬�μ�������ö������
    error_code: TCefGeopositionErrorCode;

    // ��������Ĵ����ַ���
    error_message: TCefString;
  end;

  // ��ӡ�������ɫģʽ
  TCefColorModel = (
    COLOR_MODEL_UNKNOWN,
    COLOR_MODEL_GRAY,
    COLOR_MODEL_COLOR,
    COLOR_MODEL_CMYK,
    COLOR_MODEL_CMY,
    COLOR_MODEL_KCMY,
    COLOR_MODEL_CMY_K,  // CMY_K represents CMY+K.
    COLOR_MODEL_BLACK,
    COLOR_MODEL_GRAYSCALE,
    COLOR_MODEL_RGB,
    COLOR_MODEL_RGB16,
    COLOR_MODEL_RGBA,
    COLOR_MODEL_COLORMODE_COLOR,  // �������Ǵ�ӡ��ppds.
    COLOR_MODEL_COLORMODE_MONOCHROME,  // �������Ǵ�ӡ�� ppds.
    COLOR_MODEL_HP_COLOR_COLOR,  // ����HP��ɫ��ӡ�� ppds.
    COLOR_MODEL_HP_COLOR_BLACK,  // ����HP��ɫ��ӡ�� ppds.
    COLOR_MODEL_PRINTOUTMODE_NORMAL,  // ����foomatic ppds.
    COLOR_MODEL_PRINTOUTMODE_NORMAL_GRAY,  // ����foomatic ppds.
    COLOR_MODEL_PROCESSCOLORMODEL_CMYK,  // ���ڼ��ܴ�ӡ�� ppds.
    COLOR_MODEL_PROCESSCOLORMODEL_GREYSCALE,  // ���ڼ��ܴ�ӡ�� ppds.
    COLOR_MODEL_PROCESSCOLORMODEL_RGB  // ���ڼ��ܴ�ӡ�� ppds
  );

  // ��ӡ����˫��ģʽ
  TCefDuplexMode = (
    DUPLEX_MODE_UNKNOWN = -1,
    DUPLEX_MODE_SIMPLEX,
    DUPLEX_MODE_LONG_EDGE,
    DUPLEX_MODE_SHORT_EDGE
  );

  // һ����ӡ�����ҳ��Χ
  PCefPageRange = ^TCefPageRange;
  TCefPageRange = record
    from:Integer;
    to_: Integer;
  end;
  TCefPageRangeArray = array of TCefPageRange;

  // �������
  ///
  TCefCursorType = (
    CT_POINTER = 0,
    CT_CROSS,
    CT_HAND,
    CT_IBEAM,
    CT_WAIT,
    CT_HELP,
    CT_EASTRESIZE,
    CT_NORTHRESIZE,
    CT_NORTHEASTRESIZE,
    CT_NORTHWESTRESIZE,
    CT_SOUTHRESIZE,
    CT_SOUTHEASTRESIZE,
    CT_SOUTHWESTRESIZE,
    CT_WESTRESIZE,
    CT_NORTHSOUTHRESIZE,
    CT_EASTWESTRESIZE,
    CT_NORTHEASTSOUTHWESTRESIZE,
    CT_NORTHWESTSOUTHEASTRESIZE,
    CT_COLUMNRESIZE,
    CT_ROWRESIZE,
    CT_MIDDLEPANNING,
    CT_EASTPANNING,
    CT_NORTHPANNING,
    CT_NORTHEASTPANNING,
    CT_NORTHWESTPANNING,
    CT_SOUTHPANNING,
    CT_SOUTHEASTPANNING,
    CT_SOUTHWESTPANNING,
    CT_WESTPANNING,
    CT_MOVE,
    CT_VERTICALTEXT,
    CT_CELL,
    CT_CONTEXTMENU,
    CT_ALIAS,
    CT_PROGRESS,
    CT_NODROP,
    CT_COPY,
    CT_NONE,
    CT_NOTALLOWED,
    CT_ZOOMIN,
    CT_ZOOMOUT,
    CT_GRAB,
    CT_GRABBING,
    CT_CUSTOM
  );

  // �����Ϣ. |buffer| ��һ�� |size.width|*|size.height|*4 �ֽڴ�С��
  // �����Ͻ�Ϊ����ԭ���һ��RGBAͼ�񻺴�����ָ��

  PCefCursorInfo = ^TCefCursorInfo;
  TCefCursorInfo = record
    hotspot: TCefPoint;
    image_scale_factor: Single;
    buffer: Pointer;
    size: TCefSize;
  end;

  // URI unescape rules passed to CefURIDecode().
  // todo: set of
  TCefUriUnescapeRule = (
    // Don't unescape anything at all.
    UU_NONE = 0,

    // Don't unescape anything special, but all normal unescaping will happen.
    // This is a placeholder and can't be combined with other flags (since it's
    // just the absence of them). All other unescape rules imply "normal" in
    // addition to their special meaning. Things like escaped letters, digits,
    // and most symbols will get unescaped with this mode.
    UU_NORMAL = 1,

    // Convert %20 to spaces. In some places where we're showing URLs, we may
    // want this. In places where the URL may be copied and pasted out, then
    // you wouldn't want this since it might not be interpreted in one piece
    // by other applications.
    UU_SPACES = 2,

    // Unescapes various characters that will change the meaning of URLs,
    // including '%', '+', '&', '/', '#'. If we unescaped these characters, the
    // resulting URL won't be the same as the source one. This flag is used when
    // generating final output like filenames for URLs where we won't be
    // interpreting as a URL and want to do as much unescaping as possible.
    UU_URL_SPECIAL_CHARS = 4,

    // Unescapes control characters such as %01. This INCLUDES NULLs. This is
    // used for rare cases such as data: URL decoding where the result is binary
    // data. This flag also unescapes BiDi control characters.
    //
    // DO NOT use CONTROL_CHARS if the URL is going to be displayed in the UI
    // for security reasons.
    UU_CONTROL_CHARS = 8,

    // URL queries use "+" for space. This flag controls that replacement.
    UU_REPLACE_PLUS_WITH_SPACE = 16
  );

  // Options that can be passed to CefParseJSON.
  // todo: set of
  TCefJsonParserOptions = (
    // Parses the input strictly according to RFC 4627. See comments in Chromium's
    // base/json/json_reader.h file for known limitations/deviations from the RFC.
    JSON_PARSER_RFC = 0,

    // Allows commas to exist after the last element in structures.
    JSON_PARSER_ALLOW_TRAILING_COMMAS = 1 shl 0
  );

  // Error codes that can be returned from CefParseJSONAndReturnError.
  PCefJsonParserError = ^TCefJsonParserError;
  TCefJsonParserError = (
    JSON_NO_ERROR = 0,
    JSON_INVALID_ESCAPE,
    JSON_SYNTAX_ERROR,
    JSON_UNEXPECTED_TOKEN,
    JSON_TRAILING_COMMA,
    JSON_TOO_MUCH_NESTING,
    JSON_UNEXPECTED_DATA_AFTER_ROOT,
    JSON_UNSUPPORTED_ENCODING,
    JSON_UNQUOTED_DICTIONARY_KEY,
    JSON_PARSE_ERROR_COUNT
  );

  // Options that can be passed to CefWriteJSON.
  // Default behavior.
//  JSON_WRITER_DEFAULT = 0;
  TCefJsonWriterOption = (
    // This option instructs the writer that if a Binary value is encountered,
    // the value (and key if within a dictionary) will be omitted from the
    // output, and success will be returned. Otherwise, if a binary value is
    // encountered, failure will be returned.
    JSON_WRITER_OMIT_BINARY_VALUES,

    // This option instructs the writer to write doubles that have no fractional
    // part as a normal integer (i.e., without using exponential notation
    // or appending a '.0') as long as the value is within the range of a
    // 64-bit int.
    JSON_WRITER_OMIT_DOUBLE_TYPE_PRESERVATION,

    // Return a slightly nicer formatted json string (pads with whitespace to
    // help with readability).
    JSON_WRITER_PRETTY_PRINT
  );
  TCefJsonWriterOptions = set of TCefJsonWriterOption;

  // Margin type for PDF printing.
  TCefPdfPrintMarginType = (
    // Default margins.
    PDF_PRINT_MARGIN_DEFAULT,
    // No margins.
    PDF_PRINT_MARGIN_NONE,
    // Minimum margins.
    PDF_PRINT_MARGIN_MINIMUM,
    // Custom margins using the |margin_*| values from cef_pdf_print_settings_t.
    PDF_PRINT_MARGIN_CUSTOM
  );

  // Structure representing PDF print settings.
  PCefPdfPrintSettings = ^TCefPdfPrintSettings;
  TCefPdfPrintSettings = record
    // Page title to display in the header. Only used if |header_footer_enabled|
    // is set to true (1).
    header_footer_title: TCefString;
    // URL to display in the footer. Only used if |header_footer_enabled| is set
    // to true (1).
    header_footer_url: TCefString;
    // Output page size in microns. If either of these values is less than or
    // equal to zero then the default paper size (A4) will be used.
    page_width: Integer;
    page_height: Integer;
    // Margins in millimeters. Only used if |margin_type| is set to
    // PDF_PRINT_MARGIN_CUSTOM.
    margin_top: double;
    margin_right: double;
    margin_bottom: double;
    margin_left: double;
    // Margin type.
    margin_type: TCefPdfPrintMarginType;
    // Set to true (1) to print headers and footers or false (0) to not print
    // headers and footers.
    header_footer_enabled: Integer;
    // Set to true (1) to print the selection only or false (0) to print all.
    selection_only: Integer;
    // Set to true (1) for landscape mode or false (0) for portrait mode.
    landscape: Integer;
    // Set to true (1) to print background graphics or false (0) to not print
    // background graphics.
    backgrounds_enabled: Integer;
  end;

  // Supported UI scale factors for the platform. SCALE_FACTOR_NONE is used for
  // density independent resources such as string, html/js files or an image that
  // can be used for any scale factors (such as wallpapers).
  TCefScaleFactor = (
    SCALE_FACTOR_NONE = 0,
    SCALE_FACTOR_100P,
    SCALE_FACTOR_125P,
    SCALE_FACTOR_133P,
    SCALE_FACTOR_140P,
    SCALE_FACTOR_150P,
    SCALE_FACTOR_180P,
    SCALE_FACTOR_200P,
    SCALE_FACTOR_250P,
    SCALE_FACTOR_300P
  );

  // Plugin policies supported by CefRequestContextHandler::OnBeforePluginLoad.
  PCefPluginPolicy = ^TCefPluginPolicy;
  TCefPluginPolicy = (
    // Allow the content.
    PLUGIN_POLICY_ALLOW,
    // Allow important content and block unimportant content based on heuristics.
    // The user can manually load blocked content.
    PLUGIN_POLICY_DETECT_IMPORTANT,
    // Block the content. The user can manually load blocked content.
    PLUGIN_POLICY_BLOCK,
    // Disable the content. The user cannot load disabled content.
    PLUGIN_POLICY_DISABLE
  );

(*******************************************************************************
   capi
 *******************************************************************************)
type
  PCefv8Handler = ^TCefv8Handler;
  PCefV8Accessor = ^TCefV8Accessor;
  PCefv8Value = ^TCefv8Value;
  PCefV8StackTrace = ^TCefV8StackTrace;
  PCefV8StackFrame = ^TCefV8StackFrame;
  PCefV8ValueArray = array[0..(High(Integer) div SizeOf(Pointer)) - 1] of PCefV8Value;
  PPCefV8Value = ^PCefV8ValueArray;
  PCefSchemeHandlerFactory = ^TCefSchemeHandlerFactory;
  PCefSchemeRegistrar = ^TCefSchemeRegistrar;
  PCefFrame = ^TCefFrame;
  PCefRequest = ^TCefRequest;
  PCefStreamReader = ^TCefStreamReader;
  PCefPostData = ^TCefPostData;
  PCefPostDataElement = ^TCefPostDataElement;
  PPCefPostDataElement = ^PCefPostDataElement;
  PCefReadHandler = ^TCefReadHandler;
  PCefWriteHandler = ^TCefWriteHandler;
  PCefStreamWriter = ^TCefStreamWriter;
  PCefBase = ^TCefBase;
  PCefBrowser = ^TCefBrowser;
  PCefRunFileDialogCallback = ^TCefRunFileDialogCallback;
  PCefBrowserHost = ^TCefBrowserHost;
  PCefPdfPrintCallback = ^TCefPdfPrintCallback;
  PCefTask = ^TCefTask;
  PCefTaskRunner = ^TCefTaskRunner;
  PCefDownloadHandler = ^TCefDownloadHandler;
  PCefXmlReader = ^TCefXmlReader;
  PCefZipReader = ^TCefZipReader;
  PCefDomVisitor = ^TCefDomVisitor;
  PCefDomDocument = ^TCefDomDocument;
  PCefDomNode = ^TCefDomNode;
  PCefResponse = ^TCefResponse;
  PCefv8Context = ^TCefv8Context;
  PCefCookieVisitor = ^TCefCookieVisitor;
  PCefCookie = ^TCefCookie;
  PCefClient = ^TCefClient;
  PCefLifeSpanHandler = ^TCefLifeSpanHandler;
  PCefLoadHandler = ^TCefLoadHandler;
  PCefRequestHandler = ^TCefRequestHandler;
  PCefDisplayHandler = ^TCefDisplayHandler;
  PCefFocusHandler = ^TCefFocusHandler;
  PCefKeyboardHandler = ^TCefKeyboardHandler;
  PCefJsDialogHandler = ^TCefJsDialogHandler;
  PCefApp = ^TCefApp;
  PCefV8Exception = ^TCefV8Exception;
  PCefResourceBundleHandler = ^TCefResourceBundleHandler;
  PCefCookieManager = ^TCefCookieManager;
  PCefWebPluginInfo = ^TCefWebPluginInfo;
  PCefCommandLine = ^TCefCommandLine;
  PCefProcessMessage = ^TCefProcessMessage;
  PCefBinaryValue = ^TCefBinaryValue;
  PCefDictionaryValue = ^TCefDictionaryValue;
  PCefListValue = ^TCefListValue;
  PCefBrowserProcessHandler = ^TCefBrowserProcessHandler;
  PCefRenderProcessHandler = ^TCefRenderProcessHandler;
  PCefAuthCallback = ^TCefAuthCallback;
  PCefRequestCallback = ^TCefRequestCallback;
  PCefResourceHandler = ^TCefResourceHandler;
  PCefCallback = ^TCefCallback;
  PCefCompletionCallback = ^TCefCompletionCallback;
  PCefRunContextMenuCallback = ^TCefRunContextMenuCallback;
  PCefContextMenuHandler = ^TCefContextMenuHandler;
  PCefContextMenuParams = ^TCefContextMenuParams;
  PCefMenuModel = ^TCefMenuModel;
  PCefGeolocationCallback = ^TCefGeolocationCallback;
  PCefGeolocationHandler = ^TCefGeolocationHandler;
  PCefBeforeDownloadCallback = ^TCefBeforeDownloadCallback;
  PCefDownloadItemCallback = ^TCefDownloadItemCallback;
  PCefDownloadItem = ^TCefDownloadItem;
  PCefStringVisitor = ^TCefStringVisitor;
  PCefJsDialogCallback = ^TCefJsDialogCallback;
  PCefUrlRequest = ^TCefUrlRequest;
  PCefUrlRequestClient = ^TCefUrlRequestClient;
  PCefWebPluginInfoVisitor = ^TCefWebPluginInfoVisitor;
  PCefWebPluginUnstableCallback = ^TCefWebPluginUnstableCallback;
  PCefFileDialogCallback = ^TCefFileDialogCallback;
  PCefDialogHandler = ^TCefDialogHandler;
  PCefRenderHandler = ^TCefRenderHandler;
  PCefGetGeolocationCallback = ^TCefGetGeolocationCallback;
  PCefEndTracingCallback = ^TCefEndTracingCallback;
  PCefScreenInfo = ^TCefScreenInfo;
  PCefDragData = ^TCefDragData;
  PCefDragHandler = ^TCefDragHandler;
  PCefRequestContextHandler = ^TCefRequestContextHandler;
  PCefRequestContext = ^TCefRequestContext;
  PCefPrintSettings = ^TCefPrintSettings;
  PCefPrintDialogCallback = ^TCefPrintDialogCallback;
  PCefPrintJobCallback = ^TCefPrintJobCallback;
  PCefPrintHandler = ^TCefPrintHandler;
  PCefNavigationEntry = ^TCefNavigationEntry;
  PCefNavigationEntryVisitor = ^TCefNavigationEntryVisitor;
  PCefFindHandler = ^TCefFindHandler;
  PCefSetCookieCallback = ^TCefSetCookieCallback;
  PCefDeleteCookiesCallback = ^TCefDeleteCookiesCallback;
  PCefValue = ^TCefValue;
  PCefSslCertPrincipal = ^TCefSslCertPrincipal;
  PCefSslInfo = ^TCefSslInfo;
  PCefResourceBundle = ^TCefResourceBundle;

  // һ�����ü����ĺ����ṹ�塣��������еĽṹ����뽫cef_base_t��Ϊ��һ���ֶΡ�
  TCefBase = record
    // �ṹ��ĳߴ�
    size: NativeUInt;

    // �ú����������Ӷ�������ü�����Ӧ����ÿ�ν�ָ����¿�����ֵ��һ������ʱ����
    add_ref: procedure(self: PCefBase); stdcall;

    // �ú������ڼ��ٶ�������ü����� ������ü�������0�������Ӧ�ñ������١�
    // ������ü���Ϊ0���򷵻�true (1)
    release: function(self: PCefBase): Integer; stdcall;

    // �����ǰ���ü���Ϊ1���򷵻�(1)
    has_one_ref: function(self: PCefBase): Integer; stdcall;
  end;

  // Structure that wraps other data value types. Complex types (binary,
  // dictionary and list) will be referenced but not owned by this object. Can be
  // used on any process and thread.
  TCefValue = record
    // Base structure.
    base: TCefBase;

    // Returns true (1) if the underlying data is valid. This will always be true
    // (1) for simple types. For complex types (binary, dictionary and list) the
    // underlying data may become invalid if owned by another object (e.g. list or
    // dictionary) and that other object is then modified or destroyed. This value
    // object can be re-used by calling Set*() even if the underlying data is
    // invalid.

    is_valid: function(self: PCefValue): Integer; stdcall;

    // Returns true (1) if the underlying data is owned by another object.
    is_owned: function(self: PCefValue): Integer; stdcall;

    // Returns true (1) if the underlying data is read-only. Some APIs may expose
    // read-only objects.
    is_read_only: function(self: PCefValue): Integer; stdcall;

    // Returns true (1) if this object and |that| object have the same underlying
    // data. If true (1) modifications to this object will also affect |that|
    // object and vice-versa.
    is_same: function(self, that: PCefValue): Integer; stdcall;

    // Returns true (1) if this object and |that| object have an equivalent
    // underlying value but are not necessarily the same object.
    is_equal: function(self, that: PCefValue): Integer; stdcall;

    // Returns a copy of this object. The underlying data will also be copied.
    copy: function(self: PCefValue): PCefValue; stdcall;

    // Returns the underlying value type.
    get_type: function(self: PCefValue): TCefValueType; stdcall;

    // Returns the underlying value as type bool.
    get_bool: function(self: PCefValue): Integer; stdcall;

    // Returns the underlying value as type int.
    get_int: function(self: PCefValue): Integer; stdcall;

    // Returns the underlying value as type double.
    get_double: function(self: PCefValue): Double; stdcall;

    // Returns the underlying value as type string.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_string: function(self: PCefValue): PCefStringUserFree; stdcall;

    // Returns the underlying value as type binary. The returned reference may
    // become invalid if the value is owned by another object or if ownership is
    // transferred to another object in the future. To maintain a reference to the
    // value after assigning ownership to a dictionary or list pass this object to
    // the set_value() function instead of passing the returned reference to
    // set_binary().
    get_binary: function(self: PCefValue): PCefBinaryValue; stdcall;

    // Returns the underlying value as type dictionary. The returned reference may
    // become invalid if the value is owned by another object or if ownership is
    // transferred to another object in the future. To maintain a reference to the
    // value after assigning ownership to a dictionary or list pass this object to
    // the set_value() function instead of passing the returned reference to
    // set_dictionary().
    get_dictionary: function(self: PCefValue): PCefDictionaryValue; stdcall;

    // Returns the underlying value as type list. The returned reference may
    // become invalid if the value is owned by another object or if ownership is
    // transferred to another object in the future. To maintain a reference to the
    // value after assigning ownership to a dictionary or list pass this object to
    // the set_value() function instead of passing the returned reference to
    // set_list().
    get_list: function(self: PCefValue): PCefListValue; stdcall;

    // Sets the underlying value as type null. Returns true (1) if the value was
    // set successfully.
    set_null: function(self: PCefValue): Integer; stdcall;

    // Sets the underlying value as type bool. Returns true (1) if the value was
    // set successfully.
    set_bool: function(self: PCefValue; value: Integer): Integer; stdcall;

    // Sets the underlying value as type int. Returns true (1) if the value was
    // set successfully.
    set_int: function(self: PCefValue; value: Integer): Integer; stdcall;

    // Sets the underlying value as type double. Returns true (1) if the value was
    // set successfully.
    set_double: function(self: PCefValue; value: Double): Integer; stdcall;

    // Sets the underlying value as type string. Returns true (1) if the value was
    // set successfully.
    set_string: function(self: PCefValue; const value: PCefString): Integer; stdcall;

    // Sets the underlying value as type binary. Returns true (1) if the value was
    // set successfully. This object keeps a reference to |value| and ownership of
    // the underlying data remains unchanged.
    set_binary: function(self: PCefValue; value: PCefBinaryValue): Integer; stdcall;

    // Sets the underlying value as type dict. Returns true (1) if the value was
    // set successfully. This object keeps a reference to |value| and ownership of
    // the underlying data remains unchanged.
    set_dictionary: function(self: PCefValue; value: PCefDictionaryValue): Integer; stdcall;

    // Sets the underlying value as type list. Returns true (1) if the value was
    // set successfully. This object keeps a reference to |value| and ownership of
    // the underlying data remains unchanged.
    set_list: function(self: PCefValue; value: PCefListValue): Integer; stdcall;
  end;

  // �ýṹ���ʾһ��������ֵ�����Ա������κν��̺��߳�
  TCefBinaryValue = record
    // �ṹ��ĳߴ�
    base: TCefBase;

    // ��������Чʱ����true (1)��������false(0)ʱ����Ҫ�����κ���������
    is_valid: function(self: PCefBinaryValue): Integer; stdcall;

    // ��������һ������ӵ��ʱ����true (1)
    is_owned: function(self: PCefBinaryValue): Integer; stdcall;

    // Returns true (1) if this object and |that| object have the same underlying
    // data.
    is_same: function(self, that: PCefBinaryValue):Integer; stdcall;

    // Returns true (1) if this object and |that| object have an equivalent
    // underlying value but are not necessarily the same object.
    is_equal: function(self, that: PCefBinaryValue): Integer; stdcall;

    // ���ظö����һ���¿����������е�����Ҳ����п���
    copy: function(self: PCefBinaryValue): PCefBinaryValue; stdcall;

    // �������ݵĳߴ�
    get_size: function(self: PCefBinaryValue): NativeUInt; stdcall;

    // ��ȡ|buffer_size|�ֽڵ����ݵ�|buffer|����ȡ����ʼλ����|data_offset|ָ����
    // ���ض�ȡ�����ֽ�����
    get_data: function(self: PCefBinaryValue; buffer: Pointer; buffer_size,
      data_offset: NativeUInt): NativeUInt; stdcall;
  end;

  // �ýṹ���ʾһ���ֵ�ֵ�����Ա������κν��̺��߳�
  TCefDictionaryValue = record
    // �ṹ��ĳߴ�
    base: TCefBase;

    // ��������Чʱ����true (1)��������false(0)ʱ����Ҫ�����κ���������
    is_valid: function(self: PCefDictionaryValue): Integer; stdcall;

    // ��������һ������ӵ��ʱ����true (1)
    is_owned: function(self: PCefDictionaryValue): Integer; stdcall;

    // ��������ֵ��ֻ�����򷵻�true (1)�� һЩAPI���ܻᷢ��ֻ������
    is_read_only: function(self: PCefDictionaryValue): Integer; stdcall;

    // Returns true (1) if this object and |that| object have the same underlying
    // data. If true (1) modifications to this object will also affect |that|
    // object and vice-versa.
    is_same: function(self, that: PCefDictionaryValue): Integer; stdcall;

    // Returns true (1) if this object and |that| object have an equivalent
    // underlying value but are not necessarily the same object.
    is_equal: function(self, that: PCefDictionaryValue): Integer; stdcall;

    // ����һ���ö���Ŀ�д���������|exclude_NULL_children|Ϊtrue (1)��
    // ���κ�ΪNULL���ֵ���б��ӿ������ų�
    copy: function(self: PCefDictionaryValue; exclude_empty_children: Integer): PCefDictionaryValue; stdcall;

    // ����ֵ������
    get_size: function(self: PCefDictionaryValue): NativeUInt; stdcall;

    // �������ֵ�����ɹ�ʱ����true (1)
    clear: function(self: PCefDictionaryValue): Integer; stdcall;

    // �����ǰ�ֵ����key����ֵ�򷵻�true (1)
    has_key: function(self: PCefDictionaryValue; const key: PCefString): Integer; stdcall;

    // ��������ֵ�����м���һ���б���
    get_keys: function(self: PCefDictionaryValue; const keys: TCefStringList): Integer; stdcall;

    // �Ƴ�keyָ���ļ���ֵ�������ֵ�ɹ����Ƴ��򷵻�true (1)
    remove: function(self: PCefDictionaryValue; const key: PCefString): Integer; stdcall;

    // ����ָ������ֵ����
    get_type: function(self: PCefDictionaryValue; const key: PCefString): TCefValueType; stdcall;

    // Returns the value at the specified key. For simple types the returned value
    // will copy existing data and modifications to the value will not modify this
    // object. For complex types (binary, dictionary and list) the returned value
    // will reference existing data and modifications to the value will modify
    // this object.
    get_value: function(self: PCefDictionaryValue; const key: PCefString): PCefValue; stdcall;

    // ��ָ������ֵ��Ϊbool���ͷ���
    get_bool: function(self: PCefDictionaryValue; const key: PCefString): Integer; stdcall;

    // ��ָ������ֵ��Ϊint���ͷ���
    get_int: function(self: PCefDictionaryValue; const key: PCefString): Integer; stdcall;

    // ��ָ������ֵ��Ϊdouble���ͷ���
    get_double: function(self: PCefDictionaryValue; const key: PCefString): Double; stdcall;

    // ��ָ������ֵ��Ϊ�ַ������ͷ��أ����ص��ַ����������cef_string_userfree_free()����������
    get_string: function(self: PCefDictionaryValue; const key: PCefString): PCefStringUserFree; stdcall;

    // ��ָ������ֵ��Ϊ���������ͷ���
    get_binary: function(self: PCefDictionaryValue; const key: PCefString): PCefBinaryValue; stdcall;

    // ��ָ������ֵ��Ϊ�ֵ����ͷ���
    get_dictionary: function(self: PCefDictionaryValue; const key: PCefString): PCefDictionaryValue; stdcall;

    // ��ָ������ֵ��Ϊ�б����ͷ���
    get_list: function(self: PCefDictionaryValue; const key: PCefString): PCefListValue; stdcall;

    // Sets the value at the specified key. Returns true (1) if the value was set
    // successfully. If |value| represents simple data then the underlying data
    // will be copied and modifications to |value| will not modify this object. If
    // |value| represents complex data (binary, dictionary or list) then the
    // underlying data will be referenced and modifications to |value| will modify
    // this object.
    set_value: function(self: PCefDictionaryValue; const key: PCefString; value: PCefValue): Integer; stdcall;

    // ����ָ������ֵΪnull��������óɹ��򷵻�true (1)
    set_null: function(self: PCefDictionaryValue; const key: PCefString): Integer; stdcall;

    // ����ָ������ֵΪbool���͵�ֵ��������óɹ��򷵻�true (1)
    set_bool: function(self: PCefDictionaryValue; const key: PCefString; value: Integer): Integer; stdcall;

    // ����ָ������ֵΪint���͵�ֵ��������óɹ��򷵻�true (1)
    set_int: function(self: PCefDictionaryValue; const key: PCefString; value: Integer): Integer; stdcall;

    // ����ָ������ֵΪdouble���͵�ֵ��������óɹ��򷵻�true (1)
    set_double: function(self: PCefDictionaryValue; const key: PCefString; value: Double): Integer; stdcall;

    // ����ָ������ֵΪ�ַ������͵�ֵ��������óɹ��򷵻�true (1)
    set_string: function(self: PCefDictionaryValue; const key: PCefString; value: PCefString): Integer; stdcall;

    // ����ָ������ֵΪbool���͵�ֵ��������óɹ��򷵻�true (1)
    // ���|value|��ǰ����һ������ӵ�У����ֵ���ᱻ��������|value|���ò��ᱻ�ı䡣
    // ����, ӵ�й�ϵ����ת�Ƶ���������ϣ�����|value|�����ý���ʧЧ
    set_binary: function(self: PCefDictionaryValue; const key: PCefString; value: PCefBinaryValue): Integer; stdcall;

    // ����ָ������ֵΪ�ֵ����͵�ֵ��������óɹ��򷵻�true (1)
    // �ڵ������������|value|���󽫲�����Ч�����|value|��ǰ����һ������ӵ�У�
    // ���ֵ���ᱻ��������|value|���ò��ᱻ�ı䡣
    // ����, ӵ�й�ϵ����ת�Ƶ���������ϣ�����|value|�����ý���ʧЧ
    set_dictionary: function(self: PCefDictionaryValue; const key: PCefString; value: PCefDictionaryValue): Integer; stdcall;

    // ����ָ������ֵΪ�б����͵�ֵ��������óɹ��򷵻�true (1)
    // �ڵ������������|value|���󽫲�����Ч�����|value|��ǰ����һ������ӵ�У�
    // ���ֵ���ᱻ��������|value|���ò��ᱻ�ı䡣
    // ����, ӵ�й�ϵ����ת�Ƶ���������ϣ�����|value|�����ý���ʧЧ
    set_list: function(self: PCefDictionaryValue; const key: PCefString; value: PCefListValue): Integer; stdcall;
  end;

  // �ýṹ���ʾһ���б�ֵ�����Ա������κν��̺��߳�
  TCefListValue = record
    // �ṹ��ĳߴ�
    base: TCefBase;

    // ��������Чʱ����true (1)��������false(0)ʱ����Ҫ�����κ���������
    is_valid: function(self: PCefListValue): Integer; stdcall;

    // ��������һ������ӵ��ʱ����true (1)
    is_owned: function(self: PCefListValue): Integer; stdcall;

    // ��������ֵ��ֻ�����򷵻�true (1)�� һЩAPI���ܻᷢ��ֻ������
    is_read_only: function(self: PCefListValue): Integer; stdcall;

    // Returns true (1) if this object and |that| object have the same underlying
    // data. If true (1) modifications to this object will also affect |that|
    // object and vice-versa.
    is_same: function(self, that: PCefListValue): Integer; stdcall;

    // Returns true (1) if this object and |that| object have an equivalent
    // underlying value but are not necessarily the same object.
    is_equal: function(self, that: PCefListValue): Integer; stdcall;


    // ����һ���ö���Ŀ�д���������|exclude_NULL_children|Ϊtrue (1)��
    // ���κ�ΪNULL���ֵ���б��ӿ������ų�
    copy: function(self: PCefListValue): PCefListValue; stdcall;

    // ����ֵ�����������ֵ����������չ��һ����ֵ������Щ��ֵĬ��Ϊnull��
    // ����ɹ��򷵻�true (1)
    set_size: function(self: PCefListValue; size: NativeUInt): Integer; stdcall;

    // ����ֵ������
    get_size: function(self: PCefListValue): NativeUInt; stdcall;

    // �Ƴ�����ֵ������ɹ��򷵻�true (1)
    clear: function(self: PCefListValue): Integer; stdcall;

    // �Ƴ�ָ������λ�õ�ֵ
    remove: function(self: PCefListValue; index: Integer): Integer; stdcall;

    // ��ȡָ������λ�õ�ֵ����
    get_type: function(self: PCefListValue; index: Integer): TCefValueType; stdcall;

    // Returns the value at the specified index. For simple types the returned
    // value will copy existing data and modifications to the value will not
    // modify this object. For complex types (binary, dictionary and list) the
    // returned value will reference existing data and modifications to the value
    // will modify this object.
    get_value: function(self: PCefListValue; index: Integer): PCefValue; stdcall;

    // ��ȡָ������λ�õ�bool���͵�ֵ
    get_bool: function(self: PCefListValue; index: Integer): Integer; stdcall;

    // ��ȡָ������λ�õ�int���͵�ֵ
    get_int: function(self: PCefListValue; index: Integer): Integer; stdcall;

    // ��ȡָ������λ�õ�double���͵�ֵ
    get_double: function(self: PCefListValue; index: Integer): Double; stdcall;

    // ��ȡָ������λ�õ��ַ������͵�ֵ�����ص��ַ����������cef_string_userfree_free()������
    get_string: function(self: PCefListValue; index: Integer): PCefStringUserFree; stdcall;

    // ��ȡָ������λ�õĶ��������͵�ֵ
    get_binary: function(self: PCefListValue; index: Integer): PCefBinaryValue; stdcall;

    // ��ȡָ������λ�õ��ֵ����͵�ֵ
    get_dictionary: function(self: PCefListValue; index: Integer): PCefDictionaryValue; stdcall;

    // ��ȡָ������λ�õ��б����͵�ֵ
    get_list: function(self: PCefListValue; index: Integer): PCefListValue; stdcall;

    // Sets the value at the specified index. Returns true (1) if the value was
    // set successfully. If |value| represents simple data then the underlying
    // data will be copied and modifications to |value| will not modify this
    // object. If |value| represents complex data (binary, dictionary or list)
    // then the underlying data will be referenced and modifications to |value|
    // will modify this object.
    set_value: function(self: PCefListValue; index: Integer; value: PCefValue): Integer; stdcall;

    // ����ָ������λ��Ϊnullֵ��������óɹ��򷵻�true (1)
    set_null: function(self: PCefListValue; index: Integer): Integer; stdcall;

    // ����ָ������λ��Ϊboolֵ��������óɹ��򷵻�true (1)
    set_bool: function(self: PCefListValue; index, value: Integer): Integer; stdcall;

    // ����ָ������λ��Ϊintֵ��������óɹ��򷵻�true (1)
    set_int: function(self: PCefListValue; index, value: Integer): Integer; stdcall;

    // ����ָ������λ��Ϊdoubleֵ��������óɹ��򷵻�true (1)
    set_double: function(self: PCefListValue; index: Integer; value: Double): Integer; stdcall;

    // ����ָ������λ��Ϊ�ַ���ֵ��������óɹ��򷵻�true (1)
    set_string: function(self: PCefListValue; index: Integer; value: PCefString): Integer; stdcall;

    // ����ָ������λ��Ϊ������ֵ��������óɹ��򷵻�true (1) 
    // �ڵ������������|value|���󽫲�����Ч�����|value|��ǰ����һ������ӵ�У�
    // ���ֵ���ᱻ��������|value|���ò��ᱻ�ı䡣
    // ����, ӵ�й�ϵ����ת�Ƶ���������ϣ�����|value|�����ý���ʧЧ
    set_binary: function(self: PCefListValue; index: Integer; value: PCefBinaryValue): Integer; stdcall;

    // ����ָ��������ֵΪ�ֵ����͵�ֵ��������óɹ��򷵻�true (1)
    // �ڵ������������|value|���󽫲�����Ч�����|value|��ǰ����һ������ӵ�У�
    // ���ֵ���ᱻ��������|value|���ò��ᱻ�ı䡣
    // ����, ӵ�й�ϵ����ת�Ƶ���������ϣ�����|value|�����ý���ʧЧ
    set_dictionary: function(self: PCefListValue; index: Integer; value: PCefDictionaryValue): Integer; stdcall;

    // ����ָ��������ֵΪ�б����͵�ֵ��������óɹ��򷵻�true (1)
    // �ڵ������������|value|���󽫲�����Ч�����|value|��ǰ����һ������ӵ�У�
    // ���ֵ���ᱻ��������|value|���ò��ᱻ�ı䡣
    // ����, ӵ�й�ϵ����ת�Ƶ���������ϣ�����|value|�����ý���ʧЧ
    set_list: function(self: PCefListValue; index: Integer; value: PCefListValue): Integer; stdcall;
  end;

  // �ýṹ��ʱ�첽ִ�������ʵ�֡����task�ʼ�(post)�ɹ������������Ϣѭ����Ȼִ�У�
  // execute()��������Ŀ���߳��б����á����task�ʼ�(post)ʧ�ܣ���task����Դ�̱߳�
  // ���ٶ�����Ŀ���̡߳�������task�������������Ĵ���Ҫ����

  TCefTask = record
    // ���ṹ��
    base: TCefBase;
    // ����Ŀ���߳�ִ�еķ���
    execute: procedure(self: PCefTask); stdcall;
  end;

  // ����ṹ�������ڹ����߳���ִ���첽������Щ�ṹ�庯�����κ��̵߳��ö��ǰ�ȫ�ġ�
  //
  // CEFά�������ڲ��̣߳��û�����ͬ���̼䲻ͬ��������
  // cef_types.h��Ԫ�г���CEF�߳�ͨ�õ�cef_thread_id_t���塣
  // Task runners�ں��ʵ�ʱ��Ҳ���Ա�����CEF�̷߳���(����, V8 WebWorker�߳�).
  TCefTaskRunner = record
    // ���ṹ��
    base: TCefBase;

    // ���|self|��|that|ָ����ͬ��TaskRunner�򷵻�true (1)
    is_same: function(self, that: PCefTaskRunner): Integer; stdcall;

    // ���|self|���Ե�ǰ�̣߳��򷵻�true (1)
    belongs_to_current_thread: function(self: PCefTaskRunner): Integer; stdcall;

    // ���|self|����|threadId|�߳��򷵻�true (1)
    belongs_to_thread: function(self: PCefTaskRunner; threadId: TCefThreadId): Integer; stdcall;

    // �ʼ�(Post)һ��Task����TaskRunner�������߳���ִ�У�task�����ִ�н����첽�ġ�
    post_task: function(self: PCefTaskRunner; task: PCefTask): Integer; stdcall;

    // �ʼ�(Post)һ��Task����TaskRunner�������߳����ӳ�ִ�У�task�����ִ�н����첽�ġ�
    // V8 WebWorker�̲߳�֧���ӳ�task�������Խ��������ӳ١�
    post_delayed_task: function(self: PCefTaskRunner; task: PCefTask; delay_ms: Int64): Integer; stdcall;
  end;

  // ��ʾһ����Ϣ�����Ա������κν��̺��߳�
  TCefProcessMessage = record
    // ���ṹ��
    base: TCefBase;

    // ��������Чʱ����true (1)��������false(0)ʱ����Ҫ�����κ���������
    is_valid: function(self: PCefProcessMessage): Integer; stdcall;

    // ��������ֵ��ֻ�����򷵻�true (1)�� һЩAPI���ܻᷢ��ֻ������
    is_read_only: function(self: PCefProcessMessage): Integer; stdcall;

    // ����һ���ö���Ŀ�д������
    copy: function(self: PCefProcessMessage): PCefProcessMessage; stdcall;

    // ��ȡ��Ϣ�����ƣ����ص��ַ����������cef_string_userfree_free()������
    get_name: function(self: PCefProcessMessage): PCefStringUserFree; stdcall;

    // ��ȡ�����б�
    get_argument_list: function(self: PCefProcessMessage): PCefListValue; stdcall;
  end;

  // ��ʾһ����������ڵ��ࡣ��������������У������ķ����������κ��߳�(����ע
  // �����ر�˵����)�б����á�������Ⱦ������ʱ�������ķ���ֻ���������߳��е���
  TCefBrowser = record
    // ���ṹ��
    base: TCefBase;

    // ��ȡ����������������������������������������б�����
    get_host: function(self: PCefBrowser): PCefBrowserHost; stdcall;

    // �����������Ի��˵������򷵻�true (1)
    can_go_back: function(self: PCefBrowser): Integer; stdcall;

    // ���˵���
    go_back: procedure(self: PCefBrowser); stdcall;

    // ��������������ǰ�������򷵻�true (1)
    can_go_forward: function(self: PCefBrowser): Integer; stdcall;

    // ��ǰ����
    go_forward: procedure(self: PCefBrowser); stdcall;

    // �����������ڱ����أ��򷵻�true (1)
    is_loading: function(self: PCefBrowser): Integer; stdcall;

    // ���¼��ص�ǰҳ
    reload: procedure(self: PCefBrowser); stdcall;

    // ���¼��ص�ǰҳ(�����κλ���)
    reload_ignore_cache: procedure(self: PCefBrowser); stdcall;

    // ֹͣ���ص�ǰҳ
    stop_load: procedure(self: PCefBrowser); stdcall;

    // ���������������ڵ�ȫ��Ψһ��ʶ��
    get_identifier  : function(self: PCefBrowser): Integer; stdcall;

    // ���|self|��|that|ָ����ͬ�������������򷵻�true (1)
    is_same: function(self, that: PCefBrowser): Integer; stdcall;

    // ���������һ���������ڣ��򷵻�true (1)
    is_popup: function(self: PCefBrowser): Integer; stdcall;

    // ����ĵ��Ѿ������ص���������򷵻�true (1)
    has_document: function(self: PCefBrowser): Integer; stdcall;

    // ��ȡ��������ڵ���(����)frame
    get_main_frame: function(self: PCefBrowser): PCefFrame; stdcall;

    // ��ȡ��������ڵ�ǰ��ȡ�����frame
    get_focused_frame: function(self: PCefBrowser): PCefFrame; stdcall;

    // ����ָ����ʶ����ȡframe, ���δ�ҵ��򷵻�NULL
    get_frame_byident: function(self: PCefBrowser; identifier: Int64): PCefFrame; stdcall;

    // ����ָ�����ƻ�ȡframe, ���δ�ҵ��򷵻�NULL
    get_frame: function(self: PCefBrowser; const name: PCefString): PCefFrame; stdcall;

    // ��ȡ��ǰ���ڵ�frame����
    get_frame_count: function(self: PCefBrowser): NativeUInt; stdcall;

    // ��ȡ��ǰ���д���frame�ı�ʶ��
    get_frame_identifiers: procedure(self: PCefBrowser; identifiersCount: PNativeUInt; identifiers: PInt64); stdcall;

    // ���е�ǰ���д���frame�������б�
    get_frame_names: procedure(self: PCefBrowser; names: TCefStringList); stdcall;

    // ��|target_process|ָ���Ľ��̷���һ����Ϣ��������ͳɹ��򷵻�true (1)
    send_process_message: function(self: PCefBrowser; target_process: TCefProcessId;
      message: PCefProcessMessage): Integer; stdcall;
  end;

  // cef_browser_host_t::RunFileDialog�Ļص��ṹ�塣
  // ����ṹ���еĺ���������������̵�UI�߳��б����á�
  TCefRunFileDialogCallback = record
    // ���ṹ��
    base: TCefBase;
    // ���ļ��Ի���رպ��첽���á�|selected_accept_filter|�ǻ���0�����Ĺ�����������
	// ���ѡ��ɹ�����|file_paths|������һ������ֵ��
    // ��ȡ�����ļ��Ի����ģʽ�����ѡ��ȡ������|file_paths|ΪNULL��
    on_file_dialog_dismissed: procedure(self: PCefRunFileDialogCallback;
      selected_accept_filter: Integer; file_paths: TCefStringList); stdcall;
  end;

  // cef_browser_host_t::GetNavigationEntries�Ļص��ṹ�塣
  // ����ṹ���еĺ���������������̵�UI�߳��б����á�
  TCefNavigationEntryVisitor = record
    // ���ṹ��
    base: TCefBase;

    // ����ִ�еķ�������Ҫ������ص�֮�Ᵽ��|entry|�����á�
    // �������true (1)�����������Ŀ(Entry)������ֹͣ���ʡ�
    // ���entry�ǵ�ǰ�����صĵ�����Ŀ����|current|Ϊtrue (1)��
    // |index|�ǻ���0��entry��������|total|��������Ŀ������
    visit: function(self: PCefNavigationEntryVisitor; entry: PCefNavigationEntry;
      current, index, total: Integer): Integer; stdcall;
  end;

  // Callback structure for cef_browser_host_t::PrintToPDF. The functions of this
  // structure will be called on the browser process UI thread.
  TCefPdfPrintCallback = record
    // Base structure.
    base: TCefBase;

    // Method that will be executed when the PDF printing has completed. |path| is
    // the output path. |ok| will be true (1) if the printing completed
    // successfully or false (0) otherwise.
    on_pdf_print_finished: procedure(self: PCefPdfPrintCallback;
      const path: PCefString; ok: Integer); stdcall;
  end;


  // ����ṹ���ʾһ����������ڵ���������̡�
  // ����ṹ���еĺ���������������������б����á�
  // ���ǿ�������������е��κ��߳�(����ע�����ر�˵����)�б����á�
  TCefBrowserHost = record
    // ���ṹ��
    base: TCefBase;

    // ��ȡ�����������������
    get_browser: function(self: PCefBrowserHost): PCefBrowser; stdcall;

    // ����ر���������ڡ�JavaScript�е�'onbeforeunload'�¼�����������
    // ���|force_close|Ϊfalse (0)�����¼�������(�������)���������û�������ʾ��
    // ����Ҳ����ѡ��ȡ���رա�
    // ���|force_close|Ϊtrue (1)���򲻻���ʾ��ʾ�򣬲��ҽ�ֱ�ӹرա�
    // ����¼�����������رջ�|force_close|Ϊtrue (1)������õĽ�������ݸ�
    // cef_life_span_handler_t::do_close()������μ�cef_life_span_handler_t::do_close()�ĵ���
    close_browser: procedure(self: PCefBrowserHost; force_close: Integer); stdcall;

    // ����������Ƿ�۽�
    set_focus: procedure(self: PCefBrowserHost; focus: Integer); stdcall;

    // ���ô��ڰ�����������Ƿ�ɼ�(��С��/��󻯡�app����/��ʾ��)��������Mac OS X��
    set_window_visibility: procedure(self: PCefBrowserHost; visible: Integer); stdcall;

    // ��ȡ���������Ĵ��ھ��
    get_window_handle: function(self: PCefBrowserHost): TCefWindowHandle; stdcall;

    // ��ȡ��������������������ھ��������Ƿǵ��������򷵻�NULL��
    // �����������ģ̬���ڵ��Զ��崦�����ʹ�á�
    get_opener_window_handle: function(self: PCefBrowserHost): TCefWindowHandle; stdcall;

    // �������������Ŀͻ��˶���
    get_client: function(self: PCefBrowserHost): PCefClient; stdcall;

    // ������������������������
    get_request_context: function(self: PCefBrowserHost): PCefRequestContext; stdcall;

    // ��õ�ǰ���ż���Ĭ�ϵ����ű���Ϊ0���˹���ֻ�����û������߳��е��á�
    get_zoom_level: function(self: PCefBrowserHost): Double; stdcall;

    // �����ż������Ϊָ����ֵ��ָ��0�������ż���
    // ����ú�����UI�̱߳����ã�������Ӧ�ñ仯�� ����ñ仯���첽Ӧ�õ�UI�̡߳�
    set_zoom_level: procedure(self: PCefBrowserHost; zoomLevel: Double); stdcall;

    // ��ʾһ���ļ�ѡ��Ի��� ͬһʱ�̾�������ʾһ���ļ�ѡ��Ի���
    // |mode|��ʾ�Ի�����ʾ�����͡�|title|�ǶԻ���ı��⣬���ΪNULL����ʾĬ�ϱ���
    // ("��" �� "����"��ȡ����mode)�� |default_file_path|�ǶԻ���ĳ�ʼĿ¼���ʼ�ļ�����
    // |accept_filters|��һ����Ч��Сд��MIME����("text/*"��"image/*")���ļ���չ��(".txt"��".png")��
	// ���������������չ���Ļ����("Image Types|.png;.gif;.jpg")�������ڹ��˿�ѡ����ļ����͡�
    // |selected_accept_filter|��Ĭ�ϵĹ������Ļ���0��������
	// |callback|���ڶԻ���رպ�ص�(������һ���Ի������ڵȴ���ʾ������������)�ĺ�����
    // ����Ի����첽����UI�߳��г�ʼ����
    run_file_dialog: procedure(self: PCefBrowserHost; mode: TCefFileDialogMode;
      const title, default_file_path: PCefString; accept_filters: TCefStringList;
      selected_accept_filter: Integer; callback: PCefRunFileDialogCallback); stdcall;

    // ʹ��cef_download_handler_t����urlָ�����ļ�
    start_download: procedure(self: PCefBrowserHost; const url: PCefString); stdcall;

    // ��ӡ��ǰ�����������
    print: procedure(self: PCefBrowserHost); stdcall;

    // Print the current browser contents to the PDF file specified by |path| and
    // execute |callback| on completion. The caller is responsible for deleting
    // |path| when done. For PDF printing to work on Linux you must implement the
    // cef_print_handler_t::GetPdfPaperSize function.
    print_to_pdf: procedure(self: PCefBrowserHost; const path: PCefString;
        const settings: PCefPdfPrintSettings; callback: PCefPdfPrintCallback); stdcall;

    // ����|searchText|�ı���|identifier|�ɱ�����ͬʱ���ж��������
    // |forward|ָʾ�Ƿ���ǰ���������ҳ�档 |matchCase|ָʾ�����Ƿ��Ǵ�Сд���е�
    // |findNext|ָʾ�Ƿ��ǵ�һ�����󣬻��Ǻ�������
	// ���������cef_find_handler_tʾ������ͨ��cef_client_t::GetFindHandler���������Ľ����
    find: procedure(self: PCefBrowserHost; identifier: Integer;
        const searchText: PCefString; forward, matchCase, findNext: Integer); stdcall;


    // ȡ����ǰ���ڽ��е���������
    stop_finding: procedure(self: PCefBrowserHost; clearSelection: Integer); stdcall;

    // ������ӵ�д����ϴ򿪿����߹��ߣ� ���|inspect_element_at|��NULL�������(x,y)λ�õ�Ԫ��
    show_dev_tools: procedure(self: PCefBrowserHost; const windowInfo: PCefWindowInfo;
        client: PCefClient; const settings: PCefBrowserSettings;
        const inspect_element_at: PCefPoint); stdcall;

    // �����ǰ�����ʵ���Ѿ������˿����߹��ߴ��ڣ������ر�
    close_dev_tools: procedure(self: PCefBrowserHost); stdcall;

    // ��ȡ��ǰ������Ŀ��һ�����շ��͸�visitor��
    // ���|current_only|Ϊtrue (1)�������ǰ������Ŀ�����ͣ�����������Ŀ���ᱻ���͡�
    get_navigation_entries: procedure(self: PCefBrowserHost;
        visitor: PCefNavigationEntryVisitor; current_only: Integer); stdcall;

    // �����Ƿ���øı������
    set_mouse_cursor_change_disabled: procedure(self: PCefBrowserHost; disabled: Integer); stdcall;

    // ����ѽ��øı�������򷵻�true (1)
    is_mouse_cursor_change_disabled: function(self: PCefBrowserHost): Integer; stdcall;

    // �����ǰ�ɱ༭�ڵ���ѡ����һ��ƴд����ĵ��ʣ�������������������滻Ϊָ����|word|���ʡ�
    replace_misspelling: procedure(self: PCefBrowserHost; const word: PCefString); stdcall;

    // ���һ��ָ����|word|���ʵ�ƴд�ֵ���
    add_word_to_dictionary: procedure(self: PCefBrowserHost; const word: PCefString); stdcall;

    // ���������Ⱦ�����ã��򷵻�true (1)
    is_window_rendering_disabled: function(self: PCefBrowserHost): Integer; stdcall;

    // ֪ͨ��������(widget)�ߴ类�ı䡣����������ȵ���cef_render_handler_t::GetViewRect
    // ����ȡ�³ߴ磬Ȼ�����cef_render_handler_t::OnPaint���첽���ڸ�������
    // ����������ڴ�����Ⱦ������ʱ����Ч��
    was_resized: procedure(self: PCefBrowserHost); stdcall;

    // ֪ͨ������������ػ���ʾ���������������ʱ�����ֺ�
    // cef_render_handler_t::OnPaint֪ͨ��ֹͣ��
    // ����������ڴ�����Ⱦ������ʱ����Ч��
    was_hidden: procedure(self: PCefBrowserHost; hidden: Integer); stdcall;

    // ֪ͨ�������Ļ��Ϣ�����ı䡣������������cef_render_handler_t::GetScreenInfo
    // ��������Ļ��Ϣ������ģ��"��webview���ڴ�һ����ʾ�ƶ�����һ����ʾ"��
    // "�ı䵱ǰ��ʾ����"��Ч����
    // ����������ڴ�����Ⱦ������ʱ����Ч��
    notify_screen_info_changed: procedure(self: PCefBrowserHost); stdcall;

    // ʹviewʧЧ��������������cef_render_handler_t::OnPaint�����첽ˢ�¡�
    // ����������ڴ�����Ⱦ������ʱ����Ч��
    invalidate: procedure(self: PCefBrowserHost; kind: TCefPaintElementType); stdcall;

    // �����������һ�������¼�
    send_key_event: procedure(self: PCefBrowserHost; const event: PCefKeyEvent); stdcall;

    // �����������һ��������¼���|x|��|y|�����������ͼ�����Ͻǡ�
    send_mouse_click_event: procedure(self: PCefBrowserHost;
      const event: PCefMouseEvent; kind: TCefMouseButtonType;
      mouseUp, clickCount: Integer); stdcall;

    // ���������������ƶ��¼���|x|��|y|�����������ͼ�����Ͻǡ�
    send_mouse_move_event: procedure(self: PCefBrowserHost;
        const event: PCefMouseEvent; mouseLeave: Integer); stdcall;

    // �����������һ���������¼���|x|��|y|�����������ͼ�����Ͻǡ�
    // |deltaX|��|deltaY|��ʾ��X��Y�����ϵ�������
    // Ϊ���ܹ����ڲ�select�Ľ��ô�����Ⱦ�ĵ�������Ӧ��ʵ��
    // cef_render_handler_t::GetScreenPoint�ӿ�
    send_mouse_wheel_event: procedure(self: PCefBrowserHost;
        const event: PCefMouseEvent; deltaX, deltaY: Integer); stdcall;

    // �����������һ���۽��¼�
    send_focus_event: procedure(self: PCefBrowserHost; setFocus: Integer); stdcall;

    // �����������һ��ʧȥ����(capture)���¼�
    send_capture_lost_event: procedure(self: PCefBrowserHost); stdcall;

    // ֪ͨ������������ڽ����ƶ���ı�ߴ硣
    // ����������� Windows��Linux����Ч��
    notify_move_or_resize_started: procedure(self: PCefBrowserHost); stdcall;

    // Returns the maximum rate in frames per second (fps) that
    // cef_render_handler_t:: OnPaint will be called for a windowless browser. The
    // actual fps may be lower if the browser cannot generate frames at the
    // requested rate. The minimum value is 1 and the maximum value is 60 (default
    // 30). This function can only be called on the UI thread.
    get_windowless_frame_rate: function(self: PCefBrowserHost): Integer; stdcall;

    // Set the maximum rate in frames per second (fps) that cef_render_handler_t::
    // OnPaint will be called for a windowless browser. The actual fps may be
    // lower if the browser cannot generate frames at the requested rate. The
    // minimum value is 1 and the maximum value is 60 (default 30). Can also be
    // set at browser creation via cef_browser_tSettings.windowless_frame_rate.
    set_windowless_frame_rate: procedure(self: PCefBrowserHost; frame_rate: Integer); stdcall;

    // ��������Ⱦ������ʱ����ȡNSTextInputContextʵ��������Mac�ϵ�IME
    get_nstext_input_context: function(self: PCefBrowserHost): TCefTextInputContext; stdcall;

    // ��ʼһ����ǰͨ��NSTextInputClient���ݵ�KeyDown�¼���
    handle_key_event_before_text_input_client: procedure(self: PCefBrowserHost; keyEvent: TCefEventHandle); stdcall;

    // ��NSTextInputClient�����¼�����һЩ���������
    handle_key_event_after_text_input_client: procedure(self: PCefBrowserHost; keyEvent: TCefEventHandle); stdcall;

    // ���û���ק��굽web��ͼʱ�����������(
    // �ڵ���DragTargetDragOver/DragTargetLeave/DragTargetDrop֮ǰ)�� |drag_data|
    // ��Ӧ�ð�����������ק��web��ͼ���ļ����ݡ��ļ����ݿ���ʹ��
    // cef_drag_data_t::ResetFileContents���Ƴ�(���統|drag_data|����
    // cef_render_handler_t::StartDraggingʱ)��
    // ����������ڴ�����Ⱦ������ʱ����Ч��
    drag_target_drag_enter: procedure(self: PCefBrowserHost;
        drag_data: PCefDragData;
        const event: PCefMouseEvent;
        allowed_ops: TCefDragOperations); stdcall;

    // ������ק����ʱ��ÿ�������web��ͼ���ƶ�ʱ�������������
    // (��DragTargetDragEnter֮���Լ�DragTargetDragLeave/DragTargetDrop֮ǰ)��
    // ����������ڴ�����Ⱦ������ʱ����Ч��
    drag_target_drag_over: procedure(self: PCefBrowserHost;
        const event: PCefMouseEvent;
        allowed_ops: TCefDragOperations); stdcall;

    // ���û���ק����뿪web��ͼʱ�����������(��DragTargetDragEnter֮��)��
    // ����������ڴ�����Ⱦ������ʱ����Ч��
    drag_target_drag_leave: procedure(self: PCefBrowserHost); stdcall;

    // ���û�����ק����ŵ�web��ͼ�������ק����������������(����DragTargetDragEnter��)��
    // ����ק�Ķ�����|drag_data|, ����֮ǰ����DragTargetDragEnterʱ���õĲ�����
    // ����������ڴ�����Ⱦ������ʱ����Ч��
    drag_target_drop: procedure(self: PCefBrowserHost; event: PCefMouseEvent); stdcall;

    // ����cef_render_handler_t::StartDragging��ʼ����ק��������(���ܳɹ�����ȡ��)
    // ʱ������������� |x|��|y|���������ͼ���Ͻǵ����ꡣ���web��ͼ������קԴ
    // Ҳ����קĿ�꣬�����е�DragTarget*����Ӧ����DragSource*����֮ǰ���á�
    // ����������ڴ�����Ⱦ������ʱ����Ч��
    drag_source_ended_at: procedure(self: PCefBrowserHost;
        x, y: Integer; op: TCefDragOperation); stdcall;

    // ����cef_render_handler_t::StartDragging��ʼ����ק��������(���ܳɹ�����ȡ��)
    // ʱ������������������������ֱ�ӵ��ã��������DragSourceEndedAt��ȡ����ק������
    // ���web��ͼ������קԴҲ����קĿ�꣬�����е�DragTarget*����Ӧ����DragSource*
    // ����֮ǰ���á�����������ڴ�����Ⱦ������ʱ����Ч��
    drag_source_system_drag_ended: procedure(self: PCefBrowserHost); stdcall;
  end;

  // ����ṹ�����첽�����ַ���ֵ��ʵ��
  TCefStringVisitor = record
    // ���ṹ��
    base: TCefBase;

    // ��ִ�еķ���
    visit: procedure(self: PCefStringVisitor; const str: PCefString); stdcall;
  end;

  // ����ṹ���ʾ����������е�һ��frame��
  // �������������ʱ��֪���к����������κ��߳�(����ע�����ر�˵����)�б����á�
  // ������Ⱦ����ʱ������ֻ���������߳��е��á�
  TCefFrame = record
    // ���ṹ��
    base: TCefBase;

    // ��������󸽼ӵ�һ����Чframeʱ����True
    is_valid: function(self: PCefFrame): Integer; stdcall;

    // �����frame��ִ�� ���� ����
    undo: procedure(self: PCefFrame); stdcall;

    // �����frame��ִ�� ���� ����
    redo: procedure(self: PCefFrame); stdcall;

    // �����frame��ִ�� ���� ����
    cut: procedure(self: PCefFrame); stdcall;

    // �����frame��ִ�� ���� ����
    copy: procedure(self: PCefFrame); stdcall;

    // �����frame��ִ�� ճ�� ����
    paste: procedure(self: PCefFrame); stdcall;

    // �����frame��ִ�� ɾ�� ����
    del: procedure(self: PCefFrame); stdcall;

    // �����frame��ִ�� ѡ������ ����
    select_all: procedure(self: PCefFrame); stdcall;

    // ����frame��HTMLԴ��һ����ʱ�ļ���Ȼ����Ĭ�ϵ��ı��༭���д�����
    // �������������������������б�����
    view_source: procedure(self: PCefFrame); stdcall;

    // ��ȡframe��HTMLԴ��������Ϊ�ַ������͸�ָ����visitor������
    get_source: procedure(self: PCefFrame; visitor: PCefStringVisitor); stdcall;

    // ��ȡframe����ʾ�ı���������Ϊ�ַ������͸�ָ����visitor������
    get_text: procedure(self: PCefFrame; visitor: PCefStringVisitor); stdcall;

    // ����|request|�����ʾ������
    load_request: procedure(self: PCefFrame; request: PCefRequest); stdcall;

    // ����ָ����|url|
    load_url: procedure(self: PCefFrame; const url: PCefString); stdcall;

    // ����ָ��������|url|��|string_val|�����ݡ�|url|Ӧ����һ����׼��scheme(����http)
    // ����Ϊ(�������ӵ��)��web��ȫ���ƿ�����Ԥ�ڲ�һ����
    load_string: procedure(self: PCefFrame; const stringVal, url: PCefString); stdcall;

    // �����frame��ִ��һ��JavaScript�ַ�����|script_url|�����ǽű��ɱ��ҵ���URL��
    // ������URL���ڣ�����Ⱦ�������������URL����ʾ����Դ��|start_line|������
    // ���������кš�
    execute_java_script: procedure(self: PCefFrame; const code,
      script_url: PCefString; start_line: Integer); stdcall;

    // �����ǰframe����(����)frame�򷵻�true (1)
    is_main: function(self: PCefFrame): Integer; stdcall;

    // ����Ǿ۽�frame,�򷵻�true (1)
    is_focused: function(self: PCefFrame): Integer; stdcall;

    // ��ȡ���frame�����ơ����frame��һ������(����ͨ������iframe��"name"����)
    // �򽫷���������ơ�����Ϊ���frame�������ĸ�frame����һ��Ψһ���ơ�
    // ��(����)frame���Ƿ���NULL��
    // ���صĽ���������cef_string_userfree_free()������
    get_name: function(self: PCefFrame): PCefStringUserFree; stdcall;

    // ��ȡ���frameȫ��Ψһ�ı�ʶ��
    get_identifier: function(self: PCefFrame): Int64; stdcall;

    // �������frame�ĸ�frame���������(����)frame�򷵻�NULL��
    get_parent: function(self: PCefFrame): PCefFrame; stdcall;

    // ��ȡ��ǰ���ص����frame��URL
    // ���صĽ���������cef_string_userfree_free()������
    get_url: function(self: PCefFrame): PCefStringUserFree; stdcall;

    // ��ȡ���frame���������������
    get_browser: function(self: PCefFrame): PCefBrowser; stdcall;

    // ��ȡ���frame������V8�����ġ����������������Ⱦ�����б����á�
    get_v8context: function(self: PCefFrame): PCefv8Context; stdcall;

    // ����DOM�ĵ������������������Ⱦ�����б����á�
    visit_dom: procedure(self: PCefFrame; visitor: PCefDomVisitor); stdcall;
  end;

  // ����ṹ������ʵ��һ���Զ�����Դbundle�ṹ�塣��Щ���������ڶ��߳��е��á�
  TCefResourceBundleHandler = record
    // ���ṹ��
    base: TCefBase;

    // ͨ��ָ��|string_id|Ϊ�ַ�����ȡ���ط��롣
    // ����ṩ�˷��룬������|string|Ϊ�����ַ����������� true (1)�����ʹ��Ĭ��
    // �����򷵻�false (0)��cef_pack_strings.h�г�������֧�ֵ���ϢID��
    get_localized_string: function(self: PCefResourceBundleHandler;
      string_id: Integer; string_val: PCefString): Integer; stdcall;

    // ͨ��|resource_id|������Դ���ݡ�����ṩ����Դ��������|data|��|data_size|
    // Ϊ����ָ��ͳ��ȣ�������true (1)�����ʹ��Ĭ����Դ���ݣ��򷵻� false (0)��
    // �����Դ���ݲ��ᷢ�����������ұ��뱣�����ڴ��С�
    // cef_pack_resources.h�г�������֧�ֵ���ԴID��
    get_data_resource: function(self: PCefResourceBundleHandler;
        resource_id: Integer; var data: Pointer; var data_size: NativeUInt): Integer; stdcall;

    // Called to retrieve data for the specified |resource_id| nearest the scale
    // factor |scale_factor|. To provide the resource data set |data| and
    // |data_size| to the data pointer and size respectively and return true (1).
    // To use the default resource data return false (0). The resource data will
    // not be copied and must remain resident in memory. Include
    // cef_pack_resources.h for a listing of valid resource ID values.
    get_data_resource_for_scale: function(self: PCefResourceBundleHandler;
      resource_id: Integer; scale_factor: TCefScaleFactor; out data: Pointer;
      data_size: NativeUInt): Integer; stdcall;
  end;

  // ����ṹ�����ڴ�������������в�������Windowsϵͳ����'--'��'-'��'/'��Ϊǰ׺
  // ����Ϊ�ǿ��ء��������������������ǿ���ǰ׺�Ĳ�����
  // ���ؿ�����һ��ʹ��'='�ָ���ֵ(����-switch=value)��
  // һ��"--"�������սῪ�ؼ�����token�Ľ���������ǰ׺��������Ϊ�ǿ��ز�����
  // ���������Ǵ�Сд���еġ�����ṹ�������cef_initialize()������֮ǰʹ�á�

  TCefCommandLine = record
    // ���ṹ��
    base: TCefBase;

    // ������������Ч�򷵻�true (1)��������falseʱ��Ҫ��������������
    is_valid: function(self: PCefCommandLine): Integer; stdcall;

    // ���������ֻ���ģ��򷵻�true (1)��ĳЩAPI���Ա�¶һЩֻ���ӿڡ�
    is_read_only: function(self: PCefCommandLine): Integer; stdcall;

    // ���ظö����һ����д����
    copy: function(self: PCefCommandLine): PCefCommandLine; stdcall;

    // ʹ��|argc|��|argv|����ʼ�������С���һ�����������ǳ�������ơ�
    // ���������֧�ַ�Windowsƽ̨��
    init_from_argv: procedure(self: PCefCommandLine; argc: Integer; const argv: PPAnsiChar); stdcall;

    // ʹ��GetCommandLineW()���ص��ַ�������ʼ��������
    // ���������֧��Windowsϵͳ��
    init_from_string: procedure(self: PCefCommandLine; command_line: PCefString); stdcall;

    // ���������п��غͲ����������³���δ�ı�Ĳ��֡�
    reset: procedure(self: PCefCommandLine); stdcall;

    // ��ȡԭʼ�������ַ�����һ���б��С����argv�����ʽ��
    // { program, [(--|-|/)switch[=value]]*, [--], [argument]* }
    get_argv: procedure(self: PCefCommandLine; argv: TCefStringList); stdcall;

    // ���첢����һ���������ַ����������ʹ�������������Ϊ���ù�ϵ�ǲ�����ġ�
    // ����ַ����������cef_string_userfree_free()������
    get_command_line_string: function(self: PCefCommandLine): PCefStringUserFree; stdcall;

    // ��ȡ�������г���·������(��һ��)��
    // ����ַ����������cef_string_userfree_free()������
    get_program: function(self: PCefCommandLine): PCefStringUserFree; stdcall;

    // �����������г���·������ (��һ��)��
    set_program: procedure(self: PCefCommandLine; program_: PCefString); stdcall;

    // ����������а������أ��򷵻�true (1)
    has_switches: function(self: PCefCommandLine): Integer; stdcall;

    // ����������а���nameָ���Ŀ��أ��򷵻�true (1)
    has_switch: function(self: PCefCommandLine; const name: PCefString): Integer; stdcall;

    // ����ָ��name���ع�����ֵ������������û��ֵ�����߲������򷵻�NULL�ַ�����
    // ����ַ����������cef_string_userfree_free()������
    get_switch_value: function(self: PCefCommandLine; const name: PCefString): PCefStringUserFree; stdcall;

    // ���ؿ������ƺ�ֵ��ӳ����������û��ֵ��������NULL�ַ�����
    get_switches: procedure(self: PCefCommandLine; switches: TCefStringMap); stdcall;

    // ���һ�����ص������е�β�����������û��ֵ���򴫵�NULL�ַ�����
    append_switch: procedure(self: PCefCommandLine; const name: PCefString); stdcall;

    // ���һ��ָ����ֵ�Ŀ��ص������е�β��
    append_switch_with_value: procedure(self: PCefCommandLine; const name, value: PCefString); stdcall;

    // ������������в����ⷵ��True
    has_arguments: function(self: PCefCommandLine): Integer; stdcall;

    // ��ȡ���ֵ������в���
    get_arguments: procedure(self: PCefCommandLine; arguments: TCefStringList); stdcall;

    // ���һ�������������е�β��
    append_argument: procedure(self: PCefCommandLine; const argument: PCefString); stdcall;

    // �ڵ�ǰ����֮ǰ����һ������첽���ڵ���ǰ������ "valgrind" �� "gdb --args".
    prepend_wrapper: procedure(self: PCefCommandLine; const wrapper: PCefString); stdcall;
  end;


  // ����ṹ������ʵ����������̵Ļص�������ṹ��ĺ���������������̵����߳�
  // �е���(�����ر�ָ��)��
  TCefBrowserProcessHandler = record
    // ���ṹ��
    base: TCefBase;

    // ����������̵�UI�߳��У�CEF�����ı���ʼ�����������á�
    on_context_initialized: procedure(self: PCefBrowserProcessHandler); stdcall;

    // ��һ���ӽ��̱�����ʱ���á�������һ����Ⱦ�����Լ�����һ��GPU��������ʱ
    // ����������̵�UI�߳��б����á��ṩһ���޸��ӽ��������в����Ļ��ᡣ
    // ��Ҫ����������ⲿ����|command_line|�����á�
    on_before_child_process_launch: procedure(self: PCefBrowserProcessHandler;
      command_line: PCefCommandLine); stdcall;

    // ��һ���µ���Ⱦ���������̴߳���֮���������IO�߳��б����á�
    // �ṩһ��Ϊ��Ⱦ���̵�cef_render_process_handler_t::on_render_thread_created()
    // ���ݶ�������Ļ��ᡣ
    // ��Ҫ����������ⲿ����|extra_info|�����á�
    on_render_process_thread_created: procedure(self: PCefBrowserProcessHandler;
        extra_info: PCefListValue); stdcall;

    // ��Linux�Ϸ���һ����ӡ�������������ӡ������δ�ṩ������Linux�Ͻ���֧�ִ�ӡ��
    get_print_handler: function(self: PCefBrowserProcessHandler): PCefPrintHandler; stdcall;
  end;

  // ����ṹ������ʵ����Ⱦ���̵Ļص�������ṹ��ĺ�������Ⱦ���̵����߳�
  // (TID_RENDERER)�б����ã���������˵����
  TCefRenderProcessHandler = record
    // ���ṹ��
    base: TCefBase;

    // ����Ⱦ���̵����̱߳���������á�|extra_info|��һ��ֻ��ֵ��������
    // cef_browser_process_handler_t::on_render_process_thread_created()��
    // ��Ҫ���������֮�Ᵽ��|extra_info|�����á�
    on_render_thread_created: procedure(self: PCefRenderProcessHandler;
      extra_info: PCefListValue); stdcall;

    // ��WebKit��ʼ���󱻵���
    on_web_kit_initialized: procedure(self: PCefRenderProcessHandler); stdcall;

    // �������������֮�󱻵��á�������ͬ��ʶ���ľ������������ǰ���µĿ��������������ʱ��
    on_browser_created: procedure(self: PCefRenderProcessHandler;
      browser: PCefBrowser); stdcall;

    // ��һ�������������֮ǰ
    on_browser_destroyed: procedure(self: PCefRenderProcessHandler;
      browser: PCefBrowser); stdcall;

    // ����������ļ���״̬�¼�������
    get_load_handler: function(self: PCefRenderProcessHandler): PCefLoadHandler; stdcall;

    // �����������֮ǰ�����á������ȡ�������򷵻�true (1)������������򷵻�
    // false (0)���ڻص���|request|�����ܱ��޸ġ�
    on_before_navigation: function(self: PCefRenderProcessHandler;
      browser: PCefBrowser; frame: PCefFrame; request: PCefRequest;
      navigation_type: TCefNavigationType; is_redirect: Integer): Integer; stdcall;

    // ��frame��V8�����Ĵ��������������á�Ҫ��ȡJavaScript��'window'���󣬿���ʹ��
    // cef_v8context_t::get_global() ������V8�Ĵ���������ڴ��������߳��ڷ��ʡ�
    // Ҫ��ȡ�����ʼ�(post)task���񵽹����̵߳�TaskRunner,����ʹ��
    // cef_v8context_t::get_task_runner()������
    on_context_created: procedure(self: PCefRenderProcessHandler;
      browser: PCefBrowser; frame: PCefFrame; context: PCefv8Context); stdcall;

    // ��frame��V8�������ͷ�ʱ���������á���Ҫ���������֮�Ᵽ��|context|�����á�
    on_context_released: procedure(self: PCefRenderProcessHandler;
      browser: PCefBrowser; frame: PCefFrame; context: PCefv8Context); stdcall;

    // ��frame�в���ȫ��δ�����쳣ʱ�����á�Ĭ������ص��Ǳ����õġ�
    // Ҫ��������������CefSettings.uncaught_exception_stack_size > 0.
    on_uncaught_exception: procedure(self: PCefRenderProcessHandler;
      browser: PCefBrowser; frame: PCefFrame; context: PCefv8Context;
      exception: PCefV8Exception; stackTrace: PCefV8StackTrace); stdcall;

    // ���������һ���½ڵ��ý���ʱ�����á����û��ָ���Ľڵ��ý��㣬|node|ֵ����ΪNULL��
    // ������ݸ�������node�����ʾ����ִ��ʱDOM���ա�
    // DOM������������������������Ч����Ҫ����������������Ᵽ���������ã��Լ���������
    on_focused_node_changed: procedure(self: PCefRenderProcessHandler;
      browser: PCefBrowser; frame: PCefFrame; node: PCefDomNode); stdcall;

    // ���յ�������һ�����̵���Ϣʱ�����á������Ϣ�������ⷵ��true�����򷵻�false (0)��
    // ��Ҫ�������������������message
    on_process_message_received: function(self: PCefRenderProcessHandler;
      browser: PCefBrowser; source_process: TCefProcessId;
      message: PCefProcessMessage): Integer; stdcall;
  end;

  // ����ṹ���ṩ���¼���������ʵ�֣���������ָ���Ľ��̺�/���߳��е��á�
  TCefApp = record
    // ���ṹ��
    base: TCefBase;

    // �ṩ��һ����CEF��Chromium���������в���֮ǰ�鿴/�޸������в����Ļ��ᡣ
    // ������������̣�|process_type|ֵ����ΪNULL��
    // ��Ҫ���������֮�Ᵽ��cef_command_line_t��������á�
    // CefSettings.command_line_args_disabled��ֵ�ɱ���������һ��NULL�����ж���
    // CefSettings�е��κ�һ��ֵ��ͬ���ڵ����������֮ǰ�����õ������в�����
    // ��ʹ���������Ϊ������������޸������в���ʱҪ��������Ϊ����ܵ���δ֪������ǳ��������
    on_before_command_line_processing: procedure(self: PCefApp; const process_type: PCefString;
      command_line: PCefCommandLine); stdcall;

    // �ṩһ��ע���Զ���scheme�Ļ��ᡣ��Ҫ����|registrar|��������á�
    // ���������ÿ�����̵����߳��б����ã�ע���scheme���������н����з��ʡ�
    on_register_custom_schemes: procedure(self: PCefApp; registrar: PCefSchemeRegistrar); stdcall;

    // ��ȡ��Դbundle�¼��Ĵ����������CefSettings.pack_loading_disabledΪtrue (1)��
    // ����뷵��һ�������������û�з��ش�����������Դ����pack�ļ��м��ء�
    // ������������������Ⱦ���̵Ķ��߳��б����á�
    get_resource_bundle_handler: function(self: PCefApp): PCefResourceBundleHandler; stdcall;

    // ��ȡ��������̵Ĵ������������������������̵Ķ��߳��б����á�
    get_browser_process_handler: function(self: PCefApp): PCefBrowserProcessHandler; stdcall;

    // ��ȡ��Ⱦ���̵Ĵ������������������Ⱦ���̵����߳��б����á�
    get_render_process_handler: function(self: PCefApp): PCefRenderProcessHandler; stdcall;
  end;


  // ����ṹ�����ڴ����¼�������������������ڡ���������˵������Щ��������UI�߳��б����á�
  TCefLifeSpanHandler = record
    // ���ṹ��
    base: TCefBase;

    // ��һ���µĵ������ڱ�����ʱ����IO�߳��б����á�|browser|��|frame|������ʾ
    // ���������Դ���������û��ָ����|target_url|��|target_frame_name|��ֵ����ΪNULL��
	// |target_disposition|��ֵָʾ�û�������򿪵ĵ���(���� ��ǰtab �� ��tab ��)��
    // ���������ͨ���û��ֶ���(������������)����|user_gesture|��ֵΪtrue(1)��
    // ��������Զ���(����ͨ��DomContentLoaded�¼�)�򿪣���ֵΪfalse (0)��
    // |popupFeatures|�ṹ������˱�����ĵ�����Ϣ��
    // Ҫ������һ�������������޸�(��ѡ)|windowInfo|��|client|��|settings|��
    // |no_javascript_access|��������false (0)��Ҫȡ�������Ĵ������򷵻�true (1)��
    // |client|��|settings|��ֵ����Դ�������Ĭ��ֵ��
    // |no_javascript_access|ֵָʾ�µ�����������Ƿ��ǿɽű����ģ�����ͬԴ���������ͬ���̡�
    on_before_popup: function(self: PCefLifeSpanHandler;
      browser: PCefBrowser; frame: PCefFrame;
      const target_url, target_frame_name: PCefString;
      target_disposition: TCefWindowOpenDisposition; user_gesture: Integer;
      const popupFeatures: PCefPopupFeatures;
      windowInfo: PCefWindowInfo; var client: PCefClient;
      settings: PCefBrowserSettings; no_javascript_access: PInteger): Integer; stdcall;

    // ��һ��������������������
    on_after_created: procedure(self: PCefLifeSpanHandler; browser: PCefBrowser); stdcall;

    // ��һ��ģ̬���ڽ�Ҫ��ʾ������ģ̬ѭ����Ҫ����ʱ�����á�
    // ���Ҫʹ��Ĭ�ϵ�ģ̬ѭ��ʵ���򷵻�false (0)�����Ҫʹ���Զ���ʵ���򷵻�true (1)
    run_modal: function(self: PCefLifeSpanHandler; browser: PCefBrowser): Integer; stdcall;

    // ����������յ��ر�����ʱ�����á��������ǵ���cef_browser_host_t::close_browser()
    // ���û����Թرմ��ڲ������¼���
    // �����������JavaScript��'onunload'�¼�������֮�󱻵��á�
    // �ڹ�����OS���ڱ����ٺ���������ᱻ��������¼�(��������ٿ����л���ȡ���ر�)��
    //
    // ���CEFΪ���������һ��OS���ڣ�����false (0)��������������ڵĶ���ӵ���� will send
    // (���磬��Windows�е�WM_CLOSE��OS-X�е�performClose��Linux�е�"delete_event")����
    // һ��OS�ر�֪ͨ��
    // ���������OS����(������Ⱦ������)������false (0)������������������������٣�
    // ����Return true (1)ʱ���������������Ƶ���һ�����ڣ�����Щ������Ҫͨ����
    // ��׼�������رա�
    //
    // ���һ��Ӧ�ó����ṩ�����Լ��Ķ��㴰�ڣ���Ӧ��ͨ������cef_browser_host_t::CloseBrowser(false (0))
    // ������OS�ر�֪ͨ��������ֱ�ӹرմ���(�μ������ʾ��)���������CEFһ������
    // ������'onbeforeunload'�¼������ҿ�����do_close()������֮ǰȡ���رա�
    //
    // cef_life_span_handler_t::on_before_close()�������������������֮ǰ���������á�
    // Ӧ�ó���Ӧ���ڵ���on_before_close()�����������������������뿪(exit)��
    //
    // ����������ʾһ��ģ̬���ڣ�������in cef_life_span_handler_t::run_modal()
    // ���ṩ��һ���Զ����ģ̬ѭ��ʵ�֣�����ص�Ӧ�����ڻ�ԭ���ߴ��ڵ�״̬��
    //
    // �����ʾ�����������ڣ���������һ��Ӧ�ó����ṩ�Ķ���OS���ڣ����ڼ����ر�ʱ��
    // 1.  �û�����˴��ڹرհ�ť��������OS�ر�֪ͨ (���磬��Windows�е�WM_CLOSE��
    //     OS-X�е�performClose��Linux�е�"delete_event").
    // 2.  Ӧ�ó���Ķ��㴰���յ��˹ر�֪ͨ������:
    //     A. ����CefBrowserHost::CloseBrowser(false).
    //     B. ȡ�����ڹر�.
    // 3.  JavaScript��'onbeforeunload'��������ִ�У�������ʾ��һ��ȷ�ϹرնԻ���
    //     (�öԻ���ɱ�CefJSDialogHandler::OnBeforeUnloadDialog()����)��
    // 4.  �û���׼�رա�
    // 5.  JavaScript��'onunload'��������ִ��
    // 6.  Ӧ�ó���� do_close()�����������á�Ӧ�ó���:
    //     A. ����һ����־��ָʾ��һ���رճ��Խ�������
    //     B. ����false��
    // 7.  CEF����OS�ر�֪ͨ��
    // 8.  Ӧ�ó���Ķ��㴰�ڽ��յ�OS�ر�֪ͨ�����������ڹر�(���ڲ���6���õı�־)��
    // 9.  �����OS���ڱ����١�
    // 10. Ӧ�ó����cef_life_span_handler_t::on_before_close()�����������ã�����
    //     ������������١�
    // 11. ���û�������������Ӧ�ó���ͨ������cef_quit_message_loop()���뿪��
    do_close: function(self: PCefLifeSpanHandler; browser: PCefBrowser): Integer; stdcall;

    // �������������֮ǰ�����á��ͷ����й���������������ϵ����ã�������������غ�
    // ��Ҫ������������ϳ���ִ���κκ������������һ��ģ̬���ڣ�������run_modal()
    // ���ṩ���Զ���ģ̬ѭ��ʵ�֣�����ص�Ӧ�������뿪�Զ���ģ̬ѭ����
    // �μ������do_close()�ĵ�˵����
    on_before_close: procedure(self: PCefLifeSpanHandler; browser: PCefBrowser); stdcall;
  end;


  // ����ṹ�����ڴ����¼������������������״̬����Щ����������UI�߳��б�����
  TCefLoadHandler = record
    // ���ṹ��
    base: TCefBase;

    // ������״̬�����ı�ʱ�����á�����ص�����ִ������ -- һ���ǵ����ر�������û���ʼ����ʱ��
    // ��һ�����ڼ���������ɡ�ʧ��ʱȡ�����¼�����ֹʱ��
    on_loading_state_change: procedure(self: PCefLoadHandler;
      browser: PCefBrowser; isLoading, canGoBack, canGoForward: Integer); stdcall;

    // ���������ʼ����һ��frameʱ�����á�|frame|ֵ��Զ������NULL -- ����is_main()
    // ������������frame�ǲ�����frame��
    // ���frame���Ա�ͬʱ���ء���frame��������frame���ؽ�����ʼ��������ء�
    // �����������frameʧ��ʱ��������������ܲ���Ϊ���frame�����á�
    // Ҫ֪ͨ�������������״̬����ʹ��OnLoadingStateChange��
    on_load_start: procedure(self: PCefLoadHandler;
      browser: PCefBrowser; frame: PCefFrame); stdcall;

    // �����������frame��ɺ󱻵��á�|frame|ֵ��Զ������NULL -- ����is_main()
    // ������������frame�ǲ�����frame��
    // ���frame���Ա�ͬʱ���ء���frame��������frame���ؽ�����ʼ��������ء�
    // ���������Ƿ�ɹ���ɣ�����Ϊ����frame�������������
    on_load_end: procedure(self: PCefLoadHandler; browser: PCefBrowser;
      frame: PCefFrame; httpStatusCode: Integer); stdcall;

    // ��һ������������Դʧ�ܻ�ȡ��ʱ�����á�
    // |errorCode|�Ǵ����, |errorText|�Ǵ����ı���|failedUrl|�Ǽ���ʧ�ܵ�URL��
    // Ҫ��ȡ�����Ĵ���ŵ���������μ�net\base\net_error_list.h
    on_load_error: procedure(self: PCefLoadHandler; browser: PCefBrowser;
      frame: PCefFrame; errorCode: Integer; const errorText, failedUrl: PCefString); stdcall;
  end;

  // ͨ�õ��첽"�Ƿ����"�ص��ṹ��
  TCefCallback = record
    // ���ṹ��
    base: TCefBase;

    // ��������
    cont: procedure(self: PCefCallback); stdcall;

    // ȡ������
    cancel: procedure(self: PCefCallback); stdcall;
  end;

  // ͨ�õ��첽"���"�ص��ṹ��
  TCefCompletionCallback = record
    // ���ṹ��
    base: TCefBase;
    // ���������ʱ�����õķ���
    on_complete: procedure(self: PCefCompletionCallback); stdcall;
  end;


  // ����ṹ������ʵ���Զ����������������Щ����������IO�߳��б����á�
  TCefResourceHandler = record
    // ���ṹ��
    base: TCefBase;

    // ��ʼ��������Ҫ���������뷵��true (1)�����ҵ���һ��cef_callback_t::cont()
    // ��ʹ��Ӧͷ��Ϣ����Ч��(���ͷ��Ϣ��ֱ�ӿɻ�õģ����������������ڵ���cef_callback_t::cont()).
    // Ҫȡ�������򷵻�false (0)��
    process_request: function(self: PCefResourceHandler;
      request: PCefRequest; callback: PCefCallback): Integer; stdcall;

    // ��ȡ��Ӧͷ��Ϣ�������Ӧ����δ֪������|response_length|Ϊ-1������read_response()
    // ��������ֱ������false (0)�������Ӧ�̶���֪��������|response_length|Ϊһ��
    // ��ֵ������read_response()��������ֱ������false(0)����ָ���������ֽڱ���ȡ��
    // ʹ��|response|����������mime���͡�http״̬���������ѡͷֵ��
    // Ҫ�ض�������һ���µ�URL��������|redirectUrl|Ϊһ����URL��
    get_response_headers: procedure(self: PCefResourceHandler;
      response: PCefResponse; response_length: PInt64; redirectUrl: PCefString); stdcall;

    // ��ȡ��Ӧ���ݡ���������ǿ�������õ��򿽱�|bytes_to_read|�ֽ����ݵ�|data_out|��
    // ����|bytes_read|Ϊ�������ֽ�������������true (1)��
    // Ҫ�ӳ�һ��ʱ���ȡ���ݣ�������|bytes_read|Ϊ0�����ҷ���true (1)��ͬʱ
    // �����ݵ���ʱ����cef_callback_t::cont()��Ҫָʾ��Ӧ����򷵻�false (0)��
    read_response: function(self: PCefResourceHandler;
      data_out: Pointer; bytes_to_read: Integer; bytes_read: PInteger;
        callback: PCefCallback): Integer; stdcall;

    // ���������Է���ָ����cookie�򷵻�true (1)�����򷵻�false (0)��������κ�
    // cookie����false (0)��������󲻻ᷢ��cookie��
    can_get_cookie: function(self: PCefResourceHandler;
      const cookie: PCefCookie): Integer; stdcall;

    // ������ص���Ӧ��ָ����cookie�ɱ������򷵻�true (1)�����򷵻�false (0)��
    can_set_cookie: function(self: PCefResourceHandler;
      const cookie: PCefCookie): Integer; stdcall;

    // ������ȡ��
    cancel: procedure(self: PCefResourceHandler); stdcall;
  end;

  // ����ص��ṹ��������Ȩ������첽�����ص�
  TCefAuthCallback = record
    // ���ṹ��
    base: TCefBase;

    // ������Ȩ����
    cont: procedure(self: PCefAuthCallback;
        const username, password: PCefString); stdcall;

    // ȡ����Ȩ����
    cancel: procedure(self: PCefAuthCallback); stdcall;
  end;

  // ����ص��ṹ������quota������첽�����ص�
  TCefRequestCallback = record
    // ���ṹ��
    base: TCefBase;

    // ����quota�������|allow|Ϊtrue (1)�������󽫱������������󽫱��ܾ�
    cont: procedure(self: PCefRequestCallback; allow: Integer); stdcall;
    // ȡ��quota����
    cancel: procedure(self: PCefRequestCallback); stdcall;
  end;

// ����ṹ�����ڴ�������������������¼�����Щ��������ָ�����߳��б����á�
  TCefRequestHandler = record
    // ���ṹ��
    base: TCefBase;

    // �����������֮ǰ��UI�߳��е��á�Ҫȡ�������뷵��true (1)�����򷵻�False(0)������
    // |request|������������ص��б��޸ġ�
    // �����г����У�cef_load_handler_t::OnLoadingStateChange�ᱻ�������Ρ�
    // �����������cef_load_handler_t::OnLoadStart��cef_load_handler_t::OnLoadEnd
    // �������á� ���������ȡ����cef_load_handler_t::OnLoadError�������ã�
    // |errorCode|ֵΪERR_ABORTED��
    on_before_browse: function(self: PCefRequestHandler; browser: PCefBrowser;
     frame: PCefFrame; request: PCefRequest; isRedirect: Integer): Integer; stdcall;

    // Called on the UI thread before OnBeforeBrowse in certain limited cases
    // where navigating a new or different browser might be desirable. This
    // includes user-initiated navigation that might open in a special way (e.g.
    // links clicked via middle-click or ctrl + left-click) and certain types of
    // cross-origin navigation initiated from the renderer process (e.g.
    // navigating the top-level frame to/from a file URL). The |browser| and
    // |frame| values represent the source of the navigation. The
    // |target_disposition| value indicates where the user intended to navigate
    // the browser based on standard Chromium behaviors (e.g. current tab, new
    // tab, etc). The |user_gesture| value will be true (1) if the browser
    // navigated via explicit user gesture (e.g. clicking a link) or false (0) if
    // it navigated automatically (e.g. via the DomContentLoaded event). Return
    // true (1) to cancel the navigation or false (0) to allow the navigation to
    // proceed in the source browser's top-level frame.
    on_open_urlfrom_tab: function(self: PCefRequestHandler; browser:PCefBrowser;
      frame: PCefFrame; const target_url: PCefString;
      target_disposition: TCefWindowOpenDisposition; user_gesture: Integer): Integer; stdcall;

    // ��һ����Դ������֮ǰ��IO�߳��б����á�|request|������Ա��޸ġ�
    // Ҫȡ�������뷵��true (1)�����򷵻�false (0)��
    on_before_resource_load: function(self: PCefRequestHandler;
      browser: PCefBrowser; frame: PCefFrame; request: PCefRequest;
      callback: PCefRequestCallback): TCefReturnValue; stdcall;

    // ��һ����Դ������֮ǰ��IO�߳��б����á�Ҫ��������������Դ�뷵��NULL��
    // �ú���Ϊ��Դָ��һ��cef_resource_handler_t���͵Ĵ�������
    // |request|����Ӧ��������ص��б��޸ġ�
    get_resource_handler: function(self: PCefRequestHandler;
      browser: PCefBrowser; frame: PCefFrame; request: PCefRequest): PCefResourceHandler; stdcall;

    // ����Դ���ر��ض���ʱ��IO�߳��б����á�|old_url|Ϊ��URL��|new_url|Ϊ�µ�URL��
    // ��URL���Ա��޸�
    on_resource_redirect: procedure(self: PCefRequestHandler;
      browser: PCefBrowser; frame: PCefFrame; const request: PCefRequest;
      new_url: PCefString); stdcall;

    // Called on the IO thread when a resource response is received. To allow the
    // resource to load normally return false (0). To redirect or retry the
    // resource modify |request| (url, headers or post body) and return true (1).
    // The |response| object cannot be modified in this callback.
    on_resource_response: function(self: PCefRequestHandler;
        browser: PCefBrowser; frame: PCefFrame; request: PCefRequest;
        response: PCefResponse): Integer; stdcall;

    // ���������Ҫ���û������ȡ֤��ʱ��IO�߳��б����á�
    // |isProxy|ָʾ�����Ƿ���һ�������������|host|Ϊ��������|port|Ϊ�˿ںš�
    // �������true (1)��������󣬵���Ȩ��Ϣ����ʱ����cef_auth_callback_t::cont()������
    // ����false (0)��ȡ���������
    get_auth_credentials: function(self: PCefRequestHandler;
      browser: PCefBrowser; frame: PCefFrame; isProxy: Integer; const host: PCefString;
      port: Integer; const realm, scheme: PCefString; callback: PCefAuthCallback): Integer; stdcall;

    // ��JavaScriptͨ��webkitStorageInfo.requestQuota����������һ��storage��quota�ߴ�
    // ʱ�����á�|origin_url|�Ƿ��������ҳ���Դ��|new_size|�������quota�ߴ�(�ֽ�)��
    // ����true (1)�����������������֮��һ��ʱ�����cef_quota_callback_t::cont()
    // �������ܾ����󡣷���false (0)��ȡ���������
    on_quota_request: function(self: PCefRequestHandler; browser: PCefBrowser;
      const origin_url: PCefString; new_size: Int64; callback: PCefRequestCallback): Integer; stdcall;

    // ������һ��δ֪Э���URLʱ��UI�̱߳����á�
    // ����|allow_os_execution|Ϊtrue (1)������ͨ��ע���OSЭ�鴦����(�������)ִ�С�
    // ��ȫ����:
    //   �������ִ��֮ǰ����Ӧ������������ж�URL��SCHEME��HOST��URL������������ǿ������
    on_protocol_execution: procedure(self: PCefRequestHandler;
      browser: PCefBrowser; const url: PCefString; allow_os_execution: PInteger); stdcall;

    // �������URL����һ����Ч��SSL֤��ʱ��������
    // ����true (1)�����������������֮��һ��ʱ�����cef_allow_certificate_error_callback_t::cont()
    // ��������ܾ����󡣷���false (0)��ֱ��ȡ������
    // ���|callback|ΪNULL���򵱷�������ʱ�������Զ�ȡ����
    // �������CefSettings.ignore_certificate_errorsΪtrue, ��������Ч��֤�鶼��
    // �����ܲ��Ҳ���������������
    on_certificate_error: function(self: PCefRequestHandler;
      browser: PCefBrowser; cert_error: TCefErrorcode;
      const request_url: PCefString; ssl_info: PCefSslInfo;
      callback: PCefRequestCallback): Integer; stdcall;

    // ��һ���������ʱ����������̵�UI�߳��б�������
    // |plugin_path|�Ǳ����Ĳ�����ļ�·��
    on_plugin_crashed: procedure(self: PCefRequestHandler; browser: PCefBrowser;
      const plugin_path: PCefString); stdcall;

    // Called on the browser process UI thread when the render view associated
    // with |browser| is ready to receive/handle IPC messages in the render
    // process.
    on_render_view_ready: procedure(self: PCefRequestHandler; browser: PCefBrowser); stdcall;

    // ��ѡ�˽��̷�Ԥ�ڽ��������������UI�����б�������
    // |status|ֻ�ǽ�����ֹ��ԭ��
    on_render_process_terminated: procedure(self: PCefRequestHandler; browser: PCefBrowser;
      status: TCefTerminationStatus); stdcall;
  end;

  // ����ṹ�����ڴ����������ʾ״̬����Щ����������UI�߳��б����á�
  TCefDisplayHandler = record
    // ���ṹ��
    base: TCefBase;

    // ��frame�ĵ�ַ�����ı�ʱ������
    on_address_change: procedure(self: PCefDisplayHandler;
      browser: PCefBrowser; frame: PCefFrame; const url: PCefString); stdcall;

    // ��ҳ����ⷢ�͸ı�ʱ������
    on_title_change: procedure(self: PCefDisplayHandler;
        browser: PCefBrowser; const title: PCefString); stdcall;

    // Called when the page icon changes.
    on_favicon_urlchange: procedure(self: PCefDisplayHandler;
        browser: PCefBrowser; icon_urls: TCefStringList); stdcall;

    // Called when web content in the page has toggled fullscreen mode. If
    // |fullscreen| is true (1) the content will automatically be sized to fill
    // the browser content area. If |fullscreen| is false (0) the content will
    // automatically return to its original size and position. The client is
    // responsible for resizing the browser if desired.
    on_fullscreen_mode_change: procedure(self: PCefDisplayHandler;
        browser: PCefBrowser; fullscreen: Integer); stdcall;

    // �����������ʾ������ʾ(tooltip)ʱ��������|text|������������ʾ���ı���
    // �����Ҫ�Լ�����������ʾ���뷵��true (1)�� ����, ������޸�|text|Ȼ�󷵻�
    // false (0)�������������ʾ���ݡ�
    // ��������Ⱦ�����ú�Ӧ�ó���Ӳ����������ݣ����ҷ���ֵ�������ԡ�
    on_tooltip: function(self: PCefDisplayHandler;
        browser: PCefBrowser; text: PCefString): Integer; stdcall;

    // ����������յ�״̬��Ϣʱ��������|value|Ϊ��Ҫչʾ���ı���
    on_status_message: procedure(self: PCefDisplayHandler;
        browser: PCefBrowser; const value: PCefString); stdcall;

    // ��Ҫ��ʾһ��console��Ϣʱ�����á�����true (1)��ֹͣ����Ϣ�����console��
    on_console_message: function(self: PCefDisplayHandler;
        browser: PCefBrowser; const message: PCefString;
        const source: PCefString; line: Integer): Integer; stdcall;
  end;

  // ����ṹ�����ڴ���۽�����Щ����������UI�߳��б����á�
  TCefFocusHandler = record
    // ���ṹ��
    base: TCefBase;

    // ����������ֽ�Ҫʧȥ����ʱ������������, ������������һ��HTMLԪ���ϣ���
    // ��ʱ�û�����TAB�����������������㴫����һ����ʱ��|next|��Ϊtrue (1)��
    // �������������㴫����һ����ʱ��|next|��Ϊfalse (0)
    on_take_focus: procedure(self: PCefFocusHandler;
        browser: PCefBrowser; next: Integer); stdcall;

    // ����������������ȡ����ʱ��������|source|ָʾ�����������Դ��
    // �������false (0)���������ý��㣬����ȡ����ȡ���㡣
    on_set_focus: function(self: PCefFocusHandler;
        browser: PCefBrowser; source: TCefFocusSource): Integer; stdcall;

    // ����������ֽ��յ�����ʱ������
    on_got_focus: procedure(self: PCefFocusHandler; browser: PCefBrowser); stdcall;
  end;

  // ����ṹ�����ڴ���������롣��Щ����������UI�߳��б����á�
  TCefKeyboardHandler = record
    // ���ṹ��
    base: TCefBase;

    // �������¼����͸�renderer֮ǰ��������|event|Ϊ�����¼�����Ϣ��
    // |os_event|�ǲ���ϵͳ���¼���Ϣ(�������)��
    // ����¼��������򷵻�true (1)�����򷵻�false (0)��
    // ����¼�����on_key_event()����Ϊ��ݼ�����������|is_keyboard_shortcut|
    // Ϊtrue (1)�����ҷ���false (0)��
    on_pre_key_event: function(self: PCefKeyboardHandler;
      browser: PCefBrowser; const event: PCefKeyEvent;
      os_event: TCefEventHandle; is_keyboard_shortcut: PInteger): Integer; stdcall;

    // ��renderer��ҳ���ϵ�JavaScript�л��ᴦ��������¼��󱻴�����
    // |event|Ϊ�����¼�����Ϣ��
    // |os_event|�ǲ���ϵͳ���¼���Ϣ(�������)��
    // ����¼��������򷵻�true (1)�����򷵻�false (0)��
    on_key_event: function(self: PCefKeyboardHandler;
        browser: PCefBrowser; const event: PCefKeyEvent;
        os_event: TCefEventHandle): Integer; stdcall;
  end;

  // ����ṹ�����ڴ���JavaScript�Ի���������첽����
  TCefJsDialogCallback = record
    // ���ṹ��
    base: TCefBase;

    // ����JS�Ի����������������OK��ť��������|success|Ϊtrue (1)��
    // |user_input|��ֵΪprompt�Ի�������ݡ�
    cont: procedure(self: PCefJsDialogCallback; success: Integer; const user_input: PCefString); stdcall;
  end;

  // ����ṹ�����ڴ���JavaScript�Ի���Ĵ�����Щ����������UI�߳��б����á�
  TCefJsDialogHandler = record
    // ���ṹ��
    base: TCefBase;

    // �����������������һ��JavaScript�Ի���|default_prompt_text|������prompt
    // �Ի�������|suppress_message|Ϊtrue (1)���ҷ���false (0)��������Ϣ()
    // (������Ϣ����ȡ�ķ�ʽ������ִ��callback���������ܵĶ�����Ϊ��������
    // onbeforeunload�е�����������Ϣ)������|suppress_message|Ϊfalse (0)���ҷ���
    // false (0)��ʹ��Ĭ�ϵ�ʵ��(Ĭ��ʵ�ֽ�����ʾһ��ģ̬�Ի��򣬲��������κ�����
    // �Ի�������֪���Ի���ر�)�����Ӧ�ó���ʹ���Զ���Ի����callback������ִ
    // ���򷵻�true (1)���Զ���Ի��������ģ̬���ģ̬�ġ�
    // ���ʹ���Զ���Ի���Ӧ�ó�������ڶԻ���رպ�ִ��|callback|��
    on_jsdialog: function(self: PCefJsDialogHandler;
      browser: PCefBrowser; const origin_url, accept_lang: PCefString;
      dialog_type: TCefJsDialogType; const message_text, default_prompt_text: PCefString;
      callback: PCefJsDialogCallback; suppress_message: PInteger): Integer; stdcall;

    // ����û����뿪ҳ��ʱ��������ӿڵ���һ���Ի���ѯ���û�������false (0)��ʹ��
    // Ĭ�ϵĶԻ���ʵ�֡����Ӧ�ó���ʹ���Զ���Ի������callback����ִ�У���
    // ��true (1)���Զ���Ի��������ģ̬�Ļ��ģ̬�ġ����If a custom
    // ���ʹ���Զ���Ի���Ӧ�ó�������ڶԻ���رպ�ִ��|callback|��
    on_before_unload_dialog: function(self: PCefJsDialogHandler;
      browser: PCefBrowser; const message_text: PCefString; is_reload: Integer;
      callback: PCefJsDialogCallback): Integer; stdcall;

    // �������������ȡ�����еȴ���ʾ�ĶԻ����������б���ĶԻ���״̬��
    // һ��������ҳ�浼�����µĵ��á�
    on_reset_dialog_state: procedure(self: PCefJsDialogHandler; browser: PCefBrowser); stdcall;

    // ��Ĭ��ʵ�ֵĶԻ���ر�ʱ������
    on_dialog_closed: procedure(self: PCefJsDialogHandler; browser: PCefBrowser); stdcall;
  end;

  // ֧�ֲ˵��Ĵ������޸ġ��μ�cef_menu_id_t��Ĭ��ʵ�ֵ�����ID��
  // �����û����������IDӦ����MENU_ID_USER_FIRST��MENU_ID_USER_LAST֮�䡣The functions of
  // ��Щ��������������������̵�UI�߳��С�
  TCefMenuModel = record
    // ���ṹ��
    base: TCefBase;

    // ����˵�������ɹ�����true (1)
    clear: function(self: PCefMenuModel): Integer; stdcall;

    // ��ȡ����˵���������
    get_count: function(self: PCefMenuModel): Integer; stdcall;

    // ��˵����һ���ָ���������ɹ��򷵻�true (1)
    add_separator: function(self: PCefMenuModel): Integer; stdcall;

    // ��˵������һ�����ɹ��򷵻�true (1)
    add_item: function(self: PCefMenuModel; command_id: Integer;
      const text: PCefString): Integer; stdcall;

    // ���һ��check��˵��С�����ɹ��򷵻�true (1)
    add_check_item: function(self: PCefMenuModel; command_id: Integer;
      const text: PCefString): Integer; stdcall;

    // ���һ��radio��˵�����ͬ��|group_id|��ֻ��һ����Ա�ѡ�С�����ɹ��򷵻�true (1)
    add_radio_item: function(self: PCefMenuModel; command_id: Integer;
      const text: PCefString; group_id: Integer): Integer; stdcall;

    // ��˵����һ���Ӳ˵�������������Ӳ˵���
    add_sub_menu: function(self: PCefMenuModel; command_id: Integer;
      const text: PCefString): PCefMenuModel; stdcall;

    // ��|index|λ�ò���һ���ָ���������ɹ��򷵻�true (1)
    insert_separator_at: function(self: PCefMenuModel; index: Integer): Integer; stdcall;

    // ��|index|λ�ò���һ�����ɹ��򷵻�true (1)
    insert_item_at: function(self: PCefMenuModel; index, command_id: Integer;
      const text: PCefString): Integer; stdcall;

    // ��|index|λ�ò���һcheck�����ɹ��򷵻�true (1)
    insert_check_item_at: function(self: PCefMenuModel; index, command_id: Integer;
      const text: PCefString): Integer; stdcall;

    // ��|index|λ�ò���һradio���ͬ��|group_id|��ֻ��һ����Ա�ѡ�С�����ɹ��򷵻�true (1)
    insert_radio_item_at: function(self: PCefMenuModel; index, command_id: Integer;
      const text: PCefString; group_id: Integer): Integer; stdcall;

    // |index|λ�ò���һ�Ӳ˵�������������Ӳ˵���
    insert_sub_menu_at: function(self: PCefMenuModel; index, command_id: Integer;
      const text: PCefString): PCefMenuModel; stdcall;

    // ����|command_id|�Ƴ��˵������ɹ��򷵻�true (1)
    remove: function(self: PCefMenuModel; command_id: Integer): Integer; stdcall;

    // ����|index|�Ƴ��˵������ɹ��򷵻�true (1)
    remove_at: function(self: PCefMenuModel; index: Integer): Integer; stdcall;

    // ��ȡ|command_id|�����Ĳ˵����������������ID�ڸò˵��в������򷵻�-1��
    get_index_of: function(self: PCefMenuModel; command_id: Integer): Integer; stdcall;

    //��ȡ|index|�����Ĳ˵�������ID���������������Χ���Ƿָ����򷵻�-1��
    get_command_id_at: function(self: PCefMenuModel; index: Integer): Integer; stdcall;

    // ����|index|��������ID. ����ɹ��򷵻�true (1)
    set_command_id_at: function(self: PCefMenuModel; index, command_id: Integer): Integer; stdcall;

    // ����|command_id|�˵���ı�ǩ�������δ�ҵ��򷵻�NULL��
    // ���صĽ���ַ����������cef_string_userfree_free()������
    get_label: function(self: PCefMenuModel; command_id: Integer): PCefStringUserFree; stdcall;

    // ����|index|�˵���ı�ǩ���������������Χ���Ƿָ����򷵻�NULL��
    // ���صĽ���ַ����������cef_string_userfree_free()������
    get_label_at: function(self: PCefMenuModel; index: Integer): PCefStringUserFree; stdcall;

    // ����|command_id|�˵���ı�ǩ��������ɹ��򷵻�true (1)
    set_label: function(self: PCefMenuModel; command_id: Integer;
      const text: PCefString): Integer; stdcall;

    // ����|index|�˵���ı�ǩ��������ɹ��򷵻�true (1)
    set_label_at: function(self: PCefMenuModel; index: Integer;
      const text: PCefString): Integer; stdcall;

    // ����|index|�˵���Ĳ˵������ͣ�����ɹ��򷵻�true (1)
    get_type: function(self: PCefMenuModel; command_id: Integer): TCefMenuItemType; stdcall;

    // ��ȡ|index|�˵���Ĳ˵�������
    get_type_at: function(self: PCefMenuModel; index: Integer): TCefMenuItemType; stdcall;

    // ��ȡ|command_id|�˵������ID�����û���򷵻�-1
    get_group_id: function(self: PCefMenuModel; command_id: Integer): Integer; stdcall;

    // ��ȡ|index|�˵������ID�����û���򷵻�-1
    get_group_id_at: function(self: PCefMenuModel; index: Integer): Integer; stdcall;

    // ����|command_id|�˵������ID������ɹ��򷵻�true (1)
    set_group_id: function(self: PCefMenuModel; command_id, group_id: Integer): Integer; stdcall;

    // ����|index|�˵������ID������ɹ��򷵻�true (1)
    set_group_id_at: function(self: PCefMenuModel; index, group_id: Integer): Integer; stdcall;

    // ��ȡ|command_id|�˵�����Ӳ˵�������������򷵻�NULL
    get_sub_menu: function(self: PCefMenuModel; command_id: Integer): PCefMenuModel; stdcall;

    // ��ȡ|index|�˵�����Ӳ˵�������������򷵻�NULL
    get_sub_menu_at: function(self: PCefMenuModel; index: Integer): PCefMenuModel; stdcall;

    // ���|command_id|�˵���ɼ����򷵻�true (1)
    is_visible: function(self: PCefMenuModel; command_id: Integer): Integer; stdcall;

    // ���|index|�˵���ɼ����򷵻�true (1)
    is_visible_at: function(self: PCefMenuModel; index: Integer): Integer; stdcall;

    // �޸�|command_id|�˵���Ŀɼ��ԡ�����ɹ��򷵻�true (1)
    set_visible: function(self: PCefMenuModel; command_id, visible: Integer): Integer; stdcall;

    // �޸�|index|�˵���Ŀɼ��ԡ�����ɹ��򷵻�true (1)
    set_visible_at: function(self: PCefMenuModel; index, visible: Integer): Integer; stdcall;

    // ���|command_id|�˵�����ã��򷵻�true (1)
    is_enabled: function(self: PCefMenuModel; command_id: Integer): Integer; stdcall;

    // ���|index|�˵�����ã��򷵻�true (1)
    is_enabled_at: function(self: PCefMenuModel; index: Integer): Integer; stdcall;

    // �޸�|command_id|�˵�����Ƿ���á�����ɹ��򷵻�true (1)
    set_enabled: function(self: PCefMenuModel; command_id, enabled: Integer): Integer; stdcall;

    // �޸�|index|�˵�����Ƿ���á�����ɹ��򷵻�true (1)
    set_enabled_at: function(self: PCefMenuModel; index, enabled: Integer): Integer; stdcall;

    // ���|command_id|�˵���checked���򷵻�true (1)
    is_checked: function(self: PCefMenuModel; command_id: Integer): Integer; stdcall;

    // ���|index|�˵���checked���򷵻�true (1)
    is_checked_at: function(self: PCefMenuModel; index: Integer): Integer; stdcall;

    // �޸�|command_id|�˵�����Ƿ�checked������ɹ��򷵻�true (1)
    set_checked: function(self: PCefMenuModel; command_id, checked: Integer): Integer; stdcall;

    // �޸�|index|�˵�����Ƿ�checked������ɹ��򷵻�true (1)
    set_checked_at: function(self: PCefMenuModel; index, checked: Integer): Integer; stdcall;

    // ���|command_id|�˵����м��̿�ݼ����򷵻�true (1)
    has_accelerator: function(self: PCefMenuModel; command_id: Integer): Integer; stdcall;

    // ���|index|�˵����м��̿�ݼ����򷵻�true (1)
    has_accelerator_at: function(self: PCefMenuModel; index: Integer): Integer; stdcall;

    // ����|command_id|�˵���ļ��̿�ݼ���|key_code|�������κ���������ַ�ֵ��
    // ����ɹ��򷵻�true (1)
    set_accelerator: function(self: PCefMenuModel; command_id, key_code,
      shift_pressed, ctrl_pressed, alt_pressed: Integer): Integer; stdcall;

    // ����|index|�˵���ļ��̿�ݼ���|key_code|�������κ���������ַ�ֵ��
    // ����ɹ��򷵻�true (1)
    set_accelerator_at: function(self: PCefMenuModel; index, key_code,
      shift_pressed, ctrl_pressed, alt_pressed: Integer): Integer; stdcall;

    // �Ƴ�|command_id|�˵���Ŀ�ݼ�������ɹ��򷵻�true (1)
    remove_accelerator: function(self: PCefMenuModel; command_id: Integer): Integer; stdcall;

    // �Ƴ�|index|�˵���Ŀ�ݼ�������ɹ��򷵻�true (1)
    remove_accelerator_at: function(self: PCefMenuModel; index: Integer): Integer; stdcall;

    // ��ȡ|command_id|�˵���Ŀ�ݼ�������ɹ��򷵻�true (1)
    get_accelerator: function(self: PCefMenuModel; command_id: Integer; key_code,
      shift_pressed, ctrl_pressed, alt_pressed: PInteger): Integer; stdcall;

    // ��ȡ|index|�˵���Ŀ�ݼ�������ɹ��򷵻�true (1)
    get_accelerator_at: function(self: PCefMenuModel; index: Integer; key_code,
      shift_pressed, ctrl_pressed, alt_pressed: PInteger): Integer; stdcall;
  end;


  // Callback structure used for continuation of custom context menu display.
  TCefRunContextMenuCallback = record
    // Base structure.
    base: TCefBase;
    // Complete context menu display by selecting the specified |command_id| and
    // |event_flags|.
    cont: procedure(self: PCefRunContextMenuCallback; command_id: Integer;
      event_flags: TCefEventFlags); stdcall;
    // Cancel context menu display.
    cancel: procedure(self: PCefRunContextMenuCallback); stdcall;
  end;

  // ����ṹ������ע�������Ĳ˵��¼�����Щ������UI�߳��б����á�
  TCefContextMenuHandler = record
    // ���ṹ��
    base: TCefBase;

    // �������Ĳ˵���ʾ֮ǰ�����á�|params|�ṩ�������Ĳ˵�״̬��Ϣ��
    // |model|ΪĬ�ϵ������Ĳ˵���
    // |model|���Ա�����������ʾ�����Ĳ˵��������޸�������ʾһ���Զ���˵���
    // ��Ҫ����������ⲿ����|params|��|model|�����á�
    on_before_context_menu: procedure(self: PCefContextMenuHandler;
      browser: PCefBrowser; frame: PCefFrame; params: PCefContextMenuParams;
      model: PCefMenuModel); stdcall;

    // Called to allow custom display of the context menu. |params| provides
    // information about the context menu state. |model| contains the context menu
    // model resulting from OnBeforeContextMenu. For custom display return true
    // (1) and execute |callback| either synchronously or asynchronously with the
    // selected command ID. For default display return false (0). Do not keep
    // references to |params| or |model| outside of this callback.
    run_context_menu: function(self: PCefContextMenuHandler;
      browser: PCefBrowser; frame: PCefFrame; params: PCefContextMenuParams;
      model: PCefMenuModel; callback: PCefRunContextMenuCallback): Integer; stdcall;

    // �������Ĳ˵�ִ��һ��ѡ������ʱ�����á������������򷵻�true (1)��
    // �������false (0)��ʹ��Ĭ��ʵ�֡��μ���Ĭ��ʵ�ֵ�����ID��cef_menu_id_t��
    // �����û����������IDӦ����MENU_ID_USER_FIRST��MENU_ID_USER_LAST֮�䡣
    // |params|�봫��on_before_context_menu()��ֵ��ͬ��
    // ��Ҫ����������ⲿ����|params|�����á�
    on_context_menu_command: function(self: PCefContextMenuHandler;
      browser: PCefBrowser; frame: PCefFrame; params: PCefContextMenuParams;
      command_id: Integer; event_flags: Integer): Integer; stdcall;

    // �������Ĳ˵��ر�ʱ�����������۲˵��Ƿ�ΪNULL�������Ƿ�ѡ��
    on_context_menu_dismissed: procedure(self: PCefContextMenuHandler;
      browser: PCefBrowser; frame: PCefFrame); stdcall;
  end;


  // �ṩ����������״̬����Ϣ����Щ������UI�߳��б����á�
  TCefContextMenuParams = record
    // ���ṹ��
    base: TCefBase;

    // ��ȡ�����Ĳ˵�������ʱ������X���ꡣ���������RenderView��ԭ�㡣
    get_xcoord: function(self: PCefContextMenuParams): Integer; stdcall;

    // ��ȡ�����Ĳ˵�������ʱ������Y���ꡣ���������RenderView��ԭ�㡣
    get_ycoord: function(self: PCefContextMenuParams): Integer; stdcall;

    // ��ȡ�����Ĳ˵�������ʱ�Ľڵ�����ͱ�־
    get_type_flags: function(self: PCefContextMenuParams): Integer; stdcall;

    // ��ȡ�����Ĳ˵�������ʱ�Ľڵ����ӵ�URL(�������)��
    // ����ַ�����Ҫ����cef_string_userfree_free()������
    get_link_url: function(self: PCefContextMenuParams): PCefStringUserFree; stdcall;

    // ��ȡ������"copy link address"�������ַ��������ǲ�����ǰ̨����У������ֶΡ�
    // ����ַ�����Ҫ����cef_string_userfree_free()������
    get_unfiltered_link_url: function(self: PCefContextMenuParams): PCefStringUserFree; stdcall;

    // ��ȡ�����Ĳ˵�������ʱ��Ԫ�ص�URL(�������)������img��audio�Լ�video�ȡ�
    // ����ַ�����Ҫ����cef_string_userfree_free()������
    get_source_url: function(self: PCefContextMenuParams): PCefStringUserFree; stdcall;

    // ��������Ĳ˵�������ʱ��һ����NULL���ݵ�image��ʱ����true (1)��
    has_image_contents: function(self: PCefContextMenuParams): Integer; stdcall;

    // ��ȡ�����Ĳ˵�������ʱ����ҳ���URL��
    // ����ַ�����Ҫ����cef_string_userfree_free()������
    get_page_url: function(self: PCefContextMenuParams): PCefStringUserFree; stdcall;

    // ��ȡ�����Ĳ˵�������ʱ����frame��URL��
    // ����ַ�����Ҫ����cef_string_userfree_free()������
    get_frame_url: function(self: PCefContextMenuParams): PCefStringUserFree; stdcall;

    // ��ȡ�����Ĳ˵�������ʱ����frame���ַ����롣
    // ����ַ�����Ҫ����cef_string_userfree_free()������
    get_frame_charset: function(self: PCefContextMenuParams): PCefStringUserFree; stdcall;

    // ��ȡ�����Ĳ˵�������ʱ�������Ľڵ�����
    get_media_type: function(self: PCefContextMenuParams): TCefContextMenuMediaType; stdcall;

    // ��ȡ�����Ĳ˵�������ʱ��ý��Ԫ��֧�ֵĶ�����־(�������)
    get_media_state_flags: function(self: PCefContextMenuParams): Integer; stdcall;

    // ��ȡ�����Ĳ˵�������ʱ��ý��Ԫ��֧�ֵ��ı�ѡ������(�������)
    // ����ַ�����Ҫ����cef_string_userfree_free()������
    get_selection_text: function(self: PCefContextMenuParams): PCefStringUserFree; stdcall;

    // ��ȡ�����Ĳ˵�������ʱ��ƴд����ĵ��ʵ��ı���
    // ����ַ�����Ҫ����cef_string_userfree_free()������
    get_misspelled_word: function(self: PCefContextMenuParams): PCefStringUserFree; stdcall;

    // ���ƴд�������д���ƴд���󵥴ʵĽ���(suggestions),����䵽suggestions��
    // ������true (1), ���򷵻�false (0)��
    get_dictionary_suggestions: function(self: PCefContextMenuParams;
      suggestions: TCefStringList): Integer; stdcall;

    // ��������Ĳ˵�������ʱ��һ���ɱ༭�ڵ��ϣ��򷵻�true (1)
    is_editable: function(self: PCefContextMenuParams): Integer; stdcall;

    // ��������Ĳ˵�������ʱ��һ��������ƴд���Ŀɱ༭�ڵ��ϣ��򷵻�true (1)
    is_spell_check_enabled: function(self: PCefContextMenuParams): Integer; stdcall;

    // ���������Ĳ˵�������ʱ�ı༭�ڵ�֧�ֵĶ�����־(�������)��
    get_edit_state_flags: function(self: PCefContextMenuParams): Integer; stdcall;

    // Returns true (1) if the context menu contains items specified by the
    // renderer process (for example, plugin placeholder or pepper plugin menu
    // items).
    is_custom_menu: function(self: PCefContextMenuParams): Integer; stdcall;

    // Returns true (1) if the context menu was invoked from a pepper plugin.
    is_pepper_menu: function(self: PCefContextMenuParams): Integer; stdcall;
  end;

  // ����ṹ�����ڻ�ȡ����λ�����������첽����
  TCefGeolocationCallback = record
    // ���ṹ��
    base: TCefBase;

    // ���������ܾ�����λ�÷���
    cont: procedure(self: PCefGeolocationCallback; allow: Integer); stdcall;
  end;


  // ����ӿ�����ʵ�ֵ���λ���������Ĵ�����Щ������UI�߳��б����á�
  TCefGeolocationHandler = record
    // ���ṹ��
    base: TCefBase;

    // ��һ��ҳ��������ʵ���λ����Ϣ���ʱ��������
    // |requesting_url|��������ɵ�URL��|request_id|����������ΨһID��
    // ���true (1)��������������ڻ��Ժ����cef_geolocation_callback_t::cont()��
    // ������ȡ�����󡣷���false (0)������ȡ������
    on_request_geolocation_permission: function(self: PCefGeolocationHandler;
        browser: PCefBrowser; const requesting_url: PCefString; request_id: Integer;
        callback: PCefGeolocationCallback): Integer; stdcall;

    // �������������ȡ��ʱ��������|requesting_url|��ԭʼ���������URL��
    // |request_id|�������������ΨһID��
    on_cancel_geolocation_permission: procedure(self: PCefGeolocationHandler;
        browser: PCefBrowser; const requesting_url: PCefString; request_id: Integer); stdcall;
  end;

  // Implement this structure to handle events related to find results. The
  // functions of this structure will be called on the UI thread.
  TCefFindHandler = record
    // Base structure.
    base: TCefBase;

    // Called to report find results returned by cef_browser_host_t::find().
    // |identifer| is the identifier passed to find(), |count| is the number of
    // matches currently identified, |selectionRect| is the location of where the
    // match was found (in window coordinates), |activeMatchOrdinal| is the
    // current position in the search results, and |finalUpdate| is true (1) if
    // this is the last find notification.
    on_find_result: procedure(self: PCefFindHandler; browser: PCefBrowser;
      identifier, count: Integer; const selection_rect: PCefRect;
      active_match_ordinal, final_update: Integer); stdcall;
  end;

    // ���������ܾ�����λ�÷���
  TCefClient = record
    // ���ṹ��
    base: TCefBase;

    // ���������Ĳ˵��Ĵ����������δ�ṩ��ʹ��Ĭ�ϵ�ʵ�֡�
    get_context_menu_handler: function(self: PCefClient): PCefContextMenuHandler; stdcall;

    // ���ضԻ���Ĵ����������Ϊ�ṩ��ʹ��Ĭ�ϵ�ʵ�֡�
    get_dialog_handler: function(self: PCefClient): PCefDialogHandler; stdcall;

    // �����������ʾ״̬�¼��Ĵ�������
    get_display_handler: function(self: PCefClient): PCefDisplayHandler; stdcall;

    // ���������¼������������δ�ṩ��֧�����ء�
    get_download_handler: function(self: PCefClient): PCefDownloadHandler; stdcall;

    // ������ק�¼��Ĵ�������
    get_drag_handler: function(self: PCefClient): PCefDragHandler; stdcall;

    // Return the handler for find result events.
    get_find_handler: function(self: PCefClient): PCefFindHandler; stdcall;

    // ���ؾ۽��¼��Ĵ�������
    get_focus_handler: function(self: PCefClient): PCefFocusHandler; stdcall;

    // ���ص����������Ĵ����������δ�ṩ��������Ĭ���ǽ�ֹ�ġ�
    get_geolocation_handler: function(self: PCefClient): PCefGeolocationHandler; stdcall;

    // ����Javascript�Ի����¼�������
    get_jsdialog_handler: function(self: PCefClient): PCefJsDialogHandler; stdcall;

    // ���ؼ����¼�������
    get_keyboard_handler: function(self: PCefClient): PCefKeyboardHandler; stdcall;

    // ������������������¼�������
    get_life_span_handler: function(self: PCefClient): PCefLifeSpanHandler; stdcall;

    // �������������״̬�¼�������
    get_load_handler: function(self: PCefClient): PCefLoadHandler; stdcall;

    // ����������Ⱦ�¼�������
    get_render_handler: function(self: PCefClient): PCefRenderHandler; stdcall;

    // ��������������¼�������
    get_request_handler: function(self: PCefClient): PCefRequestHandler; stdcall;

    // �����������̽��յ�����Ϣʱ�������������Ϣ�������ⷵ��true(1)�����򷵻�
    //  false (0)����Ҫ���������֮�Ᵽ�� message�����á�
    on_process_message_received: function(self: PCefClient; browser: PCefBrowser;
      source_process: TCefProcessId; message: PCefProcessMessage): Integer; stdcall;
  end;

  // ����ṹ���ʾһ��web������Щ���������������߳��б����á�
  TCefRequest = record
    // ���ṹ��
    base: TCefBase;

    // ��������ֻ��ʱ����true (1)
    is_read_only: function(self: PCefRequest): Integer; stdcall;

    // ��ȡ������URL
    // ����ַ�����Ҫ����cef_string_userfree_free()������
    get_url: function(self: PCefRequest): PCefStringUserFree; stdcall;
    // ����������URL
    set_url: procedure(self: PCefRequest; const url: PCefString); stdcall;

    // ��ȡ����METHOD���͡������post������Ĭ����POST��������GET��
    // ����ַ�����Ҫ����cef_string_userfree_free()������
    get_method: function(self: PCefRequest): PCefStringUserFree; stdcall;
    // ���������METHOD����
    set_method: procedure(self: PCefRequest; const method: PCefString); stdcall;

    // ��ȡpost������
    get_post_data: function(self: PCefRequest): PCefPostData; stdcall;
    // ����post������
    set_post_data: procedure(self: PCefRequest; postData: PCefPostData); stdcall;

    // ��ȡ����ͷ
    get_header_map: procedure(self: PCefRequest; headerMap: TCefStringMultimap); stdcall;
    // ��ȡ����ͷ
    set_header_map: procedure(self: PCefRequest; headerMap: TCefStringMultimap); stdcall;

    // ͬʱ��������ֵ
    set_: procedure(self: PCefRequest; const url, method: PCefString;
      postData: PCefPostData; headerMap: TCefStringMultimap); stdcall;

    // ��ȡcef_urlrequest_t��־���μ�֧�ֵ�cef_urlrequest_flags_tֵ��
    get_flags: function(self: PCefRequest): Integer; stdcall;
    // ����cef_urlrequest_t��־�� �μ�֧�ֵ�cef_urlrequest_flags_tֵ��
    set_flags: procedure(self: PCefRequest; flags: Integer); stdcall;

    // ��ȡ����cef_urlrequest_t cookie��URL�ĵ�һ���֡�
    // ����ַ�����Ҫ����cef_string_userfree_free()������
    get_first_party_for_cookies: function(self: PCefRequest): PCefStringUserFree; stdcall;
    // ��������cef_urlrequest_t cookie��URL�ĵ�һ���֡�
    set_first_party_for_cookies: procedure(self: PCefRequest; const url: PCefString); stdcall;

    // ��ȡ����������Դ���ͣ����������������Ч��
    get_resource_type: function(self: PCefRequest): TCefResourceType; stdcall;

    // ��ȡ�������Ĺ���(transition)���͡����������������Ч�����ҽ�Ӧ�õ���frame
    // ����frame�ĵ�����
    get_transition_type: function(self: PCefRequest): TCefTransitionType; stdcall;

    // Returns the globally unique identifier for this request or 0 if not
    // specified. Can be used by cef_request_tHandler implementations in the
    // browser process to track a single request across multiple callbacks.
    get_identifier: function(self: PCefRequest): UInt64; stdcall;
  end;


  TCefPostDataElementArray = array[0..(High(Integer) div SizeOf(PCefPostDataElement)) - 1] of PCefPostDataElement;
  PCefPostDataElementArray = ^TCefPostDataElementArray;

  // ����ṹ���ʾһ��web����post�����ݡ���Щ������������������̡�
  TCefPostData = record
    // ���ṹ��
    base: TCefBase;

    // �������ֵֻ�����򷵻�true (1)
    is_read_only: function(self: PCefPostData):Integer; stdcall;

    // ��ȡ���ڵ�post����Ԫ������
    get_element_count: function(self: PCefPostData): NativeUInt; stdcall;

    // ��ȡpost��dataԪ��
    get_elements: procedure(self: PCefPostData; elementsCount: PNativeUInt;
      elements: PCefPostDataElementArray); stdcall;

    // �Ƴ�ָ����post dataԪ�ء�����ɹ��Ƴ��򷵻�true (1)
    remove_element: function(self: PCefPostData;
      element: PCefPostDataElement): Integer; stdcall;

    // ���ָ����post dataԪ�ء������ӳɹ��򷵻�true (1)
    add_element: function(self: PCefPostData;
        element: PCefPostDataElement): Integer; stdcall;

    // �Ƴ����д��ڵ�post dataԪ��
    remove_elements: procedure(self: PCefPostData); stdcall;
  end;

  // ����ṹ�����ڱ�ʾ����post�����е�һ��Ԫ�ء���Щ������������������̡�
  TCefPostDataElement = record
    // ���ṹ��
    base: TCefBase;

    // �������ֵֻ�����򷵻�true (1)
    is_read_only: function(self: PCefPostDataElement): Integer; stdcall;

    // ��post dataԪ�����Ƴ���������
    set_to_empty: procedure(self: PCefPostDataElement); stdcall;

    // ����post dataԪ��Ϊһ���ļ�
    set_to_file: procedure(self: PCefPostDataElement;
        const fileName: PCefString); stdcall;

    // ����post dataΪһ���ֽ����顣����ֽ����ݽ�����п�����
    set_to_bytes: procedure(self: PCefPostDataElement;
        size: NativeUInt; const bytes: Pointer); stdcall;

    // ��ȡ���post dataԪ�ص�����
    get_type: function(self: PCefPostDataElement): TCefPostDataElementType; stdcall;

    // ��ȡ�ļ���
    // ����ַ�����Ҫ����cef_string_userfree_free()������
    get_file: function(self: PCefPostDataElement): PCefStringUserFree; stdcall;

    // ��ȡ�ֽ�����
    get_bytes_count: function(self: PCefPostDataElement): NativeUInt; stdcall;

    // ��ȡ|size|�ֽڵ����ݵ�|bytes|�����ҷ���������ȡ�����ֽ�����
    get_bytes: function(self: PCefPostDataElement;
        size: NativeUInt; bytes: Pointer): NativeUInt; stdcall;
  end;

  // ����ṹ���ʾһ��web��Ӧ����Щ��������������������б����á�
  TCefResponse = record
    // ���ṹ��
    base: TCefBase;

    // �������ֵֻ�����򷵻�true (1)
    is_read_only: function(self: PCefResponse): Integer; stdcall;

    // ��ȡ��Ӧ��״̬����
    get_status: function(self: PCefResponse): Integer; stdcall;
    // ������Ӧ��״̬����
    set_status: procedure(self: PCefResponse; status: Integer); stdcall;

    // ��ȡ��Ӧ��״̬�ı�
    // ����ַ�����Ҫ����cef_string_userfree_free()������
    get_status_text: function(self: PCefResponse): PCefStringUserFree; stdcall;
    // ������Ӧ��״̬�ı�
    set_status_text: procedure(self: PCefResponse; const statusText: PCefString); stdcall;

    // ��ȡ��Ӧ��mime����
    // ����ַ�����Ҫ����cef_string_userfree_free()������
    get_mime_type: function(self: PCefResponse): PCefStringUserFree; stdcall;
    // ������Ӧ��mime����
    set_mime_type: procedure(self: PCefResponse; const mimeType: PCefString); stdcall;

    // ��ȡָ������Ӧͷ�ֶ�ֵ
    // ����ַ�����Ҫ����cef_string_userfree_free()������
    get_header: function(self: PCefResponse; const name: PCefString): PCefStringUserFree; stdcall;

    // ��ȡ���е���Ӧͷ�ֶ�
    get_header_map: procedure(self: PCefResponse; headerMap: TCefStringMultimap); stdcall;
    // �������е���Ӧͷ�ֶ�
    set_header_map: procedure(self: PCefResponse; headerMap: TCefStringMultimap); stdcall;
  end;

  // �ͻ��˿���ʵ������ṹ�����ṩһ���Զ��������ȡ������Щ��������������������б����á�
  TCefReadHandler = record
    // ���ṹ��
    base: TCefBase;

    // ��ȡ�ڴ����������
    read: function(self: PCefReadHandler; ptr: Pointer;
      size, n: NativeUInt): NativeUInt; stdcall;

    // ������ָ����ƫ��λ�á�|whence|������SEEK_CUR��SEEK_END��SEEK_SET֮һ��
    // �ɹ��򷵻��㣬���򷵻ط���
    seek: function(self: PCefReadHandler; offset: Int64;
      whence: Integer): Integer; stdcall;

    // ��ȡ��ǰ��ƫ��λ��
    tell: function(self: PCefReadHandler): Int64; stdcall;

    // ����Ƿ񵽴��ļ�β��
    eof: function(self: PCefReadHandler): Integer; stdcall;

    // �������������ʿ��ܻ��жϵ��ļ�ϵͳ�����Ĺ����򷵻�true (1)��
    // ����������û���鴦������Դ���̡߳�
    may_block: function(self: PCefReadHandler): Integer; stdcall;
  end;

  // ����ṹ�����ڴ����ж�ȡ���ݡ���Щ��������������������б����á�
  TCefStreamReader = record
    // ���ṹ��
    base: TCefBase;

    // ��ȡ�ڴ����������
    read: function(self: PCefStreamReader; ptr: Pointer;
        size, n: NativeUInt): NativeUInt; stdcall;

    // ������ָ����ƫ��λ�á�|whence|������SEEK_CUR��SEEK_END��SEEK_SET֮һ��
    // �ɹ��򷵻��㣬���򷵻ط���
    seek: function(self: PCefStreamReader; offset: Int64;
        whence: Integer): Integer; stdcall;

    // ��ȡ��ǰ��ƫ��λ��
    tell: function(self: PCefStreamReader): Int64; stdcall;

    // ����Ƿ񵽴��ļ�β��
    eof: function(self: PCefStreamReader): Integer; stdcall;

    // �������������ʿ��ܻ��жϵ��ļ�ϵͳ�����Ĺ����򷵻�true (1)��
    // ����������û���鴦������Դ���̡߳�
    may_block: function(self: PCefStreamReader): Integer; stdcall;
  end;

  // �ͻ��˿���ʵ������Զ�����д��������Щ��������������������б����á�
  TCefWriteHandler = record
    // ���ṹ��
    base: TCefBase;

    // д��һ���ڴ����������
    write: function(self: PCefWriteHandler;
        const ptr: Pointer; size, n: NativeUInt): NativeUInt; stdcall;

    // ������ָ����ƫ��λ�á�|whence|������SEEK_CUR��SEEK_END��SEEK_SET֮һ��
    // �ɹ��򷵻��㣬���򷵻ط���
    seek: function(self: PCefWriteHandler; offset: Int64;
        whence: Integer): Integer; stdcall;

    // ��ȡ��ǰ��ƫ��λ��
    tell: function(self: PCefWriteHandler): Int64; stdcall;

    // �����������
    flush: function(self: PCefWriteHandler): Integer; stdcall;

    // �������������ʿ��ܻ��жϵ��ļ�ϵͳ�����Ĺ����򷵻�true (1)��
    // ����������û���鴦������Դ���̡߳�
    may_block: function(self: PCefWriteHandler): Integer; stdcall;
  end;

  // ����ṹ�����ڽ�Ҫ����д��������Щ��������������������б����á�
  // TODO: ʵ����
  TCefStreamWriter = record
    // ���ṹ��
    base: TCefBase;

    // д��һ���ڴ����������
    write: function(self: PCefStreamWriter;
        const ptr: Pointer; size, n: NativeUInt): NativeUInt; stdcall;

    // ������ָ����ƫ��λ�á�|whence|������SEEK_CUR��SEEK_END��SEEK_SET֮һ��
    // �ɹ��򷵻��㣬���򷵻ط���
    seek: function(self: PCefStreamWriter; offset: Int64;
        whence: Integer): Integer; stdcall;

    // ��ȡ��ǰ��ƫ��λ��
    tell: function(self: PCefStreamWriter): Int64; stdcall;

    // �����������
    flush: function(self: PCefStreamWriter): Integer; stdcall;

    // �������������ʿ��ܻ��жϵ��ļ�ϵͳ�����Ĺ����򷵻�true (1)��
    // ����������û���鴦������Դ���̡߳�
    may_block: function(self: PCefStreamWriter): Integer; stdcall;
  end;

  // ����ṹ���ʾһ��V8�����ġ�V8������������������߳��з��ʡ�
  // �ɴ���V8�������Ч�̰߳�����Ⱦ�̵߳����߳�(TID_RENDERER)��WebWorker�̡߳�
  // ���ʼ�(post)task���񵽹����̵߳�TaskRunner��ͨ��cef_v8context_t::get_task_runner()
  // �������
  TCefV8Context = record
    // ���ṹ��
    base: TCefBase;

    // ��ȡ�������V8������̹߳�����TaskRunner����������������κ���Ⱦ�����߳��б����á�
    get_task_runner: function(self: PCefv8Context): PCefTask; stdcall;

    // �������������Ч���ҿ��ڵ�ǰ�߳��з����򷵻�true (1)��
    // ������false(0)ʱ��Ҫ��������ṹ�������������
    is_valid: function(self: PCefv8Context): Integer; stdcall;

    // ��ȡ��������ĵ�������������WebWorker�����Ľ�����NULL��
    get_browser: function(self: PCefv8Context): PCefBrowser; stdcall;

    // ��ȡ��������ĵ�frame�������WebWorker�����Ľ�����NULL��
    get_frame: function(self: PCefv8Context): PCefFrame; stdcall;

    // ��ȡ��������ĵ�ȫ�ֶ����ڵ����������֮ǰ����������������
    get_global: function(self: PCefv8Context): PCefv8Value; stdcall;

    // ������������ġ��ڴ���һ��V8 Object��Array��Function��Dateʱ��������ʾ�Ľ�����������ġ�
    // ���ͷ����������֮ǰ���������ͬ������exit()������
    // V8�����������Ǵ���ʱ�������ġ�������������ɹ������򷵻�true (1)��
    enter: function(self: PCefv8Context): Integer; stdcall;

    // �뿪��������ġ�����������ڵ���enter()֮��ſ��Ե��á�������������ɹ��뿪�򷵻�true (1)��
    exit: function(self: PCefv8Context): Integer; stdcall;

    // ���self��|that|ָ��ľ����ͬ�򷵻�true (1)
    is_same: function(self, that: PCefv8Context): Integer; stdcall;

    // ��ָ����JavaScript����ʹ����������ĵ�ȫ�ֶ������Eval��ֵ��
    // ���ɹ�ʱ|retval|��������Ϊ����ֵ(�������)�����Һ�������true (1)��
    // ��ʧ��ʱ|exception|��������Ϊ�쳣��Ϣ(�������)�����ҷ���false (0).
    eval: function(self: PCefv8Context; const code: PCefString;
      var retval: PCefv8Value; var exception: PCefV8Exception): Integer; stdcall;
  end;

  // ����ṹ��Ӧ��ʵ��V8�����ĵ��á��������Ӧ����V8�����������߳��б����á�
  TCefv8Handler = record
    // ���ṹ��
    base: TCefBase;

    // ͨ��ָ����|name|��ִ��V8������|object|�Ǻ����е�'this'����
    // |arguments|�Ǵ��ݸ�����������б�
    // ���ɹ�ʱ|retval|��������Ϊ����ֵ(�������)��
    // ��ʧ��ʱ|exception|��������Ϊ�쳣��Ϣ(�������)�����ִ�б������򷵻�true (1)��
    execute: function(self: PCefv8Handler;
        const name: PCefString; obj: PCefv8Value; argumentsCount: NativeUInt;
        const arguments: PPCefV8Value; var retval: PCefV8Value;
        var exception: TCefString): Integer; stdcall;
  end;

  // ����ṹ�����ڴ���V8������(accessor)�ĵ���.��������ʶ��ͨ������
  // cef_v8value_t::set_value_byaccessor()ע�ᡣ
  // ��Щ��������V8�������������߳��б����á�
  TCefV8Accessor = record
    // ���ṹ��
    base: TCefBase;

    // ����|name|ָ���ķ�������get������|object|�Ǻ����е�'this'����
    // ���ɹ�ʱ|retval|��������Ϊ����ֵ(�������)��
    // ��ʧ��ʱ|exception|��������Ϊ�쳣��Ϣ(�������)��������ʱ������򷵻�true (1)��
    get: function(self: PCefV8Accessor; const name: PCefString;
      obj: PCefv8Value; out retval: PCefv8Value; exception: PCefString): Integer; stdcall;

    // ����|name|ָ���ķ�������set������ |object|�Ǻ����е�'this'����
    // |value|�Ǹ�ֵ������������ֵ��
    // �����ֵʧ��������|exception|Ϊ���׳����쳣��
    // ��������������������򷵻�true (1)��
    put: function(self: PCefV8Accessor; const name: PCefString;
      obj: PCefv8Value; value: PCefv8Value; exception: PCefString): Integer; stdcall;
  end;

  // ����ṹ���ʾһ��V8�쳣������ṹ��������κ��߳��б����á�
  TCefV8Exception = record
    // ���ṹ��
    base: TCefBase;

    // ��ȡ�쳣��message��Ϣ�ı���
    // ����ַ����������cef_string_userfree_free()�����١�
    get_message: function(self: PCefV8Exception): PCefStringUserFree; stdcall;

    // ��ȡ����쳣�׳��е�Դ����
    // ����ַ����������cef_string_userfree_free()�����١�
    get_source_line: function(self: PCefV8Exception): PCefStringUserFree; stdcall;

    // ��ȡ�ű����쳣�׳������ڵ���Դ���ơ�
    // ����ַ����������cef_string_userfree_free()�����١�
    get_script_resource_name: function(self: PCefV8Exception): PCefStringUserFree; stdcall;

    // ��ȡ�쳣����ʱ�Ļ���1���кţ�����к�δ֪�򷵻�0��
    get_line_number: function(self: PCefV8Exception): Integer; stdcall;

    // �����쳣����ʱ�ڽű��еĵ�һ���ַ�����λ�á�
    get_start_position: function(self: PCefV8Exception): Integer; stdcall;

    // �����쳣����ʱ�ڽű��е����һ���ַ�����λ�á�
    get_end_position: function(self: PCefV8Exception): Integer; stdcall;

    // �����쳣���������еĵ�һ���ַ�����λ�á�
    get_start_column: function(self: PCefV8Exception): Integer; stdcall;

    // �����쳣���������е����һ���ַ�����λ�á�
    get_end_column: function(self: PCefV8Exception): Integer; stdcall;
  end;


  // ����ṹ���ʾһ��V8ֵ�ľ����V8��ش�������ڴ��������߳��з��ʡ�
  // �ɴ���V8�������Ч�̰߳�����Ⱦ�̵߳����߳�(TID_RENDERER)��WebWorker�̡߳�
  // ���ʼ�(post)task���񵽹����̵߳�TaskRunner��ͨ��cef_v8context_t::get_task_runner()
  // �������
  TCefv8Value = record
    // ���ṹ��
    base: TCefBase;

    // �������������Ч���ҿ��ڵ�ǰ�߳��з����򷵻�true (1)��
    // ������false(0)ʱ��Ҫ��������ṹ�������������
    is_valid: function(self: PCefv8Value): Integer; stdcall;
    // ���ֵ������undefined�򷵻�True��
    is_undefined: function(self: PCefv8Value): Integer; stdcall;
    // ���ֵ������null�򷵻�True��
    is_null: function(self: PCefv8Value): Integer; stdcall;
    // ���ֵ������bool�����򷵻�True��
    is_bool: function(self: PCefv8Value): Integer; stdcall;
    // ���ֵ������int�����򷵻�True��
    is_int: function(self: PCefv8Value): Integer; stdcall;
    // ���ֵ������unsigned int�����򷵻�True��
    is_uint: function(self: PCefv8Value): Integer; stdcall;
    // ���ֵ������double�����򷵻�True��
    is_double: function(self: PCefv8Value): Integer; stdcall;
    // ���ֵ������Date�����򷵻�True��
    is_date: function(self: PCefv8Value): Integer; stdcall;
    // ���ֵ������string�����򷵻�True��
    is_string: function(self: PCefv8Value): Integer; stdcall;
    // ���ֵ������object�����򷵻�True��
    is_object: function(self: PCefv8Value): Integer; stdcall;
    // ���ֵ������array�����򷵻�True��
    is_array: function(self: PCefv8Value): Integer; stdcall;
    // ���ֵ������function�����򷵻�True��
    is_function: function(self: PCefv8Value): Integer; stdcall;

    // ���self��thatָ����ͬ�ľ���򷵻�true (1)
    is_same: function(self, that: PCefv8Value): Integer; stdcall;

    // ��ȡһ��boolֵ�������Ҫ��������ת��
    get_bool_value: function(self: PCefv8Value): Integer; stdcall;
    // ��ȡһ��intֵ�������Ҫ��������ת��
    get_int_value: function(self: PCefv8Value): Integer; stdcall;
    // ��ȡһ��uintֵ�������Ҫ��������ת��
    get_uint_value: function(self: PCefv8Value): Cardinal; stdcall;
    // ��ȡһ��doubleֵ�������Ҫ��������ת��
    get_double_value: function(self: PCefv8Value): Double; stdcall;
    // ��ȡһ��Dateֵ�������Ҫ��������ת��
    get_date_value: function(self: PCefv8Value): TCefTime; stdcall;
    // ��ȡһ��stringֵ�������Ҫ��������ת��
    // ����ַ����������cef_string_userfree_free()�����١�
    get_string_value: function(self: PCefv8Value): PCefStringUserFree; stdcall;


    // ���󷽷� - ������Щ�������ڶ����п��á�����ͺ���Ҳ�Ƕ���
    // �����Ҫ��String-�ͻ���integer�ļ�Ҳ�������ڲ�������ת����
  
    // �������һ���û������Ķ����򷵻�true (1)
    is_user_created: function(self: PCefv8Value): Integer; stdcall;

    // ��������һ�κ��������׳����쳣�򷵻�true (1)��������Խ����ڵ�ǰCEF��
    // value�����������С�
    has_exception: function(self: PCefv8Value): Integer; stdcall;

    // ��ȡ����쳣���������׳����쳣��������Խ����ڵ�ǰCEF��value�����������С�
    get_exception: function(self: PCefv8Value): PCefV8Exception; stdcall;

    // ���������쳣������ɹ��򷵻�true (1)
    clear_exception: function(self: PCefv8Value): Integer; stdcall;

    // ���������������쳣���򷵻�true (1)��������Խ����ڵ�ǰCEF��value�����������С�
    will_rethrow_exceptions: function(self: PCefv8Value): Integer; stdcall;

    // ������������ͷŽ����쳣��Ĭ��������ǲ��������쳣�ġ�
    // ����������쳣����ǰ�����Ĳ�Ӧ���ڼ������ʣ�ֱ���쳣����׽�������쳣��
    // ������óɹ��򷵻�true (1)��������Խ����ڵ�ǰCEF��value�����������С�
    set_rethrow_exceptions: function(self: PCefv8Value; rethrow: Integer): Integer; stdcall;


    // ���������ָ����ʶ����ֵ�򷵻�true (1)��
    has_value_bykey: function(self: PCefv8Value; const key: PCefString): Integer; stdcall;
    // ���������ָ��������ֵ�򷵻�true (1)��
    has_value_byindex: function(self: PCefv8Value; index: Integer): Integer; stdcall;

    // ����ָ����ʶ��ɾ��ֵ�����ɹ�ʱ����true (1)��
    // �������������ò���ȷ���׳��쳣�򷵻�false (0)��
    // ����ֻ���Ͳ���ɾ����ֵ����ʹɾ��ʧ�ܣ��������Ҳ�᷵��true (1)��
    delete_value_bykey: function(self: PCefv8Value; const key: PCefString): Integer; stdcall;
    // ����ָ������ɾ��ֵ�����ɹ�ʱ����true (1)��
    // �������������ò���ȷ���׳��쳣�򷵻�false (0)��
    // ����ֻ���Ͳ���ɾ����ֵ����ʹɾ��ʧ�ܣ��������Ҳ�᷵��true (1)��
    delete_value_byindex: function(self: PCefv8Value; index: Integer): Integer; stdcall;

    // ���ɹ�ʱ����ָ����ʶ����ֵ���������������ò���ȷ���׳��쳣�򷵻�NULL��
    get_value_bykey: function(self: PCefv8Value; const key: PCefString): PCefv8Value; stdcall;
    // ���ɹ�ʱ����ָ��������ֵ���������������ò���ȷ���׳��쳣�򷵻�NULL��
    get_value_byindex: function(self: PCefv8Value; index: Integer): PCefv8Value; stdcall;

    // ����ָ����ʶ����ֵ���ɹ��򷵻�true (1)���������������ò���ȷ���׳��쳣�򷵻�false (0)��
    // ����ֻ���Ͳ���ɾ����ֵ����ʹɾ��ʧ�ܣ��������Ҳ�᷵��true (1)��
    set_value_bykey: function(self: PCefv8Value; const key: PCefString;
      value: PCefv8Value; attribute: Integer): Integer; stdcall;
    // ����ָ��������ֵ���ɹ��򷵻�true (1)���������������ò���ȷ���׳��쳣�򷵻�false (0)��
    // ����ֻ���Ͳ���ɾ����ֵ����ʹɾ��ʧ�ܣ��������Ҳ�᷵��true (1)��
    set_value_byindex: function(self: PCefv8Value; index: Integer;
       value: PCefv8Value): Integer; stdcall;

    // ע��һ����ʶ��������ɹ��򷵻�true (1)�����������ʶ��ʱ��ǰ�������ݸ�
    // cef_v8value_t::cef_v8value_create_object()��cef_v8accessor_tʵ����
    // �������������ò���ȷ���׳��쳣�򷵻�false (0)��
    // ����ֻ���Ͳ���ɾ����ֵ����ʹɾ��ʧ�ܣ��������Ҳ�᷵��true (1)��
    set_value_byaccessor: function(self: PCefv8Value; const key: PCefString;
      settings: Integer; attribute: Integer): Integer; stdcall;

    // ����������м�(key)��ӵ�ָ���б��С�����Integer�ļ�Ҳ����ת��Ϊ�ַ�����
    get_keys: function(self: PCefv8Value; keys: TCefStringList): Integer; stdcall;

    // Ϊ��������user data������ɹ��򷵻�true (1)���������������ò���ȷ�򷵻�
    // false (0)������������������û������Ķ����ϵ��á�
    set_user_data: function(self: PCefv8Value; user_data: PCefBase): Integer; stdcall;

    // ��ȡ�����user data(�������)
    get_user_data: function(self: PCefv8Value): PCefBase; stdcall;

    // ��ȡΪ����������Ķ����ڴ��С��
    get_externally_allocated_memory: function(self: PCefv8Value): Integer; stdcall;

    // ����Ϊ����������õĶ����ڴ��С������������ڸ�V8�е�JavaScript�������
    // һ�������ڴ档V8�ڽ���ȫ����������ʱ��Ҫ��Щ��Ϣ��
    // ÿ��cef_v8value_t��¼�����������Ķ����ڴ棬������������ʱ�Զ��������ü�����
    // |change_in_bytes|ָ���������ֽ����������ص��������������ֽ�������
    // ��������������û������Ķ����ϱ����á�
    adjust_externally_allocated_memory: function(self: PCefv8Value; change_in_bytes: Integer): Integer; stdcall;

    // ���鷽�� - ��Щ����������������Ч

    // ��ȡ�������е�Ԫ������
    get_array_length: function(self: PCefv8Value): Integer; stdcall;


    // �������� - ��Щ�������ں�������Ч

    // ��ȡ��������
    // ����ַ����������cef_string_userfree_free()�����١�
    get_function_name: function(self: PCefv8Value): PCefStringUserFree; stdcall;

    // ��ȡ�����Ĵ��������������CEF�����ĺ����򷵻�NULL
    get_function_handler: function(
        self: PCefv8Value): PCefv8Handler; stdcall;

    // ʹ�õ�ǰ��V8������ִ��������������������Ӧ����cef_v8handler_t���������
    // cef_v8accessor_t�Ļص�����һ��cef_v8context_t���õ�enter()��exit()
    // ����֮��Ĵ����б����á�
    // |object|�Ǻ�����'this'�������|object|ΪNULL����ʹ�õ�ǰ�����ĵ�ȫ�ֶ���
    // |arguments|Ϊ�����ݸ������Ĳ����б�
    // ���ɹ�ʱ���غ����ķ���ֵ������������ò���ȷ���׳��쳣�򷵻�NULL��
    execute_function: function(self: PCefv8Value; obj: PCefv8Value;
      argumentsCount: NativeUInt; const arguments: PPCefV8Value): PCefv8Value; stdcall;

    // ʹ��ָ����V8������ִ�����������|object| is the
    // |object|�Ǻ�����'this'�������|object|ΪNULL����ʹ����������ĵ�ȫ�ֶ���
    // |arguments|Ϊ�����ݸ������Ĳ����б�
    // ���ɹ�ʱ���غ����ķ���ֵ������������ò���ȷ���׳��쳣�򷵻�NULL��
    execute_function_with_context: function(self: PCefv8Value; context: PCefv8Context;
      obj: PCefv8Value; argumentsCount: NativeUInt; const arguments: PPCefV8Value): PCefv8Value; stdcall;
  end;

  // ����ṹ����V8��ջ�켣�����V8��������ڴ��������߳��б����ʡ�
  // �ɴ���V8�������Ч�̰߳�����Ⱦ�̵߳����߳�(TID_RENDERER)��WebWorker�̡߳�
  // ���ʼ�(post)task���񵽹����̵߳�TaskRunner��ͨ��cef_v8context_t::get_task_runner()
  // �������
  TCefV8StackTrace = record
    // ���ṹ��
    base: TCefBase;

    // �������������Ч���ҿ��ڵ�ǰ�߳��з����򷵻�true (1)��
    // ������false(0)ʱ��Ҫ��������ṹ�������������
    is_valid: function(self: PCefV8StackTrace): Integer; stdcall;

    // ��ȡ��ջ֡������
    get_frame_count: function(self: PCefV8StackTrace): Integer; stdcall;

    // ��ȡָ������0�����Ķ�ջ֡
    get_frame: function(self: PCefV8StackTrace; index: Integer): PCefV8StackFrame; stdcall;
  end;

  // ����ṹ���ʾһ��V8��ջ֡�����V8��������ڴ��������߳��б����ʡ�
  // �ɴ���V8�������Ч�̰߳�����Ⱦ�̵߳����߳�(TID_RENDERER)��WebWorker�̡߳�
  // ���ʼ�(post)task���񵽹����̵߳�TaskRunner��ͨ��cef_v8context_t::get_task_runner()
  // �������.

  TCefV8StackFrame = record
    // ���ṹ��
    base: TCefBase;

    // �������������Ч���ҿ��ڵ�ǰ�߳��з����򷵻�true (1)��
    // ������false(0)ʱ��Ҫ��������ṹ�������������
    is_valid: function(self: PCefV8StackFrame): Integer; stdcall;

    // ��ȡ������������Ľű���Դ������
    // ����ַ����������cef_string_userfree_free()�����١�
    get_script_name: function(self: PCefV8StackFrame): PCefStringUserFree; stdcall;

    // ��ȡ������������Ľű���Դ�����ƣ��򵱽ű�����δ����ʱ��������Դĩβ����
    // "//@ sourceURL=..."�ַ���ʱ����sourceURL��
    // ����ַ����������cef_string_userfree_free()�����١�
    get_script_name_or_source_url: function(self: PCefV8StackFrame): PCefStringUserFree; stdcall;

    // ��ȡ����������
    // ����ַ����������cef_string_userfree_free()�����١�
    get_function_name: function(self: PCefV8StackFrame): PCefStringUserFree; stdcall;

    // ��ȡ�������û���1���кţ����δ֪�򷵻�0
    get_line_number: function(self: PCefV8StackFrame): Integer; stdcall;

    // ��ȡ�������û���1����ƫ�ƣ����δ֪�򷵻�0
    get_column: function(self: PCefV8StackFrame): Integer; stdcall;

    // ���������ʹ��eval()������򷵻�true (1)
    is_eval: function(self: PCefV8StackFrame): Integer; stdcall;

    // ���������ͨ��"new"��Ϊ���������ã��򷵻�true (1)
    is_constructor: function(self: PCefV8StackFrame): Integer; stdcall;
  end;

  // ����ṹ������Զ���schemeע��
  TCefSchemeRegistrar = record
    // ���ṹ��
    base: TCefBase;

    // ע��һ���Զ���scheme����Ӧ��Ϊ�ڽ���HTTP��HTTPS��FILE��FTP��ABOUT ��DATA
    // �������������
    // ���|is_standard|Ϊtrue (1)����scheme����������׼scheme��
    // ��׼scheme������ͨ��Internet Scheme�﷨����(RFC 1738 Section 3.1
    // available at http://www.ietf.org/rfc/rfc1738.txt)��URL��׼�ͽ�������
    //
    // ����, ��׼schemeURLӦ�������¸�ʽ:
    // <pre>
    //  [scheme]://[username]:[password]@[host]:[port]/[url-path]
    // </pre> ��׼schemeURL������һ��host���֣�����һ������������(������Section 3.5 of RFC 1034 [13]��
    // Section 2.1 of RFC 1123)��
    // "scheme://host/path" ������ʽ��
    // "scheme://username:password@host:port/path"����ȫ��ʽ��
    // "scheme:host/path" �� "scheme:///host/path"�����ȼ���"scheme://host/path"��
    //  ��׼schemeURL��scheme��host��port����� (����ȫ��ʽ�е�"scheme://host:port")��
    //
    // ���ڷǱ�׼schemeURL����"scheme:"���ֱ�������
    // URL��ʣ�ಿ�ֽ����ݸ�������������"scheme:///some%20text"������ͬ�Ĳ��֡�
    // �Ǳ�׼schemeURL������Ϊform��Ŀ���ύ��
    //
    // ���|is_local|Ϊtrue (1)����scheme��������һ������URL(����"file"����ͬ�İ�ȫ
    // ����)����������ҳ�������ӻ���ʱ���URL��ͬʱ��Ĭ������£�����URL����ִ��
    // XMLHttpRequest���õ�ԭʼ�������ͬURL(origin + path)��
    // Ҫ�������Ա���URL��XMLHttpRequest����������ͬ���URL��������
    // CefSettings.file_access_from_file_urls_allowedֵΪtrue (1)��
    // Ҫ����һ������URLͨ��XMLHttpRequest����������������
    // CefSettings.universal_access_from_file_urls_allowedֵΪtrue (1)��
    //
    // ���|is_display_isolated|Ϊtrue (1)����scheme����������ʾ����(display-isolated)��
    // ����ζ��ҳ���޷���ʾ��ЩURL����������������ͬ��scheme��
    // ���磬����һ�����ҳ���޷��������schemeURL��iframes�����ӡ�
    //
    // ��������������κ��߳��б����á���Ӧ��Ϊÿ��|scheme_name|������һ�Ρ�
    // ���|scheme_name|�Ѿ�ע�ᣬ���߷��������򷵻�false (0)��
    add_custom_scheme: function(self: PCefSchemeRegistrar;
      const scheme_name: PCefString; is_standard, is_local,
      is_display_isolated: Integer): Integer; stdcall;
  end;

  // ����ṹ�崴��һ��cef_scheme_handler_tʵ�����������������IO�߳��б����á�
  TCefSchemeHandlerFactory = record
    // ���ṹ��
    base: TCefBase;

    // ����һ����Դ������ʵ�����������󣬻򷵻�NULL��ʹ��Ĭ�ϵ�����������
    // |browser|��|frame|�ֱ��������������ڵ���������ں�frame����������Ǵ�
    // �����(������������cef_urlrequest_t)�����ǽ�ΪNULL��
    // ���ݸ����������|request|���󲻰���cookie���ݡ�
    create: function(self: PCefSchemeHandlerFactory;
        browser: PCefBrowser; frame: PCefFrame; const scheme_name: PCefString;
        request: PCefRequest): PCefResourceHandler; stdcall;
  end;

  // ����ṹ���ʾһ��������
  TCefDownloadItem = record
    // ���ṹ��
    base: TCefBase;

    // �������������Ч���ҿ��ڵ�ǰ�߳��з����򷵻�true (1)��
    // ������false(0)ʱ��Ҫ��������ṹ�������������
    is_valid: function(self: PCefDownloadItem): Integer; stdcall;

    // ������������򷵻�true (1)
    is_in_progress: function(self: PCefDownloadItem): Integer; stdcall;

    // �����������򷵻�true (1)
    is_complete: function(self: PCefDownloadItem): Integer; stdcall;

    // ������ر�ȡ�����жϣ��򷵻�true (1)
    is_canceled: function(self: PCefDownloadItem): Integer; stdcall;

    // ��ȡһ���򵥵������ٶ�bytes/s.
    get_current_speed: function(self: PCefDownloadItem): Int64; stdcall;

    // ��ȡ������ɶȰٷֱȣ���������ܴ�Сδ֪�򷵻�-1��
    get_percent_complete: function(self: PCefDownloadItem): Integer; stdcall;

    // ��ȡ�����ļ��ܴ�С(�ֽ�)
    get_total_bytes: function(self: PCefDownloadItem): Int64; stdcall;

    // ��ȡ�����صĴ�С(�ֽ�)
    get_received_bytes: function(self: PCefDownloadItem): Int64; stdcall;

    // ��ȡ���ص���ʼʱ��
    get_start_time: function(self: PCefDownloadItem): TCefTime; stdcall;

    // ��ȡ���صĽ���ʱ��
    get_end_time: function(self: PCefDownloadItem): TCefTime; stdcall;

    // ��ȡ������/������ɵ��ļ�ȫ·��
    // ����ַ����������cef_string_userfree_free()�����١�
    get_full_path: function(self: PCefDownloadItem): PCefStringUserFree; stdcall;

    // ��ȡ�������Ψһ��ʶ��
    get_id: function(self: PCefDownloadItem): Cardinal; stdcall;

    // ��ȡ���ص�URL��
    // ����ַ����������cef_string_userfree_free()�����١�
    get_url: function(self: PCefDownloadItem): PCefStringUserFree; stdcall;

    // Returns the original URL before any redirections.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_original_url: function(self: PCefDownloadItem): PCefStringUserFree; stdcall;

    // ��ȡ�Ƽ����ļ���
    // ����ַ����������cef_string_userfree_free()�����١�
    get_suggested_file_name: function(self: PCefDownloadItem): PCefStringUserFree; stdcall;

    // ��ȡ�������ݷֲ�
    // ����ַ����������cef_string_userfree_free()�����١�
    get_content_disposition: function(self: PCefDownloadItem): PCefStringUserFree; stdcall;

    // ��ȡmime����
    // ����ַ����������cef_string_userfree_free()�����١�
    get_mime_type: function(self: PCefDownloadItem): PCefStringUserFree; stdcall;
  end;

  // ����ṹ�������첽�������ؼ���
  TCefBeforeDownloadCallback = record
    // ���ṹ��
    base: TCefBase;

    // �����������ء�����|download_path|Ϊ���������ð����ļ�����ȫ·����������
    // ʹ���Ƽ����ļ�������ʱĿ¼��
    // ����ϣ����ʾһ��"���Ϊ"�Ի���ʱ��������|show_dialog|Ϊtrue (1)��
    cont: procedure(self: PCefBeforeDownloadCallback;
      const download_path: PCefString; show_dialog: Integer); stdcall;
  end;

  // ����ṹͼ�����첽ȡ������
  TCefDownloadItemCallback = record
    // ���ṹ��
    base: TCefBase;


    // �������������ȡ������
    cancel: procedure(self: PCefDownloadItemCallback); stdcall;
    // ���������������ͣ����
    pause: procedure(self: PCefDownloadItemCallback); stdcall;
    // ���������������������
    resume: procedure(self: PCefDownloadItemCallback); stdcall;
  end;

  // ����ṹ�����ڴ����ļ����ء���Щ������������UI�߳��е��á�
  TCefDownloadHandler = record
    // ���ṹ��
    base: TCefBase;

    // �ڿ�ʼ����֮ǰ�����á�|suggested_name|�������ļ��Ľ����ļ�����
    // Ĭ����������ؽ���ȡ��������������л��첽ִ��|callback|�����������ص��
    // ��Ҫ���������֮�Ᵽ��|download_item|�����á�
    on_before_download: procedure(self: PCefDownloadHandler;
      browser: PCefBrowser; download_item: PCefDownloadItem;
      const suggested_name: PCefString; callback: PCefBeforeDownloadCallback); stdcall;

    // ���������״̬�������Ϣ������ʱ��������
    // �������ڵ���on_before_download()��ǰ�󱻵��ö�Ρ�
    // ����������л��첽ִ��|callback|�����������ص��
    // ��Ҫ���������֮�Ᵽ��|download_item|�����á�
    on_download_updated: procedure(self: PCefDownloadHandler;
        browser: PCefBrowser; download_item: PCefDownloadItem;
        callback: PCefDownloadItemCallback); stdcall;
  end;

  // ����ṹ��֧��ͨ��libxml��API����XML���ݽ��ж�ȡ��
  // ��Щ������Ӧ���ڱ������Ķ����б����á�
  TCefXmlReader = record
    // ���ṹ��
    base: TcefBase;

    // �ƶ��ĵ��еĹ�굽��һ���ڵ㡣�������������ٵ���һ�������õ�ǰ���λ�á�
    // ������λ�����óɹ����򷵻�true (1)
    move_to_next_node: function(self: PCefXmlReader): Integer; stdcall;

    // �ر��ĵ���Ӧ��ֱ�ӵ�������ʹ������ȷ���߳��б����
    close: function(self: PCefXmlReader): Integer; stdcall;

    // ���XML����������������򷵻�true (1)
    has_error: function(self: PCefXmlReader): Integer; stdcall;

    // ��ȡ�����ַ�����
    // ����ַ����������cef_string_userfree_free()�����١�
    get_error: function(self: PCefXmlReader): PCefStringUserFree; stdcall;


    // ������Щ�������ڻ�ȡ��ǰ���λ�õ����ݡ�

    // ��ȡ�ڵ�����
    get_type: function(self: PCefXmlReader): TCefXmlNodeType; stdcall;

    // ��ȡ�ڵ����ȡ���ȴ�Ϊ0�ĸ��ڵ㿪ʼ���㡣
    get_depth: function(self: PCefXmlReader): Integer; stdcall;

    // ��ȡ����(local)���� ����μ�http://www.w3.org/TR/REC-xml-names/#NT-LocalPart��
    // ����ַ����������cef_string_userfree_free()�����١�
    get_local_name: function(self: PCefXmlReader): PCefStringUserFree; stdcall;

    // ��ȡ���ƿռ�ǰ׺������μ�http://www.w3.org/TR/REC-xml-names/ 
    // ����ַ����������cef_string_userfree_free()�����١�
    get_prefix: function(self: PCefXmlReader): PCefStringUserFree; stdcall;

    // ��ȡ�����ڵ���, ��ͬ��(Prefix:)LocalName. ����μ�
    // http://www.w3.org/TR/REC-xml-names/#ns-qualnames
    // ����ַ����������cef_string_userfree_free()�����١�
    get_qualified_name: function(self: PCefXmlReader): PCefStringUserFree; stdcall;

    // ��ȡ�ڵ���������ƿռ��URL���塣����μ�http://www.w3.org/TR/REC-xml-names/ 
    // ����ַ����������cef_string_userfree_free()�����١�
    get_namespace_uri: function(self: PCefXmlReader): PCefStringUserFree; stdcall;

    // ��ȡ�ڵ�Ļ�URL������μ� http://www.w3.org/TR/xmlbase/ 
    // ����ַ����������cef_string_userfree_free()�����١�
    get_base_uri: function(self: PCefXmlReader): PCefStringUserFree; stdcall;

    // ��ȡ�ڵ�������xml:lang����������μ�http://www.w3.org/TR/REC-xml/#sec-lang-tag 
    // ����ַ����������cef_string_userfree_free()�����١�
    get_xml_lang: function(self: PCefXmlReader): PCefStringUserFree; stdcall;

    // ����ڵ��ʾһ��NULLԪ�أ��򷵻�true (1)������<a/>��һ��NULLԪ�أ���
    // <a></a>���ǡ�
    is_empty_element: function(self: PCefXmlReader): Integer; stdcall;

    // ����ڵ���һ���ı�ֵ���򷵻�true (1)
    has_value: function(self: PCefXmlReader): Integer; stdcall;

    // ��ȡ�ı�ֵ
    // ����ַ����������cef_string_userfree_free()�����١�
    get_value: function(self: PCefXmlReader): PCefStringUserFree; stdcall;

    // ����ڵ������ԣ��򷵻�true (1)
    has_attributes: function(self: PCefXmlReader): Integer; stdcall;

    // �������Ե�����
    get_attribute_count: function(self: PCefXmlReader): NativeUInt; stdcall;

    // ���ݻ���0��������ȡ�ڵ������ֵ��
    // ����ַ����������cef_string_userfree_free()�����١�
    get_attribute_byindex: function(self: PCefXmlReader; index: Integer): PCefStringUserFree; stdcall;

    // ������������ȡ�ڵ������ֵ��
    // ����ַ����������cef_string_userfree_free()�����١�
    get_attribute_byqname: function(self: PCefXmlReader; const qualifiedName: PCefString): PCefStringUserFree; stdcall;

    // ����ָ����local��namespace URI��ȡ�ڵ������ֵ��
    // ����ַ����������cef_string_userfree_free()�����١�
    get_attribute_bylname: function(self: PCefXmlReader; const localName, namespaceURI: PCefString): PCefStringUserFree; stdcall;

    // ��ȡ��ǰ�ڵ���ӽڵ��ǵ�XML��ʾ��
    // ����ַ����������cef_string_userfree_free()�����١�
    get_inner_xml: function(self: PCefXmlReader): PCefStringUserFree; stdcall;

    // ��ȡ��ǰ�ڵ��Լ��ӽڵ��ǵ�XML��ʾ��
    // ����ַ����������cef_string_userfree_free()�����١�
    get_outer_xml: function(self: PCefXmlReader): PCefStringUserFree; stdcall;

    // ��ȡ��ǰ�ڵ���к�
    get_line_number: function(self: PCefXmlReader): Integer; stdcall;


    // Ĭ������²��������Խڵ㡣������������ɽ�����ƶ������Խڵ��ϡ�
    // move_to_carrying_element()�������ƶ���굽���ڴ����Ԫ���ϡ�
    // һ�����Խڵ�����(depth)���������ڴ���Ԫ�ص����+1��

    // �ƶ���굽����0�����������ϡ�����ɹ����ù��λ�ã��򷵻�true (1)��
    move_to_attribute_byindex: function(self: PCefXmlReader; index: Integer): Integer; stdcall;

    // �ƶ���굽qualifiedNameָ���������ϡ�����ɹ����ù��λ�ã��򷵻�true (1)��
    move_to_attribute_byqname: function(self: PCefXmlReader; const qualifiedName: PCefString): Integer; stdcall;

    // �ƶ���굽��localName��namespaceURIָ���������ϡ�����ɹ����ù��λ�ã��򷵻�true (1)��
    move_to_attribute_bylname: function(self: PCefXmlReader; const localName, namespaceURI: PCefString): Integer; stdcall;

    // �ƶ���굽��ǰԪ�صĵ�һ�����ϡ�����ɹ����ù��λ�ã��򷵻�true (1)��
    move_to_first_attribute: function(self: PCefXmlReader): Integer; stdcall;

    // �ڵ�ǰԪ���У��ƶ���굽��һ�������ϡ�����ɹ����ù��λ�ã��򷵻�true (1)��
    move_to_next_attribute: function(self: PCefXmlReader): Integer; stdcall;

    // �������������ƶ�����ǰԪ���ϡ�����ɹ����ù��λ�ã��򷵻�true (1)��
    move_to_carrying_element: function(self: PCefXmlReader): Integer; stdcall;
  end;

  // ����ṹ������ͨ��zlib API֧�ֶ�zip�����Ķ�ȡ����Щ������Ӧ���ڴ���������߳�
  // �ϱ�����
  TCefZipReader = record
    // ���ṹ��
    base: TCefBase;

    // �ƶ���굽�����еĵ�һ���ļ��ϡ����������óɹ��򷵻�true (1)��
    move_to_first_file: function(self: PCefZipReader): Integer; stdcall;

    // �ƶ���굽��������һ���ļ������������óɹ��򷵻�true (1)��
    move_to_next_file: function(self: PCefZipReader): Integer; stdcall;

    // �ƶ���굽�����е�ָ���ļ��ϡ����|caseSensitive|Ϊtrue,���������Ǵ�Сд���еġ�
    // ���������óɹ��򷵻�true (1)��
    move_to_file: function(self: PCefZipReader; const fileName: PCefString; caseSensitive: Integer): Integer; stdcall;

    // �رյ�����Ӧ������ȷ���߳���ֱ�ӵ�����������������ݡ�
    close: function(Self: PCefZipReader): Integer; stdcall;


    // ��������������ڵ�ǰ���λ�õĲ�����

    // ��ȡ�ļ���
    // ����ַ����������cef_string_userfree_free()�����١�
    get_file_name: function(Self: PCefZipReader): PCefStringUserFree; stdcall;

    // ��ȡ�ļ���δѹ���ߴ�
    get_file_size: function(Self: PCefZipReader): Int64; stdcall;

    // ��ȡ�ļ�������޸�ʱ���
    get_file_last_modified: function(Self: PCefZipReader): TCefTime; stdcall;

    // ���ļ��Ա��ȡδѹ�����ݡ�����ָ��һ����ȡ���롣
    open_file: function(Self: PCefZipReader; const password: PCefString): Integer; stdcall;

    // �ر��ļ�
    close_file: function(Self: PCefZipReader): Integer; stdcall;

    // ��ȡδѹ�����ļ����ݵ�ָ���Ļ�������������������򷵻�<0��ֵ��
    // ����0��ζ�ŵ����ļ�β�������򷵻�ֵ�Ƕ�ȡ���ֽ�����
    read_file: function(Self: PCefZipReader; buffer: Pointer; bufferSize: NativeUInt): Integer; stdcall;

    // ��ȡ��ǰ��δѹ���ļ����ݵ�ƫ��λ��
    tell: function(Self: PCefZipReader): Int64; stdcall;

    // ��ǰ�Ƿ񵽴��ļ����ݵ�β��
    eof: function(Self: PCefZipReader): Integer; stdcall;
  end;

  // ����ṹ�����ڷ���DOM����Щ������������Ⱦ�̵߳����߳��е��á�
  TCefDomVisitor = record
    // ���ṹ��
    base: TCefBase;

    // ����DOMִ�еķ�����document�Ǵ��ݸ������ĵ�ǰDOM�Ŀ��ա�
    // DOM��������������������������Ч����Ҫ���������֮�Ᵽ���κ�DOM��������á�
    visit: procedure(self: PCefDomVisitor; document: PCefDomDocument); stdcall;
  end;


  // ����ṹ�����һ��DOM�ĵ�����Щ��������������Ⱦ���̵����߳��е��á�
  TCefDomDocument = record
    // ���ṹ��
    base: TCefBase;

    // ��ȡ�ĵ�����
    get_type: function(self: PCefDomDocument): TCefDomDocumentType; stdcall;

    // ��ȡ�ĵ����ڵ�
    get_document: function(self: PCefDomDocument): PCefDomNode; stdcall;

    // ��ȡHTML�ĵ���BODY�ڵ�
    get_body: function(self: PCefDomDocument): PCefDomNode; stdcall;

    // ��ȡHTML�ĵ���HEAD�ڵ�
    get_head: function(self: PCefDomDocument): PCefDomNode; stdcall;

    // ��ȡHTML�ĵ��ı���
    // ����ַ����������cef_string_userfree_free()�����١�
    get_title: function(self: PCefDomDocument): PCefStringUserFree; stdcall;

    // ����ָ��ID��ȡ�ĵ�Ԫ��
    get_element_by_id: function(self: PCefDomDocument; const id: PCefString): PCefDomNode; stdcall;

    // ��ȡ��ǰ�м��̽���Ľڵ�
    get_focused_node: function(self: PCefDomDocument): PCefDomNode; stdcall;

    // ����ĵ����в���Ԫ�ر�ѡ���򷵻�true (1)
    has_selection: function(self: PCefDomDocument): Integer; stdcall;

    // ��ȡѡ�����ݵ���ʼ�ڵ��ƫ��
    get_selection_start_offset: function(self: PCefDomDocument): Integer; stdcall;

    // ��ȡѡ�����ݵ�ĩβ�ڵ��ƫ��
    get_selection_end_offset: function(self: PCefDomDocument): Integer; stdcall;

    // ��ȡѡ�����ݵ�HTML���
    // ����ַ����������cef_string_userfree_free()�����١�
    get_selection_as_markup: function(self: PCefDomDocument): PCefStringUserFree; stdcall;

    // ��ȡѡ�����ݵ��ı�
    // ����ַ����������cef_string_userfree_free()�����١�
    get_selection_as_text: function(self: PCefDomDocument): PCefStringUserFree; stdcall;

    // ��ȡ����ĵ��Ļ�URL
    // ����ַ����������cef_string_userfree_free()�����١�
    get_base_url: function(self: PCefDomDocument): PCefStringUserFree; stdcall;

    // ��ȡ���ĵ��Ļ�URL��partialURL��ɵ�����URl��
    // ����ַ����������cef_string_userfree_free()�����١�
    get_complete_url: function(self: PCefDomDocument; const partialURL: PCefString): PCefStringUserFree; stdcall;
  end;


  // ����ṹ���ʾһ��DOM�ڵ㡣��Щ������������Ⱦ���̵����߳��б����á�
  TCefDomNode = record
    // ���ṹ��
    base: TCefBase;

    // ��ȡ����ڵ������
    get_type: function(self: PCefDomNode): TCefDomNodeType; stdcall;

    // �������ڵ���һ���ı��ڵ㣬�򷵻�true (1)
    is_text: function(self: PCefDomNode): Integer; stdcall;

    // �������ڵ���һ��Ԫ�ؽڵ㣬�򷵻�true (1)
    is_element: function(self: PCefDomNode): Integer; stdcall;

    // ����ڵ���һ���ɱ༭�ڵ㣬�򷵻�true (1)
    is_editable: function(self: PCefDomNode): Integer; stdcall;

    // �������һ�����ؼ�Ԫ�ؽڵ㣬�򷵻�true (1)
    is_form_control_element: function(self: PCefDomNode): Integer; stdcall;

    // ��ȡ������ؼ��ڵ������
    // ����ַ����������cef_string_userfree_free()�����١�
    get_form_control_element_type: function(self: PCefDomNode): PCefStringUserFree; stdcall;

    // ���self��thatָ����ͬ�ľ�����򷵻�true (1)
    is_same: function(self, that: PCefDomNode): Integer; stdcall;

    // ��ȡ����ڵ������
    // ����ַ����������cef_string_userfree_free()�����١�
    get_name: function(self: PCefDomNode): PCefStringUserFree; stdcall;

    // ��ȡ����ڵ��valueֵ
    // ����ַ����������cef_string_userfree_free()�����١�
    get_value: function(self: PCefDomNode): PCefStringUserFree; stdcall;

    // ��������ڵ�valueֵ������ɹ��򷵻�true (1)��
    set_value: function(self: PCefDomNode; const value: PCefString): Integer; stdcall;

    // ������ڵ��������ΪHTML��Ƿ���
    // ����ַ����������cef_string_userfree_free()�����١�
    get_as_markup: function(self: PCefDomNode): PCefStringUserFree; stdcall;

    // ��ȡ����ڵ�������ĵ�
    get_document: function(self: PCefDomNode): PCefDomDocument; stdcall;

    // ��ȡ���ڵ�
    get_parent: function(self: PCefDomNode): PCefDomNode; stdcall;

    // ��ȡ����ڵ����һ���ֵܽڵ�
    get_previous_sibling: function(self: PCefDomNode): PCefDomNode; stdcall;

    // ��ȡ����ڵ����һ���ֵܽڵ�
    get_next_sibling: function(self: PCefDomNode): PCefDomNode; stdcall;

    // �������ڵ����ӽڵ㣬�򷵻�true (1)
    has_children: function(self: PCefDomNode): Integer; stdcall;

    // ��ȡ����ڵ�ĵ�һ���ӽڵ�
    get_first_child: function(self: PCefDomNode): PCefDomNode; stdcall;

    // ��ȡ����ڵ�����һ���ӽڵ�
    get_last_child: function(self: PCefDomNode): PCefDomNode; stdcall;

    // ������Щ��������Ԫ�ؽڵ���Ч

    // ��ȡ���Ԫ�صı�ǩ(tag)��
    // ����ַ����������cef_string_userfree_free()�����١�
    get_element_tag_name: function(self: PCefDomNode): PCefStringUserFree; stdcall;

    // ������Ԫ�������ԣ��򷵻�true (1)
    has_element_attributes: function(self: PCefDomNode): Integer; stdcall;

    // ������Ԫ�ش�������Ϊ|attrName|�����ԣ��򷵻�true (1)
    has_element_attribute: function(self: PCefDomNode; const attrName: PCefString): Integer; stdcall;

    // ��ȡ���Ԫ�ص�������Ϊ|attrName|������ֵ��
    // ����ַ����������cef_string_userfree_free()�����١�
    get_element_attribute: function(self: PCefDomNode; const attrName: PCefString): PCefStringUserFree; stdcall;

    // ��ȡ���Ԫ�ص���������ӳ���
    get_element_attributes: procedure(self: PCefDomNode; attrMap: TCefStringMap); stdcall;

    // �������Ԫ�ص�����Ϊ|attrName|������ֵ��������óɹ��򷵻�true (1)
    set_element_attribute: function(self: PCefDomNode; const attrName, value: PCefString): Integer; stdcall;

    // ��ȡ���Ԫ�ص��ڲ��ı�
    // ����ַ����������cef_string_userfree_free()�����١�
    get_element_inner_text: function(self: PCefDomNode): PCefStringUserFree; stdcall;
  end;

  // ����ṹ�����ڷ���cookieֵ����Щ����������IO�߳��з���
  TCefCookieVisitor = record
    // ���ṹ��
    base: TCefBase;

    // �����������ÿ��cookieֵ����һ�Ρ�|count|�ǵ�ǰcookie����0��������
    // |total|��cookie���������������|deleteCookie|Ϊtrue (1)���򽫻Ὣ��ǰ����
    // ��cookieɾ�����������ֹͣ����cookie,�򷵻�false (0)�����δ�ҵ�cookie����
    // ������������ᱻ����
    visit: function(self: PCefCookieVisitor; const cookie: PCefCookie;
      count, total: Integer; deleteCookie: PInteger): Integer; stdcall;
  end;

  // Structure to implement to be notified of asynchronous completion via
  // cef_cookie_manager_t::set_cookie().

  TCefSetCookieCallback = record
    // Base structure.
    base: TCefBase;

    // Method that will be called upon completion. |success| will be true (1) if
    // the cookie was set successfully.
    on_complete: procedure(self: PCefSetCookieCallback; success: Integer); stdcall;
  end;

  // Structure to implement to be notified of asynchronous completion via
  // cef_cookie_manager_t::delete_cookies().

  TCefDeleteCookiesCallback = record
    // Base structure.
    base: TCefBase;

    // Method that will be called upon completion. |num_deleted| will be the
    // number of cookies that were deleted or -1 if unknown.

    on_complete: procedure(self: PCefDeleteCookiesCallback; num_deleted: Integer); stdcall;
  end;

  // ����ṹ�����ڹ���cookies�������ر�ָ���ģ���Щ�����������κ��߳��б����á�
  TCefCookieManager = record
    // ���ṹ��
    base: TCefBase;

    // ���������֧�ֵ�scheme��Ĭ������½�֧��"http"��"https"��
	// ���|callback|��ΪNULL,�������ڸı䱻Ӧ��ʱ���첽��IO�߳��е��á�
    // �����ڷ����κ�cookie֮ǰ�����á�
    set_supported_schemes: procedure(self: PCefCookieManager;
      schemes: TCefStringList; callback: PCefCompletionCallback); stdcall;

    // ��������cookie�����ص�cookie����·�����ȡ��������ڽ������� ���cookie����
    // ���ʣ��򷵻�false (0)
    visit_all_cookies: function(self: PCefCookieManager; visitor: PCefCookieVisitor): Integer; stdcall;

    // ����cookie����URL��scheme��host��domain ��path���˵�һ���Ӽ���
    // ���|includeHttpOnly|Ϊtrue (1)�������HTTP��cookie�����ڽ���С�
    // ���ص�cookie����·�����ȡ��������ڽ������� ���cookie����
    // ���ʣ��򷵻�false (0)
    visit_url_cookies: function(self: PCefCookieManager; const url: PCefString;
      includeHttpOnly: Integer; visitor: PCefCookieVisitor): Integer; stdcall;

    // ����һ����Ч��URL���û��ṩ��cookie��������һ��cookie��
    // �������Ԥ��ÿ�����Զ��Ǹ�ʽ���õġ��������Ƿ��ַ�(����';'�ַ���cookie
    // ֵ���ǷǷ���)������ҵ��������ַ�����������cookie���ҷź�false (0)��
	// ���|callback|��ΪNULL,�������ڸı䱻Ӧ��ʱ���첽��IO�߳��е��á�
    // �������������IO�߳��б����á�
    set_cookie: function(self: PCefCookieManager; const url: PCefString;
      const cookie: PCefCookie; callback: PCefSetCookieCallback): Integer; stdcall;

    // ɾ��ƥ��ָ������������cookie�� If both |url| and
    // |cookie_name| values are specified all host and domain cookies matching
    // both will be deleted. If only |url| is specified all host cookies (but not
    // domain cookies) irrespective of path will be deleted. If |url| is NULL all
    // cookies for all hosts and domains will be deleted. If |callback| is non-
    // NULL it will be executed asnychronously on the IO thread after the cookies
    // have been deleted. Returns false (0) if a non-NULL invalid URL is specified
    // or if cookies cannot be accessed. Cookies can alternately be deleted using
    // the Visit*Cookies() functions.
    delete_cookies: function(self: PCefCookieManager; const url, cookie_name: PCefString;
      callback: PCefDeleteCookiesCallback): Integer; stdcall;

    // �������ڴ���cookie���ݵ�Ŀ¼·�������|path|ΪNULL�������ݽ��洢���ڴ��С�
    // �������ݽ��洢��ָ����|path|·���¡�
    // Ҫ�־û��Ự(session)cookie(û�й���ʱ�����Ч�����cookie)������
    // |persist_session_cookies|Ϊtrue (1)���Ựcookieһ�㶼����ʱ�ģ��󲿷�web
    // ��������־û����ǡ����cookie���ܷ����򷵻�false (0)��
	// ���|callback|��ΪNULL,�������ڸı䱻Ӧ��ʱ���첽��IO�߳��е��á�
    set_storage_path: function(self: PCefCookieManager;
      const path: PCefString; persist_session_cookies: Integer;
      callback: PCefCompletionCallback): Integer; stdcall;

    // ��ϴ��̨�洢(�������)�����̣������Ӱ���ɺ���IO�߳�ִ��ָ����|callback|��
    // ���cookie���ܷ����򷵻�false (0)
    flush_store: function(self: PCefCookieManager; handler: PCefCompletionCallback): Integer; stdcall;
  end;


  // ĳ���ض�web�������Ϣ

  TCefWebPluginInfo = record
    // ���ṹ��
    base: TCefBase;

    // ��ȡһ�������(����Flash)��
    get_name: function(self: PCefWebPluginInfo): PCefStringUserFree; stdcall;

    // ��ȡһ��������ļ�·��(DLL/bundle/library).
    get_path: function(self: PCefWebPluginInfo): PCefStringUserFree; stdcall;

    // ��ȡ����İ汾 (������OS-specific).
    get_version: function(self: PCefWebPluginInfo): PCefStringUserFree; stdcall;

    // �Ӱ汾��Ϣ�л�ȡ���������
    get_description: function(self: PCefWebPluginInfo): PCefStringUserFree; stdcall;
  end;

  // ����ṹ�����ڷ���web�����Ϣ����Щ��������������̵�UI�߳��з��ʡ�
  TCefWebPluginInfoVisitor = record
    // ���ṹ��
    base: TCefBase;

    // ���������Ϊÿ���������һ�Ρ�|count|�ǵ�ǰ�������0��������
    // |total|�ǲ���������������ֹͣ���ʲ��,�򷵻�false (0)�����δ�ҵ��������
    // ������������ᱻ����
    visit: function(self: PCefWebPluginInfoVisitor;
      info: PCefWebPluginInfo; count, total: Integer): Integer; stdcall;
  end;

  // ����ṹ�����ڽ��ղ��ȶ������Ϣ����Щ���������������IO�߳��б����á�
  TCefWebPluginUnstableCallback = record
    // ���ṹ��
    base: TCefBase;

    // ���������Ϊ����Ĳ��������������������120���ڲ���ı��������ﵽ��ֵ��4����
    // |unstable|Ϊtrue (1)��
    is_unstable: procedure(self: PCefWebPluginUnstableCallback;
        const path: PCefString; unstable: Integer); stdcall;
  end;

  // ����ṹ����������һ��URL����URL���󲻻����һ�������ʵ�������Բ��ᴥ��
  // cef_client_t�ص���URL�����������������̻���Ⱦ�����̵��κ���Ч��CEF�߳��б�������
  // һ�����������URL����������������������߳��з�����
  TCefUrlRequest = record
    // ���ṹ��
    base: TCefBase;

    //��ȡ�������URL�����������󡣷��صĶ�����ֻ���ġ�
    get_request: function(self: PCefUrlRequest): PCefRequest; stdcall;

    // ��ȡURL����ͻ���
    get_client: function(self: PCefUrlRequest): PCefUrlRequestClient; stdcall;

    // ��ȡ����״̬��
    get_request_status: function(self: PCefUrlRequest): TCefUrlRequestStatus; stdcall;

    // ���״̬��UR_CANCELED/UR_FAILEDʱ������������󣬷���Ϊ0��
    get_request_error: function(self: PCefUrlRequest): TCefErrorcode; stdcall;

    // ��ȡ��Ӧ�������Ӧ��Ϣ�����ã��򷵻�NULL��
    // ���ϴ���������Ӧ��Ϣ���ǿ��õġ����صĶ�����ֻ���ġ�
    get_response: function(self: PCefUrlRequest): PCefResponse; stdcall;

    // ȡ������
    cancel: procedure(self: PCefUrlRequest); stdcall;
  end;

  // ����ṹ������ʵ��һ��cef_urlrequest_t�ͻ��ˡ���������˵������Щ�������ڴ���
  // ���������߳��б����á�
  TCefUrlrequestClient = record
    // ���ṹ��
    base: TCefBase;

    // ֪ͨ�ͻ��������ѱ�������ɡ���ʹ��cef_urlrequest_t::GetRequestStatus������
    // �ж������Ƿ�ɹ���
    on_request_complete: procedure(self: PCefUrlRequestClient; request: PCefUrlRequest); stdcall;

    // ��ͻ���֪ͨ�ϴ����ȡ�|current|ΪĿǰΪֹ�ѷ��͵��ֽ�������
    // |total|���ϴ����ݵ��д�С(��������˿��ϴ���Ϊ-1)���������������������
    // UR_FLAG_REPORT_UPLOAD_PROGRESS��־ʱ�ű����á�
    on_upload_progress: procedure(self: PCefUrlRequestClient;
      request: PCefUrlRequest; current, total: Int64); stdcall;

    // ֪ͨ�ͻ��˵����ؽ��ȡ�|current|Ϊ��ǰ�ѽ��յ��ֽ�������
    // total|��Ԥ�ڵ������ش�С(���δ֪����-1)
    on_download_progress: procedure(self: PCefUrlRequestClient;
      request: PCefUrlRequest; current, total: Int64); stdcall;

    // ����ȡ��һ������Ӧ����ʱ��������|data|�Ǿ����ϴε��ü���յ��ֽڴ�С��
    // �������������������UR_FLAG_NO_DOWNLOAD_DATA��־ʱ�ű����á�
    on_download_data: procedure(self: PCefUrlRequestClient;
      request: PCefUrlRequest; const data: Pointer; data_length: NativeUInt); stdcall;

    // ���������Ҫ�����û���֤��ʱ��IO�߳��б����á�
    // |isProxy|ָʾhost�Ƿ���һ�������������|host|����������|port|�Ƕ˿ںš�
    // ����true (1)�������󣬲��ҵ���Ȩ��Ϣ����ʱ����cef_auth_callback_t::cont()��
    // ����false (0)��ȡ�������������������������������Ϊ�����ʼ��ʱ�����á�
    get_auth_credentials: function(self: PCefUrlRequestClient; isProxy: Integer;
      const host: PCefString; port: Integer; const realm, scheme: PCefString;
      callback: PCefAuthCallback): Integer; stdcall;
  end;

  // ����ṹ�����ļ��Ի���������첽�����ص�
  TCefFileDialogCallback = record
    // ���ṹ��
    base: TCefBase;

    // ����|file_paths|���ļ�ѡ����������һ��ֵ��Ҳ������һ��ֵ�б�
    // �������ڶԻ����ģʽ(mode)�����NULLֵ����ڵ���cancel() ��
    cont: procedure(self: PCefFileDialogCallback; selected_accept_filter: Integer;
     file_paths: TCefStringList); stdcall;

    // ȡ���ļ���ѡ��
    cancel: procedure(self: PCefFileDialogCallback); stdcall;
  end;

  // ����ṹ�����ڴ���Ի����¼�����Щ������Ӧ����UI�߳��б����á�
  TCefDialogHandler = record
    // Base structure.
    base: TCefBase;

    // ���������������ʾһ���ļ�ѡ��Ի���|mode|��ʾ�Ի�����ʾ���͡�
    // |title|�������öԻ���ı��⣬��ΪNULLʱ��ʾĬ�ϵı���("��"/"����"ȡ����mode)��
    // |default_file_path|�ǶԻ����е�Ĭ���ļ�����
    // |accept_filters|��һ����Ч��Сд��MIME���ͻ��ļ���չ���б�
    // Ҫ��ʾһ���Զ���Ի����뷵��true (1)���������ڲ����Ժ�ִ��|callback|
    // Ҫ��ʾĬ�϶Ի����뷵��false (0)��
    on_file_dialog: function(self: PCefDialogHandler; browser: PCefBrowser;
      mode: TCefFileDialogMode; const title, default_file_path: PCefString;
      accept_filters: TCefStringList; selected_accept_filter: Integer;
      callback: PCefFileDialogCallback): Integer; stdcall;
  end;

  // ����ṹ�������ڵ�������Ⱦ������ʱ�������¼���
  // ����ṹ�������UI�߳��б����á�
  TCefRenderHandler = record
    // ���ṹ��
    base: TCefBase;

    // ��ȡ��Ļ�����еĸ����ھ��Σ�����ṩ���򷵻�true (1)��
    get_root_screen_rect: function(self: PCefRenderHandler; browser: PCefBrowser;
      rect: PCefRect): Integer; stdcall;

    // ��ȡ�������Ļ����ϵ����ͼ���Ρ�����ṩ���򷵻�true (1)��
    get_view_rect: function(self: PCefRenderHandler; browser: PCefBrowser;
      rect: PCefRect): Integer; stdcall;

    // ��ȡ����ͼ���굽��Ļ����ķ��롣����ṩ���򷵻�true (1)��
    get_screen_point: function(self: PCefRenderHandler; browser: PCefBrowser;
      viewX, viewY: Integer; screenX, screenY: PInteger): Integer; stdcall;

    // ��������ӿ��ǿͻ��˷���һ��CefScreenInfo��������ṩ��screen_info�򷵻�
    // true(1)��
    // ���screen_infoΪNULl�������ʹ��GetViewRect��ȡ��
    // ������������ȻΪNULL����Ч�ĵ������ܲ�����ȷ���ơ�
    get_screen_info: function(self: PCefRenderHandler; browser: PCefBrowser;
        screen_info: PCefScreenInfo): Integer; stdcall;

    // �����������ʾ/����һ���������ʱ�����á���|show|Ϊtrue(1)ʱ��ʾ�������������ء�
    on_popup_show: procedure(self: PCefRenderProcessHandler; browser: PCefBrowser;
      show: Integer); stdcall;

    // ���������Ӧ�ƶ��������������ĳߴ�ʱ�����á�|rect|Ϊ�µ�λ�úͳߴ硣
    on_popup_size: procedure(self: PCefRenderProcessHandler; browser: PCefBrowser;
      const rect: PCefRect); stdcall;

    // ��һ��Ԫ����Ҫ����ʱ�����á�|type|ָʾԪ����һ����ͼ���ǵ��������
    // |buffer|������ͼƬ���������ݡ�|dirtyRects|��һ����Ҫ�ػ�ľ��μ���
    // |buffer|����|width|*|height|*4�ֽڵĴ�С������ʾһ�������Ͻ�Ϊԭ���BGRAͼ��
    on_paint: procedure(self: PCefRenderProcessHandler; browser: PCefBrowser;
      kind: TCefPaintElementType; dirtyRectsCount: NativeUInt;
      const dirtyRects: PCefRectArray; const buffer: Pointer; width, height: Integer); stdcall;

    // ���������걻�ı�ʱ�����������|type|��CT_CUSTOM����|custom_cursor_info|
    // Ӧ������Զ�������Ϣ��
    on_cursor_change: procedure(self: PCefRenderProcessHandler; browser: PCefBrowser;
      cursor: TCefCursorHandle; type_: TCefCursorType;
      const custom_cursor_info: PCefCursorInfo); stdcall;

    // ���û���web��ͼ����ק����ʱ����������ק���ݵ���������Ϣ��������ϵͳ��Ϣѭ
    // ����StartDragging�����е�|drag_data|�ṩ��
    //
    // ����false (0)����ֹ��ק��������Ҫ����false(0)������κ�cef_browser_host_t::DragSource*Ended*
    // ������
    //
    // ����true (1)ʱ������ק������ͬ��/�첽����cef_browser_host_t::DragSourceEndedAt��
    // DragSourceSystemDragEnded��ʹ��ק����������
    start_dragging: function(self: PCefRenderProcessHandler; browser: PCefBrowser;
      drag_data: PCefDragData; allowed_ops: TCefDragOperations; x, y: Integer): Integer; stdcall;

    // ��web��ͼ����ק�����ڼ�����������ʱ�����á�
    // |operation|��������Ĳ���(none, move, copy, link)��
    update_drag_cursor: procedure(self: PCefRenderProcessHandler; browser: PCefBrowser;
      operation: TCefDragOperation); stdcall;

    // ��������ƫ��λ�÷����ı�ʱ�����á�
    on_scroll_offset_changed: procedure(self: PCefRenderProcessHandler;
      browser: PCefBrowser; x, y: Double); stdcall;
  end;

  // ����ṹ�����ڸ��µ���λ����Ϣ�ĸ��¡���Щ��������������̵�UI�߳��б����á�
  TCefGetGeolocationCallback = record
    // ���ṹ��
    base: TCefBase;

    // ��������ӿڸ���'��ѿɴ�'λ����Ϣ, �������ʧ�ܣ����Ǵ�����Ϣ��
    on_location_update: procedure(self: PCefGetGeolocationCallback;
        const position: Pcefgeoposition); stdcall;
  end;

  // ����ṹ�����ڽ��ռ�¼�켣��ɵ�֪ͨ����Щ��������������̵�UI�߳��б����á�
  TCefEndTracingCallback = record
    // ���ṹ��
    base: TCefBase;

    // �����н��̷�����켣���ݺ󱻵��á�|tracing_file|�ǹ켣����д����ļ���
    // �ͻ��˸���ɾ�����|tracing_file|�ļ���
    on_end_tracing_complete: procedure(self: PCefEndTracingCallback; const tracing_file: PCefString); stdcall;
  end;

  TCefDragData = record
    // ���ṹ��
    base: TCefBase;

    // ��ȡ��ǰ�����һ������
    clone: function(self: PCefDragData): PCefDragData; stdcall;

    // ���������ֻ�����򷵻�true (1)
    is_read_only: function(self: PCefDragData): Integer; stdcall;

    // �����ק������һ�������򷵻�true (1)
    is_link: function(self: PCefDragData): Integer; stdcall;

    // �����ק������һ���ı���htmlƬ�Σ��򷵻�true (1)
    is_fragment: function(self: PCefDragData): Integer; stdcall;

    // �����ק������һ���ļ����򷵻�true (1)
    is_file: function(self: PCefDragData): Integer; stdcall;

    // ��ȡ����ק�����ӵ�URL��
    // ����ַ����������cef_string_userfree_free()�����١�
    get_link_url: function(self: PCefDragData): PCefStringUserFree; stdcall;

    // ��ȡ����ק�����ӵı���
    // ����ַ����������cef_string_userfree_free()�����١�
    get_link_title: function(self: PCefDragData): PCefStringUserFree; stdcall;

    // ��ȡ����ק���ӹ�����metadata(�������)��
    // ����ַ����������cef_string_userfree_free()�����١�
    get_link_metadata: function(self: PCefDragData): PCefStringUserFree; stdcall;

    // ��ȡ����ק�Ĵ��ı�Ƭ��
    // ����ַ����������cef_string_userfree_free()�����١�
    get_fragment_text: function(self: PCefDragData): PCefStringUserFree; stdcall;

    // ��ȡ����ק��text/htmlƬ��
    // ����ַ����������cef_string_userfree_free()�����١�
    get_fragment_html: function(self: PCefDragData): PCefStringUserFree; stdcall;

    // ��ȡ����קƬ�εĵĻ�URL������������ڽ�����URL��URLΪNULL�������
    // ����ַ����������cef_string_userfree_free()�����١�
    get_fragment_base_url: function(self: PCefDragData): PCefStringUserFree; stdcall;

    // ��ȡ����ק����������ڵ��ļ�����
    // ����ַ����������cef_string_userfree_free()�����١�
    get_file_name: function(self: PCefDragData): PCefStringUserFree; stdcall;

    // ������ק��web��ͼ���ļ�������д��|writer|��
    // ���ط��͵�|writer|�е��ֽ����������|writer|ΪNULL������������������ļ�
    // ���ݵĴ�С(�ֽ�)���ɵ���get_file_name()��Ϊ�ļ���ȡ�����ļ�����
    get_file_contents: function(self: PCefDragData; writer: PCefStreamWriter): NativeUInt; stdcall;

    // ��ȡ����ק����������ڵ��ļ������б�
    get_file_names: function(self: PCefDragData; names: TCefStringList): Integer; stdcall;

    // ���ñ���ק������URL��
    set_link_url: procedure(self: PCefDragData; const url: PCefString); stdcall;

    // ���ñ���ק�����ӹ����ı��⡣
    set_link_title: procedure(self: PCefDragData; const title: PCefString); stdcall;

    // ���ñ���ק�����ӵ�metadata
    set_link_metadata: procedure(self: PCefDragData; const data: PCefString); stdcall;

    // ���ñ���ק��Ƭ�εĴ��ı����ݡ�
    set_fragment_text: procedure(self: PCefDragData; const text: PCefString); stdcall;

    // ���ñ���ק��Ƭ�ε�text/html���ݡ�
    set_fragment_html: procedure(self: PCefDragData; const html: PCefString); stdcall;

    // ����Ƭ����Դ�Ļ�URL��
    set_fragment_base_url: procedure(self: PCefDragData; const base_url: PCefString); stdcall;

    // �����ļ����ݡ���Ӧ���ڵ���cef_browser_host_t::DragTargetDragEnter֮ǰ��
    // ���������û���ק������������ʱ�������������
    reset_file_contents: procedure(self: PCefDragData); stdcall;

    // ���һ������ק��webview���ļ���
    add_file: procedure(self: PCefDragData; const path, display_name: PCefString); stdcall;
  end;

  // ����ṹ�����ڴ�����ק�¼�����Щ�����û���UI�߳��б����á�
  TCefDragHandler = record
    // ���ṹ��
    base: TCefBase;

    // ��һ���ⲿ��ק�¼��������������ʱ��������|dragData|����ק�¼������ݡ�
    // |mask|������ק���������͡�
    // ����false (0)��ʹ��Ĭ�ϵ���ק�¼�������������true (1)��ȡ����ק�¼���
    on_drag_enter: function(self: PCefDragHandler; browser: PCefBrowser;
      dragData: PCefDragData; mask: TCefDragOperations): Integer; stdcall;
{$ifdef Win32}
    // Called whenever draggable regions for the browser window change. These can
    // be specified using the '-webkit-app-region: drag/no-drag' CSS-property. If
    // draggable regions are never defined in a document this function will also
    // never be called. If the last draggable region is removed from a document
    // this function will be called with an NULL vector.
    on_draggable_regions_changed: procedure(self: PCefDragHandler; browser: PCefBrowser;
      regionsCount: NativeUInt; regions: PCefDraggableRegionArray); stdcall;
{$endif}
  end;

  // ����ṹ�������ṩ���������ĵĴ���

  TCefRequestContextHandler = record
    // ���ṹ��
    base: TCefBase;


    // ��IO�߳��е��û�ȡcookie����������������������NULL��ʹ��ȫ��cookie����������������������NULL,
	// ��Ĭ�ϵ�kookie��������ͨ��cef_request_tContext::get_default_cookie_manager()����ȡ��
    get_cookie_manager: function(self: PCefRequestContextHandler): PCefCookieManager; stdcall;

    // Called on multiple browser process threads before a plugin instance is
    // loaded. |mime_type| is the mime type of the plugin that will be loaded.
    // |plugin_url| is the content URL that the plugin will load and may be NULL.
    // |top_origin_url| is the URL for the top-level frame that contains the
    // plugin when loading a specific plugin instance or NULL when building the
    // initial list of enabled plugins for 'navigator.plugins' JavaScript state.
    // |plugin_info| includes additional information about the plugin that will be
    // loaded. |plugin_policy| is the recommended policy. Modify |plugin_policy|
    // and return true (1) to change the policy. Return false (0) to use the
    // recommended policy. The default plugin policy can be set at runtime using
    // the `--plugin-policy=[allow|detect|block]` command-line flag. Decisions to
    // mark a plugin as disabled by setting |plugin_policy| to
    // PLUGIN_POLICY_DISABLED may be cached when |top_origin_url| is NULL. To
    // purge the plugin list cache and potentially trigger new calls to this
    // function call cef_request_tContext::PurgePluginListCache.
    on_before_plugin_load: function(self: PCefRequestContextHandler;
        const mime_type, plugin_url, top_origin_url: PCefString;
        plugin_info: PCefWebPluginInfo; plugin_policy: PCefPluginPolicy): Integer; stdcall;
  end;

  // ��������������ṩ���������������������
  // ������һ���µ����������ʱ����ͨ��cef_browser_host_t��̬��������Ϊ��ָ��
  // һ�����������ġ�
  // �в�ͬ���������ĵ���������󽫲�������ͬ����Ⱦ���̡�
  // ����ͬ���������ĵ�����������п�������ͬ����Ⱦ����(ȡ���ڽ���ģ��)��
  // ���������ֱ��ͨ��JavaScript��window.open��������Ŀ�����ӽ�ʹ����ͬ����Ⱦ
  // ���̣�������Դ�����ʹ����ͬ����Ⱦ�����ġ���ʹ�õ�����ģʽʱ��ֻ��һ����Ⱦ
  // ����(������)�����Ե�����ģʽ�������������������ͬ�����������ġ�
  // �⽫�ѵ�һ�����������Ĵ��ݸ�cef_browser_host_t��̬���̺�������������������
  // ���Ķ��󽫱����ԡ�
  TCefRequestContext = record
    // ���ṹ��
    base: TCefBase;

    // ������������|that|ָ����ͬ�������ģ��򷵻�true (1)��
    is_same: function(self, other: PCefRequestContext): Integer; stdcall;

    // Returns true (1) if this object is sharing the same storage as |that|
    // object.
    is_sharing_with: function(self, other: PCefRequestContext): Integer; stdcall;

    // ���������һ��ȫ�������ķ���true (1)
    is_global: function(self: PCefRequestContext): Integer; stdcall;

    // ��ȡ��������ĵĴ�����(�������)
    get_handler: function(self: PCefRequestContext): PCefRequestContextHandler; stdcall;

    // Returns the cache path for this object. If NULL an "incognito mode" in-
    // memory cache is being used.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_cache_path: function(self: PCefRequestContext): PCefStringUserFree; stdcall;

    // Returns the default cookie manager for this object. This will be the global
    // cookie manager if this object is the global request context. Otherwise,
    // this will be the default cookie manager used when this request context does
    // not receive a value via cef_request_tContextHandler::get_cookie_manager().
    // If |callback| is non-NULL it will be executed asnychronously on the IO
    // thread after the manager's storage has been initialized.
    get_default_cookie_manager: function(self: PCefRequestContext;
      callback: PCefCompletionCallback): PCefCookieManager; stdcall;

    // Register a scheme handler factory for the specified |scheme_name| and
    // optional |domain_name|. An NULL |domain_name| value for a standard scheme
    // will cause the factory to match all domain names. The |domain_name| value
    // will be ignored for non-standard schemes. If |scheme_name| is a built-in
    // scheme and no handler is returned by |factory| then the built-in scheme
    // handler factory will be called. If |scheme_name| is a custom scheme then
    // you must also implement the cef_app_t::on_register_custom_schemes()
    // function in all processes. This function may be called multiple times to
    // change or remove the factory that matches the specified |scheme_name| and
    // optional |domain_name|. Returns false (0) if an error occurs. This function
    // may be called on any thread in the browser process.
    register_scheme_handler_factory: function(self: PCefRequestContext;
        const scheme_name, domain_name: PCefString;
        factory: PCefSchemeHandlerFactory): Integer; stdcall;

    // Clear all registered scheme handler factories. Returns false (0) on error.
    // This function may be called on any thread in the browser process.
    clear_scheme_handler_factories: function(self: PCefRequestContext): Integer; stdcall;

    // Tells all renderer processes associated with this context to throw away
    // their plugin list cache. If |reload_pages| is true (1) they will also
    // reload all pages with plugins.
    // cef_request_tContextHandler::OnBeforePluginLoad may be called to rebuild
    // the plugin list cache.
    purge_plugin_list_cache: procedure(self: PCefRequestContext; reload_pages: Integer); stdcall;
  end;

  // ����ṹ���ʾ��ӡ����
  TCefPrintSettings = record
    // ���ṹ��
    base: TCefBase;

    // �����������Ч�ģ��򷵻�true (1)��������false (0)ʱ��Ҫ��������������
    is_valid: function(self: PCefPrintSettings): Integer; stdcall;

    // ������������ֻ�����򷵻�true (1)��ĳЩAIP�ᱩ¶һЩֻ������
    is_read_only: function(self: PCefPrintSettings): Integer; stdcall;

    // ����һ���������Ŀ�д����
    copy: function(self: PCefPrintSettings): PCefPrintSettings; stdcall;

    // ����ҳ��ķ���(orientation).
    set_orientation: procedure(self: PCefPrintSettings; landscape: Integer); stdcall;

    // ����Ǻ����ӡ�򷵻�true (1)
    is_landscape: function(self: PCefPrintSettings): Integer; stdcall;

    // ���ô�ӡ���Ŀɴ�ӡ����(�豸��λ)��ĳЩƽ̨�Լ��ṩ�˷�ת(flipped)����
    // ����Щƽ̨������|landscape_needs_flip|Ϊfalse (0)�Ա���˫�ط�ת��
    set_printer_printable_area: procedure(self: PCefPrintSettings;
        const physical_size_device_units: PCefSize;
        const printable_area_device_units: PCefRect;
        landscape_needs_flip: Integer); stdcall;

    // �����豸����
    set_device_name: procedure(self: PCefPrintSettings; const name: PCefString); stdcall;

    // ��ȡ�豸����
    // ����ַ����������cef_string_userfree_free()�����١�
    get_device_name: function(self: PCefPrintSettings): PCefStringUserFree; stdcall;

    // ����DPI (��/Ӣ��)
    set_dpi: procedure(self: PCefPrintSettings; dpi: Integer); stdcall;

    // ��ȡDPI(��/Ӣ��).
    get_dpi: function(self: PCefPrintSettings): Integer; stdcall;

    // ����ҳ�淶Χ
    set_page_ranges: procedure(self: PCefPrintSettings;
        rangesCount: NativeUInt; ranges: PCefPageRange); stdcall;

    // ��ȡ��ǰ���ڵ�ҳ�淶Χ������
    get_page_ranges_count: function(self: PCefPrintSettings): NativeUInt; stdcall;

    // ��ȡҳ�淶Χ
    get_page_ranges: procedure(self: PCefPrintSettings;
        rangesCount: PNativeUInt; ranges: PCefPageRange); stdcall;

    // �����Ƿ��ӡѡ�񲿷�
    set_selection_only:procedure(self: PCefPrintSettings;
        selection_only: Integer); stdcall;

    // �������ӡѡ�����ݲ������򷵻�true (1)
    is_selection_only: function(self: PCefPrintSettings): Integer; stdcall;

    // �����Ƿ�У��(collated)ҳ�档
    set_collate: procedure(self: PCefPrintSettings; collate: Integer); stdcall;

    // ���ҳ�潫У���򷵻�true (1)
    will_collate: function(self: PCefPrintSettings): Integer; stdcall;

    // ������ɫģ��
    set_color_model: procedure(self: PCefPrintSettings; model: TCefColorModel); stdcall;

    // ��ȡ��ɫģ��
    get_color_model: function(self: PCefPrintSettings): TCefColorModel; stdcall;

    // ���ô�ӡ����
    set_copies: procedure(self: PCefPrintSettings; copies: Integer); stdcall;

    // ��ȡ��ӡ����
    get_copies: function(self: PCefPrintSettings): Integer; stdcall;

    // ����˫��ģʽ
    set_duplex_mode: procedure(self: PCefPrintSettings; mode: TCefDuplexMode); stdcall;

    // ��ȡ˫��ģʽ
    get_duplex_mode: function(self: PCefPrintSettings): TCefDuplexMode; stdcall;
  end;

  // ����ṹ�������ӡ�Ի���������첽�����ص�
  TCefPrintDialogCallback = record
    // ���ṹ��
    base: TCefBase;

    // ����ָ����|settings|������ӡ
    cont: procedure(self: PCefPrintDialogCallback; settings: PCefPrintSettings); stdcall;

    // ȡ����ӡ
    cancel: procedure(self: PCefPrintDialogCallback); stdcall;
  end;

  // ����ṹ�����ڴ�ӡ����������첽�����ص�
  TCefPrintJobCallback = record
    // ���ṹ��
    base: TCefBase;

    // ָʾ��ɴ�ӡ����
    cont: procedure(self: PCefPrintJobCallback); stdcall;
  end;


  // ����ṹ�����ڴ���Linux�ϵĴ�ӡ������Щ����������������̵�UI�߳��б����á�
  TCefPrintHandler = record
    // ���ṹ��
    base: TCefBase;

    // Called when printing has started for the specified |browser|. This function
    // will be called before the other OnPrint*() functions and irrespective of
    // how printing was initiated (e.g. cef_browser_host_t::print(), JavaScript
    // window.print() or PDF extension print button).
    on_print_start: procedure(self: PCefPrintHandler; browser: PCefBrowser); stdcall;

    // ��ͻ���״̬ͬ��|settings|�����|get_defaults|Ϊtrue (1)�������|settings|
    // ΪĬ�ϵĴ�ӡ���á���Ҫ����������Ᵽ��|settings|�����á�
    on_print_settings: procedure(self: PCefPrintHandler;
        settings: PCefPrintSettings; get_defaults: Integer); stdcall;

    // ��ʾ��ӡ�Ի��򡣵��Ի���ر�ʱ����|callback|һ�Ρ�
    // ����Ի�����ʧ�򷵻�true (1)���������(0)������ȡ����ӡ��
    on_print_dialog: function(self: PCefPrintHandler; has_selection: Integer;
      callback: PCefPrintDialogCallback): Integer; stdcall;

    // ���ʹ�ӡ���񵽴�ӡ���������ʱ����|callback|һ�Ρ�
    // �������true (1)��������������򷵻�false (0)������ȡ������
    on_print_job: function(self: PCefPrintHandler; const document_name, pdf_file_path: PCefString;
        callback: PCefPrintJobCallback): Integer; stdcall;

    // ���ô�ӡ�Ŀͻ���״̬
    on_print_reset: procedure(self: PCefPrintHandler); stdcall;

    // Return the PDF paper size in device units. Used in combination with
    // cef_browser_host_t::print_to_pdf().
    get_pdf_paper_size: function(self: PCefPrintHandler;
      device_units_per_inch: Integer): TCefSize; stdcall;
  end;

  // ����ṹ���ʾ������ʷ��һ����Ŀ
  TCefNavigationEntry = record
    // ���ṹ��
    base: TCefBase;

    // �����������Ч�ģ��򷵻�true (1)��������false (0)ʱ��Ҫ��������������
    is_valid: function(self: PCefNavigationEntry): Integer; stdcall;

    // ��ȡҳ���ʵ��URL������һЩҳ�棬��������: URL�����Ƶ����ݡ�
    // ʹ��get_display_url()����ȡ��ʾ�Ѻõİ汾��
    // ����ַ����������cef_string_userfree_free()�����١�
    get_url: function(self: PCefNavigationEntry): PCefStringUserFree; stdcall;

    // ��ȡURL��ʾ�Ѻõİ汾
    // ����ַ����������cef_string_userfree_free()�����١�
    get_display_url: function(self: PCefNavigationEntry): PCefStringUserFree; stdcall;

    // ��ȡ�û��κ��ض���֮ǰ��ԭʼURL��
    // ����ַ����������cef_string_userfree_free()�����١�
    get_original_url: function(self: PCefNavigationEntry): PCefStringUserFree; stdcall;

    // ��ȡҳ�����õı��⡣���ֵ����ΪNULL��
    // ����ַ����������cef_string_userfree_free()�����١�
    get_title: function(self: PCefNavigationEntry): PCefStringUserFree; stdcall;

    // ��ȡ�û�����һ��ҳ�浽���ҳ��Ĺ������͡�
    get_transition_type: function(self: PCefNavigationEntry): TCefTransitionType; stdcall;

    // �����������post data�򷵻�true (1)
    has_post_data: function(self: PCefNavigationEntry): Integer; stdcall;

    // ��ȡ���һ����֪�ĳɹ�������ɵ�ʱ�䡣��ҳ�����¼���ʱһ������������ɶ�Ρ�
    // ���������δ�����Ϊ0.
    get_completion_time: function(self: PCefNavigationEntry): TCefTime; stdcall;

    // ��ȡ���һ����֪�ĳɹ�������Ӧ��״̬�롣
    // �����Ӧ��δ���յ��򵼺���δ����򷵻�0��
    get_http_status_code: function(self: PCefNavigationEntry): Integer; stdcall;
  end;

  // Structure representing the issuer or subject field of an X.509 certificate.
  TCefSslCertPrincipal = record
    // Base structure.
    base: TCefBase;

    // Returns a name that can be used to represent the issuer.  It tries in this
    // order: CN, O and OU and returns the first non-NULL one found.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_display_name: function(self: PCefSslCertPrincipal): PCefStringUserfree; stdcall;

    // Returns the common name.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_common_name: function(self: PCefSslCertPrincipal): PCefStringUserfree; stdcall;

    // Returns the locality name.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_locality_name: function(self: PCefSslCertPrincipal): PCefStringUserfree; stdcall;

    // Returns the state or province name.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_state_or_province_name: function(self: PCefSslCertPrincipal): PCefStringUserfree; stdcall;

    // Returns the country name.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_country_name: function(self: PCefSslCertPrincipal): PCefStringUserfree; stdcall;

    // Retrieve the list of street addresses.
    get_street_addresses: procedure(self: PCefSslCertPrincipal; addresses: TCefStringList); stdcall;

    // Retrieve the list of organization names.
    get_organization_names: procedure(self: PCefSslCertPrincipal; names: TCefStringList); stdcall;

    // Retrieve the list of organization unit names.
    get_organization_unit_names: procedure(self: PCefSslCertPrincipal; names: TCefStringList); stdcall;

    // Retrieve the list of domain components.
    get_domain_components: procedure(self: PCefSslCertPrincipal; components: TCefStringList); stdcall;
  end;

  // Structure representing SSL information.
  TCefSslInfo = record
    // Base structure.
    base: TCefBase;

    // Returns the subject of the X.509 certificate. For HTTPS server certificates
    // this represents the web server.  The common name of the subject should
    // match the host name of the web server.
    get_subject: function(self: PCefSslInfo): PCefSslCertPrincipal; stdcall;

    // Returns the issuer of the X.509 certificate.
    get_issuer: function(self: PCefSslInfo): PCefSslCertPrincipal; stdcall;

    // Returns the DER encoded serial number for the X.509 certificate. The value
    // possibly includes a leading 00 byte.
    get_serial_number: function(self: PCefSslInfo): PCefBinaryValue; stdcall;

    // Returns the date before which the X.509 certificate is invalid.
    // CefTime.GetTimeT() will return 0 if no date was specified.
    get_valid_start: function(self: PCefSslInfo): TCefTime; stdcall;

    // Returns the date after which the X.509 certificate is invalid.
    // CefTime.GetTimeT() will return 0 if no date was specified.
    get_valid_expiry: function(self: PCefSslInfo): TCefTime; stdcall;

    // Returns the DER encoded data for the X.509 certificate.
    get_derencoded: function(self: PCefSslInfo): PCefBinaryValue; stdcall;

    // Returns the PEM encoded data for the X.509 certificate.
    get_pemencoded: function(self: PCefSslInfo): PCefBinaryValue; stdcall;
  end;

  // Structure used for retrieving resources from the resource bundle (*.pak)
  // files loaded by CEF during startup or via the cef_resource_bundle_tHandler
  // returned from cef_app_t::GetResourceBundleHandler. See CefSettings for
  // additional options related to resource bundle loading. The functions of this
  // structure may be called on any thread unless otherwise indicated.
  TCefResourceBundle = record
    // Base structure.
    base: TCefBase;

    // Returns the localized string for the specified |string_id| or an NULL
    // string if the value is not found. Include cef_pack_strings.h for a listing
    // of valid string ID values.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_localized_string: function(self: PCefResourceBundle; string_id: Integer): PCefStringUserFree; stdcall;

    // Retrieves the contents of the specified scale independent |resource_id|. If
    // the value is found then |data| and |data_size| will be populated and this
    // function will return true (1). If the value is not found then this function
    // will return false (0). The returned |data| pointer will remain resident in
    // memory and should not be freed. Include cef_pack_resources.h for a listing
    // of valid resource ID values.
    get_data_resource: function(self: PCefResourceBundle; resource_id: Integer;
      out data: Pointer; out data_size: NativeUInt): Integer; stdcall;

    // Retrieves the contents of the specified |resource_id| nearest the scale
    // factor |scale_factor|. Use a |scale_factor| value of SCALE_FACTOR_NONE for
    // scale independent resources or call GetDataResource instead. If the value
    // is found then |data| and |data_size| will be populated and this function
    // will return true (1). If the value is not found then this function will
    // return false (0). The returned |data| pointer will remain resident in
    // memory and should not be freed. Include cef_pack_resources.h for a listing
    // of valid resource ID values.
     get_data_resource_for_scale: function(self: PCefResourceBundle; resource_id: Integer;
       scale_factor: TCefScaleFactor; out data: Pointer; out data_size: NativeUInt): Integer; stdcall;
  end;

//******************************************************************************
//
//  I N T E R F A C E S
//
//******************************************************************************

  ICefBrowser = interface;
  ICefFrame = interface;
  ICefRequest = interface;
  ICefv8Value = interface;
  ICefDomVisitor = interface;
  ICefDomDocument = interface;
  ICefDomNode = interface;
  ICefv8Context = interface;
  ICefListValue = interface;
  ICefBinaryValue = interface;
  ICefDictionaryValue = interface;
  ICefClient = interface;
  ICefUrlrequestClient = interface;
  ICefBrowserHost = interface;
  ICefTask = interface;
  ICefTaskRunner = interface;
  ICefFileDialogCallback = interface;
  ICefRequestContext = interface;
  ICefDragData = interface;
  ICefNavigationEntry = interface;
  ICefSslInfo = interface;

  ICefBase = interface
    ['{1F9A7B44-DCDC-4477-9180-3ADD44BDEB7B}']
    function Wrap: Pointer;
  end;

  ICefRunFileDialogCallback = interface(ICefBase)
  ['{59FCECC6-E897-45BA-873B-F09586C4BE47}']
    procedure OnFileDialogDismissed(selectedAcceptFilter: Integer; filePaths: TStrings);
  end;

  TCefRunFileDialogCallbackProc = {$IFDEF DELPHI12_UP}reference to{$ENDIF}
    procedure(selectedAcceptFilter: Integer; filePaths: TStrings);

  ICefNavigationEntryVisitor = interface(ICefBase)
  ['{CC4D6BC9-0168-4C2C-98BA-45E9AA9CD619}']
    function Visit(const entry: ICefNavigationEntry;
      current: Boolean; index, total: Integer): Boolean;
  end;

  TCefNavigationEntryVisitorProc = {$IFDEF DELPHI12_UP}reference to{$ENDIF}
    function(const entry: ICefNavigationEntry; current: Boolean; index, total: Integer): Boolean;

  TOnPdfPrintFinishedProc = {$IFDEF DELPHI12_UP}reference to{$ENDIF} procedure(const path: ustring; ok: Boolean);

  ICefPdfPrintCallback = interface(ICefBase)
  ['{F1CC58E9-2C30-4932-91AE-467C8D8EFB8E}']
    procedure OnPdfPrintFinished(const path: ustring; ok: Boolean);
  end;

  ICefBrowserHost = interface(ICefBase)
    ['{53AE02FF-EF5D-48C3-A43E-069DA9535424}']
    function GetBrowser: ICefBrowser;
    procedure CloseBrowser(forceClose: Boolean);
    procedure SetFocus(focus: Boolean);
    procedure SetWindowVisibility(visible: Boolean);
    function GetWindowHandle: TCefWindowHandle;
    function GetOpenerWindowHandle: TCefWindowHandle;
    function GetRequestContext: ICefRequestContext;
    function GetZoomLevel: Double;
    procedure SetZoomLevel(zoomLevel: Double);
    procedure RunFileDialog(mode: TCefFileDialogMode; const title, defaultFilePath: ustring;
      acceptFilters: TStrings; selectedAcceptFilter: Integer; const callback: ICefRunFileDialogCallback);
    procedure RunFileDialogProc(mode: TCefFileDialogMode; const title, defaultFilePath: ustring;
      acceptFilters: TStrings; selectedAcceptFilter: Integer; const callback: TCefRunFileDialogCallbackProc);
    procedure StartDownload(const url: ustring);
    procedure Print;
    procedure PrintToPdf(const path: ustring; settings: PCefPdfPrintSettings; const callback: ICefPdfPrintCallback);
    procedure PrintToPdfProc(const path: ustring; settings: PCefPdfPrintSettings; const callback: TOnPdfPrintFinishedProc);
    procedure Find(identifier: Integer; const searchText: ustring; forward, matchCase, findNext: Boolean);
    procedure StopFinding(clearSelection: Boolean);
    procedure ShowDevTools(const windowInfo: PCefWindowInfo; const client: ICefClient;
      const settings: PCefBrowserSettings; inspectElementAt: PCefPoint);
    procedure CloseDevTools;
    procedure GetNavigationEntries(const visitor: ICefNavigationEntryVisitor; currentOnly: Boolean);
    procedure GetNavigationEntriesProc(const proc: TCefNavigationEntryVisitorProc; currentOnly: Boolean);
    procedure SetMouseCursorChangeDisabled(disabled: Boolean);
    function IsMouseCursorChangeDisabled: Boolean;
    procedure ReplaceMisspelling(const word: ustring);
    procedure AddWordToDictionary(const word: ustring);
    function IsWindowRenderingDisabled: Boolean;
    procedure WasResized;
    procedure WasHidden(hidden: Boolean);
    procedure NotifyScreenInfoChanged;
    procedure Invalidate(kind: TCefPaintElementType);
    procedure SendKeyEvent(const event: PCefKeyEvent);
    procedure SendMouseClickEvent(const event: PCefMouseEvent;
      kind: TCefMouseButtonType; mouseUp: Boolean; clickCount: Integer);
    procedure SendMouseMoveEvent(const event: PCefMouseEvent; mouseLeave: Boolean);
    procedure SendMouseWheelEvent(const event: PCefMouseEvent; deltaX, deltaY: Integer);
    procedure SendFocusEvent(setFocus: Boolean);
    procedure SendCaptureLostEvent;
    procedure NotifyMoveOrResizeStarted;
    function GetWindowlessFrameRate(): Integer;
    procedure SetWindowlessFrameRate(frameRate: Integer);
    function GetNsTextInputContext: TCefTextInputContext;
    procedure HandleKeyEventBeforeTextInputClient(keyEvent: TCefEventHandle);
    procedure HandleKeyEventAfterTextInputClient(keyEvent: TCefEventHandle);
    procedure DragTargetDragEnter(const dragData: ICefDragData;
      const event: PCefMouseEvent; allowedOps: TCefDragOperations);
    procedure DragTargetDragOver(const event: PCefMouseEvent; allowedOps: TCefDragOperations);
    procedure DragTargetDragLeave;
    procedure DragTargetDrop(event: PCefMouseEvent);
    procedure DragSourceEndedAt(x, y: Integer; op: TCefDragOperation);
    procedure DragSourceSystemDragEnded;

    property Browser: ICefBrowser read GetBrowser;
    property WindowHandle: TCefWindowHandle read GetWindowHandle;
    property OpenerWindowHandle: TCefWindowHandle read GetOpenerWindowHandle;
    property ZoomLevel: Double read GetZoomLevel write SetZoomLevel;
    property RequestContext: ICefRequestContext read GetRequestContext;
  end;

  ICefProcessMessage = interface(ICefBase)
    ['{E0B1001A-8777-425A-869B-29D40B8B93B1}']
    function IsValid: Boolean;
    function IsReadOnly: Boolean;
    function Copy: ICefProcessMessage;
    function GetName: ustring;
    function GetArgumentList: ICefListValue;
    property Name: ustring read GetName;
    property ArgumentList: ICefListValue read GetArgumentList;
  end;

  ICefBrowser = interface(ICefBase)
  ['{BA003C2E-CF15-458F-9D4A-FE3CEFCF3EEF}']
    function GetHost: ICefBrowserHost;
    function CanGoBack: Boolean;
    procedure GoBack;
    function CanGoForward: Boolean;
    procedure GoForward;
    function IsLoading: Boolean;
    procedure Reload;
    procedure ReloadIgnoreCache;
    procedure StopLoad;
    function GetIdentifier: Integer;
    function IsSame(const that: ICefBrowser): Boolean;
    function IsPopup: Boolean;
    function HasDocument: Boolean;
    function GetMainFrame: ICefFrame;
    function GetFocusedFrame: ICefFrame;
    function GetFrameByident(identifier: Int64): ICefFrame;
    function GetFrame(const name: ustring): ICefFrame;
    function GetFrameCount: NativeUInt;
    procedure GetFrameIdentifiers(count: PNativeUInt; identifiers: PInt64);
    procedure GetFrameNames(names: TStrings);
    function SendProcessMessage(targetProcess: TCefProcessId;
      message: ICefProcessMessage): Boolean;
    property MainFrame: ICefFrame read GetMainFrame;
    property FocusedFrame: ICefFrame read GetFocusedFrame;
    property FrameCount: NativeUInt read GetFrameCount;
    property Host: ICefBrowserHost read GetHost;
    property Identifier: Integer read GetIdentifier;
  end;

  ICefPostDataElement = interface(ICefBase)
    ['{3353D1B8-0300-4ADC-8D74-4FF31C77D13C}']
    function IsReadOnly: Boolean;
    procedure SetToEmpty;
    procedure SetToFile(const fileName: ustring);
    procedure SetToBytes(size: NativeUInt; bytes: Pointer);
    function GetType: TCefPostDataElementType;
    function GetFile: ustring;
    function GetBytesCount: NativeUInt;
    function GetBytes(size: NativeUInt; bytes: Pointer): NativeUInt;
  end;

  ICefPostData = interface(ICefBase)
    ['{1E677630-9339-4732-BB99-D6FE4DE4AEC0}']
    function IsReadOnly: Boolean;
    function GetCount: NativeUInt;
    function GetElements(Count: NativeUInt): IInterfaceList; // ICefPostDataElement
    function RemoveElement(const element: ICefPostDataElement): Integer;
    function AddElement(const element: ICefPostDataElement): Integer;
    procedure RemoveElements;
  end;

  ICefStringMap = interface
  ['{A33EBC01-B23A-4918-86A4-E24A243B342F}']
    function GetHandle: TCefStringMap;
    function GetSize: Integer;
    function Find(const Key: ustring): ustring;
    function GetKey(Index: Integer): ustring;
    function GetValue(Index: Integer): ustring;
    procedure Append(const Key, Value: ustring);
    procedure Clear;

    property Handle: TCefStringMap read GetHandle;
    property Size: Integer read GetSize;
    property Key[index: Integer]: ustring read GetKey;
    property Value[index: Integer]: ustring read GetValue;
  end;

  ICefStringMultimap = interface
    ['{583ED0C2-A9D6-4034-A7C9-20EC7E47F0C7}']
    function GetHandle: TCefStringMultimap;
    function GetSize: Integer;
    function FindCount(const Key: ustring): Integer;
    function GetEnumerate(const Key: ustring; ValueIndex: Integer): ustring;
    function GetKey(Index: Integer): ustring;
    function GetValue(Index: Integer): ustring;
    procedure Append(const Key, Value: ustring);
    procedure Clear;

    property Handle: TCefStringMap read GetHandle;
    property Size: Integer read GetSize;
    property Key[index: Integer]: ustring read GetKey;
    property Value[index: Integer]: ustring read GetValue;
    property Enumerate[const Key: ustring; ValueIndex: Integer]: ustring read GetEnumerate;
  end;

  ICefRequest = interface(ICefBase)
    ['{FB4718D3-7D13-4979-9F4C-D7F6C0EC592A}']
    function IsReadOnly: Boolean;
    function GetUrl: ustring;
    function GetMethod: ustring;
    function GetPostData: ICefPostData;
    procedure GetHeaderMap(const HeaderMap: ICefStringMultimap);
    procedure SetUrl(const value: ustring);
    procedure SetMethod(const value: ustring);
    procedure SetPostData(const value: ICefPostData);
    procedure SetHeaderMap(const HeaderMap: ICefStringMultimap);
    function GetFlags: TCefUrlRequestFlags;
    procedure SetFlags(flags: TCefUrlRequestFlags);
    function GetFirstPartyForCookies: ustring;
    procedure SetFirstPartyForCookies(const url: ustring);
    procedure Assign(const url, method: ustring;
      const postData: ICefPostData; const headerMap: ICefStringMultimap);
    function GetResourceType: TCefResourceType;
    function GetTransitionType: TCefTransitionType;
    function GetIdentifier: UInt64;

    property Url: ustring read GetUrl write SetUrl;
    property Method: ustring read GetMethod write SetMethod;
    property PostData: ICefPostData read GetPostData write SetPostData;
    property Flags: TCefUrlRequestFlags read GetFlags write SetFlags;
    property FirstPartyForCookies: ustring read GetFirstPartyForCookies write SetFirstPartyForCookies;
    property ResourceType: TCefResourceType read GetResourceType;
    property TransitionType: TCefTransitionType read GetTransitionType;
    property Identifier: UInt64 read GetIdentifier;
  end;

  TCefDomVisitorProc = {$IFDEF DELPHI12_UP}reference to{$ENDIF} procedure(const document: ICefDomDocument);

  TCefStringVisitorProc = {$IFDEF DELPHI12_UP}reference to{$ENDIF} procedure(const str: ustring);

  ICefStringVisitor = interface(ICefBase)
    ['{63ED4D6C-2FC8-4537-964B-B84C008F6158}']
    procedure Visit(const str: ustring);
  end;

  ICefFrame = interface(ICefBase)
    ['{8FD3D3A6-EA3A-4A72-8501-0276BD5C3D1D}']
    function IsValid: Boolean;
    procedure Undo;
    procedure Redo;
    procedure Cut;
    procedure Copy;
    procedure Paste;
    procedure Del;
    procedure SelectAll;
    procedure ViewSource;
    procedure GetSource(const visitor: ICefStringVisitor);
    procedure GetSourceProc(const proc: TCefStringVisitorProc);
    procedure GetText(const visitor: ICefStringVisitor);
    procedure GetTextProc(const proc: TCefStringVisitorProc);
    procedure LoadRequest(const request: ICefRequest);
    procedure LoadUrl(const url: ustring);
    procedure LoadString(const str, url: ustring);
    procedure ExecuteJavaScript(const code, scriptUrl: ustring; startLine: Integer);
    function IsMain: Boolean;
    function IsFocused: Boolean;
    function GetName: ustring;
    function GetIdentifier: Int64;
    function GetParent: ICefFrame;
    function GetUrl: ustring;
    function GetBrowser: ICefBrowser;
    function GetV8Context: ICefv8Context;
    procedure VisitDom(const visitor: ICefDomVisitor);
    procedure VisitDomProc(const proc: TCefDomVisitorProc);
    property Name: ustring read GetName;
    property Url: ustring read GetUrl;
    property Browser: ICefBrowser read GetBrowser;
    property Parent: ICefFrame read GetParent;
  end;


  ICefCustomStreamReader = interface(ICefBase)
    ['{BBCFF23A-6FE7-4C28-B13E-6D2ACA5C83B7}']
    function Read(ptr: Pointer; size, n: NativeUInt): NativeUInt;
    function Seek(offset: Int64; whence: Integer): Integer;
    function Tell: Int64;
    function Eof: Boolean;
    function MayBlock: Boolean;
  end;

  ICefStreamReader = interface(ICefBase)
    ['{DD5361CB-E558-49C5-A4BD-D1CE84ADB277}']
    function Read(ptr: Pointer; size, n: NativeUInt): NativeUInt;
    function Seek(offset: Int64; whence: Integer): Integer;
    function Tell: Int64;
    function Eof: Boolean;
    function MayBlock: Boolean;
  end;

  ICefWriteHandler = interface(ICefBase)
    ['{F2431888-4EAB-421E-9EC3-320BE695AF30}']
    function Write(const ptr: Pointer; size, n: NativeUInt): NativeUInt;
    function Seek(offset: Int64; whence: Integer): Integer;
    function Tell: Int64;
    function Flush: Integer;
    function MayBlock: Boolean;
  end;

  ICefStreamWriter = interface(ICefBase)
    ['{4AA6C477-7D8A-4D5A-A704-67F900A827E7}']
    function Write(const ptr: Pointer; size, n: NativeUInt): NativeUInt;
    function Seek(offset: Int64; whence: Integer): Integer;
    function Tell: Int64;
    function Flush: Integer;
    function MayBlock: Boolean;
  end;

  ICefResponse = interface(ICefBase)
  ['{E9C896E4-59A8-4B96-AB5E-6EA3A498B7F1}']
    function IsReadOnly: Boolean;
    function GetStatus: Integer;
    procedure SetStatus(status: Integer);
    function GetStatusText: ustring;
    procedure SetStatusText(const StatusText: ustring);
    function GetMimeType: ustring;
    procedure SetMimeType(const mimetype: ustring);
    function GetHeader(const name: ustring): ustring;
    procedure GetHeaderMap(const headerMap: ICefStringMultimap);
    procedure SetHeaderMap(const headerMap: ICefStringMultimap);
    property Status: Integer read GetStatus write SetStatus;
    property StatusText: ustring read GetStatusText write SetStatusText;
    property MimeType: ustring read GetMimeType write SetMimeType;
  end;

  ICefDownloadItem = interface(ICefBase)
  ['{B34BD320-A82E-4185-8E84-B98E5EEC803F}']
    function IsValid: Boolean;
    function IsInProgress: Boolean;
    function IsComplete: Boolean;
    function IsCanceled: Boolean;
    function GetCurrentSpeed: Int64;
    function GetPercentComplete: Integer;
    function GetTotalBytes: Int64;
    function GetReceivedBytes: Int64;
    function GetStartTime: TDateTime;
    function GetEndTime: TDateTime;
    function GetFullPath: ustring;
    function GetId: Cardinal;
    function GetUrl: ustring;
    function GetOriginalUrl: ustring;
    function GetSuggestedFileName: ustring;
    function GetContentDisposition: ustring;
    function GetMimeType: ustring;

    property CurrentSpeed: Int64 read GetCurrentSpeed;
    property PercentComplete: Integer read GetPercentComplete;
    property TotalBytes: Int64 read GetTotalBytes;
    property ReceivedBytes: Int64 read GetReceivedBytes;
    property StartTime: TDateTime read GetStartTime;
    property EndTime: TDateTime read GetEndTime;
    property FullPath: ustring read GetFullPath;
    property Id: Cardinal read GetId;
    property Url: ustring read GetUrl;
    property OriginalUrl: ustring read GetOriginalUrl;
    property SuggestedFileName: ustring read GetSuggestedFileName;
    property ContentDisposition: ustring read GetContentDisposition;
    property MimeType: ustring read GetMimeType;
  end;

  ICefBeforeDownloadCallback = interface(ICefBase)
  ['{5A81AF75-CBA2-444D-AD8E-522160F36433}']
    procedure Cont(const downloadPath: ustring; showDialog: Boolean);
  end;

  ICefDownloadItemCallback = interface(ICefBase)
  ['{498F103F-BE64-4D5F-86B7-B37EC69E1735}']
    procedure Cancel;
    procedure Pause;
    procedure Resume;
  end;

  ICefDownloadHandler = interface(ICefBase)
  ['{3137F90A-5DC5-43C1-858D-A269F28EF4F1}']
    procedure OnBeforeDownload(const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
      const suggestedName: ustring; const callback: ICefBeforeDownloadCallback);
    procedure OnDownloadUpdated(const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
      const callback: ICefDownloadItemCallback);
  end;

  ICefV8Exception = interface(ICefBase)
    ['{7E422CF0-05AC-4A60-A029-F45105DCE6A4}']
    function GetMessage: ustring;
    function GetSourceLine: ustring;
    function GetScriptResourceName: ustring;
    function GetLineNumber: Integer;
    function GetStartPosition: Integer;
    function GetEndPosition: Integer;
    function GetStartColumn: Integer;
    function GetEndColumn: Integer;

    property Message: ustring read GetMessage;
    property SourceLine: ustring read GetSourceLine;
    property ScriptResourceName: ustring read GetScriptResourceName;
    property LineNumber: Integer read GetLineNumber;
    property StartPosition: Integer read GetStartPosition;
    property EndPosition: Integer read GetEndPosition;
    property StartColumn: Integer read GetStartColumn;
    property EndColumn: Integer read GetEndColumn;
  end;

  ICefv8Context = interface(ICefBase)
    ['{2295A11A-8773-41F2-AD42-308C215062D9}']
    function GetTaskRunner: ICefTaskRunner;
    function IsValid: Boolean;
    function GetBrowser: ICefBrowser;
    function GetFrame: ICefFrame;
    function GetGlobal: ICefv8Value;
    function Enter: Boolean;
    function Exit: Boolean;
    function IsSame(const that: ICefv8Context): Boolean;
    function Eval(const code: ustring; var retval: ICefv8Value; var exception: ICefV8Exception): Boolean;
    property Browser: ICefBrowser read GetBrowser;
    property Frame: ICefFrame read GetFrame;
    property Global: ICefv8Value read GetGlobal;
  end;

  TCefv8ValueArray = array of ICefv8Value;

  ICefv8Handler = interface(ICefBase)
    ['{F94CDC60-FDCB-422D-96D5-D2A775BD5D73}']
    function Execute(const name: ustring; const obj: ICefv8Value;
      const arguments: TCefv8ValueArray; var retval: ICefv8Value;
      var exception: ustring): Boolean;
  end;

  ICefV8Accessor = interface(ICefBase)
    ['{DCA6D4A2-726A-4E24-AA64-5E8C731D868A}']
    function Get(const name: ustring; const obj: ICefv8Value;
      out value: ICefv8Value; const exception: ustring): Boolean;
    function Put(const name: ustring; const obj: ICefv8Value;
      const value: ICefv8Value; const exception: ustring): Boolean;
  end;

  ICefTask = interface(ICefBase)
    ['{0D965470-4A86-47CE-BD39-A8770021AD7E}']
    procedure Execute;
  end;

  ICefTaskRunner = interface(ICefBase)
  ['{6A500FA3-77B7-4418-8EA8-6337EED1337B}']
    function IsSame(const that: ICefTaskRunner): Boolean;
    function BelongsToCurrentThread: Boolean;
    function BelongsToThread(threadId: TCefThreadId): Boolean;
    function PostTask(const task: ICefTask): Boolean; stdcall;
    function PostDelayedTask(const task: ICefTask; delayMs: Int64): Boolean;
  end;

  ICefv8Value = interface(ICefBase)
  ['{52319B8D-75A8-422C-BD4B-16FA08CC7F42}']
    function IsValid: Boolean;
    function IsUndefined: Boolean;
    function IsNull: Boolean;
    function IsBool: Boolean;
    function IsInt: Boolean;
    function IsUInt: Boolean;
    function IsDouble: Boolean;
    function IsDate: Boolean;
    function IsString: Boolean;
    function IsObject: Boolean;
    function IsArray: Boolean;
    function IsFunction: Boolean;
    function IsSame(const that: ICefv8Value): Boolean;
    function GetBoolValue: Boolean;
    function GetIntValue: Integer;
    function GetUIntValue: Cardinal;
    function GetDoubleValue: Double;
    function GetDateValue: TDateTime;
    function GetStringValue: ustring;
    function IsUserCreated: Boolean;
    function HasException: Boolean;
    function GetException: ICefV8Exception;
    function ClearException: Boolean;
    function WillRethrowExceptions: Boolean;
    function SetRethrowExceptions(rethrow: Boolean): Boolean;
    function HasValueByKey(const key: ustring): Boolean;
    function HasValueByIndex(index: Integer): Boolean;
    function DeleteValueByKey(const key: ustring): Boolean;
    function DeleteValueByIndex(index: Integer): Boolean;
    function GetValueByKey(const key: ustring): ICefv8Value;
    function GetValueByIndex(index: Integer): ICefv8Value;
    function SetValueByKey(const key: ustring; const value: ICefv8Value;
      attribute: TCefV8PropertyAttributes): Boolean;
    function SetValueByIndex(index: Integer; const value: ICefv8Value): Boolean;
    function SetValueByAccessor(const key: ustring; settings: TCefV8AccessControls;
      attribute: TCefV8PropertyAttributes): Boolean;
    function GetKeys(const keys: TStrings): Integer;
    function SetUserData(const data: ICefv8Value): Boolean;
    function GetUserData: ICefv8Value;
    function GetExternallyAllocatedMemory: Integer;
    function AdjustExternallyAllocatedMemory(changeInBytes: Integer): Integer;
    function GetArrayLength: Integer;
    function GetFunctionName: ustring;
    function GetFunctionHandler: ICefv8Handler;
    function ExecuteFunction(const obj: ICefv8Value;
      const arguments: TCefv8ValueArray): ICefv8Value;
    function ExecuteFunctionWithContext(const context: ICefv8Context;
      const obj: ICefv8Value; const arguments: TCefv8ValueArray): ICefv8Value;
  end;

  ICefV8StackFrame = interface(ICefBase)
  ['{BA1FFBF4-E9F2-4842-A827-DC220F324286}']
    function IsValid: Boolean;
    function GetScriptName: ustring;
    function GetScriptNameOrSourceUrl: ustring;
    function GetFunctionName: ustring;
    function GetLineNumber: Integer;
    function GetColumn: Integer;
    function IsEval: Boolean;
    function IsConstructor: Boolean;

    property ScriptName: ustring read GetScriptName;
    property ScriptNameOrSourceUrl: ustring read GetScriptNameOrSourceUrl;
    property FunctionName: ustring read GetFunctionName;
    property LineNumber: Integer read GetLineNumber;
    property Column: Integer read GetColumn;
  end;

  ICefV8StackTrace = interface(ICefBase)
  ['{32111C84-B7F7-4E3A-92B9-7CA1D0ADB613}']
    function IsValid: Boolean;
    function GetFrameCount: Integer;
    function GetFrame(index: Integer): ICefV8StackFrame;
    property FrameCount: Integer read GetFrameCount;
    property Frame[index: Integer]: ICefV8StackFrame read GetFrame;
  end;

  ICefXmlReader = interface(ICefBase)
  ['{0DE686C3-A8D7-45D2-82FD-92F7F4E62A90}']
    function MoveToNextNode: Boolean;
    function Close: Boolean;
    function HasError: Boolean;
    function GetError: ustring;
    function GetType: TCefXmlNodeType;
    function GetDepth: Integer;
    function GetLocalName: ustring;
    function GetPrefix: ustring;
    function GetQualifiedName: ustring;
    function GetNamespaceUri: ustring;
    function GetBaseUri: ustring;
    function GetXmlLang: ustring;
    function IsEmptyElement: Boolean;
    function HasValue: Boolean;
    function GetValue: ustring;
    function HasAttributes: Boolean;
    function GetAttributeCount: NativeUInt;
    function GetAttributeByIndex(index: Integer): ustring;
    function GetAttributeByQName(const qualifiedName: ustring): ustring;
    function GetAttributeByLName(const localName, namespaceURI: ustring): ustring;
    function GetInnerXml: ustring;
    function GetOuterXml: ustring;
    function GetLineNumber: Integer;
    function MoveToAttributeByIndex(index: Integer): Boolean;
    function MoveToAttributeByQName(const qualifiedName: ustring): Boolean;
    function MoveToAttributeByLName(const localName, namespaceURI: ustring): Boolean;
    function MoveToFirstAttribute: Boolean;
    function MoveToNextAttribute: Boolean;
    function MoveToCarryingElement: Boolean;
  end;

  ICefZipReader = interface(ICefBase)
  ['{3B6C591F-9877-42B3-8892-AA7B27DA34A8}']
    function MoveToFirstFile: Boolean;
    function MoveToNextFile: Boolean;
    function MoveToFile(const fileName: ustring; caseSensitive: Boolean): Boolean;
    function Close: Boolean;
    function GetFileName: ustring;
    function GetFileSize: Int64;
    function GetFileLastModified: TCefTime;
    function OpenFile(const password: ustring): Boolean;
    function CloseFile: Boolean;
    function ReadFile(buffer: Pointer; bufferSize: NativeUInt): Integer;
    function Tell: Int64;
    function Eof: Boolean;
  end;

  ICefDomNode = interface(ICefBase)
  ['{96C03C9E-9C98-491A-8DAD-1947332232D6}']
    function GetType: TCefDomNodeType;
    function IsText: Boolean;
    function IsElement: Boolean;
    function IsEditable: Boolean;
    function IsFormControlElement: Boolean;
    function GetFormControlElementType: ustring;
    function IsSame(const that: ICefDomNode): Boolean;
    function GetName: ustring;
    function GetValue: ustring;
    function SetValue(const value: ustring): Boolean;
    function GetAsMarkup: ustring;
    function GetDocument: ICefDomDocument;
    function GetParent: ICefDomNode;
    function GetPreviousSibling: ICefDomNode;
    function GetNextSibling: ICefDomNode;
    function HasChildren: Boolean;
    function GetFirstChild: ICefDomNode;
    function GetLastChild: ICefDomNode;
    function GetElementTagName: ustring;
    function HasElementAttributes: Boolean;
    function HasElementAttribute(const attrName: ustring): Boolean;
    function GetElementAttribute(const attrName: ustring): ustring;
    procedure GetElementAttributes(const attrMap: ICefStringMap);
    function SetElementAttribute(const attrName, value: ustring): Boolean;
    function GetElementInnerText: ustring;

    property NodeType: TCefDomNodeType read GetType;
    property Name: ustring read GetName;
    property AsMarkup: ustring read GetAsMarkup;
    property Document: ICefDomDocument read GetDocument;
    property Parent: ICefDomNode read GetParent;
    property PreviousSibling: ICefDomNode read GetPreviousSibling;
    property NextSibling: ICefDomNode read GetNextSibling;
    property FirstChild: ICefDomNode read GetFirstChild;
    property LastChild: ICefDomNode read GetLastChild;
    property ElementTagName: ustring read GetElementTagName;
    property ElementInnerText: ustring read GetElementInnerText;
  end;

  ICefDomDocument = interface(ICefBase)
  ['{08E74052-45AF-4F69-A578-98A5C3959426}']
    function GetType: TCefDomDocumentType;
    function GetDocument: ICefDomNode;
    function GetBody: ICefDomNode;
    function GetHead: ICefDomNode;
    function GetTitle: ustring;
    function GetElementById(const id: ustring): ICefDomNode;
    function GetFocusedNode: ICefDomNode;
    function HasSelection: Boolean;
    function GetSelectionStartOffset: Integer;
    function GetSelectionEndOffset: Integer;
    function GetSelectionAsMarkup: ustring;
    function GetSelectionAsText: ustring;
    function GetBaseUrl: ustring;
    function GetCompleteUrl(const partialURL: ustring): ustring;
    property DocType: TCefDomDocumentType read GetType;
    property Document: ICefDomNode read GetDocument;
    property Body: ICefDomNode read GetBody;
    property Head: ICefDomNode read GetHead;
    property Title: ustring read GetTitle;
    property FocusedNode: ICefDomNode read GetFocusedNode;
    property SelectionStartOffset: Integer read GetSelectionStartOffset;
    property SelectionEndOffset: Integer read GetSelectionEndOffset;
    property SelectionAsMarkup: ustring read GetSelectionAsMarkup;
    property SelectionAsText: ustring read GetSelectionAsText;
    property BaseUrl: ustring read GetBaseUrl;
  end;

  ICefDomVisitor = interface(ICefBase)
  ['{30398428-3196-4531-B968-2DDBED36F6B0}']
    procedure visit(const document: ICefDomDocument);
  end;

  ICefCookieVisitor = interface(ICefBase)
  ['{8378CF1B-84AB-4FDB-9B86-34DDABCCC402}']
    function visit(const name, value, domain, path: ustring; secure, httponly,
      hasExpires: Boolean; const creation, lastAccess, expires: TDateTime;
      count, total: Integer; out deleteCookie: Boolean): Boolean;
  end;

  ICefResourceBundleHandler = interface(ICefBase)
    ['{09C264FD-7E03-41E3-87B3-4234E82B5EA2}']
    function GetLocalizedString(stringId: Integer; out stringVal: ustring): Boolean;
    function GetDataResource(resourceId: Integer; out data: Pointer; out dataSize: NativeUInt): Boolean;
  end;

  ICefCommandLine = interface(ICefBase)
  ['{6B43D21B-0F2C-4B94-B4E6-4AF0D7669D8E}']
    function IsValid: Boolean;
    function IsReadOnly: Boolean;
    function Copy: ICefCommandLine;
    procedure InitFromArgv(argc: Integer; const argv: PPAnsiChar);
    procedure InitFromString(const commandLine: ustring);
    procedure Reset;
    function GetCommandLineString: ustring;
    procedure GetArgv(args: TStrings);
    function GetProgram: ustring;
    procedure SetProgram(const prog: ustring);
    function HasSwitches: Boolean;
    function HasSwitch(const name: ustring): Boolean;
    function GetSwitchValue(const name: ustring): ustring;
    procedure GetSwitches(switches: TStrings);
    procedure AppendSwitch(const name: ustring);
    procedure AppendSwitchWithValue(const name, value: ustring);
    function HasArguments: Boolean;
    procedure GetArguments(arguments: TStrings);
    procedure AppendArgument(const argument: ustring);
    procedure PrependWrapper(const wrapper: ustring);
    property CommandLineString: ustring read GetCommandLineString;
  end;

  ICefBrowserProcessHandler = interface(ICefBase)
  ['{27291B7A-C0AE-4EE0-9115-15C810E22F6C}']
    procedure OnContextInitialized;
    procedure OnBeforeChildProcessLaunch(const commandLine: ICefCommandLine);
    procedure OnRenderProcessThreadCreated(const extraInfo: ICefListValue);
  end;

  ICefSchemeRegistrar = interface(ICefBase)
  ['{1832FF6E-100B-4E8B-B996-AD633168BEE7}']
    function AddCustomScheme(const schemeName: ustring; IsStandard, IsLocal,
      IsDisplayIsolated: Boolean): Boolean; stdcall;
  end;

  ICefRenderProcessHandler = interface(IcefBase)
  ['{FADEE3BC-BF66-430A-BA5D-1EE3782ECC58}']
    procedure OnRenderThreadCreated(const extraInfo: ICefListValue) ;
    procedure OnWebKitInitialized;
    procedure OnBrowserCreated(const browser: ICefBrowser);
    procedure OnBrowserDestroyed(const browser: ICefBrowser);
    procedure OnContextCreated(const browser: ICefBrowser;
      const frame: ICefFrame; const context: ICefv8Context);
    procedure OnContextReleased(const browser: ICefBrowser;
      const frame: ICefFrame; const context: ICefv8Context);
    procedure OnUncaughtException(const browser: ICefBrowser; const frame: ICefFrame;
      const context: ICefv8Context; const exception: ICefV8Exception;
      const stackTrace: ICefV8StackTrace);
    procedure OnFocusedNodeChanged(const browser: ICefBrowser;
      const frame: ICefFrame; const node: ICefDomNode);
    function OnProcessMessageReceived(const browser: ICefBrowser;
      sourceProcess: TCefProcessId; const message: ICefProcessMessage): Boolean;
  end;

  TOnRegisterCustomSchemes = {$IFDEF DELPHI12_UP}reference to{$ENDIF} procedure(const registrar: ICefSchemeRegistrar);
  TOnBeforeCommandLineProcessing = {$IFDEF DELPHI12_UP}reference to{$ENDIF} procedure(const processType: ustring; const commandLine: ICefCommandLine);

  ICefApp = interface(ICefBase)
    ['{970CA670-9070-4642-B188-7D8A22DAEED4}']
    procedure OnBeforeCommandLineProcessing(const processType: ustring;
      const commandLine: ICefCommandLine);
    procedure OnRegisterCustomSchemes(const registrar: ICefSchemeRegistrar);
    function GetResourceBundleHandler: ICefResourceBundleHandler;
    function GetBrowserProcessHandler: ICefBrowserProcessHandler;
    function GetRenderProcessHandler: ICefRenderProcessHandler;
  end;

  TCefCookieVisitorProc = {$IFDEF DELPHI12_UP} reference to {$ENDIF} function(
    const name, value, domain, path: ustring; secure, httponly,
    hasExpires: Boolean; const creation, lastAccess, expires: TDateTime;
    count, total: Integer; out deleteCookie: Boolean): Boolean;

  ICefCompletionCallback = interface(ICefBase)
    ['{A8ECCFBB-FEE0-446F-AB32-AD69A7478D57}']
    procedure OnComplete;
  end;

  TCefCompletionCallbackProc = {$IFDEF DELPHI12_UP} reference to {$ENDIF} procedure;

  ICefSetCookieCallback = interface(ICefBase)
    ['{16E14B6F-CB0A-4F9D-A008-239E0BC7B892}']
    procedure OnComplete(success: Boolean);
  end;

  TCefSetCookieCallbackProc = {$IFDEF DELPHI12_UP} reference to {$ENDIF} procedure(success: Boolean);

  ICefDeleteCookiesCallback = interface(ICefBase)
    ['{758B79A1-B9E8-4F0D-94A0-DCE5AFADE33D}']
    procedure OnComplete(numDeleted: Integer);
  end;

  TCefDeleteCookiesCallbackProc = {$IFDEF DELPHI12_UP} reference to {$ENDIF} procedure(numDeleted: Integer);

  ICefCookieManager = Interface(ICefBase)
    ['{CC1749E6-9AD3-4283-8430-AF6CBF3E8785}']
    procedure SetSupportedSchemes(schemes: TStrings; const callback: ICefCompletionCallback);
    procedure SetSupportedSchemesProc(schemes: TStrings; const callback: TCefCompletionCallbackProc);
    function VisitAllCookies(const visitor: ICefCookieVisitor): Boolean;
    function VisitAllCookiesProc(const visitor: TCefCookieVisitorProc): Boolean;
    function VisitUrlCookies(const url: ustring;
      includeHttpOnly: Boolean; const visitor: ICefCookieVisitor): Boolean;
    function VisitUrlCookiesProc(const url: ustring;
      includeHttpOnly: Boolean; const visitor: TCefCookieVisitorProc): Boolean;
    function SetCookie(const url: ustring; const name, value, domain, path: ustring; secure, httponly,
      hasExpires: Boolean; const creation, lastAccess, expires: TDateTime;
      const callback: ICefSetCookieCallback): Boolean;
    function SetCookieProc(const url: ustring; const name, value, domain, path: ustring; secure, httponly,
      hasExpires: Boolean; const creation, lastAccess, expires: TDateTime;
      const callback: TCefSetCookieCallbackProc): Boolean;
    function DeleteCookies(const url, cookieName: ustring; const callback: ICefDeleteCookiesCallback): Boolean;
    function DeleteCookiesProc(const url, cookieName: ustring; const callback: TCefDeleteCookiesCallbackProc): Boolean;
    function SetStoragePath(const path: ustring; persistSessionCookies: Boolean; const callback: ICefCompletionCallback): Boolean;
    function SetStoragePathProc(const path: ustring; persistSessionCookies: Boolean; const callback: TCefCompletionCallbackProc): Boolean;
    function FlushStore(const handler: ICefCompletionCallback): Boolean;
    function FlushStoreProc(const proc: TCefCompletionCallbackProc): Boolean;
  end;

  ICefWebPluginInfo = interface(ICefBase)
    ['{AA879E58-F649-44B1-AF9C-655FF5B79A02}']
    function GetName: ustring;
    function GetPath: ustring;
    function GetVersion: ustring;
    function GetDescription: ustring;

    property Name: ustring read GetName;
    property Path: ustring read GetPath;
    property Version: ustring read GetVersion;
    property Description: ustring read GetDescription;
  end;

  ICefCallback = interface(ICefBase)
  ['{1B8C449F-E2D6-4B78-9BBA-6F47E8BCDF37}']
    procedure Cont;
    procedure Cancel;
  end;

  ICefResourceHandler = interface(ICefBase)
  ['{BD3EA208-AAAD-488C-BFF2-76993022F2B5}']
    function ProcessRequest(const request: ICefRequest; const callback: ICefCallback): Boolean;
    procedure GetResponseHeaders(const response: ICefResponse;
      out responseLength: Int64; out redirectUrl: ustring);
    function ReadResponse(const dataOut: Pointer; bytesToRead: Integer;
      var bytesRead: Integer; const callback: ICefCallback): Boolean;
    function CanGetCookie(const cookie: PCefCookie): Boolean;
    function CanSetCookie(const cookie: PCefCookie): Boolean;
    procedure Cancel;
  end;

  ICefSchemeHandlerFactory = interface(ICefBase)
    ['{4D9B7960-B73B-4EBD-9ABE-6C1C43C245EB}']
    function New(const browser: ICefBrowser; const frame: ICefFrame;
      const schemeName: ustring; const request: ICefRequest): ICefResourceHandler;
  end;

  ICefAuthCallback = interface(ICefBase)
  ['{500C2023-BF4D-4FF7-9C04-165E5C389131}']
    procedure Cont(const username, password: ustring);
    procedure Cancel;
  end;

  ICefJsDialogCallback = interface(ICefBase)
  ['{187B2156-9947-4108-87AB-32E559E1B026}']
    procedure Cont(success: Boolean; const userInput: ustring);
  end;

  ICefContextMenuParams = interface(ICefBase)
  ['{E31BFA9E-D4E2-49B7-A05D-20018C8794EB}']
    function GetXCoord: Integer;
    function GetYCoord: Integer;
    function GetTypeFlags: TCefContextMenuTypeFlags;
    function GetLinkUrl: ustring;
    function GetUnfilteredLinkUrl: ustring;
    function GetSourceUrl: ustring;
    function HasImageContents: Boolean;
    function GetPageUrl: ustring;
    function GetFrameUrl: ustring;
    function GetFrameCharset: ustring;
    function GetMediaType: TCefContextMenuMediaType;
    function GetMediaStateFlags: TCefContextMenuMediaStateFlags;
    function GetSelectionText: ustring;
    function GetMisspelledWord: ustring;
    function GetDictionarySuggestions(const suggestions: TStringList): Boolean;
    function IsEditable: Boolean;
    function IsSpellCheckEnabled: Boolean;
    function GetEditStateFlags: TCefContextMenuEditStateFlags;
    function IsCustomMenu: Boolean;
    function IsPepperMenu: Boolean;

    property XCoord: Integer read GetXCoord;
    property YCoord: Integer read GetYCoord;
    property TypeFlags: TCefContextMenuTypeFlags read GetTypeFlags;
    property LinkUrl: ustring read GetLinkUrl;
    property UnfilteredLinkUrl: ustring read GetUnfilteredLinkUrl;
    property SourceUrl: ustring read GetSourceUrl;
    property PageUrl: ustring read GetPageUrl;
    property FrameUrl: ustring read GetFrameUrl;
    property FrameCharset: ustring read GetFrameCharset;
    property MediaType: TCefContextMenuMediaType read GetMediaType;
    property MediaStateFlags: TCefContextMenuMediaStateFlags read GetMediaStateFlags;
    property SelectionText: ustring read GetSelectionText;
    property EditStateFlags: TCefContextMenuEditStateFlags read GetEditStateFlags;
  end;

  ICefMenuModel = interface(ICefBase)
  ['{40AF19D3-8B4E-44B8-8F89-DEB5907FC495}']
    function Clear: Boolean;
    function GetCount: Integer;
    function AddSeparator: Boolean;
    function AddItem(commandId: Integer; const text: ustring): Boolean;
    function AddCheckItem(commandId: Integer; const text: ustring): Boolean;
    function AddRadioItem(commandId: Integer; const text: ustring; groupId: Integer): Boolean;
    function AddSubMenu(commandId: Integer; const text: ustring): ICefMenuModel;
    function InsertSeparatorAt(index: Integer): Boolean;
    function InsertItemAt(index, commandId: Integer; const text: ustring): Boolean;
    function InsertCheckItemAt(index, commandId: Integer; const text: ustring): Boolean;
    function InsertRadioItemAt(index, commandId: Integer; const text: ustring; groupId: Integer): Boolean;
    function InsertSubMenuAt(index, commandId: Integer; const text: ustring): ICefMenuModel;
    function Remove(commandId: Integer): Boolean;
    function RemoveAt(index: Integer): Boolean;
    function GetIndexOf(commandId: Integer): Integer;
    function GetCommandIdAt(index: Integer): Integer;
    function SetCommandIdAt(index, commandId: Integer): Boolean;
    function GetLabel(commandId: Integer): ustring;
    function GetLabelAt(index: Integer): ustring;
    function SetLabel(commandId: Integer; const text: ustring): Boolean;
    function SetLabelAt(index: Integer; const text: ustring): Boolean;
    function GetType(commandId: Integer): TCefMenuItemType;
    function GetTypeAt(index: Integer): TCefMenuItemType;
    function GetGroupId(commandId: Integer): Integer;
    function GetGroupIdAt(index: Integer): Integer;
    function SetGroupId(commandId, groupId: Integer): Boolean;
    function SetGroupIdAt(index, groupId: Integer): Boolean;
    function GetSubMenu(commandId: Integer): ICefMenuModel;
    function GetSubMenuAt(index: Integer): ICefMenuModel;
    function IsVisible(commandId: Integer): Boolean;
    function isVisibleAt(index: Integer): Boolean;
    function SetVisible(commandId: Integer; visible: Boolean): Boolean;
    function SetVisibleAt(index: Integer; visible: Boolean): Boolean;
    function IsEnabled(commandId: Integer): Boolean;
    function IsEnabledAt(index: Integer): Boolean;
    function SetEnabled(commandId: Integer; enabled: Boolean): Boolean;
    function SetEnabledAt(index: Integer; enabled: Boolean): Boolean;
    function IsChecked(commandId: Integer): Boolean;
    function IsCheckedAt(index: Integer): Boolean;
    function setChecked(commandId: Integer; checked: Boolean): Boolean;
    function setCheckedAt(index: Integer; checked: Boolean): Boolean;
    function HasAccelerator(commandId: Integer): Boolean;
    function HasAcceleratorAt(index: Integer): Boolean;
    function SetAccelerator(commandId, keyCode: Integer; shiftPressed, ctrlPressed, altPressed: Boolean): Boolean;
    function SetAcceleratorAt(index, keyCode: Integer; shiftPressed, ctrlPressed, altPressed: Boolean): Boolean;
    function RemoveAccelerator(commandId: Integer): Boolean;
    function RemoveAcceleratorAt(index: Integer): Boolean;
    function GetAccelerator(commandId: Integer; out keyCode: Integer; out shiftPressed, ctrlPressed, altPressed: Boolean): Boolean;
    function GetAcceleratorAt(index: Integer; out keyCode: Integer; out shiftPressed, ctrlPressed, altPressed: Boolean): Boolean;
  end;

  ICefValue = interface(ICefBase)
  ['{66F9F439-B12B-4EC3-A945-91AE4EF4D4BA}']
    function IsValid: Boolean;
    function IsOwned: Boolean;
    function IsReadOnly: Boolean;
    function IsSame(const that: ICefValue): Boolean;
    function IsEqual(const that: ICefValue): Boolean;

    function Copy: ICefValue;

    function GetType: TCefValueType;
    function GetBool: Boolean;
    function GetInt: Integer;
    function GetDouble: Double;
    function GetString: ustring;
    function GetBinary: ICefBinaryValue;
    function GetDictionary: ICefDictionaryValue;
    function GetList: ICefListValue;

    function SetNull: Boolean;
    function SetBool(value: Integer): Boolean;
    function SetInt(value: Integer): Boolean;
    function SetDouble(value: Double): Boolean;
    function SetString(const value: ustring): Boolean;
    function SetBinary(const value: ICefBinaryValue): Boolean;
    function SetDictionary(const value: ICefDictionaryValue): Boolean;
    function SetList(const value: ICefListValue): Boolean;
  end;

  ICefBinaryValue = interface(ICefBase)
  ['{974AA40A-9C5C-4726-81F0-9F0D46D7C5B3}']
    function IsValid: Boolean;
    function IsOwned: Boolean;
    function IsSame(const that: ICefBinaryValue): Boolean;
    function IsEqual(const that: ICefBinaryValue): Boolean;
    function Copy: ICefBinaryValue;
    function GetSize: NativeUInt;
    function GetData(buffer: Pointer; bufferSize, dataOffset: NativeUInt): NativeUInt;
  end;

  ICefDictionaryValue = interface(ICefBase)
  ['{B9638559-54DC-498C-8185-233EEF12BC69}']
    function IsValid: Boolean;
    function isOwned: Boolean;
    function IsReadOnly: Boolean;
    function IsSame(const that: ICefDictionaryValue): Boolean;
    function IsEqual(const that: ICefDictionaryValue): Boolean;
    function Copy(excludeEmptyChildren: Boolean): ICefDictionaryValue;
    function GetSize: NativeUInt;
    function Clear: Boolean;
    function HasKey(const key: ustring): Boolean;
    function GetKeys(const keys: TStrings): Boolean;
    function Remove(const key: ustring): Boolean;
    function GetType(const key: ustring): TCefValueType;
    function GetValue(const key: ustring): ICefValue;
    function GetBool(const key: ustring): Boolean;
    function GetInt(const key: ustring): Integer;
    function GetDouble(const key: ustring): Double;
    function GetString(const key: ustring): ustring;
    function GetBinary(const key: ustring): ICefBinaryValue;
    function GetDictionary(const key: ustring): ICefDictionaryValue;
    function GetList(const key: ustring): ICefListValue;
    function SetValue(const key: ustring; const value: ICefValue): Boolean;
    function SetNull(const key: ustring): Boolean;
    function SetBool(const key: ustring; value: Boolean): Boolean;
    function SetInt(const key: ustring; value: Integer): Boolean;
    function SetDouble(const key: ustring; value: Double): Boolean;
    function SetString(const key, value: ustring): Boolean;
    function SetBinary(const key: ustring; const value: ICefBinaryValue): Boolean;
    function SetDictionary(const key: ustring; const value: ICefDictionaryValue): Boolean;
    function SetList(const key: ustring; const value: ICefListValue): Boolean;
  end;


  ICefListValue = interface(ICefBase)
  ['{09174B9D-0CC6-4360-BBB0-3CC0117F70F6}']
    function IsValid: Boolean;
    function IsOwned: Boolean;
    function IsReadOnly: Boolean;
    function IsSame(const that: ICefListValue): Boolean;
    function IsEqual(const that: ICefListValue): Boolean;
    function Copy: ICefListValue;
    function SetSize(size: NativeUInt): Boolean;
    function GetSize: NativeUInt;
    function Clear: Boolean;
    function Remove(index: Integer): Boolean;
    function GetType(index: Integer): TCefValueType;
    function GetValue(index: Integer): ICefValue;
    function GetBool(index: Integer): Boolean;
    function GetInt(index: Integer): Integer;
    function GetDouble(index: Integer): Double;
    function GetString(index: Integer): ustring;
    function GetBinary(index: Integer): ICefBinaryValue;
    function GetDictionary(index: Integer): ICefDictionaryValue;
    function GetList(index: Integer): ICefListValue;
    function SetValue(index: Integer; const value: ICefValue): Boolean;
    function SetNull(index: Integer): Boolean;
    function SetBool(index: Integer; value: Boolean): Boolean;
    function SetInt(index, value: Integer): Boolean;
    function SetDouble(index: Integer; value: Double): Boolean;
    function SetString(index: Integer; const value: ustring): Boolean;
    function SetBinary(index: Integer; const value: ICefBinaryValue): Boolean;
    function SetDictionary(index: Integer; const value: ICefDictionaryValue): Boolean;
    function SetList(index: Integer; const value: ICefListValue): Boolean;
  end;


  ICefLifeSpanHandler = interface(ICefBase)
  ['{0A3EB782-A319-4C35-9B46-09B2834D7169}']
    function OnBeforePopup(const browser: ICefBrowser; const frame: ICefFrame;
      const targetUrl, targetFrameName: ustring;
      targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean;
      var popupFeatures: TCefPopupFeatures;
      var windowInfo: TCefWindowInfo; var client: ICefClient; var settings: TCefBrowserSettings;
      var noJavascriptAccess: Boolean): Boolean;
    procedure OnAfterCreated(const browser: ICefBrowser);
    procedure OnBeforeClose(const browser: ICefBrowser);
    function RunModal(const browser: ICefBrowser): Boolean;
    function DoClose(const browser: ICefBrowser): Boolean;
  end;

  ICefLoadHandler = interface(ICefBase)
  ['{2C63FB82-345D-4A5B-9858-5AE7A85C9F49}']
    procedure OnLoadingStateChange(const browser: ICefBrowser; isLoading, canGoBack, canGoForward: Boolean);
    procedure OnLoadStart(const browser: ICefBrowser; const frame: ICefFrame);
    procedure OnLoadEnd(const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer);
    procedure OnLoadError(const browser: ICefBrowser; const frame: ICefFrame; errorCode: Integer;
      const errorText, failedUrl: ustring);
  end;

  ICefRequestCallback = interface(ICefBase)
  ['{A35B8FD5-226B-41A8-A763-1940787D321C}']
    procedure Cont(allow: Boolean);
    procedure Cancel;
  end;

  ICefRequestHandler = interface(ICefBase)
  ['{050877A9-D1F8-4EB3-B58E-50DC3E3D39FD}']
    function OnBeforeBrowse(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; isRedirect: Boolean): Boolean;
    function OnOpenUrlFromTab(const browser: ICefBrowser; const frame: ICefFrame;
      const targetUrl: ustring; targetDisposition: TCefWindowOpenDisposition;
      userGesture: Boolean): Boolean;
    function OnBeforeResourceLoad(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; const callback: ICefRequestCallback): TCefReturnValue;
    function GetResourceHandler(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest): ICefResourceHandler;
    procedure OnResourceRedirect(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; var newUrl: ustring);
    function OnResourceResponse(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; const response: ICefResponse): Boolean;
    function GetAuthCredentials(const browser: ICefBrowser; const frame: ICefFrame;
      isProxy: Boolean; const host: ustring; port: Integer; const realm, scheme: ustring;
      const callback: ICefAuthCallback): Boolean;
    function OnQuotaRequest(const browser: ICefBrowser;
      const originUrl: ustring; newSize: Int64; const callback: ICefRequestCallback): Boolean;
    procedure OnProtocolExecution(const browser: ICefBrowser; const url: ustring; out allowOsExecution: Boolean);
    function OnCertificateError(const browser: ICefBrowser; certError: TCefErrorcode;
      const requestUrl: ustring; const sslInfo: ICefSslInfo; const callback: ICefRequestCallback): Boolean;
    procedure OnPluginCrashed(const browser: ICefBrowser; const pluginPath: ustring);
    procedure OnRenderViewReady(const browser: ICefBrowser);
    procedure OnRenderProcessTerminated(const browser: ICefBrowser; status: TCefTerminationStatus);
  end;

  ICefDisplayHandler = interface(ICefBase)
  ['{1EC7C76D-6969-41D1-B26D-079BCFF054C4}']
    procedure OnAddressChange(const browser: ICefBrowser; const frame: ICefFrame; const url: ustring);
    procedure OnTitleChange(const browser: ICefBrowser; const title: ustring);
    procedure OnFaviconUrlChange(const browser: ICefBrowser; icon_urls: TStrings);
    procedure OnFullScreenModeChange(const browser: ICefBrowser; fullscreen: Boolean);
    function OnTooltip(const browser: ICefBrowser; var text: ustring): Boolean;
    procedure OnStatusMessage(const browser: ICefBrowser; const value: ustring);
    function OnConsoleMessage(const browser: ICefBrowser; const message, source: ustring; line: Integer): Boolean;
  end;

  ICefFocusHandler = interface(ICefBase)
  ['{BB7FA3FA-7B1A-4ADC-8E50-12A24018DD90}']
    procedure OnTakeFocus(const browser: ICefBrowser; next: Boolean);
    function OnSetFocus(const browser: ICefBrowser; source: TCefFocusSource): Boolean;
    procedure OnGotFocus(const browser: ICefBrowser);
  end;

  ICefKeyboardHandler = interface(ICefBase)
  ['{0512F4EC-ED88-44C9-90D3-5C6D03D3B146}']
    function OnPreKeyEvent(const browser: ICefBrowser; const event: PCefKeyEvent;
      osEvent: TCefEventHandle; out isKeyboardShortcut: Boolean): Boolean;
    function OnKeyEvent(const browser: ICefBrowser; const event: PCefKeyEvent;
      osEvent: TCefEventHandle): Boolean;
  end;

  ICefJsDialogHandler = interface(ICefBase)
  ['{64E18F86-DAC5-4ED1-8589-44DE45B9DB56}']
    function OnJsdialog(const browser: ICefBrowser; const originUrl, acceptLang: ustring;
      dialogType: TCefJsDialogType; const messageText, defaultPromptText: ustring;
      callback: ICefJsDialogCallback; out suppressMessage: Boolean): Boolean;
    function OnBeforeUnloadDialog(const browser: ICefBrowser;
      const messageText: ustring; isReload: Boolean;
      const callback: ICefJsDialogCallback): Boolean;
    procedure OnResetDialogState(const browser: ICefBrowser);
    procedure OnDialogClosed(const browser: ICefBrowser);
  end;

  ICefRunContextMenuCallback = interface(ICefBase)
  ['{44C3C6E3-B64D-4F6E-A318-4A0F3A72EB00}']
    procedure Cont(commandId: Integer; eventFlags: TCefEventFlags);
    procedure Cancel;
  end;

  ICefContextMenuHandler = interface(ICefBase)
  ['{C2951895-4087-49D5-BA18-4D9BA4F5EDD7}']
    procedure OnBeforeContextMenu(const browser: ICefBrowser; const frame: ICefFrame;
      const params: ICefContextMenuParams; const model: ICefMenuModel);
    function RunContextMenu(const browser: ICefBrowser; const frame: ICefFrame;
      const params: ICefContextMenuParams; const model: ICefMenuModel;
      const callback: ICefRunContextMenuCallback): Boolean;
    function OnContextMenuCommand(const browser: ICefBrowser; const frame: ICefFrame;
      const params: ICefContextMenuParams; commandId: Integer;
      eventFlags: TCefEventFlags): Boolean;
    procedure OnContextMenuDismissed(const browser: ICefBrowser; const frame: ICefFrame);
  end;

  ICefDialogHandler = interface(ICefBase)
  ['{7763F4B2-8BE1-4E80-AC43-8B825850DC67}']
    function OnFileDialog(const browser: ICefBrowser; mode: TCefFileDialogMode;
      const title, defaultFilePath: ustring; acceptFilters: TStrings;
      selectedAcceptFilter: Integer; const callback: ICefFileDialogCallback): Boolean;
  end;

  ICefGeolocationCallback = interface(ICefBase)
  ['{272B8E4F-4AE4-4F14-BC4E-5924FA0C149D}']
    procedure Cont(allow: Boolean);
  end;

  ICefGeolocationHandler = interface(ICefBase)
  ['{1178EE62-BAE7-4E44-932B-EAAC7A18191C}']
    function OnRequestGeolocationPermission(const browser: ICefBrowser;
      const requestingUrl: ustring; requestId: Integer; const callback: ICefGeolocationCallback): Boolean;
    procedure OnCancelGeolocationPermission(const browser: ICefBrowser;
      const requestingUrl: ustring; requestId: Integer);
  end;

  ICefRenderHandler = interface(ICefBase)
  ['{1FC1C22B-085A-4741-9366-5249B88EC410}']
    function GetRootScreenRect(const browser: ICefBrowser; rect: PCefRect): Boolean;
    function GetViewRect(const browser: ICefBrowser; rect: PCefRect): Boolean;
    function GetScreenPoint(const browser: ICefBrowser; viewX, viewY: Integer;
      screenX, screenY: PInteger): Boolean;
    function GetScreenInfo(const browser: ICefBrowser; screenInfo: PCefScreenInfo): Boolean;
    procedure OnPopupShow(const browser: ICefBrowser; show: Boolean);
    procedure OnPopupSize(const browser: ICefBrowser; const rect: PCefRect);
    procedure OnPaint(const browser: ICefBrowser; kind: TCefPaintElementType;
      dirtyRectsCount: NativeUInt; const dirtyRects: PCefRectArray;
      const buffer: Pointer; width, height: Integer);
    procedure OnCursorChange(const browser: ICefBrowser; cursor: TCefCursorHandle;
      CursorType: TCefCursorType; const customCursorInfo: PCefCursorInfo);
    function OnStartDragging(const browser: ICefBrowser; const dragData: ICefDragData;
      allowedOps: TCefDragOperations; x, y: Integer): Boolean;
    procedure OnUpdateDragCursor(const browser: ICefBrowser;
      operation: TCefDragOperation);
    procedure OnScrollOffsetChanged(const browser: ICefBrowser; x, y: Double);
  end;

  ICefClient = interface(ICefBase)
    ['{1D502075-2FF0-4E13-A112-9E541CD811F4}']
    function GetContextMenuHandler: ICefContextMenuHandler;
    function GetDisplayHandler: ICefDisplayHandler;
    function GetDownloadHandler: ICefDownloadHandler;
    function GetFocusHandler: ICefFocusHandler;
    function GetGeolocationHandler: ICefGeolocationHandler;
    function GetJsdialogHandler: ICefJsdialogHandler;
    function GetKeyboardHandler: ICefKeyboardHandler;
    function GetLifeSpanHandler: ICefLifeSpanHandler;
    function GetLoadHandler: ICefLoadHandler;
    function GetRenderHandler: ICefRenderHandler;
    function GetRequestHandler: ICefRequestHandler;
    function OnProcessMessageReceived(const browser: ICefBrowser;
      sourceProcess: TCefProcessId; const message: ICefProcessMessage): Boolean;
  end;

  ICefUrlRequest = interface(ICefBase)
    ['{59226AC1-A0FA-4D59-9DF4-A65C42391A67}']
    function GetRequest: ICefRequest;
    function GetRequestStatus: TCefUrlRequestStatus;
    function GetRequestError: Integer;
    function GetResponse: ICefResponse;
    procedure Cancel;
  end;

  ICefUrlrequestClient = interface(ICefBase)
    ['{114155BD-C248-4651-9A4F-26F3F9A4F737}']
    procedure OnRequestComplete(const request: ICefUrlRequest);
    procedure OnUploadProgress(const request: ICefUrlRequest; current, total: Int64);
    procedure OnDownloadProgress(const request: ICefUrlRequest; current, total: Int64);
    procedure OnDownloadData(const request: ICefUrlRequest; data: Pointer; dataLength: NativeUInt);
    function OnGetAuthCredentials(isProxy: Boolean; const host: ustring; port: Integer;
      const realm, scheme: ustring; const callback: ICefAuthCallback): Boolean;
  end;

  ICefWebPluginInfoVisitor = interface(ICefBase)
  ['{7523D432-4424-4804-ACAD-E67D2313436E}']
    function Visit(const info: ICefWebPluginInfo; count, total: Integer): Boolean;
  end;

  ICefWebPluginUnstableCallback = interface(ICefBase)
  ['{67459829-EB47-4B7E-9D69-2EE77DF0E71E}']
    procedure IsUnstable(const path: ustring; unstable: Boolean);
  end;

  ICefEndTracingCallback = interface(ICefBase)
  ['{79020EBE-9D1D-49A6-9714-8778FE8929F2}']
    procedure OnEndTracingComplete(const tracingFile: ustring);
  end;

  ICefGetGeolocationCallback = interface(ICefBase)
    ['{ACB82FD9-3FFD-43F9-BF1A-A4849BF5B814}']
    procedure OnLocationUpdate(const position: PCefGeoposition);
  end;

  ICefFileDialogCallback = interface(ICefBase)
    ['{1AF659AB-4522-4E39-9C52-184000D8E3C7}']
    procedure Cont(selectedAcceptFilter: Integer; filePaths: TStrings);
    procedure Cancel;
  end;

  ICefDragData = interface(ICefBase)
  ['{FBB6A487-F633-4055-AB3E-6619EDE75683}']
    function Clone: ICefDragData;
    function IsReadOnly: Boolean;
    function IsLink: Boolean;
    function IsFragment: Boolean;
    function IsFile: Boolean;
    function GetLinkUrl: ustring;
    function GetLinkTitle: ustring;
    function GetLinkMetadata: ustring;
    function GetFragmentText: ustring;
    function GetFragmentHtml: ustring;
    function GetFragmentBaseUrl: ustring;
    function GetFileName: ustring;
    function GetFileContents(const writer: ICefStreamWriter): NativeUInt;
    function GetFileNames(names: TStrings): Integer;
    procedure SetLinkUrl(const url: ustring);
    procedure SetLinkTitle(const title: ustring);
    procedure SetLinkMetadata(const data: ustring);
    procedure SetFragmentText(const text: ustring);
    procedure SetFragmentHtml(const html: ustring);
    procedure SetFragmentBaseUrl(const baseUrl: ustring);
    procedure ResetFileContents;
    procedure AddFile(const path, displayName: ustring);
  end;

  ICefDragHandler = interface(ICefBase)
    ['{59A89579-5B18-489F-A25C-5CC25FF831FC}']
    function OnDragEnter(const browser: ICefBrowser; const dragData: ICefDragData;
      mask: TCefDragOperations): Boolean;
    procedure OnDraggableRegionsChanged(const browser: ICefBrowser;
      regionsCount: NativeUInt; regions: PCefDraggableRegionArray);
  end;

  ICefFindHandler = interface(ICefBase)
    ['{F20DF234-BD43-42B3-A80B-D354A9E5B787}']
    procedure OnFindResult(const browser: ICefBrowser;
      identifier, count: Integer; const selectionRect: PCefRect;
      activeMatchOrdinal: Integer; finalUpdate: Boolean);
  end;

  ICefRequestContextHandler = interface(ICefBase)
    ['{76EB1FA7-78DF-4FD5-ABB3-1CDD3E73A140}']
    function GetCookieManager: ICefCookieManager;
    function OnBeforePluginLoad(const mimeType, pluginUrl, topOriginUrl: ustring;
      const pluginInfo: ICefWebPluginInfo; pluginPolicy: PCefPluginPolicy): Boolean;
  end;

  ICefRequestContext = interface(ICefBase)
    ['{5830847A-2971-4BD5-ABE6-21451F8923F7}']
    function IsSame(const other: ICefRequestContext): Boolean;
    function IsSharingWith(const other: ICefRequestContext): Boolean;
    function IsGlobal: Boolean;
    function GetHandler: ICefRequestContextHandler;
    function GetCachePath: ustring;
    function GetDefaultCookieManager(const callback: ICefCompletionCallback): ICefCookieManager;
    function GetDefaultCookieManagerProc(const callback: TCefCompletionCallbackProc): ICefCookieManager;
    function RegisterSchemeHandlerFactory(const schemeName, domainName: ustring;
        const factory: ICefSchemeHandlerFactory): Boolean;
    function ClearSchemeHandlerFactories: Boolean;
    procedure PurgePluginListCache(reloadPages: Boolean);
  end;

  ICefPrintSettings = Interface(ICefBase)
    ['{ACBD2395-E9C1-49E5-B7F3-344DAA4A0F12}']
    function IsValid: Boolean;
    function IsReadOnly: Boolean;
    function Copy: ICefPrintSettings;
    procedure SetOrientation(landscape: Boolean);
    function IsLandscape: Boolean;
    procedure SetPrinterPrintableArea(
      const physicalSizeDeviceUnits: PCefSize;
      const printableAreaDeviceUnits: PCefRect;
      landscapeNeedsFlip: Boolean); stdcall;
    procedure SetDeviceName(const name: ustring);
    function GetDeviceName: ustring;
    procedure SetDpi(dpi: Integer);
    function GetDpi: Integer;
    procedure SetPageRanges(const ranges: TCefPageRangeArray);
    function GetPageRangesCount: NativeUInt;
    procedure GetPageRanges(out ranges: TCefPageRangeArray);
    procedure SetSelectionOnly(selectionOnly: Boolean);
    function IsSelectionOnly: Boolean;
    procedure SetCollate(collate: Boolean);
    function WillCollate: Boolean;
    procedure SetColorModel(model: TCefColorModel);
    function GetColorModel: TCefColorModel;
    procedure SetCopies(copies: Integer);
    function GetCopies: Integer;
    procedure SetDuplexMode(mode: TCefDuplexMode);
    function GetDuplexMode: TCefDuplexMode;

    property Landscape: Boolean read IsLandscape write SetOrientation;
    property DeviceName: ustring read GetDeviceName write SetDeviceName;
    property Dpi: Integer read GetDpi write SetDpi;
    property SelectionOnly: Boolean read IsSelectionOnly write SetSelectionOnly;
    property Collate: Boolean read WillCollate write SetCollate;
    property ColorModel: TCefColorModel read GetColorModel write SetColorModel;
    property Copies: Integer read GetCopies write SetCopies;
    property DuplexMode: TCefDuplexMode read GetDuplexMode write SetDuplexMode;
  end;

  ICefNavigationEntry = interface(ICefBase)
  ['{D17B4B37-AA45-42D9-B4E4-AAB6FE2AB297}']
    function IsValid: Boolean;
    function GetUrl: ustring;
    function GetDisplayUrl: ustring;
    function GetOriginalUrl: ustring;
    function GetTitle: ustring;
    function GetTransitionType: TCefTransitionType;
    function HasPostData: Boolean;
    function GetCompletionTime: TDateTime;
    function GetHttpStatusCode: Integer;

    property Url: ustring read GetUrl;
    property DisplayUrl: ustring read GetDisplayUrl;
    property OriginalUrl: ustring read GetOriginalUrl;
    property Title: ustring read GetTitle;
    property TransitionType: TCefTransitionType read GetTransitionType;
    property CompletionTime: TDateTime read GetCompletionTime;
    property HttpStatusCode: Integer read GetHttpStatusCode;
  end;

  ICefSslCertPrincipal = interface(ICefBase)
  ['{A0B083E1-51D3-4753-9FDD-9ADF75C3E68B}']
    function GetDisplayName: ustring;
    function GetCommonName: ustring;
    function GetLocalityName: ustring;
    function GetStateOrProvinceName: ustring;
    function GetCountryName: ustring;
    procedure GetStreetAddresses(addresses: TStrings);
    procedure GetOrganizationNames(names: TStrings);
    procedure GetOrganizationUnitNames(names: TStrings);
    procedure GetDomainComponents(components: TStrings);
  end;

  ICefSslInfo = interface(ICefBase)
  ['{67EC86BD-DE7D-453D-908F-AD15626C514F}']
    function GetSubject: ICefSslCertPrincipal;
    function GetIssuer: ICefSslCertPrincipal;
    function GetSerialNumber: ICefBinaryValue;
    function GetValidStart: TCefTime;
    function GetValidExpiry: TCefTime;
    function GetDerEncoded: ICefBinaryValue;
    function GetPemEncoded: ICefBinaryValue;
  end;

  ICefResourceBundle = interface(ICefBase)
  ['{3213CF97-C854-452B-B615-39192F8D07DC}']
    function GetLocalizedString(stringId: Integer): ustring;
    function GetDataResource(resourceId: Integer;
      out data: Pointer; out dataSize: NativeUInt): Boolean;
    function GetDataResourceForScale(resourceId: Integer; scaleFactor: TCefScaleFactor;
      out data: Pointer; out dataSize: NativeUInt): Boolean;
  end;

/////////////////////////////////////////


  TCefBaseOwn = class(TInterfacedObject, ICefBase)
  private
    FData: Pointer;
  public
    function Wrap: Pointer;
    constructor CreateData(size: Cardinal; owned: Boolean = False); virtual;
    destructor Destroy; override;
  end;

  TCefBaseRef = class(TInterfacedObject, ICefBase)
  private
    FData: Pointer;
  public
    constructor Create(data: Pointer); virtual;
    destructor Destroy; override;
    function Wrap: Pointer;
    class function UnWrap(data: Pointer): ICefBase;
  end;

  TCefRunFileDialogCallbackOwn = class(TCefBaseOwn, ICefRunFileDialogCallback)
  protected
    procedure OnFileDialogDismissed(selectedAcceptFilter: Integer; filePaths: TStrings); virtual;
  public
    constructor Create;
  end;

  TCefFastRunFileDialogCallback = class(TCefRunFileDialogCallbackOwn)
  private
    FCallback: TCefRunFileDialogCallbackProc;
  protected
    procedure OnFileDialogDismissed(selectedAcceptFilter: Integer; filePaths: TStrings); override;
  public
    constructor Create(callback: TCefRunFileDialogCallbackProc); reintroduce; virtual;
  end;

  TCefBrowserHostRef = class(TCefBaseRef, ICefBrowserHost)
  protected
    function GetBrowser: ICefBrowser;
    procedure CloseBrowser(forceClose: Boolean);
    procedure SetFocus(focus: Boolean);
    procedure SetWindowVisibility(visible: Boolean);
    function GetWindowHandle: TCefWindowHandle;
    function GetOpenerWindowHandle: TCefWindowHandle;
    function GetRequestContext: ICefRequestContext;
    function GetZoomLevel: Double;
    procedure SetZoomLevel(zoomLevel: Double);
    procedure RunFileDialog(mode: TCefFileDialogMode; const title, defaultFilePath: ustring;
      acceptFilters: TStrings; selectedAcceptFilter: Integer; const callback: ICefRunFileDialogCallback);
    procedure RunFileDialogProc(mode: TCefFileDialogMode; const title, defaultFilePath: ustring;
      acceptFilters: TStrings; selectedAcceptFilter: Integer; const callback: TCefRunFileDialogCallbackProc);
    procedure StartDownload(const url: ustring);
    procedure Print;
    procedure PrintToPdf(const path: ustring; settings: PCefPdfPrintSettings; const callback: ICefPdfPrintCallback);
    procedure PrintToPdfProc(const path: ustring; settings: PCefPdfPrintSettings; const callback: TOnPdfPrintFinishedProc);
    procedure Find(identifier: Integer; const searchText: ustring; forward, matchCase, findNext: Boolean);
    procedure StopFinding(clearSelection: Boolean);
    procedure ShowDevTools(const windowInfo: PCefWindowInfo; const client: ICefClient;
      const settings: PCefBrowserSettings; inspectElementAt: PCefPoint);
    procedure CloseDevTools;
    procedure GetNavigationEntries(const visitor: ICefNavigationEntryVisitor; currentOnly: Boolean);
    procedure GetNavigationEntriesProc(const proc: TCefNavigationEntryVisitorProc; currentOnly: Boolean);
    procedure SetMouseCursorChangeDisabled(disabled: Boolean);
    function IsMouseCursorChangeDisabled: Boolean;
    procedure ReplaceMisspelling(const word: ustring);
    procedure AddWordToDictionary(const word: ustring);
    function IsWindowRenderingDisabled: Boolean;
    procedure WasResized;
    procedure NotifyScreenInfoChanged;
    procedure WasHidden(hidden: Boolean);
    procedure Invalidate(kind: TCefPaintElementType);
    procedure SendKeyEvent(const event: PCefKeyEvent);
    procedure SendMouseClickEvent(const event: PCefMouseEvent;
      kind: TCefMouseButtonType; mouseUp: Boolean; clickCount: Integer);
    procedure SendMouseMoveEvent(const event: PCefMouseEvent; mouseLeave: Boolean);
    procedure SendMouseWheelEvent(const event: PCefMouseEvent; deltaX, deltaY: Integer);
    procedure SendFocusEvent(setFocus: Boolean);
    procedure SendCaptureLostEvent;
    procedure NotifyMoveOrResizeStarted;
    function GetWindowlessFrameRate(): Integer;
    procedure SetWindowlessFrameRate(frameRate: Integer);
    function GetNsTextInputContext: TCefTextInputContext;
    procedure HandleKeyEventBeforeTextInputClient(keyEvent: TCefEventHandle);
    procedure HandleKeyEventAfterTextInputClient(keyEvent: TCefEventHandle);

    procedure DragTargetDragEnter(const dragData: ICefDragData;
      const event: PCefMouseEvent; allowedOps: TCefDragOperations);
    procedure DragTargetDragOver(const event: PCefMouseEvent; allowedOps: TCefDragOperations);
    procedure DragTargetDragLeave;
    procedure DragTargetDrop(event: PCefMouseEvent);
    procedure DragSourceEndedAt(x, y: Integer; op: TCefDragOperation);
    procedure DragSourceSystemDragEnded;
  public
    class function UnWrap(data: Pointer): ICefBrowserHost;
  end;

  TCefBrowserRef = class(TCefBaseRef, ICefBrowser)
  protected
    function GetHost: ICefBrowserHost;
    function CanGoBack: Boolean;
    procedure GoBack;
    function CanGoForward: Boolean;
    procedure GoForward;
    function IsLoading: Boolean;
    procedure Reload;
    procedure ReloadIgnoreCache;
    procedure StopLoad;
    function GetIdentifier: Integer;
    function IsSame(const that: ICefBrowser): Boolean;
    function IsPopup: Boolean;
    function HasDocument: Boolean;
    function GetMainFrame: ICefFrame;
    function GetFocusedFrame: ICefFrame;
    function GetFrameByident(identifier: Int64): ICefFrame;
    function GetFrame(const name: ustring): ICefFrame;
    function GetFrameCount: NativeUInt;
    procedure GetFrameIdentifiers(count: PNativeUInt; identifiers: PInt64);
    procedure GetFrameNames(names: TStrings);
    function SendProcessMessage(targetProcess: TCefProcessId;
      message: ICefProcessMessage): Boolean;
  public
    class function UnWrap(data: Pointer): ICefBrowser;
  end;

  TCefFrameRef = class(TCefBaseRef, ICefFrame)
  protected
    function IsValid: Boolean;
    procedure Undo;
    procedure Redo;
    procedure Cut;
    procedure Copy;
    procedure Paste;
    procedure Del;
    procedure SelectAll;
    procedure ViewSource;
    procedure GetSource(const visitor: ICefStringVisitor);
    procedure GetSourceProc(const proc: TCefStringVisitorProc);
    procedure GetText(const visitor: ICefStringVisitor);
    procedure GetTextProc(const proc: TCefStringVisitorProc);
    procedure LoadRequest(const request: ICefRequest);
    procedure LoadUrl(const url: ustring);
    procedure LoadString(const str, url: ustring);
    procedure ExecuteJavaScript(const code, scriptUrl: ustring; startLine: Integer);
    function IsMain: Boolean;
    function IsFocused: Boolean;
    function GetName: ustring;
    function GetIdentifier: Int64;
    function GetParent: ICefFrame;
    function GetUrl: ustring;
    function GetBrowser: ICefBrowser;
    function GetV8Context: ICefv8Context;
    procedure VisitDom(const visitor: ICefDomVisitor);
    procedure VisitDomProc(const proc: TCefDomVisitorProc);
  public
    class function UnWrap(data: Pointer): ICefFrame;
  end;

  TCefPostDataRef = class(TCefBaseRef, ICefPostData)
  protected
    function IsReadOnly: Boolean;
    function GetCount: NativeUInt;
    function GetElements(Count: NativeUInt): IInterfaceList; // ICefPostDataElement
    function RemoveElement(const element: ICefPostDataElement): Integer;
    function AddElement(const element: ICefPostDataElement): Integer;
    procedure RemoveElements;
  public
    class function UnWrap(data: Pointer): ICefPostData;
    class function New: ICefPostData;
  end;

  TCefPostDataElementRef = class(TCefBaseRef, ICefPostDataElement)
  protected
    function IsReadOnly: Boolean;
    procedure SetToEmpty;
    procedure SetToFile(const fileName: ustring);
    procedure SetToBytes(size: NativeUInt; bytes: Pointer);
    function GetType: TCefPostDataElementType;
    function GetFile: ustring;
    function GetBytesCount: NativeUInt;
    function GetBytes(size: NativeUInt; bytes: Pointer): NativeUInt;
  public
    class function UnWrap(data: Pointer): ICefPostDataElement;
    class function New: ICefPostDataElement;
  end;

  TCefRequestRef = class(TCefBaseRef, ICefRequest)
  protected
    function IsReadOnly: Boolean;
    function GetUrl: ustring;
    function GetMethod: ustring;
    function GetPostData: ICefPostData;
    procedure GetHeaderMap(const HeaderMap: ICefStringMultimap);
    procedure SetUrl(const value: ustring);
    procedure SetMethod(const value: ustring);
    procedure SetPostData(const value: ICefPostData);
    procedure SetHeaderMap(const HeaderMap: ICefStringMultimap);
    function GetFlags: TCefUrlRequestFlags;
    procedure SetFlags(flags: TCefUrlRequestFlags);
    function GetFirstPartyForCookies: ustring;
    procedure SetFirstPartyForCookies(const url: ustring);
    procedure Assign(const url, method: ustring;
      const postData: ICefPostData; const headerMap: ICefStringMultimap);
    function GetResourceType: TCefResourceType;
    function GetTransitionType: TCefTransitionType;
    function GetIdentifier: UInt64;
  public
    class function UnWrap(data: Pointer): ICefRequest;
    class function New: ICefRequest;
  end;

  TCefStreamReaderRef = class(TCefBaseRef, ICefStreamReader)
  protected
    function Read(ptr: Pointer; size, n: NativeUInt): NativeUInt;
    function Seek(offset: Int64; whence: Integer): Integer;
    function Tell: Int64;
    function Eof: Boolean;
    function MayBlock: Boolean;
  public
    class function UnWrap(data: Pointer): ICefStreamReader;
    class function CreateForFile(const filename: ustring): ICefStreamReader;
    class function CreateForCustomStream(const stream: ICefCustomStreamReader): ICefStreamReader;
    class function CreateForStream(const stream: TSTream; owned: Boolean): ICefStreamReader;
    class function CreateForData(data: Pointer; size: NativeUInt): ICefStreamReader;
  end;

  TCefWriteHandlerOwn = class(TCefBaseOwn, ICefWriteHandler)
  protected
    function Write(const ptr: Pointer; size, n: NativeUInt): NativeUInt; virtual;
    function Seek(offset: Int64; whence: Integer): Integer; virtual;
    function Tell: Int64; virtual;
    function Flush: Integer; virtual;
    function MayBlock: Boolean; virtual;
  public
    constructor Create; virtual;
  end;

  TCefStreamWriterRef = class(TCefBaseRef, ICefStreamWriter)
  protected
    function write(const ptr: Pointer; size, n: NativeUInt): NativeUInt;
    function Seek(offset: Int64; whence: Integer): Integer;
    function Tell: Int64;
    function Flush: Integer;
    function MayBlock: Boolean;
  public
    class function UnWrap(data: Pointer): ICefStreamWriter;
    class function CreateForFile(const fileName: ustring): ICefStreamWriter;
    class function CreateForHandler(const handler: ICefWriteHandler): ICefStreamWriter;
  end;


  TCefV8AccessorGetterProc = {$IFDEF DELPHI12_UP} reference to{$ENDIF} function(
    const name: ustring; const obj: ICefv8Value; out value: ICefv8Value; const exception: ustring): Boolean;

  TCefV8AccessorSetterProc = {$IFDEF DELPHI12_UP}reference to {$ENDIF} function(
    const name: ustring; const obj, value: ICefv8Value; const exception: ustring): Boolean;

  TCefv8ValueRef = class(TCefBaseRef, ICefv8Value)
  protected
    function IsValid: Boolean;
    function IsUndefined: Boolean;
    function IsNull: Boolean;
    function IsBool: Boolean;
    function IsInt: Boolean;
    function IsUInt: Boolean;
    function IsDouble: Boolean;
    function IsDate: Boolean;
    function IsString: Boolean;
    function IsObject: Boolean;
    function IsArray: Boolean;
    function IsFunction: Boolean;
    function IsSame(const that: ICefv8Value): Boolean;
    function GetBoolValue: Boolean;
    function GetIntValue: Integer;
    function GetUIntValue: Cardinal;
    function GetDoubleValue: Double;
    function GetDateValue: TDateTime;
    function GetStringValue: ustring;
    function IsUserCreated: Boolean;
    function HasException: Boolean;
    function GetException: ICefV8Exception;
    function ClearException: Boolean;
    function WillRethrowExceptions: Boolean;
    function SetRethrowExceptions(rethrow: Boolean): Boolean;
    function HasValueByKey(const key: ustring): Boolean;
    function HasValueByIndex(index: Integer): Boolean;
    function DeleteValueByKey(const key: ustring): Boolean;
    function DeleteValueByIndex(index: Integer): Boolean;
    function GetValueByKey(const key: ustring): ICefv8Value;
    function GetValueByIndex(index: Integer): ICefv8Value;
    function SetValueByKey(const key: ustring; const value: ICefv8Value;
      attribute: TCefV8PropertyAttributes): Boolean;
    function SetValueByIndex(index: Integer; const value: ICefv8Value): Boolean;
    function SetValueByAccessor(const key: ustring; settings: TCefV8AccessControls;
      attribute: TCefV8PropertyAttributes): Boolean;
    function GetKeys(const keys: TStrings): Integer;
    function SetUserData(const data: ICefv8Value): Boolean;
    function GetUserData: ICefv8Value;
    function GetExternallyAllocatedMemory: Integer;
    function AdjustExternallyAllocatedMemory(changeInBytes: Integer): Integer;
    function GetArrayLength: Integer;
    function GetFunctionName: ustring;
    function GetFunctionHandler: ICefv8Handler;
    function ExecuteFunction(const obj: ICefv8Value;
      const arguments: TCefv8ValueArray): ICefv8Value;
    function ExecuteFunctionWithContext(const context: ICefv8Context;
      const obj: ICefv8Value; const arguments: TCefv8ValueArray): ICefv8Value;
  public
    class function UnWrap(data: Pointer): ICefv8Value;
    class function NewUndefined: ICefv8Value;
    class function NewNull: ICefv8Value;
    class function NewBool(value: Boolean): ICefv8Value;
    class function NewInt(value: Integer): ICefv8Value;
    class function NewUInt(value: Cardinal): ICefv8Value;
    class function NewDouble(value: Double): ICefv8Value;
    class function NewDate(value: TDateTime): ICefv8Value;
    class function NewString(const str: ustring): ICefv8Value;
    class function NewObject(const Accessor: ICefV8Accessor): ICefv8Value;
    class function NewObjectProc(const getter: TCefV8AccessorGetterProc;
      const setter: TCefV8AccessorSetterProc): ICefv8Value;
    class function NewArray(len: Integer): ICefv8Value;
    class function NewFunction(const name: ustring; const handler: ICefv8Handler): ICefv8Value;
  end;

  TCefv8ContextRef = class(TCefBaseRef, ICefv8Context)
  protected
    function GetTaskRunner: ICefTaskRunner;
    function IsValid: Boolean;
    function GetBrowser: ICefBrowser;
    function GetFrame: ICefFrame;
    function GetGlobal: ICefv8Value;
    function Enter: Boolean;
    function Exit: Boolean;
    function IsSame(const that: ICefv8Context): Boolean;
    function Eval(const code: ustring; var retval: ICefv8Value; var exception: ICefV8Exception): Boolean;
  public
    class function UnWrap(data: Pointer): ICefv8Context;
    class function Current: ICefv8Context;
    class function Entered: ICefv8Context;
  end;

  TCefV8StackFrameRef = class(TCefBaseRef, ICefV8StackFrame)
  protected
    function IsValid: Boolean;
    function GetScriptName: ustring;
    function GetScriptNameOrSourceUrl: ustring;
    function GetFunctionName: ustring;
    function GetLineNumber: Integer;
    function GetColumn: Integer;
    function IsEval: Boolean;
    function IsConstructor: Boolean;
  public
    class function UnWrap(data: Pointer): ICefV8StackFrame;
  end;

  TCefV8StackTraceRef = class(TCefBaseRef, ICefV8StackTrace)
  protected
    function IsValid: Boolean;
    function GetFrameCount: Integer;
    function GetFrame(index: Integer): ICefV8StackFrame;
  public
    class function UnWrap(data: Pointer): ICefV8StackTrace;
    class function Current(frameLimit: Integer): ICefV8StackTrace;
  end;

  TCefv8HandlerRef = class(TCefBaseRef, ICefv8Handler)
  protected
    function Execute(const name: ustring; const obj: ICefv8Value;
      const arguments: TCefv8ValueArray; var retval: ICefv8Value;
      var exception: ustring): Boolean;
  public
    class function UnWrap(data: Pointer): ICefv8Handler;
  end;

  TCefClientOwn = class(TCefBaseOwn, ICefClient)
  protected
    function GetContextMenuHandler: ICefContextMenuHandler; virtual;
    function GetDialogHandler: ICefDialogHandler; virtual;
    function GetDisplayHandler: ICefDisplayHandler; virtual;
    function GetDownloadHandler: ICefDownloadHandler; virtual;
    function GetDragHandler: ICefDragHandler; virtual;
    function GetFindHandler: ICefFindHandler; virtual;
    function GetFocusHandler: ICefFocusHandler; virtual;
    function GetGeolocationHandler: ICefGeolocationHandler; virtual;
    function GetJsdialogHandler: ICefJsdialogHandler; virtual;
    function GetKeyboardHandler: ICefKeyboardHandler; virtual;
    function GetLifeSpanHandler: ICefLifeSpanHandler; virtual;
    function GetRenderHandler: ICefRenderHandler; virtual;
    function GetLoadHandler: ICefLoadHandler; virtual;
    function GetRequestHandler: ICefRequestHandler; virtual;
    function OnProcessMessageReceived(const browser: ICefBrowser;
      sourceProcess: TCefProcessId; const message: ICefProcessMessage): Boolean; virtual;
  public
    constructor Create; virtual;
  end;

  TCefGeolocationHandlerOwn = class(TCefBaseOwn, ICefGeolocationHandler)
  protected
    function OnRequestGeolocationPermission(const browser: ICefBrowser;
      const requestingUrl: ustring; requestId: Integer;
      const callback: ICefGeolocationCallback): Boolean; virtual;
    procedure OnCancelGeolocationPermission(const browser: ICefBrowser;
      const requestingUrl: ustring; requestId: Integer); virtual;
  public

    constructor Create; virtual;
  end;


  TCefLifeSpanHandlerOwn = class(TCefBaseOwn, ICefLifeSpanHandler)
  protected
    function OnBeforePopup(const browser: ICefBrowser; const frame: ICefFrame;
      const targetUrl, targetFrameName: ustring; targetDisposition: TCefWindowOpenDisposition;
      userGesture: Boolean; var popupFeatures: TCefPopupFeatures;
      var windowInfo: TCefWindowInfo; var client: ICefClient; var settings: TCefBrowserSettings;
      var noJavascriptAccess: Boolean): Boolean; virtual;
    procedure OnAfterCreated(const browser: ICefBrowser); virtual;
    procedure OnBeforeClose(const browser: ICefBrowser); virtual;
    function RunModal(const browser: ICefBrowser): Boolean; virtual;
    function DoClose(const browser: ICefBrowser): Boolean; virtual;
  public
    constructor Create; virtual;
  end;

  TCefLoadHandlerOwn = class(TCefBaseOwn, ICefLoadHandler)
  protected
    procedure OnLoadingStateChange(const browser: ICefBrowser; isLoading, canGoBack, canGoForward: Boolean); virtual;
    procedure OnLoadStart(const browser: ICefBrowser; const frame: ICefFrame); virtual;
    procedure OnLoadEnd(const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer); virtual;
    procedure OnLoadError(const browser: ICefBrowser; const frame: ICefFrame; errorCode: Integer;
      const errorText, failedUrl: ustring); virtual;
  public
    constructor Create; virtual;
  end;

  TCefRequestCallbackRef = class(TCefBaseRef, ICefRequestCallback)
  protected
    procedure Cont(allow: Boolean);
    procedure Cancel;
  public
     class function UnWrap(data: Pointer): ICefRequestCallback;
  end;

  TCefRequestHandlerOwn = class(TCefBaseOwn, ICefRequestHandler)
  protected
    function OnBeforeBrowse(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; isRedirect: Boolean): Boolean; virtual;
    function OnOpenUrlFromTab(const browser: ICefBrowser; const frame: ICefFrame;
      const targetUrl: ustring; targetDisposition: TCefWindowOpenDisposition;
      userGesture: Boolean): Boolean; virtual;
    function OnBeforeResourceLoad(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; const callback: ICefRequestCallback): TCefReturnValue; virtual;
    function GetResourceHandler(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest): ICefResourceHandler; virtual;
    procedure OnResourceRedirect(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; var newUrl: ustring); virtual;
    function OnResourceResponse(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; const response: ICefResponse): Boolean; virtual;
    function GetAuthCredentials(const browser: ICefBrowser; const frame: ICefFrame;
      isProxy: Boolean; const host: ustring; port: Integer; const realm, scheme: ustring;
      const callback: ICefAuthCallback): Boolean; virtual;
    function OnQuotaRequest(const browser: ICefBrowser; const originUrl: ustring;
      newSize: Int64; const callback: ICefRequestCallback): Boolean; virtual;
    function GetCookieManager(const browser: ICefBrowser; const mainUrl: ustring): ICefCookieManager; virtual;
    procedure OnProtocolExecution(const browser: ICefBrowser; const url: ustring; out allowOsExecution: Boolean); virtual;
    function OnCertificateError(const browser: ICefBrowser; certError: TCefErrorcode;
      const requestUrl: ustring; const sslInfo: ICefSslInfo; const callback: ICefRequestCallback): Boolean; virtual;
    procedure OnPluginCrashed(const browser: ICefBrowser; const pluginPath: ustring); virtual;
    procedure OnRenderViewReady(const browser: ICefBrowser); virtual;
    procedure OnRenderProcessTerminated(const browser: ICefBrowser; status: TCefTerminationStatus); virtual;
  public
    constructor Create; virtual;
  end;

  TCefDisplayHandlerOwn = class(TCefBaseOwn, ICefDisplayHandler)
  protected
    procedure OnAddressChange(const browser: ICefBrowser; const frame: ICefFrame; const url: ustring); virtual;
    procedure OnTitleChange(const browser: ICefBrowser; const title: ustring); virtual;
    procedure OnFaviconUrlChange(const browser: ICefBrowser; iconUrls: TStrings); virtual;
    procedure OnFullScreenModeChange(const browser: ICefBrowser; fullscreen: Boolean); virtual;
    function OnTooltip(const browser: ICefBrowser; var text: ustring): Boolean; virtual;
    procedure OnStatusMessage(const browser: ICefBrowser; const value: ustring); virtual;
    function OnConsoleMessage(const browser: ICefBrowser; const message, source: ustring; line: Integer): Boolean; virtual;
  public
    constructor Create; virtual;
  end;

  TCefFocusHandlerOwn = class(TCefBaseOwn, ICefFocusHandler)
  protected
    procedure OnTakeFocus(const browser: ICefBrowser; next: Boolean); virtual;
    function OnSetFocus(const browser: ICefBrowser; source: TCefFocusSource): Boolean; virtual;
    procedure OnGotFocus(const browser: ICefBrowser); virtual;
  public
    constructor Create; virtual;
  end;

  TCefKeyboardHandlerOwn = class(TCefBaseOwn, ICefKeyboardHandler)
  protected
    function OnPreKeyEvent(const browser: ICefBrowser; const event: PCefKeyEvent;
      osEvent: TCefEventHandle; out isKeyboardShortcut: Boolean): Boolean; virtual;
    function OnKeyEvent(const browser: ICefBrowser; const event: PCefKeyEvent;
      osEvent: TCefEventHandle): Boolean; virtual;
  public
    constructor Create; virtual;
  end;

  TCefJsDialogHandlerOwn = class(TCefBaseOwn, ICefJsDialogHandler)
  protected
    function OnJsdialog(const browser: ICefBrowser; const originUrl, acceptLang: ustring;
      dialogType: TCefJsDialogType; const messageText, defaultPromptText: ustring;
      callback: ICefJsDialogCallback; out suppressMessage: Boolean): Boolean; virtual;
    function OnBeforeUnloadDialog(const browser: ICefBrowser;
      const messageText: ustring; isReload: Boolean;
      const callback: ICefJsDialogCallback): Boolean; virtual;
    procedure OnResetDialogState(const browser: ICefBrowser); virtual;
    procedure OnDialogClosed(const browser: ICefBrowser); virtual;
  public
    constructor Create; virtual;
  end;

  TCefContextMenuHandlerOwn = class(TCefBaseOwn, ICefContextMenuHandler)
  protected
    procedure OnBeforeContextMenu(const browser: ICefBrowser; const frame: ICefFrame;
      const params: ICefContextMenuParams; const model: ICefMenuModel); virtual;
    function RunContextMenu(const browser: ICefBrowser; const frame: ICefFrame;
      const params: ICefContextMenuParams; const model: ICefMenuModel;
      const callback: ICefRunContextMenuCallback): Boolean; virtual;
    function OnContextMenuCommand(const browser: ICefBrowser; const frame: ICefFrame;
      const params: ICefContextMenuParams; commandId: Integer;
      eventFlags: TCefEventFlags): Boolean; virtual;
    procedure OnContextMenuDismissed(const browser: ICefBrowser; const frame: ICefFrame); virtual;
  public
    constructor Create; virtual;
  end;

  TCefDialogHandlerOwn = class(TCefBaseOwn, ICefDialogHandler)
  protected
    function OnFileDialog(const browser: ICefBrowser; mode: TCefFileDialogMode;
      const title, defaultFilePath: ustring; acceptFilters: TStrings;
      selectedAcceptFilter: Integer; const callback: ICefFileDialogCallback): Boolean; virtual;
  public
    constructor Create; virtual;
  end;

  TCefDownloadHandlerOwn = class(TCefBaseOwn, ICefDownloadHandler)
  protected
    procedure OnBeforeDownload(const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
      const suggestedName: ustring; const callback: ICefBeforeDownloadCallback); virtual;
    procedure OnDownloadUpdated(const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
        const callback: ICefDownloadItemCallback); virtual;
  public
    constructor Create; virtual;
  end;

  TCefCustomStreamReader = class(TCefBaseOwn, ICefCustomStreamReader)
  private
    FStream: TStream;
    FOwned: Boolean;
  protected
    function Read(ptr: Pointer; size, n: NativeUInt): NativeUInt; virtual;
    function Seek(offset: Int64; whence: Integer): Integer; virtual;
    function Tell: Int64; virtual;
    function Eof: Boolean; virtual;
    function MayBlock: Boolean; virtual;
  public
    constructor Create(Stream: TStream; Owned: Boolean); overload; virtual;
    constructor Create(const filename: string); overload; virtual;
    destructor Destroy; override;
  end;

  TCefPostDataElementOwn = class(TCefBaseOwn, ICefPostDataElement)
  private
    FDataType: TCefPostDataElementType;
    FValueByte: Pointer;
    FValueStr: TCefString;
    FSize: NativeUInt;
    FReadOnly: Boolean;
    procedure Clear;
  protected
    function IsReadOnly: Boolean; virtual;
    procedure SetToEmpty; virtual;
    procedure SetToFile(const fileName: ustring); virtual;
    procedure SetToBytes(size: NativeUInt; bytes: Pointer); virtual;
    function GetType: TCefPostDataElementType; virtual;
    function GetFile: ustring; virtual;
    function GetBytesCount: NativeUInt; virtual;
    function GetBytes(size: NativeUInt; bytes: Pointer): NativeUInt; virtual;
  public
    constructor Create(readonly: Boolean); virtual;
  end;

  TCefCallbackRef = class(TCefBaseRef, ICefCallback)
  protected
    procedure Cont;
    procedure Cancel;
  public
    class function UnWrap(data: Pointer): ICefCallback;
  end;

  TCefCompletionCallbackOwn = class(TCefBaseOwn, ICefCompletionCallback)
  protected
    procedure OnComplete; virtual;
  public
    constructor Create; virtual;
  end;

  TCefFastCompletionCallback = class(TCefCompletionCallbackOwn)
  private
    FProc: TCefCompletionCallbackProc;
  protected
    procedure OnComplete; override;
  public
    constructor Create(const proc: TCefCompletionCallbackProc); reintroduce;
  end;

  TCefResourceHandlerOwn = class(TCefBaseOwn, ICefResourceHandler)
  protected
    function ProcessRequest(const request: ICefRequest; const callback: ICefCallback): Boolean; virtual;
    procedure GetResponseHeaders(const response: ICefResponse;
      out responseLength: Int64; out redirectUrl: ustring); virtual;
    function ReadResponse(const dataOut: Pointer; bytesToRead: Integer;
      var bytesRead: Integer; const callback: ICefCallback): Boolean; virtual;
    function CanGetCookie(const cookie: PCefCookie): Boolean; virtual;
    function CanSetCookie(const cookie: PCefCookie): Boolean; virtual;
    procedure Cancel; virtual;
  public
    constructor Create(const browser: ICefBrowser; const frame: ICefFrame;
      const schemeName: ustring; const request: ICefRequest); virtual;
  end;
  TCefResourceHandlerClass = class of TCefResourceHandlerOwn;

  TCefSchemeHandlerFactoryOwn = class(TCefBaseOwn, ICefSchemeHandlerFactory)
  private
    FClass: TCefResourceHandlerClass;
  protected
    function New(const browser: ICefBrowser; const frame: ICefFrame;
      const schemeName: ustring; const request: ICefRequest): ICefResourceHandler; virtual;
  public
    constructor Create(const AClass: TCefResourceHandlerClass); virtual;
  end;

  TCefv8HandlerOwn = class(TCefBaseOwn, ICefv8Handler)
  protected
    function Execute(const name: ustring; const obj: ICefv8Value;
      const arguments: TCefv8ValueArray; var retval: ICefv8Value;
      var exception: ustring): Boolean; virtual;
  public
    constructor Create; virtual;
  end;

  TCefTaskOwn = class(TCefBaseOwn, ICefTask)
  protected
    procedure Execute; virtual;
  public
    constructor Create; virtual;
  end;

  TCefTaskRef = class(TCefBaseRef, ICefTask)
  protected
    procedure Execute; virtual;
  public
    class function UnWrap(data: Pointer): ICefTask;
  end;

  TCefTaskRunnerRef = class(TCefBaseRef, ICefTaskRunner)
  protected
    function IsSame(const that: ICefTaskRunner): Boolean;
    function BelongsToCurrentThread: Boolean;
    function BelongsToThread(threadId: TCefThreadId): Boolean;
    function PostTask(const task: ICefTask): Boolean; stdcall;
    function PostDelayedTask(const task: ICefTask; delayMs: Int64): Boolean;
  public
    class function UnWrap(data: Pointer): ICefTaskRunner;
    class function GetForCurrentThread: ICefTaskRunner;
    class function GetForThread(threadId: TCefThreadId): ICefTaskRunner;
  end;

  TCefStringMapOwn = class(TInterfacedObject, ICefStringMap)
  private
    FStringMap: TCefStringMap;
  protected
    function GetHandle: TCefStringMap; virtual;
    function GetSize: Integer; virtual;
    function Find(const key: ustring): ustring; virtual;
    function GetKey(index: Integer): ustring; virtual;
    function GetValue(index: Integer): ustring; virtual;
    procedure Append(const key, value: ustring); virtual;
    procedure Clear; virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
  end;

  TCefStringMultimapOwn = class(TInterfacedObject, ICefStringMultimap)
  private
    FStringMap: TCefStringMultimap;
  protected
    function GetHandle: TCefStringMultimap; virtual;
    function GetSize: Integer; virtual;
    function FindCount(const Key: ustring): Integer; virtual;
    function GetEnumerate(const Key: ustring; ValueIndex: Integer): ustring; virtual;
    function GetKey(Index: Integer): ustring; virtual;
    function GetValue(Index: Integer): ustring; virtual;
    procedure Append(const Key, Value: ustring); virtual;
    procedure Clear; virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
  end;

  TCefXmlReaderRef = class(TCefBaseRef, ICefXmlReader)
  protected
    function MoveToNextNode: Boolean;
    function Close: Boolean;
    function HasError: Boolean;
    function GetError: ustring;
    function GetType: TCefXmlNodeType;
    function GetDepth: Integer;
    function GetLocalName: ustring;
    function GetPrefix: ustring;
    function GetQualifiedName: ustring;
    function GetNamespaceUri: ustring;
    function GetBaseUri: ustring;
    function GetXmlLang: ustring;
    function IsEmptyElement: Boolean;
    function HasValue: Boolean;
    function GetValue: ustring;
    function HasAttributes: Boolean;
    function GetAttributeCount: NativeUInt;
    function GetAttributeByIndex(index: Integer): ustring;
    function GetAttributeByQName(const qualifiedName: ustring): ustring;
    function GetAttributeByLName(const localName, namespaceURI: ustring): ustring;
    function GetInnerXml: ustring;
    function GetOuterXml: ustring;
    function GetLineNumber: Integer;
    function MoveToAttributeByIndex(index: Integer): Boolean;
    function MoveToAttributeByQName(const qualifiedName: ustring): Boolean;
    function MoveToAttributeByLName(const localName, namespaceURI: ustring): Boolean;
    function MoveToFirstAttribute: Boolean;
    function MoveToNextAttribute: Boolean;
    function MoveToCarryingElement: Boolean;
  public
    class function UnWrap(data: Pointer): ICefXmlReader;
    class function New(const stream: ICefStreamReader;
      encodingType: TCefXmlEncodingType; const URI: ustring): ICefXmlReader;
  end;

  TCefZipReaderRef = class(TCefBaseRef, ICefZipReader)
  protected
    function MoveToFirstFile: Boolean;
    function MoveToNextFile: Boolean;
    function MoveToFile(const fileName: ustring; caseSensitive: Boolean): Boolean;
    function Close: Boolean;
    function GetFileName: ustring;
    function GetFileSize: Int64;
    function GetFileLastModified: TCefTime;
    function OpenFile(const password: ustring): Boolean;
    function CloseFile: Boolean;
    function ReadFile(buffer: Pointer; bufferSize: NativeUInt): Integer;
    function Tell: Int64;
    function Eof: Boolean;
  public
    class function UnWrap(data: Pointer): ICefZipReader;
    class function New(const stream: ICefStreamReader): ICefZipReader;
  end;

  TCefDomVisitorOwn = class(TCefBaseOwn, ICefDomVisitor)
  protected
    procedure visit(const document: ICefDomDocument); virtual;
  public
    constructor Create; virtual;
  end;

  TCefFastDomVisitor = class(TCefDomVisitorOwn)
  private
    FProc: TCefDomVisitorProc;
  protected
    procedure visit(const document: ICefDomDocument); override;
  public
    constructor Create(const proc: TCefDomVisitorProc); reintroduce; virtual;
  end;

  TCefDomDocumentRef = class(TCefBaseRef, ICefDomDocument)
  protected
    function GetType: TCefDomDocumentType;
    function GetDocument: ICefDomNode;
    function GetBody: ICefDomNode;
    function GetHead: ICefDomNode;
    function GetTitle: ustring;
    function GetElementById(const id: ustring): ICefDomNode;
    function GetFocusedNode: ICefDomNode;
    function HasSelection: Boolean;
    function GetSelectionStartOffset: Integer;
    function GetSelectionEndOffset: Integer;
    function GetSelectionAsMarkup: ustring;
    function GetSelectionAsText: ustring;
    function GetBaseUrl: ustring;
    function GetCompleteUrl(const partialURL: ustring): ustring;
  public
    class function UnWrap(data: Pointer): ICefDomDocument;
  end;

  TCefDomNodeRef = class(TCefBaseRef, ICefDomNode)
  protected
    function GetType: TCefDomNodeType;
    function IsText: Boolean;
    function IsElement: Boolean;
    function IsEditable: Boolean;
    function IsFormControlElement: Boolean;
    function GetFormControlElementType: ustring;
    function IsSame(const that: ICefDomNode): Boolean;
    function GetName: ustring;
    function GetValue: ustring;
    function SetValue(const value: ustring): Boolean;
    function GetAsMarkup: ustring;
    function GetDocument: ICefDomDocument;
    function GetParent: ICefDomNode;
    function GetPreviousSibling: ICefDomNode;
    function GetNextSibling: ICefDomNode;
    function HasChildren: Boolean;
    function GetFirstChild: ICefDomNode;
    function GetLastChild: ICefDomNode;
    function GetElementTagName: ustring;
    function HasElementAttributes: Boolean;
    function HasElementAttribute(const attrName: ustring): Boolean;
    function GetElementAttribute(const attrName: ustring): ustring;
    procedure GetElementAttributes(const attrMap: ICefStringMap);
    function SetElementAttribute(const attrName, value: ustring): Boolean;
    function GetElementInnerText: ustring;
  public
    class function UnWrap(data: Pointer): ICefDomNode;
  end;

  TCefResponseRef = class(TCefBaseRef, ICefResponse)
  protected
    function IsReadOnly: Boolean;
    function GetStatus: Integer;
    procedure SetStatus(status: Integer);
    function GetStatusText: ustring;
    procedure SetStatusText(const StatusText: ustring);
    function GetMimeType: ustring;
    procedure SetMimeType(const mimetype: ustring);
    function GetHeader(const name: ustring): ustring;
    procedure GetHeaderMap(const headerMap: ICefStringMultimap);
    procedure SetHeaderMap(const headerMap: ICefStringMultimap);
  public
    class function UnWrap(data: Pointer): ICefResponse;
    class function New: ICefResponse;
  end;

  TCefFastTaskProc = {$IFDEF DELPHI12_UP}reference to{$ENDIF} procedure;

  TCefFastTask = class(TCefTaskOwn)
  private
    FMethod: TCefFastTaskProc;
  protected
    procedure Execute; override;
  public
    class procedure New(threadId: TCefThreadId; const method: TCefFastTaskProc);
    class procedure NewDelayed(threadId: TCefThreadId; Delay: Int64; const method: TCefFastTaskProc);
    constructor Create(const method: TCefFastTaskProc); reintroduce;
  end;

{$IFDEF DELPHI14_UP}
  TCefRTTIExtension = class(TCefv8HandlerOwn)
  private
    FValue: TValue;
    FCtx: TRttiContext;
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
    FSyncMainThread: Boolean;
{$ENDIF}
    function GetValue(pi: PTypeInfo; const v: ICefv8Value; var ret: TValue): Boolean;
    function SetValue(const v: TValue; var ret: ICefv8Value): Boolean;
{$IFDEF CPUX64}
    class function StrToPtr(const str: ustring): Pointer;
    class function PtrToStr(p: Pointer): ustring;
{$ENDIF}
  protected
    function Execute(const name: ustring; const obj: ICefv8Value;
      const arguments: TCefv8ValueArray; var retval: ICefv8Value;
      var exception: ustring): Boolean; override;
  public
    constructor Create(const value: TValue
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
    ; SyncMainThread: Boolean
{$ENDIF}
); reintroduce;
    destructor Destroy; override;
    class procedure Register(const name: string; const value: TValue
      {$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}; SyncMainThread: Boolean{$ENDIF});
  end;
{$ENDIF}

  TCefV8AccessorOwn = class(TCefBaseOwn, ICefV8Accessor)
  protected
    function Get(const name: ustring; const obj: ICefv8Value;
      out value: ICefv8Value; const exception: ustring): Boolean; virtual;
    function Put(const name: ustring; const obj, value: ICefv8Value;
      const exception: ustring): Boolean; virtual;
  public
    constructor Create; virtual;
  end;

  TCefFastV8Accessor = class(TCefV8AccessorOwn)
  private
    FGetter: TCefV8AccessorGetterProc;
    FSetter: TCefV8AccessorSetterProc;
  protected
    function Get(const name: ustring; const obj: ICefv8Value;
      out value: ICefv8Value; const exception: ustring): Boolean; override;
    function Put(const name: ustring; const obj, value: ICefv8Value;
      const exception: ustring): Boolean; override;
  public
    constructor Create(const getter: TCefV8AccessorGetterProc;
      const setter: TCefV8AccessorSetterProc); reintroduce;
  end;

  TCefCookieVisitorOwn = class(TCefBaseOwn, ICefCookieVisitor)
  protected
    function visit(const name, value, domain, path: ustring; secure, httponly,
      hasExpires: Boolean; const creation, lastAccess, expires: TDateTime;
      count, total: Integer; out deleteCookie: Boolean): Boolean; virtual;
  public
    constructor Create; virtual;
  end;

  TCefFastCookieVisitor = class(TCefCookieVisitorOwn)
  private
    FVisitor: TCefCookieVisitorProc;
  protected
    function visit(const name, value, domain, path: ustring; secure, httponly,
      hasExpires: Boolean; const creation, lastAccess, expires: TDateTime;
      count, total: Integer; out deleteCookie: Boolean): Boolean; override;
  public
    constructor Create(const visitor: TCefCookieVisitorProc); reintroduce;
  end;

  TCefV8ExceptionRef = class(TCefBaseRef, ICefV8Exception)
  protected
    function GetMessage: ustring;
    function GetSourceLine: ustring;
    function GetScriptResourceName: ustring;
    function GetLineNumber: Integer;
    function GetStartPosition: Integer;
    function GetEndPosition: Integer;
    function GetStartColumn: Integer;
    function GetEndColumn: Integer;
  public
    class function UnWrap(data: Pointer): ICefV8Exception;
  end;

  TCefResourceBundleHandlerOwn = class(TCefBaseOwn, ICefResourceBundleHandler)
  protected
    function GetDataResource(stringId: Integer; out data: Pointer;
      out dataSize: NativeUInt): Boolean; virtual; abstract;
    function GetLocalizedString(messageId: Integer;
      out stringVal: ustring): Boolean; virtual; abstract;
    function GetDataResourceForScale(resourceId: Integer;
      scaleFactor: TCefScaleFactor; out data: Pointer;
      dataSize: NativeUInt): Boolean; virtual; abstract;
  public
    constructor Create; virtual;
  end;

 TGetDataResource = {$IFDEF DELPHI12_UP}reference to{$ENDIF}function(
   resourceId: Integer; out data: Pointer; out dataSize: NativeUInt): Boolean;

 TGetLocalizedString = {$IFDEF DELPHI12_UP}reference to{$ENDIF}function(
   stringId: Integer; out stringVal: ustring): Boolean;

 TGetDataResourceForScale = {$IFDEF DELPHI12_UP}reference to{$ENDIF}function(
   resourceId: Integer; scaleFactor: TCefScaleFactor; out data: Pointer;
   out dataSize: NativeUInt): Boolean;

  TCefFastResourceBundle = class(TCefResourceBundleHandlerOwn)
  private
    FGetDataResource: TGetDataResource;
    FGetLocalizedString: TGetLocalizedString;
    FGetDataResourceForScale: TGetDataResourceForScale;
  protected
    function GetDataResource(resourceId: Integer; out data: Pointer;
      out dataSize: NativeUInt): Boolean; override;
    function GetLocalizedString(stringId: Integer;
      out stringVal: ustring): Boolean; override;
    function GetDataResourceForScale(resourceId: Integer;
      scaleFactor: TCefScaleFactor; out data: Pointer;
      dataSize: NativeUInt): Boolean; override;
  public
    constructor Create(
      AGetDataResource: TGetDataResource;
      AGetLocalizedString: TGetLocalizedString;
      AGetDataResourceForScale: TGetDataResourceForScale); reintroduce;
  end;

  TCefAppOwn = class(TCefBaseOwn, ICefApp)
  protected
    procedure OnBeforeCommandLineProcessing(const processType: ustring;
      const commandLine: ICefCommandLine); virtual; abstract;
    procedure OnRegisterCustomSchemes(const registrar: ICefSchemeRegistrar); virtual; abstract;
    function GetResourceBundleHandler: ICefResourceBundleHandler; virtual; abstract;
    function GetBrowserProcessHandler: ICefBrowserProcessHandler; virtual; abstract;
    function GetRenderProcessHandler: ICefRenderProcessHandler; virtual; abstract;
  public
    constructor Create; virtual;
  end;

  TCefSetCookieCallbackOwn = class(TCefBaseOwn, ICefSetCookieCallback)
  protected
    procedure OnComplete(success: Boolean); virtual; abstract;
  public
    constructor Create; virtual;
  end;

  TCefFastSetCookieCallback = class(TCefSetCookieCallbackOwn)
  private
    FCallback: TCefSetCookieCallbackProc;
  protected
    procedure OnComplete(success: Boolean); override;
  public
    constructor Create(const callback: TCefSetCookieCallbackProc); reintroduce;
  end;

  TCefDeleteCookiesCallbackOwn = class(TCefBaseOwn, ICefDeleteCookiesCallback)
  protected
    procedure OnComplete(numDeleted: Integer); virtual; abstract;
  public
    constructor Create; virtual;
  end;

  TCefFastDeleteCookiesCallback = class(TCefDeleteCookiesCallbackOwn)
  private
    FCallback: TCefDeleteCookiesCallbackProc;
  protected
    procedure OnComplete(numDeleted: Integer); override;
  public
    constructor Create(const callback: TCefDeleteCookiesCallbackProc); reintroduce;
  end;

  TCefCookieManagerRef = class(TCefBaseRef, ICefCookieManager)
  protected
    procedure SetSupportedSchemes(schemes: TStrings; const callback: ICefCompletionCallback);
    procedure SetSupportedSchemesProc(schemes: TStrings; const callback: TCefCompletionCallbackProc);
    function VisitAllCookies(const visitor: ICefCookieVisitor): Boolean;
    function VisitAllCookiesProc(const visitor: TCefCookieVisitorProc): Boolean;
    function VisitUrlCookies(const url: ustring;
      includeHttpOnly: Boolean; const visitor: ICefCookieVisitor): Boolean;
    function VisitUrlCookiesProc(const url: ustring;
      includeHttpOnly: Boolean; const visitor: TCefCookieVisitorProc): Boolean;
    function SetCookie(const url: ustring; const name, value, domain, path: ustring; secure, httponly,
      hasExpires: Boolean; const creation, lastAccess, expires: TDateTime;
      const callback: ICefSetCookieCallback): Boolean;
    function SetCookieProc(const url: ustring; const name, value, domain, path: ustring; secure, httponly,
      hasExpires: Boolean; const creation, lastAccess, expires: TDateTime;
      const callback: TCefSetCookieCallbackProc): Boolean;
    function DeleteCookies(const url, cookieName: ustring; const callback: ICefDeleteCookiesCallback): Boolean;
    function DeleteCookiesProc(const url, cookieName: ustring; const callback: TCefDeleteCookiesCallbackProc): Boolean;
    function SetStoragePath(const path: ustring; persistSessionCookies: Boolean; const callback: ICefCompletionCallback): Boolean;
    function SetStoragePathProc(const path: ustring; persistSessionCookies: Boolean; const callback: TCefCompletionCallbackProc): Boolean;
    function FlushStore(const handler: ICefCompletionCallback): Boolean;
    function FlushStoreProc(const proc: TCefCompletionCallbackProc): Boolean;
  public
    class function UnWrap(data: Pointer): ICefCookieManager;
    class function Global(const callback: ICefCompletionCallback): ICefCookieManager;
    class function GlobalProc(const callback: TCefCompletionCallbackProc): ICefCookieManager;
    class function New(const path: ustring; persistSessionCookies: Boolean;
      const callback: ICefCompletionCallback): ICefCookieManager;
    class function NewProc(const path: ustring; persistSessionCookies: Boolean;
      const callback: TCefCompletionCallbackProc): ICefCookieManager;
  end;

  TCefWebPluginInfoRef = class(TCefBaseRef, ICefWebPluginInfo)
  protected
    function GetName: ustring;
    function GetPath: ustring;
    function GetVersion: ustring;
    function GetDescription: ustring;
  public
    class function UnWrap(data: Pointer): ICefWebPluginInfo;
  end;

  TCefProcessMessageRef = class(TCefBaseRef, ICefProcessMessage)
  protected
    function IsValid: Boolean;
    function IsReadOnly: Boolean;
    function Copy: ICefProcessMessage;
    function GetName: ustring;
    function GetArgumentList: ICefListValue;
  public
    class function UnWrap(data: Pointer): ICefProcessMessage;
    class function New(const name: ustring): ICefProcessMessage;
  end;

  TCefStringVisitorOwn = class(TCefBaseOwn, ICefStringVisitor)
  protected
    procedure Visit(const str: ustring); virtual;
  public
    constructor Create; virtual;
  end;

  TCefFastStringVisitor = class(TCefStringVisitorOwn, ICefStringVisitor)
  private
    FVisit: TCefStringVisitorProc;
  protected
    procedure Visit(const str: ustring); override;
  public
    constructor Create(const callback: TCefStringVisitorProc); reintroduce;
  end;

  TCefDownLoadItemRef = class(TCefBaseRef, ICefDownLoadItem)
  protected
    function IsValid: Boolean;
    function IsInProgress: Boolean;
    function IsComplete: Boolean;
    function IsCanceled: Boolean;
    function GetCurrentSpeed: Int64;
    function GetPercentComplete: Integer;
    function GetTotalBytes: Int64;
    function GetReceivedBytes: Int64;
    function GetStartTime: TDateTime;
    function GetEndTime: TDateTime;
    function GetFullPath: ustring;
    function GetId: Cardinal;
    function GetUrl: ustring;
    function GetOriginalUrl: ustring;
    function GetSuggestedFileName: ustring;
    function GetContentDisposition: ustring;
    function GetMimeType: ustring;
  public
    class function UnWrap(data: Pointer): ICefDownLoadItem;
  end;

  TCefBeforeDownloadCallbackRef = class(TCefBaseRef, ICefBeforeDownloadCallback)
  protected
    procedure Cont(const downloadPath: ustring; showDialog: Boolean);
  public
     class function UnWrap(data: Pointer): ICefBeforeDownloadCallback;
  end;

  TCefDownloadItemCallbackRef = class(TCefBaseRef, ICefDownloadItemCallback)
  protected
    procedure Cancel;
    procedure Pause;
    procedure Resume;
  public
    class function UnWrap(data: Pointer): ICefDownloadItemCallback;
  end;

  TCefAuthCallbackRef = class(TCefBaseRef, ICefAuthCallback)
  protected
    procedure Cont(const username, password: ustring);
    procedure Cancel;
  public
     class function UnWrap(data: Pointer): ICefAuthCallback;
  end;

  TCefJsDialogCallbackRef = class(TCefBaseRef, ICefJsDialogCallback)
  protected
    procedure Cont(success: Boolean; const userInput: ustring);
  public
    class function UnWrap(data: Pointer): ICefJsDialogCallback;
  end;

  TCefCommandLineRef = class(TCefBaseRef, ICefCommandLine)
  protected
    function IsValid: Boolean;
    function IsReadOnly: Boolean;
    function Copy: ICefCommandLine;
    procedure InitFromArgv(argc: Integer; const argv: PPAnsiChar);
    procedure InitFromString(const commandLine: ustring);
    procedure Reset;
    function GetCommandLineString: ustring;
    procedure GetArgv(args: TStrings);
    function GetProgram: ustring;
    procedure SetProgram(const prog: ustring);
    function HasSwitches: Boolean;
    function HasSwitch(const name: ustring): Boolean;
    function GetSwitchValue(const name: ustring): ustring;
    procedure GetSwitches(switches: TStrings);
    procedure AppendSwitch(const name: ustring);
    procedure AppendSwitchWithValue(const name, value: ustring);
    function HasArguments: Boolean;
    procedure GetArguments(arguments: TStrings);
    procedure AppendArgument(const argument: ustring);
    procedure PrependWrapper(const wrapper: ustring);
  public
    class function UnWrap(data: Pointer): ICefCommandLine;
    class function New: ICefCommandLine;
    class function Global: ICefCommandLine;
  end;

  TCefSchemeRegistrarRef = class(TCefBaseRef, ICefSchemeRegistrar)
  protected
    function AddCustomScheme(const schemeName: ustring; IsStandard, IsLocal,
      IsDisplayIsolated: Boolean): Boolean; stdcall;
  public
    class function UnWrap(data: Pointer): ICefSchemeRegistrar;
  end;

  TCefGeolocationCallbackRef = class(TCefBaseRef, ICefGeolocationCallback)
  protected
    procedure Cont(allow: Boolean);
  public
    class function UnWrap(data: Pointer): ICefGeolocationCallback;
  end;

  TCefContextMenuParamsRef = class(TCefBaseRef, ICefContextMenuParams)
  protected
    function GetXCoord: Integer;
    function GetYCoord: Integer;
    function GetTypeFlags: TCefContextMenuTypeFlags;
    function GetLinkUrl: ustring;
    function GetUnfilteredLinkUrl: ustring;
    function GetSourceUrl: ustring;
    function HasImageContents: Boolean;
    function GetPageUrl: ustring;
    function GetFrameUrl: ustring;
    function GetFrameCharset: ustring;
    function GetMediaType: TCefContextMenuMediaType;
    function GetMediaStateFlags: TCefContextMenuMediaStateFlags;
    function GetSelectionText: ustring;
    function GetMisspelledWord: ustring;
    function GetDictionarySuggestions(const suggestions: TStringList): Boolean;
    function IsEditable: Boolean;
    function IsSpellCheckEnabled: Boolean;
    function GetEditStateFlags: TCefContextMenuEditStateFlags;
    function IsCustomMenu: Boolean;
    function IsPepperMenu: Boolean;
  public
    class function UnWrap(data: Pointer): ICefContextMenuParams;
  end;

  TCefMenuModelRef = class(TCefBaseRef, ICefMenuModel)
  protected
    function Clear: Boolean;
    function GetCount: Integer;
    function AddSeparator: Boolean;
    function AddItem(commandId: Integer; const text: ustring): Boolean;
    function AddCheckItem(commandId: Integer; const text: ustring): Boolean;
    function AddRadioItem(commandId: Integer; const text: ustring; groupId: Integer): Boolean;
    function AddSubMenu(commandId: Integer; const text: ustring): ICefMenuModel;
    function InsertSeparatorAt(index: Integer): Boolean;
    function InsertItemAt(index, commandId: Integer; const text: ustring): Boolean;
    function InsertCheckItemAt(index, commandId: Integer; const text: ustring): Boolean;
    function InsertRadioItemAt(index, commandId: Integer; const text: ustring; groupId: Integer): Boolean;
    function InsertSubMenuAt(index, commandId: Integer; const text: ustring): ICefMenuModel;
    function Remove(commandId: Integer): Boolean;
    function RemoveAt(index: Integer): Boolean;
    function GetIndexOf(commandId: Integer): Integer;
    function GetCommandIdAt(index: Integer): Integer;
    function SetCommandIdAt(index, commandId: Integer): Boolean;
    function GetLabel(commandId: Integer): ustring;
    function GetLabelAt(index: Integer): ustring;
    function SetLabel(commandId: Integer; const text: ustring): Boolean;
    function SetLabelAt(index: Integer; const text: ustring): Boolean;
    function GetType(commandId: Integer): TCefMenuItemType;
    function GetTypeAt(index: Integer): TCefMenuItemType;
    function GetGroupId(commandId: Integer): Integer;
    function GetGroupIdAt(index: Integer): Integer;
    function SetGroupId(commandId, groupId: Integer): Boolean;
    function SetGroupIdAt(index, groupId: Integer): Boolean;
    function GetSubMenu(commandId: Integer): ICefMenuModel;
    function GetSubMenuAt(index: Integer): ICefMenuModel;
    function IsVisible(commandId: Integer): Boolean;
    function isVisibleAt(index: Integer): Boolean;
    function SetVisible(commandId: Integer; visible: Boolean): Boolean;
    function SetVisibleAt(index: Integer; visible: Boolean): Boolean;
    function IsEnabled(commandId: Integer): Boolean;
    function IsEnabledAt(index: Integer): Boolean;
    function SetEnabled(commandId: Integer; enabled: Boolean): Boolean;
    function SetEnabledAt(index: Integer; enabled: Boolean): Boolean;
    function IsChecked(commandId: Integer): Boolean;
    function IsCheckedAt(index: Integer): Boolean;
    function setChecked(commandId: Integer; checked: Boolean): Boolean;
    function setCheckedAt(index: Integer; checked: Boolean): Boolean;
    function HasAccelerator(commandId: Integer): Boolean;
    function HasAcceleratorAt(index: Integer): Boolean;
    function SetAccelerator(commandId, keyCode: Integer; shiftPressed, ctrlPressed, altPressed: Boolean): Boolean;
    function SetAcceleratorAt(index, keyCode: Integer; shiftPressed, ctrlPressed, altPressed: Boolean): Boolean;
    function RemoveAccelerator(commandId: Integer): Boolean;
    function RemoveAcceleratorAt(index: Integer): Boolean;
    function GetAccelerator(commandId: Integer; out keyCode: Integer; out shiftPressed, ctrlPressed, altPressed: Boolean): Boolean;
    function GetAcceleratorAt(index: Integer; out keyCode: Integer; out shiftPressed, ctrlPressed, altPressed: Boolean): Boolean;
  public
    class function UnWrap(data: Pointer): ICefMenuModel;
  end;

  TCefListValueRef = class(TCefBaseRef, ICefListValue)
  protected
    function IsValid: Boolean;
    function IsOwned: Boolean;
    function IsReadOnly: Boolean;
    function IsSame(const that: ICefListValue): Boolean;
    function IsEqual(const that: ICefListValue): Boolean;
    function Copy: ICefListValue;
    function SetSize(size: NativeUInt): Boolean;
    function GetSize: NativeUInt;
    function Clear: Boolean;
    function Remove(index: Integer): Boolean;
    function GetType(index: Integer): TCefValueType;
    function GetValue(index: Integer): ICefValue;
    function GetBool(index: Integer): Boolean;
    function GetInt(index: Integer): Integer;
    function GetDouble(index: Integer): Double;
    function GetString(index: Integer): ustring;
    function GetBinary(index: Integer): ICefBinaryValue;
    function GetDictionary(index: Integer): ICefDictionaryValue;
    function GetList(index: Integer): ICefListValue;
    function SetValue(index: Integer; const value: ICefValue): Boolean;
    function SetNull(index: Integer): Boolean;
    function SetBool(index: Integer; value: Boolean): Boolean;
    function SetInt(index, value: Integer): Boolean;
    function SetDouble(index: Integer; value: Double): Boolean;
    function SetString(index: Integer; const value: ustring): Boolean;
    function SetBinary(index: Integer; const value: ICefBinaryValue): Boolean;
    function SetDictionary(index: Integer; const value: ICefDictionaryValue): Boolean;
    function SetList(index: Integer; const value: ICefListValue): Boolean;
  public
    class function UnWrap(data: Pointer): ICefListValue;
    class function New: ICefListValue;
  end;

  TCefValueRef = class(TCefBaseRef, ICefValue)
  protected
    function IsValid: Boolean;
    function IsOwned: Boolean;
    function IsReadOnly: Boolean;
    function IsSame(const that: ICefValue): Boolean;
    function IsEqual(const that: ICefValue): Boolean;
    function Copy: ICefValue;
    function GetType: TCefValueType;
    function GetBool: Boolean;
    function GetInt: Integer;
    function GetDouble: Double;
    function GetString: ustring;
    function GetBinary: ICefBinaryValue;
    function GetDictionary: ICefDictionaryValue;
    function GetList: ICefListValue;
    function SetNull: Boolean;
    function SetBool(value: Integer): Boolean;
    function SetInt(value: Integer): Boolean;
    function SetDouble(value: Double): Boolean;
    function SetString(const value: ustring): Boolean;
    function SetBinary(const value: ICefBinaryValue): Boolean;
    function SetDictionary(const value: ICefDictionaryValue): Boolean;
    function SetList(const value: ICefListValue): Boolean;
  public
    class function UnWrap(data: Pointer): ICefValue;
    class function New: ICefValue;
  end;

  TCefBinaryValueRef = class(TCefBaseRef, ICefBinaryValue)
  protected
    function IsValid: Boolean;
    function IsOwned: Boolean;
    function IsSame(const that: ICefBinaryValue): Boolean;
    function IsEqual(const that: ICefBinaryValue): Boolean;
    function Copy: ICefBinaryValue;
    function GetSize: NativeUInt;
    function GetData(buffer: Pointer; bufferSize, dataOffset: NativeUInt): NativeUInt;
  public
    class function UnWrap(data: Pointer): ICefBinaryValue;
    class function New(const data: Pointer; dataSize: NativeUInt): ICefBinaryValue;
  end;

  TCefDictionaryValueRef = class(TCefBaseRef, ICefDictionaryValue)
  protected
    function IsValid: Boolean;
    function isOwned: Boolean;
    function IsReadOnly: Boolean;
    function IsSame(const that: ICefDictionaryValue): Boolean;
    function IsEqual(const that: ICefDictionaryValue): Boolean;
    function Copy(excludeEmptyChildren: Boolean): ICefDictionaryValue;
    function GetSize: NativeUInt;
    function Clear: Boolean;
    function HasKey(const key: ustring): Boolean;
    function GetKeys(const keys: TStrings): Boolean;
    function Remove(const key: ustring): Boolean;
    function GetType(const key: ustring): TCefValueType;
    function GetValue(const key: ustring): ICefValue;
    function GetBool(const key: ustring): Boolean;
    function GetInt(const key: ustring): Integer;
    function GetDouble(const key: ustring): Double;
    function GetString(const key: ustring): ustring;
    function GetBinary(const key: ustring): ICefBinaryValue;
    function GetDictionary(const key: ustring): ICefDictionaryValue;
    function GetList(const key: ustring): ICefListValue;
    function SetValue(const key: ustring; const value: ICefValue): Boolean;
    function SetNull(const key: ustring): Boolean;
    function SetBool(const key: ustring; value: Boolean): Boolean;
    function SetInt(const key: ustring; value: Integer): Boolean;
    function SetDouble(const key: ustring; value: Double): Boolean;
    function SetString(const key, value: ustring): Boolean;
    function SetBinary(const key: ustring; const value: ICefBinaryValue): Boolean;
    function SetDictionary(const key: ustring; const value: ICefDictionaryValue): Boolean;
    function SetList(const key: ustring; const value: ICefListValue): Boolean;
  public
    class function UnWrap(data: Pointer): ICefDictionaryValue;
    class function New: ICefDictionaryValue;
  end;

  TCefBrowserProcessHandlerOwn = class(TCefBaseOwn, ICefBrowserProcessHandler)
  protected
    procedure OnContextInitialized; virtual;
    procedure OnBeforeChildProcessLaunch(const commandLine: ICefCommandLine); virtual;
    procedure OnRenderProcessThreadCreated(const extraInfo: ICefListValue); virtual;
  public
    constructor Create; virtual;
  end;


  TCefRenderProcessHandlerOwn = class(TCefBaseOwn, ICefRenderProcessHandler)
  protected
    procedure OnRenderThreadCreated(const extraInfo: ICefListValue); virtual;
    procedure OnWebKitInitialized; virtual;
    procedure OnBrowserCreated(const browser: ICefBrowser); virtual;
    procedure OnBrowserDestroyed(const browser: ICefBrowser); virtual;
    function GetLoadHandler: PCefLoadHandler; virtual;
    function OnBeforeNavigation(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; navigationType: TCefNavigationType;
      isRedirect: Boolean): Boolean; virtual;
    procedure OnContextCreated(const browser: ICefBrowser;
      const frame: ICefFrame; const context: ICefv8Context); virtual;
    procedure OnContextReleased(const browser: ICefBrowser;
      const frame: ICefFrame; const context: ICefv8Context); virtual;
    procedure OnUncaughtException(const browser: ICefBrowser; const frame: ICefFrame;
      const context: ICefv8Context; const exception: ICefV8Exception;
      const stackTrace: ICefV8StackTrace); virtual;
    procedure OnFocusedNodeChanged(const browser: ICefBrowser;
      const frame: ICefFrame; const node: ICefDomNode); virtual;
    function OnProcessMessageReceived(const browser: ICefBrowser;
      sourceProcess: TCefProcessId; const message: ICefProcessMessage): Boolean; virtual;
  public
    constructor Create; virtual;
  end;


  TCefUrlrequestClientOwn = class(TCefBaseOwn, ICefUrlrequestClient)
  protected
    procedure OnRequestComplete(const request: ICefUrlRequest); virtual;
    procedure OnUploadProgress(const request: ICefUrlRequest; current, total: Int64); virtual;
    procedure OnDownloadProgress(const request: ICefUrlRequest; current, total: Int64); virtual;
    procedure OnDownloadData(const request: ICefUrlRequest; data: Pointer; dataLength: NativeUInt); virtual;
    function OnGetAuthCredentials(isProxy: Boolean; const host: ustring; port: Integer;
      const realm, scheme: ustring; const callback: ICefAuthCallback): Boolean;
  public
    constructor Create; virtual;
  end;

  TCefUrlRequestRef = class(TCefBaseRef, ICefUrlRequest)
  protected
    function GetRequest: ICefRequest;
    function GetRequestStatus: TCefUrlRequestStatus;
    function GetRequestError: Integer;
    function GetResponse: ICefResponse;
    procedure Cancel;
  public
    class function UnWrap(data: Pointer): ICefUrlRequest;
    class function New(const request: ICefRequest; const client: ICefUrlRequestClient;
      const requestContext: ICefRequestContext): ICefUrlRequest;
  end;

  TCefWebPluginInfoVisitorOwn = class(TCefBaseOwn, ICefWebPluginInfoVisitor)
  protected
    function Visit(const info: ICefWebPluginInfo; count, total: Integer): Boolean; virtual;
  public
    constructor Create; virtual;
  end;

  TCefWebPluginInfoVisitorProc = {$IFDEF DELPHI12_UP}reference to{$ENDIF} function(const info: ICefWebPluginInfo; count, total: Integer): Boolean;
  TCefWebPluginIsUnstableProc = {$IFDEF DELPHI12_UP}reference to{$ENDIF}procedure(const path: ustring; unstable: Boolean);

  TCefFastWebPluginInfoVisitor = class(TCefWebPluginInfoVisitorOwn)
  private
    FProc: TCefWebPluginInfoVisitorProc;
  protected
    function Visit(const info: ICefWebPluginInfo; count, total: Integer): Boolean; override;
  public
    constructor Create(const proc: TCefWebPluginInfoVisitorProc); reintroduce;
  end;

  TCefWebPluginUnstableCallbackOwn = class(TCefBaseOwn, ICefWebPluginUnstableCallback)
  protected
    procedure IsUnstable(const path: ustring; unstable: Boolean); virtual;
  public
    constructor Create; virtual;
  end;

  TCefFastWebPluginUnstableCallback = class(TCefWebPluginUnstableCallbackOwn)
  private
    FCallback: TCefWebPluginIsUnstableProc;
  protected
    procedure IsUnstable(const path: ustring; unstable: Boolean); override;
  public
    constructor Create(const callback: TCefWebPluginIsUnstableProc); reintroduce;
  end;

  TCefEndTracingCallbackOwn = class(TCefBaseOwn, ICefEndTracingCallback)
  protected
    procedure OnEndTracingComplete(const tracingFile: ustring); virtual;
  public
    constructor Create; virtual;
  end;

  TCefGetGeolocationCallbackOwn = class(TCefBaseOwn, ICefGetGeolocationCallback)
  protected
    procedure OnLocationUpdate(const position: PCefGeoposition); virtual;
  public
    constructor Create; virtual;
  end;

  TOnLocationUpdate = {$IFDEF DELPHI12_UP}reference to{$ENDIF} procedure(const position: PCefGeoposition);

  TCefFastGetGeolocationCallback = class(TCefGetGeolocationCallbackOwn)
  private
    FCallback: TOnLocationUpdate;
  protected
    procedure OnLocationUpdate(const position: PCefGeoposition); override;
  public
    constructor Create(const callback: TOnLocationUpdate); reintroduce;
  end;

  TCefFileDialogCallbackRef = class(TCefBaseRef, ICefFileDialogCallback)
  protected
    procedure Cont(selectedAcceptFilter: Integer; filePaths: TStrings);
    procedure Cancel;
  public
    class function UnWrap(data: Pointer): ICefFileDialogCallback;
  end;

  TCefRenderHandlerOwn = class(TCefBaseOwn, ICefRenderHandler)
  protected
    function GetRootScreenRect(const browser: ICefBrowser; rect: PCefRect): Boolean; virtual;
    function GetViewRect(const browser: ICefBrowser; rect: PCefRect): Boolean; virtual;
    function GetScreenPoint(const browser: ICefBrowser; viewX, viewY: Integer;
      screenX, screenY: PInteger): Boolean; virtual;
    function GetScreenInfo(const browser: ICefBrowser; screenInfo: PCefScreenInfo): Boolean; virtual;
    procedure OnPopupShow(const browser: ICefBrowser; show: Boolean); virtual;
    procedure OnPopupSize(const browser: ICefBrowser; const rect: PCefRect); virtual;
    procedure OnPaint(const browser: ICefBrowser; kind: TCefPaintElementType;
      dirtyRectsCount: NativeUInt; const dirtyRects: PCefRectArray;
      const buffer: Pointer; width, height: Integer); virtual;
    procedure OnCursorChange(const browser: ICefBrowser; cursor: TCefCursorHandle;
      CursorType: TCefCursorType; const customCursorInfo: PCefCursorInfo); virtual;
    function OnStartDragging(const browser: ICefBrowser; const dragData: ICefDragData;
      allowedOps: TCefDragOperations; x, y: Integer): Boolean; virtual;
    procedure OnUpdateDragCursor(const browser: ICefBrowser;
      operation: TCefDragOperation); virtual;
    procedure OnScrollOffsetChanged(const browser: ICefBrowser; x, y: Double); virtual;
  public
    constructor Create; virtual;
  end;

  TCefDragDataRef = class(TCefBaseRef, ICefDragData)
  protected
    function Clone: ICefDragData;
    function IsReadOnly: Boolean;
    function IsLink: Boolean;
    function IsFragment: Boolean;
    function IsFile: Boolean;
    function GetLinkUrl: ustring;
    function GetLinkTitle: ustring;
    function GetLinkMetadata: ustring;
    function GetFragmentText: ustring;
    function GetFragmentHtml: ustring;
    function GetFragmentBaseUrl: ustring;
    function GetFileName: ustring;
    function GetFileContents(const writer: ICefStreamWriter): NativeUInt;
    function GetFileNames(names: TStrings): Integer;
    procedure SetLinkUrl(const url: ustring);
    procedure SetLinkTitle(const title: ustring);
    procedure SetLinkMetadata(const data: ustring);
    procedure SetFragmentText(const text: ustring);
    procedure SetFragmentHtml(const html: ustring);
    procedure SetFragmentBaseUrl(const baseUrl: ustring);
    procedure ResetFileContents;
    procedure AddFile(const path, displayName: ustring);
  public
    class function UnWrap(data: Pointer): ICefDragData;
    class function New: ICefDragData;
  end;

  TCefDragHandlerOwn = class(TCefBaseOwn, ICefDragHandler)
  protected
    function OnDragEnter(const browser: ICefBrowser; const dragData: ICefDragData;
      mask: TCefDragOperations): Boolean; virtual;
    procedure OnDraggableRegionsChanged(const browser: ICefBrowser;
      regionsCount: NativeUInt; regions: PCefDraggableRegionArray); virtual;
  public
    constructor Create; virtual;
  end;

  TCefFindHandlerOwn = class(TCefBaseOwn, ICefFindHandler)
  protected
    procedure OnFindResult(const browser: ICefBrowser;
      identifier, count: Integer; const selectionRect: PCefRect;
      activeMatchOrdinal: Integer; finalUpdate: Boolean); virtual; abstract;
  public
    constructor Create; virtual;
  end;

  TCefRequestContextRef = class(TCefBaseRef, ICefRequestContext)
  protected
    function IsSame(const other: ICefRequestContext): Boolean;
    function IsSharingWith(const other: ICefRequestContext): Boolean;
    function IsGlobal: Boolean;
    function GetHandler: ICefRequestContextHandler;
    function GetCachePath: ustring;
    function GetDefaultCookieManager(const callback: ICefCompletionCallback): ICefCookieManager;
    function GetDefaultCookieManagerProc(const callback: TCefCompletionCallbackProc): ICefCookieManager;
    function RegisterSchemeHandlerFactory(const schemeName, domainName: ustring;
        const factory: ICefSchemeHandlerFactory): Boolean;
    function ClearSchemeHandlerFactories: Boolean;
    procedure PurgePluginListCache(reloadPages: Boolean);
  public
    class function UnWrap(data: Pointer): ICefRequestContext;
    class function Global: ICefRequestContext;
    class function New(const settings: PCefRequestContextSettings;
      const handler: ICefRequestContextHandler): ICefRequestContext;
    class function Shared(const other: ICefRequestContext;
      const handler: ICefRequestContextHandler): ICefRequestContext;
  end;

  TCefRequestContextHandlerRef = class(TCefBaseRef, ICefRequestContextHandler)
  protected
    function GetCookieManager: ICefCookieManager;
    function OnBeforePluginLoad(const mimeType, pluginUrl, topOriginUrl: ustring;
      const pluginInfo: ICefWebPluginInfo; pluginPolicy: PCefPluginPolicy): Boolean;
  public
    class function UnWrap(data: Pointer): ICefRequestContextHandler;
  end;

  TCefRequestContextHandlerOwn = class(TCefBaseOwn, ICefRequestContextHandler)
  protected
    function GetCookieManager: ICefCookieManager; virtual;
    function OnBeforePluginLoad(const mimeType, pluginUrl, topOriginUrl: ustring;
      const pluginInfo: ICefWebPluginInfo; pluginPolicy: PCefPluginPolicy): Boolean; virtual;
  public
    constructor Create; virtual;
  end;

  TCefRequestContextHandlerProc = {$IFDEF DELPHI12_UP}reference to{$ENDIF} function: ICefCookieManager;

  TCefFastRequestContextHandler = class(TCefRequestContextHandlerOwn)
  private
    FProc: TCefRequestContextHandlerProc;
  protected
    function GetCookieManager: ICefCookieManager; override;
  public
    constructor Create(const proc: TCefRequestContextHandlerProc); reintroduce;
  end;


  TCefPrintSettingsRef = class(TCefBaseRef, ICefPrintSettings)
  protected
    function IsValid: Boolean;
    function IsReadOnly: Boolean;
    function Copy: ICefPrintSettings;
    procedure SetOrientation(landscape: Boolean);
    function IsLandscape: Boolean;
    procedure SetPrinterPrintableArea(
      const physicalSizeDeviceUnits: PCefSize;
      const printableAreaDeviceUnits: PCefRect;
      landscapeNeedsFlip: Boolean); stdcall;
    procedure SetDeviceName(const name: ustring);
    function GetDeviceName: ustring;
    procedure SetDpi(dpi: Integer);
    function GetDpi: Integer;
    procedure SetPageRanges(const ranges: TCefPageRangeArray);
    function GetPageRangesCount: NativeUInt;
    procedure GetPageRanges(out ranges: TCefPageRangeArray);
    procedure SetSelectionOnly(selectionOnly: Boolean);
    function IsSelectionOnly: Boolean;
    procedure SetCollate(collate: Boolean);
    function WillCollate: Boolean;
    procedure SetColorModel(model: TCefColorModel);
    function GetColorModel: TCefColorModel;
    procedure SetCopies(copies: Integer);
    function GetCopies: Integer;
    procedure SetDuplexMode(mode: TCefDuplexMode);
    function GetDuplexMode: TCefDuplexMode;
  public
    class function New: ICefPrintSettings;
    class function UnWrap(data: Pointer): ICefPrintSettings;
  end;

  TCefNavigationEntryRef = class(TCefBaseRef, ICefNavigationEntry)
  protected
    function IsValid: Boolean;
    function GetUrl: ustring;
    function GetDisplayUrl: ustring;
    function GetOriginalUrl: ustring;
    function GetTitle: ustring;
    function GetTransitionType: TCefTransitionType;
    function HasPostData: Boolean;
    function GetCompletionTime: TDateTime;
    function GetHttpStatusCode: Integer;
  public
    class function UnWrap(data: Pointer): ICefNavigationEntry;
  end;

  TCefNavigationEntryVisitorOwn = class(TCefBaseOwn, ICefNavigationEntryVisitor)
  protected
    function Visit(const entry: ICefNavigationEntry;
      current: Boolean; index, total: Integer): Boolean; virtual;
  public
    constructor Create;
  end;

  TCefFastNavigationEntryVisitor = class(TCefNavigationEntryVisitorOwn)
  private
    FVisitor: TCefNavigationEntryVisitorProc;
  protected
    function Visit(const entry: ICefNavigationEntry;
      current: Boolean; index, total: Integer): Boolean; override;
  public
    constructor Create(const proc: TCefNavigationEntryVisitorProc); reintroduce;
  end;


  TCefSslCertPrincipalRef = class(TCefBaseRef, ICefSslCertPrincipal)
  protected
    function GetDisplayName: ustring;
    function GetCommonName: ustring;
    function GetLocalityName: ustring;
    function GetStateOrProvinceName: ustring;
    function GetCountryName: ustring;
    procedure GetStreetAddresses(addresses: TStrings);
    procedure GetOrganizationNames(names: TStrings);
    procedure GetOrganizationUnitNames(names: TStrings);
    procedure GetDomainComponents(components: TStrings);
  public
    class function UnWrap(data: Pointer): ICefSslCertPrincipal;
  end;

  TCefSslInfoRef = class(TCefBaseRef, ICefSslInfo)
  protected
    function GetSubject: ICefSslCertPrincipal;
    function GetIssuer: ICefSslCertPrincipal;
    function GetSerialNumber: ICefBinaryValue;
    function GetValidStart: TCefTime;
    function GetValidExpiry: TCefTime;
    function GetDerEncoded: ICefBinaryValue;
    function GetPemEncoded: ICefBinaryValue;
  public
    class function UnWrap(data: Pointer): ICefSslInfo;
  end;

  TCefPdfPrintCallbackOwn = class(TCefBaseOwn, ICefPdfPrintCallback)
  protected
    procedure OnPdfPrintFinished(const path: ustring; ok: Boolean); virtual; abstract;
  public
    constructor Create; virtual;
  end;

  TCefFastPdfPrintCallback = class(TCefPdfPrintCallbackOwn)
  private
    FProc: TOnPdfPrintFinishedProc;
  protected
    procedure OnPdfPrintFinished(const path: ustring; ok: Boolean); override;
  public
    constructor Create(const proc: TOnPdfPrintFinishedProc); reintroduce;
  end;

  TCefRunContextMenuCallbackRef = class(TCefBaseRef, ICefRunContextMenuCallback)
  protected
    procedure Cont(commandId: Integer; eventFlags: TCefEventFlags);
    procedure Cancel;
  public
    class function UnWrap(data: Pointer): ICefRunContextMenuCallback;
  end;

  TCefResourceBundleRef = class(TCefBaseRef, ICefResourceBundle)
  protected
    function GetLocalizedString(stringId: Integer): ustring;
    function GetDataResource(resourceId: Integer;
      out data: Pointer; out dataSize: NativeUInt): Boolean;
    function GetDataResourceForScale(resourceId: Integer; scaleFactor: TCefScaleFactor;
      out data: Pointer; out dataSize: NativeUInt): Boolean;
  public
    class function UnWrap(data: Pointer): ICefResourceBundle;
    class function Global: ICefResourceBundle;
  end;

  ECefException = class(Exception)
  end;

function CefLoadLibDefault: Boolean;
function CefLoadLib(
  const Cache: ustring = '';
  const UserDataPath: ustring = '';
  const UserAgent: ustring = '';
  const ProductVersion: ustring = '';
  const Locale: ustring = '';
  const LogFile: ustring = '';
  const BrowserSubprocessPath: ustring = '';
  LogSeverity: TCefLogSeverity = LOGSEVERITY_DISABLE;
  JavaScriptFlags: ustring = '';
  ResourcesDirPath: ustring = '';
  LocalesDirPath: ustring = '';
  SingleProcess: Boolean = False;
  NoSandbox: Boolean = False;
  CommandLineArgsDisabled: Boolean = False;
  PackLoadingDisabled: Boolean = False;
  RemoteDebuggingPort: Integer = 0;
  UncaughtExceptionStackSize: Integer = 0;
  ContextSafetyImplementation: Integer = 0;
  PersistSessionCookies: Boolean = False;
  IgnoreCertificateErrors: Boolean = False;
  BackgroundColor: TCefColor = 0;
  const AcceptLanguageList: ustring = '';
  WindowsSandboxInfo: Pointer = nil;
  WindowlessRenderingEnabled: Boolean = False): Boolean;
function CefGetObject(ptr: Pointer): TObject;
function CefStringAlloc(const str: ustring): TCefString;

function CefString(const str: ustring): TCefString; overload;
function CefString(const str: PCefString): ustring; overload;
function CefUserFreeString(const str: ustring): PCefStringUserFree;

function CefStringClearAndGet(var str: TCefString): ustring;
procedure CefStringFree(const str: PCefString);
function CefStringFreeAndGet(const str: PCefStringUserFree): ustring;
procedure CefStringSet(const str: PCefString; const value: ustring);
function CefBrowserHostCreate(windowInfo: PCefWindowInfo; const client: ICefClient;
  const url: ustring; const settings: PCefBrowserSettings; const requestContext: ICefRequestContext): Boolean;
function CefBrowserHostCreateSync(windowInfo: PCefWindowInfo; const client: ICefClient;
  const url: ustring; const settings: PCefBrowserSettings; const requestContext: ICefRequestContext): ICefBrowser;
{$IFNDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
procedure CefDoMessageLoopWork;
procedure CefRunMessageLoop;
procedure CefQuitMessageLoop;
procedure CefSetOsModalLoop(loop: Boolean);
{$ENDIF}
procedure CefEnableHighDpiSupport;

procedure CefShutDown;

function CefRegisterSchemeHandlerFactory(const SchemeName, HostName: ustring;
  const handler: TCefResourceHandlerClass): Boolean; overload;

function CefRegisterSchemeHandlerFactory(const SchemeName, HostName: ustring;
  const factory: ICefSchemeHandlerFactory): Boolean; overload;

function CefClearSchemeHandlerFactories: Boolean;

function CefAddCrossOriginWhitelistEntry(const SourceOrigin, TargetProtocol,
  TargetDomain: ustring; AllowTargetSubdomains: Boolean): Boolean;
function CefRemoveCrossOriginWhitelistEntry(
  const SourceOrigin, TargetProtocol, TargetDomain: ustring;
  AllowTargetSubdomains: Boolean): Boolean;
function CefClearCrossOriginWhitelist: Boolean;

function CefRegisterExtension(const name, code: ustring;
  const Handler: ICefv8Handler): Boolean;
function CefCurrentlyOn(ThreadId: TCefThreadId): Boolean;
procedure CefPostTask(ThreadId: TCefThreadId; const task: ICefTask);
procedure CefPostDelayedTask(ThreadId: TCefThreadId; const task: ICefTask; delayMs: Int64);
function CefGetData(const i: ICefBase): Pointer;
function CefParseUrl(const url: ustring; var parts: TUrlParts): Boolean;
function CefCreateUrl(var parts: TUrlParts): ustring;
function CefGetMimeType(const extension: ustring): ustring;
procedure CefGetExtensionsForMimeType(const mimeType: ustring; extensions: TStringList);

function CefBase64Encode(const data: Pointer; dataSize: NativeUInt): ustring;
function CefBase64Decode(const data: ustring): ICefBinaryValue;
function CefUriEncode(const text: ustring; usePlus: Boolean): ustring;
function CefUriDecode(const text: ustring; convertToUtf8: Boolean;
  unescapeRule: TCefUriUnescapeRule): ustring;
function CefParseCssColor(const str: ustring; strict: Boolean; out color: TCefColor): Boolean;
{$ifdef Win32}
function CefParseJson(const jsonString: ustring; options: TCefJsonParserOptions): ICefValue;
function CefParseJsonAndReturnError(const jsonString: ustring; options: TCefJsonParserOptions;
  out errorCodeOut: TCefJsonParserError; out errorMsgOut: ustring): ICefValue;
function CefWriteJson(const node: ICefValue; options: TCefJsonWriterOptions): ustring;
{$endif}
procedure CefVisitWebPluginInfo(const visitor: ICefWebPluginInfoVisitor);
procedure CefVisitWebPluginInfoProc(const visitor: TCefWebPluginInfoVisitorProc);
procedure CefRefreshWebPlugins;
procedure CefAddWebPluginPath(const path: ustring);
procedure CefAddWebPluginDirectory(const dir: ustring);
procedure CefRemoveWebPluginPath(const path: ustring);
procedure CefUnregisterInternalWebPlugin(const path: ustring);
procedure CefForceWebPluginShutdown(const path: ustring);
procedure CefRegisterWebPluginCrash(const path: ustring);
procedure CefIsWebPluginUnstable(const path: ustring;
  const callback: ICefWebPluginUnstableCallback);
procedure CefIsWebPluginUnstableProc(const path: ustring;
  const callback: TCefWebPluginIsUnstableProc);

function CefGetPath(key: TCefPathKey; out path: ustring): Boolean;

function CefBeginTracing(const categories: ustring; const callback: ICefCompletionCallback): Boolean;
function CefEndTracing(const tracingFile: ustring; const callback: ICefEndTracingCallback): Boolean;
function CefNowFromSystemTraceTime: Int64;

function CefGetGeolocation(const callback: ICefGetGeolocationCallback): Boolean;

var
  CefLibrary: string = {$IFDEF MSWINDOWS}'libcef.dll'{$ELSE}'libcef.dylib'{$ENDIF};
  CefCache: ustring = '';
  CefUserDataPath: ustring = '';
  CefUserAgent: ustring = '';
  CefProductVersion: ustring = '';
  CefLocale: ustring = '';
  CefLogFile: ustring = '';
  CefLogSeverity: TCefLogSeverity = LOGSEVERITY_DISABLE;
  CefJavaScriptFlags: ustring = '';
  CefResourcesDirPath: ustring = '';
  CefLocalesDirPath: ustring = '';
  CefPackLoadingDisabled: Boolean = False;
  CefSingleProcess: Boolean = True;
  CefNoSandbox: Boolean = False;
  CefBrowserSubprocessPath: ustring = '';
  CefCommandLineArgsDisabled: Boolean = False;
  CefRemoteDebuggingPort: Integer = 0;
  CefGetDataResource: TGetDataResource = nil;
  CefGetLocalizedString: TGetLocalizedString = nil;
  CefUncaughtExceptionStackSize: Integer = 0;
  CefContextSafetyImplementation: Integer = 0;
  CefPersistSessionCookies: Boolean = False;
  CefIgnoreCertificateErrors: Boolean = False;
  CefBackgroundColor: TCefColor = 0;
  CefAcceptLanguageList: ustring = '';
  CefWindowsSandboxInfo: Pointer = nil;
  CefWindowlessRenderingEnabled: Boolean = False;

  CefResourceBundleHandler: ICefResourceBundleHandler = nil;
  CefBrowserProcessHandler: ICefBrowserProcessHandler = nil;
  CefRenderProcessHandler: ICefRenderProcessHandler = nil;
  CefOnBeforeCommandLineProcessing: TOnBeforeCommandLineProcessing = nil;
  CefOnRegisterCustomSchemes: TOnRegisterCustomSchemes = nil;

implementation

  function CefColorGetA(color: TCefColor): Byte;
  begin
    Result := (color shr 24) and $FF;
  end;

  function CefColorGetR(color: TCefColor): byte;
  begin
    Result := (color shr 16) and $FF;
  end;

  function CefColorGetG(color: TCefColor): Byte;
  begin
    Result := (color shr 8) and $FF;
  end;

  function CefColorGetB(color: TCefColor): Byte;
  begin
    Result := color and $FF;
  end;

  function CefColorSetARGB(a, r, g, b: Byte): TCefColor;
  begin
    Result := (a shl 24) or (r shl 16) or (g shl 8) or b;
  end;

  function CefInt64Set(int32_low, int32_high: Integer): Int64;
  begin
    Result := int32_low or (int32_high shl 32);
  end;

  function CefInt64GetLow(const int64_val: Int64): Integer;
  begin
    Result := Integer(int64_val);
  end;

  function CefInt64GetHigh(const int64_val: Int64): Integer;
  begin
    Result := (int64_val shr 32) and $FFFFFFFF;
  end;


type
  TInternalApp = class(TCefAppOwn)
  protected
    procedure OnBeforeCommandLineProcessing(const processType: ustring;
      const commandLine: ICefCommandLine); override;
    procedure OnRegisterCustomSchemes(const registrar: ICefSchemeRegistrar); override;
    function GetResourceBundleHandler: ICefResourceBundleHandler; override;
    function GetBrowserProcessHandler: ICefBrowserProcessHandler; override;
    function GetRenderProcessHandler: ICefRenderProcessHandler; override;
  end;

  procedure TInternalApp.OnBeforeCommandLineProcessing(const processType: ustring;
      const commandLine: ICefCommandLine);
  begin

    if Assigned(CefOnBeforeCommandLineProcessing) then
      CefOnBeforeCommandLineProcessing(processType, commandLine);
  end;

  procedure TInternalApp.OnRegisterCustomSchemes(const registrar: ICefSchemeRegistrar);
  begin

    if Assigned(CefOnRegisterCustomSchemes) then
      CefOnRegisterCustomSchemes(registrar);
  end;

  function TInternalApp.GetResourceBundleHandler: ICefResourceBundleHandler;
  begin
    Result := CefResourceBundleHandler;
  end;

  function TInternalApp.GetBrowserProcessHandler: ICefBrowserProcessHandler;
  begin

    result := CefBrowserProcessHandler;
  end;

  function TInternalApp.GetRenderProcessHandler: ICefRenderProcessHandler;
  begin
    Result := CefRenderProcessHandler;
  end;

{$IFDEF MSWINDOWS}
function TzSpecificLocalTimeToSystemTime(
  lpTimeZoneInformation: PTimeZoneInformation;
  lpLocalTime, lpUniversalTime: PSystemTime): BOOL; stdcall; external 'kernel32.dll';

function SystemTimeToTzSpecificLocalTime(
  lpTimeZoneInformation: PTimeZoneInformation;
  lpUniversalTime, lpLocalTime: PSystemTime): BOOL; stdcall; external 'kernel32.dll';
{$ENDIF}

var
  // ��Щ�������������ַ���ֵ�����|copy|Ϊtrue (1)����ֵ�����������������á�
  // �����û����������õ��������ڡ�
  cef_string_wide_set: function(const src: PWideChar; src_len: NativeUInt;  output: PCefStringWide; copy: Integer): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_utf8_set: function(const src: PAnsiChar; src_len: NativeUInt; output: PCefStringUtf8; copy: Integer): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_utf16_set: function(const src: PChar16; src_len: NativeUInt; output: PCefStringUtf16; copy: Integer): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_set: function(const src: PCefChar; src_len: NativeUInt; output: PCefString; copy: Integer): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ��Щ������������ַ���ֵ��str����ṹ�岻�ᱻFree����
  cef_string_wide_clear: procedure(str: PCefStringWide); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_utf8_clear: procedure(str: PCefStringUtf8); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_utf16_clear: procedure(str: PCefStringUtf16); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_clear: procedure(str: PCefString); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ��Щ�������ڱȽ������ַ���ֵ�������strcmp()�������ơ�
  cef_string_wide_cmp: function(const str1, str2: PCefStringWide): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_utf8_cmp: function(const str1, str2: PCefStringUtf8): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_utf16_cmp: function(const str1, str2: PCefStringUtf16): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ��Щ���������ַ�����UTF-8/-16/-32��ʽ���ת������Щ�������ܻ�Ƚ��������Գ���
  // ��Ҫ��Ҫ����ʹ����Щ������ת���Ľ������д�뵽|output|������ֵ����ָʾת���Ƿ�100%��Ч��
  cef_string_wide_to_utf8: function(const src: PWideChar; src_len: NativeUInt; output: PCefStringUtf8): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_utf8_to_wide: function(const src: PAnsiChar; src_len: NativeUInt; output: PCefStringWide): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  cef_string_wide_to_utf16: function (const src: PWideChar; src_len: NativeUInt; output: PCefStringUtf16): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_utf16_to_wide: function(const src: PChar16; src_len: NativeUInt; output: PCefStringWide): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  cef_string_utf8_to_utf16: function(const src: PAnsiChar; src_len: NativeUInt; output: PCefStringUtf16): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_utf16_to_utf8: function(const src: PChar16; src_len: NativeUInt; output: PCefStringUtf8): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  cef_string_to_utf8: function(const src: PCefChar; src_len: NativeUInt; output: PCefStringUtf8): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_from_utf8: function(const src: PAnsiChar; src_len: NativeUInt; output: PCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_to_utf16: function(const src: PCefChar; src_len: NativeUInt; output: PCefStringUtf16): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_from_utf16: function(const src: PChar16; src_len: NativeUInt; output: PCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_to_wide: function(const src: PCefChar; src_len: NativeUInt; output: PCefStringWide): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_from_wide: function(const src: PWideChar; src_len: NativeUInt; output: PCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ��Щ��������ת��һ��ASCII�ַ���, ����ת��ΪWide/UTF16�ַ�����
  // ���ڵ���֪���ַ�����ASCIIʱ��ʹ����Щ��������ת����
  cef_string_ascii_to_wide: function(const src: PAnsiChar; src_len: NativeUInt; output: PCefStringWide): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_ascii_to_utf16: function(const src: PAnsiChar; src_len: NativeUInt; output: PCefStringUtf16): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_from_ascii: function(const src: PAnsiChar; src_len: NativeUInt; output: PCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ��Щ��������һ���µ��ַ����ṹ�塣���Ǳ���ͨ��������ص�Free���������١�
  cef_string_userfree_wide_alloc: function(): PCefStringUserFreeWide; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_userfree_utf8_alloc: function(): PCefStringUserFreeUtf8; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_userfree_utf16_alloc: function(): PCefStringUserFreeUtf16; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_userfree_alloc: function(): PCefStringUserFree; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ��Щ������������alloc�����������ַ����ṹ�壬�κ��ַ����������ȱ�����պ�������١�
  cef_string_userfree_wide_free: procedure(str: PCefStringUserFreeWide); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_userfree_utf8_free: procedure(str: PCefStringUserFreeUtf8); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_userfree_utf16_free: procedure(str: PCefStringUserFreeUtf16); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_userfree_free: procedure(str: PCefStringUserFree); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

// ���ڸ����ַ���ֵ�ķ����
function cef_string_wide_copy(const src: PWideChar; src_len: NativeUInt;  output: PCefStringWide): Integer;
begin
  Result := cef_string_wide_set(src, src_len, output, ord(True))
end;

function cef_string_utf8_copy(const src: PAnsiChar; src_len: NativeUInt; output: PCefStringUtf8): Integer;
begin
  Result := cef_string_utf8_set(src, src_len, output, ord(True))
end;

function cef_string_utf16_copy(const src: PChar16; src_len: NativeUInt; output: PCefStringUtf16): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
begin
  Result := cef_string_utf16_set(src, src_len, output, ord(True))
end;

function cef_string_copy(const src: PCefChar; src_len: NativeUInt; output: PCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
begin
  Result := cef_string_set(src, src_len, output, ord(True));
end;

var
  // ����һ����������ڣ����ڲ���ͨ��|windowInfo|ָ����
  // ����ֵ�����ڲ������������������Ĵ��ڽ���UI�߳��б�������
  // ���|request_context|ΪNULL����ʹ��ȫ�ֵ����������ġ�����������������������
  // �������߳��б����ã����Ҳ��������ġ�
  cef_browser_host_create_browser: function(
      const windowInfo: PCefWindowInfo; client: PCefClient;
      const url: PCefString; const settings: PCefBrowserSettings;
      request_context: PCefRequestContext): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����һ����������ڣ����ڲ���ͨ��|windowInfo|ָ����
  // ���|request_context|ΪNULL����ʹ��ȫ�ֵ����������ġ�
  // ����������������������UI�߳��б����á�
  cef_browser_host_create_browser_sync: function(
      const windowInfo: PCefWindowInfo; client: PCefClient;
      const url: PCefString; const settings: PCefBrowserSettings;
      request_context: PCefRequestContext): PCefBrowser; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ִ��һ��CEF��Ϣѭ����������������ڽ�CEF��Ϣѭ�����ɵ��Ѵ��ڵ�Ӧ����Ϣѭ���С�
  // ע����뱣������ƽ�⣬��������CPUռ�á�
  // �������Ӧ�ý�����Ӧ���߳��б����ã��ҽ���cef_initialize()������ʱ��
  // CefSettings.multi_threaded_message_loop��ֵΪfalse (0)ʱ�����á�
  // ����������������ġ�
  cef_do_message_loop_work: procedure(); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����CEF����Ϣѭ����ʹ��������������һ��Ӧ�ó����ṩ����Ϣѭ�����Ի����õ�
  // ������CPUռ�õ�ƽ�⡣ ���������Ӧ������Ӧ���̣߳����ҵ���cef_initialize()ʱ��
  // CefSettings.multi_threaded_message_loop��ֵΪfalse (0)ʱ�����á����������������
  // ֱ�����յ�����ϵͳ��quit��Ϣ��
  cef_run_message_loop: procedure; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����(Quit)CEF����Ϣѭ��cef_run_message_loop()��
  // ��������������̣߳���ʹ����cef_run_message_loop()ʱ�����á�
  cef_quit_message_loop: procedure; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};


  // �ڵ�������TrackPopupMenu��Windows API����һ��ģ̬��Ϣѭ��֮ǰ���øú�������Ϊtrue (1)
  // ���뿪ģ̬��Ϣѭ��֮����øú�������false (0)��
  cef_set_osmodal_loop: procedure(osModalLoop: Integer); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Call during process startup to enable High-DPI support on Windows 7 or newer.
  // Older versions of Windows should be left DPI-unaware because they do not
  // support DirectWrite and GDI fonts are kerned very badly.
  cef_enable_highdpi_support: procedure; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // �������Ӧ����Ӧ�ó�����ڵ㺯���������ڶ�������ʱ�����á�
  // ��������������������ͻ��˽���(Ĭ����Ϊ)��CefSettings.browser_subprocess_path
  // ָ���Ľ��̵ĵڶ������̡���������������������(�������е�"type"��ʶ)��
  // ������������-1�����������֪�ĵڶ������б����ã���������������ֱ�������뿪������
  // ���̵��˳��롣|application|��������ΪNULL��|windows_sandbox_info|����������
  // Windows�����ҿ���ΪNULL (����μ�cef_sandbox_win.h)��
  cef_execute_process: function(const args: PCefMainArgs; application: PCefApp; windows_sandbox_info: Pointer): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // �������Ӧ�������߳��е��ã����ڳ�ʼ��CEF��������̡�
  // |application|��������ΪNULL������true (1)ʱָʾ�ɹ�������ָʾʧ�ܡ�
  cef_initialize: function(const args: PCefMainArgs; const settings: PCefSettings; application: PCefApp; windows_sandbox_info: Pointer): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // �������Ӧ�������߳��е��ã�������Ӧ���뿪֮ǰ������CEF��������̡�
  cef_shutdown: procedure(); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����һ���µ��ַ���ӳ���
  cef_string_map_alloc: function(): TCefStringMap; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_map_size: function(map: TCefStringMap): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // ��ȡӳ�����ָ����������ֵ
  cef_string_map_find: function(map: TCefStringMap; const key: PCefString; var value: TCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // ��ȡӳ�����ָ��ӳ������(����0)�ļ���
  cef_string_map_key: function(map: TCefStringMap; index: Integer; var key: TCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // ��ȡӳ�����ָ��ӳ������(����0)�ļ�ֵ
  cef_string_map_value: function(map: TCefStringMap; index: Integer; var value: TCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // ���ַ���ӳ����ĩβ���һ���µ�key/value��
  cef_string_map_append: function(map: TCefStringMap; const key, value: PCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // ���ӳ���
  cef_string_map_clear: procedure(map: TCefStringMap); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // ����ӳ���
  cef_string_map_free: procedure(map: TCefStringMap); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����һ���µ��ַ����б�
  cef_string_list_alloc: function(): TCefStringList; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // �����ַ����б��е�Ԫ�ص�����
  cef_string_list_size: function(list: TCefStringList): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // �����б���ָ������(����0)��ֵ�����ֵ�ɹ��ҵ��򷵻�true (1)
  cef_string_list_value: function(list: TCefStringList; index: Integer; value: PCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // ���ַ����б��ĩβ���һ����ֵ
  cef_string_list_append: procedure(list: TCefStringList; const value: PCefString); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // ����ַ����б�
  cef_string_list_clear: procedure(list: TCefStringList); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // �����ַ����б�
  cef_string_list_free: procedure(list: TCefStringList); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // ����һ���Ѵ��ڵ��ַ����б�ĸ���
  cef_string_list_copy: function(list: TCefStringList): TCefStringList;


  // ����һ���µ�V8��չ����ָ����JavaScript����ʹ�������
  // ��������ʵ�ֺ���ʹ��'native'�ؼ��ֶ�������ԭ�͡�
  // ���غ����ĵ��ý��ϸ���ѭ�ñ��غ���ԭ�Ͷ����������
  // ��Щ����������Ⱦ���̵����߳��б����á�
  //
  // һ��JavaScript��չ����ʾ��:
  //
  //   // ���'example'�����ڣ��򴴽�һ��'example'ȫ�ֶ���
  //   if (!example)
  //     example = {};
  //   // ���'example.test'�����ڣ��򴴽�һ��'example.test'ȫ�ֶ���
  //   if (!example.test)
  //     example.test = {};
  //   (function() {
  //     // ����'example.test.myfunction'����.
  //     example.test.myfunction = function() {
  //       // ����CefV8Handler::Execute()��ָ���ĺ�����'MyFunction'������û�в�����
  //       native function MyFunction();
  //       return MyFunction();
  //     };
  //     // Ϊ'example.test.myparam'����getter����
  //     example.test.__defineGetter__('myparam', function() {
  //       // ����CefV8Handler::Execute()��ָ���ĺ�����'GetMyParam'������û�в�����
  //       native function GetMyParam();
  //       return GetMyParam();
  //     });
  //     // Ϊ'example.test.myparam'����setter����
  //     example.test.__defineSetter__('myparam', function(b) {
  //       // ����CefV8Handler::Execute()��ָ���ĺ�����'SetMyParam'������û�в�����
  //       native function SetMyParam();
  //       if(b) SetMyParam(b);
  //     });
  //
  //     // ��չ����Ҳ���԰���������JavaScript�����ͺ�����
  //     var myint = 0;
  //     example.test.increment = function() {
  //       myint += 1;
  //       return myint;
  //     };
  //   })();
  //
  // ��ҳ���е�ʹ��ʾ��:
  //
  //   // ���ñ��غ���.
  //   example.test.myfunction();
  //   // ���ò���
  //   example.test.myparam = value;
  //   // ��ȡ����
  //   value = example.test.myparam;
  //   // ������һ������
  //   example.test.increment();
  //
  cef_register_extension: function(const extension_name,
    javascript_code: PCefString; handler: PCefv8Handler): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Ϊָ����|scheme_name|��|domain_name|(��ѡ)ע��һ��scheme������������
  // ����һ����׼scheme����|domain_name|ΪNULLʱ���ù�����ƥ������������
  // |domain_name|��ֵ���������зǱ�׼scheme�����|scheme_name|��һ������scheme��
  // ����|factory|û�з��ش������������õ�scheme�����������������á�
  // ���|scheme_name|��һ���Զ���scheme�����������н����ж�ʵ����cef_app_t::on_register_custom_schemes()
  // ��������������������ö�Σ����ڸı�/�Ƴ�ƥ��ָ��|scheme_name|��|domain_name|�Ĺ�����
  // ����������ʱ����false (0)�����������������������̵��κ��߳��б����á�
  cef_register_scheme_handler_factory: function(
    const scheme_name, domain_name: PCefString;
    factory: PCefSchemeHandlerFactory): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // �������ע���scheme����������������������ʱ����false (0)��
  // ���������������������̵��κ��߳��б����á�
  cef_clear_scheme_handler_factories: function: Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // �������ʰ����������һ����Ŀ
  //
  // ͬԴ���������˽ű��ڲ�ͬ��(scheme + domain + port) ֮���ͨѶ������
  // Ĭ������£��ű������Է�����ͬԴ����Դ��
  // �ű��ڴ���HTTP��HTTPS��schemeʱ����ʹ��"Access-Control-Allow-Origin"ͷ������
  // �����������磬���http://target.example.com����Ӧͷ����
  // "Access-Control-Allow-Origin: https://source.example.com"��Ӧͷʱ��https://source.example.com
  // �Ϳ��Զ�http://target.example.com���п��������ˡ�
  //
  // ��һ��������frame��iframe�еĽű��������������ͬ��Э���������׺�������ǿ�
  // ִ�п���JavaScript(�������ҳ�����õ�document.domainֵ����ͬ��������׺ʱ)��
  // ����,������Ƕ�������document.domain="example.com"��
  // scheme://foo.example.com��scheme://bar.example.com����ͨ��JavaScript���н�����
  //
  // ������������������Υ��ͬԴ���Ե�Դ��
  // ����|source_origin|URL(����http://www.example.com)�Ľű����Է���ָ����|target_protocol|
  // ��|target_domain|�µ�������Դ�����|target_domain|��NULL������|allow_target_subdomains|Ϊ
  // false (0)�� �����ƥ��������ſ��Է��ʡ�
  // ���|target_domain|������һ��������������(����"example.com")������|allow_target_subdomains|Ϊ
  // true (1)����������Ҳ���Ա����ʡ����|target_domain|ΪNULL������|allow_target_subdomains|Ϊ
  // true (1)��������������IP��ַ�����Է��ʡ�
  //
  // ����������ܴ���һ�����صĻ�display isolated��scheme������μ�CefRegisterCustomScheme��
  //
  // ������������������߳��б����á����|source_origin|��Ч����������ܷ����򷵻�false (0)��
  cef_add_cross_origin_whitelist_entry: function(const source_origin, target_protocol,
    target_domain: PCefString; allow_target_subdomains: Integer): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // �ӿ�����ʰ��������Ƴ�һ����Ŀ�����|source_origin|��Ч����������ܷ����򷵻�false (0)��
  cef_remove_cross_origin_whitelist_entry: function(
      const source_origin, target_protocol, target_domain: PCefString;
      allow_target_subdomains: Integer): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // �ӿ�����ʰ��������Ƴ�������Ŀ�����|source_origin|��Ч����������ܷ����򷵻�false (0)��
  cef_clear_cross_origin_whitelist: function: Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ������÷�����ָ�����߳����򷵻�true (1)���ȼ���ʹ��
  // cef_task_tRunner::GetForThread(threadId)->belongs_to_current_thread().
  cef_currently_on: function(threadId: TCefThreadId): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // �ʼ�һ��task��ָ���߳���ִ�С��ȼ���ʹ��
  // cef_task_tRunner::GetForThread(threadId)->PostTask(task).
  cef_post_task: function(threadId: TCefThreadId; task: PCefTask): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // �ʼ�һ��task��ָ���߳����ӳ�ִ�С��ȼ���ʹ��
  // cef_task_tRunner::GetForThread(threadId)->PostDelayedTask(task, delay_ms).
  cef_post_delayed_task: function(threadId: TCefThreadId;
      task: PCefTask; delay_ms: Int64): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����ָ����|url|�����ĸ��������С����URLΪNULL����Ч���򷵻�false (0)��
  cef_parse_url: function(const url: PCefString; var parts: TCefUrlParts): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����ָ����|parts|��������һ��URL���÷����б������һ����NULL��spec���NULL��
  // host��path(����), �����ض����������|parts|δ��ʼ���򷵻�false (0)��
  cef_create_url: function(parts: PCefUrlParts; url: PCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����ָ���ļ���չ����Ӧ��mime type�����δ֪�򷵻�NULL�ַ���
  // ����ַ����������cef_string_userfree_free()������
  cef_get_mime_type: function(const extension: PCefString): PCefStringUserFree; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ��ȡָ����|mime_type|��������չ���б�|mime_type|������Сд�ġ�
  // һ��|mime_type|�����ж����������չ��������"html,htm"֮��"text/html", ��
  // "txt,text,html,..."֮��"text/*"�����ṩ��vector�е��κ��Ѵ��ڵ�Ԫ�ؽ�����������
  cef_get_extensions_for_mime_type: procedure(const mime_type: PCefString;
    extensions: TCefStringList); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

//******************************************************************************

  // Encodes |data| as a base64 string.
  // The resulting string must be freed by calling cef_string_userfree_free().
  cef_base64encode: function(const data: Pointer; data_size: NativeUInt): PCefStringUserFree;
    {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Decodes the base64 encoded string |data|. The returned value will be NULL if
  // the decoding fails.
  cef_base64decode: function(const data: PCefString): PCefBinaryValue;
    {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Escapes characters in |text| which are unsuitable for use as a query
  // parameter value. Everything except alphanumerics and -_.!~*'() will be
  // converted to "%XX". If |use_plus| is true (1) spaces will change to "+". The
  // result is basically the same as encodeURIComponent in Javacript.
  // The resulting string must be freed by calling cef_string_userfree_free().
  cef_uriencode: function(const text: PCefString; use_plus: Integer): PCefStringUserFree;
    {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Unescapes |text| and returns the result. Unescaping consists of looking for
  // the exact pattern "%XX" where each X is a hex digit and converting to the
  // character with the numerical value of those digits (e.g. "i%20=%203%3b"
  // unescapes to "i = 3;"). If |convert_to_utf8| is true (1) this function will
  // attempt to interpret the initial decoded result as UTF-8. If the result is
  // convertable into UTF-8 it will be returned as converted. Otherwise the
  // initial decoded result will be returned.  The |unescape_rule| parameter
  // supports further customization the decoding process.
  // The resulting string must be freed by calling cef_string_userfree_free().
  cef_uridecode: function(const text: PCefString; convert_to_utf8: Integer;
    unescape_rule: TCefUriUnescapeRule): PCefStringUserFree;
    {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Parses |string| which represents a CSS color value. If |strict| is true (1)
  // strict parsing rules will be applied. Returns true (1) on success or false
  // (0) on error. If parsing succeeds |color| will be set to the color value
  // otherwise |color| will remain unchanged.
  cef_parse_csscolor: function(const str: PCefString; strict: Integer;
    color: PCefColor): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

{$ifdef Win32}
  // Parses the specified |json_string| and returns a dictionary or list
  // representation. If JSON parsing fails this function returns NULL.
  cef_parse_json: function(const json_string: PCefString; options: TCefJsonParserOptions): PCefValue;
    {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Parses the specified |json_string| and returns a dictionary or list
  // representation. If JSON parsing fails this function returns NULL and
  // populates |error_code_out| and |error_msg_out| with an error code and a
  // formatted error message respectively.
  cef_parse_jsonand_return_error: function(
      const json_string: PCefString; options: TCefJsonParserOptions;
      error_code_out: PCefJsonParserError; error_msg_out: PCefString): PCefValue;
    {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Generates a JSON string from the specified root |node| which should be a
  // dictionary or list value. Returns an NULL string on failure. This function
  // requires exclusive access to |node| including any underlying data.
  // The resulting string must be freed by calling cef_string_userfree_free().
  cef_write_json: function(node: PCefValue; options: TCefJsonWriterOptions): PCefStringUserFree;
    {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
{$endif}

//******************************************************************************

  // ����һ���µ�TCefRequest����
  cef_request_create: function(): PCefRequest; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����һ���µ�TCefPostData����
  cef_post_data_create: function(): PCefPostData; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����һ���µ�cef_post_data_Element����
  cef_post_data_element_create: function(): PCefPostDataElement; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ���ļ��д���һ���µ�cef_stream_reader_t����
  cef_stream_reader_create_for_file: function(const fileName: PCefString): PCefStreamReader; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // ��data�д���һ���µ�cef_stream_reader_t����
  cef_stream_reader_create_for_data: function(data: Pointer; size: NativeUInt): PCefStreamReader; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // ���Զ��崦�����д���һ���µ�cef_stream_reader_t����
  cef_stream_reader_create_for_handler: function(handler: PCefReadHandler): PCefStreamReader; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Ϊ�ļ�����һ���µ�cef_stream_writer_t����
  cef_stream_writer_create_for_file: function(const fileName: PCefString): PCefStreamWriter; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // Ϊһ���Զ��崦��������һ���µ�cef_stream_writer_t����
  cef_stream_writer_create_for_handler: function(handler: PCefWriteHandler): PCefStreamWriter; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����V8������ջ�еĵ�ǰ(����)�����Ķ���
  cef_v8context_get_current_context: function(): PCefv8Context; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����V8������ջ���ѽ���(�ײ�)�����Ķ���
  cef_v8context_get_entered_context: function(): PCefv8Context; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ���V8��ǰ��һ�����������򷵻�true (1)
  cef_v8context_in_context: function(): Integer;

  // ����һ���µ�����Ϊundefined��cef_v8value_t����
  cef_v8value_create_undefined: function(): PCefv8Value; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // ����һ���µ�����Ϊnull��cef_v8value_t����
  cef_v8value_create_null: function(): PCefv8Value; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // ����һ���µ�����Ϊbool��cef_v8value_t����
  cef_v8value_create_bool: function(value: Integer): PCefv8Value; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // ����һ���µ�����Ϊint��cef_v8value_t����
  cef_v8value_create_int: function(value: Integer): PCefv8Value; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // ����һ���µ�����Ϊunsigned int��cef_v8value_t����
  cef_v8value_create_uint: function(value: Cardinal): PCefv8Value; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // ����һ���µ�����Ϊdouble��cef_v8value_t����
  cef_v8value_create_double: function(value: Double): PCefv8Value; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // ����һ���µ�����ΪDate��cef_v8value_t�����������Ӧ����cef_v8context_tHandler
  // cef_v8handler_t��cef_v8accessor_t�ص�������һ��cef_v8context_t���õ�enter()��
  // exit()֮����������ڱ����á�
  cef_v8value_create_date: function(const value: PCefTime): PCefv8Value; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // ����һ���µ�����Ϊstring��cef_v8value_t����
  cef_v8value_create_string: function(const value: PCefString): PCefv8Value; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����һ���µ�����Ϊobject��cef_v8value_t���󣬰���������(��ѡ)�� �������Ӧ����cef_v8context_tHandler
  // cef_v8handler_t��cef_v8accessor_t�ص�������һ��cef_v8context_t���õ�enter()��
  // exit()֮����������ڱ����á�
  cef_v8value_create_object: function(accessor: PCefV8Accessor): PCefv8Value; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // ����һ���µ�����Ϊarray��cef_v8value_t���󣬿�ָ�������|length|�����
  // |length|Ϊ�������򷵻ص����鳤��Ϊ0���������Ӧ����cef_v8context_tHandler
  // cef_v8handler_t��cef_v8accessor_t�ص�������һ��cef_v8context_t���õ�enter()��
  // exit()֮����������ڱ����á�
  cef_v8value_create_array: function(length: Integer): PCefv8Value; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // ����һ���µ�����Ϊfunction��cef_v8value_t����
  cef_v8value_create_function: function(const name: PCefString; handler: PCefv8Handler): PCefv8Value; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ���ص�ǰ������ĵĶ�ջ�켣��|frame_limit|�ǲ����frame�����������
  cef_v8stack_trace_get_current: function(frame_limit: Integer): PCefV8StackTrace; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����һ���µ�cef_xml_reader_t���󡣷��صĶ���ĺ��������ڴ����ö�����߳��б����á�
  cef_xml_reader_create: function(stream: PCefStreamReader;
    encodingType: TCefXmlEncodingType; const URI: PCefString): PCefXmlReader; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����һ���µ�cef_zip_reader_t���󡣷��صĶ���ĺ��������ڴ����ö�����߳��б����á�
  cef_zip_reader_create: function(stream: PCefStreamReader): PCefZipReader; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����һ���µ��ַ���multimap
  cef_string_multimap_alloc: function: TCefStringMultimap; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // �����ַ���multimap��Ԫ�ص�����
  cef_string_multimap_size: function(map: TCefStringMultimap): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����multimap��ָ������ֵ������
  cef_string_multimap_find_count: function(map: TCefStringMultimap; const key: PCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����multimap��ָ�����ĵ�value_index��ֵ
  cef_string_multimap_enumerate: function(map: TCefStringMultimap;
    const key: PCefString; value_index: Integer; var value: TCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����multimap��ָ������λ���ϵļ���
  cef_string_multimap_key: function(map: TCefStringMultimap; index: Integer; var key: TCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����multimap��ָ������λ���ϵļ�ֵ
  cef_string_multimap_value: function(map: TCefStringMultimap; index: Integer; var value: TCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ���ַ���multimap��ĩβ���һ���µ�key/value��
  cef_string_multimap_append: function(map: TCefStringMultimap; const key, value: PCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����ַ���multimap
  cef_string_multimap_clear: procedure(map: TCefStringMultimap); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // �����ַ���multimap
  cef_string_multimap_free: procedure(map: TCefStringMultimap); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Returns the global cookie manager. By default data will be stored at
  // CefSettings.cache_path if specified or in memory otherwise. If |callback| is
  // non-NULL it will be executed asnychronously on the IO thread after the
  // manager's storage has been initialized. Using this function is equivalent to
  // calling cef_request_tContext::cef_request_context_get_global_context()->get_d
  // efault_cookie_manager().

  cef_cookie_manager_get_global_manager: function(
    callback: PCefCompletionCallback): PCefCookieManager; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����һ���µ�cookie�����������|path|ΪNULL�����ݽ������洢���ڴ��С�
  // �������ݽ����洢��ָ����|path|·���¡�Ҫ�־û�session cookie(û��ʧЧ�պͺ���Ч�����cookie)��
  // ������|persist_session_cookies|Ϊtrue (1). Session cookieͨ������ʱ�ģ�����
  // �󲿷�Web�����������־û����ǡ��������ʧ���򷵻�NULL��
  cef_cookie_manager_create_manager: function(const path: PCefString; persist_session_cookies: Integer;
    callback: PCefCompletionCallback): PCefCookieManager; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};


  // ����һ���µ�cef_command_line_tʵ����
  cef_command_line_create: function(): PCefCommandLine; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����һ��������ȫ��cef_command_line_t�������������ֻ���ġ�
  cef_command_line_get_global: function(): PCefCommandLine; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};


  // ����һ���µ�ָ�����Ƶ�cef_process_message_t����
  cef_process_message_create: function(const name: PCefString): PCefProcessMessage; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Creates a new object.
  cef_value_create: function(): PCefValue; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����һ���µĶ����������κ���������ӵ�С�ָ����|data|��������
  cef_binary_value_create: function(const data: Pointer; data_size: NativeUInt): PCefBinaryValue; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����һ���µĶ����������κ���������ӵ�С�
  cef_dictionary_value_create: function: PCefDictionaryValue; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����һ���µĶ����������κ���������ӵ�С�
  cef_list_value_create: function: PCefListValue; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����ָ��|key|������·��������ɹ��򷵻�true (1)������������������̵��κ��߳��б����á�
  cef_get_path: function(key: TCefPathKey; path: PCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ͨ��ָ����|command_line|����������һ�����̡�����ɹ��򷵻�true (1)��
  // ��������������̵�TID_PROCESS_LAUNCHER�߳��б����á�
  //
  // Unix-�ر�ע��:
  // - ����stdin/stdout/stderr�������ڸ����̴򿪵��ļ�������(file descriptor)������
  //   �ӽ����б��رա�
  // - ��������еĵ�һ������������·��б�ߣ��򽫻�����PATH(�μ�man execvp)��
  cef_launch_process: function(command_line: PCefCommandLine): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ����һ���µ�cef_response_t����
  cef_response_create: function: PCefResponse; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Create a new URL request. Only GET, POST, HEAD, DELETE and PUT request
  // functions are supported. Multiple post data elements are not supported and
  // elements of type PDE_TYPE_FILE are only supported for requests originating
  // from the browser process. Requests originating from the render process will
  // receive the same handling as requests originating from Web content -- if the
  // response contains Content-Disposition or Mime-Type header values that would
  // not normally be rendered then the response may receive special handling
  // inside the browser (for example, via the file download code path instead of
  // the URL request code path). The |request| object will be marked as read-only
  // after calling this function. In the browser process if |request_context| is
  // NULL the global request context will be used. In the render process
  // |request_context| must be NULL and the context associated with the current
  // renderer process' browser will be used.
  cef_urlrequest_create: function(request: PCefRequest; client: PCefUrlRequestClient;
    request_context: PCefRequestContext): PCefUrlRequest; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // ���web�����Ϣ
  cef_visit_web_plugin_info: procedure(visitor: PCefWebPluginInfoVisitor); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Cause the plugin list to refresh the next time it is accessed regardless of
  // whether it has already been loaded. Can be called on any thread in the
  // browser process.
  cef_refresh_web_plugins: procedure; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Add a plugin path (directory + file). This change may not take affect until
  // after cef_refresh_web_plugins() is called. Can be called on any thread in the
  // browser process.
  cef_add_web_plugin_path: procedure(const path: PCefString); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Add a plugin directory. This change may not take affect until after
  // cef_refresh_web_plugins() is called. Can be called on any thread in the
  // browser process.
  cef_add_web_plugin_directory: procedure(const dir: PCefString); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Remove a plugin path (directory + file). This change may not take affect
  // until after cef_refresh_web_plugins() is called. Can be called on any thread
  // in the browser process.
  cef_remove_web_plugin_path: procedure(const path: PCefString); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Unregister an internal plugin. This may be undone the next time
  // cef_refresh_web_plugins() is called. Can be called on any thread in the
  // browser process.
  cef_unregister_internal_web_plugin: procedure(const path: PCefString); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Force a plugin to shutdown. Can be called on any thread in the browser
  // process but will be executed on the IO thread.
  cef_force_web_plugin_shutdown: procedure(const path: PCefString); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Register a plugin crash. Can be called on any thread in the browser process
  // but will be executed on the IO thread.
  cef_register_web_plugin_crash: procedure(const path: PCefString); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Query if a plugin is unstable. Can be called on any thread in the browser
  // process.
  cef_is_web_plugin_unstable: procedure(const path: PCefString;
    callback: PCefWebPluginUnstableCallback); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Request a one-time geolocation update. This function bypasses any user
  // permission checks so should only be used by code that is allowed to access
  // location information.
  cef_get_geolocation: function(callback: PCefGetGeolocationCallback): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Returns the task runner for the current thread. Only CEF threads will have
  // task runners. An NULL reference will be returned if this function is called
  // on an invalid thread.
  cef_task_runner_get_for_current_thread: function: PCefTaskRunner; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Returns the task runner for the specified CEF thread.
  cef_task_runner_get_for_thread: function(threadId: TCefThreadId): PCefTaskRunner; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};



  // Start tracing events on all processes. Tracing is initialized asynchronously
  // and |callback| will be executed on the UI thread after initialization is
  // complete.
  //
  // If CefBeginTracing was called previously, or if a CefEndTracingAsync call is
  // pending, CefBeginTracing will fail and return false (0).
  //
  // |categories| is a comma-delimited list of category wildcards. A category can
  // have an optional '-' prefix to make it an excluded category. Having both
  // included and excluded categories in the same list is not supported.
  //
  // Example: "test_MyTest*" Example: "test_MyTest*,test_OtherStuff" Example:
  // "-excluded_category1,-excluded_category2"
  //
  // This function must be called on the browser process UI thread.

  cef_begin_tracing: function(const categories: PCefString;
    callback: PCefCompletionCallback): Integer;
    {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Stop tracing events on all processes.
  //
  // This function will fail and return false (0) if a previous call to
  // CefEndTracingAsync is already pending or if CefBeginTracing was not called.
  //
  // |tracing_file| is the path at which tracing data will be written and
  // |callback| is the callback that will be executed once all processes have sent
  // their trace data. If |tracing_file| is NULL a new temporary file path will be
  // used. If |callback| is NULL no trace data will be written.
  //
  // This function must be called on the browser process UI thread.

  cef_end_tracing: function(const tracing_file: PCefString;
    callback: PCefEndTracingCallback): Integer;
    {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Returns the current system trace time or, if none is defined, the current
  // high-res time. Can be used by clients to synchronize with the time
  // information in trace events.
  cef_now_from_system_trace_time: function: int64; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};


  // Returns the global context object.
  cef_request_context_get_global_context: function: PCefRequestContext; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Creates a new context object with the specified |settings| and optional
  // |handler|.
  cef_request_context_create_context: function(const settings: PCefRequestContextSettings;
    handler: PCefRequestContextHandler): PCefRequestContext; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Creates a new context object that shares storage with |other| and uses an
  // optional |handler|.
  create_context_shared: function(other: PCefRequestContext;
    handler: PCefRequestContextHandler): PCefRequestContext;
      {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // See include/base/cef_logging.h for macros and intended usage.

  // Gets the current log level.
  cef_get_min_log_level: function(): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Gets the current vlog level for the given file (usually taken from
  // __FILE__). Note that |N| is the size *with* the null terminator.
  cef_get_vlog_level: function(const file_start: PAnsiChar; N: NativeInt): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Add a log message. See the LogSeverity defines for supported |severity|
  // values.
  cef_log: procedure(const file_: PAnsiChar; line, severity: Integer; const message: PAnsiChar); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};



  // Returns the current platform thread ID.
  cef_get_current_platform_thread_id: function(): TCefPlatformThreadId; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Returns the current platform thread handle.
  cef_get_current_platform_thread_handle: function(): TCefPlatformThreadHandle; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};



  // See include/base/cef_trace_event.h for macros and intended usage.

  // Functions for tracing counters and functions; called from macros.
  // - |category| string must have application lifetime (static or literal). They
  //   may not include "(quotes) chars.
  // - |argX_name|, |argX_val|, |valueX_name|, |valeX_val| are optional parameters
  //   and represent pairs of name and values of arguments
  // - |copy| is used to avoid memory scoping issues with the |name| and
  //   |arg_name| parameters by copying them
  // - |id| is used to disambiguate counters with the same name, or match async
  //   trace events

  cef_trace_event_instant: procedure(const category, name, arg1_name: PAnsiChar;
    arg1_val: uint64; const arg2_name: PAnsiChar; arg2_val: UInt64; copy: Integer);
  {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  cef_trace_event_begin: procedure(const category, name, arg1_name: PAnsiChar;
    arg1_val: UInt64; const arg2_name: PAnsiChar; arg2_val: UInt64; copy: Integer);
  {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  cef_trace_event_end: procedure(const category, name, arg1_name: PAnsiChar;
    arg1_val: UInt64; const arg2_name: PAnsiChar; arg2_val: UInt64; copy: Integer);
  {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  cef_trace_counter: procedure(const category, name, value1_name: PAnsiChar;
    value1_val: UInt64; const value2_name: PAnsiChar; value2_val: UInt64; copy: Integer);
  {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  cef_trace_counter_id: procedure(const category, name: PAnsiChar; id: UInt64;
    const value1_name: PAnsiChar; value1_val: UInt64; const value2_name: PAnsiChar;
    value2_val: UInt64; copy: Integer);
  {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  cef_trace_event_async_begin: procedure(const category, name: PAnsiChar; id: UInt64;
    const arg1_name: PAnsiChar; arg1_val: UInt64; const arg2_name: PAnsiChar;
    arg2_val: UInt64; copy: Integer);
  {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  cef_trace_event_async_step_into: procedure(const category, name: PAnsiChar;
    id, step: UInt64; const arg1_name: PAnsiChar; arg1_val: UInt64; copy: Integer);
  {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  cef_trace_event_async_step_past: procedure(const category, name: PAnsiChar;
    id, step: UInt64; const arg1_name: PAnsiChar; arg1_val: UInt64; copy: Integer);
  {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  cef_trace_event_async_end: procedure(const category, name: PAnsiChar; id: UInt64;
    const arg1_name: PAnsiChar; arg1_val: UInt64; const arg2_name: PAnsiChar;
    arg2_val: UInt64; copy: Integer);
  {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};


  cef_print_settings_create: function(): PCefPrintSettings;
  {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};


  cef_drag_data_create: function(): PCefDragData;
  {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Returns the global resource bundle instance.
  cef_resource_bundle_get_global: function(): PCefResourceBundle;
  {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};


var
  LibHandle: THandle = 0;
  CefIsMainProcess: Boolean = False;

function CefLoadLibDefault: Boolean;
begin
  if LibHandle = 0 then
    Result := CefLoadLib(CefCache, CefUserDataPath, CefUserAgent, CefProductVersion,
      CefLocale, CefLogFile, CefBrowserSubprocessPath, CefLogSeverity, CefJavaScriptFlags,
      CefResourcesDirPath, CefLocalesDirPath, CefSingleProcess, CefNoSandbox,
      CefCommandLineArgsDisabled, CefPackLoadingDisabled, CefRemoteDebuggingPort,
      CefUncaughtExceptionStackSize, CefContextSafetyImplementation,
      CefPersistSessionCookies, CefIgnoreCertificateErrors, CefBackgroundColor,
      CefAcceptLanguageList, CefWindowsSandboxInfo, CefWindowlessRenderingEnabled) else
    Result := True;
end;

function CefLoadLib(const Cache, UserDataPath, UserAgent, ProductVersion, Locale, LogFile, BrowserSubprocessPath: ustring;
  LogSeverity: TCefLogSeverity; JavaScriptFlags, ResourcesDirPath, LocalesDirPath: ustring;
  SingleProcess, NoSandbox, CommandLineArgsDisabled, PackLoadingDisabled: Boolean; RemoteDebuggingPort: Integer;
  UncaughtExceptionStackSize: Integer; ContextSafetyImplementation: Integer;
  PersistSessionCookies: Boolean; IgnoreCertificateErrors: Boolean; BackgroundColor: TCefColor;
  const AcceptLanguageList: ustring; WindowsSandboxInfo: Pointer; WindowlessRenderingEnabled: Boolean): Boolean;
var
  settings: TCefSettings;
  app: ICefApp;
  errcode: Integer;
begin
  if LibHandle = 0 then
  begin
    // deactivate FPU exception FPU & SSE2
    SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide, exOverflow, exUnderflow, exPrecision]);

    LibHandle := LoadLibrary(PChar(CefLibrary));
    if LibHandle = 0 then
      RaiseLastOSError;

    cef_string_wide_set := GetProcAddress(LibHandle, 'cef_string_wide_set');
    cef_string_utf8_set := GetProcAddress(LibHandle, 'cef_string_utf8_set');
    cef_string_utf16_set := GetProcAddress(LibHandle, 'cef_string_utf16_set');
    cef_string_wide_clear := GetProcAddress(LibHandle, 'cef_string_wide_clear');
    cef_string_utf8_clear := GetProcAddress(LibHandle, 'cef_string_utf8_clear');
    cef_string_utf16_clear := GetProcAddress(LibHandle, 'cef_string_utf16_clear');
    cef_string_wide_cmp := GetProcAddress(LibHandle, 'cef_string_wide_cmp');
    cef_string_utf8_cmp := GetProcAddress(LibHandle, 'cef_string_utf8_cmp');
    cef_string_utf16_cmp := GetProcAddress(LibHandle, 'cef_string_utf16_cmp');
    cef_string_wide_to_utf8 := GetProcAddress(LibHandle, 'cef_string_wide_to_utf8');
    cef_string_utf8_to_wide := GetProcAddress(LibHandle, 'cef_string_utf8_to_wide');
    cef_string_wide_to_utf16 := GetProcAddress(LibHandle, 'cef_string_wide_to_utf16');
    cef_string_utf16_to_wide := GetProcAddress(LibHandle, 'cef_string_utf16_to_wide');
    cef_string_utf8_to_utf16 := GetProcAddress(LibHandle, 'cef_string_utf8_to_utf16');
    cef_string_utf16_to_utf8 := GetProcAddress(LibHandle, 'cef_string_utf16_to_utf8');
    cef_string_ascii_to_wide := GetProcAddress(LibHandle, 'cef_string_ascii_to_wide');
    cef_string_ascii_to_utf16 := GetProcAddress(LibHandle, 'cef_string_ascii_to_utf16');
    cef_string_userfree_wide_alloc := GetProcAddress(LibHandle, 'cef_string_userfree_wide_alloc');
    cef_string_userfree_utf8_alloc := GetProcAddress(LibHandle, 'cef_string_userfree_utf8_alloc');
    cef_string_userfree_utf16_alloc := GetProcAddress(LibHandle, 'cef_string_userfree_utf16_alloc');
    cef_string_userfree_wide_free := GetProcAddress(LibHandle, 'cef_string_userfree_wide_free');
    cef_string_userfree_utf8_free := GetProcAddress(LibHandle, 'cef_string_userfree_utf8_free');
    cef_string_userfree_utf16_free := GetProcAddress(LibHandle, 'cef_string_userfree_utf16_free');

{$IFDEF CEF_STRING_TYPE_UTF8}
  cef_string_set := cef_string_utf8_set;
  cef_string_clear := cef_string_utf8_clear;
  cef_string_userfree_alloc := cef_string_userfree_utf8_alloc;
  cef_string_userfree_free := cef_string_userfree_utf8_free;
  cef_string_from_ascii := cef_string_utf8_copy;
  cef_string_to_utf8 := cef_string_utf8_copy;
  cef_string_from_utf8 := cef_string_utf8_copy;
  cef_string_to_utf16 := cef_string_utf8_to_utf16;
  cef_string_from_utf16 := cef_string_utf16_to_utf8;
  cef_string_to_wide := cef_string_utf8_to_wide;
  cef_string_from_wide := cef_string_wide_to_utf8;
{$ENDIF}

{$IFDEF CEF_STRING_TYPE_UTF16}
    cef_string_set := cef_string_utf16_set;
    cef_string_clear := cef_string_utf16_clear;
    cef_string_userfree_alloc := cef_string_userfree_utf16_alloc;
    cef_string_userfree_free := cef_string_userfree_utf16_free;
    cef_string_from_ascii := cef_string_ascii_to_utf16;
    cef_string_to_utf8 := cef_string_utf16_to_utf8;
    cef_string_from_utf8 := cef_string_utf8_to_utf16;
    cef_string_to_utf16 := cef_string_utf16_copy;
    cef_string_from_utf16 := cef_string_utf16_copy;
    cef_string_to_wide := cef_string_utf16_to_wide;
    cef_string_from_wide := cef_string_wide_to_utf16;
{$ENDIF}

{$IFDEF CEF_STRING_TYPE_WIDE}
    cef_string_set := cef_string_wide_set;
    cef_string_clear := cef_string_wide_clear;
    cef_string_userfree_alloc := cef_string_userfree_wide_alloc;
    cef_string_userfree_free := cef_string_userfree_wide_free;
    cef_string_from_ascii := cef_string_ascii_to_wide;
    cef_string_to_utf8 := cef_string_wide_to_utf8;
    cef_string_from_utf8 := cef_string_utf8_to_wide;
    cef_string_to_utf16 := cef_string_wide_to_utf16;
    cef_string_from_utf16 := cef_string_utf16_to_wide;
    cef_string_to_wide := cef_string_wide_copy;
    cef_string_from_wide := cef_string_wide_copy;
{$ENDIF}

    cef_string_map_alloc := GetProcAddress(LibHandle, 'cef_string_map_alloc');
    cef_string_map_size := GetProcAddress(LibHandle, 'cef_string_map_size');
    cef_string_map_find := GetProcAddress(LibHandle, 'cef_string_map_find');
    cef_string_map_key := GetProcAddress(LibHandle, 'cef_string_map_key');
    cef_string_map_value := GetProcAddress(LibHandle, 'cef_string_map_value');
    cef_string_map_append := GetProcAddress(LibHandle, 'cef_string_map_append');
    cef_string_map_clear := GetProcAddress(LibHandle, 'cef_string_map_clear');
    cef_string_map_free := GetProcAddress(LibHandle, 'cef_string_map_free');
    cef_string_list_alloc := GetProcAddress(LibHandle, 'cef_string_list_alloc');
    cef_string_list_size := GetProcAddress(LibHandle, 'cef_string_list_size');
    cef_string_list_value := GetProcAddress(LibHandle, 'cef_string_list_value');
    cef_string_list_append := GetProcAddress(LibHandle, 'cef_string_list_append');
    cef_string_list_clear := GetProcAddress(LibHandle, 'cef_string_list_clear');
    cef_string_list_free := GetProcAddress(LibHandle, 'cef_string_list_free');
    cef_string_list_copy := GetProcAddress(LibHandle, 'cef_string_list_copy');
    cef_initialize := GetProcAddress(LibHandle, 'cef_initialize');
    cef_execute_process := GetProcAddress(LibHandle, 'cef_execute_process');
    cef_shutdown := GetProcAddress(LibHandle, 'cef_shutdown');
    cef_do_message_loop_work := GetProcAddress(LibHandle, 'cef_do_message_loop_work');
    cef_run_message_loop := GetProcAddress(LibHandle, 'cef_run_message_loop');
    cef_quit_message_loop := GetProcAddress(LibHandle, 'cef_quit_message_loop');
    cef_set_osmodal_loop := GetProcAddress(LibHandle, 'cef_set_osmodal_loop');
    cef_enable_highdpi_support := GetProcAddress(LibHandle, 'cef_enable_highdpi_support');
    cef_register_extension := GetProcAddress(LibHandle, 'cef_register_extension');
    cef_register_scheme_handler_factory := GetProcAddress(LibHandle, 'cef_register_scheme_handler_factory');
    cef_clear_scheme_handler_factories := GetProcAddress(LibHandle, 'cef_clear_scheme_handler_factories');
    cef_add_cross_origin_whitelist_entry := GetProcAddress(LibHandle, 'cef_add_cross_origin_whitelist_entry');
    cef_remove_cross_origin_whitelist_entry := GetProcAddress(LibHandle, 'cef_remove_cross_origin_whitelist_entry');
    cef_clear_cross_origin_whitelist := GetProcAddress(LibHandle, 'cef_clear_cross_origin_whitelist');
    cef_currently_on := GetProcAddress(LibHandle, 'cef_currently_on');
    cef_post_task := GetProcAddress(LibHandle, 'cef_post_task');
    cef_post_delayed_task := GetProcAddress(LibHandle, 'cef_post_delayed_task');
    cef_parse_url := GetProcAddress(LibHandle, 'cef_parse_url');
    cef_create_url := GetProcAddress(LibHandle, 'cef_create_url');
    cef_get_mime_type := GetProcAddress(LibHandle, 'cef_get_mime_type');
    cef_get_extensions_for_mime_type := GetProcAddress(LibHandle, 'cef_get_extensions_for_mime_type');
    cef_base64encode := GetProcAddress(LibHandle, 'cef_base64encode');
    cef_base64decode := GetProcAddress(LibHandle, 'cef_base64decode');
    cef_uriencode := GetProcAddress(LibHandle, 'cef_uriencode');
    cef_uridecode := GetProcAddress(LibHandle, 'cef_uridecode');
    cef_parse_csscolor := GetProcAddress(LibHandle, 'cef_parse_csscolor');
{$ifdef Win32}
    cef_parse_json := GetProcAddress(LibHandle, 'cef_parse_json');
    cef_parse_jsonand_return_error := GetProcAddress(LibHandle, 'cef_parse_jsonand_return_error');
    cef_write_json := GetProcAddress(LibHandle, 'cef_write_json');
{$endif}
    cef_browser_host_create_browser := GetProcAddress(LibHandle, 'cef_browser_host_create_browser');
    cef_browser_host_create_browser_sync := GetProcAddress(LibHandle, 'cef_browser_host_create_browser_sync');
    cef_request_create := GetProcAddress(LibHandle, 'cef_request_create');
    cef_post_data_create := GetProcAddress(LibHandle, 'cef_post_data_create');
    cef_post_data_element_create := GetProcAddress(LibHandle, 'cef_post_data_element_create');
    cef_stream_reader_create_for_file := GetProcAddress(LibHandle, 'cef_stream_reader_create_for_file');
    cef_stream_reader_create_for_data := GetProcAddress(LibHandle, 'cef_stream_reader_create_for_data');
    cef_stream_reader_create_for_handler := GetProcAddress(LibHandle, 'cef_stream_reader_create_for_handler');
    cef_stream_writer_create_for_file := GetProcAddress(LibHandle, 'cef_stream_writer_create_for_file');
    cef_stream_writer_create_for_handler := GetProcAddress(LibHandle, 'cef_stream_writer_create_for_handler');
    cef_v8context_get_current_context := GetProcAddress(LibHandle, 'cef_v8context_get_current_context');
    cef_v8context_get_entered_context := GetProcAddress(LibHandle, 'cef_v8context_get_entered_context');
    cef_v8context_in_context := GetProcAddress(LibHandle, 'cef_v8context_in_context');
    cef_v8value_create_undefined := GetProcAddress(LibHandle, 'cef_v8value_create_undefined');
    cef_v8value_create_null := GetProcAddress(LibHandle, 'cef_v8value_create_null');
    cef_v8value_create_bool := GetProcAddress(LibHandle, 'cef_v8value_create_bool');
    cef_v8value_create_int := GetProcAddress(LibHandle, 'cef_v8value_create_int');
    cef_v8value_create_uint := GetProcAddress(LibHandle, 'cef_v8value_create_uint');
    cef_v8value_create_double := GetProcAddress(LibHandle, 'cef_v8value_create_double');
    cef_v8value_create_date := GetProcAddress(LibHandle, 'cef_v8value_create_date');
    cef_v8value_create_string := GetProcAddress(LibHandle, 'cef_v8value_create_string');
    cef_v8value_create_object := GetProcAddress(LibHandle, 'cef_v8value_create_object');
    cef_v8value_create_array := GetProcAddress(LibHandle, 'cef_v8value_create_array');
    cef_v8value_create_function := GetProcAddress(LibHandle, 'cef_v8value_create_function');
    cef_v8stack_trace_get_current := GetProcAddress(LibHandle, 'cef_v8stack_trace_get_current');
    cef_xml_reader_create := GetProcAddress(LibHandle, 'cef_xml_reader_create');
    cef_zip_reader_create := GetProcAddress(LibHandle, 'cef_zip_reader_create');

    cef_string_multimap_alloc := GetProcAddress(LibHandle, 'cef_string_multimap_alloc');
    cef_string_multimap_size := GetProcAddress(LibHandle, 'cef_string_multimap_size');
    cef_string_multimap_find_count := GetProcAddress(LibHandle, 'cef_string_multimap_find_count');
    cef_string_multimap_enumerate := GetProcAddress(LibHandle, 'cef_string_multimap_enumerate');
    cef_string_multimap_key := GetProcAddress(LibHandle, 'cef_string_multimap_key');
    cef_string_multimap_value := GetProcAddress(LibHandle, 'cef_string_multimap_value');
    cef_string_multimap_append := GetProcAddress(LibHandle, 'cef_string_multimap_append');
    cef_string_multimap_clear := GetProcAddress(LibHandle, 'cef_string_multimap_clear');
    cef_string_multimap_free := GetProcAddress(LibHandle, 'cef_string_multimap_free');

    cef_cookie_manager_get_global_manager := GetProcAddress(LibHandle, 'cef_cookie_manager_get_global_manager');
    cef_cookie_manager_create_manager := GetProcAddress(LibHandle, 'cef_cookie_manager_create_manager');


    cef_command_line_create := GetProcAddress(LibHandle, 'cef_command_line_create');

    cef_command_line_get_global := GetProcAddress(LibHandle, 'cef_command_line_get_global');

    cef_process_message_create := GetProcAddress(LibHandle, 'cef_process_message_create');

    cef_value_create := GetProcAddress(LibHandle, 'cef_value_create');

    cef_binary_value_create := GetProcAddress(LibHandle, 'cef_binary_value_create');

    cef_dictionary_value_create := GetProcAddress(LibHandle, 'cef_dictionary_value_create');

    cef_list_value_create := GetProcAddress(LibHandle, 'cef_list_value_create');

    cef_get_path := GetProcAddress(LibHandle, 'cef_get_path');

    cef_launch_process := GetProcAddress(LibHandle, 'cef_launch_process');

    cef_response_create := GetProcAddress(LibHandle, 'cef_response_create');

    cef_urlrequest_create := GetProcAddress(LibHandle, 'cef_urlrequest_create');

    cef_visit_web_plugin_info := GetProcAddress(LibHandle, 'cef_visit_web_plugin_info');
    cef_refresh_web_plugins := GetProcAddress(LibHandle, 'cef_refresh_web_plugins');
    cef_add_web_plugin_path := GetProcAddress(LibHandle, 'cef_add_web_plugin_path');
    cef_add_web_plugin_directory := GetProcAddress(LibHandle, 'cef_add_web_plugin_directory');
    cef_remove_web_plugin_path := GetProcAddress(LibHandle, 'cef_remove_web_plugin_path');
    cef_unregister_internal_web_plugin := GetProcAddress(LibHandle, 'cef_unregister_internal_web_plugin');
    cef_force_web_plugin_shutdown := GetProcAddress(LibHandle, 'cef_force_web_plugin_shutdown');
    cef_register_web_plugin_crash := GetProcAddress(LibHandle, 'cef_register_web_plugin_crash');
    cef_is_web_plugin_unstable := GetProcAddress(LibHandle, 'cef_is_web_plugin_unstable');

    cef_get_geolocation := GetProcAddress(LibHandle, 'cef_get_geolocation');

    cef_task_runner_get_for_current_thread := GetProcAddress(LibHandle, 'cef_task_runner_get_for_current_thread');
    cef_task_runner_get_for_thread := GetProcAddress(LibHandle, 'cef_task_runner_get_for_thread');

    cef_begin_tracing := GetProcAddress(LibHandle, 'cef_begin_tracing');
    cef_end_tracing := GetProcAddress(LibHandle, 'cef_end_tracing');
    cef_now_from_system_trace_time := GetProcAddress(LibHandle, 'cef_now_from_system_trace_time');

    cef_request_context_get_global_context := GetProcAddress(LibHandle, 'cef_request_context_get_global_context');
    cef_request_context_create_context := GetProcAddress(LibHandle, 'cef_request_context_create_context');
    create_context_shared := GetProcAddress(LibHandle, 'create_context_shared');

    cef_get_min_log_level := GetProcAddress(LibHandle, 'cef_get_min_log_level');
    cef_get_vlog_level := GetProcAddress(LibHandle, 'cef_get_vlog_level');
    cef_log := GetProcAddress(LibHandle, 'cef_log');

    cef_get_current_platform_thread_id := GetProcAddress(LibHandle, 'cef_get_current_platform_thread_id');
    cef_get_current_platform_thread_handle := GetProcAddress(LibHandle, 'cef_get_current_platform_thread_handle');

    cef_trace_event_instant := GetProcAddress(LibHandle, 'cef_trace_event_instant');
    cef_trace_event_begin := GetProcAddress(LibHandle, 'cef_trace_event_begin');
    cef_trace_event_end := GetProcAddress(LibHandle, 'cef_trace_event_end');
    cef_trace_counter := GetProcAddress(LibHandle, 'cef_trace_counter');
    cef_trace_counter_id := GetProcAddress(LibHandle, 'cef_trace_counter_id');
    cef_trace_event_async_begin := GetProcAddress(LibHandle, 'cef_trace_event_async_begin');
    cef_trace_event_async_step_into := GetProcAddress(LibHandle, 'cef_trace_event_async_step_into');
    cef_trace_event_async_step_past := GetProcAddress(LibHandle, 'cef_trace_event_async_step_past');
    cef_trace_event_async_end := GetProcAddress(LibHandle, 'cef_trace_event_async_end');

    cef_print_settings_create := GetProcAddress(LibHandle, 'cef_print_settings_create');

    cef_drag_data_create := GetProcAddress(LibHandle, 'cef_drag_data_create');

    cef_resource_bundle_get_global := GetProcAddress(LibHandle, 'cef_resource_bundle_get_global');

    if not (
      Assigned(cef_string_wide_set) and
      Assigned(cef_string_utf8_set) and
      Assigned(cef_string_utf16_set) and
      Assigned(cef_string_wide_clear) and
      Assigned(cef_string_utf8_clear) and
      Assigned(cef_string_utf16_clear) and
      Assigned(cef_string_wide_cmp) and
      Assigned(cef_string_utf8_cmp) and
      Assigned(cef_string_utf16_cmp) and
      Assigned(cef_string_wide_to_utf8) and
      Assigned(cef_string_utf8_to_wide) and
      Assigned(cef_string_wide_to_utf16) and
      Assigned(cef_string_utf16_to_wide) and
      Assigned(cef_string_utf8_to_utf16) and
      Assigned(cef_string_utf16_to_utf8) and
      Assigned(cef_string_ascii_to_wide) and
      Assigned(cef_string_ascii_to_utf16) and
      Assigned(cef_string_userfree_wide_alloc) and
      Assigned(cef_string_userfree_utf8_alloc) and
      Assigned(cef_string_userfree_utf16_alloc) and
      Assigned(cef_string_userfree_wide_free) and
      Assigned(cef_string_userfree_utf8_free) and
      Assigned(cef_string_userfree_utf16_free) and
      Assigned(cef_string_map_alloc) and
      Assigned(cef_string_map_size) and
      Assigned(cef_string_map_find) and
      Assigned(cef_string_map_key) and
      Assigned(cef_string_map_value) and
      Assigned(cef_string_map_append) and
      Assigned(cef_string_map_clear) and
      Assigned(cef_string_map_free) and
      Assigned(cef_string_list_alloc) and
      Assigned(cef_string_list_size) and
      Assigned(cef_string_list_value) and
      Assigned(cef_string_list_append) and
      Assigned(cef_string_list_clear) and
      Assigned(cef_string_list_free) and
      Assigned(cef_string_list_copy) and
      Assigned(cef_initialize) and
      Assigned(cef_execute_process) and
      Assigned(cef_shutdown) and
      Assigned(cef_do_message_loop_work) and
      Assigned(cef_run_message_loop) and
      Assigned(cef_quit_message_loop) and
      Assigned(cef_set_osmodal_loop) and
      Assigned(cef_enable_highdpi_support) and
      Assigned(cef_register_extension) and
      Assigned(cef_register_scheme_handler_factory) and
      Assigned(cef_clear_scheme_handler_factories) and
      Assigned(cef_add_cross_origin_whitelist_entry) and
      Assigned(cef_remove_cross_origin_whitelist_entry) and
      Assigned(cef_clear_cross_origin_whitelist) and
      Assigned(cef_currently_on) and
      Assigned(cef_post_task) and
      Assigned(cef_post_delayed_task) and
      Assigned(cef_parse_url) and
      Assigned(cef_create_url) and
      Assigned(cef_get_mime_type) and
      Assigned(cef_get_extensions_for_mime_type) and
      Assigned(cef_base64encode) and
      Assigned(cef_base64decode) and
      Assigned(cef_uriencode) and
      Assigned(cef_uridecode) and
      Assigned(cef_parse_csscolor) and
{$ifdef Win32}
      Assigned(cef_parse_json) and
      Assigned(cef_parse_jsonand_return_error) and
      Assigned(cef_write_json) and
{$endif}
      Assigned(cef_browser_host_create_browser) and
      Assigned(cef_browser_host_create_browser_sync) and
      Assigned(cef_request_create) and
      Assigned(cef_post_data_create) and
      Assigned(cef_post_data_element_create) and
      Assigned(cef_stream_reader_create_for_file) and
      Assigned(cef_stream_reader_create_for_data) and
      Assigned(cef_stream_reader_create_for_handler) and
      Assigned(cef_stream_writer_create_for_file) and
      Assigned(cef_stream_writer_create_for_handler) and
      Assigned(cef_v8context_get_current_context) and
      Assigned(cef_v8context_get_entered_context) and
      Assigned(cef_v8context_in_context) and
      Assigned(cef_v8value_create_undefined) and
      Assigned(cef_v8value_create_null) and
      Assigned(cef_v8value_create_bool) and
      Assigned(cef_v8value_create_int) and
      Assigned(cef_v8value_create_uint) and
      Assigned(cef_v8value_create_double) and
      Assigned(cef_v8value_create_date) and
      Assigned(cef_v8value_create_string) and
      Assigned(cef_v8value_create_object) and
      Assigned(cef_v8value_create_array) and
      Assigned(cef_v8value_create_function) and
      Assigned(cef_v8stack_trace_get_current) and
      Assigned(cef_xml_reader_create) and
      Assigned(cef_zip_reader_create) and
      Assigned(cef_string_multimap_alloc) and
      Assigned(cef_string_multimap_size) and
      Assigned(cef_string_multimap_find_count) and
      Assigned(cef_string_multimap_enumerate) and
      Assigned(cef_string_multimap_key) and
      Assigned(cef_string_multimap_value) and
      Assigned(cef_string_multimap_append) and
      Assigned(cef_string_multimap_clear) and
      Assigned(cef_string_multimap_free) and
      Assigned(cef_cookie_manager_get_global_manager) and
      Assigned(cef_cookie_manager_create_manager) and
      Assigned(cef_command_line_create) and
      Assigned(cef_command_line_get_global) and
      Assigned(cef_process_message_create) and
      Assigned(cef_value_create) and
      Assigned(cef_binary_value_create) and
      Assigned(cef_dictionary_value_create) and
      Assigned(cef_list_value_create) and
      Assigned(cef_get_path) and
      Assigned(cef_launch_process) and
      Assigned(cef_response_create) and
      Assigned(cef_urlrequest_create) and
      Assigned(cef_visit_web_plugin_info) and
      Assigned(cef_refresh_web_plugins) and
      Assigned(cef_add_web_plugin_path) and
      Assigned(cef_add_web_plugin_directory) and
      Assigned(cef_remove_web_plugin_path) and
      Assigned(cef_unregister_internal_web_plugin) and
      Assigned(cef_force_web_plugin_shutdown) and
      Assigned(cef_register_web_plugin_crash) and
      Assigned(cef_is_web_plugin_unstable) and
      Assigned(cef_get_geolocation) and
      Assigned(cef_task_runner_get_for_current_thread) and
      Assigned(cef_task_runner_get_for_thread) and
      Assigned(cef_begin_tracing) and
      Assigned(cef_end_tracing) and
      Assigned(cef_now_from_system_trace_time) and
      Assigned(cef_request_context_get_global_context) and
      Assigned(cef_request_context_create_context) and
      Assigned(create_context_shared) and
      Assigned(cef_get_min_log_level) and
      Assigned(cef_get_vlog_level) and
      Assigned(cef_log) and
      Assigned(cef_get_current_platform_thread_id) and
      Assigned(cef_get_current_platform_thread_handle) and
      Assigned(cef_trace_event_instant) and
      Assigned(cef_trace_event_begin) and
      Assigned(cef_trace_event_end) and
      Assigned(cef_trace_counter) and
      Assigned(cef_trace_counter_id) and
      Assigned(cef_trace_event_async_begin) and
      Assigned(cef_trace_event_async_step_into) and
      Assigned(cef_trace_event_async_step_past) and
      Assigned(cef_trace_event_async_end) and
      Assigned(cef_print_settings_create) and
      Assigned(cef_drag_data_create) and
      Assigned(cef_resource_bundle_get_global)
    ) then raise ECefException.Create('Invalid CEF Library version');

    FillChar(settings, SizeOf(settings), 0);
    settings.size := SizeOf(settings);
    settings.single_process := Ord(SingleProcess);
    settings.no_sandbox := Ord(NoSandbox);
{$IFNDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
    settings.multi_threaded_message_loop := Ord(False);
{$ELSE}
    settings.multi_threaded_message_loop := Ord(True);
{$ENDIF}
    settings.windowless_rendering_enabled := Ord(WindowlessRenderingEnabled);
    settings.cache_path := CefString(Cache);
    settings.user_data_path := CefString(UserDataPath);
    settings.persist_session_cookies := Ord(PersistSessionCookies);
    settings.browser_subprocess_path := CefString(BrowserSubprocessPath);
    settings.command_line_args_disabled := Ord(CommandLineArgsDisabled);
    settings.user_agent := cefstring(UserAgent);
    settings.product_version := CefString(ProductVersion);
    settings.locale := CefString(Locale);
    settings.log_file := CefString(LogFile);
    settings.log_severity := LogSeverity;
    settings.javascript_flags := CefString(JavaScriptFlags);
    settings.resources_dir_path := CefString(ResourcesDirPath);
    settings.locales_dir_path := CefString(LocalesDirPath);
    settings.pack_loading_disabled := Ord(PackLoadingDisabled);
    settings.remote_debugging_port := RemoteDebuggingPort;
    settings.uncaught_exception_stack_size := UncaughtExceptionStackSize;
    settings.context_safety_implementation := ContextSafetyImplementation;
    settings.ignore_certificate_errors := Ord(IgnoreCertificateErrors);
    settings.background_color := BackgroundColor;
    settings.accept_language_list := CefString(AcceptLanguageList);

    app := TInternalApp.Create;
    errcode := cef_execute_process(@HInstance, CefGetData(app), WindowsSandboxInfo);
    if errcode >= 0 then
    begin
      Result := False;
      Exit;
    end;
    cef_initialize(@HInstance, @settings, CefGetData(app), WindowsSandboxInfo);
    CefIsMainProcess := True;
  end;
  Result := True;
end;

{$IFNDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
procedure CefDoMessageLoopWork;
begin
  if LibHandle > 0 then
    cef_do_message_loop_work;
end;

procedure CefRunMessageLoop;
begin
  if LibHandle > 0 then
    cef_run_message_loop;
end;

procedure CefQuitMessageLoop;
begin
  cef_quit_message_loop;
end;

procedure CefSetOsModalLoop(loop: Boolean);
begin
  cef_set_osmodal_loop(Ord(loop));
end;
{$ENDIF}

procedure CefEnableHighDpiSupport;
begin
  cef_enable_highdpi_support();
end;

procedure CefShutDown;
begin
  if LibHandle <> 0 then
  begin
    if CefIsMainProcess then
      cef_shutdown;
    FreeLibrary(LibHandle);
    LibHandle := 0;
  end;
end;

function CefString(const str: ustring): TCefString;
begin
   Result.str := PChar16(PWideChar(str));
   Result.length := Length(str);
   Result.dtor := nil;
end;

function CefString(const str: PCefString): ustring;
begin
  if str <> nil then
    SetString(Result, str.str, str.length) else
    Result := '';
end;

procedure _free_string(str: PChar16); stdcall;
begin
  if str <> nil then
    FreeMem(str);
end;

function CefUserFreeString(const str: ustring): PCefStringUserFree;
begin
  Result := cef_string_userfree_alloc;
  Result.length := Length(str);
  GetMem(Result.str, Result.length * SizeOf(TCefChar));
  Move(PCefChar(str)^, Result.str^, Result.length * SizeOf(TCefChar));
  Result.dtor := @_free_string;
end;

function CefStringAlloc(const str: ustring): TCefString;
begin
  FillChar(Result, SizeOf(Result), 0);
  if str <> '' then
    cef_string_from_wide(PWideChar(str), Length(str), @Result);
end;

procedure CefStringSet(const str: PCefString; const value: ustring);
begin
  if str <> nil then
    cef_string_set(PWideChar(value), Length(value), str, 1);
end;

function CefStringClearAndGet(var str: TCefString): ustring;
begin
  Result := CefString(@str);
  cef_string_clear(@str);
end;

function CefStringFreeAndGet(const str: PCefStringUserFree): ustring;
begin
  if str <> nil then
  begin
    Result := CefString(PCefString(str));
    cef_string_userfree_free(str);
  end else
    Result := '';
end;

procedure CefStringFree(const str: PCefString);
begin
  if str <> nil then
    cef_string_clear(str);
end;

function CefRegisterSchemeHandlerFactory(const SchemeName, HostName: ustring;
  const handler: TCefResourceHandlerClass): Boolean;
var
  s, h: TCefString;
begin
  CefLoadLibDefault;
  s := CefString(SchemeName);
  h := CefString(HostName);
  Result := cef_register_scheme_handler_factory(
    @s,
    @h,
    CefGetData(TCefSchemeHandlerFactoryOwn.Create(handler) as ICefBase)) <> 0;
end;

function CefRegisterSchemeHandlerFactory(const SchemeName, HostName: ustring;
  const factory: ICefSchemeHandlerFactory): Boolean; overload;
var
  s, h: TCefString;
begin
  CefLoadLibDefault;
  s := CefString(SchemeName);
  h := CefString(HostName);
  Result := cef_register_scheme_handler_factory(
    @s,
    @h,
    CefGetData(factory as ICefBase)) <> 0;
end;

function CefClearSchemeHandlerFactories: Boolean;
begin
  CefLoadLibDefault;
  Result := cef_clear_scheme_handler_factories <> 0;
end;

function CefAddCrossOriginWhitelistEntry(const SourceOrigin, TargetProtocol,
  TargetDomain: ustring; AllowTargetSubdomains: Boolean): Boolean;
var
  so, tp, td: TCefString;
begin
  CefLoadLibDefault;
  so := CefString(SourceOrigin);
  tp := CefString(TargetProtocol);
  td := CefString(TargetDomain);
  Result := cef_add_cross_origin_whitelist_entry(@so, @tp, @td, Ord(AllowTargetSubdomains)) <> 0;
end;

function CefRemoveCrossOriginWhitelistEntry(
  const SourceOrigin, TargetProtocol, TargetDomain: ustring;
  AllowTargetSubdomains: Boolean): Boolean;
var
  so, tp, td: TCefString;
begin
  CefLoadLibDefault;
  so := CefString(SourceOrigin);
  tp := CefString(TargetProtocol);
  td := CefString(TargetDomain);
  Result := cef_remove_cross_origin_whitelist_entry(@so, @tp, @td, Ord(AllowTargetSubdomains)) <> 0;
end;

function CefClearCrossOriginWhitelist: Boolean;
begin
  CefLoadLibDefault;
  Result := cef_clear_cross_origin_whitelist <> 0;
end;

function CefRegisterExtension(const name, code: ustring;
  const Handler: ICefv8Handler): Boolean;
var
  n, c: TCefString;
begin
  CefLoadLibDefault;
  n := CefString(name);
  c := CefString(code);
  Result := cef_register_extension(@n, @c, CefGetData(handler)) <> 0;
end;

function CefCurrentlyOn(ThreadId: TCefThreadId): Boolean;
begin
  Result := cef_currently_on(ThreadId) <> 0;
end;

procedure CefPostTask(ThreadId: TCefThreadId; const task: ICefTask);
begin
  cef_post_task(ThreadId, CefGetData(task));
end;

procedure CefPostDelayedTask(ThreadId: TCefThreadId; const task: ICefTask; delayMs: Int64);
begin
  cef_post_delayed_task(ThreadId, CefGetData(task), delayMs);
end;

function CefGetData(const i: ICefBase): Pointer; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
begin
  if i <> nil then
    Result := i.Wrap else
    Result := nil;
end;

function CefGetObject(ptr: Pointer): TObject; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
begin
  Dec(PByte(ptr), SizeOf(Pointer));
  Result := TObject(PPointer(ptr)^);
end;

function CefParseUrl(const url: ustring; var parts: TUrlParts): Boolean;
var
  u: TCefString;
  p: TCefUrlParts;
begin
  FillChar(p, sizeof(p), 0);
  u := CefString(url);
  Result := cef_parse_url(@u, p) <> 0;
  if Result then
  begin
    //parts.spec := CefString(@p.spec);
    parts.scheme := CefString(@p.scheme);
    parts.username := CefString(@p.username);
    parts.password := CefString(@p.password);
    parts.host := CefString(@p.host);
    parts.port := CefString(@p.port);
    parts.origin := CefString(@p.origin);
    parts.path := CefString(@p.path);
    parts.query := CefString(@p.query);
  end;
end;

function CefCreateUrl(var parts: TUrlParts): ustring;
var
  p: TCefUrlParts;
  u: TCefString;
begin
  FillChar(p, sizeof(p), 0);
  p.spec := CefString(parts.spec);
  p.scheme := CefString(parts.scheme);
  p.username := CefString(parts.username);
  p.password := CefString(parts.password);
  p.host := CefString(parts.host);
  p.port := CefString(parts.port);
  p.origin := CefString(parts.origin);
  p.path := CefString(parts.path);
  p.query := CefString(parts.query);
  FillChar(u, SizeOf(u), 0);
  if cef_create_url(@p, @u) <> 0 then
    Result := CefString(@u) else
    Result := '';
end;

function CefGetMimeType(const extension: ustring): ustring;
var
  s: TCefString;
begin
  s := CefString(extension);
  Result := CefStringFreeAndGet(cef_get_mime_type(@s))
end;

procedure CefGetExtensionsForMimeType(const mimeType: ustring; extensions: TStringList);
var
  list: TCefStringList;
  s, str: TCefString;
  i: Integer;
begin
  list := cef_string_list_alloc();
  try
    s := CefString(mimeType);
    cef_get_extensions_for_mime_type(@s, list);
    for i := 0 to cef_string_list_size(list) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(list, i, @str);
      extensions.Add(CefStringClearAndGet(str));
    end;
  finally
    cef_string_list_free(list);
  end;
end;

function CefBase64Encode(const data: Pointer; dataSize: NativeUInt): ustring;
begin
  Result:= CefStringFreeAndGet(cef_base64encode(data, dataSize));
end;

function CefBase64Decode(const data: ustring): ICefBinaryValue;
var
  s: TCefString;
begin
  s := CefString(data);
  Result := TCefBinaryValueRef.UnWrap(cef_base64decode(@s));
end;

function CefUriEncode(const text: ustring; usePlus: Boolean): ustring;
var
  s: TCefString;
begin
  s := CefString(text);
  Result := CefStringFreeAndGet(cef_uriencode(@s, Ord(usePlus)));
end;

function CefUriDecode(const text: ustring; convertToUtf8: Boolean;
  unescapeRule: TCefUriUnescapeRule): ustring;
var
  s: TCefString;
begin
  s := CefString(text);
  Result := CefStringFreeAndGet(cef_uridecode(@s, Ord(convertToUtf8), unescapeRule));
end;

function CefParseCssColor(const str: ustring; strict: Boolean; out color: TCefColor): Boolean;
var
  s: TCefString;
begin
  s := CefString(str);
  Result := cef_parse_csscolor(@s, Ord(strict), @color) <> 0;
end;

{$ifdef Win32}
function CefParseJson(const jsonString: ustring; options: TCefJsonParserOptions): ICefValue;
var
  s: TCefString;
begin
  s := CefString(jsonString);
  Result := TCefValueRef.UnWrap(cef_parse_json(@s, options));
end;

function CefParseJsonAndReturnError(const jsonString: ustring; options: TCefJsonParserOptions;
  out errorCodeOut: TCefJsonParserError; out errorMsgOut: ustring): ICefValue;
var
  s, e: TCefString;
begin
  s := CefString(jsonString);
  FillChar(e, SizeOf(e), 0);
  Result := TCefValueRef.UnWrap(cef_parse_jsonand_return_error(@s, options,
    @errorCodeOut, @e));
  errorMsgOut := CefString(@e);
end;

function CefWriteJson(const node: ICefValue; options: TCefJsonWriterOptions): ustring;
begin
  Result := CefStringFreeAndGet(cef_write_json(CefGetData(node), options));
end;
{$endif}

function CefBrowserHostCreate(windowInfo: PCefWindowInfo; const client: ICefClient;
  const url: ustring; const settings: PCefBrowserSettings; const requestContext: ICefRequestContext): Boolean;
var
  u: TCefString;
begin
  CefLoadLibDefault;
  u := CefString(url);
  Result := cef_browser_host_create_browser(windowInfo, CefGetData(client),
    @u, settings, CefGetData(requestContext)) <> 0;
end;

function CefBrowserHostCreateSync(windowInfo: PCefWindowInfo; const client: ICefClient;
  const url: ustring; const settings: PCefBrowserSettings; const requestContext: ICefRequestContext): ICefBrowser;
var
  u: TCefString;
begin
  CefLoadLibDefault;
  u := CefString(url);
  Result := TCefBrowserRef.UnWrap(cef_browser_host_create_browser_sync(windowInfo,
    CefGetData(client), @u, settings, CefGetData(requestContext)));
end;

procedure CefVisitWebPluginInfo(const visitor: ICefWebPluginInfoVisitor);
begin
  cef_visit_web_plugin_info(CefGetData(visitor));
end;

procedure CefVisitWebPluginInfoProc(const visitor: TCefWebPluginInfoVisitorProc);
begin
  CefVisitWebPluginInfo(TCefFastWebPluginInfoVisitor.Create(visitor));
end;

procedure CefRefreshWebPlugins;
begin
  cef_refresh_web_plugins();
end;

procedure CefAddWebPluginPath(const path: ustring);
var
  p: TCefString;
begin
  p := CefString(path);
  cef_add_web_plugin_path(@p);
end;

procedure CefAddWebPluginDirectory(const dir: ustring);
var
  d: TCefString;
begin
  d := CefString(dir);
  cef_add_web_plugin_directory(@d);
end;

procedure CefRemoveWebPluginPath(const path: ustring);
var
  p: TCefString;
begin
  p := CefString(path);
  cef_remove_web_plugin_path(@p);
end;

procedure CefUnregisterInternalWebPlugin(const path: ustring);
var
  p: TCefString;
begin
  p := CefString(path);
  cef_unregister_internal_web_plugin(@p);
end;

procedure CefForceWebPluginShutdown(const path: ustring);
var
  p: TCefString;
begin
  p := CefString(path);
  cef_force_web_plugin_shutdown(@p);
end;

procedure CefRegisterWebPluginCrash(const path: ustring);
var
  p: TCefString;
begin
  p := CefString(path);
  cef_register_web_plugin_crash(@p);
end;

procedure CefIsWebPluginUnstable(const path: ustring;
  const callback: ICefWebPluginUnstableCallback);
var
  p: TCefString;
begin
  p := CefString(path);
  cef_is_web_plugin_unstable(@p, CefGetData(callback));
end;

procedure CefIsWebPluginUnstableProc(const path: ustring;
  const callback: TCefWebPluginIsUnstableProc);
begin
  CefIsWebPluginUnstable(path, TCefFastWebPluginUnstableCallback.Create(callback));
end;

function CefGetPath(key: TCefPathKey; out path: ustring): Boolean;
var
  p: TCefString;
begin
  p := CefString('');
  Result := cef_get_path(key, @p) <> 0;
  path := CefStringClearAndGet(p);
end;

function CefBeginTracing(const categories: ustring; const callback: ICefCompletionCallback): Boolean;
var
  c: TCefString;
begin
  c := CefString(categories);
  Result := cef_begin_tracing(@c, CefGetData(callback)) <> 0;
end;

function CefEndTracing(const tracingFile: ustring; const callback: ICefEndTracingCallback): Boolean;
var
  s: TCefString;
begin
  s := CefString(tracingFile);
  Result := cef_end_tracing(@s, CefGetData(callback)) <> 0;
end;

function CefNowFromSystemTraceTime: Int64;
begin
  Result := cef_now_from_system_trace_time();
end;

function CefGetGeolocation(const callback: ICefGetGeolocationCallback): Boolean;
begin
  Result := cef_get_geolocation(CefGetData(callback)) <> 0;
end;

{$IFDEF MSWINDOWS}
function CefTimeToSystemTime(const dt: TCefTime): TSystemTime;
begin
  Result.wYear := dt.year;
  Result.wMonth := dt.month;
  Result.wDayOfWeek := dt.day_of_week;
  Result.wDay := dt.day_of_month;
  Result.wHour := dt.hour;
  Result.wMinute := dt.minute;
  Result.wSecond := dt.second;
  Result.wMilliseconds := dt.millisecond;
end;

function SystemTimeToCefTime(const dt: TSystemTime): TCefTime;
begin
  Result.year := dt.wYear;
  Result.month := dt.wMonth;
  Result.day_of_week := dt.wDayOfWeek;
  Result.day_of_month := dt.wDay;
  Result.hour := dt.wHour;
  Result.minute := dt.wMinute;
  Result.second := dt.wSecond;
  Result.millisecond := dt.wMilliseconds;
end;

function CefTimeToDateTime(const dt: TCefTime): TDateTime;
var
  st: TSystemTime;
begin
  st := CefTimeToSystemTime(dt);
  SystemTimeToTzSpecificLocalTime(nil, @st, @st);
  Result := SystemTimeToDateTime(st);
end;

function DateTimeToCefTime(dt: TDateTime): TCefTime;
var
  st: TSystemTime;
begin
  DateTimeToSystemTime(dt, st);
  TzSpecificLocalTimeToSystemTime(nil, @st, @st);
  Result := SystemTimeToCefTime(st);
end;
{$ELSE}

function CefTimeToDateTime(const dt: TCefTime): TDateTime;
begin
  Result :=
    EncodeDate(dt.year, dt.month, dt.day_of_month) +
    EncodeTime(dt.hour, dt.minute, dt.second, dt.millisecond);
end;

function DateTimeToCefTime(dt: TDateTime): TCefTime;
var
  Year, Month, Day, Hour, Min, Sec, MSec: Word;
begin
  DecodeDate(dt, Year, Month, Day);
  DecodeTime(dt, Hour, Min, Sec, MSec);
  Result.year := Year;
  Result.month := Month;
  Result.day_of_week := DayOfWeek(dt);
  Result.day_of_month := Month;
  Result.hour := Hour;
  Result.minute := Min;
  Result.second := Sec;
  Result.millisecond := MSec;
end;

{$ENDIF}

{ cef_base }

procedure cef_base_add_ref(self: PCefBase); stdcall;
begin
  TCefBaseOwn(CefGetObject(self))._AddRef;
end;

function cef_base_release(self: PCefBase): Integer; stdcall;
begin
  Result := TCefBaseOwn(CefGetObject(self))._Release;
end;

function cef_base_has_one_ref(self: PCefBase): Integer; stdcall;
begin
  Result := Ord(TCefBaseOwn(CefGetObject(self)).FRefCount = 1);
end;

procedure cef_base_add_ref_owned(self: PCefBase); stdcall;
begin

end;

function cef_base_release_owned(self: PCefBase): Integer; stdcall;
begin
  Result := 1;
end;

function cef_base_has_one_ref_owned(self: PCefBase): Integer; stdcall;
begin
  Result := 1;
end;

{ cef_client }

function cef_client_get_context_menu_handler(self: PCefClient): PCefContextMenuHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetContextMenuHandler);
end;

function cef_client_get_dialog_handler(self: PCefClient): PCefDialogHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetDialogHandler);
end;

function cef_client_get_display_handler(self: PCefClient): PCefDisplayHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetDisplayHandler);
end;

function cef_client_get_download_handler(self: PCefClient): PCefDownloadHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetDownloadHandler);
end;

function cef_client_get_drag_handler(self: PCefClient): PCefDragHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetDragHandler);
end;

function cef_client_get_find_handler(self: PCefClient): PCefFindHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetFindHandler);
end;

function cef_client_get_focus_handler(self: PCefClient): PCefFocusHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetFocusHandler);
end;

function cef_client_get_geolocation_handler(self: PCefClient): PCefGeolocationHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetGeolocationHandler);
end;

function cef_client_get_jsdialog_handler(self: PCefClient): PCefJsDialogHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetJsdialogHandler);
end;

function cef_client_get_keyboard_handler(self: PCefClient): PCefKeyboardHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetKeyboardHandler);
end;

function cef_client_get_life_span_handler(self: PCefClient): PCefLifeSpanHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetLifeSpanHandler);
end;

function cef_client_get_load_handler(self: PCefClient): PCefLoadHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetLoadHandler);
end;

function cef_client_get_get_render_handler(self: PCefClient): PCefRenderHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetRenderHandler);
end;

function cef_client_get_request_handler(self: PCefClient): PCefRequestHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetRequestHandler);
end;

function cef_client_on_process_message_received(self: PCefClient; browser: PCefBrowser;
  source_process: TCefProcessId; message: PCefProcessMessage): Integer; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := Ord(OnProcessMessageReceived(TCefBrowserRef.UnWrap(browser), source_process,
      TCefProcessMessageRef.UnWrap(message)));
end;

{ cef_geolocation_handler }

function cef_geolocation_handler_on_request_geolocation_permission(self: PCefGeolocationHandler;
  browser: PCefBrowser; const requesting_url: PCefString; request_id: Integer;
  callback: PCefGeolocationCallback): Integer; stdcall;
begin
  with TCefGeolocationHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnRequestGeolocationPermission(TCefBrowserRef.UnWrap(browser), CefString(requesting_url),
      request_id, TCefGeolocationCallbackRef.UnWrap(callback)));
end;

procedure cef_geolocation_handler_on_cancel_geolocation_permission(self: PCefGeolocationHandler;
  browser: PCefBrowser; const requesting_url: PCefString; request_id: Integer); stdcall;
begin
  with TCefGeolocationHandlerOwn(CefGetObject(self)) do
    OnCancelGeolocationPermission(TCefBrowserRef.UnWrap(browser), CefString(requesting_url), request_id);
end;

{ cef_life_span_handler }

function cef_life_span_handler_on_before_popup(self: PCefLifeSpanHandler;
  browser: PCefBrowser; frame: PCefFrame; const target_url, target_frame_name: PCefString;
  target_disposition: TCefWindowOpenDisposition; user_gesture: Integer;
  const popupFeatures: PCefPopupFeatures; windowInfo: PCefWindowInfo; var client: PCefClient;
  settings: PCefBrowserSettings; no_javascript_access: PInteger): Integer; stdcall;
var
  _url, _frame: ustring;
  _client: ICefClient;
  _nojs: Boolean;
begin
  _url := CefString(target_url);
  _frame := CefString(target_frame_name);
  _client := TCefClientOwn(CefGetObject(client)) as ICefClient;
  _nojs := no_javascript_access^ <> 0;
  with TCefLifeSpanHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnBeforePopup(
      TCefBrowserRef.UnWrap(browser),
      TCefFrameRef.UnWrap(frame),
      _url,
      _frame,
      target_disposition,
      user_gesture <> 0,
      popupFeatures^,
      windowInfo^,
      _client,
      settings^,
      _nojs
    ));
  CefStringSet(target_url, _url);
  CefStringSet(target_frame_name, _frame);
  client := CefGetData(_client);
  no_javascript_access^ := Ord(_nojs);
  _client := nil;
end;

procedure cef_life_span_handler_on_after_created(self: PCefLifeSpanHandler; browser: PCefBrowser); stdcall;
begin
  with TCefLifeSpanHandlerOwn(CefGetObject(self)) do
    OnAfterCreated(TCefBrowserRef.UnWrap(browser));
end;

procedure cef_life_span_handler_on_before_close(self: PCefLifeSpanHandler; browser: PCefBrowser); stdcall;
begin
  with TCefLifeSpanHandlerOwn(CefGetObject(self)) do
    OnBeforeClose(TCefBrowserRef.UnWrap(browser));
end;

function cef_life_span_handler_run_modal(self: PCefLifeSpanHandler; browser: PCefBrowser): Integer; stdcall;
begin
  with TCefLifeSpanHandlerOwn(CefGetObject(self)) do
    Result := Ord(RunModal(TCefBrowserRef.UnWrap(browser)));
end;

function cef_life_span_handler_do_close(self: PCefLifeSpanHandler; browser: PCefBrowser): Integer; stdcall;
begin
  with TCefLifeSpanHandlerOwn(CefGetObject(self)) do
    Result := Ord(DoClose(TCefBrowserRef.UnWrap(browser)));
end;


{ cef_load_handler }

procedure cef_load_handler_on_loading_state_change(self: PCefLoadHandler;
  browser: PCefBrowser; isLoading, canGoBack, canGoForward: Integer); stdcall;
begin
  with TCefLoadHandlerOwn(CefGetObject(self)) do
    OnLoadingStateChange(TCefBrowserRef.UnWrap(browser), isLoading <> 0,
      canGoBack <> 0, canGoForward <> 0);
end;

procedure cef_load_handler_on_load_start(self: PCefLoadHandler;
  browser: PCefBrowser; frame: PCefFrame); stdcall;
begin
  with TCefLoadHandlerOwn(CefGetObject(self)) do
    OnLoadStart(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame));
end;

procedure cef_load_handler_on_load_end(self: PCefLoadHandler;
  browser: PCefBrowser; frame: PCefFrame; httpStatusCode: Integer); stdcall;
begin
  with TCefLoadHandlerOwn(CefGetObject(self)) do
    OnLoadEnd(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame), httpStatusCode);
end;

procedure cef_load_handler_on_load_error(self: PCefLoadHandler; browser: PCefBrowser;
  frame: PCefFrame; errorCode: Integer; const errorText, failedUrl: PCefString); stdcall;
begin
  with TCefLoadHandlerOwn(CefGetObject(self)) do
    OnLoadError(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame),
      errorCode, CefString(errorText), CefString(failedUrl));
end;

{ cef_request_handler }

function cef_request_handler_on_before_browse(self: PCefRequestHandler; browser: PCefBrowser;
  frame: PCefFrame; request: PCefRequest; isRedirect: Integer): Integer; stdcall;
begin
  with TCefRequestHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnBeforeBrowse(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame),
      TCefRequestRef.UnWrap(request), isRedirect <> 0));
end;

function cef_request_handler_on_open_urlfrom_tab(self: PCefRequestHandler; browser: PCefBrowser;
  frame: PCefFrame; const target_url: PCefString; target_disposition: TCefWindowOpenDisposition;
  user_gesture: Integer): Integer; stdcall;
begin
  with TCefRequestHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnOpenUrlFromTab(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame),
      CefString(target_url), target_disposition, user_gesture <> 0));
end;

function cef_request_handler_on_before_resource_load(self: PCefRequestHandler;
  browser: PCefBrowser; frame: PCefFrame; request: PCefRequest;
  callback: PCefRequestCallback): TCefReturnValue; stdcall;
begin
  with TCefRequestHandlerOwn(CefGetObject(self)) do
    Result := OnBeforeResourceLoad(
      TCefBrowserRef.UnWrap(browser),
      TCefFrameRef.UnWrap(frame),
      TCefRequestRef.UnWrap(request),
      TcefRequestCallbackRef.UnWrap(callback));
end;

function cef_request_handler_get_resource_handler(self: PCefRequestHandler;
  browser: PCefBrowser; frame: PCefFrame; request: PCefRequest): PCefResourceHandler; stdcall;
begin
  with TCefRequestHandlerOwn(CefGetObject(self)) do
    Result := CefGetData(GetResourceHandler(TCefBrowserRef.UnWrap(browser),
      TCefFrameRef.UnWrap(frame), TCefRequestRef.UnWrap(request)));
end;

procedure cef_request_handler_on_resource_redirect(self: PCefRequestHandler;
  browser: PCefBrowser; frame: PCefFrame; const request: PCefRequest; new_url: PCefString); stdcall;
var
  url: ustring;
begin
  url := CefString(new_url);
  with TCefRequestHandlerOwn(CefGetObject(self)) do
    OnResourceRedirect(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame),
      TCefRequestRef.UnWrap(request), url);
  if url <> '' then
    CefStringSet(new_url, url);
end;

function cef_request_handler_on_resource_response(self: PCefRequestHandler;
  browser: PCefBrowser; frame: PCefFrame; request: PCefRequest;
  response: PCefResponse): Integer; stdcall;
begin
  with TCefRequestHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnResourceResponse(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame),
      TCefRequestRef.UnWrap(request), TCefResponseRef.UnWrap(response)));
end;

function cef_request_handler_get_auth_credentials(self: PCefRequestHandler;
  browser: PCefBrowser; frame: PCefFrame; isProxy: Integer; const host: PCefString;
  port: Integer; const realm, scheme: PCefString; callback: PCefAuthCallback): Integer; stdcall;
begin
  with TCefRequestHandlerOwn(CefGetObject(self)) do
    Result := Ord(GetAuthCredentials(
      TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame), isProxy <> 0,
      CefString(host), port, CefString(realm), CefString(scheme), TCefAuthCallbackRef.UnWrap(callback)));
end;

function cef_request_handler_on_quota_request(self: PCefRequestHandler; browser: PCefBrowser;
  const origin_url: PCefString; new_size: Int64; callback: PCefRequestCallback): Integer; stdcall;
begin
  with TCefRequestHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnQuotaRequest(TCefBrowserRef.UnWrap(browser),
      CefString(origin_url), new_size, TCefRequestCallbackRef.UnWrap(callback)));
end;

procedure cef_request_handler_on_protocol_execution(self: PCefRequestHandler;
  browser: PCefBrowser; const url: PCefString; allow_os_execution: PInteger); stdcall;
var
  allow: Boolean;
begin
  allow := allow_os_execution^ <> 0;
  with TCefRequestHandlerOwn(CefGetObject(self)) do
    OnProtocolExecution(
      TCefBrowserRef.UnWrap(browser),
      CefString(url), allow);
  allow_os_execution^ := Ord(allow);
end;

function cef_request_handler_on_certificate_error(self: PCefRequestHandler;
  browser: PCefBrowser; cert_error: TCefErrorcode; const request_url: PCefString;
  ssl_info: PCefSslInfo; callback: PCefRequestCallback): Integer; stdcall;
begin
  with TCefRequestHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnCertificateError(TCefBrowserRef.UnWrap(browser), cert_error,
      CefString(request_url), TCefSslInfoRef.UnWrap(ssl_info),
      TCefRequestCallbackRef.UnWrap(callback)));
end;

procedure cef_request_handler_on_plugin_crashed(self: PCefRequestHandler;
  browser: PCefBrowser; const plugin_path: PCefString); stdcall;
begin
  with TCefRequestHandlerOwn(CefGetObject(self)) do
    OnPluginCrashed(TCefBrowserRef.UnWrap(browser), CefString(plugin_path));
end;

procedure cef_request_handler_on_render_view_ready(self: PCefRequestHandler;
  browser: PCefBrowser); stdcall;
begin
  with TCefRequestHandlerOwn(CefGetObject(self)) do
    OnRenderViewReady(TCefBrowserRef.UnWrap(browser));
end;

procedure cef_request_handler_on_render_process_terminated(self: PCefRequestHandler;
  browser: PCefBrowser; status: TCefTerminationStatus); stdcall;
begin
  with TCefRequestHandlerOwn(CefGetObject(self)) do
    OnRenderProcessTerminated(TCefBrowserRef.UnWrap(browser), status);
end;


{ cef_display_handler }

procedure cef_display_handler_on_address_change(self: PCefDisplayHandler;
  browser: PCefBrowser; frame: PCefFrame; const url: PCefString); stdcall;
begin
  with TCefDisplayHandlerOwn(CefGetObject(self)) do
    OnAddressChange(
      TCefBrowserRef.UnWrap(browser),
      TCefFrameRef.UnWrap(frame),
      cefstring(url))
end;

procedure cef_display_handler_on_title_change(self: PCefDisplayHandler;
  browser: PCefBrowser; const title: PCefString); stdcall;
begin
  with TCefDisplayHandlerOwn(CefGetObject(self)) do
    OnTitleChange(TCefBrowserRef.UnWrap(browser), CefString(title));
end;

procedure cef_display_handler_on_favicon_urlchange(self: PCefDisplayHandler;
  browser: PCefBrowser; icon_urls: TCefStringList); stdcall;
var
  list: TStringList;
  i: Integer;
  str: TCefString;
begin
  list := TStringList.Create;
  try
    for i := 0 to cef_string_list_size(icon_urls) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(icon_urls, i, @str);
      list.Add(CefStringClearAndGet(str));
    end;
    with TCefDisplayHandlerOwn(CefGetObject(self)) do
      OnFaviconUrlChange(TCefBrowserRef.UnWrap(browser), list);
  finally
    list.Free;
  end;
end;

procedure cef_display_handler_on_fullscreen_mode_change(self: PCefDisplayHandler;
  browser: PCefBrowser; fullscreen: Integer); stdcall;
begin
  with TCefDisplayHandlerOwn(CefGetObject(self)) do
    OnFullScreenModeChange(TCefBrowserRef.UnWrap(browser), fullscreen <> 0);
end;

function cef_display_handler_on_tooltip(self: PCefDisplayHandler;
  browser: PCefBrowser; text: PCefString): Integer; stdcall;
var
  t: ustring;
begin
  t := CefStringClearAndGet(text^);
  with TCefDisplayHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnTooltip(
      TCefBrowserRef.UnWrap(browser), t));
  text^ := CefStringAlloc(t);
end;

procedure cef_display_handler_on_status_message(self: PCefDisplayHandler;
  browser: PCefBrowser; const value: PCefString); stdcall;
begin
  with TCefDisplayHandlerOwn(CefGetObject(self)) do
    OnStatusMessage(TCefBrowserRef.UnWrap(browser), CefString(value));
end;

function cef_display_handler_on_console_message(self: PCefDisplayHandler;
    browser: PCefBrowser; const message: PCefString;
    const source: PCefString; line: Integer): Integer; stdcall;
begin
  with TCefDisplayHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnConsoleMessage(TCefBrowserRef.UnWrap(browser),
    CefString(message), CefString(source), line));
end;

{ cef_focus_handler }

procedure cef_focus_handler_on_take_focus(self: PCefFocusHandler;
  browser: PCefBrowser; next: Integer); stdcall;
begin
  with TCefFocusHandlerOwn(CefGetObject(self)) do
    OnTakeFocus(TCefBrowserRef.UnWrap(browser), next <> 0);
end;

function cef_focus_handler_on_set_focus(self: PCefFocusHandler;
  browser: PCefBrowser; source: TCefFocusSource): Integer; stdcall;
begin
  with TCefFocusHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnSetFocus(TCefBrowserRef.UnWrap(browser), source))
end;

procedure cef_focus_handler_on_got_focus(self: PCefFocusHandler; browser: PCefBrowser); stdcall;
begin
  with TCefFocusHandlerOwn(CefGetObject(self)) do
    OnGotFocus(TCefBrowserRef.UnWrap(browser));
end;

{ cef_keyboard_handler }

function cef_keyboard_handler_on_pre_key_event(self: PCefKeyboardHandler;
  browser: PCefBrowser; const event: PCefKeyEvent;
  os_event: TCefEventHandle; is_keyboard_shortcut: PInteger): Integer; stdcall;
var
  ks: Boolean;
begin
  ks := is_keyboard_shortcut^ <> 0;
  with TCefKeyboardHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnPreKeyEvent(TCefBrowserRef.UnWrap(browser), event, os_event, ks));
  is_keyboard_shortcut^ := Ord(ks);
end;

function cef_keyboard_handler_on_key_event(self: PCefKeyboardHandler;
    browser: PCefBrowser; const event: PCefKeyEvent; os_event: TCefEventHandle): Integer; stdcall;
begin
  with TCefKeyboardHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnKeyEvent(TCefBrowserRef.UnWrap(browser), event, os_event));
end;

{ cef_jsdialog_handler }

function cef_jsdialog_handler_on_jsdialog(self: PCefJsDialogHandler;
  browser: PCefBrowser; const origin_url, accept_lang: PCefString;
  dialog_type: TCefJsDialogType; const message_text, default_prompt_text: PCefString;
  callback: PCefJsDialogCallback; suppress_message: PInteger): Integer; stdcall;
var
  sm: Boolean;
begin
  sm := suppress_message^ <> 0;
  with TCefJsDialogHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnJsdialog(TCefBrowserRef.UnWrap(browser), CefString(origin_url),
      CefString(accept_lang), dialog_type, CefString(message_text),
      CefString(default_prompt_text), TCefJsDialogCallbackRef.UnWrap(callback), sm));
  suppress_message^ := Ord(sm);
end;

function cef_jsdialog_handler_on_before_unload_dialog(self: PCefJsDialogHandler;
  browser: PCefBrowser; const message_text: PCefString; is_reload: Integer;
  callback: PCefJsDialogCallback): Integer; stdcall;
begin
  with TCefJsDialogHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnBeforeUnloadDialog(TCefBrowserRef.UnWrap(browser), CefString(message_text),
      is_reload <> 0, TCefJsDialogCallbackRef.UnWrap(callback)));
end;

procedure cef_jsdialog_handler_on_reset_dialog_state(self: PCefJsDialogHandler;
  browser: PCefBrowser); stdcall;
begin
  with TCefJsDialogHandlerOwn(CefGetObject(self)) do
    OnResetDialogState(TCefBrowserRef.UnWrap(browser));
end;

procedure cef_jsdialog_handler_on_dialog_closed(self: PCefJsDialogHandler;
  browser: PCefBrowser); stdcall;
begin
  with TCefJsDialogHandlerOwn(CefGetObject(self)) do
    OnDialogClosed(TCefBrowserRef.UnWrap(browser));
end;

{ cef_context_menu_handler }

procedure cef_context_menu_handler_on_before_context_menu(self: PCefContextMenuHandler;
  browser: PCefBrowser; frame: PCefFrame; params: PCefContextMenuParams;
  model: PCefMenuModel); stdcall;
begin
  with TCefContextMenuHandlerOwn(CefGetObject(self)) do
    OnBeforeContextMenu(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame),
      TCefContextMenuParamsRef.UnWrap(params), TCefMenuModelRef.UnWrap(model));
end;

function cef_context_menu_handler_run_context_menu(self: PCefContextMenuHandler;
  browser: PCefBrowser; frame: PCefFrame; params: PCefContextMenuParams;
  model: PCefMenuModel; callback: PCefRunContextMenuCallback): Integer; stdcall;
begin
  with TCefContextMenuHandlerOwn(CefGetObject(self)) do
    Result := Ord(RunContextMenu(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame),
      TCefContextMenuParamsRef.UnWrap(params), TCefMenuModelRef.UnWrap(model),
      TCefRunContextMenuCallbackRef.UnWrap(callback)));
end;

function cef_context_menu_handler_on_context_menu_command(self: PCefContextMenuHandler;
  browser: PCefBrowser; frame: PCefFrame; params: PCefContextMenuParams;
  command_id: Integer; event_flags: Integer): Integer; stdcall;
begin
  with TCefContextMenuHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnContextMenuCommand(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame),
      TCefContextMenuParamsRef.UnWrap(params), command_id, TCefEventFlags(Pointer(@event_flags)^)));
end;

procedure cef_context_menu_handler_on_context_menu_dismissed(self: PCefContextMenuHandler;
  browser: PCefBrowser; frame: PCefFrame); stdcall;
begin
  with TCefContextMenuHandlerOwn(CefGetObject(self)) do
    OnContextMenuDismissed(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame));
end;

{  cef_stream_reader }

function cef_stream_reader_read(self: PCefReadHandler; ptr: Pointer; size, n: NativeUInt): NativeUInt; stdcall;
begin
  with TCefCustomStreamReader(CefGetObject(self)) do
    Result := Read(ptr, size, n);
end;

function cef_stream_reader_seek(self: PCefReadHandler; offset: Int64; whence: Integer): Integer; stdcall;
begin
  with TCefCustomStreamReader(CefGetObject(self)) do
    Result := Seek(offset, whence);
end;

function cef_stream_reader_tell(self: PCefReadHandler): Int64; stdcall;
begin
  with TCefCustomStreamReader(CefGetObject(self)) do
    Result := Tell;
end;

function cef_stream_reader_eof(self: PCefReadHandler): Integer; stdcall;
begin
  with TCefCustomStreamReader(CefGetObject(self)) do
    Result := Ord(Eof);
end;

function cef_stream_reader_may_block(self: PCefReadHandler): Integer; stdcall;
begin
  with TCefCustomStreamReader(CefGetObject(self)) do
    Result := Ord(MayBlock);
end;

{ cef_post_data_element }

function cef_post_data_element_is_read_only(self: PCefPostDataElement): Integer; stdcall;
begin
  with TCefPostDataElementOwn(CefGetObject(self)) do
    Result := Ord(IsReadOnly)
end;

procedure cef_post_data_element_set_to_empty(self: PCefPostDataElement); stdcall;
begin
  with TCefPostDataElementOwn(CefGetObject(self)) do
    SetToEmpty;
end;

procedure cef_post_data_element_set_to_file(self: PCefPostDataElement; const fileName: PCefString); stdcall;
begin
  with TCefPostDataElementOwn(CefGetObject(self)) do
    SetToFile(CefString(fileName));
end;

procedure cef_post_data_element_set_to_bytes(self: PCefPostDataElement; size: NativeUInt; const bytes: Pointer); stdcall;
begin
  with TCefPostDataElementOwn(CefGetObject(self)) do
    SetToBytes(size, bytes);
end;

function cef_post_data_element_get_type(self: PCefPostDataElement): TCefPostDataElementType; stdcall;
begin
  with TCefPostDataElementOwn(CefGetObject(self)) do
    Result := GetType;
end;

function cef_post_data_element_get_file(self: PCefPostDataElement): PCefStringUserFree; stdcall;
begin
  with TCefPostDataElementOwn(CefGetObject(self)) do
    Result := CefUserFreeString(GetFile);
end;

function cef_post_data_element_get_bytes_count(self: PCefPostDataElement): NativeUInt; stdcall;
begin
  with TCefPostDataElementOwn(CefGetObject(self)) do
    Result := GetBytesCount;
end;

function cef_post_data_element_get_bytes(self: PCefPostDataElement; size: NativeUInt; bytes: Pointer): NativeUInt; stdcall;
begin
  with TCefPostDataElementOwn(CefGetObject(self)) do
    Result := GetBytes(size, bytes)
end;

{ cef_v8_handler }

function cef_v8_handler_execute(self: PCefv8Handler;
  const name: PCefString; obj: PCefv8Value; argumentsCount: NativeUInt;
  const arguments: PPCefV8Value; var retval: PCefV8Value;
  var exception: TCefString): Integer; stdcall;
var
  args: TCefv8ValueArray;
  i: NativeInt;
  ret: ICefv8Value;
  exc: ustring;
begin
  SetLength(args, argumentsCount);
  for i := 0 to argumentsCount - 1 do
    args[i] := TCefv8ValueRef.UnWrap(arguments[i]);

  Result := -Ord(TCefv8HandlerOwn(CefGetObject(self)).Execute(
    CefString(name), TCefv8ValueRef.UnWrap(obj), args, ret, exc));
  retval := CefGetData(ret);
  ret := nil;
  exception := CefString(exc);
end;

{ cef_task }

procedure cef_task_execute(self: PCefTask); stdcall;
begin
  TCefTaskOwn(CefGetObject(self)).Execute();
end;

{ cef_download_handler }

procedure cef_download_handler_on_before_download(self: PCefDownloadHandler;
  browser: PCefBrowser; download_item: PCefDownloadItem;
  const suggested_name: PCefString; callback: PCefBeforeDownloadCallback); stdcall;
begin
  TCefDownloadHandlerOwn(CefGetObject(self)).
    OnBeforeDownload(TCefBrowserRef.UnWrap(browser),
    TCefDownLoadItemRef.UnWrap(download_item), CefString(suggested_name),
    TCefBeforeDownloadCallbackRef.UnWrap(callback));
end;

procedure cef_download_handler_on_download_updated(self: PCefDownloadHandler;
  browser: PCefBrowser; download_item: PCefDownloadItem; callback: PCefDownloadItemCallback); stdcall;
begin
  TCefDownloadHandlerOwn(CefGetObject(self)).
    OnDownloadUpdated(TCefBrowserRef.UnWrap(browser),
    TCefDownLoadItemRef.UnWrap(download_item),
    TCefDownloadItemCallbackRef.UnWrap(callback));
end;

{ cef_dom_visitor }

procedure cef_dom_visitor_visite(self: PCefDomVisitor; document: PCefDomDocument); stdcall;
begin
  TCefDomVisitorOwn(CefGetObject(self)).visit(TCefDomDocumentRef.UnWrap(document));
end;

{ cef_v8_accessor }

function cef_v8_accessor_get(self: PCefV8Accessor; const name: PCefString;
      obj: PCefv8Value; out retval: PCefv8Value; exception: PCefString): Integer; stdcall;
var
  ret: ICefv8Value;
begin
  Result := Ord(TCefV8AccessorOwn(CefGetObject(self)).Get(CefString(name),
    TCefv8ValueRef.UnWrap(obj), ret, CefString(exception)));
  retval := CefGetData(ret);
end;


function cef_v8_accessor_put(self: PCefV8Accessor; const name: PCefString;
      obj: PCefv8Value; value: PCefv8Value; exception: PCefString): Integer; stdcall;
begin
  Result := Ord(TCefV8AccessorOwn(CefGetObject(self)).Put(CefString(name),
    TCefv8ValueRef.UnWrap(obj), TCefv8ValueRef.UnWrap(value), CefString(exception)));
end;

{ cef_cookie_visitor }

function cef_cookie_visitor_visit(self: PCefCookieVisitor; const cookie: PCefCookie;
  count, total: Integer; deleteCookie: PInteger): Integer; stdcall;
var
  delete: Boolean;
  exp: TDateTime;
begin
  delete := False;
  if cookie.has_expires <> 0 then
    exp := CefTimeToDateTime(cookie.expires) else
    exp := 0;
  Result := Ord(TCefCookieVisitorOwn(CefGetObject(self)).visit(CefString(@cookie.name),
    CefString(@cookie.value), CefString(@cookie.domain), CefString(@cookie.path),
    Boolean(cookie.secure), Boolean(cookie.httponly), Boolean(cookie.has_expires), CefTimeToDateTime(cookie.creation),
    CefTimeToDateTime(cookie.last_access), exp, count, total, delete));
  deleteCookie^ := Ord(delete);
end;

{ cef_resource_bundle_handler }

function cef_resource_bundle_handler_get_localized_string(self: PCefResourceBundleHandler;
  string_id: Integer; string_val: PCefString): Integer; stdcall;
var
  str: ustring;
begin
  Result := Ord(TCefResourceBundleHandlerOwn(CefGetObject(self)).
    GetLocalizedString(string_id, str));
  if Result <> 0 then
    string_val^ := CefString(str);
end;

function cef_resource_bundle_handler_get_data_resource(self: PCefResourceBundleHandler;
  resource_id: Integer; var data: Pointer; var data_size: NativeUInt): Integer; stdcall;
begin
  Result := Ord(TCefResourceBundleHandlerOwn(CefGetObject(self)).
    GetDataResource(resource_id, data, data_size));
end;

function cef_resource_bundle_handler_get_data_resource_for_scale(
  self: PCefResourceBundleHandler; resource_id: Integer; scale_factor: TCefScaleFactor;
  out data: Pointer; data_size: NativeUInt): Integer; stdcall;
begin
  Result := Ord(TCefResourceBundleHandlerOwn(CefGetObject(self)).
    GetDataResourceForScale(resource_id, scale_factor, data, data_size));
end;

{ cef_app }

procedure cef_app_on_before_command_line_processing(self: PCefApp;
  const process_type: PCefString; command_line: PCefCommandLine); stdcall;
begin
  with TCefAppOwn(CefGetObject(self)) do
    OnBeforeCommandLineProcessing(CefString(process_type),
      TCefCommandLineRef.UnWrap(command_line));
end;

procedure cef_app_on_register_custom_schemes(self: PCefApp; registrar: PCefSchemeRegistrar); stdcall;
begin
  with TCefAppOwn(CefGetObject(self)) do
    OnRegisterCustomSchemes(TCefSchemeRegistrarRef.UnWrap(registrar));
end;

function cef_app_get_resource_bundle_handler(self: PCefApp): PCefResourceBundleHandler; stdcall;
begin
  Result := CefGetData(TCefAppOwn(CefGetObject(self)).GetResourceBundleHandler());
end;

function cef_app_get_browser_process_handler(self: PCefApp): PCefBrowserProcessHandler; stdcall;
begin
  Result := CefGetData(TCefAppOwn(CefGetObject(self)).GetBrowserProcessHandler());
end;

function cef_app_get_render_process_handler(self: PCefApp): PCefRenderProcessHandler; stdcall;
begin
  Result := CefGetData(TCefAppOwn(CefGetObject(self)).GetRenderProcessHandler());
end;

{ cef_string_visitor_visit }

procedure cef_string_visitor_visit(self: PCefStringVisitor; const str: PCefString); stdcall;
begin
  TCefStringVisitorOwn(CefGetObject(self)).Visit(CefString(str));
end;

{ cef_browser_process_handler }

procedure cef_browser_process_handler_on_context_initialized(self: PCefBrowserProcessHandler); stdcall;
begin
  with TCefBrowserProcessHandlerOwn(CefGetObject(self)) do
    OnContextInitialized;
end;

procedure cef_browser_process_handler_on_before_child_process_launch(
  self: PCefBrowserProcessHandler; command_line: PCefCommandLine); stdcall;
begin
  with TCefBrowserProcessHandlerOwn(CefGetObject(self)) do
    OnBeforeChildProcessLaunch(TCefCommandLineRef.UnWrap(command_line));
end;

procedure cef_browser_process_handler_on_render_process_thread_created(
  self: PCefBrowserProcessHandler; extra_info: PCefListValue); stdcall;
begin
  with TCefBrowserProcessHandlerOwn(CefGetObject(self)) do
    OnRenderProcessThreadCreated(TCefListValueRef.UnWrap(extra_info));
end;

{ cef_render_process_handler }

procedure cef_render_process_handler_on_render_thread_created(
  self: PCefRenderProcessHandler; extra_info: PCefListValue); stdcall;
begin
  with TCefRenderProcessHandlerOwn(CefGetObject(Self)) do
    OnRenderThreadCreated(TCefListValueRef.UnWrap(extra_info));
end;

procedure cef_render_process_handler_on_web_kit_initialized(self: PCefRenderProcessHandler); stdcall;
begin
  with TCefRenderProcessHandlerOwn(CefGetObject(Self)) do
    OnWebKitInitialized;
end;

procedure cef_render_process_handler_on_browser_created(self: PCefRenderProcessHandler;
  browser: PCefBrowser); stdcall;
begin
  with TCefRenderProcessHandlerOwn(CefGetObject(Self)) do
    OnBrowserCreated(TCefBrowserRef.UnWrap(browser));
end;

procedure cef_render_process_handler_on_browser_destroyed(self: PCefRenderProcessHandler;
  browser: PCefBrowser); stdcall;
begin
  with TCefRenderProcessHandlerOwn(CefGetObject(Self)) do
    OnBrowserDestroyed(TCefBrowserRef.UnWrap(browser));
end;

function cef_render_process_handler_get_load_handler(self: PCefRenderProcessHandler): PCefLoadHandler; stdcall;
begin
  with TCefRenderProcessHandlerOwn(CefGetObject(Self)) do
    Result := GetLoadHandler();
end;

function cef_render_process_handler_on_before_navigation(self: PCefRenderProcessHandler;
  browser: PCefBrowser; frame: PCefFrame; request: PCefRequest;
  navigation_type: TCefNavigationType; is_redirect: Integer): Integer; stdcall;
begin
  with TCefRenderProcessHandlerOwn(CefGetObject(Self)) do
    Result := Ord(OnBeforeNavigation(TCefBrowserRef.UnWrap(browser),
      TCefFrameRef.UnWrap(frame), TCefRequestRef.UnWrap(request),
      navigation_type, is_redirect <> 0));
end;

procedure cef_render_process_handler_on_context_created(self: PCefRenderProcessHandler;
  browser: PCefBrowser; frame: PCefFrame; context: PCefv8Context); stdcall;
begin
  with TCefRenderProcessHandlerOwn(CefGetObject(Self)) do
    OnContextCreated(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame), TCefv8ContextRef.UnWrap(context));
end;

procedure cef_render_process_handler_on_context_released(self: PCefRenderProcessHandler;
  browser: PCefBrowser; frame: PCefFrame; context: PCefv8Context); stdcall;
begin
  with TCefRenderProcessHandlerOwn(CefGetObject(Self)) do
    OnContextReleased(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame), TCefv8ContextRef.UnWrap(context));
end;

procedure cef_render_process_handler_on_uncaught_exception(self: PCefRenderProcessHandler;
  browser: PCefBrowser; frame: PCefFrame; context: PCefv8Context;
  exception: PCefV8Exception; stackTrace: PCefV8StackTrace); stdcall;
begin
  with TCefRenderProcessHandlerOwn(CefGetObject(Self)) do
    OnUncaughtException(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame),
      TCefv8ContextRef.UnWrap(context), TCefV8ExceptionRef.UnWrap(exception),
      TCefV8StackTraceRef.UnWrap(stackTrace));
end;

procedure cef_render_process_handler_on_focused_node_changed(self: PCefRenderProcessHandler;
  browser: PCefBrowser; frame: PCefFrame; node: PCefDomNode); stdcall;
begin
  with TCefRenderProcessHandlerOwn(CefGetObject(Self)) do
    OnFocusedNodeChanged(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame),
      TCefDomNodeRef.UnWrap(node));
end;

function cef_render_process_handler_on_process_message_received(self: PCefRenderProcessHandler;
  browser: PCefBrowser; source_process: TCefProcessId;
  message: PCefProcessMessage): Integer; stdcall;
begin
  with TCefRenderProcessHandlerOwn(CefGetObject(Self)) do
    Result := Ord(OnProcessMessageReceived(TCefBrowserRef.UnWrap(browser), source_process,
      TCefProcessMessageRef.UnWrap(message)));
end;

{ cef_url_request_client }

procedure cef_url_request_client_on_request_complete(self: PCefUrlRequestClient; request: PCefUrlRequest); stdcall;
begin
  with TCefUrlrequestClientOwn(CefGetObject(self)) do
    OnRequestComplete(TCefUrlRequestRef.UnWrap(request));
end;

procedure cef_url_request_client_on_upload_progress(self: PCefUrlRequestClient;
  request: PCefUrlRequest; current, total: Int64); stdcall;
begin
  with TCefUrlrequestClientOwn(CefGetObject(self)) do
    OnUploadProgress(TCefUrlRequestRef.UnWrap(request), current, total);
end;

procedure cef_url_request_client_on_download_progress(self: PCefUrlRequestClient;
  request: PCefUrlRequest; current, total: Int64); stdcall;
begin
  with TCefUrlrequestClientOwn(CefGetObject(self)) do
    OnDownloadProgress(TCefUrlRequestRef.UnWrap(request), current, total);
end;

procedure cef_url_request_client_on_download_data(self: PCefUrlRequestClient;
  request: PCefUrlRequest; const data: Pointer; data_length: NativeUInt); stdcall;
begin
  with TCefUrlrequestClientOwn(CefGetObject(self)) do
    OnDownloadData(TCefUrlRequestRef.UnWrap(request), data, data_length);
end;

function cef_url_request_client_get_auth_credentials(self: PCefUrlRequestClient;
  isProxy: Integer; const host: PCefString; port: Integer; const realm,
  scheme: PCefString; callback: PCefAuthCallback): Integer; stdcall;
begin
  with TCefUrlrequestClientOwn(CefGetObject(self)) do
    Result := Ord(OnGetAuthCredentials(isProxy <> 0, CefString(host), port,
      CefString(realm), CefString(scheme), TCefAuthCallbackRef.UnWrap(callback)));
end;

{ cef_scheme_handler_factory }

function cef_scheme_handler_factory_create(self: PCefSchemeHandlerFactory;
  browser: PCefBrowser; frame: PCefFrame; const scheme_name: PCefString;
  request: PCefRequest): PCefResourceHandler; stdcall;
begin

  with TCefSchemeHandlerFactoryOwn(CefGetObject(self)) do
    Result := CefGetData(New(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame),
      CefString(scheme_name), TCefRequestRef.UnWrap(request)));
end;

{ cef_resource_handler }

function cef_resource_handler_process_request(self: PCefResourceHandler;
  request: PCefRequest; callback: PCefCallback): Integer; stdcall;
begin
  with TCefResourceHandlerOwn(CefGetObject(self)) do
    Result := Ord(ProcessRequest(TCefRequestRef.UnWrap(request), TCefCallbackRef.UnWrap(callback)));
end;

procedure cef_resource_handler_get_response_headers(self: PCefResourceHandler;
  response: PCefResponse; response_length: PInt64; redirectUrl: PCefString); stdcall;
var
  ru: ustring;
begin
  ru := '';
  with TCefResourceHandlerOwn(CefGetObject(self)) do
    GetResponseHeaders(TCefResponseRef.UnWrap(response), response_length^, ru);
  if ru <> '' then
    CefStringSet(redirectUrl, ru);
end;

function cef_resource_handler_read_response(self: PCefResourceHandler;
  data_out: Pointer; bytes_to_read: Integer; bytes_read: PInteger;
    callback: PCefCallback): Integer; stdcall;
begin
  with TCefResourceHandlerOwn(CefGetObject(self)) do
    Result := Ord(ReadResponse(data_out, bytes_to_read, bytes_read^, TCefCallbackRef.UnWrap(callback)));
end;

function cef_resource_handler_can_get_cookie(self: PCefResourceHandler;
  const cookie: PCefCookie): Integer; stdcall;
begin

  with TCefResourceHandlerOwn(CefGetObject(self)) do
    Result := Ord(CanGetCookie(cookie));
end;

function cef_resource_handler_can_set_cookie(self: PCefResourceHandler;
  const cookie: PCefCookie): Integer; stdcall;
begin

  with TCefResourceHandlerOwn(CefGetObject(self)) do
    Result := Ord(CanSetCookie(cookie));
end;

procedure cef_resource_handler_cancel(self: PCefResourceHandler); stdcall;
begin

  with TCefResourceHandlerOwn(CefGetObject(self)) do
    Cancel;
end;


{ cef_web_plugin_info_visitor }


function cef_web_plugin_info_visitor_visit(self: PCefWebPluginInfoVisitor;

      info: PCefWebPluginInfo; count, total: Integer): Integer; stdcall;
begin
  with TCefWebPluginInfoVisitorOwn(CefGetObject(self)) do
    Result := Ord(Visit(TCefWebPluginInfoRef.UnWrap(info), count, total));
end;


{ cef_web_plugin_unstable_callback }


procedure cef_web_plugin_unstable_callback_is_unstable(
  self: PCefWebPluginUnstableCallback; const path: PCefString; unstable: Integer); stdcall;
begin
  with TCefWebPluginUnstableCallbackOwn(CefGetObject(self)) do
    IsUnstable(CefString(path), unstable <> 0);
end;


{ cef_run_file_dialog_callback }

procedure cef_run_file_dialog_callback_on_file_dialog_dismissed(
  self: PCefRunFileDialogCallback; selected_accept_filter: Integer;
  file_paths: TCefStringList); stdcall;
var
  list: TStringList;
  i: Integer;
  str: TCefString;
begin
  list := TStringList.Create;
  try
    for i := 0 to cef_string_list_size(file_paths) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(file_paths, i, @str);
      list.Add(CefStringClearAndGet(str));
    end;
    with TCefRunFileDialogCallbackOwn(CefGetObject(self)) do
      OnFileDialogDismissed(selected_accept_filter, list);
  finally
    list.Free;
  end;
end;


{ cef_end_tracing_callback }

procedure cef_end_tracing_callback_on_end_tracing_complete(self: PCefEndTracingCallback; const tracing_file: PCefString); stdcall;
begin
  with TCefEndTracingCallbackOwn(CefGetObject(self)) do
    OnEndTracingComplete(CefString(tracing_file));
end;

{ cef_get_geolocation_callback }

procedure cef_get_geolocation_callback_on_location_update(
  self: PCefGetGeolocationCallback; const position: PCefGeoposition); stdcall;
begin
  with TCefGetGeolocationCallbackOwn(CefGetObject(self)) do
    OnLocationUpdate(position);
end;

{ cef_dialog_handler }


function cef_dialog_handler_on_file_dialog(self: PCefDialogHandler; browser: PCefBrowser;
  mode: TCefFileDialogMode; const title, default_file_path: PCefString;
  accept_filters: TCefStringList; selected_accept_filter: Integer;
  callback: PCefFileDialogCallback): Integer; stdcall;
var
  list: TStringList;
  i: Integer;
  str: TCefString;
begin
  list := TStringList.Create;
  try
    for i := 0 to cef_string_list_size(accept_filters) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(accept_filters, i, @str);
      list.Add(CefStringClearAndGet(str));
    end;

    with TCefDialogHandlerOwn(CefGetObject(self)) do
      Result := Ord(OnFileDialog(TCefBrowserRef.UnWrap(browser), mode, CefString(title),
        CefString(default_file_path), list, selected_accept_filter,
        TCefFileDialogCallbackRef.UnWrap(callback)));
  finally
    list.Free;
  end;
end;

{ cef_render_handler }

function cef_render_handler_get_root_screen_rect(self: PCefRenderHandler;
  browser: PCefBrowser; rect: PCefRect): Integer; stdcall;
begin
  with TCefRenderHandlerOwn(CefGetObject(self)) do
    Result := Ord(GetRootScreenRect(TCefBrowserRef.UnWrap(browser), rect));
end;

function cef_render_handler_get_view_rect(self: PCefRenderHandler;
  browser: PCefBrowser; rect: PCefRect): Integer; stdcall;
begin
  with TCefRenderHandlerOwn(CefGetObject(self)) do
    Result := Ord(GetViewRect(TCefBrowserRef.UnWrap(browser), rect));
end;

function cef_render_handler_get_screen_point(self: PCefRenderHandler;
  browser: PCefBrowser; viewX, viewY: Integer; screenX, screenY: PInteger): Integer; stdcall;
begin
  with TCefRenderHandlerOwn(CefGetObject(self)) do
    Result := Ord(GetScreenPoint(TCefBrowserRef.UnWrap(browser), viewX, viewY, screenX, screenY));
end;

function cef_render_handler_get_screen_info(self: PCefRenderHandler;
  browser: PCefBrowser; screen_info: PCefScreenInfo): Integer; stdcall;
begin
  with TCefRenderHandlerOwn(CefGetObject(self)) do
    Result := Ord(GetScreenInfo(TCefBrowserRef.UnWrap(browser), screen_info));
end;

procedure cef_render_handler_on_popup_show(self: PCefRenderProcessHandler;
  browser: PCefBrowser; show: Integer); stdcall;
begin
  with TCefRenderHandlerOwn(CefGetObject(self)) do
    OnPopupShow(TCefBrowserRef.UnWrap(browser), show <> 0);
end;

procedure cef_render_handler_on_popup_size(self: PCefRenderProcessHandler;
  browser: PCefBrowser; const rect: PCefRect); stdcall;
begin
  with TCefRenderHandlerOwn(CefGetObject(self)) do
    OnPopupSize(TCefBrowserRef.UnWrap(browser), rect);
end;

procedure cef_render_handler_on_paint(self: PCefRenderProcessHandler;
  browser: PCefBrowser; kind: TCefPaintElementType; dirtyRectsCount: NativeUInt;
  const dirtyRects: PCefRectArray; const buffer: Pointer; width, height: Integer); stdcall;
begin
  with TCefRenderHandlerOwn(CefGetObject(self)) do
    OnPaint(TCefBrowserRef.UnWrap(browser), kind, dirtyRectsCount, dirtyRects,
      buffer, width, height);
end;

procedure cef_render_handler_on_cursor_change(self: PCefRenderProcessHandler;
  browser: PCefBrowser; cursor: TCefCursorHandle; type_: TCefCursorType;
  const custom_cursor_info: PCefCursorInfo); stdcall;
begin
  with TCefRenderHandlerOwn(CefGetObject(self)) do
    OnCursorChange(TCefBrowserRef.UnWrap(browser), cursor, type_, custom_cursor_info);
end;

function cef_render_handler_start_dragging(self: PCefRenderProcessHandler; browser: PCefBrowser;
  drag_data: PCefDragData; allowed_ops: TCefDragOperations; x, y: Integer): Integer; stdcall;
begin
  with TCefRenderHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnStartDragging(TCefBrowserRef.UnWrap(browser),
      TCefDragDataRef.UnWrap(drag_data), allowed_ops, x, y));
end;

procedure cef_render_handler_update_drag_cursor(self: PCefRenderProcessHandler;
  browser: PCefBrowser; operation: TCefDragOperation); stdcall;
begin
  with TCefRenderHandlerOwn(CefGetObject(self)) do
    OnUpdateDragCursor(TCefBrowserRef.UnWrap(browser), operation);
end;

procedure cef_render_handler_on_scroll_offset_changed(self: PCefRenderProcessHandler;
  browser: PCefBrowser; x, y: Double); stdcall;
begin
  with TCefRenderHandlerOwn(CefGetObject(self)) do
    OnScrollOffsetChanged(TCefBrowserRef.UnWrap(browser), x, y);
end;

{ cef_completion_callback }

procedure cef_completion_callback_on_complete(self: PCefCompletionCallback); stdcall;
begin
  with TCefCompletionCallbackOwn(CefGetObject(self)) do
    OnComplete();
end;

{ cef_drag_handler }

function cef_drag_handler_on_drag_enter(self: PCefDragHandler; browser: PCefBrowser;
  dragData: PCefDragData; mask: TCefDragOperations): Integer; stdcall;
begin
  with TCefDragHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnDragEnter(TCefBrowserRef.UnWrap(browser), TCefDragDataRef.UnWrap(dragData), mask));
end;

procedure cef_drag_handler_on_draggable_regions_changed(self: PCefDragHandler;
  browser: PCefBrowser; regionsCount: NativeUInt; regions: PCefDraggableRegionArray); stdcall;
begin
  with TCefDragHandlerOwn(CefGetObject(self)) do
    OnDraggableRegionsChanged(TCefBrowserRef.UnWrap(browser), regionsCount, regions);
end;

{ cef_find_handler }

procedure cef_find_handler_on_find_result(self: PCefFindHandler; browser: PCefBrowser; identifier,
  count: Integer; const selection_rect: PCefRect; active_match_ordinal,
  final_update: Integer); stdcall;
begin
  with TCefFindHandlerOwn(CefGetObject(self)) do
    OnFindResult(TCefBrowserRef.UnWrap(browser), identifier, count, selection_rect,
      active_match_ordinal, final_update <> 0);
end;

{ cef_request_context_handler }

function cef_request_context_handler_get_cookie_manager(self: PCefRequestContextHandler): PCefCookieManager; stdcall;
begin
  with TCefRequestContextHandlerOwn(CefGetObject(self)) do
    Result := CefGetData(GetCookieManager());
end;

function cef_request_context_handler_on_before_plugin_load(self: PCefRequestContextHandler;
  const mime_type, plugin_url, top_origin_url: PCefString;
  plugin_info: PCefWebPluginInfo; plugin_policy: PCefPluginPolicy): Integer; stdcall;
begin
  with TCefRequestContextHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnBeforePluginLoad(CefString(mime_type), CefString(plugin_url),
      CefString(top_origin_url), TCefWebPluginInfoRef.UnWrap(plugin_info), plugin_policy));
end;

{  cef_write_handler_ }

function cef_write_handler_write(self: PCefWriteHandler; const ptr: Pointer;
  size, n: NativeUInt): NativeUInt; stdcall;
begin
  with TCefWriteHandlerOwn(CefGetObject(self)) do
    Result:= Write(ptr, size, n);
end;

function cef_write_handler_seek(self: PCefWriteHandler; offset: Int64;
  whence: Integer): Integer; stdcall;
begin
  with TCefWriteHandlerOwn(CefGetObject(self)) do
    Result := Seek(offset, whence);
end;

function cef_write_handler_tell(self: PCefWriteHandler): Int64; stdcall;
begin
  with TCefWriteHandlerOwn(CefGetObject(self)) do
    Result := Tell();
end;

function cef_write_handler_flush(self: PCefWriteHandler): Integer; stdcall;
begin
  with TCefWriteHandlerOwn(CefGetObject(self)) do
    Result := Flush();
end;

function cef_write_handler_may_block(self: PCefWriteHandler): Integer; stdcall;
begin
  with TCefWriteHandlerOwn(CefGetObject(self)) do
    Result := Ord(MayBlock);
end;

{ cef_navigation_entry_visitor }

function cef_navigation_entry_visitor_visit(self: PCefNavigationEntryVisitor;
  entry: PCefNavigationEntry; current, index, total: Integer): Integer; stdcall;
begin
  with TCefNavigationEntryVisitorOwn(CefGetObject(self)) do
    Result := Ord(Visit(TCefNavigationEntryRef.UnWrap(entry), current <> 0, index, total));
end;

{ cef_set_cookie_callback }

procedure cef_set_cookie_callback_on_complete(self: PCefSetCookieCallback; success: Integer); stdcall;
begin
  with TCefSetCookieCallbackOwn(CefGetObject(self)) do
    OnComplete(success <> 0);
end;

{ cef_delete_cookie_callback }

procedure cef_delete_cookie_callback_on_complete(self: PCefDeleteCookiesCallback; num_deleted: Integer); stdcall;
begin
  with TCefDeleteCookiesCallbackOwn(CefGetObject(self)) do
    OnComplete(num_deleted);
end;

{ cef_pdf_print_callback }

procedure cef_pdf_print_callback_on_pdf_print_finished(self: PCefPdfPrintCallback; const path: PCefString; ok: Integer); stdcall;
begin
  with TCefPdfPrintCallbackOwn(CefGetObject(self)) do
    OnPdfPrintFinished(CefString(path), ok <> 0);
end;


{ TCefBaseOwn }

constructor TCefBaseOwn.CreateData(size: Cardinal; owned: Boolean);
begin
  GetMem(FData, size + SizeOf(Pointer));
  PPointer(FData)^ := Self;
  Inc(PByte(FData), SizeOf(Pointer));
  FillChar(FData^, size, 0);
  PCefBase(FData)^.size := size;
  if owned then
  begin
    PCefBase(FData)^.add_ref := cef_base_add_ref_owned;
    PCefBase(FData)^.release := cef_base_release_owned;
    PCefBase(FData)^.has_one_ref := cef_base_has_one_ref_owned;
  end else
  begin
    PCefBase(FData)^.add_ref := cef_base_add_ref;
    PCefBase(FData)^.release := cef_base_release;
    PCefBase(FData)^.has_one_ref := cef_base_has_one_ref;
  end;
end;

destructor TCefBaseOwn.Destroy;
begin
  Dec(PByte(FData), SizeOf(Pointer));
  FreeMem(FData);
  inherited;
end;

function TCefBaseOwn.Wrap: Pointer;
begin
  Result := FData;
  if Assigned(PCefBase(FData)^.add_ref) then
    PCefBase(FData)^.add_ref(PCefBase(FData));
end;

{ TCefBaseRef }

constructor TCefBaseRef.Create(data: Pointer);
begin
  Assert(data <> nil);
  FData := data;
end;

destructor TCefBaseRef.Destroy;
begin
  if Assigned(PCefBase(FData)^.release) then
    PCefBase(FData)^.release(PCefBase(FData));
  inherited;
end;

class function TCefBaseRef.UnWrap(data: Pointer): ICefBase;
begin
  if data <> nil then
    Result := Create(data) as ICefBase else
    Result := nil;
end;

function TCefBaseRef.Wrap: Pointer;
begin
  Result := FData;
  if Assigned(PCefBase(FData)^.add_ref) then
    PCefBase(FData)^.add_ref(PCefBase(FData));
end;

{ TCefBrowserRef }

function TCefBrowserRef.GetHost: ICefBrowserHost;
begin
  Result := TCefBrowserHostRef.UnWrap(PCefBrowser(FData)^.get_host(PCefBrowser(FData)));
end;

function TCefBrowserRef.CanGoBack: Boolean;
begin
  Result := PCefBrowser(FData)^.can_go_back(PCefBrowser(FData)) <> 0;
end;

function TCefBrowserRef.CanGoForward: Boolean;
begin
  Result := PCefBrowser(FData)^.can_go_forward(PCefBrowser(FData)) <> 0;
end;

function TCefBrowserRef.GetFocusedFrame: ICefFrame;
begin
  Result := TCefFrameRef.UnWrap(PCefBrowser(FData)^.get_focused_frame(PCefBrowser(FData)))
end;

function TCefBrowserRef.GetFrameByident(identifier: Int64): ICefFrame;
begin
  Result := TCefFrameRef.UnWrap(PCefBrowser(FData)^.get_frame_byident(PCefBrowser(FData), identifier));
end;

function TCefBrowserRef.GetFrame(const name: ustring): ICefFrame;
var
  n: TCefString;
begin
  n := CefString(name);
  Result := TCefFrameRef.UnWrap(PCefBrowser(FData)^.get_frame(PCefBrowser(FData), @n));
end;

function TCefBrowserRef.GetFrameCount: NativeUInt;
begin
  Result := PCefBrowser(FData)^.get_frame_count(PCefBrowser(FData));
end;

procedure TCefBrowserRef.GetFrameIdentifiers(count: PNativeUInt; identifiers: PInt64);
begin
  PCefBrowser(FData)^.get_frame_identifiers(PCefBrowser(FData), count, identifiers);
end;

procedure TCefBrowserRef.GetFrameNames(names: TStrings);
var
  list: TCefStringList;
  i: Integer;
  str: TCefString;
begin
  list := cef_string_list_alloc;
  try
    PCefBrowser(FData)^.get_frame_names(PCefBrowser(FData), list);
    FillChar(str, SizeOf(str), 0);
    for i := 0 to cef_string_list_size(list) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(list, i, @str);
      names.Add(CefStringClearAndGet(str));
    end;
  finally
    cef_string_list_free(list);
  end;
end;

function TCefBrowserRef.SendProcessMessage(targetProcess: TCefProcessId;
  message: ICefProcessMessage): Boolean;
begin
  Result := PCefBrowser(FData)^.send_process_message(PCefBrowser(FData), targetProcess, CefGetData(message)) <> 0;
end;

function TCefBrowserRef.GetMainFrame: ICefFrame;
begin
  Result := TCefFrameRef.UnWrap(PCefBrowser(FData)^.get_main_frame(PCefBrowser(FData)))
end;

procedure TCefBrowserRef.GoBack;
begin
  PCefBrowser(FData)^.go_back(PCefBrowser(FData));
end;

procedure TCefBrowserRef.GoForward;
begin
  PCefBrowser(FData)^.go_forward(PCefBrowser(FData));
end;

function TCefBrowserRef.IsLoading: Boolean;
begin
  Result := PCefBrowser(FData)^.is_loading(PCefBrowser(FData)) <> 0;
end;

function TCefBrowserRef.HasDocument: Boolean;
begin
  Result := PCefBrowser(FData)^.has_document(PCefBrowser(FData)) <> 0;
end;

function TCefBrowserRef.IsPopup: Boolean;
begin
  Result := PCefBrowser(FData)^.is_popup(PCefBrowser(FData)) <> 0;
end;

function TCefBrowserRef.IsSame(const that: ICefBrowser): Boolean;
begin
  Result := PCefBrowser(FData)^.is_same(PCefBrowser(FData), CefGetData(that)) <> 0;
end;

procedure TCefBrowserRef.Reload;
begin
  PCefBrowser(FData)^.reload(PCefBrowser(FData));
end;

procedure TCefBrowserRef.ReloadIgnoreCache;
begin
  PCefBrowser(FData)^.reload_ignore_cache(PCefBrowser(FData));
end;

procedure TCefBrowserRef.StopLoad;
begin
  PCefBrowser(FData)^.stop_load(PCefBrowser(FData));
end;

function TCefBrowserRef.GetIdentifier: Integer;
begin
  Result := PCefBrowser(FData)^.get_identifier(PCefBrowser(FData));
end;

class function TCefBrowserRef.UnWrap(data: Pointer): ICefBrowser;
begin
  if data <> nil then
    Result := Create(data) as ICefBrowser else
    Result := nil;
end;

{ TCefFrameRef }

function TCefFrameRef.IsValid: Boolean;
begin
  Result := PCefFrame(FData)^.is_valid(PCefFrame(FData)) <> 0;
end;

procedure TCefFrameRef.Copy;
begin
  PCefFrame(FData)^.copy(PCefFrame(FData));
end;

procedure TCefFrameRef.Cut;
begin
  PCefFrame(FData)^.cut(PCefFrame(FData));
end;

procedure TCefFrameRef.Del;
begin
  PCefFrame(FData)^.del(PCefFrame(FData));
end;

procedure TCefFrameRef.ExecuteJavaScript(const code, scriptUrl: ustring;
  startLine: Integer);
var
  j, s: TCefString;
begin
  j := CefString(code);
  s := CefString(scriptUrl);
  PCefFrame(FData)^.execute_java_script(PCefFrame(FData), @j, @s, startline);
end;

function TCefFrameRef.GetBrowser: ICefBrowser;
begin
  Result := TCefBrowserRef.UnWrap(PCefFrame(FData)^.get_browser(PCefFrame(FData)));
end;

function TCefFrameRef.GetIdentifier: Int64;
begin
  Result := PCefFrame(FData)^.get_identifier(PCefFrame(FData));
end;

function TCefFrameRef.GetName: ustring;
begin
  Result := CefStringFreeAndGet(PCefFrame(FData)^.get_name(PCefFrame(FData)));
end;

function TCefFrameRef.GetParent: ICefFrame;
begin
  Result := TCefFrameRef.UnWrap(PCefFrame(FData)^.get_parent(PCefFrame(FData)));
end;

procedure TCefFrameRef.GetSource(const visitor: ICefStringVisitor);
begin
  PCefFrame(FData)^.get_source(PCefFrame(FData), CefGetData(visitor));
end;

procedure TCefFrameRef.GetSourceProc(const proc: TCefStringVisitorProc);
begin
  GetSource(TCefFastStringVisitor.Create(proc));
end;

procedure TCefFrameRef.getText(const visitor: ICefStringVisitor);
begin
  PCefFrame(FData)^.get_text(PCefFrame(FData), CefGetData(visitor));
end;

procedure TCefFrameRef.GetTextProc(const proc: TCefStringVisitorProc);
begin
  GetText(TCefFastStringVisitor.Create(proc));
end;

function TCefFrameRef.GetUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefFrame(FData)^.get_url(PCefFrame(FData)));
end;

function TCefFrameRef.GetV8Context: ICefv8Context;
begin
  Result := TCefv8ContextRef.UnWrap(PCefFrame(FData)^.get_v8context(PCefFrame(FData)));
end;

function TCefFrameRef.IsFocused: Boolean;
begin
  Result := PCefFrame(FData)^.is_focused(PCefFrame(FData)) <> 0;
end;

function TCefFrameRef.IsMain: Boolean;
begin
  Result := PCefFrame(FData)^.is_main(PCefFrame(FData)) <> 0;
end;

procedure TCefFrameRef.LoadRequest(const request: ICefRequest);
begin
  PCefFrame(FData)^.load_request(PCefFrame(FData), CefGetData(request));
end;

procedure TCefFrameRef.LoadString(const str, url: ustring);
var
  s, u: TCefString;
begin
  s := CefString(str);
  u := CefString(url);
  PCefFrame(FData)^.load_string(PCefFrame(FData), @s, @u);
end;

procedure TCefFrameRef.LoadUrl(const url: ustring);
var
  u: TCefString;
begin
  u := CefString(url);
  PCefFrame(FData)^.load_url(PCefFrame(FData), @u);

end;

procedure TCefFrameRef.Paste;
begin
  PCefFrame(FData)^.paste(PCefFrame(FData));
end;

procedure TCefFrameRef.Redo;
begin
  PCefFrame(FData)^.redo(PCefFrame(FData));
end;

procedure TCefFrameRef.SelectAll;
begin
  PCefFrame(FData)^.select_all(PCefFrame(FData));
end;

procedure TCefFrameRef.Undo;
begin
  PCefFrame(FData)^.undo(PCefFrame(FData));
end;

procedure TCefFrameRef.ViewSource;
begin
  PCefFrame(FData)^.view_source(PCefFrame(FData));
end;

procedure TCefFrameRef.VisitDom(const visitor: ICefDomVisitor);
begin
  PCefFrame(FData)^.visit_dom(PCefFrame(FData), CefGetData(visitor));
end;

procedure TCefFrameRef.VisitDomProc(const proc: TCefDomVisitorProc);
begin
  VisitDom(TCefFastDomVisitor.Create(proc) as ICefDomVisitor);
end;

class function TCefFrameRef.UnWrap(data: Pointer): ICefFrame;
begin
  if data <> nil then
    Result := Create(data) as ICefFrame else
    Result := nil;
end;

{ TCefCustomStreamReader }

constructor TCefCustomStreamReader.Create(Stream: TStream; Owned: Boolean);
begin
  inherited CreateData(SizeOf(TCefReadHandler));
  FStream := stream;
  FOwned := Owned;
  with PCefReadHandler(FData)^ do
  begin
    read := cef_stream_reader_read;
    seek := cef_stream_reader_seek;
    tell := cef_stream_reader_tell;
    eof := cef_stream_reader_eof;
    may_block := cef_stream_reader_may_block;
  end;
end;

constructor TCefCustomStreamReader.Create(const filename: string);
begin
  Create(TFileStream.Create(filename, fmOpenRead or fmShareDenyWrite), True);
end;

destructor TCefCustomStreamReader.Destroy;
begin
  if FOwned then
    FStream.Free;
  inherited;
end;

function TCefCustomStreamReader.Eof: Boolean;
begin
  Result := FStream.Position = FStream.size;
end;

function TCefCustomStreamReader.MayBlock: Boolean;
begin
  Result := False;
end;

function TCefCustomStreamReader.Read(ptr: Pointer; size, n: NativeUInt): NativeUInt;
begin
  result := NativeUInt(FStream.Read(ptr^, n * size)) div size;
end;

function TCefCustomStreamReader.Seek(offset: Int64; whence: Integer): Integer;
begin
  Result := FStream.Seek(offset, whence);
end;

function TCefCustomStreamReader.Tell: Int64;
begin
  Result := FStream.Position;
end;

{ TCefPostDataRef }

function TCefPostDataRef.IsReadOnly: Boolean;
begin
  Result := PCefPostData(FData)^.is_read_only(PCefPostData(FData)) <> 0;
end;

function TCefPostDataRef.AddElement(
  const element: ICefPostDataElement): Integer;
begin
  Result := PCefPostData(FData)^.add_element(PCefPostData(FData), CefGetData(element));
end;

function TCefPostDataRef.GetCount: NativeUInt;
begin
  Result := PCefPostData(FData)^.get_element_count(PCefPostData(FData))
end;

function TCefPostDataRef.GetElements(Count: NativeUInt): IInterfaceList;
var
  items: PCefPostDataElementArray;
  i: Integer;
begin
  Result := TInterfaceList.Create;
  GetMem(items, SizeOf(PCefPostDataElement) * Count);
  FillChar(items^, SizeOf(PCefPostDataElement) * Count, 0);
  try
    PCefPostData(FData)^.get_elements(PCefPostData(FData), @Count, items);
    for i := 0 to Count - 1 do
      Result.Add(TCefPostDataElementRef.UnWrap(items[i]));
  finally
    FreeMem(items);
  end;
end;

class function TCefPostDataRef.New: ICefPostData;
begin
  Result := UnWrap(cef_post_data_create);
end;

function TCefPostDataRef.RemoveElement(
  const element: ICefPostDataElement): Integer;
begin
  Result := PCefPostData(FData)^.remove_element(PCefPostData(FData), CefGetData(element));
end;

procedure TCefPostDataRef.RemoveElements;
begin
  PCefPostData(FData)^.remove_elements(PCefPostData(FData));
end;

class function TCefPostDataRef.UnWrap(data: Pointer): ICefPostData;
begin
  if data <> nil then
    Result := Create(data) as ICefPostData else
    Result := nil;
end;

{ TCefPostDataElementRef }

function TCefPostDataElementRef.IsReadOnly: Boolean;
begin
  Result := PCefPostDataElement(FData)^.is_read_only(PCefPostDataElement(FData)) <> 0;
end;

function TCefPostDataElementRef.GetBytes(size: NativeUInt;
  bytes: Pointer): NativeUInt;
begin
  Result := PCefPostDataElement(FData)^.get_bytes(PCefPostDataElement(FData), size, bytes);
end;

function TCefPostDataElementRef.GetBytesCount: NativeUInt;
begin
  Result := PCefPostDataElement(FData)^.get_bytes_count(PCefPostDataElement(FData));
end;

function TCefPostDataElementRef.GetFile: ustring;
begin
  Result := CefStringFreeAndGet(PCefPostDataElement(FData)^.get_file(PCefPostDataElement(FData)));
end;

function TCefPostDataElementRef.GetType: TCefPostDataElementType;
begin
  Result := PCefPostDataElement(FData)^.get_type(PCefPostDataElement(FData));
end;

class function TCefPostDataElementRef.New: ICefPostDataElement;
begin
  Result := UnWrap(cef_post_data_element_create);
end;

procedure TCefPostDataElementRef.SetToBytes(size: NativeUInt; bytes: Pointer);
begin
  PCefPostDataElement(FData)^.set_to_bytes(PCefPostDataElement(FData), size, bytes);
end;

procedure TCefPostDataElementRef.SetToEmpty;
begin
  PCefPostDataElement(FData)^.set_to_empty(PCefPostDataElement(FData));
end;

procedure TCefPostDataElementRef.SetToFile(const fileName: ustring);
var
  f: TCefString;
begin
  f := CefString(fileName);
  PCefPostDataElement(FData)^.set_to_file(PCefPostDataElement(FData), @f);
end;

class function TCefPostDataElementRef.UnWrap(data: Pointer): ICefPostDataElement;
begin
  if data <> nil then
    Result := Create(data) as ICefPostDataElement else
    Result := nil;
end;

{ TCefPostDataElementOwn }

procedure TCefPostDataElementOwn.Clear;
begin
  case FDataType of
    PDE_TYPE_BYTES:
      if (FValueByte <> nil) then
      begin
        FreeMem(FValueByte);
        FValueByte := nil;
      end;
    PDE_TYPE_FILE:
      CefStringFree(@FValueStr)
  end;
  FDataType := PDE_TYPE_EMPTY;
  FSize := 0;
end;

constructor TCefPostDataElementOwn.Create(readonly: Boolean);
begin
  inherited CreateData(SizeOf(TCefPostDataElement));
  FReadOnly := readonly;
  FDataType := PDE_TYPE_EMPTY;
  FValueByte := nil;
  FillChar(FValueStr, SizeOf(FValueStr), 0);
  FSize := 0;
  with PCefPostDataElement(FData)^ do
  begin
    is_read_only := cef_post_data_element_is_read_only;
    set_to_empty := cef_post_data_element_set_to_empty;
    set_to_file := cef_post_data_element_set_to_file;
    set_to_bytes := cef_post_data_element_set_to_bytes;
    get_type := cef_post_data_element_get_type;
    get_file := cef_post_data_element_get_file;
    get_bytes_count := cef_post_data_element_get_bytes_count;
    get_bytes := cef_post_data_element_get_bytes;
  end;
end;

function TCefPostDataElementOwn.GetBytes(size: NativeUInt;
  bytes: Pointer): NativeUInt;
begin
  if (FDataType = PDE_TYPE_BYTES) and (FValueByte <> nil) then
  begin
    if size > FSize then
      Result := FSize else
      Result := size;
    Move(FValueByte^, bytes^, Result);
  end else
    Result := 0;
end;

function TCefPostDataElementOwn.GetBytesCount: NativeUInt;
begin
  if (FDataType = PDE_TYPE_BYTES) then
    Result := FSize else
    Result := 0;
end;

function TCefPostDataElementOwn.GetFile: ustring;
begin
  if (FDataType = PDE_TYPE_FILE) then
    Result := CefString(@FValueStr) else
    Result := '';
end;

function TCefPostDataElementOwn.GetType: TCefPostDataElementType;
begin
  Result := FDataType;
end;

function TCefPostDataElementOwn.IsReadOnly: Boolean;
begin
  Result := FReadOnly;
end;

procedure TCefPostDataElementOwn.SetToBytes(size: NativeUInt; bytes: Pointer);
begin
  Clear;
  if (size > 0) and (bytes <> nil) then
  begin
    GetMem(FValueByte, size);
    Move(bytes^, FValueByte, size);
    FSize := size;
  end else
  begin
    FValueByte := nil;
    FSize := 0;
  end;
  FDataType := PDE_TYPE_BYTES;
end;

procedure TCefPostDataElementOwn.SetToEmpty;
begin
  Clear;
end;

procedure TCefPostDataElementOwn.SetToFile(const fileName: ustring);
begin
  Clear;
  FSize := 0;
  FValueStr := CefStringAlloc(fileName);
  FDataType := PDE_TYPE_FILE;
end;

{ TCefRequestRef }

function TCefRequestRef.IsReadOnly: Boolean;
begin
  Result := PCefRequest(FData).is_read_only(PCefRequest(FData)) <> 0;
end;

procedure TCefRequestRef.Assign(const url, method: ustring;
  const postData: ICefPostData; const headerMap: ICefStringMultimap);
var
  u, m: TCefString;
begin
  u := cefstring(url);
  m := cefstring(method);
  PCefRequest(FData).set_(PCefRequest(FData), @u, @m, CefGetData(postData), headerMap.Handle);
end;

function TCefRequestRef.GetFirstPartyForCookies: ustring;
begin
  Result := CefStringFreeAndGet(PCefRequest(FData).get_first_party_for_cookies(PCefRequest(FData)));
end;

function TCefRequestRef.GetFlags: TCefUrlRequestFlags;
begin
  Byte(Result) := PCefRequest(FData)^.get_flags(PCefRequest(FData));
end;

procedure TCefRequestRef.GetHeaderMap(const HeaderMap: ICefStringMultimap);
begin
  PCefRequest(FData)^.get_header_map(PCefRequest(FData), HeaderMap.Handle);
end;

function TCefRequestRef.GetIdentifier: UInt64;
begin
  Result := PCefRequest(FData)^.get_identifier(PCefRequest(FData));
end;

function TCefRequestRef.GetMethod: ustring;
begin
  Result := CefStringFreeAndGet(PCefRequest(FData)^.get_method(PCefRequest(FData)))
end;

function TCefRequestRef.GetPostData: ICefPostData;
begin
  Result := TCefPostDataRef.UnWrap(PCefRequest(FData)^.get_post_data(PCefRequest(FData)));
end;

function TCefRequestRef.GetResourceType: TCefResourceType;
begin
  Result := PCefRequest(FData).get_resource_type(FData);
end;

function TCefRequestRef.GetTransitionType: TCefTransitionType;
begin
    Result := PCefRequest(FData).get_transition_type(FData);
end;

function TCefRequestRef.GetUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefRequest(FData)^.get_url(PCefRequest(FData)))
end;

class function TCefRequestRef.New: ICefRequest;
begin
  Result := UnWrap(cef_request_create);
end;

procedure TCefRequestRef.SetFirstPartyForCookies(const url: ustring);
var
  str: TCefString;
begin
  str := CefString(url);
  PCefRequest(FData).set_first_party_for_cookies(PCefRequest(FData), @str);
end;

procedure TCefRequestRef.SetFlags(flags: TCefUrlRequestFlags);
begin
  PCefRequest(FData)^.set_flags(PCefRequest(FData), PByte(@flags)^);
end;

procedure TCefRequestRef.SetHeaderMap(const HeaderMap: ICefStringMultimap);
begin
  PCefRequest(FData)^.set_header_map(PCefRequest(FData), HeaderMap.Handle);
end;

procedure TCefRequestRef.SetMethod(const value: ustring);
var
  v: TCefString;
begin
  v := CefString(value);
  PCefRequest(FData)^.set_method(PCefRequest(FData), @v);
end;

procedure TCefRequestRef.SetPostData(const value: ICefPostData);
begin
  if value <> nil then
    PCefRequest(FData)^.set_post_data(PCefRequest(FData), CefGetData(value));
end;

procedure TCefRequestRef.SetUrl(const value: ustring);
var
  v: TCefString;
begin
  v := CefString(value);
  PCefRequest(FData)^.set_url(PCefRequest(FData), @v);
end;

class function TCefRequestRef.UnWrap(data: Pointer): ICefRequest;
begin
  if data <> nil then
    Result := Create(data) as ICefRequest else
    Result := nil;
end;

{ TCefStreamReaderRef }

class function TCefStreamReaderRef.CreateForCustomStream(
  const stream: ICefCustomStreamReader): ICefStreamReader;
begin
  Result := UnWrap(cef_stream_reader_create_for_handler(CefGetData(stream)))
end;

class function TCefStreamReaderRef.CreateForData(data: Pointer; size: NativeUInt): ICefStreamReader;
begin
  Result := UnWrap(cef_stream_reader_create_for_data(data, size))
end;

class function TCefStreamReaderRef.CreateForFile(const filename: ustring): ICefStreamReader;
var
  f: TCefString;
begin
  f := CefString(filename);
  Result := UnWrap(cef_stream_reader_create_for_file(@f))
end;

class function TCefStreamReaderRef.CreateForStream(const stream: TSTream;
  owned: Boolean): ICefStreamReader;
begin
  Result := CreateForCustomStream(TCefCustomStreamReader.Create(stream, owned) as ICefCustomStreamReader);
end;

function TCefStreamReaderRef.Eof: Boolean;
begin
  Result := PCefStreamReader(FData)^.eof(PCefStreamReader(FData)) <> 0;
end;

function TCefStreamReaderRef.MayBlock: Boolean;
begin
  Result := PCefStreamReader(FData)^.may_block(FData) <> 0;
end;

function TCefStreamReaderRef.Read(ptr: Pointer; size, n: NativeUInt): NativeUInt;
begin
  Result := PCefStreamReader(FData)^.read(PCefStreamReader(FData), ptr, size, n);
end;

function TCefStreamReaderRef.Seek(offset: Int64; whence: Integer): Integer;
begin
  Result := PCefStreamReader(FData)^.seek(PCefStreamReader(FData), offset, whence);
end;

function TCefStreamReaderRef.Tell: Int64;
begin
  Result := PCefStreamReader(FData)^.tell(PCefStreamReader(FData));
end;

class function TCefStreamReaderRef.UnWrap(data: Pointer): ICefStreamReader;
begin
  if data <> nil then
    Result := Create(data) as ICefStreamReader else
    Result := nil;
end;

{ TCefv8ValueRef }

function TCefv8ValueRef.AdjustExternallyAllocatedMemory(
  changeInBytes: Integer): Integer;
begin
  Result := PCefV8Value(FData)^.adjust_externally_allocated_memory(PCefV8Value(FData), changeInBytes);
end;

class function TCefv8ValueRef.NewArray(len: Integer): ICefv8Value;
begin
  Result := UnWrap(cef_v8value_create_array(len));
end;

class function TCefv8ValueRef.NewBool(value: Boolean): ICefv8Value;
begin
  Result := UnWrap(cef_v8value_create_bool(Ord(value)));
end;

class function TCefv8ValueRef.NewDate(value: TDateTime): ICefv8Value;
var
  dt: TCefTime;
begin
  dt := DateTimeToCefTime(value);
  Result := UnWrap(cef_v8value_create_date(@dt));
end;

class function TCefv8ValueRef.NewDouble(value: Double): ICefv8Value;
begin
  Result := UnWrap(cef_v8value_create_double(value));
end;

class function TCefv8ValueRef.NewFunction(const name: ustring;
  const handler: ICefv8Handler): ICefv8Value;
var
  n: TCefString;
begin
  n := CefString(name);
  Result := UnWrap(cef_v8value_create_function(@n, CefGetData(handler)));
end;

class function TCefv8ValueRef.NewInt(value: Integer): ICefv8Value;
begin
  Result := UnWrap(cef_v8value_create_int(value));
end;

class function TCefv8ValueRef.NewUInt(value: Cardinal): ICefv8Value;
begin
  Result := UnWrap(cef_v8value_create_uint(value));
end;

class function TCefv8ValueRef.NewNull: ICefv8Value;
begin
  Result := UnWrap(cef_v8value_create_null);
end;

class function TCefv8ValueRef.NewObject(const Accessor: ICefV8Accessor): ICefv8Value;
begin
  Result := UnWrap(cef_v8value_create_object(CefGetData(Accessor)));
end;

class function TCefv8ValueRef.NewObjectProc(const getter: TCefV8AccessorGetterProc;
  const setter: TCefV8AccessorSetterProc): ICefv8Value;
begin
  Result := NewObject(TCefFastV8Accessor.Create(getter, setter) as ICefV8Accessor);
end;

class function TCefv8ValueRef.NewString(const str: ustring): ICefv8Value;
var
  s: TCefString;
begin
  s := CefString(str);
  Result := UnWrap(cef_v8value_create_string(@s));
end;

class function TCefv8ValueRef.NewUndefined: ICefv8Value;
begin
  Result := UnWrap(cef_v8value_create_undefined);
end;

function TCefv8ValueRef.DeleteValueByIndex(index: Integer): Boolean;
begin
  Result := PCefV8Value(FData)^.delete_value_byindex(PCefV8Value(FData), index) <> 0;
end;

function TCefv8ValueRef.DeleteValueByKey(const key: ustring): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefV8Value(FData)^.delete_value_bykey(PCefV8Value(FData), @k) <> 0;
end;

function TCefv8ValueRef.ExecuteFunction(const obj: ICefv8Value;
  const arguments: TCefv8ValueArray): ICefv8Value;
var
  args: PPCefV8Value;
  i: Integer;
begin
  GetMem(args, SizeOf(PCefV8Value) * Length(arguments));
  try
    for i := 0 to Length(arguments) - 1 do
      args[i] := CefGetData(arguments[i]);
    Result := TCefv8ValueRef.UnWrap(PCefV8Value(FData)^.execute_function(PCefV8Value(FData),
      CefGetData(obj), Length(arguments), args));
  finally
    FreeMem(args);
  end;
end;

function TCefv8ValueRef.ExecuteFunctionWithContext(const context: ICefv8Context;
  const obj: ICefv8Value; const arguments: TCefv8ValueArray): ICefv8Value;
var
  args: PPCefV8Value;
  i: Integer;
begin
  GetMem(args, SizeOf(PCefV8Value) * Length(arguments));
  try
    for i := 0 to Length(arguments) - 1 do
      args[i] := CefGetData(arguments[i]);
    Result := TCefv8ValueRef.UnWrap(PCefV8Value(FData)^.execute_function_with_context(PCefV8Value(FData),
      CefGetData(context), CefGetData(obj), Length(arguments), args));
  finally
    FreeMem(args);
  end;
end;

function TCefv8ValueRef.GetArrayLength: Integer;
begin
  Result := PCefV8Value(FData)^.get_array_length(PCefV8Value(FData));
end;

function TCefv8ValueRef.GetBoolValue: Boolean;
begin
  Result := PCefV8Value(FData)^.get_bool_value(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.GetDateValue: TDateTime;
begin
  Result := CefTimeToDateTime(PCefV8Value(FData)^.get_date_value(PCefV8Value(FData)));
end;

function TCefv8ValueRef.GetDoubleValue: Double;
begin
  Result := PCefV8Value(FData)^.get_double_value(PCefV8Value(FData));
end;

function TCefv8ValueRef.GetExternallyAllocatedMemory: Integer;
begin
  Result := PCefV8Value(FData)^.get_externally_allocated_memory(PCefV8Value(FData));
end;

function TCefv8ValueRef.GetFunctionHandler: ICefv8Handler;
begin
  Result := TCefv8HandlerRef.UnWrap(PCefV8Value(FData)^.get_function_handler(PCefV8Value(FData)));
end;

function TCefv8ValueRef.GetFunctionName: ustring;
begin
  Result := CefStringFreeAndGet(PCefV8Value(FData)^.get_function_name(PCefV8Value(FData)))
end;

function TCefv8ValueRef.GetIntValue: Integer;
begin
  Result := PCefV8Value(FData)^.get_int_value(PCefV8Value(FData))
end;

function TCefv8ValueRef.GetUIntValue: Cardinal;
begin
  Result := PCefV8Value(FData)^.get_uint_value(PCefV8Value(FData))
end;

function TCefv8ValueRef.GetKeys(const keys: TStrings): Integer;
var
  list: TCefStringList;
  i: Integer;
  str: TCefString;
begin
  list := cef_string_list_alloc;
  try
    Result := PCefV8Value(FData)^.get_keys(PCefV8Value(FData), list);
    FillChar(str, SizeOf(str), 0);
    for i := 0 to cef_string_list_size(list) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(list, i, @str);
      keys.Add(CefStringClearAndGet(str));
    end;
  finally
    cef_string_list_free(list);
  end;
end;

function TCefv8ValueRef.SetUserData(const data: ICefv8Value): Boolean;
begin
  Result := PCefV8Value(FData)^.set_user_data(PCefV8Value(FData), CefGetData(data)) <> 0;
end;

function TCefv8ValueRef.GetStringValue: ustring;
begin
  Result := CefStringFreeAndGet(PCefV8Value(FData)^.get_string_value(PCefV8Value(FData)));
end;

function TCefv8ValueRef.IsUserCreated: Boolean;
begin
  Result := PCefV8Value(FData)^.is_user_created(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.IsValid: Boolean;
begin
  Result := PCefV8Value(FData)^.is_valid(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.HasException: Boolean;
begin
  Result := PCefV8Value(FData)^.has_exception(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.GetException: ICefV8Exception;
begin
   Result := TCefV8ExceptionRef.UnWrap(PCefV8Value(FData)^.get_exception(PCefV8Value(FData)));
end;

function TCefv8ValueRef.ClearException: Boolean;
begin
  Result := PCefV8Value(FData)^.clear_exception(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.WillRethrowExceptions: Boolean;
begin
  Result := PCefV8Value(FData)^.will_rethrow_exceptions(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.SetRethrowExceptions(rethrow: Boolean): Boolean;
begin
  Result := PCefV8Value(FData)^.set_rethrow_exceptions(PCefV8Value(FData), Ord(rethrow)) <> 0;
end;

function TCefv8ValueRef.GetUserData: ICefv8Value;
begin
  Result := TCefv8ValueRef.UnWrap(PCefV8Value(FData)^.get_user_data(PCefV8Value(FData)));
end;

function TCefv8ValueRef.GetValueByIndex(index: Integer): ICefv8Value;
begin
  Result := TCefv8ValueRef.UnWrap(PCefV8Value(FData)^.get_value_byindex(PCefV8Value(FData), index))
end;

function TCefv8ValueRef.GetValueByKey(const key: ustring): ICefv8Value;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := TCefv8ValueRef.UnWrap(PCefV8Value(FData)^.get_value_bykey(PCefV8Value(FData), @k))
end;

function TCefv8ValueRef.HasValueByIndex(index: Integer): Boolean;
begin
  Result := PCefV8Value(FData)^.has_value_byindex(PCefV8Value(FData), index) <> 0;
end;

function TCefv8ValueRef.HasValueByKey(const key: ustring): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefV8Value(FData)^.has_value_bykey(PCefV8Value(FData), @k) <> 0;
end;

function TCefv8ValueRef.IsArray: Boolean;
begin
  Result := PCefV8Value(FData)^.is_array(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.IsBool: Boolean;
begin
  Result := PCefV8Value(FData)^.is_bool(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.IsDate: Boolean;
begin
  Result := PCefV8Value(FData)^.is_date(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.IsDouble: Boolean;
begin
  Result := PCefV8Value(FData)^.is_double(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.IsFunction: Boolean;
begin
  Result := PCefV8Value(FData)^.is_function(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.IsInt: Boolean;
begin
  Result := PCefV8Value(FData)^.is_int(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.IsUInt: Boolean;
begin
  Result := PCefV8Value(FData)^.is_uint(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.IsNull: Boolean;
begin
  Result := PCefV8Value(FData)^.is_null(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.IsObject: Boolean;
begin
  Result := PCefV8Value(FData)^.is_object(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.IsSame(const that: ICefv8Value): Boolean;
begin
  Result := PCefV8Value(FData)^.is_same(PCefV8Value(FData), CefGetData(that)) <> 0;
end;

function TCefv8ValueRef.IsString: Boolean;
begin
  Result := PCefV8Value(FData)^.is_string(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.IsUndefined: Boolean;
begin
  Result := PCefV8Value(FData)^.is_undefined(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.SetValueByAccessor(const key: ustring;
  settings: TCefV8AccessControls; attribute: TCefV8PropertyAttributes): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result:= PCefV8Value(FData)^.set_value_byaccessor(PCefV8Value(FData), @k,
    PByte(@settings)^, PByte(@attribute)^) <> 0;
end;

function TCefv8ValueRef.SetValueByIndex(index: Integer;
  const value: ICefv8Value): Boolean;
begin
  Result:= PCefV8Value(FData)^.set_value_byindex(PCefV8Value(FData), index, CefGetData(value)) <> 0;
end;

function TCefv8ValueRef.SetValueByKey(const key: ustring;
  const value: ICefv8Value; attribute: TCefV8PropertyAttributes): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result:= PCefV8Value(FData)^.set_value_bykey(PCefV8Value(FData), @k,
    CefGetData(value), PByte(@attribute)^) <> 0;
end;

class function TCefv8ValueRef.UnWrap(data: Pointer): ICefv8Value;
begin
  if data <> nil then
    Result := Create(data) as ICefv8Value else
    Result := nil;
end;

{ TCefv8HandlerRef }

function TCefv8HandlerRef.Execute(const name: ustring; const obj: ICefv8Value;
  const arguments: TCefv8ValueArray; var retval: ICefv8Value;
  var exception: ustring): Boolean;
var
  args: array of PCefV8Value;
  i: Integer;
  ret: PCefV8Value;
  exc: TCefString;
  n: TCefString;
begin
  SetLength(args, Length(arguments));
  for i := 0 to Length(arguments) - 1 do
    args[i] := CefGetData(arguments[i]);
  ret := nil;
  FillChar(exc, SizeOf(exc), 0);
  n := CefString(name);
  Result := PCefv8Handler(FData)^.execute(PCefv8Handler(FData), @n,
    CefGetData(obj), Length(arguments), @args, ret, exc) <> 0;
  retval := TCefv8ValueRef.UnWrap(ret);
  exception := CefStringClearAndGet(exc);
end;

class function TCefv8HandlerRef.UnWrap(data: Pointer): ICefv8Handler;
begin
  if data <> nil then
    Result := Create(data) as ICefv8Handler else
    Result := nil;
end;

{ TCefv8HandlerOwn }

constructor TCefv8HandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefv8Handler));
  with PCefv8Handler(FData)^ do
    execute := cef_v8_handler_execute;
end;

function TCefv8HandlerOwn.Execute(const name: ustring; const obj: ICefv8Value;
  const arguments: TCefv8ValueArray; var retval: ICefv8Value;
  var exception: ustring): Boolean;
begin
  Result := False;
end;

{ TCefTaskOwn }

constructor TCefTaskOwn.Create;
begin
  inherited CreateData(SizeOf(TCefTask));
  with PCefTask(FData)^ do
    execute := cef_task_execute;
end;

procedure TCefTaskOwn.Execute;
begin

end;

{ TCefStringMapOwn }

procedure TCefStringMapOwn.Append(const key, value: ustring);
var
  k, v: TCefString;
begin
  k := CefString(key);
  v := CefString(value);
  cef_string_map_append(FStringMap, @k, @v);
end;

procedure TCefStringMapOwn.Clear;
begin
  cef_string_map_clear(FStringMap);
end;

constructor TCefStringMapOwn.Create;
begin
  FStringMap := cef_string_map_alloc;
end;

destructor TCefStringMapOwn.Destroy;
begin
  cef_string_map_free(FStringMap);
end;

function TCefStringMapOwn.Find(const key: ustring): ustring;
var
  str, k: TCefString;
begin
  FillChar(str, SizeOf(str), 0);
  k := CefString(key);
  cef_string_map_find(FStringMap, @k, str);
  Result := CefString(@str);
end;

function TCefStringMapOwn.GetHandle: TCefStringMap;
begin
  Result := FStringMap;
end;

function TCefStringMapOwn.GetKey(index: Integer): ustring;
var
  str: TCefString;
begin
  FillChar(str, SizeOf(str), 0);
  cef_string_map_key(FStringMap, index, str);
  Result := CefString(@str);
end;

function TCefStringMapOwn.GetSize: Integer;
begin
  Result := cef_string_map_size(FStringMap);
end;

function TCefStringMapOwn.GetValue(index: Integer): ustring;
var
  str: TCefString;
begin
  FillChar(str, SizeOf(str), 0);
  cef_string_map_value(FStringMap, index, str);
  Result := CefString(@str);
end;

{ TCefStringMultimapOwn }

procedure TCefStringMultimapOwn.Append(const Key, Value: ustring);
var
  k, v: TCefString;
begin
  k := CefString(key);
  v := CefString(value);
  cef_string_multimap_append(FStringMap, @k, @v);
end;

procedure TCefStringMultimapOwn.Clear;
begin
  cef_string_multimap_clear(FStringMap);
end;

constructor TCefStringMultimapOwn.Create;
begin
  FStringMap := cef_string_multimap_alloc;
end;

destructor TCefStringMultimapOwn.Destroy;
begin
  cef_string_multimap_free(FStringMap);
  inherited;
end;

function TCefStringMultimapOwn.FindCount(const Key: ustring): Integer;
var
  k: TCefString;
begin
  k := CefString(Key);
  Result := cef_string_multimap_find_count(FStringMap, @k);
end;

function TCefStringMultimapOwn.GetEnumerate(const Key: ustring;
  ValueIndex: Integer): ustring;
var
  k, v: TCefString;
begin
  k := CefString(Key);
  FillChar(v, SizeOf(v), 0);
  cef_string_multimap_enumerate(FStringMap, @k, ValueIndex, v);
  Result := CefString(@v);
end;

function TCefStringMultimapOwn.GetHandle: TCefStringMultimap;
begin
  Result := FStringMap;
end;

function TCefStringMultimapOwn.GetKey(Index: Integer): ustring;
var
  str: TCefString;
begin
  FillChar(str, SizeOf(str), 0);
  cef_string_multimap_key(FStringMap, index, str);
  Result := CefString(@str);
end;

function TCefStringMultimapOwn.GetSize: Integer;
begin
  Result := cef_string_multimap_size(FStringMap);
end;

function TCefStringMultimapOwn.GetValue(Index: Integer): ustring;
var
  str: TCefString;
begin
  FillChar(str, SizeOf(str), 0);
  cef_string_multimap_value(FStringMap, index, str);
  Result := CefString(@str);
end;

{ TCefDownloadHandlerOwn }

constructor TCefDownloadHandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefDownloadHandler));
  with PCefDownloadHandler(FData)^ do
  begin
    on_before_download := cef_download_handler_on_before_download;
    on_download_updated := cef_download_handler_on_download_updated;
  end;
end;

procedure TCefDownloadHandlerOwn.OnBeforeDownload(const browser: ICefBrowser;
  const downloadItem: ICefDownloadItem; const suggestedName: ustring;
  const callback: ICefBeforeDownloadCallback);
begin

end;

procedure TCefDownloadHandlerOwn.OnDownloadUpdated(const browser: ICefBrowser;
  const downloadItem: ICefDownloadItem;
  const callback: ICefDownloadItemCallback);
begin

end;

{ TCefXmlReaderRef }

function TCefXmlReaderRef.Close: Boolean;
begin
  Result := PCefXmlReader(FData).close(FData) <> 0;
end;

class function TCefXmlReaderRef.New(const stream: ICefStreamReader;
  encodingType: TCefXmlEncodingType; const URI: ustring): ICefXmlReader;
var
  u: TCefString;
begin
  u := CefString(URI);
  Result := UnWrap(cef_xml_reader_create(CefGetData(stream), encodingType, @u));
end;

function TCefXmlReaderRef.GetAttributeByIndex(index: Integer): ustring;
begin
  Result := CefStringFreeAndGet(PCefXmlReader(FData).get_attribute_byindex(FData, index));
end;

function TCefXmlReaderRef.GetAttributeByLName(const localName,
  namespaceURI: ustring): ustring;
var
  l, n: TCefString;
begin
  l := CefString(localName);
  n := CefString(namespaceURI);
  Result := CefStringFreeAndGet(PCefXmlReader(FData).get_attribute_bylname(FData, @l, @n));
end;

function TCefXmlReaderRef.GetAttributeByQName(
  const qualifiedName: ustring): ustring;
var
  q: TCefString;
begin
  q := CefString(qualifiedName);
  Result := CefStringFreeAndGet(PCefXmlReader(FData).get_attribute_byqname(FData, @q));
end;

function TCefXmlReaderRef.GetAttributeCount: NativeUInt;
begin
  Result := PCefXmlReader(FData).get_attribute_count(FData);
end;

function TCefXmlReaderRef.GetBaseUri: ustring;
begin
  Result := CefStringFreeAndGet(PCefXmlReader(FData).get_base_uri(FData));
end;

function TCefXmlReaderRef.GetDepth: Integer;
begin
  Result := PCefXmlReader(FData).get_depth(FData);
end;

function TCefXmlReaderRef.GetError: ustring;
begin
  Result := CefStringFreeAndGet(PCefXmlReader(FData).get_error(FData));
end;

function TCefXmlReaderRef.GetInnerXml: ustring;
begin
  Result := CefStringFreeAndGet(PCefXmlReader(FData).get_inner_xml(FData));
end;

function TCefXmlReaderRef.GetLineNumber: Integer;
begin
  Result := PCefXmlReader(FData).get_line_number(FData);
end;

function TCefXmlReaderRef.GetLocalName: ustring;
begin
  Result := CefStringFreeAndGet(PCefXmlReader(FData).get_local_name(FData));
end;

function TCefXmlReaderRef.GetNamespaceUri: ustring;
begin
  Result := CefStringFreeAndGet(PCefXmlReader(FData).get_namespace_uri(FData));
end;

function TCefXmlReaderRef.GetOuterXml: ustring;
begin
  Result := CefStringFreeAndGet(PCefXmlReader(FData).get_outer_xml(FData));
end;

function TCefXmlReaderRef.GetPrefix: ustring;
begin
  Result := CefStringFreeAndGet(PCefXmlReader(FData).get_prefix(FData));
end;

function TCefXmlReaderRef.GetQualifiedName: ustring;
begin
  Result := CefStringFreeAndGet(PCefXmlReader(FData).get_qualified_name(FData));
end;

function TCefXmlReaderRef.GetType: TCefXmlNodeType;
begin
  Result := PCefXmlReader(FData).get_type(FData);
end;

function TCefXmlReaderRef.GetValue: ustring;
begin
  Result := CefStringFreeAndGet(PCefXmlReader(FData).get_value(FData));
end;

function TCefXmlReaderRef.GetXmlLang: ustring;
begin
  Result := CefStringFreeAndGet(PCefXmlReader(FData).get_xml_lang(FData));
end;

function TCefXmlReaderRef.HasAttributes: Boolean;
begin
  Result := PCefXmlReader(FData).has_attributes(FData) <> 0;
end;

function TCefXmlReaderRef.HasError: Boolean;
begin
  Result := PCefXmlReader(FData).has_error(FData) <> 0;
end;

function TCefXmlReaderRef.HasValue: Boolean;
begin
  Result := PCefXmlReader(FData).has_value(FData) <> 0;
end;

function TCefXmlReaderRef.IsEmptyElement: Boolean;
begin
  Result := PCefXmlReader(FData).is_empty_element(FData) <> 0;
end;

function TCefXmlReaderRef.MoveToAttributeByIndex(index: Integer): Boolean;
begin
  Result := PCefXmlReader(FData).move_to_attribute_byindex(FData, index) <> 0;
end;

function TCefXmlReaderRef.MoveToAttributeByLName(const localName,
  namespaceURI: ustring): Boolean;
var
  l, n: TCefString;
begin
  l := CefString(localName);
  n := CefString(namespaceURI);
  Result := PCefXmlReader(FData).move_to_attribute_bylname(FData, @l, @n) <> 0;
end;

function TCefXmlReaderRef.MoveToAttributeByQName(
  const qualifiedName: ustring): Boolean;
var
  q: TCefString;
begin
  q := CefString(qualifiedName);
  Result := PCefXmlReader(FData).move_to_attribute_byqname(FData, @q) <> 0;
end;

function TCefXmlReaderRef.MoveToCarryingElement: Boolean;
begin
  Result := PCefXmlReader(FData).move_to_carrying_element(FData) <> 0;
end;

function TCefXmlReaderRef.MoveToFirstAttribute: Boolean;
begin
  Result := PCefXmlReader(FData).move_to_first_attribute(FData) <> 0;
end;

function TCefXmlReaderRef.MoveToNextAttribute: Boolean;
begin
  Result := PCefXmlReader(FData).move_to_next_attribute(FData) <> 0;
end;

function TCefXmlReaderRef.MoveToNextNode: Boolean;
begin
  Result := PCefXmlReader(FData).move_to_next_node(FData) <> 0;
end;

class function TCefXmlReaderRef.UnWrap(data: Pointer): ICefXmlReader;
begin
  if data <> nil then
    Result := Create(data) as ICefXmlReader else
    Result := nil;
end;

{ TCefZipReaderRef }

function TCefZipReaderRef.Close: Boolean;
begin
  Result := PCefZipReader(FData).close(FData) <> 0;
end;

function TCefZipReaderRef.CloseFile: Boolean;
begin
  Result := PCefZipReader(FData).close_file(FData) <> 0;
end;

class function TCefZipReaderRef.New(const stream: ICefStreamReader): ICefZipReader;
begin
  Result := UnWrap(cef_zip_reader_create(CefGetData(stream)));
end;

function TCefZipReaderRef.Eof: Boolean;
begin
  Result := PCefZipReader(FData).eof(FData) <> 0;
end;

function TCefZipReaderRef.GetFileLastModified: TCefTime;
begin
  Result := PCefZipReader(FData).get_file_last_modified(FData);
end;

function TCefZipReaderRef.GetFileName: ustring;
begin
  Result := CefStringFreeAndGet(PCefZipReader(FData).get_file_name(FData));
end;

function TCefZipReaderRef.GetFileSize: Int64;
begin
  Result := PCefZipReader(FData).get_file_size(FData);
end;

function TCefZipReaderRef.MoveToFile(const fileName: ustring;
  caseSensitive: Boolean): Boolean;
var
  f: TCefString;
begin
  f := CefString(fileName);
  Result := PCefZipReader(FData).move_to_file(FData, @f, Ord(caseSensitive)) <> 0;
end;

function TCefZipReaderRef.MoveToFirstFile: Boolean;
begin
  Result := PCefZipReader(FData).move_to_first_file(FData) <> 0;
end;

function TCefZipReaderRef.MoveToNextFile: Boolean;
begin
  Result := PCefZipReader(FData).move_to_next_file(FData) <> 0;
end;

function TCefZipReaderRef.OpenFile(const password: ustring): Boolean;
var
  p: TCefString;
begin
  p := CefString(password);
  Result := PCefZipReader(FData).open_file(FData, @p) <> 0;
end;

function TCefZipReaderRef.ReadFile(buffer: Pointer;
  bufferSize: NativeUInt): Integer;
begin
    Result := PCefZipReader(FData).read_file(FData, buffer, buffersize);
end;

function TCefZipReaderRef.Tell: Int64;
begin
  Result := PCefZipReader(FData).tell(FData);
end;

class function TCefZipReaderRef.UnWrap(data: Pointer): ICefZipReader;
begin
  if data <> nil then
    Result := Create(data) as ICefZipReader else
    Result := nil;
end;

{ TCefFastTask }

constructor TCefFastTask.Create(const method: TCefFastTaskProc);
begin
  inherited Create;
  FMethod := method;
end;

procedure TCefFastTask.Execute;
begin
  FMethod();
end;

class procedure TCefFastTask.New(threadId: TCefThreadId; const method: TCefFastTaskProc);
begin
  CefPostTask(threadId, Create(method));
end;

class procedure TCefFastTask.NewDelayed(threadId: TCefThreadId;
  Delay: Int64; const method: TCefFastTaskProc);
begin
  CefPostDelayedTask(threadId, Create(method), Delay);
end;

{ TCefv8ContextRef }

class function TCefv8ContextRef.Current: ICefv8Context;
begin
  Result := UnWrap(cef_v8context_get_current_context)
end;

function TCefv8ContextRef.Enter: Boolean;
begin
  Result := PCefv8Context(FData)^.enter(PCefv8Context(FData)) <> 0;
end;

class function TCefv8ContextRef.Entered: ICefv8Context;
begin
  Result := UnWrap(cef_v8context_get_entered_context)
end;

function TCefv8ContextRef.Exit: Boolean;
begin
  Result := PCefv8Context(FData)^.exit(PCefv8Context(FData)) <> 0;
end;

function TCefv8ContextRef.GetBrowser: ICefBrowser;
begin
  Result := TCefBrowserRef.UnWrap(PCefv8Context(FData)^.get_browser(PCefv8Context(FData)));
end;

function TCefv8ContextRef.GetFrame: ICefFrame;
begin
  Result := TCefFrameRef.UnWrap(PCefv8Context(FData)^.get_frame(PCefv8Context(FData)))
end;

function TCefv8ContextRef.GetGlobal: ICefv8Value;
begin
  Result := TCefv8ValueRef.UnWrap(PCefv8Context(FData)^.get_global(PCefv8Context(FData)));
end;

function TCefv8ContextRef.GetTaskRunner: ICefTaskRunner;
begin
  Result := TCefTaskRunnerRef.UnWrap(PCefv8Context(FData)^.get_task_runner(FData));
end;

function TCefv8ContextRef.IsSame(const that: ICefv8Context): Boolean;
begin
  Result := PCefv8Context(FData)^.is_same(PCefv8Context(FData), CefGetData(that)) <> 0;
end;

function TCefv8ContextRef.IsValid: Boolean;
begin
  Result := PCefv8Context(FData)^.is_valid(FData) <> 0;
end;

function TCefv8ContextRef.Eval(const code: ustring; var retval: ICefv8Value;
 var exception: ICefV8Exception): Boolean;
var
  c: TCefString;
  r: PCefv8Value;
  e: PCefV8Exception;
begin
  c := CefString(code);
  r := nil; e := nil;
  Result := PCefv8Context(FData)^.eval(PCefv8Context(FData), @c, r, e) <> 0;
  retval := TCefv8ValueRef.UnWrap(r);
  exception := TCefV8ExceptionRef.UnWrap(e);
end;

class function TCefv8ContextRef.UnWrap(data: Pointer): ICefv8Context;
begin
  if data <> nil then
    Result := Create(data) as ICefv8Context else
    Result := nil;
end;

{ TCefDomVisitorOwn }

constructor TCefDomVisitorOwn.Create;
begin
  inherited CreateData(SizeOf(TCefDomVisitor));
  with PCefDomVisitor(FData)^ do
    visit := cef_dom_visitor_visite;
end;

procedure TCefDomVisitorOwn.visit(const document: ICefDomDocument);
begin

end;

{ TCefFastDomVisitor }

constructor TCefFastDomVisitor.Create(const proc: TCefDomVisitorProc);
begin
  inherited Create;
  FProc := proc;
end;

procedure TCefFastDomVisitor.visit(const document: ICefDomDocument);
begin
  FProc(document);
end;

{ TCefDomDocumentRef }

function TCefDomDocumentRef.GetBaseUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefDomDocument(FData)^.get_base_url(PCefDomDocument(FData)))
end;

function TCefDomDocumentRef.GetBody: ICefDomNode;
begin
  Result :=  TCefDomNodeRef.UnWrap(PCefDomDocument(FData)^.get_body(PCefDomDocument(FData)));
end;

function TCefDomDocumentRef.GetCompleteUrl(const partialURL: ustring): ustring;
var
  p: TCefString;
begin
  p := CefString(partialURL);
  Result := CefStringFreeAndGet(PCefDomDocument(FData)^.get_complete_url(PCefDomDocument(FData), @p));
end;

function TCefDomDocumentRef.GetDocument: ICefDomNode;
begin
  Result := TCefDomNodeRef.UnWrap(PCefDomDocument(FData)^.get_document(PCefDomDocument(FData)));
end;

function TCefDomDocumentRef.GetElementById(const id: ustring): ICefDomNode;
var
  i: TCefString;
begin
  i := CefString(id);
  Result := TCefDomNodeRef.UnWrap(PCefDomDocument(FData)^.get_element_by_id(PCefDomDocument(FData), @i));
end;

function TCefDomDocumentRef.GetFocusedNode: ICefDomNode;
begin
  Result := TCefDomNodeRef.UnWrap(PCefDomDocument(FData)^.get_focused_node(PCefDomDocument(FData)));
end;

function TCefDomDocumentRef.GetHead: ICefDomNode;
begin
  Result := TCefDomNodeRef.UnWrap(PCefDomDocument(FData)^.get_head(PCefDomDocument(FData)));
end;

function TCefDomDocumentRef.GetSelectionAsMarkup: ustring;
begin
  Result := CefStringFreeAndGet(PCefDomDocument(FData)^.get_selection_as_markup(PCefDomDocument(FData)));
end;

function TCefDomDocumentRef.GetSelectionAsText: ustring;
begin
  Result := CefStringFreeAndGet(PCefDomDocument(FData)^.get_selection_as_text(PCefDomDocument(FData)));
end;

function TCefDomDocumentRef.GetSelectionEndOffset: Integer;
begin
  Result := PCefDomDocument(FData)^.get_selection_end_offset(PCefDomDocument(FData));
end;

function TCefDomDocumentRef.GetSelectionStartOffset: Integer;
begin
  Result := PCefDomDocument(FData)^.get_selection_start_offset(PCefDomDocument(FData));
end;

function TCefDomDocumentRef.GetTitle: ustring;
begin
  Result := CefStringFreeAndGet(PCefDomDocument(FData)^.get_title(PCefDomDocument(FData)));
end;

function TCefDomDocumentRef.GetType: TCefDomDocumentType;
begin
  Result := PCefDomDocument(FData)^.get_type(PCefDomDocument(FData));
end;

function TCefDomDocumentRef.HasSelection: Boolean;
begin
  Result := PCefDomDocument(FData)^.has_selection(PCefDomDocument(FData)) <> 0;
end;

class function TCefDomDocumentRef.UnWrap(data: Pointer): ICefDomDocument;
begin
  if data <> nil then
    Result := Create(data) as ICefDomDocument else
    Result := nil;
end;

{ TCefDomNodeRef }

function TCefDomNodeRef.GetAsMarkup: ustring;
begin
  Result := CefStringFreeAndGet(PCefDomNode(FData)^.get_as_markup(PCefDomNode(FData)));
end;

function TCefDomNodeRef.GetDocument: ICefDomDocument;
begin
  Result := TCefDomDocumentRef.UnWrap(PCefDomNode(FData)^.get_document(PCefDomNode(FData)));
end;

function TCefDomNodeRef.GetElementAttribute(const attrName: ustring): ustring;
var
  p: TCefString;
begin
  p := CefString(attrName);
  Result := CefStringFreeAndGet(PCefDomNode(FData)^.get_element_attribute(PCefDomNode(FData), @p));
end;

procedure TCefDomNodeRef.GetElementAttributes(const attrMap: ICefStringMap);
begin
  PCefDomNode(FData)^.get_element_attributes(PCefDomNode(FData), attrMap.Handle);
end;

function TCefDomNodeRef.GetElementInnerText: ustring;
begin
  Result := CefStringFreeAndGet(PCefDomNode(FData)^.get_element_inner_text(PCefDomNode(FData)));
end;

function TCefDomNodeRef.GetElementTagName: ustring;
begin
  Result := CefStringFreeAndGet(PCefDomNode(FData)^.get_element_tag_name(PCefDomNode(FData)));
end;

function TCefDomNodeRef.GetFirstChild: ICefDomNode;
begin
  Result := TCefDomNodeRef.UnWrap(PCefDomNode(FData)^.get_first_child(PCefDomNode(FData)));
end;

function TCefDomNodeRef.GetFormControlElementType: ustring;
begin
  Result := CefStringFreeAndGet(PCefDomNode(FData)^.get_form_control_element_type(PCefDomNode(FData)));
end;

function TCefDomNodeRef.GetLastChild: ICefDomNode;
begin
  Result := TCefDomNodeRef.UnWrap(PCefDomNode(FData)^.get_last_child(PCefDomNode(FData)));
end;

function TCefDomNodeRef.GetName: ustring;
begin
  Result := CefStringFreeAndGet(PCefDomNode(FData)^.get_name(PCefDomNode(FData)));
end;

function TCefDomNodeRef.GetNextSibling: ICefDomNode;
begin
  Result := TCefDomNodeRef.UnWrap(PCefDomNode(FData)^.get_next_sibling(PCefDomNode(FData)));
end;

function TCefDomNodeRef.GetParent: ICefDomNode;
begin
  Result := TCefDomNodeRef.UnWrap(PCefDomNode(FData)^.get_parent(PCefDomNode(FData)));
end;

function TCefDomNodeRef.GetPreviousSibling: ICefDomNode;
begin
  Result := TCefDomNodeRef.UnWrap(PCefDomNode(FData)^.get_previous_sibling(PCefDomNode(FData)));
end;

function TCefDomNodeRef.GetType: TCefDomNodeType;
begin
  Result := PCefDomNode(FData)^.get_type(PCefDomNode(FData));
end;

function TCefDomNodeRef.GetValue: ustring;
begin
  Result := CefStringFreeAndGet(PCefDomNode(FData)^.get_value(PCefDomNode(FData)));
end;

function TCefDomNodeRef.HasChildren: Boolean;
begin
  Result := PCefDomNode(FData)^.has_children(PCefDomNode(FData)) <> 0;
end;

function TCefDomNodeRef.HasElementAttribute(const attrName: ustring): Boolean;
var
  p: TCefString;
begin
  p := CefString(attrName);
  Result := PCefDomNode(FData)^.has_element_attribute(PCefDomNode(FData), @p) <> 0;
end;

function TCefDomNodeRef.HasElementAttributes: Boolean;
begin
  Result := PCefDomNode(FData)^.has_element_attributes(PCefDomNode(FData)) <> 0;
end;

function TCefDomNodeRef.IsEditable: Boolean;
begin
  Result := PCefDomNode(FData)^.is_editable(PCefDomNode(FData)) <> 0;
end;

function TCefDomNodeRef.IsElement: Boolean;
begin
  Result := PCefDomNode(FData)^.is_element(PCefDomNode(FData)) <> 0;
end;

function TCefDomNodeRef.IsFormControlElement: Boolean;
begin
  Result := PCefDomNode(FData)^.is_form_control_element(PCefDomNode(FData)) <> 0;
end;

function TCefDomNodeRef.IsSame(const that: ICefDomNode): Boolean;
begin
  Result := PCefDomNode(FData)^.is_same(PCefDomNode(FData), CefGetData(that)) <> 0;
end;

function TCefDomNodeRef.IsText: Boolean;
begin
  Result := PCefDomNode(FData)^.is_text(PCefDomNode(FData)) <> 0;
end;

function TCefDomNodeRef.SetElementAttribute(const attrName,
  value: ustring): Boolean;
var
  p1, p2: TCefString;
begin
  p1 := CefString(attrName);
  p2 := CefString(value);
  Result := PCefDomNode(FData)^.set_element_attribute(PCefDomNode(FData), @p1, @p2) <> 0;
end;

function TCefDomNodeRef.SetValue(const value: ustring): Boolean;
var
  p: TCefString;
begin
  p := CefString(value);
  Result := PCefDomNode(FData)^.set_value(PCefDomNode(FData), @p) <> 0;
end;

class function TCefDomNodeRef.UnWrap(data: Pointer): ICefDomNode;
begin
  if data <> nil then
    Result := Create(data) as ICefDomNode else
    Result := nil;
end;

{ TCefResponseRef }

class function TCefResponseRef.New: ICefResponse;
begin
  Result := UnWrap(cef_response_create);
end;

function TCefResponseRef.GetHeader(const name: ustring): ustring;
var
  n: TCefString;
begin
  n := CefString(name);
  Result := CefStringFreeAndGet(PCefResponse(FData)^.get_header(PCefResponse(FData), @n));
end;

procedure TCefResponseRef.GetHeaderMap(const headerMap: ICefStringMultimap);
begin
  PCefResponse(FData)^.get_header_map(PCefResponse(FData), headermap.Handle);
end;

function TCefResponseRef.GetMimeType: ustring;
begin
  Result := CefStringFreeAndGet(PCefResponse(FData)^.get_mime_type(PCefResponse(FData)));
end;

function TCefResponseRef.GetStatus: Integer;
begin
  Result := PCefResponse(FData)^.get_status(PCefResponse(FData));
end;

function TCefResponseRef.GetStatusText: ustring;
begin
  Result := CefStringFreeAndGet(PCefResponse(FData)^.get_status_text(PCefResponse(FData)));
end;

function TCefResponseRef.IsReadOnly: Boolean;
begin
  Result := PCefResponse(FData)^.is_read_only(PCefResponse(FData)) <> 0;
end;

procedure TCefResponseRef.SetHeaderMap(const headerMap: ICefStringMultimap);
begin
  PCefResponse(FData)^.set_header_map(PCefResponse(FData), headerMap.Handle);
end;

procedure TCefResponseRef.SetMimeType(const mimetype: ustring);
var
  txt: TCefString;
begin
  txt := CefString(mimetype);
  PCefResponse(FData)^.set_mime_type(PCefResponse(FData), @txt);
end;

procedure TCefResponseRef.SetStatus(status: Integer);
begin
  PCefResponse(FData)^.set_status(PCefResponse(FData), status);
end;

procedure TCefResponseRef.SetStatusText(const StatusText: ustring);
var
  txt: TCefString;
begin
  txt := CefString(StatusText);
  PCefResponse(FData)^.set_status_text(PCefResponse(FData), @txt);
end;

class function TCefResponseRef.UnWrap(data: Pointer): ICefResponse;
begin
  if data <> nil then
    Result := Create(data) as ICefResponse else
    Result := nil;
end;

{ TCefRTTIExtension }

{$IFDEF DELPHI14_UP}

constructor TCefRTTIExtension.Create(const value: TValue
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
; SyncMainThread: Boolean
{$ENDIF}
);
begin
  inherited Create;
  FCtx := TRttiContext.Create;
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
  FSyncMainThread := SyncMainThread;
{$ENDIF}
  FValue := value;
end;

destructor TCefRTTIExtension.Destroy;
begin
  FCtx.Free;
  inherited;
end;

function TCefRTTIExtension.GetValue(pi: PTypeInfo; const v: ICefv8Value; var ret: TValue): Boolean;
  function ProcessInt: Boolean;
  var
    sv: record
      case byte of
      0:  (ub: Byte);
      1:  (sb: ShortInt);
      2:  (uw: Word);
      3:  (sw: SmallInt);
      4:  (si: Integer);
      5:  (ui: Cardinal);
    end;
    pd: PTypeData;
  begin
    pd := GetTypeData(pi);
    if (v.IsInt or v.IsBool) and (v.GetIntValue >= pd.MinValue) and (v.GetIntValue <= pd.MaxValue) then
    begin
      case pd.OrdType of
        otSByte: sv.sb := v.GetIntValue;
        otUByte: sv.ub := v.GetIntValue;
        otSWord: sv.sw := v.GetIntValue;
        otUWord: sv.uw := v.GetIntValue;
        otSLong: sv.si := v.GetIntValue;
        otULong: sv.ui := v.GetIntValue;
      end;
      TValue.Make(@sv, pi, ret);
    end else
      Exit(False);
    Result := True;
  end;

  function ProcessInt64: Boolean;
  var
    i: Int64;
  begin
    i := StrToInt64(v.GetStringValue); // hack
    TValue.Make(@i, pi, ret);
    Result := True;
  end;

  function ProcessUString: Boolean;
  var
    vus: string;
  begin
    if v.IsString then
    begin
      vus := v.GetStringValue;
      TValue.Make(@vus, pi, ret);
    end else
      Exit(False);
    Result := True;
  end;

  function ProcessLString: Boolean;
  var
    vas: AnsiString;
  begin
    if v.IsString then
    begin
      vas := AnsiString(v.GetStringValue);
      TValue.Make(@vas, pi, ret);
    end else
      Exit(False);
    Result := True;
  end;

  function ProcessWString: Boolean;
  var
    vws: WideString;
  begin
    if v.IsString then
    begin
      vws := v.GetStringValue;
      TValue.Make(@vws, pi, ret);
    end else
      Exit(False);
    Result := True;
  end;

  function ProcessFloat: Boolean;
  var
    sv: record
      case byte of
      0: (fs: Single);
      1: (fd: Double);
      2: (fe: Extended);
      3: (fc: Comp);
      4: (fcu: Currency);
    end;
  begin
    if v.IsDouble or v.IsInt then
    begin
      case GetTypeData(pi).FloatType of
        ftSingle: sv.fs := v.GetDoubleValue;
        ftDouble: sv.fd := v.GetDoubleValue;
        ftExtended: sv.fe := v.GetDoubleValue;
        ftComp: sv.fc := v.GetDoubleValue;
        ftCurr: sv.fcu := v.GetDoubleValue;
      end;
      TValue.Make(@sv, pi, ret);
    end else
    if v.IsDate then
    begin
      sv.fd := v.GetDateValue;
      TValue.Make(@sv, pi, ret);
    end else
      Exit(False);
    Result := True;
  end;

  function ProcessSet: Boolean;
  var
    sv: record
      case byte of
      0:  (ub: Byte);
      1:  (sb: ShortInt);
      2:  (uw: Word);
      3:  (sw: SmallInt);
      4:  (si: Integer);
      5:  (ui: Cardinal);
    end;
  begin
    if v.IsInt then
    begin
      case GetTypeData(pi).OrdType of
        otSByte: sv.sb := v.GetIntValue;
        otUByte: sv.ub := v.GetIntValue;
        otSWord: sv.sw := v.GetIntValue;
        otUWord: sv.uw := v.GetIntValue;
        otSLong: sv.si := v.GetIntValue;
        otULong: sv.ui := v.GetIntValue;
      end;
      TValue.Make(@sv, pi, ret);
    end else
      Exit(False);
    Result := True;
  end;

  function ProcessVariant: Boolean;
  var
    vr: Variant;
    i: Integer;
    vl: TValue;
  begin
    VarClear(vr);
    if v.IsString then vr := v.GetStringValue else
    if v.IsBool then vr := v.GetBoolValue else
    if v.IsInt then vr := v.GetIntValue else
    if v.IsDouble then vr := v.GetDoubleValue else
    if v.IsUndefined then TVarData(vr).VType := varEmpty else
    if v.IsNull then TVarData(vr).VType := varNull else
    if v.IsArray then
      begin
        vr := VarArrayCreate([0, v.GetArrayLength], varVariant);
        for i := 0 to v.GetArrayLength - 1 do
        begin
          if not GetValue(pi, v.GetValueByIndex(i), vl) then Exit(False);
          VarArrayPut(vr, vl.AsVariant, i);
        end;
      end else
      Exit(False);
    TValue.Make(@vr, pi, ret);
    Result := True;
  end;

  function ProcessObject: Boolean;
  var
    ud: ICefv8Value;
    i: Pointer;
    td: PTypeData;
    rt: TRttiType;
  begin
    if v.IsObject then
    begin
      ud := v.GetUserData;
      if (ud = nil) then Exit(False);
{$IFDEF CPUX64}
      rt := StrToPtr(ud.GetValueByIndex(0).GetStringValue);
{$ELSE}
      rt := TRttiType(ud.GetValueByIndex(0).GetIntValue);
{$ENDIF}
      td := GetTypeData(rt.Handle);

      if (rt.TypeKind = tkClass) and td.ClassType.InheritsFrom(GetTypeData(pi).ClassType) then
      begin
{$IFDEF CPUX64}
        i := StrToPtr(ud.GetValueByIndex(1).GetStringValue);
{$ELSE}
        i := Pointer(ud.GetValueByIndex(1).GetIntValue);
{$ENDIF}

        TValue.Make(@i, pi, ret);
      end else
        Exit(False);
    end else
      Exit(False);
    Result := True;
  end;

  function ProcessClass: Boolean;
  var
    ud: ICefv8Value;
    i: Pointer;
    rt: TRttiType;
  begin
    if v.IsObject then
    begin
      ud := v.GetUserData;
      if (ud = nil) then Exit(False);
{$IFDEF CPUX64}
      rt := StrToPtr(ud.GetValueByIndex(0).GetStringValue);
{$ELSE}
      rt := TRttiType(ud.GetValueByIndex(0).GetIntValue);
{$ENDIF}

      if (rt.TypeKind = tkClassRef) then
      begin
{$IFDEF CPUX64}
        i := StrToPtr(ud.GetValueByIndex(1).GetStringValue);
{$ELSE}
        i := Pointer(ud.GetValueByIndex(1).GetIntValue);
{$ENDIF}
        TValue.Make(@i, pi, ret);
      end else
        Exit(False);
    end else
      Exit(False);
    Result := True;
  end;

  function ProcessRecord: Boolean;
  var
    r: TRttiField;
    f: TValue;
    rec: Pointer;
  begin
    if v.IsObject then
    begin
      TValue.Make(nil, pi, ret);
{$IFDEF DELPHI15_UP}
      rec := TValueData(ret).FValueData.GetReferenceToRawData;
{$ELSE}
      rec := IValueData(TValueData(ret).FHeapData).GetReferenceToRawData;
{$ENDIF}
      for r in FCtx.GetType(pi).GetFields do
      begin
        if not GetValue(r.FieldType.Handle, v.GetValueByKey(r.Name), f) then
          Exit(False);
        r.SetValue(rec, f);
      end;
      Result := True;
    end else
      Result := False;
  end;

  function ProcessInterface: Boolean;
  begin
    if pi = TypeInfo(ICefV8Value) then
    begin
      TValue.Make(@v, pi, ret);
      Result := True;
    end else
      Result := False; // todo
  end;
begin
  case pi.Kind of
    tkInteger, tkEnumeration: Result := ProcessInt;
    tkInt64: Result := ProcessInt64;
    tkUString: Result := ProcessUString;
    tkLString: Result := ProcessLString;
    tkWString: Result := ProcessWString;
    tkFloat: Result := ProcessFloat;
    tkSet: Result := ProcessSet;
    tkVariant: Result := ProcessVariant;
    tkClass: Result := ProcessObject;
    tkClassRef: Result := ProcessClass;
    tkRecord: Result := ProcessRecord;
    tkInterface: Result := ProcessInterface;
  else
    Result := False;
  end;
end;

function TCefRTTIExtension.SetValue(const v: TValue; var ret: ICefv8Value): Boolean;

  function ProcessRecord: Boolean;
  var
    rf: TRttiField;
    vl: TValue;
    ud, v8: ICefv8Value;
    rec: Pointer;
    rt: TRttiType;
  begin
    ud := TCefv8ValueRef.NewArray(1);
    rt := FCtx.GetType(v.TypeInfo);
{$IFDEF CPUX64}
    ud.SetValueByIndex(0, TCefv8ValueRef.NewString(PtrToStr(rt)));
{$ELSE}
    ud.SetValueByIndex(0, TCefv8ValueRef.NewInt(Integer(rt)));
{$ENDIF}
    ret := TCefv8ValueRef.NewObject(nil);
    ret.SetUserData(ud);

{$IFDEF DELPHI15_UP}
    rec := TValueData(v).FValueData.GetReferenceToRawData;
{$ELSE}
    rec := IValueData(TValueData(v).FHeapData).GetReferenceToRawData;
{$ENDIF}
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
    if FSyncMainThread then
    begin
      v8 := ret;
      TThread.Synchronize(nil, procedure
      var
        rf: TRttiField;
        o: ICefv8Value;
      begin
        for rf in rt.GetFields do
        begin
          vl := rf.GetValue(rec);
          SetValue(vl, o);
          v8.SetValueByKey(rf.Name, o, []);
        end;
      end)
    end else
{$ENDIF}
      for rf in FCtx.GetType(v.TypeInfo).GetFields do
      begin
        vl := rf.GetValue(rec);
        if not SetValue(vl, v8) then
          Exit(False);
        ret.SetValueByKey(rf.Name, v8,  []);
      end;
    Result := True;
  end;

  function ProcessObject: Boolean;
  var
    m: TRttiMethod;
    p: TRttiProperty;
    fl: TRttiField;
    f: ICefv8Value;
    _r, _g, _s, ud: ICefv8Value;
    _a: TCefv8ValueArray;
    rt: TRttiType;
  begin
    rt := FCtx.GetType(v.TypeInfo);

    ud := TCefv8ValueRef.NewArray(2);
{$IFDEF CPUX64}
    ud.SetValueByIndex(0, TCefv8ValueRef.NewString(PtrToStr(rt)));
    ud.SetValueByIndex(1, TCefv8ValueRef.NewString(PtrToStr(v.AsObject)));
{$ELSE}
    ud.SetValueByIndex(0, TCefv8ValueRef.NewInt(Integer(rt)));
    ud.SetValueByIndex(1, TCefv8ValueRef.NewInt(Integer(v.AsObject)));
{$ENDIF}
    ret := TCefv8ValueRef.NewObject(nil); // todo
    ret.SetUserData(ud);

    for m in rt.GetMethods do
      if m.Visibility > mvProtected then
      begin
        f := TCefv8ValueRef.NewFunction(m.Name, Self);
        ret.SetValueByKey(m.Name, f, []);
      end;

    for p in rt.GetProperties do
      if (p.Visibility > mvProtected) then
      begin
        if _g = nil then _g := ret.GetValueByKey('__defineGetter__');
        if _s = nil then _s := ret.GetValueByKey('__defineSetter__');
        SetLength(_a, 2);
        _a[0] := TCefv8ValueRef.NewString(p.Name);
        if p.IsReadable then
        begin
          _a[1] := TCefv8ValueRef.NewFunction('$pg' + p.Name, Self);
          _r := _g.ExecuteFunction(ret, _a);
        end;
        if p.IsWritable then
        begin
          _a[1] := TCefv8ValueRef.NewFunction('$ps' + p.Name, Self);
          _r := _s.ExecuteFunction(ret, _a);
        end;
      end;

    for fl in rt.GetFields do
      if (fl.Visibility > mvProtected) then
      begin
        if _g = nil then _g := ret.GetValueByKey('__defineGetter__');
        if _s = nil then _s := ret.GetValueByKey('__defineSetter__');

        SetLength(_a, 2);
        _a[0] := TCefv8ValueRef.NewString(fl.Name);
        _a[1] := TCefv8ValueRef.NewFunction('$vg' + fl.Name, Self);
        _r := _g.ExecuteFunction(ret, _a);
        _a[1] := TCefv8ValueRef.NewFunction('$vs' + fl.Name, Self);
        _r := _s.ExecuteFunction(ret, _a);
      end;

    Result := True;
  end;

  function ProcessClass: Boolean;
  var
    m: TRttiMethod;
    f, ud: ICefv8Value;
    c: TClass;
    rt: TRttiType;
  begin
    c := v.AsClass;
    rt := FCtx.GetType(c);

    ud := TCefv8ValueRef.NewArray(2);
{$IFDEF CPUX64}
    ud.SetValueByIndex(0, TCefv8ValueRef.NewString(PtrToStr(rt)));
    ud.SetValueByIndex(1, TCefv8ValueRef.NewString(PtrToStr(c)));
{$ELSE}
    ud.SetValueByIndex(0, TCefv8ValueRef.NewInt(Integer(rt)));
    ud.SetValueByIndex(1, TCefv8ValueRef.NewInt(Integer(c)));
{$ENDIF}
    ret := TCefv8ValueRef.NewObject(nil); // todo
    ret.SetUserData(ud);

    if c <> nil then
    begin
      for m in rt.GetMethods do
        if (m.Visibility > mvProtected) and (m.MethodKind in [mkClassProcedure, mkClassFunction]) then
        begin
          f := TCefv8ValueRef.NewFunction(m.Name, Self);
          ret.SetValueByKey(m.Name, f, []);
        end;
    end;

    Result := True;
  end;

  function ProcessVariant: Boolean;
  var
    vr: Variant;
  begin
    vr := v.AsVariant;
    case TVarData(vr).VType of
      varSmallint, varInteger, varShortInt:
        ret := TCefv8ValueRef.NewInt(vr);
      varByte, varWord, varLongWord:
        ret := TCefv8ValueRef.NewUInt(vr);
      varUString, varOleStr, varString:
        ret := TCefv8ValueRef.NewString(vr);
      varSingle, varDouble, varCurrency, varUInt64, varInt64:
        ret := TCefv8ValueRef.NewDouble(vr);
      varBoolean:
        ret := TCefv8ValueRef.NewBool(vr);
      varNull:
        ret := TCefv8ValueRef.NewNull;
      varEmpty:
        ret := TCefv8ValueRef.NewUndefined;
    else
      ret := nil;
      Exit(False)
    end;
    Result := True;
  end;

  function ProcessInterface: Boolean;
  var
    m: TRttiMethod;
    f: ICefv8Value;
    ud: ICefv8Value;
    rt: TRttiType;
  begin

    if TypeInfo(ICefV8Value) = v.TypeInfo then
    begin
      ret := ICefV8Value(v.AsInterface);
      Result := True;
    end else
    begin
      rt := FCtx.GetType(v.TypeInfo);


      ud := TCefv8ValueRef.NewArray(2);
  {$IFDEF CPUX64}
      ud.SetValueByIndex(0, TCefv8ValueRef.NewString(PtrToStr(rt)));
      ud.SetValueByIndex(1, TCefv8ValueRef.NewString(PtrToStr(Pointer(v.AsInterface))));
  {$ELSE}
      ud.SetValueByIndex(0, TCefv8ValueRef.NewInt(Integer(rt)));
      ud.SetValueByIndex(1, TCefv8ValueRef.NewInt(Integer(v.AsInterface)));
  {$ENDIF}
      ret := TCefv8ValueRef.NewObject(nil);
      ret.SetUserData(ud);

      for m in rt.GetMethods do
        if m.Visibility > mvProtected then
        begin
          f := TCefv8ValueRef.NewFunction(m.Name, Self);
          ret.SetValueByKey(m.Name, f, []);
        end;

      Result := True;
    end;
  end;

  function ProcessFloat: Boolean;
  begin
    if v.TypeInfo = TypeInfo(TDateTime) then
      ret := TCefv8ValueRef.NewDate(TValueData(v).FAsDouble) else
      ret := TCefv8ValueRef.NewDouble(v.AsExtended);
    Result := True;
  end;

begin
  case v.TypeInfo.Kind of
    tkUString, tkLString, tkWString, tkChar, tkWChar:
      ret := TCefv8ValueRef.NewString(v.AsString);
    tkInteger: ret := TCefv8ValueRef.NewInt(v.AsInteger);
    tkEnumeration:
      if v.TypeInfo = TypeInfo(Boolean) then
        ret := TCefv8ValueRef.NewBool(v.AsBoolean) else
        ret := TCefv8ValueRef.NewInt(TValueData(v).FAsSLong);
    tkFloat: if not ProcessFloat then Exit(False);
    tkInt64: ret := TCefv8ValueRef.NewDouble(v.AsInt64);
    tkClass: if not ProcessObject then Exit(False);
    tkClassRef: if not ProcessClass then Exit(False);
    tkRecord: if not ProcessRecord then Exit(False);
    tkVariant: if not ProcessVariant then Exit(False);
    tkInterface: if not ProcessInterface then Exit(False);
  else
    Exit(False)
  end;
  Result := True;
end;

class procedure TCefRTTIExtension.Register(const name: string;
  const value: TValue{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}; SyncMainThread: Boolean{$ENDIF});
begin
  CefRegisterExtension(name,
    format('__defineSetter__(''%s'', function(v){native function $s();$s(v)});__defineGetter__(''%0:s'', function(){native function $g();return $g()});', [name]),
    TCefRTTIExtension.Create(value
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
    , SyncMainThread
{$ENDIF}
    ) as ICefv8Handler);
end;

{$IFDEF CPUX64}
class function TCefRTTIExtension.StrToPtr(const str: ustring): Pointer;
begin
  HexToBin(PWideChar(str), @Result, SizeOf(Result));
end;

class function TCefRTTIExtension.PtrToStr(p: Pointer): ustring;
begin
  SetLength(Result, SizeOf(p)*2);
  BinToHex(@p, PWideChar(Result), SizeOf(p));
end;
{$ENDIF}

function TCefRTTIExtension.Execute(const name: ustring; const obj: ICefv8Value;
  const arguments: TCefv8ValueArray; var retval: ICefv8Value;
  var exception: ustring): Boolean;
var
  p: PChar;
  ud: ICefv8Value;
  rt: TRttiType;
  val: TObject;
  cls: TClass;
  m: TRttiMethod;
  pr: TRttiProperty;
  vl: TRttiField;
  args: array of TValue;
  prm: TArray<TRttiParameter>;
  i: Integer;
  ret: TValue;
begin
  Result := True;
  p := PChar(name);
  m := nil;
  if obj <> nil then
  begin
    ud := obj.GetUserData;
    if ud <> nil then
    begin
{$IFDEF CPUX64}
      rt := StrToPtr(ud.GetValueByIndex(0).GetStringValue);
{$ELSE}
      rt := TRttiType(ud.GetValueByIndex(0).GetIntValue);
{$ENDIF}
      case rt.TypeKind of
        tkClass:
          begin
{$IFDEF CPUX64}
            val := StrToPtr(ud.GetValueByIndex(1).GetStringValue);
{$ELSE}
            val := TObject(ud.GetValueByIndex(1).GetIntValue);
{$ENDIF}
            cls := GetTypeData(rt.Handle).ClassType;

            if p^ = '$' then
            begin
              inc(p);
              case p^ of
                'p':
                  begin
                    inc(p);
                    case p^ of
                    'g':
                      begin
                        inc(p);
                        pr := rt.GetProperty(p);
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
                        if FSyncMainThread then
                        begin
                          TThread.Synchronize(nil, procedure begin
                            ret := pr.GetValue(val);
                          end);
                          Exit(SetValue(ret, retval));
                        end else
{$ENDIF}
                          Exit(SetValue(pr.GetValue(val), retval));
                      end;
                    's':
                      begin
                        inc(p);
                        pr := rt.GetProperty(p);
                        if GetValue(pr.PropertyType.Handle, arguments[0], ret) then
                        begin
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
                          if FSyncMainThread then
                            TThread.Synchronize(nil, procedure begin
                              pr.SetValue(val, ret) end) else
{$ENDIF}
                            pr.SetValue(val, ret);
                          Exit(True);
                        end else
                          Exit(False);
                      end;
                    end;
                  end;
                'v':
                  begin
                    inc(p);
                    case p^ of
                    'g':
                      begin
                        inc(p);
                        vl := rt.GetField(p);
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
                        if FSyncMainThread then
                        begin
                          TThread.Synchronize(nil, procedure begin
                            ret := vl.GetValue(val);
                          end);
                          Exit(SetValue(ret, retval));
                        end else
{$ENDIF}
                          Exit(SetValue(vl.GetValue(val), retval));
                      end;
                    's':
                      begin
                        inc(p);
                        vl := rt.GetField(p);
                        if GetValue(vl.FieldType.Handle, arguments[0], ret) then
                        begin
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
                          if FSyncMainThread then
                            TThread.Synchronize(nil, procedure begin
                              vl.SetValue(val, ret) end) else
{$ENDIF}
                            vl.SetValue(val, ret);
                          Exit(True);
                        end else
                          Exit(False);
                      end;
                    end;
                  end;
              end;
            end else
              m := rt.GetMethod(name);
          end;
        tkClassRef:
          begin
            val := nil;
{$IFDEF CPUX64}
            cls := StrToPtr(ud.GetValueByIndex(1).GetStringValue);
{$ELSE}
            cls := TClass(ud.GetValueByIndex(1).GetIntValue);
{$ENDIF}
            m := FCtx.GetType(cls).GetMethod(name);
          end;
      else
        m := nil;
        cls := nil;
        val := nil;
      end;

      prm := m.GetParameters;
      i := Length(prm);
      if i = Length(arguments) then
      begin
        SetLength(args, i);
        for i := 0 to i - 1 do
          if not GetValue(prm[i].ParamType.Handle, arguments[i], args[i]) then
            Exit(False);

        case m.MethodKind of
          mkClassProcedure, mkClassFunction:
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
            if FSyncMainThread then
              TThread.Synchronize(nil, procedure begin
                ret := m.Invoke(cls, args) end) else
{$ENDIF}
              ret := m.Invoke(cls, args);
          mkProcedure, mkFunction:
            if (val <> nil) then
            begin
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
              if FSyncMainThread then
                TThread.Synchronize(nil, procedure begin
                  ret := m.Invoke(val, args) end) else
{$ENDIF}
                ret := m.Invoke(val, args);
            end else
              Exit(False)
        else
          Exit(False);
        end;

        if m.MethodKind in [mkClassFunction, mkFunction] then
          if not SetValue(ret, retval) then
            Exit(False);
      end else
        Exit(False);
    end else
    if p^ = '$' then
    begin
      inc(p);
      case p^ of
        'g': SetValue(FValue, retval);
        's': GetValue(FValue.TypeInfo, arguments[0], FValue);
      else
        Exit(False);
      end;
    end else
      Exit(False);
  end else
    Exit(False);
end;
{$ENDIF}

{ TCefV8AccessorOwn }

constructor TCefV8AccessorOwn.Create;
begin
  inherited CreateData(SizeOf(TCefV8Accessor));
  PCefV8Accessor(FData)^.get  := cef_v8_accessor_get;
  PCefV8Accessor(FData)^.put := cef_v8_accessor_put;
end;

function TCefV8AccessorOwn.Get(const name: ustring; const obj: ICefv8Value;
  out value: ICefv8Value; const exception: ustring): Boolean;
begin
  Result := False;
end;

function TCefV8AccessorOwn.Put(const name: ustring; const obj,
  value: ICefv8Value; const exception: ustring): Boolean;
begin
  Result := False;
end;

{ TCefFastV8Accessor }

constructor TCefFastV8Accessor.Create(
  const getter: TCefV8AccessorGetterProc;
  const setter: TCefV8AccessorSetterProc);
begin
  FGetter := getter;
  FSetter := setter;
end;

function TCefFastV8Accessor.Get(const name: ustring; const obj: ICefv8Value;
  out value: ICefv8Value; const exception: ustring): Boolean;
begin
  if Assigned(FGetter)  then
    Result := FGetter(name, obj, value, exception) else
    Result := False;
end;

function TCefFastV8Accessor.Put(const name: ustring; const obj,
  value: ICefv8Value; const exception: ustring): Boolean;
begin
  if Assigned(FSetter)  then
    Result := FSetter(name, obj, value, exception) else
    Result := False;
end;

{ TCefCookieVisitorOwn }

constructor TCefCookieVisitorOwn.Create;
begin
  inherited CreateData(SizeOf(TCefCookieVisitor));
  PCefCookieVisitor(FData)^.visit := cef_cookie_visitor_visit;
end;

function TCefCookieVisitorOwn.visit(const name, value, domain, path: ustring;
  secure, httponly, hasExpires: Boolean; const creation, lastAccess, expires: TDateTime;
  count, total: Integer; out deleteCookie: Boolean): Boolean;
begin
  Result := True;
end;

{ TCefFastCookieVisitor }

constructor TCefFastCookieVisitor.Create(const visitor: TCefCookieVisitorProc);
begin
  inherited Create;
  FVisitor := visitor;
end;

function TCefFastCookieVisitor.visit(const name, value, domain, path: ustring;
  secure, httponly, hasExpires: Boolean; const creation, lastAccess,
  expires: TDateTime; count, total: Integer; out deleteCookie: Boolean): Boolean;
begin
  Result := FVisitor(name, value, domain, path, secure, httponly, hasExpires,
    creation, lastAccess, expires, count, total, deleteCookie);
end;

{ TCefClientOwn }

constructor TCefClientOwn.Create;
begin
  inherited CreateData(SizeOf(TCefClient));
  with PCefClient(FData)^ do
  begin
    get_context_menu_handler := cef_client_get_context_menu_handler;
    get_dialog_handler := cef_client_get_dialog_handler;
    get_display_handler := cef_client_get_display_handler;
    get_download_handler := cef_client_get_download_handler;
    get_drag_handler := cef_client_get_drag_handler;
    get_find_handler := cef_client_get_find_handler;
    get_focus_handler := cef_client_get_focus_handler;
    get_geolocation_handler := cef_client_get_geolocation_handler;
    get_jsdialog_handler := cef_client_get_jsdialog_handler;
    get_keyboard_handler := cef_client_get_keyboard_handler;
    get_life_span_handler := cef_client_get_life_span_handler;
    get_load_handler := cef_client_get_load_handler;
    get_render_handler := cef_client_get_get_render_handler;
    get_request_handler := cef_client_get_request_handler;
    on_process_message_received := cef_client_on_process_message_received;
  end;
end;

function TCefClientOwn.GetContextMenuHandler: ICefContextMenuHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetDialogHandler: ICefDialogHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetDisplayHandler: ICefDisplayHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetDownloadHandler: ICefDownloadHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetDragHandler: ICefDragHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetFindHandler: ICefFindHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetFocusHandler: ICefFocusHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetGeolocationHandler: ICefGeolocationHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetJsdialogHandler: ICefJsDialogHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetKeyboardHandler: ICefKeyboardHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetLifeSpanHandler: ICefLifeSpanHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetLoadHandler: ICefLoadHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetRenderHandler: ICefRenderHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetRequestHandler: ICefRequestHandler;
begin
  Result := nil;
end;

function TCefClientOwn.OnProcessMessageReceived(const browser: ICefBrowser;
  sourceProcess: TCefProcessId; const message: ICefProcessMessage): Boolean;
begin
  Result := False;
end;

{ TCefGeolocationHandlerOwn }

constructor TCefGeolocationHandlerOwn.Create;
begin

  inherited CreateData(SizeOf(TCefGeolocationHandler));
  with PCefGeolocationHandler(FData)^ do
  begin
    on_request_geolocation_permission := cef_geolocation_handler_on_request_geolocation_permission;
    on_cancel_geolocation_permission :=  cef_geolocation_handler_on_cancel_geolocation_permission;
  end;
end;


function TCefGeolocationHandlerOwn.OnRequestGeolocationPermission(
  const browser: ICefBrowser; const requestingUrl: ustring; requestId: Integer;
  const callback: ICefGeolocationCallback): Boolean;
begin
  Result := False;
end;

procedure TCefGeolocationHandlerOwn.OnCancelGeolocationPermission(
  const browser: ICefBrowser; const requestingUrl: ustring; requestId: Integer);
begin

end;

{ TCefLifeSpanHandlerOwn }


constructor TCefLifeSpanHandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefLifeSpanHandler));
  with PCefLifeSpanHandler(FData)^ do
  begin
    on_before_popup := cef_life_span_handler_on_before_popup;
    on_after_created := cef_life_span_handler_on_after_created;
    on_before_close := cef_life_span_handler_on_before_close;
    run_modal := cef_life_span_handler_run_modal;
    do_close := cef_life_span_handler_do_close;
  end;
end;

procedure TCefLifeSpanHandlerOwn.OnAfterCreated(const browser: ICefBrowser);
begin

end;

procedure TCefLifeSpanHandlerOwn.OnBeforeClose(const browser: ICefBrowser);
begin

end;

function TCefLifeSpanHandlerOwn.OnBeforePopup(const browser: ICefBrowser;
  const frame: ICefFrame; const targetUrl, targetFrameName: ustring;
  targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean;
  var popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo;
  var client: ICefClient; var settings: TCefBrowserSettings;
  var noJavascriptAccess: Boolean): Boolean;
begin
  Result := False;
end;

function TCefLifeSpanHandlerOwn.DoClose(const browser: ICefBrowser): Boolean;
begin
  Result := False;
end;

function TCefLifeSpanHandlerOwn.RunModal(const browser: ICefBrowser): Boolean;
begin
  Result := False;
end;


{ TCefLoadHandlerOwn }

constructor TCefLoadHandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefLoadHandler));
  with PCefLoadHandler(FData)^ do
  begin
    on_loading_state_change := cef_load_handler_on_loading_state_change;
    on_load_start := cef_load_handler_on_load_start;
    on_load_end := cef_load_handler_on_load_end;
    on_load_error := cef_load_handler_on_load_error;
  end;
end;

procedure TCefLoadHandlerOwn.OnLoadEnd(const browser: ICefBrowser;
  const frame: ICefFrame; httpStatusCode: Integer);
begin

end;

procedure TCefLoadHandlerOwn.OnLoadError(const browser: ICefBrowser;
  const frame: ICefFrame; errorCode: Integer; const errorText, failedUrl: ustring);
begin

end;

procedure TCefLoadHandlerOwn.OnLoadingStateChange(const browser: ICefBrowser;
  isLoading, canGoBack, canGoForward: Boolean);
begin

end;

procedure TCefLoadHandlerOwn.OnLoadStart(const browser: ICefBrowser;
  const frame: ICefFrame);
begin

end;

{ TCefRequestHandlerOwn }

constructor TCefRequestHandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefRequestHandler));
  with PCefRequestHandler(FData)^ do
  begin
    on_before_browse := cef_request_handler_on_before_browse;
    on_open_urlfrom_tab := cef_request_handler_on_open_urlfrom_tab;
    on_before_resource_load := cef_request_handler_on_before_resource_load;
    get_resource_handler := cef_request_handler_get_resource_handler;
    on_resource_redirect := cef_request_handler_on_resource_redirect;
    on_resource_response := cef_request_handler_on_resource_response;
    get_auth_credentials := cef_request_handler_get_auth_credentials;
    on_quota_request := cef_request_handler_on_quota_request;
    on_protocol_execution := cef_request_handler_on_protocol_execution;
    on_certificate_error := cef_request_handler_on_certificate_error;
    on_plugin_crashed := cef_request_handler_on_plugin_crashed;
    on_render_view_ready := cef_request_handler_on_render_view_ready;
    on_render_process_terminated := cef_request_handler_on_render_process_terminated;
  end;
end;

function TCefRequestHandlerOwn.GetAuthCredentials(const browser: ICefBrowser; const frame: ICefFrame;
  isProxy: Boolean; const host: ustring; port: Integer; const realm, scheme: ustring;
  const callback: ICefAuthCallback): Boolean;
begin
  Result := False;
end;

function TCefRequestHandlerOwn.GetCookieManager(const browser: ICefBrowser;
  const mainUrl: ustring): ICefCookieManager;
begin
  Result := nil;
end;

function TCefRequestHandlerOwn.OnBeforeBrowse(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest;
  isRedirect: Boolean): Boolean;
begin
  Result := False;
end;

function TCefRequestHandlerOwn.OnBeforeResourceLoad(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest;
  const callback: ICefRequestCallback): TCefReturnValue;
begin
  Result := RV_CONTINUE;
end;

function TCefRequestHandlerOwn.OnCertificateError(const browser: ICefBrowser;
  certError: TCefErrorcode; const requestUrl: ustring; const sslInfo: ICefSslInfo;
  const callback: ICefRequestCallback): Boolean;
begin
  Result := False;
end;

function TCefRequestHandlerOwn.OnOpenUrlFromTab(const browser: ICefBrowser;
  const frame: ICefFrame; const targetUrl: ustring;
  targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean): Boolean;
begin
  Result := False;
end;

function TCefRequestHandlerOwn.GetResourceHandler(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest): ICefResourceHandler;
begin
  Result := nil;
end;

procedure TCefRequestHandlerOwn.OnPluginCrashed(const browser: ICefBrowser;
  const pluginPath: ustring);
begin

end;

procedure TCefRequestHandlerOwn.OnProtocolExecution(const browser: ICefBrowser;
  const url: ustring; out allowOsExecution: Boolean);
begin

end;

function TCefRequestHandlerOwn.OnQuotaRequest(const browser: ICefBrowser;
  const originUrl: ustring; newSize: Int64;
  const callback: ICefRequestCallback): Boolean;
begin
  Result := False;
end;

procedure TCefRequestHandlerOwn.OnRenderProcessTerminated(
  const browser: ICefBrowser; status: TCefTerminationStatus);
begin

end;

procedure TCefRequestHandlerOwn.OnRenderViewReady(const browser: ICefBrowser);
begin

end;

procedure TCefRequestHandlerOwn.OnResourceRedirect(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest; var newUrl: ustring);
begin

end;

function TCefRequestHandlerOwn.OnResourceResponse(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest;
  const response: ICefResponse): Boolean;
begin
  Result := False;
end;

{ TCefDisplayHandlerOwn }

constructor TCefDisplayHandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefDisplayHandler));
  with PCefDisplayHandler(FData)^ do
  begin
    on_address_change := cef_display_handler_on_address_change;
    on_title_change := cef_display_handler_on_title_change;
    on_favicon_urlchange := cef_display_handler_on_favicon_urlchange;
    on_fullscreen_mode_change := cef_display_handler_on_fullscreen_mode_change;
    on_tooltip := cef_display_handler_on_tooltip;
    on_status_message := cef_display_handler_on_status_message;
    on_console_message := cef_display_handler_on_console_message;
  end;
end;

procedure TCefDisplayHandlerOwn.OnAddressChange(const browser: ICefBrowser;
  const frame: ICefFrame; const url: ustring);
begin

end;

function TCefDisplayHandlerOwn.OnConsoleMessage(const browser: ICefBrowser;
  const message, source: ustring; line: Integer): Boolean;
begin
  Result := False;
end;

procedure TCefDisplayHandlerOwn.OnFaviconUrlChange(const browser: ICefBrowser;
  iconUrls: TStrings);
begin

end;

procedure TCefDisplayHandlerOwn.OnFullScreenModeChange(
  const browser: ICefBrowser; fullscreen: Boolean);
begin

end;

procedure TCefDisplayHandlerOwn.OnStatusMessage(const browser: ICefBrowser;
  const value: ustring);
begin

end;

procedure TCefDisplayHandlerOwn.OnTitleChange(const browser: ICefBrowser;
  const title: ustring);
begin

end;

function TCefDisplayHandlerOwn.OnTooltip(const browser: ICefBrowser;
  var text: ustring): Boolean;
begin
  Result := False;
end;

{ TCefFocusHandlerOwn }

constructor TCefFocusHandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefFocusHandler));
  with PCefFocusHandler(FData)^ do
  begin
    on_take_focus := cef_focus_handler_on_take_focus;
    on_set_focus := cef_focus_handler_on_set_focus;
    on_got_focus := cef_focus_handler_on_got_focus;
  end;
end;

function TCefFocusHandlerOwn.OnSetFocus(const browser: ICefBrowser;
  source: TCefFocusSource): Boolean;
begin
  Result := False;
end;

procedure TCefFocusHandlerOwn.OnGotFocus(const browser: ICefBrowser);
begin

end;

procedure TCefFocusHandlerOwn.OnTakeFocus(const browser: ICefBrowser;
  next: Boolean);
begin

end;

{ TCefKeyboardHandlerOwn }

constructor TCefKeyboardHandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefKeyboardHandler));
  with PCefKeyboardHandler(FData)^ do
  begin
    on_pre_key_event := cef_keyboard_handler_on_pre_key_event;
    on_key_event := cef_keyboard_handler_on_key_event;
  end;
end;

function TCefKeyboardHandlerOwn.OnPreKeyEvent(const browser: ICefBrowser;
  const event: PCefKeyEvent; osEvent: TCefEventHandle;
  out isKeyboardShortcut: Boolean): Boolean;
begin
  Result := False;
end;

function TCefKeyboardHandlerOwn.OnKeyEvent(const browser: ICefBrowser;
  const event: PCefKeyEvent; osEvent: TCefEventHandle): Boolean;
begin

  Result := False;
end;

{ TCefJsDialogHandlerOwn }

constructor TCefJsDialogHandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefJsDialogHandler));
  with PCefJsDialogHandler(FData)^ do
  begin
    on_jsdialog := cef_jsdialog_handler_on_jsdialog;
    on_before_unload_dialog := cef_jsdialog_handler_on_before_unload_dialog;
    on_reset_dialog_state := cef_jsdialog_handler_on_reset_dialog_state;
    on_dialog_closed := cef_jsdialog_handler_on_dialog_closed;
  end;
end;

function TCefJsDialogHandlerOwn.OnJsdialog(const browser: ICefBrowser;
  const originUrl, acceptLang: ustring; dialogType: TCefJsDialogType;
  const messageText, defaultPromptText: ustring; callback: ICefJsDialogCallback;
  out suppressMessage: Boolean): Boolean;
begin
  Result := False;
end;

function TCefJsDialogHandlerOwn.OnBeforeUnloadDialog(const browser: ICefBrowser;
  const messageText: ustring; isReload: Boolean; const callback: ICefJsDialogCallback): Boolean;
begin

  Result := False;
end;

procedure TCefJsDialogHandlerOwn.OnDialogClosed(const browser: ICefBrowser);
begin

end;

procedure TCefJsDialogHandlerOwn.OnResetDialogState(const browser: ICefBrowser);
begin

end;

{ TCefContextMenuHandlerOwn }

constructor TCefContextMenuHandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefContextMenuHandler));
  with PCefContextMenuHandler(FData)^ do
  begin
    on_before_context_menu := cef_context_menu_handler_on_before_context_menu;
    run_context_menu := cef_context_menu_handler_run_context_menu;
    on_context_menu_command := cef_context_menu_handler_on_context_menu_command;
    on_context_menu_dismissed := cef_context_menu_handler_on_context_menu_dismissed;
  end;
end;

procedure TCefContextMenuHandlerOwn.OnBeforeContextMenu(
  const browser: ICefBrowser; const frame: ICefFrame;
  const params: ICefContextMenuParams; const model: ICefMenuModel);
begin

end;

function TCefContextMenuHandlerOwn.OnContextMenuCommand(
  const browser: ICefBrowser; const frame: ICefFrame;
  const params: ICefContextMenuParams; commandId: Integer;
  eventFlags: TCefEventFlags): Boolean;
begin
  Result := False;
end;

procedure TCefContextMenuHandlerOwn.OnContextMenuDismissed(
  const browser: ICefBrowser; const frame: ICefFrame);
begin

end;

function TCefContextMenuHandlerOwn.RunContextMenu(const browser: ICefBrowser;
  const frame: ICefFrame; const params: ICefContextMenuParams;
  const model: ICefMenuModel;
  const callback: ICefRunContextMenuCallback): Boolean;
begin
  Result := False;
end;

{ TCefV8ExceptionRef }

function TCefV8ExceptionRef.GetEndColumn: Integer;
begin
  Result := PCefV8Exception(FData)^.get_end_column(FData);
end;

function TCefV8ExceptionRef.GetEndPosition: Integer;
begin
  Result := PCefV8Exception(FData)^.get_end_position(FData);
end;

function TCefV8ExceptionRef.GetLineNumber: Integer;
begin
  Result := PCefV8Exception(FData)^.get_line_number(FData);
end;

function TCefV8ExceptionRef.GetMessage: ustring;
begin
  Result := CefStringFreeAndGet(PCefV8Exception(FData)^.get_message(FData));
end;

function TCefV8ExceptionRef.GetScriptResourceName: ustring;
begin
  Result := CefStringFreeAndGet(PCefV8Exception(FData)^.get_script_resource_name(FData));
end;

function TCefV8ExceptionRef.GetSourceLine: ustring;
begin
  Result := CefStringFreeAndGet(PCefV8Exception(FData)^.get_source_line(FData));
end;

function TCefV8ExceptionRef.GetStartColumn: Integer;
begin
  Result := PCefV8Exception(FData)^.get_start_column(FData);
end;

function TCefV8ExceptionRef.GetStartPosition: Integer;
begin
  Result := PCefV8Exception(FData)^.get_start_position(FData);
end;

class function TCefV8ExceptionRef.UnWrap(data: Pointer): ICefV8Exception;
begin
  if data <> nil then
    Result := Create(data) as ICefV8Exception else
    Result := nil;
end;

{ TCefResourceBundleHandlerOwn }

constructor TCefResourceBundleHandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefResourceBundleHandler));
  with PCefResourceBundleHandler(FData)^ do
  begin
    get_localized_string := cef_resource_bundle_handler_get_localized_string;
    get_data_resource := cef_resource_bundle_handler_get_data_resource;
    get_data_resource_for_scale := cef_resource_bundle_handler_get_data_resource_for_scale;
  end;
end;

{ TCefFastResourceBundle }

constructor TCefFastResourceBundle.Create(AGetDataResource: TGetDataResource;
  AGetLocalizedString: TGetLocalizedString; AGetDataResourceForScale: TGetDataResourceForScale);
begin
  inherited Create;
  FGetDataResource := AGetDataResource;
  FGetLocalizedString := AGetLocalizedString;
  FGetDataResourceForScale := AGetDataResourceForScale;
end;

function TCefFastResourceBundle.GetDataResource(resourceId: Integer;
  out data: Pointer; out dataSize: NativeUInt): Boolean;
begin
  if Assigned(FGetDataResource) then
    Result := FGetDataResource(resourceId, data, dataSize) else
    Result := False;
end;

function TCefFastResourceBundle.GetDataResourceForScale(resourceId: Integer;
  scaleFactor: TCefScaleFactor; out data: Pointer;
  dataSize: NativeUInt): Boolean;
begin
  if Assigned(FGetDataResourceForScale) then
    Result := FGetDataResourceForScale(resourceId, scaleFactor, data, dataSize) else
    Result := False;
end;

function TCefFastResourceBundle.GetLocalizedString(stringId: Integer;
  out stringVal: ustring): Boolean;
begin
  if Assigned(FGetLocalizedString) then
    Result := FGetLocalizedString(stringId, stringVal) else
    Result := False;
end;

{ TCefAppOwn }

constructor TCefAppOwn.Create;
begin
  inherited CreateData(SizeOf(TCefApp));
  with PCefApp(FData)^ do
  begin
    on_before_command_line_processing := cef_app_on_before_command_line_processing;
    on_register_custom_schemes := cef_app_on_register_custom_schemes;
    get_resource_bundle_handler := cef_app_get_resource_bundle_handler;
    get_browser_process_handler := cef_app_get_browser_process_handler;
    get_render_process_handler := cef_app_get_render_process_handler;
  end;
end;

{ TCefCookieManagerRef }

class function TCefCookieManagerRef.New(const path: ustring; persistSessionCookies: Boolean;
  const callback: ICefCompletionCallback): ICefCookieManager;
var
  pth: TCefString;
begin
  pth := CefString(path);
  Result := UnWrap(cef_cookie_manager_create_manager(@pth, Ord(persistSessionCookies), CefGetData(callback)));
end;

class function TCefCookieManagerRef.NewProc(const path: ustring;
  persistSessionCookies: Boolean;
  const callback: TCefCompletionCallbackProc): ICefCookieManager;
begin
  Result := New(path, persistSessionCookies, TCefFastCompletionCallback.Create(callback));
end;

function TCefCookieManagerRef.DeleteCookies(const url,
  cookieName: ustring; const callback: ICefDeleteCookiesCallback): Boolean;
var
  u, n: TCefString;
begin
  u := CefString(url);
  n := CefString(cookieName);
  Result := PCefCookieManager(FData).delete_cookies(
    PCefCookieManager(FData), @u, @n, CefGetData(callback)) <> 0;
end;

function TCefCookieManagerRef.DeleteCookiesProc(const url, cookieName: ustring;
  const callback: TCefDeleteCookiesCallbackProc): Boolean;
begin
  Result := DeleteCookies(url, cookieName, TCefFastDeleteCookiesCallback.Create(callback));
end;

function TCefCookieManagerRef.FlushStore(
  const handler: ICefCompletionCallback): Boolean;
begin
  Result := PCefCookieManager(FData).flush_store(PCefCookieManager(FData),
    CefGetData(handler)) <> 0;
end;

function TCefCookieManagerRef.FlushStoreProc(
  const proc: TCefCompletionCallbackProc): Boolean;
begin
  Result := FlushStore(TCefFastCompletionCallback.Create(proc))
end;

class function TCefCookieManagerRef.Global(const callback: ICefCompletionCallback): ICefCookieManager;
begin
  Result := UnWrap(cef_cookie_manager_get_global_manager(CefGetData(callback)));
end;

class function TCefCookieManagerRef.GlobalProc(
  const callback: TCefCompletionCallbackProc): ICefCookieManager;
begin
  Result := Global(TCefFastCompletionCallback.Create(callback));
end;

function TCefCookieManagerRef.SetCookie(const url, name, value, domain,
  path: ustring; secure, httponly, hasExpires: Boolean; const creation,
  lastAccess, expires: TDateTime; const callback: ICefSetCookieCallback): Boolean;
var
  str: TCefString;
  cook: TCefCookie;
begin
  str := CefString(url);
  cook.name := CefString(name);
  cook.value := CefString(value);
  cook.domain := CefString(domain);
  cook.path := CefString(path);
  cook.secure := Ord(secure);
  cook.httponly := Ord(httponly);
  cook.creation := DateTimeToCefTime(creation);
  cook.last_access := DateTimeToCefTime(lastAccess);
  cook.has_expires := Ord(hasExpires);
  if hasExpires then
    cook.expires := DateTimeToCefTime(expires) else
    FillChar(cook.expires, SizeOf(TCefTime), 0);
  Result := PCefCookieManager(FData).set_cookie(
    PCefCookieManager(FData), @str, @cook, CefGetData(callback)) <> 0;
end;

function TCefCookieManagerRef.SetCookieProc(const url, name, value, domain,
  path: ustring; secure, httponly, hasExpires: Boolean; const creation,
  lastAccess, expires: TDateTime;
  const callback: TCefSetCookieCallbackProc): Boolean;
begin
  Result := SetCookie(url, name, value, domain, path, secure,
    httponly, hasExpires, creation, lastAccess, expires,
    TCefFastSetCookieCallback.Create(callback));
end;

function TCefCookieManagerRef.SetStoragePath(const path: ustring;
  persistSessionCookies: Boolean; const callback: ICefCompletionCallback): Boolean;
var
  p: TCefString;
begin
  p := CefString(path);
  Result := PCefCookieManager(FData)^.set_storage_path(
    PCefCookieManager(FData), @p, Ord(persistSessionCookies), CefGetData(callback)) <> 0;
end;

function TCefCookieManagerRef.SetStoragePathProc(const path: ustring;
  persistSessionCookies: Boolean;
  const callback: TCefCompletionCallbackProc): Boolean;
begin
  Result := SetStoragePath(path, persistSessionCookies, TCefFastCompletionCallback.Create(callback));
end;

procedure TCefCookieManagerRef.SetSupportedSchemes(schemes: TStrings; const callback: ICefCompletionCallback);
var
  list: TCefStringList;
  i: Integer;
  item: TCefString;
begin
  list := cef_string_list_alloc();
  try
    if (schemes <> nil) then
      for i := 0 to schemes.Count - 1 do
      begin
        item := CefString(schemes[i]);
        cef_string_list_append(list, @item);
      end;
    PCefCookieManager(FData).set_supported_schemes(
      PCefCookieManager(FData), list, CefGetData(callback));

  finally
    cef_string_list_free(list);
  end;
end;

procedure TCefCookieManagerRef.SetSupportedSchemesProc(schemes: TStrings;
  const callback: TCefCompletionCallbackProc);
begin
  SetSupportedSchemes(schemes, TCefFastCompletionCallback.Create(callback));
end;

class function TCefCookieManagerRef.UnWrap(data: Pointer): ICefCookieManager;
begin
  if data <> nil then
    Result := Create(data) as ICefCookieManager else
    Result := nil;
end;

function TCefCookieManagerRef.VisitAllCookies(
  const visitor: ICefCookieVisitor): Boolean;
begin
  Result := PCefCookieManager(FData).visit_all_cookies(
    PCefCookieManager(FData), CefGetData(visitor)) <> 0;
end;

function TCefCookieManagerRef.VisitAllCookiesProc(
  const visitor: TCefCookieVisitorProc): Boolean;
begin
  Result := VisitAllCookies(
    TCefFastCookieVisitor.Create(visitor) as ICefCookieVisitor);
end;

function TCefCookieManagerRef.VisitUrlCookies(const url: ustring;
  includeHttpOnly: Boolean; const visitor: ICefCookieVisitor): Boolean;
var
  str: TCefString;
begin
  str := CefString(url);
  Result := PCefCookieManager(FData).visit_url_cookies(PCefCookieManager(FData), @str, Ord(includeHttpOnly), CefGetData(visitor)) <> 0;
end;

function TCefCookieManagerRef.VisitUrlCookiesProc(const url: ustring;
  includeHttpOnly: Boolean; const visitor: TCefCookieVisitorProc): Boolean;
begin
  Result := VisitUrlCookies(url, includeHttpOnly,
    TCefFastCookieVisitor.Create(visitor) as ICefCookieVisitor);
end;

{ TCefWebPluginInfoRef }

function TCefWebPluginInfoRef.GetDescription: ustring;
begin
  Result := CefStringFreeAndGet(PCefWebPluginInfo(FData)^.get_description(PCefWebPluginInfo(FData)));
end;

function TCefWebPluginInfoRef.GetName: ustring;
begin
  Result := CefStringFreeAndGet(PCefWebPluginInfo(FData)^.get_name(PCefWebPluginInfo(FData)));
end;

function TCefWebPluginInfoRef.GetPath: ustring;
begin
  Result := CefStringFreeAndGet(PCefWebPluginInfo(FData)^.get_path(PCefWebPluginInfo(FData)));
end;

function TCefWebPluginInfoRef.GetVersion: ustring;
begin
  Result := CefStringFreeAndGet(PCefWebPluginInfo(FData)^.get_version(PCefWebPluginInfo(FData)));
end;

class function TCefWebPluginInfoRef.UnWrap(data: Pointer): ICefWebPluginInfo;
begin
  if data <> nil then
    Result := Create(data) as ICefWebPluginInfo else
    Result := nil;
end;

{ TCefBrowserHostRef }

procedure TCefBrowserHostRef.CloseDevTools;
begin
  PCefBrowserHost(FData).close_dev_tools(FData);
end;

procedure TCefBrowserHostRef.DragSourceEndedAt(x, y: Integer;
  op: TCefDragOperation);
begin
  PCefBrowserHost(FData).drag_source_ended_at(FData, x, y, op);
end;

procedure TCefBrowserHostRef.DragSourceSystemDragEnded;
begin
  PCefBrowserHost(FData).drag_source_system_drag_ended(FData);
end;

procedure TCefBrowserHostRef.DragTargetDragEnter(const dragData: ICefDragData;
  const event: PCefMouseEvent; allowedOps: TCefDragOperations);
begin
  PCefBrowserHost(FData).drag_target_drag_enter(FData, CefGetData(dragData), event, allowedOps);
end;

procedure TCefBrowserHostRef.DragTargetDragLeave;
begin
  PCefBrowserHost(FData).drag_target_drag_leave(FData);
end;

procedure TCefBrowserHostRef.DragTargetDragOver(const event: PCefMouseEvent;
  allowedOps: TCefDragOperations);
begin
  PCefBrowserHost(FData).drag_target_drag_over(FData, event, allowedOps);
end;

procedure TCefBrowserHostRef.DragTargetDrop(event: PCefMouseEvent);
begin
  PCefBrowserHost(FData).drag_target_drop(FData, event);
end;

procedure TCefBrowserHostRef.Find(identifier: Integer;
  const searchText: ustring; forward, matchCase, findNext: Boolean);
var
  s: TCefString;
begin
  s := CefString(searchText);
  PCefBrowserHost(FData).find(FData, identifier, @s, Ord(forward), Ord(matchCase), Ord(findNext));
end;

function TCefBrowserHostRef.GetBrowser: ICefBrowser;
begin
  Result := TCefBrowserRef.UnWrap(PCefBrowserHost(FData).get_browser(PCefBrowserHost(FData)));
end;

procedure TCefBrowserHostRef.Print;
begin
  PCefBrowserHost(FData).print(FData);
end;

procedure TCefBrowserHostRef.PrintToPdf(const path: ustring;
  settings: PCefPdfPrintSettings; const callback: ICefPdfPrintCallback);
var
  str: TCefString;
begin
  str := CefString(path);
  PCefBrowserHost(FData).print_to_pdf(FData, @str, settings, CefGetData(callback));
end;

procedure TCefBrowserHostRef.PrintToPdfProc(const path: ustring;
  settings: PCefPdfPrintSettings; const callback: TOnPdfPrintFinishedProc);
begin
  PrintToPdf(path, settings, TCefFastPdfPrintCallback.Create(callback));
end;

procedure TCefBrowserHostRef.ReplaceMisspelling(const word: ustring);
var
  str: TCefString;
begin
  str := CefString(word);
  PCefBrowserHost(FData).replace_misspelling(FData, @str);
end;

procedure TCefBrowserHostRef.RunFileDialog(mode: TCefFileDialogMode;
  const title, defaultFilePath: ustring; acceptFilters: TStrings;
  selectedAcceptFilter: Integer; const callback: ICefRunFileDialogCallback);
var
  t, f: TCefString;
  list: TCefStringList;
  item: TCefString;
  i: Integer;
begin
  t := CefString(title);
  f := CefString(defaultFilePath);
  list := cef_string_list_alloc();
  try
    for i := 0 to acceptFilters.Count - 1 do
    begin
      item := CefString(acceptFilters[i]);
      cef_string_list_append(list, @item);
    end;
    PCefBrowserHost(FData).run_file_dialog(PCefBrowserHost(FData), mode, @t, @f,
      list, selectedAcceptFilter, CefGetData(callback));
  finally
    cef_string_list_free(list);
  end;
end;

procedure TCefBrowserHostRef.RunFileDialogProc(mode: TCefFileDialogMode;
  const title, defaultFilePath: ustring; acceptFilters: TStrings;
  selectedAcceptFilter: Integer; const callback: TCefRunFileDialogCallbackProc);
begin
  RunFileDialog(mode, title, defaultFilePath, acceptFilters, selectedAcceptFilter,
    TCefFastRunFileDialogCallback.Create(callback));
end;

procedure TCefBrowserHostRef.AddWordToDictionary(const word: ustring);
var
  str: TCefString;
begin
  str := CefString(word);
  PCefBrowserHost(FData).add_word_to_dictionary(FData, @str);
end;

procedure TCefBrowserHostRef.CloseBrowser(forceClose: Boolean);
begin
  PCefBrowserHost(FData).close_browser(PCefBrowserHost(FData), Ord(forceClose));
end;

procedure TCefBrowserHostRef.SendCaptureLostEvent;
begin
  PCefBrowserHost(FData).send_capture_lost_event(FData);
end;

procedure TCefBrowserHostRef.SendFocusEvent(setFocus: Boolean);
begin
  PCefBrowserHost(FData).send_focus_event(FData, Ord(setFocus));
end;

procedure TCefBrowserHostRef.SendKeyEvent(const event: PCefKeyEvent);
begin
  PCefBrowserHost(FData).send_key_event(FData, event);
end;

procedure TCefBrowserHostRef.SendMouseClickEvent(const event: PCefMouseEvent;
  kind: TCefMouseButtonType; mouseUp: Boolean; clickCount: Integer);
begin
  PCefBrowserHost(FData).send_mouse_click_event(FData, event, kind, Ord(mouseUp), clickCount);
end;

procedure TCefBrowserHostRef.SendMouseMoveEvent(const event: PCefMouseEvent;
  mouseLeave: Boolean);
begin
  PCefBrowserHost(FData).send_mouse_move_event(FData, event, Ord(mouseLeave));
end;

procedure TCefBrowserHostRef.SendMouseWheelEvent(const event: PCefMouseEvent;
  deltaX, deltaY: Integer);
begin
  PCefBrowserHost(FData).send_mouse_wheel_event(FData, event, deltaX, deltaY);
end;

procedure TCefBrowserHostRef.SetFocus(focus: Boolean);
begin
  PCefBrowserHost(FData).set_focus(PCefBrowserHost(FData), Ord(focus));
end;

procedure TCefBrowserHostRef.SetMouseCursorChangeDisabled(disabled: Boolean);
begin
  PCefBrowserHost(FData).set_mouse_cursor_change_disabled(PCefBrowserHost(FData), Ord(disabled));
end;

procedure TCefBrowserHostRef.SetWindowlessFrameRate(frameRate: Integer);
begin
  PCefBrowserHost(FData).set_windowless_frame_rate(PCefBrowserHost(FData), frameRate);
end;

procedure TCefBrowserHostRef.SetWindowVisibility(visible: Boolean);
begin
  PCefBrowserHost(FData).set_window_visibility(PCefBrowserHost(FData), Ord(visible));
end;

function TCefBrowserHostRef.GetWindowHandle: TCefWindowHandle;
begin
  Result := PCefBrowserHost(FData).get_window_handle(PCefBrowserHost(FData))
end;

function TCefBrowserHostRef.GetWindowlessFrameRate: Integer;
begin
  Result := PCefBrowserHost(FData).get_windowless_frame_rate(PCefBrowserHost(FData));
end;

function TCefBrowserHostRef.GetOpenerWindowHandle: TCefWindowHandle;
begin
  Result := PCefBrowserHost(FData).get_opener_window_handle(PCefBrowserHost(FData));
end;

function TCefBrowserHostRef.GetRequestContext: ICefRequestContext;
begin
  Result := TCefRequestContextRef.UnWrap(PCefBrowserHost(FData).get_request_context(FData));
end;

procedure TCefBrowserHostRef.GetNavigationEntries(
  const visitor: ICefNavigationEntryVisitor; currentOnly: Boolean);
begin
  PCefBrowserHost(FData).get_navigation_entries(FData, CefGetData(visitor), Ord(currentOnly));
end;

procedure TCefBrowserHostRef.GetNavigationEntriesProc(
  const proc: TCefNavigationEntryVisitorProc; currentOnly: Boolean);
begin
  GetNavigationEntries(TCefFastNavigationEntryVisitor.Create(proc), currentOnly);
end;

function TCefBrowserHostRef.GetNsTextInputContext: TCefTextInputContext;
begin
  Result := PCefBrowserHost(FData).get_nstext_input_context(PCefBrowserHost(FData));
end;

function TCefBrowserHostRef.GetZoomLevel: Double;
begin
  Result := PCefBrowserHost(FData).get_zoom_level(PCefBrowserHost(FData));
end;

procedure TCefBrowserHostRef.HandleKeyEventAfterTextInputClient(
  keyEvent: TCefEventHandle);
begin
  PCefBrowserHost(FData).handle_key_event_after_text_input_client(PCefBrowserHost(FData), keyEvent);
end;

procedure TCefBrowserHostRef.HandleKeyEventBeforeTextInputClient(
  keyEvent: TCefEventHandle);
begin
  PCefBrowserHost(FData).handle_key_event_before_text_input_client(PCefBrowserHost(FData), keyEvent);
end;

procedure TCefBrowserHostRef.Invalidate(kind: TCefPaintElementType);
begin
  PCefBrowserHost(FData).invalidate(FData, kind);
end;

function TCefBrowserHostRef.IsMouseCursorChangeDisabled: Boolean;
begin
  Result := PCefBrowserHost(FData).is_mouse_cursor_change_disabled(FData) <> 0
end;

function TCefBrowserHostRef.IsWindowRenderingDisabled: Boolean;
begin
  Result := PCefBrowserHost(FData).is_window_rendering_disabled(FData) <> 0
end;

procedure TCefBrowserHostRef.NotifyMoveOrResizeStarted;
begin
  PCefBrowserHost(FData).notify_move_or_resize_started(PCefBrowserHost(FData));
end;

procedure TCefBrowserHostRef.NotifyScreenInfoChanged;
begin
  PCefBrowserHost(FData).notify_screen_info_changed(PCefBrowserHost(FData));
end;

procedure TCefBrowserHostRef.SetZoomLevel(zoomLevel: Double);
begin
  PCefBrowserHost(FData).set_zoom_level(PCefBrowserHost(FData), zoomLevel);
end;

procedure TCefBrowserHostRef.ShowDevTools(const windowInfo: PCefWindowInfo;
  const client: ICefClient; const settings: PCefBrowserSettings;
  inspectElementAt: PCefPoint);
begin
  PCefBrowserHost(FData).show_dev_tools(FData, windowInfo, CefGetData(client),
    settings, inspectElementAt);
end;

procedure TCefBrowserHostRef.StartDownload(const url: ustring);
var
  u: TCefString;
begin
  u := CefString(url);
  PCefBrowserHost(FData).start_download(PCefBrowserHost(FData), @u);
end;

procedure TCefBrowserHostRef.StopFinding(clearSelection: Boolean);
begin
  PCefBrowserHost(FData).stop_finding(FData, Ord(clearSelection));
end;

class function TCefBrowserHostRef.UnWrap(data: Pointer): ICefBrowserHost;
begin
  if data <> nil then
    Result := Create(data) as ICefBrowserHost else
    Result := nil;
end;

procedure TCefBrowserHostRef.WasHidden(hidden: Boolean);
begin
  PCefBrowserHost(FData).was_hidden(FData, Ord(hidden));
end;

procedure TCefBrowserHostRef.WasResized;
begin
  PCefBrowserHost(FData).was_resized(FData);
end;

{ TCefProcessMessageRef }

function TCefProcessMessageRef.Copy: ICefProcessMessage;
begin
  Result := UnWrap(PCefProcessMessage(FData)^.copy(PCefProcessMessage(FData)));
end;

function TCefProcessMessageRef.GetArgumentList: ICefListValue;
begin
  Result := TCefListValueRef.UnWrap(PCefProcessMessage(FData)^.get_argument_list(PCefProcessMessage(FData)));
end;

function TCefProcessMessageRef.GetName: ustring;
begin
  Result := CefStringFreeAndGet(PCefProcessMessage(FData)^.get_name(PCefProcessMessage(FData)));
end;

function TCefProcessMessageRef.IsReadOnly: Boolean;
begin
  Result := PCefProcessMessage(FData)^.is_read_only(PCefProcessMessage(FData)) <> 0;
end;

function TCefProcessMessageRef.IsValid: Boolean;
begin
  Result := PCefProcessMessage(FData)^.is_valid(PCefProcessMessage(FData)) <> 0;
end;

class function TCefProcessMessageRef.New(const name: ustring): ICefProcessMessage;
var
  n: TCefString;
begin
  n := CefString(name);
  Result := UnWrap(cef_process_message_create(@n));
end;

class function TCefProcessMessageRef.UnWrap(data: Pointer): ICefProcessMessage;
begin
  if data <> nil then
    Result := Create(data) as ICefProcessMessage else
    Result := nil;
end;

{ TCefStringVisitorOwn }

constructor TCefStringVisitorOwn.Create;
begin
  inherited CreateData(SizeOf(TCefStringVisitor));
  with PCefStringVisitor(FData)^ do
    visit := cef_string_visitor_visit;
end;

procedure TCefStringVisitorOwn.Visit(const str: ustring);
begin

end;

{ TCefFastStringVisitor }

constructor TCefFastStringVisitor.Create(
  const callback: TCefStringVisitorProc);
begin
  inherited Create;
  FVisit := callback;
end;

procedure TCefFastStringVisitor.Visit(const str: ustring);
begin
  FVisit(str);
end;

{ TCefDownLoadItemRef }

function TCefDownLoadItemRef.GetContentDisposition: ustring;
begin
  Result := CefStringFreeAndGet(PCefDownloadItem(FData)^.get_content_disposition(PCefDownloadItem(FData)));
end;

function TCefDownLoadItemRef.GetCurrentSpeed: Int64;
begin
  Result := PCefDownloadItem(FData)^.get_current_speed(PCefDownloadItem(FData));
end;

function TCefDownLoadItemRef.GetEndTime: TDateTime;
begin
  Result := CefTimeToDateTime(PCefDownloadItem(FData)^.get_end_time(PCefDownloadItem(FData)));
end;

function TCefDownLoadItemRef.GetFullPath: ustring;
begin
  Result := CefStringFreeAndGet(PCefDownloadItem(FData)^.get_full_path(PCefDownloadItem(FData)));
end;

function TCefDownLoadItemRef.GetId: Cardinal;
begin
  Result := PCefDownloadItem(FData)^.get_id(PCefDownloadItem(FData));
end;

function TCefDownLoadItemRef.GetMimeType: ustring;
begin
  Result := CefStringFreeAndGet(PCefDownloadItem(FData)^.get_mime_type(PCefDownloadItem(FData)));
end;

function TCefDownLoadItemRef.GetOriginalUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefDownloadItem(FData)^.get_original_url(PCefDownloadItem(FData)));
end;

function TCefDownLoadItemRef.GetPercentComplete: Integer;
begin
  Result := PCefDownloadItem(FData)^.get_percent_complete(PCefDownloadItem(FData));
end;

function TCefDownLoadItemRef.GetReceivedBytes: Int64;
begin
  Result := PCefDownloadItem(FData)^.get_received_bytes(PCefDownloadItem(FData));
end;

function TCefDownLoadItemRef.GetStartTime: TDateTime;
begin
  Result := CefTimeToDateTime(PCefDownloadItem(FData)^.get_start_time(PCefDownloadItem(FData)));
end;

function TCefDownLoadItemRef.GetSuggestedFileName: ustring;
begin
  Result := CefStringFreeAndGet(PCefDownloadItem(FData)^.get_suggested_file_name(PCefDownloadItem(FData)));
end;

function TCefDownLoadItemRef.GetTotalBytes: Int64;
begin
  Result := PCefDownloadItem(FData)^.get_total_bytes(PCefDownloadItem(FData));
end;

function TCefDownLoadItemRef.GetUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefDownloadItem(FData)^.get_url(PCefDownloadItem(FData)));
end;

function TCefDownLoadItemRef.IsCanceled: Boolean;
begin
  Result := PCefDownloadItem(FData)^.is_canceled(PCefDownloadItem(FData)) <> 0;
end;

function TCefDownLoadItemRef.IsComplete: Boolean;
begin
  Result := PCefDownloadItem(FData)^.is_complete(PCefDownloadItem(FData)) <> 0;
end;

function TCefDownLoadItemRef.IsInProgress: Boolean;
begin
  Result := PCefDownloadItem(FData)^.is_in_progress(PCefDownloadItem(FData)) <> 0;
end;

function TCefDownLoadItemRef.IsValid: Boolean;
begin
  Result := PCefDownloadItem(FData)^.is_valid(PCefDownloadItem(FData)) <> 0;
end;

class function TCefDownLoadItemRef.UnWrap(data: Pointer): ICefDownLoadItem;
begin
  if data <> nil then
    Result := Create(data) as ICefDownLoadItem else
    Result := nil;
end;

{ TCefBeforeDownloadCallbackRef }

procedure TCefBeforeDownloadCallbackRef.Cont(const downloadPath: ustring;
  showDialog: Boolean);
var
  dp: TCefString;
begin
  dp := CefString(downloadPath);
  PCefBeforeDownloadCallback(FData).cont(PCefBeforeDownloadCallback(FData), @dp, Ord(showDialog));
end;

class function TCefBeforeDownloadCallbackRef.UnWrap(
  data: Pointer): ICefBeforeDownloadCallback;
begin
  if data <> nil then
    Result := Create(data) as ICefBeforeDownloadCallback else
    Result := nil;
end;

{ TCefDownloadItemCallbackRef }

procedure TCefDownloadItemCallbackRef.cancel;
begin
  PCefDownloadItemCallback(FData).cancel(PCefDownloadItemCallback(FData));
end;

procedure TCefDownloadItemCallbackRef.Pause;
begin
  PCefDownloadItemCallback(FData).pause(PCefDownloadItemCallback(FData));
end;

procedure TCefDownloadItemCallbackRef.Resume;
begin
  PCefDownloadItemCallback(FData).resume(PCefDownloadItemCallback(FData));
end;

class function TCefDownloadItemCallbackRef.UnWrap(
  data: Pointer): ICefDownloadItemCallback;
begin
  if data <> nil then
    Result := Create(data) as ICefDownloadItemCallback else
    Result := nil;
end;

{ TCefAuthCallbackRef }

procedure TCefAuthCallbackRef.Cancel;
begin
  PCefAuthCallback(FData).cancel(PCefAuthCallback(FData));
end;

procedure TCefAuthCallbackRef.Cont(const username, password: ustring);
var
  u, p: TCefString;
begin
  u := CefString(username);
  p := CefString(password);
  PCefAuthCallback(FData).cont(PCefAuthCallback(FData), @u, @p);
end;

class function TCefAuthCallbackRef.UnWrap(data: Pointer): ICefAuthCallback;
begin
  if data <> nil then
    Result := Create(data) as ICefAuthCallback else
    Result := nil;
end;

{ TCefJsDialogCallbackRef }

procedure TCefJsDialogCallbackRef.Cont(success: Boolean;
  const userInput: ustring);
var
  ui: TCefString;
begin
  ui := CefString(userInput);
  PCefJsDialogCallback(FData).cont(PCefJsDialogCallback(FData), Ord(success), @ui);
end;

class function TCefJsDialogCallbackRef.UnWrap(
  data: Pointer): ICefJsDialogCallback;
begin
  if data <> nil then
    Result := Create(data) as ICefJsDialogCallback else
    Result := nil;
end;

{ TCefCommandLineRef }

procedure TCefCommandLineRef.AppendArgument(const argument: ustring);
var
  a: TCefString;
begin
  a := CefString(argument);
  PCefCommandLine(FData).append_argument(PCefCommandLine(FData), @a);
end;

procedure TCefCommandLineRef.AppendSwitch(const name: ustring);
var
  n: TCefString;
begin
  n := CefString(name);
  PCefCommandLine(FData).append_switch(PCefCommandLine(FData), @n);
end;

procedure TCefCommandLineRef.AppendSwitchWithValue(const name, value: ustring);
var
  n, v: TCefString;
begin
  n := CefString(name);
  v := CefString(value);
  PCefCommandLine(FData).append_switch_with_value(PCefCommandLine(FData), @n, @v);
end;

function TCefCommandLineRef.Copy: ICefCommandLine;
begin
  Result := UnWrap(PCefCommandLine(FData).copy(PCefCommandLine(FData)));
end;

procedure TCefCommandLineRef.GetArguments(arguments: TStrings);
var
  list: TCefStringList;
  i: Integer;
  str: TCefString;
begin
  list := cef_string_list_alloc;
  try
    PCefCommandLine(FData).get_arguments(PCefCommandLine(FData), list);
    for i := 0 to cef_string_list_size(list) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(list, i, @str);
      arguments.Add(CefStringClearAndGet(str));
    end;
  finally
    cef_string_list_free(list);
  end;
end;

procedure TCefCommandLineRef.GetArgv(args: TStrings);
var
  list: TCefStringList;
  i: Integer;
  str: TCefString;
begin
  list := cef_string_list_alloc;
  try
    PCefCommandLine(FData).get_argv(FData, list);
    for i := 0 to cef_string_list_size(list) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(list, i, @str);
      args.Add(CefStringClearAndGet(str));
    end;
  finally
    cef_string_list_free(list);
  end;
end;

function TCefCommandLineRef.GetCommandLineString: ustring;
begin
  Result := CefStringFreeAndGet(PCefCommandLine(FData).get_command_line_string(PCefCommandLine(FData)));
end;

function TCefCommandLineRef.GetProgram: ustring;
begin
  Result := CefStringFreeAndGet(PCefCommandLine(FData).get_program(PCefCommandLine(FData)));
end;

procedure TCefCommandLineRef.GetSwitches(switches: TStrings);
var
  list: TCefStringList;
  i: Integer;
  str: TCefString;
begin
  list := cef_string_list_alloc;
  try
    PCefCommandLine(FData).get_switches(PCefCommandLine(FData), list);
    for i := 0 to cef_string_list_size(list) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(list, i, @str);
      switches.Add(CefStringClearAndGet(str));
    end;
  finally
    cef_string_list_free(list);
  end;
end;

function TCefCommandLineRef.GetSwitchValue(const name: ustring): ustring;
var
  n: TCefString;
begin
  n := CefString(name);
  Result := CefStringFreeAndGet(PCefCommandLine(FData).get_switch_value(PCefCommandLine(FData), @n));
end;

class function TCefCommandLineRef.Global: ICefCommandLine;
begin
  Result := UnWrap(cef_command_line_get_global);
end;

function TCefCommandLineRef.HasArguments: Boolean;
begin
  Result := PCefCommandLine(FData).has_arguments(PCefCommandLine(FData)) <> 0;
end;

function TCefCommandLineRef.HasSwitch(const name: ustring): Boolean;
var
  n: TCefString;
begin
  n := CefString(name);
  Result := PCefCommandLine(FData).has_switch(PCefCommandLine(FData), @n) <> 0;
end;

function TCefCommandLineRef.HasSwitches: Boolean;
begin
  Result := PCefCommandLine(FData).has_switches(PCefCommandLine(FData)) <> 0;
end;

procedure TCefCommandLineRef.InitFromArgv(argc: Integer;
  const argv: PPAnsiChar);
begin
  PCefCommandLine(FData).init_from_argv(PCefCommandLine(FData), argc, argv);
end;

procedure TCefCommandLineRef.InitFromString(const commandLine: ustring);
var
  cl: TCefString;
begin
  cl := CefString(commandLine);
  PCefCommandLine(FData).init_from_string(PCefCommandLine(FData), @cl);
end;

function TCefCommandLineRef.IsReadOnly: Boolean;
begin
  Result := PCefCommandLine(FData).is_read_only(PCefCommandLine(FData)) <> 0;
end;

function TCefCommandLineRef.IsValid: Boolean;
begin
  Result := PCefCommandLine(FData).is_valid(PCefCommandLine(FData)) <> 0;
end;

class function TCefCommandLineRef.New: ICefCommandLine;
begin
  Result := UnWrap(cef_command_line_create);
end;

procedure TCefCommandLineRef.PrependWrapper(const wrapper: ustring);
var
  w: TCefString;
begin
  w := CefString(wrapper);
  PCefCommandLine(FData).prepend_wrapper(PCefCommandLine(FData), @w);
end;

procedure TCefCommandLineRef.Reset;
begin
  PCefCommandLine(FData).reset(PCefCommandLine(FData));
end;

procedure TCefCommandLineRef.SetProgram(const prog: ustring);
var
  p: TCefString;
begin
  p := CefString(prog);
  PCefCommandLine(FData).set_program(PCefCommandLine(FData), @p);
end;

class function TCefCommandLineRef.UnWrap(data: Pointer): ICefCommandLine;
begin
  if data <> nil then
    Result := Create(data) as ICefCommandLine else
    Result := nil;
end;

{ TCefSchemeRegistrarRef }

function TCefSchemeRegistrarRef.AddCustomScheme(const schemeName: ustring;
  IsStandard, IsLocal, IsDisplayIsolated: Boolean): Boolean;
var
  sn: TCefString;
begin
  sn := CefString(schemeName);
  Result := PCefSchemeRegistrar(FData).add_custom_scheme(PCefSchemeRegistrar(FData),
    @sn, Ord(IsStandard), Ord(IsLocal), Ord(IsDisplayIsolated)) <> 0;
end;

class function TCefSchemeRegistrarRef.UnWrap(
  data: Pointer): ICefSchemeRegistrar;
begin
  if data <> nil then
    Result := Create(data) as ICefSchemeRegistrar else
    Result := nil;
end;

{ TCefGeolocationCallbackRef }

procedure TCefGeolocationCallbackRef.Cont(allow: Boolean);
begin
  PCefGeolocationCallback(FData).cont(PCefGeolocationCallback(FData), Ord(allow));
end;

class function TCefGeolocationCallbackRef.UnWrap(
  data: Pointer): ICefGeolocationCallback;
begin
  if data <> nil then
    Result := Create(data) as ICefGeolocationCallback else
    Result := nil;
end;

{ TCefContextMenuParamsRef }

function TCefContextMenuParamsRef.GetDictionarySuggestions(
  const suggestions: TStringList): Boolean;
var
  list: TCefStringList;
  i: Integer;
  str: TCefString;
begin
  list := cef_string_list_alloc;
  try
    Result := PCefContextMenuParams(FData).get_dictionary_suggestions(PCefContextMenuParams(FData), list) <> 0;
    FillChar(str, SizeOf(str), 0);
    for i := 0 to cef_string_list_size(list) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(list, i, @str);
      suggestions.Add(CefStringClearAndGet(str));
    end;
  finally
    cef_string_list_free(list);
  end;
end;

function TCefContextMenuParamsRef.GetEditStateFlags: TCefContextMenuEditStateFlags;
begin
  Byte(Result) := PCefContextMenuParams(FData).get_edit_state_flags(PCefContextMenuParams(FData));
end;

function TCefContextMenuParamsRef.GetFrameCharset: ustring;
begin
  Result := CefStringFreeAndGet(PCefContextMenuParams(FData).get_frame_charset(PCefContextMenuParams(FData)));
end;

function TCefContextMenuParamsRef.GetFrameUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefContextMenuParams(FData).get_frame_url(PCefContextMenuParams(FData)));
end;

function TCefContextMenuParamsRef.GetLinkUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefContextMenuParams(FData).get_link_url(PCefContextMenuParams(FData)));
end;

function TCefContextMenuParamsRef.GetMediaStateFlags: TCefContextMenuMediaStateFlags;
begin
  Word(Result) := PCefContextMenuParams(FData).get_media_state_flags(PCefContextMenuParams(FData));
end;

function TCefContextMenuParamsRef.GetMediaType: TCefContextMenuMediaType;
begin
  Result := PCefContextMenuParams(FData).get_media_type(PCefContextMenuParams(FData));
end;

function TCefContextMenuParamsRef.GetMisspelledWord: ustring;
begin
  Result := CefStringFreeAndGet(PCefContextMenuParams(FData).get_misspelled_word(PCefContextMenuParams(FData)));
end;

function TCefContextMenuParamsRef.GetPageUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefContextMenuParams(FData).get_page_url(PCefContextMenuParams(FData)));
end;

function TCefContextMenuParamsRef.GetSelectionText: ustring;
begin
  Result := CefStringFreeAndGet(PCefContextMenuParams(FData).get_selection_text(PCefContextMenuParams(FData)));
end;

function TCefContextMenuParamsRef.GetSourceUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefContextMenuParams(FData).get_source_url(PCefContextMenuParams(FData)));
end;

function TCefContextMenuParamsRef.GetTypeFlags: TCefContextMenuTypeFlags;
begin
  Byte(Result) := PCefContextMenuParams(FData).get_type_flags(PCefContextMenuParams(FData));
end;

function TCefContextMenuParamsRef.GetUnfilteredLinkUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefContextMenuParams(FData).get_unfiltered_link_url(PCefContextMenuParams(FData)));
end;

function TCefContextMenuParamsRef.GetXCoord: Integer;
begin
  Result := PCefContextMenuParams(FData).get_xcoord(PCefContextMenuParams(FData));
end;

function TCefContextMenuParamsRef.GetYCoord: Integer;
begin
  Result := PCefContextMenuParams(FData).get_ycoord(PCefContextMenuParams(FData));
end;

function TCefContextMenuParamsRef.IsCustomMenu: Boolean;
begin
  Result := PCefContextMenuParams(FData).is_custom_menu(PCefContextMenuParams(FData)) <> 0;
end;

function TCefContextMenuParamsRef.IsEditable: Boolean;
begin
  Result := PCefContextMenuParams(FData).is_editable(PCefContextMenuParams(FData)) <> 0;
end;

function TCefContextMenuParamsRef.IsPepperMenu: Boolean;
begin
  Result := PCefContextMenuParams(FData).is_pepper_menu(PCefContextMenuParams(FData)) <> 0;
end;

function TCefContextMenuParamsRef.IsSpellCheckEnabled: Boolean;
begin
  Result := PCefContextMenuParams(FData).is_spell_check_enabled(PCefContextMenuParams(FData)) <> 0;
end;

function TCefContextMenuParamsRef.HasImageContents: Boolean;
begin
  Result := PCefContextMenuParams(FData).has_image_contents(PCefContextMenuParams(FData)) <> 0;
end;

class function TCefContextMenuParamsRef.UnWrap(
  data: Pointer): ICefContextMenuParams;
begin
  if data <> nil then
    Result := Create(data) as ICefContextMenuParams else
    Result := nil;
end;

{ TCefMenuModelRef }

function TCefMenuModelRef.AddCheckItem(commandId: Integer;
  const text: ustring): Boolean;
var
  t: TCefString;
begin
  t := CefString(text);
  Result := PCefMenuModel(FData).add_check_item(PCefMenuModel(FData), commandId, @t) <> 0;
end;

function TCefMenuModelRef.AddItem(commandId: Integer;
  const text: ustring): Boolean;
var
  t: TCefString;
begin
  t := CefString(text);
  Result := PCefMenuModel(FData).add_item(PCefMenuModel(FData), commandId, @t) <> 0;
end;

function TCefMenuModelRef.AddRadioItem(commandId: Integer; const text: ustring;
  groupId: Integer): Boolean;
var
  t: TCefString;
begin
  t := CefString(text);
  Result := PCefMenuModel(FData).add_radio_item(PCefMenuModel(FData), commandId, @t, groupId) <> 0;
end;

function TCefMenuModelRef.AddSeparator: Boolean;
begin
  Result := PCefMenuModel(FData).add_separator(PCefMenuModel(FData)) <> 0;
end;

function TCefMenuModelRef.AddSubMenu(commandId: Integer;
  const text: ustring): ICefMenuModel;
var
  t: TCefString;
begin
  t := CefString(text);
  Result := TCefMenuModelRef.UnWrap(PCefMenuModel(FData).add_sub_menu(PCefMenuModel(FData), commandId, @t));
end;

function TCefMenuModelRef.Clear: Boolean;
begin
  Result := PCefMenuModel(FData).clear(PCefMenuModel(FData)) <> 0;
end;

function TCefMenuModelRef.GetAccelerator(commandId: Integer;
  out keyCode: Integer; out shiftPressed, ctrlPressed,
  altPressed: Boolean): Boolean;
var
  sp, cp, ap: Integer;
begin
  Result := PCefMenuModel(FData).get_accelerator(PCefMenuModel(FData),
    commandId, @keyCode, @sp, @cp, @ap) <> 0;
  shiftPressed := sp <> 0;
  ctrlPressed := cp <> 0;
  altPressed := ap <> 0;
end;

function TCefMenuModelRef.GetAcceleratorAt(index: Integer; out keyCode: Integer;
  out shiftPressed, ctrlPressed, altPressed: Boolean): Boolean;
var
  sp, cp, ap: Integer;
begin
  Result := PCefMenuModel(FData).get_accelerator_at(PCefMenuModel(FData),
    index, @keyCode, @sp, @cp, @ap) <> 0;
  shiftPressed := sp <> 0;
  ctrlPressed := cp <> 0;
  altPressed := ap <> 0;
end;

function TCefMenuModelRef.GetCommandIdAt(index: Integer): Integer;
begin
  Result := PCefMenuModel(FData).get_command_id_at(PCefMenuModel(FData), index);
end;

function TCefMenuModelRef.GetCount: Integer;
begin
  Result := PCefMenuModel(FData).get_count(PCefMenuModel(FData));
end;

function TCefMenuModelRef.GetGroupId(commandId: Integer): Integer;
begin
  Result := PCefMenuModel(FData).get_group_id(PCefMenuModel(FData), commandId);
end;

function TCefMenuModelRef.GetGroupIdAt(index: Integer): Integer;
begin
  Result := PCefMenuModel(FData).get_group_id(PCefMenuModel(FData), index);
end;

function TCefMenuModelRef.GetIndexOf(commandId: Integer): Integer;
begin
  Result := PCefMenuModel(FData).get_index_of(PCefMenuModel(FData), commandId);
end;

function TCefMenuModelRef.GetLabel(commandId: Integer): ustring;
begin
  Result := CefStringFreeAndGet(PCefMenuModel(FData).get_label(PCefMenuModel(FData), commandId));
end;

function TCefMenuModelRef.GetLabelAt(index: Integer): ustring;
begin
  Result := CefStringFreeAndGet(PCefMenuModel(FData).get_label_at(PCefMenuModel(FData), index));
end;

function TCefMenuModelRef.GetSubMenu(commandId: Integer): ICefMenuModel;
begin
  Result := TCefMenuModelRef.UnWrap(PCefMenuModel(FData).get_sub_menu(PCefMenuModel(FData), commandId));
end;

function TCefMenuModelRef.GetSubMenuAt(index: Integer): ICefMenuModel;
begin
  Result := TCefMenuModelRef.UnWrap(PCefMenuModel(FData).get_sub_menu_at(PCefMenuModel(FData), index));
end;

function TCefMenuModelRef.GetType(commandId: Integer): TCefMenuItemType;
begin
  Result := PCefMenuModel(FData).get_type(PCefMenuModel(FData), commandId);
end;

function TCefMenuModelRef.GetTypeAt(index: Integer): TCefMenuItemType;
begin
  Result := PCefMenuModel(FData).get_type_at(PCefMenuModel(FData), index);
end;

function TCefMenuModelRef.HasAccelerator(commandId: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).has_accelerator(PCefMenuModel(FData), commandId) <> 0;
end;

function TCefMenuModelRef.HasAcceleratorAt(index: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).has_accelerator_at(PCefMenuModel(FData), index) <> 0;
end;

function TCefMenuModelRef.InsertCheckItemAt(index, commandId: Integer;
  const text: ustring): Boolean;
var
  t: TCefString;
begin
  t := CefString(text);
  Result := PCefMenuModel(FData).insert_check_item_at(PCefMenuModel(FData), index, commandId, @t) <> 0;
end;

function TCefMenuModelRef.InsertItemAt(index, commandId: Integer;
  const text: ustring): Boolean;
var
  t: TCefString;
begin
  t := CefString(text);
  Result := PCefMenuModel(FData).insert_item_at(PCefMenuModel(FData), index, commandId, @t) <> 0;
end;

function TCefMenuModelRef.InsertRadioItemAt(index, commandId: Integer;
  const text: ustring; groupId: Integer): Boolean;
var
  t: TCefString;
begin
  t := CefString(text);
  Result := PCefMenuModel(FData).insert_radio_item_at(PCefMenuModel(FData),
    index, commandId, @t, groupId) <> 0;
end;

function TCefMenuModelRef.InsertSeparatorAt(index: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).insert_separator_at(PCefMenuModel(FData), index) <> 0;
end;

function TCefMenuModelRef.InsertSubMenuAt(index, commandId: Integer;
  const text: ustring): ICefMenuModel;
var
  t: TCefString;
begin
  t := CefString(text);
  Result := TCefMenuModelRef.UnWrap(PCefMenuModel(FData).insert_sub_menu_at(
    PCefMenuModel(FData), index, commandId, @t));
end;

function TCefMenuModelRef.IsChecked(commandId: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).is_checked(PCefMenuModel(FData), commandId) <> 0;
end;

function TCefMenuModelRef.IsCheckedAt(index: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).is_checked_at(PCefMenuModel(FData), index) <> 0;
end;

function TCefMenuModelRef.IsEnabled(commandId: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).is_enabled(PCefMenuModel(FData), commandId) <> 0;
end;

function TCefMenuModelRef.IsEnabledAt(index: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).is_enabled_at(PCefMenuModel(FData), index) <> 0;
end;

function TCefMenuModelRef.IsVisible(commandId: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).is_visible(PCefMenuModel(FData), commandId) <> 0;
end;

function TCefMenuModelRef.isVisibleAt(index: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).is_visible_at(PCefMenuModel(FData), index) <> 0;
end;

function TCefMenuModelRef.Remove(commandId: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).remove(PCefMenuModel(FData), commandId) <> 0;
end;

function TCefMenuModelRef.RemoveAccelerator(commandId: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).remove_accelerator(PCefMenuModel(FData), commandId) <> 0;
end;

function TCefMenuModelRef.RemoveAcceleratorAt(index: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).remove_accelerator_at(PCefMenuModel(FData), index) <> 0;
end;

function TCefMenuModelRef.RemoveAt(index: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).remove_at(PCefMenuModel(FData), index) <> 0;
end;

function TCefMenuModelRef.SetAccelerator(commandId, keyCode: Integer;
  shiftPressed, ctrlPressed, altPressed: Boolean): Boolean;
begin
  Result := PCefMenuModel(FData).set_accelerator(PCefMenuModel(FData),
    commandId, keyCode, Ord(shiftPressed), Ord(ctrlPressed), Ord(altPressed)) <> 0;
end;

function TCefMenuModelRef.SetAcceleratorAt(index, keyCode: Integer;
  shiftPressed, ctrlPressed, altPressed: Boolean): Boolean;
begin
  Result := PCefMenuModel(FData).set_accelerator_at(PCefMenuModel(FData),
    index, keyCode, Ord(shiftPressed), Ord(ctrlPressed), Ord(altPressed)) <> 0;
end;

function TCefMenuModelRef.setChecked(commandId: Integer;
  checked: Boolean): Boolean;
begin
  Result := PCefMenuModel(FData).set_checked(PCefMenuModel(FData),
    commandId, Ord(checked)) <> 0;
end;

function TCefMenuModelRef.setCheckedAt(index: Integer;
  checked: Boolean): Boolean;
begin
  Result := PCefMenuModel(FData).set_checked_at(PCefMenuModel(FData), index, Ord(checked)) <> 0;
end;

function TCefMenuModelRef.SetCommandIdAt(index, commandId: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).set_command_id_at(PCefMenuModel(FData), index, commandId) <> 0;
end;

function TCefMenuModelRef.SetEnabled(commandId: Integer;
  enabled: Boolean): Boolean;
begin
  Result := PCefMenuModel(FData).set_enabled(PCefMenuModel(FData), commandId, Ord(enabled)) <> 0;
end;

function TCefMenuModelRef.SetEnabledAt(index: Integer;
  enabled: Boolean): Boolean;
begin
  Result := PCefMenuModel(FData).set_enabled_at(PCefMenuModel(FData), index, Ord(enabled)) <> 0;
end;

function TCefMenuModelRef.SetGroupId(commandId, groupId: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).set_group_id(PCefMenuModel(FData), commandId, groupId) <> 0;
end;

function TCefMenuModelRef.SetGroupIdAt(index, groupId: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).set_group_id_at(PCefMenuModel(FData), index, groupId) <> 0;
end;

function TCefMenuModelRef.SetLabel(commandId: Integer;
  const text: ustring): Boolean;
var
  t: TCefString;
begin
  t := CefString(text);
  Result := PCefMenuModel(FData).set_label(PCefMenuModel(FData), commandId, @t) <> 0;
end;

function TCefMenuModelRef.SetLabelAt(index: Integer;
  const text: ustring): Boolean;
var
  t: TCefString;
begin
  t := CefString(text);
  Result := PCefMenuModel(FData).set_label_at(PCefMenuModel(FData), index, @t) <> 0;
end;

function TCefMenuModelRef.SetVisible(commandId: Integer;
  visible: Boolean): Boolean;
begin
  Result := PCefMenuModel(FData).set_visible(PCefMenuModel(FData), commandId, Ord(visible)) <> 0;
end;

function TCefMenuModelRef.SetVisibleAt(index: Integer;
  visible: Boolean): Boolean;
begin
  Result := PCefMenuModel(FData).set_visible_at(PCefMenuModel(FData), index, Ord(visible)) <> 0;
end;

class function TCefMenuModelRef.UnWrap(data: Pointer): ICefMenuModel;
begin
  if data <> nil then
    Result := Create(data) as ICefMenuModel else
    Result := nil;
end;

{ TCefListValueRef }

function TCefListValueRef.Clear: Boolean;
begin
  Result := PCefListValue(FData).clear(PCefListValue(FData)) <> 0;
end;

function TCefListValueRef.Copy: ICefListValue;
begin
  Result := UnWrap(PCefListValue(FData).copy(PCefListValue(FData)));
end;

class function TCefListValueRef.New: ICefListValue;
begin
  Result := UnWrap(cef_list_value_create);
end;

function TCefListValueRef.GetBinary(index: Integer): ICefBinaryValue;
begin
  Result := TCefBinaryValueRef.UnWrap(PCefListValue(FData).get_binary(PCefListValue(FData), index));
end;

function TCefListValueRef.GetBool(index: Integer): Boolean;
begin
  Result := PCefListValue(FData).get_bool(PCefListValue(FData), index) <> 0;
end;

function TCefListValueRef.GetDictionary(index: Integer): ICefDictionaryValue;
begin
  Result := TCefDictionaryValueRef.UnWrap(PCefListValue(FData).get_dictionary(PCefListValue(FData), index));
end;

function TCefListValueRef.GetDouble(index: Integer): Double;
begin
  Result := PCefListValue(FData).get_double(PCefListValue(FData), index);
end;

function TCefListValueRef.GetInt(index: Integer): Integer;
begin
  Result := PCefListValue(FData).get_int(PCefListValue(FData), index);
end;

function TCefListValueRef.GetList(index: Integer): ICefListValue;
begin
  Result := UnWrap(PCefListValue(FData).get_list(PCefListValue(FData), index));
end;

function TCefListValueRef.GetSize: NativeUInt;
begin
  Result := PCefListValue(FData).get_size(PCefListValue(FData));
end;

function TCefListValueRef.GetString(index: Integer): ustring;
begin
  Result := CefStringFreeAndGet(PCefListValue(FData).get_string(PCefListValue(FData), index));
end;

function TCefListValueRef.GetType(index: Integer): TCefValueType;
begin
  Result := PCefListValue(FData).get_type(PCefListValue(FData), index);
end;

function TCefListValueRef.GetValue(index: Integer): ICefValue;
begin
  Result := TCefValueRef.UnWrap(PCefListValue(FData).get_value(PCefListValue(FData), index));
end;

function TCefListValueRef.IsEqual(const that: ICefListValue): Boolean;
begin
  Result := PCefListValue(FData).is_equal(PCefListValue(FData), CefGetData(that)) <> 0;
end;

function TCefListValueRef.IsOwned: Boolean;
begin
  Result := PCefListValue(FData).is_owned(PCefListValue(FData)) <> 0;
end;

function TCefListValueRef.IsReadOnly: Boolean;
begin
  Result := PCefListValue(FData).is_read_only(PCefListValue(FData)) <> 0;
end;

function TCefListValueRef.IsSame(const that: ICefListValue): Boolean;
begin
  Result := PCefListValue(FData).is_same(PCefListValue(FData), CefGetData(that)) <> 0;
end;

function TCefListValueRef.IsValid: Boolean;
begin
  Result := PCefListValue(FData).is_valid(PCefListValue(FData)) <> 0;
end;

function TCefListValueRef.Remove(index: Integer): Boolean;
begin
  Result := PCefListValue(FData).remove(PCefListValue(FData), index) <> 0;
end;

function TCefListValueRef.SetBinary(index: Integer;
  const value: ICefBinaryValue): Boolean;
begin
  Result := PCefListValue(FData).set_binary(PCefListValue(FData), index, CefGetData(value)) <> 0;
end;

function TCefListValueRef.SetBool(index: Integer; value: Boolean): Boolean;
begin
  Result := PCefListValue(FData).set_bool(PCefListValue(FData), index, Ord(value)) <> 0;
end;

function TCefListValueRef.SetDictionary(index: Integer;
  const value: ICefDictionaryValue): Boolean;
begin
  Result := PCefListValue(FData).set_dictionary(PCefListValue(FData), index, CefGetData(value)) <> 0;
end;

function TCefListValueRef.SetDouble(index: Integer; value: Double): Boolean;
begin
  Result := PCefListValue(FData).set_double(PCefListValue(FData), index, value) <> 0;
end;

function TCefListValueRef.SetInt(index, value: Integer): Boolean;
begin
  Result := PCefListValue(FData).set_int(PCefListValue(FData), index, value) <> 0;
end;

function TCefListValueRef.SetList(index: Integer;
  const value: ICefListValue): Boolean;
begin
  Result := PCefListValue(FData).set_list(PCefListValue(FData), index, CefGetData(value)) <> 0;
end;

function TCefListValueRef.SetNull(index: Integer): Boolean;
begin
  Result := PCefListValue(FData).set_null(PCefListValue(FData), index) <> 0;
end;

function TCefListValueRef.SetSize(size: NativeUInt): Boolean;
begin
  Result := PCefListValue(FData).set_size(PCefListValue(FData), size) <> 0;
end;

function TCefListValueRef.SetString(index: Integer;
  const value: ustring): Boolean;
var
  v: TCefString;
begin
  v := CefString(value);
  Result := PCefListValue(FData).set_string(PCefListValue(FData), index, @v) <> 0;
end;

function TCefListValueRef.SetValue(index: Integer;
  const value: ICefValue): Boolean;
begin
  Result := PCefListValue(FData).set_value(PCefListValue(FData), index, CefGetData(value)) <> 0;
end;

class function TCefListValueRef.UnWrap(data: Pointer): ICefListValue;
begin
  if data <> nil then
    Result := Create(data) as ICefListValue else
    Result := nil;
end;

{ TCefBinaryValueRef }

function TCefBinaryValueRef.Copy: ICefBinaryValue;
begin
  Result := UnWrap(PCefBinaryValue(FData).copy(PCefBinaryValue(FData)));
end;

function TCefBinaryValueRef.GetData(buffer: Pointer; bufferSize,
  dataOffset: NativeUInt): NativeUInt;
begin
  Result := PCefBinaryValue(FData).get_data(PCefBinaryValue(FData), buffer, bufferSize, dataOffset);
end;

function TCefBinaryValueRef.GetSize: NativeUInt;
begin
  Result := PCefBinaryValue(FData).get_size(PCefBinaryValue(FData));
end;

function TCefBinaryValueRef.IsEqual(const that: ICefBinaryValue): Boolean;
begin
  Result := PCefBinaryValue(FData).is_equal(PCefBinaryValue(FData), CefGetData(that)) <> 0;
end;

function TCefBinaryValueRef.IsOwned: Boolean;
begin
  Result := PCefBinaryValue(FData).is_owned(PCefBinaryValue(FData)) <> 0;
end;

function TCefBinaryValueRef.IsSame(const that: ICefBinaryValue): Boolean;
begin
  Result := PCefBinaryValue(FData).is_same(PCefBinaryValue(FData), CefGetData(that)) <> 0;
end;

function TCefBinaryValueRef.IsValid: Boolean;
begin
  Result := PCefBinaryValue(FData).is_valid(PCefBinaryValue(FData)) <> 0;
end;

class function TCefBinaryValueRef.New(const data: Pointer; dataSize: NativeUInt): ICefBinaryValue;
begin
  Result := UnWrap(cef_binary_value_create(data, dataSize));
end;

class function TCefBinaryValueRef.UnWrap(data: Pointer): ICefBinaryValue;
begin
  if data <> nil then
    Result := Create(data) as ICefBinaryValue else
    Result := nil;
end;

{ TCefDictionaryValueRef }

function TCefDictionaryValueRef.Clear: Boolean;
begin
  Result := PCefDictionaryValue(FData).clear(PCefDictionaryValue(FData)) <> 0;
end;

function TCefDictionaryValueRef.Copy(
  excludeEmptyChildren: Boolean): ICefDictionaryValue;
begin
  Result := UnWrap(PCefDictionaryValue(FData).copy(PCefDictionaryValue(FData), Ord(excludeEmptyChildren)));
end;

function TCefDictionaryValueRef.GetBinary(const key: ustring): ICefBinaryValue;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := TCefBinaryValueRef.UnWrap(PCefDictionaryValue(FData).get_binary(PCefDictionaryValue(FData), @k));
end;

function TCefDictionaryValueRef.GetBool(const key: ustring): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).get_bool(PCefDictionaryValue(FData), @k) <> 0;
end;

function TCefDictionaryValueRef.GetDictionary(
  const key: ustring): ICefDictionaryValue;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := UnWrap(PCefDictionaryValue(FData).get_dictionary(PCefDictionaryValue(FData), @k));
end;

function TCefDictionaryValueRef.GetDouble(const key: ustring): Double;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).get_double(PCefDictionaryValue(FData), @k);
end;

function TCefDictionaryValueRef.GetInt(const key: ustring): Integer;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).get_int(PCefDictionaryValue(FData), @k);
end;

function TCefDictionaryValueRef.GetKeys(const keys: TStrings): Boolean;
var
  list: TCefStringList;
  i: Integer;
  str: TCefString;
begin
  list := cef_string_list_alloc;
  try
    Result := PCefDictionaryValue(FData).get_keys(PCefDictionaryValue(FData), list) <> 0;
    FillChar(str, SizeOf(str), 0);
    for i := 0 to cef_string_list_size(list) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(list, i, @str);
      keys.Add(CefStringClearAndGet(str));
    end;
  finally
    cef_string_list_free(list);
  end;
end;

function TCefDictionaryValueRef.GetList(const key: ustring): ICefListValue;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := TCefListValueRef.UnWrap(PCefDictionaryValue(FData).get_list(PCefDictionaryValue(FData), @k));
end;

function TCefDictionaryValueRef.GetSize: NativeUInt;
begin
  Result := PCefDictionaryValue(FData).get_size(PCefDictionaryValue(FData));
end;

function TCefDictionaryValueRef.GetString(const key: ustring): ustring;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := CefStringFreeAndGet(PCefDictionaryValue(FData).get_string(PCefDictionaryValue(FData), @k));
end;

function TCefDictionaryValueRef.GetType(const key: ustring): TCefValueType;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).get_type(PCefDictionaryValue(FData), @k);
end;

function TCefDictionaryValueRef.GetValue(const key: ustring): ICefValue;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := TCefValueRef.UnWrap(PCefDictionaryValue(FData).get_value(PCefDictionaryValue(FData), @k));
end;

function TCefDictionaryValueRef.HasKey(const key: ustring): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).has_key(PCefDictionaryValue(FData), @k) <> 0;
end;

function TCefDictionaryValueRef.IsEqual(
  const that: ICefDictionaryValue): Boolean;
begin
  Result := PCefDictionaryValue(FData).is_equal(PCefDictionaryValue(FData), CefGetData(that)) <> 0;
end;

function TCefDictionaryValueRef.isOwned: Boolean;
begin
  Result := PCefDictionaryValue(FData).is_owned(PCefDictionaryValue(FData)) <> 0;
end;

function TCefDictionaryValueRef.IsReadOnly: Boolean;
begin
  Result := PCefDictionaryValue(FData).is_read_only(PCefDictionaryValue(FData)) <> 0;
end;

function TCefDictionaryValueRef.IsSame(
  const that: ICefDictionaryValue): Boolean;
begin
  Result := PCefDictionaryValue(FData).is_same(PCefDictionaryValue(FData), CefGetData(that)) <> 0;
end;

function TCefDictionaryValueRef.IsValid: Boolean;
begin
  Result := PCefDictionaryValue(FData).is_valid(PCefDictionaryValue(FData)) <> 0;
end;

class function TCefDictionaryValueRef.New: ICefDictionaryValue;
begin
  Result := UnWrap(cef_dictionary_value_create);
end;

function TCefDictionaryValueRef.Remove(const key: ustring): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).remove(PCefDictionaryValue(FData), @k) <> 0;
end;

function TCefDictionaryValueRef.SetBinary(const key: ustring;
  const value: ICefBinaryValue): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).set_binary(PCefDictionaryValue(FData), @k, CefGetData(value)) <> 0;
end;

function TCefDictionaryValueRef.SetBool(const key: ustring;
  value: Boolean): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).set_bool(PCefDictionaryValue(FData), @k, Ord(value)) <> 0;
end;

function TCefDictionaryValueRef.SetDictionary(const key: ustring;
  const value: ICefDictionaryValue): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).set_dictionary(PCefDictionaryValue(FData), @k, CefGetData(value)) <> 0;
end;

function TCefDictionaryValueRef.SetDouble(const key: ustring;
  value: Double): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).set_double(PCefDictionaryValue(FData), @k, value) <> 0;
end;

function TCefDictionaryValueRef.SetInt(const key: ustring;
  value: Integer): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).set_int(PCefDictionaryValue(FData), @k, value) <> 0;
end;

function TCefDictionaryValueRef.SetList(const key: ustring;
  const value: ICefListValue): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).set_list(PCefDictionaryValue(FData), @k, CefGetData(value)) <> 0;
end;

function TCefDictionaryValueRef.SetNull(const key: ustring): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).set_null(PCefDictionaryValue(FData), @k) <> 0;
end;

function TCefDictionaryValueRef.SetString(const key, value: ustring): Boolean;
var
  k, v: TCefString;
begin
  k := CefString(key);
  v := CefString(value);
  Result := PCefDictionaryValue(FData).set_string(PCefDictionaryValue(FData), @k, @v) <> 0;
end;

function TCefDictionaryValueRef.SetValue(const key: ustring;
  const value: ICefValue): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).set_value(PCefDictionaryValue(FData), @k, CefGetData(value)) <> 0;
end;

class function TCefDictionaryValueRef.UnWrap(
  data: Pointer): ICefDictionaryValue;
begin
  if data <> nil then
    Result := Create(data) as ICefDictionaryValue else
    Result := nil;
end;

{ TCefBrowserProcessHandlerOwn }

constructor TCefBrowserProcessHandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefBrowserProcessHandler));
  with PCefBrowserProcessHandler(FData)^ do
  begin
    on_context_initialized := cef_browser_process_handler_on_context_initialized;
    on_before_child_process_launch := cef_browser_process_handler_on_before_child_process_launch;
    on_render_process_thread_created := cef_browser_process_handler_on_render_process_thread_created;
    get_print_handler := nil; // linux
  end;
end;

procedure TCefBrowserProcessHandlerOwn.OnBeforeChildProcessLaunch(
  const commandLine: ICefCommandLine);
begin

end;

procedure TCefBrowserProcessHandlerOwn.OnContextInitialized;
begin

end;

procedure TCefBrowserProcessHandlerOwn.OnRenderProcessThreadCreated(
  const extraInfo: ICefListValue);
begin

end;

{ TCefRenderProcessHandlerOwn }

constructor TCefRenderProcessHandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefRenderProcessHandler));
  with PCefRenderProcessHandler(FData)^ do
  begin
    on_render_thread_created := cef_render_process_handler_on_render_thread_created;
    on_web_kit_initialized := cef_render_process_handler_on_web_kit_initialized;
    on_browser_created := cef_render_process_handler_on_browser_created;
    on_browser_destroyed := cef_render_process_handler_on_browser_destroyed;
    get_load_handler := cef_render_process_handler_get_load_handler;
    on_before_navigation := cef_render_process_handler_on_before_navigation;
    on_context_created := cef_render_process_handler_on_context_created;
    on_context_released := cef_render_process_handler_on_context_released;
    on_uncaught_exception := cef_render_process_handler_on_uncaught_exception;
    on_focused_node_changed := cef_render_process_handler_on_focused_node_changed;
    on_process_message_received := cef_render_process_handler_on_process_message_received;
  end;
end;

function TCefRenderProcessHandlerOwn.GetLoadHandler: PCefLoadHandler;
begin
  Result := nil;
end;

function TCefRenderProcessHandlerOwn.OnBeforeNavigation(
  const browser: ICefBrowser; const frame: ICefFrame;
  const request: ICefRequest; navigationType: TCefNavigationType;
  isRedirect: Boolean): Boolean;
begin
  Result := False;
end;

procedure TCefRenderProcessHandlerOwn.OnBrowserCreated(
  const browser: ICefBrowser);
begin

end;

procedure TCefRenderProcessHandlerOwn.OnBrowserDestroyed(
  const browser: ICefBrowser);
begin

end;

procedure TCefRenderProcessHandlerOwn.OnContextCreated(
  const browser: ICefBrowser; const frame: ICefFrame;
  const context: ICefv8Context);
begin

end;

procedure TCefRenderProcessHandlerOwn.OnContextReleased(
  const browser: ICefBrowser; const frame: ICefFrame;
  const context: ICefv8Context);
begin

end;

procedure TCefRenderProcessHandlerOwn.OnFocusedNodeChanged(
  const browser: ICefBrowser; const frame: ICefFrame; const node: ICefDomNode);
begin

end;

function TCefRenderProcessHandlerOwn.OnProcessMessageReceived(
  const browser: ICefBrowser; sourceProcess: TCefProcessId;
  const message: ICefProcessMessage): Boolean;
begin
  Result := False;
end;

procedure TCefRenderProcessHandlerOwn.OnRenderThreadCreated(const extraInfo: ICefListValue);
begin

end;

procedure TCefRenderProcessHandlerOwn.OnUncaughtException(
  const browser: ICefBrowser; const frame: ICefFrame;
  const context: ICefv8Context; const exception: ICefV8Exception;
  const stackTrace: ICefV8StackTrace);
begin

end;

procedure TCefRenderProcessHandlerOwn.OnWebKitInitialized;
begin

end;

{ TCefResourceHandlerOwn }

procedure TCefResourceHandlerOwn.Cancel;
begin

end;

function TCefResourceHandlerOwn.CanGetCookie(const cookie: PCefCookie): Boolean;
begin
  Result := False;
end;

function TCefResourceHandlerOwn.CanSetCookie(const cookie: PCefCookie): Boolean;
begin
  Result := False;
end;

constructor TCefResourceHandlerOwn.Create(const browser: ICefBrowser;
  const frame: ICefFrame; const schemeName: ustring;
  const request: ICefRequest);
begin
  inherited CreateData(SizeOf(TCefResourceHandler));
  with PCefResourceHandler(FData)^ do
  begin
    process_request := cef_resource_handler_process_request;
    get_response_headers := cef_resource_handler_get_response_headers;
    read_response := cef_resource_handler_read_response;
    can_get_cookie := cef_resource_handler_can_get_cookie;
    can_set_cookie := cef_resource_handler_can_set_cookie;
    cancel:= cef_resource_handler_cancel;
  end;
end;

procedure TCefResourceHandlerOwn.GetResponseHeaders(
  const response: ICefResponse; out responseLength: Int64;
  out redirectUrl: ustring);
begin

end;

function TCefResourceHandlerOwn.ProcessRequest(const request: ICefRequest;
  const callback: ICefCallback): Boolean;
begin
  Result := False;
end;

function TCefResourceHandlerOwn.ReadResponse(const dataOut: Pointer;
  bytesToRead: Integer; var bytesRead: Integer;
  const callback: ICefCallback): Boolean;
begin
  Result := False;
end;

{ TCefSchemeHandlerFactoryOwn }

constructor TCefSchemeHandlerFactoryOwn.Create(
  const AClass: TCefResourceHandlerClass);
begin
  inherited CreateData(SizeOf(TCefSchemeHandlerFactory));
  FClass := AClass;
  with PCefSchemeHandlerFactory(FData)^ do
    create := cef_scheme_handler_factory_create;
end;

function TCefSchemeHandlerFactoryOwn.New(const browser: ICefBrowser;
  const frame: ICefFrame; const schemeName: ustring;
  const request: ICefRequest): ICefResourceHandler;
begin
  Result := FClass.Create(browser, frame, schemeName, request);
end;

{ TCefCallbackRef }

procedure TCefCallbackRef.Cancel;
begin
  PCefCallback(FData)^.cancel(PCefCallback(FData));
end;

procedure TCefCallbackRef.Cont;
begin
  PCefCallback(FData)^.cont(PCefCallback(FData));
end;

class function TCefCallbackRef.UnWrap(data: Pointer): ICefCallback;
begin
  if data <> nil then
    Result := Create(data) as ICefCallback else
    Result := nil;
end;


{ TCefUrlrequestClientOwn }

constructor TCefUrlrequestClientOwn.Create;
begin
  inherited CreateData(SizeOf(TCefUrlrequestClient));
  with PCefUrlrequestClient(FData)^ do
  begin
    on_request_complete := cef_url_request_client_on_request_complete;
    on_upload_progress := cef_url_request_client_on_upload_progress;
    on_download_progress := cef_url_request_client_on_download_progress;
    on_download_data := cef_url_request_client_on_download_data;
    get_auth_credentials := cef_url_request_client_get_auth_credentials;
  end;
end;

procedure TCefUrlrequestClientOwn.OnDownloadData(const request: ICefUrlRequest;
  data: Pointer; dataLength: NativeUInt);
begin

end;

procedure TCefUrlrequestClientOwn.OnDownloadProgress(
  const request: ICefUrlRequest; current, total: Int64);
begin

end;

function TCefUrlrequestClientOwn.OnGetAuthCredentials(isProxy: Boolean;
  const host: ustring; port: Integer; const realm, scheme: ustring;
  const callback: ICefAuthCallback): Boolean;
begin
  Result := False;
end;

procedure TCefUrlrequestClientOwn.OnRequestComplete(
  const request: ICefUrlRequest);
begin

end;

procedure TCefUrlrequestClientOwn.OnUploadProgress(
  const request: ICefUrlRequest; current, total: Int64);
begin

end;

{ TCefUrlRequestRef }

procedure TCefUrlRequestRef.Cancel;
begin
  PCefUrlRequest(FData).cancel(PCefUrlRequest(FData));
end;

class function TCefUrlRequestRef.New(const request: ICefRequest; const client: ICefUrlRequestClient;
  const requestContext: ICefRequestContext): ICefUrlRequest;
begin
  Result := UnWrap(cef_urlrequest_create(CefGetData(request), CefGetData(client), CefGetData(requestContext)));
end;

function TCefUrlRequestRef.GetRequest: ICefRequest;
begin
  Result := TCefRequestRef.UnWrap(PCefUrlRequest(FData).get_request(PCefUrlRequest(FData)));
end;

function TCefUrlRequestRef.GetRequestError: Integer;
begin
  Result := PCefUrlRequest(FData).get_request_error(PCefUrlRequest(FData));
end;

function TCefUrlRequestRef.GetRequestStatus: TCefUrlRequestStatus;
begin
  Result := PCefUrlRequest(FData).get_request_status(PCefUrlRequest(FData));
end;

function TCefUrlRequestRef.GetResponse: ICefResponse;
begin
  Result := TCefResponseRef.UnWrap(PCefUrlRequest(FData).get_response(PCefUrlRequest(FData)));
end;

class function TCefUrlRequestRef.UnWrap(data: Pointer): ICefUrlRequest;
begin
  if data <> nil then
    Result := Create(data) as ICefUrlRequest else
    Result := nil;
end;


{ TCefWebPluginInfoVisitorOwn }

constructor TCefWebPluginInfoVisitorOwn.Create;
begin
  inherited CreateData(SizeOf(TCefWebPluginInfoVisitor));
  PCefWebPluginInfoVisitor(FData).visit := cef_web_plugin_info_visitor_visit;
end;

function TCefWebPluginInfoVisitorOwn.Visit(const info: ICefWebPluginInfo; count,
  total: Integer): Boolean;
begin
  Result := False;
end;

{ TCefFastWebPluginInfoVisitor }

constructor TCefFastWebPluginInfoVisitor.Create(
  const proc: TCefWebPluginInfoVisitorProc);
begin
  inherited Create;
  FProc := proc;
end;

function TCefFastWebPluginInfoVisitor.Visit(const info: ICefWebPluginInfo;
  count, total: Integer): Boolean;
begin
  Result := FProc(info, count, total);
end;

{ TCefRequestCallbackRef }

procedure TCefRequestCallbackRef.Cancel;
begin
  PCefRequestCallback(FData).cancel(FData);
end;

procedure TCefRequestCallbackRef.Cont(allow: Boolean);
begin
  PCefRequestCallback(FData).cont(FData, Ord(allow));
end;

class function TCefRequestCallbackRef.UnWrap(data: Pointer): ICefRequestCallback;
begin
  if data <> nil then
    Result := Create(data) as ICefRequestCallback else
    Result := nil;
end;

{ TCefV8StackFrameRef }

function TCefV8StackFrameRef.GetColumn: Integer;
begin
  Result := PCefV8StackFrame(FData).get_column(FData);
end;

function TCefV8StackFrameRef.GetFunctionName: ustring;
begin
  Result := CefStringFreeAndGet(PCefV8StackFrame(FData).get_function_name(FData));
end;

function TCefV8StackFrameRef.GetLineNumber: Integer;
begin
  Result := PCefV8StackFrame(FData).get_line_number(FData);
end;

function TCefV8StackFrameRef.GetScriptName: ustring;
begin
  Result := CefStringFreeAndGet(PCefV8StackFrame(FData).get_script_name(FData));
end;

function TCefV8StackFrameRef.GetScriptNameOrSourceUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefV8StackFrame(FData).get_script_name_or_source_url(FData));
end;

function TCefV8StackFrameRef.IsConstructor: Boolean;
begin
  Result := PCefV8StackFrame(FData).is_constructor(FData) <> 0;
end;

function TCefV8StackFrameRef.IsEval: Boolean;
begin
  Result := PCefV8StackFrame(FData).is_eval(FData) <> 0;
end;

function TCefV8StackFrameRef.IsValid: Boolean;
begin
  Result := PCefV8StackFrame(FData).is_valid(FData) <> 0;
end;

class function TCefV8StackFrameRef.UnWrap(data: Pointer): ICefV8StackFrame;
begin
  if data <> nil then
    Result := Create(data) as ICefV8StackFrame else
    Result := nil;
end;

{ TCefV8StackTraceRef }

class function TCefV8StackTraceRef.Current(frameLimit: Integer): ICefV8StackTrace;
begin
  Result := UnWrap(cef_v8stack_trace_get_current(frameLimit));
end;

function TCefV8StackTraceRef.GetFrame(index: Integer): ICefV8StackFrame;
begin
  Result := TCefV8StackFrameRef.UnWrap(PCefV8StackTrace(FData).get_frame(FData, index));
end;

function TCefV8StackTraceRef.GetFrameCount: Integer;
begin
  Result := PCefV8StackTrace(FData).get_frame_count(FData);
end;

function TCefV8StackTraceRef.IsValid: Boolean;
begin
  Result := PCefV8StackTrace(FData).is_valid(FData) <> 0;
end;

class function TCefV8StackTraceRef.UnWrap(data: Pointer): ICefV8StackTrace;
begin
  if data <> nil then
    Result := Create(data) as ICefV8StackTrace else
    Result := nil;
end;

{ TCefWebPluginUnstableCallbackOwn }

constructor TCefWebPluginUnstableCallbackOwn.Create;
begin
  inherited CreateData(SizeOf(TCefWebPluginUnstableCallback));
  PCefWebPluginUnstableCallback(FData).is_unstable := cef_web_plugin_unstable_callback_is_unstable;
end;

procedure TCefWebPluginUnstableCallbackOwn.IsUnstable(const path: ustring;
  unstable: Boolean);
begin

end;

{ TCefFastWebPluginUnstableCallback }

constructor TCefFastWebPluginUnstableCallback.Create(
  const callback: TCefWebPluginIsUnstableProc);
begin
  FCallback := callback;
end;

procedure TCefFastWebPluginUnstableCallback.IsUnstable(const path: ustring;
  unstable: Boolean);
begin
  FCallback(path, unstable);
end;

{ TCefRunFileDialogCallbackOwn }

constructor TCefRunFileDialogCallbackOwn.Create;
begin
  inherited CreateData(SizeOf(TCefRunFileDialogCallback));
  with PCefRunFileDialogCallback(FData)^ do
    on_file_dialog_dismissed := cef_run_file_dialog_callback_on_file_dialog_dismissed;
end;

procedure TCefRunFileDialogCallbackOwn.OnFileDialogDismissed(
  selectedAcceptFilter: Integer; filePaths: TStrings);
begin

end;

{ TCefFastRunFileDialogCallback }

procedure TCefFastRunFileDialogCallback.OnFileDialogDismissed(
  selectedAcceptFilter: Integer; filePaths: TStrings);
begin
  FCallback(selectedAcceptFilter, filePaths);
end;

constructor TCefFastRunFileDialogCallback.Create(
  callback: TCefRunFileDialogCallbackProc);
begin
  inherited Create;
  FCallback := callback;
end;

{ TCefTaskRef }

procedure TCefTaskRef.Execute;
begin
  PCefTask(FData).execute(FData);
end;

class function TCefTaskRef.UnWrap(data: Pointer): ICefTask;
begin
  if data <> nil then
    Result := Create(data) as ICefTask else
    Result := nil;
end;

{ TCefTaskRunnerRef }

function TCefTaskRunnerRef.BelongsToCurrentThread: Boolean;
begin
  Result := PCefTaskRunner(FData).belongs_to_current_thread(FData) <> 0;
end;

function TCefTaskRunnerRef.BelongsToThread(threadId: TCefThreadId): Boolean;
begin
  Result := PCefTaskRunner(FData).belongs_to_thread(FData, threadId) <> 0;
end;

class function TCefTaskRunnerRef.GetForCurrentThread: ICefTaskRunner;
begin
  Result := UnWrap(cef_task_runner_get_for_current_thread());
end;

class function TCefTaskRunnerRef.GetForThread(threadId: TCefThreadId): ICefTaskRunner;
begin
  Result := UnWrap(cef_task_runner_get_for_thread(threadId));
end;

function TCefTaskRunnerRef.IsSame(const that: ICefTaskRunner): Boolean;
begin
  Result := PCefTaskRunner(FData).is_same(FData, CefGetData(that)) <> 0;
end;

function TCefTaskRunnerRef.PostDelayedTask(const task: ICefTask;
  delayMs: Int64): Boolean;
begin
  Result := PCefTaskRunner(FData).post_delayed_task(FData, CefGetData(task), delayMs) <> 0;
end;

function TCefTaskRunnerRef.PostTask(const task: ICefTask): Boolean;
begin
  Result := PCefTaskRunner(FData).post_task(FData, CefGetData(task)) <> 0;
end;

class function TCefTaskRunnerRef.UnWrap(data: Pointer): ICefTaskRunner;
begin
  if data <> nil then
    Result := Create(data) as ICefTaskRunner else
    Result := nil;
end;

{ TCefEndTracingCallbackOwn }

constructor TCefEndTracingCallbackOwn.Create;
begin
  inherited CreateData(SizeOf(TCefEndTracingCallback));
  with PCefEndTracingCallback(FData)^ do
    on_end_tracing_complete := cef_end_tracing_callback_on_end_tracing_complete;
end;

procedure TCefEndTracingCallbackOwn.OnEndTracingComplete(
  const tracingFile: ustring);
begin

end;

{ TCefGetGeolocationCallbackOwn }

constructor TCefGetGeolocationCallbackOwn.Create;
begin
  inherited CreateData(SizeOf(TCefGetGeolocationCallback));
  with PCefGetGeolocationCallback(FData)^ do
    on_location_update := cef_get_geolocation_callback_on_location_update;
end;

procedure TCefGetGeolocationCallbackOwn.OnLocationUpdate(
  const position: PCefGeoposition);
begin

end;

{ TCefFastGetGeolocationCallback }

constructor TCefFastGetGeolocationCallback.Create(
  const callback: TOnLocationUpdate);
begin
  inherited Create;
  FCallback := callback;
end;

procedure TCefFastGetGeolocationCallback.OnLocationUpdate(
  const position: PCefGeoposition);
begin
  FCallback(position);
end;

{ TCefFileDialogCallbackRef }

procedure TCefFileDialogCallbackRef.Cancel;
begin
  PCefFileDialogCallback(FData).cancel(FData);
end;

procedure TCefFileDialogCallbackRef.Cont(selectedAcceptFilter: Integer; filePaths: TStrings);
var
  list: TCefStringList;
  i: Integer;
  str: TCefString;
begin
  list := cef_string_list_alloc;
  try
    for i := 0 to filePaths.Count - 1 do
    begin
      str := CefString(filePaths[i]);
      cef_string_list_append(list, @str);
    end;
    PCefFileDialogCallback(FData).cont(FData, selectedAcceptFilter, list);
  finally
    cef_string_list_free(list);
  end;
end;

class function TCefFileDialogCallbackRef.UnWrap(
  data: Pointer): ICefFileDialogCallback;
begin
  if data <> nil then
    Result := Create(data) as ICefFileDialogCallback else
    Result := nil;
end;

{ TCefDialogHandlerOwn }

constructor TCefDialogHandlerOwn.Create;
begin
  CreateData(SizeOf(TCefDialogHandler));
  with PCefDialogHandler(FData)^ do
    on_file_dialog := cef_dialog_handler_on_file_dialog;
end;

function TCefDialogHandlerOwn.OnFileDialog(const browser: ICefBrowser;
  mode: TCefFileDialogMode; const title, defaultFilePath: ustring;
  acceptFilters: TStrings; selectedAcceptFilter: Integer;
  const callback: ICefFileDialogCallback): Boolean;
begin
  Result := False;
end;

{ TCefRenderHandlerOwn }

constructor TCefRenderHandlerOwn.Create;
begin
  CreateData(SizeOf(TCefRenderHandler), False);
  with PCefRenderHandler(FData)^ do
  begin
    get_root_screen_rect := cef_render_handler_get_root_screen_rect;
    get_view_rect := cef_render_handler_get_view_rect;
    get_screen_point := cef_render_handler_get_screen_point;
    on_popup_show := cef_render_handler_on_popup_show;
    on_popup_size := cef_render_handler_on_popup_size;
    on_paint := cef_render_handler_on_paint;
    on_cursor_change := cef_render_handler_on_cursor_change;
    start_dragging := cef_render_handler_start_dragging;
    update_drag_cursor := cef_render_handler_update_drag_cursor;
    on_scroll_offset_changed := cef_render_handler_on_scroll_offset_changed;
  end;
end;

function TCefRenderHandlerOwn.GetRootScreenRect(const browser: ICefBrowser;
  rect: PCefRect): Boolean;
begin
  Result := False;
end;

function TCefRenderHandlerOwn.GetScreenInfo(const browser: ICefBrowser;
  screenInfo: PCefScreenInfo): Boolean;
begin
  Result := False;
end;

function TCefRenderHandlerOwn.GetScreenPoint(const browser: ICefBrowser; viewX,
  viewY: Integer; screenX, screenY: PInteger): Boolean;
begin
  Result := False;
end;

function TCefRenderHandlerOwn.GetViewRect(const browser: ICefBrowser;
  rect: PCefRect): Boolean;
begin
  Result := False;
end;

procedure TCefRenderHandlerOwn.OnCursorChange(const browser: ICefBrowser;
  cursor: TCefCursorHandle; CursorType: TCefCursorType;
  const customCursorInfo: PCefCursorInfo);
begin

end;

procedure TCefRenderHandlerOwn.OnPaint(const browser: ICefBrowser;
  kind: TCefPaintElementType; dirtyRectsCount: NativeUInt;
  const dirtyRects: PCefRectArray; const buffer: Pointer; width, height: Integer);
begin

end;

procedure TCefRenderHandlerOwn.OnPopupShow(const browser: ICefBrowser;
  show: Boolean);
begin

end;

procedure TCefRenderHandlerOwn.OnPopupSize(const browser: ICefBrowser;
  const rect: PCefRect);
begin

end;

procedure TCefRenderHandlerOwn.OnScrollOffsetChanged(
  const browser: ICefBrowser; x, y: Double);
begin

end;

function TCefRenderHandlerOwn.OnStartDragging(const browser: ICefBrowser;
  const dragData: ICefDragData; allowedOps: TCefDragOperations; x,
  y: Integer): Boolean;
begin
  Result := False;
end;

procedure TCefRenderHandlerOwn.OnUpdateDragCursor(const browser: ICefBrowser;
  operation: TCefDragOperation);
begin

end;

{ TCefCompletionHandlerOwn }

constructor TCefCompletionCallbackOwn.Create;
begin
  inherited CreateData(SizeOf(TCefCompletionCallback));
  with PCefCompletionCallback(FData)^ do
    on_complete := cef_completion_callback_on_complete;
end;

procedure TCefCompletionCallbackOwn.OnComplete;
begin

end;

{ TCefFastCompletionHandler }

constructor TCefFastCompletionCallback.Create(
  const proc: TCefCompletionCallbackProc);
begin
   inherited Create;
   FProc := proc;
end;

procedure TCefFastCompletionCallback.OnComplete;
begin
  FProc();
end;

{ TCefDragDataRef }

procedure TCefDragDataRef.AddFile(const path, displayName: ustring);
var
  p, d: TCefString;
begin
  p := CefString(path);
  d := CefString(displayName);
  PCefDragData(FData).add_file(FData, @p, @d);
end;

function TCefDragDataRef.Clone: ICefDragData;
begin
  Result := UnWrap(PCefDragData(FData).clone(FData));
end;

function TCefDragDataRef.GetFileContents(
  const writer: ICefStreamWriter): NativeUInt;
begin
  Result := PCefDragData(FData).get_file_contents(FData, CefGetData(writer))
end;

function TCefDragDataRef.GetFileName: ustring;
begin
  Result := CefStringFreeAndGet(PCefDragData(FData).get_file_name(FData));
end;

function TCefDragDataRef.GetFileNames(names: TStrings): Integer;
var
  list: TCefStringList;
  i: Integer;
  str: TCefString;
begin
  list := cef_string_list_alloc;
  try
    Result := PCefDragData(FData).get_file_names(FData, list);
    for i := 0 to cef_string_list_size(list) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(list, i, @str);
      names.Add(CefStringClearAndGet(str));
    end;
  finally
    cef_string_list_free(list);
  end;
end;

function TCefDragDataRef.GetFragmentBaseUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefDragData(FData).get_fragment_base_url(FData));
end;

function TCefDragDataRef.GetFragmentHtml: ustring;
begin
  Result := CefStringFreeAndGet(PCefDragData(FData).get_fragment_html(FData));
end;

function TCefDragDataRef.GetFragmentText: ustring;
begin
  Result := CefStringFreeAndGet(PCefDragData(FData).get_fragment_text(FData));
end;

function TCefDragDataRef.GetLinkMetadata: ustring;
begin
  Result := CefStringFreeAndGet(PCefDragData(FData).get_link_metadata(FData));
end;

function TCefDragDataRef.GetLinkTitle: ustring;
begin
  Result := CefStringFreeAndGet(PCefDragData(FData).get_link_title(FData));
end;

function TCefDragDataRef.GetLinkUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefDragData(FData).get_link_url(FData));
end;

function TCefDragDataRef.IsFile: Boolean;
begin
  Result := PCefDragData(FData).is_file(FData) <> 0;
end;

function TCefDragDataRef.IsFragment: Boolean;
begin
  Result := PCefDragData(FData).is_fragment(FData) <> 0;
end;

function TCefDragDataRef.IsLink: Boolean;
begin
  Result := PCefDragData(FData).is_link(FData) <> 0;
end;

function TCefDragDataRef.IsReadOnly: Boolean;
begin
  Result := PCefDragData(FData).is_read_only(FData) <> 0;
end;

class function TCefDragDataRef.New: ICefDragData;
begin
  Result := UnWrap(cef_drag_data_create());
end;

procedure TCefDragDataRef.ResetFileContents;
begin
  PCefDragData(FData).reset_file_contents(FData);
end;

procedure TCefDragDataRef.SetFragmentBaseUrl(const baseUrl: ustring);
var
  s: TCefString;
begin
  s := CefString(baseUrl);
  PCefDragData(FData).set_fragment_base_url(FData, @s);
end;

procedure TCefDragDataRef.SetFragmentHtml(const html: ustring);
var
  s: TCefString;
begin
  s := CefString(html);
  PCefDragData(FData).set_fragment_html(FData, @s);
end;

procedure TCefDragDataRef.SetFragmentText(const text: ustring);
var
  s: TCefString;
begin
  s := CefString(text);
  PCefDragData(FData).set_fragment_text(FData, @s);
end;

procedure TCefDragDataRef.SetLinkMetadata(const data: ustring);
var
  s: TCefString;
begin
  s := CefString(data);
  PCefDragData(FData).set_link_metadata(FData, @s);
end;

procedure TCefDragDataRef.SetLinkTitle(const title: ustring);
var
  s: TCefString;
begin
  s := CefString(title);
  PCefDragData(FData).set_link_title(FData, @s);
end;

procedure TCefDragDataRef.SetLinkUrl(const url: ustring);
var
  s: TCefString;
begin
  s := CefString(url);
  PCefDragData(FData).set_link_url(FData, @s);
end;

class function TCefDragDataRef.UnWrap(data: Pointer): ICefDragData;
begin
  if data <> nil then
    Result := Create(data) as ICefDragData else
    Result := nil;
end;

{ TCefDragHandlerOwn }

constructor TCefDragHandlerOwn.Create;
begin
  CreateData(SizeOf(TCefDragHandler), False);
  with PCefDragHandler(FData)^ do
  begin
    on_drag_enter := cef_drag_handler_on_drag_enter;
{$ifdef Win32}
    on_draggable_regions_changed := cef_drag_handler_on_draggable_regions_changed;
{$endif}
  end;
end;

function TCefDragHandlerOwn.OnDragEnter(const browser: ICefBrowser;
  const dragData: ICefDragData; mask: TCefDragOperations): Boolean;
begin
  Result := False;
end;

procedure TCefDragHandlerOwn.OnDraggableRegionsChanged(
  const browser: ICefBrowser; regionsCount: NativeUInt;
  regions: PCefDraggableRegionArray);
begin

end;

{ TCefRequestContextRef }

function TCefRequestContextRef.ClearSchemeHandlerFactories: Boolean;
begin
  Result := PCefRequestContext(FData).clear_scheme_handler_factories(FData) <> 0;
end;

function TCefRequestContextRef.GetCachePath: ustring;
begin
  Result := CefStringFreeAndGet(PCefRequestContext(FData).get_cache_path(FData));
end;

function TCefRequestContextRef.GetDefaultCookieManager(
  const callback: ICefCompletionCallback): ICefCookieManager;
begin
  Result := TCefCookieManagerRef.UnWrap(
    PCefRequestContext(FData).get_default_cookie_manager(
      FData, CefGetData(callback)));
end;

function TCefRequestContextRef.GetDefaultCookieManagerProc(
  const callback: TCefCompletionCallbackProc): ICefCookieManager;
begin
  Result := GetDefaultCookieManager(TCefFastCompletionCallback.Create(callback));
end;

function TCefRequestContextRef.GetHandler: ICefRequestContextHandler;
begin
  Result := TCefRequestContextHandlerRef.UnWrap(PCefRequestContext(FData).get_handler(FData));
end;

class function TCefRequestContextRef.Global: ICefRequestContext;
begin
  Result:= UnWrap(cef_request_context_get_global_context());
end;

function TCefRequestContextRef.IsGlobal: Boolean;
begin
  Result:= PCefRequestContext(FData).is_global(FData) <> 0;
end;

function TCefRequestContextRef.IsSame(const other: ICefRequestContext): Boolean;
begin
  Result:= PCefRequestContext(FData).is_same(FData, CefGetData(other)) <> 0;
end;

function TCefRequestContextRef.IsSharingWith(
  const other: ICefRequestContext): Boolean;
begin
  Result:= PCefRequestContext(FData).is_sharing_with(FData, CefGetData(other)) <> 0;
end;

class function TCefRequestContextRef.New(
  const settings: PCefRequestContextSettings;
  const handler: ICefRequestContextHandler): ICefRequestContext;
begin
  Result := UnWrap(cef_request_context_create_context(settings, CefGetData(handler)));
end;

procedure TCefRequestContextRef.PurgePluginListCache(reloadPages: Boolean);
begin
  PCefRequestContext(FData).purge_plugin_list_cache(FData, Ord(reloadPages));
end;

function TCefRequestContextRef.RegisterSchemeHandlerFactory(const schemeName,
  domainName: ustring; const factory: ICefSchemeHandlerFactory): Boolean;
var
  s, d: TCefString;
begin
  s := CefString(schemeName);
  d := CefString(domainName);
  Result := PCefRequestContext(FData).register_scheme_handler_factory(FData, @s, @d, CefGetData(factory)) <> 0;
end;

class function TCefRequestContextRef.Shared(const other: ICefRequestContext;
  const handler: ICefRequestContextHandler): ICefRequestContext;
begin
  Result := UnWrap(create_context_shared(CefGetData(other), CefGetData(handler)));
end;

class function TCefRequestContextRef.UnWrap(data: Pointer): ICefRequestContext;
begin
  if data <> nil then
    Result := Create(data) as ICefRequestContext else
    Result := nil;
end;

{ TCefRequestContextHandlerRef }

function TCefRequestContextHandlerRef.GetCookieManager: ICefCookieManager;
begin
  Result := TCefCookieManagerRef.UnWrap(PCefRequestContextHandler(FData).get_cookie_manager(FData));
end;

function TCefRequestContextHandlerRef.OnBeforePluginLoad(const mimeType,
  pluginUrl, topOriginUrl: ustring; const pluginInfo: ICefWebPluginInfo;
  pluginPolicy: PCefPluginPolicy): Boolean;
var
  mt, pu, ou: TCefString;
begin
  mt := CefString(mimeType);
  pu:= CefString(pluginUrl);
  ou := CefString(topOriginUrl);
  Result := PCefRequestContextHandler(FData).on_before_plugin_load(
    FData, @mt, @pu, @ou, CefGetData(pluginInfo), pluginPolicy) <> 0;
end;

class function TCefRequestContextHandlerRef.UnWrap(
  data: Pointer): ICefRequestContextHandler;
begin
  if data <> nil then
    Result := Create(data) as ICefRequestContextHandler else
    Result := nil;
end;

{ TCefRequestContextHandlerOwn }

constructor TCefRequestContextHandlerOwn.Create;
begin
  CreateData(SizeOf(TCefRequestContextHandler), False);
  with PCefRequestContextHandler(FData)^ do
  begin
    get_cookie_manager := cef_request_context_handler_get_cookie_manager;
    on_before_plugin_load := cef_request_context_handler_on_before_plugin_load;
  end;
end;

function TCefRequestContextHandlerOwn.GetCookieManager: ICefCookieManager;
begin
  Result:= nil;
end;

function TCefRequestContextHandlerOwn.OnBeforePluginLoad(const mimeType,
  pluginUrl, topOriginUrl: ustring; const pluginInfo: ICefWebPluginInfo;
  pluginPolicy: PCefPluginPolicy): Boolean;
begin
  Result := False;
end;

{ TCefFastRequestContextHandler }

constructor TCefFastRequestContextHandler.Create(
  const proc: TCefRequestContextHandlerProc);
begin
  FProc := proc;
  inherited Create;
end;

function TCefFastRequestContextHandler.GetCookieManager: ICefCookieManager;
begin
  Result := FProc();
end;

{ TCefPrintSettingsRef }

function TCefPrintSettingsRef.Copy: ICefPrintSettings;
begin
  Result := UnWrap(PCefPrintSettings(FData).copy(FData))
end;

function TCefPrintSettingsRef.GetColorModel: TCefColorModel;
begin
  Result := PCefPrintSettings(FData).get_color_model(FData);
end;

function TCefPrintSettingsRef.GetCopies: Integer;
begin
  Result := PCefPrintSettings(FData).get_copies(FData);
end;

function TCefPrintSettingsRef.GetDeviceName: ustring;
begin
  Result := CefStringFreeAndGet(PCefPrintSettings(FData).get_device_name(FData));
end;

function TCefPrintSettingsRef.GetDpi: Integer;
begin
  Result := PCefPrintSettings(FData).get_dpi(FData);
end;

function TCefPrintSettingsRef.GetDuplexMode: TCefDuplexMode;
begin
  Result := PCefPrintSettings(FData).get_duplex_mode(FData);
end;

procedure TCefPrintSettingsRef.GetPageRanges(
  out ranges: TCefPageRangeArray);
var
  len: NativeUInt;
begin
  len := GetPageRangesCount;
  SetLength(ranges, len);
  if len > 0 then
    PCefPrintSettings(FData).get_page_ranges(FData, @len, @ranges[0]);
end;

function TCefPrintSettingsRef.GetPageRangesCount: NativeUInt;
begin
  Result := PCefPrintSettings(FData).get_page_ranges_count(FData);
end;

function TCefPrintSettingsRef.IsLandscape: Boolean;
begin
  Result := PCefPrintSettings(FData).is_landscape(FData) <> 0;
end;

function TCefPrintSettingsRef.IsReadOnly: Boolean;
begin
  Result := PCefPrintSettings(FData).is_read_only(FData) <> 0;
end;

function TCefPrintSettingsRef.IsSelectionOnly: Boolean;
begin
  Result := PCefPrintSettings(FData).is_selection_only(FData) <> 0;
end;

function TCefPrintSettingsRef.IsValid: Boolean;
begin
  Result := PCefPrintSettings(FData).is_valid(FData) <> 0;
end;

class function TCefPrintSettingsRef.New: ICefPrintSettings;
begin
  Result := UnWrap(cef_print_settings_create);
end;

procedure TCefPrintSettingsRef.SetCollate(collate: Boolean);
begin
  PCefPrintSettings(FData).set_collate(FData, Ord(collate));
end;

procedure TCefPrintSettingsRef.SetColorModel(model: TCefColorModel);
begin
  PCefPrintSettings(FData).set_color_model(FData, model);
end;

procedure TCefPrintSettingsRef.SetCopies(copies: Integer);
begin
  PCefPrintSettings(FData).set_copies(FData, copies);
end;

procedure TCefPrintSettingsRef.SetDeviceName(const name: ustring);
var
  s: TCefString;
begin
  s := CefString(name);
  PCefPrintSettings(FData).set_device_name(FData, @s);
end;

procedure TCefPrintSettingsRef.SetDpi(dpi: Integer);
begin
  PCefPrintSettings(FData).set_dpi(FData, dpi);
end;

procedure TCefPrintSettingsRef.SetDuplexMode(mode: TCefDuplexMode);
begin
  PCefPrintSettings(FData).set_duplex_mode(FData, mode);
end;

procedure TCefPrintSettingsRef.SetOrientation(landscape: Boolean);
begin
  PCefPrintSettings(FData).set_orientation(FData, Ord(landscape));
end;

procedure TCefPrintSettingsRef.SetPageRanges(
  const ranges: TCefPageRangeArray);
var
  len: NativeUInt;
begin
  len := Length(ranges);
  if len > 0 then
    PCefPrintSettings(FData).set_page_ranges(FData, len, @ranges[0]) else
    PCefPrintSettings(FData).set_page_ranges(FData, 0, nil);
end;

procedure TCefPrintSettingsRef.SetPrinterPrintableArea(
  const physicalSizeDeviceUnits: PCefSize;
  const printableAreaDeviceUnits: PCefRect; landscapeNeedsFlip: Boolean);
begin
  PCefPrintSettings(FData).set_printer_printable_area(FData, physicalSizeDeviceUnits,
    printableAreaDeviceUnits, Ord(landscapeNeedsFlip));
end;

procedure TCefPrintSettingsRef.SetSelectionOnly(selectionOnly: Boolean);
begin
  PCefPrintSettings(FData).set_selection_only(FData, Ord(selectionOnly));
end;

class function TCefPrintSettingsRef.UnWrap(
  data: Pointer): ICefPrintSettings;
begin
  if data <> nil then
    Result := Create(data) as ICefPrintSettings else
    Result := nil;
end;

function TCefPrintSettingsRef.WillCollate: Boolean;
begin
  Result := PCefPrintSettings(FData).will_collate(FData) <> 0;
end;

{ TCefStreamWriterRef }

class function TCefStreamWriterRef.CreateForFile(
  const fileName: ustring): ICefStreamWriter;
var
  s: TCefString;
begin
  s := CefString(fileName);
  Result := UnWrap(cef_stream_writer_create_for_file(@s));
end;

class function TCefStreamWriterRef.CreateForHandler(
  const handler: ICefWriteHandler): ICefStreamWriter;
begin
  Result := UnWrap(cef_stream_writer_create_for_handler(CefGetData(handler)));
end;

function TCefStreamWriterRef.Flush: Integer;
begin
  Result := PCefStreamWriter(FData).flush(FData);
end;

function TCefStreamWriterRef.MayBlock: Boolean;
begin
  Result := PCefStreamWriter(FData).may_block(FData) <> 0;
end;

function TCefStreamWriterRef.Seek(offset: Int64; whence: Integer): Integer;
begin
  Result := PCefStreamWriter(FData).seek(FData, offset, whence);
end;

function TCefStreamWriterRef.Tell: Int64;
begin
  Result := PCefStreamWriter(FData).tell(FData);
end;

class function TCefStreamWriterRef.UnWrap(data: Pointer): ICefStreamWriter;
begin
  if data <> nil then
    Result := Create(data) as ICefStreamWriter else
    Result := nil;
end;

function TCefStreamWriterRef.write(const ptr: Pointer; size,
  n: NativeUInt): NativeUInt;
begin
  Result := PCefStreamWriter(FData).write(FData, ptr, size, n);
end;

{ TCefWriteHandlerOwn }

constructor TCefWriteHandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefWriteHandler));
  with PCefWriteHandler(FData)^ do
  begin
    write := cef_write_handler_write;
    seek := cef_write_handler_seek;
    tell := cef_write_handler_tell;
    flush := cef_write_handler_flush;
    may_block := cef_write_handler_may_block;
  end;
end;

function TCefWriteHandlerOwn.Flush: Integer;
begin
  Result := 0;
end;

function TCefWriteHandlerOwn.MayBlock: Boolean;
begin
  Result := False;
end;

function TCefWriteHandlerOwn.Seek(offset: Int64; whence: Integer): Integer;
begin
  Result := 0;
end;

function TCefWriteHandlerOwn.Tell: Int64;
begin
  Result := 0;
end;

function TCefWriteHandlerOwn.Write(const ptr: Pointer; size,
  n: NativeUInt): NativeUInt;
begin
  Result := 0;
end;

{ TCefNavigationEntryRef }

function TCefNavigationEntryRef.IsValid: Boolean;
begin
  Result := PCefNavigationEntry(FData).is_valid(FData) <> 0;
end;

function TCefNavigationEntryRef.GetUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefNavigationEntry(FData).get_url(FData));
end;

function TCefNavigationEntryRef.GetDisplayUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefNavigationEntry(FData).get_display_url(FData));
end;

function TCefNavigationEntryRef.GetOriginalUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefNavigationEntry(FData).get_original_url(FData));
end;

function TCefNavigationEntryRef.GetTitle: ustring;
begin
  Result := CefStringFreeAndGet(PCefNavigationEntry(FData).get_title(FData));
end;

function TCefNavigationEntryRef.GetTransitionType: TCefTransitionType;
begin
  Result := PCefNavigationEntry(FData).get_transition_type(FData);
end;

function TCefNavigationEntryRef.HasPostData: Boolean;
begin
  Result := PCefNavigationEntry(FData).has_post_data(FData) <> 0;
end;

function TCefNavigationEntryRef.GetCompletionTime: TDateTime;
begin
  Result := CefTimeToDateTime(PCefNavigationEntry(FData).get_completion_time(FData));
end;

function TCefNavigationEntryRef.GetHttpStatusCode: Integer;
begin
  Result := PCefNavigationEntry(FData).get_http_status_code(FData);
end;

class function TCefNavigationEntryRef.UnWrap(data: Pointer): ICefNavigationEntry;
begin
  if data <> nil then
    Result := Create(data) as ICefNavigationEntry else
    Result := nil;
end;

{ TCefNavigationEntryVisitorOwn }

constructor TCefNavigationEntryVisitorOwn.Create;
begin
  CreateData(SizeOf(TCefNavigationEntryVisitor), False);
  with PCefNavigationEntryVisitor(FData)^ do
    visit := cef_navigation_entry_visitor_visit;
end;

function TCefNavigationEntryVisitorOwn.Visit(const entry: ICefNavigationEntry;
  current: Boolean; index, total: Integer): Boolean;
begin
  Result:= False;
end;

{ TCefFastNavigationEntryVisitor }

constructor TCefFastNavigationEntryVisitor.Create(
  const proc: TCefNavigationEntryVisitorProc);
begin
  FVisitor := proc;
  inherited Create;
end;

function TCefFastNavigationEntryVisitor.Visit(const entry: ICefNavigationEntry;
  current: Boolean; index, total: Integer): Boolean;
begin
  Result := FVisitor(entry, current, index, total);
end;

{ TCefFindHandlerOwn }

constructor TCefFindHandlerOwn.Create;
begin
  CreateData(SizeOf(TCefFindHandler), False);
  with PCefFindHandler(FData)^ do
    on_find_result := cef_find_handler_on_find_result;
end;

{ TCefSetCookieCallbackOwn }

constructor TCefSetCookieCallbackOwn.Create;
begin
  inherited CreateData(SizeOf(TCefSetCookieCallback));
  with PCefSetCookieCallback(FData)^ do
    on_complete := cef_set_cookie_callback_on_complete;
end;

{ TCefFastSetCookieCallback }

constructor TCefFastSetCookieCallback.Create(
  const callback: TCefSetCookieCallbackProc);
begin
  inherited Create;
  FCallback := callback;
end;

procedure TCefFastSetCookieCallback.OnComplete(success: Boolean);
begin
  FCallback(success);
end;

{ TCefDeleteCookiesCallbackOwn }

constructor TCefDeleteCookiesCallbackOwn.Create;
begin
  inherited CreateData(SizeOf(TCefDeleteCookiesCallback));
  with PCefDeleteCookiesCallback(FData)^ do
    on_complete := cef_delete_cookie_callback_on_complete;
end;

{ TCefFastDeleteCookiesCallback }

constructor TCefFastDeleteCookiesCallback.Create(
  const callback: TCefDeleteCookiesCallbackProc);
begin
  inherited Create;
  FCallback := callback;
end;

procedure TCefFastDeleteCookiesCallback.OnComplete(numDeleted: Integer);
begin
  FCallback(numDeleted)
end;

{ TCefValueRef }

function TCefValueRef.Copy: ICefValue;
begin
  Result := UnWrap(PCefValue(FData).copy(FData));
end;

function TCefValueRef.GetBinary: ICefBinaryValue;
begin
  Result := TCefBinaryValueRef.UnWrap(PCefValue(FData).get_binary(FData));
end;

function TCefValueRef.GetBool: Boolean;
begin
  Result := PCefValue(FData).get_bool(FData) <> 0;
end;

function TCefValueRef.GetDictionary: ICefDictionaryValue;
begin
  Result := TCefDictionaryValueRef.UnWrap(PCefValue(FData).get_dictionary(FData));
end;

function TCefValueRef.GetDouble: Double;
begin
  Result := PCefValue(FData).get_double(FData);
end;

function TCefValueRef.GetInt: Integer;
begin
  Result := PCefValue(FData).get_int(FData);
end;

function TCefValueRef.GetList: ICefListValue;
begin
  Result := TCefListValueRef.UnWrap(PCefValue(FData).get_list(FData));
end;

function TCefValueRef.GetString: ustring;
begin
  Result := CefStringFreeAndGet(PCefValue(FData).get_string(FData));
end;

function TCefValueRef.GetType: TCefValueType;
begin
  Result := PCefValue(FData).get_type(FData);
end;

function TCefValueRef.IsEqual(const that: ICefValue): Boolean;
begin
  Result := PCefValue(FData).is_equal(FData, CefGetData(that)) <> 0;
end;

function TCefValueRef.IsOwned: Boolean;
begin
  Result := PCefValue(FData).is_owned(FData) <> 0;
end;

function TCefValueRef.IsReadOnly: Boolean;
begin
  Result := PCefValue(FData).is_read_only(FData) <> 0;
end;

function TCefValueRef.IsSame(const that: ICefValue): Boolean;
begin
  Result := PCefValue(FData).is_same(FData, CefGetData(that)) <> 0;
end;

function TCefValueRef.IsValid: Boolean;
begin
  Result := PCefValue(FData).is_valid(FData) <> 0;
end;

class function TCefValueRef.New: ICefValue;
begin
  Result := UnWrap(cef_value_create());
end;

function TCefValueRef.SetBinary(const value: ICefBinaryValue): Boolean;
begin
  Result := PCefValue(FData).set_binary(FData, CefGetData(value)) <> 0;
end;

function TCefValueRef.SetBool(value: Integer): Boolean;
begin
  Result := PCefValue(FData).set_bool(FData, value) <> 0;
end;

function TCefValueRef.SetDictionary(const value: ICefDictionaryValue): Boolean;
begin
  Result := PCefValue(FData).set_dictionary(FData, CefGetData(value)) <> 0;
end;

function TCefValueRef.SetDouble(value: Double): Boolean;
begin
  Result := PCefValue(FData).set_double(FData, value) <> 0;
end;

function TCefValueRef.SetInt(value: Integer): Boolean;
begin
  Result := PCefValue(FData).set_int(FData, value) <> 0;
end;

function TCefValueRef.SetList(const value: ICefListValue): Boolean;
begin
  Result := PCefValue(FData).set_list(FData, CefGetData(value)) <> 0;
end;

function TCefValueRef.SetNull: Boolean;
begin
  Result := PCefValue(FData).set_null(FData) <> 0;
end;

function TCefValueRef.SetString(const value: ustring): Boolean;
var
 s: TCefString;
begin
  s := CefString(value);
  Result := PCefValue(FData).set_string(FData, @s) <> 0;
end;

class function TCefValueRef.UnWrap(data: Pointer): ICefValue;
begin
  if data <> nil then
    Result := Create(data) as ICefValue else
    Result := nil;
end;

{ TCefSslCertPrincipalRef }

function TCefSslCertPrincipalRef.GetCommonName: ustring;
begin
  Result := CefStringFreeAndGet(PCefSslCertPrincipal(FData).get_common_name(FData));
end;

function TCefSslCertPrincipalRef.GetCountryName: ustring;
begin
  Result := CefStringFreeAndGet(PCefSslCertPrincipal(FData).get_country_name(FData));
end;

function TCefSslCertPrincipalRef.GetDisplayName: ustring;
begin
  Result := CefStringFreeAndGet(PCefSslCertPrincipal(FData).get_display_name(FData));
end;

procedure TCefSslCertPrincipalRef.GetDomainComponents(components: TStrings);
var
  list: TCefStringList;
  i: Integer;
  str: TCefString;
begin
  list := cef_string_list_alloc;
  try
    PCefSslCertPrincipal(FData).get_domain_components(FData, list);
    for i := 0 to cef_string_list_size(list) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(list, i, @str);
      components.Add(CefStringClearAndGet(str));
    end;
  finally
    cef_string_list_free(list);
  end;
end;

function TCefSslCertPrincipalRef.GetLocalityName: ustring;
begin
  Result := CefStringFreeAndGet(PCefSslCertPrincipal(FData).get_locality_name(FData));
end;

procedure TCefSslCertPrincipalRef.GetOrganizationNames(names: TStrings);
var
  list: TCefStringList;
  i: Integer;
  str: TCefString;
begin
  list := cef_string_list_alloc;
  try
    PCefSslCertPrincipal(FData).get_organization_names(FData, list);
    for i := 0 to cef_string_list_size(list) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(list, i, @str);
      names.Add(CefStringClearAndGet(str));
    end;
  finally
    cef_string_list_free(list);
  end;
end;

procedure TCefSslCertPrincipalRef.GetOrganizationUnitNames(names: TStrings);
var
  list: TCefStringList;
  i: Integer;
  str: TCefString;
begin
  list := cef_string_list_alloc;
  try
    PCefSslCertPrincipal(FData).get_organization_unit_names(FData, list);
    for i := 0 to cef_string_list_size(list) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(list, i, @str);
      names.Add(CefStringClearAndGet(str));
    end;
  finally
    cef_string_list_free(list);
  end;
end;

function TCefSslCertPrincipalRef.GetStateOrProvinceName: ustring;
begin
  Result := CefStringFreeAndGet(PCefSslCertPrincipal(FData).get_state_or_province_name(FData));
end;

procedure TCefSslCertPrincipalRef.GetStreetAddresses(addresses: TStrings);
var
  list: TCefStringList;
  i: Integer;
  str: TCefString;
begin
  list := cef_string_list_alloc;
  try
    PCefSslCertPrincipal(FData).get_street_addresses(FData, list);
    for i := 0 to cef_string_list_size(list) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(list, i, @str);
      addresses.Add(CefStringClearAndGet(str));
    end;
  finally
    cef_string_list_free(list);
  end;
end;

class function TCefSslCertPrincipalRef.UnWrap(
  data: Pointer): ICefSslCertPrincipal;
begin
  if data <> nil then
    Result := Create(data) as ICefSslCertPrincipal else
    Result := nil;
end;

{ TCefSslInfoRef }

function TCefSslInfoRef.GetDerEncoded: ICefBinaryValue;
begin
  Result := TCefBinaryValueRef.UnWrap(PCefSslInfo(FData).get_derencoded(FData));
end;

function TCefSslInfoRef.GetIssuer: ICefSslCertPrincipal;
begin
  Result := TCefSslCertPrincipalRef.UnWrap(PCefSslInfo(FData).get_issuer(FData));
end;

function TCefSslInfoRef.GetPemEncoded: ICefBinaryValue;
begin
  Result := TCefBinaryValueRef.UnWrap(PCefSslInfo(FData).get_pemencoded(FData));
end;

function TCefSslInfoRef.GetSerialNumber: ICefBinaryValue;
begin
  Result := TCefBinaryValueRef.UnWrap(PCefSslInfo(FData).get_serial_number(FData));
end;

function TCefSslInfoRef.GetSubject: ICefSslCertPrincipal;
begin
  Result := TCefSslCertPrincipalRef.UnWrap(PCefSslInfo(FData).get_subject(FData));
end;

function TCefSslInfoRef.GetValidExpiry: TCefTime;
begin
  Result := PCefSslInfo(FData).get_valid_expiry(FData);
end;

function TCefSslInfoRef.GetValidStart: TCefTime;
begin
  Result := PCefSslInfo(FData).get_valid_start(FData);
end;

class function TCefSslInfoRef.UnWrap(data: Pointer): ICefSslInfo;
begin
  if data <> nil then
    Result := Create(data) as ICefSslInfo else
    Result := nil;
end;

{ TCefPdfPrintCallbackOwn }

constructor TCefPdfPrintCallbackOwn.Create;
begin
  CreateData(SizeOf(TCefPdfPrintCallback), False);
  with PCefPdfPrintCallback(FData)^ do
    on_pdf_print_finished := cef_pdf_print_callback_on_pdf_print_finished;
end;

{ TCefFastPdfPrintCallback }

constructor TCefFastPdfPrintCallback.Create(
  const proc: TOnPdfPrintFinishedProc);
begin
  FProc := proc;
  inherited Create;
end;

procedure TCefFastPdfPrintCallback.OnPdfPrintFinished(const path: ustring;
  ok: Boolean);
begin
  FProc(path, ok);
end;

{ TCefRunContextMenuCallbackRef }

procedure TCefRunContextMenuCallbackRef.Cancel;
begin
  PCefRunContextMenuCallback(FData).cancel(FData);
end;

procedure TCefRunContextMenuCallbackRef.Cont(commandId: Integer;
  eventFlags: TCefEventFlags);
begin
  PCefRunContextMenuCallback(FData).cont(FData, commandId, eventFlags);
end;

class function TCefRunContextMenuCallbackRef.UnWrap(
  data: Pointer): ICefRunContextMenuCallback;
begin
  if data <> nil then
    Result := Create(data) as ICefRunContextMenuCallback else
    Result := nil;
end;

{ TCefResourceBundleRef }

function TCefResourceBundleRef.GetDataResource(resourceId: Integer;
  out data: Pointer; out dataSize: NativeUInt): Boolean;
begin
  Result := PCefResourceBundle(FData).get_data_resource(FData, resourceId,
    data, dataSize) <> 0;
end;

function TCefResourceBundleRef.GetDataResourceForScale(resourceId: Integer;
  scaleFactor: TCefScaleFactor; out data: Pointer;
  out dataSize: NativeUInt): Boolean;
begin
  Result := PCefResourceBundle(FData).get_data_resource_for_scale(FData,
    resourceId, scaleFactor, data, dataSize) <> 0;
end;

function TCefResourceBundleRef.GetLocalizedString(stringId: Integer): ustring;
begin
  Result := CefStringFreeAndGet(PCefResourceBundle(FData).get_localized_string(FData, stringId));
end;

class function TCefResourceBundleRef.Global: ICefResourceBundle;
begin
  Result := UnWrap(cef_resource_bundle_get_global());
end;

class function TCefResourceBundleRef.UnWrap(data: Pointer): ICefResourceBundle;
begin
  if data <> nil then
    Result := Create(data) as ICefResourceBundle else
    Result := nil;
end;

initialization
  IsMultiThread := True;

finalization
  CefShutDown;

end.

