file(GLOB_RECURSE SRC CONFIGURE_DEPENDS
     "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")
# Define the executable
add_executable(VisualNovel ${SRC})

target_include_directories(VisualNovel
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# Link the vendor library (propagates SDL3 + SDL_image)
target_link_libraries(VisualNovel PRIVATE VNEngine)  
target_include_directories(VisualNovel PRIVATE vn-engine/src)
target_include_directories(VisualNovel PRIVATE vn-engine/include)
target_include_directories(VisualNovel
    PRIVATE vendor/sol2/include
)
