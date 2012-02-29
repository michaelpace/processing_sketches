BufferedReader reader;
String line;
PrintWriter output;

wall wl = new wall(67);
ship sh = new ship();
block bl = new block();
score sc = new score();

int blockcounter;
String state;
color bg;
int fr;
String highscore;
boolean ready;
boolean ridin;
boolean screwed;

void setup(){
  size(400, 200);
  reader = createReader("highscore.txt");
  try {
    line = reader.readLine();
    } 
  catch (IOException e) {
    e.printStackTrace();
    line = null;
  }
  fr = 23;
  frameRate(fr);
  bg = 255;
  fill(0);
  noStroke();
  wl.drawwall();
  blockcounter = 0;
  ready = false;
  ridin = false;
  screwed = false;
  state = "yi";
}

void draw(){
  frameRate(fr);
  
  // save high score
  if(line != null){
    if (sc.playerscore/10 > int(line)){
      output = createWriter("highscore.txt"); 
      output.print(sc.playerscore/10);
      output.close();
      reader = createReader("highscore.txt");
      try {
        line = reader.readLine();
      } 
      catch (IOException e) {
        e.printStackTrace();
        line = null;
      }
    }
  }
  
  // increase speed
  if (sc.playerscore%500==0 && sc.playerscore!=0){
    fr+=2;
  }
  
  
  if (state.equals("er")){
    blockcounter += 1;
    if(blockcounter%int(random(50, 90))==0 && random(2) >= 0.5){
      bl.insertblock();
    }
    if(ridin) bg = 235;
    else bg = 255;
    if(!screwed)background(bg);
    wl.updatewall();
    sh.updateship();
    sc.updatescore();
    wl.drawwall();
    sc.drawscore();
    bl.updateblock();
    bl.drawblock();
    sh.drawship();
  }
  
  else if (state.equals("san")){
    background(random(250, 255));
    for(int i = 0; i < width; i ++){
      fill(int(random(100, 200)));
      if(i%10==0) text(sc.playerscore/10, (i*2.1)+2, i+12);
    }
  }
  
  else if(state.equals("si")){
    background(random(250, 255));
    for(int i = 0; i < width; i ++){
      fill(int(random(100, 200)));
      if(i%10==0) text("high score = " + line, (i*2.1)+2, i+12);
    }
  }
  
  // state equals yi
  else{
    assert state.equals("yi");
    background(random(250, 255));
    for(int i = 0; i < width; i ++){
      fill(int(random(100, 200)));
      if(i%10==0) text("press any key", (i*2.1), i+10);
    }
  }
}

void restart(){
  state = "san";
  fr = 23;
  wl.closing = 0;
  screwed = false;
}

void keyReleased(){
  ready = true;
}

void keyPressed(){
  if(state.equals("yi")) state = "er";
  else if (ready){
    if(state.equals("san")) state = "si";
    else if(state.equals("si")){
      sc.resetscore();
      bl.resetblock();
      sh.resetship();
      wl = new wall(67);
      state = "er";
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
  
  wall(int tempypos){
    for(int i = 0; i < vals.length; i++){
      vals[i] = tempypos;
    }
    dir = 0;
    temp = 0;
    closing = 0;
  }
  
  void updatewall(){
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
  
  void drawwall(){
    for(int i = 0; i < vals.length; i++){
      if(screwed)fill(random(100,200));
      else fill(0);
      int ytop = vals[i];
      float ybot = vals[i]+(height/2)+closing;
      text("-", i*10, ytop);
      text("-", i*10, ybot);
      fill(255);
      if(!screwed)rect(i*10, vals[i]-3, 10, (height/2)+closing-3);
      if(ridin)fill(random(100));
      else fill(0);
      // dots on top
      if(screwed)fill(random(200, 255));
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
  public float ypos;
  float traj;
  float[] tvals = new float[8];
 
 ship(){
  ypos = 100;
  traj = 0.0;
  for(int i = 0; i < tvals.length; i++){
    tvals[i] = 0.0;
  }
 }
 
 void resetship(){
  ypos = 100;
  traj = 0.0;
  newtail();
 }
 
 void updateship(){
   // movement
   if(keyPressed == true){
     if(traj>0) traj -= 1.25;
     else traj -= .5;
   }
   else{
     if(traj<0) traj += 1.25;
     else traj += .5;
   }
   ypos += traj;
   
   updatetail();
   
   // check for collision with wall
   if ((ypos < wl.vals[8] || ypos > wl.vals[8] + (height/2) + wl.closing || abs(ypos - bl.blockvals[8] + 0.0) <= 9) && keyPressed){
     if(screwed){
       state = "san";
       restart();
     }
     else screwed = true;
   }
   else if((ypos < wl.vals[8] || ypos > wl.vals[8] + (height/2) + wl.closing || abs(ypos - bl.blockvals[8] + 0.0) <= 9) && !keyPressed){
     if(screwed){
       state = "san";
       restart();
     }
     else screwed = true;
   }
 }
  
  void drawship(){
    if(screwed)fill(random(random(0, 10), random(245, 255)));
    text(">", 80, ypos);
    drawtail();
  }
  
  void updatetail(){
   // tail
   for(int i = 0; i < tvals.length-1; i++){
     tvals[i] = tvals[i+1];
   }
   tvals[tvals.length-1] = ypos;
  }
  
  void drawtail(){
    for(int i = 0; i < tvals.length; i++){
      text("-", i*10, tvals[i]);
    }
  }
  
  void newtail(){
   for(int i = 0; i < tvals.length; i++){
     tvals[i] = 100;
   }
  }
}

class block{
  public float[] blockvals = new float[41];
  
  block(){
    for(int i = 0; i < blockvals.length; i++){
      blockvals[i] = -200.0;
    }
  }
  
  void resetblock(){
    for(int i = 0; i < blockvals.length; i++){
      blockvals[i] = -200.0;
    }
  }
  
  void insertblock(){
    blockvals[blockvals.length-1] = random(wl.vals[wl.vals.length-1]+5, wl.vals[wl.vals.length-1]+(height/2)+wl.closing-5);
  }
  
  void updateblock(){
    for(int i = 0; i < blockvals.length-1; i++){
      blockvals[i] = blockvals[i+1];
    }
    blockvals[blockvals.length-1] = -200.0;
  }
  
  void drawblock(){
    if(screwed) fill(random(100));
    else fill(0);
    for(int i = 0; i < blockvals.length; i++){
      text("|", (i*10), blockvals[i]+2);
      text("|", (i*10), blockvals[i]);
      text("|", (i*10), blockvals[i]-2);
    }
  }
}

class score{
  int playerscore;
  score(){
    playerscore = 0;
  }
  
  void updatescore(){
    if(abs(sh.ypos - wl.vals[8]) <= 12 || abs(sh.ypos - (wl.vals[8]+(height/2)) - wl.closing) <= 12){
      ridin = true;
      playerscore += 1;
    }
    else ridin = false;
    if(screwed) playerscore += 1;
    playerscore += 1;
  }
  
  void resetscore(){
    playerscore = 0;
  }
  
  void drawscore(){
    fill(255);
    rect(0, 0, width, 12);
    fill(0);
    text(playerscore/10, 1, 11);
  }
}
