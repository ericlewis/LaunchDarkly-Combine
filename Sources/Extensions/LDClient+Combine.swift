//
//  LDClient+Combine.swift
//
//  Created by Eric Lewis on 10/7/20.
//

import Combine
import LaunchDarkly

// MARK: LDClient Publishers

extension LDClient {
    public func variationPublisher<T: LDFlagValueConvertible>(forKey: LDFlagKey) -> LDClient.VariationPublisher<T> {
        VariationPublisher(forKey, client: self)
    }
    
    public func currentConnectionModePublisher() -> LDClient.ConnectionModePublisher {
        ConnectionModePublisher(client: self)
    }
}

// MARK: variationPublisher

extension LDClient {
    public struct VariationPublisher<T: LDFlagValueConvertible>: Combine.Publisher {
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
    
    fileprivate final class VariationSubscription<SubscriberType: Subscriber>: Combine.Subscription where SubscriberType.Input: LDFlagValueConvertible, SubscriberType.Failure == Never {
        private let subscriber: SubscriberType
        private let client: LDClient
        private let key: LDFlagKey
        
        init(subscriber: SubscriberType, key: LDFlagKey, client: LDClient) {
            self.subscriber = subscriber
            self.key = key
            self.client = client
            
            client.observe(key: key, owner: self as LDObserverOwner) { [weak self] in
                _ = self?.subscriber.receive($0.newValue as! SubscriberType.Input)
            }
        }
        
        func request(_ demand: Subscribers.Demand) {
            if demand > 0 {
                _ = subscriber.receive(client.variation(forKey: key)!)
            }
        }
        
        func cancel() {
            client.stopObserving(owner: self as LDObserverOwner)
        }
    }
}

// MARK: currentConnectionModePublisher

extension LDClient {
    public struct ConnectionModePublisher: Combine.Publisher {
        public typealias Output = ConnectionInformation.ConnectionMode
        public typealias Failure = Never
        
        private let client: LDClient
        
        init(client: LDClient) {
            self.client = client
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = LDClient.ConnectionModeSubscription(subscriber: subscriber, client: client)
            subscriber.receive(subscription: subscription)
        }
    }
    
    fileprivate final class ConnectionModeSubscription<SubscriberType: Subscriber>: Combine.Subscription where SubscriberType.Input == ConnectionInformation.ConnectionMode, SubscriberType.Failure == Never {
        private let subscriber: SubscriberType
        private let client: LDClient
        
        init(subscriber: SubscriberType, client: LDClient) {
            self.subscriber = subscriber
            self.client = client
            
            client.observeCurrentConnectionMode(owner: self as LDObserverOwner) { [weak self] in
                _ = self?.subscriber.receive($0)
            }
        }
        
        func request(_ demand: Subscribers.Demand) {
            // NOOP
        }
        
        func cancel() {
            client.stopObserving(owner: self as LDObserverOwner)
        }
    }
}
