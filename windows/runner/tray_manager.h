#ifndef RUNNER_TRAY_MANAGER_H_
#define RUNNER_TRAY_MANAGER_H_

#include <windows.h>
#include <shellapi.h>
#include <functional>
#include <string>

// Does not log notification text or task identifiers.
void WriteDesktopLog(const char* event, const char* state, DWORD error,
                     unsigned attempt = 0, unsigned request = 0);

class TrayManager {
 public:
  using ShellCall = std::function<BOOL(DWORD, PNOTIFYICONDATAW)>;
  TrayManager(HWND window, HICON icon,
              ShellCall shell = Shell_NotifyIconW);
  ~TrayManager();
  bool Recover();
  bool Notify(const std::wstring& title, const std::wstring& body);
  void Remove();
  bool ready() const { return state_ == "ready"; }
  const std::string& state() const { return state_; }
  DWORD error() const { return error_; }
  std::function<void()> on_state;

 private:
  bool Call(DWORD operation, NOTIFYICONDATAW& data);
  void SetState(const char* state);
  NOTIFYICONDATAW identity_{};
  ShellCall shell_;
  std::string state_ = "initializing";
  DWORD error_ = ERROR_SUCCESS;
  unsigned request_ = 0;
  bool removed_ = false;
};

#endif  // RUNNER_TRAY_MANAGER_H_
