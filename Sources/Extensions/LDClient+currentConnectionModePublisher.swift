//
//  LDClient+currentConnectionModePublisher.swift
//  
//
//  Created by Eric Lewis on 10/7/20.
//

import Combine
import LaunchDarkly

extension LDClient {
    public func currentConnectionModePublisher() -> LDClient.ConnectionModePublisher {
        ConnectionModePublisher(client: self)
    }
}

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
