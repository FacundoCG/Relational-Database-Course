#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"

SALON(){
  if [[ $1 ]]
  then
    echo $1
  fi

  # Get list of services
  SERVICES_LIST=$($PSQL "SELECT * FROM services")

  # Check if there are services
  if [[ -z $SERVICES_LIST ]]
  then
    echo -e "\nSorry, we don't any have any service available now."
  else
    # Display services
    echo "$SERVICES_LIST" | while read SERVICE_ID BAR SERVICE_NAME
    do
        echo "$SERVICE_ID) $SERVICE_NAME"
    done

    # Read service chosen
    read SERVICE_ID_SELECTED
    SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    echo $SERVICE_ID

    # Check if the service chosen is valid
    if [[ -z $SERVICE_ID ]]
    then
      SALON "I could not find that service. What would you like today?"
    else
      REGISTER_SERVICE $SERVICE_ID
    fi
  fi
}

REGISTER_SERVICE(){
  SERVICE_ID=$1

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_PHONE_INSERTED=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # Check if there is an user with that phone
  if [[ -z $CUSTOMER_PHONE_INSERTED ]]
  then
    # If the user is new, I insert him/her in the database
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers (phone,name) VALUES ('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
  fi

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/ //')
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID")
  SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/ //')
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
  read SERVICE_TIME

  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id,service_id,time) VALUES ($CUSTOMER_ID,$SERVICE_ID,'$SERVICE_TIME')")

  echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
}

SALON