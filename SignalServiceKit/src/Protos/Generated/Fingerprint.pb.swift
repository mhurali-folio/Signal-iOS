//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

/// iOS - since we use a modern proto-compiler, we must specify
/// the legacy proto format.

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
private struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

struct FingerprintProtos_LogicalFingerprint {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// @required
  var identityData: Data {
    get {return _identityData ?? Data()}
    set {_identityData = newValue}
  }
  /// Returns true if `identityData` has been explicitly set.
  var hasIdentityData: Bool {return self._identityData != nil}
  /// Clears the value of `identityData`. Subsequent reads from it will return its default value.
  mutating func clearIdentityData() {self._identityData = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _identityData: Data?
}

struct FingerprintProtos_LogicalFingerprints {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// @required
  var version: UInt32 {
    get {return _version ?? 0}
    set {_version = newValue}
  }
  /// Returns true if `version` has been explicitly set.
  var hasVersion: Bool {return self._version != nil}
  /// Clears the value of `version`. Subsequent reads from it will return its default value.
  mutating func clearVersion() {self._version = nil}

  /// @required
  var localFingerprint: FingerprintProtos_LogicalFingerprint {
    get {return _localFingerprint ?? FingerprintProtos_LogicalFingerprint()}
    set {_localFingerprint = newValue}
  }
  /// Returns true if `localFingerprint` has been explicitly set.
  var hasLocalFingerprint: Bool {return self._localFingerprint != nil}
  /// Clears the value of `localFingerprint`. Subsequent reads from it will return its default value.
  mutating func clearLocalFingerprint() {self._localFingerprint = nil}

  /// @required
  var remoteFingerprint: FingerprintProtos_LogicalFingerprint {
    get {return _remoteFingerprint ?? FingerprintProtos_LogicalFingerprint()}
    set {_remoteFingerprint = newValue}
  }
  /// Returns true if `remoteFingerprint` has been explicitly set.
  var hasRemoteFingerprint: Bool {return self._remoteFingerprint != nil}
  /// Clears the value of `remoteFingerprint`. Subsequent reads from it will return its default value.
  mutating func clearRemoteFingerprint() {self._remoteFingerprint = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _version: UInt32?
  fileprivate var _localFingerprint: FingerprintProtos_LogicalFingerprint?
  fileprivate var _remoteFingerprint: FingerprintProtos_LogicalFingerprint?
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

private let _protobuf_package = "FingerprintProtos"

extension FingerprintProtos_LogicalFingerprint: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".LogicalFingerprint"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "identityData")
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBytesField(value: &self._identityData) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._identityData {
      try visitor.visitSingularBytesField(value: v, fieldNumber: 1)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: FingerprintProtos_LogicalFingerprint, rhs: FingerprintProtos_LogicalFingerprint) -> Bool {
    if lhs._identityData != rhs._identityData {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension FingerprintProtos_LogicalFingerprints: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".LogicalFingerprints"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "version"),
    2: .same(proto: "localFingerprint"),
    3: .same(proto: "remoteFingerprint")
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularUInt32Field(value: &self._version) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._localFingerprint) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._remoteFingerprint) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._version {
      try visitor.visitSingularUInt32Field(value: v, fieldNumber: 1)
    } }()
    try { if let v = self._localFingerprint {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    try { if let v = self._remoteFingerprint {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: FingerprintProtos_LogicalFingerprints, rhs: FingerprintProtos_LogicalFingerprints) -> Bool {
    if lhs._version != rhs._version {return false}
    if lhs._localFingerprint != rhs._localFingerprint {return false}
    if lhs._remoteFingerprint != rhs._remoteFingerprint {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
