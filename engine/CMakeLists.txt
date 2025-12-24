add_subdirectory(cereka)

add_library(engine INTERFACE)
target_link_libraries(engine INTERFACE Cereka)
