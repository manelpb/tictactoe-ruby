class GameController < ApplicationController
	layout "Slim"

	def index
		@cols = [nil, nil, nil]
		@rows = [nil, nil, nil]
		@board = Array.new(3) { Array.new(3) }
		@scores = [0, 0]

		session[:cols] = @cols
		session[:rows] = @rows
		session[:board] = @board
		session[:scores] = @scores
	end

	def reset
		board = Array.new(3) { Array.new(3) }

		# save board
		save_board(board)
		
		# setup 
		config_board

		render "_board", layout: false
	end

	def play
		board = session[:board]
		scores = session[:scores]

		# user move
		if user_move(board)
	  		# check if the user won
	  		if !check_won
	  			# computer move
	  			computer_move(board)

	  			# check if the computer won
	  			check_won
	  		end
	  	end
	  	
		# setup 
		config_board

		render "_board", layout: false
	end

	def scores
		#show the scores
	end

	private 
	
	def user_move(board)
      	# get the user action
      	user_col = params[:col]
      	user_row = params[:row]

		#get the user move
		if can_play(board, [user_col.to_i, user_row.to_i])
			board[user_col.to_i][user_row.to_i] = "X"

			# save the board
			save_board(board)

			return true
		else
			return false
		end
	end

	def computer_move(board)
		played = false
		
      	# checking if i can play
      	if count_moves_board(board) < 9

	        # strategy: http://en.wikipedia.org/wiki/Tic-tac-toe#Strategy

	        # 1. Win: If the player has two in a row, they can place a third to get three in a row
	        where_play = check_row(board, 'O')
	        if !played && where_play != nil
	        	board[where_play[0].to_i][where_play[1].to_i] = "O"
	        	played = true
	        end

	        # 2. Block: If the opponent has two in a row, the player must play the third themselves to block the opponent
	        where_play = check_row(board, 'X')
	        if !played && where_play != nil
	        	board[where_play[0].to_i][where_play[1].to_i] = "O"
	        	played = true
	        end

	       	# 3. If center is empty, i will play there because for me the proability to win 
	       	if !played && can_play(board, [1,1])
	       		board[1][1] = "O"
	       		played = true
	       	end

	        # 4. Blocking an opponent's fork 
	        # and 
	        # 5. Center: A player marks the center.
	        if !played
	        	where_play = check_blocking(board, "X", "O")
	        	if where_play != nil
	        		board[where_play[0].to_i][where_play[1].to_i] = "O"
	        		played = true
	        	end
	        end

	        # 6. Opposite corner: If the opponent is in the corner, the player plays the opposite corner.
	        where_play = check_corner(board, 'X')
	        if !played && where_play != nil
	        	board[where_play[0].to_i][where_play[1].to_i] = "O"
	        	played = true
	        end

	        # 7. Empty corner: The player plays in a corner square
	        where_play = check_extremity_available(true, board)
	        if !played && where_play != nil
	        	board[where_play[0].to_i][where_play[1].to_i] = "O"
	        	played = true
	        end

	        # 8. Empty side: The player plays in a middle square on any of the 4 sides.
	        where_play = check_extremity_available(false, board)
	        if !played && where_play != nil
	        	board[where_play[0].to_i][where_play[1].to_i] = "O"
	        	played = true
	        end
	    end
	    save_board(board)
	end

	def check_possibilites(board, type, value)
		possibilites = ['011', '110', '101']

		possibilites.each_with_index do |pos, index|
			case type
			when 'top'
				if pos == '011' && board[0][0] == nil && board[1][0] == value && board[2][0] == value
					return [0,0]
				elsif pos == '101' && board[0][0] == value && board[1][0] == nil && board[2][0] == value
					return [1,0]
				elsif pos == '110' && board[0][0] == value && board[1][0] == value && board[2][0] == nil
					return [2,0]
				end
			when 'middle'
				if pos == '011' && board[0][1] == nil && board[1][1] == value && board[2][1] == value
					return [0,1]
				elsif pos == '101' && board[0][1] == value &&  board[1][1] == nil && board[2][1] == value
					return [1,1]
				elsif pos == '110' && board[0][1] == value &&  board[1][1] == value && board[2][1] == nil
					return [2,1]
				end
			when 'bottom'
				if pos == '011' && board[0][2] == nil &&  board[1][2] == value && board[2][2] == value
					return [0,2]
				elsif pos == '101' && board[0][2] == value &&  board[1][2] == nil && board[2][2] == value
					return [1,2]
				elsif pos == '110' && board[0][2] == value &&  board[1][2] == value && board[2][2] == nil
					return [2,2]
				end   
			when 'leftdown'
				if pos == '011' && board[0][0] == nil &&  board[0][1] == value && board[0][2] == value
					return [0,0]
				elsif pos == '101' && board[0][0] == value &&  board[0][1] == nil && board[0][2] == value
					return [0,1]
				elsif pos == '110' && board[0][0] == value &&  board[0][1] == value && board[0][2] == nil
					return [0,2]
				end  
			when 'middown'
				if pos == '011' && board[1][0] == nil &&  board[1][1] == value && board[1][2] == value
					return [1,0]
				elsif pos == '101' && board[1][0] == value &&  board[1][1] == nil && board[1][2] == value
					return [1,1]
				elsif pos == '110' && board[1][0] == value &&  board[1][1] == value && board[1][2] == nil
					return [1,2]
				end  
			when 'rightdown'
				if pos == '011' && board[2][0] == nil &&  board[2][1] == value && board[2][2] == value
					return [2,0]
				elsif pos == '101' && board[2][0] == value &&  board[2][1] == nil && board[2][2] == value
					return [2,1]
				elsif pos == '110' && board[2][0] == value &&  board[2][1] == value && board[2][2] == nil
					return [2,2]
				end   
			when 'diagonal1'
				if pos == '011' && board[2][0] == nil &&  board[1][1] == value && board[0][2] == value
					return [2, 0]
				elsif pos == '101' && board[2][0] == value &&  board[1][1] == nil && board[0][2] == value
					return [1,1]
				elsif pos == '110' && board[2][0] == value &&  board[1][1] == value && board[0][2] == nil
					return [0, 2]
				end   
			when 'diagonal2'
				if pos == '011' && board[0][0] == nil &&  board[1][1] == value && board[2][2] == value
					return [0,0]
				elsif pos == '101' && board[0][0] == value &&  board[1][1] == nil && board[2][2] == value
					return [1,1]
				elsif pos == '110' && board[0][0] == value &&  board[1][1] == value && board[2][2] == nil
					return [2,2]
				end           
			end
		end

		return nil
	end

	def can_play(board, coord)
		if board[coord[0]][coord[1]] == nil
			return true
		else 
			return false
		end
	end

	def check_row(board, who)
		# check if the row has 2 places used
		where_play = nil

		top = check_possibilites(board, "top", who)
		middle = check_possibilites(board, 'middle', who)
		bottom = check_possibilites(board, 'bottom', who)

		left_down = check_possibilites(board, 'leftdown', who)
		mid_down = check_possibilites(board, 'middown', who)
		right_down = check_possibilites(board, 'rightdown', who)

		diagonal1 = check_possibilites(board, 'diagonal1', who)       
		diagonal2 = check_possibilites(board, 'diagonal2', who)

		if top != nil && can_play(board, top) # top
			where_play = top
		elsif middle != nil && can_play(board, middle) # middle
			where_play = middle
		elsif bottom != nil && can_play(board, bottom) # bottom 
			where_play = bottom
		elsif left_down != nil && can_play(board, left_down) # leftdown 
			where_play = left_down
		elsif mid_down != nil && can_play(board, mid_down) # middown 
			where_play = mid_down
		elsif right_down != nil && can_play(board, right_down) # rightdown 
			where_play = right_down
		elsif diagonal1 != nil && can_play(board, diagonal1) # diagonal1 
			where_play = diagonal1
		elsif diagonal2 != nil && can_play(board, diagonal2) # diagonal2 
			where_play = diagonal2
		end

		return where_play
	end

	def check_corner(board, who)
		where_play = nil
		
		if board[0][0] == who && can_play(board, [2,2])
			where_play = [2,2]
		elsif board[2][2] == who && can_play(board, [0,0])
			where_play = [0,0]
		elsif board[2][0] == who && can_play(board, [0,2])
			where_play = [0,2]
		elsif board[0][2] == who && can_play(board, [2,0])
			where_play = [2,0]
		end

		return where_play
	end

	def count_possibilites(board, position, who)
		# check if i have more opportunities to win
		points_right = 0
		points_left = 0
				
		#check vertically
      	board[0].each_with_index do |row, rindex|
			board.each_with_index do |cc, rr|
				row_win = rindex
				col_win = rr     

      			if position == 'right' && cc[rindex] == who && rr == 2
	      			points_right += 1
	      		end

	      		if position == 'left' && cc[rindex] == who && rr == 0
	      			points_left += 1
	      		end
      		end
      	end

      	if position == 'right'
      		return points_right
      	elsif position == 'left'
      		return points_left
      	end
	end

	def check_extremity_available(is_corner, board) 
		where_play = nil

		if is_corner
			if board[0][0] == nil && (count_possibilites(board, 'right', 'X') == 0)
				where_play = [0,0]
			elsif board[2][2] == nil && (count_possibilites(board, 'left', 'X') == 0)
				where_play = [2,2]
			elsif board[2][0] == nil
				where_play = [2,0]
			elsif board[0][2] == nil
				where_play = [0,2]
			end
		else
			if board[1][0] == nil
				where_play = [1,0]
			elsif board[0][1] == nil
				where_play = [0,1]
			elsif board[2][1] == nil
				where_play = [2,1]
			elsif board[1][2] == nil
				where_play = [1,2]
			end
		end

		return where_play
	end

	def check_blocking(board, who, opponent)
		# Option 1: The player should create two in a row to force the opponent into defending, 
		# as long as it doesn't result in them creating a fork. 

		# For example, if "X" has a corner, "O" has the center, and "X" has the opposite corner as well, 
		# "O" must not play a corner in order to win. (Playing a corner in this scenario creates a fork 
		# for "X" to win.)

		if (board[0][0] == who || 
			board[2][0] == who || 
			board[0][2] == who || 
			board[2][2] == who) && 
			board[1][1] == opponent
	        
	        while true
	        	r = Random.new
	        	col = r.rand(0..2)
	        	row = r.rand(0..2)

	        	got_random = true

	        	# checking if random is trying to get any corner
	        	# because it can't get this
	        	if (col == 0 && row == 0)
	        		got_random = false
	        	elsif (col == 2 && row == 0)
	        		got_random = false
	        	elsif (col == 0 && row == 2)
	        		got_random = false
	        	elsif (col == 2 && row == 2)
	        		got_random = false
	        	end
	        	
	        	# only accept if isn't a corner and i can play
	        	if can_play(board, [col, row]) && got_random
	        		return [col, row]
	        	end
	        end
	    end
	end

	def check_won
		board = session[:board]
		col_win = nil
		row_win = nil
		winner = nil
		points_vert_x = nil
		points_vert_o = nil
		points_horiz_x = nil
		points_horiz_o = nil

      	#check vertically
      	board.each_with_index do |col, cindex|
      		points_vert_x = 0
      		points_vert_o = 0

      		board[cindex].each_with_index do |row, rindex|
      			col_win = cindex
      			row_win = rindex

      			if row != nil
      				if row == 'X'
      					points_vert_x += 1
      				else
      					points_vert_o += 1
      				end
      			end
      		end

      		if points_vert_x == 3 || points_vert_o == 3
      			break
      		end
      	end

      	if points_vert_x == 3
      		winner = "X"
      	elsif points_vert_o == 3
      		winner = "O"
      	end

		# check only if there's no winner vertically
		if winner == nil 
			#check horizontally 
			board[0].each_with_index do |row, rindex|
				points_horiz_x = 0
				points_horiz_o = 0

				board.each_with_index do |cc, rr|
					row_win = rindex
					col_win = rr          

					if cc[rindex] != nil
						if cc[rindex] == 'X'
							points_horiz_x += 1
						else
							points_horiz_o += 1
						end           
					end
				end

				if points_horiz_x == 3 || points_horiz_o == 3
					break
				end
			end

			if points_horiz_x == 3
				winner = "X"
			elsif points_horiz_o == 3
				winner = "O"
			end
		end

		# check diagonal 1
		if board[0][0] == "X" && board[1][1] == "X" && board[2][2] == "X"
			winner = "X"
		elsif board[0][0] == "O" && board[1][1] == "O" && board[2][2] == "O"
			winner = "O"
		end

		# check diagonal 2
		if board[0][2] == "X" && board[1][1] == "X" && board[2][0] == "X"
			winner = "X"
		elsif board[0][2] == "O" && board[1][1] == "O" && board[2][0] == "O"
			winner = "O"
		end

		# print result
		if winner != nil
			save_scores(session[:scores], winner)
			winner = winner == 'O' ? "Computer" : "You"
			@result = { 'status': 'win', 'winner': winner }
		elsif (count_moves_board board) == 9 
			@result = { 'status': 'tie' }
		end

		return winner
	end

	def count_moves_board(board)
		@total_moves = 0

		board.each_with_index do |col, cindex|
			board[cindex].each_with_index do |row, rindex|
				if board[cindex][rindex] != nil
					@total_moves += 1
				end
			end
		end

		return @total_moves
	end

	def config_board
		@cols = session[:cols]
		@rows = session[:rows]
		@board = session[:board]
		@scores = session[:scores]
	end

	def save_scores(scores, who)
		if who == "O"
			scores[0] = scores[0] + 1
		else
			scores[1] += 1
		end

		session[:scores] = scores
	end

	def save_board(board)
		session[:board] = board
	end
end
