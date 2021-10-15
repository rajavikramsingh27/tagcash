class ChatClickedEvent {
  Map userData;
  ChatClickedEvent(this.userData);
}

class ProfileClickedEvent {
  Map profileData;
  ProfileClickedEvent(this.profileData);
}

class LayoutRefreshEvent {
  bool refreshStatus;
  LayoutRefreshEvent(this.refreshStatus);
}
