// tb_add_sub4.v
// Testbench de add_sub4 junto con ctrl_decode.
//
// Prueba EXHAUSTIVA: las 256 combinaciones de A y B, para cada una
// de las tres operaciones aritmeticas. Son 768 casos, imposibles de
// revisar a ojo, por lo que el testbench compara automaticamente
// contra el valor esperado y cuenta los errores.
//
// El valor esperado se calcula con los operadores +/- normales de
// Verilog. Eso esta permitido aqui porque el testbench NO se
// sintetiza: solo sirve como referencia para verificar que el
// circuito de compuertas da el mismo resultado.

`timescale 1ns / 1ps

module tb_add_sub4;

    reg  [2:0] op;
    reg  [3:0] a, b;

    wire       inv_a, inv_b, cin;
    wire [3:0] s;
    wire       cout;

    reg  [3:0] esperado;

    integer i, j;
    integer errores;

    ctrl_decode u_ctrl (
        .op    (op),
        .inv_a (inv_a),
        .inv_b (inv_b),
        .cin   (cin)
    );

    add_sub4 u_dut (
        .a     (a),
        .b     (b),
        .inv_a (inv_a),
        .inv_b (inv_b),
        .cin   (cin),
        .s     (s),
        .cout  (cout)
    );

    // Calcula el resultado de referencia segun el opcode
    task calcular_esperado;
        begin
            case (op)
                3'b001: esperado = a + b;   // se trunca solo a 4 bits
                3'b010: esperado = a - b;
                3'b011: esperado = b - a;
                default: esperado = 4'bx;
            endcase
        end
    endtask

    initial begin
        $dumpfile("build/tb_add_sub4.vcd");
        $dumpvars(0, tb_add_sub4);

        errores = 0;

        // ---------------------------------------------------------
        // Parte 1: algunos casos representativos, legibles a ojo
        // ---------------------------------------------------------
        $display("");
        $display("  === Casos representativos (valores con signo) ===");
        $display("   op    A     B    |   S     dec   esperado");
        $display("  ------------------+------------------------");

        op = 3'b001; a = 4'd5;    b = 4'd3;    #10; mostrar;  // 5 + 3
        op = 3'b010; a = 4'd5;    b = 4'd3;    #10; mostrar;  // 5 - 3
        op = 3'b011; a = 4'd5;    b = 4'd3;    #10; mostrar;  // 3 - 5
        op = 3'b010; a = 4'd3;    b = 4'd5;    #10; mostrar;  // 3 - 5
        op = 3'b001; a = 4'b1111; b = 4'd1;    #10; mostrar;  // -1 + 1
        op = 3'b001; a = 4'd7;    b = 4'd1;    #10; mostrar;  // overflow
        op = 3'b010; a = 4'd0;    b = 4'd1;    #10; mostrar;  // 0 - 1

        // ---------------------------------------------------------
        // Parte 2: barrido exhaustivo, silencioso
        // ---------------------------------------------------------
        $display("");
        $display("  === Barrido exhaustivo (768 casos) ===");

        for (i = 0; i < 8; i = i + 1) begin
            case (i)
                0: op = 3'b001;
                1: op = 3'b010;
                2: op = 3'b011;
                default: op = 3'b001;
            endcase

            if (i < 3) begin
                for (j = 0; j < 256; j = j + 1) begin
                    a = j[7:4];
                    b = j[3:0];
                    #10;
                    calcular_esperado;
                    if (s !== esperado) begin
                        errores = errores + 1;
                        if (errores <= 5)
                            $display("    FALLO: op=%b A=%b B=%b -> S=%b (esperado %b)",
                                     op, a, b, s, esperado);
                    end
                end
            end
        end

        $display("");
        if (errores == 0)
            $display("  RESULTADO: los 768 casos pasaron.");
        else
            $display("  RESULTADO: %0d caso(s) fallaron.", errores);
        $display("");

        #10 $finish;
    end

    task mostrar;
        begin
            calcular_esperado;
            $display("  %b  %b  %b  |  %b   %0d      %0d",
                     op, a, b, s, $signed(s), $signed(esperado));
            if (s !== esperado) errores = errores + 1;
        end
    endtask

endmodule
