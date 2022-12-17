import Foundation
import Combine

import Auth
import WalletConnectSign

/// Web3 Wallet Client
///
/// Cannot be instantiated outside of the SDK
///
/// Access via `Web3Wallet.instance`
public class Web3WalletClient {
    // MARK: - Public Properties

    /// Publisher that sends session proposal
    ///
    /// event is emited on responder client only
    public var sessionProposalPublisher: AnyPublisher<Session.Proposal, Never> {
        signClient.sessionProposalPublisher.eraseToAnyPublisher()
    }

    /// Publisher that sends session request
    ///
    /// In most cases event will be emited on wallet
    public var sessionRequestPublisher: AnyPublisher<Request, Never> {
        signClient.sessionRequestPublisher.eraseToAnyPublisher()
    }
    
    /// Publisher that sends authentication requests
    ///
    /// Wallet should subscribe on events in order to receive auth requests.
    public var authRequestPublisher: AnyPublisher<AuthRequest, Never> {
        authClient.authRequestPublisher.eraseToAnyPublisher()
    }

    // MARK: - Private Properties
    public let authClient: AuthClient
    public let signClient: SignClient
    
    private var account: Account?

    init(
        authClient: AuthClient,
        signClient: SignClient
    ) {
        self.authClient = authClient
        self.signClient = signClient
    }
    
    /// For a wallet to approve a session proposal.
    /// - Parameters:
    ///   - proposalId: Session Proposal id
    ///   - namespaces: namespaces for given session, needs to contain at least required namespaces proposed by dApp.
    public func approve(proposalId: String, namespaces: [String: SessionNamespace]) async throws {
        try await signClient.approve(proposalId: proposalId, namespaces: namespaces)
    }

    /// For the wallet to reject a session proposal.
    /// - Parameters:
    ///   - proposalId: Session Proposal id
    ///   - reason: Reason why the session proposal has been rejected. Conforms to CAIP25.
    public func reject(proposalId: String, reason: RejectionReason) async throws {
        try await signClient.reject(proposalId: proposalId, reason: reason)
    }

    /// For the wallet to update session namespaces
    /// - Parameters:
    ///   - topic: Topic of the session that is intended to be updated.
    ///   - namespaces: Dictionary of namespaces that will replace existing ones.
    public func update(topic: String, namespaces: [String: SessionNamespace]) async throws {
        try await signClient.update(topic: topic, namespaces: namespaces)
    }

    /// For wallet to extend a session to 7 days
    /// - Parameters:
    ///   - topic: Topic of the session that is intended to be extended.
    public func extend(topic: String) async throws {
        try await signClient.extend(topic: topic)
    }
    
    /// For the wallet to respond on pending dApp's JSON-RPC request
    /// - Parameters:
    ///   - topic: Topic of the session for which the request was received.
    ///   - requestId: RPC request ID
    ///   - response: Your JSON RPC response or an error.
    public func respond(topic: String, requestId: RPCID, response: RPCResult) async throws {
        try await signClient.respond(topic: topic, requestId: requestId, response: response)
    }
    
    /// For the wallet to emit an event to a dApp
    ///
    /// When a client wants to emit an event to its peer client (eg. chain changed or tx replaced)
    ///
    /// Should Error:
    /// - When the session topic is not found
    /// - When the event params are invalid
    /// - Parameters:
    ///   - topic: Session topic
    ///   - event: session event
    ///   - chainId: CAIP-2 chain
    public func emit(topic: String, event: Session.Event, chainId: Blockchain) async throws {
        try await signClient.emit(topic: topic, event: event, chainId: chainId)
    }
    
    /// For a wallet and a dApp to terminate a session
    ///
    /// Should Error:
    /// - When the session topic is not found
    /// - Parameters:
    ///   - topic: Session topic that you want to delete
    public func disconnect(topic: String) async throws {
        try await signClient.disconnect(topic: topic)
    }

    
    /// Query sessions
    /// - Returns: All sessions
    public func getSessions() -> [Session] {
        signClient.getSessions()
    }
    
    public func formatMessage(payload: AuthPayload, address: String) throws -> String {
        try authClient.formatMessage(payload: payload, address: address)
    }
    
    /// For a wallet to respond on authentication request
    /// - Parameters:
    ///   - requestId: authentication request id
    ///   - signature: CACAO signature of requested message
    public func respond(requestId: RPCID, signature: CacaoSignature, from account: Account) async throws {
        try await authClient.respond(requestId: requestId, signature: signature, from: account)
    }
    
    /// Query pending requests
    /// - Returns: Pending requests received from peer with `wc_sessionRequest` protocol method
    /// - Parameter topic: topic representing session for which you want to get pending requests. If nil, you will receive pending requests for all active sessions.
    public func getPendingRequests(topic: String? = nil) -> [Request] {
        signClient.getPendingRequests(topic: topic)
    }
    
    /// - Parameter id: id of a wc_sessionRequest jsonrpc request
    /// - Returns: json rpc record object for given id or nil if record for give id does not exits
    public func getSessionRequestRecord(id: RPCID) -> Request? {
        signClient.getSessionRequestRecord(id: id)
    }
    
    /// Query pending authentication requests
    /// - Returns: Pending authentication requests
    public func getPendingRequests(account: Account) throws -> [AuthRequest] {
        try authClient.getPendingRequests(account: account)
    }
}
