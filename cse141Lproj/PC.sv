// program counter
// our ISA only supports both relative jumps
module PC #(parameter D=12)(
  input reset,					// synchronous reset
        clk,
  		req,
		reljump_en,             // rel. jump enable
  input       [D-1:0] offset,	// how far/where to jump
  output logic[D-1:0] prog_ctr
);

  always_ff @(posedge clk) begin
    if(reset)
	  prog_ctr <= '0;
    else if (req) begin
      if (reljump_en && (offset != 'b0))
        // target = prog_ctr + offset
        prog_ctr <= prog_ctr + offset;
        // no absolute addressing
  	  else
	  	prog_ctr <= prog_ctr + 1;
    end 
  end 

endmodule