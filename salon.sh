#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Appointments ~~~~~\n"

SCHEDULE_APPOINTMENT(){
  echo -e "\nWelcome, please select a service:" 
  # get service type
  SERVICE_TYPE=$($PSQL "SELECT service_id,name FROM services ORDER BY service_id")
  
  # display services
  echo "$SERVICE_TYPE" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED

  # if input is not valid
  if [[ ! $SERVICE_ID_SELECTED =~ [1-3] ]]
  then
    SCHEDULE_APPOINTMENT
  else
    # get customer info
    echo -e "\nWhat is your phone number?"
    read CUSTOMER_PHONE

    # get customer name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    #if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # get new customer info
      echo -e "\nWhat is your name?"
      read CUSTOMER_NAME

      # insert new customer name
      INSERT_CUSTOMER_NAME=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
    fi

    # get appointment time
    echo -e "\nWhat time would you like to schedule your appointment for?"
    read SERVICE_TIME

    # get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # insert appointmet
    INSERT_SERVICE_TIME=$($PSQL "INSERT INTO appointments(time,customer_id,service_id) VALUES('$SERVICE_TIME',$CUSTOMER_ID,$SERVICE_ID_SELECTED)")

    # get service name
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    # notify customer of details
    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
  fi
}

SCHEDULE_APPOINTMENT
