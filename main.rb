require 'io/console'
require 'json'


class Game  
    def initialize
        @secret_word = ""
        @dashes = []
        @turn = 1
        @miss = 0
        @game_over = false
        Dir.mkdir("saved_games") unless File.exists?("saved_games")
        start_menu()
    end

    def start_menu
        #Game Menu
        system("clear")
        puts "\t\t\t\t---- Hangman ----"
        puts "1.Start New Game"
        puts "2.Load Game"
        puts "3.Exit"
        while true
            puts "\nPick an Option"
            option = gets.chomp.to_i
            break if option.between?(1,3)
            puts "Option must be a number between 1 or 3"
        end
        system('clear')
        @game_over = false

        new_game() if option == 1
        load_game() if option == 2
        exit if option == 3
    end

    def load_game
        system('clear')
        saved_list = Dir.glob("saved_games/*")

        if saved_list.empty?
            puts "No Saved Files"
            print "Press any key to continue\n"
            STDIN.getch
            start_menu()
        else
            file = choose_file(saved_list)
             
            system('clear')
            puts "\nYour File: (#{file})"
            puts "1.Load Save"
            puts "2.Delete Save"
            while true
                puts " Choose an Option:"
                option = gets.chomp.to_i
                break if option.between?(1,2)
                puts "\n\tOption must be a number between 1 or 2"
            end

            if option == 1
                load_file(file)
            elsif option == 2
                delete_file(file)
            end
        end
    end

    def choose_file list
        #choose and manipulate file
        list.each_with_index do |file,index|
            puts "#{index+1}-#{File.basename(file,'.json')}"
        end
        while true
            puts "\nchoose file:"
            player_choice = gets.chomp.to_i
            break if player_choice.between?(1,list.length)
            puts "Invalid Input,try again !!"
        end
        chosen_file = File.basename(list[player_choice-1],'.json') 
    end

    def load_file file
        data = JSON.parse(File.read("saved_games/#{file}.json"))
        @secret_word = data["secret_word"]
        @dashes = data["row"]
        @turn = data["current_turn"]
        @miss = data["mistakes"]
        puts "#{file} loaded.."
        print "Press any key to continue.."
        STDIN.getch
        active_game()
    end

    def delete_file file
        loop do
            puts "\nAre you Sure you want to delete this file (#{file}.json)?(Y/N)"
            @confirm = gets.chomp.upcase
            break if @confirm == 'Y' || @confirm == 'N'
            puts "\tinvalid Input, Please press Y or N"
        end
        if @confirm == 'N'
            start_menu()
        else
            File.delete("saved_games/#{file}.json")
            puts "File: #{file}.json deleted.."
            puts "Returning to Main Menu"
            print "Press any key to continue"
            STDIN.getch
            start_menu()
        end
    end

    def save_game
        saved_files = Dir.glob("saved_games/*")

        while true
            puts "\nInsert Name for Saved File"
            save_name = gets.chomp
            file_name = "saved_games/#{save_name}.json"

            if saved_files.include?(file_name)
                while true
                    puts "\n#{save_name} will be overwritten,\nproceed?(Y/N)"
                    player_decision = gets.chomp.upcase
                    break if player_decision == 'Y' || player_decision == 'N'
                    puts "\tinvalid Input, Please press Y or N"
                end
            else
                break
            end
            break if player_decision == 'Y'
        end
        data_input = {
            "secret_word":@secret_word,
            "row":@dashes,
            "current_turn":@turn,
            "mistakes":@miss
        }

        File.open(file_name,'w') do |file| 
            file.puts JSON.dump(data_input)
        end
        puts "Game Saved...\nReturning to Main Menu"
        print "press any key to continue.."                                                                                                    
        STDIN.getch
        start_menu()
    end

    def get_random_word
        words = File.readlines('5desk.txt')
        words.each { |word| word.strip!}

        loop do
            @secret_word = words[rand(0...words.length)].downcase
            break if @secret_word.length.between?(5,12)
        end
    end

    def generate_dashes
        @secret_word.split("").each {|letter| @dashes.push(" ")}
    end

    def display
        puts "Turn: #{@turn} ."
        puts "Attempts: #{@miss}/10 .\n\n"

        @dashes.each {|letter| print "  #{letter} "}
        puts ""
        @dashes.each {|letter| print " ---"}
        puts ""
    end

    def check_word
        #checks if player input matches secret wort
        word = @dashes.join().strip.delete(" ")
        return (word == @secret_word? true : false)
    end

    def player_input
        #prompts player for letters & offering them to save
        system('clear')
        display()
        while true
            puts "\nInsert a Letter:"
            guess = gets.chomp.downcase
            break if guess.match(/[[a-zA-Z]]/)
            puts "\tInvalid Input,Try Again"
        end

        if @secret_word.include?(guess)
            @secret_word.split("").each_with_index{ |letter,index| @dashes[index] = letter if (guess == letter.downcase)}
        else
            @miss += 1
        end
        @turn += 1
        
        system('clear')
        display()

        puts "1.Continue game"
        puts "2.Save game"
        while true
            proceeding = STDIN.getch()
            break if proceeding.match(/[[1-2]]/)
            puts "\n\tOption must be a number between 1 or 2"
        end
        save_game() if proceeding == "2"
    end

    def active_game
        until @game_over
            player_input()
            @game_over = true if(@miss == 10 || check_word())
        end
        system('clear')
        display()

        if check_word()
            puts "Congratulations, You made it !!"
        else
            puts "Hard Luck, Secret Word was: #{@secret_word} ."
        end

        print "Press any key to continue.."
        STDIN.getch()
        start_menu()

    end

    def new_game
        @secret_word =""
        @dashes = []
        @turn = 1
        @miss = 0
        @game_over = false
        get_random_word()
        generate_dashes()
        active_game()
    end
end

play = Game.new


