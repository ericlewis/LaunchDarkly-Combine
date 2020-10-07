//
//  LDClient+allPublisher.swift
//  
//
//  Created by Eric Lewis on 10/7/20.
//

import Combine
import LaunchDarkly

extension LDClient {
    public func allPublisher() -> LDClient.AllPublisher {
        AllPublisher(client: self)
    }
}

extension LDClient {
    public struct AllPublisher: Combine.Publisher {
        public typealias Output = [LDFlagKey: LDChangedFlag]
        public typealias Failure = Never
        
        private let client: LDClient
        
        init(client: LDClient) {
            self.client = client
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = LDClient.AllSubscription(subscriber: subscriber, client: client)
            subscriber.receive(subscription: subscription)
        }
    }
    
    fileprivate final class AllSubscription<SubscriberType: Subscriber>: Combine.Subscription where SubscriberType.Input == [LDFlagKey: LDChangedFlag], SubscriberType.Failure == Never {
        private let client: LDClient
        
        init(subscriber: SubscriberType, client: LDClient) {
            self.client = client
            
            client.observeAll(owner: self as LDObserverOwner) {
                _ = subscriber.receive($0)
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
