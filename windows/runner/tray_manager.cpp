#include "tray_manager.h"

#include <filesystem>
#include <fstream>
#include <iomanip>
#include <sstream>

#ifndef FLUTTER_VERSION
#define FLUTTER_VERSION "test"
#endif

void WriteDesktopLog(const char* event, const char* state, DWORD error,
                     unsigned attempt, unsigned request) {
  // Logging must not prevent window access when the folder is read-only/full.
  {
    std::error_code ec;
    wchar_t executable[32768];
    const DWORD length = GetModuleFileNameW(nullptr, executable, 32768);
    if (length == 0 || length >= 32768) return;
    const auto folder = std::filesystem::path(executable).parent_path() /
                        L"data" / L"logs";
    std::filesystem::create_directories(folder, ec);
    if (ec) return;
    const auto file = folder / L"desktop.log";
    std::ostringstream line;
    SYSTEMTIME now;
    GetSystemTime(&now);
    line << std::setfill('0') << std::setw(4) << now.wYear << '-'
         << std::setw(2) << now.wMonth << '-' << std::setw(2) << now.wDay
         << 'T' << std::setw(2) << now.wHour << ':' << std::setw(2)
         << now.wMinute << ':' << std::setw(2) << now.wSecond << 'Z'
         << " version=" << FLUTTER_VERSION << " event=" << event
         << " state=" << state << " error=" << error
         << " attempt=" << attempt << " request=" << request << '\n';
    const auto text = line.str();
    if (std::filesystem::exists(file, ec) &&
        std::filesystem::file_size(file, ec) + text.size() > 2 * 1024 * 1024) {
      if (ec) return;
      // Current file plus four archives; at most 10 MiB total.
      std::filesystem::remove(folder / L"desktop.4.log", ec);
      if (ec) return;
      for (int index = 3; index >= 0; --index) {
        const auto from = index == 0 ? file :
            folder / (L"desktop." + std::to_wstring(index) + L".log");
        const auto to = folder /
            (L"desktop." + std::to_wstring(index + 1) + L".log");
        if (std::filesystem::exists(from, ec)) {
          std::filesystem::rename(from, to, ec);
          if (ec) return;
        }
        if (ec) return;
      }
    }
    std::ofstream output(file, std::ios::app | std::ios::binary);
    output << text;
  }
}

TrayManager::TrayManager(HWND window, HICON icon, ShellCall shell)
    : shell_(std::move(shell)) {
  identity_.cbSize = sizeof(identity_);
  identity_.hWnd = window;
  identity_.uID = 1;
  identity_.uFlags = NIF_ICON | NIF_MESSAGE | NIF_TIP;
  identity_.uCallbackMessage = WM_APP + 17;
  identity_.hIcon = icon;
  wcscpy_s(identity_.szTip, L"Daily DDL - double click to open");
}

TrayManager::~TrayManager() { Remove(); }

bool TrayManager::Call(DWORD operation, NOTIFYICONDATAW& data) {
  SetLastError(ERROR_SUCCESS);
  if (shell_(operation, &data)) {
    error_ = ERROR_SUCCESS;
    return true;
  }
  error_ = GetLastError();
  // Shell_NotifyIcon is not guaranteed to set a Win32 error code.
  if (error_ == ERROR_SUCCESS) error_ = ERROR_GEN_FAILURE;
  return false;
}

void TrayManager::SetState(const char* state) {
  if (state_ == state) return;
  state_ = state;
  if (on_state) on_state();
}

bool TrayManager::Recover() {
  removed_ = false;
  SetState("recovering");
  auto data = identity_;
  // MODIFY first preserves an existing icon. ADD handles an Explorer restart;
  // a final MODIFY handles the race where ADD finds an already existing icon.
  const bool ok = Call(NIM_MODIFY, data) || Call(NIM_ADD, data) ||
                  Call(NIM_MODIFY, data);
  SetState(ok ? "ready" : "unavailable");
  WriteDesktopLog("tray_recover", state_.c_str(), error_);
  return ok;
}

bool TrayManager::Notify(const std::wstring& title, const std::wstring& body) {
  ++request_;
  // At most two sends. A failed send is followed by one recovery and retry.
  for (unsigned attempt = 1; attempt <= 2; ++attempt) {
    if (!ready() && !Recover()) {
      WriteDesktopLog("notify_unavailable", state_.c_str(), error_, attempt,
                      request_);
      return false;
    }
    auto data = identity_;
    data.uFlags = NIF_INFO;
    data.dwInfoFlags = NIIF_INFO;
    wcsncpy_s(data.szInfoTitle, title.c_str(), _TRUNCATE);
    wcsncpy_s(data.szInfo, body.c_str(), _TRUNCATE);
    const bool accepted = Call(NIM_MODIFY, data);
    WriteDesktopLog("notify_request", state_.c_str(), error_, attempt, request_);
    if (accepted) return true;
    if (attempt == 1 && !Recover()) return false;
  }
  // A notification can fail while the icon still exists. Verify rather than
  // turning the ready state into an outdated failure snapshot.
  const DWORD send_error = error_;
  Recover();
  error_ = send_error;
  return false;
}

void TrayManager::Remove() {
  if (removed_) return;
  removed_ = true;
  auto data = identity_;
  Call(NIM_DELETE, data);
  WriteDesktopLog("tray_remove", state_.c_str(), error_);
}
