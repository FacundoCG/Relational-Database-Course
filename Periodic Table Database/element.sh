echo Please provide an element as an argument.

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# I look for the information of the element in the database
if [[ $1 =~ ^[0-9]+$ ]] # If the input is a number
then 
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1;")
else 
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1' OR name='$1';")
fi

if [[ -z $ATOMIC_NUMBER ]] # If the element doesn't exist
then
  echo I could not find that element in the database.
else
  ELEMENT_INFORMATION=$($PSQL "SELECT * FROM properties JOIN elements USING (atomic_number) WHERE atomic_number=$ATOMIC_NUMBER")
  echo "$ELEMENT_INFORMATION" | while read ATOMIC_N BAR ATOMIC_MASS BAR MELTING_POINT BAR BOILING_POINT BAR TYPE_ID BAR SYMBOL BAR NAME
  do
    ELEMENT_TYPE=$($PSQL "SELECT type FROM types WHERE type_id=$TYPE_ID")
    ELEMENT_TYPE_FORMATTED=$(echo $ELEMENT_TYPE | sed 's/ //')
    echo "The element with atomic number $ATOMIC_N is $NAME ($SYMBOL). It's a $ELEMENT_TYPE_FORMATTED, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  done 
fi
