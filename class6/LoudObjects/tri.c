// Define frequency of our chip
#define F_CPU 8000000
// Include helper libraries
#include <avr/io.h>
#include <util/delay.h>
#include <stdint.h>

int main(void)
{
    // Set data-direction of all pins of port B to output
    DDRB = 255;
    
    // Define the frequency (Hz) - 440Hz is A4 note
    uint16_t frequency = 440;
    
    // For a smooth triangle wave, we'll use multiple steps per cycle
    // Number of steps per cycle (power of 2 for efficiency)
    #define STEPS 32
    
    // Calculate time per step in microseconds
    // A full cycle is (1/frequency) seconds or (1000000/frequency) microseconds
    uint16_t stepDelay = (1000000 / frequency) / STEPS;
    
    // Triangle wave amplitude values (8-bit)
    uint8_t triangleValues[STEPS] = {
        0, 16, 32, 48, 64, 80, 96, 112, 128, 144, 160, 176, 192, 208, 224, 240,
        255, 240, 224, 208, 192, 176, 160, 144, 128, 112, 96, 80, 64, 48, 32, 16
    };
    
    while (1)
    {
        // Loop through each step of the triangle wave
        for (uint8_t i = 0; i < STEPS; i++)
        {
            // Output the current value to all pins
            PORTB = triangleValues[i];
            
            // Wait for the step delay time
            _delay_us(stepDelay);
        }
    }
}