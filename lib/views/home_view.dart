import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/api_controller.dart';
import '../controllers/consultations_controller.dart';
import '../controllers/logs_controller.dart';
import '../controllers/projects_controller.dart';
import '../models/api_response.dart';
import '../models/project.dart';
import '../models/service_request.dart';
import '../services/api_service.dart';

const _background = Color(0xFF0D0D0D);
const _surface = Color(0xFF171717);
const _surfaceSoft = Color(0xFF202020);
const _gold = Color(0xFFD4AF37);
const _muted = Color(0xFF9A9A9A);

class HomeView extends StatefulWidget {
  const HomeView({required this.apiService, super.key});

  final ApiService apiService;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final ApiController _controller;
  late final ConsultationsController _consultationsController;
  late final LogsController _logsController;
  late final ProjectsController _projectsController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _logsController = LogsController();
    _controller = ApiController(apiService: widget.apiService);
    _consultationsController = ConsultationsController(apiService: widget.apiService, onLog: _logsController.add);
    _projectsController = ProjectsController(apiService: widget.apiService, onLog: _logsController.add);
    _consultationsController.cargarConsultas();
    _projectsController.loadProjects();
  }

  @override
  void dispose() {
    _consultationsController.dispose();
    _projectsController.dispose();
    _logsController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _consultationsController, _projectsController, _logsController]),
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
          _buildSectionTitle('Proyectos recientes', 'Ver todos'),
          const SizedBox(height: 12),
          _buildRecentProjectsPreview(),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(Icons.folder_copy_outlined, color: _gold, size: 20), SizedBox(width: 8), Text('CRM EVOLUTION', style: TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2))]),
          SizedBox(height: 18),
          Text('Proyectos', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
          SizedBox(height: 5),
          Text('Administra los proyectos de tu portafolio', style: TextStyle(color: Color(0xFFD9D0B5), fontSize: 14)),
          SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: Text('${_projectsController.projects.length} proyectos registrados', style: const TextStyle(color: _muted, fontSize: 12))),
              FilledButton.icon(
                onPressed: () => setState(() => _selectedIndex = 2),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('Abrir'),
                style: FilledButton.styleFrom(backgroundColor: _gold, foregroundColor: Colors.black),
              ),
            ],
          ),
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
        _metricCard('${_consultationsController.consultations.length}', 'Solicitudes', Icons.inbox_outlined, 'API'),
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

  Widget _buildRecentProjectsPreview() {
    return Column(
      children: [for (final project in _projectsController.projects.take(2)) _projectTile(project)],
    );
  }

  Widget _buildApisView() {
    return _pageScaffold(
      title: 'APIs',
      subtitle: 'Conecta y administra los recursos de tu CRM',
      child: Column(
        children: [
          _apiProjectCard(),
          const SizedBox(height: 22),
          _manualRequestPanel(),
        ],
      ),
    );
  }

  Widget _apiProjectCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF3D3211), Color(0xFF1F1A0B)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: _gold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.folder_copy_outlined, color: _gold),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Proyectos', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('Gestiona los proyectos de tu portafolio', style: TextStyle(color: _muted, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: Text('${_projectsController.projects.length} proyectos disponibles', style: const TextStyle(color: Color(0xFFD9D0B5), fontSize: 12))),
              FilledButton.icon(
                onPressed: _openProjectsManagement,
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('Abrir'),
                style: FilledButton.styleFrom(backgroundColor: _gold, foregroundColor: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsView() {
    final state = _projectsController;
    return _pageScaffold(
      title: 'Proyectos',
      subtitle: 'Administra los proyectos de tu portafolio',
      action: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: state.isLoading ? null : state.loadProjects, icon: const Icon(Icons.refresh_rounded, color: _gold), tooltip: 'Recargar proyectos'),
          IconButton(onPressed: _openCreateProject, icon: const Icon(Icons.add_rounded, color: _gold), tooltip: 'Agregar proyecto'),
        ],
      ),
      child: Column(
        children: [
          if (state.isLoading) const Padding(padding: EdgeInsets.all(35), child: CircularProgressIndicator(color: _gold)),
          if (!state.isLoading && state.errorMessage != null) _projectError(state.errorMessage!),
          if (!state.isLoading && state.errorMessage == null && state.projects.isEmpty) _emptyProjects(),
          if (!state.isLoading && state.errorMessage == null) for (final project in state.projects) _projectCard(project),
        ],
      ),
    );
  }

  Widget _projectTile(Project project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(17)),
      child: Row(
        children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: _gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.folder_open_outlined, color: _gold, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(project.name ?? 'Proyecto sin nombre', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(project.githubUrl, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 11))])),
          const Icon(Icons.chevron_right_rounded, color: _muted),
        ],
      ),
    );
  }

  Widget _projectCard(Project project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(19), border: Border.all(color: const Color(0xFF292929))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(project.name ?? 'Proyecto sin nombre', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))), if (project.isActive == false) _projectStatus('Inactivo')]),
        const SizedBox(height: 8),
        Text(project.description ?? 'Sin descripción disponible.', style: const TextStyle(color: _muted, fontSize: 13, height: 1.4)),
        if (project.tags?.isNotEmpty == true) ...[const SizedBox(height: 12), Wrap(spacing: 6, runSpacing: 6, children: [for (final tag in project.tags!) _tag(tag)])],
        const SizedBox(height: 15),
        Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () => _openEditProject(project), icon: const Icon(Icons.edit_outlined, size: 17), label: const Text('Editar'))), const SizedBox(width: 10), Expanded(child: TextButton.icon(onPressed: project.isActive == false ? null : () => _deactivateProject(project), icon: const Icon(Icons.block_outlined, size: 17), label: const Text('Desactivar')))]),
      ]),
    );
  }

  Widget _tag(String value) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: _gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)), child: Text(value, style: const TextStyle(color: _gold, fontSize: 10)));

  Widget _projectStatus(String label) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: const Color(0xFF522222), borderRadius: BorderRadius.circular(20)), child: Text(label, style: const TextStyle(color: Color(0xFFFFAAA0), fontSize: 10)));

  Widget _projectError(String message) => Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(18)), child: Column(children: [const Icon(Icons.cloud_off_rounded, color: _gold, size: 28), const SizedBox(height: 10), Text(message, textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 13)), const SizedBox(height: 12), OutlinedButton(onPressed: _projectsController.loadProjects, child: const Text('Reintentar'))]));

  Widget _emptyProjects() => Container(width: double.infinity, padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(18)), child: const Column(children: [Icon(Icons.folder_off_outlined, color: _muted, size: 34), SizedBox(height: 12), Text('No hay proyectos disponibles.', style: TextStyle(color: _muted, fontSize: 14))]));

  Widget _manualRequestPanel() => ManualApiRequestPanel(apiService: widget.apiService, logsController: _logsController);

  void _openProjectsManagement() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: _background,
          appBar: AppBar(
            backgroundColor: _background,
            foregroundColor: Colors.white,
            title: const Text('Proyectos'),
          ),
          body: _buildProjectsView(),
        ),
      ),
    );
  }

  void _openCreateProject() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProjectFormView(controller: _projectsController)));
  }

  void _openEditProject(Project project) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProjectFormView(controller: _projectsController, project: project)));
  }

  Future<void> _deactivateProject(Project project) async {
    final error = await _projectsController.deactivateProject(project.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Proyecto desactivado correctamente.')));
  }

  Widget _buildRequestsView() {
    final state = _consultationsController;

    return _pageScaffold(
      title: 'Solicitudes',
      subtitle: 'Encargos web recibidos',
      action: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: state.isLoading ? null : _reloadRequests,
            icon: const Icon(Icons.refresh_rounded, color: _gold),
            tooltip: 'Recargar solicitudes',
          ),
          IconButton(
            onPressed: _openCreateRequest,
            icon: const Icon(Icons.add_rounded, color: _gold),
            tooltip: 'Crear solicitud',
          ),
        ],
      ),
      child: state.isLoading
          ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: _gold)))
          : state.errorMessage != null
          ? _buildRequestsError(state.errorMessage!)
          : state.consultations.isEmpty
          ? _buildEmptyRequests()
          : Column(children: [for (final request in state.consultations) _requestCard(request)]),
    );
  }

  Widget _buildRequestsError(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: _gold, size: 28),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 13)),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: _consultationsController.cargarConsultas, child: const Text('Reintentar')),
        ],
      ),
    );
  }

  Future<void> _reloadRequests() {
    return _consultationsController.cargarConsultas();
  }

  Widget _buildEmptyRequests() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(18)),
      child: const Column(children: [Icon(Icons.inbox_outlined, color: _muted, size: 34), SizedBox(height: 12), Text('No hay solicitudes disponibles.', style: TextStyle(color: _muted, fontSize: 14))]),
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
          Row(children: [Expanded(child: Text(request.title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))), _statusBadge(request)]),
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.business_outlined, color: _gold, size: 16), const SizedBox(width: 6), Text(request.client, style: const TextStyle(color: _muted, fontSize: 12))]),
          const SizedBox(height: 14),
          Row(children: [_requestInfo(Icons.category_outlined, request.category), const SizedBox(width: 18), _requestInfo(Icons.schedule_outlined, request.receivedAt)]),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => _openRequestDetails(request), child: const Text('Ver detalles'))),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openEditRequest(request),
                  icon: const Icon(Icons.edit_outlined, size: 17),
                  label: const Text('Editar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _deactivateRequest(request),
                  icon: const Icon(Icons.block_outlined, size: 17),
                  label: const Text('Desactivar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(ServiceRequest request) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: _gold.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(20)), child: Text(request.priority, style: const TextStyle(color: _gold, fontSize: 10, fontWeight: FontWeight.w700)));
  }

  Widget _requestInfo(IconData icon, String text) {
    return Expanded(child: Row(children: [Icon(icon, color: _muted, size: 15), const SizedBox(width: 5), Expanded(child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 11)))]));
  }

  void _openRequestDetails(ServiceRequest request) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => RequestDetailsView(request: request, controller: _consultationsController)));
  }

  void _openCreateRequest() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateRequestView(controller: _consultationsController),
      ),
    );
  }

  void _openEditRequest(ServiceRequest request) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateRequestView(
          controller: _consultationsController,
          request: request,
        ),
      ),
    );
  }

  Future<void> _deactivateRequest(ServiceRequest request) async {
    if (!request.isActive) return;

    final error = await _consultationsController.desactivarConsulta(request.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Solicitud desactivada correctamente.')),
    );
  }

  Widget _buildSettingsView() {
    return _pageScaffold(
      title: 'Ajustes',
      subtitle: 'Preferencias de tu CRM personal',
      child: Column(children: [_settingsTile(Icons.person_outline_rounded, 'Perfil', 'Gestiona tus datos personales'), _settingsTile(Icons.notifications_none_rounded, 'Notificaciones', 'Configura tus recordatorios'), _settingsTile(Icons.palette_outlined, 'Apariencia', 'Tema oscuro premium'), const SizedBox(height: 20), _buildLogsSection()]),
    );
  }

  Widget _buildLogsSection() {
    final logs = _logsController.logs;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Expanded(child: Text('Log de actividad', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700))), TextButton(onPressed: logs.isEmpty ? null : _logsController.clear, child: const Text('Limpiar'))]),
      const SizedBox(height: 10),
      Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(17)), child: logs.isEmpty ? const Text('Todavía no hay operaciones registradas.', style: TextStyle(color: _muted, fontSize: 12)) : Column(children: [for (final log in logs.take(12)) ListTile(contentPadding: EdgeInsets.zero, dense: true, leading: const Icon(Icons.terminal_rounded, color: _gold, size: 18), title: Text(log.message, style: const TextStyle(color: Colors.white, fontSize: 12)), subtitle: Text(_logTime(log.createdAt), style: const TextStyle(color: _muted, fontSize: 10)))])),
    ]);
  }

  String _logTime(DateTime time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';

  Widget _settingsTile(IconData icon, String title, String subtitle) {
    return Container(margin: const EdgeInsets.only(bottom: 10), child: ListTile(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), tileColor: _surface, leading: Icon(icon, color: _gold), title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)), subtitle: Text(subtitle, style: const TextStyle(color: _muted, fontSize: 12)), trailing: const Icon(Icons.chevron_right_rounded, color: _muted)));
  }

  Widget _pageScaffold({required String title, required String subtitle, required Widget child, Widget? action}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CRM MINI', style: TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800))),
              if (action != null) action,
            ],
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: _muted, fontSize: 14)),
          const SizedBox(height: 25),
          child,
        ],
      ),
    );
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
  const RequestDetailsView({required this.request, required this.controller, super.key});

  final ServiceRequest request;
  final ConsultationsController controller;

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
            _statusBadge(request),
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
                Expanded(child: _detailBlock('Correo', request.email)),
                const SizedBox(width: 16),
                Expanded(child: _detailBlock('Teléfono', request.phone)),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(child: _detailBlock('Plan solicitado', request.category)),
                const SizedBox(width: 16),
                Expanded(child: _detailBlock('Prioridad', request.priority)),
              ],
            ),
            const SizedBox(height: 22),
            _detailBlock('Plazo solicitado', request.deadline),
            const SizedBox(height: 8),
            Text('Recibida: ${request.receivedAt}', style: const TextStyle(color: _muted, fontSize: 12)),
            const SizedBox(height: 4),
            Text('Estado: ${request.status}', style: const TextStyle(color: _muted, fontSize: 12)),
            const SizedBox(height: 34),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _contactClient(context),
                    icon: const Icon(Icons.mail_outline_rounded),
                    label: const Text('Contactar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _deactivate(context),
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

  Future<void> _contactClient(BuildContext context) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: request.email,
      queryParameters: {
        'subject': 'Consulta sobre tu solicitud web',
        'body': 'Hola ${request.client},\n\nQuisiera conversar sobre tu solicitud: ${request.title}.',
      },
    );

    final opened = await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró una aplicación de correo disponible.')),
      );
    }
  }

  Future<void> _deactivate(BuildContext context) async {
    final error = await controller.desactivarConsulta(request.id);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pop();
  }

  Widget _statusBadge(ServiceRequest request) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: _gold.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(20)), child: Text(request.priority.toUpperCase(), style: const TextStyle(color: _gold, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)));
  }
}

class CreateRequestView extends StatefulWidget {
  const CreateRequestView({required this.controller, this.request, super.key});

  final ConsultationsController controller;
  final ServiceRequest? request;

  @override
  State<CreateRequestView> createState() => _CreateRequestViewState();
}

class _CreateRequestViewState extends State<CreateRequestView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _planController = TextEditingController(text: '1');
  final _problemController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  String _priority = 'Normal';
  bool _isActive = true;
  DateTime? _startDate;
  DateTime? _endDate;

  bool get _isEditing => widget.request != null;

  @override
  void initState() {
    super.initState();
    final request = widget.request;
    if (request != null) {
      _nameController.text = request.client;
      _emailController.text = request.email;
      _phoneController.text = request.phone;
      _planController.text = request.plan.toString();
      _problemController.text = request.description;
      _priority = ['Baja', 'Normal', 'Alta', 'Urgente'].contains(request.priority) ? request.priority : 'Normal';
      _isActive = request.isActive;
      _startDate = _parseDate(request.startDate);
      _endDate = _parseDate(request.endDate);
      if (_startDate != null) _startDateController.text = _formatDate(_startDate!);
      if (_endDate != null) _endDateController.text = _formatDate(_endDate!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _planController.dispose();
    _problemController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _background,
          appBar: AppBar(
            backgroundColor: _background,
            foregroundColor: Colors.white,
            title: Text(_isEditing ? 'Editar solicitud' : 'Crear solicitud', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              children: [
                Text(_isEditing ? 'Editar consulta' : 'Nueva consulta', style: const TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w800)),
                const SizedBox(height: 7),
                Text(_isEditing ? 'Revisa los datos de la consulta.' : 'Completa los datos del encargo recibido.', style: const TextStyle(color: _muted, fontSize: 14)),
                const SizedBox(height: 26),
                _textField(_nameController, 'Nombre', Icons.person_outline_rounded),
                const SizedBox(height: 14),
                _textField(_emailController, 'Correo', Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 14),
                _textField(_phoneController, 'Teléfono', Icons.phone_outlined, keyboardType: TextInputType.phone),
                const SizedBox(height: 14),
                _textField(_planController, 'Plan', Icons.tune_rounded, keyboardType: TextInputType.number),
                const SizedBox(height: 14),
                _textField(_problemController, 'Problema o encargo', Icons.description_outlined, maxLines: 5),
                const SizedBox(height: 14),
                _dateField('Plazo inicial', _startDate, _startDateController, (date) => setState(() => _startDate = date)),
                const SizedBox(height: 14),
                _dateField('Plazo final', _endDate, _endDateController, (date) => setState(() => _endDate = date)),
                const SizedBox(height: 14),
                _dropdown<String>('Prioridad', _priority, ['Baja', 'Normal', 'Alta', 'Urgente'], (value) => setState(() => _priority = value!), (value) => value),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Solicitud activa', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: const Text('Disponible para seguimiento', style: TextStyle(color: _muted, fontSize: 12)),
                  value: _isActive,
                  activeColor: _gold,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: widget.controller.isSaving ? null : _save,
                    icon: widget.controller.isSaving
                        ? const SizedBox(width: 19, height: 19, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : const Icon(Icons.save_outlined),
                    label: Text(widget.controller.isSaving ? 'Guardando...' : _isEditing ? 'Guardar cambios' : 'Crear solicitud'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _textField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Ingresa ${label[0].toLowerCase()}${label.substring(1)}';
        }
        if (label == 'Plan' && int.tryParse(value.trim()) == null) {
          return 'El plan debe ser un número';
        }
        return null;
      },
      decoration: _inputDecoration(label, icon),
    );
  }

  Widget _dropdown<T>(String label, T value, List<T> values, ValueChanged<T?> onChanged, String Function(T) text) {
    return DropdownButtonFormField<T>(
      value: value,
      dropdownColor: _surfaceSoft,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: _inputDecoration(label, Icons.tune_rounded),
      items: values.map((item) => DropdownMenuItem<T>(value: item, child: Text(text(item)))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _dateField(String label, DateTime? date, TextEditingController controller, ValueChanged<DateTime> onSelected) {
    return TextFormField(
      readOnly: true,
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: _inputDecoration(label, Icons.calendar_today_outlined).copyWith(suffixIcon: const Icon(Icons.expand_more_rounded, color: _muted)),
      onTap: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.dark(primary: _gold, surface: _surface)), child: child!),
        );
        if (selected != null) {
          controller.text = _formatDate(selected);
          onSelected(selected);
        }
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _muted),
      helperText: label == 'Plan' ? '1 Básico · 2 Pro · 3 Avanzado' : null,
      helperStyle: const TextStyle(color: _muted, fontSize: 11),
      prefixIcon: Icon(icon, color: _gold, size: 20),
      filled: true,
      fillColor: _surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: _gold)),
      errorStyle: const TextStyle(color: Color(0xFFFF8A80)),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final payload = {
      'nombre': _nameController.text.trim(),
      'correo': _emailController.text.trim(),
      'telefono': _phoneController.text.trim(),
      'plan': int.tryParse(_planController.text.trim()) ?? 1,
      'problema': _problemController.text.trim(),
      'plazo_inicio': _startDate == null ? null : _formatApiDate(_startDate!),
      'plazo_final': _endDate == null ? null : _formatApiDate(_endDate!),
      'prioridad': _priority,
      'estado': _isActive,
    };

    final error = _isEditing
        ? await widget.controller.editarConsulta(widget.request!.id, payload)
        : await widget.controller.crearConsulta(payload);

    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pop();
  }

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  String _formatApiDate(DateTime date) => '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  DateTime? _parseDate(String? value) => value == null ? null : DateTime.tryParse(value);
}

class ProjectFormView extends StatefulWidget {
  const ProjectFormView({required this.controller, this.project, super.key});

  final ProjectsController controller;
  final Project? project;

  @override
  State<ProjectFormView> createState() => _ProjectFormViewState();
}

class _ProjectFormViewState extends State<ProjectFormView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _tags = TextEditingController();
  final _github = TextEditingController();
  final _demo = TextEditingController();
  bool _featured = false;
  bool _active = true;

  bool get _editing => widget.project != null;

  @override
  void initState() {
    super.initState();
    final project = widget.project;
    if (project != null) {
      _name.text = project.name ?? '';
      _description.text = project.description ?? '';
      _tags.text = project.tags?.join(', ') ?? '';
      _github.text = project.githubUrl;
      _demo.text = project.demoUrl ?? '';
      _featured = project.featured ?? false;
      _active = project.isActive ?? true;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _tags.dispose();
    _github.dispose();
    _demo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) => Scaffold(
        backgroundColor: _background,
        appBar: AppBar(backgroundColor: _background, foregroundColor: Colors.white, title: Text(_editing ? 'Editar proyecto' : 'Agregar proyecto')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            children: [
              Text(_editing ? 'Editar proyecto' : 'Nuevo proyecto', style: const TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w800)),
              const SizedBox(height: 7),
              const Text('Información que aparecerá en tu portafolio.', style: TextStyle(color: _muted, fontSize: 14)),
              const SizedBox(height: 25),
              _field(_name, 'Nombre', Icons.title_rounded),
              const SizedBox(height: 14),
              _field(_description, 'Descripción', Icons.description_outlined, maxLines: 5),
              const SizedBox(height: 14),
              _field(_tags, 'Tags separados por coma', Icons.sell_outlined),
              const SizedBox(height: 14),
              _field(_github, 'URL de GitHub', Icons.code_rounded, required: true, keyboardType: TextInputType.url),
              const SizedBox(height: 14),
              _field(_demo, 'URL de demo', Icons.language_rounded, keyboardType: TextInputType.url),
              SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Proyecto destacado', style: TextStyle(color: Colors.white)), value: _featured, activeColor: _gold, onChanged: (value) => setState(() => _featured = value)),
              SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Proyecto activo', style: TextStyle(color: Colors.white)), value: _active, activeColor: _gold, onChanged: (value) => setState(() => _active = value)),
              const SizedBox(height: 18),
              SizedBox(height: 52, child: FilledButton.icon(onPressed: widget.controller.isSaving ? null : _save, icon: widget.controller.isSaving ? const SizedBox(width: 19, height: 19, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Icon(Icons.save_outlined), label: Text(widget.controller.isSaving ? 'Guardando...' : _editing ? 'Guardar cambios' : 'Agregar proyecto'))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon, {bool required = false, TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
      decoration: _decoration(label, icon),
    );
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(labelText: label, labelStyle: const TextStyle(color: _muted), prefixIcon: Icon(icon, color: _gold, size: 20), filled: true, fillColor: _surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: _gold)));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final payload = {
      'nombre': _name.text.trim().isEmpty ? null : _name.text.trim(),
      'descripcion': _description.text.trim().isEmpty ? null : _description.text.trim(),
      'tags': _tags.text.trim().isEmpty ? null : _tags.text.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList(),
      'github_url': _github.text.trim(),
      'demo_url': _demo.text.trim().isEmpty ? null : _demo.text.trim(),
      'destacado': _featured,
      'estado': _active,
    };
    final error = _editing ? await widget.controller.updateProject(widget.project!.id, payload) : await widget.controller.createProject(payload);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pop();
  }
}

class ManualApiRequestPanel extends StatefulWidget {
  const ManualApiRequestPanel({required this.apiService, required this.logsController, super.key});

  final ApiService apiService;
  final LogsController logsController;

  @override
  State<ManualApiRequestPanel> createState() => _ManualApiRequestPanelState();
}

class _ManualApiRequestPanelState extends State<ManualApiRequestPanel> {
  final _url = TextEditingController(text: 'https://portafolio-basthianf.vercel.app/api/proyectos/getall');
  final _body = TextEditingController(text: '{}');
  String _method = 'GET';
  String _response = 'La respuesta aparecerá aquí.';
  bool _loading = false;

  @override
  void dispose() {
    _url.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(19), border: Border.all(color: const Color(0xFF292929))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.terminal_rounded, color: _gold, size: 20), SizedBox(width: 8), Text('Solicitud manual', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))]),
        const SizedBox(height: 6),
        const Text('Prueba cualquier endpoint de desarrollo.', style: TextStyle(color: _muted, fontSize: 12)),
        const SizedBox(height: 16),
        Row(children: [SizedBox(width: 105, child: DropdownButtonFormField<String>(value: _method, dropdownColor: _surfaceSoft, decoration: _manualDecoration('Método'), items: [for (final method in ['GET', 'POST', 'PUT', 'PATCH', 'DELETE']) DropdownMenuItem(value: method, child: Text(method))], onChanged: (value) => setState(() => _method = value!))), const SizedBox(width: 10), Expanded(child: TextField(controller: _url, style: const TextStyle(color: Colors.white, fontSize: 12), decoration: _manualDecoration('URL')))]),
        const SizedBox(height: 12),
        TextField(controller: _body, maxLines: 5, style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 12), decoration: _manualDecoration('JSON body')),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: _loading ? null : _send, icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: _gold)) : const Icon(Icons.send_rounded, size: 17), label: Text(_loading ? 'Enviando...' : 'Enviar solicitud'))),
        const SizedBox(height: 16),
        const Text('Respuesta', style: TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 7),
        Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)), child: SelectableText(_response, style: const TextStyle(color: Color(0xFFD5D5D5), fontFamily: 'monospace', fontSize: 11))),
      ]),
    );
  }

  InputDecoration _manualDecoration(String label) => InputDecoration(labelText: label, labelStyle: const TextStyle(color: _muted, fontSize: 12), filled: true, fillColor: _surfaceSoft, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12));

  Future<void> _send() async {
    setState(() {
      _loading = true;
      _response = 'Enviando...';
    });
    try {
      final response = await widget.apiService.manualRequest(method: _method, url: _url.text.trim(), body: _method == 'GET' ? null : _body.text.trim());
      setState(() => _response = 'HTTP ${response.statusCode}\n${response.body}');
      widget.logsController.add('$_method ${_url.text.trim()} · ${response.statusCode}');
    } catch (error) {
      setState(() => _response = 'ERROR\n$error');
      widget.logsController.add('$_method ${_url.text.trim()} · ERROR');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
