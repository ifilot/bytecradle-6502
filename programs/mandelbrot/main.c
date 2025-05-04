#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "io.h"

#define WIDTH  80        /* Screen width (80 columns) */
#define HEIGHT 24        /* Screen height (24 rows) */
#define MAX_ITER 64      /* More iterations for finer detail */
#define SCALE 256        /* Fixed-point scaling factor (2^15) */
#define SHIFT 8          /* Used for fixed-point shifting */
#define X_MIN (-2 * SCALE)  /* -2.0 in fixed-point */
#define X_MAX ( 1 * SCALE)  /*  1.0 in fixed-point */
#define Y_MIN (-1 * SCALE)  /* -1.0 in fixed-point */
#define Y_MAX ( 1 * SCALE)  /*  1.0 in fixed-point */

/* 16-character gradient for shading */
const char gradient[] = " .-'|+/=*$&#@MWX";

void mandelbrot() {
    uint16_t x, y, iter;
    int16_t real, imag;
    int32_t zr, zi;
    int16_t zr2, zi2, zrzi;
    int16_t x_step, y_step;
    uint8_t c;

    putstrnl("Plotting Mandelbrot set between [-2, 1] x [-1, 1]:");

    /* Compute steps for fixed-point grid mapping */
    x_step = (X_MAX - X_MIN) / WIDTH;
    y_step = (Y_MAX - Y_MIN) / HEIGHT;

    for (y = 0; y < HEIGHT; y++) {
        imag = Y_MIN + y * y_step;  /* Fixed-point imaginary part */

        for (x = 0; x < WIDTH; x++) {
            real = X_MIN + x * x_step;  /* Fixed-point real part */

            /* Initialize Mandelbrot iteration */
            zr = 0;
            zi = 0;
            iter = 0;

            while (iter < MAX_ITER) {
                zr2 = (zr * zr) >> SHIFT;  /* (zr^2) in fixed-point */
                zi2 = (zi * zi) >> SHIFT;  /* (zi^2) in fixed-point */
                zrzi = (zr * zi) >> (SHIFT - 1);  /* (2*zr*zi) */

                zr += zr2 - zi2 + real;  /* zr = zr^2 - zi^2 + real */
                zi = zrzi + imag;        /* zi = 2*zr*zi + imag */

                if((zr2 + zi2) > (4 * SCALE)) {
                    break;
                }

                iter++;
            }

            /* Map iteration count to gradient */
            c = gradient[(iter * (sizeof(gradient) - 2)) / MAX_ITER];

            putch(c);
        }
        putch('\r');  /* Move to the next line */
        putch('\n');  /* Move to the next line */
    }
}

int main() {
    mandelbrot();
    return 0;
}
