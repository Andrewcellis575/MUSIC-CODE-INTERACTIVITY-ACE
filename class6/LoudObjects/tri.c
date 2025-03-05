// Define frequency of our chip
#define F_CPU 8000000
// Include helper libraries
#include <avr/io.h>
#include <util/delay.h>

int main()
{
    // Set data-direction of all pins of port B to output
    DDRB = 255;
    
    // Define the frequency (Hz) - 440Hz is A4 note
    uint16_t frequency = 440;
    
    // Calculate half period in microseconds
    // Half period = (1 / frequency) * 1000000 / 2
    uint16_t halfPeriod = 500000 / frequency;
    
    while (1)
    {
        // Turn on the outputs
        PORTB = 255;
        
        // Delay for half period
        _delay_us(halfPeriod);
        
        // Turn off the outputs
        PORTB = 0;
            
        // Delay for half period
        _delay_us(halfPeriod);
    }
}