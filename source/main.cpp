// This file is a part of stm32-cubemx-fixture project.

#include <cubemx_fixture_main.h>

int setup()
{
}

int loop()
{
}

int main()
{
    cubemx_fixture_main();

    setup();

    while(1)
    {
        loop();
    }
}

