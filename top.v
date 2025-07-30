`timescale 1ns / 1ps
module top(
    input clk,
    input reset,
    input btnR,//buton dreapta
    input btnL,//buton stanga
    input btnD,//buton jos
    input btnU,//buton sus
    output Hsync,
    output Vsync,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue
    );
    
    wire clk_148Mhz;
    
      design_1_wrapper design_1_wrapper_i
       (.clk_in1_0(clk),
        .clk_out1_0(clk_148Mhz),
        .reset_0(reset));
        
           vga_controllerHD vga_controllerHD_i(
        .clk(clk_148Mhz),
        .reset(reset),
        .btnU(btnU),
        .btnD(btnD),
        .btnL(btnL),
        .btnR(btnR),
        .Hsync(Hsync),
        .Vsync(Vsync),
        .vgaRed(vgaRed),
        .vgaGreen(vgaGreen),
        .vgaBlue(vgaBlue)
        );

endmodule
