// This file is a part of stm32-cubemx-fixture project.

#include <cubemx_fixture_main.h>
#include <stm32f1xx_hal.h>
#include <stm32f1xx_hal_def.h>

#ifdef SEMIHOST
extern "C" {
__weak void initialise_monitor_handles(void) {}
}
#endif

int setup()
{
#ifdef SEMIHOST
    printf("Hello World!\n");

    auto f = fopen("/tmp/semihost.txt", "w");
    fprintf(f, "Hello Semihost File\n");
    fclose(f);
#endif
}

int loop()
{
#ifdef SEMIHOST
    static int loopCounter = 0;
    printf("Hello Semihost (%x)!\n", loopCounter);
    loopCounter++;
#endif
}

int main()
{
#ifdef SEMIHOST
    initialise_monitor_handles();
#endif

    cubemx_fixture_main();

    setup();

    while(1)
    {
        loop();
    }
}

