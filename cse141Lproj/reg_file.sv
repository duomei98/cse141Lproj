// cache memory/register file
// we have 8 registers
module reg_file #(parameter pw=3)(
  input[7:0] dat_in,
  input      clk,
  input      wr_en,           // write enable
  input 	 flag, 		  	  // value of r1
  input		 flag_en,
  input[pw:0] 	wr_addr,	  // write address pointer
              	rd_addrA,	  // read address pointers
			  	rd_addrB,
  output logic[7:0] datA_out, // read data
                    datB_out);

  logic[7:0] core[2**pw];    // 2-dim array  8 wide 8 deep

// reads are combinational
// if reading from r0, always output 0
  assign datA_out = (rd_addrA == 0) ? 8'b0 : core[rd_addrA];
  assign datB_out = (rd_addrB == 0) ? 8'b0 : core[rd_addrB];


// writes are sequential (clocked)
  always_ff @(posedge clk) begin
  	// anything but stores or no ops
    
    // flag write to r1 has priority
    if (flag_en)
      core[1] <= {7'b0, flag}; 
    // prohibits you from writing to r0 / r1 
    else if(wr_en && wr_addr != 0 && wr_addr != 1)	
      core[wr_addr] <= dat_in; 
  end 

endmodule
