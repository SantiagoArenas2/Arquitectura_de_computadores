// alu4.v
// Unidad aritmetico-logica de 4 bits.
//
// Este modulo NO contiene compuertas propias: solo interconecta los
// bloques ya disenados y verificados.
//
// PRINCIPIO DE FUNCIONAMIENTO
//
// Todos los circuitos calculan SIEMPRE, en paralelo. No existe la
// idea de "no ejecutar" un circuito: el sumador y los dos shifters
// son hardware fisico que esta permanentemente encendido. Lo unico
// que decide el opcode es cual de los resultados se deja pasar
// hacia la salida.
//
// Por eso no hace falta ningun "case" ni "if": el decodificador
// enciende una sola linea one-hot, y el multiplexor deja pasar el
// dato correspondiente mientras anula los otros siete.
//
// TABLA DE OPERACIONES
//
//   opcode | operacion      | resultado
//   -------+----------------+---------------------
//    000   | reinicio       | 0000
//    001   | suma           | A + B
//    010   | resta          | A - B
//    011   | resta inversa  | B - A
//    100   | shift left     | A << B[1:0]
//    101   | shift right    | A >> B[1:0]
//    110   | no usado       | 0000
//    111   | no usado       | 0000
//
// Los codigos 110 y 111 no estan definidos en el enunciado. Se
// mapean a 0000 para que el multiplexor 8 a 1 quede completo y no
// existan entradas sin conectar.

module alu4 (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [2:0] op,
    output wire [3:0] y
);

    // --- Senales internas ---
    wire       inv_a, inv_b, cin;
    wire [7:0] sel;
    wire [3:0] r_suma;    // salida del sumador/restador
    wire       cout;      // acarreo final, se descarta
    wire [3:0] r_shl;     // salida del shifter izquierdo
    wire [3:0] r_shr;     // salida del shifter derecho

    // --- Logica de control del sumador ---
    ctrl_decode u_ctrl (
        .op    (op),
        .inv_a (inv_a),
        .inv_b (inv_b),
        .cin   (cin)
    );

    // --- Sumador / restador ---
    // Sirve a los opcodes 001, 010 y 011. Las senales de control ya
    // lo configuraron para la operacion correcta, por lo que su
    // unica salida vale para los tres casos.
    add_sub4 u_addsub (
        .a     (a),
        .b     (b),
        .inv_a (inv_a),
        .inv_b (inv_b),
        .cin   (cin),
        .s     (r_suma),
        .cout  (cout)
    );

    // --- Desplazadores ---
    // La cantidad a desplazar son los dos bits bajos del operando B,
    // tal como especifica el enunciado.
    shift_left4 u_shl (
        .a  (a),
        .sh (b[1:0]),
        .y  (r_shl)
    );

    shift_right4 u_shr (
        .a  (a),
        .sh (b[1:0]),
        .y  (r_shr)
    );

    // --- Decodificador del opcode a one-hot ---
    decoder3to8 u_dec (
        .op  (op),
        .sel (sel)
    );

    // --- Multiplexor de operacion ---
    mux8_4bit u_mux (
        .d0  (4'b0000),   // 000 reinicio
        .d1  (r_suma),    // 001 suma
        .d2  (r_suma),    // 010 resta
        .d3  (r_suma),    // 011 resta inversa
        .d4  (r_shl),     // 100 shift left
        .d5  (r_shr),     // 101 shift right
        .d6  (4'b0000),   // 110 no usado
        .d7  (4'b0000),   // 111 no usado
        .sel (sel),
        .y   (y)
    );

endmodule
