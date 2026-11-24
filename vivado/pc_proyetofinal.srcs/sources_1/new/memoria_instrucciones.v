`timescale 1ns / 1ps

module memoria_instrucciones (
    input wire [31:0] direccion_instruccion,
    output wire [31:0] instruccion_bus
);

reg [31:0] memoria [0:255];

integer i;

initial begin
    for (i = 0; i < 256; i = i + 1)
        memoria[i] = 32'h00000013;

    $readmemh("programa.mem", memoria);
end

assign instruccion_bus =
    (direccion_instruccion[31:10] == 22'b0 &&
     direccion_instruccion[1:0] == 2'b00)
    ? memoria[direccion_instruccion[9:2]]
    : 32'h00000013;

endmodule