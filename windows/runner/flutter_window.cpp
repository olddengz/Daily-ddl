#include "flutter_window.h"

#include <optional>
#include <flutter/standard_method_codec.h>
#include "resource.h"

#include "flutter/generated_plugin_registrant.h"

namespace {
constexpr UINT_PTR kTrayRecoveryTimer = 71;
flutter::EncodableValue TrayStatus(const TrayManager& tray) {
  return flutter::EncodableValue(flutter::EncodableMap{
      {flutter::EncodableValue("state"), flutter::EncodableValue(tray.state())},
      {flutter::EncodableValue("errorCode"),
       flutter::EncodableValue(static_cast<int64_t>(tray.error()))}});
}
}

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());
  taskbar_created_ = RegisterWindowMessageW(L"TaskbarCreated");
  if (taskbar_created_ == 0) {
    WriteDesktopLog("taskbar_register_failed", "initializing", GetLastError());
  }
  tray_ = std::make_unique<TrayManager>(GetHandle(),
      LoadIcon(GetModuleHandle(nullptr), MAKEINTRESOURCE(IDI_APP_ICON)));
  desktop_channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(), "daily_ddl/desktop", &flutter::StandardMethodCodec::GetInstance());
  desktop_channel_->SetMethodCallHandler([this](const auto& call, auto result) {
    const auto& method = call.method_name();
    if (method == "exit") { result->Success(); PostMessage(GetHandle(), WM_APP + 18, 0, 0); return; }
    if (method == "trayReady") { result->Success(flutter::EncodableValue(tray_->ready())); return; }
    if (method == "getReminderStatus") { result->Success(TrayStatus(*tray_)); return; }
    if (method == "recoverTray") {
      RecoverTray(true);
      result->Success(TrayStatus(*tray_)); return;
    }
    if (method == "notify") {
      const auto* args = std::get_if<flutter::EncodableMap>(call.arguments());
      if (!args) { result->Error("args", "Missing notification data"); return; }
      auto get = [&](const char* key) -> std::string {
        auto it = args->find(flutter::EncodableValue(key));
        if (it == args->end()) return "";
        const auto* value = std::get_if<std::string>(&it->second);
        return value ? *value : "";
      };
      auto wide = [](const std::string& text) {
        int size = MultiByteToWideChar(CP_UTF8, 0, text.data(), static_cast<int>(text.size()), nullptr, 0);
        std::wstring value(size, 0);
        MultiByteToWideChar(CP_UTF8, 0, text.data(), static_cast<int>(text.size()), value.data(), size);
        return value;
      };
      const auto title = wide(get("title")); const auto body = wide(get("body"));
      if (tray_->Notify(title, body)) {
        notification_task_ = get("taskId");
        result->Success();
      } else {
        KeepWindowReachable();
        result->Error("notification_unavailable", "Notification request failed");
      }
      return;
    }
    if (method == "getStartup" || method == "setStartup") {
      HKEY key = nullptr;
      const auto access = method == "getStartup" ? KEY_QUERY_VALUE : KEY_SET_VALUE;
      auto status = RegOpenKeyExW(HKEY_CURRENT_USER, L"Software\\Microsoft\\Windows\\CurrentVersion\\Run", 0, access, &key);
      if (status != ERROR_SUCCESS) { result->Error("startup", "Cannot open startup settings"); return; }
      if (method == "getStartup") {
        status = RegQueryValueExW(key, L"DailyDDL", nullptr, nullptr, nullptr, nullptr);
        RegCloseKey(key); result->Success(flutter::EncodableValue(status == ERROR_SUCCESS)); return;
      }
      const auto* enabled = std::get_if<bool>(call.arguments());
      if (!enabled) { RegCloseKey(key); result->Error("args", "Expected a boolean"); return; }
      if (*enabled) {
        wchar_t path[32768]; GetModuleFileNameW(nullptr, path, 32768);
        std::wstring command = std::wstring(L"\"") + path + L"\"";
        status = RegSetValueExW(key, L"DailyDDL", 0, REG_SZ,
          reinterpret_cast<const BYTE*>(command.c_str()), static_cast<DWORD>((command.size()+1)*sizeof(wchar_t)));
      } else { status = RegDeleteValueW(key, L"DailyDDL"); if (status == ERROR_FILE_NOT_FOUND) status = ERROR_SUCCESS; }
      RegCloseKey(key);
      if (status == ERROR_SUCCESS) result->Success(); else result->Error("startup", "Cannot change startup settings");
      return;
    }
    result->NotImplemented();
  });
  tray_->on_state = [this]() { PublishTrayState(); };
  RecoverTray(true);

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  KillTimer(GetHandle(), kTrayRecoveryTimer);
  if (tray_) {
    tray_->on_state = nullptr;
    tray_.reset();
  }
  desktop_channel_.reset();
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

void FlutterWindow::PublishTrayState() {
  if (desktop_channel_ && tray_) {
    desktop_channel_->InvokeMethod("trayStateChanged",
        std::make_unique<flutter::EncodableValue>(TrayStatus(*tray_)));
  }
  KeepWindowReachable();
}

void FlutterWindow::KeepWindowReachable() {
  if (tray_ && tray_->state() == "unavailable" &&
      !IsWindowVisible(GetHandle())) {
    ShowWindow(GetHandle(), SW_RESTORE);
    WriteDesktopLog("window_restored", tray_->state().c_str(), tray_->error());
  }
}

void FlutterWindow::RecoverTray(bool schedule_retry) {
  if (!tray_) return;
  if (schedule_retry) recovery_attempts_ = 0;
  const bool ready = tray_->Recover();
  KillTimer(GetHandle(), kTrayRecoveryTimer);
  if (!ready && recovery_attempts_ < 3) {
    if (SetTimer(GetHandle(), kTrayRecoveryTimer, 2000, nullptr) == 0) {
      WriteDesktopLog("retry_timer_failed", tray_->state().c_str(), GetLastError());
    }
  }
  KeepWindowReachable();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  if (message == WM_APP + 18) { Destroy(); return 0; }
  if (message == WM_CLOSE && tray_) {
    RecoverTray(true);
    if (tray_->ready()) ShowWindow(hwnd, SW_HIDE);
    else {
      ShowWindow(hwnd, SW_RESTORE);
      PublishTrayState();
    }
    return 0;
  }
  if (taskbar_created_ != 0 && message == taskbar_created_) {
    WriteDesktopLog("taskbar_created", tray_->state().c_str(), 0);
    RecoverTray(true);
    return 0;
  }
  if (message == WM_POWERBROADCAST &&
      (wparam == PBT_APMRESUMEAUTOMATIC || wparam == PBT_APMRESUMESUSPEND)) {
    WriteDesktopLog("system_resume", tray_->state().c_str(), 0);
    RecoverTray(true);
  }
  if (message == WM_TIMER && wparam == kTrayRecoveryTimer) {
    ++recovery_attempts_;
    WriteDesktopLog("recovery_timer", tray_->state().c_str(), tray_->error(),
                    recovery_attempts_);
    RecoverTray(false);
    return 0;
  }
  if (message == WM_APP + 17) {
    if (lparam == WM_LBUTTONDBLCLK || lparam == NIN_BALLOONUSERCLICK) {
      ShowWindow(hwnd, SW_RESTORE); SetForegroundWindow(hwnd);
      if (lparam == NIN_BALLOONUSERCLICK && desktop_channel_) {
        desktop_channel_->InvokeMethod("openTask", notification_task_.empty() ? nullptr :
          std::make_unique<flutter::EncodableValue>(notification_task_));
      }
    } else if (lparam == WM_RBUTTONUP) {
      HMENU menu = CreatePopupMenu();
      AppendMenuW(menu, MF_STRING, 1, L"Open Daily DDL");
      AppendMenuW(menu, MF_STRING, 2, L"Exit");
      POINT point; GetCursorPos(&point); SetForegroundWindow(hwnd);
      const auto selected = TrackPopupMenu(menu, TPM_RETURNCMD | TPM_NONOTIFY, point.x, point.y, 0, hwnd, nullptr);
      DestroyMenu(menu);
      if (selected == 1) { ShowWindow(hwnd, SW_RESTORE); SetForegroundWindow(hwnd); }
      if (selected == 2) { Destroy(); }
    }
    return 0;
  }
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
