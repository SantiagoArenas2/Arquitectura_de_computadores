// tb_seg7.v
// Testbench del decodificador de siete segmentos.
//
// Recorre los 16 valores posibles y DIBUJA el display en la terminal,
// para poder verificar a simple vista que cada digito se forma bien.
//
// Recordar que la salida es activa en BAJO (anodo comun), por lo que
// un segmento encendido corresponde a un 0 en su pin.

`timescale 1ns / 1ps

module tb_seg7;

    reg  [3:0] v;
    reg        blank;
    wire       sa, sb, sc, sd, se, sf, sg;

    integer i;

    seg7_decoder dut (
        .v     (v),
        .blank (blank),
        .seg_a (sa), .seg_b (sb), .seg_c (sc), .seg_d (sd),
        .seg_e (se), .seg_f (sf), .seg_g (sg)
    );

    // Dibuja el display. Un segmento esta encendido cuando su pin
    // vale 0, por eso se compara contra 1'b0.
    task dibujar;
        begin
            $display("   %s", (sa == 1'b0) ? " ---- " : "      ");
            $display("  %s    %s", (sf == 1'b0) ? "|" : " ",
                                   (sb == 1'b0) ? "|" : " ");
            $display("   %s", (sg == 1'b0) ? " ---- " : "      ");
            $display("  %s    %s", (se == 1'b0) ? "|" : " ",
                                   (sc == 1'b0) ? "|" : " ");
            $display("   %s", (sd == 1'b0) ? " ---- " : "      ");
        end
    endtask

    initial begin
        $dumpfile("build/tb_seg7.vcd");
        $dumpvars(0, tb_seg7);

        blank = 1'b0;

        for (i = 0; i < 16; i = i + 1) begin
            v = i[3:0];
            #10;
            $display("");
            $display("  v = %b  (%h)   pines abcdefg = %b%b%b%b%b%b%b",
                     v, v, sa, sb, sc, sd, se, sf, sg);
            dibujar;
        end

        // Prueba del apagado global
        $display("");
        $display("  === blank = 1 (display apagado) ===");
        v = 4'b1000;
        blank = 1'b1;
        #10;
        $display("  v = 1000, pines abcdefg = %b%b%b%b%b%b%b (todos en 1 = apagado)",
                 sa, sb, sc, sd, se, sf, sg);
        dibujar;

        $display("");
        #10 $finish;
    end

endmodule
