_handlers = {}

def listen(event_name, callback):
    if event_name not in _handlers:
        _handlers[event_name] = []
    _handlers[event_name].append(callback)

def call(event_name, *args):
    if event_name in _handlers:
        for cb in _handlers[event_name]:
            try:
                cb(*args)
            except Exception as e:
                print(f"Error in event {event_name}: {e}")
