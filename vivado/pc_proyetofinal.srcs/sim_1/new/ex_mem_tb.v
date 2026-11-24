`timescale 1ns / 1ps

module ex_mem_tb;

reg clok = 0;
reg reset = 1;
reg hab_paso = 0;
reg anular_etapa = 0;

reg [31:0] resultado_alu_entrada = 0;
reg [31:0] dato_para_memoria_entrada = 0;
reg [31:0] pc_mas_4_entrada = 0;
reg [4:0] rd_entrada = 0;
reg [2:0] funct3_entrada = 0;
reg escribir_registro_entrada = 0;
reg escribir_memoria_entrada = 0;
reg [1:0] origen_resultado_entrada = 0;
reg [31:0] inmediato_entrada = 0;

wire [31:0] resultado_alu_salida;
wire [31:0] dato_para_memoria_salida;
wire [31:0] pc_mas_4_salida;
wire [4:0] rd_salida;
wire [2:0] funct3_salida;
wire escribir_registro_salida;
wire escribir_memoria_salida;
wire [1:0] origen_resultado_salida;
wire [31:0] inmediato_salida;

ex_mem dut (
    .clok(clok),
    .reset(reset),
    .hab_paso(hab_paso),
    .anular_etapa(anular_etapa),

    .resultado_alu_entrada(resultado_alu_entrada),
    .resultado_alu_salida(resultado_alu_salida),

    .dato_para_memoria_entrada(dato_para_memoria_entrada),
    .dato_para_memoria_salida(dato_para_memoria_salida),

    .pc_mas_4_entrada(pc_mas_4_entrada),
    .pc_mas_4_salida(pc_mas_4_salida),

    .rd_entrada(rd_entrada),
    .rd_salida(rd_salida),

    .funct3_entrada(funct3_entrada),
    .funct3_salida(funct3_salida),

    .escribir_registro_entrada(escribir_registro_entrada),
    .escribir_registro_salida(escribir_registro_salida),

    .escribir_memoria_entrada(escribir_memoria_entrada),
    .escribir_memoria_salida(escribir_memoria_salida),

    .origen_resultado_entrada(origen_resultado_entrada),
    .origen_resultado_salida(origen_resultado_salida),

    .inmediato_entrada(inmediato_entrada),
    .inmediato_salida(inmediato_salida)
);

always #5 clok = ~clok;

task comprobar_cero;
begin
    if ({resultado_alu_salida, dato_para_memoria_salida,
         pc_mas_4_salida, rd_salida, funct3_salida,
         escribir_registro_salida, escribir_memoria_salida,
         origen_resultado_salida, inmediato_salida} !== 140'b0)
        $fatal(1, "ERROR: el registro no esta limpio");
end
endtask

initial begin

    // Reset inicial
    #2 reset = 0;
    #1 comprobar_cero();
    $display("Reset inicial OK");


    // Captura de una instruccion STORE
    @(negedge clok);
    reset = 1;
    hab_paso = 1;

    resultado_alu_entrada = 108;
    dato_para_memoria_entrada = 42;
    pc_mas_4_entrada = 104;
    rd_entrada = 0;
    funct3_entrada = 3'b010;
    escribir_registro_entrada = 0;
    escribir_memoria_entrada = 1;
    origen_resultado_entrada = 2'b00;
    inmediato_entrada = 8;

    @(posedge clok);
    #1;

    if (resultado_alu_salida !== 108 ||
        dato_para_memoria_salida !== 42 ||
        pc_mas_4_salida !== 104 ||
        rd_salida !== 0 ||
        funct3_salida !== 3'b010 ||
        escribir_registro_salida !== 0 ||
        escribir_memoria_salida !== 1 ||
        origen_resultado_salida !== 2'b00 ||
        inmediato_salida !== 8)
        $fatal(1, "ERROR en captura");

    $display("Captura OK");


    // Retencion
    @(negedge clok);
    hab_paso = 0;
    resultado_alu_entrada = 999;
    dato_para_memoria_entrada = 999;

    @(posedge clok);
    #1;

    if (resultado_alu_salida !== 108 ||
        dato_para_memoria_salida !== 42)
        $fatal(1, "ERROR en retencion");

    $display("Retencion OK");


    // Flush debe funcionar incluso con hab_paso=0
    @(negedge clok);
    anular_etapa = 1;

    @(posedge clok);
    #1;

    comprobar_cero();

    $display("Flush OK");


    // Recuperacion y transporte del inmediato LUI
    @(negedge clok);
    anular_etapa = 0;
    hab_paso = 1;

    inmediato_entrada = 32'h12345000;
    rd_entrada = 5'd5;
    escribir_registro_entrada = 1;
    escribir_memoria_entrada = 0;
    origen_resultado_entrada = 2'b11;

    @(posedge clok);
    #1;

    if (inmediato_salida !== 32'h12345000 ||
        rd_salida !== 5'd5 ||
        escribir_registro_salida !== 1 ||
        escribir_memoria_salida !== 0 ||
        origen_resultado_salida !== 2'b11)
        $fatal(1, "ERROR en recuperacion");

    $display("Recuperacion OK");


    // Reset asincrono entre flancos
    @(negedge clok);
    reset = 0;

    #1;
    comprobar_cero();

    $display("Reset asincrono OK");
    $display("PRUEBAS BASICAS EX/MEM SUPERADAS");

    $finish;

end

endmodule
