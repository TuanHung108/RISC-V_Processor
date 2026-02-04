module tb_pipeline_automated;

	reg clk;
	reg rst_n;

	integer total_error;

	parameter CLOCK_CYCLE = 2;

	initial clk = 0;
	always #(CLOCK_CYCLE/2) clk = ~clk;

	// Tín hiệu nối với DUT
	wire [31:0] pcF;
	wire [31:0] instrF;

	// Instruction memory giả lập trong testbench
	reg [31:0] instruction_memory [0:255];
	// Golden register file
	reg [31:0] golden_register_file [0:31];

	// DUT
	riscv DUT(
		.clk(clk),
		.rst_n(rst_n),
		.instrF(instrF),
		.pcF(pcF)
	);

	// Kết nối instrF từ bộ nhớ testbench
	assign instrF = instruction_memory[pcF[9:2]];

	// Reset register file (để khởi tạo quan sát rõ ràng khi cần)
	task reset_register_file;
		integer i;
		begin
			for (i = 0; i < 32; i = i + 1) begin
				DUT.core_inst.u_decode.reg_file[i] = 32'b0;
			end
		end
	endtask

	// Reset instruction memory
	task reset_imem;
		integer i;
		begin
			for (i = 0; i < 256; i = i + 1) begin
				instruction_memory[i] = 32'h00000013; // nop (addi x0, x0, 0)
			end
		end
	endtask

	// Reset data memory (nếu có data memory trong pipeline)
	task reset_data_memory;
    integer i;
    begin
        for (i = 0; i < 256; i = i + 1) begin
            DUT.data_memory_inst.ram[i] = 32'b0;
        end
    end
endtask

	// Dump register file hiện tại của DUT ra file hex (tiện đối chiếu golden)
	task dump_register_file_hex;
		input [8*256-1:0] out_path;
		integer fd;
		integer i;
		begin
			fd = $fopen(out_path, "w");
			if (fd == 0) begin
				$display("Cannot open %s for write", out_path);
			end else begin
				for (i = 0; i < 32; i = i + 1) begin
					$fdisplay(fd, "%08h", DUT.core_inst.u_decode.reg_file[i]);
				end
				$fclose(fd);
				$display("Dumped DUT reg_file to %s", out_path);
			end
		end
	endtask

	// Task tổng quát để test bất kỳ kiểu lệnh nào
	task test_instruction_type;
		input [8*256-1:0] test_name;
		input [8*256-1:0] imem_path;
		input [8*256-1:0] golden_path;
		input [8*256-1:0] observed_path;
		input integer cycles;
		integer error_count;
		integer i;
		begin
			error_count = 0;

			$display("%t Starting %s test...", $time, test_name);

			// Reset hệ thống
			rst_n = 0;
			reset_imem();
			reset_register_file();
			reset_data_memory();
			#(CLOCK_CYCLE);
			@(negedge clk) rst_n = 1;

			// Nạp chương trình vào instruction_memory
			$readmemh(imem_path, instruction_memory);

			// Chạy một số chu kỳ đủ lớn để chương trình thực thi
			repeat (cycles) @(posedge clk);

			// Nạp golden và so sánh
			$readmemh(golden_path, golden_register_file);
			for (i = 0; i < 32; i = i + 1) begin
				// Kiểm tra nếu có bit X trong giá trị
				if (^DUT.core_inst.u_decode.reg_file[i] === 1'bx || ^golden_register_file[i] === 1'bx) begin
					$display("Register x%0d contains X! DUT = %h, Golden = %h", i, DUT.core_inst.u_decode.reg_file[i], golden_register_file[i]);
					error_count = error_count + 1;
				end else if (DUT.core_inst.u_decode.reg_file[i] != golden_register_file[i]) begin
					$display("Register mismatch at x%0d: DUT = %h, Golden = %h", i, DUT.core_inst.u_decode.reg_file[i], golden_register_file[i]);
					error_count = error_count + 1;
				end else if (DUT.core_inst.u_decode.reg_file[i] != 32'b0) begin
					$display("Register correct at x%0d: DUT = %h, Golden = %h", i, DUT.core_inst.u_decode.reg_file[i], golden_register_file[i]);
    			end
			end

			if(error_count == 0) begin
				$display("%t %s test passed!", $time, test_name);
			end else begin
				$display("%t %s test failed with %0d errors.", $time, test_name, error_count);
				total_error = total_error + error_count;
			end

			// Ghi lại kết quả thanh ghi quan sát được
			dump_register_file_hex(observed_path);
		end
	endtask

	// Chạy test R-type
	task test_R_type;
		begin
			test_instruction_type(
				"R-type",
				"./sim_pipeline/R-type/imem_hex.txt",
				"./sim_pipeline/R-type/golden_reg_file_hex.txt",
				"./sim_pipeline/R-type/observed_reg_file_hex.txt",
				300
			);
		end
	endtask

	// Chạy test B-type
	task test_B_type;
		begin
			test_instruction_type(
				"B-type",
				"./sim_pipeline/B-type/imem_hex.txt",
				"./sim_pipeline/B-type/golden_reg_file_hex.txt",
				"./sim_pipeline/B-type/observed_reg_file_hex.txt",
				300
			);
		end
	endtask

	// Chạy test U-type
	task test_U_type;
		begin
			test_instruction_type(
				"U-type",
				"./sim_pipeline/U-type/imem_hex.txt",
				"./sim_pipeline/U-type/golden_reg_file_hex.txt",
				"./sim_pipeline/U-type/observed_reg_file_hex.txt",
				300
			);
		end
	endtask

	// Chạy test I-type (arithmetic_logic)
	task test_I_type_arithmetic_logic;
		begin
			test_instruction_type(
				"I-type (arithmetic_logic)",
				"./sim_pipeline/I-type(arithmetic_logic)/imem_hex.txt",
				"./sim_pipeline/I-type(arithmetic_logic)/golden_reg_file.txt",
				"./sim_pipeline/I-type(arithmetic_logic)/observed_reg_file_hex.txt",
				300
			);
		end
	endtask

	// Chạy test I-type (JALR)
	task test_I_type_JALR;
		begin
			test_instruction_type(
				"I-type (JALR)",
				"./sim_pipeline/I-type(JALR)/imem_hex_jalr.txt",
				"./sim_pipeline/I-type(JALR)/golden_reg_file_jalr.txt",
				"./sim_pipeline/I-type(JALR)/observed_reg_file_hex.txt",
				300
			);
		end
	endtask

	// Chạy test I-type (load)
	task test_I_type_load;
		begin
			test_instruction_type(
				"I-type (load)",
				
				"./sim_pipeline/I-type/load/imem_hex_lw.txt",
				"./sim_pipeline/I-type/load/golden_reg_file_lw.txt",
				"./sim_pipeline/I-type/load/observed_reg_file_hex.txt",
				300
			);
		end
	endtask

	// Chạy test J-type
	task test_J_type;
		begin
			test_instruction_type(
				"J-type",
				"./sim_pipeline/J-type/imem_hex.txt",
				"./sim_pipeline/J-type/golden_reg_file_hex.txt",
				"./sim_pipeline/J-type/observed_reg_file_hex.txt",
				300
			);
		end
	endtask

	// Chạy test S-type
	task test_S_type;
		begin
			test_instruction_type(
				"S-type",
				"./sim_pipeline/S-type/imem_hex.txt",
				"./sim_pipeline/S-type/golden_reg_file_hex.txt",
				"./sim_pipeline/S-type/observed_reg_file_hex.txt",
				300
			);
		end
	endtask

	// Chạy test Hazard
	task test_Hazard;
		begin
			test_instruction_type(
				"Hazard",
				"./sim_pipeline/Hazard/imem_hex.txt",
				"./sim_pipeline/Hazard/golden_reg_file_hex.txt",
				"./sim_pipeline/Hazard/observed_reg_file_hex.txt",
				300
			);
		end
	endtask

	// Khởi tạo data memory cho Bubble Sort
	task init_bubble_sort_data_memory;
    begin
        // array: .word 5, 1, 4, 2, 8 tại địa chỉ 0x08
        DUT.data_memory_inst.ram[2] = 32'd5; // 0x08
        DUT.data_memory_inst.ram[3] = 32'd1; // 0x0C
        DUT.data_memory_inst.ram[4] = 32'd4; // 0x10
        DUT.data_memory_inst.ram[5] = 32'd2; // 0x14
        DUT.data_memory_inst.ram[6] = 32'd8; // 0x18
        // n: .word 5 tại địa chỉ 0x28
        DUT.data_memory_inst.ram[10] = 32'd5; // 0x28
    end
endtask

	// Chạy test Bubble Sort
	task test_Bubble_Sort;
    begin
        test_instruction_type_bubble_sort(
            "Bubble Sort",
            "./sim_pipeline/Bubble_Sort/imem_hex.txt",
            "./sim_pipeline/Bubble_Sort/golden_reg_file_hex.txt",
            "./sim_pipeline/Bubble_Sort/observed_reg_file_hex.txt",
            1000
        );
    end
endtask

// Task riêng cho Bubble Sort để khởi tạo data memory
	task test_instruction_type_bubble_sort;
		input [8*256-1:0] test_name;
		input [8*256-1:0] imem_path;
		input [8*256-1:0] golden_path;
		input [8*256-1:0] observed_path;
		input integer cycles;
		integer error_count;
		integer i;
		begin
			error_count = 0;

			$display("%t Starting %s test...", $time, test_name);

			// Reset hệ thống
			rst_n = 0;
			reset_imem();
			reset_register_file();
			reset_data_memory();
			init_bubble_sort_data_memory(); // <-- chỉ Bubble Sort mới gọi
			#(CLOCK_CYCLE);
			@(negedge clk) rst_n = 1;

			// Nạp chương trình vào instruction_memory
			$readmemh(imem_path, instruction_memory);

			// Chạy một số chu kỳ đủ lớn để chương trình thực thi
			repeat (cycles) @(posedge clk);

			// Nạp golden và so sánh
			$readmemh(golden_path, golden_register_file);
			for (i = 0; i < 32; i = i + 1) begin
				if (^DUT.core_inst.u_decode.reg_file[i] === 1'bx || ^golden_register_file[i] === 1'bx) begin
					$display("Register x%0d contains X! DUT = %h, Golden = %h", i, DUT.core_inst.u_decode.reg_file[i], golden_register_file[i]);
					error_count = error_count + 1;
				end else if (DUT.core_inst.u_decode.reg_file[i] != golden_register_file[i]) begin
					$display("Register mismatch at x%0d: DUT = %h, Golden = %h", i, DUT.core_inst.u_decode.reg_file[i], golden_register_file[i]);
					error_count = error_count + 1;
				end else if (DUT.core_inst.u_decode.reg_file[i] != 32'b0) begin
					$display("Register correct at x%0d: DUT = %h, Golden = %h", i, DUT.core_inst.u_decode.reg_file[i], golden_register_file[i]);
				end
			end

			if(error_count == 0) begin
				$display("%t %s test passed!", $time, test_name);
			end else begin
				$display("%t %s test failed with %0d errors.", $time, test_name, error_count);
				total_error = total_error + error_count;
			end

			dump_register_file_hex(observed_path);
		end
	endtask

	initial begin
		total_error = 0;

		$display("==========================================");
		$display("RISC-V 5-Stage Pipeline Automated Testbench");
		$display("==========================================");

		// Chạy tất cả các test
		test_R_type();
		test_B_type();
		test_U_type();
		test_I_type_arithmetic_logic();
		test_I_type_JALR();
		test_I_type_load();
		test_J_type();
		test_S_type();
		test_Hazard();
		// test_Bubble_Sort();

		$display("==========================================");
		$display("Total error count: %0d", total_error);
		$display("==========================================");

		if(total_error == 0) begin
			$display("All test cases Pass!\n");
		end else begin
			$display("Pipeline Test Failed!\n");
		end

		$finish;
	end

endmodule
