class Change<T> {
  Change(
    this._oldValue,
    this._execute(),
    this._undo(T oldValue), {
    this.description = '',
  });

  final String description;

  final void Function() _execute;
  final T _oldValue;

  final void Function(T oldValue) _undo;

  void execute() {
    _execute();
  }

  void undo() {
    _undo(_oldValue);
  }
}
