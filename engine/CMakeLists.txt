add_subdirectory(vn-engine)

add_library(engine INTERFACE)
target_link_libraries(engine INTERFACE VNEngine)
