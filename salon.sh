#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"



MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "$1\n"
  fi

  echo -e "Welcome to My Salon, how can I help you?"
 
  # Show the list of services to pick from
  SERVICES_RESULT=$($PSQL "SELECT * FROM services")
  echo "$SERVICES_RESULT" | while read SERVICE_ID BAR SERVICE_NAME
  do
  echo "$SERVICE_ID) $SERVICE_NAME"
  done
  
  #take input from customer
  read SERVICE_ID_SELECTED
  # Check if service exists
  SERVICE_RESULT=$($PSQL "SELECT * FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
  if [[ -z $SERVICE_RESULT ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    PHONE_CHECK=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $PHONE_CHECK ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      echo $($PSQL "INSERT INTO customers(phone,name) VALUES ('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi
    echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME"
    read SERVICE_TIME
    echo -e "\nI have put you down for a cut at $SERVICE_TIME, $CUSTOMER_NAME."
    # set appointment in appointment table
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    
  fi
  

}

MAIN_MENU
