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
    public func variationPublisher(forKey: LDFlagKey) -> LDClient.VariationPublisher {
        VariationPublisher(forKey, client: self)
    }
}

extension LDClient {
    public struct VariationPublisher: Combine.Publisher {
        public typealias Output = LDValue
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
                _ = self.subscriber.receive($0.newValue as! SubscriberType.Input)
            }
        }
        
        func request(_ demand: Subscribers.Demand) {
            if demand > 0 {
                let value: LDValue = client.jsonVariation(forKey: key, defaultValue: LDValue.null)
                _ = subscriber.receive(value as! SubscriberType.Input)
            }
        }
        
        func cancel() {
            client.stopObserving(owner: self as LDObserverOwner)
        }
        
    }
}
