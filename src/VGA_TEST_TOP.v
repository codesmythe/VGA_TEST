
module VGA_TEST_TOP( 
    input clk50M,
	input n_reset,
    output hsync,
	output vsync,
	output VGA_SYNC,
	output VGA_CLK,
	output display_on,
	output [3:0] red,
	output [3:0] green,
	output [3:0] blue,

	// flash connections

	output [21:0] flashAddr,
	input [7:0] flashData,
	output flash_oe,
	output flash_we,
	output flash_ce,
	output flash_rst,

	// SRAM connections
	output [17:0] sramAddr,
	inout [15:0] sramData,
	output sram_oe,
	output sram_we,
	output sram_ub,
	output sram_lb,
	output sram_ce
);

wire [9:0] hpos;
wire [9:0] vpos;
wire reset;
wire ready, n_ready;
wire a0;

wire [18:0] display_addr;

reg clk25M;

assign VGA_SYNC = 1'b0;
assign VGA_CLK = clk25M;

assign reset = ~n_reset;
assign n_ready = ~ready;

assign sramAddr =  ready ? display_addr[18:1] : sramAddrForCopy;
assign sramData =  ready ? 16'bz : sramDataForCopy;
assign sram_we  =  ready ? 1'b1 : 1'b0;
assign sram_oe  =  ready ? 1'b0 : 1'b1;
assign sram_ub  =  ready ? 1'b0 : sram_ub_for_copy;
assign sram_lb  =  ready ? 1'b0 : sram_lb_for_copy;

assign a0 = display_addr[0];


/*
always @(*)
begin
	if ({a1,a0} == 2'b11) begin
		red   <= { sramData[12], sramData[15] };
	    green <= { sramData[13], sramData[15] };
	    blue  <= { sramData[14], sramData[15] };
	end else if ({a1, a0} == 2'b10) begin
	    red   <= { sramData[ 8], sramData[11] };
	    green <= { sramData[ 9], sramData[11] };
	    blue  <= { sramData[10], sramData[11] };
	end else if ({a1, a0} == 2'b01) begin
		red   <= { sramData[ 4], sramData[ 7] };
		green <= { sramData[ 5], sramData[ 7] };
		blue  <= { sramData[ 6], sramData[ 7] };
	end else if ({a1, a0} == 2'b00) begin
		red   <= { sramData[ 1], sramData[ 0] };
		green <= { sramData[ 2], sramData[ 0] };
		blue  <= { sramData[ 3], sramData[ 0] };
	end
end
*/

// For a color RGB 3-3-2 image.

assign red   = display_on ? { a0 ? sramData[15:13] : sramData[7:5], 1'b0} : 4'b0;
assign green = display_on ? { a0 ? sramData[12:10] : sramData[4:2], 1'b0} : 4'b0;
assign blue  = display_on ? { a0 ? sramData[9:8]   : sramData[1:0], 2'b0} : 4'b0;

// For a monochrome image
//assign red   = display_on ? { a0 ? sramData[15:12] : sramData[7:4] } : 4'b0;
//assign green = display_on ? { a0 ? sramData[15:12] : sramData[7:4] } : 4'b0;
//assign blue  = display_on ? { a0 ? sramData[15:12] : sramData[7:4] } : 4'b0;

wire [17:0] sramAddrForCopy;
wire [15:0] sramDataForCopy;
wire sram_we_for_copy, sram_oe_for_copy, sram_ub_for_copy, sram_lb_for_copy;

hvsync_generator hvsync(
   .clk(clk50M), .clk25en(clk25M), .reset(~ready), .hsync(hsync), .vsync(vsync), .display_on(display_on), .hpos(hpos), .vpos(vpos), 
   .display_addr(display_addr)
);

flash2sram test_mod(
    .clk50M(clk50M),
    .reset(reset),

    .ready(ready),

    // Flash connections
    .flashAddr(flashAddr),
	.flashData(flashData),
	.flash_oe(flash_oe),
	.flash_we(flash_we),
	.flash_ce(flash_ce),
	.flash_rst(flash_rst),

	// SRAM connections
	.sramAddr(sramAddrForCopy),
	.sramData(sramDataForCopy),
	.sram_oe(sram_oe_for_copy),
	.sram_we(sram_we_for_copy),
	.sram_ub(sram_ub_for_copy),
	.sram_lb(sram_lb_for_copy),
	.sram_ce(sram_ce)
);

always @(posedge clk50M, posedge n_ready)
begin
    if (n_ready)begin
       clk25M <= 1'b0;
	end else begin
       clk25M <= ~clk25M;
	end
end


endmodule
