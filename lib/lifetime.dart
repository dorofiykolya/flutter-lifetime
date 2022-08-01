import 'package:flutter/foundation.dart' show VoidCallback;

class Definition {
  final String _id;
  final int _parent;
  final Lifetime _lifetime;

  Definition._(String id, int parentId)
      : _id = id,
        _parent = parentId,
        _lifetime = Lifetime._(id);

  String get id => _id;

  int get parentId => _parent;

  Lifetime get lifetime => _lifetime;

  bool get isTerminated => _lifetime._isTerminated;

  void terminate() {
    _lifetime._terminate();
  }
}

class Lifetime {
  static List<List<VoidCallback>> _pool = <List<VoidCallback>>[];
  static int _counter = 0;
  static final Lifetime eternal = new Lifetime._("eternal");

  static Definition define(Lifetime lifetime, {String? id}) {
    if (lifetime._isTerminated) {
      throw new ArgumentError("lifetime was terminated");
    }
    id ??= _counter.toString();
    var definition = new Definition._(id, _counter);
    lifetime._addDefinition(definition);
    return definition;
  }

  static Definition intersection(List<Lifetime> lifetimes) {
    var definition =
        define(eternal, id: "intersection: " + _counter.toString());
    for (var value in lifetimes) {
      value._addDefinition(definition);
    }
    return definition;
  }

  final int _index;
  final String _id;
  late bool _isTerminated;
  late List<VoidCallback>? _actions;

  Lifetime._(String id)
      : _index = _counter,
        _id = id,
        _isTerminated = false {
    _counter++;
    if (_pool.isNotEmpty) {
      _actions = _pool.removeLast();
    } else {
      _actions = <VoidCallback>[];
    }
  }

  int get index => _index;

  String get id => _id;

  bool get isTerminated => _isTerminated;

  Definition defineNested({String? id}) {
    return define(this, id: id);
  }

  Lifetime add(VoidCallback action) {
    if (_isTerminated || _actions == null) {
      return this;
    }
    if (_actions!.contains(action)) {
      throw new ArgumentError("actions already exist");
    }
    _actions!.add(action);
    return this;
  }

  void _addDefinition(Definition definition) {
    if (_actions == null) {
      if (_isTerminated) {
        definition.terminate();
      }
    } else if (!_actions!.contains(definition.terminate)) {
      _actions!.add(definition.terminate);
      definition.lifetime.add(() {
        if (_actions != null) {
          _actions!.remove(definition.terminate);
        }
      });
      if (_isTerminated || definition.isTerminated) {
        definition.terminate();
      }
    }
  }

  void _terminate() {
    if (_actions == null) return;
    _isTerminated = true;
    var actions = _actions;
    _actions = null;
    for (var i = actions!.length - 1; i >= 0; --i) {
      var action = actions[i];
      action();
    }
    actions.clear();
    _pool.add(actions);
  }
}
