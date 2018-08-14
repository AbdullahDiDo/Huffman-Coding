module aludec(input  logic [5:0] funct,
			input  logic [1:0] aluop,
		        output logic [3:0] alucontrol,
		        output logic jr,
			output logic mult,
			output logic div,
			output logic movlo,
			output logic movhi);
	always_comb
		case(aluop)
			2'b00:begin alucontrol <= 3'b010; jr<=0;end // add
			2'b01:begin alucontrol <= 3'b110; jr<=0; end // sub
			2'b11 :begin alucontrol <= 3'b111; jr<=0;end //slti 
			default: case(funct) // RTYPE
  					6'b100000: begin alucontrol <= 4'b0010;jr<=1'b0;mult<=1'b0;div<=1'b0;movlo=1'b0;movhi=1'b0;end // ADD
					6'b100010: begin alucontrol <= 4'b0110;jr<=1'b0;mult<=1'b0;div<=1'b0;movlo=1'b0;movhi=1'b0;end // SUB
					6'b100100: begin alucontrol <= 4'b0000;jr<=1'b0;mult<=1'b0;div<=1'b0;movlo=1'b0;movhi=1'b0;end // AND
					6'b100101: begin alucontrol <= 4'b0001;jr<=1'b0;mult<=1'b0;div<=1'b0;movlo=1'b0;movhi=1'b0;end // OR
					6'b101010: begin alucontrol <= 4'b0111;jr<=1'b0;mult<=1'b0;div<=1'b0;movlo=1'b0;movhi=1'b0;end // SLT
					6'b001000: begin alucontrol <= 4'b0000;jr<=1'b1;mult<=1'b0;div<=1'b0;movlo=1'b0;movhi=1'b0;end //jr
     					6'b011000: begin alucontrol <= 4'b0000; jr<=1'b0;mult<=1'b1;div<=1'b0;movlo=1'b0;movhi=1'b0;end // mult
					6'b011010: begin alucontrol <=4'b0000; jr<=1'b0; mult<=1'b0;div<=1'b1;movlo=1'b0;movhi=1'b0;end//div
					6'b010000: begin alucontrol <=4'b0000; jr<=1'b0;mult<=1'b0;div<=1'b0;movlo=1'b0;movhi=1'b1;end//mfhi
					6'b010010: begin alucontrol <=4'b0000; jr<=1'b0;mult<=1'b0;div<=1'b0;movlo=1'b1;movhi=1'b0;end//mflo
					6'b000000: begin alucontrol <=4'b0011; jr<=1'b0;mult<=1'b0;div<=1'b0;movlo=1'b0;movhi=1'b0;end//sll
					6'b000010: begin alucontrol <=4'b1110; jr<=1'b0;mult<=1'b0;div<=1'b0;movlo=1'b0;movhi=1'b0;end//srl
      					default:   begin alucontrol <= 4'bxxxx;jr<=1'b0;mult<=1'b0;div<=1'b0;movlo=1'b0;movhi=1'b0;end // ???
				endcase
		endcase
endmodule