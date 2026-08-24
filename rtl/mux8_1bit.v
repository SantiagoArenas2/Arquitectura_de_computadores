// mux8_1bit.v
// Multiplexor 8 a 1 de 1 bit, con selector ONE-HOT.
//
// A diferencia de un mux convencional, este NO recibe un selector
// binario de 3 bits, sino las 8 lineas one-hot que produce el
// decodificador. Eso permite implementarlo como una simple
// estructura AND-OR:
//
//   y = (sel0 AND d0) OR (sel1 AND d1) OR ... OR (sel7 AND d7)
//
// Como exactamente una linea sel esta en 1, siete de los ocho
// terminos AND dan 0, y el OR final deja pasar solo el dato
// habilitado.
//
// IMPORTANTE: esto asume que sel es realmente one-hot. Si dos lineas
// estuvieran encendidas a la vez, el OR mezclaria dos datos. El
// decodificador3to8 garantiza que eso no ocurra.

module mux8_1bit (
    input  wire       d0,
    input  wire       d1,
    input  wire       d2,
    input  wire       d3,
    input  wire       d4,
    input  wire       d5,
    input  wire       d6,
    input  wire       d7,
    input  wire [7:0] sel,
    output wire       y
);

    wire [7:0] g;   // salidas de las compuertas de habilitacion

    and u_g0 (g[0], sel[0], d0);
    and u_g1 (g[1], sel[1], d1);
    and u_g2 (g[2], sel[2], d2);
    and u_g3 (g[3], sel[3], d3);
    and u_g4 (g[4], sel[4], d4);
    and u_g5 (g[5], sel[5], d5);
    and u_g6 (g[6], sel[6], d6);
    and u_g7 (g[7], sel[7], d7);

    // Las primitivas de Verilog aceptan cualquier numero de entradas
    or u_or (y, g[0], g[1], g[2], g[3], g[4], g[5], g[6], g[7]);

endmodule
