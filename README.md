## Project Overview

**Anime Case Opener** is an iOS app that gives anime fans a collectible, gamified experience: users open virtual cases to receive randomized anime characters, inspect character details (voice actors, MyAnimeList links), sort and manage their collection, and hear rarity-based sounds during the reveal. It’s aimed at casual collectors and anime fans who enjoy surprise-based rewards and lightweight progression systems. Core features include case opening with randomized drops, a persistent local collection, character detail views, rarity influenced by MAL favorites, and integration with the Jikan API for character metadata.

## Requirements

* MacOS 15.7+
* Xcode 26+
* iOS 26+ simulator

## Run Instructions

1. Download Xcode with iOS 26+
> <img src="https://docs-assets.developer.apple.com/published/5b619e20546c54b998cfde097d42227a/downloading-and-installing-components~dark%402x.png" width="600">
2. Open the project
> Option A — Clone an existing project: `git clone https://github.com/rymayerhofer/Anime-Case-Opener` <br/>
> Option B — Open a project or file: `Final Project Submission/src/Anime Case Opener.xcodeproj`
3. Select an iPhone.
> <img src="https://docs-assets.developer.apple.com/published/45d31630ac5781664b4dbf911fa7f55e/build-select-device~dark%402x.png" width="600">
4. Build & run
> `⌘R`

https://developer.apple.com/documentation/xcode/building-and-running-an-app

## OOP Features

| OOP Feature | File Name | Line Numbers | Reasoning / Purpose |
|---|---|---|---|
| Inheritance | DetailViewController, CaseViewController, DetailViewController | 11, 10, 17 | Subclassing UIViewController allows reuse of built-in controller lifecycle behavior and UI management. |
| Inheritance | CharacterCollectionViewCell | 11 | Subclassing UICollectionViewCell allows custom layout and display logic for character items. |
| Inheritance | AppDelegate, SceneDelegate | 12, 10 | Inheriting UIResponder enables the app to handle app-level and scene-level events (app lifecycle). |
| Inheritance | AnimeCharacter, MangaCharacter, FullCharacter | 10 | Each subclass extends a common Character model, enabling shared behavior and specialized properties. |
| Interface | Anime, Manga | All | Protocols define required properties so multiple character types can share behavior through abstraction. |
| Interface | AppDelegate, SceneDelegate | 12, 10 | Conforming to UIApplicationDelegate and UIWindowSceneDelegate enables system callbacks for app setup and lifecycle. |
| Interface | Character | 10 | Conforming to Codable allows encoding/decoding character data for networking and serialization. |
| Polymorphism | CharacterLoader | 46 | Loader returns base `Character` type, allowing multiple concrete character subclasses to be used interchangeably. |
| Polymorphism | UIImageView+Extensions | All | Extensions support loading various image formats polymorphically without changing calling code. |
| Access modifiers | Controllers/*, UIImageView+Extentions, CharacterWrapper, CaseAnimationService, CharacterLoader, CharacterStorage, JikanAPIService, JikanCharacterAdapter | Various | `private` hides implementation details and enforces encapsulation across services and views. |
| Access modifiers | Controllers/*, CaseAnimationService, CharacterFactory, CharacterLoader, CharacterAPIService, JikanCharacterAdapter | Class decleration | `final` prevents further subclassing, ensuring classes are not extended beyond their intended use. |
| Struct | DetailViewController | 11–15 | Using a predefined struct that can be built on a class level enables open-closed design. |
| Enum | Character, Anime, Manga | 28–30, 21–23, 18–20 | Enumerations specify coding keys, ensuring type-safe JSON decoding and preventing string duplication. |
| Enum | JikanAPIService | 14-19 | Defines a custom service error type for clearer and type-safe error handling when API requests fail. |
| Data structure | CharacterStorage | 18–19 | Arrays hold collections of characters enabling indexing, iteration, and flexible storage. |
| I/O | Controllers/* | All | Controllers perform UI updates and user interaction, serving as the point of input/output with the application. |
| I/O | Services/* | Various | Service classes output diagnostic information to the console, supporting runtime debugging and feedback. |

## Design Patterns
| Pattern Name | Category | File Name | Line Numbers | Rationale |
|---|---|---|---|---|
| Singleton | Creational | CharacterFactory, CharacterLoader, CharacterStorage, CharacterAPIService, JikanCharacterAdapter | 12 | Provides a single, shared instance so services and loaders can be accessed consistently throughout the app. This avoids creating multiple copies of objects that should be centralized, such as loaders and storage providers. It also simplifies dependency management across controllers. |
| Adapter | Structural | JikanCharacterAdapter | All | Converts external Jikan API response formats into the app’s Character model. It cleanly separates API data shape from internal domain models. |
| Factory | Creational | CharacterFactory | All | Responsible for creating Character subclass instances based on provided data. This centralizes creation logic in one place rather than scattering `init` logic across the codebase. It also makes the system easier to extend if new character types are added in the future. |

## Design Decisions

The app is organized into three main layers: UI controllers for interaction, domain models for character logic, and services for API access and persistence. Characters are defined using protocols so that Anime, Manga, and other types share a common interface. This makes it easier to add new features without changing existing UI code.

The use of protocols and subclassing provides flexibility but has tradeoffs. As more character types or data sources are introduced, the protocol system may require additional subclasses to fully support new behaviors, increasing maintenance cost. Likewise, the `CharacterAdapter` and `CharacterFactory` centralize object creation, but they cannot perfectly follow the open/closed principle—adding new character types may require modifying factory or adapter code instead of extending them safely. In a small project this is an acceptable cost for clarity and control, but it may become more complex as the number of character variations grows.

Singleton services (such as loaders and storage classes) simplify access across the app and reduce wiring, but can increase coupling and make isolated testing harder. The design favors straightforward integration and speed of development over complete adherence to advanced architectural patterns, which is reasonable for a solo project with limited scope and timeline.
