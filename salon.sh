#! /bin/bash

PSQL="psql -X --tuples-only --username=freecodecamp --dbname=salon -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?"

SERVICE_MENU() {

  if [[ $1 ]]
  then
    echo -e "$1"
  fi

  echo "$($PSQL "SELECT * FROM services ORDER BY service_id")" | while read ID BAR SERVICE
  do
    echo "$ID) $SERVICE"
  done

  read SERVICE_ID_SELECTED

  SERVICE_NAME="$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")"
  
  if [[ -z $SERVICE_NAME ]]
  then

    SERVICE_MENU "\nI could not find that service. What would you like today?\n"

  else

    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    PHONE_LOOKUP_RESULT="$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")"
    
    if [[ -z $PHONE_LOOKUP_RESULT ]]
    then

      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      CUSTOMER_INSERT_RESULT="$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")"

    fi

    CUSTOMER_NAME="$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")"

    echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
    read SERVICE_TIME

    CUSTOMER_ID="$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")"
    echo $CUSTOMER_ID
    APPOINTMENT_INSERT_RESULT="$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")"

    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."

  fi
}


SERVICE_MENU

