//setting the module for the ALU
module alu (input  logic [31:0] a,b,
	    input  logic [3:0]    f,
		input logic [4:0] shamt,
            output logic [31:0]   y);

	logic[31:0] s;
//block of statements 
	always_comb
		begin
			case(f)
				4'b0000  : y = a & b;                       // a AND b
			        4'b0100  : y = a & (~b+1);                  // a AND ~b
				4'b0001  : y = a | b;                       // a OR b
				4'b0101  : y = a | (~b+1);                  // a OR ~b
			        4'b0010  : y = a + b;                       // a ADD b
			        4'b0110  : y = a + (~b+1);                  // a SUB b
				4'b0111  : begin s = a+~b+1;
    				
                    				 if(s[31]) y=32'h0000_0001; else y=32'h0000_0000; 
                  			  end                              //STL
				4'b0011:  y=b<<(shamt) ; 
				4'b1110:  y=b>>(shamt) ; 
       				default : y=0;
       			endcase	
		end
endmodule 