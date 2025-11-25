class Ambiente {
  // Tu configuración actual
  static String urlServer = 'https://lechuzointegradora-production.up.railway.app';
  static int idUsuario = 0;
  static String nombreUsuario = '';
  static String token = '';
  static String rol = '';

  // --- NUEVA FUNCIÓN MÁGICA ---
  // Esta función decide si concatenar o no
  static String getUrlImagen(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }
    // Si la imagen ya viene con "http" o "https", NO concatenamos nada
    if (path.startsWith('http')) {
      return path;
    }

    // Si no tiene slash al inicio, se lo ponemos para evitar errores
    String rutaLimpia = path.startsWith('/') ? path : '/$path';

    // Concatenamos servidor + ruta relativa
    return '$urlServer$rutaLimpia';
  }
}