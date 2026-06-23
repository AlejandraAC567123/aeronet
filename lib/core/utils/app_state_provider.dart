import 'package:flutter/material.dart';

class AppStateProvider<T extends Listenable> extends InheritedNotifier<T> {
  const AppStateProvider({
    super.key,
    required T notifier,
    required super.child,
  }) : super(notifier: notifier);

  static T of<T extends Listenable>(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppStateProvider<T>>();
    assert(provider != null, 'No se encontró un AppStateProvider de tipo $T en el contexto. Asegúrate de registrarlo arriba en el árbol de widgets.');
    return provider!.notifier!;
  }
}
