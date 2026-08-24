// shift_right4.v
// Desplazamiento a la derecha de 0 a 3 posiciones, con relleno de
// ceros por la izquierda.  R = A >> sh
//
// Estructura identica a shift_left4, pero con las conexiones en
// sentido contrario: los bits bajan de posicion en vez de subir,
// y los huecos quedan arriba.
//
//   Etapa 1: desplaza 1 posicion si sh[0] = 1
//   Etapa 2: desplaza 2 posiciones si sh[1] = 1
//
// Es un desplazamiento LOGICO, no aritmetico: siempre entra 0 por
// la izquierda, sin replicar el bit de signo. Eso es lo que pide el
// enunciado ("rellena con ceros por la izquierda"), de modo que
// desplazar un numero negativo a la derecha lo convierte en positivo.

module shift_right4 (
    input  wire [3:0] a,
    input  wire [1:0] sh,
    output wire [3:0] y
);

    wire [3:0] t;   // salida de la etapa 1

    // --- Etapa 1: desplaza 1 posicion si sh[0] = 1 ---
    //   sin desplazar: t[k] = a[k]
    //   desplazando:   t[k] = a[k+1]   (y t[3] = 0)
    mux2_1bit u_e1_3 (.i0(a[3]), .i1(1'b0), .s(sh[0]), .y(t[3]));
    mux2_1bit u_e1_2 (.i0(a[2]), .i1(a[3]), .s(sh[0]), .y(t[2]));
    mux2_1bit u_e1_1 (.i0(a[1]), .i1(a[2]), .s(sh[0]), .y(t[1]));
    mux2_1bit u_e1_0 (.i0(a[0]), .i1(a[1]), .s(sh[0]), .y(t[0]));

    // --- Etapa 2: desplaza 2 posiciones si sh[1] = 1 ---
    //   sin desplazar: y[k] = t[k]
    //   desplazando:   y[k] = t[k+2]   (y y[2] = y[3] = 0)
    mux2_1bit u_e2_3 (.i0(t[3]), .i1(1'b0), .s(sh[1]), .y(y[3]));
    mux2_1bit u_e2_2 (.i0(t[2]), .i1(1'b0), .s(sh[1]), .y(y[2]));
    mux2_1bit u_e2_1 (.i0(t[1]), .i1(t[3]), .s(sh[1]), .y(y[1]));
    mux2_1bit u_e2_0 (.i0(t[0]), .i1(t[2]), .s(sh[1]), .y(y[0]));

endmodule
