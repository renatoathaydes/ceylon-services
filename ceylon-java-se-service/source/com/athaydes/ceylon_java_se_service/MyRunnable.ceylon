import com.google.auto.service {
	autoService
}

import java.lang {
	Runnable
}

autoService(`interface Runnable`)
shared class MyRunnable() satisfies Runnable {
	run() => print("Running A Ceylon Java SE Service");
}
