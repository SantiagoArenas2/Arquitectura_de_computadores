// tick_gen.v
// Genera un pulso de un ciclo cada 2^N ciclos de reloj.
//
// Se usa para muestrear los botones a un ritmo lento, muy por debajo
// de los 25 MHz del reloj de la placa.
//
// CONTADOR SIN USAR EL OPERADOR "+"
//
// Un contador binario tiene una propiedad simple: el bit k se
// invierte exactamente cuando TODOS los bits por debajo de el estan
// en 1. Piensa en como se cuenta 0111 -> 1000: el bit 3 cambia
// porque los bits 2, 1 y 0 estaban todos en 1.
//
// Eso se traduce directo a compuertas:
//
//   en[0]   = 1                      (el bit 0 se invierte siempre)
//   en[k+1] = en[k] AND cnt[k]       (cadena de habilitacion)
//   tog[k]  = cnt[k] XOR en[k]       (inversion condicional)
//
// El pulso de salida se toma de en[N], que vale 1 solo cuando todos
// los bits del contador estan en 1, es decir justo antes de volver a
// cero.
//
// PARAMETRO N
//   Con el reloj de 25 MHz de la Go Board:
//     N = 15  ->  tick cada 32768 ciclos  ~ 1.3 ms
//     N = 18  ->  tick cada 262144 ciclos ~ 10 ms
//   En simulacion conviene un N chico (3 o 4) para no esperar
//   millones de ciclos.

module tick_gen #(
    parameter N = 15
) (
    input  wire clk,
    output wire tick
);

    reg  [N-1:0] cnt;
    wire [N:0]   en;    // en[k] = 1 si el bit k debe invertirse
    wire [N-1:0] tog;   // proximo valor de cada bit

    // El bit menos significativo se invierte en cada ciclo
    buf u_en0 (en[0], 1'b1);

    genvar k;
    generate
        for (k = 0; k < N; k = k + 1) begin : etapa
            xor u_tog (tog[k],  cnt[k], en[k]);
            and u_en  (en[k+1], en[k],  cnt[k]);
        end
    endgenerate

    initial cnt = {N{1'b0}};

    always @(posedge clk) begin
        cnt <= tog;
    end

    // en[N] es el AND de todos los bits del contador
    buf u_tick (tick, en[N]);

endmodule
