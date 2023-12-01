`timescale 1ns / 1ps

module block_controller(
    input clk, //this clock must be a slow enough clock to view the changing positions of the objects
    input rst,
    input BTNC,
    input bright,
    input [9:0] hCount, vCount, // horizontal count, vertical count
    output reg [11:0] rgb
    );
    localparam
        START    = 5'b00001,
        STACK    = 5'b00010,
        UPDATE   = 5'b00100,
        CHECK    = 5'b01000,
        DEBOUNCE = 5'b10000;

    wire block_fill;
    reg [1:0] left;
    reg [9:0] xposL, xposR, ypos; // values to dictate center of block
    reg [9:0] xprevL, xprevR;
    reg [1:0] first;
    reg [1:0] second;
    reg [7:0] state;
    reg [4:0] height;
    reg [11:0] difference;
    reg [9:0] stack [0:9][0:1]; // 10-bit wide, 10 row 2 col 2-d array to store previous blocks
    integer i, j;

    parameter BLACK     = 12'b0000_0000_0000;
	parameter BLUE      = 12'b0000_1111_1111;
    parameter RED       = 12'b1111_0000_0000;
    parameter WHITE     = 12'b1111_1111_1111;

    always@ (*) begin
        if(~bright)
            rgb = BLACK;
        else if (hCount >= xposL && hCount <= xposR && vCount <= ypos && vCount > ypos - 50)
            rgb = RED;
        else if (hCount >= stack[0][0] && hCount <= stack[0][1] && vCount <= 514 && vCount > 464) // check if in any blocks
            rgb = RED;
        else if (hCount >= stack[1][0] && hCount <= stack[1][1] && vCount <= 464 && vCount > 414) 
            rgb = RED;
        else if (hCount >= stack[2][0] && hCount <= stack[2][1] && vCount <= 414 && vCount > 364)
            rgb = RED;
        else if (hCount >= stack[3][0] && hCount <= stack[3][1] && vCount <= 364 && vCount > 314)
            rgb = RED;
        else if (hCount >= stack[4][0] && hCount <= stack[4][1] && vCount <= 314 && vCount > 264)
            rgb = RED;
        else if (hCount >= stack[5][0] && hCount <= stack[5][1] && vCount <= 264 && vCount > 214)
            rgb = RED;
        else if (hCount >= stack[6][0] && hCount <= stack[6][1] && vCount <= 214 && vCount > 164)
            rgb = RED;
        else if (hCount >= stack[7][0] && hCount <= stack[7][1] && vCount <= 164 && vCount > 114)
            rgb = RED;
        else if (hCount >= stack[8][0] && hCount <= stack[8][1] && vCount <= 114 && vCount > 64)
            rgb = RED;
        else if (hCount >= stack[9][0] && hCount <= stack[9][1] && vCount <= 64 && vCount > 14)
            rgb = RED;
        else
            rgb = BLUE;
    end


    always@(posedge clk, posedge rst)
    begin
        if (rst)
        begin
            xposL <= 144; // left edge of sprite
            xposR <= 244; // right edge of sprite todo
            ypos <= 514; // bottom of screen
            left <= 1'b1;
            first <= 1'b1;
            height <= 0;
            difference <= 0;
            state <= START;
            second <= 0;
        end
        else if (clk) begin
            case(state)
                START:
                begin
                    xposL <= 144; // left edge of sprite
                    xposR <= 244; // right edge of sprite todo
                    ypos <= 514; // bottom of screen
                    left <= 1'b1;
                    first <= 1'b1;
                    height <= 0;
                    difference <= 0;
                    second <= 0;
					
                    for (i = 0; i < 10; i=i+1)begin
                        for (j = 0; j < 2; j=j+1)begin
                            stack[i][j] = 0;
                        end
                    end

                    if (BTNC) begin 
                        state <= DEBOUNCE;
                    end
                end
                STACK:
                begin
                    if (BTNC) begin
                        if (first == 1'b1) begin
                            first <= 1'b0;
                            xprevL <= xposL;
                            xprevR <= xposR;
							xposL <= 144;
							xposR <= 244;
							height <= height + 1;
							ypos <= ypos - 50;
							stack[height][0] <= xposL;
							stack[height][1] <= xposR;
							left <= 1'b1;
							second <= 1'b1;
							state <= DEBOUNCE;
                        end
                        else begin
                            state <= DEBOUNCE;
                        end
                    end
                    else if (left == 1'b1) begin
                        xposL <= xposL - 1;
                        xposR <= xposR - 1;
                        if (xposR >= 783)
                            left <= 1'b0;
                            xposR <= xposR + 1;
                            xposL <= xposL + 1;
                    end
                    else if (left == 1'b0) begin
                        xposL <= xposL + 1;
                        xposR <= xposR + 1;
                        if (xposL <= 144)
                            left <= 1'b1;
                            xposR <= xposR - 1;
                            xposL <= xposL - 1;
                    end
                end
                DEBOUNCE:
                begin
                    if(BTNC)
                    begin
                    end
					else if(first)begin
						state <= STACK;
					end
					else if(second)begin
						second <= 0;
						state <= STACK;
					end
                    else if(!BTNC)begin
                        state <= UPDATE;
                    end
                end
                UPDATE:
				begin
                    // check boundary
                    if (xposL >= xprevR || xposR <= xprevL) begin
                        state <= START;
                    end
                    else if (xposL > xprevL) begin
                        xposR <= xprevR;
						state <= CHECK;
                    end
                    else begin // xposL <= xprev
                        xposL <= xprevL;
						state <= CHECK;
                    end
				end
                CHECK:
				begin
                    difference = xposR - xposL;
                    if ((difference < 10) || (height == 9)) begin
                        state <= START;
                    end
                    else begin
                        xprevL <= xposL;
                        xprevR <= xposR;
                        ypos <= ypos - 50;
                        xposL <= 144;
                        xposR <= 144 + difference;
                        state <= STACK;
                        left <= 1'b1;
                        stack[height][0] <= xposL;
                        stack[height][1] <= xposR;
                        height <= height + 1;
                    end
				end
            endcase
        end
    end
endmodule