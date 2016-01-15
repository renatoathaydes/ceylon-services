import ceylon.test {
	test,
	assertThatException
}

import com.athaydes.ceylon.services {
	component,
	initializeModules,
	CeylonModule,
	ProvidedService,
	CircularDependenciesException
}

shared class C1(C2 c2) {}

shared class C2(C1 c1) {}

class CircularDependenciesTest() {
	
	test
	shared void circularDependencyTest() {
		value module1 = CeylonModule {
			name = "circularDependencyTest";
			providedServices = {
				ProvidedService(`C1` -> `C1`),
				ProvidedService(`C2` -> `C2`, [component])
			};
			requiredServices = { `C1` -> [], `C2` -> [] };
		};
		
		assertThatException(() => initializeModules { module1 }).hasType(`CircularDependenciesException`);
	}
	
}
