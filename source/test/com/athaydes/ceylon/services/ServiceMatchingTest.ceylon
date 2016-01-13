import ceylon.test {
	test,
	assertEquals
}

import com.athaydes.ceylon.services {
	ProvidedService,
	NamedServiceAttribute,
	NamedServiceRequirement,
	matchServices,
	AnyType
}

shared class ServiceMatchingTest() {
	
	interface Inter {}
	class InterImpl() satisfies Inter {}
	interface Inter2 {}
	class Inter2Impl() satisfies Inter2 {}
	interface Inter3 {}
	class Inter3Impl() satisfies Inter2&Inter3 {}
	interface NoImpls {}
	
	function providedTypes(<AnyType -> {ProvidedService<Anything,Anything>*}>[] matches)
			=> [ for (k -> v in matches) k -> v*.serviceType*.item ];
	
	test
	shared void canFindSimpleService() {
		value matches = matchServices(
			{ProvidedService(`Inter`->`InterImpl`)},
			{`Inter`->[]});
		
		assertEquals(providedTypes(matches), [`Inter`->[`InterImpl`]]);
	}
	
	test
	shared void canFindServiceWithNamedAttribute() {
		value matches = matchServices(
			{ProvidedService(`Inter`->`InterImpl`, {NamedServiceAttribute("inter")})},
			{`Inter`->[NamedServiceRequirement("inter")]});
		
		assertEquals(providedTypes(matches), [`Inter`->[`InterImpl`]]);
	}

	test
	shared void canFindServiceWithIntersectionType() {
		value matches = matchServices(
			{ProvidedService(`Inter2`->`Inter2Impl`),
			 ProvidedService(`Inter2&Inter3`->`Inter3Impl`)},
			{`Inter2&Inter3`->[], `Inter2`->[], `Inter3`->[]});
		
		assertEquals(set(providedTypes(matches)), set([
			`Inter2`->[`Inter2Impl`, `Inter3Impl`],
			`Inter2&Inter3`->[`Inter3Impl`],
			`Inter3`->[`Inter3Impl`]]));
	}

	test
	shared void canFindServiceWithUnionType() {
		value matches = matchServices(
			{ProvidedService(`Inter`->`InterImpl`),
			 ProvidedService(`Inter2`->`Inter2Impl`),
			 ProvidedService(`Inter3`->`Inter3Impl`)},
			{`Inter|Inter2`->[]});
		
		assertEquals(set(providedTypes(matches)), set([
			`Inter|Inter2`->[`InterImpl`, `Inter2Impl`]]));
	}

	test
	shared void cannotFindServiceWithNonMatchingNamedAttribute() {
		value matches = matchServices(
			{ProvidedService(`Inter`->`InterImpl`, {NamedServiceAttribute("inter1")})},
			{`Inter`->[NamedServiceRequirement("inter2")]});
		
		assertEquals(providedTypes(matches), [`Inter`->[]]);
	}

	test
	shared void cannotFindServiceWithNonMatchingType() {
		value matches = matchServices(
			{ProvidedService(`Inter`->`InterImpl`)},
			{`NoImpls`->[]});
		
		assertEquals(providedTypes(matches), [`NoImpls`->[]]);
	}
	
	test
	shared void canFindSimpleServicesAmongstMany() {
		value matches = matchServices(
			{ProvidedService(`Inter`->`InterImpl`),
				ProvidedService(`Inter2`->`Inter2Impl`),
				ProvidedService(`Inter2`->`Inter3Impl`),
				ProvidedService(`Inter3`->`Inter3Impl`),
				ProvidedService(`String`->`String`)},
			{ `Inter`->[], `Inter2`->[], `Inter3`->[] });
		
		assertEquals(set(providedTypes(matches)), set {
			`Inter`->[`InterImpl`],
			`Inter2`->[`Inter2Impl`, `Inter3Impl`],
			`Inter3`->[`Inter3Impl`] });
	}

	test
	shared void requirementWithNoAttributesCanBeMetByServiceWithAttributes() {
		value matches = matchServices(
			{ProvidedService(`Inter`->`InterImpl`, {NamedServiceAttribute("inter")})},
			{`Inter`->[]});
		
		assertEquals(providedTypes(matches), [`Inter`->[`InterImpl`]]);
	}

	test
	shared void requirementWithAttributesCannotBeMetByServiceWithoutAttributes() {
		value matches = matchServices(
			{ProvidedService(`Inter`->`InterImpl`)},
			{`Inter`->[NamedServiceRequirement("inter2")]});
		
		assertEquals(providedTypes(matches), [`Inter`->[]]);
	}
	
}