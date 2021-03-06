/*
 * Very simple LED blinker for Mulle
 */

extern "C" {

/* CPU specific header */
#include "K60.h"

} /* extern "C" */

int state = 0;

class Led
{
    private:

    public:
    Led()
    {
        state |= 1;
        setup();
    }

    Led(const Led& other)
    {
    }

    ~Led()
    {
    }

    Led& operator= (const Led& other)
    {
        return *this;
    }

    void setup()
    {
        state |= 2;
        /* Setup PORTA */

        SIM_SCGC5   |= SIM_SCGC5_PORTC_MASK;    /* Enable PORTC clock gate */
        PORTC_PCR13 |= 0x00100;                 /* Setup PTC13 as GPIO */
        PORTC_PCR14 |= 0x00100;                 /* Setup PTC14 as GPIO */
        PORTC_PCR15 |= 0x00100;                 /* Setup PTC15 as GPIO */
        GPIOC_PDDR  |= 0x0E000;                 /* Setup PTA14-PTA17 as outputs */
    }

    void toggle()
    {
        GPIOC_PTOR  = 0x0E000;
    }
};

Led* pled;
Led gled;

extern "C" {

/* Our timer ISR, which will toggle the LEDs */
void _isr_lpt(void)
{
    LPTMR0_CSR |= 0x80;                     /* Clear Time Compare Flag */
    pled->toggle();
}

/* C entry point (after startup code has executed) */
int main(void)
{
    //~ Led my_led;
    //~ led = &my_led;
    //~ state = 0;
    pled = &gled;

    /* Remove pin function NMI from PTA4 */

    SIM_SCGC5  |= SIM_SCGC5_PORTA_MASK;     /* Enable PORTA clock gate */
    PORTA_PCR4  = 0x0000;

    /* Setup Low Power Timer (LPT) */

    SIM_SCGC5 |= SIM_SCGC5_LPTIMER_MASK;    /* Enable LPT clock gate */
    LPTMR0_CNR = 0;
    LPTMR0_CMR = 499;                       /* Underflow every x+1 milliseconds */
    LPTMR0_PSR = 0x05;                      /* PBYP, LPO 1 KHz selected */
    LPTMR0_CSR = 0x40;                      /* TIE */
    LPTMR0_CSR = 0x41;                      /* TIE | TEN */

    /* Setup interrupt(s) */

    NVICISER2  |= 0x00200000;               /* Enable LPT interrupt */

    /* Don't return from main */
    for(;;)
    {
    }

    return 0;
}

} /* extern "C" */

