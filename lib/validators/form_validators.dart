class FormValidators {

  // ── Nombre ─────────────────────────────────
  static String? nombreValido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es obligatorio';
    }
    if (value.trim().length < 3) {
      return 'Mínimo 3 caracteres';
    }
    if (value.trim().length > 50) {
      return 'Máximo 50 caracteres';
    }
    final regex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9 ]+$');
    if (!regex.hasMatch(value.trim())) {
      return 'Sin caracteres especiales';
    }
    return null;
  }

  // ── Semestre ───────────────────────────────
  static String? semestreValido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El semestre es obligatorio';
    }
    if (value.trim().length < 6) {
      return 'Mínimo 6 caracteres';
    }
    if (value.trim().length > 15) {
      return 'Máximo 15 caracteres';
    }
    final regex = RegExp(r'^[a-zA-Z0-9\-]+$');
    if (!regex.hasMatch(value.trim())) {
      return 'Solo se permite el guion (-) como carácter especial';
    }
    return null;
  }

  // ── Créditos ───────────────────────────────
  static String? creditosValido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Los créditos son obligatorios';
    }
    final regex = RegExp(r'^([1-9]|10)$');
    if (!regex.hasMatch(value.trim())) {
      return 'Ingresa un número entre 1 y 10';
    }
    return null;
  }
}