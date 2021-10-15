class SocketEvent {
  static const String CONNECT = 'connect';
  static const String CONNECT_ERROR = "connect_error";
  static const String CONNECT_TIMEOUT = "connect_timeout";
  static const String CONNECTING = "connecting";
  static const String DISCONNECT = "disconnect";
  static const String ERROR = "error";
  static const String RECONNECT = "reconnect";
  static const String RECONNECT_ATTEMPT = "reconnect_attempt";
  static const String RECONNECT_FAILED = "reconnect_failed";
  static const String RECONNECT_ERROR = "reconnect_error";
  static const String RECONNECTING = "reconnecting";
  static const String PING = "ping";
  static const String PONG = "pong";

  static const String LOAD_CONVERSATIONS = "loadConversations";
  static const String SEND_MESSAGE = "newMessageToServer";
  static const String MESSAGE = "incomingcall";
  static const String MESSAGE_TO_CLIENTS = "messageToClients";
  static const String BROADCASTED_MESSAGSE_TOCLIENTS =
      "broadcastMessageToClients";

  static const String CLEAR_UNREAD_HISTORY = "clearUnreadHistory";
  static const String UPDATE_MESSAGE_HISTORY = "updateMessageStatus";
  static const String ROOM_HISTORY = "historyCatchUp";
  static const String JOIN_ROOM = "joinRoom";
  static const String LEAVE_ROOM = "leaveRoom";
  // static const String JITSI_SERVER_URL = 'https://jitsi.tagcash.com/';
  static const String JITSI_SERVER_URL = 'https://meet.jit.si/';
}
