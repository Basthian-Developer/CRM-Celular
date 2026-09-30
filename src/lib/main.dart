import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CRM Celular',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      home: const InicioPage(),
    );
  }
}

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  String mensaje = 'Aún no se ha consultado la API.';
  bool cargando = false;
  bool consultaRealizada = false;
  bool huboError = false;

  Future<void> consumirApi() async {
    setState(() {
      cargando = true;
      huboError = false;
      mensaje = 'Consultando servidor...';
    });

    try {
      final url = Uri.parse(
        'https://portafolio-basthianf.vercel.app/api/',
      );

      final respuesta = await http.get(url);

      if (!mounted) return;

      if (respuesta.statusCode == 200) {
        setState(() {
          mensaje = respuesta.body;
          consultaRealizada = true;
          huboError = false;
        });
      } else {
        setState(() {
          mensaje = 'El servidor respondió con código ${respuesta.statusCode}.';
          consultaRealizada = true;
          huboError = true;
        });
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        mensaje = 'No fue posible conectar con la API.\n\n$error';
        consultaRealizada = true;
        huboError = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _construirEncabezado(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _construirBienvenida(),

                    const SizedBox(height: 28),

                    _construirEstadoApi(),

                    const SizedBox(height: 20),

                    _construirRespuesta(),

                    const SizedBox(height: 24),

                    _construirBoton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirEncabezado() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CRM Celular',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Panel de administración',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirBienvenida() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola 👋',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),

        SizedBox(height: 8),

        Text(
          'Comprueba la conexión entre tu aplicación móvil y el servidor.',
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _construirEstadoApi() {
    final Color colorEstado;

    if (huboError) {
      colorEstado = const Color(0xFFDC2626);
    } else if (consultaRealizada) {
      colorEstado = const Color(0xFF16A34A);
    } else {
      colorEstado = const Color(0xFF9CA3AF);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colorEstado.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              huboError
                  ? Icons.cloud_off_rounded
                  : Icons.cloud_done_outlined,
              color: colorEstado,
              size: 27,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estado de la API',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  cargando
                      ? 'Consultando...'
                      : huboError
                      ? 'Error de conexión'
                      : consultaRealizada
                      ? 'Servidor disponible'
                      : 'Sin comprobar',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: colorEstado,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: colorEstado,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirRespuesta() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 25,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.terminal_rounded,
                color: Color(0xFF93C5FD),
                size: 20,
              ),

              SizedBox(width: 9),

              Text(
                'Respuesta del servidor',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(14),
            ),
            child: cargando
                ? const Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF60A5FA),
                  ),
                ),

                SizedBox(width: 14),

                Text(
                  'Esperando respuesta...',
                  style: TextStyle(
                    color: Color(0xFFD1D5DB),
                    fontSize: 14,
                  ),
                ),
              ],
            )
                : SelectableText(
              mensaje,
              style: TextStyle(
                color: huboError
                    ? const Color(0xFFFCA5A5)
                    : const Color(0xFFD1D5DB),
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirBoton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: cargando ? null : consumirApi,
        icon: cargando
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Icon(
          Icons.sync_rounded,
          size: 22,
        ),
        label: Text(
          cargando ? 'Consultando...' : 'Consumir API',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF93C5FD),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}