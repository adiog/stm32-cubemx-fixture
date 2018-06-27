// This file is a part of stm32-cubemx-fixture project.

#include <cubemx_fixture_main.h>
#include <stm32f1xx_hal.h>
#include <stm32f1xx_hal_def.h>

#ifdef SEMIHOST
extern "C" {
__weak void initialise_monitor_handles(void) {}
}
#else
//#pragma import(__use_no_semihosting)
#endif

int setup()
{
}

int loop()
{
}

int main()
{
#ifdef SEMIHOST
    initialise_monitor_handles();
#endif


    cubemx_fixture_main();

    printf("Hello World\n");
    auto f = fopen("/tmp/semihost.txt", "w");
    fprintf(f, "HelloWorld");
    fclose(f);

    setup();

    while(1)
    {
        loop();
    }
}

