// debounce.v
// Antirrebote para un boton mecanico.
//
// EL PROBLEMA
// Los contactos de un pulsador rebotan durante varios milisegundos al
// presionarlo y al soltarlo, generando decenas de transiciones. Con un
// reloj de 25 MHz, cada rebote se veria como una presion distinta.
//
// LA SOLUCION
// Se toman muestras del boton al ritmo lento de "tick" y se guardan
// las ultimas cuatro en un registro de desplazamiento:
//
//   las 4 muestras en 1  ->  la salida sube
//   las 4 muestras en 0  ->  la salida baja
//   muestras mezcladas   ->  la salida conserva su valor
//
// Es decir, la senal debe mantenerse estable durante cuatro periodos
// de tick seguidos para que se le crea. Con tick cada 1.3 ms eso son
// unos 5 ms de estabilidad exigida, muy por encima de la duracion
// tipica del rebote.
//
// La ecuacion de la salida sale de esa descripcion:
//
//   set   = s3 AND s2 AND s1 AND s0
//   clr   = NOR(s3, s2, s1, s0)
//   clean = set OR (clean AND NOT clr)
//
// Todo con compuertas: no se usa if ni case en ningun punto.

module debounce (
    input  wire clk,
    input  wire tick,    // pulso lento de muestreo
    input  wire noisy,   // senal cruda del boton
    output reg  clean    // senal estable
);

    reg  [3:0] s;        // ultimas cuatro muestras
    wire [3:0] s_next;

    wire set;    // las cuatro muestras coinciden en 1
    wire clr;    // las cuatro muestras coinciden en 0
    wire nclr;
    wire hold;
    wire next;

    // --- Registro de desplazamiento, avanza solo cuando llega tick ---
    // Sin tick cada etapa se recarga con su propio valor (mismo truco
    // que en reg4 para evitar el if).
    mux2_1bit u_s0 (.i0(s[0]), .i1(noisy), .s(tick), .y(s_next[0]));
    mux2_1bit u_s1 (.i0(s[1]), .i1(s[0]),  .s(tick), .y(s_next[1]));
    mux2_1bit u_s2 (.i0(s[2]), .i1(s[1]),  .s(tick), .y(s_next[2]));
    mux2_1bit u_s3 (.i0(s[3]), .i1(s[2]),  .s(tick), .y(s_next[3]));

    // --- Decision sobre la salida ---
    and u_set  (set,  s[0], s[1], s[2], s[3]);
    nor u_clr  (clr,  s[0], s[1], s[2], s[3]);
    not u_ncl  (nclr, clr);
    and u_hold (hold, clean, nclr);
    or  u_next (next, set, hold);

    initial begin
        s     = 4'b0000;
        clean = 1'b0;
    end

    always @(posedge clk) begin
        s     <= s_next;
        clean <= next;
    end

endmodule
