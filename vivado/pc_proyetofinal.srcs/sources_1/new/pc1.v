
`timescale 1ns / 1ps

module pc1 #(
    parameter ANCHO = 32
)(
    input clok,
    input reset,
    input hab_paso,
    input [ANCHO-1:0] pc_siguiente,
    output [ANCHO-1:0] pc_actual
);

reg [ANCHO-1:0] pc_guardado;

always @(posedge clok or negedge reset) begin
    if (!reset) begin
        pc_guardado <= {ANCHO{1'b0}};
    end
    else if (hab_paso) begin
        pc_guardado <= pc_siguiente;
    end
end

assign pc_actual = pc_guardado;

endmodule

