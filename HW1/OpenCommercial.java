import java.net.*;
import java.io.*;
class OpenComercial{
public static void main(String[] arg) throws Exception {

    BufferedReader keyboard;
    String inputLine;

    keyboard = new BufferedReader(new InputStreamReader(System.in));

    System.out.print("Please enter the name of a company (without spaces): ");
    System.out.flush();        /* Make sure the line is printed immediately. */
    inputLine = keyboard.readLine();
    URL u = new URL("http://www."+inputLine+".com/");
    
    BufferedReader in = new BufferedReader(new InputStreamReader(u.openStream()));
    String array[] = new String[5];
    for (int i=0; i<5; i++){
        array[i] = in.readLine();
    }
        for(int i=4;i>=0;i--)
    {
        System.out.println(array[i]);        
    }
   }
}