#include "Cereka/Cereka.hpp"
#include "Cereka/exceptions.hpp"
#include <iostream>
#include <vector>

using namespace cereka;

int main(int argc,
         char **argv)
{
    CerekaEngine cereka;

    // 1. Initialize the game window
    if (!cereka.InitGame("My VN Game", 1280, 720, true)) {
        throw engine::error("Failed to initialize VNEngine\n");
        return 1;
    }

    // 2. Compile your script
    std::vector<scenario::Instruction> script = scenario::CompileVNScript(
        "assets/scripts/test.crka");
    cereka.LoadCompiledScript(script);

    while (!cereka.IsGameFinished()) {  // bukan while(running)
        CerekaEvent e;
        while (cereka.PollEvent(e)) {
            cereka.HandleEvent(e);
        }
        cereka.Update(1.0f / 60.0f);
        cereka.TickScript();
        cereka.Draw();
        cereka.Present();
    }
    // 4. Shutdown cereka and cleanup
    cereka.ShutDown();

    return 0;
}
