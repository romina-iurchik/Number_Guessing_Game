#!/bin/bash


PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
INICIO(){
    INTENTOS=0
    NUM_RANDOM=$(( ($RANDOM % 1000) + 1 ))
    SIGO=true
}

GET_USER(){
    #metodos de la bd
    
    echo -e "Enter your username:"
    read NAME_USER
    EXISTE=$($PSQL "SELECT username FROM BD_table WHERE username='$NAME_USER'")
    # if exite el usuario
    if [[ ! -z $EXISTE ]]
    then
        VARS=$($PSQL "SELECT username, games_played, best_game FROM BD_table  WHERE username='$NAME_USER'")
        echo "$VARS" | while IFS="|" read -r UN GP BG
        do
        # Imprimir el mensaje de bienvenida
        echo -e "Welcome back, $UN! You have played $GP games, and your best game took $BG guesses."
        done
    else
        echo "Welcome, $NAME_USER! It looks like this is your first time here."
        INSER=$($PSQL "INSERT INTO BD_table(username) VALUES('$NAME_USER')")
    fi
    PLAY
    
    
}

PLAY(){
    INICIO
    echo "Guess the secret number between 1 and 1000:"
    while [[ SIGO ]]
    do
        GET_NUMBER
    done

}



GET_NUMBER(){  
    read NUM_INGR
        if [[ $NUM_INGR =~ ^[0-9]+$ ]]
        then
            SIGO=true
            (( INTENTOS ++ ))
            JUEGO 
        else
            echo -e "That is not an integer, guess again:"
            SIGO=false
        fi
}


JUEGO(){
    if [[ $NUM_INGR -eq $NUM_RANDOM ]]
    then
    echo "You guessed it in $INTENTOS tries. The secret number was $NUM_RANDOM. Nice job!"
        ACTUALIZO_BD
        exit
    fi
    if [[ $NUM_INGR -gt $NUM_RANDOM ]]
    then
        echo "It's lower than that, guess again:"

    else
        echo "It's higher than that, guess again:"
    fi
}


ACTUALIZO_BD(){
    GAMES=$($PSQL "SELECT games_played FROM BD_table WHERE username='$NAME_USER'")
    (( GAMES ++ ))
    GAMES_PLUS=$($PSQL "UPDATE BD_table SET games_played = $GAMES WHERE username='$NAME_USER'")

    LAST=$($PSQL "SELECT best_game FROM BD_table WHERE username='$NAME_USER'")
    if [[ $LAST -gt $INTENTOS ]]
    then
        IS_BEST=$($PSQL "UPDATE BD_table SET best_game = $INTENTOS WHERE username='$NAME_USER'")
    fi
}
GET_USER


