module flash2sram(
    input clk50M,
    input reset,

    output reg ready,

    // Flash connections
    output [21:0] flashAddr,
	input [7:0] flashData,
	output flash_oe,
	output flash_we,
	output flash_ce,
	output reg flash_rst,

	// SRAM connections
	output [17:0] sramAddr,
	output [15:0] sramData,
	output sram_oe,
	output reg sram_we,
	output sram_ub,
	output sram_lb,
	output sram_ce
);

    reg [18:0] memAddr;

    assign sramAddr = memAddr[18:1];
    assign flashAddr = { 3'b0, memAddr };

    assign sram_oe = 1'b1;
    assign sram_ce = 1'b0;

    assign flash_oe = 1'b0;
    assign flash_we = 1'b1;
    assign flash_ce = 1'b0;

    reg [1:0] counter;
    
    assign sramData = { flashData, flashData };
    assign sram_ub  = ~memAddr[0];
    assign sram_lb  = memAddr[0];

    always @(posedge clk50M, posedge reset)
    begin
        if (reset) begin 
            counter <= 0;
            flash_rst <= 0;
        end else begin 
            counter <= counter + 2'b1;
            flash_rst <= 1;
        end
    end

    always @(posedge clk50M, posedge reset)
    begin
        
        if (reset) begin 
            memAddr <= 19'h7FFFF;
            ready <= 0;
            sram_we <= 1'b1;
        end else if (memAddr == 19'd307200) begin 
            ready <= 1;
            sram_we <= 1'b1;
        end else if (counter == 2'b01) begin 
            memAddr <= memAddr + 19'b1;
            ready <= 0;
            sram_we <= 1'b1;
        end else if (counter == 2'b10) begin
            sram_we <= 1'b0;
        end else if (counter == 2'b11 || counter == 2'b00) begin
            sram_we <= 1'b1;
        end
    end

endmodule