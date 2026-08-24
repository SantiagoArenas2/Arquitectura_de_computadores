// shift_left4.v
// Desplazamiento a la izquierda de 0 a 3 posiciones, con relleno de
// ceros por la derecha.  R = A << sh
//
// ESTRUCTURA: barrel shifter de dos etapas.
//
//   Etapa 1: desplaza 1 posicion si sh[0] = 1
//   Etapa 2: desplaza 2 posiciones si sh[1] = 1
//
//   Desplazamiento total = sh[0] + 2*sh[1] = valor de sh[1:0]
//
// No contiene ninguna compuerta propia: cada etapa son cuatro
// multiplexores 2 a 1 de 1 bit, ya disenados y verificados.
// Los huecos que deja el desplazamiento se conectan a la
// constante 1'b0.
//
// Recordatorio de mux2_1bit:  s = 0 -> y = i0
//                             s = 1 -> y = i1
// Por lo tanto i0 es "no desplazar" e i1 es "desplazar".

module shift_left4 (
    input  wire [3:0] a,
    input  wire [1:0] sh,
    output wire [3:0] y
);

    wire [3:0] t;   // salida de la etapa 1

    // --- Etapa 1: desplaza 1 posicion si sh[0] = 1 ---
    //   sin desplazar: t[k] = a[k]
    //   desplazando:   t[k] = a[k-1]   (y t[0] = 0)
    mux2_1bit u_e1_0 (.i0(a[0]), .i1(1'b0), .s(sh[0]), .y(t[0]));
    mux2_1bit u_e1_1 (.i0(a[1]), .i1(a[0]), .s(sh[0]), .y(t[1]));
    mux2_1bit u_e1_2 (.i0(a[2]), .i1(a[1]), .s(sh[0]), .y(t[2]));
    mux2_1bit u_e1_3 (.i0(a[3]), .i1(a[2]), .s(sh[0]), .y(t[3]));

    // --- Etapa 2: desplaza 2 posiciones si sh[1] = 1 ---
    //   sin desplazar: y[k] = t[k]
    //   desplazando:   y[k] = t[k-2]   (y y[0] = y[1] = 0)
    mux2_1bit u_e2_0 (.i0(t[0]), .i1(1'b0), .s(sh[1]), .y(y[0]));
    mux2_1bit u_e2_1 (.i0(t[1]), .i1(1'b0), .s(sh[1]), .y(y[1]));
    mux2_1bit u_e2_2 (.i0(t[2]), .i1(t[0]), .s(sh[1]), .y(y[2]));
    mux2_1bit u_e2_3 (.i0(t[3]), .i1(t[1]), .s(sh[1]), .y(y[3]));

endmodule
