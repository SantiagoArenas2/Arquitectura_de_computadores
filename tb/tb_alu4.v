// tb_alu4.v
// Testbench de la ALU completa.
//
// Prueba EXHAUSTIVA: 8 opcodes x 16 valores de A x 16 valores de B
// = 2048 casos. Si todos pasan, la parte combinacional del proyecto
// esta terminada y verificada.

`timescale 1ns / 1ps

module tb_alu4;

    reg  [2:0] op;
    reg  [3:0] a, b;
    wire [3:0] y;

    reg  [3:0] esperado;

    integer i, j, k;
    integer errores;

    alu4 dut (
        .a  (a),
        .b  (b),
        .op (op),
        .y  (y)
    );

    // Modelo de referencia: describe QUE debe hacer la ALU, sin
    // preocuparse de COMO. Usa operadores de alto nivel porque el
    // testbench no se sintetiza.
    task referencia;
        begin
            case (op)
                3'b000: esperado = 4'b0000;
                3'b001: esperado = a + b;
                3'b010: esperado = a - b;
                3'b011: esperado = b - a;
                3'b100: esperado = a << b[1:0];
                3'b101: esperado = a >> b[1:0];
                3'b110: esperado = 4'b0000;
                3'b111: esperado = 4'b0000;
            endcase
        end
    endtask

    initial begin
        $dumpfile("build/tb_alu4.vcd");
        $dumpvars(0, tb_alu4);

        errores = 0;

        // ---------------------------------------------------------
        // Recorrido guiado: A = 6, B = 3, las seis operaciones
        // ---------------------------------------------------------
        $display("");
        $display("  === A = 0110 (6), B = 0011 (3) ===");
        $display("   op  | operacion       |   Y     dec");
        $display("  -----+-----------------+-------------");

        a = 4'b0110;
        b = 4'b0011;

        op = 3'b000; #10; $display("   %b | reinicio        |  %b   %0d", op, y, $signed(y));
        op = 3'b001; #10; $display("   %b | suma            |  %b   %0d", op, y, $signed(y));
        op = 3'b010; #10; $display("   %b | resta           |  %b   %0d", op, y, $signed(y));
        op = 3'b011; #10; $display("   %b | resta inversa   |  %b   %0d", op, y, $signed(y));
        op = 3'b100; #10; $display("   %b | shift left      |  %b   %0d", op, y, $signed(y));
        op = 3'b101; #10; $display("   %b | shift right     |  %b   %0d", op, y, $signed(y));

        // ---------------------------------------------------------
        // Barrido exhaustivo
        // ---------------------------------------------------------
        $display("");
        $display("  === Barrido exhaustivo (2048 casos) ===");

        for (i = 0; i < 8; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                for (k = 0; k < 16; k = k + 1) begin
                    op = i[2:0];
                    a  = j[3:0];
                    b  = k[3:0];
                    #10;

                    referencia;

                    if (y !== esperado) begin
                        errores = errores + 1;
                        if (errores <= 10)
                            $display("    FALLO: op=%b A=%b B=%b -> Y=%b (esperado %b)",
                                     op, a, b, y, esperado);
                    end
                end
            end
        end

        $display("");
        if (errores == 0)
            $display("  RESULTADO: los 2048 casos pasaron.");
        else
            $display("  RESULTADO: %0d caso(s) fallaron.", errores);
        $display("");

        #10 $finish;
    end

endmodule
