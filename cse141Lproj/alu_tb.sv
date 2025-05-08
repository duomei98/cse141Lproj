// used chatgpt to help with writing testbench
module alu_tb;
  // datB is 
  logic [7:0] a, b;
  logic [3:0] alu_cmd;
  logic [7:0] rslt;
  logic 	  flag_in;

  alu dut (
    .alu_cmd(alu_cmd),
    .inA(a),
    .inB(b),
    .rslt(rslt),
    .out(flag_in));

  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    // $dumpfile("alu.vcd");
    // $dumpvars(0, alu_tb);

    // Test ADD: alu_cmd = 0000
    a = 8'd18; b = 8'd49; alu_cmd = 'b0000; #10;
    $display("TEST: ADD, no c_out");
    $display("Expected: a=18 b=49 rslt=67 out=0 | Actual: a=%0d b=%0d rslt=%0d out=%0d", a, b, rslt, flag_in);
    $display();
    
    a = 8'd255; b = 8'd1; alu_cmd = 'b0000; #10;
    $display("TEST: ADD with c_out 1");
    $display("Expected: a=255 b=1 rslt=0 out=1 | Actual: a=%0d b=%0d rslt=%0d out=%0d", a, b, rslt, flag_in);
    $display();
    
    a = 8'd255; b = 8'd255; alu_cmd = 'b0000; #10;
    $display("TEST: ADD with c_out 2");
    $display("Expected: a=255 b=255 rslt=254 out=1 | Actual: a=%0d b=%0d rslt=%0d out=%0d", a, b, rslt, flag_in);
    $display();
    
    // Test SUB: alu_cmd = 0001
	
    // Test NOT: alu_cmd = 0010
    
    // Test CMP: alu_cmd = 0011
    a = 8'd27; b = 8'd27; alu_cmd = 'b0011; #10;
    $display("TEST: CMP equals");
    $display("Expected: a=27 b=27 rslt=0 out=1 | Actual: a=%0d b=%0d rslt=%0d out=%0d", a, b, rslt, flag_in);
    $display();
    
    // Test CMP: alu_cmd = 0011
    a = 8'd27; b = 8'd26; alu_cmd = 'b0011; #10;
    $display("TEST: CMP not equals");
    $display("Expected: a=27 b=26 rslt=0 out=0 | Actual: a=%0d b=%0d rslt=%0d out=%0d", a, b, rslt, flag_in);
    $display();
    
    // Test MOVL: alu_cmd = 0100
    a = 8'd27; b = 8'd26; alu_cmd = 'b0100; #10;
    $display("TEST: MOVL");
    $display("Expected: a=27 b=26 rslt=26 out=0 | Actual: a=%0d b=%0d rslt=%0d out=%0d", a, b, rslt, flag_in);
    $display();
    
    // Test MOVR: alu_cmd = 0101
    a = 8'd24; b = 8'd26; alu_cmd = 'b0101; #10;
    $display("TEST: MOVR");
    $display("Expected: a=24 b=26 rslt=24 out=0 | Actual: a=%0d b=%0d rslt=%0d out=%0d", a, b, rslt, flag_in);
    $display();
    
    // Test AND: alu_cmd = 0110
    a = 8'b0010_1111; b = 8'b1011_0010; alu_cmd = 'b0110; #10;
    $display("TEST: AND");
    $display("Expected: a=0010_1111 b=1011_0010 rslt=0010_0010 out=0 | Actual: a=%0b b=%0b rslt=%0b out=%0d", a, b, rslt, flag_in);
    $display();
    
    a = 8'b1011_1001; b = 8'b1111_1111; alu_cmd = 'b0110; #10;
    $display("TEST: AND: mask");
    $display("Expected: a=1011_1001 b=1111_1111 rslt=1011_1001 out=0 | Actual: a=%0b b=%0b rslt=%0b out=%0d", a, b, rslt, flag_in);
    $display();
    
    // Test OR: alu_cmd = 0111
    
    a = 8'b1011_1001; b = 8'b0; alu_cmd = 'b0110; #10;
    $display("TEST: AND: clear");
    $display("Expected: a=1011_1001 b=0 rslt=0 out=0 | Actual: a=%0b b=%0b rslt=%0b out=%0d", a, b, rslt, flag_in);
    $display();
    
    // Test: ADDI
    
    // Test: SH
    
    $finish;
  end
endmodule
