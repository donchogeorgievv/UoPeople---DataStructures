
public class StackImplementation {

	public static void main(String[] args) {
		
		//Creating instance of my stack
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

