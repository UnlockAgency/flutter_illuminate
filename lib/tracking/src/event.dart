abstract class EventNameable {
  String get value;
}

abstract class Event {
  EventNameable get name;
  Map<String, dynamic>? get parameters;
}
