`timescale 1ns / 1ps

module cpu_bus (
    input wire clok,
    input wire reset,

    input wire [31:0] instruccion_bus,
    output wire [31:0] direccion_instruccion,

    input wire [31:0] dato_lectura_bus,
    input wire fallo_direccion_bus,

    output wire [31:0] direccion_datos,
    output wire [31:0] dato_escritura_bus,
    output wire escribir_memoria_bus,
    output wire leer_memoria_bus,
    output wire [3:0] habilitar_bytes,
    output wire acceso_desalineado,

    output wire [31:0] pc_observado,
    output reg detenido,
    output reg [2:0] motivo_detencion,
    output reg [31:0] pc_detencion
);

// ==========================================
// SEÑALES DEL PIPELINE
// ==========================================

wire [31:0] pc_actual;
wire [31:0] pc_siguiente;
wire [31:0] pc_secuencial;

wire detener_pipeline;
wire tomar_salto_ex;
wire [31:0] destino_salto_ex;
wire salto_efectivo;

wire registrar_detencion;
wire fallo_ex;
wire fallo_mem;
wire destino_desalineado_ex;

wire instruccion_valida_ex;
wire instruccion_ilegal_ex;
wire es_fence_ex;
wire es_ecall_ex;
wire es_ebreak_ex;

// ==========================================
// ETAPA IF
// ==========================================

wire [31:0] instruccion_if;

// ==========================================
// ETAPA ID
// ==========================================

wire [31:0] pc_id;
wire [31:0] instruccion_id;
wire [31:0] inmediato_id;

wire [31:0] valor_rs1_id;
wire [31:0] valor_rs2_id;
wire [31:0] valor_rs1_id_preparado;
wire [31:0] valor_rs2_id_preparado;

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

// ==========================================
// ETAPA EX
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

wire [1:0] seleccion_rs1;
wire [1:0] seleccion_rs2;

wire [31:0] valor_rs1_ex_real;
wire [31:0] valor_rs2_ex_real;

wire [31:0] operando_a;
wire [31:0] operando_b;
wire [31:0] resultado_alu_ex;
wire zero_ex;

// ==========================================
// ETAPA MEM
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

wire solicitar_lectura_mem;
wire [31:0] dato_leido_memoria_mem;
wire [31:0] dato_forward_mem;

// ==========================================
// ETAPA WB
// ==========================================

wire [31:0] resultado_alu_wb;
wire [31:0] dato_leido_memoria_wb;
wire [31:0] pc_mas_4_wb;
wire [31:0] inmediato_wb;

wire [4:0] rd_wb;
wire escribir_registro_wb;
wire [1:0] origen_resultado_wb;
wire [31:0] dato_escritura_wb;

// ==========================================
// ETAPA IF
// ==========================================

assign pc_observado = pc_actual;
assign direccion_instruccion = pc_actual;
assign instruccion_if = instruccion_bus;

pc1 #(.ANCHO(32)) contador_programa (
    .clok(clok),
    .reset(reset),

    .hab_paso(
        !detenido &&
        !registrar_detencion &&
        (!detener_pipeline || salto_efectivo)
    ),

    .pc_siguiente(pc_siguiente),
    .pc_actual(pc_actual)
);

next_pc_logic siguiente_pc (
    .pc_actual(pc_actual),
    .inmediato(32'b0),
    .resultado_jalr(32'b0),
    .seleccion_pc(2'b00),
    .pc_siguiente(pc_secuencial)
);

assign pc_siguiente =
    salto_efectivo
    ? destino_salto_ex
    : pc_secuencial;

// ==========================================
// REGISTRO IF/ID
// ==========================================

if_id registro_if_id (
    .clok(clok),
    .reset(reset),

    .hab_paso(!detenido && !detener_pipeline),

    .anular_etapa(
        salto_efectivo ||
        registrar_detencion ||
        detenido
    ),

    .pc_entrada(pc_actual),
    .instruccion_entrada(instruccion_if),

    .pc_salida(pc_id),
    .instruccion_salida(instruccion_id)
);

// ==========================================
// ETAPA ID
// ==========================================

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

    .operacion_alu(operacion_alu_id),

    .instruccion_valida(),
    .es_fence(),
    .es_ecall(),
    .es_ebreak(),
    .instruccion_ilegal()
);

// ==========================================
// GENERADOR DE INMEDIATOS
// ==========================================

immgen generador_inmediatos (
    .instruccion(instruccion_id),
    .tipo_inmediato(tipo_inmediato_id),
    .inmediato_salida(inmediato_id)
);

// ==========================================
// BANCO DE REGISTROS
// ==========================================

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
// BYPASS WB HACIA ID
// ==========================================

assign valor_rs1_id_preparado =
    (
        escribir_registro_wb &&
        (rd_wb != 5'b00000) &&
        (rd_wb == instruccion_id[19:15])
    )
    ? dato_escritura_wb
    : valor_rs1_id;

assign valor_rs2_id_preparado =
    (
        escribir_registro_wb &&
        (rd_wb != 5'b00000) &&
        (rd_wb == instruccion_id[24:20])
    )
    ? dato_escritura_wb
    : valor_rs2_id;

// ==========================================
// DETECCION DE RIESGOS
// ==========================================

unidad_riesgos control_riesgos (
    .instruccion_id(instruccion_id),

    .rd_ex(instruccion_ex[11:7]),
    .escribir_registro_ex(escribir_registro_ex),
    .origen_resultado_ex(origen_resultado_ex),

    .detener_pipeline(detener_pipeline)
);

// ==========================================
// REGISTRO ID/EX
// ==========================================

id_ex registro_id_ex (
    .clok(clok),
    .reset(reset),

    .hab_paso(1'b1),

    .anular_etapa(
        salto_efectivo ||
        detener_pipeline ||
        registrar_detencion ||
        detenido
    ),

    .pc_entrada(pc_id),
    .instruccion_entrada(instruccion_id),

    .valor_rs1_entrada(valor_rs1_id_preparado),
    .valor_rs2_entrada(valor_rs2_id_preparado),
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
// UNIDAD DE FORWARDING
// ==========================================

unidad_forwarding control_forwarding (
    .rs1_ex(instruccion_ex[19:15]),
    .rs2_ex(instruccion_ex[24:20]),

    .rd_mem(rd_mem),
    .rd_wb(rd_wb),

    .escribir_registro_mem(escribir_registro_mem),
    .escribir_registro_wb(escribir_registro_wb),

    .origen_resultado_mem(origen_resultado_mem),

    .seleccion_rs1(seleccion_rs1),
    .seleccion_rs2(seleccion_rs2)
);

// ==========================================
// RESULTADO DISPONIBLE EN MEM
// ==========================================

assign dato_forward_mem =
    (origen_resultado_mem == 2'b00)
        ? resultado_alu_mem :

    (origen_resultado_mem == 2'b10)
        ? pc_mas_4_mem :

    (origen_resultado_mem == 2'b11)
        ? inmediato_mem :

        32'b0;

// ==========================================
// OPERANDOS CON FORWARDING
// ==========================================

assign valor_rs1_ex_real =
    (seleccion_rs1 == 2'b10)
        ? dato_forward_mem :

    (seleccion_rs1 == 2'b01)
        ? dato_escritura_wb :

        valor_rs1_ex;

assign valor_rs2_ex_real =
    (seleccion_rs2 == 2'b10)
        ? dato_forward_mem :

    (seleccion_rs2 == 2'b01)
        ? dato_escritura_wb :

        valor_rs2_ex;

// ==========================================
// ETAPA EX
// ==========================================

assign operando_a =
    alu_usa_pc_ex
    ? pc_ex
    : valor_rs1_ex_real;

assign operando_b =
    tipo_seg_operando_ex
    ? inmediato_ex
    : valor_rs2_ex_real;

ALU #(.ANCHO(32)) unidad_alu (
    .A(operando_a),
    .B(operando_b),

    .operacion_alu(operacion_alu_ex),

    .resultado(resultado_alu_ex),
    .zero(zero_ex)
);

// ==========================================
// UNIDAD DE SALTOS
// ==========================================

unidad_saltos control_saltos (
    .pc_instruccion(pc_ex),
    .inmediato(inmediato_ex),

    .valor_rs1(valor_rs1_ex_real),
    .valor_rs2(valor_rs2_ex_real),

    .funct3(instruccion_ex[14:12]),

    .salto_condicional(salto_condicional_ex),
    .salto(salto_ex),
    .jalr(jalr_ex),

    .tomar_salto(tomar_salto_ex),
    .destino_salto(destino_salto_ex)
);

// ==========================================
// VALIDACION DE INSTRUCCIONES EN EX
// ==========================================

control_top validacion_ex (
    .instruccion(instruccion_ex),

    .instruccion_valida(instruccion_valida_ex),
    .es_fence(es_fence_ex),
    .es_ecall(es_ecall_ex),
    .es_ebreak(es_ebreak_ex),
    .instruccion_ilegal(instruccion_ilegal_ex)
);

// ==========================================
// DETECCION DE FALLOS
// ==========================================

assign destino_desalineado_ex =
    tomar_salto_ex &&
    (destino_salto_ex[1:0] != 2'b00);

assign fallo_ex =
    instruccion_ilegal_ex ||
    es_ecall_ex ||
    es_ebreak_ex ||
    destino_desalineado_ex;

// Se detectan tanto accesos desalineados
// como direcciones fuera del mapa de memoria.

assign fallo_mem =
    acceso_desalineado || fallo_direccion_bus;

assign registrar_detencion =
    !detenido && (fallo_mem || fallo_ex);

assign salto_efectivo =
    tomar_salto_ex &&
    !registrar_detencion &&
    !detenido;

// ==========================================
// REGISTRO DE DETENCION
// ==========================================

// Codigos internos:
// 1 = Instruccion ilegal
// 2 = ECALL
// 3 = EBREAK
// 4 = Salto desalineado
// 5 = LOAD desalineado
// 6 = STORE desalineado
// 7 = Direccion de datos fuera del mapa

always @(posedge clok or negedge reset) begin

    if (!reset) begin
        detenido <= 1'b0;
        motivo_detencion <= 3'b000;
        pc_detencion <= 32'b0;
    end

    else if (registrar_detencion) begin

        detenido <= 1'b1;

        if (fallo_mem) begin

            pc_detencion <= pc_mas_4_mem - 32'd4;

            if (fallo_direccion_bus)
                motivo_detencion <= 3'd7;

            else if (escribir_memoria_mem)
                motivo_detencion <= 3'd6;

            else
                motivo_detencion <= 3'd5;

        end

        else begin

            pc_detencion <= pc_ex;

            if (instruccion_ilegal_ex)
                motivo_detencion <= 3'd1;

            else if (es_ecall_ex)
                motivo_detencion <= 3'd2;

            else if (es_ebreak_ex)
                motivo_detencion <= 3'd3;

            else
                motivo_detencion <= 3'd4;

        end

    end

end

// ==========================================
// REGISTRO EX/MEM
// ==========================================

ex_mem registro_ex_mem (
    .clok(clok),
    .reset(reset),

    .hab_paso(1'b1),

    .anular_etapa(
        registrar_detencion || detenido
    ),

    .resultado_alu_entrada(resultado_alu_ex),
    .resultado_alu_salida(resultado_alu_mem),

    .dato_para_memoria_entrada(valor_rs2_ex_real),
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

assign solicitar_lectura_mem =
    escribir_registro_mem &&
    (origen_resultado_mem == 2'b01);

acceso_memoria unidad_acceso_memoria (
    .direccion_alu(resultado_alu_mem),
    .dato_para_memoria(dato_para_memoria_mem),
    .funct3(funct3_mem),

    .escribir_memoria(escribir_memoria_mem),
    .leer_memoria(solicitar_lectura_mem),

    .dato_lectura_bus(dato_lectura_bus),

    .direccion_datos(direccion_datos),
    .dato_escritura_bus(dato_escritura_bus),

    .escribir_memoria_bus(escribir_memoria_bus),
    .leer_memoria_bus(leer_memoria_bus),

    .habilitar_bytes(habilitar_bytes),

    .dato_leido_memoria(dato_leido_memoria_mem),
    .acceso_desalineado(acceso_desalineado)
);

// ==========================================
// REGISTRO MEM/WB
// ==========================================

mem_wb registro_mem_wb (
    .clok(clok),
    .reset(reset),

    .hab_paso(1'b1),

    .anular_etapa(
        fallo_mem || detenido
    ),

    .resultado_alu_entrada(resultado_alu_mem),
    .resultado_alu_salida(resultado_alu_wb),

    .dato_leido_memoria_entrada(dato_leido_memoria_mem),
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

assign dato_escritura_wb =
    (origen_resultado_wb == 2'b00)
        ? resultado_alu_wb :

    (origen_resultado_wb == 2'b01)
        ? dato_leido_memoria_wb :

    (origen_resultado_wb == 2'b10)
        ? pc_mas_4_wb :

        inmediato_wb;

endmodule