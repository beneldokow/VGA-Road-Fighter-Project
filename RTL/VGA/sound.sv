module Sound (
    input logic clk,
    input logic resetN,
    input logic game, // 1 if game is running
    input logic lose, // 1 if game is lost
    input logic win, // 1 if game is won
	input logic special, // 1 if special mode is on
    input logic gas, // 1 if gas is pressed
    input logic [3:0] playerSpeed,
    input logic collision, // 1 if collision
    input logic fuel, // 1 if recharge fuel
    input logic counterClk, //fast clock for counting
   
    output logic EnableSound, // 1 if sound is enabled
    output logic [3:0] tone // tone to be played
);

    logic start; //flag for start of game
    logic [32:0] count; //counter for tone release
    logic reset_count; //flag for reseting counter
    parameter toneBuffer = 7; //tone release buffer

    // States declaration
    enum logic [6:0] {s_idle,s_newGame, s_launch, s_gameOver, s_collision,s_special,s_win,s_fuel} sound_ps, sound_ns;

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            sound_ps <= s_idle;
            count <= 0;
            start <= 0;
        end
        else begin
            sound_ps <= sound_ns;
            start <= game; //making start a flag for start of game
            
            if (counterClk) //counting at fast clock
                count <= count + 1;
            
            if(reset_count)//reseting counter according to flag
                count <= 0;

        end
    end

    always_comb begin
        sound_ns = sound_ps;
        tone = 0;
        EnableSound = 1;
        reset_count = 0;

        case (sound_ps)
            //--------------------------------------------------
            s_idle: begin //idle state - which activates the sound according to the flags
                EnableSound = 0;
                reset_count = 1;
                
                if (game == 1 && start == 0) //start of game sound activation
                    sound_ns = s_newGame;
                else if (special) //special mode sound activation
                    sound_ns = s_special;
                else if (gas && game) //gas sound activation
                    sound_ns = s_launch;
				else if (lose) //game over sound activation
                    sound_ns = s_gameOver;
                else if (collision) //collision sound activation
                    sound_ns = s_collision;
                else if (win) //win sound activation
                    sound_ns = s_win;
                else if (fuel) //fueling sound activation
                    sound_ns = s_fuel;

            end

            //--------------------------------------------------
            s_newGame: begin

                if (count < toneBuffer)
                    tone = 6;
                else if (count < 2 * toneBuffer)
                    tone = 7;
                else if (count < 3 * toneBuffer)
                    tone = 8;
                else if (count < 4 * toneBuffer)
                    tone = 9;
                else
                    sound_ns = s_idle;
            end

            //--------------------------------------------------
            s_launch: begin
                
                tone = playerSpeed;
                sound_ns = s_idle;
                
                if (lose)
                    sound_ns = s_gameOver;
                else if (collision)
                    sound_ns = s_collision;
                else if (win)
                    sound_ns = s_win;
                else if (fuel)
                    sound_ns = s_fuel;
                else if (gas == 0) begin
                    sound_ns = s_idle;
                end
            end

            //--------------------------------------------------
            s_collision: begin
                
                if (count < toneBuffer)
                    tone = 15;
                else if (count < 2 * toneBuffer)
                    tone = 14;
                else if (count < 3 * toneBuffer)
                    tone = 13;
                else if (count < 4 * toneBuffer)
                    tone = 12;
                else
                    sound_ns = s_idle;
            end

            //--------------------------------------------------

            s_special: begin

                if (count < toneBuffer)
                    tone = 2;
                else if (count < 2 * toneBuffer)
                    tone = 3;
                else if (count < 3 * toneBuffer)
                    tone = 0;
                else if (count < 4 * toneBuffer)
                    tone = 1;
                else if (count < 5 * toneBuffer)
                    tone = 2;
                else if (count < 6 * toneBuffer)
                    tone = 3;
                else if (count < 7 * toneBuffer)
                    tone = 0;
                else
                    sound_ns = s_idle;
            end
            //--------------------------------------------------
            s_gameOver: begin

                if (count <  toneBuffer)
                    tone = 9;
                else if (count < 2 * toneBuffer)
                    tone = 10;
                else if (count < 3 * toneBuffer)
                    tone = 8;
				else if (count < 4 * toneBuffer)
                    tone = 7;
                else if (count < 5 * toneBuffer)
                    tone = 6;
                else if (count < 6 * toneBuffer)
                    tone = 5;
                else if (count < 7 * toneBuffer)
                    tone = 4;
                else if (count < 8 * toneBuffer)
                    tone = 3;
                else if (count < 9 * toneBuffer)
                    tone = 2;
                else if (count < 10 * toneBuffer)
                    tone = 1;
                else if (count < 11 * toneBuffer)
                    tone = 0;
                else if (count < 12 * toneBuffer)
                    tone = 1;
                else if (count < 13 * toneBuffer)
                    tone = 2;
                else if (count < 14 * toneBuffer)
                    tone = 3;
                else if (count < 15 * toneBuffer)
                    tone = 4;
                else if (count < 16 * toneBuffer)
                    tone = 5;
                else if (count < 17 * toneBuffer)
                    tone = 6;
                else if (count < 18 * toneBuffer)
                    tone = 7;
                else if (count < 19 * toneBuffer)
                    tone = 8;
                else if (count < 20 * toneBuffer)
                    tone = 9;
                else if(game == 1 && start == 0) begin
                    sound_ns = s_newGame;
                    reset_count = 1;
                end
                else
                    EnableSound = 0;
            end
            
            //--------------------------------------------------
            s_win: begin

                if (count <  toneBuffer)
                    tone = 9;
                else if (count < 2 * toneBuffer)
                    tone = 10;
                else if (count < 3 * toneBuffer)
                    tone = 8;
                else if (count < 4 * toneBuffer)
                    tone = 7;
                else if (count < 5 * toneBuffer)
                    tone = 6;
                else if (count < 6 * toneBuffer)
                    tone = 5;
                else if (count < 7 * toneBuffer)
                    tone = 4;
                else if (count < 8 * toneBuffer)
                    tone = 3;
                else if (count < 9 * toneBuffer)
                    tone = 2;
                else if (count < 10 * toneBuffer)
                    tone = 1;
                else if (count < 11 * toneBuffer)
                    tone = 0;
                else if (count < 12 * toneBuffer)
                    tone = 1;
                else if (count < 13 * toneBuffer)
                    tone = 2;
                else if (count < 14 * toneBuffer)
                    tone = 3;
                else if (count < 15 * toneBuffer)
                    tone = 4;
                else if (count < 16 * toneBuffer)
                    tone = 5;
                else if (count < 17 * toneBuffer)
                    tone = 6;
                else if (count < 18 * toneBuffer)
                    tone = 7;
                else if (count < 19 * toneBuffer)
                    tone = 8;
                else if (count < 20 * toneBuffer)
                    tone = 9;
                else if (count < 21 * toneBuffer)
                    tone = 10;

                else if(game == 1 && start == 0) begin
                    sound_ns = s_newGame;
                    reset_count = 1;
                end
                else
                    EnableSound = 0;
            end

            //--------------------------------------------------
            s_fuel: begin

                if (count <  toneBuffer)
                    tone = 2;
                else if (count < 2 * toneBuffer)
                    tone = 6;
                else if (count < 3 * toneBuffer)
                    tone = 7;
                else if (count < 4 * toneBuffer)
                    tone = 6;
                else
                    sound_ns = s_idle;
            end
            //--------------------------------------------------
            default: sound_ns = s_idle;
        endcase 			
	end
endmodule