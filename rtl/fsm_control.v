// fsm_control.v
// Maquina de estados de ingreso de la calculadora.
//
// ESTADOS
//
//   st  | nombre  | que se ingresa    | que se muestra
//   ----+---------+-------------------+----------------
//   00  | ST_OP   | codigo de operac. | opcode
//   01  | ST_A    | primer operando   | operando A
//   10  | ST_B    | segundo operando  | operando B
//   11  | ST_RES  | nada              | resultado
//
// Cada pulso de confirmacion avanza al siguiente estado, y desde
// ST_RES se vuelve a ST_OP. Eso equivale a contar de 0 a 3 con
// desborde, por lo que la logica de proximo estado es la de un
// contador de 2 bits:
//
//   st0_next = st0 XOR conf
//   st1_next = st1 XOR (conf AND st0)
//
// CONTADOR DE INGRESO COMPARTIDO
//
// Los tres campos (opcode, A, B) tienen su propio registro, pero
// comparten un unico sumador para subir y bajar:
//
//   subir  ->  valor + 0001   (inv_b = 0, cin = 0)
//   bajar  ->  valor - 0001   (inv_b = 1, cin = 1)
//
// Una sola senal, p_down, controla inv_b y cin a la vez. Un mux 8 a 1
// gobernado por el estado one-hot elige que registro alimenta al
// sumador, y la habilitacion de carga decide cual lo recibe de vuelta.
//
// Los valores dan la vuelta al llegar al maximo: el truncamiento a 4
// bits lo hace solo, sin logica adicional. El opcode se limita a 3
// bits forzando su bit alto a cero, de modo que recorre los codigos
// 000 a 111 y vuelve a empezar.

module fsm_control (
    input  wire       clk,

    // Pulsos de un ciclo provenientes de los botones
    input  wire       p_up,      // superior izquierdo: incrementar
    input  wire       p_down,    // inferior izquierdo: decrementar
    input  wire       p_conf,    // superior derecho: confirmar
    input  wire       p_prev,    // inferior derecho: usar resultado previo

    input  wire [3:0] result,    // resultado actual del calc_core

    output wire [2:0] opcode,
    output wire [3:0] op1,
    output wire [3:0] op2,
    output reg        sel_b,
    output wire       exec,
    output wire [3:0] disp_val,  // valor a mostrar en el display
    output wire [1:0] estado
);

    // ---- Registro de estado ----
    reg  [1:0] st;
    wire       st0_next, st1_next, t_st1;

    // ---- Decodificacion del estado ----
    wire       n1, n0;
    wire       en_op, en_a, en_b, en_res;
    wire [7:0] sel_estado;

    // ---- Datapath de ingreso ----
    wire [3:0] reg_op;
    wire [3:0] val_actual;
    wire [3:0] val_nuevo;
    wire [3:0] d_op;
    wire       cout_cnt;
    wire       mover;
    wire       ld_op, ld_a, ld_b;

    // ---- sel_b ----
    wire       s_set, s_nop, s_hold, s_next;

    // ---- Display ----
    wire [3:0] b_efectivo;

    // ===============================================================
    // Proximo estado
    // ===============================================================
    xor u_x0 (st0_next, st[0], p_conf);
    and u_t1 (t_st1,    p_conf, st[0]);
    xor u_x1 (st1_next, st[1], t_st1);

    initial st = 2'b00;

    always @(posedge clk) begin
        st <= {st1_next, st0_next};
    end

    buf u_es0 (estado[0], st[0]);
    buf u_es1 (estado[1], st[1]);

    // ===============================================================
    // Decodificacion del estado a one-hot
    // ===============================================================
    not u_n1 (n1, st[1]);
    not u_n0 (n0, st[0]);

    and u_dop (en_op,  n1,    n0   );   // 00
    and u_da  (en_a,   n1,    st[0]);   // 01
    and u_db  (en_b,   st[1], n0   );   // 10
    and u_dr  (en_res, st[1], st[0]);   // 11

    buf u_se0 (sel_estado[0], en_op );
    buf u_se1 (sel_estado[1], en_a  );
    buf u_se2 (sel_estado[2], en_b  );
    buf u_se3 (sel_estado[3], en_res);
    buf u_se4 (sel_estado[4], 1'b0  );
    buf u_se5 (sel_estado[5], 1'b0  );
    buf u_se6 (sel_estado[6], 1'b0  );
    buf u_se7 (sel_estado[7], 1'b0  );

    // ===============================================================
    // Contador de ingreso compartido
    // ===============================================================

    // Elige el campo que se esta editando
    mux8_4bit u_mux_val (
        .d0  (reg_op),
        .d1  (op1),
        .d2  (op2),
        .d3  (4'b0000),
        .d4  (4'b0000),
        .d5  (4'b0000),
        .d6  (4'b0000),
        .d7  (4'b0000),
        .sel (sel_estado),
        .y   (val_actual)
    );

    // Suma o resta 1 segun el boton presionado
    add_sub4 u_cnt (
        .a     (val_actual),
        .b     (4'b0001),
        .inv_a (1'b0),
        .inv_b (p_down),
        .cin   (p_down),
        .s     (val_nuevo),
        .cout  (cout_cnt)
    );

    // Habilitacion de carga: solo el registro del estado activo
    or  u_mov (mover, p_up, p_down);
    and u_lop (ld_op, en_op, mover);
    and u_la  (ld_a,  en_a,  mover);
    and u_lb  (ld_b,  en_b,  mover);

    // El opcode ocupa solo 3 bits: su bit alto se fuerza a cero
    buf u_do0 (d_op[0], val_nuevo[0]);
    buf u_do1 (d_op[1], val_nuevo[1]);
    buf u_do2 (d_op[2], val_nuevo[2]);
    buf u_do3 (d_op[3], 1'b0);

    reg4 u_rop (.clk(clk), .load(ld_op), .d(d_op),      .q(reg_op));
    reg4 u_ra  (.clk(clk), .load(ld_a),  .d(val_nuevo), .q(op1));
    reg4 u_rb  (.clk(clk), .load(ld_b),  .d(val_nuevo), .q(op2));

    buf u_op0 (opcode[0], reg_op[0]);
    buf u_op1 (opcode[1], reg_op[1]);
    buf u_op2 (opcode[2], reg_op[2]);

    // ===============================================================
    // Biestable sel_b
    // ===============================================================
    // Se activa al presionar el boton inferior derecho durante el
    // ingreso del segundo operando, y se limpia al volver al estado
    // inicial para empezar una operacion nueva.
    //
    //   sel_b_next = (p_prev AND en_b) OR (sel_b AND NOT en_op)

    and u_ss (s_set,  p_prev, en_b);
    not u_sn (s_nop,  en_op);
    and u_sh (s_hold, sel_b, s_nop);
    or  u_sx (s_next, s_set, s_hold);

    initial sel_b = 1'b0;

    always @(posedge clk) begin
        sel_b <= s_next;
    end

    // ===============================================================
    // Pulso de ejecucion
    // ===============================================================
    // Se genera al confirmar estando en el ingreso del segundo
    // operando. Dura un solo ciclo porque p_conf dura un solo ciclo.

    and u_ex (exec, p_conf, en_b);

    // ===============================================================
    // Valor a mostrar en el display
    // ===============================================================
    // En el estado ST_B se muestra el resultado anterior si sel_b
    // esta activo, para que el usuario vea con que va a operar.

    mux2_4bit u_bef (
        .i0 (op2),
        .i1 (result),
        .s  (sel_b),
        .y  (b_efectivo)
    );

    mux8_4bit u_mux_disp (
        .d0  (reg_op),
        .d1  (op1),
        .d2  (b_efectivo),
        .d3  (result),
        .d4  (4'b0000),
        .d5  (4'b0000),
        .d6  (4'b0000),
        .d7  (4'b0000),
        .sel (sel_estado),
        .y   (disp_val)
    );

endmodule
