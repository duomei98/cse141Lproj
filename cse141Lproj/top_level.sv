// sample top level design
module top_level(
  input        clk, reset, req, 
  output logic done);
  parameter D = 12,             // program counter width
    A = 4;             		    // ALU command bit width
  wire[D-1:0] prog_ctr; 			
              
  // flags for R1 (catch-all flag register)
  // carryout, shift out, cmp out
  logic  	  flag_in, 
  		      flag_out;				
  
  wire        RegDst,			// write in place or not
  			  Branch,			// conditional Branch enable
  			  Jump,				// unconditional Jump enable
   			  MemtoReg,
         	  MemWrite,
          	  ALUSrc,			// immediate switch
    		  flag_en,	  		// enable for R1
  			  RegWrite;	
  
  wire[A-1:0] alu_cmd;			// 4 bits; 16 ALU commands
  
  // instruction breakdown 
  wire [8:0]    mach_code;      // machine code
  wire [2:0]    opcode;
  wire [1:0]    rd_2bit;		// src1 and dest reg
  wire [1:0]    rs_2bit;		// src2 reg, only for r-type
  wire [1:0]    funct; 
  wire signed [7:0]    immed;	// 4-bit immediate, sign_ext to 8 bits
  wire [D-1:0]  offset;         // 6-bit offset, sign_ext to 12 bits
 
  // datA: rd (r4-r7), datB: rs (r0-r3)
  wire[7:0]   datA, datB,		// from RegFile
  			  mux1,				// write back to rd (def) or rs
  			  mux3,				// output of memory or reg
			  rslt;             // alu output
  
  wire signed [7:0] mux2;		// imm or reg output to alu
  
  // address pointers to reg_file; map from rs_2bit and rt_2bit
  wire[2:0] rd_addrA, rd_adrB;  
  
  // wires for output of memory and write back to reg
  wire [7:0] mem_out;
  
  // jump if either instruction is unconditional jump or we meet conditions for Branch
  assign PCSrc = Jump || (Branch && flag_out);

// fetch subassembly
  PC #(.D(D)) 					  // D: PC width
  pc1 (
    // inputs 
    .reset(reset), 
    .clk(clk), 
    .req(req),
    .reljump_en(PCSrc),  // remove the absolute jump enable
    .offset(offset), 
  	 // outputs
    .prog_ctr(prog_ctr));   

  // contains machine code
  instr_ROM ir1(
    // input 
    .prog_ctr(prog_ctr),
    // output
    .mach_code(mach_code));
    
  // decode machine code
  assign opcode  = mach_code[8:6];  // 3 bits opcode
  assign rd_2bit = mach_code[5:4];  // 2 bits rd (r4–r7 → addr 4–7)
  assign rs_2bit = mach_code[3:2];  // 2 bits rs (r0–r3 → addr 0–3)
  assign funct   = mach_code[1:0];  // 2 bits funct (r-type)
  
  // 4 bits immediate, sign extend to 8 bits (i-type)
  assign immed   = {{4{mach_code[3]}},mach_code[3:0]}; 
  // 6 bits offset, sign extend to 12 bits (j-type)
  assign offset  = {{6{mach_code[5]}},mach_code[5:0]};

  // map the registers
  assign rd_addrA = {1'b1, rd_2bit};    // rd (4–7)
  assign rd_addrB = {1'b0, rs_2bit};    // rs (0–3)
  
  // mux that decides write in place if RegDst = 0, don't if = 1
  assign mux1 = RegDst ? rd_addrB: rd_addrA; 
  
  // control decoder
  Control ctl1(
    // inputs
    .opcode(opcode), 
    .funct(funct),
    // outputs
    .RegDst(RegDst), 
    .Branch(Branch),  		// conditional Branch
    .Jump(Jump),			// unconditional Jump
    .MemtoReg(MemtoReg), 
    .MemWrite(MemWrite),  
    .ALUSrc(ALUSrc),  
    .ALUOp(alu_cmd),
    .flag_en(flag_en),		// enable flag update based on operation
    .RegWrite(RegWrite)      
  );
  
  /* for movr, addrA is dest reg. For all other 
	instructions, addrB is dest reg*/
  // register file
  reg_file #(.pw(3)) rf1(
    // inputs
    .clk(clk),
    .wr_en(RegWrite), 
    .flag_en(flag_en),		// wired from Control
    .rd_addrA(rd_addrA), 
    .rd_addrB(rd_addrB), 
    .wr_addr (mux1), 
    .dat_in(mux3),	   		// loads, most ops
    .flag(flag_in),			// r1: flag register
    // outputs
    .datA_out(datA), 
    .datB_out(datB));  
  
  // mux2 decides immediate or register data for ALU input
  assign mux2 = ALUSrc? immed : datB;
  
  alu alu1(
    // inputs
    .alu_cmd(alu_cmd),	    // from output of Control
    .inA(datA), 
    .inB(mux2),
    // outputs
    .rslt(rslt),
    .out(flag_in));			// all flags get written to one wire
  
  // mux to  write reg output or memory output back to reg
  assign mux3 = MemtoReg ? mem_out : rslt;

  // Write data to memory if MemWrite is enabled
  dat_mem dm1(
    // inputs
    .dat_in(datA),  		// from reg_file
    .clk(clk),
	.wr_en(MemWrite), 		// stores
    .addr(immed),			// absolute memory address
    // output 
    .dat_out(mem_out));		

// registered flags from ALU
  always_ff @(posedge clk or posedge reset) begin
    if (reset) 
      flag_out <= 'b0;
    else begin
      if (flag_en)
      	/* flag_out should be the stored value of flag_in so we can 
        	use it in a later cycle*/
        flag_out <= flag_in;
    end
  end

  assign done = prog_ctr == 128;
 
endmodule