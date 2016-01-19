import ceylon.test {
	test,
	assertEquals
}
import com.athaydes.ceylon.services.java {
	loadAllJavaServices
}

test
shared void canLoadCeylonServiceExportedAsJavaService() {
	value javaServices = loadAllJavaServices();
	
	assertEquals(javaServices*.serviceType*.item.sequence(), [ `MyRunnable` ]);
}
