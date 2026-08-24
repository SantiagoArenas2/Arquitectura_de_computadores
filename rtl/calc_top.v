// calc_top.v
// Modulo de nivel superior para la Nandland Go Board.
//
// Conecta el diseno con los pines fisicos de la placa. No contiene
// logica propia: solo instancia y cablea.
//
// BOTONES  (pulsadores, activos en alto, con rebote mecanico)
//
//   i_Switch[0]  superior izquierdo  -> incrementar
//   i_Switch[1]  inferior izquierdo  -> decrementar
//   i_Switch[2]  superior derecho    -> confirmar / ejecutar
//   i_Switch[3]  inferior derecho    -> usar resultado anterior
//
// Cada boton pasa por dos etapas:
//   1) debounce     filtra el rebote mecanico
//   2) edge_detect  convierte el nivel en un pulso de un ciclo
//
// Sin la segunda etapa, mantener un boton presionado generaria 25
// millones de eventos por segundo.
//
// LEDS
//   o_LED[2:0]  codigo de operacion
//   o_LED[3]    indicador de "usando resultado anterior"
//
// DISPLAYS  (anodo comun: el segmento se enciende con 0)
//   Display 1 (izquierdo)  signo
//   Display 2 (derecho)    valor en hexadecimal
//
// RELOJ
//   i_Clk  25 MHz

module calc_top (
    input  wire       i_Clk,
    input  wire [3:0] i_Switch,
    output wire [3:0] o_LED,

    output wire o_Segment1_A,
    output wire o_Segment1_B,
    output wire o_Segment1_C,
    output wire o_Segment1_D,
    output wire o_Segment1_E,
    output wire o_Segment1_F,
    output wire o_Segment1_G,

    output wire o_Segment2_A,
    output wire o_Segment2_B,
    output wire o_Segment2_C,
    output wire o_Segment2_D,
    output wire o_Segment2_E,
    output wire o_Segment2_F,
    output wire o_Segment2_G
);

    // ---- Senales internas ----
    wire       tick;
    wire [3:0] limpio;   // botones ya sin rebote
    wire [3:0] pulso;    // pulsos de un ciclo

    wire [2:0] opcode;
    wire [3:0] op1, op2;
    wire       sel_b, exec;
    wire [3:0] disp_val;
    wire [1:0] estado;
    wire [3:0] result;

    // ===============================================================
    // Generador del tick de muestreo
    // ===============================================================
    // N = 15 -> un tick cada 32768 ciclos, aprox 1.3 ms a 25 MHz.
    // El antirrebote exige cuatro muestras coincidentes, por lo que
    // pide unos 5 ms de estabilidad.
    tick_gen #(.N(15)) u_tick (
        .clk  (i_Clk),
        .tick (tick)
    );

    // ===============================================================
    // Acondicionamiento de los cuatro botones
    // ===============================================================
    debounce u_deb0 (.clk(i_Clk), .tick(tick), .noisy(i_Switch[0]), .clean(limpio[0]));
    debounce u_deb1 (.clk(i_Clk), .tick(tick), .noisy(i_Switch[1]), .clean(limpio[1]));
    debounce u_deb2 (.clk(i_Clk), .tick(tick), .noisy(i_Switch[2]), .clean(limpio[2]));
    debounce u_deb3 (.clk(i_Clk), .tick(tick), .noisy(i_Switch[3]), .clean(limpio[3]));

    edge_detect u_edg0 (.clk(i_Clk), .level(limpio[0]), .pulse(pulso[0]));
    edge_detect u_edg1 (.clk(i_Clk), .level(limpio[1]), .pulse(pulso[1]));
    edge_detect u_edg2 (.clk(i_Clk), .level(limpio[2]), .pulse(pulso[2]));
    edge_detect u_edg3 (.clk(i_Clk), .level(limpio[3]), .pulse(pulso[3]));

    // ===============================================================
    // Maquina de estados de ingreso
    // ===============================================================
    fsm_control u_fsm (
        .clk      (i_Clk),
        .p_up     (pulso[0]),
        .p_down   (pulso[1]),
        .p_conf   (pulso[2]),
        .p_prev   (pulso[3]),
        .result   (result),
        .opcode   (opcode),
        .op1      (op1),
        .op2      (op2),
        .sel_b    (sel_b),
        .exec     (exec),
        .disp_val (disp_val),
        .estado   (estado)
    );

    // ===============================================================
    // Nucleo de la calculadora
    // ===============================================================
    calc_core u_core (
        .clk    (i_Clk),
        .op1    (op1),
        .op2    (op2),
        .opcode (opcode),
        .sel_b  (sel_b),
        .exec   (exec),
        .result (result)
    );

    // ===============================================================
    // LEDs
    // ===============================================================
    buf u_led0 (o_LED[0], opcode[0]);
    buf u_led1 (o_LED[1], opcode[1]);
    buf u_led2 (o_LED[2], opcode[2]);
    buf u_led3 (o_LED[3], sel_b);

    // ===============================================================
    // Display 1: signo
    // ===============================================================
    sign_display u_signo (
        .v     (disp_val),
        .seg_a (o_Segment1_A),
        .seg_b (o_Segment1_B),
        .seg_c (o_Segment1_C),
        .seg_d (o_Segment1_D),
        .seg_e (o_Segment1_E),
        .seg_f (o_Segment1_F),
        .seg_g (o_Segment1_G)
    );

    // ===============================================================
    // Display 2: valor en hexadecimal
    // ===============================================================
    seg7_decoder u_valor (
        .v     (disp_val),
        .blank (1'b0),
        .seg_a (o_Segment2_A),
        .seg_b (o_Segment2_B),
        .seg_c (o_Segment2_C),
        .seg_d (o_Segment2_D),
        .seg_e (o_Segment2_E),
        .seg_f (o_Segment2_F),
        .seg_g (o_Segment2_G)
    );

endmodule
