#include "../../windows/runner/tray_manager.h"

#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <iterator>
#include <vector>

namespace {
void Check(bool ok, const char* name) {
  if (!ok) { std::cerr << "FAIL " << name << '\n'; std::exit(1); }
}
void Pass(const char* name) { std::cout << "PASS " << name << '\n'; }

struct FakeShell {
  bool available = true;
  bool exists = false;
  int failed_sends = 0;
  int sends = 0;
  int accepted = 0;
  int adds = 0;
  int deletes = 0;
  BOOL Call(DWORD operation, PNOTIFYICONDATAW data) {
    SetLastError(ERROR_NOT_READY);
    if (operation == NIM_DELETE) { ++deletes; exists = false; return TRUE; }
    if (data->uFlags == NIF_INFO) {
      ++sends;
      if (failed_sends > 0) { --failed_sends; return FALSE; }
      if (!available || !exists) return FALSE;
      ++accepted;
      return TRUE;
    }
    if (operation == NIM_ADD) ++adds;
    if (!available) return FALSE;
    if (operation == NIM_ADD) { exists = true; return TRUE; }
    return exists ? TRUE : FALSE;
  }
  TrayManager Manager() {
    return TrayManager(nullptr, nullptr, [this](DWORD op, PNOTIFYICONDATAW data) {
      return Call(op, data);
    });
  }
};
}

int main() {
  {
    FakeShell shell;
    auto tray = shell.Manager();
    std::vector<std::string> states;
    tray.on_state = [&]() { states.push_back(tray.state()); };
    Check(tray.Recover() && shell.adds == 1, "initial add");
    Check(states == std::vector<std::string>{"recovering", "ready"}, "state push");
    Check(tray.Recover() && shell.adds == 1, "existing icon not re-added");
    shell.exists = false;
    Check(tray.Recover() && shell.adds == 2, "lost icon restored");
    tray.Remove();
    tray.Remove();
    Check(shell.deletes == 1, "remove idempotent");
    Pass("create / state push / existing icon / lost icon / remove");
  }
  {
    int calls = 0;
    TrayManager tray(nullptr, nullptr, [&](DWORD op, PNOTIFYICONDATAW) -> BOOL {
      if (op == NIM_DELETE) return TRUE;
      return ++calls == 3 ? TRUE : FALSE;
    });
    Check(tray.Recover() && calls == 3, "ADD race final MODIFY");
    Pass("ADD failure with existing icon recovers through MODIFY");
  }
  {
    FakeShell shell;
    shell.available = false;
    auto tray = shell.Manager();
    Check(!tray.Recover() && tray.state() == "unavailable", "startup unavailable");
    Check(tray.error() == ERROR_NOT_READY, "Win32 error recorded");
    Check(!tray.Notify(L"PRIVATE_TITLE", L"PRIVATE_BODY") && shell.sends == 0,
          "no send while recovery unavailable");
    shell.available = true;
    Check(tray.Recover() && tray.Notify(L"PRIVATE_TITLE", L"PRIVATE_BODY"),
          "Explorer available later");
    Pass("Explorer unavailable / bounded failure / later recovery");
  }
  {
    FakeShell shell;
    auto tray = shell.Manager();
    tray.Recover();
    shell.failed_sends = 1;
    Check(tray.Notify(L"PRIVATE_TITLE", L"PRIVATE_BODY"), "retry succeeds");
    Check(shell.sends == 2 && shell.accepted == 1, "one retry only");
    Pass("notification fails once / exactly one retry and one acceptance");
  }
  {
    FakeShell shell;
    auto tray = shell.Manager();
    tray.Recover();
    shell.failed_sends = 3;
    Check(!tray.Notify(L"PRIVATE_TITLE", L"PRIVATE_BODY"), "two sends fail");
    Check(shell.sends == 2 && tray.ready(), "bounded sends and actual icon ready");
    Pass("repeated send failure / no infinite retry / icon state verified");
  }
  {
    FakeShell shell;
    auto tray = shell.Manager();
    tray.Recover();
    shell.exists = false;
    Check(tray.Notify(L"PRIVATE_TITLE", L"PRIVATE_BODY"), "loss at send restored");
    Check(shell.sends == 2 && shell.accepted == 1, "no duplicate acceptance");
    Pass("icon lost immediately before send / restored and one accepted request");
  }
  wchar_t path[32768];
  GetModuleFileNameW(nullptr, path, 32768);
  const auto folder = std::filesystem::path(path).parent_path() / L"data" / L"logs";
  const auto log = folder / L"desktop.log";
  {
    std::ifstream input(log);
    const std::string text((std::istreambuf_iterator<char>(input)), {});
    Check(text.find("PRIVATE_") == std::string::npos, "no task content logged");
    Check(text.find("request=") != std::string::npos, "request diagnostic");
    Pass("diagnostics include metadata and exclude title/body");
  }
  // Only files in this dedicated test executable's data/logs are overwritten.
  {
    std::ofstream fill(log, std::ios::binary | std::ios::trunc);
    fill << std::string(2 * 1024 * 1024 - 1, 'x');
  }
  for (int i = 1; i <= 4; ++i) {
    std::ofstream archive(folder / (L"desktop." + std::to_wstring(i) + L".log"));
    archive << "archive" << i;
  }
  WriteDesktopLog("rotation_test", "ready", 0);
  Check(std::filesystem::file_size(log) < 1024, "new log after rotation");
  Check(std::filesystem::file_size(folder / L"desktop.1.log") ==
        2 * 1024 * 1024 - 1, "old file rotated");
  Check(!std::filesystem::exists(folder / L"desktop.5.log"), "five file cap");
  Pass("2MiB log rotation / five file cap");
  // A file at the log directory path simulates a filesystem error without
  // changing user permissions. Rename back afterwards to preserve diagnostics.
  const auto held = folder.parent_path() / L"logs_test_held";
  std::filesystem::rename(folder, held);
  { std::ofstream blocked(folder); blocked << "blocked"; }
  WriteDesktopLog("blocked_test", "unavailable", 31);
  std::filesystem::remove(folder);
  std::filesystem::rename(held, folder);
  Pass("logging failure does not crash application");
  std::cout << "All native tray scenarios passed\n";
}
