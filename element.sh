#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table --tuples-only -c"


PROVIDE_AN_ARGUMENT_MESSAGE() {
  echo -e "Please provide an element as an argument."
}

ELEMENT_NOT_FOUND_MESSAGE() {
  echo -e "I could not find that element in the database."
}

GET_ELEMENT_RESULT_AND_PRINT_MESSAGE() {
  ATOMIC_NUMBER=$1

  # get remaining information of by atomic_number
  ELEMENT_RESULT=$($PSQL "SELECT elements.atomic_number,symbol,name,atomic_mass,melting_point_celsius,boiling_point_celsius,type
    FROM elements
    JOIN properties ON elements.atomic_number=properties.atomic_number
    JOIN types ON properties.type_id=types.type_id WHERE elements.atomic_number=$ATOMIC_NUMBER")

  # print final message
  echo "$ELEMENT_RESULT" | while read NUMBER bar SYMBOL bar NAME bar MASS bar MELTING_POINT bar BOILING_POINT bar TYPE
  do
    echo "The element with atomic number $NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  done
}

TEST_ATOMIC_NUMBER_AND_PRINT_MESSAGE() {
  ATOMIC_NUMBER=$1
  if [[ -z $ATOMIC_NUMBER ]]; then
    ELEMENT_NOT_FOUND_MESSAGE
  else
    # if found, get remaining information and print final message
    GET_ELEMENT_RESULT_AND_PRINT_MESSAGE $ATOMIC_NUMBER
  fi
}

# element.sh input value
INPUT=$1


# If no argument provided
if [[ -z $INPUT ]] ; then
	PROVIDE_AN_ARGUMENT_MESSAGE
else

	# check if argument $1 is only digits (a number)
	if [[ $INPUT =~ ^[0-9]+$ ]]; then
		# get element by atomic_number
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$INPUT")
    TEST_ATOMIC_NUMBER_AND_PRINT_MESSAGE $ATOMIC_NUMBER

	# check if argument $1 is only <= 2 letters (a symbol)
	elif [[ $1 =~ ^[a-zA-Z][a-zA-Z]?$ ]] ; then
		# get element's atomic_number by symbol
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$INPUT'")
    TEST_ATOMIC_NUMBER_AND_PRINT_MESSAGE $ATOMIC_NUMBER
		

	# check if argument $1 is >= 3 letters (name)
	elif [[ $1 =~ ^[a-zA-Z][a-zA-Z]+$ ]] ; then

    # get element's atomic_number by symbol
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$INPUT'")
    TEST_ATOMIC_NUMBER_AND_PRINT_MESSAGE $ATOMIC_NUMBER

	#else
  #  PROVIDE_AN_ARGUMENT_MESSAGE
  fi
fi
