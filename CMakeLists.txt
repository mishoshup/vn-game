cmake_minimum_required(VERSION 3.24)
project(MyVNGame)

# Engine (builds CerekaGame, CerekaLauncher, and the Cereka library)
add_subdirectory(engine)

# Copy game assets and config to the build directory
add_custom_target(copy_assets ALL
    COMMAND ${CMAKE_COMMAND} -E copy_directory
            ${CMAKE_SOURCE_DIR}/assets
            ${CMAKE_BINARY_DIR}/assets
    COMMAND ${CMAKE_COMMAND} -E copy
            ${CMAKE_SOURCE_DIR}/game.cfg
            ${CMAKE_BINARY_DIR}/game.cfg
    COMMENT "Copying assets and game.cfg"
)
