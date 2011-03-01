// {boardNumber, word, detect, sum, value, oldvalue, oldvalue, oldvalue }
#define NETWORK_SIZE 32
#define NETWORK_DEPTH 12

#define DETECT_SLOT 2
#define SUM_SLOT 3
#define VALUE_SLOT 4

#define VALUE_HISTORY_START VALUE_SLOT
#define VALUE_HISTORY_END (NETWORK_DEPTH - 1)
#define AVG_DIVISOR = 8

int network[NETWORK_SIZE][NETWORK_DEPTH] = {
  {1,0,0,0,0,0},
  {1,1,0},
  {1,2,0},
  {1,3,0},
  {1,4,0},
  {1,5,0},
  {1,6,0},
  {1,7,0},
  {1,8,0},
  {1,9,0},
  {1,10,0},
  {1,11,0},
  {1,12,0},
  {1,13,0},
  {1,14,0},
  {1,15,0},


  {2,0,0},
  {2,1,0},
  {2,2,0},
  {2,3,0},
  {2,4,0},
  {2,5,0},
  {2,6,0},
  {2,7,0},
  {2,8,0},
  {2,9,0},
  {2,10,0},
  {2,11,0},
  {2,12,0},
  {2,13,0},
  {2,14,0},
  {2,15,0},
};


void setup(){
  DDRB = B00011111;

  //Give the ability to pick the mux chip
  //make me some pull-ups!
  pinMode(2,OUTPUT);
  pinMode(3,OUTPUT);
  digitalWrite(2,1);
  digitalWrite(3,1);

  PORTB = B0;
  Serial.begin(115200);
}

void loop(){
  read_sensors(network);
  print_network(network);

  //Serial.println(VALUE_HISTORY_END);
  //for (;;);
  delay(1000);
  Serial.println();
  Serial.println();
  Serial.println();
  Serial.println();
  Serial.println();
  Serial.println();
  Serial.println();
  Serial.println();
  Serial.println();
}

int increment(int counter){
  counter ++;

  //nothing plugged into pin 6.
  if (counter == 6)
    counter = 7;

  //nothing plugged in above 12
  if (counter > 12)
    counter = 0;

  return counter;
}

void print_network(int network[NETWORK_SIZE][NETWORK_DEPTH]){
  for (int i=0; i < NETWORK_SIZE; i++){
    for (int j=0; j < NETWORK_DEPTH; j++){
      Serial.print(network[i][j]);
      Serial.print(' ');
    }
    Serial.println();
  }
}

void read_sensors(int network[NETWORK_SIZE][NETWORK_DEPTH]){
  for (int i = 0; i < NETWORK_SIZE; i++)
    read_sensor(i, network);
}

int read_sensor(int network_port, int network[NETWORK_SIZE][NETWORK_DEPTH]){
  int *port = network[network_port];

  //set the mux nibble to pull the correct pin
  //Serial.print(port[0]);
  //Serial.print(' ');
  //Serial.println(port[1]);
  PORTB = port[1];

  if (port[0] == 2){
    digitalWrite(2,0);
    digitalWrite(3,1);
  }else{
    digitalWrite(2,1);
    digitalWrite(3,0);
  }

  port[SUM_SLOT] -= port[VALUE_HISTORY_END];

  for (int j=VALUE_HISTORY_END; j>VALUE_HISTORY_START; j--){
    port[j] = port[j-1];
  }

  port[VALUE_SLOT] = analogRead(A0);
  port[SUM_SLOT] += port[VALUE_SLOT];
}
