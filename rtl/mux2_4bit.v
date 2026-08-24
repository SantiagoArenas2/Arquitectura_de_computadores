// mux2_4bit.v
// Multiplexor 2 a 1 de 4 bits.
//
// Se construye instanciando cuatro veces el mux de 1 bit, uno por
// cada posicion del bus. El selector es comun a los cuatro.
//
//   s = 0  ->  y = i0
//   s = 1  ->  y = i1
//
// Este modulo es el que elige el segundo operando de la calculadora:
// operando externo op2 (s = 0) o resultado anterior (s = 1).

module mux2_4bit (
    input  wire [3:0] i0,
    input  wire [3:0] i1,
    input  wire       s,
    output wire [3:0] y
);

    mux2_1bit u_bit0 (.i0(i0[0]), .i1(i1[0]), .s(s), .y(y[0]));
    mux2_1bit u_bit1 (.i0(i0[1]), .i1(i1[1]), .s(s), .y(y[1]));
    mux2_1bit u_bit2 (.i0(i0[2]), .i1(i1[2]), .s(s), .y(y[2]));
    mux2_1bit u_bit3 (.i0(i0[3]), .i1(i1[3]), .s(s), .y(y[3]));

endmodule
