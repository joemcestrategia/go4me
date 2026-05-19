import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum AppLocale { pt, en, es }

final localeProvider = StateProvider<AppLocale>((ref) => AppLocale.pt);

extension AppLocaleX on AppLocale {
  Locale get flutterLocale {
    switch (this) {
      case AppLocale.pt: return const Locale('pt');
      case AppLocale.en: return const Locale('en');
      case AppLocale.es: return const Locale('es');
    }
  }
}

final appStringsProvider = Provider<AppStrings>((ref) {
  final locale = ref.watch(localeProvider);
  return AppStrings(locale);
});

class AppStrings {
  final AppLocale _locale;

  AppStrings(this._locale);

  String get appTitle => _i('Go4Me', 'Go4Me', 'Go4Me');
  String get login => _i('Entrar', 'Sign In', 'Iniciar Sesión');
  String get signUp => _i('Cadastrar', 'Sign Up', 'Registrarse');
  String get email => _i('E-mail', 'Email', 'Correo');
  String get password => _i('Senha', 'Password', 'Contraseña');
  String get forgotPassword => _i('Esqueceu a senha?', 'Forgot password?', '¿Olvidó su contraseña?');
  String get enterPlatform => _i('Entre na plataforma', 'Sign in to the platform', 'Ingrese a la plataforma');
  String get save => _i('Salvar', 'Save', 'Guardar');
  String get search => _i('Buscar', 'Search', 'Buscar');
  String get explore => _i('Explorar', 'Explore', 'Explorar');
  String get feed => _i('Feed', 'Feed', 'Feed');
  String get profile => _i('Perfil', 'Profile', 'Perfil');
  String get home => _i('Início', 'Home', 'Inicio');
  String get impact => _i('Meu Impacto', 'My Impact', 'Mi Impacto');
  String get prayerWall => _i('Mural de Oração', 'Prayer Wall', 'Muro de Oración');
  String get pray => _i('Orar', 'Pray', 'Orar');
  String get praying => _i('Orando', 'Praying', 'Orando');
  String get prayed => _i('Já orei', 'Prayed', 'Orado');
  String get prayerRequest => _i('Pedido de Oração', 'Prayer Request', 'Petición de Oración');
  String get allCategories => _i('Todas', 'All', 'Todas');
  String get emptyPrayerWall => _i('Nenhum pedido de oração ainda', 'No prayer requests yet', 'Sin peticiones aún');
  String get follow => _i('Seguir', 'Follow', 'Seguir');
  String get following => _i('Seguindo', 'Following', 'Siguiendo');
  String get editProfile => _i('Editar Perfil', 'Edit Profile', 'Editar Perfil');
  String get donate => _i('Doar', 'Donate', 'Donar');
  String get logout => _i('Sair', 'Logout', 'Cerrar Sesión');

  String categoryName(String key) {
    final map = {
      'education': _i('Educação', 'Education', 'Educación'),
      'health': _i('Saúde', 'Health', 'Salud'),
      'church_planting': _i('Plantação de Igrejas', 'Church Planting', 'Plantación de Iglesias'),
      'bible_translation': _i('Tradução Bíblica', 'Bible Translation', 'Traducción Bíblica'),
      'humanitarian': _i('Ajuda Humanitária', 'Humanitarian Aid', 'Ayuda Humanitaria'),
      'discipleship': _i('Discipulado', 'Discipleship', 'Discipulado'),
      'street_outreach': _i('Missão de Rua', 'Street Outreach', 'Alcance Callejero'),
      'orphans': _i('Orfanatos', 'Orphanages', 'Orfanatos'),
      'water': _i('Projetos de Água', 'Water Projects', 'Proyectos de Agua'),
      'urban': _i('Missão Urbana', 'Urban Mission', 'Misión Urbana'),
    };
    return map[key] ?? key;
  }

  String _i(String pt, String en, String es) {
    switch (_locale) {
      case AppLocale.pt: return pt;
      case AppLocale.en: return en;
      case AppLocale.es: return es;
    }
  }
}
