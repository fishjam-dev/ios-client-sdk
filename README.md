## Components

The repository consists of 3 separapable components:

- `JellyfishClientSdk` - Jellyfish client fully compatible with `Jellyfish`, responsible for exchaning media events and receiving media streams which then are presented to the user
- `JellyfishCLientDemo` - Demo application utilizing `Jellyfish` client

### JellyfishClientDemo

Really simple App allowing to test `Jellyfish client` functionalities. It consist of 2 screens:

- Joining screen where user passes peer token followed by join button click
- Room's screen consisting of set of control buttons and an area where participants' videos get displayed

## Documentation

API documentation is available [here](https://jellyfish-dev.github.io/ios-client-sdk/documentation/jellyfishclientsdk/).

## Installation

Add JellyfishClientSDK dependency to your project.

## Developing

1. Run `./scripts/init.sh` in the main directory to install swift-format and release-it and set up git hooks
2. Edit `Debug.xcconfig` to set backend url in development.
3. Run `release-it` to release. Follow the prompts, it should update version in podspec, make a commit and tag and push the new version.

This project has been built and is maintained thanks to the support from[Software Mansion](https://swmansion.com).

<img alt="Software Mansion" src="https://logo.swmansion.com/logo?color=white&variant=desktop&width=150&tag=react-native-reanimated-github"/>
