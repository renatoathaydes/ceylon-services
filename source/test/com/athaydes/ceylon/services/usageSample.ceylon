import com.athaydes.ceylon.services {
	ProvidedService,
	NamedServiceAttribute,
	NamedServiceRequirement,
	CeylonModule,
	initializeModules,
	singleton,
	component
}

interface HelloService {
	shared formal void sayHello(String name);
}

class EnglishHelloService() satisfies HelloService {
	sayHello(String name) => print("Hello ``name``!");
}

class PortugueseHelloService() satisfies HelloService {
	sayHello(String name) => print("Oi ``name``!");
}

class Main(HelloService service) {
	service.sayHello("World");
}

shared void runSample() {
	value module1 = CeylonModule {
		name = "Module 1";
		requiredServices = { `HelloService` -> [NamedServiceRequirement("EN")] };
		providedServices = { ProvidedService(`Main` -> `Main`, [component]) };
	};
	
	value module2 = CeylonModule {
		name = "Module 2";
		providedServices = {
			ProvidedService(`HelloService` -> `PortugueseHelloService` ,[NamedServiceAttribute("PT"), singleton]),
			ProvidedService(`HelloService` -> `EnglishHelloService` ,[NamedServiceAttribute("EN"), singleton])
		};
		imports = { module1 };
	};

	initializeModules { module1, module2 };
}