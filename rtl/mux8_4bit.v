// mux8_4bit.v
// Multiplexor 8 a 1 de 4 bits con selector one-hot.
//
// Selecciona cual de los ocho resultados candidatos de la ALU sale
// hacia el registro. Se construye instanciando cuatro veces el mux
// de 1 bit: uno por cada posicion del bus.
//
// Notar como se conectan: la instancia del bit 0 recibe el bit 0 de
// los OCHO datos de entrada. Es decir, se corta "en vertical" a
// traves de todos los operandos.

module mux8_4bit (
    input  wire [3:0] d0,
    input  wire [3:0] d1,
    input  wire [3:0] d2,
    input  wire [3:0] d3,
    input  wire [3:0] d4,
    input  wire [3:0] d5,
    input  wire [3:0] d6,
    input  wire [3:0] d7,
    input  wire [7:0] sel,
    output wire [3:0] y
);

    mux8_1bit u_bit0 (
        .d0(d0[0]), .d1(d1[0]), .d2(d2[0]), .d3(d3[0]),
        .d4(d4[0]), .d5(d5[0]), .d6(d6[0]), .d7(d7[0]),
        .sel(sel), .y(y[0])
    );

    mux8_1bit u_bit1 (
        .d0(d0[1]), .d1(d1[1]), .d2(d2[1]), .d3(d3[1]),
        .d4(d4[1]), .d5(d5[1]), .d6(d6[1]), .d7(d7[1]),
        .sel(sel), .y(y[1])
    );

    mux8_1bit u_bit2 (
        .d0(d0[2]), .d1(d1[2]), .d2(d2[2]), .d3(d3[2]),
        .d4(d4[2]), .d5(d5[2]), .d6(d6[2]), .d7(d7[2]),
        .sel(sel), .y(y[2])
    );

    mux8_1bit u_bit3 (
        .d0(d0[3]), .d1(d1[3]), .d2(d2[3]), .d3(d3[3]),
        .d4(d4[3]), .d5(d5[3]), .d6(d6[3]), .d7(d7[3]),
        .sel(sel), .y(y[3])
    );

endmodule
