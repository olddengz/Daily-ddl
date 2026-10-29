cmake_minimum_required(VERSION 3.14)
project(daily_ddl_tray_tests LANGUAGES CXX)
add_executable(tray_manager_test tray_manager_test.cpp ../../windows/runner/tray_manager.cpp)
target_compile_features(tray_manager_test PRIVATE cxx_std_17)
target_compile_definitions(tray_manager_test PRIVATE UNICODE _UNICODE NOMINMAX _HAS_EXCEPTIONS=0)
target_compile_options(tray_manager_test PRIVATE /W4 /WX /EHsc)
target_link_libraries(tray_manager_test PRIVATE shell32 user32)

# Explicitly run this optional target for a real Windows shell request.
# It does not assert that Windows displayed a visible notification.
add_executable(tray_windows_smoke tray_windows_smoke.cpp ../../windows/runner/tray_manager.cpp)
target_compile_features(tray_windows_smoke PRIVATE cxx_std_17)
target_compile_definitions(tray_windows_smoke PRIVATE UNICODE _UNICODE NOMINMAX _HAS_EXCEPTIONS=0)
target_compile_options(tray_windows_smoke PRIVATE /W4 /WX /EHsc)
target_link_libraries(tray_windows_smoke PRIVATE shell32 user32)
