import 'package:flutter/material.dart';

import '../controllers/api_controller.dart';
import '../models/api_response.dart';
import '../models/service_request.dart';
import '../services/api_service.dart';

const _background = Color(0xFF0D0D0D);
const _surface = Color(0xFF171717);
const _surfaceSoft = Color(0xFF202020);
const _gold = Color(0xFFD4AF37);
const _muted = Color(0xFF9A9A9A);

const _requests = [
  ServiceRequest(
    title: 'Landing page para emprendimiento',
    client: 'Estudio Nómada',
    description: 'Diseño y desarrollo de una landing page para presentar servicios, equipo y formulario de contacto.',
    budget: '\$450.000 - \$600.000',
    deadline: '15 días',
    receivedAt: 'Hace 2 horas',
    category: 'Desarrollo web',
  ),
  ServiceRequest(
    title: 'Tienda online básica',
    client: 'Casa Roble',
    description: 'Sitio web con catálogo de productos, carrito de compras y una sección de contacto para pedidos.',
    budget: '\$700.000 - \$950.000',
    deadline: '30 días',
    receivedAt: 'Ayer',
    category: 'E-commerce',
  ),
  ServiceRequest(
    title: 'Rediseño de sitio corporativo',
    client: 'Grupo Andino',
    description: 'Actualizar la imagen visual del sitio actual y mejorar su experiencia en dispositivos móviles.',
    budget: '\$500.000 - \$750.000',
    deadline: '20 días',
    receivedAt: 'Hace 3 días',
    category: 'Diseño web',
  ),
];

const _recentApis = [
  ('Portafolio personal', 'portafolio-basthianf.vercel.app', 'Hace 10 min', Icons.language_rounded),
  ('API del CRM', 'portafolio-basthianf.vercel.app/api/', 'Hace 35 min', Icons.api_rounded),
  ('Panel de clientes', 'clientes.miweb.cl', 'Ayer, 18:20', Icons.dashboard_customize_outlined),
  ('Formulario de contacto', 'contacto.miweb.cl', 'Ayer, 15:42', Icons.contact_mail_outlined),
];

class HomeView extends StatefulWidget {
  const HomeView({required this.apiService, super.key});

  final ApiService apiService;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final ApiController _controller;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = ApiController(apiService: widget.apiService);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _background,
          body: SafeArea(child: _buildSelectedView()),
          bottomNavigationBar: _buildNavbar(),
        );
      },
    );
  }

  Widget _buildSelectedView() {
    switch (_selectedIndex) {
      case 1:
        return _buildRequestsView();
      case 2:
        return _buildApisView();
      case 3:
        return _buildSettingsView();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    final apiResponse = _controller.response;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(),
          const SizedBox(height: 30),
          const Text('Buenos días,', style: TextStyle(color: _muted, fontSize: 15)),
          const SizedBox(height: 5),
          const Text('Tu resumen personal', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          _buildPrimaryCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('Resumen', 'Ver detalles'),
          const SizedBox(height: 12),
          _buildMetrics(),
          const SizedBox(height: 24),
          _buildSectionTitle('APIs usadas recientemente', 'Ver todas'),
          const SizedBox(height: 12),
          _buildRecentApisPreview(),
          const SizedBox(height: 24),
          _buildSyncCard(apiResponse),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(13)),
          child: const Icon(Icons.auto_awesome_rounded, color: Colors.black, size: 22),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Text('CRM MINI', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.5))),
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded, color: Colors.white)),
        const SizedBox(width: 4),
        const CircleAvatar(
          radius: 19,
          backgroundColor: _surfaceSoft,
          child: Text('BF', style: TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _buildPrimaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF3D3211), Color(0xFF1F1A0B)]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _gold.withValues(alpha: 0.45)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(Icons.insights_rounded, color: _gold, size: 20), SizedBox(width: 8), Text('RESUMEN DE HOY', style: TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2))]),
          SizedBox(height: 18),
          Text('24', style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w800)),
          SizedBox(height: 2),
          Text('seguimientos pendientes', style: TextStyle(color: Color(0xFFD9D0B5), fontSize: 14)),
          SizedBox(height: 18),
          ClipRRect(borderRadius: BorderRadius.all(Radius.circular(10)), child: LinearProgressIndicator(value: 0.68, minHeight: 7, backgroundColor: Color(0x664B411D), color: _gold)),
          SizedBox(height: 9),
          Text('68% completado esta semana', style: TextStyle(color: _muted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String? action) {
    return Row(
      children: [
        Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700))),
        if (action != null) Text(action, style: const TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildMetrics() {
    return Row(
      children: [
        _metricCard('128', 'Contactos', Icons.people_alt_outlined, '+12%'),
        const SizedBox(width: 10),
        _metricCard('56', 'Interacciones', Icons.chat_bubble_outline_rounded, '+8%'),
        const SizedBox(width: 10),
        _metricCard('18', 'Solicitudes', Icons.inbox_outlined, '+5%'),
      ],
    );
  }

  Widget _metricCard(String value, String label, IconData icon, String growth) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(17)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: _gold, size: 19),
            const SizedBox(height: 14),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 11)),
            const SizedBox(height: 9),
            Text(growth, style: const TextStyle(color: _gold, fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentApisPreview() {
    return Column(children: [_apiTile(_recentApis[0]), _apiTile(_recentApis[1])]);
  }

  Widget _buildApisView() {
    return _pageScaffold(
      title: 'APIs',
      subtitle: 'Páginas y servicios usados recientemente',
      child: Column(children: [for (final api in _recentApis) _apiTile(api, showChevron: true)]),
    );
  }

  Widget _apiTile((String, String, String, IconData) api, {bool showChevron = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(17)),
      child: Row(
        children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: _gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(13)), child: Icon(api.$4, color: _gold, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(api.$1, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(api.$2, style: const TextStyle(color: _muted, fontSize: 11)), const SizedBox(height: 4), Text(api.$3, style: const TextStyle(color: Color(0xFF6F6F6F), fontSize: 10))])),
          if (showChevron) const Icon(Icons.chevron_right_rounded, color: _muted),
        ],
      ),
    );
  }

  Widget _buildRequestsView() {
    return _pageScaffold(
      title: 'Solicitudes',
      subtitle: 'Encargos web recibidos',
      child: Column(
        children: [
          for (final request in _requests) _requestCard(request),
        ],
      ),
    );
  }

  Widget _requestCard(ServiceRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(19), border: Border.all(color: const Color(0xFF292929))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Expanded(child: Text(request.title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))), _statusBadge()]),
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.business_outlined, color: _gold, size: 16), const SizedBox(width: 6), Text(request.client, style: const TextStyle(color: _muted, fontSize: 12))]),
          const SizedBox(height: 14),
          Row(children: [_requestInfo(Icons.category_outlined, request.category), const SizedBox(width: 18), _requestInfo(Icons.schedule_outlined, request.receivedAt)]),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => _openRequestDetails(request), child: const Text('Ver detalles'))),
        ],
      ),
    );
  }

  Widget _statusBadge() {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: _gold.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(20)), child: const Text('Nueva', style: TextStyle(color: _gold, fontSize: 10, fontWeight: FontWeight.w700)));
  }

  Widget _requestInfo(IconData icon, String text) {
    return Expanded(child: Row(children: [Icon(icon, color: _muted, size: 15), const SizedBox(width: 5), Expanded(child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 11)))]));
  }

  void _openRequestDetails(ServiceRequest request) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => RequestDetailsView(request: request)));
  }

  Widget _buildSettingsView() {
    return _pageScaffold(
      title: 'Ajustes',
      subtitle: 'Preferencias de tu CRM personal',
      child: Column(children: [_settingsTile(Icons.person_outline_rounded, 'Perfil', 'Gestiona tus datos personales'), _settingsTile(Icons.notifications_none_rounded, 'Notificaciones', 'Configura tus recordatorios'), _settingsTile(Icons.palette_outlined, 'Apariencia', 'Tema oscuro premium')]),
    );
  }

  Widget _settingsTile(IconData icon, String title, String subtitle) {
    return Container(margin: const EdgeInsets.only(bottom: 10), child: ListTile(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), tileColor: _surface, leading: Icon(icon, color: _gold), title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)), subtitle: Text(subtitle, style: const TextStyle(color: _muted, fontSize: 12)), trailing: const Icon(Icons.chevron_right_rounded, color: _muted)));
  }

  Widget _pageScaffold({required String title, required String subtitle, required Widget child}) {
    return SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 24, 20, 28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('CRM MINI', style: TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5)), const SizedBox(height: 14), Text(title, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text(subtitle, style: const TextStyle(color: _muted, fontSize: 14)), const SizedBox(height: 25), child]));
  }

  Widget _buildSyncCard(ApiResponse response) {
    final isLoading = response.isLoading;
    final isSuccess = response.wasSuccessful;
    final status = isLoading ? 'Sincronizando...' : isSuccess ? 'Sincronizado' : 'Listo para sincronizar';
    return Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13), decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16)), child: Row(children: [Icon(isSuccess ? Icons.cloud_done_outlined : Icons.cloud_queue_outlined, color: isSuccess ? _gold : _muted, size: 20), const SizedBox(width: 10), Expanded(child: Text(status, style: const TextStyle(color: _muted, fontSize: 12))), TextButton(onPressed: isLoading ? null : _controller.consultarApi, child: const Text('Sincronizar'))]));
  }

  Widget _buildNavbar() {
    const items = [(Icons.space_dashboard_rounded, 'Inicio'), (Icons.inbox_outlined, 'Solicitudes'), (Icons.api_rounded, 'APIs'), (Icons.settings_outlined, 'Ajustes')];
    return NavigationBar(selectedIndex: _selectedIndex, onDestinationSelected: (index) => setState(() => _selectedIndex = index), backgroundColor: _surface, indicatorColor: _gold.withValues(alpha: 0.18), labelBehavior: NavigationDestinationLabelBehavior.alwaysShow, destinations: [for (final item in items) NavigationDestination(icon: Icon(item.$1, color: _muted), selectedIcon: Icon(item.$1, color: _gold), label: item.$2)]);
  }
}

class RequestDetailsView extends StatelessWidget {
  const RequestDetailsView({required this.request, super.key});

  final ServiceRequest request;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        title: const Text(
          'Detalle de solicitud',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statusBadge(),
            const SizedBox(height: 18),
            Text(
              request.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.business_outlined, color: _gold, size: 17),
                const SizedBox(width: 7),
                Text(
                  request.client,
                  style: const TextStyle(color: _muted, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _detailBlock('Descripción del encargo', request.description),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(child: _detailBlock('Presupuesto', request.budget)),
                const SizedBox(width: 16),
                Expanded(child: _detailBlock('Plazo estimado', request.deadline)),
              ],
            ),
            const SizedBox(height: 22),
            _detailBlock('Categoría', request.category),
            const SizedBox(height: 34),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.mail_outline_rounded),
                    label: const Text('Contactar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Rechazar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailBlock(String title, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: _muted, fontSize: 12)), const SizedBox(height: 8), Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.45, fontWeight: FontWeight.w600))]);
  }

  Widget _statusBadge() {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: _gold.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(20)), child: const Text('SOLICITUD NUEVA', style: TextStyle(color: _gold, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)));
  }
}
