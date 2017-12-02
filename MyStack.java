
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
