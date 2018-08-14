module maindec(input logic [5:0] op,
	       output logic memtoreg, memwrite,
	       output logic branch, alusrc,
	       output logic [1:0]regdst,
	       output logic  regwrite,
	       output logic jump,
	       output logic [1:0] aluop,
	       output logic bne,
	       output logic jal,
	       output logic lb,
 	       output logic sb );
				
	logic [13:0] controls;
	assign {regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, aluop,bne,jal,lb,sb} = controls;
	always_comb
		case(op)
			6'b000000: controls <= 14'b10100000100000; //Rtype
			6'b100011: controls <= 14'b10010010000000; //LW
			6'b101011: controls <= 14'b00010100000000; //SW
			6'b000100: controls <= 14'b00001000010000; //BEQ
			6'b000101: controls <= 14'b00000000011000; //BNE
			6'b001000: controls <= 14'b10010000000000; //ADDI
			6'b000010: controls <= 14'b00000001000000; //J
			6'b000011: controls <= 14'b11000001000100; //JAL
			6'b001010: controls <=14'b10010000110000;  //slti
			6'b100000: controls <=14'b10010010000010; //lb
			6'b101000: controls <=14'b00010100000001; //sb 
			default:   controls <= 14'bxxxxxxxxxxxxxx; //???
		endcase
endmodule