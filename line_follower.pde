//
// Please read the Romeo WIKI
// http://www.dfrobot.com/wiki/index.php?title=DFRduino_Romeo-All_in_one_Controller_%28SKU:DFR0004%29
//

//
// Set debug to true to switch to motor debug mode.
// Motor debug mode allow you to increase or decrease motors power step by step
// by pressing s6 and s7, it's usefull to verify how they work.
//
// We should use a button to switch at runtine between debug and line follower.
//
// While debugging, curent motor speed is printed out to the serial port.
//
byte debug_mode = false;
byte debug_default_speed = 0;

// Line follower slow and fast motor speed, slow is used when the line is seen,
// else fast is used.
byte slow = 0;
byte fast = 40;

// Arduino configuration
byte key_run = 2;
byte key_stop = 3;
byte m1_direction = 4;
byte m1_speed = 5;
byte m2_speed = 6;
byte m2_direction = 7;
byte led1 = 10;
byte led2 = 11;
byte sensor_left = 12;
byte sensor_right = 13;

byte input[] = {sensor_left, sensor_right, key_run, key_stop};
byte output[] = {m1_speed, m2_speed, m1_direction, m2_direction, led1, led2};

byte running = 0;
byte speed = debug_default_speed;

//
// Setup the arduino according to input[] and output[] arrays.
//
void setup()
{
   byte i;

   for (i = 0; i < sizeof(input); ++i)
       pinMode(input[i], INPUT);
   for (i = 0; i < sizeof(output); ++i)
       pinMode(output[i], OUTPUT);
   Serial.begin(9600);
   digitalWrite(m1_direction, HIGH);
   digitalWrite(m2_direction, HIGH);
}

void stop_motors()
{
   analogWrite(m1_speed, 0);
   analogWrite(m2_speed, 0);
}

//
// Main code of the line follower, the algorithm is basic and simple :
// Stop the wheel at the oposite side of the sensor seeing the line
//
// Also switch led1 and led2 to give a visual feedback on how and when motors
// are powered.
//
void follow_line()
{
   if (digitalRead(sensor_right))
   {
       analogWrite(m1_speed, fast);
       digitalWrite(led2, HIGH);
   }
   else
   {
       analogWrite(m1_speed, slow);
       digitalWrite(led2, LOW);
   }
   if (digitalRead(sensor_left))
   {
       analogWrite(m2_speed, fast);
       digitalWrite(led1, HIGH);
   }
   else
   {
       analogWrite(m2_speed, slow);
       digitalWrite(led1, LOW);
   }
}

//
// Function to test motors,
// Use s6 and s7 to increase or decrease motors speed.
//
void debug()
{
   if (digitalRead(key_run))
   {
       speed += 2;
       Serial.println(speed);
   }
   if (digitalRead(key_stop))
   {
       speed -= 2;
       Serial.println(speed);
   }
   analogWrite(m1_speed, speed);
   analogWrite(m2_speed, speed);
   delay(100);
}

//
// Main Arduino loop, use key_run (s6) and key_stop (s7) to start or stop
// the program, by default the robot is stopped.
//
void loop()
{
   if (digitalRead(key_stop))
   {
       stop_motors();
       running = false;
   }
   else if (digitalRead(key_run))
   {
       running = true;
   }
   if (!running)
       return ;
   if (debug_mode)
       debug();
   else
       follow_line();
}
