// seg7_decoder.v
// Decodificador de un valor de 4 bits a display de siete segmentos.
//
// DISPOSICION DE LOS SEGMENTOS
//
//      aaaa
//     f    b
//     f    b
//      gggg
//     e    c
//     e    c
//      dddd
//
// TABLA DE VERDAD (1 = segmento encendido)
//
//   v     digito | a b c d e f g
//   ------------+---------------
//   0000    0    | 1 1 1 1 1 1 0
//   0001    1    | 0 1 1 0 0 0 0
//   0010    2    | 1 1 0 1 1 0 1
//   0011    3    | 1 1 1 1 0 0 1
//   0100    4    | 0 1 1 0 0 1 1
//   0101    5    | 1 0 1 1 0 1 1
//   0110    6    | 1 0 1 1 1 1 1
//   0111    7    | 1 1 1 0 0 0 0
//   1000    8    | 1 1 1 1 1 1 1
//   1001    9    | 1 1 1 1 0 1 1
//   1010    A    | 1 1 1 0 1 1 1
//   1011    b    | 0 0 1 1 1 1 1
//   1100    C    | 1 0 0 1 1 1 0
//   1101    d    | 0 1 1 1 1 0 1
//   1110    E    | 1 0 0 1 1 1 1
//   1111    F    | 1 0 0 0 1 1 1
//
// IMPLEMENTACION
// Se usa la forma canonica de suma de productos: el decoder4to16
// genera los 16 minterms y cada segmento es el OR de los minterms
// en que debe encenderse. Es directamente legible desde la tabla.
//
// ANODO COMUN
// Los displays de la Go Board son de anodo comun: el segmento se
// ENCIENDE cuando el pin esta en 0. Por eso la ultima etapa son
// siete inversores. Sin ellos el display muestra el negativo de
// cada digito.
//
// La entrada "blank" apaga el display completo, util para el
// display de signo cuando el numero es positivo.

module seg7_decoder (
    input  wire [3:0] v,
    input  wire       blank,   // 1 = apagar todos los segmentos
    output wire       seg_a,
    output wire       seg_b,
    output wire       seg_c,
    output wire       seg_d,
    output wire       seg_e,
    output wire       seg_f,
    output wire       seg_g
);

    wire [15:0] m;

    // Segmentos en logica positiva (1 = encendido)
    wire on_a, on_b, on_c, on_d, on_e, on_f, on_g;

    // Segmentos ya considerando blank
    wire vis_a, vis_b, vis_c, vis_d, vis_e, vis_f, vis_g;

    wire nblank;

    decoder4to16 u_dec (.v(v), .m(m));

    // --- Suma de productos, leida directo de la tabla ---

    // a: 0 2 3 5 6 7 8 9 A C E F
    or u_a (on_a, m[0], m[2], m[3], m[5], m[6], m[7],
                  m[8], m[9], m[10], m[12], m[14], m[15]);

    // b: 0 1 2 3 4 7 8 9 A d
    or u_b (on_b, m[0], m[1], m[2], m[3], m[4],
                  m[7], m[8], m[9], m[10], m[13]);

    // c: 0 1 3 4 5 6 7 8 9 A b d
    or u_c (on_c, m[0], m[1], m[3], m[4], m[5], m[6],
                  m[7], m[8], m[9], m[10], m[11], m[13]);

    // d: 0 2 3 5 6 8 9 b C d E
    or u_d (on_d, m[0], m[2], m[3], m[5], m[6], m[8],
                  m[9], m[11], m[12], m[13], m[14]);

    // e: 0 2 6 8 A b C d E F
    or u_e (on_e, m[0], m[2], m[6], m[8], m[10],
                  m[11], m[12], m[13], m[14], m[15]);

    // f: 0 4 5 6 8 9 A b C E F
    or u_f (on_f, m[0], m[4], m[5], m[6], m[8], m[9],
                  m[10], m[11], m[12], m[14], m[15]);

    // g: 2 3 4 5 6 8 9 A b d E F
    or u_g (on_g, m[2], m[3], m[4], m[5], m[6], m[8],
                  m[9], m[10], m[11], m[13], m[14], m[15]);

    // --- Apagado global ---
    not u_nb (nblank, blank);
    and u_va (vis_a, on_a, nblank);
    and u_vb (vis_b, on_b, nblank);
    and u_vc (vis_c, on_c, nblank);
    and u_vd (vis_d, on_d, nblank);
    and u_ve (vis_e, on_e, nblank);
    and u_vf (vis_f, on_f, nblank);
    and u_vg (vis_g, on_g, nblank);

    // --- Conversion a logica negativa (anodo comun) ---
    not u_sa (seg_a, vis_a);
    not u_sb (seg_b, vis_b);
    not u_sc (seg_c, vis_c);
    not u_sd (seg_d, vis_d);
    not u_se (seg_e, vis_e);
    not u_sf (seg_f, vis_f);
    not u_sg (seg_g, vis_g);

endmodule
