#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


 if [[ -z $1 ]]
  then
    echo "Enter your username:"
    read GET_USERNAME
    USERNAME=$($PSQL "SELECT * FROM players WHERE username = '$GET_USERNAME'")
fi

MAIN_PAGE() {
    if [[ -z $USERNAME ]]
    then
      #if the user is not database
      echo "Welcome, $GET_USERNAME! It looks like this is your first time here."
      INSERT_NEW_PLAYER=$($PSQL "INSERT INTO players(username, games_played, best_game) VALUES('$GET_USERNAME', 1, 0)")
    else
      #if the user is in the database
      echo $USERNAME | while IFS=" |" read PLAYER GAMES_PLAYED BEST_GAME
      do
      echo "Welcome back, $PLAYER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
      INSERT_NEW_NUMBER_GAMES=$($PSQL "UPDATE players SET games_played = $GAMES_PLAYED + 1 WHERE username = '$PLAYER'")
      UPDATE_BEST_GAME=$($PSQL "UPDATE players SET best_game = 0 WHERE username = '$GET_USERNAME'")
      done
    fi
    #give a second delay
    sleep 1
    echo "Guess the secret number between 1 and 1000:"
    #set the random number
    NUMBER=$((RANDOM%1000+1))
    #start the game
    GAMES_PAGE
}

GAMES_PAGE() {
  #get the best_game
  BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE username = '$GET_USERNAME'")
  UPDATED_NUMBER_GUESS=$($PSQL "UPDATE players SET best_game = $BEST_GAME + 1 WHERE username = '$GET_USERNAME'")
  read GUESS_NUMBER
        #if it's correct answer
        if [[ $GUESS_NUMBER = $NUMBER ]]
         then
         #get the updated best game
          BEST_GAME2=$($PSQL "SELECT best_game FROM players WHERE username = '$GET_USERNAME'")
          echo "You guessed it in $BEST_GAME2 tries. The secret number was $GUESS_NUMBER. Nice job!"
          else
          #if the answer is larger than the secret number
        if [[ $GUESS_NUMBER -gt $NUMBER ]]
          then
          echo "It's lower than that, guess again:"
          #return to start over Games Page
          GAMES_PAGE
          #if the answer is smaller than the secret number
        elif [[ $GUESS_NUMBER -lt $NUMBER ]]
          then
          echo "It's higher than that, guess again:"
          #return to start over Games Page
          GAMES_PAGE
          #if not a number
          elif [[ ! $GUESS_NUMBER =~ ^[0-9]+$ ]]
          then
            echo "That is not an integer, guess again:"
            #return to start over Games Page
            GAMES_PAGE
          fi
        fi

}





MAIN_PAGE
