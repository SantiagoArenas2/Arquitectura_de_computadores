// tb_shift.v
// Testbench de shift_left4 y shift_right4.
//
// Prueba exhaustiva: los 16 valores posibles de A por los 4
// desplazamientos posibles = 64 casos por shifter.
//
// La referencia se calcula con los operadores << y >> de Verilog,
// que aqui si estan permitidos porque el testbench no se sintetiza.

`timescale 1ns / 1ps

module tb_shift;

    reg  [3:0] a;
    reg  [1:0] sh;
    wire [3:0] y_izq;
    wire [3:0] y_der;

    reg  [3:0] esp_izq;
    reg  [3:0] esp_der;

    integer i, j;
    integer errores;

    shift_left4  u_izq (.a(a), .sh(sh), .y(y_izq));
    shift_right4 u_der (.a(a), .sh(sh), .y(y_der));

    initial begin
        $dumpfile("build/tb_shift.vcd");
        $dumpvars(0, tb_shift);

        errores = 0;

        // ---------------------------------------------------------
        // Casos representativos con A = 0110 (6)
        // ---------------------------------------------------------
        $display("");
        $display("  === A = 0110, todos los desplazamientos ===");
        $display("   sh |  A << sh   A >> sh");
        $display("  ----+-------------------");

        a = 4'b0110;
        for (j = 0; j < 4; j = j + 1) begin
            sh = j[1:0];
            #10;
            $display("   %b |   %b      %b", sh, y_izq, y_der);
        end

        // ---------------------------------------------------------
        // Un negativo, para ver que el shift derecho es LOGICO
        // ---------------------------------------------------------
        $display("");
        $display("  === A = 1000 (-8), shift derecho logico ===");
        $display("   sh |  A >> sh   valor con signo");
        $display("  ----+---------------------------");

        a = 4'b1000;
        for (j = 0; j < 4; j = j + 1) begin
            sh = j[1:0];
            #10;
            $display("   %b |   %b       %0d", sh, y_der, $signed(y_der));
        end

        // ---------------------------------------------------------
        // Barrido exhaustivo: 16 valores x 4 desplazamientos x 2
        // ---------------------------------------------------------
        $display("");
        $display("  === Barrido exhaustivo (128 casos) ===");

        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                a  = i[3:0];
                sh = j[1:0];
                #10;

                esp_izq = a << sh;
                esp_der = a >> sh;

                if (y_izq !== esp_izq) begin
                    errores = errores + 1;
                    $display("    FALLO IZQ: A=%b sh=%b -> %b (esperado %b)",
                             a, sh, y_izq, esp_izq);
                end

                if (y_der !== esp_der) begin
                    errores = errores + 1;
                    $display("    FALLO DER: A=%b sh=%b -> %b (esperado %b)",
                             a, sh, y_der, esp_der);
                end
            end
        end

        $display("");
        if (errores == 0)
            $display("  RESULTADO: los 128 casos pasaron.");
        else
            $display("  RESULTADO: %0d caso(s) fallaron.", errores);
        $display("");

        #10 $finish;
    end

endmodule
