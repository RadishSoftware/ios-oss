#if DEBUG
  import Foundation
  import GraphAPI
  import Prelude

  extension MockService {
    /// What the OSS build (`Secrets.isOSS`) serves in place of the API: one live sample project with two
    /// rewards that ship to the United States for $10. With it the pledge flow runs from Discover to checkout
    /// with no secrets and no API. The project is made up: it is no real campaign.
    internal static func oss() -> MockService {
      let day: TimeInterval = 60 * 60 * 24
      let today = Foundation.Date().timeIntervalSince1970

      let ships = Reward.Shipping(
        enabled: true,
        location: nil,
        preference: .unrestricted,
        summary: "Ships worldwide",
        type: .anywhere
      )
      let toTheUnitedStates = ShippingRule(
        cost: 10,
        id: 1,
        location: .usa,
        estimatedMin: nil,
        estimatedMax: nil
      )

      let earlyBird = Reward.template
        |> Reward.lens.id .~ 1
        |> Reward.lens.title .~ "Gooseneck Kettle - Early Bird"
        |> Reward.lens.description .~ "A matte black pour-over kettle with a walnut handle."
        |> Reward.lens.minimum .~ 79
        |> Reward.lens.convertedMinimum .~ 79
        |> Reward.lens.pledgeAmount .~ 79
        |> Reward.lens.latePledgeAmount .~ 79
        |> Reward.lens.estimatedDeliveryOn .~ (today + 120 * day)
        |> Reward.lens.rewardsItems .~ []
        |> Reward.lens.isAvailable .~ true
        |> Reward.lens.shipping .~ ships
        |> Reward.lens.shippingRulesExpanded .~ [toTheUnitedStates]

      let kettle = earlyBird
        |> Reward.lens.id .~ 2
        |> Reward.lens.title .~ "Gooseneck Kettle"
        |> Reward.lens.minimum .~ 99
        |> Reward.lens.convertedMinimum .~ 99
        |> Reward.lens.pledgeAmount .~ 99
        |> Reward.lens.latePledgeAmount .~ 99
        |> Reward.lens.limit .~ nil
        |> Reward.lens.remaining .~ nil

      let project = Project.template
        |> Project.lens.name .~ "Gooseneck Kettle"
        |> Project.lens.blurb .~ "A matte black pour-over kettle with a walnut handle."
        |> Project.lens.dates.launchedAt .~ (today - 15 * day)
        |> Project.lens.dates.deadline .~ (today + 15 * day)

      let shippableLocations = GraphAPI.ShippableLocationsForProjectQuery.Data(
        project: .init(shippableCountriesExpanded: [
          .init(
            country: Location.usa.country,
            countryName: Location.usa.name,
            displayableName: Location.usa.displayableName,
            id: Location.usa.graphID,
            name: Location.usa.name
          )
        ])
      )

      return MockService(
        fetchGraphQLResponses: [(GraphAPI.ShippableLocationsForProjectQuery.self, shippableLocations)],
        fetchDiscoveryResponse: .template |> DiscoveryEnvelope.lens.projects .~ [project],
        fetchProjectPamphletResult: .success(Project.ProjectPamphletData(project: project, backingId: nil)),
        fetchProjectRewardsResult: .success([earlyBird, kettle])
      )
    }
  }
#endif
