
# Jellyfish iOS Client

[Jellyfish](https://github.com/jellyfish-dev/jellyfish) Client library for iOS apps written in Swift.

## Components

The repository consists of 2 separapable components:

- `JellyfishClientSdk` - Jellyfish client fully compatible with `Jellyfish`, responsible for exchaning media events and receiving media streams which then are presented to the user
- `JellyfishCLientDemo` - Demo application utilizing `Jellyfish` client

### Example App

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

## Contributing

We welcome contributions to iOS Client SDK. Please report any bugs or issues you find or feel free to make a pull request with your own bug fixes and/or features.

## Jellyfish Ecosystem

|             |                                                                                                                                                                                                                                                              |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Client SDKs | [React](https://github.com/jellyfish-dev/react-client-sdk), [React Native](https://github.com/jellyfish-dev/react-native-client-sdk), [iOs](https://github.com/jellyfish-dev/ios-client-sdk), [Android](https://github.com/jellyfish-dev/android-client-sdk) |
| Server SDKs | [Elixir](https://github.com/jellyfish-dev/elixir_server_sdk), [Python](https://github.com/jellyfish-dev/python-server-sdk), [OpenAPI](https://jellyfish-dev.github.io/jellyfish-docs/api_reference/rest_api)                                                 |
| Services    | [Videoroom](https://github.com/jellyfish-dev/jellyfish_videoroom) - an example videoconferencing app written in elixir <br/> [Dashboard](https://github.com/jellyfish-dev/jellyfish-dashboard) - an internal tool used to showcase Jellyfish's capabilities   |
| Resources   | [Jellyfish Book](https://jellyfish-dev.github.io/book/) - theory of the framework, [Docs](https://jellyfish-dev.github.io/jellyfish-docs/), [Tutorials](https://github.com/jellyfish-dev/jellyfish-clients-tutorials)                                        |
| Membrane    | Jellyfish is based on [Membrane](https://membrane.stream/), [Discord](https://discord.gg/nwnfVSY)                                                                                                                                                            |
| Compositor  | [Compositor](https://github.com/membraneframework/membrane_video_compositor_plugin) - Membrane plugin to transform video                                                                                                                                     |
| Protobufs   | If you want to use Jellyfish on your own, you can use our [protobufs](https://github.com/jellyfish-dev/protos)

## Copyright and License

Copyright 2022, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=jellyfish)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=jellyfish)

Licensed under the [Apache License, Version 2.0](LICENSE)
