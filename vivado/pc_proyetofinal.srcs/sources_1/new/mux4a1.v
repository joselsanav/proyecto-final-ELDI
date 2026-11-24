`timescale 1ns / 1ps

module mux4a1 #(
    parameter ANCHO = 32
)(
    input wire [ANCHO-1:0] D0,
    input wire [ANCHO-1:0] D1,
    input wire [ANCHO-1:0] D2,
    input wire [ANCHO-1:0] D3,
    input wire [1:0] sel,
    output wire [ANCHO-1:0] Y
);

    wire [ANCHO-1:0] t0;
    wire [ANCHO-1:0] t1;
    wire [ANCHO-1:0] t2;
    wire [ANCHO-1:0] t3;
    
   assign  t0= {ANCHO{~sel[1] & ~sel[0]}} & D0;
    assign t1 = {ANCHO{~sel[1] & sel[0]}} & D1;
    assign t2 = {ANCHO{sel[1] & ~sel[0]}} & D2;
   assign  t3= {ANCHO{sel[1] & sel[0]}} & D3;
   assign Y = t0 | t1 | t2 | t3;

endmodule

