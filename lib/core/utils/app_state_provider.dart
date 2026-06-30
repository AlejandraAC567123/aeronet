import 'package:flutter/material.dart';

class AppStateProvider<T extends Listenable> extends InheritedNotifier<T> {
  const AppStateProvider({
    super.key,
    required T notifier,
    required super.child,
  }) : super(notifier: notifier);

  // Suscribe al widget (se reconstruye cuando cambia)
  static T of<T extends Listenable>(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppStateProvider<T>>();
    assert(provider != null, 'No AppStateProvider<$T> encontrado.');
    return provider!.notifier!;
  }

  // Solo lee sin suscribirse (no reconstruye el widget)
  static T read<T extends Listenable>(BuildContext context) {
    final provider = context.getInheritedWidgetOfExactType<AppStateProvider<T>>();
    assert(provider != null, 'No AppStateProvider<$T> encontrado.');
    return provider!.notifier!;
  }
}
