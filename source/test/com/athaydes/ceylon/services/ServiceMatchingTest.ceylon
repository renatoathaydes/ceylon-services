import ceylon.test {
	test,
	assertEquals
}

import com.athaydes.ceylon.services {
	ProvidedService,
	NamedServiceAttribute,
	NamedServiceRequirement,
	matchServices
}

shared class ServiceMatchingTest() {
	
	interface Inter {}
	class InterImpl() satisfies Inter {}
	interface Inter2 {}
	class Inter2Impl() satisfies Inter2 {}
	interface Inter3 {}
	class Inter3Impl() satisfies Inter2&Inter3 {}
	interface NoImpls {}
	
	test
	shared void canFindSimpleService() {
		value matches = matchServices(
			{ProvidedService(`Inter`->`InterImpl`, {})},
			{`Inter`->[]});
		
		assertEquals(matches, [`Inter`->`InterImpl`]);
	}
	
	test
	shared void canFindServiceWithNamedAttribute() {
		value matches = matchServices(
			{ProvidedService(`Inter`->`InterImpl`, {NamedServiceAttribute("inter")})},
			{`Inter`->[NamedServiceRequirement("inter")]});
		
		assertEquals(matches, [`Inter`->`InterImpl`]);
	}

	test
	shared void canFindServiceWithIntersectionType() {
		value matches = matchServices(
			{ProvidedService(`Inter2`->`Inter2Impl`, {}),
			 ProvidedService(`Inter2&Inter3`->`Inter3Impl`, {})},
			{`Inter2&Inter3`->[], `Inter2`->[], `Inter3`->[]});
		
		assertEquals(set(matches), set([
			`Inter2`->`Inter2Impl`,
			`Inter2&Inter3`->`Inter3Impl`,
			`Inter2`->`Inter3Impl`,
			`Inter3`->`Inter3Impl`]));
	}

	test
	shared void canFindServiceWithUnionType() {
		value matches = matchServices(
			{ProvidedService(`Inter`->`InterImpl`, {}),
			 ProvidedService(`Inter2`->`Inter2Impl`, {}),
			 ProvidedService(`Inter3`->`Inter3Impl`, {})},
			{`Inter|Inter2`->[]});
		
		assertEquals(set(matches), set([
			`Inter|Inter2`->`InterImpl`,
			`Inter|Inter2`->`Inter2Impl`]));
	}

	test
	shared void cannotFindServiceWithNonMatchingNamedAttribute() {
		value matches = matchServices(
			{ProvidedService(`Inter`->`InterImpl`, {NamedServiceAttribute("inter1")})},
			{`Inter`->[NamedServiceRequirement("inter2")]});
		
		assertEquals(matches, []);
	}

	test
	shared void cannotFindServiceWithNonMatchingType() {
		value matches = matchServices(
			{ProvidedService(`Inter`->`InterImpl`, {})},
			{`NoImpls`->[]});
		
		assertEquals(matches, []);
	}
	
	test
	shared void canFindSimpleServicesAmongstMany() {
		value matches = matchServices(
			{ProvidedService(`Inter`->`InterImpl`, {}),
				ProvidedService(`Inter2`->`Inter2Impl`, {}),
				ProvidedService(`Inter2`->`Inter3Impl`, {}),
				ProvidedService(`Inter3`->`Inter3Impl`, {}),
				ProvidedService(`String`->`String`, {})},
			{ `Inter`->[], `Inter2`->[], `Inter3`->[] });
		
		assertEquals(set(matches), set {
			`Inter`->`InterImpl`, `Inter2`->`Inter2Impl`,
			`Inter2`->`Inter3Impl`, `Inter3`->`Inter3Impl` });
		
	}

	test
	shared void requirementWithNoAttributesCanBeMetByServiceWithAttributes() {
		value matches = matchServices(
			{ProvidedService(`Inter`->`InterImpl`, {NamedServiceAttribute("inter")})},
			{`Inter`->[]});
		
		assertEquals(matches, [`Inter`->`InterImpl`]);
	}

	test
	shared void requirementWithAttributesCannotBeMetByServiceWithoutAttributes() {
		value matches = matchServices(
			{ProvidedService(`Inter`->`InterImpl`, {})},
			{`Inter`->[NamedServiceRequirement("inter2")]});
		
		assertEquals(matches, []);
	}
	
}