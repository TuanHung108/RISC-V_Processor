`timescale 1ns/1ps

module tb_bubble_sort;

	// clock / reset
	reg clk;
	reg rst_n;
	parameter CLOCK_CYCLE = 2;
	initial clk = 0;
	always #(CLOCK_CYCLE/2) clk = ~clk;

	integer total_error;

	// DUT <-> TB signals
	wire [31:0] pcF;
	wire [31:0] instrF;

	// TB instruction memory (word addressed)
	reg [31:0] instruction_memory [0:255];

	// Golden buffers (module scope so tasks can use)
	reg [31:0] golden_reg [0:31];
	reg [31:0] golden_dmem [0:255];

	// DUT instance (ensure instance name and ports match your top)
	riscv DUT(
		.clk(clk),
		.rst_n(rst_n),
		.instrF(instrF),
		.pcF(pcF)
	);

	// map instrF to TB imem (pcF[9:2] => word index)
	assign instrF = instruction_memory[pcF[9:2]];

	// ---------- utility tasks ----------
	task reset_imem;
		integer i;
		begin
			for (i = 0; i < 256; i = i + 1) instruction_memory[i] = 32'h00000013; // nop
		end
	endtask

	task reset_register_file;
		integer i;
		begin
			for (i = 0; i < 32; i = i + 1) DUT.core_inst.u_decode.reg_file[i] = 32'b0;
		end
	endtask

	task reset_data_memory;
		integer i;
		begin
			for (i = 0; i < 256; i = i + 1) DUT.data_memory_inst.ram[i] = 32'b0;
		end
	endtask

	// init data memory for Bubble Sort:
	task init_bubble_sort_data_memory;
		begin
			DUT.data_memory_inst.ram[2] = 32'd5;
			DUT.data_memory_inst.ram[3] = 32'd1;
			DUT.data_memory_inst.ram[4] = 32'd4;
			DUT.data_memory_inst.ram[5] = 32'd2;
			DUT.data_memory_inst.ram[6] = 32'd8;
			DUT.data_memory_inst.ram[10] = 32'd5;
		end
	endtask

	// check sorted result in data memory (quick check)
	task check_bubble_sort_result;
		integer pass;
		begin
			pass = 1;
			if (DUT.data_memory_inst.ram[2] !== 32'd1) pass = 0;
			if (DUT.data_memory_inst.ram[3] !== 32'd2) pass = 0;
			if (DUT.data_memory_inst.ram[4] !== 32'd4) pass = 0;
			if (DUT.data_memory_inst.ram[5] !== 32'd5) pass = 0;
			if (DUT.data_memory_inst.ram[6] !== 32'd8) pass = 0;

			if (pass) $display("[%0t] Bubble Sort PASS (data memory quick check)", $time);
			else begin
				$display("[%0t] Bubble Sort FAIL (data memory quick check)", $time);
				total_error = total_error + 1;
			end
		end
	endtask

	// write observed reg file (hex, one register per line)
	task write_observed_reg_file;
		input [8*256-1:0] out_path;
		integer fd;
		integer i;
		begin
			fd = $fopen(out_path, "w");
			if (fd == 0) $display("Cannot open %s for write", out_path);
			else begin
				for (i = 0; i < 32; i = i + 1) $fdisplay(fd, "%08h", DUT.core_inst.u_decode.reg_file[i]);
				$fclose(fd);
				$display("Wrote observed reg_file to %s", out_path);
			end
		end
	endtask

	// write observed data memory (hex, one word per line)
	task write_observed_dmem_file;
		input [8*256-1:0] out_path;
		integer fd;
		integer i;
		begin
			fd = $fopen(out_path, "w");
			if (fd == 0) $display("Cannot open %s for write", out_path);
			else begin
				for (i = 0; i < 256; i = i + 1) $fdisplay(fd, "%08h", DUT.data_memory_inst.ram[i]);
				$fclose(fd);
				$display("Wrote observed data_memory to %s", out_path);
			end
		end
	endtask

	// compare DUT reg_file against golden file (32 lines)
	task compare_register_file_with_golden;
		input [8*256-1:0] golden_path;
		input [8*256-1:0] observed_path;
		integer gfd;
		integer i;
		integer mismatches;
		begin
			// write observed first
			write_observed_reg_file(observed_path);

			// check golden exists
			gfd = $fopen(golden_path, "r");
			if (gfd == 0) begin
				$display("Golden reg file not found: %s -- skipping regfile comparison", golden_path);
			end else begin
				$fclose(gfd);
				// read golden into golden_reg
				$readmemh(golden_path, golden_reg);

				// compare
				mismatches = 0;
				for (i = 0; i < 32; i = i + 1) begin
					if (DUT.core_inst.u_decode.reg_file[i] !== golden_reg[i]) begin
						$display("REG MISMATCH r%0d: observed=%08h golden=%08h", i, DUT.core_inst.u_decode.reg_file[i], golden_reg[i]);
						mismatches = mismatches + 1;
					end
				end

				if (mismatches == 0) $display("Register file comparison PASS");
				else begin
					$display("Register file comparison FAIL: %0d mismatches", mismatches);
					total_error = total_error + mismatches;
				end
			end
		end
	endtask

	// compare DUT data_memory against golden file (256 lines)
	task compare_data_memory_with_golden;
		input [8*256-1:0] golden_path;
		input [8*256-1:0] observed_path;
		integer gfd;
		integer i;
		integer mismatches;
		begin
			// write observed dmem first
			write_observed_dmem_file(observed_path);

			// check golden exists
			gfd = $fopen(golden_path, "r");
			if (gfd == 0) begin
				$display("Golden dmem file not found: %s -- skipping dmem comparison", golden_path);
			end else begin
				$fclose(gfd);
				// read golden into golden_dmem
				$readmemh(golden_path, golden_dmem);

				// compare all 256 words
				mismatches = 0;
				for (i = 0; i < 256; i = i + 1) begin
					if (DUT.data_memory_inst.ram[i] !== golden_dmem[i]) begin
						// only report non-equal entries to reduce noise
						$display("DMEM MISMATCH addr[%0d]: observed=%08h golden=%08h", i, DUT.data_memory_inst.ram[i], golden_dmem[i]);
						mismatches = mismatches + 1;
					end
				end

				if (mismatches == 0) $display("Data memory comparison PASS");
				else begin
					$display("Data memory comparison FAIL: %0d mismatches", mismatches);
					total_error = total_error + mismatches;
				end
			end
		end
	endtask

	// ---------- test sequence ----------
	task test_Bubble_Sort;
		input [8*256-1:0] imem_path;
		input integer cycles;
		begin
			$display("[%0t] Starting Bubble Sort test ...", $time);

			// reset and init
			rst_n = 0;
			reset_imem();
			reset_register_file();
			reset_data_memory();
			init_bubble_sort_data_memory();

			// load program BEFORE releasing reset
			$readmemh(imem_path, instruction_memory);

			#(CLOCK_CYCLE);
			@(negedge clk) rst_n = 1;

			// run
			repeat (cycles) @(posedge clk);

			// quick data memory check
			check_bubble_sort_result();

			// compare with golden files (full comparisons)
			compare_register_file_with_golden(
				"C:/QuestaSim_Project/RISC-V-5-stage-Pipeline/sim_pipeline/Bubble_Sort/golden_reg_file_hex.txt",
				"C:/QuestaSim_Project/RISC-V-5-stage-Pipeline/sim_pipeline/Bubble_Sort/observed_reg_file_hex.txt"
			);

			compare_data_memory_with_golden(
				"C:/QuestaSim_Project/RISC-V-5-stage-Pipeline/sim_pipeline/Bubble_Sort/golden_dmem_hex.txt",
				"C:/QuestaSim_Project/RISC-V-5-stage-Pipeline/sim_pipeline/Bubble_Sort/observed_dmem_hex.txt"
			);

		end
	endtask

	// ---------- main ----------
	initial begin
		total_error = 0;
		$display("==========================================");
		$display("RISC-V 5-Stage Pipeline Automated Testbench");
		$display("==========================================");

		// // waveform dump
		// $dumpfile("tb_bu.vcd");
		// $dumpvars(0, tb_pipeline_automated);bb

		// run bubble sort test
		test_Bubble_Sort("C:/QuestaSim_Project/RISC-V-5-stage-Pipeline/sim_pipeline/Bubble_Sort/imem_hext.txt", 1000);

		$display("==========================================");
		$display("Total error count: %0d", total_error);
		$display("==========================================");

		if (total_error == 0) $display("All test cases Pass!");
		else $display("Pipeline Test Failed!");

		$finish;
	end

endmodule