`timescale 1ns / 1ps

module nextpc_tb;

parameter ANCHO = 32;

reg clok;
reg reset;
reg hab_paso;

reg [ANCHO-1:0] inmediato;
reg [ANCHO-1:0] resultado_jalr;
reg [1:0] seleccion_pc;

wire [ANCHO-1:0] pc_actual;
wire [ANCHO-1:0] pc_siguiente;

pc1 #(.ANCHO(ANCHO)) uut (
    .clok(clok),
    .reset(reset),
    .hab_paso(hab_paso),
    .pc_siguiente(pc_siguiente),
    .pc_actual(pc_actual)
);

next_pc_logic #(.ANCHO(ANCHO)) testeo (
    .pc_actual(pc_actual),
    .inmediato(inmediato),
    .resultado_jalr(resultado_jalr),
    .seleccion_pc(seleccion_pc),
    .pc_siguiente(pc_siguiente)
);

initial begin
    clok = 0;
    forever #5 clok = ~clok;
end

initial begin

    reset = 0;
    hab_paso = 0;
    inmediato = 0;
    resultado_jalr = 0;
    seleccion_pc = 2'b00;

    #10;

    hab_paso = 1;
    reset = 1;
    inmediato = 32'd8;
    resultado_jalr = 32'd33;
    seleccion_pc = 2'b00;

    #10;

    seleccion_pc = 2'b10;

    #10;

    seleccion_pc = 2'b10;
    hab_paso = 0;

    #10;

    seleccion_pc = 2'b01;

    #10;

    hab_paso = 1;
    seleccion_pc = 2'b01;

    #10;

    seleccion_pc = 2'b01;

    #10;

    seleccion_pc = 2'b11;

    #12;

    seleccion_pc = 2'b10;
    reset = 0;

    #10;

    $finish;

end

endmodule
