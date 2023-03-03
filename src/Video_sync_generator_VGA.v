
`ifndef HVSYNC_GENERATOR_H
`define HVSYNC_GENERATOR_H

/*
Video sync generator, used to drive a VGA monitor.
Timing from: https://en.wikipedia.org/wiki/Video_Graphics_Array
To use:
- Wire the hsync and vsync signals to top level outputs
- Add a 3-bit (or more) "rgb" output to the top level
*/

module hvsync_generator(clk, reset, hsync, vsync, display_on, hpos, vpos, display_addr);

  input clk;
  input reset;
  output hsync, vsync;
  output display_on;
  output reg [9:0] hpos;
  output reg [9:0] vpos;
  output reg [18:0] display_addr;

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
  
  always @(posedge clk, posedge reset)
  begin
    if (reset) begin
      hpos <= H_MAX;
      vpos <= V_MAX;
    end else begin
      if (hpos == H_MAX) begin 
        hpos <= 0;
        if (vpos == V_MAX) vpos <= 0;
        else vpos <= vpos + 10'b1;
      end else hpos <= hpos + 10'b1;
    end
  end

  assign hsync = hpos >= H_SYNC_START && hpos <= H_SYNC_END;
  assign vsync = vpos >= V_SYNC_START && vpos <= V_SYNC_END;

  //assign display_on_early = (hpos < H_DISPLAY-1 && hpos == (H_DISPLAY+H_BACK+H_FRONT+H_SYNC-1)) 
  //               && ((vpos < V_DISPLAY-1) && vpos == (V_DISPLAY+V_TOP+V_BOTTOM+V_SYNC-1));
  
  always @(posedge clk, posedge reset)
  begin
    if (reset) begin
      display_on_early <= 0;
      display_on <= 0;
    end else begin 
      display_on_early <= ((hpos < H_DISPLAY-1) || (hpos == H_MAX)) && (vpos < V_DISPLAY);
      display_on <= display_on_early;
    end
  end

  always @(posedge clk, posedge reset)
  begin
    if (reset) display_addr <= 0;
    else if (vpos == V_MAX) display_addr <= 0;
    else if (display_on_early) display_addr <= display_addr + 1;
  end

endmodule

`endif