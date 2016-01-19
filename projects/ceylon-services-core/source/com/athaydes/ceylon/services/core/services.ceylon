import ceylon.language.meta.model {
	ClassModel,
	Type
}

shared interface ServiceRequirement {}

shared interface ServiceAttribute {
	shared default Boolean meets(ServiceRequirement requirement) => false;
}

shared class NamedServiceAttribute(
	shared String name)
		satisfies ServiceAttribute {
	shared actual Boolean meets(ServiceRequirement requirement)
			=> switch (requirement)
				case (is NamedServiceRequirement) this.name == requirement.name
				else false;
	
	string = "NamedServiceAttribute=``name``";
}

shared object singleton satisfies ServiceAttribute {}

shared object component satisfies ServiceAttribute {}

shared class NamedServiceRequirement(
	shared String name)
		satisfies ServiceRequirement {
	string = "NamedServiceRequirement='``name``'";
}

shared class ProvidedService<out Service, out ServiceImpl>(
	shared Type<Service> -> ClassModel<ServiceImpl, Nothing> serviceType,
	shared {ServiceAttribute*} attributes = {})
		given ServiceImpl satisfies Service {
	string = "``serviceType``(``attributes``)";
}

shared <AnyType -> {ProvidedService<Anything, Anything>*}>[] matchServices(
	{ProvidedService<Anything, Anything>*} providedServices,
	{<AnyType -> [ServiceRequirement*]>*} requiredServices)
	=> [for (required -> requirements in requiredServices)
			let (candidateServices = providedServices.filter((service)
					=> service.serviceType.key.subtypeOf(required)),
				 matchedServices = candidateServices.filter((service)
				 	=> requirements.every((req)
						=> service.attributes.any((attr) => attr.meets(req)))))
			required -> matchedServices
	];
