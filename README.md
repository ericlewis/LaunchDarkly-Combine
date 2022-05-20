# LaunchDarkly+Combine

[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-informational)](#swift-package-manager)

An easy to use [LaunchDarkly](https://launchdarkly.com) framework that adds support for Combine.

## Requirements

| Platform | Version |
| -------- | ------- |
| iOS      | 13.0    |
| watchOS  | 6.0     |
| tvOS     | 13.0    |
| macOS    | 10.15   |

## Installation

Current support is only for SPM, feel free to open a PR to add other package managers.

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a dependency manager integrated into the `swift` compiler and Xcode.

To integrate LaunchDarkly+Combine into an Xcode project, go to the project editor, and select `Swift Packages`. From here hit the `+` button and follow the prompts using  `https://github.com/ericlewis/LaunchDarkly-Combine.git` as the URL.

To include LaunchDarkly+Combine in a Swift package, simply add it to the dependencies section of your `Package.swift` file. And add the product "LaunchDarkly+Combine" as a dependency for your targets.

```swift
dependencies: [
    .package(url: "https://github.com/ericlewis/LaunchDarkly-Combine.git", .upToNextMinor(from: "2.0.0"))
]
```

## Example
```swift
import Combine
import LaunchDarkly_Combine
import LaunchDarkly

func observeFlag<T: Decodable>(key: LDFlagKey) -> AnyPublisher<T, Error> {
    LDClient.get()!
        .variationPublisher(forKey: key)
        .decode()
        .eraseToAnyPublisher()
}

func observeMyBoolFlag() -> AnyPublisher<Bool, Never> {
   return observeFlag(key: "#FLAG_KEY")
            .replaceError(with: false) // Default value
}

LDClient.start(config: LDConfig(mobileKey: "#YOUR_MOBILE_KEY#"))

var cancellable: AnyCancellable?
cancellable = observeMyBoolFlag()
    .sink {
        print($0)
    }
```

## Project Structure

### Extensions
- Contains the code for extending `LDClient` with Combine.

## License
Copyright (c) 2020 Eric Lewis

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
