import jeliot.io.*;

public class MyClass {
    public static void main() {
        ///Creating instance of my stack
        MyStack stack = new MyStack();
        
        //Algorithm pushes three items on to the stack
        for(int i = 2; i >= 0; i--) {
            stack.Push(i);
        }
        
        //Algorithm pops three items off of the stack and reports each time it does so by writing a message to the console.
        for(int i= 0; i < 3; i++) {
            int temp = stack.Pop(); //Popping an item, and storing its value to a temp variable
            System.out.println(temp); //Printing the variable on the screen
        }
    }
}

public class MyStack {
     //Stack is implemented as either an array or linked list
     //array to store the items
    private int[] arr = new int[3];  // Array will have size of 3, as bigger is not required for the assignment
    private int currentPosition; //To store the current position 
    
    //Constructor to initialize an empty stack
    public MyStack() {
        currentPosition = 0; //Setting the current position of the empty stack to be 0
    
    }
    
    
    //Pop method to Pop items
    //Includes method (or equivalent code) to pop items off of the stack
    public int Pop(){
        //Handling low boundry border case 
        if(currentPosition == 0) {
            throw new IllegalStateException("Cannot pop from an empty stack!");
        }
        return arr[--currentPosition]; //
    }
    
    //Push method to push items
    //Includes method (or equivalent code) to push items onto the stack
    public void Push(int newItem) {
        arr[currentPosition++] = newItem; //Using post increment, i.e. the new item will be assigned to old poistion, and then curretnPosition will be increased
    }
}
