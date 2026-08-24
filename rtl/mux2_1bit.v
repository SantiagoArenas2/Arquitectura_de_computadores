// mux2_1bit.v
// Multiplexor 2 a 1 de 1 bit.
//
//   s = 0  ->  y = i0
//   s = 1  ->  y = i1
//
// Expresion booleana obtenida del mapa de Karnaugh:
//
//   y = (~s AND i0) OR (s AND i1)
//
// Implementado solo con primitivas de compuerta.

module mux2_1bit (
    input  wire i0,   // entrada seleccionada cuando s = 0
    input  wire i1,   // entrada seleccionada cuando s = 1
    input  wire s,    // selector
    output wire y
);

    wire w_ns;   // ~s
    wire w_t0;   // ~s AND i0
    wire w_t1;   //  s AND i1

    not u_not1 (w_ns, s);
    and u_and0 (w_t0, w_ns, i0);
    and u_and1 (w_t1, s,    i1);
    or  u_or1  (y,    w_t0, w_t1);

endmodule
