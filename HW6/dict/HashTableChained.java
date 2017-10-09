/* HashTableChained.java */

package dict;

import list.*;

/**
 *  HashTableChained implements a Dictionary as a hash table with chaining.
 *  All objects used as keys must have a valid hashCode() method, which is
 *  used to determine which bucket of the hash table an entry is stored in.
 *  Each object's hashCode() is presumed to return an int between
 *  Integer.MIN_VALUE and Integer.MAX_VALUE.  The HashTableChained class
 *  implements only the compression function, which maps the hash code to
 *  a bucket in the table's range.
 *
 *  DO NOT CHANGE ANY PROTOTYPES IN THIS FILE.
 **/

public class HashTableChained implements Dictionary {

  /**
   *  Place any data fields here.
   **/
    public int size;
    public int bucketLength;
    protected SList[] hash;
    public int listSize;



  /** 
   *  Construct a new empty hash table intended to hold roughly sizeEstimate
   *  entries.  (The precise number of buckets is up to you, but we recommend
   *  you use a prime number, and shoot for a load factor between 0.5 and 1.)
   **/

  public HashTableChained(int sizeEstimate) {
    // Your solution here.
      bucketLength = getPrime(sizeEstimate);
      hash = new SList[bucketLength];
      for (int i = 0; i<bucketLength; i++) {
          hash[i] = new SList();
      }
      size = 0;
      listSize = 0;
  }

  private static int getPrime(int num) {
      while(true){
          if(isPrime(num)) {
              return num;
          } else {
              num++;
          }
      }
  }
  
  private static boolean isPrime(int num) {
      if(num <= 0) return false;
      if(num == 1) return false;
      if(num == 2 || num == 3) return true;
      for (int i = 2; i*i <=num; i++){
          if (num%i == 0) return false;
      }
      return true;
      
  }
  /** 
   *  Construct a new empty hash table with a default size.  Say, a prime in
   *  the neighborhood of 100.
   **/

  public HashTableChained() {
    // Your solution here.
      this(100);
  }

  /**
   *  Converts a hash code in the range Integer.MIN_VALUE...Integer.MAX_VALUE
   *  to a value in the range 0...(size of hash table) - 1.
   *
   *  This function should have package protection (so we can test it), and
   *  should be used by insert, find, and remove.
   **/

  protected int compFunction(int code) {
    // Replace the following line with your solution.
    return Math.abs(code) % bucketLength;
  }

  /** 
   *  Returns the number of entries stored in the dictionary.  Entries with
   *  the same key (or even the same key and value) each still count as
   *  a separate entry.
   *  @return number of entries in the dictionary.
   **/

  public int size() {
    // Replace the following line with your solution.
    return size;
  }

  /** 
   *  Tests if the dictionary is empty.
   *
   *  @return true if the dictionary has no entries; false otherwise.
   **/

  public boolean isEmpty() {
    // Replace the following line with your solution.
    return size == 0;
  }

  /**
   *  Create a new Entry object referencing the input key and associated value,
   *  and insert the entry into the dictionary.  Return a reference to the new
   *  entry.  Multiple entries with the same key (or even the same key and
   *  value) can coexist in the dictionary.
   *
   *  This method should run in O(1) time if the number of collisions is small.
   *
   *  @param key the key by which the entry can be retrieved.
   *  @param value an arbitrary object.
   *  @return an entry containing the key and value.
   **/

  public Entry insert(Object key, Object value) {
    // Replace the following line with your solution.
      int code = this.compFunction(key.hashCode());
      Entry en = new Entry();
      en.key = key;
      en.value = value;
      if (hash[code].length()!=0) {
          listSize++;
      }
      hash[code].insertEnd(en);
      size++;
      return en;
  }

  /** 
   *  Search for an entry with the specified key.  If such an entry is found,
   *  return it; otherwise return null.  If several entries have the specified
   *  key, choose one arbitrarily and return it.
   *
   *  This method should run in O(1) time if the number of collisions is small.
   *
   *  @param key the search key.
   *  @return an entry containing the key and an associated value, or null if
   *          no entry contains the specified key.
   **/

  public Entry find(Object key) {
    // Replace the following line with your solution.
      int code = this.compFunction(key.hashCode());
      if(hash[code].length()<1) {
          return null;
      } else {
          SListNode cur = (SListNode)hash[code].front();
          while (cur != null) {
              if (key.equals(((Entry)cur.item).key)) {
                  return (Entry)cur.item;
              } else {
                  cur = cur.next;
              }
          }
          return null;
      }
  }

  /** 
   *  Remove an entry with the specified key.  If such an entry is found,
   *  remove it from the table and return it; otherwise return null.
   *  If several entries have the specified key, choose one arbitrarily, then
   *  remove and return it.
   *
   *  This method should run in O(1) time if the number of collisions is small.
   *
   *  @param key the search key.
   *  @return an entry containing the key and an associated value, or null if
   *          no entry contains the specified key.
   */

  public Entry remove(Object key) {
    // Replace the following line with your solution.
    int code = this.compFunction(key.hashCode());
    if(hash[code].length()<1) return null;
    else {
        SListNode cur = (SListNode)hash[code].front();
        int count = 1;
        while(cur!= null) {
            if (key.equals(((Entry)cur.item).key)) {
                hash[code].remove(count);
                size--;
                return (Entry)cur.item;
            } else {
                cur = cur.next;
                count++;
            }
        }
        return null;
    }
  }

  /**
   *  Remove all entries from the dictionary.
   */
  public void makeEmpty() {
    // Your solution here.
      for (int i = 0; i<bucketLength; i++) {
          hash[i] = new SList();
      }
      size = 0;
  }
  
  public String toString() {
      String p = new String();
      for (int i=0; i<bucketLength;i++) {
          p = p+"["+hash[i].length()+"]";
          if( (i+1)%20 == 0 ) {
              p = p + "\n";
          }
      }
      return p;
  }
  
  public double collisions() {
      return (double) (size-bucketLength+bucketLength*Math.pow((double)(1-1.0/(double)bucketLength),(double)size));
  }
 
  public static void main(String[] argv) {
   System.out.println("testing");
      // test prime number function
      //test basic hash table function
      System.out.println("======================basic insert,find,remove=====================");
      HashTableChained table = new HashTableChained();
      System.out.println("table's size is: " + table.size());
      System.out.println("table is Empty: " + table.isEmpty());
      
      System.out.println("=====================insert================================");
      table.insert("1", "The first one");
      table.insert("2", "The second one");
      table.insert("3", "The third one");
      table.insert("what", "nani?");
      table.insert("the","Eh-heng");
      table.insert("hell!","impolite");
      System.out.println("table's size is: " + table.size());
      System.out.println("table is Empty: " + table.isEmpty());
      
      System.out.println("====================find, remove===========================");
      Entry e1 = table.find("what");
      if(e1 != null){
        System.out.println("The item found is: [ " + e1.toString() + " ]");
      }else{
        System.out.println("The is no such item in the table to be found.");
      }
      
      Entry e2 = table.remove("6");
      if(e2 != null){
       System.out.println("The item deleted is: [ " + e2.toString() + " ]");
      }else{
       System.out.println("The is no such item in the table to be deleted.");
      }       

      // testing makeEmpty, isEmpty, size
      System.out.println("===============test makeEmpty===================");
      System.out.println("Is empty?: "+table.isEmpty());
      System.out.println("Size before empty: "+table.size());
      table.makeEmpty();
      System.out.println("Size after empty: "+table.size());
     
  }
  
}