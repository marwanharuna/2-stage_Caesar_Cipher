// -----------------------------------------------------------------------------
// Testbench of Caesar's cipher module for debug and corner cases check
// -----------------------------------------------------------------------------
module caesar_ciph_tb_checks;

//clock time.
  reg clk = 1'b0;
  always #5 clk = !clk;
  
  //reset signal
  reg rst_n = 1'b0;
  event reset_deassertion;
  
  initial begin
    #12.8 rst_n = 1'b1;
    -> reset_deassertion;
  end
  
  reg        shift_dir;
  reg  [4:0] shift_N_1;
  reg  [4:0] shift_N_2;
  reg  [7:0] ptxt_char;
  reg     input_valid;
  reg     mode;
  wire [7:0] ctxt_char;
  wire    invalid_key;
  wire    invalid_char;
  wire    ready;

  caesar_cipher INSTANCE_NAME (
      .clk                      (clk)
    ,.rst_n                     (rst_n)
    ,.ptxt_valid                (input_valid)
    ,.mode                      (mode)
    ,.key_shift_dir           (shift_dir)
    ,.key_shift_num_1           (shift_N_1)
    ,.key_shift_num_2           (shift_N_2)
    ,.ptxt_char                 (ptxt_char)
    ,.ctxt_char                 (ctxt_char)
    ,.err_invalid_key_shift_num (invalid_key)
    ,.err_invalid_ptxt_char     (invalid_char)
    ,.ctx_ready                 (ready)
  );
  
  reg [7:0] EXPECTED_GEN;
  reg [7:0] EXPECTED_CHECK;
  reg [7:0] EXPECTED_QUEUE [$];
  
  localparam NUL_CHAR = 8'h00;
  
  localparam UPPERCASE_A_CHAR = 8'h41;
  localparam UPPERCASE_Z_CHAR = 8'h5A;
  localparam LOWERCASE_A_CHAR = 8'h61;
  localparam LOWERCASE_Z_CHAR = 8'h7A;
  
  wire err_invalid_key_shift_num = shift_N_1 > 26 || shift_N_2 > 26 || shift_N_1 == shift_N_2; // control of the conditions on the shift values

  
  wire ptxt_char_is_uppercase_letter = (ptxt_char >= UPPERCASE_A_CHAR) &&
                                       (ptxt_char <= UPPERCASE_Z_CHAR);   //control if the character is uppercase
                                         
  wire ptxt_char_is_lowercase_letter = (ptxt_char >= LOWERCASE_A_CHAR) &&
                                       (ptxt_char <= LOWERCASE_Z_CHAR); //control if the character is lowercase
                                         
  wire ptxt_char_is_letter = ptxt_char_is_uppercase_letter ||
                             ptxt_char_is_lowercase_letter;
    
  wire err_invalid_ptxt_char = !ptxt_char_is_letter; //error signal
  
  // Tasks are similar to C/C++ functions: they can or cannot return values/objects and can or cannot have inputs;
  // in addition they can include time-based statements (e.g.: wait, posedge, negedge, ...)
  task expected_calc (
     output [7:0] exp_char
  );
  
  if(err_invalid_key_shift_num || err_invalid_ptxt_char)
      exp_char = NUL_CHAR;
      
    else begin
      if(!shift_dir) begin
        exp_char = ptxt_char + {3'b000, shift_N_1}+ {3'b000, shift_N_2};
        if(ptxt_char_is_uppercase_letter && (exp_char > UPPERCASE_Z_CHAR))begin
          exp_char -= 8'h1A;
		  if(ptxt_char_is_uppercase_letter && (exp_char > UPPERCASE_Z_CHAR))
				exp_char -= 8'h1A;
			end
        if(ptxt_char_is_lowercase_letter && (exp_char > LOWERCASE_Z_CHAR))begin
          exp_char -= 8'h1A;
			if(ptxt_char_is_lowercase_letter && (exp_char > LOWERCASE_Z_CHAR))
				exp_char -= 8'h1A;
			end
      end
      else begin
        exp_char = ptxt_char - {3'b000, shift_N_1} - {3'b000, shift_N_2};
        if(ptxt_char_is_uppercase_letter && (exp_char < UPPERCASE_A_CHAR))begin
          exp_char += 8'h1A;
		  if(ptxt_char_is_uppercase_letter && (exp_char < UPPERCASE_A_CHAR))
			exp_char += 8'h1A;
		end
        if(ptxt_char_is_lowercase_letter && (exp_char < LOWERCASE_A_CHAR))begin
          exp_char += 8'h1A;
		   if(ptxt_char_is_lowercase_letter && (exp_char < LOWERCASE_A_CHAR))
			exp_char += 8'h1A;
		end
      end
    end
    
  endtask
  
  initial begin //below is a set of encryption or decryption carried out with different keys
    @(reset_deassertion);
    
    @(posedge clk);
		shift_dir = 1'b0;
		shift_N_1 = 5'd1;
		shift_N_2 = 5'd1;
		input_valid = 1'b0;
		mode = 1'b0;
    
    fork
    
     begin: STIMULI_1R
        for(int i = 0; i < 26; i++) begin
          ptxt_char = "A" + i;
          @(posedge clk);
          expected_calc(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);
        end
        
        for(int i = 0; i < 26; i++) begin
          ptxt_char = "a" + i;
          @(posedge clk);
          expected_calc(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);
        end
      end: STIMULI_1R
      
      begin: CHECK_1R
        @(posedge clk);
        for(int j = 0; j < 52; j++) begin
          @(posedge clk);
          EXPECTED_CHECK = EXPECTED_QUEUE.pop_front();
          $display("%c %c %-5s", ctxt_char, EXPECTED_CHECK, EXPECTED_CHECK === ctxt_char ? "OK" : "ERROR");
          if(EXPECTED_CHECK !== ctxt_char) $stop;
        end
      end: CHECK_1R
        
    join
    
    @(posedge clk);
		shift_dir = 1'b1;
		shift_N_1 = 5'd1;
		shift_N_2 = 5'd1;
		input_valid = 1'b0;
		mode = 1'b1;
		
    
    fork
    
     begin: STIMULI_1L
        for(int i = 0; i < 26; i++) begin
          ptxt_char = "A" + i;
          @(posedge clk);
          expected_calc(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);
        end
        
        for(int i = 0; i < 26; i++) begin
          ptxt_char = "a" + i;
          @(posedge clk);
          expected_calc(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);
        end
      end: STIMULI_1L
      
      begin: CHECK_1L
        @(posedge clk);
        for(int j = 0; j < 52; j++) begin
          @(posedge clk);
          EXPECTED_CHECK = EXPECTED_QUEUE.pop_front();
          $display("%c %c %-5s", ctxt_char, EXPECTED_CHECK, EXPECTED_CHECK === ctxt_char ? "OK" : "ERROR");
          if(EXPECTED_CHECK !== ctxt_char) $stop;
        end
      end: CHECK_1L
        
    join
    
    @(posedge clk);
		shift_dir = 1'b0;
		shift_N_1 = 5'd5;
		shift_N_2 = 5'd5;
		input_valid = 1'b0;
		mode = 1'b0;
    
    fork
    
       begin: STIMULI_5R
        for(int i = 0; i < 26; i++) begin
          ptxt_char = "A" + i;
          @(posedge clk);
          expected_calc(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);
        end
        
        for(int i = 0; i < 26; i++) begin
          ptxt_char = "a" + i;
          @(posedge clk);
          expected_calc(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);
        end
      end: STIMULI_5R
      
      begin: CHECK_5R
        @(posedge clk);
        for(int j = 0; j < 52; j++) begin
          @(posedge clk);
          EXPECTED_CHECK = EXPECTED_QUEUE.pop_front();
          $display("%c %c %-5s", ctxt_char, EXPECTED_CHECK, EXPECTED_CHECK === ctxt_char ? "OK" : "ERROR");
          if(EXPECTED_CHECK !== ctxt_char) $stop;
        end
      end: CHECK_5R
        
    join
    
    @(posedge clk);
		shift_dir = 1'b1;
		shift_N_1 = 5'd5;
		shift_N_2 = 5'd5;
		input_valid = 1'b0;
		mode = 1'b1;
    
    fork
    
      begin: STIMULI_5L
        for(int i = 0; i < 26; i++) begin
          ptxt_char = "A" + i;
          @(posedge clk);
          expected_calc(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);
        end
        
        for(int i = 0; i < 26; i++) begin
          ptxt_char = "a" + i;
          @(posedge clk);
          expected_calc(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);
        end
      end: STIMULI_5L
      
      begin: CHECK_5L
        @(posedge clk);
        for(int j = 0; j < 52; j++) begin
          @(posedge clk);
          EXPECTED_CHECK = EXPECTED_QUEUE.pop_front();
          $display("%c %c %-5s", ctxt_char, EXPECTED_CHECK, EXPECTED_CHECK === ctxt_char ? "OK" : "ERROR");
          if(EXPECTED_CHECK !== ctxt_char) $stop;
        end
      end: CHECK_5L
        
    join
    
    @(posedge clk);
		shift_dir = 1'b1;
		shift_N_1 = 5'd5;
		shift_N_2 = 5'd20;
		input_valid = 1'b1;
		mode = 1'b0;
    
    fork
    
       begin: STIMULI_1R_FULL_SWEEP
        for(int i = 0; i < 128; i++) begin
          ptxt_char = 8'h00 + i;
          @(posedge clk);
          expected_calc(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);
        end
      end: STIMULI_1R_FULL_SWEEP
      
      begin: CHECK_1R_FULL_SWEEP
        @(posedge clk);
        for(int j = 0; j < 128; j++) begin
          @(posedge clk);
          EXPECTED_CHECK = EXPECTED_QUEUE.pop_front();
          $display("%c %c %-5s", ctxt_char, EXPECTED_CHECK, EXPECTED_CHECK === ctxt_char ? "OK" : "ERROR");
          if(EXPECTED_CHECK !== ctxt_char) $stop;
        end
      end: CHECK_1R_FULL_SWEEP
        
    join
    
    @(posedge clk);
		shift_dir = 1'b0;
		shift_N_1 = 5'd29;
		shift_N_2 = 5'd1;
		input_valid = 1'b1;
		mode = 1'b1;
    
    fork
    
      begin: STIMULI_1R_INVALID_SHIFT_N
        for(int i = 0; i < 26; i++) begin
          ptxt_char = "A" + i;
          @(posedge clk);
          expected_calc(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);
        end
        
        for(int i = 0; i < 26; i++) begin
          ptxt_char = "a" + i;
          @(posedge clk);
          expected_calc(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);
        end
      end: STIMULI_1R_INVALID_SHIFT_N
      
      begin: CHECK_1R_INVALID_SHIFT_N
        @(posedge clk);
        for(int j = 0; j < 52; j++) begin
          @(posedge clk);
          EXPECTED_CHECK = EXPECTED_QUEUE.pop_front();
          $display("%c %c %-5s", ctxt_char, EXPECTED_CHECK, EXPECTED_CHECK === ctxt_char ? "OK" : "ERROR");
          if(EXPECTED_CHECK !== ctxt_char) $stop;
        end
      end: CHECK_1R_INVALID_SHIFT_N
        
    join
    
    $stop;
    
  end

endmodule
// -----------------------------------------------------------------------------


// -----------------------------------------------------------------------------
// Testbench for file encryption
// -----------------------------------------------------------------------------

module caesar_ciph_tb_file_enc;

  reg clk = 1'b0;
  always #5 clk = !clk;
  
  reg rst_n = 1'b0;
  event reset_deassertion;
  
  initial begin
    #12.8 rst_n = 1'b1;
    -> reset_deassertion;
  end
  
  reg        shift_dir;
  reg  [4:0] shift_N_1;
  reg  [4:0] shift_N_2;
  reg  [7:0] ptxt_char;
  reg     input_valid;
  reg     mode;
  wire [7:0] ctxt_char;
  wire    invalid_key;
  wire    invalid_char;
  wire    ready;

  caesar_cipher INSTANCE_NAME (
     .clk                       (clk)
    ,.rst_n                     (rst_n)
    ,.ptxt_valid         (input_valid)
    ,.mode            (mode)
    ,.key_shift_dir             (shift_dir)
    ,.key_shift_num_1            (shift_N_1)
    ,.key_shift_num_2            (shift_N_2)
    ,.ptxt_char                 (ptxt_char)
    ,.ctxt_char                 (ctxt_char)
    ,.err_invalid_key_shift_num (invalid_key)
    ,.err_invalid_ptxt_char     (invalid_char)
    ,.ctx_ready         (ready)
  );
 
  
  localparam UPPERCASE_A_CHAR = 8'h41;
  localparam UPPERCASE_Z_CHAR = 8'h5A;
  localparam LOWERCASE_A_CHAR = 8'h61;
  localparam LOWERCASE_Z_CHAR = 8'h7A;
  localparam NUL_CHAR = 8'h20;
  
  int FP_PTXT;
  int FP_CTXT;
  string char;

  //buffers used to contain the encrypted and decrypted characters and those present in the source files of model C

  //test 1
  reg [7:0] CTXT [$];
  reg [7:0] PTXT [$];
  reg [7:0] PTXT_source [$];
  reg [7:0] CTXT_source [$];
  
  //test 2
  reg [7:0] CTXT2 [$];
  reg [7:0] PTXT2 [$];
  reg [7:0] PTXT_source2 [$];
  reg [7:0] CTXT_source2 [$];
  
  
  
  initial begin
    @(reset_deassertion);
    
	/*-------------------test 1 begins----------------------------*/
    @(posedge clk);
    FP_PTXT = $fopen("./tv/ptxt.txt", "r");
    $write("Encrypting file 'tv/ptxt.txt' to 'tv/enc_HW.txt'... ");
   		shift_dir = 1'b1;
		shift_N_1 = 5'd10;
		shift_N_2 = 5'd3;
		input_valid = 1'b1;
		mode = 1'b0;
    
    while($fscanf(FP_PTXT, "%c", char) == 1) begin
      ptxt_char = int'(char);
      @(posedge clk);
      if(
        ((ptxt_char >= UPPERCASE_A_CHAR ) && (ptxt_char <= UPPERCASE_Z_CHAR)) ||
        ((ptxt_char >= LOWERCASE_A_CHAR ) && (ptxt_char <= LOWERCASE_Z_CHAR))
      ) begin
        @(posedge clk);
        CTXT.push_back(ctxt_char);
      end
      else begin
        CTXT.push_back(NUL_CHAR);
		end;
    end
    $fclose(FP_PTXT);
    
    FP_CTXT = $fopen("./tv/enc_HW.txt", "w");
    foreach(CTXT[i])
      $fwrite(FP_CTXT, "%c", CTXT[i]);
    $fclose(FP_CTXT);
	

    
    $display("Encrypt Done!");
	
	FP_PTXT = $fopen("./tv/enc.txt", "r");
	while($fscanf(FP_PTXT, "%c", char) == 1) begin
      ptxt_char = int'(char);
      begin
		CTXT_source.push_back(ptxt_char);
      end
    end;
    $fclose(FP_PTXT);
		
	if(CTXT != CTXT_source)begin
		$display("ERROR");
		$stop;
	end
    $fclose(FP_PTXT);
	
	 $display("Compare Done tv/enc.txt - tv/enc_HW.txt!");
    
    @(posedge clk);
    FP_CTXT = $fopen("./tv/enc_HW.txt", "r");
    $write("Decrypting file 'tv/enc_HW.txt' to 'tv/dec_HW.txt'... ");
		mode = 1'b1;
    
    while($fscanf(FP_CTXT, "%c", char) == 1) begin
      ptxt_char = int'(char);
      @(posedge clk);
      if(
        ((ptxt_char >= UPPERCASE_A_CHAR ) && (ptxt_char <= UPPERCASE_Z_CHAR)) ||
        ((ptxt_char >= LOWERCASE_A_CHAR ) && (ptxt_char <= LOWERCASE_Z_CHAR))
      ) begin
        @(posedge clk);
        PTXT.push_back(ctxt_char);
      end
      else
        PTXT.push_back(NUL_CHAR);
    end
    $fclose(FP_CTXT);
    
    FP_PTXT = $fopen("./tv/dec_HW.txt", "w");
    foreach(PTXT[i])
      $fwrite(FP_PTXT, "%c", PTXT[i]);
    $fclose(FP_PTXT);

	
	$display("Decrypt Done!");
	
	FP_PTXT = $fopen("./tv/dec.txt", "r");
	while($fscanf(FP_PTXT, "%c", char) == 1) begin
      ptxt_char = int'(char);
      begin
		PTXT_source.push_back(ptxt_char);
      end
    end;
    $fclose(FP_PTXT);

	 
	if(PTXT != PTXT_source)begin
		$display("ERROR");
		$stop;
	end
    $fclose(FP_PTXT);
    
    $display("Compare Done tv/dec.txt - tv/dec_HW.txt!");
    
    //$stop;
	
  //end
    /* $fclose(FP_PTXT);
    
    $display("Compare Done model/dec.txt - tv/dec_HW.txt!"); */
	

  
  /*-------------------test 2 begins----------------------------*/
    
    @(posedge clk);
    FP_PTXT = $fopen("./tv/ptxt2.txt", "r");
    $write("Encrypting file 'tv/ptxt2.txt' to 'tv/enc_HW2.txt'... ");
   		shift_dir = 1'b0;
		shift_N_1 = 5'd5;
		shift_N_2 = 5'd1;
		input_valid = 1'b1;
		mode = 1'b0;
    
    while($fscanf(FP_PTXT, "%c", char) == 1) begin
      ptxt_char = int'(char);
      @(posedge clk);
      if(
        ((ptxt_char >= UPPERCASE_A_CHAR ) && (ptxt_char <= UPPERCASE_Z_CHAR)) ||
        ((ptxt_char >= LOWERCASE_A_CHAR ) && (ptxt_char <= LOWERCASE_Z_CHAR))
      ) begin
        @(posedge clk);
        CTXT2.push_back(ctxt_char);
      end
      else begin
        CTXT2.push_back(NUL_CHAR);
		end;
    end
    $fclose(FP_PTXT);
    
    FP_CTXT = $fopen("./tv/enc_HW2.txt", "w");
    foreach(CTXT2[i])
      $fwrite(FP_CTXT, "%c", CTXT2[i]);
    $fclose(FP_CTXT);
	
    
    $display("Encrypt Done!");
	
	FP_PTXT = $fopen("./tv/enc2.txt", "r");
	while($fscanf(FP_PTXT, "%c", char) == 1) begin
      ptxt_char = int'(char);
      begin
		CTXT_source2.push_back(ptxt_char);
      end
    end;
    $fclose(FP_PTXT);
		
	if(CTXT2 != CTXT_source2)begin
		$display("ERROR");
		$stop;
	end
    $fclose(FP_PTXT);
	
	 $display("Compare Done tv/enc2.txt - tv/enc_HW2.txt!");
    
    @(posedge clk);
    FP_CTXT = $fopen("./tv/enc_HW2.txt", "r");
    $write("Decrypting file 'tv/enc_HW2.txt' to 'tv/dec_HW2.txt'... ");
		mode = 1'b1;
    
    while($fscanf(FP_CTXT, "%c", char) == 1) begin
      ptxt_char = int'(char);
      @(posedge clk);
      if(
        ((ptxt_char >= UPPERCASE_A_CHAR ) && (ptxt_char <= UPPERCASE_Z_CHAR)) ||
        ((ptxt_char >= LOWERCASE_A_CHAR ) && (ptxt_char <= LOWERCASE_Z_CHAR))
      ) begin
        @(posedge clk);
        PTXT2.push_back(ctxt_char);
      end
      else
        PTXT2.push_back(NUL_CHAR);
    end
    $fclose(FP_CTXT);
    
    FP_PTXT = $fopen("./tv/dec_HW2.txt", "w");
    foreach(PTXT2[i])
      $fwrite(FP_PTXT, "%c", PTXT2[i]);
    $fclose(FP_PTXT);
	
	
	$display("Decrypt Done!");
	
	FP_PTXT = $fopen("./tv/dec2.txt", "r");
	while($fscanf(FP_PTXT, "%c", char) == 1) begin
      ptxt_char = int'(char);
      begin
		PTXT_source2.push_back(ptxt_char);
      end
    end;
    $fclose(FP_PTXT);

	 
	if(PTXT2 != PTXT_source2)begin
		$display("ERROR");
		$stop;
	end
    $fclose(FP_PTXT);
    
    $display("Compare Done tv/dec2.txt - tv/dec_HW2.txt!");
	
	@(posedge clk);
    FP_PTXT = $fopen("./tv/ptxt2.txt", "r");
    $write("Encrypting file 'tv/ptxt2.txt' to 'tv/enc_HW2.txt'... ");
   		shift_dir = 1'b1;
		shift_N_1 = 5'd5;
		shift_N_2 = 5'd1;
		input_valid = 1'b1;
		mode = 1'b0;
    
    while($fscanf(FP_PTXT, "%c", char) == 1) begin
      ptxt_char = int'(char);
      @(posedge clk);
      if(
        ((ptxt_char >= UPPERCASE_A_CHAR ) && (ptxt_char <= UPPERCASE_Z_CHAR)) ||
        ((ptxt_char >= LOWERCASE_A_CHAR ) && (ptxt_char <= LOWERCASE_Z_CHAR))
      ) begin
        @(posedge clk);
        CTXT.push_back(ctxt_char);
      end
      else begin
        CTXT.push_back(NUL_CHAR);
		end;
    end
    $fclose(FP_PTXT);
    
    FP_CTXT = $fopen("./tv/enc_HW2.txt", "w");
    foreach(CTXT[i])
      $fwrite(FP_CTXT, "%c", CTXT[i]);
    $fclose(FP_CTXT);
    
    $stop; 
	
  end

endmodule


// -----------------------------------------------------------------------------
