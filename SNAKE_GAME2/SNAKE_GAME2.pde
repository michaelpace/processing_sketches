BufferedReader reader;
String savedScore;
PrintWriter output;

wall wl = new wall(67);
ship sh = new ship();
block bl = new block();
score sc = new score();

int blockCounter;
String state;
color bg;
int fr;
String highScore;
boolean ready;
boolean wallRiding;
boolean impaired;

void setup(){
  size(400, 200);
  reader = createReader("highScore.txt");
  try {
    savedScore = reader.readLine();
    } 
  catch (IOException e) {
    e.printStackTrace();
    savedScore = null;
  }
  fr = 23;
  frameRate(fr);
  bg = 255;
  fill(0);
  noStroke();
  wl.drawWall();
  blockCounter = 0;
  ready = false;
  wallRiding = false;
  impaired = false;
  state = "pressAnyKeyScreen";
}

void draw(){
  frameRate(fr);
  
  
  // increase speed
  if (sc.playerScore%500==0 && sc.playerScore!=0){
    fr+=2;
  }
  
  
  if (state.equals("playScreen")){
    blockCounter += 1;
    if(blockCounter%int(random(50, 90))==0 && random(2) >= 0.5){
      bl.insertBlock();
    }
    if(wallRiding) bg = 235;
    else bg = 255;
    if(!impaired)background(bg);
    wl.updateWall();
    sh.updateShip();
    sc.updateScore();
    wl.drawWall();
    sc.drawScore();
    bl.updateBlock();
    bl.drawBlock();
    sh.drawShip();
  }
  
  else if (state.equals("yourScoreScreen")){
    background(random(250, 255));
    for(int i = 0; i < width; i ++){
      fill(int(random(100, 200)));
      if(i%10==0) text(sc.playerScore/10, (i*2.1)+2, i+12);
    }
  }
  
  else if(state.equals("highScoreScreen")){
    background(random(250, 255));
    for(int i = 0; i < width; i ++){
      fill(int(random(100, 200)));
      if(i%10==0) text("high score = " + savedScore, (i*2.1)+2, i+12);
    }
  }
  
  // state equals pressAnyKeyScreen
  else{
    assert state.equals("pressAnyKeyScreen");
    background(random(250, 255));
    for(int i = 0; i < width; i ++){
      fill(int(random(100, 200)));
      if(i%10==0) text("press any key", (i*2.1), i+10);
    }
  }
}

void endGame(){
  if(savedScore != null
     && sc.playerScore/10 > int(savedScore)){
      output = createWriter("highScore.txt"); 
      output.print(sc.playerScore/10);
      output.close();
      reader = createReader("highScore.txt");
      try {
        savedScore = reader.readLine();
      } 
      catch (IOException e) {
        e.printStackTrace();
        savedScore = "0";
      }
  }

  state = "yourScoreScreen";
  fr = 23;
  wl.closing = 0;
  impaired = false;
}

void keyReleased(){
  ready = true;
}

void keyPressed(){
  if(state.equals("pressAnyKeyScreen")) state = "playScreen";
  else if (ready){
    if(state.equals("yourScoreScreen")) state = "highScoreScreen";
    else if(state.equals("highScoreScreen")){
      sc.resetScore();
      bl.resetBlock();
      sh.resetShip();
      wl = new wall(67);
      state = "playScreen";
    }
  }
  ready = false;
}

class wall{
  public int[] vals = new int[40];
  int ytop;
  int ybot;
  int temp;
  int dir;
  public float closing;
  public boolean isclosing = true;
  
  wall(int tempyPos){
    for(int i = 0; i < vals.length; i++){
      vals[i] = tempyPos;
    }
    dir = 0;
    temp = 0;
    closing = 0;
  }
  
  void updateWall(){
    // rate at which the tunnel closes
    if(isclosing) closing -= random(.075, .3);
    else closing += random(1, 10);
    // smallest the tunnel can get
    if(closing <= random(-80, -60)) isclosing = false;
    // biggest the tunnel can get
    if(closing >= random(-40, 20)) isclosing = true;
    // update all values of vals but the last
    for(int i = 0; i < vals.length - 1; i++){
      vals[i] = vals[i+1];
    }
    if(temp == 0){
      dir = 0;
      temp = int(random(3));
      // length of up or down
      if(temp == 1) temp = 5;
      if(temp == 2) temp = -5;
    }
    if(temp > 0){
      dir = 1;
      temp -= 1;
    }
    if(temp < 0){
      dir = -1;
      temp += 1;
    }
    // add new value to vals
    vals[vals.length - 1] = vals[vals.length-2] + dir;
    while(vals[vals.length-1] > ((height/2) - 5) || vals[vals.length-1] < 20){
      temp = int(random(3));
      if(temp == 2) temp = -1;
      vals[vals.length - 1] = vals[vals.length-2] + temp;
    }
  }
  
  void drawWall(){
    for(int i = 0; i < vals.length; i++){
      if(impaired)fill(random(100,200));
      else fill(0);
      int ytop = vals[i];
      float ybot = vals[i]+(height/2)+closing;
      text("-", i*10, ytop);
      text("-", i*10, ybot);
      fill(255);
      if(!impaired)rect(i*10, vals[i]-3, 10, (height/2)+closing-3);
      if(wallRiding)fill(random(100));
      else fill(0);
      // dots on top
      if(impaired)fill(random(200, 255));
      for(int j = 0; j < vals[i]-5; j+=15){
        text(".", i*10, j);
      }
      // dots on bottom
      for(int k = height; k > vals[i]+(height/2)+closing+2; k-=15){
        text(".", i*10, k);
      }
    }
    fill(0);
  }
}

class ship{
  public float yPos;
  float traj;
  float[] tailVals = new float[8];
 
 ship(){
  yPos = 100;
  traj = 0.0;
  for(int i = 0; i < tailVals.length; i++){
    tailVals[i] = 0.0;
  }
 }
 
 void resetShip(){
  yPos = 100;
  traj = 0.0;
  newTail();
 }
 
 void updateShip(){
   // movement
   if(keyPressed == true){
     if(traj>0) traj -= 1.25;
     else traj -= .5;
   }
   else{
     if(traj<0) traj += 1.25;
     else traj += .5;
   }
   yPos += traj;
   
   updateTail();
   
   // check for collision with wall
   if ((yPos < wl.vals[8] || yPos > wl.vals[8] + (height/2) + wl.closing || abs(yPos - bl.blockVals[8] + 0.0) <= 9) && keyPressed){
     if(impaired){
       state = "yourScoreScreen";
       endGame();
     }
     else impaired = true;
   }
   else if((yPos < wl.vals[8] || yPos > wl.vals[8] + (height/2) + wl.closing || abs(yPos - bl.blockVals[8] + 0.0) <= 9) && !keyPressed){
     if(impaired){
       state = "yourScoreScreen";
       endGame();
     }
     else impaired = true;
   }
 }
  
  void drawShip(){
    if(impaired)fill(random(random(0, 10), random(245, 255)));
    text(">", 80, yPos);
    drawTail();
  }
  
  void updateTail(){
   for(int i = 0; i < tailVals.length-1; i++){
     tailVals[i] = tailVals[i+1];
   }
   tailVals[tailVals.length-1] = yPos;
  }
  
  void drawTail(){
    for(int i = 0; i < tailVals.length; i++){
      text("-", i*10, tailVals[i]);
    }
  }
  
  void newTail(){
   for(int i = 0; i < tailVals.length; i++){
     tailVals[i] = 100;
   }
  }
}

class block{
  public float[] blockVals = new float[41];
  
  block(){
    for(int i = 0; i < blockVals.length; i++){
      blockVals[i] = -200.0;
    }
  }
  
  void resetBlock(){
    for(int i = 0; i < blockVals.length; i++){
      blockVals[i] = -200.0;
    }
  }
  
  void insertBlock(){
    blockVals[blockVals.length-1] = random(wl.vals[wl.vals.length-1]+5, wl.vals[wl.vals.length-1]+(height/2)+wl.closing-5);
  }
  
  void updateBlock(){
    for(int i = 0; i < blockVals.length-1; i++){
      blockVals[i] = blockVals[i+1];
    }
    blockVals[blockVals.length-1] = -200.0;
  }
  
  void drawBlock(){
    if(impaired) fill(random(100));
    else fill(0);
    for(int i = 0; i < blockVals.length; i++){
      text("|", (i*10), blockVals[i]+2);
      text("|", (i*10), blockVals[i]);
      text("|", (i*10), blockVals[i]-2);
    }
  }
}

class score{
  int playerScore;
  score(){
    playerScore = 0;
  }
  
  void updateScore(){
    if(abs(sh.yPos - wl.vals[8]) <= 12 || abs(sh.yPos - (wl.vals[8]+(height/2)) - wl.closing) <= 12){
      wallRiding = true;
      playerScore += 1;
    }
    else wallRiding = false;
    if(impaired) playerScore += 1;
    playerScore += 1;
  }
  
  void resetScore(){
    playerScore = 0;
  }
  
  void drawScore(){
    fill(255);
    rect(0, 0, width, 12);
    fill(0);
    text(playerScore/10, 1, 11);
  }
}
