#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))

# Read the user input
echo Enter your username:
read NICKNAME

USERNAME_INSERTED=$($PSQL "SELECT username,games_played,best_game FROM games WHERE username='$NICKNAME'")

if [[ -z $USERNAME_INSERTED ]] # If there isn't an user with that nickname
then
  while [[ ${#NICKNAME} -gt 22 ]] # Validating that the new user has a nickname with length <= 22
  do
    echo "You cannot use a username longer than 22 characters."
    read NICKNAME
  done
  echo -e "\nWelcome $NICKNAME! It looks like this is your first time here."
else # If the user has already played
  echo "$USERNAME_INSERTED" | while IFS='|' read -r USERNAME GAMES_PLAYED BEST_GAME; do
    echo -e "\nWelcome back, $NICKNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

TOTAL_GUESSES=0

echo -e "\nGuess the secret number between 1 and 1000:"

# Counting the number of guesses
while [[ true ]]
do
  read NEW_GUESS
  
  if [[ ! $NEW_GUESS =~ ^[0-9]+$ ]] # Checking if the input is a number
  then 
    echo "The input has to be a number."
  else
    (( TOTAL_GUESSES++ ))

    if [[ $NEW_GUESS -gt $RANDOM_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    elif [[ $NEW_GUESS -lt $RANDOM_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    else
      echo "That's the number"
      break
    fi 
  fi
done

echo -e "\nYou guessed it in $TOTAL_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"

if [[ -z $USERNAME_INSERTED ]] # Inserting the new user to the database
then
  INSERT_INTO=$($PSQL "INSERT INTO games (username,games_played,best_game) VALUES ('$NICKNAME',1,$TOTAL_GUESSES)")
else # Updating the user's row
  echo "$USERNAME_INSERTED" | while IFS='|' read -r USERNAME GAMES_PLAYED BEST_GAME
  do  
    if [[ $TOTAL_GUESSES -lt $BEST_GAME ]]
    then
      UPDATE=$($PSQL "UPDATE games SET best_game=$TOTAL_GUESSES, games_played=($GAMES_PLAYED) + 1 WHERE username='$NICKNAME'")
    else 
      UPDATE=$($PSQL "UPDATE games SET games_played=($GAMES_PLAYED) + 1 WHERE username='$NICKNAME'")
    fi
  done
fi