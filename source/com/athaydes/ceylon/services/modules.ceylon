import ceylon.collection {
	HashMap,
	MutableList,
	ArrayList
}
import ceylon.language.meta.model {
	Type,
	FunctionModel,
	ClassModel
}

shared alias AnyType => Type<Anything>;
shared alias ConcreteType => ClassModel<Anything, Nothing>;
shared alias Constructor => FunctionModel<Anything, Nothing>;

"Extension of ceylon modules that allow modules to declare required and provided services"
shared class CeylonModule(
	shared String name,
	shared {<Type<Anything> -> [ServiceRequirement*]>*} requiredServices = {},
	shared {ProvidedService<Anything, Anything>*} providedServices = {},
	shared {CeylonModule*} imports = {}) {
	string = "CeylonModule(``name``)";
}

object serviceFactory {
	
	value servicesByModule = HashMap<CeylonModule, MutableList<AnyType -> ServiceReference>>();
	
	shared ServiceReference createServiceRef(CeylonModule ceylonModule)(
		AnyType apiType,
		ProvidedService<Anything,Anything> serviceImpl,
		{<Constructor -> {{ServiceReference+}*}?>*}() getConstructors) {
		value ref = ServiceReference(serviceImpl, getConstructors);
		
		function newModuleEntry() {
			value entries = ArrayList<AnyType -> ServiceReference>(3);
			servicesByModule.put(ceylonModule, entries);
			return entries;
		}
		
		value refs = servicesByModule[ceylonModule] else newModuleEntry();
		refs.add(apiType -> ref);
		
		return ref;
	}
	
	shared {ServiceReference?*} getReferences(CeylonModule ceylonModule)(AnyType apiType) {
		value entries = servicesByModule[ceylonModule] else {};
		return {
			for (type -> ref in entries)
			if (apiType.subtypeOf(type)) then ref else null
		};
	}

}


shared void a1() {
		
}


shared class ServiceReference(
	ProvidedService<Anything,Anything> serviceImpl,
	{<Constructor -> {{ServiceReference+}*}?>*}() getConstructors) {
	
	Object? getNewService() {
		print("====== Attempting to get new service ``serviceImpl.serviceType.item`` ========");
		value constructors = getConstructors();
		
		value constructorEntries = {
			for (constructor -> refs in constructors)
			if (is Object refs) constructor -> refs
		};
		
		"There should be at least one callable constructor but none were found"
		assert(!constructorEntries.empty);

		for (constructor -> paramMatchesAlternatives in constructorEntries) {
			variable [Object*]? resolvedParameterServices = [];
			
			if (paramMatchesAlternatives.empty) {
				"Expected constructor to have no parameters"
				assert(constructor.parameterTypes.empty);
			} else {
				for (matches in paramMatchesAlternatives) {
					value goodMatches = [
						for (match in matches)
						if (exists service = match.getService()) service
					];
					if (constructor.parameterTypes.size == goodMatches.size) {
						resolvedParameterServices = goodMatches;
						break; // any alternative that works can be used
					}
				}
			}

			if (exists parameters = resolvedParameterServices) {
				value service = constructor.declaration.invoke([], *parameters);
				
				"A Service must be an instance of Object"
				assert(exists service);
				
				print("Created service instance: ``service``");
				return service;
			} else {
				print("Skipping unresolved constructor with parameter types: ``constructor.parameterTypes``");
			}
		}
		
		throw Exception("Cannot instantiate service ``serviceImpl.serviceType.item`` as no constructor could be resolved.
		                 Attempted constructors: ``constructors``");
	}

	object singletonRef {
		
		Object initializeService() {
			value instance = getNewService();
			if (exists instance) {
				return instance;
			} else {
				throw Exception("Could not create singleton instance of ``serviceImpl.serviceType.item``");
			}
		}
		
		shared variable Object?() getService = () {
			value service = initializeService();
			getService = () => service;
			return service;
		};
	}
	
	string = "ServiceReference(``serviceImpl``)";
	
	shared {ServiceAttribute*} serviceAttributes = serviceImpl.attributes;
	
	shared Boolean singletonService
			= serviceAttributes.any((attr) => attr == singleton); 
	
	shared Boolean componentService
			= serviceAttributes.any((attr) => attr == component); 
	
	shared Object?() getService = 
			if (singletonService)
			then singletonRef.getService
			else getNewService;
	
}

shared {ProvidedService<Anything, Anything>*} providedBy({CeylonModule*} ceylonModules)
		=> { for (mod in ceylonModules) mod.providedServices }.flatMap(identity);

shared {<AnyType -> [ServiceRequirement*]>*} requiredBy({CeylonModule*} ceylonModules)
		=> { for (mod in ceylonModules) mod.requiredServices }.flatMap(identity);

void verifyRequirementsMet(<AnyType->{ProvidedService<Anything,Anything>*}>[] matches) {
	value unmetRequirements = [ for (match in matches) if (match.item.empty) match.key ];
	if (!unmetRequirements.empty) {
		throw Exception("Required Services have not been provided:
		                 ``unmetRequirements.collect((it) => "    * ``it``")``");
	}
}

[ServiceReference*] createServiceRefs(
	CeylonModule ceylonModule,
	<AnyType -> {ProvidedService<Anything,Anything>*}>[] matches) {

	function resolveConstructors(ConcreteType implType)() {
		
		function serviceRefsForParametersOf(
			Constructor constructor) {
			
			value paramMatches = constructor.parameterTypes
					.map(serviceFactory.getReferences(ceylonModule));
			
			if (paramMatches.any((refs) => refs.every((ref) => ref is Null))) {
				return constructor -> null;
			} else {
				value goodRefs = {
					for (refs in paramMatches)
					refs.coalesced
				};
				return constructor -> goodRefs.map((refs) {
					assert(exists r = refs.first);
					return {r, *refs.rest};
				});
			}
		}
		
		value allConstructors = { implType.defaultConstructor }
			.coalesced
			.chain(implType.getCallableConstructors())
			.distinct;
		
		return allConstructors
			// longest constructors are preferred
			.sort(byDecreasing(compose(Iterable<>.size, Constructor.parameterTypes)))
			.collect(serviceRefsForParametersOf);		
	}

	value components = ceylonModule.providedServices
			.filter((provided) => provided.attributes.any((attr)
				=> attr == component))
			.map((provided) => provided.serviceType.key -> {provided});

	return [
		for (apiType -> implTypes in matches.chain(components).distinct)
		for (impl in implTypes)
		serviceFactory.createServiceRef(ceylonModule)
			(apiType, impl, resolveConstructors(impl.serviceType.item))
	];
}

shared [ServiceReference*] createServiceRefsForModule(
	CeylonModule ceylonModule,
	{ProvidedService<Anything, Anything>*} providedServices) {
	print("Initializing module: ``ceylonModule``");
	value requiredServices = ceylonModule.requiredServices;
	
	value matches = matchServices(providedServices, requiredServices);
	
	verifyRequirementsMet(matches);
	
	print("ALL service matches: ``matches``");
	
	return createServiceRefs(ceylonModule, matches);
}

shared void initializeModules(
	{CeylonModule*} ceylonModules) {
	value providedServices = providedBy(ceylonModules);
	value serviceRefs = ceylonModules
			.collect((m) => createServiceRefsForModule(m, providedServices))
			.flatMap(identity);
	
	for (serviceRef in serviceRefs.filter(ServiceReference.componentService)) {
		print("Creating component: ``serviceRef``");
		serviceRef.getService();
	}
}
