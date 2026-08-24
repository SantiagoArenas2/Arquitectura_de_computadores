// sign_display.v
// Display de signo para el primer digito de siete segmentos.
//
// En complemento a dos, el bit mas significativo indica el signo:
//
//   v[3] = 0  ->  numero positivo  ->  display apagado
//   v[3] = 1  ->  numero negativo  ->  se dibuja un guion
//
// Un guion corresponde al segmento g encendido y los otros seis
// apagados:
//
//      ....        (a apagado)
//     .    .       (f, b apagados)
//      gggg        (g encendido)
//     .    .       (e, c apagados)
//      ....        (d apagado)
//
// Los displays de la Go Board son de anodo comun, por lo que un
// segmento se enciende con 0 y se apaga con 1. Por eso los seis
// segmentos no usados quedan fijos en 1, y el segmento g es
// simplemente la negacion del bit de signo.

module sign_display (
    input  wire [3:0] v,
    output wire       seg_a,
    output wire       seg_b,
    output wire       seg_c,
    output wire       seg_d,
    output wire       seg_e,
    output wire       seg_f,
    output wire       seg_g
);

    // Seis segmentos permanentemente apagados
    buf u_a (seg_a, 1'b1);
    buf u_b (seg_b, 1'b1);
    buf u_c (seg_c, 1'b1);
    buf u_d (seg_d, 1'b1);
    buf u_e (seg_e, 1'b1);
    buf u_f (seg_f, 1'b1);

    // El guion se enciende (0) cuando el numero es negativo
    not u_g (seg_g, v[3]);

endmodule
