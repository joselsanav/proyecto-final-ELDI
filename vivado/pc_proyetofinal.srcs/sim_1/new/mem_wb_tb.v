`timescale 1ns / 1ps

module mem_wb_tb;

reg clok = 0;
reg reset = 1;
reg hab_paso = 0;
reg anular_etapa = 0;

reg [31:0] resultado_alu_entrada = 0;
reg [31:0] dato_leido_memoria_entrada = 0;
reg [31:0] pc_mas_4_entrada = 0;
reg [4:0] rd_entrada = 0;
reg escribir_registro_entrada = 0;
reg [1:0] origen_resultado_entrada = 0;
reg [31:0] inmediato_entrada = 0;

wire [31:0] resultado_alu_salida;
wire [31:0] dato_leido_memoria_salida;
wire [31:0] pc_mas_4_salida;
wire [4:0] rd_salida;
wire escribir_registro_salida;
wire [1:0] origen_resultado_salida;
wire [31:0] inmediato_salida;

mem_wb dut (
    .clok(clok),
    .reset(reset),
    .hab_paso(hab_paso),
    .anular_etapa(anular_etapa),

    .resultado_alu_entrada(resultado_alu_entrada),
    .resultado_alu_salida(resultado_alu_salida),

    .dato_leido_memoria_entrada(dato_leido_memoria_entrada),
    .dato_leido_memoria_salida(dato_leido_memoria_salida),

    .pc_mas_4_entrada(pc_mas_4_entrada),
    .pc_mas_4_salida(pc_mas_4_salida),

    .rd_entrada(rd_entrada),
    .rd_salida(rd_salida),

    .escribir_registro_entrada(escribir_registro_entrada),
    .escribir_registro_salida(escribir_registro_salida),

    .origen_resultado_entrada(origen_resultado_entrada),
    .origen_resultado_salida(origen_resultado_salida),

    .inmediato_entrada(inmediato_entrada),
    .inmediato_salida(inmediato_salida)
);

always #5 clok = ~clok;

task comprobar_cero;
begin
    if ({resultado_alu_salida, dato_leido_memoria_salida,
         pc_mas_4_salida, rd_salida,
         escribir_registro_salida,
         origen_resultado_salida,
         inmediato_salida} !== 136'b0)
        $fatal(1, "ERROR: registro no reiniciado");
end
endtask

initial begin

    // Reset inicial
    #2 reset = 0;
    #1 comprobar_cero();
    $display("RESET OK");


    // Captura
    @(negedge clok);
    reset = 1;
    hab_paso = 1;

    resultado_alu_entrada = 32'd50;
    dato_leido_memoria_entrada = 32'd100;
    pc_mas_4_entrada = 32'd104;
    rd_entrada = 5'd5;
    escribir_registro_entrada = 1;
    origen_resultado_entrada = 2'b01;
    inmediato_entrada = 32'h12345000;

    @(posedge clok);
    #1;

    if (resultado_alu_salida !== 50 ||
        dato_leido_memoria_salida !== 100 ||
        pc_mas_4_salida !== 104 ||
        rd_salida !== 5 ||
        escribir_registro_salida !== 1 ||
        origen_resultado_salida !== 2'b01 ||
        inmediato_salida !== 32'h12345000)
        $fatal(1, "ERROR EN CAPTURA");

    $display("CAPTURA OK");


    // Retencion
    @(negedge clok);
    hab_paso = 0;
    resultado_alu_entrada = 999;
    dato_leido_memoria_entrada = 999;

    @(posedge clok);
    #1;

    if (resultado_alu_salida !== 50 ||
        dato_leido_memoria_salida !== 100)
        $fatal(1, "ERROR EN RETENCION");

    $display("RETENCION OK");


    // Anulacion
    @(negedge clok);
    anular_etapa = 1;

    @(posedge clok);
    #1;

    comprobar_cero();

    $display("FLUSH OK");


    // Recuperacion
    @(negedge clok);
    anular_etapa = 0;
    hab_paso = 1;

    resultado_alu_entrada = 75;
    dato_leido_memoria_entrada = 150;
    pc_mas_4_entrada = 204;
    rd_entrada = 10;
    escribir_registro_entrada = 1;
    origen_resultado_entrada = 2'b11;
    inmediato_entrada = 32'hABCDE000;

    @(posedge clok);
    #1;

    if (resultado_alu_salida !== 75 ||
        dato_leido_memoria_salida !== 150 ||
        pc_mas_4_salida !== 204 ||
        rd_salida !== 10 ||
        escribir_registro_salida !== 1 ||
        origen_resultado_salida !== 2'b11 ||
        inmediato_salida !== 32'hABCDE000)
        $fatal(1, "ERROR EN RECUPERACION");

    $display("RECUPERACION OK");


    // Reset asincrono
    @(negedge clok);
    reset = 0;
    #1;

    comprobar_cero();

    $display("RESET ASINCRONO OK");
    $display("MEM/WB: PRUEBAS BASICAS SUPERADAS");

    $finish;

end

endmodule