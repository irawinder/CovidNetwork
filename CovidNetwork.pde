// https://www.census.gov/popclock/
private int US_POP_SIZE = 329463471;

// https://www.npr.org/sections/coronavirus-live-updates/2020/03/29/823517467/fauci-estimates-that-100-000-to-200-000-americans-could-die-from-the-coronavirus
private int NUM_DEATHS = 200000;

// https://www.brandwatch.com/blog/facebook-statistics/
private int NUM_FRIENDS = 338;

// Scale down population so that simulation can be done more quickly
// (i.e. Marginal benefit of simulating whole population does not add significantly to accuracy)
int POP_SCALER = 10000;
  
private ArrayList<Person> population;
private HashMap<Integer, Integer> deathHistogram;

public void setup() { 
  run(NUM_FRIENDS, NUM_DEATHS, US_POP_SIZE);
}

private void run(int numFriends, int numDead, int popSize) {
  
  // Make Population
  println("------------------\nInitializing Population ...");
  population = new ArrayList<Person>();
  for(int i=0; i<popSize/POP_SCALER; i++) {
    population.add(new Person());
  }
  println("  Total Pop: " + population.size() * POP_SCALER);
  
  // Populate their social networks
  println("Initializing Social Networks ...");
  for(Person current : population) {
    for(int i=0; i<numFriends; i++) {
      int index = (int)(popSize/POP_SCALER*Math.random());
      Person friend = population.get(index);
      current.addFriend(friend);
    }
  }
  println("  Total Friends: " + numFriends);
  
  // Subset of People Fall Vicitim
  println("Updating Victims ...");
  for(int i=0; i<numDead/POP_SCALER; i++) {
    int index = (int)(popSize/POP_SCALER*Math.random());
    population.get(index).kill();
  }
  println("  Total Dead: " + numDead);
    
  // For each person, calculate how many deaths they see in their social network 
  // and add this figure to the deathHistogram
  println("Counting Victims ...");
  deathHistogram = new HashMap<Integer, Integer>();
  for(Person current : population) {
    
    // Don't count current person if dead
    if(current.alive()) {;
    
      // Count Dead Friends
      int deadFriends = 0;
      for(Person friend : current.getFacebookFriends()) {
        if(!friend.alive()) deadFriends++;
      }
      
      // Add Count to Histogram
      int count = 0;
      if(deathHistogram.containsKey(deadFriends)) {
        count = deathHistogram.get(deadFriends);
      }
      deathHistogram.put(deadFriends, count + 1);
    }
  }
  
  // Print Histogram to console
  for(int i=0; i<20; i++) {
    int count = 0;
    if(deathHistogram.containsKey(i)) {
      count = deathHistogram.get(i);
    }
    println("  #Friends who fell victim = " + i + "; " + "Count: " + count);
  }
  
  // Print percent of people with one or more dead friends
  int count = population.size();
  if(deathHistogram.containsKey(0)) {
    count -= deathHistogram.get(0);
  }
  println("Chance of knowing one or more victims: " + 100.0 * count / population.size() + "%");
}

private class SocialNetwork {
  
  private ArrayList<Person> friends;
  
  public SocialNetwork() {
    this.friends = new ArrayList<Person>();
  }
  
  public void addFriend(Person friend) {
    this.friends.add(friend);
  }
  
  public ArrayList<Person> getFriends() {
    return this.friends;
  }
}

private class Person {
  
  private SocialNetwork facebook;
  private boolean alive;
  
  public Person() {
    this.facebook = new SocialNetwork();
    this.alive = true;
  }
  
  public void addFriend(Person friend) {
    this.facebook.addFriend(friend);
  }
  
  public void kill() {
    this.alive = false;
  }
  
  public boolean alive() {
    return this.alive;
  }
  
  public ArrayList<Person> getFacebookFriends() {
    return this.facebook.getFriends();
  }
}
