`timescale 1ns / 1ps

module block_controller(
    input clk, //this clock must be a slow enough clock to view the changing positions of the objects
    input rst,
    input BTNC,
    input [9:0] hCount, vCount,
    output reg [11:0] rgb,
    output reg [11:0] background

    localparam
    INI =8'b00000001;
    MENU = 8'b00000010;
    STACK = 8'b00000100;
    CHECK = 8'b00001000;
    WAIT  = 8'b00010000;
    SUCCESS = 8'b00100000;
    FAIL = 8'b0100000;
    DONE = 8'b10000000;
    );

    wire block_fill;
    reg [3:0] block_count = 3'b100; // keeps track of how many blocks left
    reg [1:0] right;
    reg [9:0] xposL, xposR, ypos; // values to dictate center of block
    reg [9:0] xprevL, xprevR;
    reg [1:0] first;
    reg [7:0] state;

    parameter BLACK = 12'b0000_0000_0000;
    parameter RED   = 12'b1111_0000_0000;
    parameter WHITE = 12'b1111_1111_1111;

    always@ (*) begin
        // figure out block
        // set background back ???
    end

    assign block_fill=vCount>=(ypos-5) && vCount<=(ypos+5) && hCount>=(xpos-5) && hCount<=(xpos+5);

    always@(posedge clk, posedge rst)
    begin
        if (rst)
        begin
            xposL <= 144; // correct values ???
            xposR <= 144 + (12 * block_count);
            ypos <= ; // ???
            right = 1'b1;
            first = 1'b1;
        end
        else if (clk) begin
            case(state)
                INI:
                MENU:
                STACK:
                    begin
                    if (BTNC) begin
                        if (first == 1'b1) begin
                            first <= 1'b0;
                            xprevL <= xposL;
                            xprevR <= xposR;
                        end
                        else begin
                            state <= CHECK;
                        end
                    end
                    if (right == 1'b1) begin
                        xposL <= xposL + 10;// changed to 8 ???
                        xposR <= xposR + 10;
                        if (xposR >= 800)
                            right <= 1'b0;
                            xposR <= xposR - 10;
                            xposL <= xposL - 10;
                    end
                    else if (right == 1'b0) begin
                        xposL <= xposL - 10;
                        xposR <= xposR - 10;
                        if (xposL >= 150)
                            right <= 1'b1;
                            xposR <= xposR + 10;
                            xposL <= xposL + 10;
                    end
                    end
                CHECK:
                    // check boundary
                        if(xposL<xprevL){
                            //This means we overextended on the left side
                            xposL
                        }
                    // 
                WAIT:
                SUCCESS:
                FAIL:
                DONE:
            endcase
        end
    end
endmodule