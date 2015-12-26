import ceylon.language.meta.model {
	ClassModel,
	Type
}

shared interface ServiceRequirement {
	shared formal String name;
}

shared interface ServiceAttribute {
	shared formal String name;
	shared default Boolean meets(ServiceRequirement requirement)
			=> this.name == requirement.name;
}

shared class NamedServiceAttribute(
	shared actual String name)
		satisfies ServiceAttribute {}

shared class NamedServiceRequirement(
	shared actual String name)
		satisfies ServiceRequirement {}

shared class ProvidedService<out Service, out ServiceImpl>(
	shared Type<Service> -> ClassModel<ServiceImpl, Nothing> serviceType,
	shared {ServiceAttribute*} attributes = {})
		given ServiceImpl satisfies Service {}

shared class CeylonModule(
	shared {<Type<Anything> -> [ServiceRequirement*]>*} requiredServices = {},
	shared {ProvidedService<Anything, Anything>*} providedServices = {}) {}

shared {ProvidedService<Anything, Anything>*} providedBy({CeylonModule*} ceylonModules)
		=> { for (mod in ceylonModules) mod.providedServices }.flatMap(identity);

shared {<Type<Anything> -> [ServiceRequirement*]>*} requiredBy({CeylonModule*} ceylonModules)
		=> { for (mod in ceylonModules) mod.requiredServices }.flatMap(identity);

shared <Type<Anything>->ClassModel<Anything,Nothing>>[] matchServices(
	{ProvidedService<Anything, Anything>*} providedServices,
	{<Type<Anything> -> [ServiceRequirement*]>*} requiredServices)
	=> [for (required->requirements in requiredServices)
		for (providedService in providedServices)
			if (providedService.serviceType.key.subtypeOf(required),
				requirements.every((req)
					=> providedService.attributes.any((attr) => attr.meets(req))))
				required -> providedService.serviceType.item
	];
