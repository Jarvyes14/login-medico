import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _edadController = TextEditingController();
  final _lugarNacimientoController = TextEditingController();
  final _padecimientosController = TextEditingController();
  
  // Asumo que estas clases tienen los métodos que necesitas.
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Carga inicial
    _loadUserData();
  }

  /// Función para cargar los datos del usuario.
  Future<void> _loadUserData() async {
    // Solo mostramos el indicador de carga si es la carga inicial o si se hace Pull to Refresh
    if (mounted && !_isSaving) {
      setState(() => _isLoading = true);
    }
    
    final user = _authService.currentUser;
    if (user != null) {
      final userData = await _firestoreService.getUser(user.uid);
      if (userData != null) {
        // Actualiza los controladores con los datos más recientes
        _nombreController.text = userData.nombre;
        _edadController.text = userData.edad?.toString() ?? '';
        _lugarNacimientoController.text = userData.lugarNacimiento ?? '';
        _padecimientosController.text = userData.padecimientos ?? '';
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  /// Función para guardar el perfil del usuario.
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final user = _authService.currentUser;
      if (user != null) {
        try {
          await _firestoreService.updateUser(user.uid, {
            'nombre': _nombreController.text,
            'edad': int.tryParse(_edadController.text),
            'lugar_nacimiento': _lugarNacimientoController.text,
            'padecimientos': _padecimientosController.text,
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Perfil actualizado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al actualizar perfil: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }

      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _edadController.dispose();
    _lugarNacimientoController.dispose();
    _padecimientosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mi Perfil',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading && !_isSaving // Muestra el loader solo en la carga inicial
          ? const Center(child: CircularProgressIndicator())
          // ************************************************
          // CAMBIO CLAVE 3: Implementar "Pull to Refresh" (downslide)
          : RefreshIndicator(
              onRefresh: _loadUserData, // Llama a la función de recarga
              color: Colors.blue[700],
              child: SingleChildScrollView(
                // Asegúrate de que el SingleChildScrollView tenga un Child que pueda
                // extenderse, como un Column, para que el Pull to Refresh funcione
                // incluso si el contenido no llena la pantalla.
                physics: const AlwaysScrollableScrollPhysics(), 
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blue[100],
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Nombre
                      TextFormField(
                        controller: _nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre completo',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Edad
                      TextFormField(
                        controller: _edadController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Edad',
                          prefixIcon: const Icon(Icons.cake_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final edad = int.tryParse(value);
                            if (edad == null || edad < 0 || edad > 120) {
                              return 'Ingresa una edad válida';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Lugar de nacimiento
                      TextFormField(
                        controller: _lugarNacimientoController,
                        decoration: InputDecoration(
                          labelText: 'Lugar de nacimiento',
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Padecimientos
                      TextFormField(
                        controller: _padecimientosController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Padecimientos o alergias',
                          prefixIcon: const Icon(Icons.medical_information_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Botón de guardar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Guardar cambios',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // ************************************************
    );
  }
}