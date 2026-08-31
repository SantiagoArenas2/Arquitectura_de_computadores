// calculadora_4bits.v
// Modulo envoltorio con la interfaz exigida por el testbench de
// referencia entregado por el curso.
//
// No agrega logica: solo traduce los nombres de las senales hacia
// calc_core, que es el nucleo de la calculadora.
//
//   INTERFAZ EXIGIDA        NUCLEO INTERNO
//   ----------------        --------------
//   clk                ->   clk
//   ejecutar           ->   exec
//   codigo             ->   opcode
//   sel_op2            ->   sel_b
//   op1                ->   op1
//   op2_ext            ->   op2
//   resultado          ->   result
//
// La semantica de sel_op2 coincide con la del diseno:
//   0 -> se usa el operando externo op2_ext
//   1 -> se usa el resultado de la operacion anterior
//
// Se mantiene calc_core como modulo separado porque es el que
// instancia calc_top para la implementacion en la FPGA. Este
// envoltorio existe unicamente para la evaluacion en simulacion.

module calculadora_4bits (
    input  wire       clk,
    input  wire       ejecutar,
    input  wire [2:0] codigo,
    input  wire       sel_op2,
    input  wire [3:0] op1,
    input  wire [3:0] op2_ext,
    output wire [3:0] resultado
);

    calc_core u_core (
        .clk    (clk),
        .op1    (op1),
        .op2    (op2_ext),
        .opcode (codigo),
        .sel_b  (sel_op2),
        .exec   (ejecutar),
        .result (resultado)
    );

endmodule
