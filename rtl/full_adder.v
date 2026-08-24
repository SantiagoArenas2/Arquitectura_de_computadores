// full_adder.v
// Sumador completo de 1 bit.
// Implementado EXCLUSIVAMENTE con primitivas de compuerta,
// como exige el enunciado del Proyecto 1.
//
//   sum  = a XOR b XOR cin
//   cout = (a AND b) OR (cin AND (a XOR b))
//
// Sintaxis de las primitivas: nombre (salida, entrada1, entrada2, ...);
// La PRIMERA senal siempre es la salida.

module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);

    wire w_axb;      // a XOR b
    wire w_ab;       // a AND b
    wire w_cin_axb;  // cin AND (a XOR b)

    xor u_xor1 (w_axb,     a, b);
    xor u_xor2 (sum,       w_axb, cin);

    and u_and1 (w_ab,      a, b);
    and u_and2 (w_cin_axb, cin, w_axb);
    or  u_or1  (cout,      w_ab, w_cin_axb);

endmodule
