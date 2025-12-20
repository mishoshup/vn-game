#include <VNEngine/VNEngine.hpp>

int main(int, const char **) {
  VNEngine engine;
  if (!engine.Init("My Visual Novel", 1920, 1080, true))
    return 1;

  engine.LoadScript("assets/scripts/prologue.lua");

  bool running = true;
  Uint64 last = SDL_GetPerformanceCounter();

  while (running) {
    Uint64 now = SDL_GetPerformanceCounter();
    float dt = (now - last) / float(SDL_GetPerformanceFrequency());
    last = now;

    VNEvent event;
    while (engine.PollEvent(event)) {
      if (event.type == VNEvent::Quit) {
        running = false;
        break;
      }
      engine.HandleEvent(event);
    }
    if (!running)
      break;

    engine.Update(dt);
    engine.Draw();
    engine.Present();
  }

  engine.ShutDown();
  return 0;
}
