`timescale 1ns / 1ps

module cpu_prueba (
    input wire clok,
    input wire reset,
    output reg [5:0] color_video,
    output wire [31:0] pc_observado
);

// ==========================================
// ETAPA IF
// ==========================================

wire [31:0] pc_actual;
wire [31:0] pc_siguiente;
reg [31:0] instruccion_if;

assign pc_observado = pc_actual;

pc1 #(.ANCHO(32)) contador_programa (
    .clok(clok),
    .reset(reset),
    .hab_paso(1'b1),
    .pc_siguiente(pc_siguiente),
    .pc_actual(pc_actual)
);

next_pc_logic siguiente_pc (
    .pc_actual(pc_actual),
    .inmediato(32'b0),
    .resultado_jalr(32'b0),
    .seleccion_pc(2'b00),
    .pc_siguiente(pc_siguiente)
);

// Programa de prueba
always @(*) begin
    case (pc_actual)

        32'd0:  instruccion_if = 32'h400000B7;
        32'd4:  instruccion_if = 32'h03000113;

        32'd8:  instruccion_if = 32'h00000013;
        32'd12: instruccion_if = 32'h00000013;
        32'd16: instruccion_if = 32'h00000013;
        32'd20: instruccion_if = 32'h00000013;

        32'd24: instruccion_if = 32'h0020A023;

        default: instruccion_if = 32'h00000013;

    endcase
end

// ==========================================
// REGISTRO IF/ID
// ==========================================

wire [31:0] pc_id;
wire [31:0] instruccion_id;

if_id registro_if_id (
    .clok(clok),
    .reset(reset),
    .hab_paso(1'b1),
    .anular_etapa(1'b0),
    .pc_entrada(pc_actual),
    .instruccion_entrada(instruccion_if),
    .pc_salida(pc_id),
    .instruccion_salida(instruccion_id)
);

// ==========================================
// ETAPA ID
// ==========================================

wire escribir_registro_id;
wire tipo_seg_operando_id;
wire [2:0] tipo_inmediato_id;
wire escribir_memoria_id;
wire [1:0] origen_resultado_id;
wire alu_usa_pc_id;
wire salto_condicional_id;
wire salto_id;
wire jalr_id;
wire [3:0] operacion_alu_id;

control_top control_cpu (
    .instruccion(instruccion_id),
    .escribir_registro(escribir_registro_id),
    .tipo_seg_operando(tipo_seg_operando_id),
    .tipo_inmediato(tipo_inmediato_id),
    .escribir_memoria(escribir_memoria_id),
    .origen_resultado(origen_resultado_id),
    .alu_usa_pc(alu_usa_pc_id),
    .salto_condicional(salto_condicional_id),
    .salto(salto_id),
    .jalr(jalr_id),
    .operacion_alu(operacion_alu_id)
);

wire [31:0] inmediato_id;

immgen generador_inmediatos (
    .instruccion(instruccion_id),
    .tipo_inmediato(tipo_inmediato_id),
    .inmediato_salida(inmediato_id)
);

wire [31:0] valor_rs1_id;
wire [31:0] valor_rs2_id;

wire [4:0] rd_wb;
wire escribir_registro_wb;
wire [31:0] dato_escritura_wb;

regfile banco_registros (
    .clok(clok),
    .escribir_registro(escribir_registro_wb),
    .rs1(instruccion_id[19:15]),
    .rs2(instruccion_id[24:20]),
    .rd(rd_wb),
    .dato_escritura(dato_escritura_wb),
    .valor_rs1(valor_rs1_id),
    .valor_rs2(valor_rs2_id)
);

// ==========================================
// REGISTRO ID/EX
// ==========================================

wire [31:0] pc_ex;
wire [31:0] instruccion_ex;
wire [31:0] valor_rs1_ex;
wire [31:0] valor_rs2_ex;
wire [31:0] inmediato_ex;

wire escribir_registro_ex;
wire tipo_seg_operando_ex;
wire escribir_memoria_ex;
wire [1:0] origen_resultado_ex;
wire alu_usa_pc_ex;
wire salto_condicional_ex;
wire salto_ex;
wire jalr_ex;
wire [3:0] operacion_alu_ex;

id_ex registro_id_ex (
    .clok(clok),
    .reset(reset),
    .hab_paso(1'b1),
    .anular_etapa(1'b0),

    .pc_entrada(pc_id),
    .instruccion_entrada(instruccion_id),
    .valor_rs1_entrada(valor_rs1_id),
    .valor_rs2_entrada(valor_rs2_id),
    .inmediato_entrada(inmediato_id),

    .pc_salida(pc_ex),
    .instruccion_salida(instruccion_ex),
    .valor_rs1_salida(valor_rs1_ex),
    .valor_rs2_salida(valor_rs2_ex),
    .inmediato_salida(inmediato_ex),

    .escribir_registro_entrada(escribir_registro_id),
    .escribir_registro_salida(escribir_registro_ex),

    .tipo_seg_operando_entrada(tipo_seg_operando_id),
    .tipo_seg_operando_salida(tipo_seg_operando_ex),

    .escribir_memoria_entrada(escribir_memoria_id),
    .escribir_memoria_salida(escribir_memoria_ex),

    .origen_resultado_entrada(origen_resultado_id),
    .origen_resultado_salida(origen_resultado_ex),

    .alu_usa_pc_entrada(alu_usa_pc_id),
    .alu_usa_pc_salida(alu_usa_pc_ex),

    .salto_condicional_entrada(salto_condicional_id),
    .salto_condicional_salida(salto_condicional_ex),

    .salto_entrada(salto_id),
    .salto_salida(salto_ex),

    .jalr_entrada(jalr_id),
    .jalr_salida(jalr_ex),

    .operacion_alu_entrada(operacion_alu_id),
    .operacion_alu_salida(operacion_alu_ex)
);

// ==========================================
// ETAPA EX
// ==========================================

wire [31:0] operando_a;
wire [31:0] operando_b;
wire [31:0] resultado_alu_ex;
wire zero_ex;

assign operando_a = alu_usa_pc_ex
                 ? pc_ex
                 : valor_rs1_ex;

assign operando_b = tipo_seg_operando_ex
                 ? inmediato_ex
                 : valor_rs2_ex;

ALU #(.ANCHO(32)) unidad_alu (
    .A(operando_a),
    .B(operando_b),
    .operacion_alu(operacion_alu_ex),
    .resultado(resultado_alu_ex),
    .zero(zero_ex)
);

// ==========================================
// REGISTRO EX/MEM
// ==========================================

wire [31:0] resultado_alu_mem;
wire [31:0] dato_para_memoria_mem;
wire [31:0] pc_mas_4_mem;
wire [31:0] inmediato_mem;

wire [4:0] rd_mem;
wire [2:0] funct3_mem;
wire escribir_registro_mem;
wire escribir_memoria_mem;
wire [1:0] origen_resultado_mem;

ex_mem registro_ex_mem (
    .clok(clok),
    .reset(reset),
    .hab_paso(1'b1),
    .anular_etapa(1'b0),

    .resultado_alu_entrada(resultado_alu_ex),
    .resultado_alu_salida(resultado_alu_mem),

    .dato_para_memoria_entrada(valor_rs2_ex),
    .dato_para_memoria_salida(dato_para_memoria_mem),

    .pc_mas_4_entrada(pc_ex + 32'd4),
    .pc_mas_4_salida(pc_mas_4_mem),

    .rd_entrada(instruccion_ex[11:7]),
    .rd_salida(rd_mem),

    .funct3_entrada(instruccion_ex[14:12]),
    .funct3_salida(funct3_mem),

    .escribir_registro_entrada(escribir_registro_ex),
    .escribir_registro_salida(escribir_registro_mem),

    .escribir_memoria_entrada(escribir_memoria_ex),
    .escribir_memoria_salida(escribir_memoria_mem),

    .origen_resultado_entrada(origen_resultado_ex),
    .origen_resultado_salida(origen_resultado_mem),

    .inmediato_entrada(inmediato_ex),
    .inmediato_salida(inmediato_mem)
);

// ==========================================
// ETAPA MEM
// ==========================================

// Registro de color provisional.
// Direccion de video utilizada para esta prueba:
// 0x40000000

always @(posedge clok or negedge reset) begin

    if (!reset) begin
        color_video <= 6'b000000;
    end

    else if (
        escribir_memoria_mem &&
        funct3_mem == 3'b010 &&
        resultado_alu_mem == 32'h40000000
    ) begin

        color_video <= dato_para_memoria_mem[5:0];

    end

end

// ==========================================
// REGISTRO MEM/WB
// ==========================================

wire [31:0] resultado_alu_wb;
wire [31:0] dato_leido_memoria_wb;
wire [31:0] pc_mas_4_wb;
wire [31:0] inmediato_wb;
wire [1:0] origen_resultado_wb;

mem_wb registro_mem_wb (
    .clok(clok),
    .reset(reset),
    .hab_paso(1'b1),
    .anular_etapa(1'b0),

    .resultado_alu_entrada(resultado_alu_mem),
    .resultado_alu_salida(resultado_alu_wb),

    .dato_leido_memoria_entrada(32'b0),
    .dato_leido_memoria_salida(dato_leido_memoria_wb),

    .pc_mas_4_entrada(pc_mas_4_mem),
    .pc_mas_4_salida(pc_mas_4_wb),

    .rd_entrada(rd_mem),
    .rd_salida(rd_wb),

    .escribir_registro_entrada(escribir_registro_mem),
    .escribir_registro_salida(escribir_registro_wb),

    .origen_resultado_entrada(origen_resultado_mem),
    .origen_resultado_salida(origen_resultado_wb),

    .inmediato_entrada(inmediato_mem),
    .inmediato_salida(inmediato_wb)
);

// ==========================================
// ETAPA WB
// ==========================================

// Seleccion del dato que se escribe en rd.

assign dato_escritura_wb =
    (origen_resultado_wb == 2'b00)
        ? resultado_alu_wb :

    (origen_resultado_wb == 2'b01)
        ? dato_leido_memoria_wb :

    (origen_resultado_wb == 2'b10)
        ? pc_mas_4_wb :

        inmediato_wb;

endmodule