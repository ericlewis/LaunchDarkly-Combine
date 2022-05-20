//
//  LDCLient+variationPublisher.swift
//
//
//  Created by Eric Lewis on 10/7/20.
//

import Combine
import LaunchDarkly
import Foundation

extension LDClient {
    public func variationPublisher<T: Codable>(forKey: LDFlagKey) -> LDClient.VariationPublisher<T> {
        VariationPublisher(forKey, client: self)
    }
}

extension LDClient {
    public struct VariationPublisher<T: Codable>: Combine.Publisher {
        public typealias Output = T
        public typealias Failure = Never
        
        private let key: LDFlagKey
        private let client: LDClient
        
        init(_ key: LDFlagKey, client: LDClient) {
            self.key = key
            self.client = client
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = LDClient.VariationSubscription(subscriber: subscriber, key: key, client: client)
            subscriber.receive(subscription: subscription)
        }
    }
    
    fileprivate final class VariationSubscription<SubscriberType: Subscriber>: Combine.Subscription where SubscriberType.Input: Codable, SubscriberType.Failure == Never {
        private let subscriber: SubscriberType
        private let client: LDClient
        private let key: LDFlagKey
        private let encoder = JSONEncoder()
        private let decoder = JSONDecoder()
        
        init(subscriber: SubscriberType, key: LDFlagKey, client: LDClient) {
            self.subscriber = subscriber
            self.key = key
            self.client = client
            
            client.observe(key: key, owner: self as LDObserverOwner) { [weak self] in
                guard let self = self else { return }
                _ = self.subscriber.receive(self._cast($0.newValue))
            }
        }
        
        func request(_ demand: Subscribers.Demand) {
            if demand > 0 {
                let value: LDValue = client.jsonVariation(forKey: key, defaultValue: LDValue.null)
                _ = subscriber.receive(_cast(value))
            }
        }
        
        func cancel() {
            client.stopObserving(owner: self as LDObserverOwner)
        }
        
        private func _cast(_ value: LDValue) -> SubscriberType.Input {
            let data = try! encoder.encode(value)
            return try! decoder.decode(SubscriberType.Input.self, from: data)
        }
    }
}
