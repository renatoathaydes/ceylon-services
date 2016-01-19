import ceylon.interop.java {
	javaClass
}
import ceylon.language.meta {
	type
}

import com.athaydes.ceylon.services.core {
	ProvidedService
}

import java.util {
	ServiceLoader
}
import java.lang {
	Runnable
}

shared {ProvidedService<Anything, Anything>*} loadAllJavaServices() {
	ServiceLoader<Runnable> allLoader = ServiceLoader.load(javaClass<Runnable>());
	value serviceIterator = allLoader.iterator();
	
	variable {ProvidedService<Anything, Anything>*} result = {};
	
	while (serviceIterator.hasNext()) {
		value service = serviceIterator.next();
		value providedService = ProvidedService<Anything, Anything>(type(service) -> type(service));
		result = result.chain { providedService };
	}
	
	return result;
}
