# Launchly

An easy to use [LaunchDarkly](https://launchdarkly.com) framework that adds support for Combine. Supports iOS 13+, macOS 10.15+, watchOS 6+, tvOS 13+.

# Example
```swift
import Combine
import LaunchDarkly_Combine
import LaunchDarkly

LDClient.start(config: LDConfig(mobileKey: "#YOUR_MOBILE_KEY#"))

var cancellable: AnyCancellable?
cancellable = LDClient.get()!.variationPublisher(forKey: key)
    .sink {
        print($0)
    }
```

# Project Structure

## Extensions
- Contains the code for extending `LDClient` with Combine.

# License
Copyright (c) 2020 Eric Lewis

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
OR OTHER DEALINGS IN THE SOFTWARE.

