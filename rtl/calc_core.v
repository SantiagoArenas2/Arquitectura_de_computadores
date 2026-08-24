// calc_core.v
// Nucleo de la calculadora de 4 bits.
//
// Integra los tres bloques del datapath:
//
//   1) Multiplexor del operando B: elige entre el operando externo
//      op2 y el resultado de la operacion anterior.
//   2) ALU de 4 bits (toda combinacional, hecha con compuertas).
//   3) Registro de resultado, que se carga con el pulso exec.
//
// Este es el modulo que se prueba en el testbench de la evaluacion
// presencial. No depende de botones, displays ni antirrebote: es la
// calculadora pura.
//
// EL LAZO DE REALIMENTACION
//
//   result --> mux operando B --> ALU --> reg4 --> result
//
// El lazo NO es combinacional porque el registro lo interrumpe: la
// senal recorre el camino y se detiene en la entrada del flip-flop,
// esperando el proximo flanco de reloj. Esto es lo que permite
// encadenar operaciones usando el resultado anterior.
//
// INTERFAZ
//
//   op1     operando A (siempre externo)
//   op2     operando B externo
//   opcode  codigo de operacion de 3 bits
//   sel_b   0 = usar op2 externo
//           1 = usar el resultado anterior como operando B
//   exec    pulso de un ciclo que carga el registro
//   result  contenido actual del registro

module calc_core (
    input  wire       clk,
    input  wire [3:0] op1,
    input  wire [3:0] op2,
    input  wire [2:0] opcode,
    input  wire       sel_b,
    input  wire       exec,
    output wire [3:0] result
);

    wire [3:0] b;        // operando B efectivo
    wire [3:0] alu_out;  // resultado combinacional de la ALU

    // --- Seleccion del segundo operando ---
    mux2_4bit u_sel_b (
        .i0 (op2),      // sel_b = 0 -> operando externo
        .i1 (result),   // sel_b = 1 -> resultado anterior
        .s  (sel_b),
        .y  (b)
    );

    // --- Unidad aritmetico-logica ---
    alu4 u_alu (
        .a  (op1),
        .b  (b),
        .op (opcode),
        .y  (alu_out)
    );

    // --- Registro de resultado ---
    reg4 u_reg (
        .clk  (clk),
        .load (exec),
        .d    (alu_out),
        .q    (result)
    );

endmodule
