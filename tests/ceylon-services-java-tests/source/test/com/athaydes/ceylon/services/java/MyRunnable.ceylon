import com.google.auto.service {
	autoService
}

import java.lang {
	Runnable
}

autoService(`interface Runnable`)  class MyRunnable() 
	satisfies Runnable {
	
	shared actual void run() {
		print("Running MjkjkjyRunnable");
	}
	
}
