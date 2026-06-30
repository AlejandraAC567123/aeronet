import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:aeronet_app_flutter/core/utils/app_state_provider.dart';
import 'package:aeronet_app_flutter/features/client/providers/client_provider.dart';
import 'package:aeronet_app_flutter/shared/widgets/app_page.dart';
import 'package:aeronet_app_flutter/shared/widgets/loading_widget.dart';
import 'package:aeronet_app_flutter/shared/widgets/error_state.dart';
import 'package:aeronet_app_flutter/shared/widgets/empty_state.dart';
import 'package:aeronet_app_flutter/features/client/widgets/ticket_card.dart';
import 'package:aeronet_app_flutter/shared/widgets/glass_container.dart';
import 'package:aeronet_app_flutter/core/constants/app_constants.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';
import 'package:aeronet_app_flutter/shared/extensions/string_extensions.dart';

class TicketsClientScreen extends StatelessWidget {
  const TicketsClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clientProvider = AppStateProvider.of<ClientProvider>(context);

    return AppPage(
      title: 'Soporte Técnico',
      subtitle: 'Mis Tickets y Consultas',
      actions: [
        IconButton(
          tooltip: 'Borradores Locales',
          icon: const Icon(Icons.drafts_outlined, color: Color(0xFF2DD4BF)),
          onPressed: () {
            clientProvider.loadLocalDrafts();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AppStateProvider<ClientProvider>(
                  notifier: clientProvider,
                  child: const DraftsListPage(),
                ),
              ),
            );
          },
        ),
        IconButton(
          tooltip: 'Nuevo Ticket',
          icon: const Icon(Icons.add_comment_outlined, color: Color(0xFF2DD4BF)),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AppStateProvider<ClientProvider>(
                  notifier: clientProvider,
                  child: const TicketFormPage(),
                ),
              ),
            );
          },
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () => clientProvider.loadMyTickets(),
        child: _buildList(context, clientProvider),
      ),
    );
  }

  Widget _buildList(BuildContext context, ClientProvider provider) {
    if (provider.isLoading && provider.myTickets.isEmpty) {
      return const LoadingWidget(message: 'Cargando tus tickets...');
    }

    if (provider.errorMessage != null) {
      return ErrorState(
        error: provider.errorMessage!,
        onRetry: () => provider.loadMyTickets(),
      );
    }

    if (provider.myTickets.isEmpty) {
      return const EmptyState(
        text: 'No tienes tickets de soporte registrados. Si tienes algún inconveniente, crea uno nuevo.',
        icon: Icons.chat_bubble_outline_rounded,
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
      itemCount: provider.myTickets.length,
      itemBuilder: (context, index) {
        return TicketCard(ticket: provider.myTickets[index]);
      },
    );
  }
}

// Sub Page: Ticket Creator Form with speech to text
class TicketFormPage extends StatefulWidget {
  const TicketFormPage({super.key, this.initialSubject, this.initialDescription, this.initialCategory});

  final String? initialSubject;
  final String? initialDescription;
  final String? initialCategory;

  @override
  State<TicketFormPage> createState() => _TicketFormPageState();
}

class _TicketFormPageState extends State<TicketFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _subjectController;
  late final TextEditingController _descriptionController;
  late String _selectedCategory;
  String _selectedPriority = 'medium';
  
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.initialSubject);
    _descriptionController = TextEditingController(text: widget.initialDescription);
    _selectedCategory = widget.initialCategory ?? AppConstants.ticketCategories.first;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    try {
      bool available = await _speech.initialize(
        onError: (val) => debugPrint('onError: $val'),
        onStatus: (val) => debugPrint('onStatus: $val'),
      );

      if (available) {
        setState(() => _isListening = true);
        await _speech.listen(
          localeId: 'es_PE',
          onResult: (val) {
            setState(() {
              _descriptionController.text = val.recognizedWords;
            });
          },
        );
      } else {
        if (mounted) showMessage(context, 'El dictado por voz no está disponible en este dispositivo.');
      }
    } catch (e) {
      if (mounted) showMessage(context, 'Error de SpeechToText: $e');
    }
  }

  Future<void> _saveAsDraft(ClientProvider provider) async {
    if (_subjectController.text.trim().isEmpty && _descriptionController.text.trim().isEmpty) {
      showMessage(context, 'Escribe al menos el asunto o la descripción para guardar un borrador.');
      return;
    }

    try {
      await provider.saveDraftTicket(
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
      );
      if (mounted) {
        showMessage(context, 'Borrador guardado localmente en SQLite.');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) showMessage(context, 'Error al guardar borrador: $e');
    }
  }

  Future<void> _submit(ClientProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      await provider.createSupportTicket(
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
      );
      if (mounted) {
        showMessage(context, '¡Ticket de soporte creado!');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) showMessage(context, e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = AppStateProvider.of<ClientProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Nuevo Ticket',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w800,
            color: Color(0xFFF2F4FA),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: const Color(0xFF10131F),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Crear Ticket de Soporte',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Describe tu consulta. Puedes presionar el micrófono para dictar la descripción por voz.',
                    style: TextStyle(fontSize: 13, color: Colors.white60),
                  ),
                  const SizedBox(height: 24),
                  
                  // Subject
                  TextFormField(
                    controller: _subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Asunto o Título',
                      prefixIcon: Icon(Icons.title_outlined),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Por favor ingresa un asunto'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    dropdownColor: const Color(0xFF1A1E30),
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    items: AppConstants.ticketCategories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat.cleanStatus()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Priority Segment
                  const Text(
                    'Prioridad del Ticket',
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'low', label: Text('Baja')),
                      ButtonSegment(value: 'medium', label: Text('Media')),
                      ButtonSegment(value: 'high', label: Text('Alta')),
                    ],
                    selected: {_selectedPriority},
                    onSelectionChanged: (val) {
                      setState(() {
                        _selectedPriority = val.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description input with Mic icon for Speech-to-Text
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      labelText: 'Descripción detallada',
                      alignLabelWithHint: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 90.0),
                        child: Icon(Icons.description_outlined),
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(bottom: 90.0),
                        child: IconButton(
                          tooltip: _isListening ? 'Detener dictado' : 'Iniciar dictado',
                          icon: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: _isListening ? Colors.redAccent : const Color(0xFF2DD4BF),
                          ),
                          onPressed: _toggleListening,
                        ),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Por favor ingresa la descripción del problema'
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // Actions buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _submitting ? null : () => _saveAsDraft(clientProvider),
                          icon: const Icon(Icons.save_outlined, size: 16),
                          label: const Text('Borrador SQLite'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _submitting ? null : () => _submit(clientProvider),
                          icon: _submitting
                              ? const SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.send_outlined, size: 16),
                          label: const Text('Enviar Ticket'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Sub Page: Local Drafts Browser
class DraftsListPage extends StatelessWidget {
  const DraftsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final clientProvider = AppStateProvider.of<ClientProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Borradores Locales',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w800,
            color: Color(0xFFF2F4FA),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: const Color(0xFF10131F),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: clientProvider,
            builder: (context, _) {
              if (clientProvider.localDrafts.isEmpty) {
                return const EmptyState(
                  text: 'No tienes borradores locales guardados.',
                  icon: Icons.drafts_outlined,
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: clientProvider.localDrafts.length,
                itemBuilder: (context, index) {
                  final draft = clientProvider.localDrafts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  draft.subject.isNotEmpty ? draft.subject : 'Borrador sin título',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                onPressed: () => clientProvider.deleteDraft(draft.id!),
                              ),
                            ],
                          ),
                          Text(
                            'Categoría: ${draft.category.cleanStatus()}',
                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          if (draft.description.isNotEmpty) ...[
                            Text(
                              draft.description,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${draft.createdAt.day}/${draft.createdAt.month}/${draft.createdAt.year}',
                                style: const TextStyle(color: Colors.white30, fontSize: 11),
                              ),
                              TextButton.icon(
                                style: TextButton.styleFrom(foregroundColor: const Color(0xFF2DD4BF)),
                                icon: const Icon(Icons.edit_note_outlined, size: 16),
                                label: const Text('Cargar', style: TextStyle(fontSize: 12)),
                                onPressed: () {
                                  // Open form page with draft content
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => AppStateProvider<ClientProvider>(
                                        notifier: clientProvider,
                                        child: TicketFormPage(
                                          initialSubject: draft.subject,
                                          initialDescription: draft.description,
                                          initialCategory: draft.category,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
