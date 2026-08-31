`timescale 1ns/1ps

module calculadora_4bits_tb_basico;

  logic clk;
  logic ejecutar;
  logic [2:0] codigo;
  logic sel_op2;
  logic [3:0] op1;
  logic [3:0] op2_ext;
  logic [3:0] resultado;

  calculadora_4bits dut (
    .clk(clk),
    .ejecutar(ejecutar),
    .codigo(codigo),
    .sel_op2(sel_op2),
    .op1(op1),
    .op2_ext(op2_ext),
    .resultado(resultado)
  );

  localparam SUMA  = 3'b001;
  localparam RESTA = 3'b010;

  always #5 clk = ~clk;

  task automatic pulso_ejecutar;
    begin
      ejecutar = 1'b1;
      @(posedge clk);
      #1;
      ejecutar = 1'b0;
      @(posedge clk);
      #1;
    end
  endtask

  task automatic probar;
    input [2:0] cod;
    input [3:0] a;
    input [3:0] b;
    input [3:0] esperado;
    input string nombre;
    begin
      codigo  = cod;
      sel_op2 = 1'b0;
      op1     = a;
      op2_ext = b;

      pulso_ejecutar();

      if (resultado !== esperado) begin
        $display("FAIL %s", nombre);
        $display("  codigo   = %b", cod);
        $display("  op1      = %b", a);
        $display("  op2_ext  = %b", b);
        $display("  esperado = %b", esperado);
        $display("  obtenido = %b", resultado);
        $fatal;
      end else begin
        $display("PASS %s: resultado = %b", nombre, resultado);
      end
    end
  endtask

  initial begin
    $dumpfile("calculadora_4bits_tb_basico.vcd");
    $dumpvars(0, calculadora_4bits_tb_basico);

    clk = 1'b0;
    ejecutar = 1'b0;
    codigo = 3'b000;
    sel_op2 = 1'b0;
    op1 = 4'b0000;
    op2_ext = 4'b0000;

    repeat (2) @(posedge clk);

    probar(SUMA,  4'b0011, 4'b0100, 4'b0111, "suma 3 + 4 = 7");
    probar(SUMA,  4'b1110, 4'b0011, 4'b0001, "suma -2 + 3 = 1");
    probar(SUMA,  4'b0111, 4'b0011, 4'b1010, "suma con overflow 7 + 3");

    probar(RESTA, 4'b0101, 4'b0010, 4'b0011, "resta 5 - 2 = 3");
    probar(RESTA, 4'b0010, 4'b0101, 4'b1101, "resta 2 - 5 = -3");
    probar(RESTA, 4'b1011, 4'b1110, 4'b1101, "resta -5 - (-2) = -3");

    $display("LOS TESTS PASARON!");
    $finish;
  end

endmodule