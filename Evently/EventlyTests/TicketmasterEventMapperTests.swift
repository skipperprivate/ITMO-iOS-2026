import Foundation
import Testing
@testable import Evently

@Suite("Ticketmaster event details")
struct TicketmasterEventDetailsMapperTests {
    @Test("Event details retain original source, address and ticket link")
    func mapsDetails() throws {
        let payload = """
        {
          "id": "test-event-id", "name": "Example Event",
          "dates": {"start": {"localDate": "2026-12-10"}},
          "description": "Example description",
          "url": "https://www.ticketmaster.com/event/test-event-id",
          "_embedded": {"venues": [{
            "name": "Example Hall", "city": {"name": "Boston"},
            "address": {"line1": "12 Main Street"},
            "state": {"name": "Massachusetts"}, "postalCode": "02108"
          }]}
        }
        """
        let dto = try JSONDecoder().decode(
            TicketmasterEventDTO.self,
            from: Data(payload.utf8)
        )
        let event = try #require(TicketmasterEventMapper.map(dto))
        #expect(event.sourceID == "test-event-id")
        #expect(event.description == "Example description")
        #expect(event.address?.contains("12 Main Street") == true)
        #expect(event.ticketURL?.host == "www.ticketmaster.com")
    }

    @Test("Missing optional details remain absent")
    func missingDetails() throws {
        let payload = """
        {"id":"event-2","name":"Example","dates":{"start":{"localDate":"2026-12-11"}}}
        """
        let dto = try JSONDecoder().decode(
            TicketmasterEventDTO.self, from: Data(payload.utf8)
        )
        let event = try #require(TicketmasterEventMapper.map(dto))
        #expect(event.description == nil)
        #expect(event.address == nil)
        #expect(event.ticketURL == nil)
    }
}
