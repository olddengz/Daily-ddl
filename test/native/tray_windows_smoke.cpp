#include "../../windows/runner/tray_manager.h"
#include <iostream>

int main() {
  WNDCLASSW wc{};
  wc.lpfnWndProc = DefWindowProcW;
  wc.hInstance = GetModuleHandleW(nullptr);
  wc.lpszClassName = L"DailyDDLTraySmoke";
  if (!RegisterClassW(&wc)) return 1;
  HWND window = CreateWindowW(wc.lpszClassName, L"Daily DDL notification test",
      WS_OVERLAPPEDWINDOW, 0, 0, 400, 300, nullptr, nullptr, wc.hInstance, nullptr);
  if (!window) return 1;
  bool ok;
  {
    TrayManager tray(window, LoadIconW(nullptr, IDI_APPLICATION));
    ok = tray.Recover() && tray.Notify(L"Daily DDL",
        L"Windows notification request test.");
    std::cout << "Windows request accepted=" << ok
              << " state=" << tray.state() << " error=" << tray.error() << '\n';
    // Keep the test window alive briefly to process shell messages; it stays hidden.
    const ULONGLONG end = GetTickCount64() + 1500;
    while (GetTickCount64() < end) {
      MSG message;
      while (PeekMessageW(&message, nullptr, 0, 0, PM_REMOVE)) {
        TranslateMessage(&message);
        DispatchMessageW(&message);
      }
      Sleep(20);
    }
  }
  DestroyWindow(window);
  UnregisterClassW(wc.lpszClassName, wc.hInstance);
  return ok ? 0 : 1;
}
