#define NETWORK_SIZE 12
#define NETWORK_DEPTH 13
#define AVG_DIVISOR 3

//there are 8 spots for the chip to average, so historical data is weighted pretty heavily
#define DIFF_THRESHOLD 50
#define DETECT_COUNT 2

#define BOARD_SELECT_SLOT 0
#define NIBBLE_SLOT 1
#define DETECT_SLOT 2
#define DETECT_COUNT_SLOT 3
#define SUM_SLOT 4
#define VALUE_SLOT 5

#define VALUE_HISTORY_START VALUE_SLOT
#define VALUE_HISTORY_END (NETWORK_DEPTH - 1)

// {boardNumber, word, detect, detect_ct, sum, value, value, value, value, value, value, value}
int network[NETWORK_SIZE][NETWORK_DEPTH] = {
  {2,0, 0,0, 0,0,0},
  {2,1, 0,0, 0,0,0},
  {2,2, 0,0, 0,0,0},
  {2,3, 0,0, 0,0,0},
  {2,4, 0,0, 0,0,0},
  {2,5, 0,0, 0,0,0},
  {2,7, 0,0, 0,0,0},
  {2,8, 0,0, 0,0,0},
  {2,9, 0,0, 0,0,0},
  {2,10,0,0, 0,0,0},
  {2,11,0,0, 0,0,0},
  {2,12,0,0, 0,0,0},

  //{1,0, 0,0, 0,0,0},
  //{1,1, 0,0, 0,0,0},
  //{1,2, 0,0, 0,0,0},
  //{1,3, 0,0, 0,0,0},
  //{1,4, 0,0, 0,0,0},
  //{1,5, 0,0, 0,0,0},
  //{1,7, 0,0, 0,0,0},
  //{1,8, 0,0, 0,0,0},
  //{1,9, 0,0, 0,0,0},
  //{1,10,0,0, 0,0,0},
  //{1,11,0,0, 0,0,0},
  //{1,12,0,0, 0,0,0},
};

int current_value_slot = VALUE_HISTORY_START;


void setup(){
  DDRB = B00111111;

  //Give the ability to pick the mux chip
  pinMode(2,OUTPUT);
  pinMode(3,OUTPUT);
  digitalWrite(2,1);
  digitalWrite(3,1);

  pinMode(7,INPUT);
  digitalWrite(7,1);

  PORTB = B0;
  Serial.begin(115200);


  //bootstrap the sensor network
  for (int i=0; i<5; i++){
    read_sensors(current_value_slot, network);
    increment();
  }

  zero_detect_pins();

}

int state = false;

void loop(){

  //PORTB = 7;
  //digitalWrite(3,0);
  //digitalWrite(2,1);

  //Serial.print(analogRead(0));

  //for (;;);

  read_sensors(current_value_slot, network);
  //Serial.println(current_value_slot);
  print_network(network);
  digitalWrite(13,state);
  state = ! state;

  increment();

  delay(50);
  ////Serial.println(VALUE_HISTORY_END);
  //Serial.println(); Serial.println(); Serial.println();
  //Serial.println(); Serial.println(); Serial.println();
  //Serial.println(); Serial.println(); Serial.println();
}


void increment(){
  current_value_slot ++;
  if (current_value_slot > VALUE_HISTORY_END)
    current_value_slot = VALUE_HISTORY_START;
}

void zero_detect_pins(){
  for (int i=0; i < NETWORK_SIZE; i++){
      network[i][DETECT_SLOT] = 0;
      network[i][DETECT_COUNT_SLOT] = 0;
  }
}


void print_network(int network[][NETWORK_DEPTH]){
  for (int i=0; i < NETWORK_SIZE; i++){
    //for (int j=0; j < NETWORK_DEPTH; j++){
      Serial.print(network[i][DETECT_SLOT]);
    //  Serial.print(network[i][j]);
    //  Serial.print(' ');
    //}
    Serial.print(' ');
  }
  Serial.println();
}

void read_sensors(int into_slot, int network[][NETWORK_DEPTH]){
  for (int i = 0; i < NETWORK_SIZE; i++)
    read_sensor(i, into_slot, network);
}

int read_sensor(int network_port, int into_slot, int network[][NETWORK_DEPTH]){
  int *port = network[network_port];

  //set the mux nibble to pull the correct pin
  //Serial.print(port[0]);
  //Serial.print(' ');
  //Serial.println(port[1]);
  PORTB = port[NIBBLE_SLOT];

  if (port[BOARD_SELECT_SLOT] == 2){
    digitalWrite(2,0);
    digitalWrite(3,1);
  }else{
    digitalWrite(2,1);
    digitalWrite(3,0);
  }

  port[SUM_SLOT] -= port[into_slot];

  port[into_slot] = analogRead(A0);

  port[SUM_SLOT] += port[into_slot];
  int avg = port[SUM_SLOT] >> AVG_DIVISOR;

  int diff = port[into_slot] - avg;

  //Serial.print("into_slot:");
  //Serial.print(into_slot);
  //Serial.print("  ");

  //for (int i=0; i<NETWORK_DEPTH; i++){
  //  Serial.print(port[i]);
  //  Serial.print(' ');
  //}
  //Serial.print("...............");
  //Serial.print("diff:");
  //Serial.print(diff);
  //Serial.print(" avg:");
  //Serial.print(avg);
  //Serial.print(" detect:");
  //Serial.print(port[DETECT_SLOT]);
  //Serial.print(" detect_ct:");
  //Serial.print(port[DETECT_COUNT_SLOT]);
  //Serial.println();

  //we no longer care about the history, zero it out and set the avg to our current value
  if (port[DETECT_SLOT])
    port[DETECT_SLOT] ++;

  if (abs(diff) > DIFF_THRESHOLD){
    port[DETECT_COUNT_SLOT] ++;

    if (port[DETECT_COUNT_SLOT] > DETECT_COUNT){
      port[DETECT_SLOT] = (diff < 0);
      port[DETECT_COUNT_SLOT] = 0;
    }
  } else {
    port[DETECT_COUNT_SLOT] = 0;
  }

  if (port[DETECT_SLOT] > 60)
    port[DETECT_SLOT] = port[DETECT_COUNT] = 0;
}
