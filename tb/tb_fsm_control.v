// tb_fsm_control.v
// Testbench de la maquina de estados conectada al nucleo.
//
// Simula una sesion completa de uso, tal como ocurriria en la placa,
// pero inyectando los pulsos directamente en vez de pasar por los
// botones y el antirrebote.
//
// Escenario:
//   Operacion 1:  5 + 3          (deberia dar 1000, es decir -8)
//   Operacion 2:  5 + resultado  (5 + (-8) = -3, es decir 1101)
//
// La segunda operacion usa el boton inferior derecho para reutilizar
// el resultado anterior como segundo operando.

`timescale 1ns / 1ps

module tb_fsm_control;

    reg  clk;
    reg  p_up, p_down, p_conf, p_prev;

    wire [2:0] opcode;
    wire [3:0] op1, op2;
    wire       sel_b, exec;
    wire [3:0] disp_val;
    wire [1:0] estado;
    wire [3:0] result;

    integer errores;

    fsm_control u_fsm (
        .clk      (clk),
        .p_up     (p_up),
        .p_down   (p_down),
        .p_conf   (p_conf),
        .p_prev   (p_prev),
        .result   (result),
        .opcode   (opcode),
        .op1      (op1),
        .op2      (op2),
        .sel_b    (sel_b),
        .exec     (exec),
        .disp_val (disp_val),
        .estado   (estado)
    );

    calc_core u_core (
        .clk    (clk),
        .op1    (op1),
        .op2    (op2),
        .opcode (opcode),
        .sel_b  (sel_b),
        .exec   (exec),
        .result (result)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    // ---- Tareas que simulan presiones de botones ----
    task sube;
        begin
            @(negedge clk); p_up = 1'b1;
            @(negedge clk); p_up = 1'b0;
            @(negedge clk);
        end
    endtask

    task baja;
        begin
            @(negedge clk); p_down = 1'b1;
            @(negedge clk); p_down = 1'b0;
            @(negedge clk);
        end
    endtask

    task confirma;
        begin
            @(negedge clk); p_conf = 1'b1;
            @(negedge clk); p_conf = 1'b0;
            @(negedge clk);
        end
    endtask

    task usar_previo;
        begin
            @(negedge clk); p_prev = 1'b1;
            @(negedge clk); p_prev = 1'b0;
            @(negedge clk);
        end
    endtask

    task subir_n;
        input integer n;
        integer k;
        begin
            for (k = 0; k < n; k = k + 1) sube;
        end
    endtask

    task mostrar;
        input [8*20:1] etiqueta;
        begin
            $display("  %0s | st=%b op=%b A=%b B=%b selB=%b disp=%b res=%b",
                     etiqueta, estado, opcode, op1, op2, sel_b, disp_val, result);
        end
    endtask

    initial begin
        $dumpfile("build/tb_fsm_control.vcd");
        $dumpvars(0, tb_fsm_control);

        errores = 0;
        p_up = 0; p_down = 0; p_conf = 0; p_prev = 0;
        #20;

        $display("");
        $display("  === OPERACION 1:  5 + 3 ===");
        mostrar("inicio          ");

        // Estado ST_OP: subir una vez para llegar al opcode 001 (suma)
        subir_n(1);
        mostrar("opcode = suma   ");
        if (opcode !== 3'b001) errores = errores + 1;

        confirma;
        mostrar("-> estado A     ");

        // Estado ST_A: subir hasta 5
        subir_n(5);
        mostrar("A = 5           ");
        if (op1 !== 4'd5) errores = errores + 1;

        confirma;
        mostrar("-> estado B     ");

        // Estado ST_B: subir hasta 3
        subir_n(3);
        mostrar("B = 3           ");
        if (op2 !== 4'd3) errores = errores + 1;

        confirma;   // aqui se genera exec
        mostrar("-> resultado    ");
        if (result !== 4'b1000) errores = errores + 1;

        confirma;
        mostrar("-> vuelta a OP  ");

        $display("");
        $display("  === OPERACION 2:  5 + resultado anterior ===");

        // El opcode sigue en suma, se confirma directo
        confirma;
        mostrar("-> estado A     ");

        // A sigue valiendo 5, se confirma directo
        confirma;
        mostrar("-> estado B     ");

        // Se pide usar el resultado anterior
        usar_previo;
        mostrar("usar previo     ");
        if (sel_b !== 1'b1) errores = errores + 1;

        confirma;
        mostrar("-> resultado    ");
        // 5 + (-8) = -3  ->  1101
        if (result !== 4'b1101) errores = errores + 1;

        confirma;
        mostrar("-> vuelta a OP  ");
        if (sel_b !== 1'b0) errores = errores + 1;

        // Prueba del decremento
        $display("");
        $display("  === Prueba de decremento en el opcode ===");
        baja;
        mostrar("opcode - 1      ");
        if (opcode !== 3'b000) errores = errores + 1;

        $display("");
        if (errores == 0)
            $display("  RESULTADO: la maquina de estados funciona correctamente.");
        else
            $display("  RESULTADO: %0d verificacion(es) fallaron.", errores);
        $display("");

        #20 $finish;
    end

endmodule
