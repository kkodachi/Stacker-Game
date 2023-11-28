`timescale 1ns / 1ps

module block_controller(
    input clk, //this clock must be a slow enough clock to view the changing positions of the objects
    input rst,
    input BTNC,
    input bright,
    input [9:0] hCount, vCount, // horizontal count, vertical count
    output reg [11:0] rgb,

    localparam
        START = 5'b00000;
        STACK = 5'b00010;
        UPDATE = 5'b00100;
        CHECK = 5'b01000;
        TEMP = 5'b10000;
    );

    wire block_fill;
    reg [3:0] block_count = 3'b100; // keeps track of how many blocks left
    reg [1:0] right;
    reg [9:0] xposL, xposR, ypos; // values to dictate center of block
    reg [9:0] xprevL, xprevR;
    reg [1:0] first;
    reg [7:0] state;
    reg [4:0] height;
    reg [11:0] difference;
    reg [9:0] stack [0:9][0:1]; // 10-bit wide, 10 row 2 col 2-d array to store previous blocks

    parameter BLACK = 12'b0000_0000_0000;
    parameter RED   = 12'b1111_0000_0000;
    parameter WHITE = 12'b1111_1111_1111;

    always@ (*) begin
        // figure out block
        // set background back ???
        if(~bright)
            rgb = BLACK;
        else if (hCount >= stack[0][0] && hCount <= stack[0][1] && vCount <= 514 && vCount > 504) // check if in any blocks
            rgb = RED;
        else if (hCount >= stack[1][0] && hCount <= stack[1][1] && vCount <= 504 && vCount > 494) 
            rgb = RED;
        else if (hCount >= stack[2][0] && hCount <= stack[2][1] && vCount <= 494 && vCount > 484)
            rgb = RED;
        else if (hCount >= stack[3][0] && hCount <= stack[3][1] && vCount <= 484 && vCount > 474)
            rgb = RED;
        else if (hCount >= stack[4][0] && hCount <= stack[4][1] && vCount <= 474 && vCount > 464)
            rgb = RED;
        else if (hCount >= stack[5][0] && hCount <= stack[5][1] && vCount <= 464 && vCount > 454)
            rgb = RED;
        else if (hCount >= stack[6][0] && hCount <= stack[6][1] && vCount <= 454 && vCount > 444)
            rgb = RED;
        else if (hCount >= stack[7][0] && hCount <= stack[7][1] && vCount <= 444 && vCount > 434)
            rgb = RED;
        else if (hCount >= stack[8][0] && hCount <= stack[8][1] && vCount <= 434 && vCount > 424)
            rgb = RED;
        else if (hCount >= stack[9][0] && hCount <= stack[9][1] && vCount <= 424 && vCount > 414)
            rgb = RED;
        else
            rgb = WHITE;
    end


    always@(posedge clk, posedge rst)
    begin
        if (rst)
        begin
            xposL <= 144; // left edge of sprite
            xposR <= 184; // right edge of sprite todo
            ypos <= 514; // bottom of screen
            right <= 1'b1;
            first <= 1'b1;
            height <= 0;
            difference <= 0;
            state <= START;
        end
        else if (clk) begin
            case(state)
                START:
                    xposL <= 144; // left edge of sprite
                    xposR <= 184; // right edge of sprite todo
                    ypos <= 514; // bottom of screen
                    right = 1'b1;
                    first = 1'b1;
                    height <= 0;
                    difference <= 0;
                    state <= START;
                    // correct way to initliaze array?
                    for (int i = 0; i < 10; i++) begin
                        for (int j = 0; j < 2; j++) begin
                            stack[i][j] = 0;
                        end
                    end
                    if (BTNC) begin 
                        state <= STACK;
                    end
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
                        if (xposR >= 790)
                            right <= 1'b0;
                            xposR <= xposR - 10;
                            xposL <= xposL - 10;
                    end
                    else if (right == 1'b0) begin
                        xposL <= xposL - 10;
                        xposR <= xposR - 10;
                        if (xposL <= 154)
                            right <= 1'b1;
                            xposR <= xposR + 10;
                            xposL <= xposL + 10;
                    end
                    end
                UPDATE:
                    // check boundary
                    if (xposL >= xprevR || xposR <= xprevL) begin
                        state <= FAIL;
                        block_count = 0;
                    end
                    else if (xposL > xprevL) begin
                        xposR <= xprevR;
                    end
                    else begin // xposL <= xprev
                        xposL <= xprevL;
                    end
                CHECK:
                    difference = xposR - xposL;

                    if (difference < 10 || height == 9) begin
                        state <= START;
                    end
                    else begin
                        xprevL <= xposL;
                        xprevR <= xposR;
                        ypos <= ypos + 10;
                        xposL <= 144;
                        xposR <= 144 + difference;
                        state <= STACK;
                        right <= 1'b1; // not sure
                        stack[height][0] <= xposL;
                        stack[height][1] <= xposR;
                        height <= height + 1;
                    end
                TEMP:

            endcase
        end
    end
endmodule