import ceylon.test {
	test,
	assertEquals,
	beforeTest
}

import com.athaydes.ceylon.services {
	component,
	CeylonModule,
	ProvidedService,
	initializeModules,
	singleton,
	serviceFactory
}

variable Integer myFirstServiceInstances = 0;
variable Integer serviceWithDepsInstances = 0;
variable Integer myInterfaceImplInstances = 0;
variable Integer userOfMyInterfaceInstances = 0;

shared class MyFirstService() {
	myFirstServiceInstances++;
}

shared class ServiceWithDependency(shared MyFirstService otherService) {
	serviceWithDepsInstances++;
}

shared interface MyInterface {}

shared class MyInterfaceImpl() satisfies MyInterface {
	myInterfaceImplInstances++;
}

shared class UserOfMyInterface(MyInterface myInterface) {
	userOfMyInterfaceInstances++;
}

shared class ModulesTest() {
	
	beforeTest
	shared void cleanup() {
		serviceFactory.clear();
	}
	
	test
	shared void canInstantiateSimpleService() {
		value currentInstances = myFirstServiceInstances;
		
		value module1 = CeylonModule {
			name = "canInstantiateSimpleService";
			providedServices = { ProvidedService(`MyFirstService` -> `MyFirstService`, [component]) };
		};
		
		initializeModules { module1 };
		
		assertEquals(myFirstServiceInstances, currentInstances + 1);
	}
	
	test
	shared void doesNotInstantiateServicesIfNotComponent() {
		value currentInstances = myFirstServiceInstances;
		value currentMyInterfaceImplInstances = myInterfaceImplInstances;
		
		value module1 = CeylonModule {
			name = "doesNotInstantiateServiceIfNotComponent";
			providedServices = {
				ProvidedService(`MyFirstService` -> `MyFirstService`, []),
				ProvidedService(`MyInterface` -> `MyInterfaceImpl`, [singleton])
			};
		};
		
		initializeModules { module1 };
		
		assertEquals(myFirstServiceInstances, currentInstances);
		assertEquals(myInterfaceImplInstances, currentMyInterfaceImplInstances);
	}

	test
	shared void singletonIsInstatiatedOnlyOnce() {
		value currentMyFirstServiceInstances = myFirstServiceInstances;
		value currentMyInterfaceImplInstances = myInterfaceImplInstances;
		
		value module1 = CeylonModule {
			name = "singletonIsInstatiatedOnlyOnce_1";
			providedServices = {
				ProvidedService(`MyFirstService` -> `MyFirstService`, []),
				ProvidedService(`UserOfMyInterface` -> `UserOfMyInterface`, [component]),
				ProvidedService(`MyInterface` -> `MyInterfaceImpl`, [singleton])
			};
			requiredServices = { `MyInterface` -> [] };
		};
		
		value module2 = CeylonModule {
			name = "singletonIsInstatiatedOnlyOnce_2";
			providedServices = {
				ProvidedService(`MyFirstService` -> `MyFirstService`, [singleton, component]),
				ProvidedService(`Object` -> `UserOfMyInterface`, [component])
			};
			requiredServices = { `MyInterface` -> [] };
		};
		
		initializeModules { module1, module2 };
		
		assertEquals(myFirstServiceInstances, currentMyFirstServiceInstances + 1);
		assertEquals(myInterfaceImplInstances, currentMyInterfaceImplInstances + 1);
	}
	
	test
	shared void canInstantiateServiceWithADependencyFromSameModule() {
		value currentMyFirstServiceInstances = myFirstServiceInstances;
		value currentServiceWithDepsInstances = serviceWithDepsInstances;
		
		value module1 = CeylonModule {
			name = "canInstantiateServiceWithADependencyFromSameModule";
			providedServices = {
				ProvidedService(`MyFirstService` -> `MyFirstService`),
				ProvidedService(`ServiceWithDependency` -> `ServiceWithDependency`, [component])
			};
			requiredServices = { `MyFirstService` -> [] };
		};
		
		initializeModules { module1 };
		
		assertEquals(myFirstServiceInstances, currentMyFirstServiceInstances + 1);
		assertEquals(serviceWithDepsInstances, currentServiceWithDepsInstances + 1);
	}
	
	test
	shared void canInstantiateServiceWithADependencyFromAnotherModule() {
		value currentMyFirstServiceInstances = myFirstServiceInstances;
		value currentServiceWithDepsInstances = serviceWithDepsInstances;
		
		value module1 = CeylonModule {
			name = "canInstantiateServiceWithADependencyFromAnotherModule_1";
			providedServices = {
				ProvidedService(`ServiceWithDependency` -> `ServiceWithDependency`, [component])
			};
			requiredServices = { `MyFirstService` -> [] };
		};
		
		value module2 = CeylonModule {
			name = "canInstantiateServiceWithADependencyFromAnotherModule_2";
			providedServices = {
				ProvidedService(`MyFirstService` -> `MyFirstService`)
			};
		};
		
		initializeModules { module1, module2 };
		
		assertEquals(myFirstServiceInstances, currentMyFirstServiceInstances + 1);
		assertEquals(serviceWithDepsInstances, currentServiceWithDepsInstances + 1);
	}
	
	test
	shared void canInstantiateServiceWithADependencyOnInterfaceFromAnotherModule() {
		value currentMyInterfaceImplInstances = myInterfaceImplInstances;
		value currentUserOfMyInterfaceInstances = userOfMyInterfaceInstances;
		
		value module1 = CeylonModule {
			name = "canInstantiateServiceWithADependencyOnInterfaceFromAnotherModule_1";
			providedServices = {
				ProvidedService(`UserOfMyInterface` -> `UserOfMyInterface`, [component])
			};
			requiredServices = { `MyInterface` -> [] };
		};
		
		value module2 = CeylonModule {
			name = "canInstantiateServiceWithADependencyOnInterfaceFromAnotherModule_2";
			providedServices = {
				ProvidedService(`MyInterface` -> `MyInterfaceImpl`)
			};
		};
		
		initializeModules { module1, module2 };
		
		assertEquals(myInterfaceImplInstances, currentMyInterfaceImplInstances + 1);
		assertEquals(userOfMyInterfaceInstances, currentUserOfMyInterfaceInstances + 1);
	}
	
}
