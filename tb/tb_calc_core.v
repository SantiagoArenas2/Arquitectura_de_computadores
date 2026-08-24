// tb_calc_core.v
// Testbench del nucleo de la calculadora.
//
// **ESTE ES EL TESTBENCH DE LA EVALUACION PRESENCIAL.**
//
// Durante la clase el profesor indicara las operaciones y los
// valores a utilizar. Para cambiarlos basta editar la SECUENCIA DE
// PRUEBA marcada mas abajo: cada linea es una operacion.
//
// Uso de la tarea ejecutar:
//
//   ejecutar(OPCODE, A, B, USAR_PREVIO, ESPERADO);
//
//     OPCODE       3 bits, ver tabla
//     A            primer operando (4 bits)
//     B            segundo operando externo (se ignora si USAR_PREVIO = 1)
//     USAR_PREVIO  0 = usa B;  1 = usa el resultado anterior como B
//     ESPERADO     valor esperado, para la verificacion automatica
//
//   OPCODES:  000 reinicio        011 resta inversa (B - A)
//             001 suma            100 shift left
//             010 resta (A - B)   101 shift right

`timescale 1ns / 1ps

module tb_calc_core;

    reg        clk;
    reg  [3:0] op1;
    reg  [3:0] op2;
    reg  [2:0] opcode;
    reg        sel_b;
    reg        exec;
    wire [3:0] result;

    integer errores;
    integer paso;

    calc_core dut (
        .clk    (clk),
        .op1    (op1),
        .op2    (op2),
        .opcode (opcode),
        .sel_b  (sel_b),
        .exec   (exec),
        .result (result)
    );

    // Reloj de periodo 10 ns
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // ---------------------------------------------------------------
    // Ejecuta una operacion y verifica el resultado
    // ---------------------------------------------------------------
    // Las senales se establecen en el flanco de BAJADA, de modo que
    // esten estables cuando llegue el flanco de subida que carga el
    // registro. exec dura exactamente un ciclo de reloj.
    task ejecutar;
        input [2:0] o;
        input [3:0] va;
        input [3:0] vb;
        input       prev;
        input [3:0] esperado;
        begin
            @(negedge clk);
            opcode = o;
            op1    = va;
            op2    = vb;
            sel_b  = prev;
            exec   = 1'b1;

            @(negedge clk);
            exec   = 1'b0;

            @(negedge clk);

            paso = paso + 1;
            $display("  %2d  |  %b  | %b | %b |   %b    %3d  |   %b   %3d  | %s",
                     paso, o, va, prev ? 4'bzzzz : vb, result, $signed(result),
                     esperado, $signed(esperado),
                     (result === esperado) ? "ok" : "FALLO");

            if (result !== esperado) errores = errores + 1;
        end
    endtask

    initial begin
        $dumpfile("build/tb_calc_core.vcd");
        $dumpvars(0, tb_calc_core);

        errores = 0;
        paso    = 0;

        op1 = 4'b0000;
        op2 = 4'b0000;
        opcode = 3'b000;
        sel_b  = 1'b0;
        exec   = 1'b0;

        $display("");
        $display("  paso | op  |  A   |  B   | resultado  |  esperado  |");
        $display("  -----+-----+------+------+------------+------------+------");

        // ===========================================================
        // SECUENCIA DE PRUEBA  --  EDITAR AQUI EN LA EVALUACION
        // ===========================================================

        // Reinicio: deja el registro en cero
        ejecutar(3'b000, 4'b0000, 4'b0000, 1'b0, 4'b0000);

        // 5 + 3 = 8, que en 4 bits con signo es -8 (overflow)
        ejecutar(3'b001, 4'd5, 4'd3, 1'b0, 4'b1000);

        // Vuelve a cero
        ejecutar(3'b000, 4'b0000, 4'b0000, 1'b0, 4'b0000);

        // 2 + 3 = 5
        ejecutar(3'b001, 4'd2, 4'd3, 1'b0, 4'd5);

        // Encadenamiento: 4 + (resultado anterior = 5) = 9 -> -7
        ejecutar(3'b001, 4'd4, 4'bxxxx, 1'b1, 4'b1001);

        // Encadenamiento: 1 - (resultado anterior = -7) = 8 -> -8
        ejecutar(3'b010, 4'd1, 4'bxxxx, 1'b1, 4'b1000);

        // Resta inversa: B - A, con B = 6 y A = 2  ->  4
        ejecutar(3'b011, 4'd2, 4'd6, 1'b0, 4'd4);

        // Shift left: 0001 << 2 = 0100
        ejecutar(3'b100, 4'b0001, 4'b0010, 1'b0, 4'b0100);

        // Shift right: 1000 >> 1 = 0100
        ejecutar(3'b101, 4'b1000, 4'b0001, 1'b0, 4'b0100);

        // Reinicio final
        ejecutar(3'b000, 4'b0000, 4'b0000, 1'b0, 4'b0000);

        // ===========================================================
        // FIN DE LA SECUENCIA DE PRUEBA
        // ===========================================================

        $display("");
        if (errores == 0)
            $display("  RESULTADO: las %0d operaciones dieron el valor esperado.", paso);
        else
            $display("  RESULTADO: %0d de %0d operaciones fallaron.", errores, paso);
        $display("");

        #20 $finish;
    end

endmodule
