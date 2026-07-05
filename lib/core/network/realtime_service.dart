import 'package:socket_io_client/socket_io_client.dart' as socket_io;

import '../config/app_config.dart';

/// Thin wrapper around a single Socket.IO connection to the Aligo
/// backend. A listing's shipper and driver join a room scoped to that
/// listing's id and get pushed status/location updates instantly,
/// instead of both sides polling on a timer.
class RealtimeService {
  socket_io.Socket? _socket;

  void connect(String token) {
    _socket = socket_io.io(
      AppConfig.backendBaseUrl,
      socket_io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );
    _socket!.connect();
  }

  void joinListing(String listingId) {
    _socket?.emit('join-listing', listingId);
  }

  void leaveListing(String listingId) {
    _socket?.emit('leave-listing', listingId);
  }

  /// Fired with the full updated listing (as raw JSON) whenever its
  /// status changes — accepted, picked up, delivered, cancelled, etc.
  void onListingUpdated(void Function(Map<String, dynamic> json) handler) {
    _socket?.on(
      'listing:updated',
      (data) => handler(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Fired with `{lat, lng, updatedAt}` whenever the driver reports a
  /// new position for a listing this client has joined.
  void onListingLocation(void Function(Map<String, dynamic> json) handler) {
    _socket?.on(
      'listing:location',
      (data) => handler(Map<String, dynamic>.from(data as Map)),
    );
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
  }
}
