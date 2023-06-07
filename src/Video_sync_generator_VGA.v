`ifndef HVSYNC_GENERATOR_H
`define HVSYNC_GENERATOR_H

/*
Video sync generator, used to drive a VGA monitor.
Timing from: https://en.wikipedia.org/wiki/Video_Graphics_Array
To use:
- Wire the hsync and vsync signals to top level outputs
- Add a 3-bit (or more) "rgb" output to the top level
*/

module hvsync_generator(clk, reset, hsync, vsync, display_on, display_addr, load_shifter);

  input clk;
  input reset;
  output hsync, vsync;
  output display_on;
  output reg [18:0] display_addr;
  output load_shifter;

  // declarations for VGA sync parameters
  // horizontal constants
  parameter H_DISPLAY       = 640; // horizontal display width
  parameter H_BACK          =  45; // horizontal left border (back porch)
  parameter H_FRONT         =  20; // horizontal right border (front porch)
  parameter H_SYNC          =  95; // horizontal sync width
  // vertical constants
  parameter V_DISPLAY       = 480; // vertical display height
  parameter V_TOP           =  32; // vertical top border
  parameter V_BOTTOM        =  14; // vertical bottom border
  parameter V_SYNC          =   2; // vertical sync # lines
  // derived constants
  parameter H_SYNC_START    = H_DISPLAY + H_FRONT;
  parameter H_SYNC_END      = H_DISPLAY + H_FRONT + H_SYNC - 1;
  parameter H_MAX           = H_DISPLAY + H_BACK + H_FRONT + H_SYNC - 1;
  parameter V_SYNC_START    = V_DISPLAY + V_BOTTOM;
  parameter V_SYNC_END      = V_DISPLAY + V_BOTTOM + V_SYNC - 1;
  parameter V_MAX           = V_DISPLAY + V_TOP + V_BOTTOM + V_SYNC - 1;
  
  reg display_on, display_on_early;
  reg [9:0] hpos;
  reg [9:0] vpos;
  reg [3:0] pixel_counter;
  
  always @(posedge clk)
  begin
    if (reset) begin
      hpos <= H_MAX;
      vpos <= V_MAX;
      pixel_counter <= 4'd15;
    end else if (clk) begin
      if (hpos == H_MAX) begin
        hpos <= 0;
	pixel_counter <= 0;
        if (vpos == V_MAX) vpos <= 0;
        else vpos <= vpos + 10'b1;
    end else begin
	hpos <= hpos + 10'b1;
	pixel_counter <= pixel_counter + 4'b1;
    end
    end
  end

  assign hsync = hpos >= H_SYNC_START && hpos <= H_SYNC_END;
  assign vsync = vpos >= V_SYNC_START && vpos <= V_SYNC_END;

  assign load_shifter = (pixel_counter == 0);
  
  always @(posedge clk)
  begin
    if (clk) begin
      display_on_early <= ((hpos < H_DISPLAY-2) || (hpos == H_MAX) || (hpos  == H_MAX-1)) && (vpos < V_DISPLAY);
      display_on <= display_on_early;
    end
  end

  always @(posedge clk)
  begin
    if (reset) display_addr <= 0;
    else if (clk && (vpos == V_MAX)) display_addr <= 0;
    else if (clk && display_on_early) display_addr <= display_addr + 1;
    /*else if (clk && display_on_early && (pixel_counter == 4'd15)) display_addr <= display_addr + 1; */
  end

endmodule

`endif
